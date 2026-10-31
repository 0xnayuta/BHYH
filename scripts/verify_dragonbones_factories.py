#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/verify_dragonbones_factories.py

DragonBones 工厂加载门禁：逐个 `load()` `.dbfactory`，捕获「文件存在但加载即崩」的资源。

背景
----
`DragonBonesFactory.set_dragon_bones_ske_file_list` 在 C++ 层解析 ske/tex，遇到
特定 `zOrder` timeline 会直接终止进程（退出码 5），GDScript 层无法 try/catch。
因此必须在独立子进程里验证，崩掉的批次再对半二分定位到个体。

检查范围
--------
1. `source/Art/**/*.dbfactory` 能否被 `load()` 成功；
2. 有 `*_ske.json` 但一直没有 `.dbfactory` 的目录（插件解析失败的典型表现，始终检查）。

增量
----
默认按 mtime/size 缓存跳过未变化的工厂（与 `format_all.py` 同款：缓存落在
`.godot/dragonbones_factory_cache.json`）；`--all` 强制全量，发布前使用。
缓存记录工具 schema 版本，脚本逻辑变更后自动全量。

性能
----
- 路径清单写入临时文件由 GDScript 读取，避开 Windows 32k 命令行上限；
- 单进程可连续加载数千个工厂（实测 3,627 个约 29 s）；
- 失败批对半二分，单个坏资源只需 log2(batch) 次额外运行。

边界
----
- 公开 clone 不含 `source/Art/`：检测不到骨骼目录时直接跳过并返回成功；
- 需要 Godot 4.7.2；通过 `--godot` 或 `GODOT_BIN` 指定，不内置绝对路径；
- 只读资源；报告写入 `docs/reports/`，缓存写入 `.godot/`。
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PROJECT = REPO_ROOT / "source"
REPORT_PATH = REPO_ROOT / "docs" / "reports" / "dragonbones_factory_verify.json"
CACHE_REL = Path(".godot") / "dragonbones_factory_cache.json"
CACHE_SCHEMA = 1

LOADER = """extends SceneTree
func _init():
	var list_path: String = OS.get_cmdline_user_args()[0]
	var f := FileAccess.open(list_path, FileAccess.READ)
	if f == null:
		print("LIST_OPEN_FAIL")
		quit(2)
		return
	var bases: Array[String] = []
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line != "":
			bases.append(line)
	f.close()
	for base in bases:
		if load(base + ".dbfactory") != null:
			print("LOAD_OK ", base)
		else:
			print("LOAD_FAIL ", base)
	quit()
"""


def resolve_godot(explicit: str | None) -> str:
    candidates = [explicit, os.environ.get("GODOT_BIN"), "godot", "godot4"]
    for candidate in candidates:
        if not candidate:
            continue
        path = Path(candidate)
        if path.is_file():
            return str(path)
        found = shutil.which(candidate)
        if found:
            return str(found)
    raise SystemExit("未找到 Godot 可执行文件，请使用 --godot 或设置 GODOT_BIN。")


def collect_factories(project: Path, only_zorder: bool) -> list[tuple[str, Path]]:
    """返回 [(res:// 基路径, dbfactory 磁盘路径)]。"""
    art = project / "Art"
    items: list[tuple[str, Path]] = []
    for factory in sorted(art.rglob("*.dbfactory")):
        base = factory.with_suffix("")
        if only_zorder:
            ske = base.with_name(base.name + "_ske.json")
            if not ske.is_file() or "\"zOrder\"" not in ske.read_text(encoding="utf-8", errors="ignore"):
                continue
        items.append(("res://" + factory.relative_to(project).with_suffix("").as_posix(), factory))
    return items


def missing_factories(project: Path) -> list[str]:
    """有 `*_ske.json` 却没有同名 `.dbfactory` 的目录。"""
    art = project / "Art"
    missing: list[str] = []
    for ske in sorted(art.rglob("*_ske.json")):
        if not ske.with_name(ske.name.replace("_ske.json", ".dbfactory")).is_file():
            missing.append("res://" + ske.parent.relative_to(project).as_posix())
    return missing


def load_cache(cache_path: Path) -> dict:
    if not cache_path.exists():
        return {}
    try:
        data = json.loads(cache_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    if data.get("schema") != CACHE_SCHEMA:
        return {}
    return data


def save_cache(cache_path: Path, entries: dict) -> None:
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    cache_path.write_text(
        json.dumps({"schema": CACHE_SCHEMA, "entries": entries}, ensure_ascii=False, indent=1) + "\n",
        encoding="utf-8", newline="\n")


def select_pending(items: list[tuple[str, Path]], cache_entries: dict,
                   force_all: bool) -> tuple[list[tuple[str, Path]], int]:
    """按 mtime/size 过滤；返回 (待验证列表, 缓存命中数)。"""
    if force_all:
        return items, 0
    pending: list[tuple[str, Path]] = []
    hits = 0
    for base, path in items:
        try:
            st = path.stat()
        except OSError:
            pending.append((base, path))
            continue
        rec = cache_entries.get(base)
        if rec and rec[0] == st.st_mtime and rec[1] == st.st_size:
            hits += 1
        else:
            pending.append((base, path))
    return pending, hits


def run_batch(godot: str, project: Path, loader: Path, workdir: Path,
              bases: list[str], timeout: int) -> bool:
    listing = workdir / "bases.txt"
    listing.write_text("\n".join(bases) + "\n", encoding="utf-8", newline="\n")
    cmd = [godot, "--headless", "--path", str(project), "--script", str(loader), "--", str(listing)]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, errors="ignore", timeout=timeout)
    except subprocess.TimeoutExpired:
        return False
    return proc.returncode == 0 and all(f"LOAD_OK {b}" in proc.stdout for b in bases)


def isolate(godot: str, project: Path, loader: Path, workdir: Path,
            chunk: list[str], timeout: int, failures: list[str]) -> None:
    if run_batch(godot, project, loader, workdir, chunk, timeout):
        return
    if len(chunk) == 1:
        failures.append(chunk[0])
        return
    mid = len(chunk) // 2
    isolate(godot, project, loader, workdir, chunk[:mid], timeout, failures)
    isolate(godot, project, loader, workdir, chunk[mid:], timeout, failures)


def main() -> int:
    parser = argparse.ArgumentParser(description="DragonBones 工厂加载门禁")
    parser.add_argument("--project", default=str(DEFAULT_PROJECT), help="Godot 工程目录 (默认: source)")
    parser.add_argument("--godot", default=None, help="Godot 4.7.2 可执行文件")
    parser.add_argument("--filter", choices=["all", "zorder"], default="all",
                        help="all=全部工厂；zorder=只测 ske 含 zOrder timeline 的资源")
    parser.add_argument("--all", action="store_true", help="忽略增量缓存，验证全部工厂（发布前使用）")
    parser.add_argument("--no-cache", action="store_true", help="忽略缓存读写，且不更新缓存")
    parser.add_argument("--batch", type=int, default=900, help="单进程验证的工厂数")
    parser.add_argument("--timeout", type=int, default=600, help="单批超时秒数")
    parser.add_argument("--strict-missing", action="store_true",
                        help="把「有 ske 但无 dbfactory」也计为失败（默认只报告）")
    parser.add_argument("--json", action="store_true", help="以 JSON 输出结果")
    args = parser.parse_args()

    project = Path(args.project).resolve()
    if not (project / "Art").is_dir():
        print("[skip] 未找到 source/Art（公开 clone 不含素材），跳过 DragonBones 工厂门禁。")
        return 0

    started = time.time()
    items = collect_factories(project, args.filter == "zorder")
    missing = missing_factories(project)

    cache_path = project / CACHE_REL
    cache = {} if args.no_cache else load_cache(cache_path)
    cache_entries: dict = cache.get("entries", {}) if cache else {}

    if not items:
        print("[skip] 未找到 .dbfactory。")
        payload = {"checked": 0, "failures": [], "missing_dbfactory": missing, "skipped": True}
        REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
        REPORT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        return 0

    pending, cached_hits = select_pending(items, cache_entries, args.all or args.no_cache)
    fetched_entries = dict(cache_entries)
    passed = cached_hits
    failures: list[str] = []

    if pending:
        godot = resolve_godot(args.godot)
        workdir = Path(tempfile.mkdtemp(prefix="dbf_verify_"))
        loader = workdir / "dbf_verify_loader.gd"
        loader.write_text(LOADER, encoding="utf-8", newline="\n")
        try:
            for start in range(0, len(pending), args.batch):
                chunk = pending[start:start + args.batch]
                bases = [base for base, _ in chunk]
                if run_batch(godot, project, loader, workdir, bases, args.timeout):
                    passed += len(chunk)
                    for base, path in chunk:
                        st = path.stat()
                        fetched_entries[base] = [st.st_mtime, st.st_size]
                    print(f"  [{start + len(chunk)}/{len(pending)}] 通过")
                    continue
                print(f"  [{start + len(chunk)}/{len(pending)}] 批失败，二分定位 {len(chunk)} 个")
                before = len(failures)
                mid = len(chunk) // 2
                isolate(godot, project, loader, workdir, [b for b, _ in chunk[:mid]], args.timeout, failures)
                isolate(godot, project, loader, workdir, [b for b, _ in chunk[mid:]], args.timeout, failures)
                failed_in_chunk = set(failures[before:])
                for base, path in chunk:
                    if base in failed_in_chunk:
                        fetched_entries.pop(base, None)
                        continue
                    st = path.stat()
                    fetched_entries[base] = [st.st_mtime, st.st_size]
                passed += len(chunk) - len(failed_in_chunk)
        finally:
            shutil.rmtree(workdir, ignore_errors=True)
        if not args.no_cache:
            save_cache(cache_path, fetched_entries)

    elapsed = time.time() - started
    payload = {
        "checked": len(pending),
        "candidates": len(items),
        "cached": cached_hits,
        "passed": passed,
        "mode": "full" if (args.all or args.no_cache) else "incremental",
        "filter": args.filter,
        "elapsed_seconds": round(elapsed, 2),
        "failures": failures,
        "missing_dbfactory": missing,
    }
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if args.json:
        print(json.dumps(payload, ensure_ascii=False))
    else:
        mode = "全量" if payload["mode"] == "full" else "增量"
        print(f"\n[{mode}] 候选 {len(items)} 个，缓存命中 {cached_hits} 个，"
              f"本次验证 {len(pending)} 个：通过 {passed}，失败 {len(failures)}，"
              f"{len(missing)} 个未生成，用时 {elapsed:.1f}s")
        print(f"报告 → {REPORT_PATH.relative_to(REPO_ROOT)}")
        for item in failures:
            print(f"  [失败] {item}")
        for item in missing:
            print(f"  [未生成] {item}")

    if failures:
        return 1
    if args.strict_missing and missing:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

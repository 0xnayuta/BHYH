#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FrameSequence 发布包闭包探针：实际导出 PCK，并交给 Godot 自己校验包内路径。

源目录闭包与 export_presets.cfg 声明覆盖都不等于发布包完整；本探针必须看到
真实 PCK 中的 Catalog、每个序列资源与全部延迟纹理路径。

不使用自写的 PCK 二进制解析器：PCK 头格式随引擎版本变化，误判会制造假通过或
假失败。改为在最小空工程中挂载 PCK，用引擎的 FileAccess 判定路径是否存在。

退出码：
- 0 已验证：PCK 内包含全部依赖；
- 1 验证失败：PCK 缺少依赖或探针脚本异常；
- 2 无法验证：缺少 Godot、导出预设，或导出未产生 PCK，未产生任何“通过”结论。
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
MANIFEST_PATHS = (
    SOURCE / "Art/frame_sequences/frame_sequence_export_dependencies.json",
    SOURCE / "Script/data/level_preload_export_dependencies.json",
)
EXPORT_PRESETS_PATH = SOURCE / "export_presets.cfg"
RESULT_PREFIX = "PACK_PROBE_RESULT="

PROBE_PROJECT = """config_version=5

[application]
config/name="bhyh_pack_probe"
"""

PROBE_SCRIPT = """extends SceneTree

const RESULT_PREFIX := "%s"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		print(RESULT_PREFIX + JSON.stringify({"ok": false, "error": "usage: <pck> <manifest>"}))
		quit(2)
		return
	var pck_path := args[0]
	var manifest_path := args[1]
	var manifest_file := FileAccess.open(manifest_path, FileAccess.READ)
	if manifest_file == null:
		print(RESULT_PREFIX + JSON.stringify({"ok": false, "error": "manifest unreadable"}))
		quit(2)
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	if not parsed is Dictionary:
		print(RESULT_PREFIX + JSON.stringify({"ok": false, "error": "manifest not an object"}))
		quit(2)
		return
	var manifest: Dictionary = parsed
	var required: Array[String] = []
	var items: Variant = manifest.get("required", [])
	if not items is Array:
		print(RESULT_PREFIX + JSON.stringify({"ok": false, "error": "manifest.required is not an array"}))
		quit(2)
		return
	for item in items:
		required.append(str(item))
	if not ProjectSettings.load_resource_pack(pck_path, true):
		print(RESULT_PREFIX + JSON.stringify({"ok": false, "error": "load_resource_pack failed"}))
		quit(1)
		return
	# 导出会把源文件重写为 *.remap、*.import 或导入容器（.ctex）；
	# 判定“资源可加载”必须走引擎的 ResourceLoader，而不是 FileAccess 的原始路径。
	var missing: Array[String] = []
	var imported: int = 0
	for path in required:
		if FileAccess.file_exists(path):
			continue
		if FileAccess.file_exists(path + ".remap") or FileAccess.file_exists(path + ".import"):
			imported += 1
			continue
		if ResourceLoader.exists(path):
			imported += 1
			continue
		missing.append(path)
	print(
		RESULT_PREFIX
		+ JSON.stringify(
			{"ok": missing.is_empty(), "required": required.size(), "imported": imported, "missing": missing}
		)
	)
	quit(0 if missing.is_empty() else 1)
""" % RESULT_PREFIX


def normalize(path: str) -> str:
    return path.replace("\\", "/")


def required_paths(manifest: dict[str, object]) -> list[str]:
    paths: list[str] = []
    catalog = str(manifest.get("catalog", ""))
    if catalog:
        paths.append(catalog)
    for key in (
        "sequences",
        "deferred_textures",
        "monster_scenes",
        "dynamic_monster_scenes",
        "bullet_scenes",
        "dynamic_textures",
    ):
        items = manifest.get(key, [])
        if isinstance(items, list):
            paths.extend(str(item) for item in items)
    return paths


def resolve_godot(explicit: str | None) -> str | None:
    candidate = explicit or os.environ.get("GODOT_BIN", "")
    if candidate and Path(candidate).is_file():
        return candidate
    for name in ("godot", "godot4", "Godot"):
        found = shutil.which(name)
        if found:
            return found
    return None


def find_preset_name() -> str:
    if not EXPORT_PRESETS_PATH.is_file():
        raise FileNotFoundError(f"缺少导出预设: {EXPORT_PRESETS_PATH.relative_to(ROOT)}")
    text = EXPORT_PRESETS_PATH.read_text(encoding="utf-8-sig")
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("name="):
            return stripped.split("=", 1)[1].strip().strip('"')
    raise ValueError("export_presets.cfg 未找到预设名称")


def run_export(godot: str, preset: str, output: Path, timeout: int) -> str | None:
    """返回失败原因；None 表示导出产生了 PCK。"""
    command = [godot, "--headless", "--path", str(SOURCE), "--export-pack", preset, str(output)]
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout
        )
    except subprocess.TimeoutExpired:
        return f"导出在 {timeout}s 内未完成"
    if output.is_file():
        return None
    detail = (result.stderr or result.stdout or "").strip().splitlines()
    return detail[-1] if detail else f"退出码 {result.returncode}"


def run_probe(godot: str, pck: Path, manifest_copy: Path, timeout: int) -> tuple[int, dict[str, object], str]:
    workdir = Path(tempfile.mkdtemp(prefix="bhyh_pack_probe_proj_"))
    try:
        (workdir / "project.godot").write_text(PROBE_PROJECT, encoding="utf-8", newline="\n")
        (workdir / "pack_probe.gd").write_text(PROBE_SCRIPT, encoding="utf-8", newline="\n")
        command = [
            godot,
            "--headless",
            "--path",
            str(workdir),
            "--script",
            "res://pack_probe.gd",
            "--",
            str(pck),
            str(manifest_copy),
        ]
        try:
            result = subprocess.run(
                command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout
            )
        except subprocess.TimeoutExpired:
            return 2, {}, f"包内校验在 {timeout}s 内未完成"
        for line in (result.stdout or "").splitlines():
            if line.startswith(RESULT_PREFIX):
                try:
                    payload = json.loads(line[len(RESULT_PREFIX) :])
                except json.JSONDecodeError:
                    break
                if isinstance(payload, dict):
                    return 0, payload, ""
        stderr = (result.stderr or "").strip().splitlines()
        return 2, {}, stderr[-1] if stderr else "探针未输出结果"
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


def load_manifests(paths: list[Path]) -> list[dict[str, object]]:
    manifests: list[dict[str, object]] = []
    for path in paths:
        if not path.is_file():
            raise FileNotFoundError(f"缺少发布依赖清单: {path.relative_to(ROOT)}")
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise ValueError(f"发布依赖清单不是 JSON 对象: {path.relative_to(ROOT)}")
        manifests.append(data)
    return manifests


def combined_required(manifests: list[dict[str, object]]) -> list[str]:
    paths = [path for manifest in manifests for path in required_paths(manifest)]
    return list(dict.fromkeys(paths))


def self_test(paths: list[Path] | None = None) -> int:
    """不依赖 Godot：验证清单可解析且必需路径结构正确。"""
    manifest_paths = paths or list(MANIFEST_PATHS)
    try:
        manifests = load_manifests(manifest_paths)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"[FAIL] 发布依赖清单自检失败: {error}", file=sys.stderr)
        return 1
    required = combined_required(manifests)
    problems: list[str] = []
    for manifest in manifests:
        if not str(manifest.get("catalog", "")).startswith("res://"):
            problems.append("catalog 不是 res:// 路径")
        raw = [normalize(path) for path in required_paths(manifest)]
        if len(raw) != len(set(raw)):
            problems.append("单份清单包含重复路径")
    if len(required) < 2:
        problems.append("依赖路径数量不足")
    bad = [path for path in required if not path.startswith("res://")]
    if bad:
        problems.append(f"非 res:// 路径: {bad[:3]}")
    if problems:
        for problem in problems:
            print(f"[FAIL] {problem}", file=sys.stderr)
        return 1
    print(
        f"[OK] 发布依赖清单自检通过: {len(required)} 条路径"
        f"（{len(manifests)} 份清单：FrameSequence + 关卡预载）"
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="发布包依赖闭包探针（FrameSequence + 关卡预载）")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径（或设 GODOT_BIN）")
    parser.add_argument("--preset", default=None, help="导出预设名称；默认取第一个预设")
    parser.add_argument("--manifest", action="append", default=None, help="依赖清单路径；可重复，默认读取两份构建清单")
    parser.add_argument("--self-test", action="store_true", help="只校验依赖清单结构")
    parser.add_argument("--report", default=None, help="可选 JSON 报告输出路径")
    parser.add_argument("--export-timeout", type=int, default=900, help="导出子进程墙钟上限（秒）")
    parser.add_argument("--probe-timeout", type=int, default=300, help="包内校验子进程墙钟上限（秒）")
    args = parser.parse_args()
    manifest_paths = [Path(item) for item in args.manifest] if args.manifest else list(MANIFEST_PATHS)

    if args.self_test:
        return self_test(manifest_paths)

    try:
        manifests = load_manifests(manifest_paths)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        print(
            "[FAIL] 先运行 python scripts/convert_frame_sequences.py 与 "
            "python scripts/convert_level_preload_catalog.py 生成清单",
            file=sys.stderr,
        )
        return 2
    expected = [normalize(path) for path in combined_required(manifests)]

    godot = resolve_godot(args.godot)
    if godot is None:
        print("[BLOCKED] 未找到 Godot 可执行文件，无法导出 PCK；本项不得记为通过", file=sys.stderr)
        return 2
    try:
        preset = args.preset or find_preset_name()
    except (OSError, ValueError) as error:
        print(f"[BLOCKED] {error}", file=sys.stderr)
        return 2

    workdir = Path(tempfile.mkdtemp(prefix="bhyh_pack_probe_"))
    pck_path = workdir / "publish_probe.pck"
    manifest_copy = workdir / "manifest.json"
    manifest_copy.write_text(
        json.dumps({"required": expected}, ensure_ascii=False), encoding="utf-8"
    )
    try:
        failure = run_export(godot, preset, pck_path, max(args.export_timeout, 1))
        if failure is not None:
            print(f"[BLOCKED] 导出未产生 PCK，无法验证发布闭包: {failure}", file=sys.stderr)
            print("[BLOCKED] 常见原因：缺少导出模板（编辑器 Install Export Templates）", file=sys.stderr)
            return 2
        status, payload, error = run_probe(
            godot, pck_path.resolve(), manifest_copy.resolve(), max(args.probe_timeout, 1)
        )
        if status != 0 or not payload:
            print(f"[BLOCKED] 包内校验未取得结果: {error}", file=sys.stderr)
            return 2
        missing = [str(item) for item in payload.get("missing", [])]
        digest_handle = hashlib.sha256()
        with pck_path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1 << 20), b""):
                digest_handle.update(chunk)
        report = {
            "preset": preset,
            "manifests": [str(path.relative_to(ROOT)) for path in manifest_paths],
            "pck_bytes": pck_path.stat().st_size,
            "pck_sha256": digest_handle.hexdigest(),
            "required_paths": len(expected),
            "missing": missing[:50],
            "missing_count": len(missing),
        }
        if args.report:
            report_path = Path(args.report)
            report_path.parent.mkdir(parents=True, exist_ok=True)
            report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        if missing:
            print(
                f"[FAIL] PCK 缺少 {len(missing)}/{len(expected)} 条发布依赖，例如: "
                + ", ".join(missing[:5]),
                file=sys.stderr,
            )
            return 1
        print(
            f"[OK] PCK 闭包验证通过: {len(expected)} 条发布依赖全部在包内，"
            f"PCK {report['pck_bytes']} 字节，sha256 {report['pck_sha256'][:12]}"
        )
        return 0
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())

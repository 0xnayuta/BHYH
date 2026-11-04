#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""原始数据导出闭包探针：实际导出 PCK 并逐条验证清单内 JSON/BIN。

与 frame_sequence_pack_probe.py 使用同一套“最小工程挂载 PCK + 引擎
FileAccess 判定”方法，但读取的是 export_raw_dependencies.json。这里验证的是
实际包，不是 export_presets.cfg 或插件声明。

退出码：0 PASS；1 清单/包内文件缺失；2 BLOCKED（缺 Godot、模板或清单）。
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from tool_common import ROOT, SOURCE, resolve_godot, write_json
from frame_sequence_pack_probe import find_preset_name, run_probe

MANIFEST_PATH = SOURCE / "Script" / "data" / "export_raw_dependencies.json"
EXPORT_MARKER = "BHYH_RAW_EXPORT"


def load_manifest(path: Path) -> list[str]:
    if not path.is_file():
        raise FileNotFoundError(f"缺少原始数据清单: {path.relative_to(ROOT)}")
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("schema_id") != "export_raw_dependencies":
        raise ValueError("原始数据清单 schema 不匹配")
    files = data.get("files")
    if not isinstance(files, list) or not files:
        raise ValueError("原始数据清单 files 为空或不是数组")
    paths: list[str] = []
    for entry in files:
        if not isinstance(entry, dict):
            raise ValueError("原始数据清单条目不是对象")
        path_text = normalize(str(entry.get("path", "")))
        if not path_text.startswith("res://"):
            raise ValueError(f"原始数据路径不是 res://: {path_text}")
        paths.append(path_text)
    if len(paths) != len(set(paths)):
        raise ValueError("原始数据清单包含重复路径")
    return paths


def export_pack(godot: str, preset: str, output: Path, timeout: int) -> tuple[str | None, str]:
    command = [godot, "--headless", "--path", str(SOURCE), "--export-pack", preset, str(output)]
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout
        )
    except subprocess.TimeoutExpired:
        return f"导出在 {timeout}s 内未完成", ""
    output_text = (result.stdout or "") + (result.stderr or "")
    if not output.is_file():
        detail = output_text.strip().splitlines()
        return (detail[-1] if detail else f"导出退出码 {result.returncode}"), output_text
    return None, output_text


def parse_plugin_marker(output: str) -> tuple[int | None, int | None, int | None]:
    for line in output.splitlines():
        if not line.startswith(EXPORT_MARKER):
            continue
        fields: dict[str, int] = {}
        for part in line[len(EXPORT_MARKER) :].strip().split():
            if "=" not in part:
                continue
            key, value = part.split("=", 1)
            try:
                fields[key] = int(value)
            except ValueError:
                continue
        return fields.get("files"), fields.get("expected"), fields.get("missing")
    return None, None, None


def main() -> int:
    parser = argparse.ArgumentParser(description="原始数据 PCK 闭包探针")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径（或 GODOT_BIN）")
    parser.add_argument("--preset", default=None, help="导出预设名称；默认取第一个预设")
    parser.add_argument("--manifest", default=str(MANIFEST_PATH), help="原始数据清单路径")
    parser.add_argument("--report", default=None, help="可选 JSON 报告路径")
    parser.add_argument("--self-test", action="store_true", help="只校验清单结构，不导出")
    parser.add_argument("--export-timeout", type=int, default=1800)
    parser.add_argument("--probe-timeout", type=int, default=300)
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    try:
        expected = load_manifest(manifest_path)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1

    if args.self_test:
        print(f"[OK] 原始数据清单结构通过: {len(expected)} 条路径")
        return 0

    godot = resolve_godot(args.godot)
    if godot is None:
        print("[BLOCKED] 未找到 Godot，无法导出 PCK；本项不得记为通过", file=sys.stderr)
        return 2
    try:
        preset = args.preset or find_preset_name()
    except (OSError, ValueError) as error:
        print(f"[BLOCKED] {error}", file=sys.stderr)
        return 2

    workdir = Path(tempfile.mkdtemp(prefix="bhyh_raw_pack_probe_"))
    pck_path = workdir / "raw_data_probe.pck"
    probe_manifest = workdir / "required.json"
    probe_manifest.write_text(json.dumps({"required": expected}, ensure_ascii=False), encoding="utf-8")
    try:
        failure, output_text = export_pack(
            godot, preset, pck_path, max(args.export_timeout, 1)
        )
        if failure is not None:
            print(f"[BLOCKED] 导出未产生 PCK: {failure}", file=sys.stderr)
            print("[BLOCKED] 常见原因：缺少导出模板，或导出插件/预设未加载", file=sys.stderr)
            return 2
        plugin_files, plugin_expected, plugin_missing = parse_plugin_marker(output_text)
        if plugin_files is None:
            print("[FAIL] 导出日志缺少 BHYH_RAW_EXPORT 标记，插件可能未启用", file=sys.stderr)
            return 1
        if plugin_missing != 0 or plugin_files != plugin_expected:
            print(
                f"[FAIL] 导出插件未完整写入原始数据: files={plugin_files} "
                f"expected={plugin_expected} missing={plugin_missing}",
                file=sys.stderr,
            )
            return 1

        status, payload, error = run_probe(
            godot, pck_path.resolve(), probe_manifest.resolve(), max(args.probe_timeout, 1)
        )
        if status != 0 or not payload:
            print(f"[BLOCKED] 包内校验未取得结果: {error}", file=sys.stderr)
            return 2
        missing = [str(item) for item in payload.get("missing", [])]
        digest = hashlib.sha256()
        with pck_path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1 << 20), b""):
                digest.update(chunk)
        report = {
            "preset": preset,
            "manifest": str(manifest_path.resolve().relative_to(ROOT)),
            "pck_bytes": pck_path.stat().st_size,
            "pck_sha256": digest.hexdigest(),
            "required_paths": len(expected),
            "plugin_files": plugin_files,
            "plugin_expected": plugin_expected,
            "missing": missing[:50],
            "missing_count": len(missing),
        }
        if args.report:
            write_json(Path(args.report), report)
        if missing:
            print(
                f"[FAIL] PCK 缺少 {len(missing)}/{len(expected)} 条原始数据，例如: "
                + ", ".join(missing[:5]),
                file=sys.stderr,
            )
            return 1
        print(
            f"[OK] 原始数据 PCK 闭包通过: {len(expected)} 条路径全部在包内，"
            f"PCK {report['pck_bytes']} 字节，sha256 {report['pck_sha256'][:12]}"
        )
        return 0
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())

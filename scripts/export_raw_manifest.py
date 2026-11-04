#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""原始数据导出闭包清单：从手工评审的根配置生成精确文件清单。

运行时通过 FileAccess 读取的 JSON/BIN 不是 Godot Resource，``all_resources``
不保证把它们放进 PCK。本脚本是清单的唯一生成入口；编辑器导出插件和 PCK
探针都只消费生成后的清单，避免导出配置、插件与测试各自维护路径。

用法：
    python scripts/export_raw_manifest.py --write
    python scripts/export_raw_manifest.py --check
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
CONFIG_PATH = ROOT / "scripts" / "export_raw_roots.json"
MANIFEST_PATH = SOURCE / "Script" / "data" / "export_raw_dependencies.json"
PROJECT_GODOT = SOURCE / "project.godot"
EXPORT_PRESETS = SOURCE / "export_presets.cfg"
PLUGIN_PATH = "res://addons/bhyh_export/plugin.cfg"


def _res_to_path(value: str) -> Path:
    if not value.startswith("res://"):
        raise ValueError(f"路径必须以 res:// 开头: {value}")
    return SOURCE / value[len("res://") :]


def _path_to_res(path: Path) -> str:
    return "res://" + path.relative_to(SOURCE).as_posix()


def load_config() -> dict:
    data = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("export_raw_roots.json 不是 JSON 对象")
    if data.get("schema_id") != "export_raw_roots" or data.get("schema_version") != 1:
        raise ValueError("export_raw_roots.json schema 不匹配")
    roots = data.get("roots", [])
    files = data.get("files", [])
    if not isinstance(roots, list) or not isinstance(files, list):
        raise ValueError("roots/files 必须是数组")
    for entry in roots:
        if not isinstance(entry, dict) or not str(entry.get("path", "")).startswith("res://"):
            raise ValueError(f"无效 root: {entry!r}")
        extensions = entry.get("extensions", [])
        if not isinstance(extensions, list) or not extensions:
            raise ValueError(f"root 缺少 extensions: {entry!r}")
        if any(not isinstance(ext, str) or not ext.startswith(".") for ext in extensions):
            raise ValueError(f"extensions 必须带点号: {entry!r}")
    for entry in files:
        if not isinstance(entry, dict) or not str(entry.get("path", "")).startswith("res://"):
            raise ValueError(f"无效 file: {entry!r}")
    return data


def collect_files(config: dict, allow_missing: bool) -> list[dict[str, object]]:
    collected: dict[str, int] = {}
    missing: list[str] = []
    for root in config["roots"]:
        root_path = str(root["path"])
        disk_root = _res_to_path(root_path)
        extensions = {str(ext).lower() for ext in root["extensions"]}
        if not disk_root.is_dir():
            missing.append(root_path)
            continue
        for dirpath, _dirnames, filenames in os.walk(disk_root, followlinks=True):
            for filename in filenames:
                if Path(filename).suffix.lower() not in extensions:
                    continue
                disk_path = Path(dirpath) / filename
                if not disk_path.is_file():
                    continue
                collected[_path_to_res(disk_path)] = disk_path.stat().st_size
    for entry in config["files"]:
        path = str(entry["path"])
        disk_path = _res_to_path(path)
        if not disk_path.is_file():
            missing.append(path)
            continue
        collected[path] = disk_path.stat().st_size

    if missing:
        message = "原始数据根/文件缺失: " + ", ".join(missing[:8])
        if not allow_missing:
            raise FileNotFoundError(message)
        print(f"[BLOCKED] {message}", file=sys.stderr)
        return []

    return [
        {"path": path, "bytes": collected[path]}
        for path in sorted(collected)
    ]


def build_manifest(config: dict, allow_missing: bool) -> dict:
    files = collect_files(config, allow_missing)
    return {
        "schema_id": "export_raw_dependencies",
        "schema_version": 1,
        "roots_config": "scripts/export_raw_roots.json",
        "files": files,
    }


def check_contract_entries() -> list[str]:
    problems: list[str] = []
    if not PROJECT_GODOT.is_file():
        problems.append("缺少 source/project.godot")
    else:
        project_text = PROJECT_GODOT.read_text(encoding="utf-8-sig")
        if PLUGIN_PATH not in project_text:
            problems.append(f"project.godot 未启用 {PLUGIN_PATH}")
    if not EXPORT_PRESETS.is_file():
        problems.append("缺少 source/export_presets.cfg")
    else:
        preset_text = EXPORT_PRESETS.read_text(encoding="utf-8-sig")
        for line in preset_text.splitlines():
            stripped = line.strip()
            if stripped.startswith("include_filter=") and "*.bin" in stripped:
                problems.append("export_presets.cfg 仍使用 include_filter=\"*.bin\" 兜底")
                break
    return problems


def check_literal_coverage(expected_paths: list[str], roots: list[str]) -> list[str]:
    """生产脚本中的 res:// JSON/BIN 字面量必须进入清单。

    静态路径必须精确命中；带 %d/%s 等格式符的动态路径由根配置覆盖。
    """
    expected = set(expected_paths)
    pattern = re.compile(r"res://[^\"'\\\n]+?\.(?:json|bin)")
    problems: list[str] = []
    seen: set[str] = set()
    for script_path in sorted((SOURCE).rglob("*.gd")):
        relative_parts = script_path.relative_to(SOURCE).parts
        if "addons" in relative_parts or ".godot" in relative_parts:
            continue
        text = script_path.read_text(encoding="utf-8", errors="ignore")
        for match in pattern.finditer(text):
            value = match.group(0)
            if value in seen:
                continue
            seen.add(value)
            if "%" in value or "{" in value:
                if not any(value.startswith(root) for root in roots):
                    problems.append(
                        f"{script_path.relative_to(ROOT)} 的动态原始数据路径未被根配置覆盖: {value}"
                    )
            elif value not in expected:
                problems.append(
                    f"{script_path.relative_to(ROOT)} 的原始数据路径未进入清单: {value}"
                )
    return problems


def check_manifest(expected: dict) -> list[str]:
    if not MANIFEST_PATH.is_file():
        return [f"缺少 {MANIFEST_PATH.relative_to(ROOT)}"]
    try:
        actual = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        return [f"清单 JSON 无效: {error}"]
    if actual != expected:
        return [f"{MANIFEST_PATH.relative_to(ROOT)} 已过期；运行 --write 重新生成"]
    return []


def main() -> int:
    parser = argparse.ArgumentParser(description="生成/校验原始数据导出清单")
    parser.add_argument("--write", action="store_true", help="写入 source/Script/data/export_raw_dependencies.json")
    parser.add_argument("--check", action="store_true", help="校验清单与当前素材/契约一致")
    parser.add_argument(
        "--allow-missing",
        action="store_true",
        help="素材目录缺失时返回 BLOCKED 而非失败（用于公开 clone；本地完整工作区不应使用）",
    )
    args = parser.parse_args()
    if not args.write and not args.check:
        parser.error("必须指定 --write 或 --check")

    try:
        config = load_config()
        expected = build_manifest(config, args.allow_missing)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 2

    if not expected["files"] and args.allow_missing:
        print("[BLOCKED] 原始数据素材不可用，未生成清单结论", file=sys.stderr)
        return 0

    if args.write:
        MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
        MANIFEST_PATH.write_text(
            json.dumps(expected, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
            newline="\n",
        )
        print(
            f"[OK] 写入 {MANIFEST_PATH.relative_to(ROOT)}: "
            f"{len(expected['files'])} 个原始数据文件"
        )

    if args.check:
        problems = check_contract_entries()
        problems.extend(check_manifest(expected))
        problems.extend(check_literal_coverage(
            [str(item["path"]) for item in expected["files"]],
            [str(root["path"]) for root in config["roots"]],
        ))
        if problems:
            for problem in problems:
                print(f"[FAIL] {problem}", file=sys.stderr)
            return 1
        print(
            f"[OK] 原始数据导出清单一致: {len(expected['files'])} 个文件；"
            "插件已启用且无 include_filter 兜底"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())

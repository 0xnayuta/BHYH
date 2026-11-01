#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""关卡布局迁移的双数据源门禁。

规则：
- `scripts/level_layout_sources.json` 登记的标准关卡，若同目录存在同名脚本；
- 该脚本仍包含 `monster_group = {` 时失败，表示布局资源和脚本数据表同时存在；
- 未登记布局的脚本只统计，不失败，供 30-3 分批迁移时观察剩余数量。
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
LAYOUT_SOURCES = ROOT / "scripts" / "level_layout_sources.json"
MARKER = "monster_group = {"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="检查已登记布局的关卡是否仍有脚本数据表")
    parser.add_argument("--fail-on-error", action="store_true", help="存在双数据源时返回 1")
    args = parser.parse_args(argv)

    if not LAYOUT_SOURCES.is_file():
        print(f"FAIL 缺少布局源: {LAYOUT_SOURCES.relative_to(ROOT)}", file=sys.stderr)
        return 1
    try:
        levels = json.loads(LAYOUT_SOURCES.read_text(encoding="utf-8")).get("levels", {})
    except (OSError, json.JSONDecodeError) as error:
        print(f"FAIL 布局源无法读取: {error}", file=sys.stderr)
        return 1

    duplicates: list[str] = []
    remaining: list[str] = []
    for scene_path in sorted(levels):
        prefix = "res://Scene/level/"
        if not scene_path.startswith(prefix) or not scene_path.endswith(".tscn"):
            continue
        level_name = Path(scene_path.removeprefix(prefix)).stem
        script_path = SOURCE / "Script" / "level" / f"{level_name}.gd"
        if not script_path.is_file():
            continue
        text = script_path.read_text(encoding="utf-8", errors="replace")
        if MARKER not in text:
            continue
        duplicates.append(f"{scene_path} <-> {script_path.relative_to(ROOT).as_posix()}")
    all_scripts = sorted((SOURCE / "Script" / "level").glob("*.gd"))
    for script_path in all_scripts:
        text = script_path.read_text(encoding="utf-8", errors="replace")
        if MARKER in text:
            remaining.append(script_path.name)

    print(f"已登记布局且仍有脚本数据表: {len(duplicates)}")
    for item in duplicates:
        print(f"FAIL 双数据源: {item}", file=sys.stderr)
    print(f"尚未迁移的脚本数据表: {len(remaining)}")
    if duplicates:
        return 1 if args.fail_on_error else 0
    print("PASS 已登记布局的关卡不存在脚本数据表")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

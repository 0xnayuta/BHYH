#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""关卡布局迁移的双数据源门禁。

规则：
- `scripts/level_layout_sources.json` 登记的标准关卡，若同目录存在同名脚本；
- 该脚本仍包含 `monster_group = {` 时失败，表示布局资源和脚本数据表同时存在；
- 未登记布局的脚本必须出现在 `scripts/level_layout_data_exceptions.json`，且理由非空；
- 登记例外失效（脚本已无数据表）同样失败，防止清单漂移。
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
LAYOUT_SOURCES = ROOT / "scripts" / "level_layout_sources.json"
EXCEPTIONS = ROOT / "scripts" / "level_layout_data_exceptions.json"
MARKER = "monster_group = {"


def load_exceptions() -> dict[str, str]:
    if not EXCEPTIONS.is_file():
        raise ValueError(f"缺少关卡数据例外清单: {EXCEPTIONS.relative_to(ROOT)}")
    payload = json.loads(EXCEPTIONS.read_text(encoding="utf-8"))
    if payload.get("schema_id") != "level_layout_data_exceptions" or payload.get("schema_version") != 1:
        raise ValueError("关卡数据例外清单 schema 不匹配")
    entries = payload.get("exceptions")
    if not isinstance(entries, dict):
        raise ValueError("关卡数据例外清单 exceptions 必须是对象")
    result: dict[str, str] = {}
    for name, reason in entries.items():
        if not isinstance(name, str) or not name.endswith(".gd") or not isinstance(reason, str) or not reason.strip():
            raise ValueError(f"关卡数据例外条目非法: {name!r}")
        result[name] = reason
    return result


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="检查已登记布局的关卡是否仍有脚本数据表")
    parser.add_argument("--fail-on-error", action="store_true", help="存在双数据源时返回 1")
    args = parser.parse_args(argv)

    if not LAYOUT_SOURCES.is_file():
        print(f"FAIL 缺少布局源: {LAYOUT_SOURCES.relative_to(ROOT)}", file=sys.stderr)
        return 1
    try:
        levels = json.loads(LAYOUT_SOURCES.read_text(encoding="utf-8")).get("levels", {})
        exceptions = load_exceptions()
    except (OSError, json.JSONDecodeError, ValueError) as error:
        print(f"FAIL 迁移审计输入无法读取: {error}", file=sys.stderr)
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
    unregistered = [name for name in remaining if name not in exceptions]
    stale = [name for name in exceptions if name not in remaining]

    print(f"已登记布局且仍有脚本数据表: {len(duplicates)}")
    for item in duplicates:
        print(f"FAIL 双数据源: {item}", file=sys.stderr)
    print(f"未迁移脚本数据表: {len(remaining)}；已登记例外: {len(exceptions) - len(stale)}")
    for name in unregistered:
        print(f"FAIL 未登记的数据表例外: {name}", file=sys.stderr)
    for name in stale:
        print(f"FAIL 已失效的数据表例外（脚本已无数据表）: {name}", file=sys.stderr)
    if duplicates or unregistered or stale:
        return 1 if args.fail_on_error else 0
    print("PASS 已登记布局无脚本数据表，剩余数据表均有例外理由")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

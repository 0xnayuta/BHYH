#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""装备构建源字段审计。

检查 `scripts/equipment_sources.json` 的 32 字段白名单、类型、扩展键、
字段存在性与随机字段边界。随机字段不保存采样值；由其 `randomized_fields`
登记，规则层在后续批次实现。

用法：
    python scripts/equipment_data_audit.py
    python scripts/equipment_data_audit.py --check --json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from equipment_data_schema import (
    ALL_FIELDS,
    ENHANCEMENT_FIELDS,
    RANDOMIZABLE_FIELDS,
    SCHEMA_VERSION,
    EquipmentSourceError,
    load_source,
    source_summary,
    validate_source,
)

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "scripts/equipment_sources.json"


def main() -> int:
    parser = argparse.ArgumentParser(description="装备构建源字段审计")
    parser.add_argument("--check", action="store_true", help="只校验，不写文件")
    parser.add_argument("--json", action="store_true", help="输出机器可读摘要")
    parser.add_argument("--source", type=Path, default=SOURCE_PATH, help="构建源路径")
    args = parser.parse_args()

    try:
        payload = load_source(args.source)
    except EquipmentSourceError as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 1

    errors = validate_source(payload)
    summary = source_summary(payload)
    summary["schema_version"] = SCHEMA_VERSION
    summary["enhancement_fields"] = len(ENHANCEMENT_FIELDS)
    summary["randomizable_fields"] = len(RANDOMIZABLE_FIELDS)
    if args.json:
        print(json.dumps({"ok": not errors, "summary": summary, "errors": errors}, ensure_ascii=False, indent=2))
    elif errors:
        print(f"[FAIL] 装备构建源审计失败，共 {len(errors)} 项", file=sys.stderr)
        for error in errors[:40]:
            print(f"  - {error}", file=sys.stderr)
        if len(errors) > 40:
            print(f"  ... 还有 {len(errors) - 40} 项", file=sys.stderr)
    else:
        print(
            "[SUCCESS] 装备构建源审计通过："
            f"{summary['definitions']} 条定义，{summary['schema_fields']} 个字段，"
            f"{summary['randomized_definitions']} 条含随机字段，"
            f"{summary['randomized_fields']} 个随机字段值"
        )
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())

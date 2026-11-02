#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""构建期生成装备 Catalog。

输入：`scripts/equipment_sources.json`（已提交、可审查的单文件构建源）。
输出：`source/Script/data/equipment_catalog.tres`。

运行时只加载 `.tres`，不解析源文本、玉兔 JSON 或本脚本。
随机字段在构建源中以 `randomized_fields` 登记，构建源与 Catalog 均不保存采样值；
其运行时生成属于后续装备规则批次。

用法：
    python scripts/convert_equipment_catalog.py
    python scripts/convert_equipment_catalog.py --check
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any

from equipment_data_schema import (
    ALL_FIELDS,
    STAT_FIELDS,
    EquipmentSourceError,
    load_source,
    validate_source,
)

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "scripts/equipment_sources.json"
CATALOG_PATH = ROOT / "source/Script/data/equipment_catalog.tres"
CATALOG_SCRIPT_PATH = "res://Script/data/equipment_catalog.gd"
DEFINITION_SCRIPT_PATH = "res://Script/data/equipment_definition.gd"
ROLL_SCRIPT_PATH = "res://Script/data/equipment_stat_roll.gd"
UID_ALPHABET = "abcdefghijklmnopqrstuvwxy012345678"
UID_BASE = len(UID_ALPHABET)
UID_MAX_VALUE = 0x7FFFFFFFFFFFFFFF


def uid_text(value: int) -> str:
    value &= UID_MAX_VALUE
    chars: list[str] = []
    while value:
        chars.append(UID_ALPHABET[value % UID_BASE])
        value //= UID_BASE
    return "uid://" + "".join(reversed(chars))


def catalog_uid() -> str:
    return uid_text(int.from_bytes(hashlib.sha256(b"bhyh:equipment_catalog:v1").digest()[:8], "big"))


def gd_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def gd_string_name(value: str) -> str:
    return "&" + gd_string(value)


def gd_scalar(value: Any) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        return repr(value)
    if isinstance(value, str):
        return gd_string(value)
    raise ValueError(f"不支持的标量类型: {type(value).__name__}")


def gd_dictionary(values: dict[str, Any]) -> str:
    if not values:
        return "{}"
    lines = ["{"]
    for key, value in values.items():
        lines.append(f"\t{gd_string_name(str(key))}: {gd_scalar(value)},")
    lines.append("}")
    return "\n".join(lines)


def gd_packed_strings(values: list[str]) -> str:
    if not values:
        return "PackedStringArray()"
    return "PackedStringArray(" + ", ".join(gd_string(value) for value in values) + ")"


def source_digest(payload: dict[str, Any]) -> str:
    canonical = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def definition_stats(definition: dict[str, Any]) -> dict[str, Any]:
    defined = definition["defined_fields"]
    randomized = set(definition["randomized_fields"])
    values = definition["values"]
    return {
        field: values[field]
        for field in STAT_FIELDS
        if field in defined and field not in randomized
    }


def render_roll(roll: dict[str, Any], roll_id: str) -> str:
    return "\n".join(
        [
            f'[sub_resource type="Resource" id="{roll_id}"]',
            'script = ExtResource("3_roll")',
            f"sampler = {gd_string_name(str(roll['sampler']))}",
            f"kind = {gd_string_name(str(roll['kind']))}",
            f"minimum = {repr(float(roll['minimum']))}",
            f"maximum = {repr(float(roll['maximum']))}",
            f"step = {repr(float(roll['step']))}",
            f"scale = {repr(float(roll['scale']))}",
            f"rounding = {gd_string_name(str(roll['rounding']))}",
        ]
    )


def render_definition(definition: dict[str, Any], index: int, roll_ids: dict[tuple[int, str], str]) -> str:
    values = definition["values"]
    defined = definition["defined_fields"]
    randomized = definition["randomized_fields"]
    enhancement = values.get("强化属性", {})
    gem_slots = values.get("宝石", [])
    element = values.get("五行", [])
    growth_rate = float(values["成长率"]) if "成长率" in values else 0.0
    lines = [
        f'[sub_resource type="Resource" id="definition_{index}"]',
        'script = ExtResource("2_definition")',
        f"id = {gd_string_name(definition['id'])}",
        f"display_name = {gd_string(values.get('名字', ''))}",
        f"origin = {gd_string(values.get('所属', ''))}",
        f"quality = {gd_string(values.get('品质', ''))}",
        f"color_hex = {gd_string(values.get('颜色', ''))}",
        f"category = {gd_string(values.get('类型', ''))}",
        f"description = {gd_string(values.get('描述', ''))}",
        f"price = {int(values.get('售价', 0))}",
        f"icon_path = {gd_string(values.get('图标', ''))}",
        f"equipment_type = {gd_string(values.get('装备类型', ''))}",
        f"fb_type = {gd_string(values.get('FBTYPE', ''))}",
        f"next_stage = {gd_string(values.get('下一阶段', ''))}",
        f"growth_rate = {repr(growth_rate)}",
        f"element = {gd_packed_strings(element)}",
        f"forge_forbidden = {gd_scalar(bool(values.get('不可神铸', False)))}",
        f"stats = {gd_dictionary(definition_stats(definition))}",
        f"enhancement = {gd_dictionary(enhancement)}",
        f"gem_slots = {gd_packed_strings(gem_slots)}",
        f"defined_fields = {gd_packed_strings(defined)}",
        f"randomized_fields = {gd_packed_strings(randomized)}",
    ]
    if randomized:
        lines.append("random_rolls = {")
        for field in randomized:
            lines.append(f"\t{gd_string_name(str(field))}: SubResource(\"{roll_ids[(index, str(field))]}\"),")
        lines.append("}")
    else:
        lines.append("random_rolls = {}")
    return "\n".join(lines)


def render_catalog(payload: dict[str, Any]) -> str:
    definitions = payload["definitions"]
    count = len(definitions)
    roll_ids: dict[tuple[int, str], str] = {}
    roll_blocks: list[str] = []
    for index, definition in enumerate(definitions, 1):
        for field in definition["randomized_fields"]:
            roll_id = f"roll_{index}_{len(roll_ids) + 1}"
            roll_ids[(index, str(field))] = roll_id
            roll_blocks.append(render_roll(definition["random_rolls"][field], roll_id))
    lines = [
        f'[gd_resource type="Resource" script_class="EquipmentCatalog" load_steps={count + len(roll_blocks) + 4} format=3 uid="{catalog_uid()}"]',
        "",
        f'[ext_resource type="Script" path="{CATALOG_SCRIPT_PATH}" id="1_catalog"]',
        f'[ext_resource type="Script" path="{DEFINITION_SCRIPT_PATH}" id="2_definition"]',
        f'[ext_resource type="Script" path="{ROLL_SCRIPT_PATH}" id="3_roll"]',
        "",
    ]
    for block in roll_blocks:
        lines.append(block)
        lines.append("")
    for index, definition in enumerate(definitions, 1):
        lines.append(render_definition(definition, index, roll_ids))
        lines.append("")
    subresources = ", ".join(f'SubResource("definition_{index}")' for index in range(1, count + 1))
    lines.extend(
        [
            "[resource]",
            'script = ExtResource("1_catalog")',
            "schema_version = 1",
            f"source_sha256 = {gd_string(source_digest(payload))}",
            f"definition_count = {count}",
            f'definitions = Array[ExtResource("2_definition")]([{subresources}])',
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="equipment_sources.json -> equipment_catalog.tres 构建期转换器")
    parser.add_argument("--check", action="store_true", help="只校验 Catalog 是否与构建源同步，不写文件")
    parser.add_argument("--source", type=Path, default=SOURCE_PATH, help="构建源路径")
    parser.add_argument("--output", type=Path, default=CATALOG_PATH, help="Catalog 输出路径")
    args = parser.parse_args()

    try:
        payload = load_source(args.source)
    except EquipmentSourceError as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 1
    errors = validate_source(payload)
    if errors:
        print(f"[FAIL] 构建源校验失败，共 {len(errors)} 项", file=sys.stderr)
        for error in errors[:40]:
            print(f"  - {error}", file=sys.stderr)
        return 1

    content = render_catalog(payload)
    if args.check:
        if not args.output.is_file():
            print(f"[FAIL] 缺少构建期 Catalog: {args.output}", file=sys.stderr)
            return 1
        current = args.output.read_text(encoding="utf-8")
        if current != content:
            print("[FAIL] equipment_catalog.tres 与构建源不同步，请运行转换器。", file=sys.stderr)
            return 1
        print(
            f"[SUCCESS] equipment_catalog.tres 已同步：{payload['definition_count']} 条定义，"
            f"{len(ALL_FIELDS)} 个字段"
        )
        return 0

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(content, encoding="utf-8", newline="\n")
    print(f"[SUCCESS] 已生成 {args.output}: {payload['definition_count']} 条定义，{len(ALL_FIELDS)} 个字段")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

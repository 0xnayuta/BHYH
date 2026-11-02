#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""装备构建源 schema 与类型校验。

构建源是 `scripts/equipment_sources.json`。它只保存静态定义：
- `values` 保存确定性字段；
- `randomized_fields` 标记由旧运行时代码生成的字段，构建源不保存采样值；
- `defined_fields` 保留旧字典的字段存在性，区分“缺失”和“空值”。

本模块被审计脚本与 Catalog 生成器共用，避免两套字段白名单漂移。
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

SCHEMA_VERSION = 1

CORE_FIELDS = (
    "名字",
    "所属",
    "品质",
    "颜色",
    "类型",
    "描述",
    "售价",
    "图标",
)
STAT_FIELDS = (
    "SHp",
    "SMp",
    "power",
    "Def",
    "Mdef",
    "Crit",
    "Miss",
    "R_hp",
    "R_mp",
    "vampirism",
    "Lucky",
    "toughness",
    "htarget",
    "CritReduce",
    "ar",
    "sp",
)
STRUCT_FIELDS = ("强化属性", "宝石")
EXTENSION_FIELDS = (
    "FBTYPE",
    "成长率",
    "五行",
    "下一阶段",
    "不可神铸",
    "装备类型",
)
ALL_FIELDS = CORE_FIELDS + STAT_FIELDS + STRUCT_FIELDS + EXTENSION_FIELDS
ENHANCEMENT_FIELDS = STAT_FIELDS + ("target",)
RANDOMIZABLE_FIELDS = STAT_FIELDS + ("成长率",)
REQUIRED_FIELDS = (
    "名字",
    "所属",
    "品质",
    "颜色",
    "类型",
    "描述",
    "售价",
)
STRING_FIELDS = (
    "名字",
    "所属",
    "品质",
    "颜色",
    "类型",
    "描述",
    "图标",
    "FBTYPE",
    "装备类型",
    "下一阶段",
)
ELEMENTS = ("金", "木", "水", "火", "土")


class EquipmentSourceError(ValueError):
    """构建源不可用；调用方必须显式失败，不做回退。"""


def load_source(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise EquipmentSourceError(f"构建源不存在: {path}")
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise EquipmentSourceError(f"构建源无法解析: {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise EquipmentSourceError("构建源根节点必须是对象")
    return payload


def _is_number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def _validate_value(field: str, value: Any, errors: list[str]) -> None:
    if field in STRING_FIELDS:
        if not isinstance(value, str):
            errors.append(f"{field}: 期望字符串，得到 {type(value).__name__}")
        elif field == "图标" and value and not value.startswith("res://"):
            errors.append(f"{field}: 图标路径必须以 res:// 开头")
        return
    if field == "售价":
        if not isinstance(value, int) or isinstance(value, bool):
            errors.append(f"{field}: 期望 int，得到 {type(value).__name__}")
        elif value < 0:
            errors.append(f"{field}: 售价不能为负数")
        return
    if field in STAT_FIELDS:
        if not _is_number(value):
            errors.append(f"{field}: 期望 int/float，得到 {type(value).__name__}")
        return
    if field == "强化属性":
        if not isinstance(value, dict):
            errors.append(f"{field}: 期望 Dictionary，得到 {type(value).__name__}")
            return
        for key, nested in value.items():
            if key not in ENHANCEMENT_FIELDS:
                errors.append(f"{field}.{key}: 未登记强化属性键")
            elif not _is_number(nested):
                errors.append(f"{field}.{key}: 期望 int/float，得到 {type(nested).__name__}")
        return
    if field == "宝石":
        if not isinstance(value, list):
            errors.append(f"{field}: 期望 Array，得到 {type(value).__name__}")
            return
        for index, gem in enumerate(value):
            if not isinstance(gem, str):
                errors.append(f"{field}[{index}]: 期望字符串，得到 {type(gem).__name__}")
        return
    if field == "成长率":
        if not _is_number(value):
            errors.append(f"{field}: 期望 int/float，得到 {type(value).__name__}")
        return
    if field == "五行":
        if not isinstance(value, list):
            errors.append(f"{field}: 期望 Array，得到 {type(value).__name__}")
            return
        for index, element in enumerate(value):
            if not isinstance(element, str) or element not in ELEMENTS:
                errors.append(f"{field}[{index}]: 未知五行元素 {element!r}")
        return
    if field == "不可神铸":
        if not isinstance(value, bool):
            errors.append(f"{field}: 期望 bool，得到 {type(value).__name__}")
        return
    errors.append(f"{field}: 未实现类型校验")


def _validate_definition(definition: Any, index: int) -> list[str]:
    prefix = f"definitions[{index}]"
    if not isinstance(definition, dict):
        return [f"{prefix}: 期望对象，得到 {type(definition).__name__}"]
    errors: list[str] = []
    item_id = definition.get("id")
    if not isinstance(item_id, str) or not item_id.strip():
        errors.append(f"{prefix}.id: 必须是非空字符串")
    elif any(char.isspace() for char in item_id):
        errors.append(f"{prefix}.id: 不能包含空白字符")

    defined = definition.get("defined_fields")
    randomized = definition.get("randomized_fields")
    values = definition.get("values")
    if not isinstance(defined, list) or not all(isinstance(field, str) for field in defined):
        errors.append(f"{prefix}.defined_fields: 必须是字符串数组")
        defined = []
    if not isinstance(randomized, list) or not all(isinstance(field, str) for field in randomized):
        errors.append(f"{prefix}.randomized_fields: 必须是字符串数组")
        randomized = []
    if not isinstance(values, dict):
        errors.append(f"{prefix}.values: 必须是对象")
        values = {}

    if len(defined) != len(set(defined)):
        errors.append(f"{prefix}.defined_fields: 存在重复字段")
    unknown_defined = [field for field in defined if field not in ALL_FIELDS]
    if unknown_defined:
        errors.append(f"{prefix}.defined_fields: 未登记字段 {sorted(unknown_defined)}")
    for field in REQUIRED_FIELDS:
        if field not in defined:
            errors.append(f"{prefix}.defined_fields: 缺少必需字段 {field}")

    if len(randomized) != len(set(randomized)):
        errors.append(f"{prefix}.randomized_fields: 存在重复字段")
    for field in randomized:
        if field not in defined:
            errors.append(f"{prefix}.randomized_fields: {field} 不在 defined_fields")
        if field not in RANDOMIZABLE_FIELDS:
            errors.append(f"{prefix}.randomized_fields: {field} 不是已登记的随机字段")

    for field in values:
        if field not in ALL_FIELDS:
            errors.append(f"{prefix}.values.{field}: 未登记字段")
        if field not in defined:
            errors.append(f"{prefix}.values.{field}: 不在 defined_fields")
        if field in randomized:
            errors.append(f"{prefix}.values.{field}: 随机字段不得保存采样值")
        _validate_value(field, values[field], errors)

    for field in defined:
        if field not in randomized and field not in values:
            errors.append(f"{prefix}.values.{field}: 确定性字段缺少值")
    return errors


def validate_source(payload: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if payload.get("schema_version") != SCHEMA_VERSION:
        errors.append(f"schema_version: 期望 {SCHEMA_VERSION}")
    definitions = payload.get("definitions")
    if not isinstance(definitions, list):
        errors.append("definitions: 必须是数组")
        return errors
    if payload.get("definition_count") != len(definitions):
        errors.append("definition_count: 与 definitions 数量不一致")

    seen_ids: set[str] = set()
    randomized_field_count = 0
    for index, definition in enumerate(definitions):
        errors.extend(_validate_definition(definition, index))
        if not isinstance(definition, dict):
            continue
        item_id = definition.get("id")
        if isinstance(item_id, str):
            if item_id in seen_ids:
                errors.append(f"definitions[{index}].id: 重复 ID {item_id}")
            seen_ids.add(item_id)
        randomized = definition.get("randomized_fields")
        if isinstance(randomized, list):
            randomized_field_count += len(randomized)
    if payload.get("randomized_field_count") != randomized_field_count:
        errors.append("randomized_field_count: 与 randomized_fields 总数不一致")
    return errors


def source_summary(payload: dict[str, Any]) -> dict[str, int]:
    definitions = payload.get("definitions", [])
    randomized_definitions = 0
    randomized_fields = 0
    if isinstance(definitions, list):
        for definition in definitions:
            if not isinstance(definition, dict):
                continue
            fields = definition.get("randomized_fields")
            if isinstance(fields, list) and fields:
                randomized_definitions += 1
                randomized_fields += len(fields)
    return {
        "definitions": len(definitions) if isinstance(definitions, list) else 0,
        "randomized_definitions": randomized_definitions,
        "randomized_fields": randomized_fields,
        "schema_fields": len(ALL_FIELDS),
    }

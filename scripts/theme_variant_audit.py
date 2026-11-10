#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Phase 27-4 Theme 变体层级与规模门禁。

- 保留 `theme_legacy_variants.json` 中 618 个冻结变体名；
- 允许新增 `Semantic*` 语义基类，但必须形成无环链；
- 纯别名（无自有 Theme 项且继承已有变体）不计入独立视觉角色；
- 独立变体的有效 Theme 签名重复组不得超过 10；
- Theme 资源属性 <= 2,000，StyleBox 子资源 <= 36。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

if __package__:
    from .theme_inheritance import effective_theme_properties
else:
    from theme_inheritance import effective_theme_properties

ROOT = Path(__file__).resolve().parent.parent
THEME = ROOT / "source" / "Scene" / "theme" / "bhyh_theme.tres"
MANIFEST = ROOT / "scripts" / "theme_legacy_variants.json"
TARGET_MAX_PROPERTIES = 2000
TARGET_MAX_STYLEBOXES = 36
TARGET_MAX_DUPLICATE_GROUPS = 10
SEMANTIC_PREFIX = "Semantic"


def parse_theme(text: str) -> tuple[dict[str, dict[str, str]], dict[str, str], int]:
    lines = text.splitlines()
    start = lines.index("[resource]")
    props: dict[str, str] = {}
    for line in lines[start + 1 :]:
        if line.startswith("["):
            continue
        if "=" in line:
            key, value = line.split("=", 1)
            props[key.strip()] = value.strip()
    variants: dict[str, dict[str, str]] = defaultdict(dict)
    for key, value in props.items():
        if "/" in key:
            name, prop = key.split("/", 1)
            variants[name][prop] = value
    styleboxes = {m.group(2): m.group(1) for m in re.finditer(r'^\[sub_resource type="([^"]+)" id="([^"]+)"\]', text, re.M)}
    return variants, styleboxes, len(props)


def base_name(props: dict[str, str]) -> str:
    return props.get("base_type", "").strip('&"')


def effective(variants: dict[str, dict[str, str]]) -> dict[str, dict[str, str]]:
    return effective_theme_properties(variants)


def native_root(variants: dict[str, dict[str, str]], name: str) -> str:
    seen: set[str] = set()
    while name in variants:
        if name in seen:
            return "CYCLE"
        seen.add(name)
        name = base_name(variants[name])
    return name


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Phase 27-4 Theme 变体层级审计")
    parser.add_argument("--check", action="store_true", help="超出门禁上限或破坏冻结清单时返回 1")
    parser.add_argument("--json", action="store_true", help="输出 JSON")
    args = parser.parse_args(argv)
    if not THEME.is_file() or not MANIFEST.is_file():
        print("FAIL Theme 或冻结变体清单不存在", file=sys.stderr)
        return 2
    text = THEME.read_text(encoding="utf-8")
    variants, styleboxes, property_count = parse_theme(text)
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8")).get("variants", [])
    legacy = [name for name in manifest if name in variants]
    missing = [name for name in manifest if name not in variants]
    effective_map = effective(variants)
    semantic_bases = [name for name in variants if name.startswith(SEMANTIC_PREFIX)]
    cycles = [name for name in variants if native_root(variants, name) == "CYCLE"]

    aliases: list[str] = []
    independent: list[str] = []
    for name in legacy:
        props = variants[name]
        own_items = [key for key in props if key != "base_type"]
        base = base_name(props)
        if not own_items and base in variants:
            aliases.append(name)
        else:
            independent.append(name)

    groups: dict[tuple[str, tuple[tuple[str, str], ...]], list[str]] = defaultdict(list)
    for name in independent:
        signature = tuple(sorted(effective_map.get(name, {}).items()))
        groups[(native_root(variants, name), signature)].append(name)
    duplicate_groups = [members for members in groups.values() if len(members) > 1]
    duplicate_variants = sum(len(members) for members in duplicate_groups)
    style_refs = set(re.findall(r'SubResource\("([^"]+)"\)', text))
    missing_style_refs = style_refs - set(styleboxes)
    errors: list[str] = []
    if missing:
        errors.append(f"缺少冻结变体 {len(missing)} 个: {', '.join(missing[:6])}")
    if cycles:
        errors.append(f"变体基类成环: {', '.join(cycles[:6])}")
    if missing_style_refs:
        errors.append(f"缺失 StyleBox 引用: {', '.join(sorted(missing_style_refs)[:6])}")
    if property_count > TARGET_MAX_PROPERTIES:
        errors.append(f"Theme 属性 {property_count} > {TARGET_MAX_PROPERTIES}")
    if len(styleboxes) > TARGET_MAX_STYLEBOXES:
        errors.append(f"StyleBox {len(styleboxes)} > {TARGET_MAX_STYLEBOXES}")
    if len(duplicate_groups) > TARGET_MAX_DUPLICATE_GROUPS:
        errors.append(f"独立变体重复签名组 {len(duplicate_groups)} > {TARGET_MAX_DUPLICATE_GROUPS}")
    report = {
        "legacy_variants": len(manifest),
        "legacy_present": len(legacy),
        "semantic_bases": len(semantic_bases),
        "total_variants": len(variants),
        "aliases": len(aliases),
        "independent_variants": len(independent),
        "theme_properties": property_count,
        "styleboxes": len(styleboxes),
        "duplicate_groups": len(duplicate_groups),
        "duplicate_variants": duplicate_variants,
        "max_base_depth": max((base_depth(variants, name) for name in semantic_bases), default=0),
    }
    if args.json:
        print(json.dumps({"ok": not errors, "errors": errors, **report}, ensure_ascii=False, indent=2))
    else:
        print(
            "theme variant: "
            f"legacy {len(manifest)}/{len(legacy)}, bases {len(semantic_bases)}, "
            f"properties {property_count}, styleboxes {len(styleboxes)}, "
            f"duplicate groups {len(duplicate_groups)}, errors {len(errors)}"
        )
        for error in errors:
            print("FAIL", error)
    return 0 if not errors else 1


def base_depth(variants: dict[str, dict[str, str]], name: str) -> int:
    depth = 0
    seen: set[str] = set()
    while name in variants:
        if name in seen:
            return depth
        seen.add(name)
        depth += 1
        name = base_name(variants[name])
    return depth


if __name__ == "__main__":
    raise SystemExit(main())

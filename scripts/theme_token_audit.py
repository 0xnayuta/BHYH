#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Theme token 审计。

- 只读解析 `bhyh_theme.tres`；
- 用 `scripts/theme_token_baseline.json` 冻结迁移前的既有变体值；
- 新增变体或既有变体新增/改写的字号、描边、字体颜色必须属于 token 集合；
- 新增 Button 变体必须继承已登记的 Button token 基类。

基线是迁移期的兼容上限，不是新值白名单；新 UI 必须使用 token。
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
THEME = ROOT / "source" / "Scene" / "theme" / "bhyh_theme.tres"
BASELINE = ROOT / "scripts" / "theme_token_baseline.json"

FONT_SIZES = {10, 12, 14, 16, 18, 20, 24, 28, 32, 36, 40, 50, 76, 100}
OUTLINE_SIZES = {0, 1, 2, 3, 6, 10}
COLORS = {
    "Color(1, 1, 1, 1)",
    "Color(0.87451, 0.87451, 0.87451, 1)",
    "Color(0.815686, 0.815686, 0.815686, 1)",
    "Color(0.94, 0.94, 0.94, 1)",
    "Color(1, 0.956863, 0.74902, 1)",
    "Color(1, 0.84, 0.54, 1)",
    "Color(1, 0.72, 0.16, 1)",
    "Color(0.388235, 0.780392, 1, 1)",
    "Color(1, 0.290196, 0, 1)",
    "Color(1, 1, 0, 1)",
    "Color(0, 0, 0, 1)",
    "Color(1, 0, 0, 1)",
    "Color(0.42, 0.88, 0.7, 1)",
    "Color(0.84, 0.86, 0.9, 1)",
    "Color(0.94, 0.73, 0.34, 1)",
    "Color(1, 0.584314, 0, 1)",
    "Color(1, 0.752941, 0, 1)",
    "Color(0, 1, 0, 1)",
    "Color(0.964706, 0.403922, 0, 1)",
}
BUTTON_TOKEN_BASES = {
    "Button",
    "MenuActionButton",
    "EmptyButton",
    "SettingsButton",
    "SettingsButtonSmall",
    "SettingsButtonTiny",
    "LlbtCgmsButton",
    "BackpackActionButton",
    "BackpackToggleButton",
}
COLOR_KEYS = ("colors/font_color", "colors/font_outline_color", "colors/font_shadow_color")


def read_variants() -> dict[str, dict[str, str]]:
    text = THEME.read_text(encoding="utf-8")
    lines = text.splitlines()
    start = next(index for index, line in enumerate(lines) if line.strip() == "[resource]")
    props: dict[str, str] = {}
    for line in lines[start + 1 :]:
        if line.startswith("["):
            continue
        if "=" in line:
            key, value = line.split("=", 1)
            props[key.strip()] = value.strip()
    variants: dict[str, dict[str, str]] = {}
    for key, value in props.items():
        if "/" in key:
            name, prop = key.split("/", 1)
            variants.setdefault(name, {})[prop] = value
    return variants


def signature(variants: dict[str, dict[str, str]]) -> dict[str, dict[str, str]]:
    result: dict[str, dict[str, str]] = {}
    for name, props in variants.items():
        entry = {
            "base_type": props.get("base_type", ""),
            "font_sizes/font_size": props.get("font_sizes/font_size", ""),
            "constants/outline_size": props.get("constants/outline_size", ""),
        }
        for key in COLOR_KEYS:
            entry[key] = props.get(key, "")
        result[name] = entry
    return result


def check(current: dict[str, dict[str, str]], baseline: dict[str, dict[str, str]]) -> list[str]:
    errors: list[str] = []
    for name, props in sorted(current.items()):
        previous = baseline.get(name)
        if previous is None:
            for prop in ("font_sizes/font_size", "constants/outline_size"):
                value = props.get(prop)
                if value is None:
                    continue
                if prop == "font_sizes/font_size" and int(value) not in FONT_SIZES:
                    errors.append(f"新增变体 {name} 字号不在 token: {value}")
                if prop == "constants/outline_size" and int(value) not in OUTLINE_SIZES:
                    errors.append(f"新增变体 {name} 描边不在 token: {value}")
            for key in COLOR_KEYS:
                value = props.get(key)
                if value is not None and value not in COLORS:
                    errors.append(f"新增变体 {name} {key} 不在 token: {value}")
            base = props.get("base_type", "").strip('&"')
            if base == "Button" or (base in current and current[base].get("base_type") == '&"Button"'):
                if base != "Button" and base not in BUTTON_TOKEN_BASES:
                    errors.append(f"新增 Button 变体 {name} 未继承登记 token 基类: {base}")
                if base == "Button":
                    errors.append(f"新增 Button 变体 {name} 直接继承 Button，应使用 token 基类")
            continue
        for prop in ("font_sizes/font_size", "constants/outline_size"):
            value = props.get(prop)
            old = previous.get(prop, "")
            if value is not None and value != old:
                allowed = FONT_SIZES if prop.startswith("font_sizes") else OUTLINE_SIZES
                if int(value) not in allowed:
                    errors.append(f"{name} {prop} 改写值不在 token: {value}")
        for key in COLOR_KEYS:
            value = props.get(key)
            old = previous.get(key, "")
            if value is not None and value != old and value not in COLORS:
                errors.append(f"{name} {key} 改写值不在 token: {value}")
    return errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Theme token 审计")
    parser.add_argument("--check", action="store_true", help="与 baseline 比较，发现未登记 token 偏离时返回 1")
    parser.add_argument("--write-baseline", action="store_true", help="写入当前变体签名作为迁移期基线")
    parser.add_argument("--json", action="store_true", help="输出 JSON")
    args = parser.parse_args(argv)
    if args.check and args.write_baseline:
        print("FAIL --check 与 --write-baseline 不能同时使用", file=sys.stderr)
        return 2
    if not THEME.is_file():
        print(f"FAIL Theme 不存在: {THEME}", file=sys.stderr)
        return 2
    current = signature(read_variants())
    if args.write_baseline:
        BASELINE.write_text(json.dumps({"schema_version": 1, "variants": current}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        print(f"已写入 token 基线: {BASELINE.relative_to(ROOT)}，变体 {len(current)}")
        return 0
    if not BASELINE.is_file():
        print(f"FAIL token 基线不存在: {BASELINE}", file=sys.stderr)
        return 2
    baseline = json.loads(BASELINE.read_text(encoding="utf-8")).get("variants", {})
    errors = check(read_variants(), baseline)
    if args.json:
        print(json.dumps({"ok": not errors, "errors": errors, "variants": len(current)}, ensure_ascii=False, indent=2))
    else:
        print(f"theme token: 变体 {len(current)}，基线 {len(baseline)}，违规 {len(errors)}")
        for error in errors[:30]:
            print("FAIL", error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Theme token 审计。

- 只读解析 `bhyh_theme.tres`；
- 用 `scripts/theme_token_baseline.json` 冻结迁移前的既有变体值；
- 所有当前字号与字体色必须属于 token 集合；新增/改写的描边必须属于 token 集合；
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
TOKEN_SOURCE = ROOT / "scripts" / "ui_theme_tokens.json"


def _load_tokens() -> dict:
    if not TOKEN_SOURCE.is_file():
        raise RuntimeError(f"token 源不存在: {TOKEN_SOURCE.relative_to(ROOT)}")
    data = json.loads(TOKEN_SOURCE.read_text(encoding="utf-8"))
    if not isinstance(data.get("theme_audit"), dict):
        raise RuntimeError("token 源缺少 theme_audit")
    if not isinstance(data.get("theme_font_colors"), dict):
        raise RuntimeError("token 源缺少 theme_font_colors")
    return data


_TOKENS = _load_tokens()
_TOKEN_AUDIT = _TOKENS["theme_audit"]
FONT_SIZES = set(_TOKEN_AUDIT["font_sizes"])
OUTLINE_SIZES = set(_TOKEN_AUDIT["outline_sizes"])
COLORS = set(_TOKENS["theme_font_colors"].values())
BUTTON_TOKEN_BASES = set(_TOKEN_AUDIT["button_token_bases"])
COLOR_KEYS = (
    "colors/font_color",
    "colors/font_outline_color",
    "colors/font_shadow_color",
    "colors/font_hover_color",
    "colors/font_pressed_color",
    "colors/font_hover_pressed_color",
    "colors/font_disabled_color",
    "colors/font_placeholder_color",
)


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


def effective_variants(variants: dict[str, dict[str, str]]) -> dict[str, dict[str, str]]:
    """解析语义基类链，返回每个变体的有效 Theme 项。

    Theme 的 ``base_type`` 不在资源内保存继承结果；审计必须沿链读取，
    否则基类收敛后的字号/颜色会逃逸检查。
    """

    memo: dict[str, dict[str, str]] = {}
    visiting: set[str] = set()

    def resolve(name: str) -> dict[str, str]:
        if name in memo:
            return memo[name]
        if name in visiting:
            return {}
        visiting.add(name)
        props = variants.get(name, {})
        base = props.get("base_type", "").strip('&"')
        effective = dict(resolve(base)) if base in variants else {}
        effective.update({key: value for key, value in props.items() if key != "base_type"})
        visiting.discard(name)
        memo[name] = effective
        return effective

    result: dict[str, dict[str, str]] = {}
    for name, props in variants.items():
        entry = {"base_type": props.get("base_type", "")}
        entry.update(resolve(name))
        result[name] = entry
    return result


def signature(variants: dict[str, dict[str, str]]) -> dict[str, dict[str, str]]:
    return effective_variants(variants)


def check(current: dict[str, dict[str, str]], baseline: dict[str, dict[str, str]]) -> list[str]:
    errors: list[str] = []
    for name, props in sorted(current.items()):
        # Phase 27-2 后，存量与新增字号都必须落在 token 标尺内。
        current_size = props.get("font_sizes/font_size")
        if current_size is not None and int(current_size) not in FONT_SIZES:
            errors.append(f"{name} 当前字号不在 token: {current_size}")
        for key in COLOR_KEYS:
            value = props.get(key)
            if value is not None and value not in COLORS:
                errors.append(f"{name} {key} 当前字体色不在 token: {value}")
        previous = baseline.get(name)
        if previous is None:
            value = props.get("constants/outline_size")
            if value is not None and int(value) not in OUTLINE_SIZES:
                errors.append(f"新增变体 {name} 描边不在 token: {value}")
            base = props.get("base_type", "").strip('&"')
            if base.startswith("Semantic") or name.startswith("Semantic"):
                continue
            if base == "Button" or (base in current and current[base].get("base_type") == '&"Button"'):
                if base != "Button" and base not in BUTTON_TOKEN_BASES:
                    errors.append(f"新增 Button 变体 {name} 未继承登记 token 基类: {base}")
                if base == "Button":
                    errors.append(f"新增 Button 变体 {name} 直接继承 Button，应使用 token 基类")
            continue
        value = props.get("constants/outline_size")
        old = previous.get("constants/outline_size", "")
        if value is not None and value != old and int(value) not in OUTLINE_SIZES:
            errors.append(f"{name} constants/outline_size 改写值不在 token: {value}")
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

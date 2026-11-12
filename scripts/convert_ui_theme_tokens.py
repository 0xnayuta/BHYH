#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""UI Theme token 源生成与一致性校验。

`scripts/ui_theme_tokens.json` 是字号、语义色、字体角色、受管 Theme 属性与
Theme token 审计集合的单一来源。本脚本：

- `--write`：生成 `UiColorTokens`、`UiSurfaceTokens`，并回写 Theme 的受管属性；
- `--check`：要求生成结果与工作区完全一致，发现 Theme/脚本双写漂移时失败。

首期只管理共享色彩、输入配色与默认字体；不重排 618 个变体，不改字号基线。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
TOKEN_SOURCE = ROOT / "scripts" / "ui_theme_tokens.json"
THEME = SOURCE / "Scene" / "theme" / "bhyh_theme.tres"
COLOR_CLASS = SOURCE / "Script" / "base" / "ui_color_tokens.gd"
SURFACE_CLASS = SOURCE / "Script" / "base" / "ui_surface_tokens.gd"
FONT_SIZE_CLASS = SOURCE / "Script" / "base" / "ui_font_sizes.gd"
SCHEMA_ID = "ui_theme_tokens"
SCHEMA_VERSION = 1
NAME_RE = re.compile(r"^[A-Z][A-Z0-9_]*$")
IDENT_RE = re.compile(r"^[A-Z][A-Z0-9_]*$")
DEFAULT_FONT_KEY = "default_font"


def load_source() -> dict:
    if not TOKEN_SOURCE.is_file():
        raise ValueError(f"token 源不存在: {TOKEN_SOURCE.relative_to(ROOT)}")
    data = json.loads(TOKEN_SOURCE.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("token 源必须是 JSON 对象")
    if data.get("schema_id") != SCHEMA_ID or data.get("schema_version") != SCHEMA_VERSION:
        raise ValueError("token 源 schema 不匹配")
    for key in ("text_tokens", "surface_groups", "theme_only", "default_font", "theme_properties", "theme_font_colors", "theme_audit"):
        if key not in data:
            raise ValueError(f"token 源缺少 {key}")
    validate_source(data)
    return data


def validate_source(data: dict) -> None:
    names: set[str] = set()
    for name in data["text_tokens"]:
        _validate_name(name, names, "text_tokens")
    for group in data["surface_groups"]:
        if not isinstance(group, dict) or not isinstance(group.get("title"), str):
            raise ValueError("surface_groups 条目非法")
        for name in group.get("tokens", {}):
            _validate_name(name, names, "surface_groups")
    for name, value in data["theme_only"].items():
        if not isinstance(name, str) or not isinstance(value, str) or not value.strip():
            raise ValueError("theme_only 条目非法")
    palette_names: set[str] = set()
    for name, value in data["theme_font_colors"].items():
        _validate_name(name, palette_names, "theme_font_colors")
        if not isinstance(value, str) or not value.strip():
            raise ValueError(f"theme_font_colors.{name} 值非法")
    for name, value in _all_constants(data).items():
        if not isinstance(value, str) or not value.strip():
            raise ValueError(f"token {name} 值非法")
    for name, ref in data["theme_properties"].items():
        if not isinstance(name, str) or not isinstance(ref, str):
            raise ValueError("theme_properties 条目非法")
        if ref != "font.default":
            resolve(data, ref)
    font = data["default_font"]
    if not isinstance(font.get("resource_id"), str) or not isinstance(font.get("path"), str):
        raise ValueError("default_font 条目非法")
    audit = data["theme_audit"]
    for key in ("font_sizes", "outline_sizes", "button_token_bases"):
        if not isinstance(audit.get(key), list):
            raise ValueError(f"theme_audit.{key} 必须是数组")


def _validate_name(name: str, names: set[str], where: str) -> None:
    if not isinstance(name, str) or not NAME_RE.match(name):
        raise ValueError(f"{where} token 名非法: {name!r}")
    if name in names:
        raise ValueError(f"token 重名: {name}")
    names.add(name)


def _all_constants(data: dict) -> dict[str, str]:
    result = dict(data["text_tokens"])
    for group in data["surface_groups"]:
        result.update(group["tokens"])
    result.update(data["theme_only"])
    return result


def resolve(data: dict, ref: str) -> str:
    if ref == "font.default":
        return "font.default"
    if "." not in ref:
        raise ValueError(f"token 引用非法: {ref}")
    group, name = ref.split(".", 1)
    if group == "text":
        values = data["text_tokens"]
    elif group == "surface":
        values = {}
        for item in data["surface_groups"]:
            values.update(item["tokens"])
    elif group == "theme_only":
        values = data["theme_only"]
    else:
        raise ValueError(f"未知 token 组: {ref}")
    if name not in values:
        raise ValueError(f"未知 token: {ref}")
    return values[name]


def resolve_color(data: dict, expression: str, seen: set[str] | None = None) -> str:
    """将常量别名解析为最终 GDScript 颜色表达式。"""
    if seen is None:
        seen = set()
    value = expression.strip()
    if value.startswith("Color("):
        return value
    if IDENT_RE.match(value):
        if value in seen:
            raise ValueError(f"token 循环引用: {value}")
        constants = _all_constants(data)
        if value not in constants:
            raise ValueError(f"未知颜色别名: {value}")
        return resolve_color(data, constants[value], seen | {value})
    raise ValueError(f"不支持的 token 表达式: {expression}")


def render_color_class(data: dict) -> str:
    lines = [
        "# 由 scripts/ui_theme_tokens.json 生成；不要手改。",
        "class_name UiColorTokens",
        "extends RefCounted",
        "",
        "## 脚本动态 UI 的语义文字色。值来自 scripts/ui_theme_tokens.json。",
        "",
    ]
    for name, value in data["text_tokens"].items():
        lines.append(f"const {name} := {value}")
    return "\n".join(lines) + "\n"


def render_surface_class(data: dict) -> str:
    lines = [
        "# 由 scripts/ui_theme_tokens.json 生成；不要手改。",
        "class_name UiSurfaceTokens",
        "extends RefCounted",
        "",
        "## 脚本自绘面板的 StyleBox 底色、边框、遮罩与输入配色。",
        "## 值来自 scripts/ui_theme_tokens.json；与文字色分离。",
    ]
    for group in data["surface_groups"]:
        lines.extend(["", f"# {group['title']}"])
        for name, value in group["tokens"].items():
            lines.append(f"const {name} := {value}")
    return "\n".join(lines) + "\n"


def render_font_size_class(data: dict) -> str:
    lines = [
        "# 由 scripts/ui_theme_tokens.json 生成；不要手改。",
        "class_name UiFontSizes",
        "extends RefCounted",
        "",
        "## 脚本动态 UI 的 token 字号；值来自 theme_audit.font_sizes。",
    ]
    sizes = set(data["theme_audit"]["font_sizes"])
    sizes.update(data.get("script_font_sizes", []))
    for size in sorted(sizes):
        lines.append(f"const FONT_SIZE_{int(size)} := {int(size)}")
    return "\n".join(lines) + "\n"


_INTEGRAL_FLOAT_RE = re.compile(r'(?<![\d.])(-?\d+)\.0(?![\d])')


def _canonical_color_text(value: str) -> str:
    """按 Godot 文本序列化规范去掉整数值的小数尾巴（1.0 -> 1）。"""
    return _INTEGRAL_FLOAT_RE.sub(r"\1", value)


def expected_theme_value(data: dict, key: str) -> str:
    ref = data["theme_properties"][key]
    if ref == "font.default":
        return f'ExtResource("{data["default_font"]["resource_id"]}")'
    return _canonical_color_text(resolve_color(data, resolve(data, ref)))


def _find_theme_line(lines: list[str], key: str) -> int:
    matches = [index for index, line in enumerate(lines) if line.startswith(f"{key} = ")]
    if len(matches) != 1:
        raise ValueError(f"Theme 受管属性 {key} 出现 {len(matches)} 次，期望 1 次")
    return matches[0]


def render_theme(data: dict) -> str:
    if not THEME.is_file():
        raise ValueError(f"Theme 不存在: {THEME.relative_to(ROOT)}")
    lines = THEME.read_text(encoding="utf-8").splitlines()
    for key in data["theme_properties"]:
        value = expected_theme_value(data, key)
        index = _find_theme_line(lines, key)
        lines[index] = f"{key} = {value}"
    font = data["default_font"]
    # 编辑器保存会给 ext_resource 追加 uid 并可能调整属性顺序；
    # 这里按 type/path/id 三个属性匹配，不依赖整行文本与 uid 是否存在。
    if not any(
        line.startswith('[ext_resource type="FontVariation"')
        and f'path="{font["path"]}"' in line
        and f'id="{font["resource_id"]}"' in line
        for line in lines
    ):
        raise ValueError(f"Theme 缺少 default_font 资源声明: {font['path']} (id={font['resource_id']})")
    return "\n".join(lines) + "\n"


def check_generated(path: Path, expected: str) -> list[str]:
    if not path.is_file():
        return [f"生成文件不存在: {path.relative_to(ROOT)}"]
    actual = path.read_text(encoding="utf-8")
    if actual == expected:
        return []
    actual_lines = actual.splitlines()
    expected_lines = expected.splitlines()
    for index, (left, right) in enumerate(zip(actual_lines, expected_lines), 1):
        if left != right:
            return [f"{path.relative_to(ROOT)}:{index} 漂移: 当前 {left!r}，期望 {right!r}"]
    return [f"{path.relative_to(ROOT)} 行数漂移: 当前 {len(actual_lines)}，期望 {len(expected_lines)}"]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="UI Theme token 生成/一致性校验")
    parser.add_argument("--check", action="store_true", help="生成结果与工作区不一致时返回 1")
    parser.add_argument("--write", action="store_true", help="回写 UiColorTokens/UiSurfaceTokens 与 Theme 受管属性")
    args = parser.parse_args(argv)
    if args.check and args.write:
        print("FAIL --check 与 --write 不能同时使用", file=sys.stderr)
        return 2
    try:
        data = load_source()
        color_text = render_color_class(data)
        surface_text = render_surface_class(data)
        font_size_text = render_font_size_class(data)
        theme_text = render_theme(data)
    except (ValueError, OSError, json.JSONDecodeError) as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        return 2
    if args.write:
        for path, content in ((COLOR_CLASS, color_text), (SURFACE_CLASS, surface_text), (FONT_SIZE_CLASS, font_size_text), (THEME, theme_text)):
            if not path.is_file() or path.read_text(encoding="utf-8") != content:
                path.write_text(content, encoding="utf-8", newline="\n")
        print("已生成颜色/表面/字号 token 类与 Theme 受管属性")
        return 0
    errors = check_generated(COLOR_CLASS, color_text) + check_generated(SURFACE_CLASS, surface_text) + check_generated(FONT_SIZE_CLASS, font_size_text) + check_generated(THEME, theme_text)
    if errors:
        print(f"token 源校验失败: {len(errors)} 处", file=sys.stderr)
        for error in errors[:20]:
            print("FAIL", error, file=sys.stderr)
        return 1
    print(
        "token 源: 文字 {}、表面 {} 组、Theme 受管属性 {}、审计字号 {}、审计颜色 {}；0 漂移".format(
            len(data["text_tokens"]),
            len(data["surface_groups"]),
            len(data["theme_properties"]),
            len(data["theme_audit"]["font_sizes"]),
            len(data["theme_font_colors"]),
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

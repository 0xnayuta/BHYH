#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Phase 27-7 动态主题覆盖审计。

扫描全部 `source/**/*.gd`（排除 `addons/` 与 `.godot/`），把
`add_theme_*` 调用分为：

- static_role: 字面字号/颜色/字体路径或字面 StyleBox，禁止存在；
- tokenized: 使用 `UiColorTokens` / `UiSurfaceTokens` / `UiFontSizes` 或已生成的样式函数；
- data: 使用业务数据、变量或运行时生成值；
- layout: `add_theme_constant_override` 布局常量；
- dynamic_style: 函数生成的 StyleBox（当前均读取 token）。

解析器按括号平衡合并跨行调用，避免多行 StyleBox 绕过分类。静态角色覆盖必须为 0；
其余调用总数不得超过基线，避免新增未登记覆盖。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
BASELINE = ROOT / "scripts" / "ui_dynamic_theme_baseline.json"
SCHEMA_ID = "ui_dynamic_theme_baseline"
SCHEMA_VERSION = 1
CALL_START_RE = re.compile(r"add_theme_(font_size|font|color|constant|stylebox|icon)[a-z_]*\s*\(")
TOKEN_MARKERS = ("UiColorTokens", "UiSurfaceTokens", "UiFontSizes", "UiFontRoles")


def classify(kind: str, value: str) -> str:
    value = value.strip()
    if kind == "constant":
        return "layout"
    if kind == "stylebox":
        if value.startswith("_"):
            return "dynamic_style"
        if value.startswith("StyleBox"):
            return "static_role"
        return "tokenized" if any(marker in value for marker in TOKEN_MARKERS) else "data"
    if kind in {"font", "font_size"}:
        if any(marker in value for marker in TOKEN_MARKERS):
            return "tokenized"
        if kind == "font_size" and re.fullmatch(r"\d+(?:\.\d+)?", value):
            return "static_role"
        if kind == "font" and (
            "preload(" in value
            or "load(" in value
            or value.startswith("res://")
            or value in {"UI_FONT", "TOWER_FONT", "FORMULA_FONT", "PET_EQUIPMENT_STRENGTH_FONT"}
        ):
            return "static_role"
        return "data"
    if kind == "color":
        if any(marker in value for marker in TOKEN_MARKERS):
            return "tokenized"
        if value.startswith("Color.html(") or value.startswith("Color.from_"):
            return "data"
        if re.fullmatch(r"Color\(\s*[A-Za-z_]\w*\s*\)", value):
            return "data"
        if value.startswith("Color(") or value.startswith('"') or value.startswith("Color."):
            return "static_role"
        return "data"
    return "data"


def _split_arguments(arguments: str) -> list[str]:
    """按顶层逗号拆分调用参数，保留嵌套调用与字符串。"""
    parts: list[str] = []
    start = 0
    depth = 0
    quote = ""
    escaped = False
    for index, char in enumerate(arguments):
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = ""
            continue
        if char in {'"', "'"}:
            quote = char
            continue
        if char in "([{":
            depth += 1
        elif char in ")]}":
            depth -= 1
        elif char == "," and depth == 0:
            parts.append(arguments[start:index].strip())
            start = index + 1
    tail = arguments[start:].strip()
    if tail:
        parts.append(tail)
    return parts


def _collect_call(lines: list[str], start_line: int, start_column: int) -> tuple[str, int]:
    """从起始行收集完整调用文本，返回文本与结束行号。"""
    text = lines[start_line][start_column:]
    depth = 0
    quote = ""
    escaped = False
    line_index = start_line
    while True:
        for char in lines[line_index] if line_index != start_line else text:
            if quote:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == quote:
                    quote = ""
                continue
            if char in {'"', "'"}:
                quote = char
            elif char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
        if depth <= 0 or line_index + 1 >= len(lines):
            return text, line_index
        line_index += 1
        text += "\n" + lines[line_index]


def _parse_call(text: str) -> tuple[str, str] | None:
    """解析调用方法名前缀与第二个参数。"""
    match = CALL_START_RE.search(text)
    if match is None:
        return None
    open_index = text.find("(", match.start())
    if open_index < 0:
        return None
    depth = 0
    quote = ""
    escaped = False
    close_index = -1
    for index in range(open_index, len(text)):
        char = text[index]
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = ""
            continue
        if char in {'"', "'"}:
            quote = char
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                close_index = index
                break
    if close_index < 0:
        return None
    arguments = _split_arguments(text[open_index + 1 : close_index])
    if len(arguments) < 2:
        return None
    return match.group(1), arguments[1]


def scan() -> dict[str, object]:
    files: dict[str, Counter[str]] = defaultdict(Counter)
    rows: list[dict[str, str | int]] = []
    parse_errors: list[dict[str, str | int]] = []
    for path in sorted(SOURCE.rglob("*.gd")):
        if path.is_relative_to(SOURCE / "addons") or path.is_relative_to(SOURCE / ".godot"):
            continue
        if path.name.startswith("level_smoke_driver_"):
            continue
        lines = path.read_text(encoding="utf-8").splitlines()
        line_index = 0
        while line_index < len(lines):
            line = lines[line_index]
            if line.lstrip().startswith("#"):
                line_index += 1
                continue
            match = CALL_START_RE.search(line)
            if match is None:
                line_index += 1
                continue
            text, end_line = _collect_call(lines, line_index, match.start())
            parsed = _parse_call(text)
            relative = path.relative_to(SOURCE).as_posix()
            if parsed is None:
                parse_errors.append({"file": relative, "line": line_index + 1, "text": text[:120]})
                line_index = end_line + 1
                continue
            kind, value = parsed
            category = classify(kind, value)
            files[relative][category] += 1
            files[relative]["total"] += 1
            rows.append({"file": relative, "line": line_index + 1, "kind": kind, "category": category})
            line_index = end_line + 1
    totals = Counter()
    for counts in files.values():
        totals.update(counts)
    return {
        "schema_id": SCHEMA_ID,
        "schema_version": SCHEMA_VERSION,
        "totals": dict(sorted(totals.items())),
        "files": {name: dict(sorted(counts.items())) for name, counts in sorted(files.items())},
        "calls": rows,
        "parse_errors": parse_errors,
    }


def _self_test() -> int:
    cases = [
        (
            'button.add_theme_stylebox_override(\n\t"normal",\n\tStyleBoxFlat.new()\n)',
            ("stylebox", "StyleBoxFlat.new()"),
            "static_role",
        ),
        (
            'button.add_theme_stylebox_override(\n\t"normal",\n\t_style(UiSurfaceTokens.COOL_PANEL, UiSurfaceTokens.COOL_BORDER)\n)',
            ("stylebox", "_style(UiSurfaceTokens.COOL_PANEL, UiSurfaceTokens.COOL_BORDER)"),
            "dynamic_style",
        ),
        (
            'label.add_theme_color_override(\n\t"font_color",\n\tUiColorTokens.TEXT_PRIMARY\n)',
            ("color", "UiColorTokens.TEXT_PRIMARY"),
            "tokenized",
        ),
        (
            'label.add_theme_color_override(\n\t"font_color",\n\tColor(color_)\n)',
            ("color", "Color(color_)"),
            "data",
        ),
    ]
    for text, expected, category in cases:
        parsed = _parse_call(text)
        if parsed != expected or classify(*parsed) != category:
            print(f"FAIL self-test: {text!r} -> {parsed}", file=sys.stderr)
            return 1
    print("PASS ui_dynamic_theme_audit self-test")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Phase 27-7 动态主题覆盖审计")
    parser.add_argument("--check", action="store_true", help="静态角色覆盖或调用总数超过基线时返回 1")
    parser.add_argument("--write-baseline", action="store_true", help="写入当前分类计数基线")
    parser.add_argument("--json", action="store_true", help="输出 JSON")
    parser.add_argument("--self-test", action="store_true", help="运行跨行解析与分类自测")
    args = parser.parse_args(argv)
    if args.self_test:
        return _self_test()
    if args.check and args.write_baseline:
        print("FAIL --check 与 --write-baseline 不能同时使用", file=sys.stderr)
        return 2
    report = scan()
    error = ""
    if report.get("parse_errors"):
        first = report["parse_errors"][0]
        error = f"无法解析 add_theme_* 调用 {first['file']}:{first['line']}"
    elif report["totals"].get("static_role", 0):
        error = f"静态角色覆盖 {report['totals']['static_role']} > 0"
    if args.write_baseline:
        if error:
            print("FAIL", error, file=sys.stderr)
            return 1
        BASELINE.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        print(
            f"已写入动态主题基线: {BASELINE.relative_to(ROOT)}，"
            f"总计 {report['totals'].get('total', 0)}，"
            f"静态 {report['totals'].get('static_role', 0)}"
        )
        return 0
    if args.json:
        print(json.dumps({"ok": not error, "error": error, **report}, ensure_ascii=False, indent=2))
        return 0 if not error else 1
    print(
        "动态主题覆盖: "
        f"总计 {report['totals'].get('total', 0)}，"
        f"静态角色 {report['totals'].get('static_role', 0)}，"
        f"token {report['totals'].get('tokenized', 0)}，"
        f"数据 {report['totals'].get('data', 0)}，"
        f"布局 {report['totals'].get('layout', 0)}，"
        f"动态样式 {report['totals'].get('dynamic_style', 0)}，"
        f"解析错误 {len(report.get('parse_errors', []))}"
    )
    if error:
        print("FAIL", error)
        return 1
    if args.check:
        if not BASELINE.is_file():
            print("FAIL 动态主题基线不存在", file=sys.stderr)
            return 2
        baseline = json.loads(BASELINE.read_text(encoding="utf-8"))
        current_total = int(report["totals"].get("total", 0))
        baseline_total = int(baseline.get("totals", {}).get("total", 0))
        if current_total > baseline_total:
            print(f"FAIL 动态主题调用 {baseline_total} -> {current_total}", file=sys.stderr)
            return 1
        for name, counts in report["files"].items():
            old = baseline.get("files", {}).get(name)
            if old is None:
                print(f"FAIL 新增未登记动态主题文件: {name}", file=sys.stderr)
                return 1
            if int(counts.get("total", 0)) > int(old.get("total", 0)):
                print(f"FAIL {name}: 动态主题调用 {old.get('total', 0)} -> {counts.get('total', 0)}", file=sys.stderr)
                return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

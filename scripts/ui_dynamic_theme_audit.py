#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Phase 27-6 动态主题覆盖审计。

将脚本内 `add_theme_*` 调用分为：

- static_role: 字面字号/颜色/字体路径或字面 StyleBox，禁止存在；
- tokenized: 使用 `UiColorTokens` / `UiSurfaceTokens` / `UiFontSizes` 或已生成的样式函数；
- data: 使用业务数据、变量或运行时生成值；
- layout: `add_theme_constant_override` 布局常量；
- dynamic_style: 函数生成的 StyleBox（当前均读取 token）。

静态角色覆盖必须为 0；其余调用总数不得超过基线，避免新增未登记覆盖。
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
CALL_RE = re.compile(r"add_theme_(font_size|font|color|constant|stylebox|icon)[a-z_]*\(([^,]+),(.*)\)\s*$")
TOKEN_MARKERS = ("UiColorTokens", "UiSurfaceTokens", "UiFontSizes", "UiFontRoles")


def classify(kind: str, value: str) -> str:
    value = value.strip().rstrip(");").strip()
    if kind == "constant":
        return "layout"
    if kind == "stylebox":
        if value.startswith("_") or value.startswith("StyleBox"):
            return "dynamic_style" if value.startswith("_") else "static_role"
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
        if value.startswith("Color(") or value.startswith('"') or value.startswith("Color."):
            return "static_role"
        return "data"
    return "data"


def scan() -> dict[str, object]:
    files: dict[str, Counter[str]] = defaultdict(Counter)
    rows: list[dict[str, str | int]] = []
    for path in sorted((SOURCE / "Script").rglob("*.gd")):
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if "add_theme_" not in line:
                continue
            match = CALL_RE.search(line)
            if match is None:
                category = "dynamic_style" if "add_theme_stylebox" in line else "data"
                kind = "stylebox" if "add_theme_stylebox" in line else "unknown"
                value = ""
            else:
                kind = match.group(1)
                value = match.group(3)
                category = classify(kind, value)
            relative = path.relative_to(SOURCE).as_posix()
            files[relative][category] += 1
            files[relative]["total"] += 1
            rows.append({"file": relative, "line": line_number, "kind": kind, "category": category})
    totals = Counter()
    for counts in files.values():
        totals.update(counts)
    return {
        "schema_id": SCHEMA_ID,
        "schema_version": SCHEMA_VERSION,
        "totals": dict(sorted(totals.items())),
        "files": {name: dict(sorted(counts.items())) for name, counts in sorted(files.items())},
        "calls": rows,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Phase 27-6 动态主题覆盖审计")
    parser.add_argument("--check", action="store_true", help="静态角色覆盖或调用总数超过基线时返回 1")
    parser.add_argument("--write-baseline", action="store_true", help="写入当前分类计数基线")
    parser.add_argument("--json", action="store_true", help="输出 JSON")
    args = parser.parse_args(argv)
    if args.check and args.write_baseline:
        print("FAIL --check 与 --write-baseline 不能同时使用", file=sys.stderr)
        return 2
    report = scan()
    error = ""
    if report["totals"].get("static_role", 0):
        error = f"静态角色覆盖 {report['totals']['static_role']} > 0"
    if args.write_baseline:
        BASELINE.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        print(
            f"已写入动态主题基线: {BASELINE.relative_to(ROOT)}，"
            f"总计 {report['totals'].get('total', 0)}，"
            f"静态 {report['totals'].get('static_role', 0)}"
        )
        return 0 if not error else 1
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
        f"动态样式 {report['totals'].get('dynamic_style', 0)}"
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

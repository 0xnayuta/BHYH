#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""自绘 StyleBox 与 main_menu 裸色审计。

扫描 `source/Script`：

- 所有包含 `StyleBoxFlat` 的脚本，`bg_color` / `border_color` / `shadow_color`
  不得直接写 `Color(...)`、`Color("...")` 或 `Color.<常量>`；
- `Script/main_menu` 下所有脚本不得直接写裸色，确保动态文字、遮罩、modulate、
  shader 参数也通过 `UiSurfaceTokens` / `UiColorTokens` 表达。

`Color.WHITE` / `Color.TRANSPARENT` 是重置与透明占位，不视为调色板裸色。
迁移期既有脚本用 `scripts/ui_surface_token_baseline.json` 冻结；基线只允许下降，
新代码不得新增违规。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
SCRIPTS = SOURCE / "Script"
BASELINE = ROOT / "scripts" / "ui_surface_token_baseline.json"
SCHEMA_ID = "ui_surface_token_baseline"
SCHEMA_VERSION = 1
RAW_COLOR_RE = re.compile(r"\bColor\s*(?:\(|\.)")
STYLE_ASSIGN_RE = re.compile(
    r"\.(?:bg_color|border_color|shadow_color)\s*=\s*(.+?)(?:\s*#.*)?$"
)
ALLOWED_COLOR_CONSTANTS = ("Color.WHITE", "Color.TRANSPARENT")
ALLOWED_COLOR_CALLS = ("Color.html(", "Color.from_string(")
MAIN_MENU_PREFIX = "Script/main_menu/"


def _normalized(rel: str, code: str) -> str:
    return f"{rel}::{code.strip()}"


def scan_text(rel: str, text: str) -> Counter[str]:
    """返回 `文件::代码` 计数；同一裸色行重复出现时保留次数。"""
    violations: Counter[str] = Counter()
    menu_scope = rel.startswith(MAIN_MENU_PREFIX)
    style_scope = "StyleBoxFlat.new()" in text
    for raw_line in text.splitlines():
        code = raw_line.split("#", 1)[0].rstrip()
        if not code or not RAW_COLOR_RE.search(code):
            continue
        scrubbed = code
        for constant in ALLOWED_COLOR_CONSTANTS:
            scrubbed = scrubbed.replace(constant, "")
        for call in ALLOWED_COLOR_CALLS:
            scrubbed = scrubbed.replace(call, "")
        if not RAW_COLOR_RE.search(scrubbed):
            continue
        style_match = STYLE_ASSIGN_RE.search(code)
        if menu_scope or (style_scope and style_match):
            violations[_normalized(rel, code)] += 1
    return violations


def scan() -> Counter[str]:
    violations: Counter[str] = Counter()
    for path in sorted(SCRIPTS.rglob("*.gd")):
        rel = path.relative_to(SOURCE).as_posix()
        text = path.read_text(encoding="utf-8", errors="ignore")
        violations.update(scan_text(rel, text))
    return violations


def load_baseline() -> Counter[str]:
    if not BASELINE.is_file():
        raise ValueError(f"基线不存在: {BASELINE.relative_to(ROOT)}")
    data = json.loads(BASELINE.read_text(encoding="utf-8"))
    if data.get("schema_id") != SCHEMA_ID or data.get("schema_version") != SCHEMA_VERSION:
        raise ValueError("基线 schema 不匹配")
    entries = data.get("entries")
    if not isinstance(entries, dict):
        raise ValueError("基线缺少 entries")
    baseline: Counter[str] = Counter()
    for key, count in entries.items():
        if not isinstance(key, str) or not isinstance(count, int) or count < 1:
            raise ValueError("基线条目非法")
        baseline[key] = count
    return baseline


def write_baseline(current: Counter[str]) -> None:
    data = {
        "schema_id": SCHEMA_ID,
        "schema_version": SCHEMA_VERSION,
        "entries": dict(sorted(current.items())),
    }
    BASELINE.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )


def check(current: Counter[str], baseline: Counter[str]) -> tuple[list[str], int]:
    new: list[str] = []
    for key, count in sorted(current.items()):
        allowed = baseline.get(key, 0)
        if count > allowed:
            new.append(f"{key}（当前 {count}，基线 {allowed}）")
    stale = sum(max(0, count - current.get(key, 0)) for key, count in baseline.items())
    return new, stale


def self_test() -> int:
    cases = [
        ("Script/main_menu/demo.gd", "rect.color = Color(1, 0, 0, 1)\n", 1),
        ("Script/main_menu/demo.gd", "rect.color = Color.WHITE\n", 0),
        ("Script/main_menu/demo.gd", "rect.color = Color.TRANSPARENT\n", 0),
        ("Script/main_menu/demo.gd", "rect.color = UiSurfaceTokens.OVERLAY_MEDIUM\n", 0),
        ("Script/main_menu/demo.gd", "rect.color = Color.html(\"ff0000\")\n", 0),
        ("Script/main_menu/demo.gd", "rect.color = Color.from_string(\"ff0000\", Color.WHITE)\n", 0),
        ("Script/main_menu/demo.gd", "rect.modulate = Color(0.55, 0.55, 0.55, 1) if false else Color.WHITE\n", 1),
        ("Script/main_menu/demo.gd", "label.add_theme_color_override(\"font_color\", Color(1, 0, 0, 1))\n", 1),
        ("Script/other/demo.gd", "var style := StyleBoxFlat.new()\nstyle.bg_color = Color(1, 0, 0, 1)\n", 1),
        ("Script/other/demo.gd", "var style := StyleBoxFlat.new()\nstyle.bg_color = UiSurfaceTokens.COOL_DEEP\n", 0),
        ("Script/other/demo.gd", "var shade := ColorRect.new()\nshade.color = Color(0, 0, 0, 1)\n", 0),
    ]
    failed = 0
    for rel, text, expected in cases:
        actual = sum(scan_text(rel, text).values())
        if actual != expected:
            failed += 1
            print(f"FAIL self-test {rel}: expected {expected}, got {actual}")
    print(f"ui surface token self-test: {len(cases) - failed}/{len(cases)} PASS")
    return 0 if failed == 0 else 1


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="自绘 StyleBox 与 main_menu 裸色审计")
    parser.add_argument("--check", action="store_true", help="与基线比较，新增裸色时返回 1")
    parser.add_argument("--write-baseline", action="store_true", help="写入当前裸色基线")
    parser.add_argument("--self-test", action="store_true", help="运行扫描规则正负样本")
    parser.add_argument("--json", action="store_true", help="输出 JSON")
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    if args.check and args.write_baseline:
        print("FAIL --check 与 --write-baseline 不能同时使用", file=sys.stderr)
        return 2
    if not SCRIPTS.is_dir():
        print(f"FAIL 业务脚本目录不存在: {SCRIPTS}", file=sys.stderr)
        return 2
    current = scan()
    if args.write_baseline:
        write_baseline(current)
        print(f"已写入表面色基线: {BASELINE.relative_to(ROOT)}，条目 {len(current)}")
        return 0
    if not args.check:
        print(f"ui surface token: 裸色 {sum(current.values())} 处，条目 {len(current)}")
        return 0
    try:
        baseline = load_baseline()
    except (ValueError, OSError) as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        return 2
    new, stale = check(current, baseline)
    if args.json:
        print(json.dumps({"ok": not new, "new": new, "stale": stale, "current": sum(current.values())}, ensure_ascii=False, indent=2))
    else:
        print(f"ui surface token: 当前 {sum(current.values())} 处，基线 {sum(baseline.values())} 处，新增 {len(new)} 处，基线失效 {stale} 处")
        for item in new[:30]:
            print("FAIL", item)
    return 0 if not new else 1


if __name__ == "__main__":
    raise SystemExit(main())

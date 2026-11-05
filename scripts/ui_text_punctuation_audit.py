#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
UI 文本标点审计（report-only）
================================

扫描 `source/**/*.gd` 与 `source/**/*.tscn` 中的用户可见文本标点，报告
中文自然语言里残留的 ASCII 冒号、逗号、分号、问号、感叹号、括号与省略号。

本脚本默认只报告，不进入 `check_all`；发现项不会导致非零退出码。需要作为
门禁使用时显式传入 `--fail-on-findings`。

明确排除：
- `print` / `printerr` / `push_error` / `push_warning` / `assert` / `_report_missing`
  开发日志与断言；
- `RegEx.compile` 正则表达式；
- `skill_damage_formula_data.gd` 数学公式；
- `@export_enum` 编辑器标签；
- `runtime_diagnostics.gd` 调试覆盖层；
- `res://` / `user://` 路径与文件对话框 MIME 过滤器；
- `Lv.`、小数、版本号与编号列表的 `1.` 标记；
- 全角标点、代码标识符与格式占位。
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"

SKIP_FILES = {
    "skill_damage_formula_data.gd",
    "runtime_diagnostics.gd",
}
SKIP_PARTS = {"addons", ".godot"}
LOG_MARKERS = ("print(", "printerr(", "push_error(", "push_warning(", "assert(", "_report_missing(")
LOG_BLOCK_MARKERS = LOG_MARKERS
UI_MARKERS = (".text", "add_message_show", "set_button_text", "set_text", "tooltip_text")

STRING_RE = re.compile(r'"(?:\\.|[^"\\])*"')
CJK_RE = re.compile(r"[\u3400-\u9fff]")
NATURAL_PUNCT_RE = re.compile(r"[,:;!?()~]")
ELLIPSIS_RE = re.compile(r"\.{3,}")
SENTENCE_PERIOD_RE = re.compile(r"[\u3400-\u9fff）】”’]\.(?=$|[^0-9A-Za-z])")
LIST_MARKER_RE = re.compile(r"^\s*\d+\.\s*")
VERSION_RE = re.compile(r"\bV\d+(?:[._]\d+)*\b")
DECIMAL_RE = re.compile(r"\b\d+\.\d+\b")
LEVEL_ABBR_RE = re.compile(r"\bLv\.")
EXPORT_ENUM_RE = re.compile(r"@export_enum\s*\((?:[^()]|\([^)]*\))*\)", re.S)
UI_PUNCT_LITERAL_RE = re.compile(r"^(?:[,:;!?()~]|\.{3,})$")


@dataclass(frozen=True)
class Finding:
    path: str
    line: int
    category: str
    text: str


def _rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def _skip_line(path: Path, line: str) -> bool:
    if path.name in SKIP_FILES:
        return True
    if any(part in SKIP_PARTS for part in path.parts):
        return True
    if any(marker in line for marker in LOG_MARKERS):
        return True
    if "res://" in line or "user://" in line:
        return True
    if "filters =" in line or "application/" in line:
        return True
    if ".compile(" in line or "RegEx.new(" in line:
        return True
    return False


def _export_enum_lines(text: str) -> set[int]:
    lines: set[int] = set()
    for match in EXPORT_ENUM_RE.finditer(text):
        start = text.count("\n", 0, match.start()) + 1
        end = text.count("\n", 0, match.end()) + 1
        lines.update(range(start, end + 1))
    return lines


def _normalize(text: str) -> str:
    """移除不作为自然语言缺陷处理的数字/列表标记。"""
    text = LIST_MARKER_RE.sub("", text)
    text = VERSION_RE.sub("", text)
    text = DECIMAL_RE.sub("", text)
    return LEVEL_ABBR_RE.sub("", text)


def classify_literal(text: str) -> bool:
    """判断字符串是否仍含中文自然语言 ASCII 标点。"""
    if not CJK_RE.search(text):
        return False
    normalized = _normalize(text)
    if ELLIPSIS_RE.search(normalized):
        return True
    if NATURAL_PUNCT_RE.search(normalized):
        return True
    return bool(SENTENCE_PERIOD_RE.search(normalized))


def _ui_punctuation_literals(line: str) -> list[str]:
    """检测 UI 拼接中的纯标点字面量，例如 + ":"。"""
    if not any(marker in line for marker in UI_MARKERS):
        return []
    result: list[str] = []
    for match in STRING_RE.finditer(line):
        value = match.group(0)[1:-1]
        if CJK_RE.search(value):
            continue
        if UI_PUNCT_LITERAL_RE.fullmatch(value):
            result.append(value)
    return result


def _paren_delta(line: str) -> int:
    """统计代码行括号深度，忽略字符串内容与注释。"""
    code = STRING_RE.sub("", line).split("#", 1)[0]
    return code.count("(") - code.count(")")


def _scan_file(path: Path) -> list[Finding]:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return []
    enum_lines = _export_enum_lines(text) if path.suffix == ".gd" else set()
    findings: list[Finding] = []
    log_depth = 0
    for line_number, line in enumerate(text.splitlines(), 1):
        if log_depth > 0:
            log_depth += _paren_delta(line)
            if log_depth < 0:
                log_depth = 0
            continue
        if any(marker in line for marker in LOG_BLOCK_MARKERS):
            log_depth = max(0, _paren_delta(line))
            continue
        if line_number in enum_lines or _skip_line(path, line):
            continue
        for match in STRING_RE.finditer(line):
            literal = match.group(0)[1:-1]
            if classify_literal(literal):
                findings.append(Finding(_rel(path), line_number, "literal", literal))
        for literal in _ui_punctuation_literals(line):
            findings.append(Finding(_rel(path), line_number, "ui-concat", literal))
    return findings


def _self_test() -> int:
    samples = [
        ("正在准备资源...", True),
        ("8.效果.", True),
        ("1.修复双排模式", False),
        ("V6.0更新详情", False),
        ("Lv.90", False),
        ("1.3倍伤害", False),
        ("普通（1）", False),
        ("batch_get_texture_rects()", False),
        ("召唤物转轮王（神器）", False),
    ]
    failures = [text for text, expected in samples if classify_literal(text) != expected]
    if failures:
        print("[FAIL] 自测失败: " + repr(failures), file=sys.stderr)
        return 1
    print(f"[PASS] 自测通过: {len(samples)} 个样本")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="UI 文本标点审计（report-only）")
    parser.add_argument("--fail-on-findings", action="store_true", help="发现项返回退出码 1；默认仅报告")
    parser.add_argument("--self-test", action="store_true", help="运行内置样本分类自测")
    args = parser.parse_args()

    if args.self_test:
        return _self_test()

    if not SOURCE.is_dir():
        print(f"[ERROR] 找不到 source 目录: {SOURCE}", file=sys.stderr)
        return 2

    findings: list[Finding] = []
    for path in sorted(SOURCE.rglob("*")):
        if path.suffix not in {".gd", ".tscn"}:
            continue
        findings.extend(_scan_file(path))

    if not findings:
        print("[PASS] 未发现中文自然语言 ASCII 标点残留")
        return 0

    print(f"[INFO] 报告模式：发现 {len(findings)} 处中文自然语言 ASCII 标点")
    for item in findings:
        print(f"  {item.path}:{item.line} [{item.category}] {item.text}")
    print("[INFO] 默认不阻塞；需要门禁时使用 --fail-on-findings")
    return 1 if args.fail_on_findings else 0


if __name__ == "__main__":
    raise SystemExit(main())

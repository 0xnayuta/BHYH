#!/usr/bin/env python3
"""非 atlas 运行时 PNG 流 allowlist 门禁。

除冻结 allowlist 外，本门禁还检查已迁移消费者：
- 不得再写回 StreamedPngEffect 已删除的数组/播放字段，只允许注入 FrameSequence；
- 不得恢复 DirAccess 目录枚举、编号 PNG 探测或逐帧 PNG 路径扫描。
负向检查只作用于 allowlist 内的生产消费者，避免把其它系统的合法目录访问误报为
PNG 流回退；不自动扩大 allowlist。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / "source"
SCRIPT_ROOT = PROJECT / "Script"
ALLOWLIST = ROOT / "scripts" / "png_stream_allowlist.json"
STREAM_CLASS_FILE = "Script/monster/streamed_png_effect.gd"

UNAMBIGUOUS_LEGACY_PROPERTIES = (
    "frame_paths",
    "frame_textures",
    "frame_regions",
    "frame_margins",
    "frame_has_visual",
    "loop_animation",
)
AMBIGUOUS_LEGACY_PROPERTIES = ("fps", "hold_last_frame", "prefetch_frames")
STREAM_RECEIVER_PATTERNS = (
    re.compile(r"\bvar\s+([A-Za-z_]\w*)\s*:\s*StreamedPngEffect\b"),
    re.compile(r"\bvar\s+([A-Za-z_]\w*)\s*:=\s*StreamedPngEffect\.new\s*\("),
    re.compile(r"\b([A-Za-z_]\w*)\s*:=\s*[^\n=]+\.new\(\)\s*as\s+StreamedPngEffect\b"),
    re.compile(r"\b([A-Za-z_]\w*)\s*=\s*StreamedPngEffect\.new\s*\("),
    re.compile(r"\b([A-Za-z_]\w*)\s*:\s*StreamedPngEffect\b"),
)
DIRECTORY_SCAN_PATTERN = re.compile(r"\bDirAccess\.(open|get_files_at|get_directories_at)\s*\(")
EXISTS_CALL_PATTERN = re.compile(r"\bResourceLoader\.exists\s*\(")
NUMBERED_PNG_PATTERN = re.compile(r"%[^\"'\s]*\.png|\.png[\"']\s*%", re.IGNORECASE)


def load_allowlist() -> dict[str, str]:
    data = json.loads(ALLOWLIST.read_text(encoding="utf-8"))
    entries = data.get("allowed_files") or {}
    return {str(key): str(value) for key, value in entries.items()}


def line_number(text: str, index: int) -> int:
    return text[:index].count("\n") + 1


def call_arguments(text: str, open_paren: int) -> str:
    """返回括号内的文本；用于检查 ResourceLoader.exists 的实际参数。"""
    depth = 0
    quote = ""
    escaped = False
    for index in range(open_paren, len(text)):
        char = text[index]
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = ""
            continue
        if char in "\"'":
            quote = char
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return text[open_paren + 1 : index]
    return text[open_paren + 1 :]


def stream_receivers(text: str) -> set[str]:
    receivers: set[str] = set()
    for pattern in STREAM_RECEIVER_PATTERNS:
        receivers.update(match.group(1) for match in pattern.finditer(text))
    return receivers


def scan_migrated_consumer(rel: str, text: str) -> list[tuple[str, int, str]]:
    findings: list[tuple[str, int, str]] = []
    unambiguous_pattern = re.compile(
        r"\.(%s)\s*=(?!=)"
        % "|".join(re.escape(name) for name in UNAMBIGUOUS_LEGACY_PROPERTIES)
    )
    for match in unambiguous_pattern.finditer(text):
        findings.append(
            (
                rel,
                line_number(text, match.start()),
                f"已迁移消费者写回旧 StreamedPngEffect 数组/播放字段 .{match.group(1)}；只允许注入 FrameSequence",
            )
        )
    receivers = stream_receivers(text)
    for receiver in sorted(receivers):
        property_pattern = re.compile(
            r"\b%s\.(%s)\s*=(?!=)"
            % (re.escape(receiver), "|".join(re.escape(name) for name in AMBIGUOUS_LEGACY_PROPERTIES))
        )
        for match in property_pattern.finditer(text):
            findings.append(
                (
                    rel,
                    line_number(text, match.start()),
                    f"已迁移消费者写回旧 StreamedPngEffect 字段 {receiver}.{match.group(1)}；只允许注入 FrameSequence",
                )
            )
    for match in DIRECTORY_SCAN_PATTERN.finditer(text):
        findings.append(
            (
                rel,
                line_number(text, match.start()),
                "已迁移消费者不得恢复 DirAccess 目录扫描；帧列表必须来自构建期 Catalog",
            )
        )
    for match in EXISTS_CALL_PATTERN.finditer(text):
        arguments = call_arguments(text, match.end() - 1)
        if ".png" in arguments.lower():
            findings.append(
                (
                    rel,
                    line_number(text, match.start()),
                    "已迁移消费者不得用 ResourceLoader.exists 探测编号 PNG；帧路径必须来自 Catalog",
                )
            )
    if NUMBERED_PNG_PATTERN.search(text) and EXISTS_CALL_PATTERN.search(text):
        findings.append(
            (
                rel,
                line_number(text, NUMBERED_PNG_PATTERN.search(text).start()),
                "已迁移消费者存在编号 PNG 路径拼接与存在性探测；禁止运行时猜帧名",
            )
        )
    return findings


def scan() -> list[tuple[str, int, str]]:
    allowed = load_allowlist()
    findings: list[tuple[str, int, str]] = []
    for path in sorted(SCRIPT_ROOT.rglob("*.gd")):
        rel = path.relative_to(PROJECT).as_posix()
        if rel == STREAM_CLASS_FILE:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if "StreamedPngEffect" not in text:
            continue
        if rel not in allowed:
            findings.append(
                (
                    rel,
                    line_number(text, text.find("StreamedPngEffect")),
                    "未登记运行时 PNG 流",
                )
            )
            continue
        findings.extend(scan_migrated_consumer(rel, text))
    unique: list[tuple[str, int, str]] = []
    seen: set[tuple[str, int, str]] = set()
    for finding in findings:
        if finding not in seen:
            seen.add(finding)
            unique.append(finding)
    return sorted(unique)


def main() -> int:
    parser = argparse.ArgumentParser(description="非 atlas PNG 流 allowlist 门禁")
    parser.add_argument("--fail-on-error", action="store_true")
    args = parser.parse_args()
    if not PROJECT.is_dir():
        print(f"[FAIL] 工程目录不存在: {PROJECT}", file=sys.stderr)
        return 2
    findings = scan()
    if not findings:
        print("[SUCCESS] PNG 流 allowlist 门禁通过：无未登记 StreamedPngEffect，已迁移消费者无旧数组/目录扫描")
        return 0
    for rel, line, message in findings:
        print(f"[ERROR] {message}: {rel}:{line}", file=sys.stderr)
    return 1 if args.fail_on_error else 0


if __name__ == "__main__":
    sys.exit(main())

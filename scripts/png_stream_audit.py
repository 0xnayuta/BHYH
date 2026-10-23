#!/usr/bin/env python3
"""非 atlas 运行时 PNG 流 allowlist 门禁。"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / "source"
SCRIPT_ROOT = PROJECT / "Script"
ALLOWLIST = ROOT / "scripts" / "png_stream_allowlist.json"


def load_allowlist() -> set[str]:
    data = json.loads(ALLOWLIST.read_text(encoding="utf-8"))
    return set((data.get("allowed_files") or {}).keys())


def scan() -> list[tuple[str, int]]:
    allowed = load_allowlist()
    findings: list[tuple[str, int]] = []
    for path in sorted(SCRIPT_ROOT.rglob("*.gd")):
        rel = path.relative_to(PROJECT).as_posix()
        if rel == "Script/monster/streamed_png_effect.gd":
            continue
        if rel in allowed:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if "StreamedPngEffect" in text:
            findings.append((rel, text[: text.find("StreamedPngEffect")].count("\n") + 1))
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description="非 atlas PNG 流 allowlist 门禁")
    parser.add_argument("--fail-on-error", action="store_true")
    args = parser.parse_args()
    if not PROJECT.is_dir():
        print(f"[FAIL] 工程目录不存在: {PROJECT}", file=sys.stderr)
        return 2
    findings = scan()
    if not findings:
        print("[SUCCESS] PNG 流 allowlist 门禁通过：无未登记 StreamedPngEffect")
        return 0
    for rel, line in findings:
        print(f"[ERROR] 未登记运行时 PNG 流: {rel}:{line}", file=sys.stderr)
    return 1 if args.fail_on_error else 0


if __name__ == "__main__":
    sys.exit(main())

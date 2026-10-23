#!/usr/bin/env python3
"""契约域总门禁：契约扫描 + AtlasMetadata 校验 + 非 atlas PNG 流 allowlist。"""
from __future__ import annotations

import concurrent.futures
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPORT_DIR = ROOT / "docs" / "reports"
COMMANDS = [
    ("contract_scan", [sys.executable, "scripts/contract_scan.py", "--fail-on-error"]),
    ("atlas_metadata_check", [sys.executable, "scripts/convert_atlas_metadata.py", "--check"]),
    ("atlas_metadata_self_test", [sys.executable, "scripts/convert_atlas_metadata.py", "--self-test"]),
    ("png_stream_audit", [sys.executable, "scripts/png_stream_audit.py", "--fail-on-error"]),
    ("whitelist_audit", [sys.executable, "scripts/whitelist_audit.py", "--fail-on-error"]),
]


def run_command(item: tuple[str, list[str]]) -> tuple[str, subprocess.CompletedProcess[str]]:
    name, command = item
    result = subprocess.run(
        command,
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="ignore",
    )
    return name, result


def main() -> int:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    # 子命令彼此只读或写入独立报告，可并发执行；按原顺序汇总输出与退出码。
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(COMMANDS)) as executor:
        results = list(executor.map(run_command, COMMANDS))

    for name, result in results:
        status = "PASS" if result.returncode == 0 else f"FAIL (exit={result.returncode})"
        print(f"[contract_gate] {name}: {status}")
        if result.stdout:
            print(result.stdout, end="")
        if result.stderr:
            print(result.stderr, end="", file=sys.stderr)

    for _name, result in results:
        if result.returncode != 0:
            return result.returncode
    return 0


if __name__ == "__main__":
    sys.exit(main())

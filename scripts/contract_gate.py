#!/usr/bin/env python3
"""契约域总门禁：契约扫描与边界自测 + AtlasMetadata/FrameSequence/关卡预载/编号帧/sheet 帧构建校验 + 非 atlas PNG 流 allowlist + UI Theme/字体覆盖/表面色基线。"""
from __future__ import annotations

import concurrent.futures
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPORT_DIR = ROOT / "docs" / "reports"
# 子命令的输出被按 UTF-8 解码；必须同时锁定子进程 stdout/stderr 为 UTF-8，
# 否则 PowerShell 的 GBK 控制台会让中文以 GBK 字节写入管道，解码后变成乱码。
CHILD_ENV = os.environ.copy()
CHILD_ENV["PYTHONIOENCODING"] = "utf-8"
CHILD_ENV["PYTHONUTF8"] = "1"
CHILD_ENV.pop("PYTHONLEGACYWINDOWSSTDIO", None)
COMMANDS = [
    ("contract_scan", [sys.executable, "scripts/contract_scan.py", "--fail-on-error"]),
    ("contract_self_test", [sys.executable, "scripts/contract_scan.py", "--self-test"]),
    ("atlas_metadata_check", [sys.executable, "scripts/convert_atlas_metadata.py", "--check"]),
    ("atlas_metadata_self_test", [sys.executable, "scripts/convert_atlas_metadata.py", "--self-test"]),
    ("frame_sequences_check", [sys.executable, "scripts/convert_frame_sequences.py", "--check"]),
    ("monster_frames_check", [sys.executable, "scripts/convert_monster_frames.py", "--check"]),
    ("numbered_frames_check", [sys.executable, "scripts/convert_numbered_frames.py", "--all", "--check"]),
    ("sheet_frames_check", [sys.executable, "scripts/convert_sheet_frames.py", "--check"]),
    ("liu_sha_frames_check", [sys.executable, "scripts/convert_liu_sha_frames.py", "--check"]),
    ("action_views_check", [sys.executable, "scripts/convert_monster_action_views.py", "--check"]),
    ("level_preload_catalog_check", [sys.executable, "scripts/convert_level_preload_catalog.py", "--check"]),
    ("level_layout_catalog_check", [sys.executable, "scripts/convert_level_layout_catalog.py", "--check"]),
    ("equipment_catalog_check", [sys.executable, "scripts/convert_equipment_catalog.py", "--check"]),
    ("equipment_data_audit", [sys.executable, "scripts/equipment_data_audit.py", "--check"]),
    ("level_layout_migration_audit", [sys.executable, "scripts/level_layout_migration_audit.py", "--fail-on-error"]),
    ("external_monster_catalog_check", [sys.executable, "scripts/convert_external_monster_catalog.py", "--check"]),
    ("runtime_frames_audit", [sys.executable, "scripts/runtime_frames_audit.py", "--fail-on-error"]),
    ("export_raw_manifest_check", [sys.executable, "scripts/export_raw_manifest.py", "--check", "--allow-missing"]),
    ("theme_override_audit", [sys.executable, "scripts/theme_override_audit.py", "--check"]),
    ("ui_theme_tokens_check", [sys.executable, "scripts/convert_ui_theme_tokens.py", "--check"]),
    ("theme_token_audit", [sys.executable, "scripts/theme_token_audit.py", "--check"]),
    ("theme_variant_audit", [sys.executable, "scripts/theme_variant_audit.py", "--check"]),
    ("ui_dynamic_theme_audit", [sys.executable, "scripts/ui_dynamic_theme_audit.py", "--check"]),
    ("font_coverage_audit", [sys.executable, "scripts/font_coverage_audit.py", "--check"]),
    ("font_role_audit", [sys.executable, "scripts/font_role_audit.py", "--check"]),
    ("ui_surface_token_audit", [sys.executable, "scripts/ui_surface_token_audit.py", "--check"]),
    ("ui_surface_token_self_test", [sys.executable, "scripts/ui_surface_token_audit.py", "--self-test"]),
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
        errors="replace",
        env=CHILD_ENV,
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

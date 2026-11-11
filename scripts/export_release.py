#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""发布前资源闭包包装：清单校验 + 实际 PCK 探针 + 可选 release 导出。

该脚本不把“配置声明”当作证据：
1. 校验原始数据清单与发布资源排除策略；
2. 用指定预设实际导出 PCK，验证原始数据、必需资源和排除资源；
3. 如提供 --output，再执行一次 release 导出并确认产物存在。

release 冷启动、目标设备 VRAM/首帧仍需单独实测，本脚本不伪造这些结论。
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from frame_sequence_pack_probe import check_export_result
from tool_common import ROOT, SOURCE, resolve_godot


def run(command: list[str]) -> int:
    print("[run] " + " ".join(command), flush=True)
    return subprocess.run(command, cwd=ROOT).returncode


def main() -> int:
    parser = argparse.ArgumentParser(description="发布前资源闭包包装")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径（或 GODOT_BIN）")
    parser.add_argument("--preset", default="Windows Desktop (release)", help="导出预设名称")
    parser.add_argument("--output", default=None, help="可选 release 可执行文件输出路径")
    parser.add_argument("--report", default=None, help="PCK 探针报告路径")
    parser.add_argument("--export-timeout", type=int, default=1800)
    args = parser.parse_args()

    godot = resolve_godot(args.godot)
    if godot is None:
        print("[BLOCKED] 未找到 Godot，发布包装不执行", file=sys.stderr)
        return 2

    check = run([sys.executable, "scripts/export_raw_manifest.py", "--check"])
    if check != 0:
        print("[FAIL] 原始数据清单预检失败", file=sys.stderr)
        return 1
    check = run([sys.executable, "scripts/export_asset_exclusions.py", "--check"])
    if check != 0:
        print("[FAIL] 发布资源排除预检失败", file=sys.stderr)
        return check

    probe_command = [
        sys.executable,
        "scripts/export_closure_probe.py",
        "--godot",
        godot,
        "--preset",
        args.preset,
        "--export-timeout",
        str(args.export_timeout),
    ]
    if args.report:
        probe_command.extend(["--report", args.report])
    probe = run(probe_command)
    if probe != 0:
        print("[FAIL] 原始数据 PCK 闭包验证失败", file=sys.stderr)
        return probe

    resource_probe = run(
        [
            sys.executable,
            "scripts/frame_sequence_pack_probe.py",
            "--godot",
            godot,
            "--preset",
            args.preset,
            "--check-exclusions",
            "--export-timeout",
            str(args.export_timeout),
        ]
    )
    if resource_probe != 0:
        print("[FAIL] 发布资源 PCK 闭包验证失败", file=sys.stderr)
        return resource_probe

    if args.output:
        output = Path(args.output)
        output.parent.mkdir(parents=True, exist_ok=True)
        command = [
            godot,
            "--headless",
            "--path",
            str(SOURCE),
            "--export-release",
            args.preset,
            str(output.resolve()),
        ]
        print("[run] " + " ".join(command), flush=True)
        try:
            result = subprocess.run(
                command, cwd=ROOT, capture_output=True, text=True, encoding="utf-8",
                errors="replace", timeout=max(args.export_timeout, 1),
            )
        except (OSError, subprocess.TimeoutExpired) as error:
            print(f"[BLOCKED] 无法完成 release 导出: {error}", file=sys.stderr)
            return 2
        output_text = (result.stdout or "") + "\n" + (result.stderr or "")
        print(output_text, end="" if output_text.endswith("\n") else "\n", flush=True)
        export_status, failure = check_export_result(output, result.returncode, output_text)
        if export_status:
            print(f"[{'FAIL' if export_status == 1 else 'BLOCKED'}] release 导出未通过: {failure}", file=sys.stderr)
            return export_status
        print(f"[OK] release 产物已生成: {output}")
    print("[OK] 发布前资源闭包包装通过；冷启动与设备性能仍需单独验收")
    return 0


if __name__ == "__main__":
    sys.exit(main())

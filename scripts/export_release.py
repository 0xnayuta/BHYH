#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""发布前原始数据闭包包装：清单校验 + 实际 PCK 探针 + 可选 release 导出。

该脚本不把“配置声明”当作证据：
1. 校验 export_raw_dependencies.json 与素材树、插件启用、预设一致；
2. 用指定预设实际导出 PCK，并逐条验证清单路径；
3. 如提供 --output，再执行一次 release 导出并确认产物存在。

release 冷启动、目标设备 VRAM/首帧仍需单独实测，本脚本不伪造这些结论。
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from tool_common import ROOT, SOURCE, resolve_godot


def run(command: list[str]) -> int:
    print("[run] " + " ".join(command), flush=True)
    return subprocess.run(command, cwd=ROOT).returncode


def main() -> int:
    parser = argparse.ArgumentParser(description="发布前原始数据导出闭包包装")
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

    if args.output:
        output = Path(args.output)
        output.parent.mkdir(parents=True, exist_ok=True)
        export = run(
            [
                godot,
                "--headless",
                "--path",
                str(SOURCE),
                "--export-release",
                args.preset,
                str(output.resolve()),
            ]
        )
        if export != 0 or not output.is_file():
            print("[FAIL] release 导出未产生可执行文件", file=sys.stderr)
            return 1
        print(f"[OK] release 产物已生成: {output}")
    print("[OK] 发布前原始数据闭包包装通过；冷启动与设备性能仍需单独验收")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""正式 Windows release EXE 的窗口冷启动 + WM_CLOSE 退出验收 runner。

目标
----
验证真实发行包在无测试注入、无 override 的情况下：

- 窗口冷启动成功，且进程只创建一个可见窗口；
- 发送 `WM_CLOSE` 后进程正常退出，退出码为 0；
- 退出日志没有 RID / ObjectDB / 资源泄漏，没有 `RenderingServer` 空单例错误，
  没有 SCRIPT ERROR / ERROR / WARNING。

该探针覆盖渲染服务器关闭顺序与光标纹理释放，headless 关卡探针不执行该路径。
不修改 EXE / PCK；复制到隔离运行目录并重定向 APPDATA / LOCALAPPDATA / TEMP。

仅 Windows 桌面会话可用；其他平台或无法创建可见窗口时返回 2（BLOCKED）。

退出码：0 通过；1 验证失败；2 夹具/环境阻塞（EXE/PCK/平台/窗口/准备失败）。
"""

from __future__ import annotations

import argparse
import ctypes
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from ctypes import wintypes
from pathlib import Path
from typing import Any

try:
    from tool_common import REPORT_DIR, SOURCE
except ImportError:  # 允许从任意 cwd 以绝对路径直接运行
    ROOT = Path(__file__).resolve().parents[1]
    REPORT_DIR = ROOT / "docs" / "reports"
    SOURCE = ROOT / "source"

from release_exe_level_runner import (
    _link_or_copy,
    _read_project_settings,
    _user_data_relative_dir,
    _validate_pck,
    _validate_release_binary,
)

REPORT_NAME = "release_exe_window_probe_report.json"
DEFAULT_BOOT_TIMEOUT_SECONDS = 60
DEFAULT_CLOSE_TIMEOUT_SECONDS = 120
POLL_INTERVAL_SECONDS = 0.25
WM_CLOSE = 0x0010

LEAK_PATTERNS = {
    "rid_allocations_leaked": re.compile(r"RID allocations of type .* were leaked at exit"),
    "rids_leaked": re.compile(r'RIDs of type ".*" were leaked'),
    "objectdb_leaked": re.compile(r"ObjectDB instances were leaked at exit"),
    "leaked_instance": re.compile(r"^Leaked instance:"),
    "resources_still_in_use": re.compile(r"resources still in use at exit"),
    "rendering_server_null": re.compile(r'Parameter "RenderingServer::get_singleton\(\)" is null'),
}
DIAGNOSTIC_LINE = re.compile(r"^(SCRIPT ERROR|ERROR|WARNING)")
# 驱动/加载器在窗口启动时输出的环境噪声，与游戏日志门禁无关；数量随驱动版本变化。
WINDOW_DRIVER_NOISE = re.compile(
    r"^WARNING: (?:GENERAL - Message Id Number:|Image format .* not supported by hardware)"
)


def _print(message: str) -> None:
    print(message, flush=True)


def _load_user32() -> Any:
    user32 = ctypes.WinDLL("user32", use_last_error=True)
    callback = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    user32.EnumWindows.argtypes = [callback, wintypes.LPARAM]
    user32.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
    user32.IsWindowVisible.argtypes = [wintypes.HWND]
    user32.IsWindow.argtypes = [wintypes.HWND]
    user32.PostMessageW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM]
    return user32, callback


def _visible_windows(user32: Any, callback: Any, pid: int) -> list[int]:
    windows: list[int] = []

    @callback
    def collect(hwnd: int, _: int) -> bool:
        window_pid = wintypes.DWORD()
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(window_pid))
        if window_pid.value == pid and user32.IsWindowVisible(hwnd):
            windows.append(hwnd)
        return True

    user32.EnumWindows(collect, 0)
    return windows


def _scan_log(text: str) -> dict[str, Any]:
    # game.log 与 stdout 都包含 engine 输出；按行去重后计数，避免同一诊断重复。
    lines = list(dict.fromkeys(text.splitlines()))
    text = "\n".join(lines)
    fatal: dict[str, int] = {}
    for name, pattern in LEAK_PATTERNS.items():
        fatal[name] = len(pattern.findall(text))
    diagnostics = [line.strip() for line in text.splitlines() if DIAGNOSTIC_LINE.match(line)]
    driver_noise = [line for line in diagnostics if WINDOW_DRIVER_NOISE.match(line)]
    engine_diagnostics = [line for line in diagnostics if not WINDOW_DRIVER_NOISE.match(line)]
    leaked_instances = [
        line.strip() for line in text.splitlines() if line.startswith("Leaked instance:")
    ]
    return {
        "fatal": fatal,
        "leaked_instances": leaked_instances[:20],
        "diagnostics": engine_diagnostics[:20],
        "driver_noise": len(driver_noise),
        "engine_errors": sum(
            1 for line in engine_diagnostics if line.startswith(("SCRIPT ERROR", "ERROR"))
        ),
        "engine_warnings": sum(1 for line in engine_diagnostics if line.startswith("WARNING")),
    }


def _failures_from_log(log_facts: dict[str, Any]) -> list[str]:
    failures = [
        f"{name}={count}" for name, count in log_facts["fatal"].items() if count
    ]
    if log_facts["engine_errors"]:
        failures.append(f"engine_errors={log_facts['engine_errors']}")
    if log_facts["engine_warnings"]:
        failures.append(f"engine_warnings={log_facts['engine_warnings']}")
    return failures


def _write_report(report: dict[str, Any]) -> Path:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    path = REPORT_DIR / REPORT_NAME
    path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return path


def main() -> int:
    parser = argparse.ArgumentParser(description="正式 Windows release EXE 的窗口冷启动 + WM_CLOSE 退出验收")
    parser.add_argument("--exe", required=True, help="release EXE 路径")
    parser.add_argument("--pck", default=None, help="同目录发行 PCK 路径；默认 <exe>.pck")
    parser.add_argument("--project", default=str(SOURCE), help="用于解析 user:// 目录名的工程目录")
    parser.add_argument("--work-dir", default=None, help="运行产物根目录；默认系统临时目录")
    parser.add_argument(
        "--boot-timeout", type=int, default=DEFAULT_BOOT_TIMEOUT_SECONDS, help="等待窗口出现的秒数"
    )
    parser.add_argument(
        "--timeout", type=int, default=DEFAULT_CLOSE_TIMEOUT_SECONDS, help="发送 WM_CLOSE 后的退出超时秒数"
    )
    args = parser.parse_args()

    if sys.platform != "win32":
        _print("[BLOCKED] 窗口退出探针仅支持 Windows 桌面会话")
        return 2

    exe = Path(args.exe).resolve()
    pck = Path(args.pck).resolve() if args.pck else exe.with_suffix(".pck")
    if not exe.is_file():
        _print(f"[BLOCKED] EXE 不存在: {exe}")
        return 2

    build_ok, build_facts = _validate_release_binary(exe)
    if not build_ok:
        _print(f"[BLOCKED] {build_facts.get('error')}")
        _print(json.dumps(build_facts, ensure_ascii=False, indent=2))
        return 2
    pck_ok, pck_facts = _validate_pck(pck)
    if not pck_ok:
        _print(f"[BLOCKED] {pck_facts.get('error')}")
        return 2

    project = _read_project_settings(Path(args.project))
    base_dir = Path(args.work_dir).resolve() if args.work_dir else Path(tempfile.gettempdir())
    base_dir.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("run-%Y%m%d-%H%M%S") + f"-{os.getpid()}"
    run_dir = base_dir
    if run_dir.exists() and any(run_dir.iterdir()):
        run_dir = base_dir / stamp
    run_dir.mkdir(parents=True, exist_ok=True)
    game_dir = run_dir / "game"
    appdata_dir = run_dir / "appdata"
    localappdata_dir = run_dir / "localappdata"
    temp_dir = run_dir / "temp"
    for directory in (game_dir, appdata_dir, localappdata_dir, temp_dir):
        directory.mkdir(parents=True, exist_ok=True)

    link_methods: dict[str, str] = {}
    link_methods[exe.name] = _link_or_copy(exe, game_dir / exe.name)
    pck_target = game_dir / (exe.stem + ".pck")
    link_methods[pck_target.name] = _link_or_copy(pck, pck_target)
    for sibling in sorted(exe.parent.glob("*.dll")):
        link_methods[sibling.name] = _link_or_copy(sibling, game_dir / sibling.name)

    user_rel = _user_data_relative_dir(
        project["name"], project["use_custom_user_dir"], project["custom_user_dir_name"]
    )
    (appdata_dir / user_rel).mkdir(parents=True, exist_ok=True)

    game_log = run_dir / "game.log"
    stdout_log = run_dir / "stdout.log"
    command = [
        str(game_dir / exe.name),
        "--verbose",
        "--log-file",
        str(game_log),
    ]
    env = dict(os.environ)
    env["APPDATA"] = str(appdata_dir)
    env["LOCALAPPDATA"] = str(localappdata_dir)
    env["TEMP"] = str(temp_dir)
    env["TMP"] = str(temp_dir)

    facts: dict[str, Any] = {
        "exe": str(exe),
        "pck": str(pck),
        "pck_size": pck_facts.get("size", 0),
        "run_dir": str(run_dir),
        "command": command,
        "link_methods": link_methods,
        "project": project,
    }
    failures: list[str] = []

    user32, callback = _load_user32()
    _print(f"[run] {' '.join(command)}")
    started = time.time()
    windows: list[int] = []
    returncode: int | None = None
    timed_out = False
    boot_seconds: float | None = None
    with stdout_log.open("wb") as output:
        process = subprocess.Popen(
            command,
            cwd=str(game_dir),
            env=env,
            stdin=subprocess.DEVNULL,
            stdout=output,
            stderr=subprocess.STDOUT,
        )
        boot_deadline = started + args.boot_timeout
        while time.time() < boot_deadline:
            if process.poll() is not None:
                break
            windows = _visible_windows(user32, callback, process.pid)
            if windows:
                boot_seconds = round(time.time() - started, 2)
                break
            time.sleep(POLL_INTERVAL_SECONDS)

        if returncode is None and not windows:
            if process.poll() is not None:
                returncode = process.returncode
                failures.append(f"process_exited_before_window={returncode}")
            else:
                process.kill()
                returncode = process.wait()
                failures.append(f"window_not_found_after={args.boot_timeout}s")
        elif len(windows) > 1:
            failures.append(f"window_count={len(windows)}")
            process.kill()
            returncode = process.wait()
        elif windows:
            if not user32.IsWindow(windows[0]):
                failures.append("window_handle_invalid")
                process.kill()
                returncode = process.wait()
            elif not user32.PostMessageW(windows[0], WM_CLOSE, 0, 0):
                failures.append(f"wm_close_post_failed={ctypes.get_last_error()}")
                process.kill()
                returncode = process.wait()
            else:
                try:
                    returncode = process.wait(timeout=args.timeout)
                except subprocess.TimeoutExpired:
                    timed_out = True
                    process.kill()
                    try:
                        returncode = process.wait(timeout=30)
                    except subprocess.TimeoutExpired:
                        returncode = -1
                    failures.append(f"process_timeout={args.timeout}s")

    elapsed = round(time.time() - started, 2)
    log_text = ""
    for path in (game_log, stdout_log):
        if path.is_file():
            log_text += path.read_text(encoding="utf-8", errors="replace") + "\n"
    log_facts = _scan_log(log_text)
    failures.extend(_failures_from_log(log_facts))
    if returncode is None:
        failures.append("process_exit_unknown")
    elif returncode != 0:
        failures.append(f"process_exit={returncode}")

    report = {
        "ok": not failures,
        "failures": failures,
        "elapsed_seconds": elapsed,
        "boot_seconds": boot_seconds,
        "process_exit": returncode,
        "timed_out": timed_out,
        "window_count": len(windows),
        "facts": facts,
        "log": log_facts,
    }
    report_path = _write_report(report)

    _print("=" * 72)
    _print(" 正式 release EXE 窗口冷启动 + WM_CLOSE 退出验收")
    _print("=" * 72)
    _print(f"  EXE: {exe}")
    _print(f"  PCK: {pck} ({pck_facts.get('size', 0)} bytes)")
    _print(f"  运行目录: {run_dir}")
    _print(f"  窗口数: {len(windows)}  首窗耗时: {boot_seconds}s")
    _print(f"  进程退出码: {returncode}  耗时: {elapsed}s")
    _print(f"  泄漏实例: {len(log_facts['leaked_instances'])}")
    _print(f"  ERROR/WARNING: {log_facts['engine_errors']}/{log_facts['engine_warnings']}")
    _print(f"  驱动噪声: {log_facts['driver_noise']}")
    for line in log_facts["diagnostics"]:
        _print(f"  log: {line}")
    if failures:
        _print(f"[FAIL] {'; '.join(failures)}")
    else:
        _print("[OK] 窗口冷启动与 WM_CLOSE 退出通过：0 泄漏、0 ERROR、0 WARNING")
    _print(f"  报告: {report_path}")
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())

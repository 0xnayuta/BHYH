#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""正式 Windows release EXE 的 level_1 四阶段验证 runner。

目标
----
用**官方 release 导出模板**产出的 EXE 与发行 PCK 运行真实 level_1 契约，
同时满足：

- 不修改 EXE / PCK，不替换发行资源；
- 不用 editor Godot 加载 PCK 冒充正式 EXE；
- 不用 debug template、不传 --path / --scene / --main-pack / --script /
  --remote-debug（官方 release 模板均不可用或直接中止）；
- 通过 EXE 同目录的 override.cfg 追加一个独立 autoload，探针脚本放在隔离的
  user:// 目录；探针路径唯一，不遮蔽任何 res:// 生产资源；
- 全程重定向 APPDATA / LOCALAPPDATA / TEMP，player 存档与日志不落到真实用户目录；
- 报告、日志与运行目录只写入 --work-dir（或系统临时目录）。

退出码：0 通过；1 验证失败；2 夹具/环境阻塞（EXE/PCK/探针缺失、准备失败）。
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

try:
    from tool_common import ROOT, SOURCE
except ImportError:  # 允许从任意 cwd 以绝对路径直接运行
    ROOT = Path(__file__).resolve().parents[1]
    SOURCE = ROOT / "source"

PROBE_NAME = "release_exe_level_probe"
PROBE_AUTOLOAD = "ReleaseExeLevelProbe"
PROBE_USER_PATH = f"user://{PROBE_NAME}.gd"
REPORT_NAME = f"{PROBE_NAME}_report.json"
TARGET_LEVEL = "res://Scene/level/level_1.tscn"
EXPECTED_STAGE_COUNT = 4
DEFAULT_TIMEOUT_SECONDS = 300
SAFETY_QUIT_FRAMES = 600_000
HEADLESS_RENDER_NOISE = re.compile(
    r'^ERROR: (?:Parameter "(?:t|mem)" is null|Initializing already initialized RID)\.?\n'
    r"(?:[ \t].*\n)*",
    re.M,
)
PATH_OVERRIDE_ABORT = "compiled without support for path overrides"
REMOTE_DEBUG_ABORT = "`--remote-debug` was specified on the command line, but this Godot binary was compiled without debug"
RELEASE_HELP_MARKER = "this build = release export template"
DEBUG_HELP_MARKER = "this build = debug export template"
PCK_MAGIC = b"GDPC"


def _print(message: str) -> None:
    print(message, flush=True)


def _run_capture(command: list[str], timeout: int = 60) -> tuple[int, str]:
    try:
        proc = subprocess.run(
            command,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        return -1, str(exc)
    return proc.returncode, (proc.stdout or b"").decode("utf-8", "replace")


def _read_project_settings(project_dir: Path) -> dict[str, Any]:
    """读取 user:// 布局、主场景与 autoload 名单（用于校验注入是纯追加）。"""
    settings: dict[str, Any] = {
        "name": "造梦西游八荒湮隳",
        "use_custom_user_dir": False,
        "custom_user_dir_name": "",
        "main_scene": "",
        "autoloads": [],
    }
    project_file = project_dir / "project.godot"
    if not project_file.is_file():
        return settings
    section = ""
    for raw_line in project_file.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw_line.strip()
        if not line or line.startswith(";"):
            continue
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
            value = value[1:-1]
        if section == "application":
            if key == "config/name":
                settings["name"] = value
            elif key == "config/use_custom_user_dir":
                settings["use_custom_user_dir"] = value.lower() == "true"
            elif key == "config/custom_user_dir_name":
                settings["custom_user_dir_name"] = value
            elif key == "run/main_scene":
                settings["main_scene"] = value
        elif section == "autoload":
            settings["autoloads"].append(key)
    return settings


def _validate_override_cfg(path: Path, project: dict[str, Any]) -> tuple[bool, dict[str, Any]]:
    """确认 override.cfg 只追加一个与生产 autoload 不冲突的探针键。"""
    facts: dict[str, Any] = {"path": str(path)}
    sections: list[str] = []
    keys: list[str] = []
    values: dict[str, str] = {}
    section = ""
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith(";"):
            continue
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            sections.append(section)
            continue
        if "=" in line:
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip()
            if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
                value = value[1:-1]
            keys.append(key)
            values[key] = value
    facts["sections"] = sections
    facts["keys"] = keys
    facts["values"] = values
    errors: list[str] = []
    if sections != ["autoload"]:
        errors.append("override_sections_not_only_autoload")
    if keys != [PROBE_AUTOLOAD]:
        errors.append("override_keys_not_only_probe")
    if values.get(PROBE_AUTOLOAD) != f"*{PROBE_USER_PATH}":
        errors.append("override_probe_path_mismatch")
    if PROBE_AUTOLOAD in project["autoloads"]:
        errors.append("override_probe_name_collides_with_production_autoload")
    facts["errors"] = errors
    return not errors, facts


def _user_data_relative_dir(name: str, use_custom: bool, custom_name: str) -> Path:
    # 与 Godot 4 OS::get_user_data_dir() 的默认布局保持一致。
    safe_name = custom_name if use_custom and custom_name else name
    if use_custom:
        return Path(safe_name)
    return Path("Godot") / "app_userdata" / safe_name


def _link_or_copy(source: Path, target: Path) -> str:
    target.parent.mkdir(parents=True, exist_ok=True)
    try:
        if target.exists() and target.samefile(source):
            return "in-place"
    except OSError:
        pass
    if target.exists():
        target.unlink()
    try:
        os.link(source, target)
        return "hardlink"
    except OSError:
        shutil.copy2(source, target)
        return "copy"


def _validate_release_binary(exe: Path) -> tuple[bool, dict[str, Any]]:
    facts: dict[str, Any] = {"exe": str(exe)}
    code, version_text = _run_capture([str(exe), "--version"])
    facts["version_exit"] = code
    facts["version"] = version_text.strip()
    if code != 0 or not re.search(r"4\.7\.\d+\.stable", version_text):
        facts["error"] = "无法读取 Godot 4.7 stable 版本号"
        return False, facts
    code, help_text = _run_capture([str(exe), "--help"])
    facts["help_exit"] = code
    if code != 0:
        facts["error"] = "读取 --help 失败"
        return False, facts
    if RELEASE_HELP_MARKER not in help_text:
        facts["error"] = "EXE 不是官方 release export template"
        return False, facts
    if DEBUG_HELP_MARKER in help_text:
        facts["error"] = "EXE 是 debug export template"
        return False, facts
    # 官方 release 模板不提供这些注入入口；按“选项行”判断，避免命中说明文字
    # （例如 --headless 的说明里提到 --script）。
    forbidden = ("--path", "--scene", "--main-pack", "--script", "--remote-debug")
    facts["forbidden_options_absent"] = {
        flag: re.search(r"^\s+" + re.escape(flag) + r"(?:\s|,|$)", help_text, re.M) is None
        for flag in forbidden
    }
    if not all(facts["forbidden_options_absent"].values()):
        facts["error"] = "release 模板帮助中出现了不应可用的注入选项"
        return False, facts
    return True, facts


def _validate_pck(pck: Path) -> tuple[bool, dict[str, Any]]:
    facts: dict[str, Any] = {"pck": str(pck)}
    if not pck.is_file():
        facts["error"] = "PCK 不存在"
        return False, facts
    size = pck.stat().st_size
    facts["size"] = size
    if size <= 0:
        facts["error"] = "PCK 为空"
        return False, facts
    with pck.open("rb") as handle:
        magic = handle.read(4)
    facts["magic"] = magic.decode("latin-1")
    if magic != PCK_MAGIC:
        facts["error"] = "PCK 魔数不是 GDPC"
        return False, facts
    return True, facts


def _write_override_cfg(game_dir: Path) -> Path:
    override = game_dir / "override.cfg"
    override.write_text(
        "[autoload]\n\n"
        f"{PROBE_AUTOLOAD}=\"*{PROBE_USER_PATH}\"\n",
        encoding="utf-8",
        newline="\n",
    )
    return override


def _scan_log(log_text: str) -> dict[str, Any]:
    noise = HEADLESS_RENDER_NOISE.findall(log_text)
    filtered = HEADLESS_RENDER_NOISE.sub("", log_text)
    script_errors = re.findall(r"SCRIPT ERROR", filtered)
    errors = re.findall(r"^ERROR", filtered, re.M)
    warnings = re.findall(r"^WARNING", filtered, re.M)
    samples = [
        line
        for line in filtered.splitlines()
        if re.match(r"^(SCRIPT ERROR|ERROR|WARNING)", line)
    ][:20]
    return {
        "script_errors": len(script_errors),
        "errors": len(errors),
        "warnings": len(warnings),
        "headless_render_noise": len(noise),
        "samples": samples,
    }


def _validate_probe_report(
    report: dict[str, Any], returncode: int | None, project: dict[str, Any]
) -> list[str]:
    failures: list[str] = []
    probe = report.get("probe") or {}
    if report.get("ok") is not True:
        failures.append("probe_report_not_ok")
    if report.get("errors"):
        failures.append("probe_errors:" + ";".join(str(item) for item in report["errors"][:6]))
    if report.get("target_level") != TARGET_LEVEL:
        failures.append("target_level_mismatch")
    if report.get("scene_file_path") != TARGET_LEVEL:
        failures.append("scene_path_mismatch")
    if int(report.get("stage_count", 0)) != EXPECTED_STAGE_COUNT:
        failures.append(f"stage_count={report.get('stage_count')}")
    stages = report.get("stages") or []
    if len(stages) != EXPECTED_STAGE_COUNT:
        failures.append(f"stage_results={len(stages)}")
    if [stage.get("target_stage") for stage in stages] != list(range(1, EXPECTED_STAGE_COUNT + 1)):
        failures.append("stage_sequence_mismatch")
    for stage in stages:
        target = int(stage.get("target_stage", -1))
        actual = int(stage.get("actual_stage", -1))
        if stage.get("ok") is not True or actual < target:
            failures.append(f"stage_{target}_not_reached(actual={actual})")
        if stage.get("can_pass") is not True:
            failures.append(f"stage_{target}_can_pass_missing_or_false")
    if probe.get("is_debug_build") is not False:
        failures.append("in_process_debug_build")
    if probe.get("has_release_feature") is not True:
        failures.append("in_process_release_feature_missing")
    if probe.get("debugger_active") is not False:
        failures.append("in_process_debugger_active")
    if probe.get("script_path") != PROBE_USER_PATH:
        failures.append(f"probe_script_path={probe.get('script_path')}")
    if probe.get("script_in_pck") is not False:
        failures.append("probe_script_found_inside_res")
    boot = report.get("boot") or {}
    expected_main = str(project.get("main_scene", ""))
    if boot.get("startup_scene_present") is not True:
        failures.append("startup_scene_missing")
    if not expected_main or boot.get("startup_scene_path") != expected_main:
        failures.append(
            f"startup_scene_mismatch(actual={boot.get('startup_scene_path')},expected={expected_main})"
        )
    if boot.get("main_scene_booted") is not True:
        failures.append("main_scene_not_booted")
    production_autoloads = report.get("production_autoloads") or {}
    for autoload_name in project.get("autoloads", []):
        if production_autoloads.get(autoload_name) is not True:
            failures.append(f"production_autoload_missing:{autoload_name}")
    if report.get("probe_autoload_name") in project.get("autoloads", []):
        failures.append("probe_autoload_name_collides")
    report_exit = report.get("exit_code")
    if returncode is None or report_exit != returncode:
        failures.append(f"exit_code_mismatch(process={returncode},report={report_exit})")
    if returncode != 0:
        failures.append(f"process_exit={returncode}")
    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description="正式 Windows release EXE 的 level_1 四阶段验证")
    parser.add_argument("--exe", required=True, help="release EXE 路径")
    parser.add_argument("--pck", default=None, help="同目录发行 PCK 路径；默认 <exe>.pck")
    parser.add_argument("--project", default=str(SOURCE), help="用于解析 user:// 目录名的工程目录")
    parser.add_argument("--work-dir", default=None, help="运行产物根目录；默认系统临时目录")
    parser.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT_SECONDS, help="EXE 墙钟超时秒数")
    args = parser.parse_args()

    exe = Path(args.exe).resolve()
    pck = Path(args.pck).resolve() if args.pck else exe.with_suffix(".pck")
    probe_source = Path(__file__).with_name(f"{PROBE_NAME}.gd")
    failures: list[str] = []
    facts: dict[str, Any] = {}

    if not exe.is_file():
        _print(f"[BLOCKED] EXE 不存在: {exe}")
        return 2
    if not probe_source.is_file():
        _print(f"[BLOCKED] 探针脚本缺失: {probe_source}")
        return 2

    build_ok, build_facts = _validate_release_binary(exe)
    facts["build"] = build_facts
    if not build_ok:
        _print(f"[BLOCKED] {build_facts.get('error')}")
        _print(json.dumps(build_facts, ensure_ascii=False, indent=2))
        return 2
    pck_ok, pck_facts = _validate_pck(pck)
    facts["pck"] = pck_facts
    if not pck_ok:
        _print(f"[BLOCKED] {pck_facts.get('error')}")
        return 2

    project = _read_project_settings(Path(args.project))
    facts["project"] = project

    base_dir = Path(args.work_dir).resolve() if args.work_dir else Path(tempfile.gettempdir())
    base_dir.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("run-%Y%m%d-%H%M%S") + f"-{os.getpid()}"
    run_dir = base_dir / stamp if not args.work_dir else base_dir
    if args.work_dir and run_dir.exists() and any(run_dir.iterdir()):
        # 不覆盖既有证据；每次运行使用独立目录。
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
    # Godot 只按 <exe basename>.pck 查找同目录发行包；链接时使用规范名。
    pck_target = game_dir / (exe.stem + ".pck")
    link_methods[pck_target.name] = _link_or_copy(pck, pck_target)
    # GDExtension 的 release DLL 与 EXE 同目录；必须随包带入运行目录。
    for sibling in sorted(exe.parent.glob("*.dll")):
        link_methods[sibling.name] = _link_or_copy(sibling, game_dir / sibling.name)

    user_rel = _user_data_relative_dir(
        project["name"], project["use_custom_user_dir"], project["custom_user_dir_name"]
    )
    user_root = appdata_dir / user_rel
    user_root.mkdir(parents=True, exist_ok=True)
    probe_target = user_root / f"{PROBE_NAME}.gd"
    shutil.copy2(probe_source, probe_target)
    override_path = _write_override_cfg(game_dir)

    game_log = run_dir / "game.log"
    stdout_log = run_dir / "stdout.log"
    command = [
        str(game_dir / exe.name),
        "--headless",
        "--log-file",
        str(game_log),
        "--quit-after",
        str(SAFETY_QUIT_FRAMES),
    ]
    env = dict(os.environ)
    env["APPDATA"] = str(appdata_dir)
    env["LOCALAPPDATA"] = str(localappdata_dir)
    env["TEMP"] = str(temp_dir)
    env["TMP"] = str(temp_dir)

    facts.update(
        {
            "run_dir": str(run_dir),
            "game_dir": str(game_dir),
            "command": command,
            "link_methods": link_methods,
            "override_cfg": override_path.read_text(encoding="utf-8"),
            "probe_target": str(probe_target),
            "user_root": str(user_root),
        }
    )

    override_ok, override_facts = _validate_override_cfg(override_path, project)
    facts["override_cfg_check"] = override_facts
    if not override_ok:
        failures.append("override_cfg_not_additive:" + ",".join(override_facts.get("errors", [])))

    _print(f"[run] {' '.join(command)}")
    started = time.time()
    returncode: int | None = None
    timed_out = False
    with stdout_log.open("wb") as output:
        process = subprocess.Popen(
            command,
            cwd=str(game_dir),
            env=env,
            stdin=subprocess.DEVNULL,
            stdout=output,
            stderr=subprocess.STDOUT,
        )
        try:
            returncode = process.wait(timeout=args.timeout)
        except subprocess.TimeoutExpired:
            timed_out = True
            process.kill()
            try:
                returncode = process.wait(timeout=30)
            except subprocess.TimeoutExpired:
                returncode = -1
    elapsed = round(time.time() - started, 2)

    report_path = user_root / REPORT_NAME
    report: dict[str, Any] = {}
    if report_path.is_file():
        try:
            loaded = json.loads(report_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            failures.append(f"report_unreadable:{exc}")
        else:
            if isinstance(loaded, dict):
                report = loaded
            else:
                failures.append("report_not_object")
    else:
        failures.append("report_not_written")

    log_text = ""
    for path in (game_log, stdout_log):
        if path.is_file():
            log_text += path.read_text(encoding="utf-8", errors="replace") + "\n"
    if PATH_OVERRIDE_ABORT in log_text:
        failures.append("path_override_abort")
    if REMOTE_DEBUG_ABORT in log_text:
        failures.append("remote_debug_abort")
    log_facts = _scan_log(log_text)
    if log_facts["script_errors"]:
        failures.append(f"script_errors={log_facts['script_errors']}")
    if log_facts["errors"]:
        failures.append(f"engine_errors={log_facts['errors']}")
    if log_facts["warnings"]:
        failures.append(f"engine_warnings={log_facts['warnings']}")
    if timed_out:
        failures.append(f"process_timeout={args.timeout}s")
    failures.extend(_validate_probe_report(report, returncode, project))

    report_probe = report.get("probe") or {}
    if report_probe:
        user_dir = str(report_probe.get("user_dir", ""))
        if not user_dir or Path(user_dir).resolve() != user_root.resolve():
            failures.append(f"user_dir_not_isolated:{user_dir}")

    runner_report = {
        "ok": not failures,
        "failures": failures,
        "elapsed_seconds": elapsed,
        "process_exit": returncode,
        "timed_out": timed_out,
        "facts": facts,
        "log": log_facts,
        "probe_report_path": str(report_path),
        "probe_report": report,
    }
    runner_report_path = run_dir / "runner_report.json"
    runner_report_path.write_text(
        json.dumps(runner_report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    _print("=" * 72)
    _print(" 正式 release EXE level_1 四阶段验证")
    _print("=" * 72)
    _print(f"  EXE: {exe}")
    _print(f"  PCK: {pck} ({pck_facts.get('size', 0)} bytes)")
    _print(f"  运行目录: {run_dir}")
    _print(f"  进程退出码: {returncode}  耗时: {elapsed}s")
    for stage in report.get("stages", []):
        flag = "PASS" if stage.get("ok") else "FAIL"
        _print(
            f"  [{flag}] Stage {stage.get('target_stage')} @ x={stage.get('x')} -> "
            f"actual={stage.get('actual_stage')} alive={stage.get('alive')} "
            f"can_pass={stage.get('can_pass')}"
        )
    _print(
        "  日志门禁: SCRIPT ERROR={script_errors} ERROR={errors} WARNING={warnings} "
        "dummy_noise={headless_render_noise}".format(**log_facts)
    )
    if failures:
        _print("[FAIL] " + "; ".join(failures))
        for sample in log_facts["samples"]:
            _print("  log: " + sample)
        _print(f"  报告: {runner_report_path}")
        return 1
    _print("[OK] 正式 release EXE level_1 四阶段契约通过，0 ERROR / 0 WARNING")
    _print(f"  报告: {runner_report_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

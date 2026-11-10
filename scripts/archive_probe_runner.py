#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""运行档案持久化定向探针。

探针位于 scripts/archive_probes/；运行时复制到 Godot 工程根目录，以
`--scene` 启动完整项目生命周期，并使用独立的临时 user:// 目录，避免触碰
本机真实存档与 MainGame.json。除档案读写外，同时验证胜败结算的保存一次、
返回/重战去重、奖励持久化、商店/神秘商店/强化/技能/幻化/奖励命令、保存失败回滚与 BGM/音效池边界。结束后清理临时 fixture 与用户目录。
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
import uuid
from pathlib import Path

from tool_common import REPORT_DIR, ROOT, SOURCE, resolve_godot, write_json

PROJECT = SOURCE
FIXTURE_DIR = ROOT / "scripts" / "archive_probes"
RESULT_PREFIX = "ARCHIVE_PERSISTENCE_PROBE_RESULT="
USER_DIR_PREFIX = "USER_DIR="
# 探针会主动触发校验拒绝；这些日志属于预期，不计入门禁。
EXPECTED_ERROR_MARKERS = (
    "拒绝读取无效的玩家存档数据",
    "拒绝保存无效的玩家存档数据",
    "拒绝保存不完整的玩家存档数据",
    "存档保存失败（probe_invalid）",
    "存档保存失败（probe_empty_profile）",
    "存档保存失败（probe_normalize_fail）",
    "存档保存失败（probe_sync_write_fail）",
    "拒绝保存过期档案身份",
    "保存前补全后置条件不满足",
    "magic != 0x43454447",
    "change_scene rejected level target without archive session",
    "后台存档写入失败，已保留快照",
)


def write_fixture(gd_path: Path, scene_path: Path) -> None:
    shutil.copy2(FIXTURE_DIR / "archive_persistence_probe.gd", gd_path)
    scene_text = (FIXTURE_DIR / "archive_persistence_probe.tscn").read_text(encoding="utf-8")
    scene_text = scene_text.replace("__PROBE_SCRIPT__", f"res://{gd_path.name}")
    scene_path.write_text(scene_text, encoding="utf-8", newline="\n")


def cleanup_temp(paths: list[Path], user_dir: Path | None) -> None:
    cleanup_error: OSError | None = None
    try:
        for path in paths:
            for temp_path in (path, path.with_name(path.name + ".uid")):
                try:
                    temp_path.unlink(missing_ok=True)
                except OSError as error:
                    if cleanup_error is None:
                        cleanup_error = error
    finally:
        if user_dir is not None:
            shutil.rmtree(user_dir, ignore_errors=True)
    if cleanup_error is not None:
        raise cleanup_error


def redact_user_dir(value: object, user_dir: Path) -> object:
    resolved_user_dir = user_dir.resolve()
    paths = (str(user_dir), user_dir.as_posix(), str(resolved_user_dir), resolved_user_dir.as_posix())
    flags = re.IGNORECASE if os.name == "nt" else 0

    def redact(text: str) -> str:
        for path in paths:
            text = re.sub(re.escape(path), "<temporary user dir>", text, flags=flags)
        return text

    if isinstance(value, str):
        return redact(value)
    if isinstance(value, list):
        return [redact_user_dir(item, user_dir) for item in value]
    if isinstance(value, dict):
        return {
            redact(key) if isinstance(key, str) else key: redact_user_dir(item, user_dir)
            for key, item in value.items()
        }
    return value


def parse_result(output: str) -> dict:
    for line in reversed(output.splitlines()):
        if not line.startswith(RESULT_PREFIX):
            continue
        try:
            payload = json.loads(line[len(RESULT_PREFIX) :])
        except json.JSONDecodeError:
            return {"ok": False, "failures": ["探针结果 JSON 无效"], "checks": {}}
        if not isinstance(payload, dict):
            return {"ok": False, "failures": ["探针结果不是 JSON 对象"], "checks": {}}
        payload.setdefault("failures", [])
        payload.setdefault("checks", {})
        return payload
    return {"ok": False, "failures": [f"缺少 {RESULT_PREFIX} 输出"], "checks": {}}


def collect_isolated_user_dir(output: str) -> str:
    for line in output.splitlines():
        if line.startswith(USER_DIR_PREFIX):
            return line[len(USER_DIR_PREFIX) :].strip()
    return ""


def collect_runtime_errors(output: str) -> list[str]:
    findings = []
    for line in output.splitlines():
        if not line.startswith(("SCRIPT ERROR:", "ERROR:", "WARNING:")):
            continue
        if any(marker in line for marker in EXPECTED_ERROR_MARKERS):
            continue
        # 引擎退出阶段的 RID/ObjectDB 回收噪声：探针已释放全部自有节点，
        # 剩余对象来自 Autoload 与引擎缓存，与保存行为无关。
        if "resources still in use at exit" in line or "ObjectDB instances were leaked at exit" in line:
            continue
        findings.append(line)
    return findings


def run(godot: str, timeout: int) -> int:
    instance_id = uuid.uuid4().hex[:10]
    fixture_paths = [
        PROJECT / f"_archive_persistence_probe_{instance_id}.gd",
        PROJECT / f"_archive_persistence_probe_{instance_id}.tscn",
    ]
    user_dir = Path(tempfile.mkdtemp(prefix="bhyh_archive_probe_"))
    try:
        write_fixture(fixture_paths[0], fixture_paths[1])
        env = os.environ.copy()
        env["APPDATA"] = str(user_dir)
        env["XDG_DATA_HOME"] = str(user_dir)
        command = [
            godot,
            "--headless",
            "--path",
            str(PROJECT),
            "--scene",
            f"res://{fixture_paths[1].name}",
        ]
        try:
            completed = subprocess.run(
                command,
                cwd=str(ROOT),
                env=env,
                capture_output=True,
                text=True,
                timeout=timeout,
            )
        except subprocess.TimeoutExpired:
            print(f"FAIL: 探针超时（{timeout}s）")
            return 1

        output = (completed.stdout or "") + (completed.stderr or "")
        result = parse_result(output)
        isolated_dir = collect_isolated_user_dir(output)
        isolation_ok = bool(isolated_dir) and Path(isolated_dir).resolve().is_relative_to(user_dir.resolve())
        runtime_errors = collect_runtime_errors(output)

        failures = list(result.get("failures", []))
        if not isolation_ok:
            failures.append("user:// 未隔离到临时目录")
        if runtime_errors:
            failures.append("运行期出现非预期 ERROR/WARNING：" + " | ".join(runtime_errors[:5]))

        checks = result.get("checks", {})
        print(f"user:// = {isolated_dir or '<missing>'}")
        print(f"隔离目录 = {user_dir}")
        for name in sorted(checks):
            item = checks[name]
            print(f"  [{'PASS' if item.get('ok') else 'FAIL'}] {name} {item.get('detail', '')}")
        print(f"检查项 {len(checks)}，失败 {len(failures)}")

        report = {
            "ok": not failures,
            "checks": redact_user_dir(checks, user_dir),
            "failures": redact_user_dir(failures, user_dir),
            "isolation_ok": isolation_ok,
            "runtime_errors": redact_user_dir(runtime_errors, user_dir),
            "returncode": completed.returncode,
        }
        write_json(REPORT_DIR / "archive_persistence_probe_report.json", report)
        if failures:
            for failure in failures:
                print(" - " + failure)
            return 1
        print("ARCHIVE PERSISTENCE PROBE: PASS")
        return 0
    finally:
        cleanup_temp(fixture_paths, user_dir)


def main() -> int:
    parser = argparse.ArgumentParser(description="运行档案持久化定向探针")
    parser.add_argument("--godot", help="Godot 可执行文件；缺省读 GODOT_BIN 或 PATH")
    parser.add_argument("--timeout", type=int, default=120)
    args = parser.parse_args()
    godot = resolve_godot(args.godot)
    if godot is None:
        raise SystemExit("未找到 Godot 可执行文件，请使用 --godot 或 GODOT_BIN 指定。")
    return run(godot, args.timeout)


if __name__ == "__main__":
    sys.exit(main())

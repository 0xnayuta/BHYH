#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""运行场景级运行时探针套件。

探针规格位于 scripts/scene_probes/；运行器只在执行期间把 .gd/.tscn 复制到
Godot 工程根目录，用 `--scene` 启动完整项目生命周期，结束后清理。

之所以不用 `--script`：自定义 SceneTree 会在 Autoload 全局标识注册前编译
入口依赖，导致 `LocalCoop` 等标识在编译期不可见。`--scene` 与生产启动顺序
一致，能真实验证 `_ready()`、资源加载与视觉节点。

套件当前包含：

- `constellation`：星座 Boss 视觉后端与 FrameSequence 生命周期；
- `level-selection`：八仙过海 / 挑战三太子的运行期选择态与自预载边界；
- `level-resource-lease`：关卡资源租约的路径分类、按租约释放与共享缓存保留；
- `load-guard`：预载单槽清理、重复切换取消、加载超时与失败不提交；
- `role-skills`：角色 2/4 技能入口、BingYu/CangMu 效果实例化与 5 个 Spine 资源预加载；
- `level-progress-exit`：Level10/17/19/20/21/22 非胜利转场只保存一次进度；
- `magic-weapons`：法宝与角色特效构建期帧（诛仙剑阵、青莲、青龙剑/太极、八仙、Lyfb、哪吒阴阳）。
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import time
import uuid
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "source"
FIXTURE_DIR = ROOT / "scripts" / "scene_probes"
REPORT_DIR = ROOT / "docs" / "reports"
GODOT_CANDIDATES = ("godot", "godot4")


@dataclass(frozen=True)
class ProbeSpec:
    key: str
    title: str
    script_name: str
    scene_name: str
    result_prefix: str
    report_stem: str
    teardown_marker: str | None = None
    quit_after_frames: int = 600
    timeout_seconds: int = 90

    @property
    def script_path(self) -> Path:
        return FIXTURE_DIR / self.script_name

    @property
    def scene_path(self) -> Path:
        return FIXTURE_DIR / self.scene_name


PROBES: tuple[ProbeSpec, ...] = (
    ProbeSpec(
        key="constellation",
        title="星座 Boss 运行时探针",
        script_name="constellation_probe.gd",
        scene_name="constellation_probe.tscn",
        result_prefix="CONSTELLATION_PROBE_RESULT=",
        report_stem="constellation_probe_report",
    ),
    ProbeSpec(
        key="level-selection",
        title="关卡选择态运行时探针",
        script_name="level_selection_probe.gd",
        scene_name="level_selection_probe.tscn",
        result_prefix="LEVEL_SELECTION_PROBE_RESULT=",
        report_stem="level_selection_probe_report",
        teardown_marker="LEVEL_SELECTION_PROBE_TEARDOWN",
        quit_after_frames=6000,
        timeout_seconds=240,
    ),
    ProbeSpec(
        key="level-resource-lease",
        title="关卡资源租约运行时探针",
        script_name="level_resource_lease_probe.gd",
        scene_name="level_resource_lease_probe.tscn",
        result_prefix="LEVEL_RESOURCE_LEASE_PROBE_RESULT=",
        report_stem="level_resource_lease_probe_report",
        teardown_marker="LEVEL_RESOURCE_LEASE_PROBE_TEARDOWN",
        quit_after_frames=120,
        timeout_seconds=60,
    ),
    ProbeSpec(
        key="load-guard",
        title="加载失败/取消/超时探针",
        script_name="load_guard_probe.gd",
        scene_name="load_guard_probe.tscn",
        result_prefix="LOAD_GUARD_PROBE_RESULT=",
        report_stem="load_guard_probe_report",
        teardown_marker="LOAD_GUARD_PROBE_TEARDOWN",
        quit_after_frames=5000,
        timeout_seconds=180,
    ),
    ProbeSpec(
        key="magic-weapons",
        title="法宝/角色特效构建期帧运行时探针",
        script_name="magic_weapon_probe.gd",
        scene_name="magic_weapon_probe.tscn",
        result_prefix="MAGIC_WEAPON_PROBE_RESULT=",
        report_stem="magic_weapon_probe_report",
        teardown_marker="MAGIC_WEAPON_PROBE_TEARDOWN",
        quit_after_frames=600,
        timeout_seconds=180,
    ),
    ProbeSpec(
        key="level-progress-exit",
        title="关卡退出分支保存次数探针",
        script_name="level_progress_exit_probe.gd",
        scene_name="level_progress_exit_probe.tscn",
        result_prefix="LEVEL_PROGRESS_EXIT_PROBE_RESULT=",
        report_stem="level_progress_exit_probe_report",
        teardown_marker="LEVEL_PROGRESS_EXIT_PROBE_TEARDOWN",
        quit_after_frames=6000,
        timeout_seconds=240,
    ),
    ProbeSpec(
        key="role-skills",
        title="角色 2/4 技能运行时探针",
        script_name="role_skill_probe.gd",
        scene_name="role_skill_probe.tscn",
        result_prefix="ROLE_SKILL_PROBE_RESULT=",
        report_stem="role_skill_probe_report",
        teardown_marker="ROLE_SKILL_PROBE_TEARDOWN",
        quit_after_frames=600,
        timeout_seconds=180,
    ),
    ProbeSpec(
        key="ui-factories",
        title="场景工厂族运行时探针",
        script_name="ui_factory_probe.gd",
        scene_name="ui_factory_probe.tscn",
        result_prefix="UI_FACTORY_PROBE_RESULT=",
        report_stem="ui_factory_probe_report",
        teardown_marker="UI_FACTORY_PROBE_TEARDOWN",
        quit_after_frames=600,
        timeout_seconds=180,
    ),
    ProbeSpec(
        key="run-context",
        title="运行上下文与结算读取探针",
        script_name="run_context_probe.gd",
        scene_name="run_context_probe.tscn",
        result_prefix="RUN_CONTEXT_PROBE_RESULT=",
        report_stem="run_context_probe_report",
        teardown_marker="RUN_CONTEXT_PROBE_TEARDOWN",
        quit_after_frames=600,
        timeout_seconds=180,
    ),
    ProbeSpec(
        key="level-entry",
        title="关卡进入与怪物生成探针",
        script_name="level_entry_probe.gd",
        scene_name="level_entry_probe.tscn",
        result_prefix="LEVEL_ENTRY_PROBE_RESULT=",
        report_stem="level_entry_probe_report",
        teardown_marker="LEVEL_ENTRY_PROBE_TEARDOWN",
        quit_after_frames=600,
        timeout_seconds=180,
    ),
    ProbeSpec(
        key="utils",
        title="通用工具与角色贴图运行时探针",
        script_name="utils_probe.gd",
        scene_name="utils_probe.tscn",
        result_prefix="UTILS_PROBE_RESULT=",
        report_stem="utils_probe_report",
        teardown_marker="UTILS_PROBE_TEARDOWN",
        quit_after_frames=600,
        timeout_seconds=180,
    ),
)


def resolve_godot(explicit: str | None) -> str:
    candidates = [explicit] if explicit else []
    candidates.extend(GODOT_CANDIDATES)
    for candidate in candidates:
        if not candidate:
            continue
        path = Path(candidate)
        if path.is_file():
            return str(path)
        found = shutil.which(candidate)
        if found:
            return found
    raise SystemExit("未找到 Godot 可执行文件，请使用 --godot 指定。")


def write_fixture(spec: ProbeSpec, instance_id: str) -> tuple[Path, Path]:
    gd_path = PROJECT / f"_{spec.key.replace('-', '_')}_probe_{instance_id}.gd"
    scene_path = PROJECT / f"_{spec.key.replace('-', '_')}_probe_{instance_id}.tscn"
    shutil.copy2(spec.script_path, gd_path)
    scene_text = spec.scene_path.read_text(encoding="utf-8")
    scene_text = scene_text.replace("__PROBE_SCRIPT__", f"res://{gd_path.name}")
    scene_path.write_text(scene_text, encoding="utf-8", newline="\n")
    return gd_path, scene_path


def cleanup_temp(paths: list[Path]) -> None:
    for path in paths:
        if path.exists():
            path.unlink()
        uid_path = path.with_name(path.name + ".uid")
        if uid_path.exists():
            uid_path.unlink()


def parse_result(output: str, spec: ProbeSpec) -> dict:
    for line in reversed(output.splitlines()):
        if not line.startswith(spec.result_prefix):
            continue
        try:
            payload = json.loads(line[len(spec.result_prefix) :])
        except json.JSONDecodeError:
            return {"ok": False, "failures": ["探针结果 JSON 无效"], "checks": {}}
        if not isinstance(payload, dict):
            return {"ok": False, "failures": ["探针结果不是 JSON 对象"], "checks": {}}
        payload.setdefault("failures", [])
        payload.setdefault("checks", {})
        return payload
    return {"ok": False, "failures": [f"缺少 {spec.result_prefix} 输出"], "checks": {}}


# Godot headless dummy renderer 在纹理初始化时会产生固定的
# `Parameter "t" is null` 引擎噪声（带 dummy texture 栈）；与
# level_test_runner 使用同一白名单，其它 ERROR/WARNING 仍按 0/0 门禁计数。
HEADLESS_RENDER_NOISE = re.compile(r'^ERROR: Parameter "t" is null\.\n(?:[ \t].*\n)*', re.M)


def collect_runtime_errors(output: str, teardown_marker: str | None) -> list[str]:
    if teardown_marker:
        output = output.split(teardown_marker, 1)[0]
    cleaned = HEADLESS_RENDER_NOISE.sub("", output)
    return [
        line
        for line in cleaned.splitlines()
        if line.startswith(("SCRIPT ERROR:", "ERROR:", "WARNING:"))
        and "resources still in use at exit" not in line
    ]


def run_probe(godot: str, spec: ProbeSpec, timeout_override: int | None) -> dict:
    instance_id = uuid.uuid4().hex[:10]
    gd_path, scene_path = write_fixture(spec, instance_id)
    temp_paths = [gd_path, scene_path]
    command = [
        godot,
        "--headless",
        "--path",
        str(PROJECT),
        "--quit-after",
        str(spec.quit_after_frames),
        "--scene",
        f"res://{scene_path.name}",
    ]
    timeout = timeout_override or spec.timeout_seconds
    result: dict = {"ok": False, "failures": [], "checks": {}}
    started = time.perf_counter()
    try:
        completed = subprocess.run(
            command,
            cwd=ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout,
        )
        output = (completed.stdout or "") + (completed.stderr or "")
        result = parse_result(output, spec)
        result["exit_code"] = completed.returncode
        runtime_errors = collect_runtime_errors(output, spec.teardown_marker)
        if runtime_errors:
            result["ok"] = False
            result["failures"].extend(f"runtime: {line}" for line in runtime_errors[-5:])
        if completed.returncode != 0:
            result["ok"] = False
            result["failures"].append(f"Godot 退出码 {completed.returncode}")
        result["output_tail"] = "\n".join(output.strip().splitlines()[-12:])
    except subprocess.TimeoutExpired:
        result = {
            "ok": False,
            "failures": [f"探针超时 ({timeout}s)"],
            "checks": {},
            "exit_code": None,
        }
    finally:
        cleanup_temp(temp_paths)
        result["duration_seconds"] = round(time.perf_counter() - started, 2)
    return result


def write_reports(spec: ProbeSpec, result: dict) -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    report_json = REPORT_DIR / f"{spec.report_stem}.json"
    report_md = REPORT_DIR / f"{spec.report_stem}.md"
    report_json.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    lines = [
        f"# {spec.title}报告",
        "",
        "> 由 `scripts/scene_probe_runner.py` 生成；探针只在执行期间复制到工程根目录。",
        "",
        f"**结果**：{'PASS' if result.get('ok') else 'FAIL'}",
        f"**耗时**：{result.get('duration_seconds', 0):.2f} 秒",
        "",
        "| 检查项 | 结果 |",
        "|---|---|",
    ]
    for key, value in (result.get("checks") or {}).items():
        lines.append(f"| `{key}` | `{value}` |")
    failures = result.get("failures") or []
    if failures:
        lines.extend(["", "## 失败", ""])
        lines.extend(f"- {failure}" for failure in failures)
    output_tail = result.get("output_tail")
    if output_tail:
        lines.extend(["", "## 输出尾部", "", "```text", output_tail, "```"])
    report_md.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="运行场景级运行时探针套件")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径")
    parser.add_argument(
        "--probe",
        action="append",
        choices=[spec.key for spec in PROBES],
        help="只运行指定探针，可重复；默认运行全部",
    )
    parser.add_argument("--timeout", type=int, default=None, help="覆盖单个探针超时秒数")
    args = parser.parse_args()

    for spec in PROBES:
        if not spec.script_path.exists() or not spec.scene_path.exists():
            print(f"缺少探针规格: {spec.key} ({FIXTURE_DIR})", file=sys.stderr)
            return 2
    if not (PROJECT / "project.godot").exists():
        print(f"工程目录不存在或缺少 project.godot: {PROJECT}", file=sys.stderr)
        return 2

    godot = resolve_godot(args.godot)
    selected = [spec for spec in PROBES if not args.probe or spec.key in args.probe]
    failures: list[tuple[ProbeSpec, dict]] = []
    for spec in selected:
        result = run_probe(godot, spec, args.timeout)
        write_reports(spec, result)
        if result.get("ok"):
            print(f"[PASS] {spec.title}通过 ({result.get('duration_seconds', 0):.2f}s)")
        else:
            print(f"[FAIL] {spec.title}失败 ({result.get('duration_seconds', 0):.2f}s)", file=sys.stderr)
            for failure in result.get("failures") or []:
                print(f"  - {failure}", file=sys.stderr)
            failures.append((spec, result))

    if failures:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

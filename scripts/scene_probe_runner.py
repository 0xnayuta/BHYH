#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""运行星座 Boss 运行时场景探针。

探针规格位于 scripts/scene_probes/；运行器只在执行期间把 .gd/.tscn 复制到
Godot 工程根目录，用 `--scene` 启动完整项目生命周期，结束后清理。

之所以不用 `--script`：自定义 SceneTree 会在 Autoload 全局标识注册前编译
入口依赖，导致 `LocalCoop` 等标识在编译期不可见。`--scene` 与生产启动顺序
一致，能真实验证 `_ready()`、资源加载与视觉节点。
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "source"
FIXTURE_DIR = ROOT / "scripts" / "scene_probes"
PROBE_SOURCE = FIXTURE_DIR / "constellation_probe.gd"
SCENE_SOURCE = FIXTURE_DIR / "constellation_probe.tscn"
REPORT_MD = ROOT / "docs" / "reports" / "constellation_probe_report.md"
REPORT_JSON = ROOT / "docs" / "reports" / "constellation_probe_report.json"
RESULT_PREFIX = "CONSTELLATION_PROBE_RESULT="
GODOT_CANDIDATES = ("godot", "godot4")
QUIT_AFTER_FRAMES = 600


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


def write_fixture(instance_id: str) -> tuple[Path, Path]:
    gd_path = PROJECT / f"_constellation_probe_{instance_id}.gd"
    scene_path = PROJECT / f"_constellation_probe_{instance_id}.tscn"
    shutil.copy2(PROBE_SOURCE, gd_path)
    scene_text = SCENE_SOURCE.read_text(encoding="utf-8")
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
    return {"ok": False, "failures": ["缺少 CONSTELLATION_PROBE_RESULT 输出"], "checks": {}}


def collect_runtime_errors(output: str) -> list[str]:
    return [
        line
        for line in output.splitlines()
        if line.startswith(("SCRIPT ERROR:", "ERROR:", "WARNING:"))
        and "resources still in use at exit" not in line
    ]


def run_probe(godot: str, timeout: int) -> dict:
    instance_id = uuid.uuid4().hex[:10]
    gd_path, scene_path = write_fixture(instance_id)
    temp_paths = [gd_path, scene_path]
    command = [
        godot,
        "--headless",
        "--path",
        str(PROJECT),
        "--quit-after",
        str(QUIT_AFTER_FRAMES),
        "--scene",
        f"res://{scene_path.name}",
    ]
    result: dict = {"ok": False, "failures": [], "checks": {}}
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
        result = parse_result(output)
        result["exit_code"] = completed.returncode
        runtime_errors = collect_runtime_errors(output)
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
    return result


def write_reports(result: dict) -> None:
    REPORT_JSON.parent.mkdir(parents=True, exist_ok=True)
    REPORT_JSON.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    lines = [
        "# 星座 Boss 运行时探针报告",
        "",
        "> 由 `scripts/scene_probe_runner.py` 生成；探针只在执行期间复制到工程根目录。",
        "",
        f"**结果**：{'PASS' if result.get('ok') else 'FAIL'}",
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
    REPORT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="运行星座 Boss 运行时场景探针")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径")
    parser.add_argument("--timeout", type=int, default=90, help="探针超时秒数")
    args = parser.parse_args()

    if not PROBE_SOURCE.exists() or not SCENE_SOURCE.exists():
        print(f"缺少探针规格: {FIXTURE_DIR}", file=sys.stderr)
        return 2
    if not (PROJECT / "project.godot").exists():
        print(f"工程目录不存在或缺少 project.godot: {PROJECT}", file=sys.stderr)
        return 2

    godot = resolve_godot(args.godot)
    result = run_probe(godot, args.timeout)
    write_reports(result)
    if result.get("ok"):
        print("[PASS] 星座 Boss 运行时探针通过")
        return 0
    print("[FAIL] 星座 Boss 运行时探针失败", file=sys.stderr)
    for failure in result.get("failures") or []:
        print(f"  - {failure}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())

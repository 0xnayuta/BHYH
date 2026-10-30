#!/usr/bin/env python3
"""运行 LocalCoop 验证矩阵。

矩阵脚本位于 scripts/coop_probes/coop_probe_matrix.gd；运行器只在执行期间
把它复制到 Godot 工程根目录，结束后清理，不进入生产源码。
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "source"
MATRIX_SOURCE = ROOT / "scripts" / "coop_probes" / "coop_probe_matrix.gd"
MATRIX_TEMP = PROJECT / "_coop_probe_matrix.gd"
REPORT_MD = ROOT / "docs" / "reports" / "coop_probe_matrix_report.md"
REPORT_JSON = ROOT / "docs" / "reports" / "coop_probe_matrix_report.json"

CASES = [
    "LocalCoopProbe",
    "LocalCoopGameplayProbe",
    "LocalCoopMagicSwitchProbe",
    "LocalCoopMonsterBalanceProbe",
    "LocalCoopMonsterInfoProbe",
    "LocalCoopNicknameProbe",
    "LocalCoopPanelProbe",
    "LocalCoopPerformanceProbe",
    "LocalCoopPetBuffProbe",
    "LocalCoopPetExperienceProbe",
    "LocalCoopSharedSoulProbe",
    "LocalCoopSlotLedgerProbe",
    "LocalCoopPanelOperatorProbe",
    "LocalCoopSkillKeysProbe",
    "LocalCoopSwitchPassiveProbe",
    "LocalCoopSwordMountProbe",
    "LocalCoopCreationUIProbe",
    "LocalCoopAttributionSourcesProbe",
    "LocalCoopPoolReuseProbe",
    "LocalCoopDamageStatsProbe",
    "LocalCoopWushuangAttributionProbe",
    "LocalCoopRole4PoisonProbe",
    "LocalCoopAllDeadProbe",
    "LocalCoopInputIsolationProbe",
    "LocalCoopKeyConfigProbe",
]

GODOT_CANDIDATES = ("godot", "godot4")


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


def cleanup_temp() -> None:
    for path in (MATRIX_TEMP, MATRIX_TEMP.with_suffix(".gd.uid")):
        if path.exists():
            path.unlink()


def run_case(godot: str, case: str, timeout: int) -> dict:
    command = [
        godot,
        "--headless",
        "--path",
        str(PROJECT),
        "--script",
        f"res://{MATRIX_TEMP.name}",
        "--",
        f"--case={case}",
    ]
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
        result = None
        for line in reversed(output.splitlines()):
            if line.startswith("COOP_MATRIX_RESULT="):
                try:
                    result = json.loads(line.split("=", 1)[1])
                except json.JSONDecodeError:
                    result = None
                break
        if result is None:
            tail = "\n".join(output.strip().splitlines()[-8:])
            return {
                "case": case,
                "status": "FAIL",
                "failures": [f"no matrix result (exit={completed.returncode})", tail],
                "skip_reason": "",
            }
        result.setdefault("failures", [])
        result.setdefault("skip_reason", "")
        # 引擎退出时的资源清理告警不代表探针失败；其余运行时错误必须拦截。
        runtime_errors = [
            line
            for line in output.splitlines()
            if line.startswith(("SCRIPT ERROR:", "ERROR:"))
            and "resources still in use at exit" not in line
        ]
        if runtime_errors:
            result["status"] = "FAIL"
            result["failures"].extend(f"runtime: {line}" for line in runtime_errors[-3:])
        return result
    except subprocess.TimeoutExpired:
        return {
            "case": case,
            "status": "FAIL",
            "failures": [f"timeout after {timeout}s"],
            "skip_reason": "",
        }


def write_reports(results: list[dict]) -> None:
    REPORT_JSON.parent.mkdir(parents=True, exist_ok=True)
    REPORT_JSON.write_text(
        json.dumps({"cases": results}, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    lines = [
        "# LocalCoop 验证矩阵报告",
        "",
        "> 由 `scripts/coop_probe_runner.py` 生成；探针只在执行期间复制到工程根目录。",
        "",
        "| 探针 | 状态 | 说明 |",
        "|---|---|---|",
    ]
    for result in results:
        note = result.get("skip_reason") or "; ".join(result.get("failures", [])) or "-"
        note = note.replace("|", "\\|").replace("\n", " ")
        lines.append(f"| {result['case']} | {result['status']} | {note} |")
    passed = sum(1 for result in results if result["status"] == "PASS")
    skipped = sum(1 for result in results if result["status"] == "SKIP")
    failed = sum(1 for result in results if result["status"] == "FAIL")
    lines.extend(
        [
            "",
            f"汇总：**PASS {passed} / SKIP {skipped} / FAIL {failed}**",
            "",
            "> SKIP 表示该上游探针依赖尚未移植的 UI/夹具；不得将其计为 PASS。",
        ]
    )
    REPORT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="运行 LocalCoop 验证矩阵")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径")
    parser.add_argument("--timeout", type=int, default=180, help="单个探针超时秒数")
    parser.add_argument("--only", action="append", default=None, help="只运行指定探针，可重复")
    args = parser.parse_args()

    godot = resolve_godot(args.godot)
    cases = args.only or CASES
    unknown = [case for case in cases if case not in CASES]
    if unknown:
        raise SystemExit(f"未知探针: {', '.join(unknown)}")

    if not MATRIX_SOURCE.exists():
        raise SystemExit(f"缺少矩阵脚本: {MATRIX_SOURCE}")
    if not (PROJECT / "project.godot").exists():
        raise SystemExit(f"工程目录不存在或缺少 project.godot: {PROJECT}")
    PROJECT.mkdir(parents=True, exist_ok=True)
    cleanup_temp()
    shutil.copy2(MATRIX_SOURCE, MATRIX_TEMP)
    results: list[dict] = []
    try:
        for index, case in enumerate(cases, 1):
            print(f"[{index}/{len(cases)}] {case}", flush=True)
            result = run_case(godot, case, args.timeout)
            results.append(result)
            print(f"  -> {result['status']}", flush=True)
    finally:
        cleanup_temp()
    write_reports(results)
    failed = [result for result in results if result["status"] == "FAIL"]
    print(f"报告: {REPORT_MD}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

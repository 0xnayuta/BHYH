#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/level_regression_all.py

全量关卡冒烟回归（并发，默认 4 路）。

范围
----
- `Scene/level/level_<n>.tscn`（85 个编号关卡）
- `Scene/level/level_*.tscn` 特殊关卡（Boss / 活动 / 挑战）
- `bai_gu_level` / `boat` / `bsz` / `hdzm` / `jctfloor_1`

`level_test_runner.py` 为每个实例生成唯一临时驱动/报告/日志文件名，支持安全并发执行。

日常变更回归
------------
`--changed-only` 基于 `git diff --name-only <diff-base>` 解析变更路径：
- 关卡场景、`Script/level/<关卡>.gd`、`Art/level/<关卡>/` 资源直接映射；
- 其他源码沿 `res://` 依赖反查图向上定位受影响关卡；
- 无法映射的源码保守回退全量，避免漏测；
- 默认 `--jobs 4`，`--jobs 1` 为串行排障口径。

输出
----
- `docs/reports/level_regression_manifest.json`
- `docs/reports/level_regression_report.json`（全量）
- `docs/reports/level_regression_report.md`（全量）
- `docs/reports/level_regression_changed_report.json`（changed-only）
- `docs/reports/level_regression_changed_report.md`（changed-only）
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time
import concurrent.futures
from typing import Any, Dict, List, Set, Tuple

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_ROOT = os.path.join(PROJECT_ROOT, "source")
LEVEL_DIR = os.path.join(PROJECT_ROOT, "source", "Scene", "level")
RUNNER = os.path.join(PROJECT_ROOT, "scripts", "level_test_runner.py")
MANIFEST_JSON = os.path.join(PROJECT_ROOT, "docs", "reports", "level_regression_manifest.json")
REPORT_JSON = os.path.join(PROJECT_ROOT, "docs", "reports", "level_regression_report.json")
REPORT_MD = os.path.join(PROJECT_ROOT, "docs", "reports", "level_regression_report.md")
REPORT_JSON_CHANGED = os.path.join(PROJECT_ROOT, "docs", "reports", "level_regression_changed_report.json")
REPORT_MD_CHANGED = os.path.join(PROJECT_ROOT, "docs", "reports", "level_regression_changed_report.md")
EXTRA_LEVELS = ("bai_gu_level", "boat", "bsz", "hdzm", "jctfloor_1")
# 这 5 个场景是 Node2D 菜单/地图/交互场景，没有 Hero 根节点，
# 不属于战斗关卡冒烟范围；在报告中登记为 SKIP，而不是伪装成 FAIL。
NON_BATTLE_SPECIALS = {"bai_gu_level", "boat", "bsz", "hdzm", "jctfloor_1"}
DEPENDENCY_EXTS = (".gd", ".tscn", ".tres")
RES_PATH_RE = re.compile(r'res://([^"\'\s\)]+)')


def _read_text(path: str) -> str:
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as fh:
            return fh.read()
    except OSError:
        return ""


def _git_path(abs_path: str) -> str:
    return os.path.relpath(abs_path, PROJECT_ROOT).replace("\\", "/")


def _normalize_changed_path(path: str) -> str:
    """把 .uid/.import 伴生变更归并到主文件，便于依赖图匹配。"""
    normalized = path.strip().replace("\\", "/")
    for suffix in (".import", ".uid"):
        if normalized.endswith(suffix):
            return normalized[: -len(suffix)]
    return normalized


def collect_changed_files(diff_base: str) -> List[str]:
    """读取 git diff --name-only；只返回变更路径，不执行文件内容扫描。"""
    proc = subprocess.run(
        ["git", "diff", "--name-only", diff_base],
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="ignore",
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or f"git diff --name-only {diff_base} 失败")
    return [line.strip() for line in proc.stdout.splitlines() if line.strip()]


def build_reverse_dependency_graph() -> Dict[str, Set[str]]:
    """一次遍历源码文本文件，建立 `被引用路径 -> 引用者` 反查图。"""
    graph: Dict[str, Set[str]] = {}
    for root, dirs, files in os.walk(SOURCE_ROOT):
        dirs[:] = [name for name in dirs if name not in (".godot", "godot", ".git")]
        for filename in files:
            if not filename.endswith(DEPENDENCY_EXTS):
                continue
            abs_path = os.path.join(root, filename)
            parent = _git_path(abs_path)
            text = _read_text(abs_path)
            for match in RES_PATH_RE.finditer(text):
                target_rel = match.group(1).rstrip(".,;").replace("\\", "/")
                target_git = f"source/{target_rel}"
                graph.setdefault(target_git, set()).add(parent)
    return graph


def resolve_changed_levels(
    changed_files: List[str],
    all_stems: List[str],
) -> Tuple[Set[str], List[str], List[str]]:
    """
    把 git diff 路径解析为受影响关卡集合。

    返回 (affected_stems, unknown_source_paths, ignored_paths)。
    - 关卡场景、关卡专属脚本、Art/level/<关卡>/ 资源：直接映射；
    - 其余源码路径：沿 `被引用 -> 引用者` 反查图向上找所属关卡；
    - 无法映射的源码路径：返回 unknown，由调用方保守回退全量。
    """
    all_stem_set = set(all_stems)
    level_root_map = {
        f"source/Scene/level/{stem}.tscn": stem for stem in all_stems
    }
    graph = None
    affected: Set[str] = set()
    unknown: List[str] = []
    ignored: List[str] = []

    for raw_path in changed_files:
        path = _normalize_changed_path(raw_path)
        if not path.startswith("source/"):
            ignored.append(path)
            continue
        if path == "source/project.godot":
            # Autoload/全局配置变更：任何关卡都可能受影响。
            return set(all_stems), [], ignored
        if path in level_root_map:
            affected.add(level_root_map[path])
            continue

        source_rel = path[len("source/") :]
        match = re.fullmatch(r"Script/level/([^/]+)\.gd", source_rel)
        if match and match.group(1) in all_stem_set:
            affected.add(match.group(1))
            continue
        match = re.fullmatch(r"Art/level/([^/]+)/.+", source_rel)
        if match and match.group(1) in all_stem_set:
            affected.add(match.group(1))
            continue

        # 沿反向依赖图向上查找关卡场景根节点；仅非直接映射路径才构建图。
        if graph is None:
            graph = build_reverse_dependency_graph()
        queue = [path]
        seen = {path}
        found_roots: Set[str] = set()
        while queue:
            current = queue.pop()
            for parent in graph.get(current, ()):
                if parent in level_root_map:
                    found_roots.add(level_root_map[parent])
                elif parent not in seen:
                    seen.add(parent)
                    queue.append(parent)
        if found_roots:
            affected.update(found_roots)
        else:
            unknown.append(path)

    return affected, unknown, ignored


def collect_levels() -> Tuple[List[int], List[str]]:
    numbered: List[int] = []
    special: List[str] = []
    for name in sorted(os.listdir(LEVEL_DIR)):
        if not name.endswith(".tscn"):
            continue
        stem = name[:-5]
        match = re.fullmatch(r"level_(\d+)", stem)
        if match:
            numbered.append(int(match.group(1)))
        elif stem.startswith("level_") or stem in EXTRA_LEVELS:
            special.append(stem)
    return sorted(numbered), sorted(special)


def write_manifest(numbered: List[int], special: List[str]) -> None:
    payload = {
        "generated_at": time.strftime("%Y-%m-%d %H:%M:%S"),
        "numbered_count": len(numbered),
        "special_count": len(special),
        "numbered": [f"level_{n}" for n in numbered],
        "special": special,
        "special_scenes": [
            {"name": scene_stem, "non_battle": scene_stem in NON_BATTLE_SPECIALS}
            for scene_stem in special
        ],
        "non_battle": {scene_stem: True for scene_stem in special if scene_stem in NON_BATTLE_SPECIALS},
    }
    with open(MANIFEST_JSON, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(payload, fh, ensure_ascii=False, indent=2)


def run_one(scene_stem: str, timeout: int) -> Dict[str, Any]:
    if scene_stem in NON_BATTLE_SPECIALS:
        return {
            "scene": scene_stem,
            "passed": True,
            "skipped": True,
            "testable": False,
            "elapsed": 0.0,
            "stage_count": None,
            "stages": [],
            "errors": [],
            "log": {"script_errors": 0, "errors": 0, "warnings": 0, "sample": []},
            "note": "非战斗场景（无 Hero 根节点），不纳入阶段冒烟",
        }
    scene = f"res://Scene/level/{scene_stem}.tscn"
    started = time.time()
    try:
        proc = subprocess.run(
            [sys.executable, RUNNER, "--level", scene, "--timeout", str(timeout), "--json"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="ignore",
            timeout=timeout + 90,
        )
    except subprocess.TimeoutExpired as exc:
        elapsed = round(time.time() - started, 2)
        return {
            "scene": scene_stem,
            "passed": False,
            "elapsed": elapsed,
            "stage_count": None,
            "stages": [],
            "errors": [f"runner_timeout (>{timeout + 90}s)"],
            "log": {"script_errors": 0, "errors": 0, "warnings": 0, "sample": []},
        }
    elapsed = round(time.time() - started, 2)
    try:
        report = json.loads(proc.stdout)
    except json.JSONDecodeError:
        report = {
            "errors": ["runner_json_unreadable"],
            "stdout_tail": proc.stdout[-1200:],
            "stderr_tail": proc.stderr[-1200:],
        }
    runner = report.get("_runner", {})
    errors = report.get("errors", [])
    if errors and errors[0] == "runner_json_unreadable":
        errors = [f"runner_json_unreadable (exit={proc.returncode})"]
        if report.get("stdout_tail"):
            errors.append("stdout: " + report["stdout_tail"][-500:])
        if report.get("stderr_tail"):
            errors.append("stderr: " + report["stderr_tail"][-500:])
    return {
        "scene": scene_stem,
        "passed": bool(runner.get("passed")),
        "elapsed": elapsed,
        "stage_count": report.get("stage_count"),
        "stages": [
            {"target": item.get("target_stage"), "actual": item.get("actual_stage"), "ok": item.get("ok")}
            for item in report.get("stages", [])
        ],
        "errors": errors,
        "log": runner.get("log", {}),
    }


def write_reports(
    results: List[Dict[str, Any]],
    duration: float,
    scope: str = "full",
    report_json: str = REPORT_JSON,
    report_md: str = REPORT_MD,
) -> None:
    passed = [item for item in results if item["passed"]]
    skipped = [item for item in results if item.get("skipped")]
    testable = [item for item in results if not item.get("skipped")]
    testable_passed = [item for item in testable if item["passed"]]
    failed = [item for item in results if not item["passed"]]
    payload = {
        "generated_at": time.strftime("%Y-%m-%d %H:%M:%S"),
        "scope": scope,
        "duration_seconds": round(duration, 2),
        "total": len(results),
        "testable_total": len(testable),
        "testable_passed": len(testable_passed),
        "passed": len(passed),
        "skipped": len(skipped),
        "failed": len(failed),
        "results": results,
    }
    with open(report_json, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(payload, fh, ensure_ascii=False, indent=2)

    is_full = scope == "full"
    lines = [
        "# 全量关卡冒烟回归报告 (Level Regression Report)"
        if is_full
        else "# 变更影响关卡冒烟回归报告 (Changed-Only Regression Report)",
        "",
        f"> 范围: `{scope}`",
        ">",
        f"> 生成时间: {payload['generated_at']}",
        ">",
        f"> 总耗时: `{payload['duration_seconds']} 秒`",
        ">",
        f"> 结果: **PASS {len(testable_passed)} / {len(testable)}**（SKIP {len(skipped)}），FAIL {len(failed)}",
        "",
        "| 关卡 | 结果 | 阶段 | 耗时(s) | 失败原因 |",
        "|:---:|:---:|:---:|:---:|:---|",
    ]
    for item in results:
        stages = " ".join(f"{s['actual']}/{s['target']}" for s in item["stages"]) or "-"
        reasons: List[str] = [str(err) for err in item["errors"]]
        log = item.get("log", {})
        if log.get("script_errors"):
            reasons.append(f"SCRIPT ERROR={log['script_errors']}")
        if log.get("errors"):
            reasons.append(f"ERROR={log['errors']}")
        if log.get("warnings"):
            reasons.append(f"WARNING={log['warnings']}")
        reason = "; ".join(reasons)[:200]
        lines.append(
            f"| {item['scene']} | {'SKIP' if item.get('skipped') else ('PASS' if item['passed'] else 'FAIL')} | "
            f"{stages} | {item['elapsed']} | {reason} |"
        )
    if failed:
        lines.extend(["", "## 失败明细", ""])
        for item in failed:
            lines.append(f"### {item['scene']}")
            lines.append(f"- 阶段: `{item['stages']}`")
            lines.append(f"- 驱动错误: `{item['errors']}`")
            lines.append(f"- 日志: `{item['log']}`")
            lines.append("")
    with open(report_md, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description="全量关卡冒烟回归（并发）")
    parser.add_argument("--timeout", type=int, default=150, help="单关超时（秒）")
    parser.add_argument(
        "--jobs",
        type=int,
        default=0,
        help="并发关卡数；0=auto（min(12, max(4, CPU 核数))），1=串行",
    )
    parser.add_argument("--warmup", type=int, default=0, help="并发前串行预热的关卡数（默认 0；实测无收益，保留用于对照）")
    parser.add_argument("--start", type=int, default=1, help="编号关卡起始（仅编号关）")
    parser.add_argument("--end", type=int, default=9999, help="编号关卡结束（仅编号关）")
    parser.add_argument("--special-only", action="store_true", help="只跑特殊关卡")
    parser.add_argument("--numbered-only", action="store_true", help="只跑编号关卡")
    parser.add_argument(
        "--changed-only",
        action="store_true",
        help="根据 git diff --name-only 只跑受影响的关卡（无法映射时保守回退全量）",
    )
    parser.add_argument(
        "--diff-base",
        default="HEAD",
        help="changed-only 的 git diff 基线（默认 HEAD；也可用 origin/main、HEAD~1）",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="只打印本次将运行的关卡，不执行 Godot、不写报告",
    )
    args = parser.parse_args()
    if args.jobs < 0:
        parser.error("--jobs 必须 >= 0（0=auto，1=串行）")
    jobs = args.jobs if args.jobs > 0 else min(12, max(4, os.cpu_count() or 4))
    if not os.path.isdir(SOURCE_ROOT):
        print(f"[!] 工程目录不存在: {SOURCE_ROOT}", file=sys.stderr)
        return 2

    all_numbered, all_special = collect_levels()
    all_stems = [f"level_{n}" for n in all_numbered] + all_special
    numbered = [n for n in all_numbered if args.start <= n <= args.end]
    special = all_special
    candidates: List[str] = []
    if not args.special_only:
        candidates.extend(f"level_{n}" for n in numbered)
    if not args.numbered_only:
        candidates.extend(special)
    if not candidates:
        print("[!] 无待测关卡", file=sys.stderr)
        return 1

    targets = candidates
    scope = "full"
    if args.changed_only:
        try:
            changed_files = collect_changed_files(args.diff_base)
        except RuntimeError as exc:
            print(f"[!] changed-only 获取 git diff 失败: {exc}", file=sys.stderr)
            return 2
        if not changed_files:
            print(f"[*] changed-only：git diff {args.diff_base} 无变更，无需运行关卡")
            return 0
        affected, unknown, ignored = resolve_changed_levels(changed_files, all_stems)
        if ignored:
            print(f"[*] changed-only：忽略 {len(ignored)} 个非游戏源码路径")
        if unknown:
            print(
                "[!] changed-only：以下源码路径无法映射到关卡，保守回退全量：",
                file=sys.stderr,
            )
            for path in unknown[:12]:
                print(f"    - {path}", file=sys.stderr)
            if len(unknown) > 12:
                print(f"    ... 其余 {len(unknown) - 12} 个", file=sys.stderr)
            scope = "changed-only-full-fallback"
            targets = candidates
        else:
            targets = [stem for stem in candidates if stem in affected]
            scope = "changed-only"
            print(
                f"[*] changed-only：{len(changed_files)} 个变更文件 -> "
                f"{len(targets)} 个受影响关卡"
            )
        if not targets:
            print("[*] changed-only：本次变更未影响任何待测关卡")
            return 0

    if args.dry_run:
        print(f"[*] dry-run：将运行 {len(targets)} 个关卡（scope={scope}）")
        for stem in targets:
            print(f"    - {stem}")
        return 0

    write_manifest(numbered, special)
    if scope == "full":
        print(f"[*] 全量关卡回归：{len(targets)} 个场景（并发 {jobs}，单关超时 {args.timeout}s）")
    else:
        print(f"[*] {scope} 关卡回归：{len(targets)} 个场景（并发 {jobs}，单关超时 {args.timeout}s）")
    results_by_scene: Dict[str, Dict[str, Any]] = {}
    started = time.time()
    warmup = targets[: max(0, args.warmup)]
    for stem in warmup:
        result = run_one(stem, args.timeout)
        results_by_scene[stem] = result
        label = "SKIP" if result.get("skipped") else ("PASS" if result["passed"] else "FAIL")
        print(f"[warmup] {stem}: {label} ({result['elapsed']}s)", flush=True)
    remaining = [stem for stem in targets if stem not in results_by_scene]
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, jobs)) as executor:
        futures = {executor.submit(run_one, stem, args.timeout): stem for stem in remaining}
        for index, future in enumerate(
            concurrent.futures.as_completed(futures), len(warmup) + 1
        ):
            stem = futures[future]
            try:
                result = future.result()
            except Exception as exc:  # pragma: no cover - defensive worker boundary
                result = {
                    "scene": stem,
                    "passed": False,
                    "elapsed": 0.0,
                    "stage_count": None,
                    "stages": [],
                    "errors": [f"worker_exception: {exc}"],
                    "log": {"script_errors": 0, "errors": 0, "warnings": 0, "sample": []},
                }
            results_by_scene[stem] = result
            label = "SKIP" if result.get("skipped") else ("PASS" if result["passed"] else "FAIL")
            print(f"[{index}/{len(targets)}] {stem}: {label} ({result['elapsed']}s)", flush=True)
    # 并发运行时 Godot headless 偶发资源/RID 噪声；失败关卡串行重试一次，
    # 避免把并行启动的瞬态问题误报为关卡回归失败。
    retry_stems = [
        stem for stem in targets
        if not results_by_scene[stem].get("skipped") and not results_by_scene[stem].get("passed")
    ]
    if retry_stems:
        print(f"[*] 重试失败关卡: {', '.join(retry_stems)}", flush=True)
        for stem in retry_stems:
            result = run_one(stem, args.timeout)
            results_by_scene[stem] = result
            label = "PASS" if result["passed"] else "FAIL"
            print(f"    [重试] {stem}: {label} ({result['elapsed']}s)", flush=True)
    results = [results_by_scene[stem] for stem in targets]
    duration = time.time() - started
    if scope == "full":
        report_json, report_md = REPORT_JSON, REPORT_MD
    else:
        report_json, report_md = REPORT_JSON_CHANGED, REPORT_MD_CHANGED
    write_reports(results, duration, scope=scope, report_json=report_json, report_md=report_md)
    passed = sum(1 for item in results if item["passed"])
    skipped = sum(1 for item in results if item.get("skipped"))
    testable = len(results) - skipped
    testable_passed = passed - skipped
    print(f"[*] 完成：PASS {testable_passed}/{testable} + SKIP {skipped}，耗时 {duration:.1f}s")
    print(f"[*] 报告：{report_md}")
    return 0 if passed == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Phase 32 UI Theme 基线审计与静态覆盖守恒门禁。

本脚本只做只读扫描与基线比较：

- 统计 `source/Scene/**/*.tscn` 中的直接 `theme_override_*` 属性；
- 单独统计 Animation 轨道里对 `theme_override_*` 属性的路径引用；
- 统计 Theme 资源、场景引用、`theme_type_variation`、FontFile 引用与脚本动态主题调用；
- 与 `scripts/theme_override_baseline.json` 比较，禁止场景级直接属性、动画引用、直接字体或动态调用/文件数增加。

基线是上限而不是目标：Phase 32 迁移只能让计数下降；新增 UI 场景或动态主题文件需要
显式更新基线并在评审中说明原因。动画轨道与脚本动态覆盖不计入静态迁移完成度。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
SCENE_ROOT = SOURCE / "Scene"
DEFAULT_BASELINE = ROOT / "scripts" / "theme_override_baseline.json"
SCHEMA_ID = "theme_override_baseline"
SCHEMA_VERSION = 1

NODE_RE = re.compile(r'^\[node name="([^"]*)"(?: type="([^"]*)")?')
DIRECT_RE = re.compile(r"^theme_override_([a-zA-Z0-9_/]+)\s*=")
ANIMATION_REF_RE = re.compile(r'NodePath\("[^"]*theme_override_([a-zA-Z0-9_/]+)"\)')
THEME_REF_RE = re.compile(r'^theme\s*=\s*ExtResource\("([^"]+)"\)')
THEME_VARIATION_RE = re.compile(r'^theme_type_variation\s*=\s*&?"([^"]+)"')
FONT_RE = re.compile(r'^\[ext_resource type="FontFile"[^\]]*path="([^"]+)"')
THEME_RESOURCE_RE = re.compile(r'^\[gd_resource type="Theme"')


def _relative(path: Path) -> str:
    return path.relative_to(SOURCE).as_posix()


def _category(prop: str) -> str:
    return prop.split("/", 1)[0]


def scan() -> dict[str, object]:
    scenes: dict[str, dict[str, int]] = {}
    property_categories: Counter[str] = Counter()
    animation_categories: Counter[str] = Counter()
    node_types: Counter[str] = Counter()
    unassigned = 0
    theme_refs = 0
    theme_variations: set[str] = set()
    theme_variation_refs = 0
    font_refs = 0
    font_paths: set[str] = set()

    for path in sorted(SCENE_ROOT.rglob("*.tscn")):
        text = path.read_text(encoding="utf-8", errors="ignore")
        current_type = ""
        direct = 0
        animation = 0
        for line in text.splitlines():
            node_match = NODE_RE.match(line)
            if node_match:
                current_type = node_match.group(2) or "<inherited>"
                continue
            direct_match = DIRECT_RE.match(line)
            if direct_match:
                prop = direct_match.group(1)
                direct += 1
                property_categories[_category(prop)] += 1
                node_types[current_type or "<unknown>"] += 1
                if not current_type:
                    unassigned += 1
                continue
            animation_match = ANIMATION_REF_RE.search(line)
            if animation_match:
                animation += 1
                animation_categories[_category(animation_match.group(1))] += 1
            if THEME_REF_RE.match(line):
                theme_refs += 1
            variation_match = THEME_VARIATION_RE.match(line)
            if variation_match:
                theme_variation_refs += 1
                theme_variations.add(variation_match.group(1))
        for line in text.splitlines():
            if FONT_RE.match(line):
                font_refs += 1
                font_paths.add(FONT_RE.match(line).group(1))
        if direct or animation:
            scenes[_relative(path)] = {"direct": direct, "animation": animation}

    theme_resources: list[str] = []
    for path in sorted(SOURCE.rglob("*.tres")):
        try:
            first_line = path.read_text(encoding="utf-8", errors="ignore").splitlines()[0]
        except (OSError, IndexError):
            continue
        if THEME_RESOURCE_RE.match(first_line):
            theme_resources.append(_relative(path))

    dynamic_calls = 0
    dynamic_files: set[str] = set()
    for path in SOURCE.rglob("*.gd"):
        if path.is_relative_to(SOURCE / "addons") or path.is_relative_to(SOURCE / ".godot"):
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        count = text.count("add_theme_")
        if count:
            dynamic_calls += count
            dynamic_files.add(_relative(path))

    direct_total = sum(item["direct"] for item in scenes.values())
    animation_total = sum(item["animation"] for item in scenes.values())
    return {
        "schema_id": SCHEMA_ID,
        "schema_version": SCHEMA_VERSION,
        "totals": {
            "direct_properties": direct_total,
            "animation_track_refs": animation_total,
            "textual_references": direct_total + animation_total,
            "scenes": len(scenes),
        },
        "property_categories": dict(sorted(property_categories.items())),
        "animation_categories": dict(sorted(animation_categories.items())),
        "node_types": dict(sorted(node_types.items())),
        "unassigned_direct": unassigned,
        "themes": {
            "resources": theme_resources,
            "scene_refs": theme_refs,
            "type_variations": sorted(theme_variations),
            "variation_refs": theme_variation_refs,
        },
        "fonts": {
            "scene_refs": font_refs,
            "unique_files": len(font_paths),
            "paths": sorted(font_paths),
        },
        "dynamic_add_theme": {
            "calls": dynamic_calls,
            "files": len(dynamic_files),
            "paths": sorted(dynamic_files),
        },
        "scenes": dict(sorted(scenes.items())),
    }


def load_baseline(path: Path) -> dict[str, object]:
    if not path.is_file():
        raise ValueError(f"基线不存在: {path.relative_to(ROOT)}")
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("基线必须是 JSON 对象")
    if data.get("schema_id") != SCHEMA_ID or data.get("schema_version") != SCHEMA_VERSION:
        raise ValueError("基线 schema 不匹配")
    scenes = data.get("scenes")
    totals = data.get("totals")
    if not isinstance(scenes, dict) or not isinstance(totals, dict):
        raise ValueError("基线缺少 scenes/totals")
    for path, counts in scenes.items():
        if not isinstance(path, str) or not isinstance(counts, dict):
            raise ValueError("基线 scene 条目非法")
        for key in ("direct", "animation"):
            value = counts.get(key, 0)
            if not isinstance(value, int) or value < 0:
                raise ValueError(f"基线 {path}.{key} 非法")
    for key in ("direct_properties", "animation_track_refs"):
        value = totals.get(key)
        if not isinstance(value, int) or value < 0:
            raise ValueError(f"基线 totals.{key} 非法")
    return data


def check(report: dict[str, object], baseline: dict[str, object]) -> list[str]:
    errors: list[str] = []
    current_scenes: dict[str, dict[str, int]] = report["scenes"]  # type: ignore[assignment]
    baseline_scenes: dict[str, dict[str, int]] = baseline["scenes"]  # type: ignore[assignment]
    current_totals = report["totals"]  # type: ignore[assignment]
    baseline_totals = baseline["totals"]  # type: ignore[assignment]

    for path, counts in current_scenes.items():
        previous = baseline_scenes.get(path)
        if previous is None:
            errors.append(f"新增未登记场景: {path}（direct={counts['direct']} animation={counts['animation']}）")
            continue
        for key, label in (("direct", "直接属性"), ("animation", "动画轨道")):
            old = int(previous.get(key, 0))
            new = int(counts.get(key, 0))
            if new > old:
                errors.append(f"{path}: {label} {old} -> {new}")

    if int(current_totals["direct_properties"]) > int(baseline_totals["direct_properties"]):
        errors.append(f"直接属性总数增加: {baseline_totals['direct_properties']} -> {current_totals['direct_properties']}")
    if int(current_totals["animation_track_refs"]) > int(baseline_totals["animation_track_refs"]):
        errors.append(f"动画轨道引用总数增加: {baseline_totals['animation_track_refs']} -> {current_totals['animation_track_refs']}")

    current_fonts = report.get("fonts", {})  # type: ignore[assignment]
    baseline_fonts = baseline.get("fonts", {})  # type: ignore[assignment]
    current_font_refs = int(current_fonts.get("scene_refs", 0))
    baseline_font_refs = int(baseline_fonts.get("scene_refs", 0))
    if current_font_refs > baseline_font_refs:
        errors.append(f"场景直接字体引用增加: {baseline_font_refs} -> {current_font_refs}")

    current_dynamic = report.get("dynamic_add_theme", {})  # type: ignore[assignment]
    baseline_dynamic = baseline.get("dynamic_add_theme", {})  # type: ignore[assignment]
    current_calls = int(current_dynamic.get("calls", 0))
    baseline_calls = int(baseline_dynamic.get("calls", 0))
    if current_calls > baseline_calls:
        errors.append(f"动态主题调用增加: {baseline_calls} -> {current_calls}")
    current_files = int(current_dynamic.get("files", 0))
    baseline_files = int(baseline_dynamic.get("files", 0))
    if current_files > baseline_files:
        errors.append(f"动态主题文件增加: {baseline_files} -> {current_files}")
    baseline_paths = set(baseline_dynamic.get("paths", []))
    for path in current_dynamic.get("paths", []):
        if path not in baseline_paths:
            errors.append(f"新增未登记动态主题文件: {path}")
    return errors


def print_summary(report: dict[str, object]) -> None:
    totals = report["totals"]
    print(
        "UI Theme 基线："
        f"直接属性 {totals['direct_properties']}，"
        f"动画轨道 {totals['animation_track_refs']}，"
        f"文本引用 {totals['textual_references']}，"
        f"场景 {totals['scenes']}"
    )
    print(f"直接属性分类: {report['property_categories']}")
    print(f"节点类型: {report['node_types']}")
    print(
        "Theme: "
        f"{len(report['themes']['resources'])} 个资源 / "
        f"{report['themes']['scene_refs']} 个场景引用 / "
        f"{len(report['themes']['type_variations'])} 个类型变体 / {report['themes']['variation_refs']} 个节点引用"
    )
    print(
        "字体: "
        f"{report['fonts']['scene_refs']} 个场景引用 / "
        f"{report['fonts']['unique_files']} 个文件；"
        f"动态主题调用 {report['dynamic_add_theme']['calls']} 处 / "
        f"{report['dynamic_add_theme']['files']} 个文件"
    )
    if report["unassigned_direct"]:
        print(f"WARN 未归属节点的直接属性: {report['unassigned_direct']}", file=sys.stderr)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Phase 32 UI Theme 基线审计")
    parser.add_argument("--baseline", type=Path, default=DEFAULT_BASELINE, help="基线 JSON 路径")
    parser.add_argument("--check", action="store_true", help="与基线比较，计数增加时返回 1")
    parser.add_argument("--write-baseline", action="store_true", help="写入当前扫描结果作为新基线")
    parser.add_argument("--json", action="store_true", help="输出 JSON 报告")
    args = parser.parse_args(argv)

    if args.check and args.write_baseline:
        print("FAIL --check 与 --write-baseline 不能同时使用", file=sys.stderr)
        return 2

    report = scan()
    if args.write_baseline:
        report["generated_at"] = date.today().isoformat()
        args.baseline.parent.mkdir(parents=True, exist_ok=True)
        args.baseline.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        print(f"已写入基线: {args.baseline.relative_to(ROOT)}")
        print_summary(report)
        return 0

    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_summary(report)

    if not args.check:
        return 0

    try:
        baseline = load_baseline(args.baseline)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        return 1

    errors = check(report, baseline)
    if errors:
        for error in errors:
            print(f"FAIL {error}", file=sys.stderr)
        return 1
    if not args.json:
        print("PASS UI Theme 直接属性与动画轨道未超过基线")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

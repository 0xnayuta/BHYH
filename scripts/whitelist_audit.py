#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Phase 11-2 白名单冻结审计：版本、条目、评审记录与未登记项门禁。"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / "source"
REGISTRY = ROOT / "scripts/contract_whitelist.json"
REPORT_JSON = ROOT / "docs/reports/whitelist_freeze_audit.json"
REPORT_MD = ROOT / "docs/reports/whitelist_freeze_audit.md"
MACHINE_RE = re.compile(r"^(?:DefineSprite_|symbolClass$|.*-assets$|.*\.sprites$|glb_)")


def load_registry() -> dict:
    return json.loads(REGISTRY.read_text(encoding="utf-8"))


def scan_actual(project: Path) -> tuple[set[str], set[str], set[str]]:
    machine: set[str] = set()
    numeric: set[str] = set()
    prefixes = (
        "Art/monster/swf_png/",
        "Art/monster/north_original/",
        "Art/monster/palace_boss/",
        "Art/constellations/boss/",
        "Art/mount/runtime/mounts/",
        "Art/mount/runtime/effects/",
    )
    for dirpath, dirnames, _files in os.walk(project):
        relroot = os.path.relpath(dirpath, project).replace("\\", "/")
        if relroot == ".":
            dirnames[:] = [d for d in dirnames if d not in (".godot", "godot", "addons")]
        if relroot.startswith((".godot", "godot", "addons")):
            continue
        for name in dirnames:
            rel = f"{relroot}/{name}" if relroot != "." else name
            if MACHINE_RE.match(name):
                machine.add(rel)
            elif name.isdigit() and any(rel.startswith(prefix) for prefix in prefixes):
                numeric.add(rel)
    scene_root = project / "Scene/mount/rider_adjustments"
    scenes: set[str] = set()
    for path in scene_root.rglob("*.tscn"):
        if path.stem.isdigit():
            scenes.add(path.relative_to(project).as_posix())
    return machine, numeric, scenes


def digest_payload(data: dict) -> str:
    payload = {
        key: data.get(key)
        for key in (
            "naming",
            "numeric_scene_allowlist",
            "suppressed_literals",
            "suppressed_files",
            "known_extension_methods",
            "unresolved_node_patterns",
        )
    }
    encoded = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description="Phase 11-2 白名单冻结审计")
    parser.add_argument("--fail-on-error", action="store_true")
    args = parser.parse_args()
    if not PROJECT.is_dir():
        print(f"[FAIL] 工程目录不存在: {PROJECT}", file=sys.stderr)
        return 2
    data = load_registry()
    errors: list[str] = []
    if data.get("schema_version") != 2:
        errors.append("schema_version 必须为 2")
    if data.get("frozen") is not True:
        errors.append("frozen 必须为 true")
    if not data.get("frozen_at"):
        errors.append("缺少 frozen_at")
    naming = data.get("naming", {})
    machine = set(naming.get("machine_export_directories", []))
    numeric = set(naming.get("numeric_directories", []))
    scenes = set(naming.get("numeric_scene_files", []))
    if not machine or not numeric or not scenes:
        errors.append("naming 冻结清单不得为空")
    if len(machine) != len(naming.get("machine_export_directories", [])):
        errors.append("machine_export_directories 存在重复")
    if len(numeric) != len(naming.get("numeric_directories", [])):
        errors.append("numeric_directories 存在重复")
    actual_machine, actual_numeric, actual_scenes = scan_actual(PROJECT)
    unregistered = (actual_machine - machine) | (actual_numeric - numeric) | (actual_scenes - scenes)
    stale = (machine - actual_machine) | (numeric - actual_numeric) | (scenes - actual_scenes)
    if unregistered:
        errors.append(f"发现未登记白名单项: {sorted(unregistered)[:10]}")
    if stale:
        errors.append(f"白名单存在失效条目: {sorted(stale)[:10]}")
    expected_digest = digest_payload(data)
    if data.get("frozen_manifest_sha256") != expected_digest:
        errors.append("frozen_manifest_sha256 与当前冻结条目不一致")
    reviews = data.get("review_records", [])
    categories = {item.get("category") for item in reviews if item.get("status") == "approved"}
    for category in ("machine_export", "numeric_directory", "numeric_scene", "third_party"):
        if category not in categories:
            errors.append(f"缺少 {category} 技术评审记录")
    report = {
        "metadata": {"generated_at": __import__("datetime").datetime.now().isoformat(timespec="seconds"), "registry": REGISTRY.relative_to(ROOT).as_posix()},
        "summary": {
            "machine_export_entries": len(machine),
            "numeric_directory_entries": len(numeric),
            "numeric_scene_entries": len(scenes),
            "review_records": len(reviews),
            "unregistered": len(unregistered),
            "stale": len(stale),
            "errors": len(errors),
        },
        "errors": errors,
    }
    REPORT_JSON.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    lines = [
        "# Phase 11-2 白名单冻结审计",
        "",
        "> 机读报告：`docs/reports/whitelist_freeze_audit.json`",
        "",
        "| 项目 | 数量 |",
        "|:---|:---:|",
        f"| 机器导出目录 | {len(machine)} |",
        f"| 数字 ID 目录 | {len(numeric)} |",
        f"| 数字 ID 场景 | {len(scenes)} |",
        f"| 技术评审记录 | {len(reviews)} |",
        f"| 未登记项 | {len(unregistered)} |",
        f"| 失效条目 | {len(stale)} |",
        "",
    ]
    if errors:
        lines.extend(["## 错误", ""] + [f"- {item}" for item in errors])
    else:
        lines.extend(["## 结论", "", "白名单冻结清单完整，未登记项与失效条目均为 0。"])
    REPORT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print("\n".join(lines))
    if errors and args.fail_on_error:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

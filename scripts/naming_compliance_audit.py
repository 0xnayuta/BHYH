#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Phase 11-1R 全工程命名合规终审（Godot 官方规则 · 四张机读审计表）。"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / "source"
REGISTRY = ROOT / "scripts/contract_whitelist.json"
OUT_JSON = ROOT / "docs/reports/naming_compliance_audit.json"
OUT_MD = ROOT / "docs/reports/naming_compliance_audit.md"

SNAKE = re.compile(r"^_*[a-z0-9]+(_[a-z0-9]+)*$")
# Godot autoload bridge names. BaseObject/BaseRole/BaseMagicWeapon expose
# per-slot properties with these exact names so existing scripts keep resolving
# PlayerData/RoleProp/PlayerInput through the owning actor context.
AUTLOAD_BRIDGE_VARS = {"PlayerData", "RoleProp", "PlayerInput"}
PASCAL = re.compile(r"^[A-Z][A-Za-z0-9]*$")
UPPER = re.compile(r"^_?[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$")
CLASS_RE = re.compile(r"^\s*class_name\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
FUNC_RE = re.compile(r"^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.M)
VAR_RE = re.compile(r"^\s*(?:@export(?:[^\n]*)?\s+)?(?:@onready\s+)?var\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
CONST_RE = re.compile(r"^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
CONST_DECL_RE = re.compile(r"^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?::[^=\n]+)?=\s*(.+)$", re.M)
SIGNAL_RE = re.compile(r"^\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
ENUM_RE = re.compile(r"^\s*enum\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{", re.M)
ENUM_BLOCK_RE = re.compile(r"^\s*enum\s+[A-Za-z_][A-Za-z0-9_]*\s*\{([^}]*)\}", re.M | re.S)
CLASS_ALIAS_RE = re.compile(
    r"\bconst\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?::[^=\n]+)?\s*:?=\s*(?:preload|load)\s*\("
)
AUTOLOAD_RE = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*)="\*?res://([^"]+)"', re.M)
MACHINE_RE = re.compile(r"^(?:DefineSprite_|symbolClass$|.*-assets$|.*\.sprites$|glb_)")
ASSET_EXTS = {".tres", ".res", ".png", ".jpg", ".jpeg", ".webp", ".mp3", ".ogg", ".wav", ".ttf", ".otf", ".gdshader", ".json"}
IGNORE_EXTS = {".import", ".uid", ".translation", ".atlas", ".spine-json", ".dll", ".exe", ".godot"}
ROOT_STANDARD_DIRS = {"Art", "Font", "Music", "Scene", "Script", "Shader", "Spritesheet", "addons", "bin"}


def load_registry() -> dict:
    return json.loads(REGISTRY.read_text(encoding="utf-8"))


def registry_sets(data: dict) -> tuple[set[str], set[str], set[str], tuple[str, ...], tuple[str, ...]]:
    naming = data.get("naming", {})
    return (
        set(naming.get("machine_export_directories", [])),
        set(naming.get("numeric_directories", [])),
        set(naming.get("numeric_scene_files", [])),
        tuple(naming.get("third_party_prefixes", ["addons/"])) + ("godot/", ".godot/"),
        tuple(naming.get("companion_tool_suffixes", [".import", ".uid", ".atlas", ".spine-json", ".translation"])),
    )


def path_is_whitelisted(rel: str, machine: set[str], numeric: set[str], numeric_scenes: set[str], third_party: tuple[str, ...]) -> bool:
    if rel in numeric_scenes:
        return True
    if any(rel == p.rstrip("/") or rel.startswith(p) for p in third_party):
        return True
    if rel.startswith((".godot/", "godot/")):
        return True
    parent = os.path.dirname(rel)
    while parent:
        if parent in machine or parent in numeric:
            return True
        parent = os.path.dirname(parent)
    return False


def scan_dirs(data: dict) -> dict:
    machine, numeric, scenes, third_party, _companions = registry_sets(data)
    total = compliant = whitelisted = 0
    violations: list[dict] = []
    categories: Counter[str] = Counter()
    for dirpath, dirnames, _files in os.walk(PROJECT):
        relroot = os.path.relpath(dirpath, PROJECT).replace("\\", "/")
        for name in dirnames:
            rel = f"{relroot}/{name}" if relroot != "." else name
            total += 1
            if "/" not in rel and name in ROOT_STANDARD_DIRS:
                whitelisted += 1
                categories["root_standard"] += 1
            elif any(rel == p.rstrip("/") or rel.startswith(p) for p in third_party):
                whitelisted += 1
                categories["third_party"] += 1
            elif rel in machine:
                whitelisted += 1
                categories["machine_export"] += 1
            elif rel in numeric:
                whitelisted += 1
                categories["numeric_id"] += 1
            elif SNAKE.match(name):
                compliant += 1
                categories["snake_case"] += 1
            else:
                violations.append({"path": rel, "expected": "snake_case", "actual": name})
    return {
        "total": total, "compliant": compliant, "whitelisted": whitelisted,
        "violations": len(violations), "categories": dict(categories), "details": violations,
        "compliance_rate": round(compliant / max(total - whitelisted, 1) * 100, 4),
    }


def autoload_paths() -> set[str]:
    text = (PROJECT / "project.godot").read_text(encoding="utf-8", errors="ignore")
    return {m.group(2) for m in AUTOLOAD_RE.finditer(text)}


def scan_files(data: dict) -> dict:
    machine, numeric, numeric_scenes, third_party, companions = registry_sets(data)
    total = compliant = whitelisted = 0
    violations: list[dict] = []
    by_ext: dict[str, dict] = defaultdict(lambda: {"total": 0, "compliant": 0, "whitelisted": 0, "violations": 0})
    for dirpath, dirnames, filenames in os.walk(PROJECT):
        relroot = os.path.relpath(dirpath, PROJECT).replace("\\", "/")
        dirnames[:] = [d for d in dirnames if d not in (".git",)]
        for filename in filenames:
            rel = f"{relroot}/{filename}" if relroot != "." else filename
            ext = os.path.splitext(filename)[1].lower()
            if ext in IGNORE_EXTS:
                continue
            if ext not in ASSET_EXTS and ext not in {".tscn", ".gd"}:
                continue
            total += 1
            row = by_ext[ext]
            row["total"] += 1
            if path_is_whitelisted(rel, machine, numeric, numeric_scenes, third_party):
                whitelisted += 1
                row["whitelisted"] += 1
                continue
            stem = os.path.splitext(filename)[0]
            ok = True
            expected = "snake_case"
            if ext == ".tscn":
                expected = "snake_case"
                ok = bool(SNAKE.match(stem))
            elif ext == ".gd":
                expected = "snake_case"
                ok = bool(SNAKE.match(stem))
            elif ext in ASSET_EXTS:
                expected = "snake_case"
                ok = bool(SNAKE.match(stem))
            if ok:
                compliant += 1
                row["compliant"] += 1
            else:
                row["violations"] += 1
                violations.append({"path": rel, "extension": ext, "expected": expected, "actual": stem})
    for ext in by_ext:
        by_ext[ext]["compliance_rate"] = round(by_ext[ext]["compliant"] / max(by_ext[ext]["total"] - by_ext[ext]["whitelisted"], 1) * 100, 4)
    return {
        "total": total, "compliant": compliant, "whitelisted": whitelisted,
        "violations": len(violations), "by_extension": dict(sorted(by_ext.items())),
        "details": violations, "compliance_rate": round(compliant / max(total - whitelisted, 1) * 100, 4),
    }


def scan_code(data: dict) -> dict:
    total = compliant = 0
    violations: list[dict] = []
    by_kind: dict[str, dict] = defaultdict(lambda: {"total": 0, "compliant": 0, "violations": 0})
    for dirpath, dirnames, filenames in os.walk(PROJECT):
        relroot = os.path.relpath(dirpath, PROJECT).replace("\\", "/")
        dirnames[:] = [d for d in dirnames if d not in (".git", ".godot", "godot", "addons")]
        for filename in filenames:
            if not filename.endswith(".gd"):
                continue
            rel = f"{relroot}/{filename}" if relroot != "." else filename
            text = (PROJECT / rel).read_text(encoding="utf-8", errors="ignore")
            checks = (
                ("func", FUNC_RE, SNAKE), ("var", VAR_RE, SNAKE),
                ("signal", SIGNAL_RE, SNAKE), ("class_name", CLASS_RE, PASCAL), ("enum", ENUM_RE, PASCAL),
            )
            for kind, pattern, rule in checks:
                for match in pattern.finditer(text):
                    name = match.group(1)
                    total += 1
                    by_kind[kind]["total"] += 1
                    if rule.match(name) or (kind == "var" and name in AUTLOAD_BRIDGE_VARS):
                        compliant += 1
                        by_kind[kind]["compliant"] += 1
                    else:
                        by_kind[kind]["violations"] += 1
                        line = text.count("\n", 0, match.start()) + 1
                        violations.append({"file": rel, "line": line, "kind": kind, "name": name, "expected": rule.pattern})
            # 常量：普通常量 UPPER；`const ClassAlias = preload/load(...)` 允许 PascalCase。
            const_aliases: set[str] = set()
            search_start = 0
            while True:
                alias_match = CLASS_ALIAS_RE.search(text, search_start)
                if not alias_match:
                    break
                const_aliases.add(alias_match.group(1))
                search_start = alias_match.end()
            for match in CONST_RE.finditer(text):
                name = match.group(1)
                is_class_alias = name in const_aliases
                total += 1
                by_kind["const"]["total"] += 1
                if UPPER.match(name) or (is_class_alias and PASCAL.match(name)):
                    compliant += 1
                    by_kind["const"]["compliant"] += 1
                else:
                    by_kind["const"]["violations"] += 1
                    line = text.count("\n", 0, match.start()) + 1
                    expected = "UPPER_SNAKE_CASE or PascalCase(class alias)"
                    violations.append({"file": rel, "line": line, "kind": "const", "name": name, "expected": expected})
            # 枚举成员必须 UPPER_SNAKE_CASE。
            for block in ENUM_BLOCK_RE.finditer(text):
                base_line = text.count("\n", 0, block.start()) + 1
                for offset, raw in enumerate(block.group(1).splitlines()):
                    member = raw.split("#", 1)[0].strip().rstrip(",").strip()
                    if not member:
                        continue
                    name = member.split("=", 1)[0].strip()
                    if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", name):
                        continue
                    total += 1
                    by_kind["enum_member"]["total"] += 1
                    if UPPER.match(name):
                        compliant += 1
                        by_kind["enum_member"]["compliant"] += 1
                    else:
                        by_kind["enum_member"]["violations"] += 1
                        violations.append({"file": rel, "line": base_line + offset, "kind": "enum_member", "name": name, "expected": UPPER.pattern})
    for row in by_kind.values():
        row["compliance_rate"] = round(row["compliant"] / max(row["total"], 1) * 100, 4)
    return {
        "total": total, "compliant": compliant, "violations": len(violations),
        "by_kind": dict(sorted(by_kind.items())), "details": violations,
        "compliance_rate": round(compliant / max(total, 1) * 100, 4),
    }


def scan_whitelist(data: dict) -> dict:
    machine, numeric, scenes, third_party, _ = registry_sets(data)
    return {
        "total_entries": len(machine) + len(numeric) + len(scenes),
        "machine_export": len(machine), "numeric_directory": len(numeric), "numeric_scene": len(scenes),
        "third_party_prefixes": list(third_party),
        "review_records": data.get("review_records", []),
        "schema_version": data.get("schema_version"),
        "frozen": data.get("frozen"),
        "frozen_at": data.get("frozen_at"),
        "entries": {
            "machine_export": sorted(machine),
            "numeric_directory": sorted(numeric),
            "numeric_scene": sorted(scenes),
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Phase 11-1 全工程命名合规终审")
    parser.add_argument("--fail-on-error", action="store_true", help="存在违规时返回非零")
    args = parser.parse_args()
    if not PROJECT.is_dir():
        print(f"[FAIL] 工程目录不存在: {PROJECT}", file=sys.stderr)
        return 2
    data = load_registry()
    tables = {
        "directories": scan_dirs(data),
        "files": scan_files(data),
        "code": scan_code(data),
        "whitelist": scan_whitelist(data),
    }
    total_violations = sum(tables[key]["violations"] for key in ("directories", "files", "code"))
    report = {
        "metadata": {"generated_at": datetime.now().isoformat(timespec="seconds"), "project": PROJECT.relative_to(ROOT).as_posix(), "standard": "docs/standards/naming_standard.md"},
        "summary": {"total_violations": total_violations, "status": "PASS" if total_violations == 0 else "FAIL"},
        "tables": tables,
    }
    OUT_JSON.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    d, f, c, w = tables["directories"], tables["files"], tables["code"], tables["whitelist"]
    lines = [
        "# Phase 11-1 全工程命名合规终审",
        "",
        "> 机读报告：`docs/reports/naming_compliance_audit.json`",
        ">",
        "> 标准：`docs/standards/naming_standard.md` v2.1.0（Godot 官方 `snake_case` 文件命名）",
        ">",
        f"> 生成时间：{report['metadata']['generated_at']}",
        "",
        f"**总体状态：{report['summary']['status']}，违规总数：{total_violations}**",
        "",
        "## 表 1：目录命名",
        "",
        "| 指标 | 数量 |",
        "|:---|:---:|",
        f"| 检查目录 | {d['total']} |",
        f"| 合规 | {d['compliant']} |",
        f"| 白名单 | {d['whitelisted']} |",
        f"| 违规 | {d['violations']} |",
        f"| 白名单外合规率 | {d['compliance_rate']}% |",
        "",
        "| 分类 | 数量 |",
        "|:---|:---:|",
    ]
    lines += [f"| {key} | {value} |" for key, value in sorted(d["categories"].items())]
    lines += [
        "",
        "## 表 2：文件命名",
        "",
        "| 指标 | 数量 |",
        "|:---|:---:|",
        f"| 检查文件 | {f['total']} |",
        f"| 合规 | {f['compliant']} |",
        f"| 白名单 | {f['whitelisted']} |",
        f"| 违规 | {f['violations']} |",
        f"| 白名单外合规率 | {f['compliance_rate']}% |",
        "",
        "| 扩展名 | 总数 | 合规 | 白名单 | 违规 |",
        "|:---|:---:|:---:|:---:|:---:|",
    ]
    lines += [f"| {ext} | {row['total']} | {row['compliant']} | {row['whitelisted']} | {row['violations']} |" for ext, row in f["by_extension"].items()]
    lines += [
        "",
        "## 表 3：代码内命名",
        "",
        "| 指标 | 数量 |",
        "|:---|:---:|",
        f"| 检查声明 | {c['total']} |",
        f"| 合规 | {c['compliant']} |",
        f"| 违规 | {c['violations']} |",
        f"| 合规率 | {c['compliance_rate']}% |",
        "",
        "| 元素 | 总数 | 合规 | 违规 |",
        "|:---|:---:|:---:|:---:|",
    ]
    lines += [f"| {kind} | {row['total']} | {row['compliant']} | {row['violations']} |" for kind, row in c["by_kind"].items()]
    lines += [
        "",
        "## 表 4：白名单条目",
        "",
        "| 类别 | 数量 | 评审状态 |",
        "|:---|:---:|:---|",
        f"| 机器导出目录 | {w['machine_export']} | 已批准 |",
        f"| 数字 ID 目录 | {w['numeric_directory']} | 已批准 |",
        f"| 数字 ID 场景 | {w['numeric_scene']} | 已批准 |",
        f"| 第三方前缀 | {len(w['third_party_prefixes'])} | 已批准 |",
        f"| 白名单总数 | {w['total_entries']} | - |",
        "",
        f"白名单版本：`{w['schema_version']}`，冻结：`{w['frozen']}`，日期：`{w['frozen_at']}`。",
        "",
        "## 违规示例",
        "",
    ]
    samples = c["details"][:10] + f["details"][:20] + d["details"][:10]
    if samples:
        lines += ["```text"] + [str(item)[:240] for item in samples] + ["```"]
    else:
        lines += ["无。"]
    lines += [
        "",
        "## 结论",
        "",
        f"- 目录：{d['compliance_rate']}% 白名单外合规；",
        f"- 文件：{f['compliance_rate']}% 白名单外合规；",
        f"- 代码：{c['compliance_rate']}% 合规；",
        "- 本报告是 Godot 官方规则下的真实存量基线；Phase 11-1 验收状态为 "
        + ("**PASS**" if total_violations == 0 else "**FAIL（存量债务待治理）**") + "。",
        f"- 白名单冻结：schema_version={w['schema_version']}，frozen={w['frozen']}，"
        f"条目 {w['total_entries']}。",
    ]
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print("\n".join(lines))
    if total_violations and args.fail_on_error:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

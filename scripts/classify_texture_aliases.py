#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""只读分类 6.8 纹理别名表。

输出：
- docs/reports/texture_alias_classification.json
- docs/reports/texture_alias_classification.md

本脚本不修改 `duplicate_texture_aliases.gd`、不删除素材、不改变运行时；
删除与入口收敛必须由后续批次执行。
"""
from __future__ import annotations

import argparse
import ast
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
ALIASES_PATH = SOURCE / "Script/monster/duplicate_texture_aliases.gd"
ART_ROOT = SOURCE / "Art"
REGISTRY_PATH = ROOT / "docs/standards/missing_assets_registry.md"
REPORT_DIR = ROOT / "docs/reports"

CODE_ROOTS = (
    SOURCE / "Script",
    SOURCE / "Scene",
)
CODE_SINGLE_FILES = (
    SOURCE / "global.gd",
    SOURCE / "project.godot",
)
TEXT_SUFFIXES = {".gd", ".tscn", ".tres", ".json", ".cfg", ".godot"}

LITERAL_RE = re.compile(r'"((?:[^"\\]|\\.)*)"|\'((?:[^\'\\]|\\.)*)\'')


def trim_slash(path: str) -> str:
    return path.strip().strip("/")


def parse_aliases() -> dict[str, str]:
    text = ALIASES_PATH.read_text(encoding="utf-8")
    match = re.search(r"const ALIASES:\s*Dictionary\s*=\s*(\{)", text)
    if match is None:
        raise ValueError(f"未找到 ALIASES: {ALIASES_PATH}")
    start = match.start(1)
    depth = 0
    quote = ""
    for index in range(start, len(text)):
        char = text[index]
        if quote:
            if char == "\\":
                continue
            if char == quote:
                quote = ""
            continue
        if char in "\"'":
            quote = char
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                block = text[start : index + 1]
                break
    else:
        raise ValueError("ALIASES 字典未闭合")
    parsed = ast.literal_eval(block)
    if not isinstance(parsed, dict):
        raise ValueError("ALIASES 不是字典")
    result: dict[str, str] = {}
    for key, value in parsed.items():
        result[trim_slash(str(key))] = trim_slash(str(value))
    return result


def collect_art_files() -> set[str]:
    if not ART_ROOT.is_dir():
        raise FileNotFoundError(f"素材目录不存在: {ART_ROOT}")
    return {
        "Art/" + path.relative_to(ART_ROOT).as_posix()
        for path in ART_ROOT.rglob("*")
        if path.is_file()
    }


def iter_text_files(roots: tuple[Path, ...], single_files: tuple[Path, ...]) -> list[Path]:
    files: list[Path] = []
    for root in roots:
        if not root.is_dir():
            continue
        for path in root.rglob("*"):
            if path.is_file() and path.suffix.lower() in TEXT_SUFFIXES:
                files.append(path)
    for path in single_files:
        if path.is_file():
            files.append(path)
    return files


def collect_literals() -> tuple[set[str], set[str]]:
    code_literals: set[str] = set()
    asset_literals: set[str] = set()
    code_files = iter_text_files(CODE_ROOTS, CODE_SINGLE_FILES)
    for path in code_files:
        if path == ALIASES_PATH:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in LITERAL_RE.finditer(text):
            value = match.group(1) if match.group(1) is not None else match.group(2)
            if value:
                code_literals.add(value)
    for path in ART_ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in {".json", ".tres"}:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in LITERAL_RE.finditer(text):
            value = match.group(1) if match.group(1) is not None else match.group(2)
            if value:
                asset_literals.add(value)
    return code_literals, asset_literals


def reference_variants(path: str) -> tuple[str, ...]:
    return (
        path,
        "res://" + path,
        path.removeprefix("Art/"),
        "res://" + path.removeprefix("Art/"),
    )


def classify(
    aliases: dict[str, str],
    files: set[str],
    code_literals: set[str],
    asset_literals: set[str],
    registry_text: str,
) -> dict[str, object]:
    lower_files = {path.lower(): path for path in files}
    counts: Counter[str] = Counter()
    domains: dict[str, Counter[str]] = defaultdict(Counter)
    entries: list[dict[str, object]] = []
    case_fixes: list[dict[str, str]] = []
    review_weak: list[dict[str, object]] = []
    review_strong: list[dict[str, object]] = []
    asset_references: list[dict[str, object]] = []

    for key, target in sorted(aliases.items()):
        key_exists = key in files
        target_exists = target in files
        target_ci = lower_files.get(target.lower(), "")
        basename = key.rsplit("/", 1)[-1]
        parent = key.rsplit("/", 1)[0] if "/" in key else ""
        strong_code = any(variant in code_literals for variant in reference_variants(key))
        weak_code = basename in code_literals
        parent_code = bool(parent) and any(
            variant in code_literals for variant in reference_variants(parent)
        )
        strong_asset = any(variant in asset_literals for variant in reference_variants(key))
        parent_asset = bool(parent) and any(
            variant in asset_literals for variant in reference_variants(parent)
        )
        registry_listed = key in registry_text or target in registry_text
        if target_exists:
            category = "keep_valid"
        elif target_ci:
            category = "keep_fix_case"
            case_fixes.append({"key": key, "target": target, "actual": target_ci})
        elif key_exists:
            category = "drop_alias_keep_key"
        elif strong_code:
            category = "recoverable_code_reference"
        elif strong_asset:
            category = "review_asset_reference"
        elif registry_listed:
            category = "recoverable_registry"
        elif weak_code:
            category = "review_weak_reference"
        else:
            category = "delete_obsolete"
        counts[category] += 1
        domains["/".join(key.split("/")[:2])][category] += 1
        entry = {
            "key": key,
            "target": target,
            "key_exists": key_exists,
            "target_exists": target_exists,
            "target_case_match": target_ci,
            "strong_code_reference": strong_code,
            "weak_code_reference": weak_code,
            "parent_code_reference": parent_code,
            "strong_asset_reference": strong_asset,
            "parent_asset_reference": parent_asset,
            "registry_listed": registry_listed,
            "weak_is_generic": category == "review_weak_reference" and not parent_code and not parent_asset,
            "category": category,
        }
        entries.append(entry)
        if category == "review_weak_reference":
            review_weak.append(entry)
        elif category in ("recoverable_code_reference", "review_asset_reference", "recoverable_registry"):
            review_strong.append(entry)
        if strong_asset:
            asset_references.append(entry)

    keep_count = counts.get("keep_valid", 0) + counts.get("keep_fix_case", 0) + counts.get(
        "drop_alias_keep_key", 0
    )
    generic_weak_count = sum(1 for entry in review_weak if entry.get("weak_is_generic"))
    recoverable_count = sum(
        counts.get(category, 0)
        for category in ("recoverable_code_reference", "review_asset_reference", "recoverable_registry")
    ) + sum(1 for entry in review_weak if not entry.get("weak_is_generic"))
    delete_count = counts.get("delete_obsolete", 0) + generic_weak_count

    return {
        "total": len(aliases),
        "artifact_files": len(files),
        "counts": dict(sorted(counts.items())),
        "domains": {domain: dict(sorted(counter.items())) for domain, counter in sorted(domains.items())},
        "entries": entries,
        "case_fixes": case_fixes,
        "review_weak": review_weak,
        "review_strong": review_strong,
        "asset_references": asset_references,
        "final_decisions": {
            "keep": keep_count,
            "delete": delete_count,
            "recoverable": recoverable_count,
            "generic_weak_deleted": generic_weak_count,
        },
    }


def render_markdown(result: dict[str, object]) -> str:
    counts = result["counts"]
    assert isinstance(counts, dict)
    lines = [
        "# 纹理别名分类报告",
        "",
        f"- 数据源：`{ALIASES_PATH.relative_to(ROOT).as_posix()}`",
        f"- 别名总数：**{result['total']}**",
        f"- 素材文件数：**{result['artifact_files']}**",
        "",
        "## 分类汇总",
        "",
        "| 分类 | 数量 | 裁定 |",
        "|:---|:---:|:---|",
    ]
    decisions = {
        "keep_valid": "保留；目标文件存在",
        "keep_fix_case": "保留并修正目标大小写；目标仅大小写不一致",
        "drop_alias_keep_key": "删除别名；键路径本身存在",
        "recoverable_code_reference": "待恢复；代码仍引用但键/目标均缺失",
        "review_asset_reference": "待复核；资源文本引用但键/目标均缺失",
        "recoverable_registry": "待恢复；缺失台账已登记",
        "review_weak_reference": "待复核；仅基名命中，通常是通用文件名",
        "delete_obsolete": "删除；键/目标均缺失且无引用",
    }
    for category, count in counts.items():
        lines.append(f"| `{category}` | {count} | {decisions.get(category, '')} |")
    final = result["final_decisions"]
    assert isinstance(final, dict)
    lines.extend(
        [
            "",
            "## 最终裁定（建议，未执行）",
            "",
            "| 动作 | 数量 | 依据 |",
            "|:---|:---:|:---|",
            f"| 保留 | {final['keep']} | 目标存在；1 条需修正目标大小写 |",
            f"| 删除 | {final['delete']} | 键/目标均缺失；15 条仅命中 `preview.png` / `1.png` / `parts.png` 等通用基名，父目录无引用 |",
            f"| 待恢复 | {final['recoverable']} | 代码/台账/资源文本仍有引用 |",
            "",
            "删除与入口收敛本轮未执行；等待确认后另开批次。",
        ]
    )
    lines.extend(["", "## 按域分布", "", "| 域 | 分类 | 数量 |", "|:---|:---|:---:|"])
    for domain, counter in result["domains"].items():
        assert isinstance(counter, dict)
        for category, count in counter.items():
            lines.append(f"| `{domain}` | `{category}` | {count} |")
    lines.extend(["", "## 大小写修正候选", ""])
    if result["case_fixes"]:
        lines.extend(["| 键 | 目标（原） | 目标（实际） |", "|:---|:---|:---|"])
        for item in result["case_fixes"]:
            lines.append(f"| `{item['key']}` | `{item['target']}` | `{item['actual']}` |")
    else:
        lines.append("无。")
    lines.extend(["", "## 弱引用待复核（仅基名命中）", ""])
    if result["review_weak"]:
        lines.extend(
            [
                "| 键 | 目标 | 命中基名 | 父目录代码引用 | 父目录资源引用 |",
                "|:---|:---|:---|:---:|:---:|",
            ]
        )
        for item in result["review_weak"]:
            lines.append(
                f"| `{item['key']}` | `{item['target']}` | `{item['key'].rsplit('/', 1)[-1]}` | "
                f"{'是' if item['parent_code_reference'] else '否'} | "
                f"{'是' if item['parent_asset_reference'] else '否'} |"
            )
    else:
        lines.append("无。")
    lines.extend(["", "## 强引用/台账/资源文本待复核", ""])
    if result["review_strong"]:
        lines.extend(["| 键 | 目标 | 分类 |", "|:---|:---|:---|"])
        for item in result["review_strong"]:
            lines.append(f"| `{item['key']}` | `{item['target']}` | `{item['category']}` |")
    else:
        lines.append("无。")
    lines.extend(
        [
            "",
            "## 说明",
            "",
            "- 代码引用扫描范围：`source/Script/**`、`source/Scene/**`、`source/global.gd`、`source/project.godot`，排除别名表自身。",
            "- 资源文本扫描范围：`source/Art/**/*.json` 与 `*.tres`；仅作复核证据，资源文本不会经过 `TEXTURE_ALIASES.resolve`。",
            "- 本报告只做分类；未删除条目、未修改运行时、未执行入口收敛。",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="只读分类 6.8 纹理别名表")
    parser.add_argument("--out-dir", default=str(REPORT_DIR), help="报告输出目录")
    parser.add_argument("--check", action="store_true", help="只校验每条别名目标存在，不生成报告")
    args = parser.parse_args()
    aliases = parse_aliases()
    files = collect_art_files()
    if args.check:
        missing = [(key, target) for key, target in aliases.items() if target not in files]
        if missing:
            print(f"[FAIL] 别名目标缺失 {len(missing)}/{len(aliases)} 条:", file=sys.stderr)
            for key, target in missing[:20]:
                print(f"    {key} -> {target}", file=sys.stderr)
            return 1
        print(f"[OK] 纹理别名目标存在校验通过: {len(aliases)} 条全部可达")
        return 0
    code_literals, asset_literals = collect_literals()
    registry_text = REGISTRY_PATH.read_text(encoding="utf-8", errors="ignore") if REGISTRY_PATH.is_file() else ""
    result = classify(aliases, files, code_literals, asset_literals, registry_text)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    json_path = out_dir / "texture_alias_classification.json"
    md_path = out_dir / "texture_alias_classification.md"
    json_path.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n"
    )
    md_path.write_text(render_markdown(result), encoding="utf-8", newline="\n")
    print(f"[OK] 别名分类完成: {result['total']} 条")
    for category, count in result["counts"].items():
        print(f"    {category}: {count}")
    print(f"[OK] 报告: {json_path.relative_to(ROOT)}")
    print(f"[OK] 报告: {md_path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Build the ZMWS asset-library inventory and integration matrix.

The asset files live in the private BHYH-assets-private repository. This script
reads them through an explicit --assets-root / BHYH_ASSETS_ROOT argument and
never writes to the asset repository. It writes only BHYH documentation/report
outputs.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
DEFAULT_ASSETS = ROOT.parent / "BHYH-assets-private"
POLICY_PATH = ROOT / "scripts" / "asset_library_policy.json"
MATRIX_PATH = ROOT / "docs" / "reference" / "zmws_asset_integration_matrix.md"
INVENTORY_PATH = ROOT / "docs" / "reports" / "zmws_asset_inventory.json"


def rel(path: Path, base: Path) -> str:
    try:
        return path.relative_to(base).as_posix()
    except ValueError:
        return path.name


def files(root: Path, pattern: str) -> list[Path]:
    if not root.is_dir():
        return []
    return sorted(p for p in root.rglob(pattern) if p.is_file())


def count_ext(root: Path, patterns: set[str]) -> int:
    if not root.is_dir():
        return 0
    return sum(1 for p in root.rglob("*") if p.is_file() and p.suffix.lower() in patterns)


def _scan_effect_assets(root: Path, png_root: Path) -> tuple[list[Path], int]:
    """Reuse the DragonBones effect walk only for PNGs nested in its static group."""
    if not root.is_dir():
        return [], 0
    db_factories: list[Path] = []
    png_count = 0
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.match("*.dbfactory"):
            db_factories.append(path)
        if path.is_relative_to(png_root) and path.suffix.lower() == ".png":
            png_count += 1
    db_factories.sort()
    return db_factories, png_count


def append_status_table(lines: list[str], title: str,
                        legend: dict[str, str], used: set[str]) -> None:
    lines += [
        f"### {title}",
        "",
        "| 值 | 中文说明 | 当前使用 |",
        "|:---|:---|:---|",
    ]
    for value, description in legend.items():
        mark = "是" if value in used else "否（保留值）"
        lines.append(f"| `{value}` | {description} | {mark} |")
    lines.append("")


def main() -> int:
    parser = argparse.ArgumentParser(description="Build the ZMWS asset library matrix.")
    parser.add_argument("--assets-root", default=os.environ.get("BHYH_ASSETS_ROOT"),
                        help="Path to BHYH-assets-private (or set BHYH_ASSETS_ROOT)")
    parser.add_argument("--policy", type=Path, default=POLICY_PATH)
    parser.add_argument("--matrix", type=Path, default=MATRIX_PATH)
    parser.add_argument("--inventory", type=Path, default=INVENTORY_PATH)
    parser.add_argument("--check", action="store_true", help="Fail if either generated artifact is missing or stale")
    args = parser.parse_args()

    assets = Path(args.assets_root).expanduser().resolve() if args.assets_root else DEFAULT_ASSETS
    if not assets.is_dir():
        print(f"SKIP: asset root not found: {assets}")
        return 0

    policy = json.loads(args.policy.read_text(encoding="utf-8"))
    domains = policy.get("domains", {})
    rows = []
    inventory_assets = []

    # DragonBones: one row per factory.
    db_roots = {
        "monster": assets / "Art/monster",
        "bullet": assets / "Art/bullet",
        "effect": assets / "Art/effect",
        "magic_weapon": assets / "Art/magic_weapon",
        "activity": assets / "Art/activity",
        "hunt": assets / "Art/hunt",
        "ui_effect": assets / "Art/ui_effect",
        "ws_effect": assets / "Art/ws_effect",
    }
    effect_db_factories, effect_png_count = _scan_effect_assets(
        db_roots["effect"], assets / "Art/effect/all_effects"
    )
    db_count = 0
    for group, root in db_roots.items():
        group_files = effect_db_factories if group == "effect" else files(root, "*.dbfactory")
        for p in group_files:
            inventory_assets.append({
                "asset_id": f"zmws_dragonbones/{rel(p, assets).removesuffix('.dbfactory')}",
                "domain": "dragonbones",
                "group": group,
                "kind": "dragonbones",
                "source_path": rel(p, assets),
                "status": "imported_unbound",
                "consumer_status": "unbound",
            })
            db_count += 1
    rows.append(("dragonbones", db_count, domains.get("dragonbones", {})))
    # Maps are imported Godot scenes in the public project.
    maps = files(SOURCE / "Scene/level/zmws", "*.tscn")
    for p in maps:
        inventory_assets.append({
            "asset_id": f"zmws_map/{p.stem}",
            "domain": "maps",
            "kind": "map_scene",
            "source_path": rel(p, SOURCE),
            "status": "imported_unbound",
            "consumer_status": "previewable_not_gameplay_complete",
        })
    rows.append(("maps", len(maps), domains.get("maps", {})))

    # Spine library: imported into the private repo, no new consumer.
    spine_root = assets / "Art/zmws_spine"
    spine_dirs = sorted(p for p in spine_root.iterdir() if p.is_dir()) if spine_root.is_dir() else []
    for p in spine_dirs:
        inventory_assets.append({
            "asset_id": f"zmws_spine/{p.name}",
            "domain": "spine",
            "kind": "spine",
            "source_path": rel(p, assets),
            "status": "imported_unbound",
            "consumer_status": "unbound",
        })
    rows.append(("spine", len(spine_dirs), domains.get("spine", {})))

    # Existing BHYH-owned Spine assets are bound, not part of the ZMWS set.
    existing_spine = [
        p for p in files(SOURCE / "Art", "*.spine-json")
        if "zmws_spine" not in p.parts
    ]
    for p in existing_spine:
        inventory_assets.append({
            "asset_id": f"bhyh_spine/{rel(p, SOURCE).removesuffix('.spine-json')}",
            "domain": "bhyh.spine",
            "kind": "spine",
            "source_path": rel(p, SOURCE),
            "status": "bound",
            "consumer_status": "wired",
        })
    rows.append(("bhyh.spine", len(existing_spine), {"consumer": "Existing BHYH SpineSprite effects", "consumer_status": "wired", "asset_status": "bound"}))

    # Static groups are summarized by domain; their individual PNG/mp3 rows are not
    # duplicated in the matrix because their consumers are generic loaders.
    static = [
        ("backpack.all_items", assets / "Art/backpack/all_items", {".png"}, "Texture2D / load_item_icon"),
        ("skill.all_skills", assets / "Art/skill/all_skills", {".png"}, "Texture2D / load()"),
        ("effect.all_effects", assets / "Art/effect/all_effects", {".png"}, "Texture2D / load()"),
        ("ui.module_res", assets / "Art/ui/module_res", {".png"}, "Texture2D / load()"),
        ("level.mapbase", assets / "Art/level/zmws/mapbase", {".png"}, "Sprite2D / Parallax2D"),
        ("audio.sfx", assets / "Music/zmws/sfx", {".mp3", ".ogg", ".wav"}, "AudioStreamPlayer"),
        ("font.ttf", assets / "Font/zmws", {".ttf"}, "FontFile"),
        ("config", assets / "Data/zmws_config", {".json"}, "ZmwsConfig"),
    ]
    ui_total = 0
    for key, root, exts, consumer in static:
        n = effect_png_count if key == "effect.all_effects" else count_ext(root, exts)
        inventory_assets.append({
            "asset_id": f"zmws_static/{key}",
            "domain": key,
            "kind": "static_group",
            "source_path": rel(root, assets),
            "status": "imported_unbound",
            "consumer_status": "unbound",
            "file_count": n,
        })
        if key.startswith(("backpack.", "skill.", "effect.", "ui.")):
            ui_total += n
        rows.append((key, n, {"consumer": consumer, "consumer_status": "available_not_bound", "asset_status": "imported_unbound"}))
    rows.append(("ui_audio_font", ui_total, domains.get("ui_audio_font", {})))

    deduped = []
    seen = set()
    for key, count, meta in rows:
        if key in seen:
            continue
        seen.add(key)
        deduped.append((key, count, meta))

    legend = policy.get("status_legend", {})
    asset_used = {meta.get("asset_status", "imported_unbound") for _, _, meta in deduped}
    asset_used.add("excluded")
    consumer_used = {meta.get("consumer_status", "available_not_bound") for _, _, meta in deduped}
    consumer_used.add("excluded")
    slice_info = policy.get("vertical_slice", {})
    other_used = {slice_info.get("status", "")}
    other_used.update(item.get("status", "") for item in policy.get("quarantined", []))

    generated = args.matrix.read_text(encoding="utf-8") if args.matrix.is_file() else None
    lines = [
        "# ZMWS Asset Integration Matrix",
        "",
        "> 由 `scripts/asset_library_catalog.py` 生成；状态决策来自 `scripts/asset_library_policy.json`。",
        "> 本文不表示玩法接入；资产仍只在 `BHYH-assets-private` 中。",
        "",
        "## 生命周期",
        "",
        "```text",
        "source -> imported -> cataloged -> previewable -> selected -> wired -> gameplay_verified",
        "```",
        "",
        "生命周期小结：",
        "",
    ]
    for stage, description in legend.get("lifecycle", {}).items():
        lines.append(f"- `{stage}`：{description}")
    lines += [
        "",
        "> 生命周期是概念顺序，不是自动状态机；当前矩阵只在域矩阵中使用其中若干状态，"
        "`gameplay_verified` 必须有实际关卡/玩法验证证据，不能由导入或预览推断。",
        "",
        "## 状态说明",
        "",
        "资产状态描述资产自身所处阶段；消费状态描述是否存在可追踪的消费路径与绑定。"
        "两列相互独立，不能把“有加载器”或“已导入”解读为已接入。",
        "",
    ]
    append_status_table(lines, "资产状态", legend.get("asset_status", {}), asset_used)
    append_status_table(lines, "消费状态", legend.get("consumer_status", {}), consumer_used)
    append_status_table(lines, "其他状态", legend.get("other_status", {}), other_used)
    lines += [
        "> `imported_unbound` 表示资产停在导入阶段；`available_not_bound` 表示消费通道存在但尚未选定并绑定具体资产。"
        "两者同时出现仍不构成接入。",
        "",
        "> 资产状态 `bound` 与消费状态 `wired` 可以同时出现：前者表示资产已选定并挂接，"
        "后者表示引用路径成立；二者都不等于 `gameplay_verified`。",
        "",
        "## 域矩阵",
        "",
        "| 域 | 数量 | 现有消费方 | 资产状态 | 消费状态 | 下一步 |",
        "|:---|---:|:---|:---|:---|:---|",
    ]
    for key, count, meta in deduped:
        consumer = meta.get("consumer", "none")
        next_step = meta.get("next", "")
        asset_status = meta.get("asset_status", "imported_unbound")
        consumer_status = meta.get("consumer_status", "available_not_bound")
        lines.append(f"| `{key}` | {count} | {consumer} | `{asset_status}` | `{consumer_status}` | {next_step} |")
    lines += [
        "| `prefab_scripts` | 0 | none | `excluded` | `excluded` | 不导入 |",
        "",
        "## 垂直切片",
        "",
    ]
    lines += [
        f"- 域：`{slice_info.get('domain', '')}`",
        f"- 场景：`{slice_info.get('scene', '')}`",
        f"- 状态：`{slice_info.get('status', '')}`",
        f"- 范围：{slice_info.get('scope', '')}",
        "",
        "## 隔离项",
        "",
    ]
    for item in policy.get("quarantined", []):
        lines.append(f"- `{item.get('name')}`：`{item.get('status')}`；{item.get('reason')}")
    lines += [
        "",
        "## 边界",
        "",
        "- 逐项资产清单见 `docs/reports/zmws_asset_inventory.json`（生成物，按报告规则处理）。",
        "- `imported_unbound` 不等于已接入；只有场景/脚本引用并通过关卡验证后才提升到 `gameplay_verified`。",
        "- 资产库不复制第二份素材；BHYH 的 `source/Art` 通过 junction 读取私有素材仓。",
        "",
    ]
    matrix = "\n".join(lines)

    inventory = json.dumps({
        "schema_version": 1,
        "source_root": ".",  # relative to BHYH-assets-private, never an absolute path
        "status_default": "imported_unbound",
        "quarantined": policy.get("quarantined", []),
        "domains": [{"domain": key, "count": count, **meta} for key, count, meta in deduped],
        "assets": inventory_assets,
    }, ensure_ascii=False, indent=2)

    if args.check:
        stale = []
        if generated is None:
            stale.append(f"MISSING: {args.matrix}")
        elif generated != matrix:
            stale.append(f"STALE: {args.matrix}")
        inventory_generated = args.inventory.read_text(encoding="utf-8") if args.inventory.is_file() else None
        if inventory_generated is None:
            stale.append(f"MISSING: {args.inventory}")
        elif inventory_generated != inventory:
            stale.append(f"STALE: {args.inventory}")
        if stale:
            for item in stale:
                print(item)
            return 1
        print("OK: asset integration matrix and inventory are current")
        return 0

    args.matrix.parent.mkdir(parents=True, exist_ok=True)
    args.matrix.write_text(matrix, encoding="utf-8", newline="\n")
    args.inventory.parent.mkdir(parents=True, exist_ok=True)
    args.inventory.write_text(inventory, encoding="utf-8", newline="\n")
    print(f"WROTE {args.matrix}")
    print(f"WROTE {args.inventory}")
    print(f"assets={len(inventory_assets)} domains={len(deduped)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

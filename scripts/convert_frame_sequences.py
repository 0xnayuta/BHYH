#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把固定 PNG / 图集帧序列转换为构建期 FrameSequence 资源与 Catalog。

运行时通过 FrameSequenceStore 读取，不扫描目录、不猜测编号文件。
当前登记：四剑台背景、星座治疗 aura、混沌、饕餮、流沙河、五台 3077
固定序列，四剑阵 AtlasMetadata 技能序列，以及星座动态 body/技能与
五台弹道非 swf 序列。
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
OUTPUT_ROOT = SOURCE / "Art/frame_sequences"
CATALOG_PATH = OUTPUT_ROOT / "frame_sequence_catalog.tres"

PROFILES: tuple[dict[str, object], ...] = (
    {
        "root": "res://Art/level/game_3_level/level_tzsijian/level_96/bg961_parts",
        "variants": ((30.0, True, False),),
    },
    {
        "root": "res://Art/constellations/common/aura_green",
        "include_root": True,
        "variants": ((24.0, True, False),),
    },
    {
        "root": "res://Art/monster/hun_dun/effects",
        "variants": ((24.0, False, False), (24.0, True, False)),
    },
    {
        "root": "res://Art/monster/tao_tie/effects",
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/liu_sha_river/original_effects/role_1",
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/liu_sha_river/original_effects/role_2",
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/liu_sha_river/original_effects/monster_172",
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/swf_png/3077",
        "exclude": {"atlas", "pages"},
        "variants": ((30.0, False, False), (30.0, True, False)),
    },
    {
        "root": "res://Art/monster/game_4_special_effect",
        "recursive": True,
        "variants": (
            (24.0, False, False),
            (24.0, True, False),
            (24.0, False, True),
            (24.0, True, True),
            (30.0, False, False),
            (30.0, True, False),
            (30.0, False, True),
            (30.0, True, True),
        ),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_169/hit2",
        "include_root": True,
        "variants": (
            (24.0, False, False),
            (24.0, True, False),
            (24.0, False, True),
            (24.0, True, True),
            (30.0, False, False),
            (30.0, True, False),
            (30.0, False, True),
            (30.0, True, True),
        ),
    },
)

SWORD_ROOT = "res://Art/monster/game_3_monster/sword_boss"
SWORD_SETS = ("zhuxian", "xianxian", "luxian", "juexian")
SWORD_SKILL_ANIMATIONS = ("hit1", "hit2", "hit3")
SWORD_MAX_FRAMES = 36
SWORD_FPS = 24.0


@dataclass
class SequenceSpec:
    key: str
    paths: list[str]
    fps: float
    loop: bool
    hold: bool
    regions: list[tuple[float, float, float, float]] = field(default_factory=list)
    margins: list[tuple[float, float, float, float]] = field(default_factory=list)


def natural_key(path: Path) -> tuple:
    name = path.name
    parts: list[tuple[int, object]] = []
    digits = ""
    for char in name:
        if char.isdigit():
            digits += char
        else:
            if digits:
                parts.append((0, int(digits)))
                digits = ""
            parts.append((1, char.lower()))
    if digits:
        parts.append((0, int(digits)))
    return tuple(parts)


def source_path(resource_path: str) -> Path:
    if not resource_path.startswith("res://"):
        raise ValueError(f"路径必须是 res:// 形式: {resource_path}")
    return SOURCE / resource_path.removeprefix("res://")


def key_for(directory: str, fps: float, loop: bool, hold: bool, prefetch: int = 2) -> str:
    return "%s|%.1f|%s|%s|%d" % (directory, fps, str(loop).lower(), str(hold).lower(), prefetch)


def escape_string(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def sequence_content(spec: SequenceSpec) -> str:
    lines = [
        '[gd_resource type="Resource" script_class="FrameSequence" load_steps=2 format=3]',
        "",
        '[ext_resource type="Script" path="res://Script/data/frame_sequence.gd" id="1_sequence"]',
        "",
        "[resource]",
        'script = ExtResource("1_sequence")',
        "frame_paths = PackedStringArray(%s)" % ", ".join('"' + escape_string(path) + '"' for path in spec.paths),
    ]
    if spec.regions:
        lines.append(
            "frame_regions = [%s]"
            % ", ".join(
                "Rect2(%s, %s, %s, %s)" % tuple(str(value) for value in region) for region in spec.regions
            )
        )
    else:
        lines.append("frame_regions = []")
    if spec.margins:
        lines.append(
            "frame_margins = [%s]"
            % ", ".join(
                "Rect2(%s, %s, %s, %s)" % tuple(str(value) for value in margin) for margin in spec.margins
            )
        )
    else:
        lines.append("frame_margins = []")
    lines.extend(
        [
            "frame_has_visual = []",
            "fps = %.1f" % spec.fps,
            "loop = %s" % ("true" if spec.loop else "false"),
            "hold_last_frame = %s" % ("true" if spec.hold else "false"),
            "prefetch_frames = 2",
            "",
        ]
    )
    return "\n".join(lines)


def catalog_content(specs: list[tuple[str, str]]) -> str:
    lines = [
        '[gd_resource type="Resource" script_class="FrameSequenceCatalog" load_steps=%d format=3]' % (len(specs) + 2),
        "",
        '[ext_resource type="Script" path="res://Script/data/frame_sequence_catalog.gd" id="1_catalog"]',
    ]
    for index, (_key, resource_path) in enumerate(specs, 2):
        lines.append(f'[ext_resource type="Resource" path="{resource_path}" id="{index}"]')
    lines.extend(["", "[resource]", 'script = ExtResource("1_catalog")', "sequences = {"])
    for index, (key, _resource_path) in enumerate(specs, 2):
        lines.append('\t&"%s": ExtResource("%d"),' % (escape_string(key), index))
    lines.extend(["}", ""])
    return "\n".join(lines)


def collect_directories(profile: dict[str, object]) -> list[Path]:
    root = source_path(str(profile["root"]))
    if not root.is_dir():
        raise FileNotFoundError(f"缺少帧目录: {root.relative_to(ROOT)}")
    excluded = set(profile.get("exclude", set()))
    directories: list[Path] = []
    if bool(profile.get("include_root", False)):
        directories.append(root)
    if bool(profile.get("recursive", False)):
        directories.extend(
            path for path in sorted(root.rglob("*"), key=natural_key) if path.is_dir() and path.name not in excluded
        )
    elif not bool(profile.get("include_root", False)):
        directories.extend(
            path for path in sorted(root.iterdir(), key=natural_key) if path.is_dir() and path.name not in excluded
        )
    return directories


def collect_frames(directory: Path) -> list[str]:
    files = sorted(
        (path for path in directory.iterdir() if path.is_file() and path.suffix.lower() == ".png"),
        key=natural_key,
    )
    return ["res://" + path.relative_to(SOURCE).as_posix() for path in files]


def collect_directory_specs() -> list[SequenceSpec]:
    specs: list[SequenceSpec] = []
    seen: set[str] = set()
    for profile in PROFILES:
        for directory in collect_directories(profile):
            paths = collect_frames(directory)
            if not paths:
                continue
            directory_res = "res://" + directory.relative_to(SOURCE).as_posix()
            for fps, loop, hold in profile["variants"]:
                key = key_for(directory_res, float(fps), bool(loop), bool(hold))
                if key in seen:
                    raise ValueError(f"重复帧序列键: {key}")
                seen.add(key)
                specs.append(SequenceSpec(key, paths, float(fps), bool(loop), bool(hold)))
    return specs


def collect_sword_specs() -> list[SequenceSpec]:
    specs: list[SequenceSpec] = []
    for set_name in SWORD_SETS:
        root = f"{SWORD_ROOT}/{set_name}"
        manifest_path = source_path(root) / "atlas" / "manifest.json"
        if not manifest_path.is_file():
            raise FileNotFoundError(f"缺少剑阵 Atlas manifest: {manifest_path.relative_to(ROOT)}")
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        pages: list = manifest.get("pages", [])
        animations: dict = manifest.get("animations", {})
        for animation_name in SWORD_SKILL_ANIMATIONS:
            entries = animations.get(animation_name, [])
            if not entries:
                raise ValueError(f"剑阵 manifest 缺少动画: {root}/{animation_name}")
            if len(entries) > SWORD_MAX_FRAMES:
                sampled = []
                for index in range(SWORD_MAX_FRAMES):
                    source_index = round(float(index) * float(len(entries) - 1) / float(SWORD_MAX_FRAMES - 1))
                    sampled.append(entries[int(source_index)])
                entries = sampled
            paths: list[str] = []
            regions: list[tuple[float, float, float, float]] = []
            for entry in entries:
                page_index = int(entry.get("page", -1))
                region = entry.get("region", [])
                if page_index < 0 or page_index >= len(pages) or len(region) != 4:
                    raise ValueError(f"剑阵条目无效: {root}/{animation_name}")
                paths.append(root + "/atlas/" + str(pages[page_index]))
                regions.append(tuple(float(value) for value in region))
            key = key_for(f"sword/{set_name}/{animation_name}", SWORD_FPS, False, False)
            specs.append(SequenceSpec(key, paths, SWORD_FPS, False, False, regions))
    return specs




def extract_gdscript_const(source: str, name: str) -> object:
    marker = f"const {name} := "
    start = source.index(marker) + len(marker)
    if source[start] != "{":
        raise ValueError(f"{name} 不是字典常量")
    depth = 0
    end = start
    for end in range(start, len(source)):
        if source[end] == "{":
            depth += 1
        elif source[end] == "}":
            depth -= 1
            if depth == 0:
                break
    block = source[start : end + 1].replace('&"', '"')
    block = re.sub(r"#.*", "", block)
    return ast.literal_eval(block)


def parse_sprite_frames(path: Path) -> dict[str, list[tuple[str, list[float], list[float]]]]:
    text = path.read_text(encoding="utf-8")
    ext = {}
    for match in re.finditer(r'\[ext_resource type="Texture2D" path="([^"]+)" id="([^"]+)"\]', text):
        ext[match.group(2)] = match.group(1)
    subs: dict[str, tuple[str, list[float], list[float]]] = {}
    for match in re.finditer(
        r'\[sub_resource type="AtlasTexture" id="([^"]+)"\]\n(.*?)(?=\n\[|\Z)', text, re.S
    ):
        body = match.group(2)
        atlas = re.search(r'atlas = ExtResource\("([^"]+)"\)', body)
        region = re.search(r'region = Rect2\(([^)]*)\)', body)
        margin = re.search(r'margin = Rect2\(([^)]*)\)', body)
        subs[match.group(1)] = (
            ext.get(atlas.group(1), "") if atlas else "",
            [float(value) for value in region.group(1).split(",")] if region else [],
            [float(value) for value in margin.group(1).split(",")] if margin else [],
        )
    start = text.index("animations = [") + len("animations = ")
    depth = 0
    end = start
    for end in range(start, len(text)):
        if text[end] == "[":
            depth += 1
        elif text[end] == "]":
            depth -= 1
            if depth == 0:
                break
    payload = text[start : end + 1].replace('&"', '"')
    payload = re.sub(r'SubResource\("([^"]+)"\)', r'{"sub":"\1"}', payload)
    payload = re.sub(r'ExtResource\("([^"]+)"\)', r'{"ext":"\1"}', payload)
    animations = json.loads(payload)
    result: dict[str, list[tuple[str, list[float], list[float]]]] = {}
    for animation in animations:
        frames = []
        for frame in animation.get("frames", []):
            texture = frame.get("texture", {})
            if "sub" in texture:
                frames.append(subs[texture["sub"]])
            elif "ext" in texture:
                page = ext.get(texture["ext"], "")
                frames.append((page, [], []))
        result[str(animation.get("name", ""))] = frames
    return result


def collect_constellation_specs() -> list[SequenceSpec]:
    source = (SOURCE / "Script/monster/constellation_boss.gd").read_text(encoding="utf-8")
    counts = extract_gdscript_const(source, "BODY_ACTION_COUNTS")
    stops = extract_gdscript_const(source, "BODY_ACTION_STOPS")
    rows = extract_gdscript_const(source, "BODY_ACTION_ROWS")
    specs: list[SequenceSpec] = []
    for source_id in sorted(counts):
        frames_path = SOURCE / "Art/constellations/boss" / str(source_id) / "atlas" / f"constellation_{source_id}_frames.tres"
        animations = parse_sprite_frames(frames_path)
        body_frames = animations.get("body", [])
        for action, row in rows.items():
            if row >= len(counts[source_id]) or row >= len(stops.get(source_id, [])):
                continue
            row_stops = stops[source_id][row]
            if not row_stops:
                continue
            frames = animations.get(f"body/{row + 1}", [])
            raw_root = SOURCE / "Art/constellations/boss" / str(source_id) / "body" / str(row + 1)
            raw_files = sorted(
                (item for item in raw_root.glob("*.png") if item.is_file()), key=natural_key
            ) if raw_root.is_dir() else []
            if not frames and raw_files:
                frames = [("res://" + item.relative_to(SOURCE).as_posix(), [], []) for item in raw_files]
            if not frames and body_frames:
                frames = [body_frames[min(row, len(body_frames) - 1)]]
            if not frames:
                raise FileNotFoundError(f"星座 body 无可用帧: {source_id}/{action}")
            paths: list[str] = []
            regions: list[list[float]] = []
            margins: list[list[float]] = []
            for keyframe in range(max(int(counts[source_id][row]), 1)):
                page, region, margin = frames[min(keyframe, len(frames) - 1)]
                hold = max(int(row_stops[keyframe % len(row_stops)]), 1)
                paths.extend([page] * hold)
                if region:
                    regions.extend([region] * hold)
                    margins.extend([margin] * hold)
            sequence_key = f"constellation/{source_id}/body/{action}"
            loop = action in {"wait", "walk"}
            spec = SequenceSpec(key_for(sequence_key, 24.0, loop, not loop), paths, 24.0, loop, not loop)
            if regions and len(regions) == len(paths):
                spec.regions = [tuple(value) for value in regions]
                spec.margins = [tuple(value) for value in margins]
            specs.append(spec)
    return specs



def collect_constellation_skill_specs() -> list[SequenceSpec]:
    specs: list[SequenceSpec] = []
    boss_root = SOURCE / "Art/constellations/boss"
    for boss_dir in sorted(boss_root.iterdir(), key=natural_key):
        if not boss_dir.is_dir() or not boss_dir.name.isdigit():
            continue
        for directory in sorted(boss_dir.glob("skill*"), key=natural_key):
            if not directory.is_dir():
                continue
            paths = collect_frames(directory)
            if not paths:
                continue
            directory_res = "res://" + directory.relative_to(SOURCE).as_posix()
            for loop in (False, True):
                for hold in (False, True):
                    specs.append(SequenceSpec(key_for(directory_res, 24.0, loop, hold), paths, 24.0, loop, hold))
    return specs


def write_spec(spec: SequenceSpec, check_only: bool) -> bool:
    digest = hashlib.sha1(spec.key.encode("utf-8")).hexdigest()[:16]
    output_path = OUTPUT_ROOT / f"{digest}.tres"
    content = sequence_content(spec)
    if check_only:
        if not output_path.is_file():
            print(f"[FAIL] 缺少 FrameSequence: {output_path.relative_to(ROOT)}", file=sys.stderr)
            return False
        if output_path.read_text(encoding="utf-8") != content:
            print(f"[FAIL] FrameSequence 已过期: {output_path.relative_to(ROOT)}", file=sys.stderr)
            return False
        return True
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(content, encoding="utf-8", newline="\n")
    return True


def run(check_only: bool) -> int:
    try:
        specs = (
            collect_directory_specs()
            + collect_sword_specs()
            + collect_constellation_specs()
            + collect_constellation_skill_specs()
        )
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    passed = True
    for spec in specs:
        passed = write_spec(spec, check_only) and passed
    catalog_specs = []
    for spec in specs:
        digest = hashlib.sha1(spec.key.encode("utf-8")).hexdigest()[:16]
        catalog_specs.append((spec.key, f"res://Art/frame_sequences/{digest}.tres"))
    expected_catalog = catalog_content(catalog_specs)
    if check_only:
        if not CATALOG_PATH.is_file():
            print(f"[FAIL] 缺少 FrameSequence Catalog: {CATALOG_PATH.relative_to(ROOT)}", file=sys.stderr)
            return 1
        if CATALOG_PATH.read_text(encoding="utf-8") != expected_catalog:
            print(f"[FAIL] FrameSequence Catalog 已过期: {CATALOG_PATH.relative_to(ROOT)}", file=sys.stderr)
            return 1
    else:
        CATALOG_PATH.parent.mkdir(parents=True, exist_ok=True)
        CATALOG_PATH.write_text(expected_catalog, encoding="utf-8", newline="\n")
    if passed:
        action = "校验通过" if check_only else "已生成"
        print(f"[OK] FrameSequence {action}: {len(specs)} 个序列")
        return 0
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description="生成固定 PNG / 图集帧序列的 FrameSequence 资源")
    parser.add_argument("--check", action="store_true", help="只校验输出存在且内容一致")
    args = parser.parse_args()
    return run(args.check)


if __name__ == "__main__":
    sys.exit(main())

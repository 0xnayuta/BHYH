#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把固定 PNG / 图集帧序列转换为构建期 FrameSequence 资源与 Catalog。

运行时通过 FrameSequenceStore 读取，不扫描目录、不猜测编号文件。
当前登记：四剑台背景、星座治疗 aura、混沌、饕餮、流沙河、五台 3077
固定序列，四剑阵 AtlasMetadata 技能序列，以及星座动态 body/技能与
五台弹道非 swf 序列。

生成约定：
- 每个序列与 Catalog 的资源头写入由身份派生的稳定 uid://，不依赖随机数；
- 延迟加载的 Texture 路径只保存在 FrameSequence 的字符串数组中，不生成
  Texture2D 强引用；
- 额外生成 frame_sequence_export_dependencies.json，供导出预设检查使用。
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import math
import re
import sys
import struct
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
OUTPUT_ROOT = SOURCE / "Art/frame_sequences"
CATALOG_PATH = OUTPUT_ROOT / "frame_sequence_catalog.tres"
EXPORT_MANIFEST_PATH = OUTPUT_ROOT / "frame_sequence_export_dependencies.json"
EXPORT_PRESETS_PATH = SOURCE / "export_presets.cfg"

EXPORT_MANIFEST_SCHEMA = "frame_sequence_export_dependencies"
EXPORT_MANIFEST_VERSION = 1

# 历史素材的正式来源；不是“缺动画就换来源”的运行期/构建期回退。
CONSTELLATION_RAW_BODY_ACTIONS: dict[int, set[str]] = {
    140: {'hurt'},
    142: {'hit2', 'hurt', 'skill2'},
    144: {'hurt'},
    146: {'hurt'},
    147: {'hurt'},
    149: {'hurt'},
    150: {'hurt', 'skill3', 'hit3'},
    151: {'hit2', 'hurt', 'skill2'},
    152: {'hurt', 'skill3', 'hit3'},
    156: {'hurt', 'skill3', 'hit3'},
    157: {'hurt'},
    158: {'hit4', 'hurt', 'skill4'},
    159: {'hurt'},
    162: {'hurt'},
}
CONSTELLATION_STATIC_BODY_ACTIONS: dict[int, set[str]] = {
    141: {'wait', 'hurt', 'walk', 'death'},
    145: {'hurt', 'skill1', 'walk', 'skill2', 'hit2', 'wait', 'hit1', 'death'},
}

PREFETCH_FRAMES = 2
# Godot 4 的 UID 使用 34 进制：a..y + 0..8（z 与 9 为历史兼容保留字符）。
UID_ALPHABET = "abcdefghijklmnopqrstuvwxy012345678"
UID_BASE = len(UID_ALPHABET)
UID_MAX_VALUE = 0x7FFFFFFFFFFFFFFF
UID_PATTERN = re.compile(r"^uid://[a-y0-8]{1,13}$")
RESOURCE_HEADER_UID_PATTERN = re.compile(
    r'^\[gd_(?:resource|scene)\b[^\]]*\buid="(uid://[^"]+)"', re.M
)
FRAME_PATHS_PATTERN = re.compile(r"^frame_paths = PackedStringArray\((.*)\)$", re.M)
FRAME_REGIONS_PATTERN = re.compile(r"^frame_regions = \[(.*)\]$", re.M)
FRAME_MARGINS_PATTERN = re.compile(r"^frame_margins = \[(.*)\]$", re.M)
EXT_RESOURCE_TAG_PATTERN = re.compile(r"^\[ext_resource\b([^\]]*)\]$", re.M)
TAG_ATTRIBUTE_PATTERN = re.compile(r'([A-Za-z_]\w*)="([^"]*)"')

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
    {
        "root": "res://Art/monster/game_3_monster/monster_163/hit1",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_163/hit2",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_163/hit3",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_164/hit1",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_164/hit2",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_164/hit3",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_165/hit1",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_165/hit2",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_165/hit3",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_166/hit1",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_166/hit2",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_166/hit3",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_168/hit1",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_168/hit2",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_168/hit3",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_169/hit1",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_169/hit3",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_174/hit1",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_174/hit2",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_174/hit3",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_175/hit1",
        "include_root": True,
        "variants": ((24.0, False, False),),
    },
    {
        "root": "res://Art/monster/game_3_monster/monster_175/hit3",
        "include_root": True,
        "variants": ((24.0, False, False),),
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


def resource_path_for(path: Path) -> str:
    return "res://" + path.relative_to(SOURCE).as_posix()


def key_for(directory: str, fps: float, loop: bool, hold: bool, prefetch: int = 2) -> str:
    return "%s|%.1f|%s|%s|%d" % (directory, fps, str(loop).lower(), str(hold).lower(), prefetch)


def escape_string(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def unescape_string(value: str) -> str:
    return re.sub(
        r"\\(.)",
        lambda match: {
            "n": "\n",
            "r": "\r",
            "t": "\t",
            '"': '"',
            "\\": "\\",
        }.get(match.group(1), match.group(1)),
        value,
    )


def uid_for_identity(identity: str) -> str:
    """把已登记身份编码成 Godot 资源 UID；同一身份始终得到同一结果。"""
    digest = hashlib.sha256(("bhyh:" + identity).encode("utf-8")).digest()
    value = int.from_bytes(digest[:8], "big") & UID_MAX_VALUE
    if value == 0:
        value = 1
    return uid_id_to_text(value)


def uid_id_to_text(value: int) -> str:
    value &= UID_MAX_VALUE
    chars: list[str] = []
    while True:
        chars.append(UID_ALPHABET[value % UID_BASE])
        value //= UID_BASE
        if value == 0:
            break
    uid = "uid://" + "".join(reversed(chars))
    if not UID_PATTERN.match(uid):
        raise ValueError(f"生成的 UID 非法: {uid}")
    return uid


def uid_text_to_id(uid: str) -> int | None:
    if not uid.startswith("uid://") or uid == "uid://<invalid>":
        return None
    text = uid.removeprefix("uid://")
    if not text:
        return None
    value = 0
    for char in text:
        if "a" <= char <= "z":
            digit = ord(char) - ord("a")
        elif "0" <= char <= "9":
            digit = ord(char) - ord("0") + 25
        else:
            return None
        value = (value * UID_BASE + digit) & UID_MAX_VALUE
    return value


def canonical_uid(uid: str) -> str | None:
    value = uid_text_to_id(uid)
    if value is None:
        return None
    return uid_id_to_text(value)


def sequence_uid(key: str) -> str:
    return uid_for_identity("frame_sequence|" + key)


def catalog_uid() -> str:
    return uid_for_identity("frame_sequence_catalog")


def catalog_resource_path() -> str:
    return resource_path_for(CATALOG_PATH)


def sequence_resource_path(key: str) -> str:
    digest = hashlib.sha1(key.encode("utf-8")).hexdigest()[:16]
    return f"res://Art/frame_sequences/{digest}.tres"


def sequence_content(spec: SequenceSpec) -> str:
    lines = [
        '[gd_resource type="Resource" script_class="FrameSequence" load_steps=2 format=3 uid="%s"]'
        % sequence_uid(spec.key),
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
            "prefetch_frames = %d" % PREFETCH_FRAMES,
            "",
        ]
    )
    return "\n".join(lines)


def catalog_content(specs: list[tuple[str, str]]) -> str:
    lines = [
        '[gd_resource type="Resource" script_class="FrameSequenceCatalog" load_steps=%d format=3 uid="%s"]'
        % (len(specs) + 2, catalog_uid()),
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
    return [resource_path_for(path) for path in files]


def collect_directory_specs() -> list[SequenceSpec]:
    specs: list[SequenceSpec] = []
    seen: set[str] = set()
    for profile in PROFILES:
        for directory in collect_directories(profile):
            paths = collect_frames(directory)
            if not paths:
                continue
            directory_res = resource_path_for(directory)
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
        if not pages:
            raise ValueError(f"剑阵 manifest 缺少 pages: {root}")
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
                page_name = str(pages[page_index])
                paths.append(f"{root}/atlas/{page_name}")
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


def tag_attributes(body: str) -> dict[str, str]:
    return {match.group(1): match.group(2) for match in TAG_ATTRIBUTE_PATTERN.finditer(body)}


def parse_sprite_frames(path: Path) -> dict[str, list[tuple[str, list[float], list[float]]]]:
    if not path.is_file():
        raise FileNotFoundError(f"缺少 SpriteFrames 资源: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    ext = {}
    for match in EXT_RESOURCE_TAG_PATTERN.finditer(text):
        attributes = tag_attributes(match.group(1))
        if attributes.get("type") == "Texture2D" and attributes.get("path") and attributes.get("id"):
            ext[attributes["id"]] = attributes["path"]
    subs: dict[str, tuple[str, list[float], list[float]]] = {}
    for match in re.finditer(
        r'\[sub_resource type="AtlasTexture" id="([^"]+)"\]\n(.*?)(?=\n\[|\Z)', text, re.S
    ):
        body = match.group(2)
        atlas = re.search(r'atlas = ExtResource\("([^"]+)"\)', body)
        region = re.search(r"region = Rect2\(([^)]*)\)", body)
        margin = re.search(r"margin = Rect2\(([^)]*)\)", body)
        if atlas is None or atlas.group(1) not in ext:
            raise ValueError(f"SpriteFrames 引用缺失: {path.relative_to(ROOT)}")
        region_values = [float(value) for value in region.group(1).split(",")] if region else []
        margin_values = [float(value) for value in margin.group(1).split(",")] if margin else []
        if region_values and len(region_values) != 4:
            raise ValueError(f"SpriteFrames region 长度非法: {path.relative_to(ROOT)}")
        if margin_values and len(margin_values) != 4:
            raise ValueError(f"SpriteFrames margin 长度非法: {path.relative_to(ROOT)}")
        subs[match.group(1)] = (ext[atlas.group(1)], region_values, margin_values)
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
                if not page:
                    raise ValueError(f"SpriteFrames 帧引用缺失: {path.relative_to(ROOT)}")
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
            if action in CONSTELLATION_RAW_BODY_ACTIONS.get(source_id, set()):
                raw_root = SOURCE / "Art/constellations/boss" / str(source_id) / "body" / str(row + 1)
                frames = [(path, [], []) for path in collect_frames(raw_root)]
            elif action in CONSTELLATION_STATIC_BODY_ACTIONS.get(source_id, set()):
                if not body_frames:
                    raise FileNotFoundError(f"星座静态 body 来源缺失: {source_id}/{action}")
                frames = [body_frames[min(row, len(body_frames) - 1)]]
            else:
                frames = animations.get(f"body/{row + 1}", [])
            if not frames:
                raise FileNotFoundError(f"星座声明的 body 来源缺失: {source_id}/{action}")
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
    if not boss_root.is_dir():
        raise FileNotFoundError(f"缺少星座 Boss 目录: {boss_root.relative_to(ROOT)}")
    for boss_dir in sorted(boss_root.iterdir(), key=natural_key):
        if not boss_dir.is_dir() or not boss_dir.name.isdigit():
            continue
        for directory in sorted(boss_dir.glob("skill*"), key=natural_key):
            if not directory.is_dir():
                continue
            paths = collect_frames(directory)
            if not paths:
                continue
            directory_res = resource_path_for(directory)
            for loop in (False, True):
                for hold in (False, True):
                    specs.append(SequenceSpec(key_for(directory_res, 24.0, loop, hold), paths, 24.0, loop, hold))
    return specs


def validate_resource_path(resource_path: str, label: str) -> list[str]:
    errors: list[str] = []
    if not isinstance(resource_path, str) or not resource_path:
        return [f"{label}: 路径不能为空"]
    if not resource_path.startswith("res://"):
        return [f"{label}: 路径必须是 res:// 形式: {resource_path}"]
    relative = resource_path.removeprefix("res://")
    if not relative or relative.startswith("/") or "\\" in relative:
        return [f"{label}: 路径非法: {resource_path}"]
    parts = relative.split("/")
    if any(part in ("", ".", "..") for part in parts):
        return [f"{label}: 路径包含空段或相对段: {resource_path}"]
    if resource_path != "res://" + "/".join(parts):
        errors.append(f"{label}: 路径不是规范形式: {resource_path}")
    target = SOURCE / relative
    if not target.is_file():
        errors.append(f"{label}: 输入文件不存在: {resource_path}")
    return errors


def validate_rect(
    values: object,
    label: str,
    *,
    positive_size: bool,
) -> list[str]:
    errors: list[str] = []
    if not isinstance(values, (list, tuple)) or len(values) != 4:
        return [f"{label}: 必须是 4 个数值"]
    numbers: list[float] = []
    for value in values:
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            return [f"{label}: 包含非数值: {value!r}"]
        number = float(value)
        if not math.isfinite(number):
            return [f"{label}: 包含非有限数值: {value!r}"]
        numbers.append(number)
    position_x, position_y, size_x, size_y = numbers
    if positive_size:
        if position_x < 0.0 or position_y < 0.0:
            errors.append(f"{label}: 位置不能为负: {values!r}")
        if size_x <= 0.0 or size_y <= 0.0:
            errors.append(f"{label}: 尺寸必须为正: {values!r}")
    else:
        if size_x < 0.0 or size_y < 0.0:
            errors.append(f"{label}: 尺寸不能为负: {values!r}")
    return errors


def validate_sequence_spec(spec: SequenceSpec) -> list[str]:
    errors: list[str] = []
    if not spec.key or any(ord(char) < 32 for char in spec.key):
        errors.append(f"序列键为空或包含控制字符: {spec.key!r}")
    if not spec.paths:
        errors.append(f"{spec.key}: frame_paths 不能为空")
    else:
        for index, resource_path in enumerate(spec.paths):
            errors.extend(validate_resource_path(resource_path, f"{spec.key} frame_paths[{index}]"))
    if not math.isfinite(float(spec.fps)) or float(spec.fps) <= 0.0:
        errors.append(f"{spec.key}: fps 必须为正数: {spec.fps!r}")
    if spec.regions and len(spec.regions) != len(spec.paths):
        errors.append(f"{spec.key}: frame_regions 长度 {len(spec.regions)} 与帧数 {len(spec.paths)} 不一致")
    if spec.margins and len(spec.margins) != len(spec.paths):
        errors.append(f"{spec.key}: frame_margins 长度 {len(spec.margins)} 与帧数 {len(spec.paths)} 不一致")
    if spec.margins and not spec.regions:
        errors.append(f"{spec.key}: frame_margins 不能在没有 frame_regions 时单独存在")
    for index, region in enumerate(spec.regions):
        errors.extend(validate_rect(region, f"{spec.key} frame_regions[{index}]", positive_size=True))
    for index, margin in enumerate(spec.margins):
        errors.extend(validate_rect(margin, f"{spec.key} frame_margins[{index}]", positive_size=False))
    for index, region in enumerate(spec.regions):
        if index >= len(spec.paths) or len(region) != 4:
            continue
        path = source_path(spec.paths[index])
        if not path.is_file():
            continue
        with path.open("rb") as image:
            header = image.read(24)
        if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
            errors.append(f"{spec.key}: 图集页不是合法 PNG: {spec.paths[index]}")
            continue
        width, height = struct.unpack(">II", header[16:24])
        x, y, w, h = region
        if x + w > width or y + h > height:
            errors.append(f"{spec.key}: frame_regions[{index}] 超出图集页 {width}x{height}")
    return errors


def collect_existing_uids() -> dict[str, set[str]]:
    """收集工程内已登记的 UID 所有者，用于生成前防碰撞。"""
    owners: dict[str, set[str]] = {}

    def register(uid: str, owner: Path) -> None:
        normalized = canonical_uid(uid)
        if normalized is None:
            return
        relative = owner.relative_to(SOURCE)
        if relative.parts and relative.parts[0] == ".godot":
            return
        owners.setdefault(normalized, set()).add(resource_path_for(owner))

    for path in SOURCE.rglob("*.uid"):
        try:
            uid = path.read_text(encoding="utf-8", errors="ignore").strip()
        except OSError:
            continue
        if uid:
            register(uid, path.with_suffix(""))
    for suffix in ("*.tres", "*.tscn"):
        for path in SOURCE.rglob(suffix):
            relative = path.relative_to(SOURCE)
            if relative.parts and relative.parts[0] == ".godot":
                continue
            try:
                with path.open("r", encoding="utf-8", errors="ignore") as handle:
                    head = handle.read(2048)
            except OSError:
                continue
            match = RESOURCE_HEADER_UID_PATTERN.search(head)
            if match:
                register(match.group(1), path)
    return owners


def validate_specs(specs: list[SequenceSpec]) -> list[str]:
    errors: list[str] = []
    if not specs:
        return ["未收集到任何 FrameSequence"]
    existing_uids = collect_existing_uids()
    seen_keys: dict[str, int] = {}
    seen_hashes: dict[str, str] = {}
    generated_uids: dict[str, str] = {}
    for spec in specs:
        errors.extend(validate_sequence_spec(spec))
        if spec.key in seen_keys:
            errors.append(f"重复帧序列键: {spec.key}")
        else:
            seen_keys[spec.key] = len(seen_keys)
        digest = hashlib.sha1(spec.key.encode("utf-8")).hexdigest()[:16]
        if digest in seen_hashes:
            errors.append(f"输出哈希冲突: {spec.key} 与 {seen_hashes[digest]} -> {digest}")
        else:
            seen_hashes[digest] = spec.key
        uid = sequence_uid(spec.key)
        if uid in generated_uids:
            errors.append(f"UID 冲突: {spec.key} 与 {generated_uids[uid]} -> {uid}")
        else:
            generated_uids[uid] = spec.key
        expected_owner = sequence_resource_path(spec.key)
        owners = existing_uids.get(uid)
        if owners and owners != {expected_owner}:
            errors.append(f"UID 已被其它资源占用: {uid} -> {sorted(owners)}")
    catalog_owner = catalog_resource_path()
    owners = existing_uids.get(catalog_uid())
    if owners and owners != {catalog_owner}:
        errors.append(f"Catalog UID 已被其它资源占用: {catalog_uid()} -> {sorted(owners)}")
    for uid, key in generated_uids.items():
        if uid == catalog_uid():
            errors.append(f"序列 UID 与 Catalog 冲突: {key} -> {uid}")
    return errors


def build_catalog_specs(specs: list[SequenceSpec]) -> list[tuple[str, str]]:
    return [(spec.key, sequence_resource_path(spec.key)) for spec in specs]


def build_export_manifest(specs: list[SequenceSpec]) -> dict[str, object]:
    sequences = sorted(sequence_resource_path(spec.key) for spec in specs)
    textures = sorted({resource_path for spec in specs for resource_path in spec.paths})
    return {
        "schema_id": EXPORT_MANIFEST_SCHEMA,
        "schema_version": EXPORT_MANIFEST_VERSION,
        "catalog": catalog_resource_path(),
        "sequences": sequences,
        "deferred_textures": textures,
    }


def export_manifest_content(manifest: dict[str, object]) -> str:
    return json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"


def parse_catalog_entries(text: str) -> tuple[dict[str, str], dict[str, str]]:
    ext_resources: dict[str, str] = {}
    for match in EXT_RESOURCE_TAG_PATTERN.finditer(text):
        attributes = tag_attributes(match.group(1))
        if attributes.get("type") == "Resource" and attributes.get("path") and attributes.get("id"):
            ext_resources[attributes["id"]] = attributes["path"]
    entries: dict[str, str] = {}
    for match in re.finditer(
        r'^\t&"((?:[^"\\]|\\.)*)": ExtResource\("([^"]+)"\),\s*$', text, re.M
    ):
        entries[unescape_string(match.group(1))] = ext_resources.get(match.group(2), "")
    return entries, ext_resources


def parse_frame_paths(text: str) -> list[str] | None:
    match = FRAME_PATHS_PATTERN.search(text)
    if match is None:
        return None
    return [
        unescape_string(value) for value in re.findall(r'"((?:[^"\\]|\\.)*)"', match.group(1))
    ]


def parse_rect_count(text: str, pattern: re.Pattern[str]) -> int:
    match = pattern.search(text)
    if match is None:
        return 0
    return len(re.findall(r"Rect2\(([^)]*)\)", match.group(1)))


def validate_generated_closure(specs: list[SequenceSpec], manifest: dict[str, object]) -> list[str]:
    """从实际资源与依赖清单反查 Catalog 闭包，不信任单一生成结果。"""
    errors: list[str] = []
    expected_catalog = build_catalog_specs(specs)
    expected_by_key = dict(expected_catalog)
    expected_sequences = sorted(path for _key, path in expected_catalog)
    expected_textures = sorted({resource_path for spec in specs for resource_path in spec.paths})

    if manifest.get("schema_id") != EXPORT_MANIFEST_SCHEMA:
        errors.append(f"依赖清单 schema_id 非法: {manifest.get('schema_id')!r}")
    if manifest.get("schema_version") != EXPORT_MANIFEST_VERSION:
        errors.append(f"依赖清单 schema_version 非法: {manifest.get('schema_version')!r}")
    if manifest.get("catalog") != catalog_resource_path():
        errors.append(f"依赖清单 Catalog 路径非法: {manifest.get('catalog')!r}")
    manifest_sequences = manifest.get("sequences")
    if not isinstance(manifest_sequences, list) or manifest_sequences != expected_sequences:
        errors.append("依赖清单 sequences 与生成集不一致")
    manifest_textures = manifest.get("deferred_textures")
    if not isinstance(manifest_textures, list) or manifest_textures != expected_textures:
        errors.append("依赖清单 deferred_textures 与生成集不一致")
    if isinstance(manifest_sequences, list) and len(set(map(str, manifest_sequences))) != len(manifest_sequences):
        errors.append("依赖清单 sequences 包含重复路径")
    if isinstance(manifest_textures, list) and len(set(map(str, manifest_textures))) != len(manifest_textures):
        errors.append("依赖清单 deferred_textures 包含重复路径")

    if not CATALOG_PATH.is_file():
        errors.append(f"缺少 Catalog: {CATALOG_PATH.relative_to(ROOT)}")
    else:
        catalog_text = CATALOG_PATH.read_text(encoding="utf-8")
        header = RESOURCE_HEADER_UID_PATTERN.search(catalog_text[:512])
        if header is None or header.group(1) != catalog_uid():
            errors.append(f"Catalog UID 头缺失或与身份不一致: {CATALOG_PATH.relative_to(ROOT)}")
        entries, ext_resources = parse_catalog_entries(catalog_text)
        if entries != expected_by_key:
            missing = sorted(set(expected_by_key) - set(entries))
            extra = sorted(set(entries) - set(expected_by_key))
            if missing:
                errors.append(f"Catalog 缺少序列键: {missing[:5]}")
            if extra:
                errors.append(f"Catalog 包含多余序列键: {extra[:5]}")
            for key in sorted(set(entries) & set(expected_by_key)):
                if entries[key] != expected_by_key[key]:
                    errors.append(f"Catalog 键指向错误资源: {key} -> {entries[key]}")
        unused = sorted(set(ext_resources.values()) - set(expected_sequences))
        if unused:
            errors.append(f"Catalog 包含多余 ext_resource: {unused[:5]}")

    actual_textures: set[str] = set()
    for key, sequence_path in expected_by_key.items():
        target = SOURCE / sequence_path.removeprefix("res://")
        if not target.is_file():
            errors.append(f"缺少序列资源: {sequence_path}")
            continue
        text = target.read_text(encoding="utf-8")
        header = RESOURCE_HEADER_UID_PATTERN.search(text[:512])
        if header is None or header.group(1) != sequence_uid(key):
            errors.append(f"序列 UID 头缺失或与身份不一致: {sequence_path}")
        paths = parse_frame_paths(text)
        if paths is None:
            errors.append(f"序列缺少 frame_paths: {sequence_path}")
            continue
        if not paths:
            errors.append(f"序列 frame_paths 为空: {sequence_path}")
        regions = parse_rect_count(text, FRAME_REGIONS_PATTERN)
        margins = parse_rect_count(text, FRAME_MARGINS_PATTERN)
        if regions and regions != len(paths):
            errors.append(f"序列 frame_regions 长度不一致: {sequence_path}")
        if margins and margins != len(paths):
            errors.append(f"序列 frame_margins 长度不一致: {sequence_path}")
        actual_textures.update(paths)

    for resource_path in sorted(actual_textures):
        errors.extend(validate_resource_path(resource_path, "FrameSequence texture"))
    for resource_path in expected_textures:
        errors.extend(validate_resource_path(resource_path, "依赖清单 texture"))
    if actual_textures != set(expected_textures):
        missing = sorted(set(expected_textures) - actual_textures)
        extra = sorted(actual_textures - set(expected_textures))
        if missing:
            errors.append(f"依赖清单缺少延迟 Texture: {missing[:5]}")
        if extra:
            errors.append(f"依赖清单包含未引用 Texture: {extra[:5]}")
    return errors


def write_spec(spec: SequenceSpec, check_only: bool) -> bool:
    output_path = SOURCE / sequence_resource_path(spec.key).removeprefix("res://")
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


def parse_godot_config_string(raw: str) -> str:
    value = raw.strip()
    if len(value) >= 2 and value.startswith('"') and value.endswith('"'):
        return unescape_string(value[1:-1])
    return value


def parse_packed_string_array(raw: str) -> list[str]:
    value = raw.strip()
    if value.startswith("PackedStringArray("):
        if not value.endswith(")"):
            raise ValueError(f"PackedStringArray 未闭合: {value[:40]}")
        value = value[len("PackedStringArray(") : -1]
    return [unescape_string(match) for match in re.findall(r'"((?:[^"\\]|\\.)*)"', value)]


def parse_export_presets(path: Path) -> list[dict[str, object]]:
    text = path.read_text(encoding="utf-8-sig")
    presets: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    in_options = False
    for line_number, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith(";") or stripped.startswith("#"):
            continue
        section = re.fullmatch(r"\[preset\.(\d+)(\.options)?\]", stripped)
        if section:
            index = int(section.group(1))
            if section.group(2):
                if current is None or current.get("index") != index:
                    raise ValueError(f"export_presets.cfg:{line_number}: options 段缺少对应 preset")
                in_options = True
            else:
                current = {"index": index, "fields": {}, "line": line_number}
                presets.append(current)
                in_options = False
            continue
        if current is None or in_options or "=" not in line:
            continue
        key, raw = line.split("=", 1)
        fields = current["fields"]
        assert isinstance(fields, dict)
        fields[key.strip()] = raw.strip()
    if not presets:
        raise ValueError("export_presets.cfg 未包含任何 [preset.N]")

    result: list[dict[str, object]] = []
    for preset in presets:
        fields = preset["fields"]
        assert isinstance(fields, dict)
        name = parse_godot_config_string(str(fields.get("name", "")))
        export_filter = parse_godot_config_string(str(fields.get("export_filter", "")))
        export_files = parse_packed_string_array(str(fields.get("export_files", "PackedStringArray()")))
        include_filter = parse_godot_config_string(str(fields.get("include_filter", "")))
        exclude_filter = parse_godot_config_string(str(fields.get("exclude_filter", "")))
        result.append(
            {
                "name": name or f"preset.{preset['index']}",
                "platform": parse_godot_config_string(str(fields.get("platform", ""))),
                "export_filter": export_filter,
                "export_files": export_files,
                "include_filter": include_filter,
                "exclude_filter": exclude_filter,
                "line": preset["line"],
            }
        )
    return result


def split_export_filters(value: str) -> list[str]:
    return [item.strip() for item in value.split(",") if item.strip()]


def glob_matches(path: str, pattern: str) -> bool:
    parts: list[str] = []
    for char in pattern:
        if char == "*":
            parts.append(".*")
        elif char == "?":
            parts.append(".")
        else:
            parts.append(re.escape(char))
    return re.match("^" + "".join(parts) + "$", path, re.IGNORECASE) is not None


def preset_coverage_errors(
    preset: dict[str, object],
    required_paths: list[str],
) -> list[str]:
    errors: list[str] = []
    export_filter = str(preset["export_filter"])
    export_file_set = {str(path) for path in preset["export_files"]}
    exclude_filters = split_export_filters(str(preset["exclude_filter"]))
    supported = {"all_resources", "resources", "customized", "selected_scenes"}
    if export_filter not in supported:
        return [f"export_filter 缺失或无法识别: {export_filter!r}"]

    for resource_path in required_paths:
        for pattern in exclude_filters:
            if glob_matches(resource_path, pattern):
                errors.append(f"被 exclude_filter 排除: {resource_path} ({pattern})")
                break
    if export_filter == "all_resources":
        return errors
    if export_filter == "selected_scenes":
        return errors + [
            "selected_scenes 只导出场景及其资源依赖；延迟 Texture 路径不是资源依赖，"
            "无法证明覆盖；请使用 all_resources 或 resources 并显式列出"
        ]

    missing = [path for path in required_paths if path not in export_file_set]
    if missing:
        errors.append(f"selected 资源未显式覆盖 {len(missing)} 条，例如: {missing[:5]}")
    return errors


def run_export_preset_check(required_paths: list[str], preset_filter: str) -> int:
    if not required_paths:
        print("[FAIL] 没有可检查的 FrameSequence 发布依赖路径", file=sys.stderr)
        return 1
    if not EXPORT_PRESETS_PATH.is_file():
        print(
            f"[FAIL] 缺少实际导出预设: {EXPORT_PRESETS_PATH.relative_to(ROOT)}，无法验证发布依赖覆盖",
            file=sys.stderr,
        )
        return 2
    try:
        presets = parse_export_presets(EXPORT_PRESETS_PATH)
    except (OSError, ValueError) as error:
        print(f"[FAIL] 无法解析 {EXPORT_PRESETS_PATH.relative_to(ROOT)}: {error}", file=sys.stderr)
        return 2
    selected = presets if preset_filter == "*" else [preset for preset in presets if preset["name"] == preset_filter]
    if not selected:
        names = ", ".join(str(preset["name"]) for preset in presets)
        print(f"[FAIL] 未找到导出预设: {preset_filter}；现有: {names}", file=sys.stderr)
        return 2
    print(
        f"[*] 导出预设检查: {len(selected)}/{len(presets)} 个预设，"
        f"依赖路径 {len(required_paths)} 条（Catalog + 序列 + 延迟 Texture）"
    )
    failed = 0
    for preset in selected:
        errors = preset_coverage_errors(preset, required_paths)
        label = f"{preset['name']} [{preset['platform']}] export_filter={preset['export_filter']}"
        if errors:
            failed += 1
            print(f"[FAIL] 预设 {label}: 未证明覆盖 {len(required_paths)} 条依赖", file=sys.stderr)
            for error in errors[:10]:
                print(f"    {error}", file=sys.stderr)
            if len(errors) > 10:
                print(f"    ... 其余 {len(errors) - 10} 条省略", file=sys.stderr)
        else:
            print(f"[OK] 预设 {label}: 声明覆盖 {len(required_paths)} 条依赖（配置级）")
    if failed:
        print(
            "[FAIL] 发布依赖覆盖失败；源目录存在不等于导出包完整。",
            file=sys.stderr,
        )
        return 1
    print(
        "[OK] export_presets.cfg 声明覆盖完成；这是配置级校验，"
        "未验证 PCK/导出包实际路径闭包与加载。"
    )
    return 0


def run(check_only: bool, preset_filter: str | None) -> int:
    if not SOURCE.is_dir():
        print(f"[FAIL] 工程目录不存在: {SOURCE}", file=sys.stderr)
        return 2
    if not (SOURCE / "Art").is_dir():
        print(
            "[FAIL] 缺少私有素材目录 source/Art/，无法校验 FrameSequence 输入与生成结果；"
            "构建工具不会自动生成替代素材。",
            file=sys.stderr,
        )
        return 1
    try:
        specs = (
            collect_directory_specs()
            + collect_sword_specs()
            + collect_constellation_specs()
            + collect_constellation_skill_specs()
        )
        validation_errors = validate_specs(specs)
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    if validation_errors:
        for error in validation_errors[:20]:
            print(f"[FAIL] {error}", file=sys.stderr)
        if len(validation_errors) > 20:
            print(f"[FAIL] ... 其余 {len(validation_errors) - 20} 条省略", file=sys.stderr)
        return 1

    catalog_specs = build_catalog_specs(specs)
    manifest = build_export_manifest(specs)
    if check_only:
        passed = True
        for spec in specs:
            passed = write_spec(spec, check_only=True) and passed
        expected_catalog = catalog_content(catalog_specs)
        if not CATALOG_PATH.is_file():
            print(f"[FAIL] 缺少 FrameSequence Catalog: {CATALOG_PATH.relative_to(ROOT)}", file=sys.stderr)
            passed = False
        elif CATALOG_PATH.read_text(encoding="utf-8") != expected_catalog:
            print(f"[FAIL] FrameSequence Catalog 已过期: {CATALOG_PATH.relative_to(ROOT)}", file=sys.stderr)
            passed = False
        expected_manifest = export_manifest_content(manifest)
        if not EXPORT_MANIFEST_PATH.is_file():
            print(f"[FAIL] 缺少发布依赖清单: {EXPORT_MANIFEST_PATH.relative_to(ROOT)}", file=sys.stderr)
            passed = False
        elif EXPORT_MANIFEST_PATH.read_text(encoding="utf-8") != expected_manifest:
            print(f"[FAIL] 发布依赖清单已过期: {EXPORT_MANIFEST_PATH.relative_to(ROOT)}", file=sys.stderr)
            passed = False
        closure_errors = validate_generated_closure(specs, manifest)
        if closure_errors:
            passed = False
            for error in closure_errors[:20]:
                print(f"[FAIL] {error}", file=sys.stderr)
            if len(closure_errors) > 20:
                print(f"[FAIL] ... 其余 {len(closure_errors) - 20} 条省略", file=sys.stderr)
        if preset_filter is not None:
            required_paths = (
                [str(manifest["catalog"])]
                + [str(path) for path in manifest["sequences"]]
                + [str(path) for path in manifest["deferred_textures"]]
            )
            preset_status = run_export_preset_check(required_paths, preset_filter)
            if preset_status != 0:
                passed = False
        if passed:
            print(
                f"[OK] FrameSequence 校验通过: {len(specs)} 个序列，"
                "Catalog 与发布依赖清单闭包完整（源闭包，非发布包验证）"
            )
            return 0
        return 1

    for spec in specs:
        write_spec(spec, check_only=False)
    CATALOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    CATALOG_PATH.write_text(catalog_content(catalog_specs), encoding="utf-8", newline="\n")
    EXPORT_MANIFEST_PATH.write_text(export_manifest_content(manifest), encoding="utf-8", newline="\n")
    closure_errors = validate_generated_closure(specs, manifest)
    if closure_errors:
        for error in closure_errors[:20]:
            print(f"[FAIL] {error}", file=sys.stderr)
        if len(closure_errors) > 20:
            print(f"[FAIL] ... 其余 {len(closure_errors) - 20} 条省略", file=sys.stderr)
        return 1
    print(
        f"[OK] FrameSequence 已生成: {len(specs)} 个序列 + Catalog + 发布依赖清单 "
        f"({len(manifest['deferred_textures'])} 条延迟 Texture)"
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description="生成固定 PNG / 图集帧序列的 FrameSequence 资源、Catalog 与发布依赖清单"
    )
    parser.add_argument("--check", action="store_true", help="只校验输出、依赖闭包与 UID，不写文件")
    parser.add_argument(
        "--export-preset",
        nargs="?",
        const="*",
        default=None,
        metavar="NAME",
        help="校验实际 export_presets.cfg 的 resources 覆盖（隐含 --check；省略 NAME 检查全部预设）",
    )
    args = parser.parse_args()
    check_only = args.check or args.export_preset is not None
    try:
        return run(check_only, args.export_preset)
    except OSError as error:
        print(f"[FAIL] 文件读写失败: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

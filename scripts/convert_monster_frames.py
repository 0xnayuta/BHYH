#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把怪物 AtlasMetadata 的 sequences 投影为构建期 SpriteFrames 资源。

数据源是每个模型目录下的 ``metadata.tres``：
- ``pages`` 给出图集页路径；
- ``sequences`` 给出有序动画名与帧元组
  ``[frame_index, page_index, x, y, w, h, margin_left, margin_top, margin_right, margin_bottom]``。

输出沿用现有生产命名，不另起一套资源：
- 同目录唯一 ``*_frames.tres`` 优先；
- 目录名为 ``atlas*`` 且同目录无目标时，取父目录唯一 ``*_frames.tres``；
- 两条规则都不满足的 metadata 视为未纳管，显式报告原因，不猜测新路径。

播放参数（loop / speed）不在 metadata 中，属于资源侧声明：
- 已有目标按动画名继承原值，避免重建改变运行时手感；
- 新目标按 ``docs/standards/spriteframes_generation_policy.md`` 取默认值
  （speed 用 metadata.fps，缺省 24；wait/walk/idle/run 与 Monster* 循环）。

UID：规范输出含由身份派生的确定性 ``uid://``。历史 148 个目标没有 UID 头，
13-2A 阶段按“已评审例外”接受；``--rewrite`` 可一次性补齐，供 13-2B 切换时使用。
``--check`` 校验已存在 UID 的确定性与全局唯一性，并统计缺失数量。

用法：
    python scripts/convert_monster_frames.py --check
    python scripts/convert_monster_frames.py --all
    python scripts/convert_monster_frames.py --emit <目录> [--only <模型>]
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import re
import struct
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
MONSTER_ROOT = SOURCE / "Art/monster"
ACTION_MAP_PATH = ROOT / "scripts/monster_action_maps.json"

UID_ALPHABET = "abcdefghijklmnopqrstuvwxy012345678"
UID_BASE = len(UID_ALPHABET)
UID_MAX_VALUE = 0x7FFFFFFFFFFFFFFF
UID_PATTERN = re.compile(r"^uid://[a-y0-8]{1,13}$")
HEADER_UID_PATTERN = re.compile(
    r'^\[gd_(?:resource|scene)\b[^\]]*\buid="(uid://[^"]+)"', re.M
)
EXT_RESOURCE_PATTERN = re.compile(
    r'^\[ext_resource type="Texture2D" path="([^"]+)" id="([^"]+)"\]$', re.M
)
SUB_RESOURCE_PATTERN = re.compile(
    r'^\[sub_resource type="AtlasTexture" id="([^"]+)"\]\n(.*?)(?=\n\[|\Z)',
    re.M | re.S,
)
ATLAS_REF_PATTERN = re.compile(r'atlas = ExtResource\("([^"]+)"\)')
REGION_PATTERN = re.compile(r'region = Rect2\(([^)]*)\)')
MARGIN_PATTERN = re.compile(r'margin = Rect2\(([^)]*)\)')
ANIMATION_PATTERN = re.compile(
    r'\{\n"frames": \[(.*?)\],\n"loop": (true|false|\d+),\n"name": &?"([^"]+)",\n"speed": ([\d.]+)',
    re.S,
)
TEXTURE_REF_PATTERN = re.compile(r'"texture": SubResource\("([^"]+)"\)')

LOOP_NAME_PREFIXES = ("Monster",)
LOOP_NAMES = frozenset({"wait", "walk", "idle", "run"})
DEFAULT_SPEED = 24.0

# 未纳管目录的显式原因；新增条目必须写明为什么不能按 metadata 一比一投影。
SKIP_REASONS: dict[str, str] = {
    "pet_tiger_boss/atlas": (
        "metadata sequences 是 model/actions/stage*/… 的聚合名；实际帧按 stage "
        "拆分在 model/pet_tiger_stage*_frames.tres，动画名与 sequences 键不是一比一"
    ),
}


@dataclass(frozen=True)
class Frame:
    page: str
    region: tuple[int, int, int, int]
    margin: tuple[int, int, int, int]


@dataclass
class Animation:
    name: str
    loop: int
    speed: float
    frames: list[Frame] = field(default_factory=list)


@dataclass
class FramesModel:
    pages: list[str]
    animations: list[Animation]

    def animation_names(self) -> list[str]:
        return [a.name for a in self.animations]


@dataclass
class MetadataModel:
    pages: list[str]
    sequences: list[tuple[str, list[Frame]]]
    fps: float | None


@dataclass
class Target:
    metadata: Path
    frames_path: Path
    metadata_model: MetadataModel
    action_map: dict[str, str] = field(default_factory=dict)
    loop_overrides: dict[str, bool] = field(default_factory=dict)

    @property
    def label(self) -> str:
        return self.metadata.relative_to(MONSTER_ROOT).as_posix()

    def expected_uid(self) -> str:
        digest = hashlib.sha256(("bhyh:monster_frames|" + self.label).encode("utf-8")).digest()
        value = int.from_bytes(digest[:8], "big") & UID_MAX_VALUE
        if value == 0:
            value = 1
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


class MetadataParseError(RuntimeError):
    pass


def parse_godot_dict(text: str, marker: str = "data = {") -> dict:
    """解析 Godot .tres 中由 ``marker`` 起始的单层字典字面量。"""
    index = text.find(marker)
    if index < 0:
        raise MetadataParseError(f"缺少 {marker!r}")
    body = text[index + len(marker) - 1 :]
    depth = 0
    end = -1
    for offset, char in enumerate(body):
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                end = offset + 1
                break
    if end < 0:
        raise MetadataParseError("字典字面量不闭合")
    literal = body[:end]

    class RewriteNames(ast.NodeTransformer):
        def visit_Name(self, node: ast.Name) -> ast.AST:
            if node.id in {"true", "false", "null"}:
                return ast.copy_location(
                    ast.Constant({"true": True, "false": False, "null": None}[node.id]),
                    node,
                )
            return node

    tree = ast.parse(literal, mode="eval")
    tree = RewriteNames().visit(tree)
    ast.fix_missing_locations(tree)
    value = ast.literal_eval(tree)
    if not isinstance(value, dict):
        raise MetadataParseError("metadata 顶层不是字典")
    return value


def load_metadata(path: Path) -> MetadataModel:
    data = parse_godot_dict(path.read_text(encoding="utf-8"))
    pages: list[str] = []
    for entry in data.get("pages") or []:
        if not isinstance(entry, dict) or "path" not in entry:
            raise MetadataParseError(f"{path}: pages 条目缺少 path")
        pages.append(str(entry["path"]))
    sequences: list[tuple[str, list[Frame]]] = []
    for name, sequence in (data.get("sequences") or {}).items():
        raw_frames = sequence.get("frames") if isinstance(sequence, dict) else None
        if not isinstance(raw_frames, list):
            raise MetadataParseError(f"{path}: 序列 {name!r} 缺少 frames")
        frames: list[Frame] = []
        for raw in raw_frames:
            if not isinstance(raw, list) or len(raw) < 10:
                raise MetadataParseError(f"{path}: 序列 {name!r} 帧元组长度不足 10")
            page_index, x, y, w, h, ml, mt, mr, mb = (int(v) for v in raw[1:10])
            if not 0 <= page_index < len(pages):
                raise MetadataParseError(
                    f"{path}: 序列 {name!r} 页索引 {page_index} 越界 ({len(pages)} 页)"
                )
            frames.append(
                Frame(
                    page=pages[page_index],
                    region=(x, y, w, h),
                    margin=(ml, mt, mr, mb),
                )
            )
        if not frames:
            raise MetadataParseError(f"{path}: 序列 {name!r} 没有帧")
        sequences.append((str(name), frames))
    fps = data.get("fps")
    return MetadataModel(
        pages=pages,
        sequences=sequences,
        fps=float(fps) if isinstance(fps, (int, float)) else None,
    )


def parse_frames(path: Path) -> FramesModel:
    text = path.read_text(encoding="utf-8")
    ext_by_id = {ext_id: page for page, ext_id in EXT_RESOURCE_PATTERN.findall(text)}
    subs: dict[str, Frame] = {}
    for sub_id, body in SUB_RESOURCE_PATTERN.findall(text):
        atlas = ATLAS_REF_PATTERN.search(body)
        region = REGION_PATTERN.search(body)
        margin = MARGIN_PATTERN.search(body)
        if not atlas or not region or not margin:
            raise MetadataParseError(f"{path}: 子资源 {sub_id} 缺少 atlas/region/margin")
        page = ext_by_id.get(atlas.group(1))
        if page is None:
            raise MetadataParseError(f"{path}: 子资源 {sub_id} 引用了未声明的页")
        subs[sub_id] = Frame(
            page=page,
            region=parse_ints(region.group(1), 4),
            margin=parse_ints(margin.group(1), 4),
        )
    animations: list[Animation] = []
    for frames_blob, loop_text, name, speed_text in ANIMATION_PATTERN.findall(text):
        refs = TEXTURE_REF_PATTERN.findall(frames_blob)
        frames: list[Frame] = []
        for ref in refs:
            if ref not in subs:
                raise MetadataParseError(f"{path}: 动画 {name!r} 引用了未定义的子资源 {ref}")
            frames.append(subs[ref])
        loop = 1 if loop_text in {"true", "1"} else 0
        animations.append(
            Animation(name=name, loop=loop, speed=float(speed_text), frames=frames)
        )
    if not animations:
        raise MetadataParseError(f"{path}: 没有解析到任何动画")
    declared_pages = list(ext_by_id.values())
    used_pages = {frame.page for animation in animations for frame in animation.frames}
    pages = [page for page in declared_pages if page in used_pages]
    return FramesModel(pages=pages, animations=animations)


def parse_ints(text: str, count: int) -> tuple[int, ...]:
    parts = [part.strip() for part in text.split(",")]
    if len(parts) != count:
        raise MetadataParseError(f"期望 {count} 个数值，实际 {text!r}")
    values = [int(round(float(part))) for part in parts]
    return tuple(values)


def resolve_target(metadata: Path) -> tuple[Path | None, str]:
    directory = metadata.parent
    same_dir = sorted(directory.glob("*_frames.tres"))
    if len(same_dir) == 1:
        return same_dir[0], ""
    if len(same_dir) > 1:
        return None, f"同目录存在多个 *_frames.tres: {[p.name for p in same_dir]}"
    if directory.name.startswith("atlas"):
        parent_dir = sorted(directory.parent.glob("*_frames.tres"))
        if len(parent_dir) == 1:
            return parent_dir[0], ""
        if len(parent_dir) > 1:
            return None, f"父目录存在多个 *_frames.tres: {[p.name for p in parent_dir]}"
    relative = directory.relative_to(MONSTER_ROOT).as_posix()
    reason = SKIP_REASONS.get(relative)
    if reason:
        return None, reason
    return None, "没有可解析的既有 *_frames.tres，且未登记推导规则"


def load_action_maps() -> tuple[dict[str, dict[str, str]], dict[str, dict[str, bool]]]:
    if not ACTION_MAP_PATH.is_file():
        return {}, {}
    data = json.loads(ACTION_MAP_PATH.read_text(encoding="utf-8"))
    maps: dict[str, dict[str, str]] = {}
    loops: dict[str, dict[str, bool]] = {}
    for metadata, entry in data.items():
        if not isinstance(entry, dict) or not isinstance(entry.get("actions"), dict):
            raise MetadataParseError(f"{ACTION_MAP_PATH}: {metadata} 缺少 actions 映射")
        maps[str(metadata)] = {
            str(action): str(sequence) for action, sequence in entry["actions"].items()
        }
        loops[str(metadata)] = {
            str(name): bool(value) for name, value in (entry.get("loop") or {}).items()
        }
    return maps, loops


def collect_targets() -> tuple[list[Target], list[tuple[str, str]]]:
    targets: list[Target] = []
    skipped: list[tuple[str, str]] = []
    action_maps, loop_overrides = load_action_maps()
    for metadata in sorted(MONSTER_ROOT.rglob("metadata.tres")):
        text = metadata.read_text(encoding="utf-8")
        if '"sequences"' not in text:
            continue
        model = load_metadata(metadata)
        if not model.sequences:
            skipped.append(
                (metadata.relative_to(MONSTER_ROOT).as_posix(), "metadata sequences 为空（聚合或占位）")
            )
            continue
        frames_path, reason = resolve_target(metadata)
        if frames_path is None:
            skipped.append((metadata.relative_to(MONSTER_ROOT).as_posix(), reason))
            continue
        targets.append(
            Target(
                metadata=metadata,
                frames_path=frames_path,
                metadata_model=model,
                action_map=action_maps.get(metadata.relative_to(MONSTER_ROOT).as_posix(), {}),
                loop_overrides=loop_overrides.get(
                    metadata.relative_to(MONSTER_ROOT).as_posix(), {}
                ),
            )
        )
    return targets, skipped


def build_expected(target: Target, existing: FramesModel | None) -> FramesModel:
    inherited: dict[str, Animation] = {}
    if existing is not None:
        inherited = {animation.name: animation for animation in existing.animations}
    used_pages = {frame.page for _, frames in target.metadata_model.sequences for frame in frames}
    pages = [page for page in target.metadata_model.pages if page in used_pages]
    animations: list[Animation] = []
    by_name = {name: frames for name, frames in target.metadata_model.sequences}
    for name, frames in target.metadata_model.sequences:
        previous = inherited.get(name)
        if previous is not None:
            loop, speed = previous.loop, previous.speed
        else:
            loop = 1 if name in LOOP_NAMES or name.startswith(LOOP_NAME_PREFIXES) else 0
            speed = target.metadata_model.fps or DEFAULT_SPEED
        animations.append(Animation(name=name, loop=loop, speed=speed, frames=frames))
    for action, sequence in target.action_map.items():
        if action in by_name:
            continue
        frames = by_name.get(sequence)
        if frames is None:
            raise MetadataParseError(
                f"{target.label}: 动作 {action!r} 指向不存在的序列 {sequence!r}"
            )
        source = next((a for a in animations if a.name == sequence), None)
        loop = source.loop if source is not None else 0
        speed = source.speed if source is not None else (target.metadata_model.fps or DEFAULT_SPEED)
        animations.append(Animation(name=action, loop=loop, speed=speed, frames=frames))
    for animation in animations:
        if animation.name in target.loop_overrides:
            animation.loop = 1 if target.loop_overrides[animation.name] else 0
    return FramesModel(pages=pages, animations=animations)


def compare_models(expected: FramesModel, actual: FramesModel) -> list[str]:
    problems: list[str] = []
    expected_names = expected.animation_names()
    actual_names = actual.animation_names()
    if expected_names != actual_names:
        missing = [name for name in expected_names if name not in actual_names]
        extra = [name for name in actual_names if name not in expected_names]
        if missing:
            problems.append(f"缺少动画 {missing[:6]}")
        if extra:
            problems.append(f"多出动画 {extra[:6]}")
        if not missing and not extra:
            problems.append("动画顺序与 metadata sequences 不一致")
    by_name = {animation.name: animation for animation in actual.animations}
    for expected_animation in expected.animations:
        actual_animation = by_name.get(expected_animation.name)
        if actual_animation is None:
            continue
        if len(expected_animation.frames) != len(actual_animation.frames):
            problems.append(
                f"动画 {expected_animation.name!r} 帧数 {len(actual_animation.frames)} "
                f"!= {len(expected_animation.frames)}"
            )
            continue
        for index, (want, got) in enumerate(
            zip(expected_animation.frames, actual_animation.frames)
        ):
            if want != got:
                problems.append(
                    f"动画 {expected_animation.name!r} 第 {index} 帧不一致: "
                    f"{got.page} {got.region} {got.margin} != {want.page} {want.region} {want.margin}"
                )
                break
        if actual_animation.loop != expected_animation.loop:
            problems.append(
                f"动画 {expected_animation.name!r} loop {actual_animation.loop} "
                f"!= {expected_animation.loop}"
            )
    return problems


def png_size(path: Path, cache: dict[Path, tuple[int, int] | None]) -> tuple[int, int] | None:
    if path in cache:
        return cache[path]
    size: tuple[int, int] | None = None
    try:
        header = path.read_bytes()[:24]
        if len(header) == 24 and header[:8] == b"\x89PNG\r\n\x1a\n":
            size = struct.unpack(">II", header[16:24])
    except OSError:
        size = None
    cache[path] = size
    return size


def validate_model(
    model: FramesModel,
    cache: dict[Path, tuple[int, int] | None],
) -> list[str]:
    problems: list[str] = []
    names = model.animation_names()
    if len(set(names)) != len(names):
        duplicates = sorted({name for name in names if names.count(name) > 1})
        problems.append(f"动画名重复: {duplicates[:6]}")
    if len(set(model.pages)) != len(model.pages):
        problems.append("页路径重复")
    for page in model.pages:
        if not page.startswith("res://"):
            problems.append(f"页路径不是 res:// 绝对路径: {page}")
            continue
        source_path = SOURCE / page.removeprefix("res://")
        size = png_size(source_path, cache)
        if size is None:
            problems.append(f"页文件缺失或不是 PNG: {page}")
            continue
        width, height = size
        for animation in model.animations:
            for index, frame in enumerate(animation.frames):
                if frame.page != page:
                    continue
                x, y, w, h = frame.region
                if w <= 0 or h <= 0:
                    problems.append(f"{animation.name}[{index}] 空区域 {frame.region}")
                elif x < 0 or y < 0 or x + w > width or y + h > height:
                    problems.append(
                        f"{animation.name}[{index}] 区域 {frame.region} 超出页 {page} ({width}x{height})"
                    )
    return problems


def render_tres(model: FramesModel, uid: str | None) -> str:
    header = '[gd_resource type="SpriteFrames" format=3'
    if uid:
        header += f' uid="{uid}"'
    header += "]"
    lines: list[str] = [header]
    page_ids: dict[str, str] = {}
    for index, page in enumerate(model.pages):
        ext_id = f"1_page_{index}"
        page_ids[page] = ext_id
        lines.extend(["", f'[ext_resource type="Texture2D" path="{page}" id="{ext_id}"]'])
    sub_ids: list[str] = []
    for index, animation in enumerate(model.animations):
        for frame in animation.frames:
            sub_id = f"AtlasTexture_{len(sub_ids)}"
            sub_ids.append(sub_id)
            x, y, w, h = frame.region
            ml, mt, mr, mb = frame.margin
            lines.extend(
                [
                    "",
                    f'[sub_resource type="AtlasTexture" id="{sub_id}"]',
                    f'atlas = ExtResource("{page_ids[frame.page]}")',
                    f"region = Rect2({x}, {y}, {w}, {h})",
                    f"margin = Rect2({ml}, {mt}, {mr}, {mb})",
                ]
            )
    lines.extend(["", "[resource]"])
    cursor = 0
    animation_blocks: list[str] = []
    for animation in model.animations:
        frame_blocks: list[str] = []
        for _ in animation.frames:
            frame_blocks.append(
                '{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % sub_ids[cursor]
            )
            cursor += 1
        animation_blocks.append(
            '{\n"frames": [%s],\n"loop": %d,\n"name": &"%s",\n"speed": %s\n}'
            % (
                ", ".join(frame_blocks),
                animation.loop,
                animation.name,
                format_float(animation.speed),
            )
        )
    lines.append("animations = [" + animation_blocks[0])
    for block in animation_blocks[1:]:
        lines.append(", " + block)
    lines.append("]")
    return "\n".join(lines) + "\n"


def format_float(value: float) -> str:
    return f"{value:.1f}"


def collect_registered_uids() -> dict[str, set[str]]:
    """收集工程内已登记的 UID 所有者，供生成前防碰撞。"""
    owners: dict[str, set[str]] = {}

    def register(uid: str, owner: Path) -> None:
        relative = owner.relative_to(SOURCE).as_posix()
        owners.setdefault(uid, set()).add(relative)

    for path in SOURCE.rglob("*.uid"):
        relative = path.relative_to(SOURCE)
        if relative.parts and relative.parts[0] == ".godot":
            continue
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
            match = HEADER_UID_PATTERN.search(head)
            if match:
                register(match.group(1), path)
    return owners


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(content)


def parse_animation_subresources(text: str) -> dict[str, list[str]]:
    return {
        name: TEXTURE_REF_PATTERN.findall(frames_blob)
        for frames_blob, _loop, name, _speed in ANIMATION_PATTERN.findall(text)
    }


def append_action_aliases(target: Target, existing: FramesModel) -> int:
    """在现有资源末尾追加动作别名动画，复用原 SubResource，不改已有动画。"""
    text = target.frames_path.read_text(encoding="utf-8")
    subresources = parse_animation_subresources(text)
    existing_by_name = {animation.name: animation for animation in existing.animations}
    blocks: list[str] = []
    for action, sequence in target.action_map.items():
        if action in subresources:
            continue
        sub_ids = subresources.get(sequence)
        source = existing_by_name.get(sequence)
        if sub_ids is None or source is None:
            raise MetadataParseError(
                f"{target.label}: 动作 {action!r} 的源序列 {sequence!r} 不在现有资源中"
            )
        frame_blocks = ", ".join(
            '{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % sub_id
            for sub_id in sub_ids
        )
        blocks.append(
            ', {\n"frames": [%s],\n"loop": %d,\n"name": &"%s",\n"speed": %s\n}'
            % (frame_blocks, source.loop, action, format_float(source.speed))
        )
    if not blocks:
        return 0
    insert_at = text.rfind("]")
    if insert_at < 0:
        raise MetadataParseError(f"{target.frames_path}: 找不到 animations 数组结尾")
    write_text(target.frames_path, text[:insert_at] + "".join(blocks) + text[insert_at:])
    return len(blocks)


def apply_loop_overrides(target: Target) -> int:
    """按动作映射原地修正动画 loop 标志，不重写帧数据。"""
    if not target.loop_overrides:
        return 0
    text = target.frames_path.read_text(encoding="utf-8")
    updated = text
    for name, loop in target.loop_overrides.items():
        pattern = re.compile(
            r'("loop": )([01])(,\n"name": &"%s")' % re.escape(name)
        )
        updated = pattern.sub(lambda m: m.group(1) + ("1" if loop else "0") + m.group(3), updated)
    if updated == text:
        return 0
    write_text(target.frames_path, updated)
    return 1


def ensure_uid_header(path: Path, uid: str) -> bool:
    """只补/修正资源头 UID，不改动帧数据；返回是否写入。"""
    text = path.read_text(encoding="utf-8")
    match = HEADER_UID_PATTERN.search(text[:512])
    if match:
        if match.group(1) == uid:
            return False
        updated = text[: match.start(1)] + uid + text[match.end(1) :]
    else:
        header_end = text.find("]")
        if header_end < 0 or not text.startswith("[gd_resource"):
            raise MetadataParseError(f"{path}: 资源头无法识别")
        updated = text[:header_end] + f' uid="{uid}"' + text[header_end:]
    write_text(path, updated)
    return True


def write_frames(path: Path, model: FramesModel, uid: str | None) -> None:
    """写入后立即回读，防止转换器产出自己无法解析的资源。"""
    write_text(path, render_tres(model, uid))
    reparsed = parse_frames(path)
    differences = compare_models(model, reparsed)
    if differences:
        raise MetadataParseError(f"{path}: 写入后回读不一致: {differences[:3]}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="怪物 AtlasMetadata → SpriteFrames 构建期转换器")
    parser.add_argument("--check", action="store_true", help="只校验，不写文件（默认）")
    parser.add_argument("--all", action="store_true", help="补齐缺失或与 metadata 不一致的目标")
    parser.add_argument("--rewrite", action="store_true", help="只补/修正全部目标的确定性 UID 头，不改帧数据")
    parser.add_argument("--emit", type=Path, default=None, help="把规范输出写到指定目录（只读源树）")
    parser.add_argument("--only", default=None, help="只处理路径包含该片段的模型")
    parser.add_argument("--report", type=Path, default=None, help="写出 JSON 报告")
    parser.add_argument("--verbose", action="store_true", help="逐条打印跳过原因")
    args = parser.parse_args(argv)

    if not MONSTER_ROOT.is_dir():
        print(f"ERROR 怪物素材目录不存在: {MONSTER_ROOT}", file=sys.stderr)
        return 1

    try:
        targets, skipped = collect_targets()
    except MetadataParseError as error:
        print(f"ERROR {error}", file=sys.stderr)
        return 1

    if args.only:
        needle = args.only.replace("\\", "/")
        targets = [target for target in targets if needle in target.label]

    if not targets:
        print("ERROR 没有匹配的怪物帧目标", file=sys.stderr)
        return 1

    cache: dict[Path, tuple[int, int] | None] = {}
    failures: list[str] = []
    missing: list[str] = []
    legacy_uid = 0
    uid_owners: dict[str, str] = {}
    registered_uids = collect_registered_uids()
    target_paths = {target.frames_path.relative_to(SOURCE).as_posix() for target in targets}
    written: list[str] = []
    emitted: list[str] = []
    checked = 0

    for target in targets:
        expected_uid = target.expected_uid()
        foreign = (
            registered_uids.get(expected_uid, set()) - target_paths
            if args.emit is None
            else set()
        )
        if foreign:
            failures.append(
                f"{target.label}: 期望 UID {expected_uid} 已被 {sorted(foreign)[:3]} 占用"
            )
        existing: FramesModel | None = None
        if target.frames_path.is_file():
            try:
                existing = parse_frames(target.frames_path)
            except MetadataParseError as error:
                failures.append(f"{target.label}: {error}")
                continue
            header_uid = HEADER_UID_PATTERN.search(
                target.frames_path.read_text(encoding="utf-8")[:512]
            )
            if header_uid:
                if header_uid.group(1) != expected_uid:
                    failures.append(
                        f"{target.label}: UID {header_uid.group(1)} != 期望 {expected_uid}"
                    )
                owner = uid_owners.get(header_uid.group(1))
                if owner is not None:
                    failures.append(
                        f"{target.label}: UID {header_uid.group(1)} 与 {owner} 重复"
                    )
                uid_owners[header_uid.group(1)] = target.label
            else:
                legacy_uid += 1
        else:
            missing.append(target.label)

        expected = build_expected(target, existing)
        problems = [f"{target.label}: {item}" for item in validate_model(expected, cache)]
        differences = compare_models(expected, existing) if existing is not None else []
        if not (args.all and existing is not None):
            problems.extend(f"{target.label}: {item}" for item in differences)
        if existing is None and not (args.all or args.rewrite or args.emit is not None):
            problems.append(f"{target.label}: 目标帧资源不存在")
        failures.extend(problems)

        needs_write = existing is None or bool(differences)
        if args.emit is not None:
            relative = target.frames_path.relative_to(SOURCE / "Art/monster").as_posix()
            destination = args.emit / relative
            try:
                write_frames(destination, expected, expected_uid)
            except MetadataParseError as error:
                failures.append(f"{target.label}: {error}")
            else:
                emitted.append(str(destination))
        elif args.all and needs_write:
            try:
                appended = 0
                if existing is not None:
                    appended = append_action_aliases(target, existing)
                    appended += apply_loop_overrides(target)
                    if appended:
                        reparsed = parse_frames(target.frames_path)
                        if not compare_models(expected, reparsed):
                            written.append(str(target.frames_path.relative_to(ROOT)))
                            continue
                write_frames(target.frames_path, expected, expected_uid)
                remaining = compare_models(expected, parse_frames(target.frames_path))
                if remaining:
                    failures.extend(f"{target.label}: {item}" for item in remaining)
            except MetadataParseError as error:
                failures.append(f"{target.label}: {error}")
            else:
                if not failures or not failures[-1].startswith(target.label):
                    written.append(str(target.frames_path.relative_to(ROOT)))
        elif args.rewrite:
            try:
                if ensure_uid_header(target.frames_path, expected_uid):
                    written.append(str(target.frames_path.relative_to(ROOT)))
            except (OSError, MetadataParseError) as error:
                failures.append(f"{target.label}: {error}")
        checked += 1

    report = {
        "checked": checked,
        "targets": len(targets),
        "missing": missing,
        "legacy_uid_missing": legacy_uid,
        "written": written,
        "emitted": emitted,
        "skipped": [{"metadata": path, "reason": reason} for path, reason in skipped],
        "failures": failures,
    }
    if args.report is not None:
        write_text(args.report, json.dumps(report, ensure_ascii=False, indent=2) + "\n")

    if args.verbose:
        for path, reason in skipped:
            print(f"SKIP {path}: {reason}")
    else:
        grouped: dict[str, int] = {}
        for _, reason in skipped:
            grouped[reason] = grouped.get(reason, 0) + 1
        for reason, count in sorted(grouped.items(), key=lambda item: -item[1]):
            print(f"SKIP {count}: {reason}")
    for label in missing:
        print(f"MISSING {label}: 目标 *_frames.tres 不存在{'（--all 将生成）' if args.all else ''}")
    for failure in failures:
        print(f"FAIL {failure}")
    print(
        f"怪物帧转换器：目标 {len(targets)}，校验 {checked}，缺失 {len(missing)}，"
        f"失败 {len(failures)}，写入 {len(written)}，输出 {len(emitted)}，"
        f"历史无 UID {legacy_uid}，跳过 {len(skipped)}"
    )
    if args.check or not (args.all or args.rewrite or args.emit):
        return 1 if failures else 0
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""构建期生成关卡布局资源与索引。

数据源：`scripts/level_layout_sources.json`（构建期输入，不进入运行时）。
输出：
- `source/Script/data/level_layouts/<level_id>.tres`
- `source/Script/data/level_layout_catalog.tres`

生成规则：
- 只生成显式登记的关卡；未登记关卡运行时沿用现有逻辑；
- 不生成占位布局，任何 schema/范围/依赖错误直接失败；
- 重复运行逐字节一致；`--check` 只比较，不写文件。

用法：
    python scripts/convert_level_layout_catalog.py
    python scripts/convert_level_layout_catalog.py --check
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
SOURCE_PATH = ROOT / "scripts" / "level_layout_sources.json"
LAYOUT_DIR = SOURCE / "Script/data/level_layouts"
CATALOG_PATH = SOURCE / "Script/data/level_layout_catalog.tres"
SCHEMA_ID = "level_layout_sources"
SCHEMA_VERSION = 1
UID_ALPHABET = "abcdefghijklmnopqrstuvwxy012345678"
UID_BASE = len(UID_ALPHABET)
UID_MAX_VALUE = 0x7FFFFFFFFFFFFFFF


class LayoutError(ValueError):
    pass


def uid_text(value: int) -> str:
    value &= UID_MAX_VALUE
    chars: list[str] = []
    while True:
        chars.append(UID_ALPHABET[value % UID_BASE])
        value //= UID_BASE
        if value == 0:
            break
    return "uid://" + "".join(reversed(chars))


def level_uid(level_id: str) -> str:
    return uid_text(int.from_bytes(hashlib.sha256(("bhyh:level_layout:" + level_id).encode()).digest()[:8], "big"))


def catalog_uid() -> str:
    return uid_text(int.from_bytes(hashlib.sha256(b"bhyh:level_layout_catalog").digest()[:8], "big"))


def number(value: object) -> str:
    if isinstance(value, bool):
        raise LayoutError(f"布尔值不能作为数值坐标: {value!r}")
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        if value == int(value):
            return str(int(value))
        return repr(value)
    raise LayoutError(f"坐标不是数值: {value!r}")


def vector2(value: object, label: str) -> str:
    if not isinstance(value, list) or len(value) != 2:
        raise LayoutError(f"{label} 必须是 [x, y]")
    return "Vector2(%s, %s)" % (number(value[0]), number(value[1]))


def rect2(value: object, label: str) -> str:
    if not isinstance(value, list) or len(value) != 4:
        raise LayoutError(f"{label} 必须是 [x, y, w, h]")
    return "Rect2(%s, %s, %s, %s)" % tuple(number(item) for item in value)


def packed_ints(values: object, label: str) -> str:
    if not isinstance(values, list) or not values:
        raise LayoutError(f"{label} 必须是非空数组")
    for value in values:
        if not isinstance(value, int) or isinstance(value, bool) or value <= 0:
            raise LayoutError(f"{label} 包含非法怪物 id: {value!r}")
    return "PackedInt32Array(%s)" % ", ".join(str(value) for value in values)


def packed_strings(values: object, label: str) -> str:
    if not isinstance(values, list) or any(not isinstance(item, str) for item in values):
        raise LayoutError(f"{label} 必须是字符串数组")
    return "PackedStringArray(%s)" % ", ".join('"%s"' % item for item in values)


def packed_vectors(values: object, label: str) -> str:
    if not isinstance(values, list) or not values:
        raise LayoutError(f"{label} 必须是非空数组")
    flat: list[str] = []
    for value in values:
        if not isinstance(value, list) or len(value) != 2:
            raise LayoutError(f"{label} 包含非法坐标: {value!r}")
        flat.extend((number(value[0]), number(value[1])))
    return "PackedVector2Array(%s)" % ", ".join(flat)


def require_rect_inside(rect: list[float], size: list[float], label: str) -> None:
    x, y, width, height = rect
    if width <= 0 or height <= 0:
        raise LayoutError(f"{label} 尺寸必须为正: {rect}")
    if x < 0 or y < 0 or x + width > size[0] + 1e-6 or y + height > size[1] + 1e-6:
        raise LayoutError(f"{label} 超出布局范围: {rect} / {size}")


def validate_level(scene_path: str, level: dict) -> None:
    if not scene_path.startswith("res://Scene/level/") or not scene_path.endswith(".tscn"):
        raise LayoutError(f"非法关卡场景路径: {scene_path}")
    if not (SOURCE / scene_path.removeprefix("res://")).is_file():
        raise LayoutError(f"关卡场景不存在: {scene_path}")
    level_id = level.get("level_id")
    if not isinstance(level_id, str) or not level_id or not level_id.replace("_", "").isalnum():
        raise LayoutError(f"{scene_path}: level_id 非法: {level_id!r}")
    size = level.get("layout_size")
    if not isinstance(size, list) or len(size) != 2 or any(not isinstance(item, (int, float)) or item <= 0 for item in size):
        raise LayoutError(f"{scene_path}: layout_size 非法: {size!r}")
    packed_vectors(level.get("player_birth_points"), f"{scene_path}: player_birth_points")
    stages = level.get("stages")
    if not isinstance(stages, list) or not 1 <= len(stages) <= 30:
        raise LayoutError(f"{scene_path}: stages 必须为 1..30 项")
    point_ids: set[int] = set()
    for index, stage in enumerate(stages, 1):
        if not isinstance(stage, dict) or stage.get("index") != index:
            raise LayoutError(f"{scene_path}: stage 索引必须从 1 连续，实际 {stage!r}")
        for key in ("screen_rect", "trigger_rect", "spawn_trigger_rect"):
            rect = stage.get(key)
            if not isinstance(rect, list) or len(rect) != 4:
                raise LayoutError(f"{scene_path}: stage {index} {key} 非法")
            require_rect_inside(rect, size, f"{scene_path}: stage {index} {key}")
        packed_strings(stage.get("close_walls"), f"{scene_path}: stage {index} close_walls")
        packed_strings(stage.get("open_walls"), f"{scene_path}: stage {index} open_walls")
        spawns = stage.get("spawn_points")
        if not isinstance(spawns, list):
            raise LayoutError(f"{scene_path}: stage {index} spawn_points 必须是数组")
        for spawn in spawns:
            if not isinstance(spawn, dict):
                raise LayoutError(f"{scene_path}: stage {index} 刷怪点不是对象")
            point_id = spawn.get("point_id")
            if not isinstance(point_id, int) or isinstance(point_id, bool) or point_id <= 0:
                raise LayoutError(f"{scene_path}: stage {index} point_id 非法: {point_id!r}")
            if point_id in point_ids:
                raise LayoutError(f"{scene_path}: point_id 重复: {point_id}")
            point_ids.add(point_id)
            packed_ints(spawn.get("monster_ids"), f"{scene_path}: point {point_id} monster_ids")
            position = spawn.get("position")
            if not isinstance(position, list) or len(position) != 2:
                raise LayoutError(f"{scene_path}: point {point_id} position 非法")
            count = spawn.get("count")
            if not isinstance(count, int) or isinstance(count, bool) or count < 1:
                raise LayoutError(f"{scene_path}: point {point_id} count 非法")
            for key in ("delay", "interval"):
                value = spawn.get(key, 0.0)
                if not isinstance(value, (int, float)) or value < 0:
                    raise LayoutError(f"{scene_path}: point {point_id} {key} 非法")
    for stage in stages:
        for spawn in stage["spawn_points"]:
            for key in ("after_spawn", "after_dead"):
                dependency = spawn.get(key, 0)
                if not isinstance(dependency, int) or dependency < 0:
                    raise LayoutError(f"{scene_path}: point {spawn['point_id']} {key} 非法")
                if dependency and dependency not in point_ids:
                    raise LayoutError(f"{scene_path}: point {spawn['point_id']} 依赖不存在的点 {dependency}")


def spawn_content(spawn: dict, index: int) -> list[str]:
    return [
        '[sub_resource type="Resource" id="spawn_%d"]' % index,
        'script = ExtResource("3_spawn")',
        "point_id = %d" % spawn["point_id"],
        "monster_ids = %s" % packed_ints(spawn["monster_ids"], "monster_ids"),
        "position = %s" % vector2(spawn["position"], "position"),
        "count = %d" % spawn["count"],
        "delay = %s" % number(float(spawn.get("delay", 0.0))),
        "interval = %s" % number(float(spawn.get("interval", 0.0))),
        "direction = %d" % int(spawn.get("direction", 0)),
        "after_spawn = %d" % int(spawn.get("after_spawn", 0)),
        "after_dead = %d" % int(spawn.get("after_dead", 0)),
        "ignore_count_multiplier = %s" % ("true" if spawn.get("ignore_count_multiplier", False) else "false"),
        "",
    ]


def level_content(level_id: str, level: dict) -> str:
    stages = level["stages"]
    spawn_blocks: list[str] = []
    stage_blocks: list[str] = []
    spawn_index = 0
    for stage in stages:
        ids: list[int] = []
        for spawn in stage["spawn_points"]:
            spawn_index += 1
            ids.append(spawn_index)
            spawn_blocks.extend(spawn_content(spawn, spawn_index))
        refs = ", ".join('SubResource("spawn_%d")' % value for value in ids)
        stage_blocks.extend(
            [
                '[sub_resource type="Resource" id="stage_%d"]' % stage["index"],
                'script = ExtResource("2_stage")',
                "index = %d" % stage["index"],
                "screen_rect = %s" % rect2(stage["screen_rect"], "screen_rect"),
                "trigger_rect = %s" % rect2(stage["trigger_rect"], "trigger_rect"),
                "spawn_trigger_rect = %s" % rect2(stage["spawn_trigger_rect"], "spawn_trigger_rect"),
                "close_walls = %s" % packed_strings(stage.get("close_walls", []), "close_walls"),
                "open_walls = %s" % packed_strings(stage.get("open_walls", []), "open_walls"),
                'spawn_points = Array[ExtResource("3_spawn")]([%s])' % refs,
                "",
            ]
        )
    stage_refs = ", ".join('SubResource("stage_%d")' % stage["index"] for stage in stages)
    lines = [
        '[gd_resource type="Resource" script_class="LevelLayoutEntry" load_steps=%d format=3 uid="%s"]'
        % (3 + spawn_index + len(stages), level_uid(level_id)),
        "",
        '[ext_resource type="Script" path="res://Script/data/level_layout_entry.gd" id="1_entry"]',
        '[ext_resource type="Script" path="res://Script/data/level_stage_spec.gd" id="2_stage"]',
        '[ext_resource type="Script" path="res://Script/data/level_spawn_point.gd" id="3_spawn"]',
        "",
    ]
    lines.extend(spawn_blocks)
    lines.extend(stage_blocks)
    lines.extend(
        [
            "[resource]",
            'script = ExtResource("1_entry")',
            "level_id = &\"%s\"" % level_id,
            "layout_size = %s" % vector2(level["layout_size"], "layout_size"),
            "player_birth_points = %s" % packed_vectors(level["player_birth_points"], "player_birth_points"),
            'stages = Array[ExtResource("2_stage")]([%s])' % stage_refs,
            "exit_rect = %s" % rect2(level["exit_rect"], "exit_rect"),
            'exit_open_when = &"%s"' % str(level.get("exit_open_when", "stage_clear")),
            "",
        ]
    )
    return "\n".join(lines)


def catalog_content(entries: list[tuple[str, str]]) -> str:
    lines = [
        '[gd_resource type="Resource" script_class="LevelLayoutCatalog" load_steps=2 format=3 uid="%s"]' % catalog_uid(),
        "",
        '[ext_resource type="Script" path="res://Script/data/level_layout_catalog.gd" id="1_catalog"]',
        "",
        "[resource]",
        'script = ExtResource("1_catalog")',
        "layout_paths = {",
    ]
    for scene_path, layout_path in entries:
        lines.append('\t&"%s": &"%s",' % (scene_path, layout_path))
    lines.extend(["}", ""])
    return "\n".join(lines)


def load_sources() -> dict:
    if not SOURCE_PATH.is_file():
        raise LayoutError(f"缺少布局源清单: {SOURCE_PATH.relative_to(ROOT)}")
    try:
        data = json.loads(SOURCE_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise LayoutError(f"布局源清单不是合法 JSON: {error}") from error
    if not isinstance(data, dict) or data.get("schema_id") != SCHEMA_ID:
        raise LayoutError("布局源清单 schema_id 不匹配")
    if data.get("schema_version") != SCHEMA_VERSION:
        raise LayoutError("布局源清单 schema_version 不匹配")
    levels = data.get("levels")
    if not isinstance(levels, dict) or not levels:
        raise LayoutError("布局源清单 levels 必须是非空对象")
    return levels


def run(check_only: bool) -> int:
    if not SOURCE.is_dir():
        print(f"[FAIL] 工程目录不存在: {SOURCE}", file=sys.stderr)
        return 2
    try:
        levels = load_sources()
        expected: list[tuple[Path, str, str]] = []
        entries: list[tuple[str, str]] = []
        for scene_path in sorted(levels):
            level = levels[scene_path]
            validate_level(scene_path, level)
            layout_id = level["level_id"]
            layout_path = LAYOUT_DIR / (layout_id + ".tres")
            res_path = "res://" + layout_path.relative_to(SOURCE).as_posix()
            expected.append((layout_path, level_content(layout_id, level), layout_id))
            entries.append((scene_path, res_path))
        catalog = catalog_content(entries)
    except LayoutError as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1

    outputs = [(path, content, f"布局资源 {level_id}") for path, content, level_id in expected]
    outputs.append((CATALOG_PATH, catalog, "布局索引"))
    if check_only:
        for path, content, label in outputs:
            if not path.is_file():
                print(f"[FAIL] 缺少{label}: {path.relative_to(ROOT)}", file=sys.stderr)
                return 1
            if path.read_text(encoding="utf-8") != content:
                print(f"[FAIL] {label}已过期: {path.relative_to(ROOT)}", file=sys.stderr)
                return 1
        print(f"[OK] 关卡布局校验通过: {len(expected)} 个关卡 / {len(entries)} 个索引")
        return 0
    for path, content, _label in outputs:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")
    print(f"[OK] 关卡布局已生成: {len(expected)} 个关卡 / {len(entries)} 个索引")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="生成关卡布局资源与索引")
    parser.add_argument("--check", action="store_true", help="只校验输出是否最新，不写文件")
    args = parser.parse_args()
    return run(args.check)


if __name__ == "__main__":
    sys.exit(main())

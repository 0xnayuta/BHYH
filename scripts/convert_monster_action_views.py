#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把既有 SpriteFrames 的 `play` 动画投影为怪物动作视图资源。

数据源：`scripts/monster_action_views.json`。每个输出资源声明：
- `animations.<action>.source`：源 `*_frames.tres`（只含 `play`）；
- `frames`：从源 `play` 取用的帧索引；
- `durations`：可选逐帧时长；省略时沿用源帧时长；
- `loop`、`speed`。

输出沿用既有目录，动画名等于怪物动作名。资源头写入由输出路径派生的
确定性 UID。`--check` 逐字比较；`--all` 生成。
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
VIEWS_PATH = ROOT / "scripts/monster_action_views.json"

UID_ALPHABET = "abcdefghijklmnopqrstuvwxy012345678"
UID_BASE = len(UID_ALPHABET)
UID_MAX_VALUE = 0x7FFFFFFFFFFFFFFF
EXT_RESOURCE_PATTERN = re.compile(
    r'^\[ext_resource type="Texture2D" path="([^"]+)" id="([^"]+)"\]$', re.M
)
FRAME_REF_PATTERN = re.compile(r'"texture": ExtResource\("([^"]+)"\)')


def source_path(resource_path: str) -> Path:
    if not resource_path.startswith("res://"):
        raise ValueError(f"路径必须是 res:// 形式: {resource_path}")
    return SOURCE / resource_path.removeprefix("res://")


def parse_source_frames(resource_path: str) -> list[tuple[str, float]]:
    text = source_path(resource_path).read_text(encoding="utf-8")
    ids = {ext_id: path for path, ext_id in EXT_RESOURCE_PATTERN.findall(text)}
    frames: list[tuple[str, float]] = []
    blocks = re.findall(r'\{\n"duration": ([0-9.]+),\n"texture": ExtResource\("([^"]+)"\)\n\}', text)
    for duration, ext_id in blocks:
        path = ids.get(ext_id)
        if path is None:
            raise ValueError(f"{resource_path}: 帧引用了未声明的 ExtResource {ext_id}")
        frames.append((path, float(duration)))
    if not frames:
        raise ValueError(f"{resource_path}: 没有解析到帧")
    return frames


def uid_for_identity(identity: str) -> str:
    digest = hashlib.sha256(("bhyh:" + identity).encode("utf-8")).digest()
    value = int.from_bytes(digest[:8], "big") & UID_MAX_VALUE
    if value == 0:
        value = 1
    chars: list[str] = []
    while True:
        chars.append(UID_ALPHABET[value % UID_BASE])
        value //= UID_BASE
        if value == 0:
            break
    return "uid://" + "".join(reversed(chars))


def format_float(value: float) -> str:
    text = f"{value:.6f}".rstrip("0").rstrip(".")
    return text if text else "0"


def build_tres(view_path: str, spec: dict) -> str:
    animations: list[tuple[str, bool, float, list[tuple[str, float]]]] = []
    unique_paths: list[str] = []
    for action, config in spec["animations"].items():
        indices = [int(index) for index in config["frames"]]
        durations = config.get("durations")
        if durations is not None and len(durations) != len(indices):
            raise ValueError(f"{action}: frames 与 durations 长度不一致")
        frames: list[tuple[str, float]] = []
        if "pattern" in config:
            pattern = str(config["pattern"])
            for position, index in enumerate(indices):
                path = pattern % index
                if not source_path(path).is_file():
                    raise ValueError(f"{action}: 缺少帧文件 {path}")
                duration = float(durations[position]) if durations is not None else 1.0
                frames.append((path, duration))
                if path not in unique_paths:
                    unique_paths.append(path)
        else:
            source_frames = parse_source_frames(config["source"])
            for position, index in enumerate(indices):
                if not 0 <= index < len(source_frames):
                    raise ValueError(f"{action}: 帧索引 {index} 越界 ({len(source_frames)} 帧)")
                path, source_duration = source_frames[index]
                duration = float(durations[position]) if durations is not None else source_duration
                frames.append((path, duration))
                if path not in unique_paths:
                    unique_paths.append(path)
        animations.append((action, bool(config["loop"]), float(config["speed"]), frames))

    uid = uid_for_identity("monster_action_view|" + view_path)
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={len(unique_paths) + 1} format=3 uid="{uid}"]',
        "",
    ]
    for index, path in enumerate(unique_paths, 1):
        lines.append(f'[ext_resource type="Texture2D" path="{path}" id="{index}"]')
    ids = {path: index for index, path in enumerate(unique_paths, 1)}
    blocks: list[str] = []
    for action, looped, speed, frames in animations:
        entries = ", ".join(
            '{\n"duration": %s,\n"texture": ExtResource("%d")\n}'
            % (format_float(duration), ids[path])
            for path, duration in frames
        )
        blocks.append(
            '{\n"frames": [%s],\n"loop": %s,\n"name": &"%s",\n"speed": %s\n}'
            % (entries, "true" if looped else "false", action, format_float(speed))
        )
    lines.extend(["", "[resource]"])
    lines.append("animations = [" + blocks[0])
    for block in blocks[1:]:
        lines.append(", " + block)
    lines.append("]")
    return "\n".join(lines) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="怪物动作视图构建期转换器")
    parser.add_argument("--all", action="store_true", help="生成全部登记资源")
    parser.add_argument("--check", action="store_true", help="只校验输出存在且内容一致")
    args = parser.parse_args(argv)

    views = json.loads(VIEWS_PATH.read_text(encoding="utf-8"))
    passed = True
    for view_path, spec in views.items():
        output = source_path(view_path)
        try:
            content = build_tres(view_path, spec)
        except (OSError, ValueError, KeyError) as error:
            print(f"[FAIL] {view_path}: {error}", file=sys.stderr)
            passed = False
            continue
        if args.check:
            if not output.is_file():
                print(f"[FAIL] 缺少构建期动作视图: {output.relative_to(ROOT)}", file=sys.stderr)
                passed = False
                continue
            if output.read_text(encoding="utf-8") != content:
                print(f"[FAIL] 构建期动作视图已过期: {output.relative_to(ROOT)}", file=sys.stderr)
                passed = False
                continue
            print(f"[OK] {output.relative_to(ROOT)}")
            continue
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(content, encoding="utf-8", newline="\n")
        print(f"[OK] {output.relative_to(ROOT)}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())

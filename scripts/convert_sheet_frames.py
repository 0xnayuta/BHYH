#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把单张纹理 sheet 的固定网格帧转换为构建期 SpriteFrames .tres。

适用于无法拆成独立 PNG 的纵向 sheet：每个动画帧由 AtlasTexture 子资源
引用同一张纹理，运行时只加载生成后的 SpriteFrames。输出位于 Art 私有
目录，不进入公开仓库。
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"

PROFILES: tuple[dict[str, object], ...] = (
    {
        "name": "qlsword_model",
        "texture": "res://Art/magic_weapon/magic_weapon_qlsword/official/magic_big_sword_bmd.png",
        "frame_width": 100,
        "frame_height": 150,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 5.0},
            {"name": "hit", "frame": 1, "loop": True, "speed": 5.0},
        ],
        "output": "res://Art/magic_weapon/magic_weapon_qlsword/official/magic_big_sword_frames.tres",
    },
    {
        "name": "taiji_model",
        "texture": "res://Art/magic_weapon/taiji_bagua/magic_bagua_bmd.png",
        "frame_width": 50,
        "frame_height": 50,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 5.0},
            {"name": "hit", "frame": 1, "loop": True, "speed": 5.0},
        ],
        "output": "res://Art/magic_weapon/taiji_bagua/magic_bagua_frames.tres",
    },
)


def source_path(resource_path: str) -> Path:
    if not resource_path.startswith("res://"):
        raise ValueError(f"路径必须是 res:// 形式: {resource_path}")
    return SOURCE / resource_path.removeprefix("res://")


def build_tres(profile: dict[str, object]) -> str:
    texture = str(profile["texture"])
    texture_path = source_path(texture)
    if not texture_path.is_file():
        raise FileNotFoundError(f"缺少纹理: {texture_path.relative_to(ROOT)}")
    frame_width = int(profile["frame_width"])
    frame_height = int(profile["frame_height"])
    frame_count = int(profile["frame_count"])
    if frame_width <= 0 or frame_height <= 0 or frame_count <= 0:
        raise ValueError("帧宽、帧高和帧数量必须为正数")

    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{texture}" id="1"]',
        "",
    ]
    for index in range(frame_count):
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{index + 1}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2(0, {index * frame_height}, {frame_width}, {frame_height})",
                "",
            ]
        )

    animations: list[str] = []
    for animation in profile["animations"]:
        assert isinstance(animation, dict)
        frame_index = int(animation["frame"])
        if frame_index < 0 or frame_index >= frame_count:
            raise ValueError(f"动画帧越界: {animation['name']} -> {frame_index}")
        animations.append(
            "{\n"
            f'"frames": [{{\n"duration": 1.0,\n"texture": SubResource("AtlasTexture_{frame_index + 1}")\n}}],\n'
            f'"loop": {"true" if bool(animation.get("loop", True)) else "false"},\n'
            f'"name": &"{animation["name"]}",\n'
            f'"speed": {str(animation.get("speed", 5.0))}\n'
            "}"
        )
    lines.extend(["[resource]", "animations = [" + ", ".join(animations) + "]", ""])
    return "\n".join(lines)


def write_profile(profile: dict[str, object], check_only: bool) -> bool:
    name = str(profile["name"])
    output = source_path(str(profile["output"]))
    try:
        content = build_tres(profile)
    except (OSError, ValueError) as error:
        print(f"[FAIL] {name}: {error}", file=sys.stderr)
        return False
    if check_only:
        if not output.is_file():
            print(f"[FAIL] 缺少构建期 SpriteFrames: {output.relative_to(ROOT)}", file=sys.stderr)
            return False
        if output.read_text(encoding="utf-8") != content:
            print(f"[FAIL] 构建期 SpriteFrames 已过期: {output.relative_to(ROOT)}", file=sys.stderr)
            return False
        print(f"[OK] {name}: {output.relative_to(ROOT)}")
        return True
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8", newline="\n")
    print(f"[OK] {name}: {output.relative_to(ROOT)}")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="生成纹理 sheet 的构建期 SpriteFrames")
    parser.add_argument("--check", action="store_true", help="只校验输出存在且内容一致")
    args = parser.parse_args()
    passed = True
    for profile in PROFILES:
        passed = write_profile(profile, args.check) and passed
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())

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
        "name": "lyfb_awaken_skill07_fallback",
        "texture": "res://Art/hero_picture/role_2/lyfb_awaken/runtime/hero_f_5012_skill.png",
        "regions": [
            (503, 2005, 113, 38),
            (1878, 1976, 160, 67),
            (1783, 1839, 210, 71),
            (938, 1793, 220, 73),
            (512, 1724, 236, 78),
            (854, 1627, 230, 82),
            (1255, 1698, 238, 79),
            (1238, 1613, 218, 83),
            (750, 1722, 183, 80),
            (1838, 1758, 180, 79),
            (1160, 1791, 165, 75),
            (2, 1821, 167, 71),
            (1790, 1912, 169, 62),
            (167, 2022, 168, 21),
            (106, 2027, 59, 16),
            (2, 2030, 42, 13),
        ],
        "animations": [
            {
                "name": "skill07",
                "frames": list(range(16)),
                "durations": [1.0] * 16,
                "loop": False,
                "speed": 30.0,
            }
        ],
        "output": "res://Art/hero_picture/role_2/lyfb_awaken/runtime/lyfb_awaken_skill07_frames.tres",
    },
    {
        "name": "nezha_yin_yang_sword_yin",
        "texture": "res://Art/hero_picture/role_6/effects/yin_yang_swords.png",
        "regions": [(0, 0, 154, 53)],
        "animations": [
            {"name": "yinYang_sword", "frames": [0], "durations": [1.0], "loop": False, "speed": 1.0}
        ],
        "output": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_sword_yin_frames.tres",
    },
    {
        "name": "nezha_yin_yang_sword_yang",
        "texture": "res://Art/hero_picture/role_6/effects/yin_yang_swords.png",
        "regions": [(154, 0, 154, 53)],
        "animations": [
            {"name": "yinYang_sword", "frames": [0], "durations": [1.0], "loop": False, "speed": 1.0}
        ],
        "output": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_sword_yang_frames.tres",
    },
    {
        "name": "nezha_yin_yang_aura",
        "texture": "res://Art/hero_picture/role_6/effects/yin_yang_aura.png",
        "regions": [((index % 4) * 300, (index // 4) * 150, 300, 150) for index in range(8)],
        "animations": [
            {
                "name": "yinYang_aura_toggle",
                "frames": list(range(8)),
                "durations": [2.0] * 8,
                "loop": False,
                "speed": 30.0,
            },
            {
                "name": "yinYang_aura_yin",
                "frames": list(range(4)),
                "durations": [2.0] * 4,
                "loop": False,
                "speed": 30.0,
            },
            {
                "name": "yinYang_aura_yang",
                "frames": list(range(4, 8)),
                "durations": [2.0] * 4,
                "loop": False,
                "speed": 30.0,
            },
        ],
        "output": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_aura_frames.tres",
    },
    {
        "name": "nezha_yin_yang_launch_yin",
        "texture": "res://Art/hero_picture/role_6/effects/yin_yang_launch.png",
        "regions": [((index % 3) * 256, (index // 3) * 180, 256, 180) for index in range(12)],
        "animations": [
            {
                "name": "yinYang_launch",
                "frames": list(range(6)),
                "durations": [1.0, 1.0, 2.0, 2.0, 2.0, 2.0],
                "loop": False,
                "speed": 30.0,
            }
        ],
        "output": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_launch_yin_frames.tres",
    },
    {
        "name": "nezha_yin_yang_launch_yang",
        "texture": "res://Art/hero_picture/role_6/effects/yin_yang_launch.png",
        "regions": [((index % 3) * 256, (index // 3) * 180, 256, 180) for index in range(12)],
        "animations": [
            {
                "name": "yinYang_launch",
                "frames": list(range(6, 12)),
                "durations": [1.0, 1.0, 2.0, 2.0, 2.0, 2.0],
                "loop": False,
                "speed": 30.0,
            }
        ],
        "output": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_launch_yang_frames.tres",
    },
    {
        "name": "eight_immortal_bjs_model",
        "texture": "res://Art/magic_weapon/eight_immortal/bjs/model.png",
        "frame_width": 60,
        "frame_height": 60,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 1.0},
            {"name": "hit", "frames": [0, 1], "loop": False, "speed": 12.0},
        ],
        "output": "res://Art/magic_weapon/eight_immortal/bjs/model_frames.tres",
    },
    {
        "name": "eight_immortal_dkhl_model",
        "texture": "res://Art/magic_weapon/eight_immortal/dkhl/model.png",
        "frame_width": 50,
        "frame_height": 50,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 1.0},
            {"name": "hit", "frames": [0, 1], "loop": False, "speed": 12.0},
        ],
        "output": "res://Art/magic_weapon/eight_immortal/dkhl/model_frames.tres",
    },
    {
        "name": "eight_immortal_hehua_model",
        "texture": "res://Art/magic_weapon/eight_immortal/hehua/model.png",
        "frame_width": 50,
        "frame_height": 50,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 1.0},
            {"name": "hit", "frames": [0, 1], "loop": False, "speed": 12.0},
        ],
        "output": "res://Art/magic_weapon/eight_immortal/hehua/model_frames.tres",
    },
    {
        "name": "eight_immortal_sxyg_model",
        "texture": "res://Art/magic_weapon/eight_immortal/sxyg/model.png",
        "frame_width": 50,
        "frame_height": 80,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 1.0},
            {"name": "hit", "frames": [0, 1], "loop": False, "speed": 12.0},
        ],
        "output": "res://Art/magic_weapon/eight_immortal/sxyg/model_frames.tres",
    },
    {
        "name": "eight_immortal_ywhl_model",
        "texture": "res://Art/magic_weapon/eight_immortal/ywhl/model.png",
        "frame_width": 60,
        "frame_height": 70,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 1.0},
            {"name": "hit", "frames": [0, 1], "loop": False, "speed": 12.0},
        ],
        "output": "res://Art/magic_weapon/eight_immortal/ywhl/model_frames.tres",
    },
    {
        "name": "eight_immortal_yyb_model",
        "texture": "res://Art/magic_weapon/eight_immortal/yyb/model.png",
        "frame_width": 60,
        "frame_height": 70,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 1.0},
            {"name": "hit", "frames": [0, 1], "loop": False, "speed": 12.0},
        ],
        "output": "res://Art/magic_weapon/eight_immortal/yyb/model_frames.tres",
    },
    {
        "name": "eight_immortal_yyzlj_model",
        "texture": "res://Art/magic_weapon/eight_immortal/yyzlj/model.png",
        "frame_width": 51,
        "frame_height": 75,
        "frame_count": 4,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 1.0},
            {"name": "hit1", "frame": 1, "loop": True, "speed": 5.0},
            {"name": "hit2", "frame": 2, "loop": True, "speed": 5.0},
            {"name": "hit3", "frame": 3, "loop": True, "speed": 5.0},
        ],
        "output": "res://Art/magic_weapon/eight_immortal/yyzlj/model_frames.tres",
    },
    {
        "name": "eight_immortal_zhyx_model",
        "texture": "res://Art/magic_weapon/eight_immortal/zhyx/model.png",
        "frame_width": 80,
        "frame_height": 80,
        "frame_count": 2,
        "animations": [
            {"name": "wait", "frame": 0, "loop": True, "speed": 1.0},
            {"name": "hit", "frames": [0, 1], "loop": False, "speed": 12.0},
        ],
        "output": "res://Art/magic_weapon/eight_immortal/zhyx/model_frames.tres",
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

    explicit_regions = profile.get("regions")
    if explicit_regions is not None:
        if not isinstance(explicit_regions, list) or not explicit_regions:
            raise ValueError("regions 必须是非空数组")
        regions: list[tuple[int, int, int, int]] = []
        for region in explicit_regions:
            if not isinstance(region, (list, tuple)) or len(region) != 4:
                raise ValueError(f"非法 region: {region}")
            x, y, width, height = (int(value) for value in region)
            if width <= 0 or height <= 0:
                raise ValueError(f"非法 region 尺寸: {region}")
            regions.append((x, y, width, height))
    else:
        frame_width = int(profile["frame_width"])
        frame_height = int(profile["frame_height"])
        frame_count = int(profile["frame_count"])
        if frame_width <= 0 or frame_height <= 0 or frame_count <= 0:
            raise ValueError("帧宽、帧高和帧数量必须为正数")
        regions = [(0, index * frame_height, frame_width, frame_height) for index in range(frame_count)]

    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={len(regions) + 2} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{texture}" id="1"]',
        "",
    ]
    for index, (x, y, width, height) in enumerate(regions):
        lines.extend(
            [
                f'[sub_resource type="AtlasTexture" id="AtlasTexture_{index + 1}"]',
                'atlas = ExtResource("1")',
                f"region = Rect2({x}, {y}, {width}, {height})",
                "",
            ]
        )

    animations: list[str] = []
    for animation in profile["animations"]:
        assert isinstance(animation, dict)
        frame_indices = animation.get("frames", [animation.get("frame", 0)])
        if not isinstance(frame_indices, list) or not frame_indices:
            raise ValueError(f"动画缺少帧: {animation['name']}")
        durations = animation.get("durations", [1.0] * len(frame_indices))
        if not isinstance(durations, list) or len(durations) != len(frame_indices):
            raise ValueError(f"动画 duration 数量不匹配: {animation['name']}")
        frame_entries: list[str] = []
        for frame_value, duration in zip(frame_indices, durations):
            frame_index = int(frame_value)
            if frame_index < 0 or frame_index >= len(regions):
                raise ValueError(f"动画帧越界: {animation['name']} -> {frame_index}")
            frame_entries.append(
                '{\n"duration": %s,\n"texture": SubResource("AtlasTexture_%d")\n}'
                % (str(duration), frame_index + 1)
            )
        animations.append(
            "{\n"
            f'"frames": [{", ".join(frame_entries)}],\n'
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

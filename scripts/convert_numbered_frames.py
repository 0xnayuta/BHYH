#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把连续编号 PNG 序列转换为构建期 SpriteFrames .tres。

本工具与具体角色无关：既可通过 --pattern/--count/--output 处理任意序列，
也可用 --all 生成项目当前登记的技能帧。

源路径与输出路径均使用 res:// 形式；源 PNG 位于 Art 私有目录，输出也
不进入公开仓库。生成后由角色 Manifest 预热，运行时只加载 SpriteFrames。
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"

PROFILES: tuple[dict[str, object], ...] = (
    {
        "name": "bi_luo_tian_cast",
        "pattern": "res://Art/hero_picture/role_4/bi_luo_tian/cast/cast_%02d.png",
        "count": 51,
        "fps": 60.0,
        "output": "res://Art/hero_picture/role_4/bi_luo_tian/cast/cast_frames.tres",
    },
    {
        "name": "bi_luo_tian_hit",
        "pattern": "res://Art/hero_picture/role_4/bi_luo_tian/hit/hit_%02d.png",
        "count": 11,
        "fps": 22.0,
        "output": "res://Art/hero_picture/role_4/bi_luo_tian/hit/hit_frames.tres",
        "tail_start": 7,
        "tail_duration": 0.35,
    },
    {
        "name": "lei_ting_jie_zhen_formation",
        "pattern": "res://Art/hero_picture/role_5/lei_ting_jie_zhen/formation_spine/formation_%02d.png",
        "count": 66,
        "fps": 30.0,
        "output": "res://Art/hero_picture/role_5/lei_ting_jie_zhen/formation_spine/formation_frames.tres",
    },
    {
        "name": "lei_ting_jie_zhen_lightning",
        "pattern": "res://Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_%02d.png",
        "count": 47,
        "fps": 30.0,
        "output": "res://Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_frames.tres",
    },
    {
        "name": "level46_bg30_frames",
        "pattern": "res://Art/level/game_3_level/level_xinshou/bg30_frames/%04d.png",
        "count": 30,
        "source_indices": list(range(1, 31)),
        "fps": 30.0,
        "loop": True,
        "animation": "play",
        "output": "res://Art/level/game_3_level/level_xinshou/bg30_frames/play_frames.tres",
    },
    {
        "name": "level46_bg12_frames",
        "pattern": "res://Art/level/game_3_level/level_xinshou/bg12_frames/%04d.png",
        "count": 13,
        "source_indices": list(range(1, 14)),
        "fps": 30.0,
        "loop": True,
        "animation": "play",
        "output": "res://Art/level/game_3_level/level_xinshou/bg12_frames/play_frames.tres",
    },
    {
        "name": "level46_bg13_frames",
        "pattern": "res://Art/level/game_3_level/level_xinshou/bg13_frames/%04d.png",
        "count": 13,
        "source_indices": list(range(1, 14)),
        "fps": 30.0,
        "loop": True,
        "animation": "play",
        "output": "res://Art/level/game_3_level/level_xinshou/bg13_frames/play_frames.tres",
    },
    {
        "name": "level46_bg14_frames",
        "pattern": "res://Art/level/game_3_level/level_xinshou/bg14_frames/%04d.png",
        "count": 13,
        "source_indices": list(range(1, 14)),
        "fps": 30.0,
        "loop": True,
        "animation": "play",
        "output": "res://Art/level/game_3_level/level_xinshou/bg14_frames/play_frames.tres",
    },
    {
        "name": "level46_bg15_frames",
        "pattern": "res://Art/level/game_3_level/level_xinshou/bg15_frames/%04d.png",
        "count": 13,
        "source_indices": list(range(1, 14)),
        "fps": 30.0,
        "loop": True,
        "animation": "play",
        "output": "res://Art/level/game_3_level/level_xinshou/bg15_frames/play_frames.tres",
    },
    {
        "name": "level46_bg16_frames",
        "pattern": "res://Art/level/game_3_level/level_xinshou/bg16_frames/%04d.png",
        "count": 13,
        "source_indices": list(range(1, 14)),
        "fps": 30.0,
        "loop": True,
        "animation": "play",
        "output": "res://Art/level/game_3_level/level_xinshou/bg16_frames/play_frames.tres",
    },
    {
        "name": "level46_bg17_frames",
        "pattern": "res://Art/level/game_3_level/level_xinshou/bg17_frames/%04d.png",
        "count": 13,
        "source_indices": list(range(1, 14)),
        "fps": 30.0,
        "loop": True,
        "animation": "play",
        "output": "res://Art/level/game_3_level/level_xinshou/bg17_frames/play_frames.tres",
    },
    {
        "name": "smsr_lightning",
        "pattern": "res://Art/hero_picture/smsr_shenqi_lightning/lightning/d_%05d.png",
        "count": 9,
        "source_indices": list(range(0, 9)),
        "fps": 60.0,
        "animation": "default",
        "output": "res://Art/hero_picture/smsr_shenqi_lightning/lightning/lightning_frames.tres",
    },
    {
        "name": "smsr_hit",
        "pattern": "res://Art/hero_picture/smsr_shenqi_lightning/hit_mesh/hit_%05d.png",
        "count": 10,
        "source_indices": list(range(0, 20, 2)),
        "fps": 30.0,
        "animation": "default",
        "tail_start": 8,
        "tail_duration": 2.0,
        "output": "res://Art/hero_picture/smsr_shenqi_lightning/hit_mesh/hit_frames.tres",
    },
    {
        "name": "mouse_pet_mouse_1_bullet_1",
        "pattern": "res://Art/pet/pet_mouse/effects/pet_mouse_1_bullet_1/%d.png",
        "count": 20,
        "source_indices": list(range(1, 21)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_mouse_1_bullet_1",
        "output": "res://Art/pet/pet_mouse/effects/pet_mouse_1_bullet_1/pet_mouse_1_bullet_1_frames.tres",
    },
    {
        "name": "mouse_pet_mouse_1_bullet_2",
        "pattern": "res://Art/pet/pet_mouse/effects/pet_mouse_1_bullet_2/%d.png",
        "count": 25,
        "source_indices": list(range(1, 26)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_mouse_1_bullet_2",
        "output": "res://Art/pet/pet_mouse/effects/pet_mouse_1_bullet_2/pet_mouse_1_bullet_2_frames.tres",
    },
    {
        "name": "mouse_pet_mouse_1_bullet_2_layer",
        "pattern": "res://Art/pet/pet_mouse/effects/pet_mouse_1_bullet_2_layer/%d.png",
        "count": 25,
        "source_indices": list(range(1, 26)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_mouse_1_bullet_2_layer",
        "output": "res://Art/pet/pet_mouse/effects/pet_mouse_1_bullet_2_layer/pet_mouse_1_bullet_2_layer_frames.tres",
    },
    {
        "name": "mouse_pet_mouse_1_bullet_3",
        "pattern": "res://Art/pet/pet_mouse/effects/pet_mouse_1_bullet_3/%d.png",
        "count": 12,
        "source_indices": list(range(1, 13)),
        "fps": 24.0,
        "loop": True,
        "animation": "pet_mouse_1_bullet_3",
        "output": "res://Art/pet/pet_mouse/effects/pet_mouse_1_bullet_3/pet_mouse_1_bullet_3_frames.tres",
    },
    {
        "name": "mouse_aoyi_buff",
        "pattern": "res://Art/pet/pet_mouse/effects/aoyi_buff/%d.png",
        "count": 14,
        "source_indices": list(range(1, 15)),
        "fps": 24.0,
        "loop": False,
        "animation": "aoyi_buff",
        "output": "res://Art/pet/pet_mouse/effects/aoyi_buff/aoyi_buff_frames.tres",
    },
    {
        "name": "rabbit_pet_pet_rabbit_bullet_1",
        "pattern": "res://Art/pet/pet_rabbit/effects/pet_pet_rabbit_bullet_1/%d.png",
        "count": 1,
        "source_indices": list(range(1, 2)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_pet_rabbit_bullet_1",
        "output": "res://Art/pet/pet_rabbit/effects/pet_pet_rabbit_bullet_1/pet_pet_rabbit_bullet_1_frames.tres",
    },
    {
        "name": "rabbit_pet_pet_rabbit_jf_buff",
        "pattern": "res://Art/pet/pet_rabbit/effects/pet_pet_rabbit_jf_buff/%d.png",
        "count": 16,
        "source_indices": list(range(1, 17)),
        "fps": 24.0,
        "loop": True,
        "animation": "pet_pet_rabbit_jf_buff",
        "output": "res://Art/pet/pet_rabbit/effects/pet_pet_rabbit_jf_buff/pet_pet_rabbit_jf_buff_frames.tres",
    },
    {
        "name": "rabbit_pet_pet_rabbit_bullet_4",
        "pattern": "res://Art/pet/pet_rabbit/effects/pet_pet_rabbit_bullet_4/%d.png",
        "count": 40,
        "source_indices": list(range(1, 41)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_pet_rabbit_bullet_4",
        "output": "res://Art/pet/pet_rabbit/effects/pet_pet_rabbit_bullet_4/pet_pet_rabbit_bullet_4_frames.tres",
    },
    {
        "name": "rabbit_pet_pet_rabbit_bullet_buff",
        "pattern": "res://Art/pet/pet_rabbit/effects/pet_pet_rabbit_bullet_buff/%d.png",
        "count": 16,
        "source_indices": list(range(1, 17)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_pet_rabbit_bullet_buff",
        "output": "res://Art/pet/pet_rabbit/effects/pet_pet_rabbit_bullet_buff/pet_pet_rabbit_bullet_buff_frames.tres",
    },
    {
        "name": "rabbit_pet_rabbit_4_aoyi_buff",
        "pattern": "res://Art/pet/pet_rabbit/effects/pet_rabbit_4_aoyi_buff/%d.png",
        "count": 7,
        "source_indices": list(range(1, 8)),
        "fps": 24.0,
        "loop": True,
        "animation": "pet_rabbit_4_aoyi_buff",
        "output": "res://Art/pet/pet_rabbit/effects/pet_rabbit_4_aoyi_buff/pet_rabbit_4_aoyi_buff_frames.tres",
    },
    {
        "name": "rabbit_monster_130_bullet_2",
        "pattern": "res://Art/pet/pet_rabbit/effects/monster_130_bullet_2/%d.png",
        "count": 30,
        "source_indices": list(range(1, 31)),
        "fps": 24.0,
        "loop": False,
        "animation": "monster_130_bullet_2",
        "output": "res://Art/pet/pet_rabbit/effects/monster_130_bullet_2/monster_130_bullet_2_frames.tres",
    },
    {
        "name": "turtle_pet_turtle_1_bullet_1",
        "pattern": "res://Art/pet/pet_turtle/effects/pet_turtle_1_bullet_1/%d.png",
        "count": 15,
        "source_indices": list(range(1, 16)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_turtle_1_bullet_1",
        "output": "res://Art/pet/pet_turtle/effects/pet_turtle_1_bullet_1/pet_turtle_1_bullet_1_frames.tres",
    },
    {
        "name": "turtle_pet_turtle_1_bullet_2",
        "pattern": "res://Art/pet/pet_turtle/effects/pet_turtle_1_bullet_2/%d.png",
        "count": 30,
        "source_indices": list(range(1, 31)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_turtle_1_bullet_2",
        "output": "res://Art/pet/pet_turtle/effects/pet_turtle_1_bullet_2/pet_turtle_1_bullet_2_frames.tres",
    },
    {
        "name": "turtle_pet_turtle_2_buff",
        "pattern": "res://Art/pet/pet_turtle/effects/pet_turtle_2_buff/%d.png",
        "count": 1,
        "source_indices": list(range(1, 2)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_turtle_2_buff",
        "output": "res://Art/pet/pet_turtle/effects/pet_turtle_2_buff/pet_turtle_2_buff_frames.tres",
    },
    {
        "name": "turtle_pet_turtle_2_bullet_1",
        "pattern": "res://Art/pet/pet_turtle/effects/pet_turtle_2_bullet_1/%d.png",
        "count": 12,
        "source_indices": list(range(1, 13)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_turtle_2_bullet_1",
        "output": "res://Art/pet/pet_turtle/effects/pet_turtle_2_bullet_1/pet_turtle_2_bullet_1_frames.tres",
    },
    {
        "name": "turtle_pet_turtle_3_bullet_3",
        "pattern": "res://Art/pet/pet_turtle/effects/pet_turtle_3_bullet_3/%d.png",
        "count": 18,
        "source_indices": list(range(1, 19)),
        "fps": 24.0,
        "loop": True,
        "animation": "pet_turtle_3_bullet_3",
        "output": "res://Art/pet/pet_turtle/effects/pet_turtle_3_bullet_3/pet_turtle_3_bullet_3_frames.tres",
    },
    {
        "name": "yin_tiger_pet_yin_tiger_1_bullet_1",
        "pattern": "res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_1/%d.png",
        "count": 20,
        "source_indices": list(range(1, 21)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_yin_tiger_1_bullet_1",
        "output": "res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_1/pet_yin_tiger_1_bullet_1_frames.tres",
    },
    {
        "name": "yin_tiger_pet_yin_tiger_1_bullet_2",
        "pattern": "res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_2/%d.png",
        "count": 30,
        "source_indices": list(range(1, 31)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_yin_tiger_1_bullet_2",
        "output": "res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_2/pet_yin_tiger_1_bullet_2_frames.tres",
    },
    {
        "name": "yin_tiger_pet_yin_tiger_1_bullet_3",
        "pattern": "res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_3/%d.png",
        "count": 30,
        "source_indices": list(range(1, 31)),
        "fps": 24.0,
        "loop": False,
        "animation": "pet_yin_tiger_1_bullet_3",
        "output": "res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_3/pet_yin_tiger_1_bullet_3_frames.tres",
    },
    {
        "name": "di_kong_idle",
        "pattern": "res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/%d.png",
        "count": 24,
        "source_indices": list(range(1, 25)),
        "fps": 12.0,
        "loop": True,
        "animation": "wait",
        "output": "res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/di_kong_idle_frames.tres",
    },
    {
        "name": "di_kong_spawn",
        "pattern": "res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/spawn_frames/%d.png",
        "count": 6,
        "source_indices": list(range(1, 7)),
        "fps": 30.0,
        "animation": "spawn",
        "output": "res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/spawn_frames/di_kong_spawn_frames.tres",
    },
    {
        "name": "di_kong_field",
        "pattern": "res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/%d.png",
        "count": 20,
        "source_indices": list(range(1, 21)),
        "fps": 30.0,
        "loop": True,
        "animation": "field",
        "output": "res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/di_kong_field_frames.tres",
    },
    {
        "name": "di_kong_flash",
        "pattern": "res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/%d.png",
        "count": 14,
        "source_indices": list(range(1, 15)),
        "fps": 30.0,
        "animation": "flash",
        "output": "res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/di_kong_flash_frames.tres",
    },
    {
        "name": "zhen_lei_idle",
        "pattern": "res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/%d.png",
        "count": 24,
        "source_indices": list(range(1, 25)),
        "fps": 30.0,
        "loop": True,
        "animation": "wait",
        "output": "res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/zhen_lei_idle_frames.tres",
    },
    {
        "name": "zhen_lei_effect",
        "pattern": "res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/%d.png",
        "count": 28,
        "source_indices": list(range(1, 29)),
        "fps": 30.0,
        "animation": "effect",
        "output": "res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/zhen_lei_effect_frames.tres",
    },
    {
        "name": "zhen_lei_flash",
        "pattern": "res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/flash_frames/%d.png",
        "count": 14,
        "source_indices": list(range(1, 15)),
        "fps": 30.0,
        "animation": "flash",
        "output": "res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/flash_frames/zhen_lei_flash_frames.tres",
    },
    {
        "name": "east_3161_hit1",
        "pattern": "res://Art/monster/game_4_special_effect/effect_3161/effect1/%d.png",
        "count": 49,
        "source_indices": list(range(1, 50)),
        "fps": 30.0,
        "animation": "hit1",
        "output": "res://Art/monster/game_4_special_effect/effect_3161/effect1_frames.tres",
    },
    {
        "name": "east_3161_hit2",
        "pattern": "res://Art/monster/game_4_special_effect/effect_3161/effect2/%d.png",
        "count": 22,
        "source_indices": list(range(1, 23)),
        "fps": 30.0,
        "animation": "hit2",
        "output": "res://Art/monster/game_4_special_effect/effect_3161/effect2_frames.tres",
    },
    {
        "name": "east_3161_hit3",
        "pattern": "res://Art/monster/game_4_special_effect/effect_3161/effect3/%d.png",
        "count": 100,
        "source_indices": list(range(1, 101)),
        "fps": 30.0,
        "animation": "hit3",
        "output": "res://Art/monster/game_4_special_effect/effect_3161/effect3_frames.tres",
    },
    {
        "name": "east_3161_hit4",
        "pattern": "res://Art/monster/game_4_special_effect/effect_3161/effect4/%d.png",
        "count": 19,
        "source_indices": list(range(1, 20)),
        "fps": 30.0,
        "animation": "hit4",
        "output": "res://Art/monster/game_4_special_effect/effect_3161/effect4_frames.tres",
    },
    {
        "name": "east_3120_hit1",
        "pattern": "res://Art/monster/game_4_special_effect/effect_3120/effect1/%d.png",
        "count": 47,
        "source_indices": list(range(1, 48)),
        "fps": 30.0,
        "animation": "hit1",
        "output": "res://Art/monster/game_4_special_effect/effect_3120/effect1_frames.tres",
    },
    {
        "name": "east_3120_hit2",
        "pattern": "res://Art/monster/game_4_special_effect/effect_3120/effect2/%d.png",
        "count": 31,
        "source_indices": list(range(1, 32)),
        "fps": 30.0,
        "animation": "hit2",
        "output": "res://Art/monster/game_4_special_effect/effect_3120/effect2_frames.tres",
    },
    {
        "name": "monster212_bullet1",
        "pattern": "res://Art/monster/game_3_monster/monster_212/DefineSprite_92_Monster212Bullet1_Cropped/%d.png",
        "count": 15,
        "source_indices": list(range(1, 16)),
        "fps": 24.0,
        "loop": True,
        "animation": "Monster212Bullet1",
        "output": "res://Art/monster/game_3_monster/monster_212/DefineSprite_92_Monster212Bullet1_Cropped/monster212_bullet1_frames.tres",
    },
    {
        "name": "monster212_bullet2",
        "pattern": "res://Art/monster/game_3_monster/monster_212/DefineSprite_88_Monster212Bullet2/%d.png",
        "count": 23,
        "source_indices": list(range(1, 24)),
        "fps": 24.0,
        "animation": "Monster212Bullet2",
        "output": "res://Art/monster/game_3_monster/monster_212/DefineSprite_88_Monster212Bullet2/monster212_bullet2_frames.tres",
    },
    {
        "name": "monster212_bullet3",
        "pattern": "res://Art/monster/game_3_monster/monster_212/DefineSprite_71_Monster212Bullet3/%d.png",
        "count": 28,
        "source_indices": list(range(1, 29)),
        "fps": 24.0,
        "animation": "Monster212Bullet3",
        "output": "res://Art/monster/game_3_monster/monster_212/DefineSprite_71_Monster212Bullet3/monster212_bullet3_frames.tres",
    },
    {
        "name": "monster212_bullet4",
        "pattern": "res://Art/monster/game_3_monster/monster_212/DefineSprite_49_Monster212Bullet4_2_Cropped/%d.png",
        "count": 15,
        "source_indices": list(range(1, 16)),
        "fps": 24.0,
        "animation": "Monster212Bullet4",
        "output": "res://Art/monster/game_3_monster/monster_212/DefineSprite_49_Monster212Bullet4_2_Cropped/monster212_bullet4_frames.tres",
    },
    {
        "name": "monster215_bullet1",
        "pattern": "res://Art/monster/game_3_monster/monster_215/DefineSprite_50_Monster215Bullet1/%d.png",
        "count": 18,
        "source_indices": list(range(1, 19)),
        "fps": 30.0,
        "animation": "Monster215Bullet1",
        "output": "res://Art/monster/game_3_monster/monster_215/DefineSprite_50_Monster215Bullet1/monster215_bullet1_frames.tres",
    },
    {
        "name": "monster215_bullet2",
        "pattern": "res://Art/monster/game_3_monster/monster_215/DefineSprite_37_Monster215Bullet2/%d.png",
        "count": 25,
        "source_indices": list(range(1, 26)),
        "fps": 30.0,
        "animation": "Monster215Bullet2",
        "output": "res://Art/monster/game_3_monster/monster_215/DefineSprite_37_Monster215Bullet2/monster215_bullet2_frames.tres",
    },
    {
        "name": "monster130_bullet1",
        "pattern": "res://Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_1/%d.png",
        "count": 11,
        "source_indices": list(range(1, 12)),
        "fps": 24.0,
        "animation": "monster_130_bullet_1",
        "output": "res://Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_1_frames.tres",
    },
    {
        "name": "monster130_bullet2",
        "pattern": "res://Art/pet/pet_rabbit/effects/monster_130_bullet_2/%d.png",
        "count": 30,
        "source_indices": list(range(1, 31)),
        "fps": 24.0,
        "animation": "monster_130_bullet_2",
        "output": "res://Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_2_frames.tres",
    },
    {
        "name": "monster130_bullet3",
        "pattern": "res://Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/%d.png",
        "count": 30,
        "source_indices": list(range(1, 31)),
        "fps": 24.0,
        "animation": "monster_130_bullet_3",
        "output": "res://Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3_frames.tres",
    },
    {
        "name": "monster130_bullet4",
        "pattern": "res://Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4/%d.png",
        "count": 14,
        "source_indices": list(range(1, 15)),
        "fps": 24.0,
        "animation": "monster_130_bullet_4",
        "output": "res://Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4_frames.tres",
    },
    {
        "name": "wutai_3077_tornado",
        "pattern": "res://Art/monster/swf_png/3077/tornado/%d.png",
        "count": 7,
        "source_indices": [1, 4, 7, 10, 13, 16, 19],
        "fps": 30.0,
        "frame_duration": 3.0,
        "animation": "tornado",
        "output": "res://Art/monster/swf_png/3077/tornado/tornado_frames.tres",
    },
)


def source_path(resource_path: str) -> Path:
    if not resource_path.startswith("res://"):
        raise ValueError(f"路径必须是 res:// 形式: {resource_path}")
    return SOURCE / resource_path.removeprefix("res://")


def build_tres(
    pattern: str,
    count: int,
    fps: float,
    loop: bool,
    tail_start: int,
    tail_duration: float,
    *,
    source_indices: list[int] | None = None,
    frame_duration: float | None = None,
    animation: str = "default",
) -> str:
    indices = list(source_indices) if source_indices is not None else list(range(count))
    if not indices:
        raise ValueError("帧索引不能为空")
    frame_paths: list[tuple[str, float]] = []
    for output_index, source_index in enumerate(indices):
        resource_path = pattern % source_index
        path = source_path(resource_path)
        if not path.is_file():
            raise FileNotFoundError(f"缺少帧文件: {path.relative_to(ROOT)}")
        if frame_duration is not None:
            duration = frame_duration
        else:
            duration = tail_duration if tail_start >= 0 and output_index >= tail_start else 1.0
        frame_paths.append((resource_path, duration))

    lines: list[str] = [
        f'[gd_resource type="SpriteFrames" load_steps={len(frame_paths) + 1} format=3]',
        "",
    ]
    for index, (resource_path, _duration) in enumerate(frame_paths, 1):
        lines.append(f'[ext_resource type="Texture2D" path="{resource_path}" id="{index}"]')
    lines.extend(["", "[resource]"])

    frame_entries: list[str] = []
    for index, (_resource_path, duration) in enumerate(frame_paths, 1):
        frame_entries.append(
            '{\n"duration": %s,\n"texture": ExtResource("%d")\n}' % (str(duration), index)
        )
    lines.extend(
        [
            'animations = [{',
            f'"frames": [{", ".join(frame_entries)}],',
            f'"loop": {"true" if loop else "false"},',
            f'"name": &"{animation}",',
            f'"speed": {str(fps)}',
            "}]",
            "",
        ]
    )
    return "\n".join(lines)


def write_profile(profile: dict[str, object], check_only: bool) -> bool:
    name = str(profile["name"])
    output = source_path(str(profile["output"]))
    source_indices = profile.get("source_indices")
    if source_indices is not None:
        source_indices = [int(value) for value in source_indices]
    frame_duration = profile.get("frame_duration")
    content = build_tres(
        pattern=str(profile["pattern"]),
        count=int(profile["count"]),
        fps=float(profile["fps"]),
        loop=bool(profile.get("loop", False)),
        tail_start=int(profile.get("tail_start", -1)),
        tail_duration=float(profile.get("tail_duration", 1.0)),
        source_indices=source_indices,
        frame_duration=float(frame_duration) if frame_duration is not None else None,
        animation=str(profile.get("animation", "default")),
    )
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


def run_all(check_only: bool) -> int:
    passed = True
    for profile in PROFILES:
        try:
            passed = write_profile(profile, check_only) and passed
        except (OSError, ValueError) as error:
            print(f"[FAIL] {profile['name']}: {error}", file=sys.stderr)
            passed = False
    return 0 if passed else 1


def run_single(args: argparse.Namespace) -> int:
    if not args.pattern or not args.output or args.count is None:
        print("[FAIL] 单次转换需要 --pattern、--count 与 --output", file=sys.stderr)
        return 2
    try:
        content = build_tres(
            pattern=args.pattern,
            count=args.count,
            fps=args.fps,
            loop=args.loop,
            tail_start=args.tail_start,
            tail_duration=args.tail_duration,
            source_indices=args.source_indices,
            frame_duration=args.frame_duration,
            animation=args.animation,
        )
    except (OSError, ValueError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    output = source_path(args.output)
    if args.check:
        if not output.is_file():
            print(f"[FAIL] 缺少构建期 SpriteFrames: {output.relative_to(ROOT)}", file=sys.stderr)
            return 1
        if output.read_text(encoding="utf-8") != content:
            print(f"[FAIL] 构建期 SpriteFrames 已过期: {output.relative_to(ROOT)}", file=sys.stderr)
            return 1
        print(f"[OK] {output.relative_to(ROOT)}")
        return 0
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8", newline="\n")
    print(f"[OK] {output.relative_to(ROOT)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="生成连续编号 PNG 序列的构建期 SpriteFrames")
    parser.add_argument("--all", action="store_true", help="生成项目登记的 BiLuoTian/LeiTingJieZhen/Wutai3077 帧")
    parser.add_argument("--check", action="store_true", help="只校验输出是否存在且未过期")
    parser.add_argument("--pattern", help="res:// 路径模板，例如 res://.../frame_%%02d.png")
    parser.add_argument("--count", type=int, help="帧数量")
    parser.add_argument("--output", help="输出 .tres 的 res:// 路径")
    parser.add_argument(
        "--source-indices",
        type=lambda value: [int(part.strip()) for part in value.split(",") if part.strip()],
        help="源帧索引，逗号分隔；覆盖连续的 0..count-1",
    )
    parser.add_argument("--frame-duration", type=float, default=None, help="统一帧时长；优先于尾段设置")
    parser.add_argument("--animation", default="default", help="SpriteFrames 动画名")
    parser.add_argument("--fps", type=float, default=30.0, help="动画速度")
    parser.add_argument("--loop", action="store_true", help="循环动画")
    parser.add_argument("--tail-start", type=int, default=-1, help="尾段起始帧；负数表示无尾段")
    parser.add_argument("--tail-duration", type=float, default=1.0, help="尾段帧时长")
    args = parser.parse_args()
    if args.all:
        return run_all(args.check)
    return run_single(args)


if __name__ == "__main__":
    sys.exit(main())

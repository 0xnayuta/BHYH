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

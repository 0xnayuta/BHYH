#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""哪吒专用构建期适配器：把 official_parts_trial 预览 JSON 转为 SpriteFrames。

本脚本固定读取哪吒的 preview_<layer>.json 结构、三层目录与图集输出路径，
不是通用 SpriteFrames 转换器。通用连续编号 PNG 序列请使用
scripts/convert_numbered_frames.py。

源数据：
    source/Art/hero_picture/role_6/official_parts_trial/<set>/preview_<layer>.json
    source/Art/hero_picture/role_6/official_parts_trial/<set>/preview_<layer>.png

输出：
    source/Art/hero_picture/role_6/equipment_atlas/<set>_<layer>/<set>_<layer>.tres

生成的 .tres 与 NeZhaEquipmentVisuals 的 body/weapon/body_front 路径一一对应。
源 PNG 位于 Art 私有目录，输出同样不进入公开仓库；需要时在本地执行本脚本。
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
PREVIEW_ROOT = SOURCE / "Art/hero_picture/role_6/official_parts_trial"
FRAME_ROOT = SOURCE / "Art/hero_picture/role_6/equipment_atlas"
LAYERS = ((0, "body"), (1, "weapon"), (2, "body_front"))


def gd_rect(values: list[float | int]) -> str:
    return "Rect2(%s, %s, %s, %s)" % tuple(str(v) for v in values[:4])


def action_name(value: str) -> str:
    return '&"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def build_tres(preview: dict, png_path: str) -> str:
    lines: list[str] = [
        '[gd_resource type="SpriteFrames" format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{png_path}" id="1"]',
        "",
    ]
    subresources: list[str] = []
    animations: list[str] = []
    frame_id = 0
    for name, entries in preview.items():
        if not isinstance(entries, list):
            raise ValueError(f"动画 {name} 的帧数据不是数组")
        frames: list[str] = []
        for entry in entries:
            if not isinstance(entry, dict):
                raise ValueError(f"动画 {name} 的帧条目不是字典")
            region = entry.get("region")
            margin = entry.get("margin")
            if not isinstance(region, list) or not isinstance(margin, list):
                raise ValueError(f"动画 {name} 缺少 region/margin")
            frame_id += 1
            sub_id = f"frame_{frame_id}"
            subresources.extend(
                [
                    f'[sub_resource type="AtlasTexture" id="{sub_id}"]',
                    'atlas = ExtResource("1")',
                    f"region = {gd_rect(region)}",
                    f"margin = {gd_rect(margin)}",
                    "filter_clip = true",
                    "",
                ]
            )
            frames.append(
                '{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % sub_id
            )
        animations.append(
            '{\n"frames": [%s],\n"loop": %s,\n"name": %s,\n"speed": 30.0\n}'
            % (
                ", ".join(frames),
                "true" if name == "wait" else "false",
                action_name(name),
            )
        )
    lines.extend(subresources)
    lines.append("[resource]")
    lines.append("animations = [%s]" % ", ".join(animations))
    lines.append("")
    return "\n".join(lines)


def build_source(preview_path: Path, png_path: Path) -> str:
    preview = json.loads(preview_path.read_text(encoding="utf-8"))
    if not isinstance(preview, dict):
        raise ValueError(f"预览 JSON 顶层不是字典: {preview_path}")
    png_res_path = png_path.relative_to(SOURCE).as_posix()
    return build_tres(preview, "res://" + png_res_path)


def convert_source(preview_path: Path, png_path: Path, output_path: Path) -> None:
    content = build_source(preview_path, png_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        content,
        encoding="utf-8",
        newline="\n",
    )


def run(check_only: bool) -> int:
    if not PREVIEW_ROOT.is_dir():
        print(f"[FAIL] 缺少哪吒预览目录: {PREVIEW_ROOT}", file=sys.stderr)
        return 2
    converted = 0
    validated = 0
    missing: list[str] = []
    stale: list[str] = []
    invalid: list[str] = []
    for set_dir in sorted(path for path in PREVIEW_ROOT.iterdir() if path.is_dir()):
        set_name = set_dir.name
        for layer_index, layer_name in LAYERS:
            preview_path = set_dir / f"preview_{layer_index}.json"
            png_path = set_dir / f"preview_{layer_index}.png"
            if not preview_path.is_file() or not png_path.is_file():
                continue
            output_dir = FRAME_ROOT / f"{set_name}_{layer_name}"
            output_path = output_dir / f"{set_name}_{layer_name}.tres"
            if check_only:
                try:
                    expected = build_source(preview_path, png_path)
                except (OSError, ValueError) as error:
                    invalid.append(f"{preview_path.relative_to(ROOT)}: {error}")
                    continue
                if not output_path.is_file():
                    missing.append(str(output_path.relative_to(ROOT)))
                elif output_path.read_text(encoding="utf-8") != expected:
                    stale.append(str(output_path.relative_to(ROOT)))
                else:
                    validated += 1
                continue
            convert_source(preview_path, png_path, output_path)
            converted += 1
    if check_only:
        for path in missing:
            print(f"[FAIL] 缺少构建期 SpriteFrames: {path}", file=sys.stderr)
        for path in stale:
            print(f"[FAIL] 构建期 SpriteFrames 已过期: {path}", file=sys.stderr)
        for message in invalid:
            print(f"[FAIL] 预览源无效: {message}", file=sys.stderr)
        if missing or stale or invalid:
            return 1
        set_count = len(list(PREVIEW_ROOT.glob("*/preview_0.json")))
        print(f"[OK] 哪吒预览帧输出齐全且内容一致: {set_count} 套 / {validated} 个")
        return 0
    print(f"[OK] 已生成 {converted} 个哪吒构建期 SpriteFrames .tres")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="生成哪吒构建期 SpriteFrames")
    parser.add_argument("--check", action="store_true", help="只检查输出是否存在且内容一致，不写文件")
    args = parser.parse_args()
    return run(args.check)


if __name__ == "__main__":
    sys.exit(main())

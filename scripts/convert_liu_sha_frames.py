#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把流沙河 Boss/分身的逐帧 PNG 动作表转换为构建期 SpriteFrames。

数据源是 `liu_sha_river_boss.gd` 与 `liu_sha_river_shadow.gd` 的 `ACTIONS`
常量：每个动作声明 `[frame_folder, holds, loop]`，holds 是逐帧时长
（单位 1/SOURCE_FPS）。资源按 boss_kind 拆分，动画名与动作名一致。

输出：
- `Art/monster/liu_sha_river/monster_<kind>/liu_sha_boss_<kind>_frames.tres`
- `Art/monster/liu_sha_river/shadow_<1|2>/liu_sha_shadow_<kind>_frames.tres`

`--check` 逐字比较；`--all` 生成。资源头写入由输出路径派生的确定性 UID。
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
BOSS_SCRIPT = SOURCE / "Script/monster/liu_sha_river_boss.gd"
SHADOW_SCRIPT = SOURCE / "Script/monster/liu_sha_river_shadow.gd"
BODY_ROOT = "res://Art/monster/liu_sha_river"
FPS = 24.0

UID_ALPHABET = "abcdefghijklmnopqrstuvwxy012345678"
UID_BASE = len(UID_ALPHABET)
UID_MAX_VALUE = 0x7FFFFFFFFFFFFFFF


def parse_actions(path: Path) -> dict[int, dict[str, list]]:
    text = path.read_text(encoding="utf-8")
    start = text.index("const ACTIONS := {")
    opening = text.index("{", start)
    depth = 0
    end = -1
    for offset in range(opening, len(text)):
        char = text[offset]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                end = offset + 1
                break
    if end < 0:
        raise ValueError(f"{path}: ACTIONS 字典不闭合")
    literal = text[opening:end]

    class RewriteNames(ast.NodeTransformer):
        def visit_Name(self, node: ast.Name) -> ast.AST:
            if node.id in {"true", "false", "null"}:
                return ast.copy_location(
                    ast.Constant({"true": True, "false": False, "null": None}[node.id]), node
                )
            return node

    tree = RewriteNames().visit(ast.parse(literal, mode="eval"))
    ast.fix_missing_locations(tree)
    value = ast.literal_eval(tree)
    if not isinstance(value, dict):
        raise ValueError(f"{path}: ACTIONS 不是字典")
    result: dict[int, dict[str, list]] = {}
    for kind, actions in value.items():
        if not isinstance(actions, dict):
            raise ValueError(f"{path}: boss_kind {kind} 不是字典")
        result[int(kind)] = {
            str(action): list(data) for action, data in actions.items()
        }
    return result


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


def build_tres(actions: dict[str, list], folder_for: str, resource_path: str) -> str:
    frame_rows: list[tuple[str, float]] = []
    animations: list[tuple[str, bool, list[tuple[str, float]]]] = []
    for action, data in actions.items():
        source_folder = str(data[0])
        holds = [float(value) for value in data[1]]
        looped = bool(data[2])
        frames: list[tuple[str, float]] = []
        for index, hold in enumerate(holds):
            png = f"{BODY_ROOT}/{folder_for}/{source_folder}/{index + 1}.png"
            if not (SOURCE / png.removeprefix("res://")).is_file():
                raise FileNotFoundError(f"缺少帧文件: {png}")
            frames.append((png, hold / FPS))
            frame_rows.append((png, hold / FPS))
        animations.append((action, looped, frames))

    uid = uid_for_identity("liu_sha_frames|" + resource_path)
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={len(frame_rows) + 1} format=3 uid="{uid}"]',
        "",
    ]
    unique_paths: list[str] = []
    for png, _duration in frame_rows:
        if png not in unique_paths:
            unique_paths.append(png)
    for index, png in enumerate(unique_paths, 1):
        lines.append(f'[ext_resource type="Texture2D" path="{png}" id="{index}"]')
    lines.extend(["", "[resource]", "animations = [" + "{"])
    path_ids = {png: index for index, png in enumerate(unique_paths, 1)}
    blocks: list[str] = []
    for action, looped, frames in animations:
        frame_entries = ", ".join(
            '{\n"duration": %s,\n"texture": ExtResource("%d")\n}'
            % (format_duration(duration), path_ids[png])
            for png, duration in frames
        )
        blocks.append(
            '{\n"frames": [%s],\n"loop": %s,\n"name": &"%s",\n"speed": %s\n}'
            % (frame_entries, "true" if looped else "false", action, format_duration(FPS))
        )
    lines[-1] = "animations = [" + blocks[0]
    for block in blocks[1:]:
        lines.append(", " + block)
    lines.append("]")
    return "\n".join(lines) + "\n"


def format_duration(value: float) -> str:
    text = f"{value:.6f}".rstrip("0").rstrip(".")
    return text if text else "0"


def profiles() -> list[tuple[str, Path, dict[str, list], str]]:
    boss_actions = parse_actions(BOSS_SCRIPT)
    shadow_actions = parse_actions(SHADOW_SCRIPT)
    result: list[tuple[str, Path, dict[str, list], str]] = []
    for kind, actions in boss_actions.items():
        resource_path = f"{BODY_ROOT}/monster_{kind}/liu_sha_boss_{kind}_frames.tres"
        result.append(
            (
                f"liu_sha_boss_{kind}",
                SOURCE / resource_path.removeprefix("res://"),
                actions,
                f"monster_{kind}",
            )
        )
    for kind, actions in shadow_actions.items():
        folder = "shadow_1" if kind == 34 else "shadow_2"
        resource_path = f"{BODY_ROOT}/{folder}/liu_sha_shadow_{kind}_frames.tres"
        result.append(
            (
                f"liu_sha_shadow_{kind}",
                SOURCE / resource_path.removeprefix("res://"),
                actions,
                folder,
            )
        )
    return result


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="流沙河逐帧动作表 → 构建期 SpriteFrames")
    parser.add_argument("--all", action="store_true", help="生成全部登记资源")
    parser.add_argument("--check", action="store_true", help="只校验输出存在且内容一致")
    args = parser.parse_args(argv)

    passed = True
    for name, output, actions, folder in profiles():
        resource_path = "res://" + output.relative_to(SOURCE).as_posix()
        try:
            content = build_tres(actions, folder, resource_path)
        except (OSError, ValueError, FileNotFoundError) as error:
            print(f"[FAIL] {name}: {error}", file=sys.stderr)
            passed = False
            continue
        if args.check:
            if not output.is_file():
                print(f"[FAIL] 缺少构建期 SpriteFrames: {output.relative_to(ROOT)}", file=sys.stderr)
                passed = False
                continue
            if output.read_text(encoding="utf-8") != content:
                print(f"[FAIL] 构建期 SpriteFrames 已过期: {output.relative_to(ROOT)}", file=sys.stderr)
                passed = False
                continue
            print(f"[OK] {name}: {output.relative_to(ROOT)}")
            continue
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(content, encoding="utf-8", newline="\n")
        print(f"[OK] {name}: {output.relative_to(ROOT)}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())

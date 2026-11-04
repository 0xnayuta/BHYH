#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""构建期生成外部 ZMWS 怪物 ID → BHYH 怪物场景映射。

匹配规则：
- 以 `source/data/zmws_config/monster.json` 的 `name` 为外部名称；
- 从 `source/Scene/monster/monster_<id>.tscn` 的脚本链读取 `my_mr_name` 字面量；
- 名称完全一致才登记；同一名称有多个 BHYH 场景时固定取最小 ID；
- 额外允许去除空白、全角兼容字符与间隔号后唯一匹配（如「邪悟空」→「邪·悟空」）；
- 归一化后仍有多个候选、或只是相似名称时不猜测，不把未匹配项静默映射到默认怪物。

用法：
    python scripts/convert_external_monster_catalog.py
    python scripts/convert_external_monster_catalog.py --check
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
MONSTER_CONFIG = SOURCE / "data/zmws_config/monster.json"
MONSTER_SCENE_DIR = SOURCE / "Scene/monster"
MONSTER_SCRIPT_DIR = SOURCE / "Script/monster"
CATALOG_PATH = SOURCE / "Script/data/external_monster_catalog.tres"
UID_ALPHABET = "abcdefghijklmnopqrstuvwxy012345678"
UID_BASE = len(UID_ALPHABET)
UID_MAX_VALUE = 0x7FFFFFFFFFFFFFFF


def uid_text(value: int) -> str:
    value &= UID_MAX_VALUE
    chars: list[str] = []
    while True:
        chars.append(UID_ALPHABET[value % UID_BASE])
        value //= UID_BASE
        if value == 0:
            break
    return "uid://" + "".join(reversed(chars))


def catalog_uid() -> str:
    digest = hashlib.sha256(b"bhyh:external_monster_catalog").digest()
    return uid_text(int.from_bytes(digest[:8], "big"))


def scene_script_names(scene_path: Path) -> set[str]:
    text = scene_path.read_text(encoding="utf-8", errors="replace")
    names: set[str] = set()
    for res_path in re.findall(r'path="(res://Script/[^"]+\.gd)"', text):
        script_path = SOURCE / res_path.removeprefix("res://")
        if not script_path.is_file():
            continue
        script_text = script_path.read_text(encoding="utf-8", errors="replace")
        names.update(re.findall(r'my_mr_name\s*=\s*"([^"]+)"', script_text))
    return names


def normalized_name(value: str) -> str:
    """统一空白、全角字符与分隔标点；不做语义别名或模糊匹配。"""
    value = unicodedata.normalize("NFKC", value)
    return re.sub(r"[\s·•・\-—–_]+", "", value)


def bhyh_names() -> dict[str, int]:
    result: dict[str, int] = {}
    for scene_path in sorted(MONSTER_SCENE_DIR.glob("monster_*.tscn")):
        match = re.fullmatch(r"monster_(\d+)\.tscn", scene_path.name)
        if match is None:
            continue
        monster_id = int(match.group(1))
        for name in scene_script_names(scene_path):
            normalized = name.strip()
            if not normalized:
                continue
            current = result.get(normalized)
            if current is None or monster_id < current:
                result[normalized] = monster_id
    return result


def source_names() -> dict[int, str]:
    try:
        payload = json.loads(MONSTER_CONFIG.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"无法读取 {MONSTER_CONFIG.relative_to(ROOT)}: {error}") from error
    if not isinstance(payload, dict):
        raise ValueError("monster.json 顶层不是对象")
    header = payload.get("header")
    rows = payload.get("rows")
    if not isinstance(header, list) or not isinstance(rows, list):
        raise ValueError("monster.json schema 不是 header/rows")
    try:
        id_index = header.index("id")
        name_index = header.index("name")
    except ValueError as error:
        raise ValueError("monster.json 缺少 id/name 列") from error
    result: dict[int, str] = {}
    for row in rows:
        if not isinstance(row, list) or len(row) <= max(id_index, name_index):
            continue
        monster_id = row[id_index]
        name = row[name_index]
        if isinstance(monster_id, int) and isinstance(name, str) and name.strip():
            result.setdefault(monster_id, name.strip())
    return result


def build_catalog() -> tuple[str, int]:
    by_name = bhyh_names()
    by_normalized: dict[str, str] = {}
    for candidate in by_name:
        key = normalized_name(candidate)
        if key in by_normalized and by_normalized[key] != candidate:
            by_normalized[key] = ""
        else:
            by_normalized[key] = candidate
    external = source_names()
    mappings: dict[int, int] = {}
    names: dict[int, str] = {}
    for external_id in sorted(external):
        name = external[external_id]
        bhyh_id = by_name.get(name)
        if bhyh_id is None:
            alias = by_normalized.get(normalized_name(name), "")
            if alias:
                bhyh_id = by_name.get(alias)
        if bhyh_id is None or bhyh_id <= 0:
            continue
        scene_path = MONSTER_SCENE_DIR / f"monster_{bhyh_id}.tscn"
        if not scene_path.is_file():
            continue
        mappings[external_id] = bhyh_id
        names[external_id] = name
    lines = [
        '[gd_resource type="Resource" script_class="ExternalMonsterCatalog" load_steps=2 format=3 uid="%s"]'
        % catalog_uid(),
        "",
        '[ext_resource type="Script" path="res://Script/data/external_monster_catalog.gd" id="1_catalog"]',
        "",
        "[resource]",
        'script = ExtResource("1_catalog")',
        "monster_ids = {",
    ]
    for external_id, bhyh_id in mappings.items():
        lines.append("\t%d: %d," % (external_id, bhyh_id))
    lines.extend(["}", "scene_paths = {"])
    for external_id, bhyh_id in mappings.items():
        lines.append('\t%d: &"res://Scene/monster/monster_%d.tscn",' % (external_id, bhyh_id))
    lines.extend(["}", "source_names = {"])
    for external_id, name in names.items():
        escaped = name.replace("\\", "\\\\").replace('"', '\\"')
        lines.append('\t%d: &"%s",' % (external_id, escaped))
    lines.extend(["}", ""])
    return "\n".join(lines), len(mappings)


def run(check_only: bool) -> int:
    if not SOURCE.is_dir():
        print(f"[FAIL] 工程目录不存在: {SOURCE}", file=sys.stderr)
        return 2
    try:
        content, count = build_catalog()
    except ValueError as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    if check_only:
        if not CATALOG_PATH.is_file():
            print(f"[FAIL] 缺少外部怪物映射: {CATALOG_PATH.relative_to(ROOT)}", file=sys.stderr)
            return 1
        if CATALOG_PATH.read_text(encoding="utf-8") != content:
            print(f"[FAIL] 外部怪物映射已过期: {CATALOG_PATH.relative_to(ROOT)}", file=sys.stderr)
            return 1
        print(f"[OK] 外部怪物映射校验通过: {count} 条精确/唯一归一化名称映射")
        return 0
    CATALOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    CATALOG_PATH.write_text(content, encoding="utf-8", newline="\n")
    print(f"[OK] 外部怪物映射已生成: {count} 条精确/唯一归一化名称映射")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="生成外部 ZMWS 怪物到 BHYH 场景的映射")
    parser.add_argument("--check", action="store_true", help="只校验输出是否最新，不写文件")
    args = parser.parse_args()
    return run(args.check)


if __name__ == "__main__":
    sys.exit(main())

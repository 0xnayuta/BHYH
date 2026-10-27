#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""构建期生成关卡预载 Catalog：场景 → 阶段怪物 ID 与怪物场景 → 弹体场景。

运行时不再读取 `.gd` / `.tscn` 源文本。生成规则：

- 关卡阶段表取该场景根脚本（含 `extends` 链）中的 `monster_group = { ... }` 字面量；
- 阶段数组中的条目支持整数、同文件（或链上）`const` 整数、`const` 整数数组取下标；
- `@export var` 若由场景根节点覆盖，则使用场景中的静态值；
- 无法静态确定的标识符（例如从 `Global` 读取的选择）跳过，由关卡脚本自身的
  运行期预载负责；生成结果不猜测、不生成候选集合；
- `monster_ids` 额外并入脚本中的 `"monster": <int>` 字面量与
  `preload_level_monster_*(常量数组|字面量数组)` 调用参数；
- 弹体场景表按怪物场景的脚本（含 `extends` 链）中的字符串字面量匹配
  `Scene/monster/monster_bullet_slim/*.tscn` 实际文件名（大小写不敏感，输出真实文件名）。

用法：
    python scripts/convert_level_preload_catalog.py            # 生成
    python scripts/convert_level_preload_catalog.py --check    # 只校验
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
LEVEL_SCENE_DIR = SOURCE / "Scene/level"
MONSTER_SCENE_DIR = SOURCE / "Scene/monster"
BULLET_SCENE_DIR = MONSTER_SCENE_DIR / "monster_bullet_slim"
CATALOG_PATH = SOURCE / "Script/data/level_preload_catalog.tres"
DYNAMIC_SOURCE_PATH = ROOT / "scripts/monster_dynamic_paths.json"
EXPORT_MANIFEST_PATH = SOURCE / "Art/frame_sequences/level_preload_export_dependencies.json"
EXPORT_MANIFEST_SCHEMA = "level_preload_export_dependencies"
EXPORT_MANIFEST_VERSION = 1

STAGE_KEYS = ("stage_1", "stage_2", "stage_3", "stage_4")
UID_ALPHABET = "abcdefghijklmnopqrstuvwxy012345678"
UID_BASE = len(UID_ALPHABET)
UID_MAX_VALUE = 0x7FFFFFFFFFFFFFFF


@dataclass
class LevelEntry:
    stages: dict[str, list[int]] = field(
        default_factory=lambda: {key: [] for key in STAGE_KEYS}
    )
    monster_ids: list[int] = field(default_factory=list)
    late_stage_ids: list[int] = field(default_factory=list)
    unresolved: list[str] = field(default_factory=list)


@dataclass
class DynamicPaths:
    scene_overrides: dict[int, str] = field(default_factory=dict)
    textures: dict[int, list[str]] = field(default_factory=dict)
    extra_scenes: dict[int, list[str]] = field(default_factory=dict)
    manifest_monster_scenes: list[str] = field(default_factory=list)
    manifest_dynamic_scenes: list[str] = field(default_factory=list)
    manifest_dynamic_textures: list[str] = field(default_factory=list)
    missing: list[str] = field(default_factory=list)


def strip_comments(text: str) -> str:
    out: list[str] = []
    quote = ""
    index = 0
    while index < len(text):
        char = text[index]
        if quote:
            out.append(char)
            if char == "\\" and index + 1 < len(text):
                out.append(text[index + 1])
                index += 2
                continue
            if char == quote:
                quote = ""
            index += 1
            continue
        if char in "\"'":
            quote = char
            out.append(char)
            index += 1
            continue
        if char == "#":
            newline = text.find("\n", index)
            index = len(text) if newline < 0 else newline
            continue
        out.append(char)
        index += 1
    return "".join(out)


def brace_block(text: str, open_index: int) -> str:
    depth = 0
    for index in range(open_index, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[open_index + 1 : index]
    return ""


def parse_constants(text: str) -> tuple[dict[str, int], dict[str, list[int]]]:
    ints: dict[str, int] = {}
    arrays: dict[str, list[int]] = {}
    pattern = re.compile(
        r"const\s+([A-Za-z_]\w*)\s*(?::\s*Array\[int\])?\s*:?=\s*(\[[^\]]*\]|-?\d+)"
    )
    for match in pattern.finditer(text):
        name, value = match.group(1), match.group(2)
        if value.startswith("["):
            arrays[name] = [int(item) for item in re.findall(r"-?\d+", value)]
        else:
            ints[name] = int(value)
    return ints, arrays


def parse_exported_ints(text: str) -> set[str]:
    names: set[str] = set()
    for match in re.finditer(r"@export\s+var\s+([A-Za-z_]\w*)\s*(?::\s*int)?\s*:?=\s*-?\d+", text):
        names.add(match.group(1))
    return names


def parse_script_constants(path: Path) -> tuple[dict[str, int], dict[str, list[int]]]:
    text = strip_comments(path.read_text(encoding="utf-8", errors="replace"))
    return parse_constants(text)


def find_extends(text: str) -> tuple[str, str] | None:
    """返回 ("path", "res://...") 或 ("class", "Name")。"""
    match = re.search(r'^extends\s+"([^"]+)"', text, re.M)
    if match:
        return "path", match.group(1)
    match = re.search(r"^extends\s+([A-Za-z_]\w*)", text, re.M)
    if match:
        return "class", match.group(1)
    return None


def build_class_index() -> dict[str, Path]:
    index: dict[str, Path] = {}
    for path in SOURCE.rglob("*.gd"):
        text = path.read_text(encoding="utf-8", errors="replace")
        match = re.search(r"^class_name\s+([A-Za-z_]\w*)", text, re.M)
        if match:
            index[match.group(1)] = path
    return index


def script_chain(path: Path, class_index: dict[str, Path]) -> list[Path]:
    chain: list[Path] = []
    seen: set[Path] = set()
    current: Path | None = path
    while current is not None and current not in seen and current.is_file():
        chain.append(current)
        seen.add(current)
        text = strip_comments(current.read_text(encoding="utf-8", errors="replace"))
        parent = find_extends(text)
        if parent is None:
            break
        kind, value = parent
        if kind == "path":
            current = SOURCE / value.removeprefix("res://")
        else:
            current = class_index.get(value)
    return chain


def chain_constants(chain: list[Path]) -> tuple[dict[str, int], dict[str, list[int]]]:
    ints: dict[str, int] = {}
    arrays: dict[str, list[int]] = {}
    for path in reversed(chain):
        more_ints, more_arrays = parse_script_constants(path)
        ints.update(more_ints)
        arrays.update(more_arrays)
    return ints, arrays


def resolve_token(
    token: str,
    ints: dict[str, int],
    arrays: dict[str, list[int]],
    scene_overrides: dict[str, int],
    exported: set[str],
) -> list[int] | None:
    token = token.strip()
    if not token:
        return None
    if re.fullmatch(r"-?\d+", token):
        return [int(token)]
    indexed = re.fullmatch(r"([A-Za-z_]\w*)\s*\[\s*(\d+)\s*\]", token)
    if indexed and indexed.group(1) in arrays:
        values = arrays[indexed.group(1)]
        position = int(indexed.group(2))
        if 0 <= position < len(values):
            return [values[position]]
        return None
    if re.fullmatch(r"[A-Za-z_]\w*", token):
        if token in exported and token in scene_overrides:
            return [scene_overrides[token]]
        if token in ints:
            return [ints[token]]
        if token in arrays:
            return list(arrays[token])
        if token in scene_overrides:
            return [scene_overrides[token]]
    return None


def bracket_items(text: str, open_index: int) -> list[str]:
    """按括号深度切分数组内容，支持 `CONST[index]` 这类嵌套下标。"""
    items: list[str] = []
    depth = 0
    current: list[str] = []
    for index in range(open_index, len(text)):
        char = text[index]
        if char == "[":
            depth += 1
            if depth == 1:
                continue
        elif char == "]":
            depth -= 1
            if depth == 0:
                items.append("".join(current))
                return items
        elif char == "," and depth == 1:
            items.append("".join(current))
            current = []
            continue
        if depth >= 1:
            current.append(char)
    return items


def extract_stage_groups(
    text: str,
    ints: dict[str, int],
    arrays: dict[str, list[int]],
    scene_overrides: dict[str, int],
    exported: set[str],
    entry: LevelEntry,
) -> None:
    for match in re.finditer(r"monster_group\s*=\s*\{", text):
        body = brace_block(text, match.end() - 1)
        for stage_match in re.finditer(r'"stage_([1-4])"\s*:\s*\[', body):
            key = "stage_" + stage_match.group(1)
            for token in bracket_items(body, stage_match.end() - 1):
                token = token.strip()
                if not token:
                    continue
                values = resolve_token(token, ints, arrays, scene_overrides, exported)
                if values is None:
                    note = f"{key}:{token}"
                    if note not in entry.unresolved:
                        entry.unresolved.append(note)
                    continue
                for value in values:
                    if value > 0 and value not in entry.stages[key]:
                        entry.stages[key].append(value)


def extract_birth_point_stages(text: str, entry: LevelEntry) -> None:
    """从出生点字典字面量（同时含 `"stage"` 与 `"monster"`）还原阶段归属。"""
    for match in re.finditer(r"\{", text):
        body = brace_block(text, match.end() - 1)
        stage_match = re.search(r'"stage"\s*:\s*([1-9])\b', body)
        monster_match = re.search(r'"monster"\s*:\s*(\d+)', body)
        if stage_match is None or monster_match is None:
            continue
        value = int(monster_match.group(1))
        if value <= 0:
            continue
        stage_index = int(stage_match.group(1))
        if stage_index > 4:
            if value not in entry.late_stage_ids:
                entry.late_stage_ids.append(value)
            continue
        key = "stage_%d" % stage_index
        if value not in entry.stages[key]:
            entry.stages[key].append(value)


def extract_monster_ids(
    text: str,
    ints: dict[str, int],
    arrays: dict[str, list[int]],
    entry: LevelEntry,
) -> None:
    for match in re.finditer(r'"monster"\s*:\s*(\d+)', text):
        value = int(match.group(1))
        if value > 0 and value not in entry.monster_ids:
            entry.monster_ids.append(value)
    for match in re.finditer(r"preload_level_monster_\w+\s*\(\s*(\[[^\]]*\]|[A-Za-z_]\w*)\s*\)", text):
        argument = match.group(1).strip()
        values: list[int] = []
        if argument.startswith("["):
            values = [int(item) for item in re.findall(r"-?\d+", argument)]
        elif argument in arrays:
            values = list(arrays[argument])
        elif argument in ints:
            values = [ints[argument]]
        for value in values:
            if value > 0 and value not in entry.monster_ids:
                entry.monster_ids.append(value)


def scene_overrides(scene_text: str, exported: set[str]) -> dict[str, int]:
    overrides: dict[str, int] = {}
    root_match = re.search(r"^\[node name=\"[^\"]+\"[^\n]*\]\n((?:\w+ = [^\n]*\n)+)", scene_text, re.M)
    if root_match is None:
        return overrides
    for line in root_match.group(1).splitlines():
        parts = line.split("=", 1)
        if len(parts) != 2:
            continue
        name = parts[0].strip()
        raw = parts[1].strip()
        if name in exported and re.fullmatch(r"-?\d+", raw):
            overrides[name] = int(raw)
    return overrides


def scene_level_scripts(scene_path: Path, class_index: dict[str, Path]) -> list[Path]:
    text = scene_path.read_text(encoding="utf-8", errors="replace")
    scripts: list[Path] = []
    seen: set[Path] = set()
    for match in re.finditer(r'path="(res://Script/level/[^"]+\.gd)"', text):
        candidate = SOURCE / match.group(1).removeprefix("res://")
        for script in script_chain(candidate, class_index):
            if script not in seen:
                seen.add(script)
                scripts.append(script)
    return scripts


def collect_levels(class_index: dict[str, Path]) -> dict[str, LevelEntry]:
    levels: dict[str, LevelEntry] = {}
    for scene_path in sorted(LEVEL_SCENE_DIR.glob("*.tscn")):
        entry = LevelEntry()
        scene_res = "res://" + scene_path.relative_to(SOURCE).as_posix()
        chain = scene_level_scripts(scene_path, class_index)
        if not chain:
            levels[scene_res] = entry
            continue
        ints, arrays = chain_constants(chain)
        declared_exported: set[str] = set()
        for script in chain:
            text = strip_comments(script.read_text(encoding="utf-8", errors="replace"))
            declared_exported |= parse_exported_ints(text)
        overrides = scene_overrides(
            scene_path.read_text(encoding="utf-8", errors="replace"), declared_exported
        )
        for script in chain:
            text = strip_comments(script.read_text(encoding="utf-8", errors="replace"))
            extract_stage_groups(text, ints, arrays, overrides, declared_exported, entry)
            extract_birth_point_stages(text, entry)
            extract_monster_ids(text, ints, arrays, entry)
        for key in STAGE_KEYS:
            for value in entry.stages[key]:
                if value not in entry.monster_ids:
                    entry.monster_ids.append(value)
        levels[scene_res] = entry
    return levels


def collect_monster_bullets() -> dict[str, list[str]]:
    by_lower = {path.stem.lower(): path.name for path in BULLET_SCENE_DIR.glob("*.tscn")}
    bullets: dict[str, list[str]] = {}
    for scene_path in sorted(MONSTER_SCENE_DIR.glob("monster_*.tscn")):
        text = scene_path.read_text(encoding="utf-8", errors="replace")
        texts: list[str] = []
        seen: set[str] = set()
        for match in sorted(set(re.findall(r'path="(res://Script/[^"]+\.gd)"', text))):
            current: Path | None = SOURCE / match.removeprefix("res://")
            while current is not None and current not in seen and current.is_file():
                seen.add(current)
                script_text = strip_comments(current.read_text(encoding="utf-8", errors="replace"))
                texts.append(script_text)
                parent = find_extends(script_text)
                if parent is None or parent[0] != "path":
                    break
                current = SOURCE / parent[1].removeprefix("res://")
        found: set[str] = set()
        for script_text in texts:
            for literal in re.findall(r'"([^"]+)"', script_text):
                if not literal or "/" in literal:
                    continue
                actual = by_lower.get(literal.lower())
                if actual:
                    found.add(f"{BULLET_SCENE_DIR.relative_to(SOURCE).as_posix()}/{actual}")
        if found:
            key = "res://" + scene_path.relative_to(SOURCE).as_posix()
            bullets[key] = sorted("res://" + item for item in found)
    return bullets


def source_path(res_path: str) -> Path:
    if not res_path.startswith("res://"):
        raise ValueError(f"不是 res:// 路径: {res_path}")
    return SOURCE / res_path.removeprefix("res://")


def direct_monster_scene_paths() -> dict[int, str]:
    result: dict[int, str] = {}
    for scene_path in sorted(MONSTER_SCENE_DIR.glob("monster_*.tscn")):
        match = re.fullmatch(r"monster_(\d+)\.tscn", scene_path.name)
        if match is None:
            continue
        monster_id = int(match.group(1))
        result[monster_id] = "res://" + scene_path.relative_to(SOURCE).as_posix()
    return result


def resolve_monster_scene_path(
    monster_id: int,
    direct: dict[int, str],
    aliases: dict[int, int],
    stack: set[int] | None = None,
) -> str:
    if monster_id in aliases:
        if stack is None:
            stack = set()
        if monster_id in stack:
            raise ValueError(f"怪物场景别名成环: {monster_id}")
        stack.add(monster_id)
        return resolve_monster_scene_path(aliases[monster_id], direct, aliases, stack)
    return direct.get(monster_id, "")


def expand_texture_entry(res_path: str, missing: list[str]) -> list[str]:
    path = source_path(res_path)
    if res_path.lower().endswith(".png"):
        if not path.is_file():
            missing.append(f"纹理文件不存在: {res_path}")
            return []
        return [res_path]
    if not path.is_dir():
        missing.append(f"纹理目录不存在: {res_path}")
        return []
    files = sorted(
        "res://" + item.relative_to(SOURCE).as_posix() for item in path.rglob("*.png")
    )
    if not files:
        missing.append(f"纹理目录内没有 PNG: {res_path}")
    return files


def build_dynamic_paths(levels: dict[str, LevelEntry]) -> DynamicPaths:
    try:
        raw = json.loads(DYNAMIC_SOURCE_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"无法读取动态路径数据源 {DYNAMIC_SOURCE_PATH.relative_to(ROOT)}: {error}") from error
    if not isinstance(raw, dict):
        raise ValueError("动态路径数据源不是 JSON 对象")

    aliases: dict[int, int] = {}
    for key, value in dict(raw.get("aliases", {})).items():
        aliases[int(key)] = int(value)
    raw_textures: dict[int, list[str]] = {}
    for key, values in dict(raw.get("textures", {})).items():
        raw_textures[int(key)] = [str(item) for item in values]
    raw_scenes: dict[int, list[str]] = {}
    for key, values in dict(raw.get("scenes", {})).items():
        raw_scenes[int(key)] = [str(item) for item in values]

    direct = direct_monster_scene_paths()
    dynamic = DynamicPaths()
    for source_id in sorted(aliases):
        path = resolve_monster_scene_path(source_id, direct, aliases)
        if not path:
            dynamic.missing.append(f"别名 {source_id} 无目标场景: {aliases[source_id]}")
        else:
            dynamic.scene_overrides[source_id] = path

    # 运行时的旧逻辑按 canonical ID 查动态纹理；生成期把目标条目的文件集合展开到别名键。
    texture_entries = {key: list(values) for key, values in raw_textures.items()}
    for source_id, target_id in aliases.items():
        inherited = raw_textures.get(target_id, [])
        if inherited:
            merged = list(dict.fromkeys([*texture_entries.get(source_id, []), *inherited]))
            texture_entries[source_id] = merged
    for monster_id in sorted(texture_entries):
        files: list[str] = []
        for entry in texture_entries[monster_id]:
            files.extend(expand_texture_entry(entry, dynamic.missing))
        unique = sorted(dict.fromkeys(files))
        if unique:
            dynamic.textures[monster_id] = unique

    for monster_id in sorted(raw_scenes):
        valid: list[str] = []
        for res_path in raw_scenes[monster_id]:
            if not source_path(res_path).is_file():
                dynamic.missing.append(f"动态场景不存在: {res_path}")
                continue
            valid.append(res_path)
        unique = sorted(dict.fromkeys(valid))
        if unique:
            dynamic.extra_scenes[monster_id] = unique

    manifest_scenes = set(dynamic.scene_overrides.values())
    for scene, entry in levels.items():
        for monster_id in entry.monster_ids:
            path = resolve_monster_scene_path(monster_id, direct, aliases)
            if not path:
                dynamic.missing.append(f"{scene}: 怪物 {monster_id} 无场景且无别名")
                continue
            manifest_scenes.add(path)
    dynamic.manifest_monster_scenes = sorted(manifest_scenes)
    dynamic.manifest_dynamic_scenes = sorted(
        {path for paths in dynamic.extra_scenes.values() for path in paths}
    )
    dynamic.manifest_dynamic_textures = sorted(
        {path for paths in dynamic.textures.values() for path in paths}
    )
    return dynamic


def dependency_manifest_content(dynamic: DynamicPaths, bullets: dict[str, list[str]]) -> str:
    payload = {
        "schema_id": EXPORT_MANIFEST_SCHEMA,
        "schema_version": EXPORT_MANIFEST_VERSION,
        "catalog": "res://" + CATALOG_PATH.relative_to(SOURCE).as_posix(),
        "monster_scenes": dynamic.manifest_monster_scenes,
        "dynamic_monster_scenes": dynamic.manifest_dynamic_scenes,
        "bullet_scenes": sorted({path for paths in bullets.values() for path in paths}),
        "dynamic_textures": dynamic.manifest_dynamic_textures,
    }
    return json.dumps(payload, indent=2, ensure_ascii=False) + "\n"


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
    digest = hashlib.sha256(b"bhyh:level_preload_catalog").digest()
    return uid_text(int.from_bytes(digest[:8], "big"))


def packed(values: list[int]) -> str:
    return "PackedInt32Array(%s)" % ", ".join(str(value) for value in values)


def catalog_content(
    levels: dict[str, LevelEntry],
    bullets: dict[str, list[str]],
    dynamic: DynamicPaths,
) -> str:
    entries = [(scene, entry) for scene, entry in levels.items() if entry.monster_ids]
    lines = [
        '[gd_resource type="Resource" script_class="LevelPreloadCatalog" load_steps=%d format=3 uid="%s"]'
        % (len(entries) + 3, catalog_uid()),
        "",
        '[ext_resource type="Script" path="res://Script/data/level_preload_catalog.gd" id="1_catalog"]',
        '[ext_resource type="Script" path="res://Script/data/level_preload_entry.gd" id="2_entry"]',
        "",
    ]
    for index, (scene, entry) in enumerate(entries, 1):
        lines.append('[sub_resource type="Resource" id="entry_%d"]' % index)
        lines.append('script = ExtResource("2_entry")')
        lines.append("first_wave_ids = %s" % packed(entry.stages["stage_1"]))
        lines.append("monster_ids = %s" % packed(entry.monster_ids))
        lines.append("")
    lines.extend(
        [
            "[resource]",
            'script = ExtResource("1_catalog")',
            "levels = {",
        ]
    )
    for index, (scene, _entry) in enumerate(entries, 1):
        lines.append('\t&"%s": SubResource("entry_%d"),' % (scene, index))
    lines.extend(["}", "monster_bullets = {"])
    for scene, paths in bullets.items():
        joined = ", ".join('"%s"' % path for path in paths)
        lines.append('\t&"%s": PackedStringArray(%s),' % (scene, joined))
    lines.extend(["}", "monster_scene_paths = {"])
    for monster_id, path in sorted(dynamic.scene_overrides.items()):
        lines.append('\t%d: &"%s",' % (monster_id, path))
    lines.extend(["}", "monster_texture_paths = {"])
    for monster_id, paths in sorted(dynamic.textures.items()):
        joined = ", ".join('"%s"' % path for path in paths)
        lines.append("\t%d: PackedStringArray(%s)," % (monster_id, joined))
    lines.extend(["}", "monster_extra_scene_paths = {"])
    for monster_id, paths in sorted(dynamic.extra_scenes.items()):
        joined = ", ".join('"%s"' % path for path in paths)
        lines.append("\t%d: PackedStringArray(%s)," % (monster_id, joined))
    lines.extend(["}", ""])
    return "\n".join(lines)


def run(check_only: bool) -> int:
    if not SOURCE.is_dir():
        print(f"[FAIL] 工程目录不存在: {SOURCE}", file=sys.stderr)
        return 2
    if not LEVEL_SCENE_DIR.is_dir():
        print(f"[FAIL] 缺少关卡场景目录: {LEVEL_SCENE_DIR.relative_to(ROOT)}", file=sys.stderr)
        return 2
    class_index = build_class_index()
    levels = collect_levels(class_index)
    bullets = collect_monster_bullets()
    try:
        dynamic = build_dynamic_paths(levels)
    except ValueError as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    if dynamic.missing:
        print("[FAIL] 动态路径数据源存在缺失或悬空项:", file=sys.stderr)
        for line in dynamic.missing[:50]:
            print("    " + line, file=sys.stderr)
        if len(dynamic.missing) > 50:
            print(f"    ... 其余 {len(dynamic.missing) - 50} 项", file=sys.stderr)
        return 1
    content = catalog_content(levels, bullets, dynamic)
    manifest = dependency_manifest_content(dynamic, bullets)
    unresolved: list[str] = []
    for scene, entry in levels.items():
        if entry.unresolved:
            unresolved.append(f"{scene}: {', '.join(entry.unresolved)}")
    if unresolved:
        print("[!] 存在无法静态解析的阶段条目（由关卡运行期自行预载）：", file=sys.stderr)
        for line in unresolved[:20]:
            print("    " + line, file=sys.stderr)
    late_stage_missing = [
        (scene, monster_id)
        for scene, entry in levels.items()
        for monster_id in entry.late_stage_ids
        if monster_id not in entry.monster_ids
    ]
    if late_stage_missing:
        print("[FAIL] stage_5+ 怪物未进入 monster_ids 完整集合:", file=sys.stderr)
        for scene, monster_id in late_stage_missing[:20]:
            print(f"    {scene}: {monster_id}", file=sys.stderr)
        return 1
    populated = sum(1 for entry in levels.values() if entry.monster_ids)
    summary = (
        f"{populated} 个关卡条目，{len(bullets)} 个怪物弹体条目，"
        f"{len(levels)} 个场景已登记；依赖清单 {len(dynamic.manifest_monster_scenes)} 个怪物场景 / "
        f"{len(dynamic.manifest_dynamic_scenes)} 个动态场景 / "
        f"{len(dynamic.manifest_dynamic_textures)} 个动态纹理"
    )
    if check_only:
        outputs = (
            (CATALOG_PATH, content, "关卡预载 Catalog"),
            (EXPORT_MANIFEST_PATH, manifest, "关卡发布依赖清单"),
        )
        for path, expected, label in outputs:
            if not path.is_file():
                print(f"[FAIL] 缺少{label}: {path.relative_to(ROOT)}", file=sys.stderr)
                return 1
            if path.read_text(encoding="utf-8") != expected:
                print(f"[FAIL] {label}已过期: {path.relative_to(ROOT)}", file=sys.stderr)
                return 1
        print(f"[OK] 关卡预载 Catalog 与依赖清单校验通过: {summary}")
        return 0
    for path, text in (
        (CATALOG_PATH, content),
        (EXPORT_MANIFEST_PATH, manifest),
    ):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8", newline="\n")
    print(f"[OK] 关卡预载 Catalog 与依赖清单已生成: {summary}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="生成关卡预载 Catalog 与发布依赖清单")
    parser.add_argument("--check", action="store_true", help="只校验输出是否最新，不写文件")
    args = parser.parse_args()
    return run(args.check)


if __name__ == "__main__":
    sys.exit(main())

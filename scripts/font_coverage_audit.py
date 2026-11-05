#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""静态字体覆盖审计。

扫描 `source/Scene/**/*.tscn` 的文本节点，按 Theme 变体解析最终字体链，
检查中文字符是否存在对应字形。只读脚本，不依赖 Godot 运行时或第三方字体库。

范围：
- 只检查显式绑定 `bhyh_theme.tres` 的场景与控件；
- 只检查 CJK Unified Ideographs（U+3400-U+9FFF）；
- 运行期创建、动态拼接文本不纳入静态覆盖统计。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
THEME_PATH = SOURCE / "Scene" / "theme" / "bhyh_theme.tres"
CJK_START = 0x3400
CJK_END = 0x9FFF

NODE_RE = re.compile(r'^\[node name="([^"]*)"')
TEXT_RE = re.compile(r'^text\s*=\s*"((?:[^"\\]|\\.)*)"', re.MULTILINE)
VARIATION_RE = re.compile(r'^theme_type_variation\s*=\s*"([^"]+)"', re.MULTILINE)
THEME_RE = re.compile(r'^theme\s*=\s*ExtResource\("([^"]+)"\)', re.MULTILINE)
EXT_RE = re.compile(r'^\[ext_resource type="([^"]+)" path="([^"]+)" id="([^"]+)"\]')
EXT_REF_RE = re.compile(r'ExtResource\("([^"]+)"\)')
BASE_TYPE_RE = re.compile(r'^base_type\s*=\s*&?"([^"]+)"')


@dataclass
class FontFace:
    path: str
    codepoints: set[int] | None
    error: str = ""

    def has_char(self, codepoint: int) -> bool:
        return self.codepoints is not None and codepoint in self.codepoints


def _u16(data: bytes, offset: int) -> int:
    return int.from_bytes(data[offset : offset + 2], "big")


def _u32(data: bytes, offset: int) -> int:
    return int.from_bytes(data[offset : offset + 4], "big")


def _font_base(data: bytes) -> int:
    if data[:4] != b"ttcf":
        return 0
    count = _u32(data, 8)
    if count < 1:
        raise ValueError("TTC 不包含字体面")
    return _u32(data, 12)


def _font_tables(data: bytes, base: int) -> dict[str, tuple[int, int]]:
    count = _u16(data, base + 4)
    tables: dict[str, tuple[int, int]] = {}
    for index in range(count):
        offset = base + 12 + index * 16
        tag = data[offset : offset + 4].decode("latin1")
        tables[tag] = (_u32(data, offset + 8), _u32(data, offset + 12))
    return tables


def _cmap_codepoints(data: bytes, tables: dict[str, tuple[int, int]]) -> set[int]:
    table_offset, table_length = tables["cmap"]
    count = _u16(data, table_offset + 2)
    records: list[tuple[int, int, int, int]] = []
    for index in range(count):
        offset = table_offset + 4 + index * 8
        platform = _u16(data, offset)
        encoding = _u16(data, offset + 2)
        sub_offset = table_offset + _u32(data, offset + 4)
        records.append((platform, encoding, sub_offset, _u16(data, sub_offset)))
    # 优先 Unicode BMP/全平面子表；同一字体可能包含多个子表，合并覆盖集合。
    priority = {10: 0, 1: 1, 0: 2, 4: 3, 6: 4}
    records.sort(key=lambda item: (0 if item[0] == 3 else 1, priority.get(item[1], 9)))
    codepoints: set[int] = set()
    for _platform, _encoding, offset, fmt in records:
        if fmt == 12:
            groups = _u32(data, offset + 12)
            for index in range(groups):
                group = offset + 16 + index * 12
                start, end = _u32(data, group), _u32(data, group + 4)
                codepoints.update(range(start, end + 1))
        elif fmt == 13:
            groups = _u32(data, offset + 12)
            for index in range(groups):
                group = offset + 16 + index * 12
                start, end = _u32(data, group), _u32(data, group + 4)
                codepoints.update(range(start, end + 1))
        elif fmt == 4:
            seg_count = _u16(data, offset + 6) // 2
            end_codes = offset + 14
            start_codes = end_codes + seg_count * 2 + 2
            id_deltas = start_codes + seg_count * 2
            id_range_offsets = id_deltas + seg_count * 2
            for index in range(seg_count):
                start = _u16(data, start_codes + index * 2)
                end = _u16(data, end_codes + index * 2)
                delta = _u16(data, id_deltas + index * 2)
                range_offset = _u16(data, id_range_offsets + index * 2)
                for codepoint in range(start, end + 1):
                    if codepoint == 0xFFFF:
                        continue
                    if range_offset == 0:
                        glyph = (codepoint + delta) & 0xFFFF
                    else:
                        glyph_offset = id_range_offsets + index * 2 + range_offset + (codepoint - start) * 2
                        if glyph_offset + 2 > len(data):
                            continue
                        glyph = _u16(data, glyph_offset)
                        if glyph != 0:
                            glyph = (glyph + delta) & 0xFFFF
                    if glyph != 0:
                        codepoints.add(codepoint)
        # 其他格式（如 0/6）对当前 CJK 检查不是必需；缺失时由覆盖结果显式体现。
    return codepoints


def load_face(path: str) -> FontFace:
    file_path = SOURCE / path.removeprefix("res://")
    if not file_path.is_file():
        return FontFace(path, None, "文件不存在")
    try:
        data = file_path.read_bytes()
        base = _font_base(data)
        tables = _font_tables(data, base)
        if "cmap" not in tables:
            return FontFace(path, None, "缺少 cmap")
        return FontFace(path, _cmap_codepoints(data, tables))
    except (OSError, ValueError, IndexError, KeyError) as exc:
        return FontFace(path, None, str(exc))


def _read_ext_resources(text: str) -> dict[str, tuple[str, str]]:
    resources: dict[str, tuple[str, str]] = {}
    for line in text.splitlines():
        match = EXT_RE.match(line)
        if match:
            resources[match.group(3)] = (match.group(1), match.group(2))
    return resources


def _read_props(text: str, marker: str = "[resource]") -> dict[str, str]:
    lines = text.splitlines()
    try:
        start = next(index for index, line in enumerate(lines) if line.strip() == marker)
    except StopIteration:
        return {}
    props: dict[str, str] = {}
    for line in lines[start + 1 :]:
        if line.startswith("["):
            continue
        if "=" in line:
            key, value = line.split("=", 1)
            props[key.strip()] = value.strip()
    return props


class ThemeFonts:
    def __init__(self, path: Path) -> None:
        self.path = path
        text = path.read_text(encoding="utf-8")
        self.ext = _read_ext_resources(text)
        self.props = _read_props(text)
        self.variants: dict[str, dict[str, str]] = {}
        for key, value in self.props.items():
            if "/" in key:
                name, rest = key.split("/", 1)
                self.variants.setdefault(name, {})[rest] = value
        self._resolved: dict[str, list[str]] = {}
        self.default = self._resolve_value(self.props.get("default_font", ""))

    def _variation_file(self, resource_id: str) -> list[str]:
        kind, path = self.ext.get(resource_id, ("", ""))
        if not path:
            return []
        if kind == "FontVariation" and path.endswith(".tres"):
            return self._font_variation(path, resource_id)
        return [path]

    def _font_variation(self, path: str, resource_id: str) -> list[str]:
        if resource_id in self._resolved:
            return self._resolved[resource_id]
        file_path = SOURCE / path.removeprefix("res://")
        if not file_path.is_file():
            return []
        wrapper = ThemeFonts(file_path)
        chain: list[str] = []
        for value in [wrapper.props.get("base_font", ""), wrapper.props.get("fallbacks", "")]:
            for ref in EXT_REF_RE.findall(value):
                chain.extend(wrapper._variation_file(ref))
        self._resolved[resource_id] = chain
        return chain

    def _resolve_value(self, value: str) -> list[str]:
        refs = EXT_REF_RE.findall(value)
        if not refs:
            return []
        result: list[str] = []
        for ref in refs:
            result.extend(self._variation_file(ref))
        return result

    def resolve_variant(self, name: str, seen: set[str] | None = None) -> list[str]:
        if seen is None:
            seen = set()
        if name in seen:
            return []
        seen.add(name)
        props = self.variants.get(name, {})
        font = props.get("fonts/font", "")
        if font:
            return self._resolve_value(font)
        base = props.get("base_type", "").strip('&"')
        if base in self.variants:
            return self.resolve_variant(base, seen)
        return list(self.default)


def _scene_text_owner(text: str, resources: dict[str, tuple[str, str]]) -> str:
    match = THEME_RE.search(text)
    if not match:
        return ""
    resource = resources.get(match.group(1))
    return resource[1] if resource else ""


def scan(theme: ThemeFonts) -> dict[str, object]:
    faces: dict[str, FontFace] = {}
    missing_fonts: dict[str, str] = {}
    text_nodes = 0
    cjk_nodes = 0
    missing_nodes = 0
    missing_samples: list[dict[str, str]] = []
    missing_chars: dict[str, int] = {}
    font_nodes: Counter[str] = Counter()
    scenes = 0
    skipped_scenes = 0

    for scene_path in sorted((SOURCE / "Scene").rglob("*.tscn")):
        text = scene_path.read_text(encoding="utf-8", errors="ignore")
        resources = _read_ext_resources(text)
        if _scene_text_owner(text, resources) != "res://Scene/theme/bhyh_theme.tres":
            skipped_scenes += 1
            continue
        scenes += 1
        # 逐节点块解析：node 块从 [node ...] 开始，到下一个 [node / sub_resource] 前结束。
        blocks = re.split(r'(?=^\[node )', text, flags=re.MULTILINE)
        for block in blocks:
            node = NODE_RE.match(block)
            if not node:
                continue
            text_match = TEXT_RE.search(block)
            if not text_match:
                continue
            content = text_match.group(1)
            if not content or not any(CJK_START <= ord(ch) <= CJK_END for ch in content):
                continue
            text_nodes += 1
            cjk_nodes += 1
            variation_match = VARIATION_RE.search(block)
            chain = theme.resolve_variant(variation_match.group(1)) if variation_match else list(theme.default)
            key = " + ".join(chain) if chain else "(no font)"
            font_nodes[key] += 1
            if not chain:
                missing_nodes += 1
                if len(missing_samples) < 20:
                    missing_samples.append({"scene": scene_path.relative_to(SOURCE).as_posix(), "node": node.group(1), "variation": variation_match.group(1) if variation_match else "", "missing": content[:60], "font": key})
                continue
            resolved: set[int] = set()
            for font_path in chain:
                if font_path not in faces:
                    face = load_face(font_path)
                    faces[font_path] = face
                    if face.error:
                        missing_fonts[font_path] = face.error
                if faces[font_path].codepoints is not None:
                    resolved.update(faces[font_path].codepoints or ())
            missing = [ch for ch in content if CJK_START <= ord(ch) <= CJK_END and ord(ch) not in resolved]
            if missing:
                missing_nodes += 1
                for ch in set(missing):
                    missing_chars[ch] = missing_chars.get(ch, 0) + 1
                if len(missing_samples) < 20:
                    missing_samples.append({"scene": scene_path.relative_to(SOURCE).as_posix(), "node": node.group(1), "variation": variation_match.group(1) if variation_match else "", "missing": "".join(missing), "text": content[:60], "font": key})

    return {
        "theme": str(theme.path.relative_to(ROOT)),
        "default_font": theme.default,
        "scenes": scenes,
        "skipped_scenes_without_theme": skipped_scenes,
        "text_nodes": text_nodes,
        "cjk_nodes": cjk_nodes,
        "missing_nodes": missing_nodes,
        "missing_chars": dict(sorted(missing_chars.items(), key=lambda item: (-item[1], item[0]))),
        "missing_samples": missing_samples,
        "font_nodes": dict(font_nodes.most_common()),
        "fonts": {path: {"error": face.error, "codepoints": len(face.codepoints) if face.codepoints is not None else 0} for path, face in sorted(faces.items())},
        "missing_fonts": missing_fonts,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="静态中文字体覆盖审计")
    parser.add_argument("--check", action="store_true", help="发现缺字或无法解析字体时返回 1")
    parser.add_argument("--json", action="store_true", help="输出 JSON 报告")
    parser.add_argument("--allow-missing-fonts", action="store_true", help="字体文件缺失时只警告，不失败")
    args = parser.parse_args(argv)

    if not THEME_PATH.is_file():
        print(f"FAIL Theme 不存在: {THEME_PATH.relative_to(ROOT)}", file=sys.stderr)
        return 2
    theme = ThemeFonts(THEME_PATH)
    report = scan(theme)
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print(f"字体覆盖：场景 {report['scenes']}，中文文本节点 {report['cjk_nodes']}，缺字节点 {report['missing_nodes']}")
        print(f"默认字体链: {' + '.join(report['default_font']) or '(none)'}")
        if report["missing_fonts"]:
            for path, error in report["missing_fonts"].items():
                print(f"WARN 字体无法读取: {path} ({error})", file=sys.stderr)
        for sample in report["missing_samples"]:
            print(f"MISS {sample['scene']}::{sample['node']} 变体={sample['variation']!r} 字体={sample['font']} 缺字={sample['missing']!r}")
        if report["missing_chars"]:
            print("缺字统计:", report["missing_chars"])

    if not args.check:
        return 0
    if report["missing_nodes"]:
        return 1
    if report["missing_fonts"] and not args.allow_missing_fonts:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

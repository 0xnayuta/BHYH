#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""UI 字体角色语义审计。

本脚本只读检查 `bhyh_theme.tres`、字体角色包装与运行时脚本：

- 每个业务变体的有效字体必须能归入 `body` / `ui` / `display` / `accent`；
- 角色配置、包装资源、基础字体与 fallback 必须一致；
- 禁止运行时引用已退役的宋体文件；
- 禁止场景直接绑定 FontFile，禁止脚本出现未登记的直接字体路径；
- 角色字号超出规范区间时，必须命中 `font_role_baseline.json` 的存量例外。

`--write` 只用于记录当前存量字号例外；新增例外必须评审并更新标准。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
THEME = SOURCE / "Scene" / "theme" / "bhyh_theme.tres"
TOKEN_SOURCE = ROOT / "scripts" / "ui_theme_tokens.json"
BASELINE = ROOT / "scripts" / "font_role_baseline.json"
ROLE_ORDER = ("body", "ui", "display", "accent")
FONT_EXT_RE = re.compile(
    r'^\[ext_resource type="([^"]+)" path="([^"]+)" id="([^"]+)"\]', re.MULTILINE
)
EXT_REF_RE = re.compile(r'ExtResource\("([^"]+)"\)')
PROP_RE = re.compile(r'^([A-Za-z0-9_]+)/([A-Za-z0-9_]+) = (.+)$')
SCENE_FONT_RE = re.compile(r'^\[ext_resource type="FontFile" path="([^"]+)"')
SCRIPT_FONT_RE = re.compile(r'res://Font/[^"\'\s]+')


def _read_ext(text: str) -> dict[str, tuple[str, str]]:
    return {
        match.group(3): (match.group(1), match.group(2))
        for match in FONT_EXT_RE.finditer(text)
    }


def _read_props(text: str) -> dict[str, str]:
    lines = text.splitlines()
    try:
        start = next(index for index, line in enumerate(lines) if line.strip() == "[resource]")
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


def _refs(value: str) -> list[str]:
    return EXT_REF_RE.findall(value)


def _resource_path(ext: dict[str, tuple[str, str]], ref: str) -> str:
    kind, path = ext.get(ref, ("", ""))
    if not path:
        raise ValueError(f"未声明的 ExtResource: {ref}")
    if kind not in {"FontFile", "FontVariation"}:
        raise ValueError(f"非字体资源: {ref} -> {kind}")
    return path


def _role_size_ok(role: str, size: int) -> bool:
    if role == "body":
        return 10 <= size <= 20 or size in {24, 28, 32, 36, 40, 50, 76, 100}
    if role == "ui":
        return 14 <= size <= 24
    if role == "display":
        return 16 <= size <= 40 or size == 50
    if role == "accent":
        return 16 <= size <= 32
    return False


class Theme:
    def __init__(self) -> None:
        self.text = THEME.read_text(encoding="utf-8")
        self.ext = _read_ext(self.text)
        self.props = _read_props(self.text)
        self.variants: dict[str, dict[str, str]] = {}
        for key, value in self.props.items():
            if "/" not in key:
                continue
            name, suffix = key.split("/", 1)
            self.variants.setdefault(name, {})[suffix] = value
        self.default_ref = _refs(self.props.get("default_font", ""))
        if len(self.default_ref) != 1:
            raise ValueError("Theme default_font 必须且只能有一个 ExtResource")

    def wrapper_path(self, resource_id: str) -> str:
        return _resource_path(self.ext, resource_id)

    def variant_font_ref(self, name: str, seen: set[str] | None = None) -> str:
        if seen is None:
            seen = set()
        if name in seen:
            raise ValueError(f"字体继承成环: {name}")
        seen.add(name)
        props = self.variants.get(name, {})
        own = _refs(props.get("fonts/font", ""))
        if own:
            if len(own) != 1:
                raise ValueError(f"{name} 字体引用不唯一")
            return own[0]
        base_type = props.get("base_type", "").strip("&\"")
        if base_type and base_type in self.variants:
            return self.variant_font_ref(base_type, seen)
        return self.default_ref[0]

    def variant_size(self, name: str, seen: set[str] | None = None) -> int:
        if seen is None:
            seen = set()
        if name in seen:
            raise ValueError(f"字号继承成环: {name}")
        seen.add(name)
        props = self.variants.get(name, {})
        own = props.get("font_sizes/font_size", "")
        if own.isdigit():
            return int(own)
        base_type = props.get("base_type", "").strip("&\"")
        if base_type and base_type in self.variants:
            return self.variant_size(base_type, seen)
        return 16


def _load_roles(theme: Theme) -> dict[str, dict[str, object]]:
    data = json.loads(TOKEN_SOURCE.read_text(encoding="utf-8"))
    roles = data.get("font_roles")
    if not isinstance(roles, dict):
        raise ValueError("ui_theme_tokens.json 缺少 font_roles")
    result: dict[str, dict[str, object]] = {}
    for role in ROLE_ORDER:
        item = roles.get(role)
        if not isinstance(item, dict):
            raise ValueError(f"字体角色缺失: {role}")
        resource_id = item.get("resource_id")
        path = item.get("path")
        fallback = item.get("fallback", "")
        if not isinstance(resource_id, str) or not resource_id:
            raise ValueError(f"{role}.resource_id 非法")
        if not isinstance(path, str) or not path.startswith("res://"):
            raise ValueError(f"{role}.path 非法")
        wrapper = theme.wrapper_path(resource_id)
        wrapper_file = SOURCE / wrapper.removeprefix("res://")
        if not wrapper_file.is_file():
            raise ValueError(f"{role} 包装不存在: {wrapper}")
        wrapper_text = wrapper_file.read_text(encoding="utf-8")
        wrapper_ext = _read_ext(wrapper_text)
        wrapper_props = _read_props(wrapper_text)
        base_refs = _refs(wrapper_props.get("base_font", ""))
        if len(base_refs) != 1:
            raise ValueError(f"{role} 包装 base_font 不唯一: {wrapper}")
        base_path = _resource_path(wrapper_ext, base_refs[0])
        if base_path != path:
            raise ValueError(f"{role} 基础字体不一致: {base_path} != {path}")
        result[role] = {
            "resource_id": resource_id,
            "wrapper": wrapper,
            "base_font": base_path,
            "fallback": fallback,
        }
    return result


def _role_for_ref(theme: Theme, roles: dict[str, dict[str, object]], ref: str) -> str | None:
    path = _resource_path(theme.ext, ref)
    for role, item in roles.items():
        if path == item["wrapper"]:
            return role
    # 直接资源引用只允许是角色基础字体，且不能有歧义（body/display 共字形时拒绝）。
    matches = [role for role, item in roles.items() if path == item["base_font"]]
    if len(matches) == 1:
        return matches[0]
    return None


def _allowed_font_files(theme: Theme, roles: dict[str, dict[str, object]]) -> set[str]:
    result: set[str] = set()
    for role in ROLE_ORDER:
        wrapper = SOURCE / str(roles[role]["wrapper"]).removeprefix("res://")
        wrapper_ext = _read_ext(wrapper.read_text(encoding="utf-8"))
        wrapper_props = _read_props(wrapper.read_text(encoding="utf-8"))
        for value in [wrapper_props.get("base_font", ""), wrapper_props.get("fallbacks", "")]:
            for ref in _refs(value):
                kind, path = wrapper_ext.get(ref, ("", ""))
                if kind == "FontFile":
                    result.add(path)
                elif kind == "FontVariation":
                    # fallback 包装自身的 base/fallback 也允许。
                    nested = SOURCE / path.removeprefix("res://")
                    if nested.is_file():
                        nested_text = nested.read_text(encoding="utf-8")
                        nested_ext = _read_ext(nested_text)
                        nested_props = _read_props(nested_text)
                        for nested_value in [
                            nested_props.get("base_font", ""),
                            nested_props.get("fallbacks", ""),
                        ]:
                            for nested_ref in _refs(nested_value):
                                kind2, path2 = nested_ext.get(nested_ref, ("", ""))
                                if kind2 == "FontFile":
                                    result.add(path2)
    return result


def _scan_scripts(allowed: set[str]) -> list[str]:
    errors: list[str] = []
    for root in (SOURCE / "Script", SOURCE / "Scene"):
        for path in sorted(root.rglob("*.gd")):
            if path.is_relative_to(SOURCE / "addons"):
                continue
            text = path.read_text(encoding="utf-8", errors="ignore")
            for match in SCRIPT_FONT_RE.finditer(text):
                font = match.group(0)
                if font not in allowed:
                    errors.append(
                        f"脚本直接字体未登记: {path.relative_to(SOURCE).as_posix()}: {font}"
                    )
    return errors


def _scan_scenes() -> list[str]:
    errors: list[str] = []
    for path in sorted((SOURCE / "Scene").rglob("*.tscn")):
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            if SCENE_FONT_RE.match(line):
                errors.append(f"场景直接绑定 FontFile: {path.relative_to(SOURCE).as_posix()}")
                break
    return errors


def _scan_retired_fonts() -> list[str]:
    errors: list[str] = []
    for path in sorted(SOURCE.rglob("*")):
        if not path.is_file() or path.suffix not in {".gd", ".tscn", ".tres", ".json"}:
            continue
        if any(part in {".godot", "addons"} for part in path.parts):
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if "source_han_serif" in text:
            errors.append(f"运行时仍引用宋体: {path.relative_to(SOURCE).as_posix()}")
    return errors


def _load_baseline() -> dict[str, dict[str, object]]:
    if not BASELINE.is_file():
        raise ValueError(f"基线不存在: {BASELINE.relative_to(ROOT)}；先运行 --write")
    data = json.loads(BASELINE.read_text(encoding="utf-8"))
    exceptions = data.get("size_exceptions")
    if not isinstance(exceptions, dict):
        raise ValueError("font_role_baseline.json 缺少 size_exceptions")
    return exceptions


def _write_baseline(exceptions: dict[str, dict[str, object]]) -> None:
    payload = {
        "schema_id": "font_role_baseline",
        "schema_version": 1,
        "size_exceptions": exceptions,
    }
    BASELINE.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n"
    )


def check(write: bool) -> int:
    errors: list[str] = []
    try:
        theme = Theme()
        roles = _load_roles(theme)
        role_counts: Counter[str] = Counter()
        actual_exceptions: dict[str, dict[str, object]] = {}
        for name in sorted(theme.variants):
            font_ref = theme.variant_font_ref(name)
            role = _role_for_ref(theme, roles, font_ref)
            if role is None:
                errors.append(f"{name}: 未知字体角色 {font_ref}")
                continue
            role_counts[role] += 1
            size = theme.variant_size(name)
            if not _role_size_ok(role, size):
                actual_exceptions[name] = {
                    "role": role,
                    "size": size,
                    "reason": "存量字号偏离；迁移前保留，禁止扩散",
                }
        allowed = _allowed_font_files(theme, roles)
        errors.extend(_scan_scripts(allowed))
        errors.extend(_scan_scenes())
        errors.extend(_scan_retired_fonts())
        if write:
            _write_baseline(actual_exceptions)
        else:
            baseline = _load_baseline()
            unexpected = sorted(set(actual_exceptions) - set(baseline))
            stale = sorted(set(baseline) - set(actual_exceptions))
            if unexpected:
                errors.append("新增字号例外未登记: " + ", ".join(unexpected))
            if stale:
                errors.append("基线例外已不再命中: " + ", ".join(stale))
            for name in sorted(set(actual_exceptions) & set(baseline)):
                if actual_exceptions[name] != baseline[name]:
                    errors.append(f"{name}: 字号例外内容与基线不一致")
        if errors:
            for error in errors:
                print(f"[font_role_audit] ERROR: {error}", file=sys.stderr)
            return 1
        print(
            "font_role_audit: variants=%d roles=%s exceptions=%d"
            % (
                sum(role_counts.values()),
                ",".join(f"{role}:{role_counts[role]}" for role in ROLE_ORDER),
                len(actual_exceptions),
            )
        )
        return 0
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"[font_role_audit] ERROR: {exc}", file=sys.stderr)
        return 1


def main() -> int:
    parser = argparse.ArgumentParser(description="UI 字体角色语义审计")
    parser.add_argument("--check", action="store_true", help="检查角色、字体来源与字号例外")
    parser.add_argument("--write", action="store_true", help="写入当前存量字号例外基线")
    args = parser.parse_args()
    if not args.check and not args.write:
        parser.error("必须指定 --check 或 --write")
    return check(args.write)


if __name__ == "__main__":
    sys.exit(main())

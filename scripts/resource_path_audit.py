#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/resource_path_audit.py

资源路径大小写与动态路径工厂门禁。

检查范围
--------
1. `.gd` / `.tscn` 中的静态 `res://` 文件路径：逐级校验目录与文件名大小写；
2. 带 `%d` / `%s` / `%f` 的格式路径：若存在仅大小写或下划线差异的真实文件，判为命名不一致；
3. Spine `.atlas` 页名：必须与同目录真实 PNG 文件名逐字一致；
4. 动态工厂：
   - `add_role_bullet()` 的语义名必须能映射到 `role_bullet_slim/` 下的真实场景；
   - `add_role_special_effect()` 的语义名必须能映射到 `role_special_effect_slim/` 下的真实场景。

边界
----
- 公开 clone 缺少 `source/Art/`、`Font/`、`Music/`、`Spritesheet/` 时，跳过对应素材路径；Art 缺失时跳过 atlas 页；
- 仅校验可静态证明的路径；无法解析的拼接表达式不猜测；
- 只读，不修改任何文件。
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PROJECT = REPO_ROOT / "source"
RESOURCE_SUFFIXES = {
    ".atlas",
    ".gd",
    ".gdshader",
    ".json",
    ".mp3",
    ".ogg",
    ".otf",
    ".png",
    ".res",
    ".spine-json",
    ".tres",
    ".tscn",
    ".ttf",
    ".wav",
}
SOURCE_SUFFIXES = {".gd", ".tscn"}
PATH_LITERAL_RE = re.compile(r'"(res://[^"\n]+)"')
DYNAMIC_TOKEN_RE = re.compile(r"%(?:0?[0-9]+)?[dsf]")
SPECIAL_BULLET_NAMES = {"Role3Bullet2", "Role3Bullet3", "TtzsszBullet"}
SPECIAL_EFFECT_NAMES = {"sd", "sd2", "zznh"}
ASSET_ROOTS = ("Art", "Font", "Music", "Spritesheet")
_ENTRY_CACHE: dict[Path, set[str]] = {}


def _display(path: Path) -> str:
    try:
        return path.relative_to(REPO_ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def _iter_exact_entries(directory: Path) -> set[str]:
    if directory not in _ENTRY_CACHE:
        _ENTRY_CACHE[directory] = {entry.name for entry in directory.iterdir()} if directory.is_dir() else set()
    return _ENTRY_CACHE[directory]


def _resolve_exact(project: Path, resource_path: str) -> bool:
    relative = resource_path.removeprefix("res://")
    current = project
    for part in relative.split("/"):
        if not part:
            return False
        if part not in _iter_exact_entries(current):
            return False
        current /= part
    return True


def _find_near_path(project: Path, resource_path: str, all_files: list[str]) -> str:
    wanted = _normalize_name(resource_path)
    for candidate in all_files:
        if _normalize_name("res://" + candidate) == wanted:
            return "res://" + candidate
    return ""


def _normalize_name(value: str) -> str:
    return value.replace("_", "").lower()


def _dynamic_regex(value: str) -> re.Pattern[str]:
    parts: list[str] = []
    cursor = 0
    for match in DYNAMIC_TOKEN_RE.finditer(value):
        parts.append(re.escape(value[cursor : match.start()]))
        token = match.group(0)
        if token.endswith("d"):
            parts.append(r"[0-9]+")
        elif token.endswith("f"):
            parts.append(r"[0-9]+(?:\.[0-9]+)?")
        else:
            parts.append(r"[^/]+")
        cursor = match.end()
    parts.append(re.escape(value[cursor:]))
    return re.compile("^" + "".join(parts) + "$")


def _normalized_regex(value: str) -> re.Pattern[str]:
    parts: list[str] = []
    cursor = 0
    for match in DYNAMIC_TOKEN_RE.finditer(value):
        parts.append(re.escape(_normalize_name(value[cursor : match.start()])))
        token = match.group(0)
        if token.endswith("d"):
            parts.append(r"[0-9]+")
        elif token.endswith("f"):
            parts.append(r"[0-9]+(?:\.[0-9]+)?")
        else:
            parts.append(r"[^/]+")
        cursor = match.end()
    parts.append(re.escape(_normalize_name(value[cursor:])))
    return re.compile("^" + "".join(parts) + "$")


def _is_skipped_asset_path(resource_path: str, missing_roots: set[str]) -> bool:
    return any(resource_path.startswith(f"res://{root}/") for root in missing_roots)


def _audit_static_path(
    project: Path,
    source_path: Path,
    resource_path: str,
    all_files: list[str],
    missing_roots: set[str],
) -> str | None:
    if _is_skipped_asset_path(resource_path, missing_roots):
        return None
    if _resolve_exact(project, resource_path):
        return None
    near = _find_near_path(project, resource_path, all_files)
    if near:
        return f"{_display(source_path)}: 大小写/命名不一致: {resource_path} -> {near}"
    return f"{_display(source_path)}: 文件不存在: {resource_path}"


def _audit_dynamic_path(
    source_path: Path,
    resource_path: str,
    candidates: list[str],
    missing_roots: set[str],
) -> str | None:
    if _is_skipped_asset_path(resource_path, missing_roots):
        return None
    exact_regex = _dynamic_regex(resource_path)
    resource_candidates = ["res://" + candidate for candidate in candidates]
    if any(exact_regex.fullmatch(candidate) for candidate in resource_candidates):
        return None
    normalized_regex = _normalized_regex(resource_path)
    near = [
        candidate for candidate in resource_candidates if normalized_regex.fullmatch(_normalize_name(candidate))
    ]
    if near:
        return f"{_display(source_path)}: 动态路径大小写/命名不一致: {resource_path} -> {near[0]}"
    return None


def _split_top_level_arguments(call_text: str) -> list[str]:
    arguments: list[str] = []
    start = 0
    depth = 0
    quote = ""
    escaped = False
    for index, character in enumerate(call_text):
        if quote:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = ""
            continue
        if character in "\"'":
            quote = character
        elif character in "([{":
            depth += 1
        elif character in ")]}":
            depth = max(0, depth - 1)
        elif character == "," and depth == 0:
            arguments.append(call_text[start:index])
            start = index + 1
    arguments.append(call_text[start:])
    return arguments


def _factory_calls(source: str, function_name: str) -> list[str]:
    calls: list[str] = []
    search_from = 0
    marker = f"{function_name}("
    while True:
        start = source.find(marker, search_from)
        if start < 0:
            break
        cursor = start + len(marker)
        depth = 1
        quote = ""
        escaped = False
        while cursor < len(source) and depth > 0:
            character = source[cursor]
            if quote:
                if escaped:
                    escaped = False
                elif character == "\\":
                    escaped = True
                elif character == quote:
                    quote = ""
            elif character in "\"'":
                quote = character
            elif character == "(":
                depth += 1
            elif character == ")":
                depth -= 1
            cursor += 1
        if depth == 0:
            calls.append(source[start + len(marker) : cursor - 1])
        search_from = cursor
    return calls


def _factory_literal(call_text: str, argument_index: int = 3) -> str:
    arguments = _split_top_level_arguments(call_text)
    if argument_index >= len(arguments):
        return ""
    match = re.search(r'"([^"\n]+)"', arguments[argument_index])
    return match.group(1) if match else ""


def _bullet_slim_filename(value: str) -> str:
    result: list[str] = []
    length = len(value)
    for index, character in enumerate(value):
        if "A" <= character <= "Z":
            previous = value[index - 1] if index > 0 else ""
            next_character = value[index + 1] if index + 1 < length else ""
            if (
                ("a" <= previous <= "z")
                or ("0" <= previous <= "9")
                or ("A" <= previous <= "Z" and "a" <= next_character <= "z")
            ):
                result.append("_")
            result.append(character.lower())
        else:
            result.append(character)
    return "".join(result) + ".tscn"


def _audit_factories(project: Path, sources: list[Path]) -> list[str]:
    findings: list[str] = []
    bullet_dir = project / "Scene" / "hero" / "role_bullet_slim"
    effect_dir = project / "Scene" / "hero" / "role_special_effect_slim"
    bullet_calls = 0
    effect_calls = 0
    for source_path in sources:
        try:
            source = source_path.read_text(encoding="utf-8")
        except OSError:
            continue
        for call_text in _factory_calls(source, "add_role_bullet"):
            literal = _factory_literal(call_text)
            if not literal or literal in SPECIAL_BULLET_NAMES:
                continue
            bullet_calls += 1
            filename = _bullet_slim_filename(literal)
            if not (bullet_dir / filename).is_file():
                findings.append(
                    f"{_display(source_path)}: add_role_bullet 工厂缺失场景: {literal} -> {filename}"
                )
        for call_text in _factory_calls(source, "add_role_special_effect"):
            literal = _factory_literal(call_text)
            if not literal or literal in SPECIAL_EFFECT_NAMES:
                continue
            effect_calls += 1
            filename = literal + ".tscn"
            if not (effect_dir / filename).is_file():
                findings.append(
                    f"{_display(source_path)}: add_role_special_effect 工厂缺失场景: {literal} -> {filename}"
                )
    print(f"[*] 动态工厂: add_role_bullet={bullet_calls}, add_role_special_effect={effect_calls}")
    return findings


def _audit_atlases(art_root: Path) -> tuple[list[str], int]:
    findings: list[str] = []
    page_count = 0
    if not art_root.is_dir():
        return findings, page_count
    for atlas in sorted(art_root.rglob("*.atlas")):
        try:
            lines = atlas.read_text(encoding="utf-8", errors="replace").splitlines()
        except OSError as error:
            findings.append(f"{_display(atlas)}: 无法读取 atlas: {error}")
            continue
        for line_number, line in enumerate(lines, 1):
            page = line.strip()
            if not page.lower().endswith(".png") or page != line or ":" in page:
                continue
            page_count += 1
            target = atlas.parent / page
            if target.is_file():
                continue
            findings.append(
                f"{_display(atlas)}:{line_number}: atlas 页名与真实文件不一致: {page}"
            )
    return findings, page_count


def run(project: Path) -> tuple[list[str], dict[str, int]]:
    if not project.is_dir():
        raise FileNotFoundError(f"项目目录不存在: {project}")
    art_present = (project / "Art").is_dir()
    missing_roots = {root for root in ASSET_ROOTS if not (project / root).is_dir()}
    all_files = [
        path.relative_to(project).as_posix()
        for path in project.rglob("*")
        if path.is_file()
    ]
    files_by_dir: dict[str, list[str]] = {}
    for relative in all_files:
        parent = relative.rsplit("/", 1)[0] if "/" in relative else ""
        files_by_dir.setdefault(parent, []).append(relative)
    findings: list[str] = []
    static_count = 0
    dynamic_count = 0
    sources = sorted(project.rglob("*.gd")) + sorted(project.rglob("*.tscn"))
    for source_path in sources:
        try:
            text = source_path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        for match in PATH_LITERAL_RE.finditer(text):
            resource_path = match.group(1)
            if "%" in resource_path:
                if any(marker in resource_path for marker in ("+", "{", "}", "$", "|", "[", "]")):
                    continue
                dynamic_count += 1
                first_token = DYNAMIC_TOKEN_RE.search(resource_path)
                dynamic_candidates = all_files
                if first_token is not None:
                    fixed_prefix = resource_path[: first_token.start()]
                    fixed_dir = fixed_prefix.rsplit("/", 1)[0].removeprefix("res://")
                    if not DYNAMIC_TOKEN_RE.search(fixed_dir):
                        dynamic_candidates = files_by_dir.get(fixed_dir)
                        if dynamic_candidates is None:
                            dynamic_candidates = all_files
                finding = _audit_dynamic_path(source_path, resource_path, dynamic_candidates, missing_roots)
            else:
                suffix = Path(resource_path).suffix.lower()
                if suffix not in RESOURCE_SUFFIXES:
                    continue
                static_count += 1
                finding = _audit_static_path(project, source_path, resource_path, all_files, missing_roots)
            if finding:
                findings.append(finding)
    findings.extend(_audit_factories(project, [path for path in sources if path.suffix == ".gd"]))
    atlas_findings, atlas_pages = _audit_atlases(project / "Art")
    findings.extend(atlas_findings)
    stats = {
        "static_paths": static_count,
        "dynamic_patterns": dynamic_count,
        "atlas_pages": atlas_pages,
        "art_present": int(art_present),
        "missing_asset_roots": sorted(missing_roots),
    }
    print(
        "[*] 资源路径审计: "
        f"static={static_count}, dynamic={dynamic_count}, atlas_pages={atlas_pages}, "
        f"art={'yes' if art_present else 'no'}"
    )
    return findings, stats


def main() -> int:
    parser = argparse.ArgumentParser(description="资源路径大小写与动态路径工厂门禁")
    parser.add_argument("--project", default=str(DEFAULT_PROJECT), help="Godot 工程目录 (默认: source)")
    parser.add_argument("--json", action="store_true", help="以 JSON 输出结果")
    args = parser.parse_args()
    project = Path(args.project).resolve()
    try:
        findings, stats = run(project)
    except FileNotFoundError as error:
        print(f"[ERROR] {error}")
        return 2
    if args.json:
        print(
            json.dumps(
                {
                    "project": project.as_posix(),
                    "stats": stats,
                    "errors": findings,
                },
                ensure_ascii=False,
                indent=2,
            )
        )
    else:
        for finding in findings[:80]:
            print(f"[ERROR] {finding}")
        if len(findings) > 80:
            print(f"[ERROR] ... 另有 {len(findings) - 80} 条")
        if findings:
            print(f"[FAILURE] 资源路径门禁失败: {len(findings)} 个问题")
            return 1
        print("[SUCCESS] 资源路径大小写与动态路径工厂检查通过")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""发布包资源排除审计：只读校验 export_presets.cfg 的排除策略。

工具职责
--------
1. 读取 ``source/export_presets.cfg``，要求所有 ``all_resources`` 预设使用同一套
   排除策略；两个预设漂移、include/exclude 冲突直接失败。
2. 校验 13 个用户指定的完整目录与所有 ``.dbfactory`` 工厂目录都被排除模式覆盖。
3. 在混合 Art 根（monster/effect/magic_weapon/...）中，压缩前缀 glob 只允许命中
   DragonBones 工厂目录或用户指定完整目录；命中任何非工厂文件即失败。
4. 扫描未被排除的生产 ``.gd/.tscn/.tres/.gdshader``、``project.godot`` 以及
   FrameSequence / 关卡预载 / 原始数据清单中的显式 ``res://`` 与 ``uid://``，
   发现被排除资源仍被生产引用时失败。
5. 公开 clone 缺少私有素材（Art/Music/Font/Spritesheet）时输出 BLOCKED，
   不把“无法验证”伪装成 PASS。

退出码
------
- 0：PASS，策略与引用均已验证；
- 1：FAIL，存在可证明的策略冲突/覆盖缺失/断裂引用；
- 2：BLOCKED，缺少私有素材或清单，无法完成验证（且没有可证明的 FAIL）。

验证边界
--------
只检查字面量引用。运行期由数据/服务器/用户输入拼出的路径、没有出现在文本里的
UID、以及真实 PCK 导出结果都不在本工具证明范围内；JSON 报告的 ``scope`` 字段
会明确列出这些限制，不能把本工具的结果当作完整发布包闭包证明。
"""

from __future__ import annotations

import argparse
import bisect
import json
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterator, Sequence

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "source"

# 用户指定的完整排除目录；配置中必须存在能覆盖其全部文件的 glob。
REQUIRED_EXCLUSION_DIRS: tuple[str, ...] = (
    "Scene/level/zmws",
    "Scene/level/zmws_playable",
    "Art/level/zmws",
    "Art/zmws_spine",
    "Art/ui",
    "Music/zmws",
    "Font/zmws",
    "Font/zmws_bmfont",
    "Art/diepng",
    "Art/skill/all_skills",
    "Art/skill/all_skills_standalone",
    "Art/effect/all_effects",
    "Art/effect/all_effects_standalone",
)

# 公开仓按 ADR-011 排除的素材根；整根缺失说明是公开 clone，不能据此判 PASS。
PRIVATE_ASSET_ROOTS: frozenset[str] = frozenset({"Art", "Music", "Font", "Spritesheet"})

# 生产文本：只有这些扩展名参与显式引用扫描。
PRODUCTION_SUFFIXES: tuple[str, ...] = (".gd", ".tscn", ".tres", ".gdshader")
PRODUCTION_ROOT_FILES: frozenset[str] = frozenset({"project.godot"})
SCAN_SKIP_DIRS: frozenset[str] = frozenset({".godot", ".git", ".svn", "__pycache__"})

# 元数据不是可导出资源；候选路径接口返回时剔除。
METADATA_SUFFIXES: tuple[str, ...] = (".import", ".uid", ".remap")
METADATA_NAMES: frozenset[str] = frozenset({".gdignore", ".DS_Store", "Thumbs.db"})

# 导出清单：清单里的 res:// 是实际依赖，不是索引键。
MANIFEST_SPECS: tuple[tuple[str, str], ...] = (
    ("Script/data/export_raw_dependencies.json", "raw"),
    ("Script/data/level_preload_export_dependencies.json", "level_preload"),
    ("Art/frame_sequences/frame_sequence_export_dependencies.json", "frame_sequence"),
)

# 仅对这些 Catalog 的明确字典字段忽略“键”；同行的值仍必须检查。
CATALOG_MAPPING_FIELDS: dict[str, str] = {
    "Script/data/level_layout_catalog.tres": "layout_paths",
    "Script/data/level_preload_catalog.tres": "levels",
}

RES_PATH_RE = re.compile(r"res://[^\s\"'`]+", re.IGNORECASE)
UID_RE = re.compile(r"uid://[a-z0-9]+", re.IGNORECASE)
RELATIVE_ROOT_RE = re.compile(
    r"^(?:Art|Scene|Script|Music|Font|Spritesheet)/[^\s\"'`]*", re.IGNORECASE
)
PRESET_SECTION_RE = re.compile(r"^\[preset\.(\d+)(\.options)?\]$")


# ---------------------------------------------------------------------------
# 基础类型
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Issue:
    """一条可定位的问题。"""

    code: str
    message: str
    path: str | None = None
    line: int | None = None
    samples: tuple[str, ...] = ()

    def as_dict(self) -> dict[str, Any]:
        payload: dict[str, Any] = {"code": self.code, "message": self.message}
        if self.path is not None:
            payload["path"] = self.path
        if self.line is not None:
            payload["line"] = self.line
        if self.samples:
            payload["samples"] = list(self.samples)
        return payload


@dataclass(frozen=True)
class FilterPattern:
    """一个按 Godot ``String.matchn`` 语义匹配的排除模式。"""

    raw: str
    normalized: str
    regex: re.Pattern[str]
    prefix: str

    @classmethod
    def parse(cls, raw: str) -> "FilterPattern":
        normalized = normalize_filter_pattern(raw)
        escaped = re.escape(normalized)
        escaped = escaped.replace(r"\*", ".*").replace(r"\?", "[^.]")
        prefix = re.split(r"[*?]", normalized, maxsplit=1)[0].casefold()
        return cls(
            raw=raw.strip(),
            normalized=normalized,
            regex=re.compile(escaped, re.IGNORECASE),
            prefix=prefix,
        )

    def matches(self, path: str) -> bool:
        return self.matches_normalized(normalize_res_path(path))

    def matches_normalized(self, relative: str) -> bool:
        return self.regex.fullmatch(relative) is not None


@dataclass
class FileIndex:
    """一次遍历得到的 source 文件清单，避免重复 rglob。"""

    paths: list[str] = field(default_factory=list)
    lower: list[str] = field(default_factory=list)
    metadata: bytearray = field(default_factory=bytearray)

    def add(self, relative: str) -> None:
        is_metadata = _is_metadata_path(relative)
        self.paths.append(relative)
        self.lower.append(relative.casefold())
        self.metadata.append(1 if is_metadata else 0)

    def __len__(self) -> int:
        return len(self.paths)


@dataclass
class PolicyResult:
    patterns: list[str] = field(default_factory=list)
    preset_summaries: list[dict[str, Any]] = field(default_factory=list)
    failures: list[Issue] = field(default_factory=list)
    warnings: list[Issue] = field(default_factory=list)


@dataclass
class PatternResult:
    patterns: list[FilterPattern] = field(default_factory=list)
    failures: list[Issue] = field(default_factory=list)
    blocked: list[str] = field(default_factory=list)
    domain_states: list[dict[str, Any]] = field(default_factory=list)
    factory_dirs: list[str] = field(default_factory=list)
    factory_uncovered: list[str] = field(default_factory=list)
    collisions: dict[str, list[str]] = field(default_factory=dict)
    unused_patterns: list[str] = field(default_factory=list)
    excluded_indices: set[int] = field(default_factory=set)
    stats: dict[str, Any] = field(default_factory=dict)
    index: FileIndex = field(default_factory=FileIndex)


@dataclass
class ReferenceResult:
    failures: list[Issue] = field(default_factory=list)
    stats: dict[str, Any] = field(default_factory=dict)


# ---------------------------------------------------------------------------
# 路径与模式
# ---------------------------------------------------------------------------


def normalize_filter_pattern(raw: str) -> str:
    """去掉 res:// 前缀与首尾空白；Godot 匹配大小写不敏感。"""
    value = raw.strip().replace("\\", "/")
    if value[:6].casefold() == "res://":
        value = value[6:]
    return value.lstrip("/")


def normalize_res_path(path: str) -> str:
    value = path.strip().replace("\\", "/")
    if value[:6].casefold() == "res://":
        value = value[6:]
    return value.lstrip("/")


def _is_metadata_path(relative: str) -> bool:
    name = relative.rsplit("/", 1)[-1]
    if name in METADATA_NAMES:
        return True
    return any(relative.casefold().endswith(suffix) for suffix in METADATA_SUFFIXES)


def _is_private_path(relative: str) -> bool:
    return relative.split("/", 1)[0] in PRIVATE_ASSET_ROOTS


def _ancestor_matches(lower_path: str, directory_set: dict[str, str]) -> str | None:
    """返回路径最近的已登记祖先目录（不含文件自身）。"""
    parts = lower_path.split("/")
    for cut in range(len(parts) - 1, 0, -1):
        key = "/".join(parts[:cut])
        if key in directory_set:
            return directory_set[key]
    return None


# ---------------------------------------------------------------------------
# 预设解析
# ---------------------------------------------------------------------------


def _unescape_cfg_string(body: str) -> str:
    def replace(match: re.Match[str]) -> str:
        value = match.group(1)
        return {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\"}.get(value, value)

    return re.sub(r"\\(.)", replace, body)


def parse_cfg_string(raw: str) -> str:
    value = raw.strip()
    if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
        return _unescape_cfg_string(value[1:-1])
    return value


def split_filters(value: str) -> list[str]:
    return [item.strip() for item in value.split(",") if item.strip()]


def parse_export_presets(path: Path) -> list[dict[str, Any]]:
    """解析 export_presets.cfg 的 [preset.N] 段。"""
    text = path.read_text(encoding="utf-8-sig")
    presets: list[dict[str, Any]] = []
    current: dict[str, Any] | None = None
    in_options = False
    for line_number, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith(";") or stripped.startswith("#"):
            continue
        section = PRESET_SECTION_RE.fullmatch(stripped)
        if section:
            index = int(section.group(1))
            if section.group(2):
                if current is None or current["index"] != index:
                    raise ValueError(f"export_presets.cfg:{line_number}: options 段缺少对应 preset")
                in_options = True
            else:
                current = {"index": index, "fields": {}, "line": line_number}
                presets.append(current)
                in_options = False
            continue
        if current is None or in_options or "=" not in line:
            continue
        key, raw = line.split("=", 1)
        current["fields"][key.strip()] = raw.strip()
    if not presets:
        raise ValueError("export_presets.cfg 未包含任何 [preset.N]")
    result: list[dict[str, Any]] = []
    for preset in presets:
        fields = preset["fields"]
        name = parse_cfg_string(str(fields.get("name", "")))
        result.append(
            {
                "index": preset["index"],
                "line": preset["line"],
                "name": name or f"preset.{preset['index']}",
                "platform": parse_cfg_string(str(fields.get("platform", ""))),
                "export_filter": parse_cfg_string(str(fields.get("export_filter", ""))),
                "include_filter": parse_cfg_string(str(fields.get("include_filter", ""))),
                "exclude_filter": parse_cfg_string(str(fields.get("exclude_filter", ""))),
            }
        )
    return result


def _pattern_set(patterns: Sequence[str]) -> set[str]:
    return {normalize_filter_pattern(item).casefold() for item in patterns}


def select_policy(presets: list[dict[str, Any]]) -> PolicyResult:
    """选出所有 all_resources 预设，并校验排除策略一致、无 include 冲突。"""
    result = PolicyResult()
    all_resources = [preset for preset in presets if preset["export_filter"] == "all_resources"]
    for preset in presets:
        result.preset_summaries.append(
            {
                "index": preset["index"],
                "name": preset["name"],
                "platform": preset["platform"],
                "export_filter": preset["export_filter"],
                "exclude_count": len(split_filters(preset["exclude_filter"])),
                "include_count": len(split_filters(preset["include_filter"])),
            }
        )
    if len(all_resources) < 2:
        result.failures.append(
            Issue(
                "preset_missing_all_resources",
                f"需要至少两个 all_resources 预设，实际 {len(all_resources)} 个",
            )
        )
        return result
    if not all_resources[0]["exclude_filter"].strip():
        result.failures.append(Issue("exclude_filter_empty", "all_resources 预设的 exclude_filter 为空"))
        return result

    canonical = split_filters(all_resources[0]["exclude_filter"])
    canonical_set = _pattern_set(canonical)
    result.patterns = canonical
    for preset in all_resources[1:]:
        patterns = split_filters(preset["exclude_filter"])
        current_set = _pattern_set(patterns)
        if current_set == canonical_set:
            continue
        missing = sorted(canonical_set - current_set)
        extra = sorted(current_set - canonical_set)
        result.failures.append(
            Issue(
                "preset_policy_drift",
                f"预设 {preset['name']!r} 与 {all_resources[0]['name']!r} 的排除策略不一致",
                path="source/export_presets.cfg",
                line=preset["line"],
                samples=tuple(
                    [f"缺少: {item}" for item in missing[:5]]
                    + [f"多出: {item}" for item in extra[:5]]
                ),
            )
        )

    # 过滤冲突：include 中的具体路径若已被 exclude 命中，Godot 会静默排除它。
    compiled = [FilterPattern.parse(item) for item in canonical]
    for preset in all_resources:
        for include in split_filters(preset["include_filter"]):
            include_norm = normalize_filter_pattern(include)
            hit = any(pattern.matches_normalized(include_norm.casefold()) for pattern in compiled)
            if not hit:
                probe = include_norm.rstrip("/") + "/__exclusion_probe__"
                hit = any(pattern.matches(probe) for pattern in compiled)
            if hit:
                result.failures.append(
                    Issue(
                        "include_filter_conflict",
                        f"预设 {preset['name']!r} 的 include_filter 项被 exclude_filter 覆盖，"
                        "Godot 将以排除优先",
                        path="source/export_presets.cfg",
                        line=preset["line"],
                        samples=(include,),
                    )
                )
                continue
            # 两侧都是通配符时无法用具体路径判定；共享字面前缀只报警告，避免假 FAIL。
            include_pattern = FilterPattern.parse(include)
            if include_pattern.prefix and any(
                exclude.prefix
                and (
                    exclude.prefix.startswith(include_pattern.prefix)
                    or include_pattern.prefix.startswith(exclude.prefix)
                )
                for exclude in compiled
            ):
                result.warnings.append(
                    Issue(
                        "include_filter_possible_overlap",
                        f"预设 {preset['name']!r} 的 include_filter 项与 exclude_filter "
                        "共享字面前缀，可能发生包含/排除重叠",
                        path="source/export_presets.cfg",
                        line=preset["line"],
                        samples=(include,),
                    )
                )

    seen: dict[str, int] = {}
    for index, pattern in enumerate(canonical, 1):
        key = normalize_filter_pattern(pattern).casefold()
        if key in seen:
            result.warnings.append(
                Issue(
                    "duplicate_pattern",
                    f"排除模式重复：{pattern!r}（第 {seen[key]} 与第 {index} 项）",
                    path="source/export_presets.cfg",
                )
            )
        else:
            seen[key] = index
    return result


# ---------------------------------------------------------------------------
# source 索引与排除匹配
# ---------------------------------------------------------------------------


def build_file_index(source: Path) -> FileIndex:
    index = FileIndex()
    if not source.is_dir():
        return index
    for dirpath, dirnames, filenames in os.walk(source, followlinks=False):
        dirnames[:] = sorted(name for name in dirnames if name not in SCAN_SKIP_DIRS)
        rel_dir = os.path.relpath(dirpath, source).replace(os.sep, "/")
        if rel_dir == ".":
            rel_dir = ""
        for name in sorted(filenames):
            relative = name if not rel_dir else f"{rel_dir}/{name}"
            index.add(relative)
    return index


def discover_factory_dirs(source: Path) -> list[str]:
    """返回 Art 下所有 .dbfactory 所在目录（res 相对路径）。"""
    art = source / "Art"
    if not art.is_dir():
        return []
    dirs: set[str] = set()
    for dirpath, dirnames, filenames in os.walk(art, followlinks=False):
        dirnames[:] = sorted(name for name in dirnames if name not in SCAN_SKIP_DIRS)
        if not any(name.casefold().endswith(".dbfactory") for name in filenames):
            continue
        relative = os.path.relpath(dirpath, source).replace(os.sep, "/")
        if relative and relative != ".":
            dirs.add(relative)
    return sorted(dirs, key=str.casefold)


def match_pattern_indices(index: FileIndex, patterns: Sequence[FilterPattern]) -> list[list[int]]:
    """对每个模式返回命中的文件下标；用字面前缀先做廉价过滤。"""
    result: list[list[int]] = []
    for pattern in patterns:
        prefix = pattern.prefix
        hits: list[int] = []
        if prefix:
            for i, lower in enumerate(index.lower):
                if lower.startswith(prefix) and pattern.regex.fullmatch(lower):
                    hits.append(i)
        else:
            for i, lower in enumerate(index.lower):
                if pattern.regex.fullmatch(lower):
                    hits.append(i)
        result.append(hits)
    return result


def _sample(items: Sequence[str], limit: int = 12) -> tuple[str, ...]:
    return tuple(items[:limit])


def excluded_resource_paths(source: Path, patterns: list[str]) -> list[str]:
    """返回 source 内被排除模式命中的资源路径（res:// 形式）。

    - 模式匹配语义与 Godot 一致：去掉 ``res://`` 前缀、大小写不敏感、``*`` 跨目录；
    - 跳过 ``.import``、``.uid``、``.remap`` 等元数据，保证返回的是可导入资源
      （以及清单/插件确实会打包的原始文件）；
    - 不写入任何文件，不依赖 export_presets.cfg 之外的第二份配置；
    - 本函数只列候选路径；完整目录/工厂目录是否全部命中由 ``audit_patterns``
      与 ``--check`` 负责验证。
    """
    compiled = [FilterPattern.parse(item) for item in patterns if item.strip()]
    source = Path(source)
    if not compiled or not source.is_dir():
        return []
    index = build_file_index(source)
    matched: set[int] = set()
    for hits in match_pattern_indices(index, compiled):
        matched.update(hits)
    return sorted(
        (f"res://{index.paths[i]}" for i in matched if not index.metadata[i]),
        key=str.casefold,
    )


# ---------------------------------------------------------------------------
# 策略/覆盖校验
# ---------------------------------------------------------------------------


def audit_patterns(
    source: Path,
    raw_patterns: Sequence[str],
    required_dirs: Sequence[str] = REQUIRED_EXCLUSION_DIRS,
    *,
    check_factories: bool = True,
) -> PatternResult:
    """校验完整目录、工厂目录覆盖，以及压缩 glob 的误伤。"""
    result = PatternResult()
    result.patterns = [FilterPattern.parse(item) for item in raw_patterns if item.strip()]
    index = build_file_index(source)
    matches = match_pattern_indices(index, result.patterns)
    covered = bytearray(len(index))
    for hits in matches:
        for i in hits:
            covered[i] = 1

    # 目录归属：先算用户完整目录，再算工厂目录。
    required_prefixes = [(d.casefold() + "/", d) for d in required_dirs]
    required_owner: list[str | None] = [None] * len(index)
    for i, lower in enumerate(index.lower):
        for prefix, directory in required_prefixes:
            if lower.startswith(prefix):
                required_owner[i] = directory
                break

    factory_dirs: list[str] = discover_factory_dirs(source) if check_factories else []
    factory_lower = {directory.casefold(): directory for directory in factory_dirs}
    factory_owner: list[str | None] = [None] * len(index)
    if factory_lower:
        for i, lower in enumerate(index.lower):
            owner = _ancestor_matches(lower, factory_lower)
            if owner is not None:
                factory_owner[i] = owner
    result.factory_dirs = factory_dirs
    # Art 根存在但没有任何 .dbfactory 时，无法判断动态规则是否仍有效；按 BLOCKED 处理，
    # 不能把“私有素材未检出”误判成每条规则都拼错。
    factories_unverifiable = bool(check_factories and (source / "Art").is_dir() and not factory_dirs)
    missing_pattern_roots: set[str] = set()

    # 每个模式：空命中、误伤、是否命中工厂。
    excluded_indices: set[int] = set()
    for pattern, hits in zip(result.patterns, matches):
        real_hits = [i for i in hits if not index.metadata[i]]
        if not real_hits:
            probe_hit = any(
                pattern.matches(directory + "/__exclusion_probe__") for directory in required_dirs
            )
            root_missing = _pattern_root_missing(source, pattern)
            if probe_hit:
                # 该模式负责一个完整目录；目录缺失/为空时由域状态给出 BLOCKED/FAIL。
                continue
            if root_missing or factories_unverifiable:
                first = pattern.prefix.split("/", 1)[0] or pattern.raw
                if first not in missing_pattern_roots:
                    missing_pattern_roots.add(first)
                    result.blocked.append(
                        f"排除模式目标根 {first!r} 不存在或未检出素材，无法判断 "
                        f"{pattern.raw!r} 是否仍有效：公开 clone 或私有素材未检出"
                    )
                continue
            result.unused_patterns.append(pattern.raw)
            result.failures.append(
                Issue(
                    "pattern_unused",
                    f"排除模式 {pattern.raw!r} 没有命中任何资源（疑似拼写错误或来自已删除素材）",
                    path="source/export_presets.cfg",
                    samples=(pattern.raw,),
                )
            )
            continue

        collisions: list[str] = []
        factory_hits = 0
        required_only_hits = 0
        required_only_samples: list[str] = []
        for i in real_hits:
            factory_owner_path = factory_owner[i]
            required_owner_path = required_owner[i]
            if factory_owner_path is not None:
                factory_hits += 1
                continue
            if required_owner_path is not None:
                required_only_hits += 1
                required_only_samples.append(index.paths[i])
                continue
            collisions.append(index.paths[i])
        # 带工厂命中的模式是动态压缩 glob：它连用户指定目录里的非工厂文件
        # 也不得命中，否则未来新增同类文件会被静默排除。
        if factory_hits > 0:
            collisions.extend(required_only_samples)
        if collisions:
            collision_samples = _sample(sorted(collisions, key=str.casefold))
            result.collisions[pattern.raw] = list(collision_samples)
            result.failures.append(
                Issue(
                    "glob_collision",
                    f"排除模式 {pattern.raw!r} 命中了 {len(collisions)} 个非工厂文件"
                    "（含用户指定目录内文件）；压缩 glob 必须只命中 DragonBones 工厂目录",
                    path="source/export_presets.cfg",
                    samples=collision_samples,
                )
            )
        if check_factories and factory_dirs and factory_hits == 0:
            # 完整目录模式允许只命中 required；其余模式必须服务至少一个工厂目录。
            if required_only_hits == 0:
                result.failures.append(
                    Issue(
                        "pattern_not_factory",
                        f"排除模式 {pattern.raw!r} 未命中任何 .dbfactory 工厂目录，"
                        "也不是用户指定完整目录的排除模式",
                        path="source/export_presets.cfg",
                        samples=(pattern.raw,),
                    )
                )

        for i in real_hits:
            excluded_indices.add(i)

    # 完整目录：模式必须存在，素材存在时必须逐文件覆盖。
    for directory in required_dirs:
        full = source / directory
        exists = full.is_dir()
        files = [
            i
            for i, owner in enumerate(required_owner)
            if owner == directory and not index.metadata[i]
        ]
        probe = directory + "/__exclusion_probe__"
        pattern_present = any(pattern.matches(probe) for pattern in result.patterns)
        uncovered = [index.paths[i] for i in files if not covered[i]]
        state = {
            "dir": directory,
            "exists": exists,
            "files": len(files),
            "pattern_present": pattern_present,
            "covered": not uncovered and bool(files),
            "uncovered": list(_sample(sorted(uncovered, key=str.casefold))),
        }
        result.domain_states.append(state)
        if not pattern_present:
            result.failures.append(
                Issue(
                    "required_domain_pattern_missing",
                    f"用户指定目录 {directory!r} 没有任何排除模式覆盖（期望类似 "
                    f"{directory}/*）",
                    path="source/export_presets.cfg",
                )
            )
        if not exists:
            if _is_private_path(directory):
                result.blocked.append(
                    f"私有素材目录缺失：{directory}；公开 clone 无法证明该域排除完整"
                )
            else:
                result.failures.append(
                    Issue(
                        "required_dir_missing",
                        f"用户指定目录不存在：{directory}",
                        path=directory,
                    )
                )
            continue
        if not files:
            if _is_private_path(directory):
                result.blocked.append(
                    f"私有素材目录为空：{directory}；无法证明该域排除完整（可能未检出私有素材）"
                )
            else:
                result.failures.append(
                    Issue("required_dir_empty", f"用户指定目录为空：{directory}", path=directory)
                )
            continue
        if uncovered:
            result.failures.append(
                Issue(
                    "required_dir_uncovered",
                    f"用户指定目录 {directory!r} 有 {len(uncovered)} 个文件未被排除",
                    path=directory,
                    samples=_sample(sorted(uncovered, key=str.casefold)),
                )
            )

    # 工厂目录：动态规则来自当前 .dbfactory 集合；新增工厂未被覆盖即失败。
    if check_factories:
        art = source / "Art"
        if not art.is_dir():
            result.blocked.append(
                "Art 私有素材根缺失；无法枚举 .dbfactory，不能证明动态工厂排除规则完整"
            )
        elif not factory_dirs:
            result.blocked.append(
                "未发现任何 .dbfactory；无法证明动态工厂排除规则完整（可能未检出私有素材）"
            )
        else:
            for directory in factory_dirs:
                files = [
                    i
                    for i, owner in enumerate(factory_owner)
                    if owner == directory and not index.metadata[i]
                ]
                uncovered = [index.paths[i] for i in files if not covered[i]]
                if uncovered:
                    result.factory_uncovered.append(directory)
                    result.failures.append(
                        Issue(
                            "factory_dir_uncovered",
                            f"DragonBones 工厂目录 {directory!r} 有 {len(uncovered)} 个文件"
                            "未被排除模式覆盖",
                            path=directory,
                            samples=_sample(sorted(uncovered, key=str.casefold)),
                        )
                    )

    result.excluded_indices = excluded_indices
    result.index = index
    result.stats = {
        "source_files": len(index),
        "resource_files": sum(1 for flag in index.metadata if not flag),
        "metadata_files": sum(index.metadata),
        "patterns": len(result.patterns),
        "required_dirs": len(required_dirs),
        "factory_dirs": len(factory_dirs),
        "factory_dirs_uncovered": len(result.factory_uncovered),
        "colliding_patterns": len(result.collisions),
        "unused_patterns": len(result.unused_patterns),
        "excluded_resources": sum(1 for i in excluded_indices if not index.metadata[i]),
    }
    return result


def _top_level_names(source: Path) -> set[str]:
    try:
        return {name.casefold() for name in os.listdir(source)}
    except OSError:
        return set()


def _pattern_root_missing(source: Path, pattern: FilterPattern) -> bool:
    """模式字面前缀的顶层目录是否缺失（公开 clone 常见）。"""
    prefix = pattern.prefix.rstrip("/")
    if not prefix:
        return False
    first = prefix.split("/", 1)[0]
    if not first:
        return False
    # prefix 已 casefold；source 顶层名也 casefold，避免 Linux 大小写误判。
    return first not in _top_level_names(source)


# ---------------------------------------------------------------------------
# 文本扫描
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class StringSpan:
    start: int
    end: int
    content: str


def _mask_comments_and_collect_strings(
    text: str, style: str
) -> tuple[str, list[StringSpan]]:
    """把注释替换为空格，同时收集字符串字面量；保留原始下标。"""
    chars = list(text)
    spans: list[StringSpan] = []
    i = 0
    length = len(text)
    while i < length:
        char = text[i]
        if char in ('"', "'"):
            quote = char
            triple = text.startswith(quote * 3, i)
            delimiter = quote * 3 if triple else quote
            content_start = i + len(delimiter)
            j = content_start
            closed = False
            while j < length:
                if text[j] == "\\":
                    j += 2
                    continue
                if text.startswith(delimiter, j):
                    spans.append(StringSpan(i, j + len(delimiter), text[content_start:j]))
                    j += len(delimiter)
                    closed = True
                    break
                j += 1
            i = j if closed else length
            continue
        if style == "gd" and char == "#":
            while i < length and text[i] != "\n":
                chars[i] = " "
                i += 1
            continue
        if style in ("cfg", "tscn", "tres") and char == ";":
            while i < length and text[i] != "\n":
                chars[i] = " "
                i += 1
            continue
        if style == "gdshader" and char == "/" and i + 1 < length:
            if text[i + 1] == "/" and (i == 0 or text[i - 1] != ":"):
                while i < length and text[i] != "\n":
                    chars[i] = " "
                    i += 1
                continue
            if text[i + 1] == "*":
                chars[i] = " "
                chars[i + 1] = " "
                i += 2
                while i + 1 < length and not (text[i] == "*" and text[i + 1] == "/"):
                    if text[i] != "\n":
                        chars[i] = " "
                    i += 1
                if i + 1 < length:
                    chars[i] = " "
                    chars[i + 1] = " "
                    i += 2
                continue
        i += 1
    return "".join(chars), spans


def _mask_catalog_mapping_keys(text: str, field_name: str) -> tuple[str, int]:
    """只屏蔽 Catalog 字典的键字面量；同一行的值保持可扫描。"""
    lines = text.splitlines(keepends=True)
    output: list[str] = []
    in_block = False
    depth = 0
    ignored = 0
    open_re = re.compile(rf"\b{re.escape(field_name)}\s*=\s*\{{")
    key_re = re.compile(r'^(\s*&?)"((?:(?:res|uid)://)[^"]+)"(\s*:)', re.IGNORECASE)
    for line in lines:
        if not in_block:
            if open_re.search(line):
                in_block = True
                depth = line.count("{") - line.count("}")
                if depth <= 0:
                    in_block = False
            output.append(line)
            continue
        depth += line.count("{") - line.count("}")
        match = key_re.match(line)
        if match:
            start, end = match.start(2), match.end(2)
            line = line[:start] + (" " * (end - start)) + line[end:]
            ignored += 1
        if depth <= 0:
            in_block = False
        output.append(line)
    return "".join(output), ignored


def _line_number(text: str, offset: int, newlines: list[int]) -> int:
    return bisect.bisect_right(newlines, offset) + 1


def _trailing_concat(text: str, end: int) -> bool:
    rest = text[end : end + 16].lstrip()
    return rest.startswith("+")


def _leading_concat(text: str, start: int) -> bool:
    """字符串字面量前面是否是拼接运算符（如 "res://" + "Art/ui/x"）。"""
    return text[:start].rstrip().endswith("+")


def _reference_kind(
    source: Path,
    literal: str,
    patterns: Sequence[FilterPattern],
    *,
    concatenated: bool,
) -> str | None:
    relative = normalize_res_path(literal).strip()
    if not relative:
        return None
    if any(pattern.matches_normalized(relative.casefold()) for pattern in patterns):
        return "file"
    is_directory = False
    try:
        is_directory = (source / relative).is_dir()
    except OSError:
        is_directory = False
    if is_directory or relative.endswith("/") or concatenated:
        probe = relative.rstrip("/") + "/__exclusion_probe__"
        if any(pattern.matches(probe) for pattern in patterns):
            return "directory"
    return None


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig", errors="replace")


def _build_uid_index(source: Path, index: FileIndex) -> tuple[dict[str, str | None], set[str]]:
    """用 .uid 边车与场景/资源头建立 UID → res 路径索引。"""
    mapping: dict[str, str | None] = {}
    duplicates: set[str] = set()

    def add(uid: str, target: str) -> None:
        key = uid.casefold()
        if key in mapping:
            if mapping[key] != target:
                duplicates.add(uid)
                mapping[key] = None
            return
        mapping[key] = target

    for relative in index.paths:
        if not relative.casefold().endswith(".uid"):
            continue
        full = source / relative
        try:
            uid = _read_text(full).strip()
        except OSError:
            continue
        if uid.casefold().startswith("uid://"):
            add(uid, relative[: -len(".uid")])

    # 导入纹理的 UID 只写在 .import 里；不建索引会把正常纹理引用误报为未解析。
    import_uid_re = re.compile(r'uid="(uid://[^"]+)"', re.IGNORECASE)
    for relative in index.paths:
        if not relative.casefold().endswith(".import"):
            continue
        full = source / relative
        try:
            with full.open("r", encoding="utf-8-sig", errors="replace") as handle:
                head = handle.read(2048)
        except OSError:
            continue
        match = import_uid_re.search(head)
        if match:
            add(match.group(1), relative[: -len(".import")])

    header_re = re.compile(
        r"^\s*\[(?:gd_scene|gd_resource)\b[^\]]*\buid=\"(uid://[^\"]+)\"", re.IGNORECASE
    )
    for relative in index.paths:
        if not relative.casefold().endswith((".tscn", ".tres")):
            continue
        full = source / relative
        try:
            with full.open("r", encoding="utf-8-sig", errors="replace") as handle:
                head = handle.read(4096)
        except OSError:
            continue
        match = header_re.search(head)
        if match:
            add(match.group(1), relative)
    return mapping, duplicates


def _iter_manifest_paths(node: Any, key_path: str) -> Iterator[tuple[str, str]]:
    if isinstance(node, str):
        if node.casefold().startswith("res://"):
            yield key_path, node
        return
    if isinstance(node, dict):
        for key, value in node.items():
            yield from _iter_manifest_paths(value, f"{key_path}.{key}" if key_path else str(key))
        return
    if isinstance(node, list):
        for index, value in enumerate(node):
            yield from _iter_manifest_paths(value, f"{key_path}[{index}]")


def audit_references(
    source: Path,
    index: FileIndex,
    patterns: Sequence[FilterPattern],
    *,
    check_manifests: bool = True,
) -> ReferenceResult:
    """扫描未被排除的生产文本与清单里的显式 res:// / uid:// 引用。"""
    result = ReferenceResult()
    stats: dict[str, Any] = {
        "scanned_files": 0,
        "skipped_excluded_files": 0,
        "res_literals": 0,
        "uid_literals": 0,
        "relative_literals": 0,
        "unresolved_res_literals": 0,
        "format_res_literals": 0,
        "stale_res_literals": 0,
        "unresolved_uids": 0,
        "ambiguous_uids": 0,
        "opaque_dynamic": 0,
        "ignored_catalog_keys": 0,
        "manifest_paths": 0,
        "manifest_failures": 0,
        "uid_index_entries": 0,
    }
    uid_map, duplicate_uids = _build_uid_index(source, index)
    stats["uid_index_entries"] = sum(1 for target in uid_map.values() if target is not None)
    stats["duplicate_uids"] = len(duplicate_uids)

    seen_violations: set[tuple[str, str, str]] = set()

    def add_violation(code: str, message: str, relative: str, line: int, literal: str) -> None:
        key = (code, relative, literal.casefold())
        if key in seen_violations:
            return
        seen_violations.add(key)
        result.failures.append(
            Issue(code, message, path=relative, line=line, samples=(literal,))
        )

    # 生产文本扫描；排除 addons、被排除文件本身和元数据。
    for i, relative in enumerate(index.paths):
        if index.metadata[i]:
            continue
        if relative.startswith("addons/"):
            continue
        if relative not in PRODUCTION_ROOT_FILES and not relative.casefold().endswith(
            PRODUCTION_SUFFIXES
        ):
            continue
        if any(pattern.matches(relative) for pattern in patterns):
            stats["skipped_excluded_files"] += 1
            continue
        full = source / relative
        try:
            text = _read_text(full)
        except OSError:
            continue
        stats["scanned_files"] += 1

        if relative.casefold().endswith(".gd"):
            style = "gd"
        elif relative.casefold().endswith(".gdshader"):
            style = "gdshader"
        elif relative.casefold().endswith((".tscn", ".tres")):
            style = "tscn" if relative.casefold().endswith(".tscn") else "tres"
        else:
            style = "cfg"

        if relative in CATALOG_MAPPING_FIELDS:
            text, ignored = _mask_catalog_mapping_keys(text, CATALOG_MAPPING_FIELDS[relative])
            stats["ignored_catalog_keys"] += ignored

        _, spans = _mask_comments_and_collect_strings(text, style)
        newlines = [offset for offset, char in enumerate(text) if char == "\n"]
        for span in spans:
            line = _line_number(text, span.start, newlines)
            concatenated = _trailing_concat(text, span.end) or _leading_concat(text, span.start)
            content = span.content

            # 完整 res:// 路径（含字符串拼接的目录前缀）。
            for match in RES_PATH_RE.finditer(content):
                literal = match.group(0).strip()
                if not literal:
                    continue
                stats["res_literals"] += 1
                exists = False
                try:
                    exists = (source / normalize_res_path(literal)).exists()
                except OSError:
                    exists = False
                if not exists:
                    literal = literal.rstrip(".,;:!?)]}")
                kind = _reference_kind(
                    source, literal, patterns, concatenated=concatenated
                )
                if kind is not None:
                    add_violation(
                        "excluded_reference",
                        f"生产资源 {relative!r} 引用了被排除的{'目录' if kind == 'directory' else '资源'}"
                        f"：{literal}",
                        relative,
                        line,
                        literal,
                    )
                elif not exists:
                    stats["unresolved_res_literals"] += 1
                    if "%" in literal or "{" in literal:
                        stats["format_res_literals"] += 1
                    else:
                        stats["stale_res_literals"] += 1
                if concatenated:
                    stats["opaque_dynamic"] += 1

            # 只有 "res://" 或 "res://Art/" 之类无法确定的拼接前缀：显式记为不可验证。
            if content.strip().casefold() == "res://" and concatenated:
                stats["opaque_dynamic"] += 1

            # GDScript 中常见的 "Art/ui/" + name 相对路径拼接。
            relative_match = RELATIVE_ROOT_RE.match(content.strip())
            if relative_match and concatenated:
                literal = relative_match.group(0)
                stats["relative_literals"] += 1
                kind = _reference_kind(source, literal, patterns, concatenated=True)
                if kind is not None:
                    add_violation(
                        "excluded_relative_reference",
                        f"生产资源 {relative!r} 用相对路径拼接引用了被排除目录：{literal}",
                        relative,
                        line,
                        literal,
                    )

            # UID 引用：能解析到被排除资源时失败；无法解析时只计数，不虚报。
            for match in UID_RE.finditer(content):
                uid = match.group(0).rstrip(".,;:")
                stats["uid_literals"] += 1
                key = uid.casefold()
                if key not in uid_map:
                    stats["unresolved_uids"] += 1
                    continue
                target = uid_map[key]
                if target is None:
                    stats["ambiguous_uids"] += 1
                    continue
                if any(
                    pattern.matches_normalized(target.casefold()) for pattern in patterns
                ) or any(
                    pattern.matches(target.rstrip("/") + "/__exclusion_probe__")
                    for pattern in patterns
                ):
                    add_violation(
                        "excluded_uid_reference",
                        f"生产资源 {relative!r} 通过 UID 引用了被排除资源：{uid} → {target}",
                        relative,
                        line,
                        uid,
                    )

    # 导出清单：路径值是实际依赖，不能当作索引键忽略。
    if check_manifests:
        for relative, kind_name in MANIFEST_SPECS:
            full = source / relative
            if not full.is_file():
                if _is_private_path(relative):
                    result.stats.setdefault("blocked", []).append(
                        f"私有素材清单缺失：{relative}；无法验证该清单不含被排除路径"
                    )
                else:
                    result.failures.append(
                        Issue(
                            "manifest_missing",
                            f"导出依赖清单缺失：{relative}",
                            path=relative,
                        )
                    )
                continue
            try:
                payload = json.loads(_read_text(full))
            except (OSError, ValueError, json.JSONDecodeError) as error:
                result.failures.append(
                    Issue(
                        "manifest_invalid",
                        f"导出依赖清单无法解析：{relative} ({error})",
                        path=relative,
                    )
                )
                continue
            count = 0
            for key_path, literal in _iter_manifest_paths(payload, ""):
                count += 1
                kind = _reference_kind(source, literal, patterns, concatenated=False)
                if kind is not None:
                    stats["manifest_failures"] += 1
                    add_violation(
                        "manifest_reference_violation",
                        f"{kind_name} 清单 {relative} 的 {key_path} 仍依赖被排除资源：{literal}",
                        relative,
                        0,
                        literal,
                    )
            stats["manifest_paths"] += count

    result.stats = stats
    return result


# ---------------------------------------------------------------------------
# 汇总与 CLI
# ---------------------------------------------------------------------------


def _issue_list(issues: Sequence[Issue]) -> list[dict[str, Any]]:
    return [issue.as_dict() for issue in issues]


def _scope_notes() -> dict[str, Any]:
    return {
        "checked": [
            "source 内未被排除的 *.gd/*.tscn/*.tres/*.gdshader 与 project.godot",
            "FrameSequence、关卡预载、原始数据导出依赖清单中的 res:// 路径",
            "显式 res:// 字面量、可由 .uid 边车/资源头解析的 uid://",
            "用户指定完整目录与所有 .dbfactory 工厂目录的排除覆盖",
        ],
        "not_covered": [
            "运行期由数据表、服务器或用户输入拼出的路径",
            "文本中不存在、无法由 .uid 边车或资源头解析的 UID",
            "非文本资源内部可能保存的引用",
            "真实 PCK 导出结果（本工具不做导出，只做源树静态审计）",
        ],
        "limitations": [
            "路径字符串拼接只能验证字面前缀；无法证明 'res://Art/' + 变量 的最终值",
            "含未转义空格的 res:// 字面量会被截断，报告计入 unresolved_res_literals",
            "Catalog 仅忽略明确的字典键；同一行的值仍会检查",
            ".import/.uid/.remap 等元数据不参与导出碰撞判断，也不会出现在候选资源列表",
        ],
    }


def run_check(
    source: Path,
    presets_path: Path,
    required_dirs: Sequence[str] = REQUIRED_EXCLUSION_DIRS,
    *,
    check_factories: bool = True,
    check_manifests: bool = True,
) -> dict[str, Any]:
    """执行完整只读校验并返回 JSON 可序列化报告。"""
    source = Path(source)
    presets_path = Path(presets_path)
    failures: list[Issue] = []
    warnings: list[Issue] = []
    blocked: list[str] = []

    if not source.is_dir():
        return {
            "ok": False,
            "status": "FAIL",
            "source": str(source),
            "failures": [
                Issue("source_missing", f"source 目录不存在：{source}").as_dict()
            ],
            "warnings": [],
            "blocked": [],
            "excluded_resources": [],
            "excluded_count": 0,
            "policy": {},
            "references": {},
            "scope": _scope_notes(),
        }

    try:
        presets = parse_export_presets(presets_path)
    except (OSError, ValueError) as error:
        return {
            "ok": False,
            "status": "FAIL",
            "source": str(source),
            "presets_path": str(presets_path),
            "failures": [Issue("presets_unreadable", str(error)).as_dict()],
            "warnings": [],
            "blocked": [],
            "excluded_resources": [],
            "excluded_count": 0,
            "policy": {},
            "references": {},
            "scope": _scope_notes(),
        }

    policy = select_policy(presets)
    failures.extend(policy.failures)
    warnings.extend(policy.warnings)

    pattern_result = audit_patterns(
        source, policy.patterns, required_dirs, check_factories=check_factories
    )
    failures.extend(pattern_result.failures)
    blocked.extend(pattern_result.blocked)

    index = pattern_result.index
    reference_result = audit_references(
        source, index, pattern_result.patterns, check_manifests=check_manifests
    )
    failures.extend(reference_result.failures)
    blocked.extend(reference_result.stats.pop("blocked", []))
    # 同一缺失根会触发多个动态模式；报告里只保留一条，避免公开 clone 刷屏。
    blocked = list(dict.fromkeys(blocked))

    excluded = sorted(
        (
            f"res://{index.paths[i]}"
            for i in pattern_result.excluded_indices
            if not index.metadata[i]
        ),
        key=str.casefold,
    )

    status = "FAIL" if failures else ("BLOCKED" if blocked else "PASS")
    return {
        "ok": status == "PASS",
        "status": status,
        "source": str(source),
        "presets_path": str(presets_path),
        "presets": policy.preset_summaries,
        "all_resources_presets": sum(
            1 for preset in policy.preset_summaries if preset["export_filter"] == "all_resources"
        ),
        "failures": _issue_list(failures),
        "warnings": _issue_list(warnings),
        "blocked": blocked,
        "excluded_resources": excluded,
        "excluded_count": len(excluded),
        "policy": {
            "exclude_patterns": list(policy.patterns),
            "required_dirs": pattern_result.domain_states,
            "factory_dirs": len(pattern_result.factory_dirs),
            "factory_dirs_uncovered": list(pattern_result.factory_uncovered),
            "collisions": pattern_result.collisions,
            "unused_patterns": list(pattern_result.unused_patterns),
            "stats": pattern_result.stats,
        },
        "references": reference_result.stats,
        "scope": _scope_notes(),
    }


def _print_human(report: dict[str, Any], verbose: bool = False) -> None:
    status = report["status"]
    prefix = {"PASS": "[OK]", "FAIL": "[FAIL]", "BLOCKED": "[BLOCKED]"}.get(status, "[?]")
    if status == "PASS":
        print(
            f"{prefix} 资源排除策略通过："
            f"{report.get('all_resources_presets', len(report.get('presets', [])))} 个 "
            "all_resources 预设一致，"
            f"{report['policy']['stats'].get('required_dirs', 0)} 个域、"
            f"{report['policy']['stats'].get('factory_dirs', 0)} 个工厂目录已覆盖；"
            f"排除 {report.get('excluded_count', 0)} 个资源，"
            f"扫描 {report.get('references', {}).get('scanned_files', 0)} 个生产文本文件。"
        )
    else:
        print(
            f"{prefix} 资源排除策略未通过：{len(report.get('failures', []))} 个失败，"
            f"{len(report.get('blocked', []))} 个无法验证项。"
        )
    for failure in report.get("failures", []):
        location = ""
        if failure.get("path"):
            location = f" [{failure['path']}"
            if failure.get("line"):
                location += f":{failure['line']}"
            location += "]"
        print(f"- {failure['code']}: {failure['message']}{location}")
        for sample in failure.get("samples", [])[:5]:
            print(f"    例：{sample}")
    for note in report.get("blocked", []):
        print(f"- 无法验证：{note}")
    refs = report.get("references", {})
    if refs:
        print(
            "参考范围："
            f"res 字面量 {refs.get('res_literals', 0)}，"
            f"UID 字面量 {refs.get('uid_literals', 0)}，"
            f"未解析 res {refs.get('unresolved_res_literals', 0)}"
            f"（格式模板 {refs.get('format_res_literals', 0)}），"
            f"未解析 UID {refs.get('unresolved_uids', 0)}，"
            f"模糊 UID {refs.get('ambiguous_uids', 0)}，"
            f"不可判定拼接 {refs.get('opaque_dynamic', 0)}，"
            f"清单路径 {refs.get('manifest_paths', 0)}。"
        )
        print("限制：只证明字面量引用；动态拼接、未知 UID 与真实 PCK 不在证明范围。")
    if verbose and report.get("warnings"):
        for warning in report["warnings"]:
            print(f"- 警告 {warning['code']}: {warning['message']}")


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="BHYH 发布包资源排除只读审计")
    parser.add_argument("--check", action="store_true", help="只读校验排除策略（默认动作）")
    parser.add_argument(
        "--json",
        action="store_true",
        help="输出 JSON 报告；包含 excluded_resources（被排除资源的 res:// 路径）",
    )
    parser.add_argument(
        "--print-excluded",
        action="store_true",
        help="只打印被排除资源的 res:// 路径，每行一条",
    )
    parser.add_argument(
        "--source", type=Path, default=DEFAULT_SOURCE, help="Godot 工程目录（默认 source/）"
    )
    parser.add_argument(
        "--presets", type=Path, default=None, help="export_presets.cfg 路径（默认 <source>/export_presets.cfg）"
    )
    parser.add_argument("--verbose", action="store_true", help="输出警告明细")
    args = parser.parse_args(argv)

    source = args.source
    presets_path = args.presets or (source / "export_presets.cfg")

    if args.print_excluded:
        try:
            presets = parse_export_presets(presets_path)
        except (OSError, ValueError) as error:
            print(f"[FAIL] {error}", file=sys.stderr)
            return 1
        policy = select_policy(presets)
        if policy.failures:
            for failure in policy.failures:
                print(f"[FAIL] {failure.message}", file=sys.stderr)
            return 1
        if not source.is_dir():
            print(f"[BLOCKED] source 目录不存在：{source}", file=sys.stderr)
            return 2
        try:
            for path in excluded_resource_paths(source, policy.patterns):
                print(path)
        except (BrokenPipeError, OSError) as error:
            # 管道被 head 等提前关闭时不要输出 traceback（Windows 报 Errno 22）。
            if isinstance(error, BrokenPipeError) or getattr(error, "errno", None) == 22:
                return 0
            raise
        return 0

    # --json 与 --check 都执行同一套只读校验；无参数时默认 --check。
    report = run_check(source, presets_path)
    try:
        if args.json:
            print(json.dumps(report, ensure_ascii=False, indent=2))
        else:
            _print_human(report, verbose=args.verbose)
    except (BrokenPipeError, OSError) as error:
        if isinstance(error, BrokenPipeError) or getattr(error, "errno", None) == 22:
            return 0
        raise
    return {"PASS": 0, "FAIL": 1, "BLOCKED": 2}.get(report["status"], 1)


if __name__ == "__main__":
    sys.exit(main())

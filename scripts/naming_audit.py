#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ZMXYBHYH 目录与资产命名审计门禁 (Naming Audit Gate)
====================================================
对照《全工程命名规范与契约白皮书》执行两类检查：

1. 全量目录命名：工程目录必须为 snake_case；机器导出结构与动态拼接
   数字 ID 目录按 `docs/naming_whitelist.md` 冻结豁免；
2. 文件命名：默认检查 Git 新增文件（暂存 + 未跟踪）；`--all`
   检查全量 tracked/untracked 文件。所有文件按 Godot 官方规则使用
   snake_case（类脚本文件名不要求与 class_name 同为大驼峰）；
3. 脚本落位：`source/Scene/` 下不得存在 `.gd`；脚本必须归
   `source/Script/<domain>/`（ADR-031，Phase 29-4 起强制）。

退出码：0 = 全部合规；1 = 存在违规。
"""

import os
import re
import json
import subprocess
import sys
import argparse
from pathlib import Path

PROJECT_ROOT = "source"

SNAKE_RE = re.compile(r"^[a-z0-9]+(_[a-z0-9]+)*$")

# 机器导出结构/纯数字目录/第三方插件均必须来自冻结登记表，
# 不再按正则或前缀自动放行；新增未登记条目由本门禁拦截。
WHITELIST_PATH = Path(__file__).resolve().parent / "contract_whitelist.json"
MACHINE_DIRS: set[str] = set()
NUMERIC_DIRS: set[str] = set()
NUMERIC_SCENE_FILES: set[str] = set()
THIRD_PARTY_PREFIXES: tuple[str, ...] = ("addons/", "source/addons/", "godot/", ".godot/")
COMPANION_SUFFIXES: tuple[str, ...] = (".import", ".uid", ".atlas", ".spine-json", ".translation")


def load_registry(path: Path = WHITELIST_PATH) -> dict:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return data


def apply_registry(data: dict) -> None:
    global MACHINE_DIRS, NUMERIC_DIRS, NUMERIC_SCENE_FILES, THIRD_PARTY_PREFIXES, COMPANION_SUFFIXES
    naming = data.get("naming", {})
    MACHINE_DIRS = set(naming.get("machine_export_directories", []))
    NUMERIC_DIRS = set(naming.get("numeric_directories", []))
    NUMERIC_SCENE_FILES = set(naming.get("numeric_scene_files", []))
    # `addons/` 是第三方插件目录，按 naming_standard 的机器导出白名单整体豁免，
    # 不为每个插件单独登记（白名单只减不增）。
    THIRD_PARTY_PREFIXES = (
        ("addons/", "source/addons/")
        + tuple(naming.get("third_party_prefixes", []))
        + ("godot/", ".godot/")
    )
    COMPANION_SUFFIXES = tuple(naming.get("companion_tool_suffixes", COMPANION_SUFFIXES))


apply_registry(load_registry())

# 工具链伴生文件：不参与业务文件命名检查
SPINE_RE = re.compile(r"\.(?:atlas|spine-json)$")
META_RE = re.compile(r"\.(?:import|uid)$")

# 允许 snake_case 的资产扩展名
SNAKE_ASSET_EXT = {
    ".tres", ".res", ".gdshader", ".mp3", ".ogg", ".wav",
    ".png", ".webp", ".jpg", ".jpeg", ".ttf", ".otf", ".json",
}


def rel_to_project(path: str) -> str:
    return path.replace(os.sep, "/")


def is_dir_whitelisted(rel: str) -> bool:
    """目录豁免必须精确命中冻结登记表，禁止按通配模式自动放行。"""
    if any(rel == p.rstrip("/") or rel.startswith(p) for p in THIRD_PARTY_PREFIXES):
        return True
    return rel in MACHINE_DIRS or rel in NUMERIC_DIRS


def is_file_whitelisted(rel: str) -> bool:
    """文件豁免：登记的数字场景、机器导出目录子文件、伴生/工具产物。"""
    if any(rel.startswith(prefix) for prefix in THIRD_PARTY_PREFIXES):
        return True
    if rel in NUMERIC_SCENE_FILES:
        return True
    if any(rel.endswith(suffix) for suffix in COMPANION_SUFFIXES):
        return True
    parent = os.path.dirname(rel)
    while parent:
        if parent in MACHINE_DIRS or parent in NUMERIC_DIRS:
            return True
        parent = os.path.dirname(parent)
    return False


def _check_directory_name(rel: str, name: str, violations: list[str]) -> None:
    if is_dir_whitelisted(rel):
        return
    if not SNAKE_RE.match(name):
        violations.append(f"目录命名违规: {rel} (期望 snake_case)")


def check_directories(violations: list[str]) -> int:
    checked = 0
    project_abs = os.path.abspath(PROJECT_ROOT)
    for root, dirs, _files in os.walk(project_abs):
        rel_root = os.path.relpath(root, project_abs)
        if rel_root == ".":
            continue
        for name in dirs:
            rel = rel_to_project(os.path.join(rel_root, name))
            checked += 1
            _check_directory_name(rel, name, violations)
    return checked


def git_new_files() -> list[str]:
    """返回 Git 新增文件（已暂存/已跟踪新增 + 未跟踪）。"""
    paths: list[str] = []
    try:
        staged = subprocess.run(
            ["git", "diff", "--name-only", "--diff-filter=A", "HEAD", "--", PROJECT_ROOT],
            capture_output=True, text=True, errors="ignore", check=False,
        )
        paths.extend(p.strip() for p in staged.stdout.splitlines() if p.strip())
        untracked = subprocess.run(
            ["git", "ls-files", "--others", "--exclude-standard", "--", PROJECT_ROOT],
            capture_output=True, text=True, errors="ignore", check=False,
        )
        paths.extend(p.strip() for p in untracked.stdout.splitlines() if p.strip())
    except OSError:
        return []
    return sorted(set(paths))


def disk_all_files() -> list[str]:
    """返回磁盘全量业务文件（跳过引擎缓存与版本控制目录），供 `--all` 全量审计。"""
    paths: list[str] = []
    root_abs = os.path.abspath(PROJECT_ROOT)
    for root, dirs, files in os.walk(root_abs):
        dirs[:] = [d for d in dirs if d not in (".git", ".godot", "godot")]
        for filename in files:
            abs_p = os.path.join(root, filename)
            rel = os.path.relpath(abs_p, root_abs).replace(os.sep, "/")
            paths.append(f"{PROJECT_ROOT}/{rel}")
    return sorted(paths)


def _check_file_paths(violations: list[str], file_paths: list[str]) -> int:
    checked = 0
    for git_path in file_paths:
        if not git_path.startswith(PROJECT_ROOT + "/"):
            continue
        rel = git_path[len(PROJECT_ROOT) + 1:]
        if rel.lower().endswith((".import", ".uid", ".translation")):
            continue
        if is_file_whitelisted(rel) or SPINE_RE.search(rel) or META_RE.search(rel):
            continue
        # `.godot` 是引擎缓存目录，不是业务资产；其内部脚本/资源不参与命名审计。
        if rel.startswith(".godot/") or rel.startswith("godot/"):
            continue
        name = os.path.basename(rel)
        stem, ext = os.path.splitext(name)
        ext = ext.lower()
        if ext not in {".tscn", ".gd"} and ext not in SNAKE_ASSET_EXT:
            continue
        checked += 1
        if ext == ".gd" and rel.startswith("Scene/"):
            violations.append(
                f"脚本落位违规: {rel} (Scene/ 不承载 .gd，应归 Script/<domain>/)"
            )
            continue
        parent = os.path.dirname(rel)
        if parent == "Scene" and ext == ".tscn":
            violations.append(
                f"场景落位违规: {rel} (Scene/ 根级不承载 .tscn，应归 Scene/<domain>/)"
            )
            continue
        if parent == "Script" and ext == ".gd":
            violations.append(
                f"脚本落位违规: {rel} (Script/ 根级不承载 .gd，应归 Script/<domain>/)"
            )
            continue
        if not SNAKE_RE.match(stem):
            kind = ".tscn 场景" if ext == ".tscn" else (".gd 脚本" if ext == ".gd" else "资源")
            violations.append(f"{kind}文件命名违规: {rel} (期望 snake_case)")
    return checked


def check_files(violations: list[str], all_files: bool = False) -> int:
    return _check_file_paths(violations, disk_all_files() if all_files else git_new_files())


def check_all(violations: list[str]) -> tuple[int, int]:
    """Combine the full-directory walk while retaining each scan's exclusions and order."""
    checked_dirs = 0
    all_files: list[str] = []
    excluded_dirs = {".git", ".godot", "godot"}
    root_abs = os.path.abspath(PROJECT_ROOT)
    for root, dirs, files in os.walk(root_abs):
        rel_root = os.path.relpath(root, root_abs)
        if rel_root != ".":
            for name in dirs:
                rel = rel_to_project(os.path.join(rel_root, name))
                checked_dirs += 1
                _check_directory_name(rel, name, violations)
        rel_parts = () if rel_root == "." else rel_root.split(os.sep)
        if any(part in excluded_dirs for part in rel_parts):
            continue
        for filename in files:
            rel = os.path.relpath(os.path.join(root, filename), root_abs).replace(os.sep, "/")
            all_files.append(f"{PROJECT_ROOT}/{rel}")
    return checked_dirs, _check_file_paths(violations, sorted(all_files))




def main() -> int:
    global PROJECT_ROOT

    parser = argparse.ArgumentParser(description="ZMXYBHYH 目录与资产命名审计门禁")
    parser.add_argument("--root", default=PROJECT_ROOT, help="工程根目录")
    parser.add_argument("--all", action="store_true", help="检查全量 tracked/untracked 文件，而非仅新增文件")
    args = parser.parse_args()

    PROJECT_ROOT = args.root
    if not os.path.isdir(PROJECT_ROOT):
        print(f"[FAIL] 工程根目录不存在: {PROJECT_ROOT}", file=sys.stderr)
        return 2
    apply_registry(load_registry())

    violations: list[str] = []
    if args.all:
        dir_count, file_count = check_all(violations)
    else:
        dir_count = check_directories(violations)
        file_count = check_files(violations, all_files=False)

    print(f"[*] 目录命名检查: {dir_count} 个")
    print(f"[*] {'全量' if args.all else '新增'}文件命名检查: {file_count} 个")

    if violations:
        print(f"[!] 发现 {len(violations)} 处命名违规:")
        for item in violations:
            print(f"    - {item}")
        return 1

    print("[SUCCESS] 目录与新增资产命名全部合规！")
    return 0


if __name__ == "__main__":
    sys.exit(main())

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
   snake_case（类脚本文件名不要求与 class_name 同为大驼峰）。

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
    THIRD_PARTY_PREFIXES = tuple(naming.get("third_party_prefixes", ["addons/"])) + ("godot/", ".godot/")
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
            if is_dir_whitelisted(rel):
                continue
            if not SNAKE_RE.match(name):
                violations.append(f"目录命名违规: {rel} (期望 snake_case)")
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


def check_files(violations: list[str], all_files: bool = False) -> int:
    checked = 0
    for git_path in (disk_all_files() if all_files else git_new_files()):
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
        if not SNAKE_RE.match(stem):
            kind = ".tscn 场景" if ext == ".tscn" else (".gd 脚本" if ext == ".gd" else "资源")
            violations.append(f"{kind}文件命名违规: {rel} (期望 snake_case)")
    return checked


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
    dir_count = check_directories(violations)
    file_count = check_files(violations, all_files=args.all)

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

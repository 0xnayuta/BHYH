#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/runtime_reference_audit.py

运行时引用契约静态门禁。

覆盖两类 Godot 动态解析风险：

1. NodePath：
   - 扫描挂载到场景上的脚本中的 `@onready` 节点绑定，包括
     `$...`、`$"..."`、`get_node(...)`、`NodePath(...)`；
   - `get_node_or_null(...)` 视为可选节点，不在此门禁中强制存在；
   - 按脚本实际挂载节点解析相对路径，并展开 `instance=ExtResource(...)`
     的子场景节点；
   - 检查路径与场景树节点名大小写逐字一致。

2. Global 方法：
   - 解析 `global.gd` 的 `func` 声明；
   - 扫描 `Global.<method>(...)` 调用，排除 Node/Object 内置方法；
   - 发现调用不存在的方法时失败，防止 B1/A1 这类“改名后漏改调用方”。

退出码：0=PASS，1=发现问题，2=扫描/参数错误。
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PROJECT = REPO_ROOT / "source"

NODE_BUILTIN_METHODS = {
    "add_child",
    "add_sibling",
    "call",
    "call_deferred",
    "callv",
    "connect",
    "disconnect",
    "duplicate",
    "emit_signal",
    "find_child",
    "find_children",
    "free",
    "get",
    "get_child",
    "get_children",
    "get_index",
    "get_node",
    "get_node_or_null",
    "get_owner",
    "get_parent",
    "get_path",
    "get_tree",
    "has_method",
    "has_node",
    "get_class",
    "get_instance_id",
    "get_meta",
    "get_meta_list",
    "get_method_list",
    "get_multiplayer",
    "get_process_delta_time",
    "get_process_mode",
    "get_property_list",
    "get_scene_file_path",
    "get_script",
    "get_signal_list",
    "get_viewport",
    "get_window",
    "get_world_2d",
    "has_meta",
    "has_signal",
    "is_class",
    "is_connected",
    "is_node_ready",
    "is_physics_processing",
    "is_processing",
    "is_inside_tree",
    "is_queued_for_deletion",
    "notification",
    "notify",
    "queue_free",
    "remove_child",
    "rpc",
    "rpc_id",
    "set",
    "set_deferred",
    "set_owner",
}

SCENE_EXT_RES_RE = re.compile(r"\[ext_resource\s+([^\]]+)\]")
ATTR_RE = re.compile(r'([a-zA-Z_]+)="([^"]*)"')
NODE_RE = re.compile(r'^\[node\s+name="([^"]+)"(.*)\]$')
SCRIPT_RES_RE = re.compile(r'script\s*=\s*ExtResource\("([^"]+)"\)')
INSTANCE_RES_RE = re.compile(r'instance\s*=\s*ExtResource\("([^"]+)"\)')

DOLLAR_RE = re.compile(r'\$("(?:[^"\\]|\\.)*"|[A-Za-z0-9_./]+)')
GET_NODE_RE = re.compile(r'get_node(?:_or_null)?\s*\(\s*"([^"]+)"')
NODE_PATH_RE = re.compile(r'NodePath\s*\(\s*"([^"]+)"')


def _clean_line(line: str) -> str:
    # 只去掉注释；不要在字符串内容上做复杂解析。
    return line.split("#", 1)[0]


def _res_to_rel(path: str) -> str:
    return path[6:] if path.startswith("res://") else path.replace("\\", "/")


def _resolve(base: str, path: str) -> Optional[str]:
    if not path or path.startswith("/") or path.startswith("%"):
        return None
    parts = [part for part in path.split("/") if part not in ("", ".")]
    for part in parts:
        if part == "..":
            if "/" not in base:
                return None
            base = base.rsplit("/", 1)[0]
        else:
            base = f"{base}/{part}" if base else part
    return base


class SceneGraph:
    """递归展开场景树，包含 instance 子场景节点和脚本挂载点。"""

    def __init__(self, project_dir: Path):
        self.project_dir = project_dir
        self.cache: Dict[str, Tuple[Set[str], Dict[str, Set[str]], str]] = {}

    def _read(self, rel: str) -> str:
        return (self.project_dir / rel).read_text(encoding="utf-8", errors="ignore")

    def parse(self, rel: str, stack: Tuple[str, ...] = ()) -> Tuple[Set[str], Dict[str, Set[str]], str]:
        if rel in self.cache:
            return self.cache[rel]
        if rel in stack:
            return set(), {}, ""
        text = self._read(rel)
        lines = text.splitlines()

        ext_types: Dict[str, str] = {}
        ext_paths: Dict[str, str] = {}
        for line in lines:
            m = SCENE_EXT_RES_RE.search(line)
            if not m:
                continue
            attrs = dict(ATTR_RE.findall(m.group(1)))
            rid = attrs.get("id", "")
            if rid:
                ext_types[rid] = attrs.get("type", "")
                ext_paths[rid] = _res_to_rel(attrs.get("path", ""))

        nodes: Set[str] = set()
        script_owners: Dict[str, Set[str]] = {}
        root_name = ""
        current_path = ""
        current_script: Optional[str] = None

        def flush_script() -> None:
            nonlocal current_script
            if current_path and current_script:
                script_owners.setdefault(current_script, set()).add(current_path)
            current_script = None

        for line in lines:
            m = NODE_RE.match(line)
            if not m:
                sm = SCRIPT_RES_RE.search(line)
                if sm:
                    rid = sm.group(1)
                    if ext_types.get(rid) == "Script":
                        current_script = ext_paths.get(rid)
                continue

            flush_script()
            name = m.group(1)
            attrs_text = m.group(2)
            attrs = dict(ATTR_RE.findall(attrs_text))
            parent = attrs.get("parent")
            if parent is None:
                root_name = name
                current_path = name
            else:
                base = root_name if parent in ("", ".") else f"{root_name}/{parent}"
                current_path = f"{base}/{name}" if base else name
            nodes.add(current_path)

            sm = SCRIPT_RES_RE.search(attrs_text)
            if sm and ext_types.get(sm.group(1)) == "Script":
                current_script = ext_paths.get(sm.group(1))

            im = INSTANCE_RES_RE.search(attrs_text)
            if im:
                target_rel = ext_paths.get(im.group(1))
                if target_rel and target_rel.endswith(".tscn"):
                    child_nodes, child_scripts, child_root = self.parse(target_rel, stack + (rel,))
                    if child_root:
                        for child_node in child_nodes:
                            if child_node == child_root:
                                merged = current_path
                            elif child_node.startswith(child_root + "/"):
                                merged = current_path + "/" + child_node[len(child_root) + 1 :]
                            else:
                                continue
                            nodes.add(merged)
                        for script_rel, owners in child_scripts.items():
                            for owner in owners:
                                if owner == child_root:
                                    merged_owner = current_path
                                elif owner.startswith(child_root + "/"):
                                    merged_owner = current_path + "/" + owner[len(child_root) + 1 :]
                                else:
                                    continue
                                script_owners.setdefault(script_rel, set()).add(merged_owner)
        flush_script()
        result = (nodes, script_owners, root_name)
        self.cache[rel] = result
        return result


def collect_scene_index(graph: SceneGraph, project_dir: Path) -> Dict[str, List[Tuple[str, Set[str]]]]:
    """返回 script_rel -> [(scene_rel, owner_paths)]。"""
    index: Dict[str, List[Tuple[str, Set[str]]]] = {}
    for path in project_dir.rglob("*.tscn"):
        if ".godot" in path.parts:
            continue
        rel = path.relative_to(project_dir).as_posix()
        _nodes, scripts, _root = graph.parse(rel)
        for script_rel, owners in scripts.items():
            index.setdefault(script_rel, []).append((rel, owners))
    return index


def scan_script_paths(project_dir: Path, scene_index: Dict[str, List[Tuple[str, Set[str]]]], graph: SceneGraph):
    issues: List[Dict[str, str]] = []
    for path in project_dir.rglob("*.gd"):
        if ".godot" in path.parts:
            continue
        script_rel = path.relative_to(project_dir).as_posix()
        owners = scene_index.get(script_rel)
        if not owners:
            continue
        refs: List[Tuple[int, str, str]] = []
        for lineno, raw_line in enumerate(path.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
            line = _clean_line(raw_line)
            # 先只审计 @onready 节点绑定：这是 A2 这类批量改名的核心风险面，
            # 也是静态可判定、不会被运行时动态 get_node 误伤的最小闭包。
            if "@onready" not in line:
                continue
            for match in DOLLAR_RE.finditer(line):
                raw = match.group(1)
                if raw.startswith('"') and raw.endswith('"'):
                    raw = raw[1:-1]
                # `$Node.property` / `$Node.method()` 只检查节点本身。
                raw = raw.split(".", 1)[0].split(":", 1)[0]
                if "%" in raw or raw.startswith("/") or raw.startswith("%"):
                    continue
                refs.append((lineno, raw, "$"))
            for regex, kind in ((GET_NODE_RE, "get_node"), (NODE_PATH_RE, "get_node")):
                for match in regex.finditer(line):
                    raw = match.group(1)
                    if "%" in raw or raw.startswith("/") or raw.startswith("%"):
                        continue
                    if kind == "get_node" and "get_node_or_null" in line:
                        continue
                    refs.append((lineno, raw, kind))
        if not refs:
            continue
        for scene_rel, owner_set in owners:
            nodes, _scripts, _root = graph.parse(scene_rel)
            for owner in owner_set:
                for lineno, raw, kind in refs:
                    full = _resolve(owner, raw)
                    if full is None:
                        continue
                    # 只检查能确定属于本地场景树的路径；首段不在该场景树中的
                    # 路径通常是运行时创建或来自未展开的继承场景，跳过以免假阳性。
                    first_segment = f"{owner}/{(raw.split('/', 1)[0] if raw else '')}"
                    if first_segment not in nodes:
                        # 根级单段路径缺失通常是固定 @onready 绑定错误；
                        # 多段路径可能来自运行时生成/未展开的继承场景，跳过。
                        if "/" not in raw:
                            issues.append(
                                {
                                    "kind": "NodePath",
                                    "script": script_rel,
                                    "line": str(lineno),
                                    "scene": scene_rel,
                                    "owner": owner,
                                    "path": raw,
                                    "resolved": full,
                                    "source": kind,
                                }
                            )
                        continue
                    if full not in nodes:
                        # 基础场景脚本可能由派生场景补充节点；任一挂载场景
                        # 能解析该路径时，不把基础场景缺失视为错误。
                        if any(
                            _resolve(other_owner, raw) in graph.parse(other_scene)[0]
                            for other_scene, other_owners in owners
                            for other_owner in other_owners
                        ):
                            continue
                        issues.append(
                            {
                                "kind": "NodePath",
                                "script": script_rel,
                                "line": str(lineno),
                                "scene": scene_rel,
                                "owner": owner,
                                "path": raw,
                                "resolved": full,
                                "source": kind,
                            }
                        )
    return issues


def collect_global_methods(project_dir: Path) -> Set[str]:
    global_script = project_dir / "global.gd"
    if not global_script.exists():
        return set()
    text = global_script.read_text(encoding="utf-8", errors="ignore")
    return set(re.findall(r"^func\s+([A-Za-z_]\w*)\s*\(", text, re.M))


def scan_global_calls(project_dir: Path, definitions: Set[str]) -> List[Dict[str, str]]:
    issues: List[Dict[str, str]] = []
    for path in project_dir.rglob("*.gd"):
        if ".godot" in path.parts:
            continue
        rel = path.relative_to(project_dir).as_posix()
        for lineno, line in enumerate(path.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
            clean = _clean_line(line)
            for match in re.finditer(r"\bGlobal\.([A-Za-z_]\w*)\s*\(", clean):
                method = match.group(1)
                if method in definitions or method in NODE_BUILTIN_METHODS:
                    continue
                issues.append(
                    {
                        "kind": "GlobalMethod",
                        "script": rel,
                        "line": str(lineno),
                        "method": method,
                    }
                )
    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description="NodePath 与 Global.<method>() 静态运行时引用门禁")
    parser.add_argument("--project", default=str(DEFAULT_PROJECT), help="Godot 工程目录")
    parser.add_argument("--json", action="store_true", help="输出 JSON 结果")
    args = parser.parse_args()
    project_dir = Path(args.project).resolve()
    if not project_dir.is_dir():
        print(f"[!] 工程目录不存在: {project_dir}", file=sys.stderr)
        return 2

    graph = SceneGraph(project_dir)
    scene_index = collect_scene_index(graph, project_dir)
    node_issues = scan_script_paths(project_dir, scene_index, graph)
    global_defs = collect_global_methods(project_dir)
    method_issues = scan_global_calls(project_dir, global_defs)
    issues = node_issues + method_issues

    payload = {
        "project": str(project_dir),
        "scene_count": len(list(project_dir.rglob("*.tscn"))),
        "script_scene_mappings": len(scene_index),
        "global_methods": len(global_defs),
        "node_path_issues": len(node_issues),
        "global_method_issues": len(method_issues),
        "issues": issues,
    }
    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print(
            f"[*] 运行时引用审计: NodePath {len(node_issues)} 个问题，"
            f"Global 方法 {len(method_issues)} 个问题"
        )
        for issue in issues[:80]:
            if issue["kind"] == "NodePath":
                print(
                    f"    - NodePath: {issue['script']}:{issue['line']} "
                    f"{issue['owner']} + {issue['path']} -> {issue['resolved']} "
                    f"(scene={issue['scene']})"
                )
            else:
                print(f"    - GlobalMethod: {issue['script']}:{issue['line']} Global.{issue['method']}()")
        if len(issues) > 80:
            print(f"    ... 其余 {len(issues) - 80} 个问题")
    return 0 if not issues else 1


if __name__ == "__main__":
    sys.exit(main())

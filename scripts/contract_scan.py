#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/contract_scan.py

BHYH 全工程字面量契约全量扫描器 (Phase 8-1)
====================================================================
用于全量扫描并比对工程中六大字面量契约与真源的一致性：
1. 资源路径契约 (Resource Path Contract): res:// 路径存在性与严格大小写敏感校验
2. 节点路径契约 (Node Path Contract): get_node/NodePath/$ 节点树层级与大小写敏感校验
3. 动态反射契约 (Reflection Contract): call/has_method/set/get/connect 字符串与符号声明比对
4. 动画轨道契约 (Animation Track Contract): method 轨道与 value 属性轨道的方法与节点大小写比对
5. 字典键契约 (Dictionary Key Contract): 中文字典键字面量与 DataKeys 常量契约映射比对
6. 运行时 manifest 门禁 (Runtime Manifest Gate): 新增代码禁止在运行时直接加载 atlas manifest

输出格式：
- Markdown 报告: docs/reports/contract_audit.md
- JSON 机读报告: docs/reports/contract_audit.json
"""

import os
import sys
import re
import json
import time
import argparse
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Optional, Any

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class DiskCaseIndex:
    """
    跨平台大小写精确文件系统索引器。
    在 Windows/Linux 下均提供确定性的大小写敏感校验与真实路径还原。
    """
    def __init__(self, root_dir: str):
        self.root_dir = os.path.abspath(root_dir)
        self._dir_cache: Dict[str, Dict[str, str]] = {}
        self._populate_dir_cache(self.root_dir)

    def _populate_dir_cache(self, current_dir: str):
        try:
            entries = os.listdir(current_dir)
        except OSError:
            return

        mapping: Dict[str, str] = {}
        subdirs: List[str] = []
        for e in entries:
            mapping[e.lower()] = e
            full_p = os.path.join(current_dir, e)
            if os.path.isdir(full_p):
                # 排除缓存与版本控制目录
                if e not in (".godot", "godot", ".git"):
                    subdirs.append(full_p)

        self._dir_cache[current_dir] = mapping
        for s in subdirs:
            self._populate_dir_cache(s)

    def resolve_res_path(self, res_path: str) -> Tuple[str, str, str]:
        """
        解析 res:// 路径。
        返回: (status, exact_res_path, reason)
        status 可选值:
          - "EXACT": 完全精确匹配（包含大小写）
          - "CASE_MISMATCH": 文件/目录存在，但路径中某些分段大小写与磁盘不一致
          - "MISSING": 路径不存在
        """
        clean = res_path.replace("res://", "").strip()
        if not clean:
            return "EXACT", "res://", "root"

        parts = [p for p in clean.replace("\\", "/").split("/") if p]
        cur_abs = self.root_dir
        exact_parts: List[str] = []
        case_mismatched = False

        for i, part in enumerate(parts):
            # 处理动态通配或格式化符号
            if "%" in part or "{" in part or "*" in part:
                exact_parts.extend(parts[i:])
                return ("CASE_MISMATCH" if case_mismatched else "DYNAMIC",
                        "res://" + "/".join(exact_parts),
                        f"动态占位分段: {part}")

            mapping = self._dir_cache.get(cur_abs)
            if mapping is None:
                # 尝试现场读取
                try:
                    entries = os.listdir(cur_abs)
                    mapping = {e.lower(): e for e in entries}
                    self._dir_cache[cur_abs] = mapping
                except OSError:
                    exact_parts.extend(parts[i:])
                    return "MISSING", "res://" + "/".join(exact_parts), f"无法访问目录: {cur_abs}"

            low = part.lower()
            if low not in mapping:
                exact_parts.extend(parts[i:])
                return "MISSING", "res://" + "/".join(exact_parts), f"分段不存在: {part}"

            real_part = mapping[low]
            if real_part != part:
                case_mismatched = True
            exact_parts.append(real_part)
            cur_abs = os.path.join(cur_abs, real_part)

        exact_res = "res://" + "/".join(exact_parts)
        if case_mismatched:
            return "CASE_MISMATCH", exact_res, "分段大小写与磁盘真名不一致"
        return "EXACT", exact_res, "精确匹配"


class SceneNodeInfo:
    def __init__(self, name: str, node_type: str, parent: str, full_path: str, script_res: str = ""):
        self.name = name
        self.node_type = node_type
        self.parent = parent
        self.full_path = full_path  # 相对于场景根节点的路径，如 "Action/RoleBody"
        self.script_res = script_res


class SceneTreeParser:
    """
    场景节点树解析器：解析 .tscn 文本，构建完整层级树、节点全名与脚本挂载点。
    """
    def __init__(self, project_dir: str):
        self.project_dir = os.path.abspath(project_dir)
        self.scenes: Dict[str, Dict[str, SceneNodeInfo]] = {}  # scn_res -> {full_path: SceneNodeInfo}
        self.script_to_scene_nodes: Dict[str, List[Tuple[str, str]]] = defaultdict(list)  # script_res -> [(scn_res, node_full_path)]
        self.all_node_names: Set[str] = set()
        self.node_name_to_paths: Dict[str, Set[str]] = defaultdict(set)

    def parse_all_scenes(self, scene_files: List[str]):
        node_def_re = re.compile(r'^\[node\s+name="([^"]+)"(?:\s+type="([^"]*)")?(?:\s+parent="([^"]*)")?(?:\s+instance=ExtResource\("([^"]*)"\))?', re.M)
        script_ext_re = re.compile(r'script\s*=\s*ExtResource\("([^"]+)"\)')
        ext_res_re = re.compile(r'\[ext_resource\s+[^\]]*path="([^"]+)"[^\]]*id="([^"]+)"')

        for scn_abs in scene_files:
            rel_p = os.path.relpath(scn_abs, self.project_dir).replace("\\", "/")
            scn_res = "res://" + rel_p

            try:
                content = open(scn_abs, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue

            # 建立 ext_resource id -> path 映射
            ext_map = {}
            for m in ext_res_re.finditer(content):
                ext_map[m.group(2)] = m.group(1)

            # 分段解析 [node ...]
            nodes_by_path: Dict[str, SceneNodeInfo] = {}
            lines = content.splitlines()
            current_node = None
            current_section_lines = []

            for line in lines:
                if line.startswith("[node "):
                    if current_node:
                        # 检查上一节点是否挂载了脚本
                        sec_text = "\n".join(current_section_lines)
                        m_sc = script_ext_re.search(sec_text)
                        if m_sc:
                            res_id = m_sc.group(1)
                            script_p = ext_map.get(res_id, "")
                            current_node.script_res = script_p
                            if script_p:
                                self.script_to_scene_nodes[script_p].append((scn_res, current_node.full_path))
                    current_section_lines = [line]
                    m_n = node_def_re.match(line)
                    if m_n:
                        name = m_n.group(1)
                        ntype = m_n.group(2) or ""
                        parent = m_n.group(3) or ""

                        # 计算 full_path
                        if parent == "":
                            full_p = "."  # 根节点自身
                        elif parent == ".":
                            full_p = name
                        else:
                            full_p = f"{parent}/{name}"

                        current_node = SceneNodeInfo(name, ntype, parent, full_p)
                        nodes_by_path[full_p] = current_node
                        self.all_node_names.add(name)
                        self.node_name_to_paths[name].add(full_p)
                    else:
                        current_node = None
                elif line.startswith("[") and current_node:
                    # 进入下一非 node 块
                    sec_text = "\n".join(current_section_lines)
                    m_sc = script_ext_re.search(sec_text)
                    if m_sc:
                        res_id = m_sc.group(1)
                        script_p = ext_map.get(res_id, "")
                        current_node.script_res = script_p
                        if script_p:
                            self.script_to_scene_nodes[script_p].append((scn_res, current_node.full_path))
                    current_node = None
                    current_section_lines = []
                else:
                    if current_node:
                        current_section_lines.append(line)

            # 收尾最后一个 node
            if current_node:
                sec_text = "\n".join(current_section_lines)
                m_sc = script_ext_re.search(sec_text)
                if m_sc:
                    res_id = m_sc.group(1)
                    script_p = ext_map.get(res_id, "")
                    current_node.script_res = script_p
                    if script_p:
                        self.script_to_scene_nodes[script_p].append((scn_res, current_node.full_path))

            self.scenes[scn_res] = nodes_by_path


class CodeSymbolIndex:
    """
    全工程 GDScript 符号提取与索引器：类、函数、变量、信号与常用内置 API。
    """
    # 常用 Godot 4 内置 API 白名单（防止对引擎原生方法/属性报错）
    GODOT_BUILTIN_METHODS = {
        "_ready", "_process", "_physics_process", "_input", "_unhandled_input",
        "_enter_tree", "_exit_tree", "_draw", "_gui_input", "queue_free", "free",
        "set_deferred", "get_node", "get_node_or_null", "has_node", "has_method",
        "call", "call_deferred", "get", "set", "connect", "disconnect", "emit_signal",
        "is_connected", "play", "stop", "pause", "resume", "show", "hide", "update",
        "reload", "instantiate", "duplicate", "add_child", "remove_child", "get_parent",
        "get_children", "get_child", "get_child_count", "reparent", "look_at",
        "move_and_slide", "is_on_floor", "is_on_wall", "is_on_ceiling", "clamp",
        "get_viewport", "get_tree", "change_scene_to_file", "change_scene_to_packed",
        "quit", "start", "stop", "is_stopped", "set_wait_time"
    }

    GODOT_BUILTIN_PROPERTIES = {
        "position", "rotation", "scale", "visible", "modulate", "self_modulate",
        "z_index", "size", "custom_minimum_size", "text", "disabled", "target_position",
        "global_position", "global_rotation", "global_scale", "hframes", "vframes",
        "frame", "texture", "offset", "flip_h", "flip_v", "color", "velocity",
        "collision_layer", "collision_mask", "name", "process_mode", "speed_scale",
        "time_left", "wait_time", "one_shot", "autostart", "value", "max_value", "min_value"
    }

    GODOT_BUILTIN_SIGNALS = {
        "tree_entered", "tree_exited", "tree_exiting", "ready", "renamed",
        "child_entered_tree", "child_exiting_tree", "timeout", "pressed",
        "button_down", "button_up", "toggled", "value_changed", "text_changed",
        "text_submitted", "item_selected", "mouse_entered", "mouse_exited",
        "focus_entered", "focus_exited", "gui_input", "visibility_changed",
        "area_entered", "area_exited", "body_entered", "body_exited",
        "animation_finished", "frame_changed", "finished"
    }

    def __init__(self, project_dir: str):
        self.project_dir = os.path.abspath(project_dir)
        self.methods_by_script: Dict[str, Set[str]] = defaultdict(set)
        self.props_by_script: Dict[str, Set[str]] = defaultdict(set)
        self.signals_by_script: Dict[str, Set[str]] = defaultdict(set)
        self.all_declared_methods: Set[str] = set()
        self.all_declared_props: Set[str] = set()
        self.all_declared_signals: Set[str] = set()
        self.lower_to_methods: Dict[str, Set[str]] = defaultdict(set)
        self.lower_to_props: Dict[str, Set[str]] = defaultdict(set)
        self.class_names: Dict[str, str] = {}  # ClassName -> res://Path.gd

    def parse_all_scripts(self, script_files: List[str]):
        func_re = re.compile(r'^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(', re.M)
        var_re = re.compile(r'^\s*(?:@export[a-z_()0-9, ]*\s+)?(?:@onready\s+)?(?:var|const)\s+([A-Za-z_][A-Za-z0-9_]*)', re.M)
        signal_re = re.compile(r'^\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)', re.M)
        class_name_re = re.compile(r'^\s*class_name\s+([A-Za-z_][A-Za-z0-9_]*)', re.M)

        for sc_abs in script_files:
            rel_p = os.path.relpath(sc_abs, self.project_dir).replace("\\", "/")
            sc_res = "res://" + rel_p

            try:
                text = open(sc_abs, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue

            for m in func_re.finditer(text):
                fn = m.group(1)
                self.methods_by_script[sc_res].add(fn)
                self.all_declared_methods.add(fn)
                self.lower_to_methods[fn.lower()].add(fn)

            for m in var_re.finditer(text):
                vn = m.group(1)
                self.props_by_script[sc_res].add(vn)
                self.all_declared_props.add(vn)
                self.lower_to_props[vn.lower()].add(vn)

            for m in signal_re.finditer(text):
                sn = m.group(1)
                self.signals_by_script[sc_res].add(sn)
                self.all_declared_signals.add(sn)

            m_cls = class_name_re.search(text)
            if m_cls:
                self.class_names[m_cls.group(1)] = sc_res


class DataKeysIndex:
    """
    解析 data_keys.gd，提取已契约化中文字典键。
    """
    def __init__(self, datakeys_abs: str):
        self.defined_keys: Dict[str, str] = {}  # "中文字符串" -> "DataKeys.Class.CONST"
        if os.path.exists(datakeys_abs):
            self._parse(datakeys_abs)

    def _parse(self, fp: str):
        current_class = "Root"
        cls_re = re.compile(r'^\s*class\s+([A-Za-z0-9_]+):')
        const_re = re.compile(r'^\s*const\s+([A-Za-z0-9_]+)\s*=\s*["\']([^"\']+)["\']')

        for line in open(fp, "r", encoding="utf-8", errors="ignore"):
            clean = line.strip()
            m_cls = cls_re.match(clean)
            if m_cls:
                current_class = m_cls.group(1)
                continue
            m_const = const_re.match(clean)
            if m_const:
                cname = m_const.group(1)
                val = m_const.group(2)
                # 记录最匹配的键路径
                self.defined_keys[val] = f"DataKeys.{current_class}.{cname}"


class ContractFinding:
    """单一契约发现记录"""
    def __init__(
        self,
        category: str,       # resource_path, node_path, reflection, anim_track, dict_key
        severity: str,       # ERROR, WARNING, INFO
        file_path: str,
        line: int,
        literal: str,
        message: str,
        suggested_fix: str = "",
        rule_id: str = ""
    ):
        self.category = category
        self.severity = severity
        self.file_path = file_path
        self.line = line
        self.literal = literal
        self.message = message
        self.suggested_fix = suggested_fix
        self.rule_id = rule_id

    def to_dict(self) -> Dict[str, Any]:
        return {
            "category": self.category,
            "severity": self.severity,
            "file": self.file_path,
            "line": self.line,
            "literal": self.literal,
            "message": self.message,
            "suggested_fix": self.suggested_fix,
            "rule_id": self.rule_id,
        }


class ContractWhitelist:
    """白名单管理器"""
    def __init__(self, whitelist_path: Optional[str] = None):
        self.whitelist_path = whitelist_path
        self.data: Dict[str, Any] = {
            "suppressed_literals": set(),
            "suppressed_files": set(),
            "missing_asset_known_allowlist": set(),
            "known_extension_methods": set(),
            "unresolved_node_patterns": [],
        }
        self._load_defaults()
        if whitelist_path and os.path.exists(whitelist_path):
            self._load_from_file(whitelist_path)

    def _load_defaults(self):
        # 默认豁免项：运行时动态路径、插件特定配置、历史已知未解包音频/材质
        self.data["missing_asset_known_allowlist"].update([
            # 常见动态或虚拟前缀
            "res://.godot/",
            "res://godot/",
        ])

    def _load_from_file(self, fp: str):
        try:
            with open(fp, "r", encoding="utf-8") as f:
                d = json.load(f)
                self.data["suppressed_literals"].update(d.get("suppressed_literals", []))
                self.data["suppressed_files"].update(d.get("suppressed_files", []))
                self.data["missing_asset_known_allowlist"].update(d.get("missing_asset_known_allowlist", []))
                self.data["known_extension_methods"].update(d.get("known_extension_methods", []))
                self.data["unresolved_node_patterns"].extend(d.get("unresolved_node_patterns", []))
        except Exception as e:
            print(f"[!] 读取白名单文件异常: {e}", file=sys.stderr)

    def is_suppressed(self, finding: ContractFinding) -> bool:
        if finding.literal in self.data["suppressed_literals"]:
            return True
        if finding.category == "reflection" and finding.literal in self.data["known_extension_methods"]:
            return True
        for sup_f in self.data["suppressed_files"]:
            if sup_f in finding.file_path:
                return True
        for allow in self.data["missing_asset_known_allowlist"]:
            if allow in finding.literal:
                return True
        return False


class ContractScanner:
    """
    契约扫描总调度器
    """
    def __init__(
        self,
        project_dir: str,
        whitelist_path: Optional[str] = None,
        md_output: Optional[str] = None,
        json_output: Optional[str] = None
    ):
        self.project_dir = os.path.abspath(project_dir)
        self.md_output = os.path.abspath(md_output) if md_output else None
        self.json_output = os.path.abspath(json_output) if json_output else None

        self.whitelist = ContractWhitelist(whitelist_path)
        self.findings: List[ContractFinding] = []

        # 扫描物料容器
        self.script_files: List[str] = []
        self.scene_files: List[str] = []
        self.res_files: List[str] = []
        self.other_scan_files: List[str] = []

        # 索引实例
        self.disk_case_index: Optional[DiskCaseIndex] = None
        self.scene_parser: Optional[SceneTreeParser] = None
        self.symbol_index: Optional[CodeSymbolIndex] = None
        self.datakeys_index: Optional[DataKeysIndex] = None

    def collect_project_files(self):
        """收集工程待测文件"""
        for root, dirs, files in os.walk(self.project_dir):
            dirs[:] = [d for d in dirs if d not in (".godot", "godot", ".git")]
            for f in files:
                abs_p = os.path.join(root, f)
                if f.endswith(".gd"):
                    self.script_files.append(abs_p)
                elif f.endswith(".tscn"):
                    self.scene_files.append(abs_p)
                elif f.endswith(".tres"):
                    self.res_files.append(abs_p)
                elif f in ("project.godot",) or f.endswith((".cfg", ".import")):
                    self.other_scan_files.append(abs_p)

    def build_indexes(self):
        """构建全量索引"""
        t0 = time.time()
        print(f"[*] 构建磁盘大小写精确索引...")
        self.disk_case_index = DiskCaseIndex(self.project_dir)

        print(f"[*] 解析全量场景节点拓扑 ({len(self.scene_files)} 个场景)...")
        self.scene_parser = SceneTreeParser(self.project_dir)
        self.scene_parser.parse_all_scenes(self.scene_files)

        print(f"[*] 索引全量代码符号定义 ({len(self.script_files)} 个脚本)...")
        self.symbol_index = CodeSymbolIndex(self.project_dir)
        self.symbol_index.parse_all_scripts(self.script_files)

        datakeys_path = os.path.join(self.project_dir, "Script", "base", "data_keys.gd")
        self.datakeys_index = DataKeysIndex(datakeys_path)
        print(f"[*] 索引初始化完成，耗时: {time.time() - t0:.2f}s")

    # --------------------------------------------------------------------------
    # 1. 资源路径契约扫描 (Resource Path Contract)
    # --------------------------------------------------------------------------
    def scan_resource_paths(self):
        print(f"[*] 扫描资源路径契约 (res://)...")
        res_pat = re.compile(r'res://([A-Za-z0-9_\-\./%\u4e00-\u9fff]+)')
        target_files = self.script_files + self.scene_files + self.res_files + self.other_scan_files

        for abs_p in target_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            # AtlasMetadata 为构建期生成的数据容器，内部保留原始源帧路径用于溯源，
            # 并非运行时资源依赖；其实际依赖由 SpriteFrames.tres 与转换器保证。
            if abs_p.endswith(".tres") and 'script_class="AtlasMetadata"' in content:
                continue

            for lineno, line in enumerate(content.splitlines(), 1):
                clean_line = line.split("#")[0] if abs_p.endswith(".gd") else line
                for m in res_pat.finditer(clean_line):
                    raw_res = "res://" + m.group(1).rstrip('/.,;)\'"')
                    if raw_res in ("res://", "res://."):
                        continue
                    if raw_res.startswith("res://.godot/") or raw_res.startswith("res://godot/"):
                        continue

                    # 如果有文件扩展名、以/结尾、或者看起来是跨级目录路径，均予校验
                    base_name = os.path.basename(raw_res)
                    if "." not in base_name and not raw_res.endswith("/") and "/" not in raw_res.replace("res://", ""):
                        continue
                    status, exact_res, reason = self.disk_case_index.resolve_res_path(raw_res)
                    if status == "CASE_MISMATCH":
                        finding = ContractFinding(
                            category="resource_path",
                            severity="ERROR",
                            file_path=rel_p,
                            line=lineno,
                            literal=raw_res,
                            message=f"资源路径大小写失配: 磁盘真名为 '{exact_res}'",
                            suggested_fix=exact_res,
                            rule_id="RES_CASE_MISMATCH"
                        )
                        if not self.whitelist.is_suppressed(finding):
                            self.findings.append(finding)
                    elif status == "MISSING":
                        # 区分是否已知纯导出 ctex 或动态前缀
                        severity = "ERROR" if ("." in base_name and "%" not in raw_res) else "WARNING"
                        finding = ContractFinding(
                            category="resource_path",
                            severity=severity,
                            file_path=rel_p,
                            line=lineno,
                            literal=raw_res,
                            message=f"资源文件或目录不存在: {reason}",
                            suggested_fix="",
                            rule_id="RES_MISSING"
                        )
                        if not self.whitelist.is_suppressed(finding):
                            self.findings.append(finding)

    # --------------------------------------------------------------------------
    # 2. 节点路径契约扫描 (Node Path Contract)
    # --------------------------------------------------------------------------
    def scan_node_paths(self):
        print(f"[*] 扫描节点路径契约 (get_node / NodePath / $)...")
        get_node_re = re.compile(r'\b(?:get_node|get_node_or_null|NodePath)\s*\(\s*["^&]([^"^&]+)["^&]')
        dollar_re = re.compile(r'\$([A-Za-z0-9_]+(?:/[A-Za-z0-9_]+)*)')

        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            sc_res = "res://" + rel_p

            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue

            # 获取挂载此脚本的场景节点上下文
            scene_contexts = self.scene_parser.script_to_scene_nodes.get(sc_res, [])

            for lineno, line in enumerate(content.splitlines(), 1):
                clean_l = line.split("#")[0]
                if not clean_l.strip():
                    continue

                candidates = []
                for m in get_node_re.finditer(clean_l):
                    candidates.append((m.group(1), "get_node"))
                for m in dollar_re.finditer(clean_l):
                    candidates.append((m.group(1), "$"))

                for node_path_str, source_type in candidates:
                    # 排除明显纯属性动画轨道后缀如 :frame
                    node_path_clean = node_path_str.split(":")[0].strip()
                    if not node_path_clean or node_path_clean == ".":
                        continue

                    # 1. 如果有明确绑定的场景节点上下文
                    if scene_contexts:
                        for scn_res, bound_node_path in scene_contexts:
                            nodes_in_scene = self.scene_parser.scenes.get(scn_res, {})
                            target_full_path = self._resolve_relative_node_path(bound_node_path, node_path_clean)
                            if target_full_path is None:
                                continue

                            # 在场景节点树中检查目标
                            if target_full_path in nodes_in_scene:
                                # 完全精确匹配
                                pass
                            else:
                                # 检查是否有同名但大小写不同的节点段！
                                matched_case = self._find_node_case_mismatch(target_full_path, nodes_in_scene)
                                if matched_case:
                                    # 构造建议相对路径
                                    suggested = self._construct_relative_suggestion(node_path_clean, matched_case)
                                    finding = ContractFinding(
                                        category="node_path",
                                        severity="ERROR",
                                        file_path=rel_p,
                                        line=lineno,
                                        literal=node_path_str,
                                        message=f"场景 '{os.path.basename(scn_res)}' 中节点路径大小写失配: 实际节点全名为 '{matched_case}'",
                                        suggested_fix=suggested,
                                        rule_id="NODE_CASE_MISMATCH"
                                    )
                                    if not self.whitelist.is_suppressed(finding):
                                        self.findings.append(finding)
                                        break
                    else:
                        # 通用无场景绑定脚本（如 global.gd）：检查路径最后一段是否与已知节点存在明显大小写错位
                        last_part = node_path_clean.split("/")[-1]
                        if last_part in self.scene_parser.all_node_names:
                            continue
                        # 查找大小写变体
                        lower_target = last_part.lower()
                        for cand_name in self.scene_parser.all_node_names:
                            if cand_name.lower() == lower_target and cand_name != last_part:
                                # 检查前缀模式
                                finding = ContractFinding(
                                    category="node_path",
                                    severity="WARNING",
                                    file_path=rel_p,
                                    line=lineno,
                                    literal=node_path_str,
                                    message=f"全局节点引用段 '{last_part}' 疑似大小写失配，工程中存在对应节点 '{cand_name}'",
                                    suggested_fix=node_path_str.replace(last_part, cand_name),
                                    rule_id="NODE_GLOBAL_CASE_MISMATCH"
                                )
                                if not self.whitelist.is_suppressed(finding):
                                    self.findings.append(finding)
                                    break

    def _resolve_relative_node_path(self, current_node_path: str, rel_path: str) -> Optional[str]:
        """将当前节点路径与相对路径解析为绝对全路径"""
        if rel_path.startswith("/"):
            return None  # 绝对路径 /root/... 不作简单场景内解析

        cur_parts = [] if current_node_path in (".", "") else current_node_path.split("/")
        rel_parts = rel_path.split("/")

        for p in rel_parts:
            if p == ".":
                continue
            elif p == "..":
                if cur_parts:
                    cur_parts.pop()
                else:
                    return None  # 越出场景根节点
            else:
                cur_parts.append(p)

        return "/".join(cur_parts) if cur_parts else "."

    def _find_node_case_mismatch(self, target_full_path: str, nodes_in_scene: Dict[str, SceneNodeInfo]) -> Optional[str]:
        target_lower = target_full_path.lower()
        for real_path in nodes_in_scene.keys():
            if real_path.lower() == target_lower and real_path != target_full_path:
                return real_path
        return None

    def _construct_relative_suggestion(self, orig_rel_path: str, target_full_path: str) -> str:
        orig_parts = orig_rel_path.split("/")
        real_parts = target_full_path.split("/")
        # 保留前导的 .. 数量
        leading_dots = [p for p in orig_parts if p in (".", "..")]
        diff_len = len(orig_parts) - len(leading_dots)
        if diff_len <= len(real_parts):
            matched_segment = real_parts[-diff_len:]
            return "/".join(leading_dots + matched_segment)
        return target_full_path

    # --------------------------------------------------------------------------
    # 3. 动态反射契约扫描 (Reflection Contract)
    # --------------------------------------------------------------------------
    def scan_reflection_contracts(self):
        print(f"[*] 扫描动态反射契约 (call / has_method / get / set / connect)...")
        method_call_re = re.compile(r'\b(?:call|call_deferred|has_method)\s*\(\s*["&]([A-Za-z0-9_]+)["&]')
        signal_re = re.compile(r'\b(?:connect|disconnect|emit_signal|is_connected)\s*\(\s*["&]([A-Za-z0-9_]+)["&]')
        get_set_re = re.compile(r'\b(?:get|set)\s*\(\s*["&]([A-Za-z0-9_]+)["&]')

        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue

            for lineno, line in enumerate(content.splitlines(), 1):
                clean_l = line.split("#")[0]

                # 检查方法调用
                for m in method_call_re.finditer(clean_l):
                    method_name = m.group(1)
                    if method_name in CodeSymbolIndex.GODOT_BUILTIN_METHODS:
                        continue
                    if method_name in self.symbol_index.all_declared_methods:
                        continue

                    # 检查是否有同名但驼峰/下划线不一致的声明
                    low = method_name.lower()
                    cands = self.symbol_index.lower_to_methods.get(low, set())
                    if cands:
                        best = sorted(cands)[0]
                        finding = ContractFinding(
                            category="reflection",
                            severity="ERROR",
                            file_path=rel_p,
                            line=lineno,
                            literal=method_name,
                            message=f"反射方法名大小写/下划线失配: 声明为 '{best}'",
                            suggested_fix=best,
                            rule_id="REFL_METHOD_MISMATCH"
                        )
                        if not self.whitelist.is_suppressed(finding):
                            self.findings.append(finding)
                    else:
                        # 属于完全未知的成员
                        if not method_name.startswith("_"):
                            finding = ContractFinding(
                                category="reflection",
                                severity="INFO",
                                file_path=rel_p,
                                line=lineno,
                                literal=method_name,
                                message=f"动态反射调用的方法 '{method_name}' 在工程中无对应显式声明",
                                suggested_fix="",
                                rule_id="REFL_METHOD_UNKNOWN"
                            )
                            if not self.whitelist.is_suppressed(finding):
                                self.findings.append(finding)

                # 检查信号连接
                for m in signal_re.finditer(clean_l):
                    sig_name = m.group(1)
                    if sig_name in CodeSymbolIndex.GODOT_BUILTIN_SIGNALS:
                        continue
                    if sig_name in self.symbol_index.all_declared_signals:
                        continue
                    finding = ContractFinding(
                        category="reflection",
                        severity="WARNING",
                        file_path=rel_p,
                        line=lineno,
                        literal=sig_name,
                        message=f"动态引用的信号 '{sig_name}' 未在工程显式信号表中定义",
                        suggested_fix="",
                        rule_id="REFL_SIGNAL_UNKNOWN"
                    )
                    if not self.whitelist.is_suppressed(finding):
                        self.findings.append(finding)

    # --------------------------------------------------------------------------
    # 4. 动画轨道契约扫描 (Animation Track Contract)
    # --------------------------------------------------------------------------
    def scan_animation_tracks(self):
        print(f"[*] 扫描动画轨道契约 (method/value 轨道)...")
        track_block_re = re.compile(
            r'tracks/(\d+)/type\s*=\s*"([^"]+)"[\s\S]*?'
            r'tracks/\1/path\s*=\s*NodePath\("([^"]+)"\)[\s\S]*?'
            r'(?:tracks/\1/keys\s*=\s*\{([^\}]+)\})?',
            re.M
        )
        method_name_re = re.compile(r'"method":\s*[&"]([A-Za-z0-9_]+)["&]')

        for scn_abs in self.scene_files:
            rel_p = os.path.relpath(scn_abs, self.project_dir).replace("\\", "/")
            scn_res = "res://" + rel_p
            nodes_in_scene = self.scene_parser.scenes.get(scn_res, {})

            try:
                content = open(scn_abs, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue

            for m in track_block_re.finditer(content):
                track_type = m.group(2)
                track_path = m.group(3)
                keys_block = m.group(4) or ""

                # 1. 检查轨道绑定的节点路径本身是否存在大小写失配
                node_part = track_path.split(":")[0].strip()
                prop_part = track_path.split(":")[1].strip() if ":" in track_path else ""

                if node_part not in ("", "."):
                    if node_part in nodes_in_scene:
                        # 节点在场景中精确存在，不属于失配
                        pass
                    else:
                        matched_case = self._find_node_case_mismatch(node_part, nodes_in_scene)
                        if matched_case:
                            new_track = f"{matched_case}:{prop_part}" if prop_part else matched_case
                            finding = ContractFinding(
                                category="anim_track",
                                severity="ERROR",
                                file_path=rel_p,
                                line=0,
                                literal=track_path,
                                message=f"动画轨道绑定节点大小写失配: 实际节点路径为 '{matched_case}'",
                                suggested_fix=new_track,
                                rule_id="ANIM_TRACK_NODE_MISMATCH"
                            )
                            if not self.whitelist.is_suppressed(finding):
                                self.findings.append(finding)

                # 2. 检查 method 轨道对应函数
                if track_type == "method" and keys_block:
                    for meth_m in method_name_re.finditer(keys_block):
                        meth_name = meth_m.group(1)
                        if meth_name in CodeSymbolIndex.GODOT_BUILTIN_METHODS:
                            continue
                        if meth_name in self.symbol_index.all_declared_methods:
                            continue

                        # 检查是否有驼峰/下划线不一致
                        cands = self.symbol_index.lower_to_methods.get(meth_name.lower(), set())
                        if cands:
                            best = sorted(cands)[0]
                            finding = ContractFinding(
                                category="anim_track",
                                severity="ERROR",
                                file_path=rel_p,
                                line=0,
                                literal=meth_name,
                                message=f"动画轨道方法名 '{meth_name}' 与脚本声明大小写不一致，声明为 '{best}'",
                                suggested_fix=best,
                                rule_id="ANIM_TRACK_METHOD_MISMATCH"
                            )
                            if not self.whitelist.is_suppressed(finding):
                                self.findings.append(finding)

    # --------------------------------------------------------------------------
    # 5. 字典键契约扫描 (Dictionary Key Contract)
    # --------------------------------------------------------------------------
    def scan_dict_keys(self):
        print(f"[*] 扫描中文字典键契约 (DataKeys)...")
        zh_pat = re.compile(r'\[\s*["\']([^"\'\n]*[\u4e00-\u9fff][^"\'\n]*)["\']\s*\]|\.get\s*\(\s*["\']([^"\'\n]*[\u4e00-\u9fff][^"\'\n]*)["\']')

        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue

            for lineno, line in enumerate(content.splitlines(), 1):
                clean_l = line.split("#")[0]
                if not clean_l.strip():
                    continue

                for m in zh_pat.finditer(clean_l):
                    zh_key = m.group(1) or m.group(2)
                    if not zh_key:
                        continue

                    # 检查是否已在 DataKeys 中定义
                    if zh_key in self.datakeys_index.defined_keys:
                        datakey_const = self.datakeys_index.defined_keys[zh_key]
                        finding = ContractFinding(
                            category="dict_key",
                            severity="WARNING",
                            file_path=rel_p,
                            line=lineno,
                            literal=zh_key,
                            message=f"硬编码中文字典键 '{zh_key}' 已在契约表收录，建议使用 '{datakey_const}'",
                            suggested_fix=datakey_const,
                            rule_id="DICT_KEY_UNCONVERGED"
                        )
                        if not self.whitelist.is_suppressed(finding):
                            self.findings.append(finding)
                    else:
                        finding = ContractFinding(
                            category="dict_key",
                            severity="INFO",
                            file_path=rel_p,
                            line=lineno,
                            literal=zh_key,
                            message=f"中文字典键 '{zh_key}' 尚未收录进 DataKeys",
                            suggested_fix="",
                            rule_id="DICT_KEY_UNRECORDED"
                        )
                        if not self.whitelist.is_suppressed(finding):
                            self.findings.append(finding)

    # --------------------------------------------------------------------------
    # 6. 运行时 manifest 直接加载门禁 (Runtime Manifest Loading Gate)
    #    Phase 10.5 阶段 3 固化：新增资产禁止运行时 manifest 直接加载。
    #    冻结名单见 docs/naming_whitelist.md §2.6，只减不增。
    # --------------------------------------------------------------------------
    RUNTIME_MANIFEST_FROZEN_ALLOWLIST = ()
    RUNTIME_MANIFEST_IO_TOKENS = (
        "FileAccess.",
        "JSON.parse_string",
        "JSON.parse(",
    )
    RUNTIME_MANIFEST_PATTERNS = (
        "manifest.json",
        "atlas_manifest",
        "manifest_path",
        "NorthOriginalData.manifest(",
        "_get_atlas_manifest",
        "_read_manifest_json",
        "_manifest_for_model(",
        "_manifest_path(",
    )

    @classmethod
    def runtime_manifest_violation(cls, content: str):
        """返回 (行号, 命中标识)；无违规返回 (0, "")。

        判定条件：文件同时具备运行时 IO 能力与 manifest 相关标识。
        仅出现在注释行中的标识不计入，避免文档性注释误报。
        """
        if not any(token in content for token in cls.RUNTIME_MANIFEST_IO_TOKENS):
            return (0, "")
        for lineno, line in enumerate(content.splitlines(), 1):
            if line.strip().startswith("#"):
                continue
            for pattern in cls.RUNTIME_MANIFEST_PATTERNS:
                if pattern in line:
                    return (lineno, pattern)
        return (0, "")

    def scan_runtime_manifest_loading(self):
        print(f"[*] 扫描运行时 manifest 加载门禁 (Phase 10.5 阶段 3)...")
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            if rel_p in self.RUNTIME_MANIFEST_FROZEN_ALLOWLIST:
                continue
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            hit_line, hit_pattern = self.runtime_manifest_violation(content)
            if hit_line == 0:
                continue
            finding = ContractFinding(
                category="runtime_manifest",
                severity="ERROR",
                file_path=rel_p,
                line=hit_line,
                literal=hit_pattern,
                message="新增代码禁止在运行时直接加载 atlas manifest（Phase 10.5 阶段 3 门禁）",
                suggested_fix="改用预生成 SpriteFrames 标准资源 (.tres)，禁止运行时解析 manifest",
                rule_id="RUNTIME_MANIFEST_FORBIDDEN",
            )
            if not self.whitelist.is_suppressed(finding):
                self.findings.append(finding)

    def run_all_checks(self):
        """执行完整六大契约扫描流水线"""
        t0 = time.time()
        self.collect_project_files()
        self.build_indexes()

        self.scan_resource_paths()
        self.scan_node_paths()
        self.scan_reflection_contracts()
        self.scan_animation_tracks()
        self.scan_dict_keys()
        self.scan_runtime_manifest_loading()

        duration = time.time() - t0
        print(f"[*] 全量契约扫描完成，累计耗时: {duration:.2f}s，发现条目: {len(self.findings)} 个")
        return duration

    def generate_reports(self, duration: float):
        """输出 Markdown 与 JSON 报告"""
        # 统计汇总
        stats = {
            "total_findings": len(self.findings),
            "by_severity": defaultdict(int),
            "by_category": defaultdict(int),
            "duration_seconds": round(duration, 2),
            "scripts_scanned": len(self.script_files),
            "scenes_scanned": len(self.scene_files),
        }
        for f in self.findings:
            stats["by_severity"][f.severity] += 1
            stats["by_category"][f.category] += 1

        # 写入 JSON
        if self.json_output:
            os.makedirs(os.path.dirname(self.json_output), exist_ok=True)
            report_data = {
                "metadata": {
                    "scan_time": time.strftime("%Y-%m-%d %H:%M:%S"),
                    "project_dir": os.path.relpath(self.project_dir, REPO_ROOT).replace("\\", "/"),
                    "stats": stats,
                },
                "findings": [f.to_dict() for f in self.findings]
            }
            with open(self.json_output, "w", encoding="utf-8") as jf:
                json.dump(report_data, jf, ensure_ascii=False, indent=2)
            print(f"[√] JSON 报告已写入: {self.json_output}")

        # 写入 Markdown
        if self.md_output:
            os.makedirs(os.path.dirname(self.md_output), exist_ok=True)
            self._write_markdown_report(stats, duration)
            print(f"[√] Markdown 报告已写入: {self.md_output}")

    def _write_markdown_report(self, stats: Dict[str, Any], duration: float):
        lines = []
        lines.append("# BHYH 全工程字面量契约诊断审计报告 (Phase 8-1)")
        lines.append("")
        lines.append(f"> 生成时间: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append(">")
        lines.append(f"> 审计对象: `{os.path.relpath(self.project_dir, REPO_ROOT).replace(chr(92), '/')}`")
        lines.append(">")
        lines.append(f"> 扫描耗时: `{duration:.2f} 秒`（指标要求 ≤ 30 秒）")
        lines.append(">")
        lines.append(f"> 覆盖资产: 脚本 `{stats['scripts_scanned']} 个` / 场景 `{stats['scenes_scanned']} 个`")
        lines.append("")
        lines.append("---")
        lines.append("")
        lines.append("## 一、六大字面量契约健康看板")
        lines.append("")
        lines.append("| 契约类别 (Category) | 严重错误 (ERROR) | 告警/建议 (WARNING) | 待收敛 (INFO) | 合计条目 | 健康状态 |")
        lines.append("|:---|:---:|:---:|:---:|:---:|:---:|")

        cat_names = {
            "resource_path": "1. 资源路径契约 (Resource Path)",
            "node_path": "2. 节点路径契约 (Node Path)",
            "reflection": "3. 动态反射契约 (Reflection)",
            "anim_track": "4. 动画轨道契约 (Anim Track)",
            "dict_key": "5. 中文字典键契约 (Dict Key)",
            "runtime_manifest": "6. 运行时 manifest 门禁 (Runtime Manifest)",
        }

        for cat_key, cat_label in cat_names.items():
            err_c = sum(1 for f in self.findings if f.category == cat_key and f.severity == "ERROR")
            warn_c = sum(1 for f in self.findings if f.category == cat_key and f.severity == "WARNING")
            info_c = sum(1 for f in self.findings if f.category == cat_key and f.severity == "INFO")
            tot_c = err_c + warn_c + info_c
            status = "🔴 待修复" if err_c > 0 else ("🟡 需关注" if warn_c > 0 else "🟢 契约完好")
            lines.append(f"| **{cat_label}** | **{err_c}** | {warn_c} | {info_c} | **{tot_c}** | {status} |")

        lines.append("")
        lines.append(f"**总计缺陷与待收敛项**: `{stats['total_findings']} 个`（ERROR: `{stats['by_severity']['ERROR']}` / WARNING: `{stats['by_severity']['WARNING']}` / INFO: `{stats['by_severity']['INFO']}`）")
        lines.append("")
        lines.append("---")
        lines.append("")

        # 逐项清单
        for cat_key, cat_label in cat_names.items():
            cat_findings = [f for f in self.findings if f.category == cat_key]
            lines.append(f"## 二、{cat_label} 详细清单 ({len(cat_findings)} 条)")
            lines.append("")
            if not cat_findings:
                lines.append("`[√] 未检测到任何契约违规项，该类别 100% 达成合规！`\n")
                continue

            # 按严重程度排序
            cat_findings.sort(key=lambda x: (0 if x.severity == "ERROR" else 1 if x.severity == "WARNING" else 2))

            lines.append("| 严重等级 | 文件位置 | 字面量内容 | 诊断原因与修复建议 |")
            lines.append("|:---:|:---|:---|:---|")
            # 限制单类别展示条目，避免超长
            for f in cat_findings[:40]:
                loc = f"`{f.file_path}:{f.line}`" if f.line else f"`{f.file_path}`"
                fix_text = f" → **建议**: `{f.suggested_fix}`" if f.suggested_fix else ""
                lines.append(f"| `{f.severity}` | {loc} | `{f.literal}` | {f.message}{fix_text} |")

            if len(cat_findings) > 40:
                lines.append(f"\n> *(剩余 {len(cat_findings) - 40} 条已收入机读 JSON 报告 docs/reports/contract_audit.json)*\n")
            lines.append("")

        lines.append("---")
        lines.append("")
        lines.append("## 三、Phase 8-2 推荐修复执行优先级")
        lines.append("")
        lines.append("1. **高危阻断项 (ERROR)**：优先清零 `resource_path` 大小写失配与 `node_path` 大小写失配，防止运行时抛出 `Node not found` 与 `Resource not found` 崩溃；")
        lines.append("2. **动画方法轨道 (anim_track)**：对齐动画帧 method 轨道大小写，消除方法静默不调用；")
        lines.append("3. **字典键收敛 (dict_key)**：分批将已收录于 `DataKeys` 的中文硬编码键迁移为强类型常量引用。")
        lines.append("")

        with open(self.md_output, "w", encoding="utf-8") as mf:
            mf.write("\n".join(lines))


def run_runtime_manifest_self_test() -> bool:
    """运行时 manifest 门禁负向自测：坏样本必须拦截，好样本必须放行。"""
    print("[*] 运行时 manifest 门禁负向自测...")
    bad_samples = {
        "字面量 manifest.json + FileAccess": (
            'const ATLAS := "res://Art/monster/3001/atlas/manifest.json"\n'
            "var f := FileAccess.get_file_as_string(ATLAS)\n"
        ),
        "atlas_manifest 变量 + JSON 解析": (
            'var atlas_manifest := ""\n'
            "func load_it() -> void:\n"
            "\tvar data: Variant = JSON.parse_string(FileAccess.get_file_as_string(atlas_manifest))\n"
        ),
        "_manifest_path() 间接加载": (
            "func _manifest_path() -> String:\n"
            '\treturn "res://Art/x/atlas/manifest.json"\n'
            "var f := FileAccess.open(_manifest_path(), FileAccess.READ)\n"
        ),
        "NorthOriginalData.manifest 间接加载": (
            "var f := FileAccess.get_file_as_string(NorthOriginalData.manifest(3353))\n"
        ),
    }
    good_samples = {
        "标准 SpriteFrames 资源加载": (
            'const FRAMES := "res://Art/x/atlas/swf_png_3001_frames.tres"\n'
            "var f := FileAccess.get_file_as_string(FRAMES)\n"
        ),
        "纯注释中的 manifest 标识": "# manifest.json legacy note\nvar value := 1\n",
        "注释同时含 IO 与 manifest": "# FileAccess.get_file_as_string(manifest.json)\n# atlas_manifest\n",
        "无运行时 IO": 'var manifest_note := "build-time only"\n',
    }

    passed = True
    for label, content in bad_samples.items():
        line, pattern = ContractScanner.runtime_manifest_violation(content)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, content in good_samples.items():
        line, pattern = ContractScanner.runtime_manifest_violation(content)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")

    if passed:
        print(f"\n[SUCCESS] 运行时 manifest 门禁负向自测通过 "
              f"(坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 运行时 manifest 门禁负向自测失败！", file=sys.stderr)
    return passed


def main():
    parser = argparse.ArgumentParser(description="BHYH 全工程字面量契约全量扫描器 (Phase 8-1)")
    parser.add_argument("--project-dir", default="source", help="工程目标根目录")
    parser.add_argument("--md-output", default="docs/reports/contract_audit.md", help="Markdown 报告输出路径")
    parser.add_argument("--json-output", default="docs/reports/contract_audit.json", help="JSON 报告输出路径")
    parser.add_argument("--whitelist", default="scripts/contract_whitelist.json", help="白名单配置文件路径")
    parser.add_argument("--fail-on-error", action="store_true", help="若存在 ERROR 级缺陷返回退出码 1")
    parser.add_argument("--self-test", action="store_true", help="运行时 manifest 门禁负向自测（不执行全量扫描、不写报告）")

    args = parser.parse_args()

    if args.self_test:
        sys.exit(0 if run_runtime_manifest_self_test() else 1)

    if not os.path.isdir(args.project_dir):
        print(f"[FAIL] 工程目录不存在: {args.project_dir}", file=sys.stderr)
        sys.exit(2)

    scanner = ContractScanner(
        project_dir=args.project_dir,
        whitelist_path=args.whitelist,
        md_output=args.md_output,
        json_output=args.json_output
    )

    duration = scanner.run_all_checks()

    if not scanner.script_files and not scanner.scene_files:
        print(f"[FAIL] 未在 {args.project_dir} 下发现任何可扫描脚本或场景，拒绝生成空报告。", file=sys.stderr)
        sys.exit(2)

    scanner.generate_reports(duration)

    # 错误退出码控制
    error_count = sum(1 for f in scanner.findings if f.severity == "ERROR")
    if args.fail_on_error and error_count > 0:
        print(f"\n[FAIL] 契约扫描未通过: 存在 {error_count} 处 ERROR 级契约阻断错误！", file=sys.stderr)
        sys.exit(1)

    print(f"\n[SUCCESS] Phase 8-1 契约扫描完成，总计发现 ERROR={error_count} 个")
    sys.exit(0)


if __name__ == "__main__":
    main()

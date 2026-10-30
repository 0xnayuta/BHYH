#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/contract_scan.py

BHYH 全工程字面量契约全量扫描器 (Phase 8-1)
====================================================================
用于全量扫描并比对工程中十七类契约与真源的一致性：
1. 资源路径契约 (Resource Path Contract): res:// 路径存在性与严格大小写敏感校验
2. 节点路径契约 (Node Path Contract): get_node/NodePath/$ 节点树层级与大小写敏感校验
3. 动态反射契约 (Reflection Contract): call/has_method/set/get/connect 字符串与符号声明比对
4. 动画轨道契约 (Animation Track Contract): method 轨道与 value 属性轨道的方法与节点大小写比对
5. 字典键契约 (Dictionary Key Contract): 中文字典键字面量与 DataKeys 常量契约映射比对
6. 运行时 manifest 门禁 (Runtime Manifest Gate): 新增代码禁止在运行时直接加载 atlas manifest
7. AtlasMetadata 边界门禁 (Atlas Metadata Boundary): 禁止旧入口、直接 .data 读取与 source_masks 覆盖
8. 关卡预载边界门禁 (Preload Boundary): 加载页禁止目录扫描或依赖清单解析
9. 场景入口边界门禁 (Scene Entry Boundary): 业务代码禁止绕过 Global.change_scene
10. 加载页私有缓存门禁 (Load Cache Boundary): 加载页只能使用窄交接 API
11. 池/UI 清理入口门禁 (Pool/UI Boundary): 未登记清理入口阻断
12. 档案边界门禁 (Archive Boundary): 禁止业务拼接档案路径或绕过 request_save 直接读写档
13. 槽位边界门禁 (Slot Boundary): 禁止业务硬编码 /root 单例，禁止重新引入全局视图交换
14. 面板操作者门禁 (Panel Operator): 面板域脚本必须按槽位解析 PlayerData/RoleProp
15. 共享账本与快照互斥门禁 (Shared Ledger): 共享键登记、2P 剥离与快照互斥必须同源
16. Phase 17 边界门禁 (Phase 17 Boundary): 结算一次、命令快照、表现层不写档与试点路径预算
17. 输入写入边界门禁 (Input Boundary): 输入读取行不得夹带 PlayerData 或 request_save
18. 运行状态边界门禁 (Run State Boundary): 禁止重新直写已迁移的运行状态字段或调用已删除的工具入口
19. HUD/面板只读门禁 (HUD Panel Boundary): HUD 与面板域禁止直接档案 IO 与 PlayerData 字典直写

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
    ATLAS_BOUNDARY_ALLOWLIST = {
        "Script/atlas/atlas_metadata.gd",
        "Script/atlas/atlas_metadata_view.gd",
    }
    PRELOAD_BOUNDARY_FILE = "Scene/other_scene/load_scene.gd"
    PRELOAD_BOUNDARY_PATTERNS = (
        "DirAccess.",
        "ResourceLoader.get_dependencies(",
        "FileAccess.",
        "JSON.parse",
        "manifest",
    )
    SCENE_ENTRY_BOUNDARY_FILES = (
        "global.gd",
        "Script/runtime/scene_flow.gd",
    )
    SCENE_ENTRY_BYPASS_PATTERNS = (
        "change_scene_to_file(",
        "change_scene_to_packed(",
    )
    LOAD_CACHE_BOUNDARY_FILE = "Scene/other_scene/load_scene.gd"
    LOAD_CACHE_PRIVATE_PATTERNS = (
        "Global._resource_cache",
        "Global._sprite_frames_cache",
        "Global._audio_cache",
        "Global._texture_cache",
        "Global._monster_scene_cache",
        "Global._cache_threaded_resource",
        "Global._track_level_resource",
        "Global._level_resource_lease",
    )
    POOL_UI_PRIVATE_PATTERNS = (
        "Global._clear_runtime_pools",
        "Global._pool_data",
        "Global.get_ui_runtime()._transient_ui_instances",
        "Global.get_ui_runtime()._ui_runtime_instance_paths",
        "Global.get_ui_runtime()._ui_runtime_instance_counts",
        "Global.get_ui_runtime().release_ui_runtime_cache",
    )
    # 运行状态边界（W8 S7/S8）：已删除的旧字段/工具入口禁止回归。
    RUNTIME_STATE_RETIRED_CALLS = (
        "Global.get_ancestor(",
        "Global.get_position_between(",
        "Global.get_dis_betweem(",
        "Global.get_clean_name(",
        "Global.get_all_item_num(",
        "Global.load_item_icon(",
        "Global.add_all_item_num(",
    )
    RUNTIME_STATE_ASSIGN_RE = re.compile(
        r"\bGlobal\.(?:current_level|llbt_level|four_swords_endless_mode|three_prince_endless_mode"
        r"|sss_lendless_mode|constellation_endless_mode|selected_eight_immortal_id"
        r"|is_ice|is_stun|is_mpo|is_poision|is_bleed|is_fire|is_speed_down|is_eye_fix|is_dead_link"
        r"|_current_role_body_texture_path|_current_role_equipment_texture_path)\b\s*(?:=|\+=|-=|\*=|/=)"
    )
    RUNTIME_STATE_TOTAL_RE = re.compile(r"\bGlobal\.total_[A-Za-z0-9_]*\b")

    ARCHIVE_PATH_LITERAL = "user://MyAr_"
    ARCHIVE_PATH_LITERAL_ALLOWLIST = {
        "Scene/other_scene/bacis_ar_button.gd",
        "Script/archive_interface/read_archive_interface.gd",
        "Script/memory_class/memory_class.gd",
    }
    ARCHIVE_ENTRY_ALLOWLIST = {
        "load_game": {"Scene/other_scene/bacis_ar_button.gd", "Script/memory_class/memory_class.gd"},
        "save_game": {"Script/memory_class/memory_class.gd"},
        "safe_write_archive": {
            "Script/archive_interface/read_archive_interface.gd",
            "Script/memory_class/memory_class.gd",
        },
    }
    ARCHIVE_ENTRY_CALL_RE = re.compile(r"(?<![A-Za-z0-9_])(load_game|save_game|safe_write_archive)\s*\(")
    SLOT_ROOT_PATTERNS = (
        'get_node("/root/PlayerData")',
        'get_node("/root/RoleProp")',
        'get_node_or_null("/root/PlayerData")',
        'get_node_or_null("/root/RoleProp")',
    )
    SLOT_ROOT_ALLOWLIST = {
        "Script/base/base_role_properies.gd",
        "Script/memory_class/player_data.gd",
    }
    VIEW_SWAP_CALL_RE = re.compile(r"(?:func\s+)?(suspend_player_view|resume_player_view)\s*\(")
    PANEL_OPERATOR_DIRS = (
        "Script/back_pack/",
        "Script/skill/",
        "Script/pet/",
        "Script/mount/",
        "Script/ldl/",
    )
    PANEL_OPERATOR_OPS = ("PlayerData", "RoleProp")
    COOP_SESSION_FILE = "Script/coop/local_coop.gd"
    COOP_SESSION_REQUIRED_TOKENS = (
        "func shared_keys()",
        "for key: String in shared_keys()",
        "is_save_snapshot_in_progress",
    )
    # 共享键族登记：四个背包键由 BAG_KEYS 统一登记，其余为显式族名。
    SHARED_LEDGER_REQUIRED_TOKENS = (
        "BAG_KEYS",
        "被动技能",
        "MAIN_SWORD_ARRAY_KEY",
        "MAIN_SWORD_ARRAY_LEVEL_KEY",
        "炼体",
        "WANLING_CATALOG_LEVELS_KEY",
        "coin_num",
    )

    # Phase 17-7：保存一次、命令原子性、表现层不写档、试点路径预算。
    PHASE17_SETTLEMENT_FILES = {
        "Script/level/victory.gd",
        "Script/level/defeat.gd",
    }
    PHASE17_COMMAND_FILES = {
        "Script/shop/shop_purchase_command.gd",
        "Script/other_menu/reward_grant_command.gd",
    }
    PHASE17_PRESENTATION_FILES = {
        "Scene/other_scene/transmogtified_box.gd",
        "Scene/other_scene/reward_interface.gd",
    }
    PHASE17_ROOT_FORBIDDEN_FILES = {
        "Script/base/base_role.gd",
        "Script/base/base_magic_weapon.gd",
        "Script/pet/pet_interface.gd",
        "Script/skill/zd_skill.gd",
        "Scene/other_scene/skill_icon.gd",
    }
    PHASE17_DEEP_PATH_BUDGETS = {
        "Script/pet/pet_interface.gd": 0,
        "Script/skill/zd_skill.gd": 0,
        "Script/base/base_role.gd": 0,
        "Script/base/base_magic_weapon.gd": 0,
    }
    PHASE17_DEEP_PATH_RE = re.compile(r'get_node(?:_or_null)?\("([^"]*)"')
    # 20-3A：HUD/面板只读域——禁止直接档案 IO 与 PlayerData 字典直写。
    HUD_PANEL_FILES = {
        "Scene/other_scene/skill_icon.gd",
        "Script/pet/pet_interface.gd",
        "Script/base/base_role.gd",
    }
    HUD_PANEL_ARCHIVE_IO = (
        "MemoryClass.save_game(",
        "MemoryClass.safe_write_archive(",
        "MemoryClass.load_game(",
    )
    # 19-4C：输入读取行不得同时操作档案或保存。
    INPUT_READ_PATTERN = re.compile(
        r"\b(?:Input|PlayerInput)\.(?:is_action_pressed|is_action_just_pressed|is_action_just_released|"
        r"get_axis|get_vector|is_physical_key_pressed|is_key_pressed)\s*\("
    )
    INPUT_BOUNDARY_ALLOWLIST: Set[str] = set()
    ATLAS_BOUNDARY_LEGACY_PATTERNS = (
        "AtlasMetadataStore.data_for",
        "AtlasMetadataStore.validate_path",
        "AtlasMetadataStore.clear_cache",
    )
    ATLAS_DATA_ACCESS_PATTERN = re.compile(r"\b(?:AtlasMetadata|metadata|atlas_metadata|resource)\b[^\n]*\.\s*data\b")
    ATLAS_SOURCE_MASKS_PATTERN = re.compile(r"\bsource_masks\b")

    @classmethod
    def atlas_boundary_violation(cls, content: str, rel_path: str):
        """返回 (行号, 命中标识)；无违规返回 (0, "")。

        仅检查代码行，注释行除外；View/资源自身允许读取 `.data`。
        """
        allow_data = rel_path in cls.ATLAS_BOUNDARY_ALLOWLIST
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            for pattern in cls.ATLAS_BOUNDARY_LEGACY_PATTERNS:
                if pattern in clean:
                    return (lineno, pattern)
            if not allow_data and cls.ATLAS_DATA_ACCESS_PATTERN.search(clean):
                return (lineno, ".data")
            if cls.ATLAS_SOURCE_MASKS_PATTERN.search(clean):
                return (lineno, "source_masks")
        return (0, "")

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

    @classmethod
    def preload_boundary_violation(cls, content: str):
        """加载页禁止目录扫描/依赖清单解析；返回 (行号, 命中标识)。"""
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            for pattern in cls.PRELOAD_BOUNDARY_PATTERNS:
                if pattern in clean:
                    return (lineno, pattern)
        return (0, "")


    @classmethod
    def scene_entry_boundary_violation(cls, content: str, rel_path: str):
        """仅 Global 允许直接调用 change_scene_to_*；返回 (行号, 命中标识)。"""
        if rel_path.startswith("addons/") or rel_path in cls.SCENE_ENTRY_BOUNDARY_FILES:
            return (0, "")
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            for pattern in cls.SCENE_ENTRY_BYPASS_PATTERNS:
                if pattern in clean:
                    return (lineno, pattern)
        return (0, "")

    @classmethod
    def load_cache_boundary_violation(cls, content: str, rel_path: str):
        """加载页只能通过窄交接 API 读写缓存；返回 (行号, 命中标识)。"""
        if rel_path != cls.LOAD_CACHE_BOUNDARY_FILE:
            return (0, "")
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            for pattern in cls.LOAD_CACHE_PRIVATE_PATTERNS:
                if pattern in clean:
                    return (lineno, pattern)
        return (0, "")

    @classmethod
    def pool_ui_boundary_violation(cls, content: str, rel_path: str):
        """池/UI 清理只允许 Global 或已登记的 UI 调用方；返回 (行号, 命中标识)。"""
        if rel_path.startswith("addons/") or rel_path == "global.gd":
            return (0, "")
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            if "Global.get_ui_runtime().cleanup_transient_ui" in clean:
                return (lineno, "Global.get_ui_runtime().cleanup_transient_ui")
            for pattern in cls.POOL_UI_PRIVATE_PATTERNS:
                if pattern in clean:
                    return (lineno, pattern)
        return (0, "")

    @classmethod
    def run_state_boundary_violation(cls, content: str, rel_path: str):
        """运行状态边界：旧字段直写与已删除工具入口禁止回归；返回 (行号, 命中标识)。"""
        if rel_path.startswith("addons/"):
            return (0, "")
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            for pattern in cls.RUNTIME_STATE_RETIRED_CALLS:
                if pattern in clean:
                    return (lineno, pattern)
            assign = cls.RUNTIME_STATE_ASSIGN_RE.search(clean)
            if assign:
                return (lineno, assign.group(0).strip())
            total = cls.RUNTIME_STATE_TOTAL_RE.search(clean)
            if total:
                return (lineno, total.group(0))
        return (0, "")

    @classmethod
    def archive_boundary_violation(cls, content: str, rel_path: str):
        """档案边界：禁止业务拼接档案路径或绕过 request_save；返回 (行号, 命中标识)。"""
        if rel_path.startswith("addons/"):
            return (0, "")
        allow_literal = rel_path in cls.ARCHIVE_PATH_LITERAL_ALLOWLIST
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            if not allow_literal and cls.ARCHIVE_PATH_LITERAL in clean:
                return (lineno, cls.ARCHIVE_PATH_LITERAL)
            for match in cls.ARCHIVE_ENTRY_CALL_RE.finditer(clean):
                entry = match.group(1)
                if rel_path not in cls.ARCHIVE_ENTRY_ALLOWLIST.get(entry, set()):
                    return (lineno, entry + "(")
        return (0, "")

    @classmethod
    def slot_boundary_violation(cls, content: str, rel_path: str):
        """槽位边界：禁止硬编码 /root 单例与重新引入全局视图交换；返回 (行号, 命中标识)。"""
        if rel_path.startswith("addons/"):
            return (0, "")
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            for pattern in cls.SLOT_ROOT_PATTERNS:
                if pattern in clean and rel_path not in cls.SLOT_ROOT_ALLOWLIST:
                    return (lineno, pattern)
            view_swap = cls.VIEW_SWAP_CALL_RE.search(clean)
            if view_swap:
                return (lineno, view_swap.group(1))
        return (0, "")

    @classmethod
    def shared_ledger_boundary_violation(cls, content: str, rel_path: str):
        """共享账本与快照互斥：登记、剥离与互斥入口必须同源；返回 (行号, 命中标识)。"""
        if rel_path != cls.COOP_SESSION_FILE:
            return (0, "")
        for token in cls.COOP_SESSION_REQUIRED_TOKENS:
            if token not in content:
                return (1, token)
        start = content.find("func shared_keys()")
        end = content.find("\nfunc ", start + 1)
        body = content[start:end if end != -1 else len(content)]
        for key in cls.SHARED_LEDGER_REQUIRED_TOKENS:
            if key not in body:
                return (1, key)
        return (0, "")

    def _operator_declaration_index(self):
        """构建 extends 链与显式操作者声明索引（惰性，仅面板操作者门禁使用）。"""
        if hasattr(self, "_operator_index"):
            return self._operator_index
        extends_map: Dict[str, str] = {}
        declares: Dict[str, Set[str]] = {}
        op_re = {
            "PlayerData": re.compile(r"^\s*var\s+PlayerData\s*:\s*PlayerDataStore", re.M),
            "RoleProp": re.compile(r"^\s*var\s+RoleProp\s*:\s*BaseRoleProperties", re.M),
        }
        extends_re = re.compile(r"^\s*extends\s+(.+?)\s*$", re.M)
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                text = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            match = extends_re.search(text)
            extends_map[rel_p] = match.group(1).strip().strip('"') if match else ""
            declares[rel_p] = {op for op, pattern in op_re.items() if pattern.search(text)}
        self._operator_index = (extends_map, declares)
        return self._operator_index

    def _resolves_operator(self, rel_path: str, operator: str, depth: int = 0) -> bool:
        extends_map, declares = self._operator_declaration_index()
        if depth > 8 or rel_path not in extends_map:
            return False
        if operator in declares.get(rel_path, set()):
            return True
        target = extends_map.get(rel_path, "")
        if not target:
            return False
        target_rel = ""
        if target.startswith("res://"):
            target_rel = target.replace("res://", "", 1)
        elif target in self.symbol_index.class_names:
            target_rel = self.symbol_index.class_names[target].replace("res://", "", 1)
        if not target_rel:
            return False
        return self._resolves_operator(target_rel, operator, depth + 1)

    @classmethod
    def panel_operator_usage(cls, content: str):
        """返回首个未带前缀的 PlayerData/RoleProp 使用位置 (行号, 操作者)。"""
        usage_re = {
            "PlayerData": re.compile(r"(?<![A-Za-z0-9_.])PlayerData\b"),
            "RoleProp": re.compile(r"(?<![A-Za-z0-9_.])RoleProp\b"),
        }
        string_re = re.compile(r"\"[^\"]*\"|'[^']*'")
        for operator, pattern in usage_re.items():
            for lineno, line in enumerate(content.splitlines(), 1):
                clean = string_re.sub('""', line.split("#", 1)[0])
                if clean.strip() and pattern.search(clean):
                    return (lineno, operator)
        return (0, "")

    def scan_panel_operator(self):
        print(f"[*] 扫描面板操作者绑定门禁 (Phase 16-5)...")
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            if not rel_p.startswith(self.PANEL_OPERATOR_DIRS):
                continue
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            hit_line, hit_op = self.panel_operator_usage(content)
            if hit_line and self._resolves_operator(rel_p, hit_op):
                hit_line, hit_op = 0, ""
            if not hit_line:
                continue
            finding = ContractFinding(
                category="panel_operator",
                severity="ERROR",
                file_path=rel_p,
                line=hit_line,
                literal=hit_op,
                message="面板域脚本使用 PlayerData/RoleProp 但未按槽位声明操作者",
                suggested_fix="声明 var PlayerData: PlayerDataStore / var RoleProp: BaseRoleProperties，getter 走 LocalCoop.data_for/props_for",
                rule_id="PANEL_OPERATOR_UNBOUND",
            )
            if not self.whitelist.is_suppressed(finding):
                self.findings.append(finding)

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

    def scan_atlas_boundary(self):
        print(f"[*] 扫描 AtlasMetadata 运行时边界门禁...")
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            hit_line, hit_pattern = self.atlas_boundary_violation(content, rel_p)
            if hit_line == 0:
                continue
            finding = ContractFinding(
                category="atlas_boundary",
                severity="ERROR",
                file_path=rel_p,
                line=hit_line,
                literal=hit_pattern,
                message="禁止旧 AtlasMetadataStore 入口、直接 .data 读取或 source_masks 覆盖",
                suggested_fix="改用 AtlasMetadataStore.view_for() 与其只读值查询",
                rule_id="ATLAS_BOUNDARY_FORBIDDEN",
            )
            if not self.whitelist.is_suppressed(finding):
                self.findings.append(finding)

    def scan_preload_boundary(self):
        print(f"[*] 扫描关卡预载清单边界门禁...")
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            if rel_p != self.PRELOAD_BOUNDARY_FILE:
                continue
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            hit_line, hit_pattern = self.preload_boundary_violation(content)
            if hit_line == 0:
                continue
            finding = ContractFinding(
                category="preload_boundary",
                severity="ERROR",
                file_path=rel_p,
                line=hit_line,
                literal=hit_pattern,
                message="加载页禁止目录扫描或依赖清单解析",
                suggested_fix="改读 LevelPreloadStore/构建期 Catalog，构建期展开由转换器负责",
                rule_id="PRELOAD_BOUNDARY_FORBIDDEN",
            )
            if not self.whitelist.is_suppressed(finding):
                self.findings.append(finding)

    def scan_scene_entry_boundary(self):
        print(f"[*] 扫描场景入口边界门禁...")
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            hit_line, hit_pattern = self.scene_entry_boundary_violation(content, rel_p)
            if hit_line == 0:
                continue
            finding = ContractFinding(
                category="scene_entry",
                severity="ERROR",
                file_path=rel_p,
                line=hit_line,
                literal=hit_pattern,
                message="业务代码禁止绕过 Global.change_scene 直接切换场景",
                suggested_fix="改用 Global.change_scene(target, force_loading_screen)",
                rule_id="SCENE_ENTRY_BYPASS",
            )
            if not self.whitelist.is_suppressed(finding):
                self.findings.append(finding)

    def scan_load_cache_boundary(self):
        print(f"[*] 扫描加载页私有缓存访问门禁...")
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            hit_line, hit_pattern = self.load_cache_boundary_violation(content, rel_p)
            if hit_line == 0:
                continue
            finding = ContractFinding(
                category="load_cache",
                severity="ERROR",
                file_path=rel_p,
                line=hit_line,
                literal=hit_pattern,
                message="加载页禁止直接访问 Global 私有缓存/租约字段",
                suggested_fix="改用 is_resource_cached/get_cached_packed_scene/handoff_loaded_resource",
                rule_id="LOAD_CACHE_PRIVATE_ACCESS",
            )
            if not self.whitelist.is_suppressed(finding):
                self.findings.append(finding)

    @classmethod
    def hud_panel_boundary_violation(cls, content: str, rel_path: str):
        """HUD/面板只读：禁止直接档案 IO 与 PlayerData 字典直写；保存只经 request_save 入口。"""
        if rel_path not in cls.HUD_PANEL_FILES:
            return (0, "")
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not clean.strip():
                continue
            for token in cls.HUD_PANEL_ARCHIVE_IO:
                if token in clean:
                    return (lineno, token)
            if "PlayerData.player_data" in clean and re.search(r"\]\s*(?<![=<>!])=(?!=)", clean):
                return (lineno, "PlayerData.player_data[...] =")
            if re.search(
                r"PlayerData\.player_data\.[A-Za-z_\u4e00-\u9fff]+\s*(?<![=<>!])=(?!=)", clean
            ):
                return (lineno, "PlayerData.player_data.attr =")
        return (0, "")

    @classmethod
    def phase17_boundary_violation(cls, content: str, rel_path: str):
        """Phase 17 边界：保存一次、命令快照、表现层不写档、试点路径预算。"""
        if rel_path in cls.PHASE17_SETTLEMENT_FILES:
            if "extends LevelSettlement" not in content:
                return (1, "extends LevelSettlement")
            if "MemoryClass.request_save" in content:
                return (1, "MemoryClass.request_save")
        if rel_path in cls.PHASE17_COMMAND_FILES:
            for token in ("snapshot_state(", "restore_state("):
                if token not in content:
                    return (1, token)
        if rel_path in cls.PHASE17_PRESENTATION_FILES:
            for lineno, line in enumerate(content.splitlines(), 1):
                clean = line.split("#", 1)[0]
                if re.search(r"PlayerData\.player_data\s*\[[^\n=]*\]\s*=", clean):
                    return (lineno, "PlayerData.player_data[...] =")
                if re.search(r"PlayerData\.player_data\.[A-Za-z_\u4e00-\u9fff]+\s*=", clean):
                    return (lineno, "PlayerData.player_data.attr =")
                if "MemoryClass.request_save" in clean:
                    return (lineno, "MemoryClass.request_save")
        if rel_path in cls.PHASE17_ROOT_FORBIDDEN_FILES and '"/root/' in content:
            return (1, '"/root/')
        if rel_path in cls.PHASE17_DEEP_PATH_BUDGETS:
            count = 0
            for line in content.splitlines():
                for match in cls.PHASE17_DEEP_PATH_RE.finditer(line):
                    path = match.group(1)
                    if "/" in path or path.startswith("/root"):
                        count += 1
            budget = cls.PHASE17_DEEP_PATH_BUDGETS[rel_path]
            if count > budget:
                return (1, f"deep_paths:{count}>{budget}")
        return (0, "")

    def scan_hud_panel_boundary(self):
        print(f"[*] 扫描 HUD/面板只读门禁 (Phase 20-3A)...")
        self._scan_rule(
            category="hud_panel_boundary",
            violation=self.hud_panel_boundary_violation,
            message="HUD/面板域只读：禁止直接档案 IO 与 PlayerData 字典直写",
            suggested_fix="保存改调 Global.request_save_with_feedback 或 MemoryClass.request_save；装备/技能变更走 PlayerData 的写入口方法",
            rule_id="HUD_PANEL_WRITE_FORBIDDEN",
        )

    def scan_phase17_boundary(self):
        print("[*] 扫描 Phase 17 边界门禁 (保存一次/命令原子性/表现层/路径预算)...")
        self._scan_rule(
            category="phase17_boundary",
            violation=self.phase17_boundary_violation,
            message="Phase 17 边界回退：结算重复保存、命令缺少快照、表现层直接写档或试点深层路径超预算",
            suggested_fix="结算改用 LevelSettlement；命令使用 snapshot_state/restore_state；表现层调用命令；路径预算见 module_api_matrix.md",
            rule_id="PHASE17_BOUNDARY_FORBIDDEN",
        )

    @classmethod
    def input_boundary_violation(cls, content: str, rel_path: str):
        """19-4C：输入读取行不得同时出现 PlayerData 或 request_save。"""
        if rel_path in cls.INPUT_BOUNDARY_ALLOWLIST:
            return (0, "")
        for lineno, line in enumerate(content.splitlines(), 1):
            clean = line.split("#", 1)[0]
            if not cls.INPUT_READ_PATTERN.search(clean):
                continue
            if "PlayerData" in clean:
                return (lineno, "input_read_with_PlayerData")
            if "request_save" in clean:
                return (lineno, "input_read_with_request_save")
        return (0, "")

    def scan_input_boundary(self):
        print("[*] 扫描输入写入边界门禁 (输入读取行禁止夹带 PlayerData/request_save)...")
        self._scan_rule(
            category="input_boundary",
            violation=self.input_boundary_violation,
            message="输入读取与档案/保存混写：输入处理不得在同一行读取 PlayerData 或调用 request_save",
            suggested_fix="先由 LocalCoop/命令解析槽位与档案；输入层只读取动作，不直接写档",
            rule_id="INPUT_BOUNDARY_STATE_WRITE",
        )

    def scan_pool_ui_boundary(self):
        print(f"[*] 扫描池/UI 清理入口登记门禁...")
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            hit_line, hit_pattern = self.pool_ui_boundary_violation(content, rel_p)
            if hit_line == 0:
                continue
            finding = ContractFinding(
                category="pool_ui",
                severity="ERROR",
                file_path=rel_p,
                line=hit_line,
                literal=hit_pattern,
                message="池/UI 清理入口未登记：只允许 Global 或已登记的 UI 调用方",
                suggested_fix="改用 Global.change_scene；临时 UI 由工厂 register_transient_ui 登记，业务不得直接调用 UiRuntime.cleanup_transient_ui",
                rule_id="POOL_UI_CLEANUP_UNREGISTERED",
            )
            if not self.whitelist.is_suppressed(finding):
                self.findings.append(finding)

    def scan_run_state_boundary(self):
        print(f"[*] 扫描运行状态边界门禁 (Phase 20-1B W8 S7/S8)...")
        self._scan_rule(
            category="run_state_boundary",
            violation=self.run_state_boundary_violation,
            message="运行状态与无状态工具已迁移：禁止重新直写 Global 旧字段或调用已删除的 Global 工具入口",
            suggested_fix="关卡名/塔层/统计/无尽模式改走 Global.get_run_context() 或对应 accessor；祖先与向量工具用 NodeUtils，品质名与随机条目用 ItemUtils",
            rule_id="RUN_STATE_RETIRED_ENTRY",
        )

    def scan_archive_boundary(self):
        print(f"[*] 扫描档案边界门禁 (Phase 16-2/16-3)...")
        self._scan_rule(
            category="archive_boundary",
            violation=self.archive_boundary_violation,
            message="业务代码禁止拼接档案路径或绕过 MemoryClass.request_save 直接读写档",
            suggested_fix="改用 MemoryClass.request_save/request_background_save 与 Global 会话查询；路径解析只留在持久化边界",
            rule_id="ARCHIVE_BOUNDARY_FORBIDDEN",
        )

    def scan_slot_boundary(self):
        print(f"[*] 扫描槽位边界门禁 (Phase 16-4/16-5)...")
        self._scan_rule(
            category="slot_boundary",
            violation=self.slot_boundary_violation,
            message="业务代码禁止硬编码 /root/PlayerData、/root/RoleProp 或重新引入全局视图交换",
            suggested_fix="改用 LocalCoop.data_for/props_for 或 BaseObject/BaseRole 的槽位感知属性",
            rule_id="SLOT_BOUNDARY_FORBIDDEN",
        )

    def scan_shared_ledger_boundary(self):
        print(f"[*] 扫描共享账本与快照互斥门禁 (Phase 16-4/16-5)...")
        self._scan_rule(
            category="shared_ledger",
            violation=self.shared_ledger_boundary_violation,
            message="共享账本登记、2P 档案剥离与快照互斥入口必须同源",
            suggested_fix="在 LocalCoop.shared_keys() 登记共享键，并让 save_profile 与快照互斥读取同一登记",
            rule_id="SHARED_LEDGER_UNREGISTERED",
        )

    def _scan_rule(self, category, violation, message, suggested_fix, rule_id):
        for abs_p in self.script_files:
            rel_p = os.path.relpath(abs_p, self.project_dir).replace("\\", "/")
            try:
                content = open(abs_p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            hit_line, hit_pattern = violation(content, rel_p)
            if hit_line == 0:
                continue
            finding = ContractFinding(
                category=category,
                severity="ERROR",
                file_path=rel_p,
                line=hit_line,
                literal=hit_pattern,
                message=message,
                suggested_fix=suggested_fix,
                rule_id=rule_id,
            )
            if not self.whitelist.is_suppressed(finding):
                self.findings.append(finding)

    def run_all_checks(self):
        """执行完整十九类契约扫描流水线"""
        t0 = time.time()
        self.collect_project_files()
        self.build_indexes()

        self.scan_resource_paths()
        self.scan_node_paths()
        self.scan_reflection_contracts()
        self.scan_animation_tracks()
        self.scan_dict_keys()
        self.scan_runtime_manifest_loading()
        self.scan_atlas_boundary()
        self.scan_preload_boundary()
        self.scan_scene_entry_boundary()
        self.scan_load_cache_boundary()
        self.scan_pool_ui_boundary()
        self.scan_run_state_boundary()
        self.scan_archive_boundary()
        self.scan_slot_boundary()
        self.scan_panel_operator()
        self.scan_shared_ledger_boundary()
        self.scan_hud_panel_boundary()
        self.scan_phase17_boundary()
        self.scan_input_boundary()

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
        lines.append("## 一、十七类契约健康看板")
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
            "atlas_boundary": "7. AtlasMetadata 边界门禁 (Atlas Metadata Boundary)",
            "preload_boundary": "8. 关卡预载边界门禁 (Preload Boundary)",
            "scene_entry": "9. 场景入口边界门禁 (Scene Entry Boundary)",
            "load_cache": "10. 加载页私有缓存门禁 (Load Cache Boundary)",
            "pool_ui": "11. 池/UI 清理入口门禁 (Pool/UI Boundary)",
            "archive_boundary": "12. 档案边界门禁 (Archive Boundary)",
            "slot_boundary": "13. 槽位边界门禁 (Slot Boundary)",
            "panel_operator": "14. 面板操作者门禁 (Panel Operator)",
            "shared_ledger": "15. 共享账本登记门禁 (Shared Ledger)",
            "phase17_boundary": "16. Phase 17 边界门禁 (Phase 17 Boundary)",
            "input_boundary": "17. 输入写入边界门禁 (Input Boundary)",
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


def run_atlas_boundary_self_test() -> bool:
    """AtlasMetadata 边界门禁负向自测：旧入口、直接 data 与 source_masks 必须拦截。"""
    print("[*] AtlasMetadata 边界门禁负向自测...")
    scanner = ContractScanner.__new__(ContractScanner)
    bad_samples = {
        "旧 data_for 入口": ("var data := AtlasMetadataStore.data_for(path)\n", "Script/monster/sample.gd"),
        "旧 validate_path 入口": ("var errors := AtlasMetadataStore.validate_path(path)\n", "Script/monster/sample.gd"),
        "旧 clear_cache 入口": ("AtlasMetadataStore.clear_cache()\n", "Script/monster/sample.gd"),
        "直接 data 读取": ("var payload: Dictionary = metadata.data\n", "Script/monster/sample.gd"),
        "source_masks 覆盖": ("projectile.source_masks[sequence] = []\n", "Script/monster/sample.gd"),
    }
    good_samples = {
        "view_for 正式入口": ("var view := AtlasMetadataStore.view_for(path)\n", "Script/monster/sample.gd"),
        "注释中的旧入口": ("# AtlasMetadataStore.data_for(path) legacy note\nvar view := AtlasMetadataStore.view_for(path)\n", "Script/monster/sample.gd"),
        "View 内部 data 读取": ("_data = metadata.data\n", "Script/atlas/atlas_metadata_view.gd"),
        "source_masks_metadata 配置键": ('var key := "source_masks_metadata"\n', "Script/monster/sample.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.atlas_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.atlas_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] AtlasMetadata 边界门禁负向自测通过 "
              f"(坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] AtlasMetadata 边界门禁负向自测失败！", file=sys.stderr)
    return passed


def run_preload_boundary_self_test() -> bool:
    """关卡预载边界门禁负向自测：目录扫描/依赖清单解析必须拦截。"""
    print("[*] 关卡预载边界门禁负向自测...")
    bad_samples = {
        "目录扫描": "for file_name in DirAccess.get_files_at(dir_path):\n",
        "依赖清单解析": "for dependency in ResourceLoader.get_dependencies(path):\n",
        "文件读取": "var text := FileAccess.get_file_as_string(path)\n",
        "manifest 解析": "var data := JSON.parse_string(text)\n",
    }
    good_samples = {
        "Catalog 只读入口": "var ids := LevelPreloadStore.first_wave_ids(scene_path)\n",
        "资源存在性检查": "if ResourceLoader.exists(path):\n",
        "注释中的扫描说明": "# DirAccess.get_files_at 只允许构建期\n",
    }
    passed = True
    for label, content in bad_samples.items():
        line, pattern = ContractScanner.preload_boundary_violation(content)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, content in good_samples.items():
        line, pattern = ContractScanner.preload_boundary_violation(content)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] 关卡预载边界门禁负向自测通过 "
              f"(坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 关卡预载边界门禁负向自测失败！", file=sys.stderr)
    return passed


def run_scene_entry_boundary_self_test() -> bool:
    """场景入口边界自测：业务绕过必须拦截，Global 入口必须放行。"""
    print("[*] 场景入口边界门禁负向自测...")
    bad_samples = {
        "业务直接 change_scene_to_file": ("get_tree().change_scene_to_file(path)\n", "Script/level/sample.gd"),
        "业务直接 change_scene_to_packed": ("get_tree().change_scene_to_packed(scene)\n", "Script/main_menu/sample.gd"),
        "字符串前含缩进调用": ("\tget_tree().change_scene_to_file(path)\n", "Scene/other_scene/sample.gd"),
    }
    good_samples = {
        "Global 正式入口": ("Global.change_scene(path)\n", "Script/level/sample.gd"),
        "Global 自身低层实现": ("var err := tree.change_scene_to_file(path)\n", "global.gd"),
        "注释中的低层调用": ("# tree.change_scene_to_file(path) legacy note\n", "Script/level/sample.gd"),
        "SceneFlow 自身低层实现": ("var err := tree.change_scene_to_file(path)\n", "Script/runtime/scene_flow.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.scene_entry_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.scene_entry_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] 场景入口边界门禁自测通过 (坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 场景入口边界门禁自测失败！", file=sys.stderr)
    return passed


def run_load_cache_boundary_self_test() -> bool:
    """加载页私有缓存自测：私有字段必须拦截，窄交接 API 必须放行。"""
    print("[*] 加载页私有缓存门禁负向自测...")
    bad_samples = {
        "直接读 _resource_cache": ("var hit = Global._resource_cache.has(path)\n", "Scene/other_scene/load_scene.gd"),
        "直接写 _texture_cache": ("Global._texture_cache[path] = resource\n", "Scene/other_scene/load_scene.gd"),
        "直接调用私有写入": ("Global._cache_threaded_resource(path, resource)\n", "Scene/other_scene/load_scene.gd"),
    }
    good_samples = {
        "窄交接提交": ("Global.handoff_loaded_resource(path, resource, true)\n", "Scene/other_scene/load_scene.gd"),
        "其他文件访问约定 API": ("var hit = Global.is_resource_cached(path)\n", "Script/level/sample.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.load_cache_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.load_cache_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] 加载页私有缓存门禁自测通过 (坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 加载页私有缓存门禁自测失败！", file=sys.stderr)
    return passed


def run_pool_ui_boundary_self_test() -> bool:
    """池/UI 清理入口自测：业务直接调用与私有字段必须拦截。"""
    print("[*] 池/UI 清理入口门禁负向自测...")
    bad_samples = {
        "未登记 UI 清理": ("Global.get_ui_runtime().cleanup_transient_ui()\n", "Script/new_ui.gd"),
        "直接池清理": ("Global._clear_runtime_pools()\n", "Script/new_ui.gd"),
        "直接池数据访问": ("var pool = Global._pool_data[\"damage_text\"]\n", "Script/level/sample.gd"),
        "直接 UI 实例表访问": (
            "var count = Global.get_ui_runtime()._transient_ui_instances.size()\n",
            "Script/main_menu/new_menu.gd",
        ),
    }
    good_samples = {
        "Global 自身清理": ("_clear_runtime_pools()\n", "global.gd"),
        "注释中的私有入口": ("# Global._clear_runtime_pools() legacy note\n", "Script/new_ui.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.pool_ui_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.pool_ui_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] 池/UI 清理入口门禁自测通过 (坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 池/UI 清理入口门禁自测失败！", file=sys.stderr)
    return passed


def run_run_state_boundary_self_test() -> bool:
    """运行状态边界自测：旧字段直写与已删除工具入口必须拦截。"""
    print("[*] 运行状态边界门禁负向自测...")
    bad_samples = {
        "旧关卡名直写": ("Global.current_level = \"花果山\"\n", "Script/level/sample.gd"),
        "旧塔层自增": ("Global.llbt_level += 1\n", "Script/level/level_llbt.gd"),
        "统计字段自增": ("Global.total_role_hit += 5\n", "Script/base/base_monster.gd"),
        "统计字段读取": ("var v = Global.total_cure_hp\n", "Scene/other_scene/after_level_end.gd"),
        "无尽模式直写": ("Global.sss_lendless_mode = false\n", "Script/level/level_sssl.gd"),
        "八仙选择直写": ("Global.selected_eight_immortal_id = 3\n", "Scene/other_scene/level_info.gd"),
        "死减益标志直写": ("Global.is_stun = false\n", "Script/main_menu/map_1.gd"),
        "旧祖先工具": ("var a = Global.get_ancestor(node, 2)\n", "Script/hero/sample.gd"),
        "旧品质名工具": ("var n = Global.get_clean_name(item_id)\n", "Script/back_pack/sample.gd"),
        "贴图槽位直写": ("Global._current_role_body_texture_path = \"\"\n", "Script/hero/sample.gd"),
    }
    good_samples = {
        "运行上下文 accessor": ("Global.set_current_level_name(\"花果山\")\n", "Script/level/sample.gd"),
        "塔层 accessor": ("Global.set_tower_floor(8)\n", "Script/level/level_llbt.gd"),
        "统计方法": ("Global.get_run_context().add_damage_dealt(5)\n", "Script/base/base_monster.gd"),
        "统计读取": ("var v = Global.get_run_context().healing\n", "Scene/other_scene/after_level_end.gd"),
        "无尽模式整体赋值": (
            "Global.set_special_dungeon_endless(path, true)\n",
            "Scene/other_scene/level_info.gd",
        ),
        "八仙选择 accessor": ("Global.set_selected_eight_immortal_id(3)\n", "Scene/other_scene/level_info.gd"),
        "NodeUtils 工具": ("var a = NodeUtils.ancestor(node, 2)\n", "Script/hero/sample.gd"),
        "ItemUtils 工具": ("var n = ItemUtils.clean_fashion_name(item_id)\n", "Script/back_pack/sample.gd"),
        "注释中的旧入口": ("# Global.current_level = \"x\" legacy note\n", "Script/level/sample.gd"),
        "同名字段不加 Global 前缀": ("is_stun = false\ncurrent_level = \"\"\n", "Script/base/base_hero.gd"),
        "插件目录": ("Global.current_level = \"x\"\n", "addons/some_plugin/plugin.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.run_state_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.run_state_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] 运行状态边界门禁自测通过 (坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 运行状态边界门禁自测失败！", file=sys.stderr)
    return passed


def run_archive_boundary_self_test() -> bool:
    """档案边界门禁自测：路径拼接与绕过 request_save 必须拦截，登记入口必须放行。"""
    print("[*] 档案边界门禁负向自测...")
    bad_samples = {
        "业务拼接档案路径": ('var p := "user://MyAr_" + str(n) + ".json"\n', "Script/main_menu/sample.gd"),
        "业务直调 save_game": ("MemoryClass.save_game(path)\n", "Script/level/sample.gd"),
        "业务直调 safe_write_archive": ("MemoryClass.safe_write_archive(path, data)\n", "Script/level/sample.gd"),
        "业务直调 load_game": ("var r = MemoryClass.load_game(path)\n", "Script/level/sample.gd"),
    }
    good_samples = {
        "存档卡片登记入口": ('var p := "user://MyAr_" + str(n) + ".json"\nMemoryClass.load_game(p)\n', "Scene/other_scene/bacis_ar_button.gd"),
        "存档界面登记写入": ('var p := "user://MyAr_" + str(n) + ".json"\nMemoryClass.safe_write_archive(p, data)\n', "Script/archive_interface/read_archive_interface.gd"),
        "持久化边界内部": ('var prefix := "user://MyAr_"\nif save_game(p):\n\tpass\n', "Script/memory_class/memory_class.gd"),
        "业务提交保存请求": ('MemoryClass.request_save("panel")\n', "Script/level/sample.gd"),
        "注释中的路径字面量": ('# "user://MyAr_1.json" legacy\nvar x := 1\n', "Script/level/sample.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.archive_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.archive_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] 档案边界门禁自测通过 (坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 档案边界门禁自测失败！", file=sys.stderr)
    return passed


def run_slot_boundary_self_test() -> bool:
    """槽位边界门禁自测：硬编码 /root 单例与视图交换必须拦截。"""
    print("[*] 槽位边界门禁负向自测...")
    bad_samples = {
        "业务硬编码 PlayerData": ('var p = get_node("/root/PlayerData")\n', "Script/main_menu/sample.gd"),
        "业务硬编码 RoleProp": ('var r = get_node_or_null("/root/RoleProp")\n', "Script/level/sample.gd"),
        "重新引入视图交换": ("LocalCoop.suspend_player_view()\n", "Script/coop/sample.gd"),
        "BaseRole 重新引入绝对回落": ('if coop == null:\n\treturn get_node("/root/RoleProp")\n', "Script/base/base_role.gd"),
    }
    good_samples = {
        "槽位查询": ("var p = LocalCoop.data_for(self)\n", "Script/back_pack/sample.gd"),
        "注释中的视图交换": ("# LocalCoop.resume_player_view() legacy note\n", "Script/coop/sample.gd"),
        "文本提示中的字样": ('var msg := "suspend_player_view is gone"\n', "Script/coop/sample.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.slot_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.slot_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] 槽位边界门禁自测通过 (坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 槽位边界门禁自测失败！", file=sys.stderr)
    return passed


def run_shared_ledger_self_test() -> bool:
    """共享账本与快照互斥自测：登记缺失必须拦截。"""
    print("[*] 共享账本与快照互斥门禁负向自测...")
    complete = (
        "func shared_keys() -> Array[String]:\n"
        "\tvar keys: Array[String] = []\n"
        "\tkeys.append_array(BAG_KEYS)\n"
        "\tkeys.append(\"被动技能\")\n"
        "\tkeys.append(PlayerData.MAIN_SWORD_ARRAY_KEY)\n"
        "\tkeys.append(PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY)\n"
        "\tkeys.append(\"炼体\")\n"
        "\tkeys.append(PlayerData.WANLING_CATALOG_LEVELS_KEY)\n"
        "\tkeys.append(\"coin_num\")\n"
        "\treturn keys\n\n\n"
        "func save_profile(snapshot: Dictionary) -> void:\n"
        "\tfor key: String in shared_keys():\n\t\tprofile.erase(key)\n\n"
        "func open_panel(slot: int, type: String) -> void:\n"
        "\tif is_save_snapshot_in_progress():\n\t\treturn\n"
    )
    bad_samples = {
        "缺少共享键登记": (complete.replace('keys.append("炼体")\n', ""), "Script/coop/local_coop.gd"),
        "缺少 2P 剥离": (complete.replace("for key: String in shared_keys():", "for key: String in BAG_KEYS:"), "Script/coop/local_coop.gd"),
        "缺少快照互斥": (complete.replace("is_save_snapshot_in_progress", "snapshot_flag"), "Script/coop/local_coop.gd"),
    }
    good_samples = {
        "完整登记与剥离": (complete, "Script/coop/local_coop.gd"),
        "非目标文件": ("func shared_keys() -> void:\n\tpass\n", "Script/other.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.shared_ledger_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.shared_ledger_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] 共享账本与快照互斥门禁自测通过 (坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] 共享账本与快照互斥门禁自测失败！", file=sys.stderr)
    return passed


def run_hud_panel_boundary_self_test() -> bool:
    """HUD/面板只读自测：直接档案 IO 与字典直写必须拦截，request_save 必须放行。"""
    print("[*] HUD/面板只读门禁负向自测...")
    bad_samples = {
        "HUD 直写档案": ("MemoryClass.save_game(path)\n", "Script/base/base_role.gd"),
        "面板直接写盘": ("MemoryClass.safe_write_archive(path, data)\n", "Script/pet/pet_interface.gd"),
        "技能图标读档": ("var d = MemoryClass.load_game(path)\n", "Scene/other_scene/skill_icon.gd"),
        "HUD 字典下标直写": ('PlayerData.player_data["技能"][0] = 1\n', "Script/base/base_role.gd"),
        "面板字典属性直写": ("PlayerData.player_data.技能 = 1\n", "Script/pet/pet_interface.gd"),
    }
    good_samples = {
        "面板提交保存请求": ('Global.request_save_with_feedback("pet_changes", self)\n', "Script/pet/pet_interface.gd"),
        "队列保存请求": ('MemoryClass.request_save("panel")\n', "Script/base/base_role.gd"),
        "只读查询": ('var v = PlayerData.player_data["技能"]\n', "Script/base/base_role.gd"),
        "比较而非赋值": ('if PlayerData.player_data["技能"] == 1:\n', "Script/base/base_role.gd"),
        "非目标文件写档": ("MemoryClass.save_game(path)\n", "Script/level/victory.gd"),
        "注释中的直写": ('# PlayerData.player_data["x"] = 1 legacy\n', "Script/base/base_role.gd"),
    }
    passed = True
    for label, (content, rel_path) in bad_samples.items():
        line, pattern = ContractScanner.hud_panel_boundary_violation(content, rel_path)
        if line == 0:
            print(f"    [X] 坏样本未被拦截: {label}", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 坏样本已拦截: {label} (行 {line}, 标识 '{pattern}')")
    for label, (content, rel_path) in good_samples.items():
        line, pattern = ContractScanner.hud_panel_boundary_violation(content, rel_path)
        if line != 0:
            print(f"    [X] 好样本被误报: {label} (行 {line}, 标识 '{pattern}')", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 好样本已放行: {label}")
    if passed:
        print(f"\n[SUCCESS] HUD/面板只读门禁自测通过 (坏样本 {len(bad_samples)} / 好样本 {len(good_samples)})")
    else:
        print("\n[FAIL] HUD/面板只读门禁自测失败！", file=sys.stderr)
    return passed


def run_phase17_boundary_self_test() -> bool:
    """Phase 17 边界自测：结算/命令/表现层/路径预算的负向样本必须拦截。"""
    print("[*] Phase 17 边界门禁负向自测...")
    good = {
        "Script/level/victory.gd": "extends LevelSettlement\nfunc _ready():\n\tpass\n",
        "Script/shop/shop_purchase_command.gd": "func execute():\n\tvar s = PlayerData.snapshot_state()\n\tPlayerData.restore_state(s)\n",
        "Scene/other_scene/reward_interface.gd": "func _process(_delta):\n\tvar x = PlayerData.player_data.get(\"x\", 0)\n",
        "Script/base/base_role.gd": "var target = LocalCoop.data_for(self)\n",
    }
    bad = (
        ("Script/level/defeat.gd", "extends LevelSettlement\nfunc _ready():\n\tMemoryClass.request_save(\"x\")\n"),
        ("Script/shop/shop_purchase_command.gd", "func execute():\n\tvar s = PlayerData.snapshot_state()\n"),
        ("Scene/other_scene/transmogtified_box.gd", "func f():\n\tPlayerData.player_data[DataKeys.TRANSMOG_LIST][\"x\"] = 1\n"),
        ("Script/base/base_magic_weapon.gd", "var n = get_node(\"/root/PlayerData\")\n"),
        ("Scene/other_scene/skill_icon.gd", "var n = get_node(\"/root/PlayerData\")\n"),
    )
    passed = True
    for rel_path, content in good.items():
        line, pattern = ContractScanner.phase17_boundary_violation(content, rel_path)
        if line != 0:
            passed = False
            print(f"  [FAIL] 正当样本被拦截: {rel_path} {pattern}")
    for rel_path, content in bad:
        line, pattern = ContractScanner.phase17_boundary_violation(content, rel_path)
        if line == 0:
            passed = False
            print(f"  [FAIL] 负向样本未拦截: {rel_path}")
    deep_ok = 'var n = get_node("a")\n'
    if ContractScanner.phase17_boundary_violation(deep_ok, "Script/pet/pet_interface.gd")[0] != 0:
        passed = False
        print("  [FAIL] 路径预算边界样本未放行")
    deep_bad = 'var n = get_node("a/b")\n'
    if ContractScanner.phase17_boundary_violation(deep_bad, "Script/pet/pet_interface.gd")[0] == 0:
        passed = False
        print("  [FAIL] 路径预算超限未拦截")
    print("[OK] Phase 17 边界门禁自测通过" if passed else "[FAIL] Phase 17 边界门禁自测失败")
    return passed


def run_input_boundary_self_test() -> bool:
    """19-4C 输入写入边界自测：输入读取行夹带档案/保存必须拦截。"""
    print("[*] 输入写入边界门禁负向自测...")
    good = (
        ('var pressed = PlayerInput.is_action_pressed("jump")\n', "Script/base/base_hero.gd"),
        ('var value = PlayerData.player_data.get("x", 0)\n', "Script/base/base_role.gd"),
        ('var axis = Input.get_axis("move_left", "move_right")\n', "Script/base/base_object.gd"),
        ('# var pressed = Input.is_action_pressed("jump") and PlayerData.player_data["x"]\n', "Script/base/base_hero.gd"),
    )
    bad = (
        (
            'var pressed = PlayerInput.is_action_pressed("jump") and PlayerData.player_data["x"]\n',
            "Script/base/base_hero.gd",
        ),
        (
            'var pressed = Input.is_action_pressed("jump"); MemoryClass.request_save("x")\n',
            "Script/base/base_hero.gd",
        ),
    )
    passed = True
    for content, rel_path in good:
        line, pattern = ContractScanner.input_boundary_violation(content, rel_path)
        if line != 0:
            passed = False
            print(f"  [FAIL] 正当样本被拦截: {rel_path} {pattern}")
    for content, rel_path in bad:
        line, pattern = ContractScanner.input_boundary_violation(content, rel_path)
        if line == 0:
            passed = False
            print(f"  [FAIL] 负向样本未拦截: {rel_path}")
    print("[OK] 输入写入边界门禁自测通过" if passed else "[FAIL] 输入写入边界门禁自测失败")
    return passed


def run_panel_operator_self_test() -> bool:
    """面板操作者门禁自测：声明/继承必须放行，未绑定必须拦截。"""
    print("[*] 面板操作者门禁负向自测...")

    class _StubSymbols:
        class_names = {"BaseThing": "res://Script/base/base_thing.gd"}

    scanner = ContractScanner.__new__(ContractScanner)
    scanner.project_dir = ""
    scanner.script_files = []
    scanner.symbol_index = _StubSymbols()
    scanner._operator_index = (
        {
            "Script/back_pack/declared.gd": "Node2D",
            "Script/back_pack/inherited.gd": "BaseThing",
            "Script/back_pack/unbound.gd": "Node2D",
            "Script/base/base_thing.gd": "Node2D",
        },
        {
            "Script/back_pack/declared.gd": {"PlayerData", "RoleProp"},
            "Script/back_pack/inherited.gd": set(),
            "Script/back_pack/unbound.gd": set(),
            "Script/base/base_thing.gd": {"PlayerData"},
        },
    )
    cases = (
        ("自身声明", "Script/back_pack/declared.gd", "PlayerData", True),
        ("继承声明", "Script/back_pack/inherited.gd", "PlayerData", True),
        ("未绑定", "Script/back_pack/unbound.gd", "PlayerData", False),
        ("继承未声明的属性", "Script/back_pack/inherited.gd", "RoleProp", False),
    )
    passed = True
    for label, rel_path, operator, expected in cases:
        resolved = scanner._resolves_operator(rel_path, operator)
        if resolved != expected:
            print(f"    [X] 判定错误: {label} (期望 {expected}, 实际 {resolved})", file=sys.stderr)
            passed = False
        else:
            print(f"    [√] 判定正确: {label} -> {operator}={resolved}")
    usage_bad = "func f() -> void:\n\tPlayerData.player_data[\"x\"] = 1\n"
    usage_good = "func f() -> void:\n\tLocalCoop.data_for(self)\n"
    if ContractScanner.panel_operator_usage(usage_bad)[0] == 0:
        print("    [X] 坏样本未被识别: 未加前缀的 PlayerData 使用", file=sys.stderr)
        passed = False
    else:
        print("    [√] 坏样本已识别: 未加前缀的 PlayerData 使用")
    if ContractScanner.panel_operator_usage(usage_good)[0] != 0:
        print("    [X] 好样本被误报: 槽位查询", file=sys.stderr)
        passed = False
    else:
        print("    [√] 好样本已放行: 槽位查询")
    if passed:
        print("\n[SUCCESS] 面板操作者门禁自测通过")
    else:
        print("\n[FAIL] 面板操作者门禁自测失败！", file=sys.stderr)
    return passed


def main():
    parser = argparse.ArgumentParser(description="BHYH 全工程字面量契约全量扫描器 (Phase 8-1)")
    parser.add_argument("--project-dir", default="source", help="工程目标根目录")
    parser.add_argument("--md-output", default="docs/reports/contract_audit.md", help="Markdown 报告输出路径")
    parser.add_argument("--json-output", default="docs/reports/contract_audit.json", help="JSON 报告输出路径")
    parser.add_argument("--whitelist", default="scripts/contract_whitelist.json", help="白名单配置文件路径")
    parser.add_argument("--fail-on-error", action="store_true", help="若存在 ERROR 级缺陷返回退出码 1")
    parser.add_argument("--self-test", action="store_true", help="全部边界门禁自测（manifest/Atlas/预载/场景入口/加载页缓存/池 UI/运行状态/档案/槽位/共享账本/HUD 面板只读/Phase 17 边界/输入写入边界/面板操作者；不执行全量扫描、不写报告）")

    args = parser.parse_args()

    if args.self_test:
        manifest_ok = run_runtime_manifest_self_test()
        atlas_ok = run_atlas_boundary_self_test()
        preload_ok = run_preload_boundary_self_test()
        scene_ok = run_scene_entry_boundary_self_test()
        load_cache_ok = run_load_cache_boundary_self_test()
        pool_ui_ok = run_pool_ui_boundary_self_test()
        run_state_ok = run_run_state_boundary_self_test()
        archive_ok = run_archive_boundary_self_test()
        slot_ok = run_slot_boundary_self_test()
        shared_ledger_ok = run_shared_ledger_self_test()
        hud_panel_ok = run_hud_panel_boundary_self_test()
        phase17_ok = run_phase17_boundary_self_test()
        input_ok = run_input_boundary_self_test()
        panel_operator_ok = run_panel_operator_self_test()
        sys.exit(
            0
            if manifest_ok
            and atlas_ok
            and preload_ok
            and scene_ok
            and load_cache_ok
            and pool_ui_ok
            and run_state_ok
            and archive_ok
            and slot_ok
            and shared_ledger_ok
            and phase17_ok
            and hud_panel_ok
            and input_ok
            and panel_operator_ok
            else 1
        )

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

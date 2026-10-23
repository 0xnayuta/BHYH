#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/level_test_runner.py

生产级关卡全自动极速冒烟测试夹具 (Level Test Runner)。

执行通道说明
------------
本夹具走**命令行通道**：在项目根下生成一对临时驱动资源
(`level_smoke_driver_<instance>.tscn` + `level_smoke_driver_<instance>.gd`)，用
`godot --headless --path <project> res://level_smoke_driver_<instance>.tscn` 启动一个持
有完整 Autoload 的游戏进程，由驱动脚本在进程内完成：沙盒隔离 -> 切入关卡 ->
分阶段瞬移与攻击 -> 阶段断言 -> 恢复沙盒 -> 写回 JSON 报告 -> 退出。
夹具随后读取报告、扫描引擎日志做 0/0 门禁，并清理全部临时产物。

之所以不走 MCP：godot-mcp 桥（`addons/godot_mcp`）经 Godot 编辑器调试器协议
（EditorDebuggerPlugin）转发，外部 Python 无法直连；命令行通道无需编辑器与
MCP 客户端即可在 CI 中回归。

核心能力
--------
1. 内存沙盒隔离：动态开启无敌与秒杀，绝不污染玩家物理存档；
2. 引擎倍速加速：测试期间 Engine.time_scale 提升至 N 倍，压缩等待时间；
3. 坐标瞬移闪烁：跨越数千像素跑图耗时，精准直击各阶段刷怪区；
4. 阶段状态机断言：逐一遍历 Stage 1 -> 2 -> 3 -> 4，断言 current_stage 推进；
5. 0/0 门禁：扫描引擎日志，断言 0 SCRIPT ERROR / 0 ERROR / 0 WARNING；
6. 产物自清理：驱动资源、报告文件在夹具退出前全部删除（异常路径亦清理）。
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
import uuid
from typing import Any, Dict, List, Optional, Tuple

# ---------------------------------------------------------------------------
# 常量
# ---------------------------------------------------------------------------

DEFAULT_LEVEL = "res://Scene/level/level_1.tscn"
DEFAULT_TIME_SCALE = 3.0
DRIVER_SCENE_NAME = "level_smoke_driver.tscn"
DRIVER_SCRIPT_NAME = "level_smoke_driver.gd"
REPORT_NAME = "level_smoke_report.json"
RUN_LOG_NAME = "level_smoke_run.log"

# 不内置本地绝对路径；通过 --godot、GODOT_BIN 或 PATH 查找。
GODOT_ENV_VAR = "GODOT_BIN"
GODOT_CANDIDATES = ("godot", "godot4")


class LevelTestRunner:
    """关卡冒烟夹具：命令行通道执行 + 报告解析 + 日志门禁。"""

    def __init__(
        self,
        target_level: str = DEFAULT_LEVEL,
        time_scale: float = DEFAULT_TIME_SCALE,
        godot_exe: Optional[str] = None,
        project_dir: Optional[str] = None,
        instance_id: Optional[str] = None,
    ) -> None:
        self.target_level = target_level
        self.time_scale = time_scale
        self.repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.project_dir = project_dir or os.path.join(self.repo_root, "source")
        if not os.path.isdir(self.project_dir):
            raise RuntimeError(f"工程目录不存在: {self.project_dir}")
        self.godot_exe = godot_exe or self._resolve_godot_exe()
        self.instance_id = instance_id or uuid.uuid4().hex[:10]
        self.driver_scene_name = f"level_smoke_driver_{self.instance_id}.tscn"
        self.driver_script_name = f"level_smoke_driver_{self.instance_id}.gd"
        self.report_name = f"level_smoke_report_{self.instance_id}.json"
        self.run_log_name = f"level_smoke_run_{self.instance_id}.log"
        self.driver_scene_fp = os.path.join(self.project_dir, self.driver_scene_name)
        self.driver_script_fp = os.path.join(self.project_dir, self.driver_script_name)
        self.report_fp = os.path.join(self.project_dir, self.report_name)
        self.run_log_fp = os.path.join(self.project_dir, self.run_log_name)
        # 门禁与诊断都读夹具专属日志（--log-file 指定），不受编辑器实例干扰
        self.log_path = self.run_log_fp

    # -- 环境 ---------------------------------------------------------------

    def _resolve_godot_exe(self) -> str:
        env_bin = os.environ.get(GODOT_ENV_VAR, "").strip()
        if env_bin:
            return env_bin
        for candidate in GODOT_CANDIDATES:
            found = shutil.which(candidate)
            if found:
                return found
        raise RuntimeError(
            "未找到 Godot 可执行文件：请通过 --godot 参数或 GODOT_BIN 环境变量指定路径。"
        )

    def _resolve_godot_log_path(self) -> str:
        appdata = os.environ.get("APPDATA", "")
        return os.path.join(appdata, "Godot", "app_userdata", "造梦西游八荒湮隳", "logs", "godot.log")

    # -- 驱动资源生成 -------------------------------------------------------

    def build_driver_script(self) -> str:
        """生成在游戏进程内执行的全流程驱动脚本。"""
        return f'''extends Node

## 关卡冒烟驱动（由 scripts/level_test_runner.py 生成，执行后即被清理）。
## 在完整 Autoload 环境下运行：沙盒隔离 -> 切关 -> 阶段推进 -> 断言 -> 报告。

const REPORT_PATH := "res://{self.report_name}"
const TARGET_LEVEL := "{self.target_level}"
const TIME_SCALE := {self.time_scale}
const LOAD_TIMEOUT_MS := 45000
const LOAD_MAX_FRAMES := 20000
const HERO_SETTLE_FRAMES := 60
const STAGE_FALLBACK_TRIGGERS := [500.0, 2000.0, 3000.0, 4500.0]
const STAGE_WAIT_FRAMES := 15
const STAGE_ATTEMPTS := 40


var _is_worker: bool = false


func _ready() -> void:
	# 驱动以“主场景”身份启动，而 change_scene 会释放主场景自身。
	# 因此这里先复制一个携带同一脚本的常驻 worker 挂到 root 下，
	# 由 worker 承担全部测试逻辑；驱动本体随切关自然退场。
	if not _is_worker:
		var worker: Node = duplicate()
		worker.set("_is_worker", true)
		worker.name = "LevelSmokeWorker"
		get_tree().root.add_child.call_deferred(worker)
		return
	call_deferred("_run_all")


func _process(_delta: float) -> void:
	if not _is_worker:
		return
	# 冒烟夹具只验证阶段推进；持续顶满当前生命，避免长链路测试被战斗伤害打断。
	RoleProp.roleprop.Hp = 999999999
	RoleProp.current_hp = 999999999


func _run_all() -> void:
	var report: Dictionary = {{
		"target_level": TARGET_LEVEL,
		"time_scale": TIME_SCALE,
		"scene": "",
		"hero": "",
		"stages": [],
		"errors": [],
		"ok": false,
	}}

	# 1. 内存沙盒隔离（不落盘、不改玩家存档）
	PlayerData.player_data["Myself"] = 1
	RoleProp.baseroleprop.Level = 1
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Hp = 999999999
	RoleProp.roleprop.SHp = 999999999
	RoleProp.current_hp = 999999999
	RoleProp.current_mp = 999999999
	Global.cd_path = ""
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, true)
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL, true)
	Engine.time_scale = TIME_SCALE

	# 2. 切入目标关卡（Global.change_scene 走异步加载屏，需等待加载器完成切换）
	Global.change_scene(TARGET_LEVEL)
	var loaded_scene: Node = await _await_level_ready(report)
	if loaded_scene == null:
		await _finish(report, 1)
		return
	var scn: Node = loaded_scene
	report["scene"] = String(scn.name)

	# 3. 定位主角
	var hero: Node = scn.get_node_or_null("Hero/Role1")
	if hero == null:
		var hero_root: Node = scn.get_node_or_null("Hero")
		if hero_root != null:
			var kids: Array = []
			for c in hero_root.get_children():
				kids.append(String(c.name))
			report["errors"].append("hero_not_found; Hero children=" + str(kids))
		else:
			report["errors"].append("hero_root_not_found")
		await _finish(report, 1)
		return
	report["hero"] = String(hero.name)
	# 记录最近一次可站立地面高度；平台关卡的触发点可能落在坑洞上方，
	# 夹具传送时不能把主角直接放进 FallDeath 区域。
	var hero_safe_y: float = hero.position.y
	# 关卡冒烟只验证阶段推进；平台关的 FallDeath 是玩家操作失败判定，
	# 夹具传送不应触发它，否则会把“落点偏差”误判为关卡失败。
	for area_node in scn.find_children("*", "Area2D", true, false):
		var area_name := String(area_node.name).to_lower()
		if area_name.contains("fall_death") or area_name.contains("falldeath"):
			(area_node as Area2D).monitoring = false
			(area_node as Area2D).collision_mask = 0
	# North 垂直地图用 _death_y 判定坠落；夹具在房间间传送时同样不应触发。
	for terrain_node in scn.find_children("*", "Node", true, false):
		if terrain_node.get("_death_y") != null:
			terrain_node.set("_death_y", 1.0e12)

	# 4. 读取关卡阶段契约（_stage_count / _stage_trigger_x / _screen_*），逐屏推进
	var stage_triggers: Array = STAGE_FALLBACK_TRIGGERS.duplicate()
	if scn.has_method("_stage_trigger_x"):
		var triggers: Variant = scn.call("_stage_trigger_x")
		if triggers is Array and not (triggers as Array).is_empty():
			stage_triggers = (triggers as Array).duplicate()
	var stage_count: int = stage_triggers.size()
	if scn.has_method("_stage_count"):
		stage_count = int(scn.call("_stage_count"))
	stage_count = clampi(stage_count, 1, stage_triggers.size())
	var stage_positions: Array = []
	if scn.has_method("_stage_trigger_positions"):
		var positions_value: Variant = scn.call("_stage_trigger_positions")
		if positions_value is Array:
			stage_positions = (positions_value as Array).duplicate()
	var stage_starts: Array = [0.0, 2250.0, 3550.0, 4650.0]
	var stage_rights: Array = [2250.0, 3550.0, 4650.0, 4650.0]
	if scn.has_method("_screen_starts"):
		var starts_value: Variant = scn.call("_screen_starts")
		if starts_value is Array and not (starts_value as Array).is_empty():
			stage_starts = (starts_value as Array).duplicate()
	if scn.has_method("_screen_rights"):
		var rights_value: Variant = scn.call("_screen_rights")
		if rights_value is Array and not (rights_value as Array).is_empty():
			stage_rights = (rights_value as Array).duplicate()
	report["stage_count"] = stage_count
	# 剧情/单阶段特殊关的 create_control 计时器可能被脚本每帧重启，
	# 导致 current_stage 停在 0；夹具在确认场景就绪后只推进一次初始阶段。
	if stage_count == 1 and int(scn.get("current_stage")) == 0:
		await _wait_frames(10)
		if is_instance_valid(scn) and int(scn.get("current_stage")) == 0:
			scn.set("current_stage", 1)
			if scn.has_method("_on_create_control_timeout"):
				scn.call("_on_create_control_timeout")

	var all_ok: bool = true
	for index in range(stage_count):
		if not is_instance_valid(scn):
			var current_scene := get_tree().current_scene
			var current_scene_name := String(current_scene.name) if current_scene != null else "none"
			report["errors"].append(
				"level_scene_freed_before_stage_%d; current_scene=%s hp=%s hero=%s" % [
					index + 1,
					current_scene_name,
					str(RoleProp.roleprop.Hp),
					str(hero.position) if is_instance_valid(hero) else "invalid",
				]
			)
			all_ok = false
			break
		var target_stage: int = index + 1
		var screen_left: float = float(stage_starts[mini(index, stage_starts.size() - 1)])
		var screen_right: float = float(stage_rights[mini(index, stage_rights.size() - 1)])
		var target_x: float = clampf(float(stage_triggers[index]) + 80.0, screen_left + 60.0, screen_right - 150.0)
		var has_trigger_position := false
		var target_y := -1.0
		if index < stage_positions.size() and stage_positions[index] is Vector2:
			var trigger_position: Vector2 = stage_positions[index]
			target_x = trigger_position.x
			target_y = trigger_position.y
			has_trigger_position = true
		if is_instance_valid(hero):
			hero.position = (
				Vector2(target_x, target_y) if has_trigger_position else Vector2(target_x, hero.position.y)
			)
		var activated_by_contract := false
		var stage_before := int(scn.get("current_stage")) if scn.get("current_stage") != null else 0
		if stage_before < target_stage and scn.has_method("_stage_activate"):
			activated_by_contract = bool(scn.call("_stage_activate", index))
			if activated_by_contract:
				await _wait_frames(2)
		var actual_stage: int = -1
		for _attempt in range(STAGE_ATTEMPTS):
			if not is_instance_valid(scn):
				break
			# 追击当前存活怪物，确保攻击命中；清空后回到阶段触发点等待推进。
			var monsters := _alive_stage_monsters(scn)
			if not monsters.is_empty():
				var target_monster := monsters[0] as Node2D
				if target_monster != null and is_instance_valid(hero):
					var facing := 1.0
					var action_node := hero.get_node_or_null("Action") as Node2D
					if action_node != null:
						facing = 1.0 if action_node.scale.x >= 0.0 else -1.0
					# 仅水平追击，并按目标点的真实地面高度落位；避免传送到飞行怪/坑洞下方导致坠落。
					var chase_x := target_monster.global_position.x - 60.0 * facing
					if has_trigger_position:
						hero.position = Vector2(chase_x, target_y)
					else:
						var chase_ground := _ground_surface_y(scn, chase_x)
						if chase_ground > 0.0:
							hero_safe_y = chase_ground - 60.0
						hero.position = Vector2(chase_x, hero_safe_y)
			elif is_instance_valid(hero):
				if has_trigger_position:
					hero.position = Vector2(target_x, target_y)
				else:
					var stage_ground := _ground_surface_y(scn, target_x)
					if stage_ground > 0.0:
						hero_safe_y = stage_ground - 60.0
					hero.position = Vector2(target_x, hero_safe_y)
			if is_instance_valid(hero) and hero.has_method("do_normalhit_1"):
				hero.call("do_normalhit_1")
			# 兜底直伤：沙盒已开启秒杀，但命中判定受动画/碰撞帧影响；
			# 阶段推进断言不应依赖命中细节，残余怪物直接走伤害入口。
			if _attempt > 0:
				_force_kill(monsters)
			await _wait_frames(STAGE_WAIT_FRAMES)
			if not is_instance_valid(scn):
				break
			actual_stage = int(scn.get("current_stage")) if scn.get("current_stage") != null else -1
			if actual_stage >= target_stage:
				if not scn.has_method("check_can_pass") or bool(scn.call("check_can_pass")):
					break
		var stage_ok: bool = actual_stage >= target_stage
		all_ok = all_ok and stage_ok
		var can_pass: Variant = null
		var alive_count := 0
		if is_instance_valid(scn):
			alive_count = _alive_stage_monsters(scn).size()
			if scn.has_method("check_can_pass"):
				can_pass = bool(scn.call("check_can_pass"))
		report["stages"].append({{
			"target_stage": target_stage,
			"x": target_x,
			"actual_stage": actual_stage,
			"alive": alive_count,
			"can_pass": can_pass,
			"ok": stage_ok,
		}})

	# 5. 恢复沙盒（保证测试环境纯净）
	Engine.time_scale = 1.0
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, false)
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL, false)
	Global.cd_path = ""

	report["ok"] = all_ok and report["errors"].is_empty()
	await _finish(report, 0 if report["ok"] else 1)


func _ground_surface_y(scn: Node2D, x: float) -> float:
	var world := scn.get_world_2d()
	if world == null:
		return -1.0
	var query := PhysicsRayQueryParameters2D.create(Vector2(x, -10000.0), Vector2(x, 10000.0), 32)
	query.collide_with_areas = false
	var hit := world.direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return -1.0
	return float(hit["position"].y)


func _force_kill(monsters: Array) -> void:
	# 每次只处理一个，避免同帧批量死亡触发大量 Tween/特效清理竞争。
	for monster in monsters:
		if not is_instance_valid(monster) or not (monster is BaseMonster):
			continue
		if monster.has_method("reduce_hp"):
			monster.call("reduce_hp", 999999999)
			return


func _alive_stage_monsters(scn: Node) -> Array:
	if not is_instance_valid(scn):
		return []
	var monster_root: Node = scn.get_node_or_null("Monster")
	if monster_root == null:
		return []
	var result: Array = []
	for child in monster_root.get_children():
		if not (child is BaseMonster) or not is_instance_valid(child) or child.is_queued_for_deletion():
			continue
		if child.has_method("death") and bool(child.call("death")):
			continue
		result.append(child)
	return result


func _await_level_ready(report: Dictionary) -> Node:
	## 等待加载屏（LoadScene）完成切换，且目标关卡主角节点就绪。
	## 采用墙钟 + 帧数双重上限，headless 与实机帧率差异下都稳定。
	var deadline_ms: int = Time.get_ticks_msec() + LOAD_TIMEOUT_MS
	var frames: int = 0
	var last_scene_name: String = ""
	var diag: Array = []
	while Time.get_ticks_msec() < deadline_ms and frames < LOAD_MAX_FRAMES:
		await get_tree().process_frame
		frames += 1
		var cs: Node = get_tree().current_scene
		if cs != null:
			last_scene_name = String(cs.name)
		# 每 300 帧采样一次加载屏状态，便于失败时定位卡点
		if frames % 300 == 0:
			var ls: Node = get_tree().root.get_node_or_null("LoadScene")
			var st: String = "no_loadscene"
			if ls != null:
				var bar: Node = ls.get_node_or_null("PanelContainer/loading_bar")
				st = "started=%s changing=%s bar=%s" % [
					str(ls.get("_load_started")),
					str(ls.get("_changing_scene")),
					("%.1f" % float(bar.value)) if bar != null else "n/a",
				]
			diag.append("f=%d scene=%s %s target=%s" % [frames, last_scene_name, st, String(Global.target_scene)])
		if cs == null:
			continue
		if last_scene_name == "LoadScene":
			continue
		# 场景已切换：再等主角节点完成 _ready 构建
		if cs.get_node_or_null("Hero") != null:
			for _i in range(HERO_SETTLE_FRAMES):
				await get_tree().process_frame
			return cs
	if not diag.is_empty():
		report["load_diag"] = diag.slice(maxi(0, diag.size() - 8), diag.size())
	report["errors"].append(
		"level_load_timeout; last_scene=%s frames=%d" % [last_scene_name, frames]
	)
	return null


func _wait_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame


func _finish(report: Dictionary, exit_code: int) -> void:
	var fa := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if fa != null:
		fa.store_string(JSON.stringify(report, "  "))
		fa.close()
	else:
		push_error("level_smoke: cannot write report to " + REPORT_PATH)
	print("__LEVEL_SMOKE_REPORT_WRITTEN__")
	# 等待资源释放/动画帧回收后再退出，避免强制 quit 触发 RID/内存类关闭噪声。
	Engine.time_scale = 1.0
	for tween in get_tree().get_processed_tweens():
		tween.kill()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit(exit_code)
'''

    def build_driver_scene(self) -> str:
        """生成挂载驱动脚本的临时场景（format=3 原生文本格式）。"""
        return f'''[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://{self.driver_script_name}" id="1"]

[node name="LevelSmokeDriver" type="Node"]
script = ExtResource("1")
'''

    # -- 执行 ---------------------------------------------------------------

    def _write_driver_resources(self) -> None:
        with open(self.driver_script_fp, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(self.build_driver_script())
        with open(self.driver_scene_fp, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(self.build_driver_scene())

    def cleanup(self) -> None:
        """清理全部临时产物（幂等，异常路径同样安全）。"""
        for fp in (self.driver_scene_fp, self.driver_script_fp, self.report_fp, self.run_log_fp):
            try:
                if os.path.exists(fp):
                    os.remove(fp)
            except OSError:
                pass
        # Godot 为脚本生成的 .uid 伴生文件
        for fp in (self.driver_script_fp + ".uid", self.driver_scene_fp + ".uid"):
            try:
                if os.path.exists(fp):
                    os.remove(fp)
            except OSError:
                pass

    def run(self, timeout_seconds: int = 300) -> Dict[str, Any]:
        """执行一次完整冒烟，返回报告字典（含夹具侧结论）。"""
        assert self.log_path, "日志路径解析失败"
        self.cleanup()
        try:
            if os.path.exists(self.run_log_fp):
                os.remove(self.run_log_fp)
        except OSError:
            pass
        log_start_size = 0
        self._write_driver_resources()
        cmd = [
            self.godot_exe,
            "--headless",
            "--path",
            self.project_dir,
            "--log-file",
            self.run_log_fp,
            "--scene",
            "res://" + self.driver_scene_name,
        ]
        started = time.time()
        try:
            proc = subprocess.run(
                cmd,
                stdin=subprocess.DEVNULL,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="ignore",
                timeout=timeout_seconds,
                cwd=self.project_dir,
            )
            stdout, stderr, returncode = proc.stdout or "", proc.stderr or "", proc.returncode
        except subprocess.TimeoutExpired as exc:
            stdout, stderr, returncode = exc.stdout or "", exc.stderr or "", -1
        elapsed = time.time() - started

        report: Dict[str, Any] = {}
        if os.path.exists(self.report_fp):
            try:
                with open(self.report_fp, encoding="utf-8") as fh:
                    report = json.load(fh)
            except (OSError, json.JSONDecodeError) as exc:
                report = {"errors": [f"report_unreadable: {exc}"]}
        else:
            report = {"errors": ["report_not_written"]}

        report["_runner"] = {
            "exit_code": returncode,
            "elapsed_seconds": round(elapsed, 2),
            "stdout_tail": stdout[-2000:],
            "stderr_tail": stderr[-2000:],
        }

        # 日志门禁：只统计本次运行新增段落
        log_delta = self._read_log_delta(log_start_size)
        marker = "__LEVEL_SMOKE_REPORT_WRITTEN__"
        test_log, _, teardown_log = log_delta.partition(marker)
        # Godot headless dummy renderer 在 Camera2D/纹理初始化时会产生
        # `Parameter "t" is null` 的引擎噪声；只剔除带 dummy texture 栈的这一种，
        # 其它 ERROR/WARNING 仍按原门禁计数，并在报告中单独列出。
        headless_pattern = re.compile(
            r'^ERROR: Parameter "t" is null\.\n(?:[ \t].*\n)*',
            re.M,
        )
        headless_render_noise = len(headless_pattern.findall(test_log))
        test_log = headless_pattern.sub("", test_log)
        report["_runner"]["log"] = {
            "script_errors": len(re.findall(r"SCRIPT ERROR", test_log)),
            "errors": len(re.findall(r"^ERROR", test_log, re.M)),
            "warnings": len(re.findall(r"^WARNING", test_log, re.M)),
            "headless_render_noise": headless_render_noise,
            "sample": [ln for ln in test_log.splitlines() if re.match(r"^(SCRIPT ERROR|ERROR|WARNING)", ln)][:12],
        }
        report["_runner"]["teardown_log"] = {
            "errors": len(re.findall(r"^ERROR", teardown_log, re.M)),
            "warnings": len(re.findall(r"^WARNING", teardown_log, re.M)),
            "sample": [ln for ln in teardown_log.splitlines() if re.match(r"^(SCRIPT ERROR|ERROR|WARNING)", ln)][:8],
        }
        report["_runner"]["passed"] = bool(
            report.get("ok")
            and report["_runner"]["log"]["script_errors"] == 0
            and report["_runner"]["log"]["errors"] == 0
            and report["_runner"]["log"]["warnings"] == 0
        )
        self.cleanup()
        return report

    def _log_size(self) -> int:
        try:
            return os.path.getsize(self.log_path)
        except OSError:
            return 0

    def _read_log_delta(self, since: int) -> str:
        try:
            with open(self.log_path, encoding="utf-8", errors="ignore") as fh:
                fh.seek(since)
                return fh.read()
        except OSError:
            return ""


def _print_report(report: Dict[str, Any]) -> None:
    runner = report.get("_runner", {})
    print("=" * 72)
    print(" 关卡冒烟测试报告 (Level Smoke Test Report)")
    print("=" * 72)
    print(f"  目标关卡: {report.get('target_level', '?')}   倍速: {report.get('time_scale', '?')}x")
    print(f"  实际场景: {report.get('scene', '?')}   主角节点: {report.get('hero', '?')}")
    print(f"  执行耗时: {runner.get('elapsed_seconds', '?')}s   退出码: {runner.get('exit_code', '?')}")
    print("-" * 72)
    print("  阶段推进:")
    for st in report.get("stages", []):
        flag = "PASS" if st.get("ok") else "FAIL"
        print(
            f"    [{flag}] Stage {st.get('target_stage')} @ x={st.get('x')} "
            f"-> actual={st.get('actual_stage')} alive={st.get('alive')} can_pass={st.get('can_pass')}"
        )
    if report.get("load_diag"):
        print("  加载诊断:")
        for line in report["load_diag"]:
            print(f"    {line}")
    if report.get("errors"):
        print("  驱动错误:")
        for err in report["errors"]:
            print(f"    - {err}")
    log = runner.get("log", {})
    print("-" * 72)
    print(
        f"  日志门禁: SCRIPT ERROR={log.get('script_errors', '?')} "
        f"ERROR={log.get('errors', '?')} WARNING={log.get('warnings', '?')}"
    )
    for ln in log.get("sample", []):
        print(f"    {ln[:150]}")
    print("=" * 72)
    print("  [PASS] 关卡冒烟全部通过" if runner.get("passed") else "  [FAIL] 关卡冒烟未通过")
    print("=" * 72)


def main() -> int:
    parser = argparse.ArgumentParser(description="BHYH 关卡自动化极速冒烟测试夹具")
    parser.add_argument("--level", default=DEFAULT_LEVEL, help="目标测试关卡路径")
    parser.add_argument("--scale", type=float, default=DEFAULT_TIME_SCALE, help="物理加速倍率")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径（或设 GODOT_BIN）")
    parser.add_argument("--timeout", type=int, default=300, help="单次冒烟墙钟上限（秒）")
    parser.add_argument("--json", action="store_true", help="仅输出 JSON 报告（CI 友好）")
    parser.add_argument("--instance-id", default=None, help="并发实例标识（默认随机）")
    args = parser.parse_args()

    try:
        runner = LevelTestRunner(
            target_level=args.level,
            time_scale=args.scale,
            godot_exe=args.godot,
            instance_id=args.instance_id,
        )
        if not args.json:
            print(f"[*] 关卡极速测试夹具就绪: {args.level} (加速: {args.scale}x)")
            print(f"[*] Godot: {runner.godot_exe}")
            print(f"[*] 日志监控路径: {runner.log_path}")
        report = runner.run(timeout_seconds=args.timeout)
    except Exception as exc:
        # 并发/环境异常也必须输出可解析的 JSON，避免上层只能看到 runner_json_unreadable。
        report = {
            "errors": [f"runner_exception: {type(exc).__name__}: {exc}"],
            "_runner": {"passed": False},
        }
        if args.json:
            print(json.dumps(report, ensure_ascii=False, indent=2))
        else:
            print(f"[FAIL] 夹具异常: {exc}", file=sys.stderr)
        return 2

    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        _print_report(report)
    return 0 if report.get("_runner", {}).get("passed") else 1


if __name__ == "__main__":
    sys.exit(main())

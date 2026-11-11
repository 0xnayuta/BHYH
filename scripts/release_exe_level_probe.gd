extends Node

## 正式 Windows release EXE 的 level_1 四阶段验证探针（外置，不进入发行 PCK）。
##
## 运行方式：
##   scripts/release_exe_level_runner.py 把本文件复制到隔离的 user:// 目录，
##   在 EXE 同目录写入只追加一个 autoload 的 override.cfg，然后启动正式
##   release EXE（不传 --path/--script/--main-pack/--remote-debug）。
##   Godot 从 override.cfg 装载本 autoload，本探针在真实发行 PCK 与完整
##   生产 autoload 环境中执行 level_1 四阶段契约，报告写入 user:// 后退出。
##
## 边界：
## - 本脚本不属于发行 PCK，也不覆盖任何 res:// 生产资源；它只是运行时追加的
##   独立 autoload。
## - 测试状态只在内存沙盒中修改；真实存档由 runner 的隔离 APPDATA 保护。
## - 任何阶段失败、超时、报告写入失败都会以非 0 退出码结束，并保留报告。

const REPORT_PATH := "user://release_exe_level_probe_report.json"
const TARGET_LEVEL := "res://Scene/level/level_1.tscn"
const EXPECTED_STAGE_COUNT := 4
const TIME_SCALE := 3.0
const RUN_TIMEOUT_MS := 240_000
const LOAD_TIMEOUT_MS := 45_000
const LOAD_MAX_FRAMES := 20_000
const HERO_SETTLE_FRAMES := 60
const STAGE_FALLBACK_TRIGGERS: Array[float] = [500.0, 2000.0, 3000.0, 4500.0]
const STAGE_WAIT_FRAMES := 15
const STAGE_ATTEMPTS := 40
const DEFAULT_STAGE_STARTS: Array[float] = [0.0, 2250.0, 3550.0, 4650.0]
const DEFAULT_STAGE_RIGHTS: Array[float] = [2250.0, 3550.0, 4650.0, 4650.0]
const PRODUCTION_AUTOLOADS: Array[String] = [
	"RoleProp",
	"PlayerData",
	"MemoryClass",
	"MainSet",
	"MLdl",
	"PaSkill",
	"Global",
	"LocalCoop",
	"MCPGameBridge",
	"ZmwsConfig",
]

var _report: Dictionary = {}
var _finished := false
var _pending_quit := -1
var _started_msec := 0
var _startup_scene_path := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_started_msec = Time.get_ticks_msec()
	_report = {
		"probe": {
			"script_path": String(get_script().resource_path),
			"script_in_pck": ResourceLoader.exists("res://release_exe_level_probe.gd"),
			"executable": OS.get_executable_path(),
			"user_dir": OS.get_user_data_dir(),
			"is_debug_build": OS.is_debug_build(),
			"has_release_feature": OS.has_feature("release"),
			"debugger_active": EngineDebugger.is_active(),
			"engine_version": String(Engine.get_version_info().get("string", "")),
			"engine_hash": String(Engine.get_version_info().get("hash", "")),
		},
		"target_level": TARGET_LEVEL,
		"time_scale": TIME_SCALE,
		"expected_stage_count": EXPECTED_STAGE_COUNT,
		"startup_scene_path": "",
		"scene": "",
		"scene_file_path": "",
		"hero": "",
		"stage_count": 0,
		"stage_triggers": [],
		"stage_positions": [],
		"stages": [],
		"errors": [],
		"exit_code": 1,
		"ok": false,
	}
	_run.call_deferred()


func _process(_delta: float) -> void:
	if _pending_quit >= 0:
		get_tree().quit(_pending_quit)
		return
	if _finished:
		return
	if Time.get_ticks_msec() - _started_msec > RUN_TIMEOUT_MS:
		_report["errors"].append("probe_timeout_%d_ms" % RUN_TIMEOUT_MS)
		_finish(2)


func _run() -> void:
	# 等待真实启动场景出现；不抢占主场景创建流程。
	var wait_deadline := Time.get_ticks_msec() + 20_000
	while get_tree().current_scene == null and Time.get_ticks_msec() < wait_deadline:
		await get_tree().process_frame
	if get_tree().current_scene != null:
		_startup_scene_path = String(get_tree().current_scene.scene_file_path)
		_report["startup_scene_path"] = _startup_scene_path
	var production_autoloads: Dictionary = {}
	for autoload_name in PRODUCTION_AUTOLOADS:
		production_autoloads[autoload_name] = get_node_or_null("/root/" + autoload_name) != null
	_report["production_autoloads"] = production_autoloads
	_report["probe_autoload_name"] = String(name)
	var main_scene_setting := String(ProjectSettings.get_setting("application/run/main_scene", ""))
	_report["boot"] = {
		"main_scene_setting": main_scene_setting,
		"startup_scene_path": _startup_scene_path,
		"main_scene_booted": _startup_scene_path == main_scene_setting,
		"startup_scene_present": get_tree().current_scene != null,
	}
	await _wait_frames(3)

	var entry_ok := _enter_sandbox()
	if not entry_ok:
		_finish(1)
		return

	# 走正式 Global.change_scene 入口；不建立档案会话，避免写玩家存档。
	if not Global.change_scene(TARGET_LEVEL, false, false):
		_report["errors"].append("change_scene_rejected")
		_finish(1)
		return

	var scn := await _await_level_ready()
	if scn == null:
		_finish(1)
		return

	_report["scene"] = String(scn.name)
	_report["scene_file_path"] = String(scn.scene_file_path)
	if String(scn.scene_file_path) != TARGET_LEVEL:
		_report["errors"].append("unexpected_scene_path:" + String(scn.scene_file_path))

	var hero: Node = _find_hero(scn)
	if hero == null:
		_report["errors"].append("hero_not_found")
		_finish(1)
		return
	_report["hero"] = String(hero.name)

	var hero_safe_y: float = hero.position.y
	for area_node in scn.find_children("*", "Area2D", true, false):
		var area_name := String(area_node.name).to_lower()
		if area_name.contains("fall_death") or area_name.contains("falldeath"):
			(area_node as Area2D).monitoring = false
			(area_node as Area2D).collision_mask = 0
	for terrain_node in scn.find_children("*", "Node", true, false):
		if terrain_node.get("_death_y") != null:
			terrain_node.set("_death_y", 1.0e12)

	var stage_triggers: Array = STAGE_FALLBACK_TRIGGERS.duplicate()
	if scn.has_method("_stage_trigger_x"):
		var triggers_value: Variant = scn.call("_stage_trigger_x")
		if triggers_value is Array and not (triggers_value as Array).is_empty():
			stage_triggers = (triggers_value as Array).duplicate()
	var stage_count: int = stage_triggers.size()
	if scn.has_method("_stage_count"):
		stage_count = int(scn.call("_stage_count"))
	stage_count = clampi(stage_count, 1, stage_triggers.size())
	_report["stage_count"] = stage_count
	_report["stage_triggers"] = stage_triggers

	var stage_positions: Array = []
	if scn.has_method("_stage_trigger_positions"):
		var positions_value: Variant = scn.call("_stage_trigger_positions")
		if positions_value is Array:
			stage_positions = (positions_value as Array).duplicate()
	var positions_json: Array = []
	for position_value in stage_positions:
		if position_value is Vector2:
			positions_json.append([position_value.x, position_value.y])
	_report["stage_positions"] = positions_json

	var stage_starts: Array = DEFAULT_STAGE_STARTS.duplicate()
	var stage_rights: Array = DEFAULT_STAGE_RIGHTS.duplicate()
	if scn.has_method("_screen_starts"):
		var starts_value: Variant = scn.call("_screen_starts")
		if starts_value is Array and not (starts_value as Array).is_empty():
			stage_starts = (starts_value as Array).duplicate()
	if scn.has_method("_screen_rights"):
		var rights_value: Variant = scn.call("_screen_rights")
		if rights_value is Array and not (rights_value as Array).is_empty():
			stage_rights = (rights_value as Array).duplicate()

	if stage_count != EXPECTED_STAGE_COUNT:
		_report["errors"].append("unexpected_stage_count:%d" % stage_count)

	var all_ok := stage_count == EXPECTED_STAGE_COUNT
	for index in range(stage_count):
		if not is_instance_valid(scn):
			_report["errors"].append("level_scene_freed_before_stage_%d" % (index + 1))
			all_ok = false
			break
		var target_stage := index + 1
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
			hero.position = Vector2(target_x, target_y) if has_trigger_position else Vector2(target_x, hero.position.y)

		var activated_by_contract := false
		var stage_before := int(scn.get("current_stage")) if scn.get("current_stage") != null else 0
		if stage_before < target_stage and scn.has_method("_stage_activate"):
			activated_by_contract = bool(scn.call("_stage_activate", index))
			if activated_by_contract:
				await _wait_frames(2)

		var actual_stage := -1
		for attempt in range(STAGE_ATTEMPTS):
			if not is_instance_valid(scn):
				break
			var monsters := _alive_stage_monsters(scn)
			if not monsters.is_empty():
				var target_monster := monsters[0] as Node2D
				if target_monster != null and is_instance_valid(hero):
					var facing := 1.0
					var action_node := hero.get_node_or_null("Action") as Node2D
					if action_node != null:
						facing = 1.0 if action_node.scale.x >= 0.0 else -1.0
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
			if attempt > 0:
				_force_kill(monsters)
			await _wait_frames(STAGE_WAIT_FRAMES)
			if not is_instance_valid(scn):
				break
			actual_stage = int(scn.get("current_stage")) if scn.get("current_stage") != null else -1
			if actual_stage >= target_stage:
				if not scn.has_method("check_can_pass") or bool(scn.call("check_can_pass")):
					break

		var stage_ok := actual_stage >= target_stage
		all_ok = all_ok and stage_ok
		var can_pass: Variant = null
		var alive_count := 0
		if is_instance_valid(scn):
			alive_count = _alive_stage_monsters(scn).size()
			if scn.has_method("check_can_pass"):
				can_pass = bool(scn.call("check_can_pass"))
		_report["stages"].append({
			"target_stage": target_stage,
			"x": target_x,
			"actual_stage": actual_stage,
			"alive": alive_count,
			"can_pass": can_pass,
			"activated_by_contract": activated_by_contract,
			"ok": stage_ok,
		})
		if stage_ok and index < stage_count - 1:
			await _wait_physics_frames(2)

	# 留出稳定窗口，避免在异步加载/实例化未收尾时退出。
	await _wait_frames(120)
	await _wait_physics_frames(2)
	# 夹具不走结算入口时，仍等待并领取关卡已经发起的结算预载。
	# 禁止停用关卡 physics，否则会漏掉出口与预载的生产行为。
	await _consume_victory_preload()
	if not Global.change_scene("res://Scene/main_menu/main_menu.tscn", false, false):
		_report["errors"].append("cleanup_scene_change_failed")
	else:
		var deadline := Time.get_ticks_msec() + LOAD_TIMEOUT_MS
		while Time.get_ticks_msec() < deadline:
			await get_tree().process_frame
			var current := get_tree().current_scene
			if current != null and current.scene_file_path == "res://Scene/main_menu/main_menu.tscn":
				break
		if get_tree().current_scene == null or get_tree().current_scene.scene_file_path != "res://Scene/main_menu/main_menu.tscn":
			_report["errors"].append("cleanup_scene_change_timeout")
	await _wait_frames(30)

	_report["ok"] = all_ok and (len(_report["stages"]) == EXPECTED_STAGE_COUNT) and (_report["errors"] as Array).is_empty()
	_finish(0 if _report["ok"] else 1)


func _enter_sandbox() -> bool:
	# 与 scripts/level_test_runner.py 相同的运行期沙盒：只改内存，不写存档。
	PlayerData.player_data["Myself"] = 1
	RoleProp.baseroleprop.Level = 1
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Hp = 999999999
	RoleProp.roleprop.SHp = 999999999
	RoleProp.current_hp = 999999999
	RoleProp.current_mp = 999999999
	Global.set_cd_path("")
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, true)
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL, true)
	Engine.time_scale = TIME_SCALE
	return true


func _find_hero(scn: Node) -> Node:
	var hero: Node = scn.get_node_or_null("Hero/Role1")
	if hero != null:
		return hero
	var hero_root: Node = scn.get_node_or_null("Hero")
	if hero_root == null:
		return null
	for candidate in hero_root.get_children():
		if candidate is BaseHero:
			return candidate
	return null


func _await_level_ready() -> Node:
	var deadline_ms := Time.get_ticks_msec() + LOAD_TIMEOUT_MS
	var frames := 0
	var last_scene_name := ""
	var diag: Array[String] = []
	while Time.get_ticks_msec() < deadline_ms and frames < LOAD_MAX_FRAMES:
		await get_tree().process_frame
		frames += 1
		var current := get_tree().current_scene
		if current != null:
			last_scene_name = String(current.name)
		if frames % 300 == 0:
			diag.append("f=%d scene=%s" % [frames, last_scene_name])
		if current == null or last_scene_name == "LoadScene":
			continue
		if current.get_node_or_null("Hero") != null:
			await _wait_frames(HERO_SETTLE_FRAMES)
			return current
	if not diag.is_empty():
		_report["load_diag"] = diag.slice(maxi(0, diag.size() - 8))
	_report["errors"].append("level_load_timeout:last_scene=%s frames=%d" % [last_scene_name, frames])
	return null


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


func _force_kill(monsters: Array) -> void:
	for monster in monsters:
		if not is_instance_valid(monster) or not (monster is BaseMonster):
			continue
		if monster.has_method("reduce_hp"):
			monster.call("reduce_hp", 999999999)
			return


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


func _wait_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame


func _wait_physics_frames(count: int) -> void:
	for _i in range(count):
		await get_tree().physics_frame


func _consume_victory_preload() -> void:
	const VICTORY_PATH := "res://Scene/level/victory.tscn"
	var resource_runtime := Global.get_resource_runtime()
	var snapshot := resource_runtime.get_preloaded_slot_snapshot()
	if str(snapshot.get("path", "")) != VICTORY_PATH:
		_report["errors"].append("victory_preload_not_requested")
		return
	var deadline := Time.get_ticks_msec() + LOAD_TIMEOUT_MS
	while Time.get_ticks_msec() < deadline:
		var status := ResourceLoader.load_threaded_get_status(VICTORY_PATH)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var result := resource_runtime.take_preloaded_scene(VICTORY_PATH)
			if result == null:
				_report["errors"].append("victory_preload_result_missing")
			return
		if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_report["errors"].append("victory_preload_failed:%s" % status)
			return
		await get_tree().process_frame
	_report["errors"].append("victory_preload_timeout")


func _finish(exit_code: int) -> void:
	if _finished:
		return
	_finished = true
	_report["exit_code"] = exit_code
	_report["duration_ms"] = Time.get_ticks_msec() - _started_msec
	var report_file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if report_file == null:
		print("RELEASE_EXE_LEVEL_PROBE_REPORT_WRITE_FAILED path=", REPORT_PATH)
		_pending_quit = 2
		return
	report_file.store_string(JSON.stringify(_report, "  "))
	report_file.close()
	var stages_value: Array = _report.get("stages", [])
	print(
		"RELEASE_EXE_LEVEL_PROBE_RESULT ok=%s stages=%d expected=%d scene=%s exit=%d" % [
			str(_report.get("ok", false)),
			stages_value.size(),
			EXPECTED_STAGE_COUNT,
			str(_report.get("scene_file_path", "")),
			exit_code,
		]
	)
	# 与 level_test_runner 相同：先还原运行期状态；退出由 _process 在下一帧
	# 执行，避免在挂起的协程栈里 quit 造成 ObjectDB 泄漏告警。
	Engine.time_scale = 1.0
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, false)
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL, false)
	Global.set_cd_path("")
	for tween in get_tree().get_processed_tweens():
		tween.kill()
	_pending_quit = exit_code

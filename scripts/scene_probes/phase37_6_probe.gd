extends Node

## 37-6 缺口回归：寒山坡出口、小龙女装备权限、分解帮助文本与固定概率掉落。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "PHASE_37_6_PROBE_RESULT="
const TEARDOWN_MARKER := "PHASE_37_6_PROBE_TEARDOWN"

var _checks: Dictionary = {}
var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var saved_data: Dictionary = PlayerData.player_data.duplicate(true)
	var saved_cd_path: String = Global.get_cd_path()
	PlayerData.player_data["Myself"] = 8
	await _check_level_77_exit()
	_check_role_8_equipment()
	await _check_decompose_help()
	_check_fixed_drop_chance()
	PlayerData.player_data = saved_data
	Global.set_cd_path(saved_cd_path)
	_report()


func _check_level_77_exit() -> void:
	var level := (load("res://Scene/level/level_77.tscn") as PackedScene).instantiate()
	add_child(level)
	await get_tree().process_frame
	level.set_physics_process(false)
	var exit := level.get_node_or_null("exit") as AnimatedSprite2D
	var exit_collision := level.get_node_or_null("exit/exit2/exit") as CollisionShape2D
	_checks["level77_exit_hidden_on_enter"] = exit != null and not exit.visible
	_checks["level77_exit_collision_disabled_on_enter"] = (
		exit_collision != null and exit_collision.disabled
	)
	if exit != null:
		var groups: Dictionary = level.get("monster_group")
		for key in groups.keys():
			groups[key] = []
		var stage_count := int(level.call("_stage_count"))
		level.set("current_stage", stage_count)
		# 北俱芦洲的 check_can_exit 还要求已见 BOSS 且当前触发点全部结算。
		level.set("_boss_seen", true)
		level.set("_boss_ids", [])
		level.set("_active_points", {999: true})
		level.set("_point_states", {999: {"spawned": 1, "target": 1, "instances": []}})
		var one_check := bool(level.call("one_check_can_exit"))
		_checks["level77_stage_count"] = stage_count > 0
		_checks["level77_one_check_can_exit"] = one_check
		level.call("_physics_process", 0.0)
		_checks["level77_exit_visible_after_clear"] = exit.visible
		if exit_collision != null:
			_checks["level77_exit_collision_enabled_after_clear"] = not exit_collision.disabled
	level.queue_free()
	await get_tree().create_timer(0.5, false).timeout


func _check_role_8_equipment() -> void:
	var popup_script := load("res://Script/back_pack/sell_or_equ.gd") as Script
	var popup: Node = popup_script.new() as Node
	_checks["role8_equipment_definition"] = (
		str(EquipmentService.data("4820101").get("所属", "")) == "小龙女"
	)
	_checks["role8_equipment_allowed"] = bool(popup.call("check_can_equipment", "4820101"))
	popup.free()


func _check_decompose_help() -> void:
	var help := (load("res://Scene/ldl/decompose_help.tscn") as PackedScene).instantiate()
	add_child(help)
	await get_tree().process_frame
	var text := _collect_text(help)
	_checks["decompose_help_7_3_text"] = (
		"按各等级强化石的累计消耗分别返还80%，不足1个向下取整" in text
	)
	_checks["decompose_help_old_text_absent"] = (
		"返还使用总量一部分的1级强化石" not in text
	)
	help.queue_free()
	await get_tree().create_timer(0.2, false).timeout


func _check_fixed_drop_chance() -> void:
	_checks["fixed_chance_max_difficulty"] = is_equal_approx(
		BaseMonster.resolve_independent_drop_chance(0.25, 3, true, false), 0.25
	)
	_checks["fixed_chance_double_fall"] = is_equal_approx(
		BaseMonster.resolve_independent_drop_chance(0.25, 3, true, true), 0.25
	)
	_checks["normal_chance_max_difficulty"] = is_equal_approx(
		BaseMonster.resolve_independent_drop_chance(0.25, 3, false, false), 0.75
	)
	_checks["normal_chance_double_fall"] = is_equal_approx(
		BaseMonster.resolve_independent_drop_chance(0.25, 3, false, true), 1.0
	)


func _collect_text(root: Node) -> String:
	var text := ""
	if root is Label:
		text += (root as Label).text + "\n"
	for child in root.get_children():
		text += _collect_text(child)
	return text


func _report() -> void:
	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

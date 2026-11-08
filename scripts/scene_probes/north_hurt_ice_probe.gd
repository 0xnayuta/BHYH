extends Node

## 北俱芦洲冰刺守卫探针：level_76 的 HurtIceEntity 仅在对应 JIT 区段触发后伤害；
## level_79 无 triggerID 的 HurtEntity 是静态陷阱，始终生效。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "NORTH_HURT_ICE_PROBE_RESULT="
const TEARDOWN_MARKER := "NORTH_HURT_ICE_PROBE_TEARDOWN"
const UNTOUCHED_LAST_HIT := -100.0

var _checks: Dictionary = {}
var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var saved_data: Dictionary = PlayerData.player_data.duplicate(true)
	var saved_settings: Dictionary = MainSet.set_data.duplicate(true)
	var saved_cd_path: String = Global.get_cd_path()
	Global.set_cd_path("")
	MainSet.set_auto_battle_enabled(false)
	PlayerData.player_data = PlayerData.initialized_data.duplicate(true)
	PlayerData.player_data["Myself"] = 8
	PlayerData.player_data["实战法宝"] = ""
	PlayerData.player_data["宠物"] = []
	for slot in ["武器", "防具", "时装", "法宝", "翅膀", "头衔"]:
		PlayerData.player_data[slot] = []
	for slot in PlayerData.player_data["幻化列表"]:
		PlayerData.player_data["幻化列表"][slot] = ""
	PlayerData.ensure_skill_data()
	RoleProp.set_physics_process(false)

	await _check_guarded_hurt()
	await _check_static_hurt()

	RoleProp.source_player = null
	PlayerData.player_data = saved_data
	MainSet.set_data = saved_settings
	Global.set_cd_path(saved_cd_path)
	_report()


func _check_guarded_hurt() -> void:
	var level := await _open_level(76)
	if level == null:
		_checks["north_76_open"] = false
		return
	_checks["north_76_open"] = true
	var hero: LongnvHero = level.get("_role") as LongnvHero
	var terrain := level.get_node_or_null("OriginalTerrain")
	if hero == null or terrain == null:
		_checks["north_76_actors"] = false
		await _close_level(level)
		return
	_checks["north_76_actors"] = true
	var hurt_records: Array = terrain.get("_hurt_zones")
	var jit_records: Array = terrain.get("_jit_triggers")
	_checks["north_76_counts"] = hurt_records.size() == 13 and jit_records.size() == 14
	var jit_ids: Variant = terrain.get("_jit_trigger_ids")
	_checks["north_76_jit_ids"] = jit_ids is Dictionary and int((jit_ids as Dictionary).size()) == 13
	var hurt := _find_triggered_hurt(hurt_records, "1")
	var jit := _find_jit(jit_records, "1")
	_checks["north_76_guard_flag"] = not hurt.is_empty() and bool(hurt.get("jit_guarded", false))
	if hurt.is_empty() or jit.is_empty():
		await _close_level(level)
		return

	hero.set_physics_process(false)
	hero.global_position = terrain.to_global((hurt["rect"] as Rect2).get_center())
	await _settle()
	terrain.call("_physics_process", 0.0)
	_checks["north_76_inactive_safe"] = is_equal_approx(float(hurt["last_hit"]), UNTOUCHED_LAST_HIT)

	hero.global_position = terrain.to_global((jit["rect"] as Rect2).get_center())
	await _settle()
	terrain.call("_physics_process", 0.0)
	_checks["north_76_jit_activates"] = bool(hurt["active"])

	hero.global_position = terrain.to_global((hurt["rect"] as Rect2).get_center())
	await _settle()
	terrain.call("_physics_process", 0.0)
	var first_hit := float(hurt["last_hit"])
	_checks["north_76_active_hurts"] = first_hit >= 0.0
	terrain.call("_physics_process", 0.0)
	_checks["north_76_cooldown"] = is_equal_approx(float(hurt["last_hit"]), first_hit)
	terrain.set("_clock", first_hit + 0.6)
	terrain.call("_physics_process", 0.0)
	_checks["north_76_repeat_hit"] = float(hurt["last_hit"]) > first_hit
	await _close_level(level)


func _check_static_hurt() -> void:
	var level := await _open_level(79)
	if level == null:
		_checks["north_79_open"] = false
		return
	_checks["north_79_open"] = true
	var hero: LongnvHero = level.get("_role") as LongnvHero
	var terrain := level.get_node_or_null("OriginalTerrain")
	if hero == null or terrain == null:
		_checks["north_79_actors"] = false
		await _close_level(level)
		return
	var hurt_records: Array = terrain.get("_hurt_zones")
	_checks["north_79_static_count"] = hurt_records.size() == 7
	if hurt_records.is_empty():
		await _close_level(level)
		return
	var hurt: Dictionary = hurt_records[0]
	_checks["north_79_not_guarded"] = not bool(hurt.get("jit_guarded", true))
	hero.set_physics_process(false)
	hero.global_position = terrain.to_global((hurt["rect"] as Rect2).get_center())
	await _settle()
	terrain.call("_physics_process", 0.0)
	_checks["north_79_static_hurts"] = float(hurt["last_hit"]) >= 0.0
	await _close_level(level)


func _find_triggered_hurt(records: Array, trigger_id: String) -> Dictionary:
	for record: Dictionary in records:
		var properties: Dictionary = record.get("properties", {})
		if str(properties.get("triggerID", "")) == trigger_id:
			return record
	return {}


func _find_jit(records: Array, trigger: String) -> Dictionary:
	for record: Dictionary in records:
		var properties: Dictionary = record.get("properties", {})
		if str(properties.get("trigger", "")) == trigger:
			return record
	return {}


func _open_level(number: int) -> Node:
	var packed := load("res://Scene/level/level_%d.tscn" % number) as PackedScene
	if packed == null:
		return null
	var level := packed.instantiate()
	add_child(level)
	level.set_physics_process(false)
	var control: Node = level.get("create_control") as Node
	if control != null and control.has_method("stop"):
		control.call("stop")
	var hero := level.get("_role") as Node
	if hero != null:
		hero.set_physics_process(false)
		hero.set("needProtect", true)
	await get_tree().create_timer(0.3).timeout
	var control_after: Node = level.get("create_control") as Node
	if control_after != null and control_after.has_method("stop"):
		control_after.call("stop")
	var monster := level.get("monster") as Node
	if monster != null:
		for enemy in monster.get_children():
			enemy.free()
	level.set("current_stage", 0)
	return level


func _close_level(level: Node) -> void:
	level.queue_free()
	await get_tree().create_timer(0.15).timeout
	RoleProp.source_player = null


func _settle() -> void:
	await get_tree().physics_frame
	await get_tree().process_frame


func _report() -> void:
	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

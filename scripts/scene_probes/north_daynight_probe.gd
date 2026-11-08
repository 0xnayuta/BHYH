extends Node

## 北俱芦洲 82 关昼夜机关探针：JIT 区段触发对应 DayNightEntity，15 秒后进入夜晚并压暗画面。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "NORTH_DAYNIGHT_PROBE_RESULT="
const TEARDOWN_MARKER := "NORTH_DAYNIGHT_PROBE_TEARDOWN"
const DAY_SECONDS := 15.0

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

	await _check_day_night()

	RoleProp.source_player = null
	PlayerData.player_data = saved_data
	MainSet.set_data = saved_settings
	Global.set_cd_path(saved_cd_path)
	_report()


func _check_day_night() -> void:
	var level := await _open_level(82)
	if level == null:
		_checks["north_82_open"] = false
		return
	_checks["north_82_open"] = true
	var hero: LongnvHero = level.get("_role") as LongnvHero
	var terrain := level.get_node_or_null("OriginalTerrain")
	if hero == null or terrain == null:
		_checks["north_82_actors"] = false
		await _close_level(level)
		return
	_checks["north_82_actors"] = true

	var triggers: Array = terrain.get("_jit_triggers")
	_checks["north_82_jit_bucket"] = triggers.size() == 3
	var day_night_records: Array = []
	for record: Dictionary in terrain.get("_source_objects"):
		if record.get("type") == "DayNightEntity":
			day_night_records.append(record)
	_checks["north_82_day_night_count"] = day_night_records.size() == 3

	# 进入第一段 JIT 区域（x=1200..1334），对应 triggerID=110 的昼夜实体。
	hero.set_physics_process(false)
	hero.global_position = terrain.to_global(Vector2(1260.0, 400.0))
	await _settle()
	terrain.call("_physics_process", 0.0)
	_checks["north_82_jit_activated"] = triggers.size() == 3 and bool(triggers[0].get("active", false))
	var first_target := _record_by_trigger_id(day_night_records, "110")
	var other_target := _record_by_trigger_id(day_night_records, "112")
	_checks["north_82_target_active"] = not first_target.is_empty() and bool(first_target.get("active", false))
	_checks["north_82_other_idle"] = not other_target.is_empty() and not bool(other_target.get("active", true))
	var start_at := float(first_target.get("start_at", -1.0))
	_checks["north_82_start_at"] = start_at >= 0.0

	# 一次性触发：再次经过同一区域不重置昼夜起点。
	terrain.call("_physics_process", 0.0)
	_checks["north_82_single_shot"] = is_equal_approx(float(first_target.get("start_at", -2.0)), start_at)

	var darkness := terrain.get("_darkness") as CanvasModulate
	_checks["north_82_darkness_bound"] = darkness != null
	if darkness != null:
		terrain.set("_clock", start_at + 1.0)
		terrain.call("_physics_process", 0.0)
		_checks["north_82_day_bright"] = darkness.color.is_equal_approx(Color.WHITE)
		terrain.set("_clock", start_at + DAY_SECONDS + 1.0)
		terrain.call("_physics_process", 0.0)
		_checks["north_82_night_dark"] = not darkness.color.is_equal_approx(Color.WHITE)
	await _close_level(level)


func _record_by_trigger_id(records: Array, trigger_id: String) -> Dictionary:
	for record: Dictionary in records:
		if str((record.get("properties") as Dictionary).get("triggerID", "")) == trigger_id:
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

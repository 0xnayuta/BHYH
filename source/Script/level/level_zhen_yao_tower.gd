extends Game4ImportedLevel

const TOWER_CURRENT_FLOOR_KEY := "镇妖塔当前层数"
const TOWER_MAX_FLOOR_KEY := "镇妖塔最高层数"
const TOWER_POINTS_KEY := "镇妖塔积分"
const TOWER_RUN_POINTS_KEY := "镇妖塔本次闯关积分"
const MAX_ACTIVE_MONSTERS := 6
const MONSTER_COUNT_PER_KIND := 10
const TOWER_DIFFICULTY_MULTIPLIERS := [1, 2, 3]
const SMALL_MONSTER_POOL := [
	3001,
	3002,
	3003,
	3004,
	3008,
	3009,
	3010,
	3011,
	1,
	2,
	7,
	9,
	10,
	13,
	14,
	15,
	16,
	21,
	26,
	27,
	39,
	40,
	51,
	52,
	53,
	54,
	58,
	73,
	74,
	75,
	76,
	80,
	81,
	82,
	86,
	87,
	88,
	90,
	92,
	115,
	118,
	119,
	120,
	122,
	123,
	124,
	1301,
]
const BOSS_POOL := [
	3005,
	3006,
	3019,
	3020,
	3,
	4,
	5,
	8,
	11,
	12,
	17,
	18,
	20,
	22,
	28,
	30,
	31,
	33,
	37,
	41,
	43,
	48,
	49,
	57,
	77,
	78,
	79,
	83,
	84,
	85,
	89,
	91,
	93,
	140,
	1401,
	1402,
	1403,
	1404,
	1405,
	1406,
	1407,
	1408,
	1409,
	1410,
	146,
	147,
	148,
	149,
	212,
	215,
	1460,
]
const SPAWN_X := [190.0, 305.0, 420.0, 535.0, 650.0, 765.0, 880.0]
const SPAWN_Y := [394.0, 405.0, 416.0, 427.0]
const TOWER_LEVEL_SCENE_PATH := "res://Scene/level/level_zhen_yao_tower.tscn"
const SMALL_MONSTER_BASE_STATS := {
	"hp": 3000000,
	"attack": 7000,
	"def": 500,
	"mdef": 500,
	"crit": 100,
	"miss": 50,
	"hit": 50,
	"armor_break": 500,
	"magic_break": 500,
}
const SMALL_MONSTER_GROWTH := {
	"hp": 500000,
	"attack": 500,
	"def": 105,
	"mdef": 105,
	"crit": 15,
	"miss": 30,
	"hit": 30,
	"armor_break": 105,
	"magic_break": 105,
}
const BOSS_BASE_STATS := {
	"hp": 7000000,
	"attack": 12000,
	"def": 1000,
	"mdef": 1000,
	"crit": 200,
	"miss": 80,
	"hit": 50,
	"armor_break": 1000,
	"magic_break": 1000,
}
const BOSS_GROWTH := {
	"hp": 1500000,
	"attack": 700,
	"def": 225,
	"mdef": 225,
	"crit": 30,
	"miss": 40,
	"hit": 40,
	"armor_break": 225,
	"magic_break": 225,
}

static var _pending_floor_plan: Dictionary = {}

var _tower_floor := 1
var _run_points := 0
var _pending_monsters: Array[Dictionary] = []
var _tower_floor_complete := false
var _tower_exit_can_use := false
var _runtime_ready := false
var _auto_next_floor_elapsed := -1.0

@onready var _tower_floor_label: Label = $CanvasLayer/TowerFloorLabel
@onready var _tower_hint_label: Label = $CanvasLayer/TowerHintLabel


func _ready() -> void:
	MainSet.set_data["Difficult"] = _tower_difficulty()
	display_name = "镇妖塔"
	stage_number = 0
	level_width_override = 1200.0
	super._ready()


func _configure_level_monsters() -> void:
	pass


func _apply_monster_count_multiplier() -> void:
	_count_multiplier = clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	MainSet.set_data["CreateMonsterCount"] = _count_multiplier
	_initialize_point_states()
	_spawn_runtime_ready = true


func _max_active_monsters() -> int:
	return MAX_ACTIVE_MONSTERS * _count_multiplier


func _preload_level_resources() -> void:
	var floor_number := _read_current_floor()
	await Global.preload_level_monster_runtime_resources(get_floor_monster_ids(floor_number))


func _prepare_level_runtime_resources() -> void:
	_apply_monster_count_multiplier()
	await _preload_level_resources()
	if not is_inside_tree():
		return
	_runtime_ready = true
	_load_tower_floor(_read_current_floor(), false)
	if create_control != null and is_instance_valid(create_control):
		create_control.start()


func _stage_count() -> int:
	return 1


func _screen_starts() -> Array:
	return [0.0]


func _screen_rights() -> Array:
	return [1200.0]


func _stage_trigger_x() -> Array:
	return [0.0]


func _birth_points() -> Array:
	return []


func _level_number() -> int:
	return 0


func get_level_monster_config(monster_id: int) -> Dictionary:
	var is_boss_monster := BOSS_POOL.has(monster_id)
	if not is_boss_monster and not SMALL_MONSTER_POOL.has(monster_id):
		return {}
	var base_stats: Dictionary = BOSS_BASE_STATS if is_boss_monster else SMALL_MONSTER_BASE_STATS
	var growth: Dictionary = BOSS_GROWTH if is_boss_monster else SMALL_MONSTER_GROWTH
	var config_floor := _tower_floor
	if not is_inside_tree():
		config_floor = _read_current_floor()
	var growth_steps := floori(float(maxi(1, config_floor)) / 5.0)
	var difficulty := _tower_difficulty()
	var difficulty_multiplier := float(TOWER_DIFFICULTY_MULTIPLIERS[difficulty])
	var base_hp := int(base_stats["hp"]) + int(growth["hp"]) * growth_steps
	var base_attack := int(base_stats["attack"]) + int(growth["attack"]) * growth_steps
	var base_def := int(base_stats["def"]) + int(growth["def"]) * growth_steps
	var base_mdef := int(base_stats["mdef"]) + int(growth["mdef"]) * growth_steps
	var base_crit := int(base_stats["crit"]) + int(growth["crit"]) * growth_steps
	var base_miss := int(base_stats["miss"]) + int(growth["miss"]) * growth_steps
	var base_hit := int(base_stats["hit"]) + int(growth["hit"]) * growth_steps
	var base_armor_break := int(base_stats["armor_break"]) + int(growth["armor_break"]) * growth_steps
	var base_magic_break := int(base_stats["magic_break"]) + int(growth["magic_break"]) * growth_steps
	return {
		"hp": int(base_hp * difficulty_multiplier),
		"attack": int(base_attack * difficulty_multiplier),
		"def": base_def,
		"mdef": base_mdef,
		"crit": base_crit,
		"miss": base_miss,
		"hit": base_hit,
		"armor_break": base_armor_break,
		"magic_break": base_magic_break,
		"nightmare": false,
	}


func clamp_monster_x_to_arena(target_x: float) -> float:
	return clampf(target_x, 80.0, 1120.0)


func _on_create_control_timeout() -> void:
	_spawn_next_tower_monster()


func _physics_process(delta: float) -> void:
	if _tower_exit_can_use and _tower_floor_complete and Input.is_action_just_pressed("Exit"):
		_advance_tower_floor()
		return
	super._physics_process(delta)
	if _auto_next_floor_elapsed >= 0.0:
		_auto_next_floor_elapsed += delta
		if _auto_next_floor_elapsed >= 0.8:
			_auto_next_floor_elapsed = -1.0
			_advance_tower_floor()
			return
	if not _runtime_ready or _tower_floor_complete:
		return
	if _pending_monsters.is_empty() and _get_alive_stage_monster_count() == 0:
		_complete_tower_floor()


func _spawn_next_tower_monster() -> void:
	if not _runtime_ready or _tower_floor_complete:
		return
	if _get_alive_stage_monster_count() >= _max_active_monsters():
		return
	if _pending_monsters.is_empty():
		return

	var spawn_data: Dictionary = _pending_monsters.pop_front()
	monster_group["stage_1"] = _pending_monsters.duplicate()
	var monster_id := int(spawn_data["monster"])
	var spawn_position: Vector2 = spawn_data["position"]
	var created := Global.create_monster(monster_id, monster, spawn_position)
	if created == null:
		push_error("镇妖塔无法创建怪物场景: %d" % monster_id)
		return
	created.set_meta("tower_floor", _tower_floor)
	created.set_meta("source_stage", 1)
	created.set_meta("tower_is_boss", BOSS_POOL.has(monster_id))

	call_deferred("_apply_tower_monster_config", created, monster_id)
	call_deferred("_apply_tower_facing", created, float(spawn_data["face"]))


func _apply_tower_monster_config(created: BaseMonster, monster_id: int) -> void:
	if created == null or not is_instance_valid(created):
		return
	var config := get_level_monster_config(monster_id)
	if config.is_empty():
		return
	created.apply_tower_monster_config(config)


func _apply_tower_facing(created: BaseMonster, face: float) -> void:
	if created == null or not is_instance_valid(created):
		return
	if created.monster_dir != null:
		created.monster_dir.scale.x = face
	if created.base_damage_box != null:
		created.base_damage_box.scale.x = face


func _load_tower_floor(floor_number: int, reset_role_position: bool = true) -> void:
	_tower_floor = maxi(1, floor_number)
	_run_points = maxi(0, int(PlayerData.player_data.get(TOWER_RUN_POINTS_KEY, 0)))
	current_stage = 1
	_pending_monsters = _build_floor_spawn_list(_tower_floor)
	monster_group["stage_1"] = _pending_monsters.duplicate()
	for stage_key in ["stage_2", "stage_3", "stage_4"]:
		monster_group[stage_key] = []
	_tower_floor_complete = false
	_tower_exit_can_use = false
	_auto_next_floor_elapsed = -1.0
	exit.visible = false
	exit_2.disabled = true
	if reset_role_position and _role != null:
		_role.position = Vector2(100.0, 340.0)
		_role.velocity = Vector2.ZERO
	_save_floor_progress(_tower_floor)
	_refresh_tower_labels()


func on_tower_monster_defeated(defeated_monster: BaseMonster) -> void:
	if defeated_monster == null or not is_instance_valid(defeated_monster):
		return
	if int(defeated_monster.get_meta("tower_floor", -1)) != _tower_floor:
		return
	var reward := _tower_floor * 2
	var is_tower_boss := bool(defeated_monster.get_meta("tower_is_boss", defeated_monster.is_boss))
	if is_tower_boss:
		reward = _tower_floor * 10
	var difficulty := _tower_difficulty()
	reward *= int(TOWER_DIFFICULTY_MULTIPLIERS[difficulty])
	_run_points += reward
	PlayerData.player_data[TOWER_RUN_POINTS_KEY] = _run_points
	PlayerData.player_data[TOWER_POINTS_KEY] = maxi(0, int(PlayerData.player_data.get(TOWER_POINTS_KEY, 0)) + reward)
	_refresh_tower_labels()


func _build_floor_spawn_list(floor_number: int) -> Array[Dictionary]:
	var plan := ensure_floor_plan(floor_number)
	var spawn_list: Variant = plan.get("spawn_list", [])
	if spawn_list is Array:
		var result: Array[Dictionary] = []
		for spawn_value in spawn_list:
			if spawn_value is Dictionary:
				result.append((spawn_value as Dictionary).duplicate(true))
		return result
	return []


static func prepare_floor_plan(floor_number: int) -> Dictionary:
	floor_number = maxi(1, floor_number)
	var count_multiplier := clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(Time.get_ticks_usec()) ^ (floor_number * 7919)
	var kinds: Array = SMALL_MONSTER_POOL.duplicate()
	kinds.shuffle()
	var selected_kinds: Array = kinds.slice(0, 3)
	var result: Array[Dictionary] = []
	var monster_ids: Array = selected_kinds.duplicate()

	if floor_number % 5 == 0:
		var boss_id := int(BOSS_POOL[rng.randi_range(0, BOSS_POOL.size() - 1)])
		monster_ids.append(boss_id)
		for _boss_index in range(count_multiplier):
			result.append({"monster": boss_id, "position": Vector2(850.0, 390.0), "face": 1.0})

	for kind_value in selected_kinds:
		for _index in range(MONSTER_COUNT_PER_KIND * count_multiplier):
			var x := float(SPAWN_X[rng.randi_range(0, SPAWN_X.size() - 1)])
			var y := float(SPAWN_Y[rng.randi_range(0, SPAWN_Y.size() - 1)])
			result.append({"monster": int(kind_value), "position": Vector2(x, y), "face": 1.0})
	_pending_floor_plan = {
		"floor": floor_number,
		"count_multiplier": count_multiplier,
		"monster_ids": monster_ids,
		"spawn_list": result,
	}
	return _pending_floor_plan.duplicate(true)


static func ensure_floor_plan(floor_number: int) -> Dictionary:
	floor_number = maxi(1, floor_number)
	var count_multiplier := clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	if (
		int(_pending_floor_plan.get("floor", 0)) != floor_number
		or int(_pending_floor_plan.get("count_multiplier", 0)) != count_multiplier
	):
		return prepare_floor_plan(floor_number)
	return _pending_floor_plan.duplicate(true)


static func get_floor_monster_ids(floor_number: int) -> Array:
	var plan := ensure_floor_plan(floor_number)
	var monster_ids: Variant = plan.get("monster_ids", [])
	return (monster_ids as Array).duplicate() if monster_ids is Array else []


func _complete_tower_floor() -> void:
	_tower_floor_complete = true
	_tower_exit_can_use = false
	exit.visible = true
	exit_2.set_deferred("disabled", false)
	_tower_hint_label.text = "本次积分 %d，前往出口" % _run_points
	_tower_hint_label.visible = true
	if bool(MainSet.set_data.get("镇妖塔自动下一层", false)):
		_tower_exit_can_use = true
		_auto_next_floor_elapsed = 0.0


func check_can_exit() -> bool:
	return false


func one_check_can_exit() -> bool:
	return false


func _on_exit_2_body_entered(body: Node2D) -> void:
	if body == _role and _tower_floor_complete:
		can_exit = true
		_tower_exit_can_use = true


func _on_exit_2_body_exited(body: Node2D) -> void:
	if body == _role:
		can_exit = false
		_tower_exit_can_use = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Global.change_scene("res://Scene/main_menu/map_0.tscn")


func _advance_tower_floor() -> void:
	var next_floor := _tower_floor + 1
	_runtime_ready = false
	_tower_exit_can_use = false
	if create_control != null and is_instance_valid(create_control):
		create_control.stop()
	_save_floor_progress(next_floor)
	if RoleProp.roleprop != null:
		RoleProp.current_hp = RoleProp.roleprop.Hp
		RoleProp.current_mp = RoleProp.roleprop.Mp
	prepare_floor_plan(next_floor)
	MemoryClass.request_save("tower_floor_advance")
	Global.change_scene(TOWER_LEVEL_SCENE_PATH, true)


func _read_current_floor() -> int:
	return maxi(1, int(PlayerData.player_data.get(TOWER_CURRENT_FLOOR_KEY, 1)))


func _tower_difficulty() -> int:
	return clampi(int(MainSet.set_data.get("Difficult", 0)), 0, 2)


func _save_floor_progress(floor_number: int) -> void:
	PlayerData.player_data[TOWER_CURRENT_FLOOR_KEY] = floor_number
	PlayerData.player_data[TOWER_MAX_FLOOR_KEY] = maxi(
		int(PlayerData.player_data.get(TOWER_MAX_FLOOR_KEY, 1)), floor_number
	)
	PlayerData.player_data[TOWER_POINTS_KEY] = maxi(0, int(PlayerData.player_data.get(TOWER_POINTS_KEY, 0)))


func _refresh_tower_labels() -> void:
	if _tower_floor_label != null:
		_tower_floor_label.text = "第 %d 层" % _tower_floor
	if _tower_hint_label != null:
		_tower_hint_label.text = "本次积分 %d" % _run_points
		_tower_hint_label.visible = true

extends BaseLevel
class_name Game4ImportedLevel

const DEFAULT_LEVEL_BGM_PATH := "res://Music/level/zhanchangbg.mp3"

const SOUTH_CONTINENT_BGM_BY_LEVEL := {
	47: "res://Music/level/original_bg_01.mp3",
	48: "res://Music/level/original_bg_01.mp3",
	49: "res://Music/level/original_bg_01.mp3",
	50: "res://Music/level/original_bg_02.mp3",
	51: "res://Music/level/original_bg_02.mp3",
	52: "res://Music/level/original_bg_02.mp3",
	53: "res://Music/level/original_bg_03.mp3",
	54: "res://Music/level/original_bg_03.mp3",
	55: "res://Music/level/original_bg_03.mp3",
	56: "res://Music/level/original_bg_04.mp3",
	57: "res://Music/level/original_bg_04.mp3",
	58: "res://Music/level/original_bg_04.mp3",
	59: "res://Music/level/original_bg_05.mp3",
	60: "res://Music/level/original_bg_05.mp3",
	61: "res://Music/level/original_bg_05.mp3",
	62: "res://Music/level/original_bg_04.mp3",
}
const EAST_CONTINENT_BGM_BY_LEVEL := {
	66: "res://Music/level/original_bg_06.mp3",
	67: "res://Music/level/original_bg_07.mp3",
	68: "res://Music/level/original_bg_08.mp3",
}

@export var source_map: String
@export var display_name: String
@export var stage_number: int
@export var background_offset_y: float
@export var fixed_layers: PackedStringArray = PackedStringArray(["bg30"])
@export var level_width_override: float
@export var background_baked: bool
@export var spawn_position := Vector2(32, 448)

var _level_width: float = 1200.0
var _screen_left_wall: CollisionShape2D
var _screen_right_wall: CollisionShape2D
var _camera_left_limit := 0.0
var _camera_room := 1
var _count_multiplier := 1
var _point_states: Dictionary = {}
var _stage_started: Dictionary = {}
var _spawn_runtime_ready := false


func _ready() -> void:
	_play_level_bgm(_level_bgm_path())
	_read_level_width_from_scene()
	Global.current_level = display_name
	level_stage = stage_number
	Global.game_over = 1
	if is_two_scene == null:
		is_two_scene = false
	_create_screen_walls()
	var stage_total := maxi(4, _stage_count())
	monster_group.clear()
	monster_position_x.clear()
	monster_position_y.clear()
	for stage in range(1, stage_total + 1):
		var stage_key := _stage_key(stage)
		monster_group[stage_key] = []
		monster_position_x[stage_key] = []
		monster_position_y[stage_key] = []
	_configure_level_monsters()
	super._ready()
	if _role != null:
		_role.position = spawn_position
	_update_screen_bounds()


func _level_bgm_path() -> String:
	var level_number := _level_number()
	if SOUTH_CONTINENT_BGM_BY_LEVEL.has(level_number):
		return SOUTH_CONTINENT_BGM_BY_LEVEL[level_number]
	if EAST_CONTINENT_BGM_BY_LEVEL.has(level_number):
		return EAST_CONTINENT_BGM_BY_LEVEL[level_number]
	return DEFAULT_LEVEL_BGM_PATH


func _play_level_bgm(bgm_path: String) -> void:
	if bgm_path == "":
		return
	var bgm_stream := Global.get_cached_audio(bgm_path)
	if bgm_stream is AudioStreamMP3:
		bgm_stream.loop = true
	Global.get_audio_runtime().add_bgm(self, bgm_path)


func _configure_level_monsters() -> void:
	for stage in range(1, _stage_count() + 1):
		var stage_key := _stage_key(stage)
		monster_group[stage_key] = []
		monster_position_x[stage_key] = []
		monster_position_y[stage_key] = []

	for point in _birth_points():
		var stage_key := _stage_key(int(point["stage"]))
		var spawn_position: Vector2 = point["position"]
		for _unit in range(int(point["total"])):
			monster_group[stage_key].append(int(point["monster"]))
			monster_position_x[stage_key].append(spawn_position.x)
			monster_position_y[stage_key].append(spawn_position.y)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_stage_progression()
	_update_screen_bounds(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = current_stage >= 1 and current_stage < _stage_count() and check_can_pass()


func _apply_monster_count_multiplier() -> void:
	_count_multiplier = clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	MainSet.set_data["CreateMonsterCount"] = _count_multiplier

	if _count_multiplier > 1:
		for point in _birth_points():
			if bool(point.get("ignore_count_multiplier", false)):
				continue
			var stage_key := _stage_key(int(point["stage"]))
			var spawn_position: Vector2 = point["position"]
			for _copy in range(1, _count_multiplier):
				for _unit in range(int(point["total"])):
					monster_group[stage_key].append(int(point["monster"]))
					monster_position_x[stage_key].append(spawn_position.x)
					monster_position_y[stage_key].append(spawn_position.y)

	_initialize_point_states()
	_spawn_runtime_ready = true


func _initialize_point_states() -> void:
	_point_states.clear()
	_stage_started.clear()
	for point in _birth_points():
		var point_id := int(point["point"])
		var point_multiplier := 1 if bool(point.get("ignore_count_multiplier", false)) else _count_multiplier
		_point_states[point_id] = {
			"started": false,
			"spawned": 0,
			"target": int(point["total"]) * point_multiplier,
			"instances": [],
		}


func _preload_level_resources() -> void:
	var level_monster_ids: Array = []
	var first_stage_ids: Variant = monster_group.get(_stage_key(1), [])
	if first_stage_ids is Array:
		level_monster_ids.append_array(first_stage_ids)
	_stage_preload_requested[1] = true
	await Global.preload_level_monster_runtime_resources(level_monster_ids)


func _request_stage_resource_preload(stage: int) -> void:
	if stage < 1 or stage > _stage_count() or _stage_preload_requested.has(stage):
		return
	_stage_preload_requested[stage] = true
	var stage_ids: Variant = monster_group.get(_stage_key(stage), [])
	if not stage_ids is Array or stage_ids.is_empty():
		return
	call_deferred("_preload_stage_resources", (stage_ids as Array).duplicate())


func _preload_stage_resources(monster_ids: Array) -> void:
	await Global.preload_level_monster_runtime_resources(monster_ids)


func _on_create_control_timeout() -> void:
	_update_stage_progression()
	_spawn_next_protected_unit()


func _update_stage_progression() -> void:
	if not _spawn_runtime_ready or _role == null:
		return
	var role_x := float(_role.position.x)
	if current_stage == 0:
		_start_stage(1)
		return
	if current_stage < _stage_count() and check_can_pass():
		var next_trigger_x: float = _stage_trigger_x()[current_stage]
		if role_x >= next_trigger_x:
			_start_stage(current_stage + 1)


func _start_stage(stage: int) -> void:
	if _stage_started.has(stage) or not advance_stage(stage):
		return
	_stage_started[stage] = true
	_request_stage_resource_preload(stage + 1)


func _spawn_next_protected_unit() -> void:
	if not _spawn_runtime_ready or current_stage < 1 or current_stage > _stage_count():
		return
	if _get_alive_stage_monster_count() >= 6 * _count_multiplier:
		return

	for point in _birth_points():
		if int(point["stage"]) != current_stage:
			continue
		var point_id := int(point["point"])
		var state: Dictionary = _point_states[point_id]
		if not bool(state["started"]):
			if not _point_dependency_satisfied(point):
				continue
			state["started"] = true

		if int(state["spawned"]) >= int(state["target"]):
			continue
		_spawn_birth_point_unit(point, state)
		return


func _point_dependency_satisfied(point: Dictionary) -> bool:
	var after_spawn := int(point["after_spawn"])
	if after_spawn > 0:
		return _point_finished_spawning(after_spawn)
	var after_dead := int(point["after_dead"])
	if after_dead > 0:
		return _point_all_dead(after_dead)
	return true


func _point_finished_spawning(point_id: int) -> bool:
	if not _point_states.has(point_id):
		return false
	var state: Dictionary = _point_states[point_id]
	return int(state["spawned"]) >= int(state["target"])


func _point_all_dead(point_id: int) -> bool:
	if not _point_finished_spawning(point_id):
		return false
	var state: Dictionary = _point_states[point_id]
	var alive_instances: Array = []
	for instance_value in state["instances"]:
		if instance_value == null or not is_instance_valid(instance_value):
			continue
		var instance_node := instance_value as Node
		if instance_node != null and _is_stage_monster_node(instance_node):
			alive_instances.append(instance_node)
	state["instances"] = alive_instances
	return alive_instances.is_empty()


func _spawn_birth_point_unit(point: Dictionary, state: Dictionary) -> bool:
	var point_id := int(point["point"])
	var monster_id := int(point["monster"])
	var spawn_position: Vector2 = point["position"]
	var created := Global.create_monster(monster_id, monster, spawn_position)
	if created == null:
		return false

	created.set_meta("allow_position_y_over_800", _allows_deep_monster_positions())
	created.set_meta("source_birth_point", point_id)
	created.set_meta("source_stage", int(point["stage"]))
	call_deferred("_apply_spawn_facing", created, float(point["face"]))
	(state["instances"] as Array).append(created)
	state["spawned"] = int(state["spawned"]) + 1
	_remove_pending_spawn(int(point["stage"]), monster_id, spawn_position)
	return true


func replace_stage_monster_instance(old_node: BaseMonster, new_node: BaseMonster) -> void:
	if old_node == null or new_node == null:
		return
	var point_id := int(old_node.get_meta("source_birth_point", -1))
	if point_id < 0 or not _point_states.has(point_id):
		return
	var state: Dictionary = _point_states[point_id]
	var instances: Array = state.get("instances", []) as Array
	var old_index := instances.find(old_node)
	if old_index >= 0:
		instances[old_index] = new_node
	elif new_node not in instances:
		instances.append(new_node)
	state["instances"] = instances


func _allows_deep_monster_positions() -> bool:
	return false


func _apply_spawn_facing(created: BaseMonster, face: float) -> void:
	if created == null or not is_instance_valid(created):
		return
	if created.monster_dir != null:
		created.monster_dir.scale.x = face
	if created.base_damage_box != null:
		created.base_damage_box.scale.x = face


func _remove_pending_spawn(stage: int, monster_id: int, spawn_position: Vector2) -> void:
	var stage_key := _stage_key(stage)
	var ids: Array = monster_group[stage_key]
	var positions_x: Array = monster_position_x[stage_key]
	var positions_y: Array = monster_position_y[stage_key]
	var remove_index := -1
	for index in range(ids.size()):
		if int(ids[index]) != monster_id:
			continue
		if (
			is_equal_approx(float(positions_x[index]), spawn_position.x)
			and is_equal_approx(float(positions_y[index]), spawn_position.y)
		):
			remove_index = index
			break
	if remove_index < 0:
		remove_index = ids.find(monster_id)
	if remove_index < 0:
		return
	ids.remove_at(remove_index)
	positions_x.remove_at(remove_index)
	positions_y.remove_at(remove_index)


func check_can_create(stage: int) -> bool:
	if stage < 1 or stage > _stage_count():
		return false
	var stage_key := _stage_key(stage)
	return _get_alive_stage_monster_count() < 6 * _count_multiplier and not monster_group[stage_key].is_empty()


func check_can_pass() -> bool:
	if current_stage < 1 or current_stage > _stage_count():
		return false
	var stage_key := _stage_key(current_stage)
	return (
		monster_group[stage_key].is_empty()
		and _stage_points_finished(current_stage)
		and _get_alive_stage_monster_count() == 0
	)


func check_can_exit() -> bool:
	return current_stage == _stage_count() and check_can_pass()


func one_check_can_exit() -> bool:
	return check_can_exit()


func _stage_points_finished(stage: int) -> bool:
	for point in _birth_points():
		if int(point["stage"]) != stage:
			continue
		var state: Dictionary = _point_states.get(int(point["point"]), {})
		if state.is_empty() or int(state["spawned"]) < int(state["target"]):
			return false
	return true


func _create_screen_walls() -> void:
	var wall_node := get_node_or_null("wall") as StaticBody2D
	if wall_node == null:
		return
	var wall_shape := RectangleShape2D.new()
	wall_shape.size = Vector2(10, 1800)
	var left_wall := wall_node.get_node_or_null("screen_left_wall") as CollisionShape2D
	if left_wall == null:
		left_wall = CollisionShape2D.new()
		left_wall.name = "screen_left_wall"
		wall_node.add_child(left_wall)
	_screen_left_wall = left_wall
	_screen_left_wall.position = Vector2(-5, -400)
	_screen_left_wall.shape = wall_shape

	var right_wall := wall_node.get_node_or_null("screen_right_wall") as CollisionShape2D
	if right_wall == null:
		right_wall = CollisionShape2D.new()
		right_wall.name = "screen_right_wall"
		wall_node.add_child(right_wall)
	_screen_right_wall = right_wall
	_screen_right_wall.position = Vector2(_screen_rights()[0] + 5.0, -400)
	_screen_right_wall.shape = wall_shape.duplicate()


func _update_screen_bounds(delta: float = 0.0) -> void:
	var stage_for_bounds := clampi(current_stage, 1, _stage_count())
	var screen_index := stage_for_bounds - 1
	var screen_right: float = _screen_rights()[screen_index]
	var stage_clear := current_stage >= 1 and check_can_pass()
	var open_right := screen_right
	if current_stage >= 1 and current_stage < _stage_count() and stage_clear:
		open_right = float(_screen_rights()[screen_index + 1])

	if current_stage >= 1 and current_stage < _stage_count() and stage_clear and _role != null:
		if float(_role.position.x) >= screen_right - 100.0:
			_camera_room = maxi(_camera_room, current_stage + 1)
	_camera_room = clampi(maxi(_camera_room, stage_for_bounds), 1, _stage_count())
	var camera_target_left: float = _screen_starts()[_camera_room - 1]
	if delta > 0.0:
		_camera_left_limit = move_toward(_camera_left_limit, camera_target_left, 600.0 * delta)

	if is_instance_valid(_screen_left_wall):
		_screen_left_wall.position.x = _camera_left_limit - 5.0
		_screen_left_wall.disabled = false
	if is_instance_valid(_screen_right_wall):
		_screen_right_wall.position.x = open_right + 5.0
		_screen_right_wall.disabled = false
	if my_camera != null:
		my_camera.max_left = _camera_left_limit
		my_camera.max_right = maxf(float(_screen_rights()[_camera_room - 1]), 1200.0)


func _stage_count() -> int:
	return 4


func _stage_key(stage: int) -> String:
	return "stage_%d" % stage


func _screen_starts() -> Array:
	return [0.0]


func _screen_rights() -> Array:
	return [_level_width]


func _stage_trigger_x() -> Array:
	return [0.0]


func _birth_points() -> Array:
	return []


func get_level_monster_config(_monster_id: int) -> Dictionary:
	return {}


func _level_number() -> int:
	return 0


func set_through() -> void:
	pass


func _read_level_width_from_scene() -> void:
	var right_wall := get_node_or_null("wall/right_wall") as CollisionShape2D
	if right_wall != null and right_wall.shape is RectangleShape2D:
		var wall_shape := right_wall.shape as RectangleShape2D
		_level_width = maxf(1200.0, right_wall.position.x - wall_shape.size.x * 0.5)
	elif level_width_override > 0.0:
		_level_width = level_width_override

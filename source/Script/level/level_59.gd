extends Game4ImportedLevel

const WUTAI_STAGE_COUNT := 5
const WUTAI_STAGE_HEIGHT := 1312.0
const WUTAI_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const WUTAI_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const WUTAI_TRIGGER_X := [236.0, 1279.0, 2343.0, 3289.0, 4298.0]
const CAMERA_VIEW_WIDTH := 1200.0
const SOURCE_CAMERA_VIEW_HEIGHT := 590.0
const CAMERA_LIMIT_SPEED := 600.0
const CAMERA_UNLOCK_MARGIN := 100.0

const LEVEL_59_MONSTER_SCENES := {
	3065: "res://Scene/monster/monster_3065.tscn",
	3066: "res://Scene/monster/monster_3066.tscn",
	3068: "res://Scene/monster/monster_3068.tscn",
	3069: "res://Scene/monster/monster_3069.tscn",
}

const LEVEL_59_MONSTER_DATA := {
	3065:
	{
		"name": "鸟身女妖",
		"level": 90,
		"hp": 12295000,
		"attack": 32000,
		"def": 4500,
		"mdef": 4500,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4500,
		"magic_break": 4500,
		"speed": 12.5,
		"min_range": 75.0,
		"range": 100.0,
		"vertical_range": 100.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 3334},
		},
	},
	3066:
	{
		"name": "泥偶精",
		"level": 90,
		"hp": 12295000,
		"attack": 32000,
		"def": 4500,
		"mdef": 4500,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4500,
		"magic_break": 4500,
		"speed": 8.75,
		"min_range": 20.0,
		"range": 110.0,
		"sight": 940.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 3334},
		},
	},
	3068:
	{
		"name": "核桃精",
		"level": 90,
		"hp": 12295000,
		"attack": 32000,
		"def": 4500,
		"mdef": 4500,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4500,
		"magic_break": 4500,
		"speed": 10.0,
		"min_range": 0.0,
		"range": 105.0,
		"sight": 940.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 3334},
		},
	},
	3069:
	{
		"name": "金光孔雀",
		"level": 90,
		"hp": 25000000,
		"attack": 48000,
		"def": 6700,
		"mdef": 6700,
		"crit": 700,
		"miss": 490,
		"hit": 500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 6700,
		"magic_break": 6700,
		"speed": 12.5,
		"range": 720.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "pgs_5", "min_value": 2, "max_value": 5, "chance": 0.15},
			{"name": "zqwqsszzs", "value": 1, "chance": 0.1},
			{"name": "zqwqblzzs", "value": 1, "chance": 0.1},
			{"name": "zqwqnzzzs", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 0.5, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-4.0, -3.0], "kind": "magic", "protect": 6668},
		},
	},
}

const WUTAI_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3066,
		"position": Vector2(1041, 812.6),
		"total": 5,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3066,
		"position": Vector2(101, 936.8),
		"total": 5,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3065,
		"position": Vector2(2039, 583),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3068,
		"position": Vector2(1127, 796),
		"total": 4,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3065,
		"position": Vector2(1109, 683),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 5
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3066,
		"position": Vector2(2046, 676),
		"total": 4,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3065,
		"position": Vector2(2983, 469),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 10,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3066,
		"position": Vector2(2150, 669),
		"total": 4,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3065,
		"position": Vector2(2147, 556),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 9
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3068,
		"position": Vector2(2983, 535),
		"total": 4,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 11,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 4,
		"monster": 3068,
		"position": Vector2(3186, 519),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 4,
		"monster": 3068,
		"position": Vector2(4057, 419),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3065,
		"position": Vector2(3454, 284),
		"total": 3,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 14,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3068,
		"position": Vector2(3182, 520),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 15
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3065,
		"position": Vector2(3780, 282),
		"total": 3,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 16,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3068,
		"position": Vector2(4050, 418),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 17,
		"after_dead": 0
	},
	{
		"point": 30,
		"stage": 5,
		"monster": 3069,
		"position": Vector2(4622, 376),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
]

const STONE_DAMAGE := 277
const STONE_INTERVAL_SECONDS := 20.0
const STONE_HIT_INTERVAL_SECONDS := 0.334
const STONE_HIT_INTERVAL_MSEC := 334
const STONE_TERRAIN_RELEASE_X := 100.0
const STONE_GROUP := "level_59_stones"
const STONE_TEXTURES := [
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_01.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_01.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_01.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_04.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_04.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_04.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_07.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_07.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_07.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_10.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_10.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_10.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_13.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_13.png"),
	preload("res://Art/level/level_59_60_terrain/stone_1021_idle_13.png"),
]

const STONE_FACTORIES := [
	{"node": "StoneFactory100", "screen": 2, "position": Vector2(2252, 771), "velocity": Vector2(-500, 0)},
	{"node": "StoneFactory101", "screen": 3, "position": Vector2(3249, 643), "velocity": Vector2(-1000, 0)},
	{"node": "StoneFactory102", "screen": 4, "position": Vector2(4223, 524), "velocity": Vector2(-500, 0)},
]

var _stone_factory_started: Dictionary = {}
var _active_stones: Array[RigidBody2D] = []
var _stone_frames: SpriteFrames
var _missing_scene_reported: Dictionary = {}


func _ready() -> void:
	is_two_scene = false
	super._ready()
	_update_screen_bounds()
	if _role != null:
		_role.position = Vector2(31, 446)
	if my_camera != null:
		my_camera.max_bottom = WUTAI_STAGE_HEIGHT
		my_camera.position.y = maxf((SOURCE_CAMERA_VIEW_HEIGHT - get_viewport_rect().size.y) * 0.5, 0.0)
	_stone_frames = _build_stone_frames()
	for factory_index in range(STONE_FACTORIES.size()):
		var area := get_node_or_null("StoneFactories/%s" % STONE_FACTORIES[factory_index]["node"]) as Area2D
		if area != null:
			area.body_entered.connect(_on_stone_factory_body_entered.bind(factory_index))


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not is_inside_tree():
		return
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = current_stage >= 1 and current_stage < _stage_count() and check_can_pass()
	for index in range(_active_stones.size() - 1, -1, -1):
		var stone := _active_stones[index]
		if not is_instance_valid(stone) or stone.get_parent() != self:
			_active_stones.remove_at(index)
			continue
		if stone.position.x <= -50.0:
			stone.queue_free()
			_active_stones.remove_at(index)
		elif stone.position.x <= STONE_TERRAIN_RELEASE_X and stone.collision_mask != 0:
			stone.collision_mask = 0
			stone.linear_velocity.x = minf(stone.linear_velocity.x, float(stone.get_meta("source_velocity_x", -500.0)))


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


func _apply_monster_count_multiplier() -> void:
	_count_multiplier = clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	MainSet.set_data["CreateMonsterCount"] = _count_multiplier

	if _count_multiplier > 1:
		for stage in range(1, _stage_count() + 1):
			var stage_key := _stage_key(stage)
			var original_ids: Array = monster_group[stage_key].duplicate()
			var original_x: Array = monster_position_x[stage_key].duplicate()
			var original_y: Array = monster_position_y[stage_key].duplicate()
			for _copy in range(1, _count_multiplier):
				monster_group[stage_key].append_array(original_ids)
				monster_position_x[stage_key].append_array(original_x)
				monster_position_y[stage_key].append_array(original_y)

	_initialize_point_states()
	_spawn_runtime_ready = true


func _initialize_point_states() -> void:
	_point_states.clear()
	_stage_started.clear()
	for point in _birth_points():
		var point_id := int(point["point"])
		_point_states[point_id] = {
			"started": false,
			"spawned": 0,
			"target": int(point["total"]) * _count_multiplier,
			"instances": [],
		}


func _request_stage_resource_preload(stage: int) -> void:
	if stage < 1 or stage > _stage_count() or _stage_preload_requested.has(stage):
		return
	_stage_preload_requested[stage] = true
	var stage_ids: Variant = monster_group.get(_stage_key(stage), [])
	if not stage_ids is Array or stage_ids.is_empty():
		return
	call_deferred("_preload_stage_resources", (stage_ids as Array).duplicate())


func _on_create_control_timeout() -> void:
	_update_stage_progression()
	_spawn_next_protected_unit()


func _update_stage_progression() -> void:
	if not _spawn_runtime_ready or _role == null:
		return
	var role_x := float(_role.position.x)
	if current_stage == 0:
		if role_x >= _stage_trigger_x()[0]:
			_start_stage(1)
		return
	if current_stage < _stage_count() and check_can_pass():
		var next_trigger_x: float = _stage_trigger_x()[current_stage]
		if role_x >= next_trigger_x:
			_start_stage(current_stage + 1)


func _start_stage(stage: int) -> void:
	if stage < 1 or stage > _stage_count() or _stage_started.has(stage):
		return
	current_stage = stage
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
		if not _missing_scene_reported.has(monster_id):
			_missing_scene_reported[monster_id] = true
			push_error("Level %d could not create monster scene for id %d" % [_level_number(), monster_id])
		return false

	created.set_meta("allow_position_y_over_800", true)
	created.set_meta("source_birth_point", point_id)
	created.set_meta("source_stage", int(point["stage"]))
	call_deferred("_apply_spawn_facing", created, float(point["face"]))
	(state["instances"] as Array).append(created)
	state["spawned"] = int(state["spawned"]) + 1
	_remove_pending_spawn(int(point["stage"]), monster_id, spawn_position)
	return true


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
	var wall_node := get_node_or_null("screen_walls") as StaticBody2D
	if wall_node == null:
		wall_node = StaticBody2D.new()
		wall_node.name = "screen_walls"
		wall_node.collision_layer = 32
		wall_node.collision_mask = 0
		add_child(wall_node)
	var wall_shape := RectangleShape2D.new()
	wall_shape.size = Vector2(10, 1800)
	_screen_left_wall = wall_node.get_node_or_null("screen_left_wall") as CollisionShape2D
	if _screen_left_wall == null:
		_screen_left_wall = CollisionShape2D.new()
		_screen_left_wall.name = "screen_left_wall"
		wall_node.add_child(_screen_left_wall)
	_screen_left_wall.position = Vector2(-5, -400)
	_screen_left_wall.shape = wall_shape

	_screen_right_wall = wall_node.get_node_or_null("screen_right_wall") as CollisionShape2D
	if _screen_right_wall == null:
		_screen_right_wall = CollisionShape2D.new()
		_screen_right_wall.name = "screen_right_wall"
		wall_node.add_child(_screen_right_wall)
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
		if float(_role.position.x) >= screen_right - CAMERA_UNLOCK_MARGIN:
			_camera_room = maxi(_camera_room, current_stage + 1)
	_camera_room = clampi(maxi(_camera_room, stage_for_bounds), 1, _stage_count())
	var camera_target_left: float = _screen_starts()[_camera_room - 1]
	if delta > 0.0:
		_camera_left_limit = move_toward(_camera_left_limit, camera_target_left, CAMERA_LIMIT_SPEED * delta)

	if is_instance_valid(_screen_left_wall):
		_screen_left_wall.position.x = _camera_left_limit - 5.0
		_screen_left_wall.disabled = false
	if is_instance_valid(_screen_right_wall):
		_screen_right_wall.position.x = open_right + 5.0
		_screen_right_wall.disabled = false
	if my_camera != null:
		my_camera.max_left = _camera_left_limit
		my_camera.max_right = maxf(float(_screen_rights()[_camera_room - 1]), CAMERA_VIEW_WIDTH)


func _stage_count() -> int:
	return WUTAI_STAGE_COUNT


func _screen_starts() -> Array:
	return WUTAI_SCREEN_STARTS


func _screen_rights() -> Array:
	return WUTAI_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return WUTAI_TRIGGER_X


func _birth_points() -> Array:
	return WUTAI_BIRTH_POINTS


func _stage_key(stage: int) -> String:
	return "stage_%d" % stage


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_59_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _level_number() -> int:
	return 59


func _build_stone_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 15.0)
	for texture in STONE_TEXTURES:
		frames.add_frame("idle", texture)
	return frames


func _on_stone_factory_body_entered(body: Node2D, factory_index: int) -> void:
	if body != _role or _stone_factory_started.has(factory_index):
		return
	_stone_factory_started[factory_index] = true
	_spawn_factory_stone(factory_index)
	var timer := Timer.new()
	timer.name = "StoneFactoryTimer%d" % factory_index
	timer.wait_time = STONE_INTERVAL_SECONDS
	timer.timeout.connect(_spawn_factory_stone.bind(factory_index))
	add_child(timer)
	timer.start()


func _spawn_factory_stone(factory_index: int) -> void:
	if factory_index < 0 or factory_index >= STONE_FACTORIES.size():
		return
	var factory: Dictionary = STONE_FACTORIES[factory_index]
	if current_stage > int(factory["screen"]):
		return

	var stone := RigidBody2D.new()
	stone.name = "Stone1021_%d" % Time.get_ticks_msec()
	stone.position = factory["position"]
	stone.collision_layer = 1
	stone.collision_mask = 1
	stone.mass = 4.0
	stone.contact_monitor = true
	stone.max_contacts_reported = 8
	stone.linear_velocity = factory["velocity"]
	stone.set_meta("source_velocity_x", float((factory["velocity"] as Vector2).x))
	stone.add_to_group(STONE_GROUP)
	add_child(stone)
	_active_stones.append(stone)

	var sprite := AnimatedSprite2D.new()
	sprite.position = Vector2(-1, -112)
	sprite.sprite_frames = _stone_frames
	sprite.animation = "idle"
	sprite.play()
	stone.add_child(sprite)

	var body_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 80.0
	body_shape.position = Vector2(-1, -112)
	body_shape.shape = circle
	stone.add_child(body_shape)

	var damage_area := Area2D.new()
	damage_area.name = "DamageArea"
	damage_area.collision_layer = 0
	damage_area.collision_mask = _role.collision_layer if _role != null else 18
	damage_area.monitoring = true
	damage_area.position = Vector2(-1, -112)
	var damage_shape := CollisionShape2D.new()
	var damage_circle := CircleShape2D.new()
	damage_circle.radius = 76.0
	damage_shape.shape = damage_circle
	damage_area.add_child(damage_shape)
	damage_area.body_entered.connect(_on_stone_damage_body_entered.bind(damage_area))
	stone.add_child(damage_area)

	var damage_timer := Timer.new()
	damage_timer.name = "DamageTimer"
	damage_timer.wait_time = STONE_HIT_INTERVAL_SECONDS
	damage_timer.timeout.connect(_on_stone_damage_timeout.bind(damage_area))
	stone.add_child(damage_timer)
	damage_timer.start()


func _on_stone_damage_body_entered(body: Node2D, damage_area: Area2D) -> void:
	if body == _role:
		_apply_stone_damage(damage_area)


func _on_stone_damage_timeout(damage_area: Area2D) -> void:
	if not is_instance_valid(damage_area) or _role == null:
		return
	for body in damage_area.get_overlapping_bodies():
		if body == _role:
			_apply_stone_damage(damage_area)
			return


func _apply_stone_damage(damage_area: Area2D) -> void:
	if _role == null or not _role.has_method("effect_reducehp"):
		return
	var now := Time.get_ticks_msec()
	var last_hit := int(damage_area.get_meta("last_role_hit_msec", -STONE_HIT_INTERVAL_MSEC))
	if now - last_hit < STONE_HIT_INTERVAL_MSEC:
		return
	damage_area.set_meta("last_role_hit_msec", now)
	_role.effect_reducehp(STONE_DAMAGE, "physics")


func _on_fall_death_body_entered(body: Node2D) -> void:
	if body == _role:
		RoleProp.roleprop.Hp = 0

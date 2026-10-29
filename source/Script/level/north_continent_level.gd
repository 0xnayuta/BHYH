extends Game4EastLateLevel
class_name NorthContinentLevel

@export var hidden_original_room := false
const MAZE_WAVE_COUNT := 3

var _north_data: Dictionary = {}
var _active_points: Dictionary = {}
var _visited_triggers: Dictionary = {}
var _pending_triggers: Array[int] = []
var _battle_bounds := Rect2()
var _camera_center := Vector2.ZERO
var _camera_initialized := false
var _source_camera_rect := Rect2()
var _source_screen_starts: Array = []
var _source_screen_width := 1200.0
var _source_map_size := Vector2.ZERO
var _elapsed := 0.0
var maze_room := 1
var in_void_space := false
var _void_boss: BaseMonster
var _void_return := Vector2.ZERO
var _void_units: Array = []
var _boss_seen := false
var _boss_ids: Array = []
var _ready_triggers: Dictionary = {}


func _build_level_runtime() -> void:
	_north_data = NorthOriginalData.level_data(stage_number, hidden_original_room)
	_source_screen_starts = NorthOriginalData.numbers(_north_data["dungeon"]["sceneStart"])
	_source_screen_width = float(_north_data["dungeon"]["screenWidth"])
	_source_map_size = Vector2(float(_north_data["width"]), float(_north_data["height"]))
	source_map = _north_data["dungeon"]["mapURL"]
	display_name = _north_data["name"]
	level_width_override = float(_north_data["width"])

	_boss_ids = NorthOriginalData.numbers(_north_data["dungeon"]["bossId"])
	if _boss_ids == [-1.0]:
		_boss_ids.clear()
		for text_id in str(_north_data["dungeon"]["monsterID"]).split(";", false):
			if NorthOriginalData.monster_record(int(text_id)).get("boss", "0") == "1":
				_boss_ids.append(float(text_id))
	_palace_terrain = get_node("OriginalTerrain") as Node2D
	_palace_terrain.configure(self, stage_number)
	_source_terrain = _north_data
	_late_birth_points.clear()
	for source: Dictionary in _north_data["points"]:
		var point := source.duplicate(true)
		point["position"] = Vector2(float(source["position"][0]), float(source["position"][1]))

		point["ignore_count_multiplier"] = (
			NorthOriginalData.monster_record(int(point["monster"])).get("boss", "0") == "1"
		)
		_late_birth_points.append(point)


func _ready() -> void:
	super._ready()
	_role.set_meta("allow_position_y_over_800", true)
	_role.floor_max_angle = deg_to_rad(80)
	_role.floor_snap_length = 18
	my_camera.zoom = Vector2.ONE
	if _source_screen_starts.size() > 1:
		my_camera.position_smoothing_enabled = true
		my_camera.limit_smoothed = true
	else:
		my_camera.position_smoothing_enabled = false
		my_camera.limit_smoothed = false
		my_camera.set_physics_process(false)
		my_camera.top_level = true
	_camera_initialized = false
	_update_screen_bounds()
	if stage_number == 85:
		_role.gravity = 0
		_role.collision_mask = 0
		_role.set_physics_process(false)


func _stage_count() -> int:
	return maxi(_north_data.get("triggers", []).size(), 1)


func _stage_trigger_x() -> Array:
	var result: Array = []
	for trigger_value in _north_data.get("triggers", []):
		var trigger: Dictionary = trigger_value
		var rect: Array = trigger.get("rect", [0.0, 0.0, 0.0, 0.0])
		if rect.size() >= 4:
			result.append(float(rect[0]) + float(rect[2]) * 0.5)
	return result


func _stage_activate(index: int) -> bool:
	if index < 0 or index >= _north_data.get("triggers", []).size():
		return false
	_activate_trigger(index)
	return current_stage == index + 1


func _stage_trigger_positions() -> Array:
	var result: Array = []
	for trigger_value in _north_data.get("triggers", []):
		var trigger: Dictionary = trigger_value
		var rect: Array = trigger.get("rect", [0.0, 0.0, 0.0, 0.0])
		if rect.size() >= 4:
			result.append(Vector2(float(rect[0]) + float(rect[2]) * 0.5, float(rect[1]) + float(rect[3]) - 60.0))
	return result


func _level_number() -> int:
	return stage_number


func _level_data() -> Dictionary:
	return {"name": display_name, "map": source_map, "width": level_width_override, "boss": -1}


func _allows_deep_monster_positions() -> bool:
	return true


func _level_bgm_path() -> String:
	var id := int(_north_data["dungeon"]["bgMusic"])
	var path := "res://Music/level/original_bg_%02d.mp3" % id
	return path if ResourceLoader.exists(path) else DEFAULT_LEVEL_BGM_PATH


func get_level_monster_config(id: int) -> Dictionary:
	return NorthOriginalData.monster_config(id)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	super._physics_process(delta)
	if stage_number == 80 and not hidden_original_room and role_information != null:
		role_information.gogo.visible = false
	if not is_instance_valid(_role):
		return
	if stage_number == 85:
		_role.velocity.y = 0
		_role._physics_process(0.0)
		_role.gravity = 0
		_role.position.y += Input.get_axis("Exit", "down") * 300.0 * delta
		_role.velocity.y = 0
		_role.global_position.x = clampf(_role.global_position.x, 25, 915)
		_role.global_position.y = clampf(_role.global_position.y, 60, 565)
	if in_void_space:
		var alive := false
		for unit in _void_units:
			if is_instance_valid(unit) and not unit.death():
				alive = true
		if not alive:
			leave_void_space()


func _update_stage_progression() -> void:
	if not _spawn_runtime_ready or not is_instance_valid(_role):
		return
	if stage_number == 80 and not hidden_original_room:
		if maze_room == 7:
			if not _visited_triggers.has(6):
				_activate_trigger(6)
		elif current_stage == 0:
			_activate_trigger(0)
		elif current_stage < MAZE_WAVE_COUNT and check_can_pass():
			_activate_trigger(current_stage)
		return
	var collider := _role.get_node_or_null("pz") as CollisionShape2D
	if collider == null:
		return
	var hero_rect := collider.shape.get_rect()
	hero_rect.position += collider.global_position - global_position
	for i in range(_north_data["triggers"].size()):
		if _visited_triggers.has(i):
			continue
		var trigger: Dictionary = _north_data["triggers"][i]
		var properties: Dictionary = trigger["properties"]
		if stage_number == 80 and not hidden_original_room and int(properties.get("screen", 0)) != maze_room:
			continue
		if stage_number == 81 and i in [4, 6]:
			continue
		if _elapsed * 1000.0 < float(properties.get("createAfterTime", "0")):
			continue
		var rect: Array = trigger["rect"]
		if hero_rect.intersects(Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))):
			if not _pending_triggers.has(i):
				_pending_triggers.append(i)

	if not _pending_triggers.is_empty() and (_active_points.is_empty() or check_can_pass()):
		_activate_trigger(_pending_triggers.pop_front())


func _activate_trigger(index: int) -> void:
	if _visited_triggers.has(index) or not _active_points.is_empty() and not check_can_pass():
		return
	# 触发器是单向前进的；英雄在相邻房间/重叠矩形中移动时，
	# 旧触发器不能把 current_stage 回退到更早阶段。
	if current_stage >= index + 1:
		_visited_triggers[index] = true
		return
	_visited_triggers[index] = true
	current_stage = index + 1
	_stage_started[current_stage] = true
	_request_stage_resource_preload(current_stage)
	for point in _north_data["triggers"][index]["points"]:
		if _point_states.has(int(point)):
			_active_points[int(point)] = true
			_point_states[int(point)]["next_spawn_at"] = _elapsed
	_set_battle_bounds(index)


func _set_battle_bounds(index: int) -> void:
	var map_size := _source_map_size
	var starts := _source_screen_starts
	var width := _source_screen_width
	var left := float(starts[mini(index, starts.size() - 1)])
	_battle_bounds = Rect2(left, 0, minf(width, map_size.x - left), map_size.y)

	var top := INF
	for point: Dictionary in _birth_points():
		if int(point["point"]) in _north_data["triggers"][index]["points"]:
			var pos: Vector2 = point["position"]
			top = minf(top, pos.y - 180)
	if stage_number in [76, 79] and is_finite(top):
		top = maxf(minf(top, _role.position.y - 295), 0)
		_battle_bounds.position.y = top
		_battle_bounds.size.y = map_size.y - top


func source_battle_bounds() -> Rect2:
	return _battle_bounds


func set_source_camera_rect(rect: Rect2) -> void:
	_source_camera_rect = rect


func _preload_level_resources() -> void:
	pass


func _request_stage_resource_preload(stage: int) -> void:
	if _stage_preload_requested.has(stage):
		return
	_stage_preload_requested[stage] = true
	call_deferred("_preload_north_trigger", stage)


func _preload_north_trigger(stage: int) -> void:
	var ids: Array = monster_group.get(_stage_key(stage), []).duplicate()
	await Global.preload_level_monster_runtime_resources(ids)
	if is_inside_tree():
		_ready_triggers[stage] = true


func _spawn_next_protected_unit() -> void:
	if not _spawn_runtime_ready:
		return
	var alive_count := _get_alive_stage_monster_count()
	if alive_count >= (30 if stage_number == 85 else 12) * _count_multiplier:
		return
	for point: Dictionary in _birth_points():
		var id := int(point["point"])
		if not _active_points.has(id):
			continue
		var state: Dictionary = _point_states[id]
		if not _ready_triggers.has(int(point["stage"])) or _elapsed < float(state.get("next_spawn_at", 0)):
			continue
		if int(state["spawned"]) >= int(state["target"]) or not _point_dependency_satisfied(point):
			continue
		var delay_ms := float(point["tile"].get("beginTime", "0")) * 1000.0
		if _elapsed * 1000 < delay_ms:
			continue
		state["started"] = true
		if _spawn_birth_point_unit(point, state):
			var speed_ratio := clampf(float(MainSet.set_data.get("CreateMonsterSpeed", 1.2)) / 1.2, 0.0625, 1.0)
			state["next_spawn_at"] = _elapsed + float(point["tile"].get("birthInterval", "0")) * speed_ratio
			if float(point["monster"]) in _boss_ids:
				_boss_seen = true
			return


func _update_screen_bounds(delta: float = 0.0) -> void:
	if _source_screen_starts.size() > 1 and not in_void_space:
		super._update_screen_bounds(delta)
		for wall_shape in [_screen_left_wall, _screen_right_wall]:
			if is_instance_valid(wall_shape):
				wall_shape.position.y = _source_map_size.y / 2
				(wall_shape.shape as RectangleShape2D).size.y = _source_map_size.y + 1000
		if my_camera != null:
			my_camera.max_top = 0
			my_camera.max_bottom = _source_map_size.y
		return
	if _screen_left_wall != null:
		_screen_left_wall.disabled = true
		_screen_right_wall.disabled = true
	if my_camera != null and not _north_data.is_empty():
		my_camera.position_smoothing_enabled = false
		my_camera.limit_smoothed = false
		var map_size := _source_map_size
		var starts := _source_screen_starts
		var clear := check_can_pass()
		var room := _battle_bounds if _battle_bounds.has_area() else Rect2(0, 0, _source_screen_width, map_size.y)
		if clear:
			if starts.size() > 1:
				var next := mini(current_stage, starts.size() - 1)
				room.size.x = minf(float(starts[next]) + _source_screen_width, map_size.x) - room.position.x
			else:
				room.size.y += room.position.y
				room.position.y = 0
		if in_void_space:
			room = Rect2(4300, 0, 2000, map_size.y)
		elif _source_camera_rect.has_area() and clear:
			room = _source_camera_rect
		my_camera.max_left = room.position.x
		my_camera.max_right = room.end.x
		my_camera.max_top = room.position.y
		my_camera.max_bottom = room.end.y
		if not in_void_space and _battle_bounds.has_area() and not clear:
			if is_instance_valid(_role):
				var pos: Vector2 = _role.global_position - global_position
				var half_view: Vector2 = get_viewport_rect().size / my_camera.zoom / 2
				var moving_left := minf(_battle_bounds.position.x, maxf(_camera_center.x - half_view.x, 0))
				var bounded := Vector2(
					clampf(pos.x, moving_left + 25, _battle_bounds.end.x - 25),
					maxf(pos.y, _battle_bounds.position.y + 40) if stage_number in [76, 79] else pos.y
				)
				if bounded.x != pos.x:
					_role.velocity.x = 0
				if bounded.y != pos.y:
					_role.velocity.y = 0
				_role.global_position = global_position + bounded
		if not is_instance_valid(_role):
			return
		var view: Vector2 = get_viewport_rect().size / my_camera.zoom
		var half := view / 2
		var desired: Vector2 = _role.global_position - global_position
		if stage_number in [80, 85] and not in_void_space:
			desired = map_size / 2
		desired.x = clampf(desired.x, room.position.x + half.x, maxf(room.position.x + half.x, room.end.x - half.x))
		desired.y = clampf(desired.y, room.position.y + half.y, maxf(room.position.y + half.y, room.end.y - half.y))
		if not _camera_initialized:
			_camera_center = desired
			_camera_initialized = true
		elif delta > 0:
			_camera_center.x = move_toward(_camera_center.x, desired.x, 300 * delta)
			_camera_center.y = lerpf(_camera_center.y, desired.y, 1 - pow(0.9, delta * 30))

		my_camera.limit_left = -100000
		my_camera.limit_right = 100000
		my_camera.limit_top = -100000
		my_camera.limit_bottom = 100000
		my_camera.global_position = global_position + _camera_center
		my_camera.force_update_scroll()


func _screen_starts() -> Array:
	var starts := _source_screen_starts.duplicate()
	while starts.size() < _stage_count():
		starts.append(starts.back())
	return starts


func _screen_rights() -> Array:
	var rights: Array = []
	for start in _screen_starts():
		rights.append(minf(float(start) + _source_screen_width, _source_map_size.x))
	return rights


func check_can_pass() -> bool:
	if _active_points.is_empty():
		return false
	for id in _active_points:
		if not _point_all_dead(id):
			return false
	return _get_alive_stage_monster_count() == 0


func check_can_exit() -> bool:
	if not _boss_seen or in_void_space or not check_can_pass():
		return false
	for point: Dictionary in _birth_points():
		if float(point["monster"]) in _boss_ids and not _point_all_dead(int(point["point"])):
			return false
	for enemy in monster.get_children():
		if enemy is BaseMonster and float(enemy.monster_kind) in _boss_ids and not enemy.death():
			return false
	return true


func maze_choices_ready() -> bool:
	return (
		stage_number == 80
		and not hidden_original_room
		and maze_room == 1
		and current_stage == MAZE_WAVE_COUNT
		and check_can_pass()
	)


func enter_maze_gate(side: int) -> void:
	if side not in [0, 1] or not maze_choices_ready():
		return
	maze_room = 7 if side == 0 else 8
	if maze_room == 8:
		Global.change_scene("res://Scene/level/level_80_hidden.tscn")
		return
	for enemy in monster.get_children():
		enemy.queue_free()
	_active_points.clear()
	_visited_triggers.clear()
	_pending_triggers.clear()
	_battle_bounds = Rect2()
	_source_camera_rect = Rect2()
	_ready_triggers.clear()
	_stage_preload_requested.clear()
	current_stage = 0

	_configure_level_monsters()
	_apply_monster_count_multiplier()
	_role.position = Vector2(590, 440)
	_camera_initialized = false
	_role.velocity = Vector2.ZERO
	_palace_terrain.set_maze_room(maze_room)


func enter_void_space(boss: BaseMonster) -> void:
	if stage_number != 81 or in_void_space or not is_instance_valid(boss):
		return
	in_void_space = true
	_void_boss = boss
	_void_return = _role.position
	boss.visible = false
	boss.set_physics_process(false)
	boss.hurt_box.set_deferred("disabled", true)
	_palace_terrain.set_void_space(true)
	_role.position = _palace_terrain.void_landing_position(_role)
	my_camera.top_level = true
	my_camera.set_physics_process(false)
	_camera_initialized = false
	_role.velocity = Vector2.ZERO
	_update_screen_bounds()
	_role.sxyr_cannot_cure = true
	_void_units.clear()
	for i in range(4):
		var unit := Global.create_monster(3423, monster, Vector2(4420 + i * 130, 570))
		unit.set_meta("allow_position_y_over_800", true)
		_void_units.append(unit)


func leave_void_space() -> void:
	in_void_space = false
	_role.position = _void_return
	if _source_screen_starts.size() > 1:
		my_camera.top_level = false
		my_camera.position = Vector2.ZERO
		my_camera.set_physics_process(true)
		my_camera.position_smoothing_enabled = true
		my_camera.limit_smoothed = true
	_camera_initialized = false
	_role.velocity = Vector2.ZERO
	_role.sxyr_cannot_cure = false
	_palace_terrain.set_void_space(false)
	if is_instance_valid(_void_boss) and not _void_boss.death():
		_void_boss.visible = true
		_void_boss.set_physics_process(true)
		_void_boss.hurt_box.set_deferred("disabled", false)


func add_tg(_number) -> void:
	LEVEL_PROGRESS_COMMAND.apply_north_continent(PlayerData.player_data, stage_number, display_name)


func _on_exit_2_body_entered(body: Node2D) -> void:
	if body == _role:
		super._on_exit_2_body_entered(body)

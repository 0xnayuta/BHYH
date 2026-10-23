extends Game4EastLateLevel


func _init() -> void:
	stage_number = 75


const LEVEL_75_MONSTER_DATA := {
	3352:
	{
		"hp": 4389508,
		"attack": 2899,
		"def": 333,
		"mdef": 14,
		"armor_break": 0,
		"magic_break": 0,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"level": 56,
		"crit": 0,
		"miss": 0,
		"hit": 0,
		"sight": 12000,
		"speed": 120.0,
		"max_protect": 50000.0,
		"is_boss": true,
		"coin": 0,
		"exp": 0,
		"drop_rate": 0.0,
		"drop_list": []
	},
}


func _level_data() -> Dictionary:
	var data := super._level_data().duplicate(true)
	data["width"] = level_width_override
	return data


func _build_level_runtime() -> void:
	source_map = "yunhai_v1"
	display_name = "云川"
	_palace_terrain = get_node("OriginalTerrain") as Node2D
	_palace_terrain.configure(self, 75)
	_source_terrain = _palace_terrain.source_data
	_late_birth_points.clear()
	for source: Dictionary in _source_terrain["points"]:
		var point := source.duplicate(true)
		point["position"] = Vector2(float(source["position"][0]), float(source["position"][1]))
		_late_birth_points.append(point)


func _level_bgm_path() -> String:
	return "res://Music/level/original_bg_02.mp3"


func _update_stage_progression() -> void:
	if _spawn_runtime_ready and current_stage == 0 and _role != null and _role.position.x >= 326.0:
		_start_stage(1)


func _update_screen_bounds(_delta: float = 0.0) -> void:
	if _screen_left_wall != null:
		_screen_left_wall.disabled = true
		_screen_right_wall.disabled = true
	if my_camera != null:
		my_camera.max_left = 0.0
		my_camera.max_right = level_width_override
		my_camera.max_top = 0.0
		my_camera.max_bottom = 600.0


func check_can_exit() -> bool:
	return true


func _on_exit_2_body_entered(body: Node2D) -> void:
	if body == _role:
		super._on_exit_2_body_entered(body)


func _leave_level_from_exit() -> void:
	if not can_exit or _auto_exit_settling:
		return

	for enemy in monster.get_children():
		if enemy is BaseMonster and not enemy.death():
			enemy.hp = 0
	super._leave_level_from_exit()


func get_level_monster_config(monster_id: int) -> Dictionary:
	return _get_monster_config_with_level_data(monster_id, LEVEL_75_MONSTER_DATA)

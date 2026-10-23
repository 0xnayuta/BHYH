extends Game4ImportedLevel
class_name Game4EastLateLevel

const ROOM_VIEW_WIDTH := 1200.0
const FLOOR_SURFACE_Y := 405.5
const FLYING_SPAWN_Y := 300.0

const FLYING_MONSTER_IDS := {
	3198: true,
	3200: true,
	3201: true,
	3226: true,
	3275: true,
	3309: true,
	3322: true,
	3323: true,
	3342: true,
	3343: true,
	3352: true,
}

const MONSTER_NAMES := {
	3198: "吸血蝙蝠",
	3199: "雷吼兽",
	3200: "千年蝠妖",
	3201: "召唤小蝙蝠",
	3221: "雷吼兽",
	3222: "邪魅童子",
	3223: "黄眉大王",
	3226: "吸血蝙蝠",
	3274: "邪魅童子",
	3275: "吸血蝙蝠",
	3276: "虎妖",
	3277: "雷之祖巫",
	3308: "小狐狸",
	3309: "琉璃鸟",
	3310: "九尾天狐",
	3320: "金甲护卫",
	3321: "小狐狸",
	3322: "琉璃鸟",
	3323: "金翅大鹏雕",
	3340: "金甲护卫",
	3341: "小狐狸",
	3342: "琉璃鸟",
	3343: "电之祖巫",
	3352: "通天教主(混沌版)",
}

const LEVELS := {
	69: {"map": "bianfuku", "name": "蝙蝠窟", "width": 6000.0, "mobs": [3198, 3199, 3201], "boss": 3200},
	70: {"map": "qixingdong_v1", "name": "七星洞", "width": 5000.0, "mobs": [3221, 3222, 3226], "boss": 3223},
	71: {"map": "wanyaoxue_v1", "name": "万妖穴", "width": 5000.0, "mobs": [3274, 3275, 3276], "boss": 3277},
	72: {"map": "liuligong_v3", "name": "琉璃宫", "width": 5000.0, "mobs": [3308, 3309], "boss": 3310},
	73: {"map": "jinyugong_v3", "name": "金玉宫", "width": 5000.0, "mobs": [3320, 3321, 3322], "boss": 3323},
	74: {"map": "futiantai", "name": "浮天台", "width": 5400.0, "mobs": [3340, 3341, 3342], "boss": 3343},
	75: {"map": "yunhai_v1", "name": "云川", "width": 1200.0, "mobs": [], "boss": 3352},
}

var _late_birth_points: Array = []
var _palace_terrain: Node2D
var _source_terrain: Dictionary = {}


func _ready() -> void:
	_build_level_runtime()
	super._ready()
	if _palace_terrain != null:
		_role.set_meta("disable_down_drop", true)
		_update_screen_bounds()


func _level_data() -> Dictionary:
	return LEVELS.get(stage_number, LEVELS[69]) as Dictionary


func _build_level_runtime() -> void:
	var data := _level_data()
	source_map = str(data["map"])
	display_name = str(data["name"])
	level_width_override = float(data["width"])

	if not background_baked:
		_create_imported_background(data)
		_configure_boundaries(data)
	if stage_number in [72, 73, 74]:
		_palace_terrain = get_node("OriginalTerrain") as Node2D
		_palace_terrain.configure(self, stage_number)
		_source_terrain = _palace_terrain.source_data
		_late_birth_points.clear()
		for source_point: Dictionary in _source_terrain["points"]:
			var point := source_point.duplicate(true)
			var coordinates: Array = point["position"]
			point["position"] = Vector2(float(coordinates[0]), float(coordinates[1]))
			point["ignore_count_multiplier"] = int(point["monster"]) == int(data["boss"])
			_late_birth_points.append(point)
	else:
		_build_birth_points(data)


func _create_imported_background(data: Dictionary) -> void:
	var fixed_parent := get_node_or_null("back_ground/End") as Node2D
	var scrolling_parent := get_node_or_null("back_ground/floor_2") as Node2D
	if fixed_parent == null or scrolling_parent == null:
		return
	var map_name := str(data["map"])
	var width := float(data["width"])
	var layer_names: Array[String] = []
	match stage_number:
		69:
			layer_names = ["bg10", "bg11"]
		70, 71:
			layer_names = ["bg10", "bg11"]
		72, 73:
			layer_names = ["bg30", "bg10", "bg11"]
		74:
			layer_names = ["bg30", "bg11", "bg12", "bg13", "bg14", "bg15", "bg16", "bg17", "bg10"]
		75:
			layer_names = ["bg10", "bg11"]
	for layer_name in layer_names:
		var texture_path := "res://Art/level/game_4_level/imported/maps/%s/background/%s.png" % [map_name, layer_name]
		var texture := load(texture_path) as Texture2D
		if texture == null:
			continue
		var parent := fixed_parent if layer_name == "bg30" else scrolling_parent
		var repeat_count := 1
		if layer_name == "bg10" and stage_number in [69, 70, 71, 73]:
			repeat_count = ceili(width / float(texture.get_width()))
		for repeat_index in range(repeat_count):
			var sprite_name := "%s_%d" % [layer_name, repeat_index]
			if parent.get_node_or_null(sprite_name) != null:
				continue
			var sprite := Sprite2D.new()
			sprite.name = sprite_name
			sprite.texture = texture
			sprite.centered = false
			sprite.position = Vector2(float(repeat_index * texture.get_width()), 0.0)
			sprite.z_index = -5 if layer_name == "bg30" else -1
			parent.add_child(sprite)
	match stage_number:
		69:
			_place_end_layer(scrolling_parent, "bg11", 1200.0)
		70, 71, 73:
			_place_end_layer(scrolling_parent, "bg11", 3988.0)
		72:
			_place_end_layer(scrolling_parent, "bg11", 3785.0)


func _place_end_layer(parent: Node2D, layer_name: String, x: float) -> void:
	var existing := parent.get_node_or_null("%s_0" % layer_name) as Sprite2D
	if existing != null:
		existing.position.x = x


func _configure_boundaries(data: Dictionary) -> void:
	var width := float(data["width"])
	var floor_node := get_node_or_null("wall/floor") as CollisionShape2D
	if floor_node != null:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(width, 300.0)
		floor_node.shape = shape
		floor_node.position = Vector2(width * 0.5, FLOOR_SURFACE_Y + shape.size.y * 0.5)
	var right_wall := get_node_or_null("wall/right_wall") as CollisionShape2D
	if right_wall != null:
		var wall_shape := RectangleShape2D.new()
		wall_shape.size = Vector2(120.0, 1800.0)
		right_wall.shape = wall_shape
		right_wall.position = Vector2(width + 60.0, -300.0)
	var exit_node := get_node_or_null("exit") as Node2D
	if exit_node != null:
		exit_node.position = Vector2(width - 165.0, 350.0)


func _build_birth_points(data: Dictionary) -> void:
	_late_birth_points.clear()
	var stages := _stage_count()
	var mobs: Array = data["mobs"] as Array
	var width := float(data["width"])
	var point_id := 1
	for stage in range(1, stages):
		var room_left := width * float(stage - 1) / float(stages)
		for mob_index in range(mobs.size()):
			var monster_id := int(mobs[mob_index])
			(
				_late_birth_points
				. append(
					{
						"point": point_id,
						"stage": stage,
						"monster": monster_id,
						"position": Vector2(room_left + 560.0 + mob_index * 130.0, _spawn_y(monster_id)),
						"total": 3,
						"face": -1,
						"after_spawn": 0,
						"after_dead": 0,
					}
				)
			)
			point_id += 1
	var boss_id := int(data["boss"])
	(
		_late_birth_points
		. append(
			{
				"point": 50,
				"stage": stages,
				"monster": boss_id,
				"position": Vector2(width - 520.0, _spawn_y(boss_id)),
				"total": 1,
				"face": -1,
				"after_spawn": 0,
				"after_dead": 0,
				"ignore_count_multiplier": true,
			}
		)
	)


func _spawn_y(monster_id: int) -> float:
	return FLYING_SPAWN_Y if FLYING_MONSTER_IDS.has(monster_id) else 448.0


func _stage_count() -> int:
	return 1 if stage_number == 75 else 5


func _stage_trigger_x() -> Array:
	if not _source_terrain.is_empty():
		var triggers: Array = []
		for trigger: Dictionary in _source_terrain["triggers"]:
			triggers.append(float(trigger["x"]))
		return triggers
	var result: Array = []
	var width := float(_level_data()["width"])
	for stage in range(_stage_count()):
		result.append(width * float(stage) / float(_stage_count()) + 200.0)
	return result


func _screen_starts() -> Array:
	if not _source_terrain.is_empty():
		return [0.0, 997.0, 1994.0, 2991.0, 3784.0]
	var result: Array = []
	var width := float(_level_data()["width"])
	for stage in range(_stage_count()):
		result.append(width * float(stage) / float(_stage_count()))
	return result


func _screen_rights() -> Array:
	if not _source_terrain.is_empty():
		return [1200.0, 2200.0, 3400.0, 4400.0, float(_level_data()["width"])]
	var result: Array = []
	var width := float(_level_data()["width"])
	for screen_start: float in _screen_starts():
		result.append(minf(screen_start + ROOM_VIEW_WIDTH, width))
	return result


func _birth_points() -> Array:
	return _late_birth_points


func _point_dependency_satisfied(point: Dictionary) -> bool:
	for point_id: Variant in point.get("after_all_dead", []):
		if not _point_all_dead(int(point_id)):
			return false
	return super._point_dependency_satisfied(point)


func _allows_deep_monster_positions() -> bool:
	return stage_number == 74


func _create_screen_walls() -> void:
	super._create_screen_walls()
	if stage_number == 74:
		for collision: CollisionShape2D in [_screen_left_wall, _screen_right_wall]:
			var shape := RectangleShape2D.new()
			shape.size = Vector2(10.0, 2200.0)
			collision.shape = shape
			collision.position.y = 500.0


func _apply_spawn_facing(created: BaseMonster, face: float) -> void:
	super._apply_spawn_facing(created, face)
	if not _source_terrain.is_empty() and is_instance_valid(created):
		created.set_collision_mask_value(21, not created.is_fly)
		if stage_number == 73 and not created.is_fly:
			created.floor_max_angle = deg_to_rad(80.0)
			created.floor_snap_length = 18.0
			created.floor_constant_speed = true


func _update_screen_bounds(delta: float = 0.0) -> void:
	super._update_screen_bounds(delta)
	if stage_number == 74 and my_camera != null:
		my_camera.max_top = 0.0
		my_camera.max_bottom = 1280.0
		if _role != null and _role.position.x >= 4248.0 and _role.is_on_floor():
			my_camera.max_bottom = 810.0


func _level_number() -> int:
	return stage_number


func get_level_monster_config(monster_id: int) -> Dictionary:
	return _get_base_monster_config(monster_id)


func _get_base_monster_config(monster_id: int) -> Dictionary:
	var boss_id := int(_level_data()["boss"])
	var boss := monster_id == boss_id
	return {
		"name": str(MONSTER_NAMES.get(monster_id, "")),
		"level": 90,
		"crit": 500 if boss else 340,
		"miss": 180,
		"hit": 900,
		"speed": 10.0 if boss else 12.0,
		"range": 320.0 if boss else 190.0,
		"sight": 1200.0 if boss else 900.0,
		"is_boss": boss,
		"is_flying": FLYING_MONSTER_IDS.has(monster_id),
		"max_protect": 250.0 if boss else 100.0,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
	}


func _get_monster_config_with_level_data(monster_id: int, level_data: Dictionary) -> Dictionary:
	var config := _get_base_monster_config(monster_id)
	var source: Variant = level_data.get(monster_id, {})
	if source is Dictionary:
		config.merge(source as Dictionary, true)
	return config

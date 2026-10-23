extends Node2D

const ASSET_ROOT := "res://Art/level/game_4_level/imported/terrain/"
var source_data: Dictionary = {}
var _level: Game4EastLateLevel
var _hidden_platforms: Array[Dictionary] = []
var _hazards: Array[Dictionary] = []
var _death_y := 0.0
var _clock := 0.0
var _animation_data: Dictionary = {}


func configure(level: Game4EastLateLevel, level_number: int) -> void:
	_level = level
	source_data = JSON.parse_string(FileAccess.get_file_as_string(ASSET_ROOT + "level_%d.json" % level_number))
	level.get_node("wall/floor").disabled = true
	_bind_scene_nodes()


func _resolve_binding(value: Variant) -> Variant:
	if value is NodePath:
		return get_node_or_null(value)
	if value is Dictionary:
		var result := {}
		for key in value:
			result[key] = _resolve_binding(value[key])
		return result
	if value is Array:
		var result: Array = []
		for entry in value:
			result.append(_resolve_binding(entry))
		return result
	return value


func _bind_scene_nodes() -> void:
	var bindings: Dictionary = _resolve_binding(get_meta("scene_bindings", {}))
	for field in bindings:
		if field == "death_region":
			var death_region := bindings[field] as CollisionShape2D
			if death_region != null:
				_death_y = _scene_region(death_region).position.y
			continue
		var current: Variant = get(field)
		if current is Array:
			current.assign(bindings[field])
		else:
			set(field, bindings[field])
	for field in ["_hidden_platforms", "_hazards", "_collapsing", "_source_objects", "_moving"]:
		var records: Variant = get(field)
		if not records is Array:
			continue
		for record: Dictionary in records:
			if record.get("region") != null:
				record["rect"] = _scene_region(record["region"])
			if record.has("origin_offset") and record.get("sprite") != null:
				record["origin"] = to_local(record["sprite"].global_position) - record["origin_offset"]
			if record.get("body") != null:
				record["home_position"] = record["body"].position
			if record.has("idle_position") and record.get("sprite") != null:
				record["idle_position"] = record["sprite"].position
	_play_scene_animations(self)


func _scene_region(collision: CollisionShape2D) -> Rect2:
	var box := collision.shape.get_rect()
	return (global_transform.affine_inverse() * collision.global_transform) * box


func _play_scene_animations(node: Node) -> void:
	for child in node.get_children():
		if child is AnimatedSprite2D:
			var sprite := child as AnimatedSprite2D
			var frames := sprite.sprite_frames
			if frames != null and not frames.get_animation_names().is_empty():
				var animation_name := sprite.animation
				if not frames.has_animation(animation_name):
					animation_name = frames.get_animation_names()[0]
				sprite.play(animation_name)
		_play_scene_animations(child)


func _physics_process(delta: float) -> void:
	_clock += delta
	var role = _level._role
	if not is_instance_valid(role):
		return
	if _level.stage_number == 73:
		role.floor_max_angle = deg_to_rad(80.0)
		role.floor_snap_length = 18.0
		role.floor_constant_speed = true
	var role_body := role.get_node_or_null("pz") as CollisionShape2D
	var role_rect := Rect2(role.global_position - global_position - Vector2(20, 60), Vector2(40, 60))
	if role_body != null and role_body.shape != null:
		role_rect = role_body.shape.get_rect()
		role_rect.position += role_body.global_position - global_position
	for platform: Dictionary in _hidden_platforms:
		var rect: Rect2 = platform["rect"]
		var standing: bool = (
			role.is_on_floor()
			and role_rect.end.x > rect.position.x
			and role_rect.position.x < rect.end.x
			and absf(role_rect.end.y - rect.position.y) < 6.0
		)
		if standing:
			platform["last_stand"] = _clock
		platform["sprite"].visible = standing or _clock - float(platform["last_stand"]) < float(platform["hide_delay"])
	for hazard: Dictionary in _hazards:
		var sprite: AnimatedSprite2D = hazard["sprite"]
		var data: Dictionary = hazard["data"]
		var hits: Array = data["hits"]
		var hit: Array = hits[mini(sprite.frame, hits.size() - 1)]
		if hit.is_empty() or _clock - float(hazard["last_hit"]) < 0.5:
			continue
		var hit_rect := _rect(hit)
		hit_rect.position += hazard["origin"] as Vector2
		if hit_rect.intersects(role_rect) and not role.is_death and not role.need_protect:
			hazard["last_hit"] = _clock
			_damage_role(role, int(hazard["damage"]), "magic")
	if _death_y > 0.0:
		if role_rect.end.y >= _death_y and not role.is_death:
			RoleProp.roleprop.Hp = 0
		for child in _level.monster.get_children():
			if child is BaseMonster and not child.is_death and child.position.y >= _death_y:
				child.hp = 0


func _damage_role(role, damage: int, kind: String) -> void:
	if not role.has_meta("pet_turtle_link_unit_ref"):
		role.set_meta("pet_turtle_link_unit_ref", false)
	role.effect_reducehp(damage, kind)


func _rect(values: Array) -> Rect2:
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))

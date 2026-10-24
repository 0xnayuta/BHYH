extends EastContinentMonster

signal source_skill_cast(skill_id: int)
signal source_projectile_spawned(sequence: String, projectile: WutaiMinghaiProjectile)

const NORTH_PROJECTILE := preload("res://Script/monster/north_boss_projectile.gd")
const STANDARD_FRAMES_MODELS := [
	3353,
	3354,
	3355,
	3356,
	3357,
	3361,
	3367,
	3371,
	3372,
	3381,
	3382,
	3383,
	3384,
	3385,
	3399,
	3400,
	3401,
	3402,
	3408,
	3409,
	3410,
	3415,
	3416,
	3417,
	3418,
	3419,
	3420,
	3421,
	3422,
	3423,
	3430,
	3431,
	3481,
	3482,
	3483,
	3484,
	3485,
	3486,
	3487,
	3499,
	3500,
	3501,
	3528,
	3529,
	3530,
	3531,
	3535,
	3536,
	3537,
	3538,
	3539,
]
var _raw: Dictionary = {}
var _source: Dictionary = {}
var _skill_actions: Dictionary = {}
var _skill_cursor := 0
var _next_cast := 0
var _regen_clock := 0.0
var _sons: Array = []
var _cast_generation := 0
var _flight_height := 0.0
var _tree: BaseMonster
var _stationary_origin := Vector2.ZERO
var _sky_path: Array = []
var _sky_origin := Vector2.ZERO
var _sky_time := 0.0
var _flight_bounds := Rect2()
var _body_motion_until := 0
var _body_motion := Vector2.ZERO
var _seek_destination := Vector2.ZERO
var _seek_refresh := 0
var _snow_guard_until := 0
var _snow_guard_ratio := 0.0
var snow_guard_visual: WutaiMinghaiProjectile


func _metadata_path() -> String:
	return NorthOriginalData.metadata(monster_kind)


func _standard_body_frames_path() -> String:
	# 资源目录以 metadata 的 model 为准：monsters.json 存在多 id 共用同一 model
	# 的情况（如 3386/3367、3426/3411/3399），按 monster_kind 取值会取到不存在的路径。
	var model := int(_raw.get("model", monster_kind))
	if model not in STANDARD_FRAMES_MODELS:
		return ""
	return "res://Art/monster/north_original/%d/north_original_%d_frames.tres" % [model, model]


func _resolve_runtime_config() -> Dictionary:
	_raw = NorthOriginalData.monster_record(monster_kind)
	_source = AtlasMetadataStore.data_for(_metadata_path())
	var config := NorthOriginalData.monster_config(monster_kind)
	var animations := {
		&"wait": ["wait", true], &"walk": ["walk", true], &"hurt": ["hurt", false], &"death": ["death", false]
	}
	var attacks: Dictionary = {}
	var index := 1
	for key in [
		"attack1",
		"attack2",
		"attack3",
		"attack4",
		"effect1",
		"effect2",
		"effect3",
		"effect4",
		"effect5",
		"protectSkill"
	]:
		var data := NorthOriginalData.skill(_raw.get(key, "0"))
		if data.is_empty():
			continue
		var body: String = "effect4" if key == "protectSkill" else key
		var sequence: String = "mc_" + body if _source["sequences"].has("mc_" + body) else body
		if not _source["sequences"].has(sequence):
			sequence = "wait"
		var action := StringName("hit%d" % index)
		animations[action] = [sequence, false]
		_skill_actions[action] = {"key": key, "data": data}
		attacks[str(action)] = _skill_attack_data(data)
		index += 1
	if config["is_flying"]:
		animations[&"Fly_wait"] = ["wait", true]
		animations[&"Fly"] = ["walk", true]
	config["animations"] = animations
	config["attacks"] = attacks
	return config


func _skill_attack_data(skill: Dictionary) -> Dictionary:
	return {
		"multiplier": float(skill.get("skillDefault", "1")),
		"kind": "magic" if int(skill.get("type", "1")) == 2 else "physics",
		"source_target_move": NorthOriginalData.numbers(skill.get("targetMove", "0,0")),
		"protect": int(skill.get("protectPoint", "0"))
	}


func _ready() -> void:
	super._ready()
	_fixed_flight_height_ready = false
	_flight_height = global_position.y
	_flight_bounds = _view_rect()
	_stationary_origin = global_position
	var level_node := get_level_node()
	if level_node is NorthContinentLevel and level_node.stage_number == 85 and not is_boss:
		_sky_origin = global_position
		var step := maxi(int(float(_raw["walkSpeed"]) / 30), 1)
		var ahead := global_position.x - 1000
		for x in range(0, maxi(int(ahead), 0), step):
			_sky_path.append(Vector2(-x, 0))
		for i in range(0, NorthOriginalData.sky_path().size(), step):
			var point: Array = NorthOriginalData.sky_path()[i]
			if float(point[0]) < ahead:
				_sky_path.append(Vector2(float(point[0]) - maxf(ahead, 0), float(point[1])))
	if is_fly or int(_raw["model"]) in [3422, 3528]:
		no_grav = true
		collision_mask = 0
	floor_max_angle = deg_to_rad(80)
	floor_snap_length = 18
	if int(_raw["model"]) in [3431, 3384, 3500, 3354]:
		_run_birth_event(int(_raw["model"]))


func _run_birth_event(model: int) -> void:
	await get_tree().create_timer(5.0 if model == 3500 else 10.0, false).timeout
	if not is_inside_tree() or death():
		return
	if model == 3354:
		hp = 0
		return
	var key := "effect2" if model == 3384 else ("attack1" if model == 3500 else "effect1")
	for action: StringName in _skill_actions:
		if _skill_actions[action]["key"] == key:
			if model == 3500:
				_standard_shot(action, _skill_actions[action]["data"])
				hp = 0
			else:
				cast_action(action)
			return


func _visual_offset(action: StringName) -> Vector2:
	var sequence := str(_config["animations"][action][0])
	var center: Array = _source["geometry"][sequence]["center"]
	return Vector2(-float(center[0]) if mr_ani.flip_h else float(center[0]), float(center[1]))


func _configure_entity_collision_boxes() -> void:
	var geometry: Dictionary = _source["geometry"]["wait"]
	var origin: Array = geometry["origin"]
	var size: Array = geometry["size"]
	var shape := RectangleShape2D.new()
	shape.size = Vector2(maxf(float(size[0]) * 0.65, 35), maxf(float(size[1]) * 0.8, 35))
	hurt_box.shape = shape
	hurt_box.position = Vector2(float(origin[0]) + float(size[0]) / 2, float(origin[1]) + float(size[1]) / 2)
	var body_shape := RectangleShape2D.new()
	body_shape.size = Vector2(minf(shape.size.x, 80), minf(shape.size.y, 90))
	pz.shape = body_shape
	pz.position = Vector2(0, -body_shape.size.y / 2)


func _physics_process(delta: float) -> void:
	_fixed_flight_height_ready = false
	var gravity_before := no_grav
	var moving_by_skill := Time.get_ticks_msec() < _body_motion_until
	if moving_by_skill:
		no_grav = true
	if no_grav and not is_fly:
		velocity.y = 0
	if Time.get_ticks_msec() < _body_motion_until:
		velocity = _body_motion
	elif _body_motion_until > 0:
		_body_motion_until = 0
		velocity = Vector2.ZERO
	super._physics_process(delta)
	if moving_by_skill:
		no_grav = gravity_before
	if death():
		for son in _sons:
			if is_instance_valid(son):
				son.hp = 0
		return
	_regen_clock += delta
	if _regen_clock >= 1:
		_regen_clock -= 1
		cure_hp(int(_raw.get("reHP", "0")))
	if is_fly:
		if _sky_path.is_empty():
			_keep_in_view()
		else:
			_sky_time += delta
			var index := mini(int(_sky_time * 30), _sky_path.size() - 1)
			global_position = _sky_origin + _sky_path[index]
			if global_position.x < -100 or index >= _sky_path.size() - 1:
				hp = 0
	if int(_raw["model"]) in [3422, 3528]:
		global_position = _stationary_origin
		velocity = Vector2.ZERO
	if is_instance_valid(_tree) and not _tree.death():
		global_position = _tree.global_position + Vector2(0, -200)
	elif _tree != null:
		_tree = null
		no_grav = is_fly
	var level := get_level_node()
	if level is NorthContinentLevel and not level.in_void_space:
		var room: Rect2 = level.source_battle_bounds()
		if room.has_area() and not death():
			var half_width := minf(float(_source["geometry"]["wait"]["size"][0]) / 2 + 10, room.size.x / 3)
			global_position.x = clampf(
				global_position.x,
				level.global_position.x + room.position.x + half_width,
				level.global_position.x + room.end.x - half_width
			)


func _keep_in_view() -> void:
	if is_boss:
		var level := get_level_node()
		if level is NorthContinentLevel and level.source_battle_bounds().has_area():
			_flight_bounds = level.source_battle_bounds()
		var size: Array = _source["geometry"]["wait"]["size"]
		var margin_x := minf(float(size[0]) / 2 + 15, _flight_bounds.size.x / 3)
		global_position.x = clampf(
			global_position.x, _flight_bounds.position.x + margin_x, _flight_bounds.end.x - margin_x
		)
		var margin_y := minf(float(size[1]) / 2 + 15, _flight_bounds.size.y / 3)
		global_position.y = clampf(global_position.y, _flight_bounds.position.y + margin_y, _flight_bounds.end.y - 40)


func _view_rect() -> Rect2:
	var inverse := get_viewport().get_canvas_transform().affine_inverse()
	return Rect2(inverse * Vector2.ZERO, get_viewport_rect().size / get_viewport().get_canvas_transform().get_scale())


func _enable_attack_box(_action: StringName = &"") -> void:
	_disable_attack_box()


func _sync_attack_collision(_force: bool = false) -> void:
	_disable_attack_box()


func is_control_immune() -> bool:
	return (
		Time.get_ticks_msec() < _snow_guard_until
		or _raw.get("superArmor", "0") == "1"
		or int(_raw.get("model", 0)) in [3422, 3528]
		or super.is_control_immune()
	)


func _apply_role_damage_vs_reduction(value: int) -> int:
	var damage := super._apply_role_damage_vs_reduction(value)
	return int(damage * (1.0 - _snow_guard_ratio)) if Time.get_ticks_msec() < _snow_guard_until else damage


func ai_think() -> void:
	if (
		death()
		or is_attacking
		or is_ice
		or is_sleep
		or is_stun
		or int(_raw["aiId"]) <= 0
		or Time.get_ticks_msec() < _body_motion_until
	):
		return
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	monster_direction = target.x >= global_position.x
	to_hero()
	if is_instance_valid(_tree) and not _tree.death():
		if Time.get_ticks_msec() >= _next_cast:
			for action: StringName in _skill_actions:
				if _skill_actions[action]["key"] == "attack1":
					cast_action(action)
					_next_cast = Time.get_ticks_msec() + 2000
					break
		return
	var reachable := _reachable_attacks(target)
	if not reachable.is_empty() and Time.get_ticks_msec() >= _next_cast:
		attack_target()
	elif reachable.is_empty():
		have_target()
	else:
		velocity = Vector2.ZERO if is_fly else Vector2(0, velocity.y)
		mr_player.play(&"wait")


func have_target() -> void:
	if is_attacking or death():
		return
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	to_hero()
	_body_motion_until = 0
	if int(_raw["model"]) in [3422, 3528] or is_instance_valid(_tree):
		velocity = Vector2.ZERO
		return
	velocity.x = signf(target.x - global_position.x) * float(_raw["walkSpeed"]) * 3
	if is_fly:
		if Time.get_ticks_msec() >= _seek_refresh:
			var scope := NorthOriginalData.numbers(
				_skill_actions[_skill_actions.keys()[0]]["data"].get("skillScope", "0,50,0,50")
			)
			var side := -1.0 if target.x >= global_position.x else 1.0
			var y := target.y - 10 - (float(scope[3]) if scope.size() >= 4 else 50.0)
			var near := Vector2(target.x + float(scope[0]) * side, y)
			var far := Vector2(target.x + float(scope[1]) * side, y)
			_seek_destination = (
				near if global_position.distance_squared_to(near) < global_position.distance_squared_to(far) else far
			)
			_seek_refresh = Time.get_ticks_msec() + 2000
		var offset := _seek_destination - global_position
		velocity = (
			offset.normalized() * minf(float(_raw["walkSpeed"]) * 3, offset.length() / get_physics_process_delta_time())
		)
	mr_player.play(&"Fly" if is_fly else &"walk")


func to_hero() -> void:
	var model := int(_raw.get("model", 0))
	if model in [3381, 3422, 3430, 3528]:
		monster_direction = model != 3528
		monster_dir.scale.x = -1 if monster_direction else 1
		base_damage_box.scale.x = monster_dir.scale.x
	else:
		monster_direction = RoleProp.get_nearest_monster_target_position(global_position).x >= global_position.x
		monster_dir.scale.x = -1 if monster_direction else 1
		base_damage_box.scale.x = monster_dir.scale.x


func _reachable_attacks(target: Vector2) -> Array[StringName]:
	var actions: Array[StringName] = []
	for action: StringName in _skill_actions:
		var data: Dictionary = _skill_actions[action]["data"]
		var scope := NorthOriginalData.numbers(data.get("skillScope", "0,1200"))
		if scope.size() >= 2 and _official_in_skill_scope(target, scope):
			actions.append(action)
	return actions


func attack_target() -> void:
	if death() or is_attacking:
		return
	var reachable := _reachable_attacks(RoleProp.get_nearest_monster_target_position(global_position))
	if reachable.is_empty():
		have_target()
		return
	cast_action(reachable[_skill_cursor % reachable.size()])
	_skill_cursor += 1


func cast_action(action: StringName) -> void:
	if not _skill_actions.has(action) or death():
		return
	to_hero()
	_body_motion_until = 0
	_cast_generation += 1
	_attack_serial += 1
	var generation := _cast_generation
	_active_attack_name = action
	hit_name = str(action)
	is_attacking = true
	_seek_refresh = 0
	velocity = Vector2.ZERO
	_next_cast = Time.get_ticks_msec() + maxi(int(_raw.get("aiDelay", "1000")), 700)
	_play_frames(action)
	mr_player.play(action)
	source_skill_cast.emit(int(_skill_actions[action]["data"]["id"]))
	_run_source_skill(action, generation)
	await get_tree().create_timer(mr_player.get_animation(action).length, false).timeout
	if is_inside_tree() and not death() and generation == _cast_generation:
		is_attacking = false
		mr_player.play(&"wait")
		if int(_raw["model"]) == 3431:
			hp = 0


func _delay(seconds: float, generation: int) -> bool:
	await get_tree().create_timer(maxf(seconds, 0.001), false).timeout

	return is_inside_tree() and not death()


func _run_source_skill(action: StringName, generation: int) -> void:
	var record: Dictionary = _skill_actions[action]
	var key := str(record["key"])
	var skill: Dictionary = record["data"]
	var model := int(_raw["model"])
	var frame := maxi(int(skill.get("shootFrame", "0")), 0)
	var body_sequence := str(_config["animations"][action][0])
	if model == 3367 and key == "attack1":
		_cast_snow_guard(action, skill)
		return

	var mask_key := body_sequence.trim_prefix("mc_")
	var contact: WutaiMinghaiProjectile
	if _source.get("masks", {}).has(mask_key):
		contact = _projectile(
			body_sequence,
			action,
			global_position,
			Vector2.ZERO,
			mr_player.get_animation(action).length,
			skill,
			{"follow_owner": true, "mask_sequence": mask_key}
		)
		if contact != null:
			contact.visible = false
	if _source["sequences"].has(body_sequence + "_overlay"):
		_projectile(
			body_sequence + "_overlay",
			action,
			global_position,
			Vector2.ZERO,
			mr_player.get_animation(action).length,
			skill,
			{"follow_owner": true, "damage_enabled": false, "loop_visual": false}
		)
	if model == 3353 and key == "effect3":
		var columns := [100, 300, 500, 700, 900, 1100]
		columns.shuffle()
		var frames := [18, 27, 37, 38, 43, 48]
		var last_frame := 0
		for i in range(6):
			if not await _delay(float(frames[i] - last_frame) / 30, generation):
				return
			last_frame = frames[i]
			_projectile(
				"effect3_1",
				action,
				Vector2(_view_rect().position.x + columns[i], global_position.y - 550),
				Vector2.ZERO,
				5,
				skill,
				{"gravity": 990, "collide_terrain": true}
			)
		return
	if model == 3409 and key in ["effect2", "effect3"]:
		if not await _delay((20.0 if key == "effect2" else 27.0) / 30, generation):
			return
		var offsets := (
			[Vector2(86, -18), Vector2(45, -73), Vector2(124, -94), Vector2(86, -145)]
			if key == "effect2"
			else [
				Vector2(-121, -18),
				Vector2(121, -18),
				Vector2(-128, -65),
				Vector2(128, -65),
				Vector2(-128, -145),
				Vector2(128, -145)
			]
		)
		var angles := [-180, 0, -170, -7, -170, -7]
		var delays := [0.0, 0.495, 0.99, 1.485] if key == "effect2" else [0.0, 0.0, 0.495, 0.495, 1.023, 1.023]
		var previous_delay := 0.0
		var source_origin := global_position
		var source_facing := _facing()
		for i in range(offsets.size()):
			if delays[i] > previous_delay and not await _delay(delays[i] - previous_delay, generation):
				return
			previous_delay = delays[i]

			var motion := Vector2(float(skill["shootSpeedX"]), float(skill["shootSpeedY"]))
			if key == "effect3":
				motion = Vector2.from_angle(deg_to_rad(angles[i])) * absf(motion.x)
			else:
				motion.x *= source_facing
			_projectile(
				"effect2_1",
				action,
				source_origin + offsets[i] * Vector2(source_facing if key == "effect2" else 1.0, 1.0),
				motion,
				_duration(skill),
				skill,
				{"bounce": true, "bounds": _view_rect()}
			)
		return
	if model == 3381 and key == "effect1":
		var source_origin := global_position
		var previous_delay := 0.0
		for i in range(3):
			var stage_delay: float = [0.528, 0.627, 0.726][i]
			if not await _delay(stage_delay - previous_delay, generation):
				return
			previous_delay = stage_delay
			for side in [-1, 1]:
				var origin := source_origin + Vector2(i * 80 * side, [-141, -180, -220][i])
				var motion := Vector2(
					float(skill["shootSpeedX"]) * (1.0 + 0.6 * i) * 3 * side, float(skill["shootSpeedY"]) * 3
				)
				_projectile("effect1_1", action, origin, motion, _duration(skill) * (1.0 + 0.1 * i), skill)
		return
	if model == 3430 and key == "effect2":
		if not await _delay(35.0 / 30, generation):
			return
		_aimed_shot("effect2_1", action, global_position + Vector2(0, -300), skill)
		return
	if model in [3400, 3421] and key == ("attack1" if model == 3400 else "effect2"):
		if not await _delay((23.0 if model == 3400 else 20.0) / 30, generation):
			return
		var target := RoleProp.get_nearest_monster_target_position(global_position)
		global_position.x = target.x
		if model == 3400:
			var hero := RoleProp.source_player as BaseHero
			var target_feet := target.y + 39.0
			var target_facing := 1.0
			if is_instance_valid(hero) and hero.global_position.distance_squared_to(target) < 4.0:
				var collider := hero.get_node("pz") as CollisionShape2D
				target_feet = collider.global_position.y + collider.shape.get_rect().end.y
				target_facing = -signf(hero.action.scale.x)
			var level := get_level_node()
			var room: Rect2 = level.source_battle_bounds() if level is NorthContinentLevel else _view_rect()
			if not room.has_area():
				room = _view_rect()
			global_position.x = clampf(target.x - target_facing * 50.0, room.position.x + 50, room.end.x - 50)
			global_position.y = target_feet - 60.0
		monster_direction = target.x >= global_position.x
		to_hero()
		if is_instance_valid(contact):
			contact.dir = _facing() > 0
		return
	if model == 3421 and key == "effect4":
		if not await _delay(float(frame) / 30, generation):
			return
		_body_motion = (Vector2(603, 160) - global_position) / _duration(skill)
		_body_motion_until = Time.get_ticks_msec() + int(skill["shootTime"])
		return
	if model in [3415, 3416, 3417, 3418, 3419, 3420] and key == "effect2":
		var endpoints := {
			3415: Vector2(144, 286),
			3416: Vector2(1078, 288),
			3417: Vector2(320, 205),
			3418: Vector2(898, 205),
			3419: Vector2(493, 450),
			3420: Vector2(715, 450)
		}
		if not await _delay(float(frame) / 30, generation):
			return
		_body_motion = (endpoints[model] - global_position) / _duration(skill)
		_body_motion_until = Time.get_ticks_msec() + int(skill["shootTime"])
		return
	if model == 3401 and key == "effect2":
		if not await _delay(0.825, generation):
			return
		var view := _view_rect()
		for side in [-1, 1]:
			var origin := Vector2(view.position.x - 100 if side == 1 else view.end.x + 100, global_position.y)
			_projectile(
				"effect2_1",
				action,
				origin,
				Vector2(absf(float(skill["shootSpeedX"])) * 3 * side, 0),
				_duration(skill),
				skill
			)
		return
	if model == 3422 and key.begins_with("attack"):
		var frames := [24] if key == "attack1" else ([27] if key == "attack2" else [31, 52, 68, 78])
		var previous := 0
		for source_frame in frames:
			if not await _delay(float(source_frame - previous) / 30, generation):
				return
			previous = source_frame
			_aimed_shot("attack1_1", action, global_position + Vector2(0, -190), skill)
		return
	if model == 3422 and key == "effect3":
		if not await _delay(0.858, generation):
			return
		var origin := Vector2(randf_range(_view_rect().position.x + 100, _view_rect().end.x - 100), 630)
		_projectile(
			"effect3_2",
			action,
			origin,
			Vector2.ZERO,
			27,
			skill,
			{
				"damage_enabled": false,
				"right": true,
				"shadow_callback": Callable(self, "_activate_shadow").bind(action, skill)
			}
		)
		return
	if model == 3422 and key == "effect1":
		if not await _delay(20.0 / 30, generation):
			return
		_projectile(
			"effect1_1",
			action,
			RoleProp.get_nearest_monster_target_position(global_position),
			Vector2.ZERO,
			2,
			skill,
			{"hit_callback": Callable(self, "_void_hit")}
		)
		return
	if model == 3422 and key == "protectSkill":
		if not await _delay(0.858, generation):
			return
		var view := _view_rect()
		var target := RoleProp.get_nearest_monster_target_position(global_position)
		_stationary_origin.x = (
			view.position.x + 320
			if absf(target.x - view.position.x - 320) > absf(target.x - view.end.x + 320)
			else view.end.x - 320
		)
		return
	if model == 3528 and key in ["attack1", "attack2"]:
		if not await _delay(1.0 / 30, generation):
			return
		var sequence := key + "_1"
		_projectile(
			sequence,
			action,
			global_position,
			Vector2.ZERO,
			float(_source["sequences"][sequence]["frames"].size()) / 30,
			skill
		)
		return
	if model == 3528 and key == "effect1":
		if not await _delay(1.0, generation):
			return
		_aimed_shot("effect1_1", action, Vector2(_view_rect().position.x, 0), skill)
		if not await _delay(2.0, generation):
			return
		_aimed_shot("effect1_2", action, Vector2(_view_rect().end.x, 0), skill)
		return
	if model == 3528 and key == "effect5":
		var level_node := get_level_node()
		if level_node != null:
			level_node.get_node("OriginalTerrain").darken_for(15)
	if model == 3539 and key == "effect4":
		if not await _delay(0.66, generation):
			return
		for burst in range(2):
			for i in range(10):
				var angle := (-PI / 2 if burst == 0 else -0.4 * PI) + i * PI / 10
				_projectile(
					"effect4_1",
					action,
					global_position + Vector2(145 * _facing(), -80),
					Vector2.from_angle(angle) * float(skill["shootSpeedX"]) * 3,
					4,
					skill
				)
			if not await _delay(0.99, generation):
				return
		return
	if model == 3539 and key == "effect1":
		if not await _delay(0.627, generation):
			return
		var sequence := "mc_effect1_1"
		var duration := float(_source["sequences"][sequence]["frames"].size()) / 30
		_projectile(
			sequence,
			action,
			global_position,
			Vector2.ZERO,
			duration,
			skill,
			{
				"damage_enabled": false,
				"loop_visual": false,
				"finished_callback": Callable(self, "_finish_glutton_charge").bind(action, skill)
			}
		)
		return
	if model == 3539 and key == "effect2":
		if not await _delay(1.089, generation):
			return
		for i in range(8):
			_projectile(
				"effect2_1",
				action,
				Vector2(_view_rect().position.x + 940 - i * 160, _view_rect().position.y + 500),
				Vector2.ZERO,
				0.6,
				skill
			)
			if not await _delay(0.7, generation):
				return
		return
	if model == 3499 and key == "effect2":
		var origin := global_position
		var target := RoleProp.get_nearest_monster_target_position(origin)
		var facing := _facing()
		if not await _delay(0.396, generation):
			return
		for y in [-42, -114]:
			var start := origin + Vector2(float(skill["x"]) * facing, y)
			_projectile(
				"effect2_1",
				action,
				start,
				start.direction_to(target) * float(skill["shootSpeedX"]) * 3,
				_duration(skill),
				skill
			)
		return
	if model == 3499 and key == "effect3":
		if not await _delay(18.0 / 30, generation):
			return
		var target := RoleProp.get_nearest_monster_target_position(global_position)
		var view := _view_rect()
		var x := target.x - 100 if target.x > global_position.x else target.x + 100
		global_position = Vector2(clampf(x, view.position.x + 100, view.end.x - 100), target.y - 70)
		_flight_height = global_position.y
		return
	if model == 3481 and key == "effect4":
		if not await _delay(float(frame) / 30, generation):
			return
		_standard_shot(action, skill)
		if not await _delay(2.0 - float(frame) / 30, generation):
			return
		var origin := Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 0)
		_projectile("effect4_3", action, origin, Vector2(0, -float(skill["shootSpeedY"]) * 3), _duration(skill), skill)
		return
	if model == 3430 and key == "effect3":
		frame = 30
	var delay := float(frame) / 30
	if model == 3353:
		delay = 0.462 if key == "effect4" else (0.99 if key == "effect5" else delay)
	if model == 3382 and key == "effect2":
		delay = 1.32
	if model == 3422 and key == "effect2":
		delay = 1.0
	if model == 3481 and key == "effect3":
		delay = 0.726
	if model == 3481 and key == "effect5":
		delay = 0.033
	if model == 3528 and key == "effect3":
		delay = 10.0 / 30
	if model == 3528 and key == "effect4":
		delay = 32.0 / 30
	if model == 3539 and key == "effect1":
		delay = 0.627
	if not await _delay(delay, generation):
		return
	_summon(skill, key)
	_standard_shot(action, skill)


func _facing() -> float:
	if int(_raw["model"]) == 3422:
		return 1.0
	if int(_raw["model"]) == 3528:
		return -1.0
	return 1.0 if monster_direction else -1.0


func _duration(skill: Dictionary) -> float:
	return maxf(float(skill.get("shootTime", "1000")) / 1000, 0.1)


func _standard_shot(action: StringName, skill: Dictionary) -> void:
	var assets := str(skill.get("assetLink", "")).split(",", false)
	if assets.is_empty():
		var effect_speed_x := float(skill.get("shootSpeedX", "-1"))
		if effect_speed_x != -1 and float(skill.get("shootTime", "-1")) > 0 and int(_raw["model"]) != 3384:
			_body_motion = Vector2(effect_speed_x * _facing(), float(skill.get("shootSpeedY", "0"))) * 3
			_body_motion_until = Time.get_ticks_msec() + int(skill["shootTime"])
		return
	var model := int(_raw["model"])
	var origin := global_position + Vector2(float(skill.get("x", "0")) * _facing(), float(skill.get("y", "0")))
	if model == 3371 and _skill_actions[action]["key"] == "effect3":
		origin.x = RoleProp.get_nearest_monster_target_position(global_position).x
	if model == 3372 and _skill_actions[action]["key"] == "effect3":
		origin.x = _view_rect().end.x if monster_direction else _view_rect().position.x
	var speed_x := float(skill.get("shootSpeedX", "0"))
	var velocity_source := Vector2(
		(0.0 if speed_x == -1 else speed_x) * 3 * _facing(), float(skill.get("shootSpeedY", "0")) * 3
	)
	var extra := {"gravity": 990.0 if skill.get("gravity", "0") == "1" else 0.0}
	var duration := _duration(skill)
	if int(_raw["classType"]) == 3487 or model in [3481, 3500] and assets[0] in ["attack1_1", "attack1"]:
		velocity_source = origin.direction_to(RoleProp.get_nearest_monster_target_position(origin)) * absf(speed_x) * 3
		extra["orient_to_motion"] = true
		extra["right"] = true
	if model in [3357, 3372, 3402] and assets[0] in ["effect2_1"]:
		var target := RoleProp.get_nearest_monster_target_position(origin)
		velocity_source.x = absf(target.x - global_position.x) / duration * _facing()
	if model == 3357 and assets.size() > 1:
		extra["impact_atlas_sequence"] = assets[1]
		extra["collide_terrain"] = true
		extra["source_impact"] = Callable(self, "_source_impact_damage").bind(assets[1], action, skill)
	if model == 3481 and assets[0] == "attack1_1":
		extra["impact_atlas_sequence"] = "attack1_2"
		extra["collide_terrain"] = true
	if model == 3372 and assets[0] == "effect2_1":
		extra["finished_callback"] = Callable(self, "_return_frost").bind(action, skill)
	if model == 3402:
		if assets[0] == "effect1_1":
			origin.y = global_position.y - 380
			var target := RoleProp.get_nearest_monster_target_position(origin) - Vector2(0, 40)
			velocity_source = origin.direction_to(target) * absf(speed_x) * 3
			duration = origin.distance_to(target) / maxf(velocity_source.length(), 1)
			extra["right"] = true
			extra["orient_to_motion"] = true
			extra["finished_callback"] = Callable(self, "_ring_land")
		elif assets[0] == "effect2_1":
			extra["finished_callback"] = Callable(self, "_return_ring").bind(action, skill)
		elif assets[0] == "effect3_1":
			origin.x = RoleProp.get_nearest_monster_target_position(origin).x
			velocity_source = Vector2.ZERO
			_rain_weapons(action, skill, origin, duration)
	if int(skill.get("shootTime", "0")) < 0 and _source["sequences"].has(assets[0]):
		duration = float(_source["sequences"][assets[0]]["frames"].size()) / 30
	_projectile(assets[0], action, origin, velocity_source, duration, skill, extra)


func _aimed_shot(sequence: String, action: StringName, origin: Vector2, skill: Dictionary) -> void:
	var target := RoleProp.get_nearest_monster_target_position(origin)
	_projectile(
		sequence, action, origin, origin.direction_to(target) * float(skill["shootSpeedX"]) * 3, _duration(skill), skill
	)


func _source_impact_damage(origin: Vector2, sequence: String, action: StringName, skill: Dictionary) -> void:
	if not is_inside_tree() or death():
		return
	var duration := float(_source["sequences"][sequence]["frames"].size()) / 30
	var damage := _projectile(sequence, action, origin, Vector2.ZERO, duration, skill, {"loop_visual": false})
	if damage != null:
		damage.visible = false


func _projectile(
	sequence: String,
	action: StringName,
	origin: Vector2,
	motion: Vector2,
	duration: float,
	skill: Dictionary,
	extra: Dictionary = {}
) -> WutaiMinghaiProjectile:
	if not _source["sequences"].has(sequence):
		return null
	var metadata := _metadata_path()
	var impact_sequence := str(extra.get("impact_atlas_sequence", ""))
	if not impact_sequence.is_empty() and _source["sequences"].has(impact_sequence):
		var impact_frame_count: int = _source["sequences"][impact_sequence]["frames"].size()
		extra["impact_atlas_metadata"] = metadata
		extra["impact_frame_count"] = impact_frame_count
		extra["impact_duration"] = float(impact_frame_count) / SOURCE_FPS
		var resource_path := _standard_body_frames_path()
		if not resource_path.is_empty():
			extra["impact_frames_resource"] = resource_path
			extra["impact_frames_animation"] = impact_sequence
	var rotates: bool = skill.get("arrow", "0") == "1" and not motion.is_zero_approx()
	var config := {
		"owner": self,
		"position": origin,
		"right": true if rotates else _facing() > 0,
		"visual_faces_right": true,
		"hit_name": str(action),
		"attack_data": _attack_entry(action),
		"skill_name": "North_%s_%s" % [monster_kind, sequence],
		"atlas_metadata": metadata,
		"atlas_sequence": sequence,
		"frames_resource": _standard_body_frames_path(),
		"frames_animation": sequence,
		"frame_fps": SOURCE_FPS,
		"velocity": motion,
		"lifetime": duration,
		"damage_duration": duration,
		"loop_visual": true,
		"expire_on_hit": false,
		"track_target": false,
		"orient_to_motion": rotates,
		"max_hits": maxi(int(skill.get("attMax", "1")), 1),
		"hit_callback": Callable(self, "_apply_source_buffs").bind(skill),
		"damage_pulse_interval": maxf(float(skill.get("attInterval", "200")) / 1000, 0.1),
		"poll_overlaps_on_damage_pulse": true
	}
	config.merge(extra, true)
	if bool(config["orient_to_motion"]):
		config["right"] = true
	var projectile := NORTH_PROJECTILE.new() as WutaiMinghaiProjectile
	projectile.configure(config)
	bullet.add_child(projectile)
	if extra.has("mask_sequence"):
		var alias := str(extra["mask_sequence"])
		projectile.source_masks[sequence] = _source["masks"][alias]
	source_projectile_spawned.emit(sequence, projectile)
	return projectile


func _summon(skill: Dictionary, key: String) -> void:
	var ids := NorthOriginalData.numbers(skill.get("summonMonster", ""))
	var offsets := NorthOriginalData.numbers(skill.get("summonCoord", "0,0"))
	var model := int(_raw["model"])
	var level_node := get_level_node()
	if level_node == null:
		return
	if model == 3401:
		for child in _sons:
			if is_instance_valid(child) and not child.death():
				return
	if model == 3409 and not ids.is_empty():
		for child in _sons:
			if is_instance_valid(child):
				child.hp = 0
		_sons.clear()
	if model == 3499 and key == "effect4":
		ids = ids + ids + ids
	if model == 3409:
		ids = ids + ids
	if model == 3431:
		ids = ids + ids + ids
	var ordinal := 0
	for id_value in ids:
		var origin := global_position
		if offsets.size() >= 2:
			origin += Vector2(float(offsets[0]) * _facing(), float(offsets[1]))
		if model == 3382 and key in ["effect3", "effect4"]:
			origin = Vector2(
				randf_range(_view_rect().position.x + 100, _view_rect().end.x - 100), randf_range(300, 400)
			)
		if model == 3481 and key == "effect3":
			origin.x = randf_range(_view_rect().position.x + 100, _view_rect().end.x - 100)
		if model == 3499:
			origin = Vector2(randf_range(_view_rect().position.x + 75, _view_rect().end.x - 150), randf_range(100, 500))
		if model == 3409:
			origin.x = 0 if ordinal == 0 else 1200
		if model == 3431:
			origin.x = global_position.x + 20 * ordinal
		ordinal += 1
		var son := Global.create_monster(int(id_value), level_node.monster, origin)
		if son == null:
			continue
		son.set_meta("allow_position_y_over_800", true)
		_sons.append(son)
		if model == 3481 and key == "effect5":
			_tree = son
			no_grav = true
			_next_cast = Time.get_ticks_msec() + 2000
		var maximum := int(skill.get("summonNumMax", "-1"))
		if model == 3382:
			maximum = 2 if key == "effect3" else 3
		if maximum > 0:
			var matching: Array = []
			for child in _sons:
				if is_instance_valid(child) and not child.death() and child.monster_kind == int(id_value):
					matching.append(child)
			if matching.size() > maximum:
				matching[0].hp = 0


func _ring_land(endpoint: Vector2) -> void:
	if is_inside_tree() and not death():
		global_position = endpoint


func _return_ring(endpoint: Vector2, action: StringName, skill: Dictionary) -> void:
	if not is_inside_tree() or death():
		return
	var duration := _duration(skill) / 2
	_projectile(
		"effect2_1",
		action,
		endpoint,
		(global_position - endpoint) / duration,
		duration,
		skill,
		{"gravity": 0.0, "orient_to_motion": skill.get("arrow", "0") == "1"}
	)


func _rain_weapons(action: StringName, skill: Dictionary, origin: Vector2, duration: float) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		if not await _delay(0.1, _cast_generation):
			return
		elapsed += 0.1
		_projectile(
			"effect3_%d" % randi_range(3, 11),
			action,
			origin + Vector2(randf_range(-185, 185), 0),
			Vector2(0, float(skill["shootSpeedY"]) * 3),
			_duration(skill),
			skill,
			{"gravity": 990.0}
		)


func _return_frost(endpoint: Vector2, action: StringName, skill: Dictionary) -> void:
	if not is_inside_tree() or death():
		return
	var destination := global_position + Vector2(0, -40)
	_projectile("effect2_1", action, endpoint, (destination - endpoint) / 0.66, 0.66, skill)


func _void_hit(_projectile: WutaiMinghaiProjectile, _target: BaseHero) -> void:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("enter_void_space"):
		level_node.enter_void_space(self)


func _activate_shadow(origin: Vector2, action: StringName, skill: Dictionary) -> void:
	if is_inside_tree() and not death():
		_projectile("effect3_4", action, origin, Vector2.ZERO, 3.0, skill, {"right": true})


func _finish_glutton_charge(endpoint: Vector2, action: StringName, skill: Dictionary) -> void:
	if not is_inside_tree() or death():
		return
	_projectile("effect1_2", action, endpoint, Vector2(float(skill["shootSpeedX"]) * 3 * _facing(), 0), 4, skill)


func _cast_snow_guard(action: StringName, skill: Dictionary) -> void:
	var reduction := NorthOriginalData.buff_record("190014")
	var armor := NorthOriginalData.buff_record("60298")
	if reduction.is_empty() or armor.is_empty():
		return
	var duration := float(reduction["time"]) / 1000.0
	var level := get_level_node()
	for ally in level.monster.get_children():
		if not ally is BaseMonster or not ally.has_method("_cast_snow_guard") or ally.death():
			continue
		ally._snow_guard_until = Time.get_ticks_msec() + int(armor["time"])
		ally._snow_guard_ratio = float(reduction["attributeV1"])
		ally._enforce_control_immunity_state()
		if is_instance_valid(ally.snow_guard_visual) and not ally.snow_guard_visual._finished:
			ally.snow_guard_visual._elapsed = 0.0
		else:
			ally.snow_guard_visual = _projectile(
				"attack1_1",
				action,
				ally.global_position,
				Vector2.ZERO,
				duration,
				skill,
				{"owner": ally, "follow_owner": true, "damage_enabled": false}
			)


func _apply_source_buffs(_projectile: WutaiMinghaiProjectile, target: BaseHero, skill: Dictionary) -> void:
	for id: String in str(skill.get("buffId", "")).split(",", false):
		var record := NorthOriginalData.buff_record(id)
		if record.is_empty():
			continue
		var name := ""
		var value := 0.0
		match int(record["type"]):
			2:
				name = "Ice" if "冰冻" in str(record["name"]) or "酷寒" in str(record["name"]) else "stun"
			3:
				name = "Immobilize"
			4:
				name = "silent"
			21:
				name = "speed_down"
				value = absf(float(record["attributeV1"]))
			17:
				var direction := target.global_position.direction_to(global_position)
				target.velocity = direction * float(record["attributeV1"]) * 3
		if not name.is_empty():
			Global.add_buff(
				target.buff,
				{
					"Name": name,
					"AddTime": float(record["time"]) / 1000,
					"reduce_interval": 0,
					"value": value,
					"CanRemove": true,
					"CanAdd": name != "speed_down",
					"DeBuff": true
				}
			)

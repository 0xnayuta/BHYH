extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3070"
const FRAMES := ROOT + "/atlas/swf_png_3070_frames.tres"
const SOURCE_FPS := 30.0
const SMALL_HURT_DURATION := 0.28
const AI_DELAY_MSEC := 1000
const PHASE_TWO_INTERVAL := 5.0

const ACTIONS := {
	&"wait": {"folder": "wait", "frames": 20, "offset": Vector2(-27.7, -67.5), "loop": true},
	&"walk": {"folder": "walk", "frames": 20, "offset": Vector2(-25.4, -68.3), "loop": true},
	&"hurt": {"folder": "hurt", "frames": 35, "offset": Vector2(-36.7, -65.1), "loop": false},
	&"death": {"folder": "death", "frames": 35, "offset": Vector2(-46.45, -14.7), "loop": false},
	&"skill1": {"folder": "effect1", "frames": 47, "offset": Vector2(52.95, -65.0), "loop": false},
	&"skill2": {"folder": "effect2", "frames": 30, "offset": Vector2(-8.05, -74.1), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 42, "offset": Vector2(-16.05, -90.65), "loop": false},
	&"skill4": {"folder": "effect4", "frames": 54, "offset": Vector2(-6.4, -61.45), "loop": false},
}

const SCREEN_X_POSITIONS := [100.0, 200.0, 300.0, 400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1100.0]
const PHASE_ONE_SEQUENCE := [1, 2, 1, 3]

@export var monster_kind := 3070

static var _frames_cache: SpriteFrames

var _runtime_config: Dictionary = {}
var _busy := false
var _death_started := false
var _death_count := 0
var _attack_serial := 0
var _skill_cycle := 0
var _next_attack_msec := 0
var _skill_direction := 1.0


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_boss(_runtime_config)
	_build_animations()
	super._ready()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WutaiBoss3070 requires level monster config for 3070")
	return {}


func _configure_boss(config: Dictionary = {}) -> void:
	if config.is_empty():
		config = _runtime_config
	if config.is_empty():
		return
	my_mr_name = str(config.get("name", "芙蓉仙子"))
	level = int(config["level"])
	attack_in = int(config["attack"])
	max_hp = int(config["hp"])
	hp = max_hp
	def = int(config["def"])
	mdef = int(config["mdef"])
	crit = int(config["crit"])
	miss = int(config["miss"])
	htarget = int(config["hit"])
	toughness = float(config["toughness"])
	crit_reduce = int(config["crit_reduce"])
	ar = int(config["armor_break"])
	sp = int(config["magic_break"])
	speed = float(config["speed"])
	mysee = int(config["sight"])
	attack_range = int(config["range"])
	attack_desire = int(config["attack_desire"])
	add_exp = int(config["exp"])
	fall_coin = int(config["coin"])
	fall_pro = float(config["drop_rate"])
	fall_list = Array(config["drop_list"]).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	obj_attack_dict.clear()
	var attacks: Dictionary = config["attacks"]
	for attack_name: String in attacks:
		obj_attack_dict[attack_name] = _attack_data(attacks[attack_name])


func _attack_data(attack: Dictionary) -> Dictionary:
	return {
		"power": roundi(float(attack_in) * float(attack["multiplier"])),
		"hurtBack": Array(attack["hurt_back"]).duplicate(),
		"attackKind": str(attack["kind"]),
		"HitProtect": int(attack["protect"]),
	}


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


static func prewarm_frames() -> void:
	_get_sprite_frames()


static func prewarm_effects() -> void:
	pass


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3070_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action_name: StringName in ACTIONS:
		var info: Dictionary = ACTIONS[action_name]
		var sequence_name := StringName(str(info["folder"]))
		if not source.has_animation(sequence_name):
			return null
		frames.add_animation(action_name)
		frames.set_animation_speed(action_name, source.get_animation_speed(sequence_name))
		frames.set_animation_loop(action_name, bool(info["loop"]))
		for frame_index in range(source.get_frame_count(sequence_name)):
			frames.add_frame(action_name, source.get_frame_texture(sequence_name, frame_index))
	return frames


static func _get_sprite_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var standard := _load_standard_frames()
	if standard != null:
		_frames_cache = standard
		return standard
	return null


func _build_animations() -> void:
	var frames := _get_sprite_frames()
	if frames != null:
		mr_ani.sprite_frames = frames
		mr_ani.centered = true
		mr_ani.visible = true
	else:
		mr_ani.visible = false
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name: StringName in ACTIONS:
		var info: Dictionary = ACTIONS[action_name]
		var animation := _make_animation(action_name, int(info["frames"]), bool(info["loop"]))
		match action_name:
			&"skill1":
				_add_method_key(animation, 0.0, &"_start_skill1_pulses")
			&"skill2":
				_add_method_key(animation, 0.7, &"_spawn_skill2_vine")
			&"skill3":
				_add_method_key(animation, 0.0, &"_start_skill3_barrage")
			&"skill4":
				_add_method_key(animation, 0.0, &"_start_skill4_barrage")
			&"death":
				_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = SMALL_HURT_DURATION if action_name == &"hurt" else maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_body_action", [action_name])
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _play_body_action(action_name: StringName) -> void:
	var info: Dictionary = ACTIONS.get(action_name, ACTIONS[&"wait"])
	var custom_speed: float = (
		float(info["frames"]) / (SMALL_HURT_DURATION * SOURCE_FPS) if action_name == &"hurt" else 1.0
	)
	if mr_ani.sprite_frames != null:
		mr_ani.visible = true
		mr_ani.position = info["offset"]
		mr_ani.play(action_name, custom_speed)


func ai_think() -> void:
	if (
		_death_count > 0
		or _busy
		or death()
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
		or _runtime_config.is_empty()
	):
		return
	var distance := absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	_face_role()
	if Time.get_ticks_msec() < _next_attack_msec:
		stop_move()
		return
	var skill_index := _next_usable_skill(distance)
	if skill_index == 0:
		_move_toward_role()
		return
	_start_skill(skill_index)


func _next_usable_skill(distance: float) -> int:
	if max_hp > 0 and hp <= max_hp * 0.5:
		var candidates := [1, 2, 3]
		candidates.shuffle()
		for candidate in candidates:
			if _skill_in_range(int(candidate), distance):
				return int(candidate)
		return 0
	for step in range(PHASE_ONE_SEQUENCE.size()):
		var candidate := int(PHASE_ONE_SEQUENCE[(_skill_cycle + step) % PHASE_ONE_SEQUENCE.size()])
		if _skill_in_range(candidate, distance):
			_skill_cycle = (_skill_cycle + step + 1) % PHASE_ONE_SEQUENCE.size()
			return candidate
	return 0


func _skill_in_range(skill_index: int, distance: float) -> bool:
	match skill_index:
		1:
			return distance <= 266.0
		2:
			return distance >= 30.0 and distance <= 750.0
		3:
			return true
	return false


func _start_skill(skill_index: int) -> void:
	if death() or _death_started:
		return
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	_face_role()
	hit_name = "hit%d" % skill_index
	_disable_attack_box()
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_disable_attack_box()
	_busy = false
	is_attacking = false
	velocity.x = 0.0
	_next_attack_msec = Time.get_ticks_msec() + AI_DELAY_MSEC
	mr_player.play(&"wait")


func _start_skill1_pulses() -> void:
	_set_attack_box(Vector2(266.0, 140.0), Vector2(-133.0, -70.0))
	_run_attack_pulses(_attack_serial, 3, 0.334)


func _spawn_skill2_vine() -> void:
	if death() or not _busy:
		return
	var target_position := global_position + Vector2(100.0 * _skill_direction, 0.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_position.x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	target_position.y = global_position.y
	_spawn_projectile(
		{
			"position": target_position,
			"right": _skill_direction > 0.0,
			"hit_name": "hit2",
			"attack_data": _attack_entry(&"hit2"),
			"skill_name": "WutaiFairyBloodVine",
			"frame_root": ROOT.path_join("effect2_1"),
			"frame_count": 15,
			"loop_visual": false,
			"visual_offset": Vector2(-1.5, -18.0),
			"impact_frame_root": ROOT.path_join("effect2_2"),
			"impact_frame_count": 16,
			"impact_visual_offset": Vector2(2.0, -33.05),
			"collision_size": Vector2(95.0, 145.0),
			"collision_offset": Vector2(0.0, -65.0),
			"lifetime": 0.5,
			"damage_duration": 0.5,
		}
	)


func _start_skill3_barrage() -> void:
	_run_skill3_barrage(_attack_serial)


func _run_skill3_barrage(serial: int) -> void:
	var positions := SCREEN_X_POSITIONS.duplicate()
	positions.shuffle()
	positions.resize(8)
	for x_value in positions:
		if death() or serial != _attack_serial:
			return
		var start_position := Vector2(float(x_value), global_position.y - 400.0)
		_spawn_visual_effect("effect3_1", 20, start_position, Vector2.ZERO, 20.0 / SOURCE_FPS)
		_delayed_skill3_fall(start_position, serial)


func _delayed_skill3_fall(start_position: Vector2, serial: int) -> void:
	await get_tree().create_timer(0.6, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_spawn_projectile(
		{
			"position": start_position,
			"right": true,
			"hit_name": "hit3",
			"attack_data": _attack_entry(&"hit3"),
			"skill_name": "WutaiFairyFlowerFall",
			"frame_root": ROOT.path_join("effect3_2"),
			"frame_count": 20,
			"loop_visual": true,
			"velocity": Vector2(0.0, 105.0),
			"collision_size": Vector2(54.0, 74.0),
			"lifetime": 4.133,
			"damage_duration": 4.133,
			"expire_on_hit": false,
		}
	)


func _start_skill4_barrage() -> void:
	_run_skill4_barrage(_attack_serial)


func _run_skill4_barrage(serial: int) -> void:
	var positions: Array = SCREEN_X_POSITIONS.slice(0, 8)
	positions.shuffle()
	for position_index in range(positions.size()):
		if death() or serial != _attack_serial:
			return
		var start_position := Vector2(float(positions[position_index]), global_position.y - 400.0)
		_spawn_visual_effect("effect4_1", 20, start_position, Vector2.ZERO, 20.0 / SOURCE_FPS)
		_delayed_skill4_aim(start_position, serial)
		if position_index + 1 < positions.size():
			await get_tree().create_timer(0.5, false).timeout


func _delayed_skill4_aim(start_position: Vector2, serial: int) -> void:
	await get_tree().create_timer(0.3, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_spawn_visual_effect("effect3_2", 20, start_position, Vector2.ZERO, 0.3, true)
	await get_tree().create_timer(0.3, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	var target_position := start_position + Vector2.DOWN
	if (
		RoleProp.get_nearest_monster_target_position(global_position).x != null
		and RoleProp.get_nearest_monster_target_position(global_position).y != null
	):
		target_position = Vector2(
			float(RoleProp.get_nearest_monster_target_position(global_position).x),
			float(RoleProp.get_nearest_monster_target_position(global_position).y)
		)
	var direction := start_position.direction_to(target_position)
	_spawn_projectile(
		{
			"position": start_position,
			"right": direction.x >= 0.0,
			"hit_name": "hit4",
			"attack_data": _attack_entry(&"hit4"),
			"skill_name": "WutaiFairyFatalFlower",
			"frame_root": ROOT.path_join("effect4_2"),
			"frame_count": 12,
			"loop_visual": true,
			"visual_offset": Vector2(0.3, 3.15),
			"velocity": direction * 120.0,
			"orient_to_motion": true,
			"collision_size": Vector2(44.0, 44.0),
			"lifetime": 5.0,
			"damage_duration": 5.0,
			"expire_on_hit": false,
		}
	)


func _spawn_visual_effect(
	folder: String,
	frame_count: int,
	effect_position: Vector2,
	effect_offset: Vector2,
	duration: float,
	looped: bool = false
) -> void:
	_spawn_projectile(
		{
			"position": effect_position,
			"right": true,
			"hit_name": "",
			"attack_data": {},
			"skill_name": "WutaiFairyVisual",
			"frame_root": ROOT.path_join(folder),
			"frame_count": frame_count,
			"loop_visual": looped,
			"visual_offset": effect_offset,
			"lifetime": duration,
			"damage_enabled": false,
		}
	)


func _run_attack_pulses(serial: int, count: int, interval: float) -> void:
	var next_pulse_msec := Time.get_ticks_msec()
	for pulse_index in range(count):
		if death() or serial != _attack_serial:
			return
		_enable_attack_box()
		await get_tree().physics_frame
		await get_tree().physics_frame
		if not is_instance_valid(self) or death() or serial != _attack_serial:
			return
		_disable_attack_box()
		if pulse_index + 1 < count:
			next_pulse_msec += roundi(interval * 1000.0)
			var delay := maxf(float(next_pulse_msec - Time.get_ticks_msec()) / 1000.0, 0.0)
			if delay > 0.0:
				await get_tree().create_timer(delay, false).timeout


func _begin_second_phase() -> void:
	_death_count = 1
	_attack_serial += 1
	hp = maxi(1, roundi(float(max_hp) * 0.01))
	_busy = false
	is_attacking = false
	velocity = Vector2.ZERO
	_disable_attack_box()
	_cancel_hurt_reaction()
	mr_player.play(&"wait")
	_phase_two_loop()


func _phase_two_loop() -> void:
	while is_instance_valid(self) and not _death_started and not death():
		if not _busy:
			_start_skill(4)
		await get_tree().create_timer(PHASE_TWO_INTERVAL, false).timeout


func _spawn_projectile(config: Dictionary) -> WutaiMinghaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var sequence := str(config.get("frame_root", "")).get_file()
	config["owner"] = self
	if sequence.is_empty():
		config["visual_backend"] = WutaiMinghaiProjectile.VisualBackend.NONE
	else:
		config["visual_backend"] = WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES
		config["frames_resource"] = FRAMES
		config["frames_animation"] = sequence
		config["frame_root"] = ""
	var impact_sequence := str(config.get("impact_frame_root", "")).get_file()
	if impact_sequence.is_empty():
		config["impact_visual_backend"] = WutaiMinghaiProjectile.VisualBackend.NONE
	else:
		config["impact_visual_backend"] = WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES
		config["impact_frames_resource"] = FRAMES
		config["impact_frames_animation"] = impact_sequence
		config["impact_frame_root"] = ""
	if not config.has("damage_enabled"):
		config["damage_enabled"] = not (config["attack_data"] as Dictionary).is_empty()
	if not projectile.configure(config):
		projectile.free()
		return null
	bullet.add_child(projectile)
	return projectile


func _attack_entry(attack_name: StringName) -> Dictionary:
	var key := str(attack_name)
	if obj_attack_dict.has(key):
		return (obj_attack_dict[key] as Dictionary).duplicate(true)
	push_error("WutaiBoss3070 level config is missing attack %s" % attack_name)
	return {}


func _set_attack_box(box_size: Vector2, box_position: Vector2) -> void:
	if hit_box == null:
		return
	var rectangle := hit_box.shape as RectangleShape2D
	if rectangle == null:
		rectangle = RectangleShape2D.new()
		hit_box.shape = rectangle
	rectangle.size = box_size
	hit_box.position = box_position


func _enable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _face_role() -> void:
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	_skill_direction = (
		1.0 if float(RoleProp.get_nearest_monster_target_position(global_position).x) >= global_position.x else -1.0
	)
	monster_dir.scale.x = _skill_direction
	base_damage_box.scale.x = -_skill_direction


func _move_toward_role() -> void:
	_face_role()
	velocity.x = speed * 10.0 * _skill_direction
	mr_player.play(&"walk")


func state_hurt() -> void:
	if death() or _busy:
		return
	super.state_hurt()


func _finish_hurt_reaction(hurt_generation: int) -> void:
	super._finish_hurt_reaction(hurt_generation)
	velocity.x = 0.0


func state_death() -> void:
	if _death_started:
		return
	if _death_count == 0:
		_begin_second_phase()
		return
	_death_started = true
	_death_count = 2
	_attack_serial += 1
	_busy = true
	_disable_attack_box()
	no_grav = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()


func get_ice_effect_offset() -> Vector2:
	return Vector2(0.0, 9.0)

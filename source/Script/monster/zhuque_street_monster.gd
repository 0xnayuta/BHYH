extends BaseMonster

const SOURCE_FPS := 30.0
const FRAME_ROOT := "res://Art/monster/swf_png"
const SMALL_HURT_DURATION := 0.28
const SMALL_CORPSE_LIFETIME := 0.75
const BOSS_CORPSE_LIFETIME := 1.0

@export_enum("猛虎射手:3002", "特处士:3006") var monster_kind := 3002

const DATA := {
	3002:
	{
		"name": "猛虎射手",
		"level": 90,
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"crit": 340,
		"miss": 170,
		"hit": 330,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 1100,
		"magic_break": 1100,
		"speed": 12.0,
		"range": 400.0,
		"min_range": 130.0,
		"sight": 820.0,
		"exp": 12,
		"coin": 10,
		"is_boss": false,
		"max_protect": 100.0,
		"cooldown": 1050,
		"attacks":
		{
			"arrow": {"multiplier": 1.0, "hurt_back": [-3, -1], "kind": "physics", "protect": 70},
		},
		"animations":
		{
			&"wait": ["wait", 20, true],
			&"walk": ["walk", 16, true],
			&"hurt": ["hurt", 18, false],
			&"death": ["death", 100, false],
			&"hit1": ["attack1", 25, false]
		},
	},
	3006:
	{
		"name": "特处士",
		"level": 90,
		"hp": 22000000,
		"attack": 35000,
		"def": 5200,
		"mdef": 5200,
		"crit": 720,
		"miss": 180,
		"hit": 500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 3100,
		"magic_break": 3100,
		"speed": 10.0,
		"range": 160.0,
		"min_range": 0.0,
		"sight": 1200.0,
		"exp": 120,
		"coin": 320,
		"is_boss": true,
		"max_protect": 250.0,
		"cooldown": 900,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-4, -2], "kind": "physics", "protect": 90},
			"hit2": {"multiplier": 0.25, "hurt_back": [-3, -1], "kind": "physics", "protect": 55},
			"hit3": {"multiplier": 0.5, "hurt_back": [-5, -2], "kind": "magic", "protect": 100},
		},
		"animations":
		{
			&"wait": ["wait", 20, true],
			&"walk": ["walk", 16, true],
			&"hurt": ["hurt", 21, false],
			&"death": ["death", 103, false],
			&"hit1": ["skill1", 37, false],
			&"hit2": ["skill2", 53, false],
			&"hit3": ["skill3", 40, false]
		},
	},
}

const VISUAL_OFFSETS := {
	3002:
	{
		&"wait": Vector2(5.0, -41.75),
		&"walk": Vector2(7.0, -40.5),
		&"hurt": Vector2(-22.5, -42.75),
		&"death": Vector2(-3.25, -27.5),
		&"hit1": Vector2(2.25, -42.5),
	},
	3006:
	{
		&"wait": Vector2(0.75, -71.5),
		&"walk": Vector2(0.25, -70.25),
		&"hurt": Vector2(-23.25, -74.0),
		&"death": Vector2(-33.25, -30.5),
		&"hit1": Vector2(74.75, -79.75),
		&"hit2": Vector2(-10.5, -60.0),
		&"hit3": Vector2(47.5, -55.75),
	},
}

static var _frames_cache: Dictionary = {}
var _skill_busy := false
var _next_attack_msec := 0
var _attack_serial := 0
var _death_sequence_started := false
var _runtime_config: Dictionary = {}
var _body_stream: StreamedPngEffect


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_monster()
	_build_animations()
	super._ready()


func _configure_monster() -> void:
	if _runtime_config.is_empty():
		_runtime_config = _resolve_runtime_config()
	if _runtime_config.is_empty():
		return
	var config: Dictionary = _runtime_config
	my_mr_name = str(config.get("name", "怪物%d" % monster_kind))
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
	attack_desire = int(config.get("attack_desire", 100))
	add_exp = int(config["exp"])
	fall_coin = int(config["coin"])
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	_build_base_attack_data(config)


func _build_base_attack_data(config: Dictionary) -> void:
	obj_attack_dict.clear()
	var attacks: Dictionary = config["attacks"]
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		obj_attack_dict[attack_name] = {
			"power": int(float(config["attack"]) * float(attack["multiplier"])),
			"hurtBack": attack["hurt_back"].duplicate(),
			"attackKind": str(attack["kind"]),
			"HitProtect": int(attack["protect"]),
		}


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", DATA[monster_kind]["attack"]))


func _resolve_runtime_config() -> Dictionary:
	var config: Dictionary = DATA[monster_kind].duplicate(true)
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if level_config is Dictionary and not level_config.is_empty():
			config.merge(level_config, true)
	return config


func monster_info_attack_values_include_difficulty() -> bool:
	return false


func _finish_hurt_reaction(hurt_generation: int) -> void:
	super._finish_hurt_reaction(hurt_generation)
	if not is_boss:
		velocity.x = 0.0


func get_ice_effect_offset() -> Vector2:
	return Vector2(0, 10)


func _build_animations() -> void:
	var frames := _get_sprite_frames()
	if frames != null:
		mr_ani.sprite_frames = frames
		mr_ani.visible = true
	elif monster_kind == 3006:
		mr_ani.visible = false
	mr_ani.centered = true
	mr_ani.flip_h = true
	mr_ani.position = _visual_offset(&"wait")
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	var animations: Dictionary = DATA[monster_kind]["animations"]
	for animation_name: StringName in animations:
		var animation_data: Array = animations[animation_name]
		var animation := _make_animation(animation_name, int(animation_data[1]), bool(animation_data[2]))
		if animation_name == &"death":
			_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		elif monster_kind == 3002 and animation_name == &"hit1":
			_add_method_key(animation, 13.0 / SOURCE_FPS, &"_fire_arrow")
		library.add_animation(animation_name, animation)
	mr_player.add_animation_library(&"", library)


func _load_standard_frames() -> SpriteFrames:
	var frames_path := FRAME_ROOT.path_join(str(monster_kind)).path_join("atlas").path_join(
		"swf_png_%d_frames.tres" % monster_kind
	)
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames


func _get_sprite_frames() -> SpriteFrames:
	if _frames_cache.has(monster_kind):
		return _frames_cache[monster_kind] as SpriteFrames
	var animations: Dictionary = DATA[monster_kind]["animations"]
	var standard := _load_standard_frames()
	if standard != null:
		_frames_cache[monster_kind] = standard
		return standard
	return null


func _make_animation(animation_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	if not is_boss and animation_name == &"hurt":
		animation.length = SMALL_HURT_DURATION
	else:
		animation.length = maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(track, 0.0, {"method": &"_play_frames", "args": [animation_name]})
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, animation.length - 0.001), {"method": method_name, "args": args}
	)


func _play_frames(animation_name: StringName) -> void:
	var custom_speed := 1.0
	if not is_boss and animation_name == &"hurt":
		var hurt_data: Array = DATA[monster_kind]["animations"][&"hurt"]
		custom_speed = float(hurt_data[1]) / (SMALL_HURT_DURATION * SOURCE_FPS)

	mr_ani.visible = true
	mr_ani.position = _visual_offset(animation_name)
	mr_ani.play(animation_name, custom_speed)


func _visual_offset(animation_name: StringName) -> Vector2:
	var offsets: Dictionary = VISUAL_OFFSETS[monster_kind]
	var offset: Vector2 = offsets.get(animation_name, offsets[&"wait"])
	if mr_ani.flip_h:
		offset.x = -offset.x
	return offset


func ai_think() -> void:
	if _skill_busy or cannotchangestatewhenattorbeatt() or death():
		return
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		has_target = false
		stop_move()
		return
	var distance := absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	to_hero()
	if monster_kind == 3006:
		_boss_intelligence(distance)
		return
	var config: Dictionary = _runtime_config
	var minimum_range := float(config["min_range"])
	if minimum_range > 0.0 and distance < minimum_range:
		_move_away_from_hero()
	elif distance > float(attack_range):
		have_target()
	elif Time.get_ticks_msec() >= _next_attack_msec:
		_start_attack(_choose_attack())
	else:
		stop_move()


func _boss_intelligence(distance: float) -> void:
	if Time.get_ticks_msec() < _next_attack_msec:
		stop_move()
		return
	if distance > 500.0:
		have_target()
	elif distance > 160.0:
		_start_attack(&"hit2")
	else:
		_start_attack(&"hit1" if randi_range(0, 1) == 0 else &"hit3")


func _move_away_from_hero() -> void:
	if float(RoleProp.get_nearest_monster_target_position(global_position).x) > position.x:
		move_left()
	else:
		move_right()


func _choose_attack() -> StringName:
	return &"hit1"


func _start_attack(attack_name: StringName) -> void:
	if not mr_player.has_animation(attack_name):
		return
	_attack_serial += 1
	var serial := _attack_serial
	hit_name = str(attack_name)
	velocity.x = 0.0
	is_attacking = true
	_skill_busy = true
	if monster_kind == 3006:
		super_armor_active = true
		cannot_attract = true
		await _run_boss_skill(attack_name, serial)
		return
	mr_player.play(attack_name)
	await mr_player.animation_finished
	if not is_instance_valid(self) or serial != _attack_serial or death() or not _skill_busy:
		return
	_finish_attack()


func _run_boss_skill(attack_name: StringName, serial: int) -> void:
	mr_player.play(attack_name)
	match attack_name:
		&"hit1":
			await get_tree().create_timer(0.28, false).timeout
			if not _boss_skill_valid(serial):
				return
			await _pulse_attack(&"hit1", 0.12)
			await get_tree().create_timer(0.314, false).timeout
			if not _boss_skill_valid(serial):
				return
			await _pulse_attack(&"hit1", 0.12)
		&"hit2":
			await get_tree().create_timer(16.0 / SOURCE_FPS, false).timeout
			if not _boss_skill_valid(serial):
				return
			await _run_boss_dash(serial)
		&"hit3":
			await get_tree().create_timer(0.22, false).timeout
			if not _boss_skill_valid(serial):
				return
			await _pulse_attack(&"hit3", 0.12)
			await get_tree().create_timer(0.48, false).timeout
			if not _boss_skill_valid(serial):
				return
			await _pulse_attack(&"hit3", 0.12)
	if not _boss_skill_valid(serial):
		return
	if mr_player.is_playing():
		await mr_player.animation_finished
	if _boss_skill_valid(serial):
		_finish_attack()


func _run_boss_dash(serial: int) -> void:
	var target_x := position.x + (360.0 if monster_direction else -360.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position:x", target_x, 0.8)
	for pulse in range(6):
		if not _boss_skill_valid(serial):
			tween.kill()
			return
		await _pulse_attack(&"hit2", 0.055)
		if pulse < 5:
			await get_tree().create_timer(0.079, false).timeout


func _boss_skill_valid(serial: int) -> bool:
	return is_instance_valid(self) and serial == _attack_serial and not death() and _skill_busy


func _pulse_attack(attack_name: StringName, duration: float) -> void:
	_enable_attack_box(attack_name)
	await get_tree().create_timer(duration, false).timeout
	if is_instance_valid(self):
		_disable_attack_box()
		await get_tree().physics_frame


func _finish_attack() -> void:
	_disable_attack_box()
	is_attacking = false
	_skill_busy = false
	super_armor_active = false
	cannot_attract = false
	_next_attack_msec = Time.get_ticks_msec() + int(_runtime_config["cooldown"])
	stop_move()


func _enable_attack_box(attack_name: StringName) -> void:
	hit_name = str(attack_name)
	if monster_kind == 3006:
		_configure_boss_attack_box(attack_name)
	hit_box.disabled = false


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.disabled = true


func _configure_boss_attack_box(attack_name: StringName) -> void:
	var shape := RectangleShape2D.new()
	match attack_name:
		&"hit1":
			hit_box.position = Vector2(-105.0, -78.0)
			shape.size = Vector2(310.0, 175.0)
		&"hit2":
			hit_box.position = Vector2(-25.0, -70.0)
			shape.size = Vector2(240.0, 145.0)
		_:
			hit_box.position = Vector2(0.0, -160.0)
			shape.size = Vector2(2200.0, 620.0)
	hit_box.shape = shape


func _fire_arrow() -> void:
	if death():
		return
	var offset := Vector2(56.0 if monster_direction else -56.0, -32.0)
	Global.add_bullet(
		"ZhuqueTigerArrow", bullet, monster_direction, 1.0, position + offset, "arrow", obj_attack_dict["arrow"]
	)


func is_control_immune() -> bool:
	return (monster_kind == 3006 and _skill_busy) or super.is_control_immune()


func state_death() -> void:
	if _death_sequence_started:
		return
	_death_sequence_started = true
	_attack_serial += 1
	_cancel_hurt_reaction()
	_disable_death_collisions()
	is_be_attacking = false
	is_attacking = false
	_skill_busy = false
	super_armor_active = false
	cannot_attract = false
	no_grav = true
	velocity = Vector2.ZERO
	super.state_death()
	_ensure_death_cleanup()


func state_hurt() -> void:
	if death() or _death_sequence_started:
		return
	if _skill_busy and monster_kind != 3006:
		_attack_serial += 1
		_skill_busy = false
		is_attacking = false
		_disable_attack_box()
	super.state_hurt()


func _clear_body_stream() -> void:
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.clear_texture()
		_body_stream.queue_free()
	_body_stream = null


func _exit_tree() -> void:
	_clear_body_stream()


func _ensure_death_cleanup() -> void:
	var corpse_lifetime := BOSS_CORPSE_LIFETIME if is_boss else SMALL_CORPSE_LIFETIME
	await get_tree().create_timer(corpse_lifetime, false).timeout
	if is_instance_valid(self) and not is_queued_for_deletion():
		settle_death_drops_and_free()


func _disable_death_collisions() -> void:
	_disable_attack_box()
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)


func little_blood_bar_control() -> void:
	super.little_blood_bar_control()
	if monster_blood_bar != null:
		monster_blood_bar.position = Vector2(-30.0, -190.0 if is_boss else -140.0)


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_frames_cache.clear()

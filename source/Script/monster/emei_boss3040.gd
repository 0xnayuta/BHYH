extends BaseMonster
class_name EmeiBoss3040

const PROJECTILE_SCRIPT := preload("res://Script/monster/nanhai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3040"
const ATLAS_METADATA := ROOT + "/atlas/metadata.tres"
const SOURCE_FPS := 30.0
const AI_DELAY_MSEC := 1000

const SKILL1_DASH_FRAME := 32
const SKILL1_DASH_DURATION := 0.4
const SKILL1_DASH_SPEED := 300.0
const SKILL1_BOX_SIZE := Vector2(180.0, 150.0)
const SKILL1_BOX_POSITION := Vector2(-110.0, -75.0)

const SKILL2_TRIGGER_FRAME := 25
const SKILL2_LEAP_DURATION := 0.667
const SKILL2_LEAP_VERTICAL_SPEED := -540.0
const SKILL2_LEAP_GRAVITY := 980.0
const SKILL2_FIELD_DURATION := 30.0
const SKILL2_HIT_INTERVAL := 0.5

const SKILL3_DASH_DURATION := 1.9
const SKILL3_DASH_SPEED := 75.0
const SKILL3_HIT_COUNT := 4
const SKILL3_HIT_INTERVAL := 0.467
const SKILL3_BOX_SIZE := Vector2(225.0, 150.0)
const SKILL3_BOX_POSITION := Vector2(-112.5, -75.0)

const ACTIONS := {
	&"wait": {"folder": "wait", "frames": 20, "offset": Vector2(-16.45, -65.05), "loop": true},
	&"walk": {"folder": "walk", "frames": 24, "offset": Vector2(-13.2, -68.7), "loop": true},
	&"hurt": {"folder": "hurt", "frames": 45, "offset": Vector2(-34.35, -69.4), "loop": false},
	&"death": {"folder": "death", "frames": 45, "offset": Vector2(-30.85, -26.5), "loop": false},
	&"skill1": {"folder": "effect1", "frames": 48, "offset": Vector2(8.05, -70.5), "loop": false},
	&"skill2": {"folder": "effect2", "frames": 63, "offset": Vector2(118.5, -54.0), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 58, "offset": Vector2(84.05, -68.75), "loop": false},
}

const EFFECTS := {
	&"effect2_1": {"frames": 22, "offset": Vector2(-35.0, -121.05)},
	&"effect2_2": {"frames": 14, "offset": Vector2(-2.85, -94.85)},
}

var monster_kind := 3040
static var _frames_cache: SpriteFrames

var _runtime_config: Dictionary = {}
var _busy := false
var _death_started := false
var _attack_serial := 0
var _skill_cycle := 0
var _next_attack_msec := 0
var _skill_direction := 1.0

var _skill1_dash_active := false
var _skill1_dash_time_left := 0.0
var _skill3_dash_active := false
var _skill3_dash_time_left := 0.0
var _skill2_leap: NanhaiProjectile
var _skill2_field_spawned := false


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_boss(_runtime_config)
	_build_animations()
	super._ready()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if level_config is Dictionary and not level_config.is_empty():
			return (level_config as Dictionary).duplicate(true)
	push_error("EmeiBoss3040 requires level monster config for 3040")
	return {}


func _configure_boss(config: Dictionary = {}) -> void:
	if config.is_empty():
		config = _runtime_config
	if config.is_empty():
		return
	my_mr_name = str(config.get("name", "赤炎金刚"))
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
	var frames_path := ROOT.path_join("atlas/swf_png_3040_frames.tres")
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
				_add_method_key(animation, _frame_time(SKILL1_DASH_FRAME), &"_start_skill1_dash")
			&"skill2":
				_add_method_key(animation, 0.0, &"_start_skill2_leap")
				_add_method_key(animation, _frame_time(SKILL2_TRIGGER_FRAME), &"_spawn_skill2_field")
			&"skill3":
				_add_method_key(animation, 0.0, &"_start_skill3_combo")
			&"death":
				_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_body_action", [action_name])
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


func _play_body_action(action_name: StringName) -> void:
	var info: Dictionary = ACTIONS.get(action_name, ACTIONS[&"wait"])
	if mr_ani.sprite_frames != null:
		mr_ani.visible = true
		mr_ani.position = info["offset"]
		mr_ani.play(action_name)


func ai_think() -> void:
	if _busy or death() or RoleProp.get_nearest_monster_target_position(global_position).x == null:
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
	for step in range(3):
		var candidate := ((_skill_cycle + step) % 3) + 1
		match candidate:
			1:
				if distance >= 20.0 and distance <= 200.0:
					return candidate
			2:
				if distance >= 100.0 and distance <= 600.0:
					return candidate
			3:
				if distance <= 225.0:
					return candidate
	return 0


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_skill_cycle = skill_index % 3
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
	if _skill1_dash_active:
		_finish_skill1_dash()
	if _skill3_dash_active:
		_finish_skill3_dash()
	_disable_attack_box()
	_busy = false
	is_attacking = false
	velocity.x = 0.0
	_next_attack_msec = Time.get_ticks_msec() + AI_DELAY_MSEC
	mr_player.play(&"wait")


func _start_skill1_dash() -> void:
	if death() or not _busy:
		return
	_set_attack_box(SKILL1_BOX_SIZE, SKILL1_BOX_POSITION)
	hit_name = "hit1"
	_skill1_dash_active = true
	_skill1_dash_time_left = SKILL1_DASH_DURATION
	velocity.x = SKILL1_DASH_SPEED * _skill_direction
	_enable_attack_box()


func _finish_skill1_dash() -> void:
	_skill1_dash_active = false
	_skill1_dash_time_left = 0.0
	velocity.x = 0.0
	_disable_attack_box()


func _start_skill2_leap() -> void:
	if death() or not _busy:
		return
	_skill2_field_spawned = false
	if _skill2_leap != null and is_instance_valid(_skill2_leap):
		_skill2_leap.queue_free()
	var target_x := global_position.x + 300.0 * _skill_direction
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	_skill2_leap = _spawn_projectile(
		{
			"position": global_position,
			"right": _skill_direction > 0.0,
			"hit_name": "hit2",
			"attack_data": _attack_entry(&"hit2"),
			"skill_name": "Emei3040ThousandJinLeap",
			"frame_root": ROOT.path_join("effect2_1"),
			"frame_count": int(EFFECTS[&"effect2_1"]["frames"]),
			"loop_visual": false,
			"visual_offset": EFFECTS[&"effect2_1"]["offset"],
			"velocity": Vector2((target_x - global_position.x) / SKILL2_LEAP_DURATION, SKILL2_LEAP_VERTICAL_SPEED),
			"acceleration": Vector2(0.0, SKILL2_LEAP_GRAVITY),
			"collision_size": Vector2(140.0, 160.0),
			"collision_offset": Vector2(0.0, -80.0),
			"lifetime": SKILL2_LEAP_DURATION,
			"damage_duration": SKILL2_LEAP_DURATION,
			"hit_interval": SKILL2_HIT_INTERVAL,
			"max_hits": 999,
			"expire_on_hit": false,
			"finished_callback": Callable(self, "_finish_skill2_leap"),
		}
	)


func _finish_skill2_leap(end_position: Vector2) -> void:
	if death():
		return
	global_position.x = end_position.x
	_skill2_leap = null


func _spawn_skill2_field() -> void:
	if death() or not _busy or _skill2_field_spawned:
		return
	_skill2_field_spawned = true
	_spawn_projectile(
		{
			"position": global_position,
			"right": _skill_direction > 0.0,
			"hit_name": "hit2",
			"attack_data": _attack_entry(&"hit2"),
			"skill_name": "Emei3040MountainFlame",
			"frame_root": ROOT.path_join("effect2_2"),
			"frame_count": int(EFFECTS[&"effect2_2"]["frames"]),
			"loop_visual": true,
			"visual_offset": EFFECTS[&"effect2_2"]["offset"],
			"collision_size": Vector2(150.0, 190.0),
			"collision_offset": Vector2(0.0, -90.0),
			"lifetime": SKILL2_FIELD_DURATION,
			"damage_duration": SKILL2_FIELD_DURATION,
			"hit_interval": SKILL2_HIT_INTERVAL,
			"max_hits": 999,
			"expire_on_hit": false,
		}
	)


func _start_skill3_combo() -> void:
	if death() or not _busy:
		return
	_set_attack_box(SKILL3_BOX_SIZE, SKILL3_BOX_POSITION)
	hit_name = "hit3"
	_skill3_dash_active = true
	_skill3_dash_time_left = SKILL3_DASH_DURATION
	velocity.x = SKILL3_DASH_SPEED * _skill_direction
	_run_skill3_pulses(_attack_serial)


func _run_skill3_pulses(serial: int) -> void:
	var next_pulse_msec := Time.get_ticks_msec()
	for pulse_index in range(SKILL3_HIT_COUNT):
		if death() or serial != _attack_serial or not _skill3_dash_active:
			return
		_enable_attack_box()
		await get_tree().physics_frame
		await get_tree().physics_frame
		if not is_instance_valid(self) or serial != _attack_serial:
			return
		_disable_attack_box()
		if pulse_index + 1 < SKILL3_HIT_COUNT:
			next_pulse_msec += roundi(SKILL3_HIT_INTERVAL * 1000.0)
			var delay := maxf(float(next_pulse_msec - Time.get_ticks_msec()) / 1000.0, 0.0)
			if delay > 0.0:
				await get_tree().create_timer(delay).timeout


func _finish_skill3_dash() -> void:
	_skill3_dash_active = false
	_skill3_dash_time_left = 0.0
	velocity.x = 0.0
	_disable_attack_box()


func _spawn_projectile(config: Dictionary) -> NanhaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as NanhaiProjectile
	config["owner"] = self
	config["atlas_metadata"] = ATLAS_METADATA
	config["atlas_sequence"] = str(config.get("frame_root", "")).get_file()
	if not str(config.get("impact_frame_root", "")).is_empty():
		config["impact_atlas_sequence"] = str(config["impact_frame_root"]).get_file()
	config["damage_enabled"] = not (config["attack_data"] as Dictionary).is_empty()
	projectile.configure(config)
	bullet.add_child(projectile)
	return projectile


func _attack_entry(attack_name: StringName) -> Dictionary:
	var attack_key := str(attack_name)
	if obj_attack_dict.has(attack_key):
		return (obj_attack_dict[attack_key] as Dictionary).duplicate(true)
	push_error("EmeiBoss3040 level config is missing attack %s" % attack_name)
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


func _physics_process(delta: float) -> void:
	if _skill1_dash_active and not death():
		velocity.x = SKILL1_DASH_SPEED * _skill_direction
	elif _skill3_dash_active and not death():
		velocity.x = SKILL3_DASH_SPEED * _skill_direction
	super._physics_process(delta)
	if _skill2_leap != null and is_instance_valid(_skill2_leap) and not death():
		global_position.x = _skill2_leap.global_position.x
	if _skill1_dash_active:
		_skill1_dash_time_left -= delta
		if death() or _skill1_dash_time_left <= 0.0:
			_finish_skill1_dash()
	if _skill3_dash_active:
		_skill3_dash_time_left -= delta
		if death() or _skill3_dash_time_left <= 0.0:
			_finish_skill3_dash()


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
	_death_started = true
	_attack_serial += 1
	_busy = true
	_finish_skill1_dash()
	_finish_skill3_dash()
	if _skill2_leap != null and is_instance_valid(_skill2_leap):
		_skill2_leap.queue_free()
	_skill2_leap = null
	_disable_attack_box()
	no_grav = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()

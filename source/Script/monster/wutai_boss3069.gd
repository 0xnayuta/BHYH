extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3069"
const ATLAS_METADATA := ROOT + "/atlas/metadata.tres"
const SOURCE_FPS := 30.0
const SMALL_HURT_DURATION := 0.28
const AI_DELAY_MSEC := 1000

const ACTIONS := {
	&"wait": {"folder": "wait", "frames": 20, "offset": Vector2(-33.45, -67.7), "loop": true},
	&"walk": {"folder": "walk", "frames": 20, "offset": Vector2(-47.0, -67.05), "loop": true},
	&"hurt": {"folder": "hurt", "frames": 35, "offset": Vector2(-54.5, -65.6), "loop": false},
	&"death": {"folder": "death", "frames": 35, "offset": Vector2(-82.55, -52.6), "loop": false},
	&"skill1": {"folder": "effect1", "frames": 46, "offset": Vector2(-46.0, -80.05), "loop": false},
	&"skill2": {"folder": "effect2", "frames": 41, "offset": Vector2(-24.75, -146.05), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 46, "offset": Vector2(-45.1, -94.05), "loop": false},
}

const FEATHER_DATA := [
	{"position": Vector2(73.0, -210.0), "speed_y": -10.0},
	{"position": Vector2(-4.0, -74.0), "speed_y": 40.0},
	{"position": Vector2(71.0, -193.0), "speed_y": 10.0},
	{"position": Vector2(43.0, -106.0), "speed_y": 30.0},
	{"position": Vector2(85.0, -160.0), "speed_y": 20.0},
]

@export var monster_kind := 3069

static var _frames_cache: SpriteFrames

var _runtime_config: Dictionary = {}
var _busy := false
var _death_started := false
var _attack_serial := 0
var _skill_cycle := 0
var _next_attack_msec := 0
var _skill_direction := 1.0
var _dash_active := false
var _dash_time_left := 0.0


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
	push_error("WutaiBoss3069 requires level monster config for 3069")
	return {}


func _configure_boss(config: Dictionary = {}) -> void:
	if config.is_empty():
		config = _runtime_config
	if config.is_empty():
		return
	my_mr_name = str(config.get("name", "金光孔雀"))
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
	var frames_path := ROOT.path_join("atlas/swf_png_3069_frames.tres")
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
				_add_method_key(animation, _frame_time(17), &"_start_golden_dash")
			&"skill2":
				_add_method_key(animation, _frame_time(21), &"_start_feather_fan")
			&"skill3":
				_add_method_key(animation, _frame_time(38), &"_trigger_screen_hit")
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


func _frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


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
		_busy
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
	var skill_count := 3 if max_hp > 0 and hp <= max_hp * 0.5 else 2
	for step in range(skill_count):
		var candidate := ((_skill_cycle + step) % skill_count) + 1
		if candidate == 1 and distance <= 720.0:
			return candidate
		if candidate == 2 and distance <= 450.0:
			return candidate
		if candidate == 3:
			return candidate
	return 0


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_skill_cycle = skill_index % (3 if max_hp > 0 and hp <= max_hp * 0.5 else 2)
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
	_finish_golden_dash()
	_disable_attack_box()
	_busy = false
	is_attacking = false
	velocity.x = 0.0
	_next_attack_msec = Time.get_ticks_msec() + AI_DELAY_MSEC
	mr_player.play(&"wait")


func _start_golden_dash() -> void:
	if death() or not _busy:
		return
	_set_attack_box(Vector2(220.0, 150.0), Vector2(-110.0, -75.0))
	_dash_active = true
	_dash_time_left = 1.0
	velocity.x = 240.0 * _skill_direction
	_run_attack_pulses(_attack_serial, 5, 0.2)


func _finish_golden_dash() -> void:
	_dash_active = false
	_dash_time_left = 0.0
	velocity.x = 0.0
	_disable_attack_box()


func _start_feather_fan() -> void:
	_spawn_feather_sequence(_attack_serial)


func _spawn_feather_sequence(serial: int) -> void:
	for feather_index in range(FEATHER_DATA.size()):
		if death() or serial != _attack_serial:
			return
		var data: Dictionary = FEATHER_DATA[feather_index]
		_spawn_feather(data)
		if feather_index + 1 < FEATHER_DATA.size():
			await get_tree().create_timer(0.066, false).timeout


func _spawn_feather(data: Dictionary) -> void:
	var source_offset: Vector2 = data["position"]
	var spawn_position := global_position + Vector2(source_offset.x * _skill_direction, source_offset.y)
	_spawn_projectile(
		{
			"position": spawn_position,
			"right": _skill_direction > 0.0,
			"hit_name": "hit2",
			"attack_data": _attack_entry(&"hit2"),
			"skill_name": "WutaiPeacockFeather",
			"frame_root": ROOT.path_join("effect2_1"),
			"frame_count": 10,
			"loop_visual": true,
			"velocity": Vector2(100.0 * _skill_direction, float(data["speed_y"])),
			"collision_size": Vector2(52.0, 42.0),
			"lifetime": 1.0,
			"damage_duration": 1.0,
			"expire_on_hit": false,
		}
	)


func _trigger_screen_hit() -> void:
	if (
		death()
		or not _busy
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
		or RoleProp.get_nearest_monster_target_position(global_position).y == null
	):
		return
	_spawn_projectile(
		{
			"position":
			Vector2(
				float(RoleProp.get_nearest_monster_target_position(global_position).x),
				float(RoleProp.get_nearest_monster_target_position(global_position).y) - 55.0
			),
			"right": true,
			"hit_name": "hit3",
			"attack_data": _attack_entry(&"hit3"),
			"skill_name": "WutaiPeacockScreenHit",
			"frame_count": 0,
			"collision_size": Vector2(180.0, 220.0),
			"lifetime": 0.1,
			"damage_duration": 0.1,
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


func _spawn_projectile(config: Dictionary) -> WutaiMinghaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
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
	var key := str(attack_name)
	if obj_attack_dict.has(key):
		return (obj_attack_dict[key] as Dictionary).duplicate(true)
	push_error("WutaiBoss3069 level config is missing attack %s" % attack_name)
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
	if _dash_active and not death():
		velocity.x = 240.0 * _skill_direction
	super._physics_process(delta)
	if _dash_active:
		_dash_time_left -= delta
		if death() or _dash_time_left <= 0.0:
			_finish_golden_dash()


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
	_finish_golden_dash()
	_disable_attack_box()
	no_grav = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()


func get_ice_effect_offset() -> Vector2:
	return Vector2(0.0, 10.0)

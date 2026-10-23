extends BaseMonster
class_name EmeiMountainMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/nanhai_projectile.gd")
const SOURCE_FPS := 30.0
const ROOT := "res://Art/monster/swf_png"
const SMALL_HURT_DURATION := 0.28
const DEFAULT_AI_DELAY_MSEC := 1000
const MONKEY_SHOT_DURATION := 1.167
const SCORPION_BURROW_SPEED := 240.0

const MODEL_BY_ENTITY := {
	3036: 3036,
	3037: 3037,
	3038: 3038,
	3039: 3039,
	3047: 3047,
	3053: 3047,
	3054: 3038,
	3055: 3036,
	3064: 3039,
}
const ENTITY_HURT_BOXES := {
	3053: [Vector2(2.0, -50.0), Vector2(90.0, 100.0)],
	3054: [Vector2(-1.5, -46.0), Vector2(55.0, 92.0)],
	3055: [Vector2(-4.75, -18.5), Vector2(84.5, 37.0)],
	3064: [Vector2(0.0, -67.5), Vector2(105.0, 135.0)],
}

const MODEL_ACTIONS := {
	3036:
	{
		&"wait": ["wait", 18, true],
		&"walk": ["walk", 18, true],
		&"hurt": ["hurt", 18, false],
		&"death": ["death", 39, false],
		&"hit1": ["attack1", 22, false]
	},
	3037:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 16, true],
		&"hurt": ["hurt", 34, false],
		&"death": ["death", 47, false],
		&"hit1": ["attack1", 80, false],
		&"emerge": ["attack1_2", 15, false]
	},
	3038:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 16, true],
		&"hurt": ["hurt", 41, false],
		&"death": ["death", 44, false],
		&"hit1": ["attack1", 28, false]
	},
	3039:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 16, true],
		&"hurt": ["hurt", 41, false],
		&"death": ["death", 41, false],
		&"hit1": ["attack1", 29, false]
	},
	3047:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 24, true],
		&"hurt": ["hurt", 45, false],
		&"death": ["death", 45, false],
		&"hit1": ["attack1", 24, false]
	},
}

const VISUAL_OFFSETS := {
	3036:
	{
		&"wait": Vector2(-2.15, -22.5),
		&"walk": Vector2(-2.15, -22.5),
		&"hurt": Vector2(-0.9, -2.95),
		&"death": Vector2(-0.6, -1.95),
		&"hit1": Vector2(77.55, 21.15)
	},
	3037:
	{
		&"wait": Vector2(-9.95, -35.85),
		&"walk": Vector2(-7.8, -35.3),
		&"hurt": Vector2(-27.5, -33.2),
		&"death": Vector2(-4.65, -20.95),
		&"hit1": Vector2(-19.3, -41.0),
		&"emerge": Vector2(6.45, -27.25)
	},
	3038:
	{
		&"wait": Vector2(-9.95, -43.15),
		&"walk": Vector2(-9.85, -43.75),
		&"hurt": Vector2(-22.7, -45.8),
		&"death": Vector2(-20.9, -20.4),
		&"hit1": Vector2(23.55, -70.85)
	},
	3039:
	{
		&"wait": Vector2(3.3, -54.9),
		&"walk": Vector2(6.85, -54.5),
		&"hurt": Vector2(-19.4, -59.9),
		&"death": Vector2(-31.25, -34.4),
		&"hit1": Vector2(49.35, -66.45)
	},
	3047:
	{
		&"wait": Vector2(-2.9, -47.7),
		&"walk": Vector2(5.35, -46.85),
		&"hurt": Vector2(-36.6, -50.9),
		&"death": Vector2(-35.7, -27.6),
		&"hit1": Vector2(46.35, -89.15)
	},
}

const PROJECTILE_OFFSETS := {
	3037: Vector2(2.0, -7.5),
	3038: Vector2(0.5, 0.5),
}

@export_enum(
	"火焰鸟:3036", "蝎子精:3037", "忍猴:3038", "百足蜈蚣:3039", "岩石怪:3047", "岩石怪变体:3053", "忍猴变体:3054", "火焰鸟变体:3055", "百足蜈蚣变体:3064"
)
var monster_kind := 3036

static var _frames_cache: Dictionary = {}

var _runtime_config: Dictionary = {}
var _busy := false
var _death_started := false
var _attack_serial := 0
var _next_attack_msec := 0
var _scorpion_burrow: NanhaiProjectile


func _ready() -> void:
	if not MODEL_BY_ENTITY.has(monster_kind):
		push_error("EmeiMountainMonster does not support entity %s" % monster_kind)
		monster_kind = 3036
	_runtime_config = _resolve_runtime_config()
	_configure_monster()
	_build_animations()
	super._ready()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("EmeiMountainMonster requires level monster config for %s" % monster_kind)
	return {}


func _configure_monster() -> void:
	if _runtime_config.is_empty():
		return
	var config := _runtime_config

	my_mr_name = str(config.get("name", "怪物%d" % monster_kind))
	level = int(config.get("level", 1))
	attack_in = int(config.get("attack", 1))
	max_hp = int(config.get("hp", 1))
	hp = max_hp
	def = int(config.get("def", 0))
	mdef = int(config.get("mdef", 0))
	crit = int(config.get("crit", 0))
	miss = int(config.get("miss", 0))
	htarget = int(config.get("hit", 0))
	toughness = float(config.get("toughness", 0.0))
	crit_reduce = int(config.get("crit_reduce", 0))
	ar = int(config.get("armor_break", 0))
	sp = int(config.get("magic_break", 0))
	speed = float(config.get("speed", 0.0))
	attack_range = roundi(float(config.get("range", 0.0)))
	mysee = roundi(float(config.get("sight", 0.0)))
	attack_desire = int(config.get("attack_desire", 0))
	add_exp = int(config.get("exp", 0))
	fall_coin = int(config.get("coin", 0))
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config.get("is_boss", false))
	boss_max_protect = float(config.get("max_protect", 100.0))
	is_fly = _model_id() == 3036
	no_grav = is_fly
	obj_attack_dict.clear()
	var attacks_value: Variant = config.get("attacks", {})
	var attacks: Dictionary = attacks_value if attacks_value is Dictionary else {}
	for attack_name: String in attacks:
		var attack_value: Variant = attacks.get(attack_name, {})
		if not attack_value is Dictionary:
			continue
		var attack: Dictionary = attack_value
		obj_attack_dict[attack_name] = {
			"power": roundi(float(attack_in) * float(attack.get("multiplier", 0.0))),
			"hurtBack": Array(attack.get("hurt_back", [0, 0])).duplicate(),
			"attackKind": str(attack.get("kind", "physics")),
			"HitProtect": int(attack.get("protect", 0)),
		}
	_configure_attack_box()
	_configure_entity_hurt_box()


func _configure_attack_box() -> void:
	if hit_box == null:
		return
	var shape := RectangleShape2D.new()
	match _model_id():
		3036:
			shape.size = Vector2(193.0, 135.0)
			hit_box.position = Vector2(-76.5, 23.5)
		3039:
			shape.size = Vector2(105.0, 120.0)
			hit_box.position = Vector2(-52.5, -60.0)
		3047:
			shape.size = Vector2(175.0, 125.0)
			hit_box.position = Vector2(-107.5, -62.5)
		_:
			shape.size = Vector2(1.0, 1.0)
			hit_box.position = Vector2.ZERO
	hit_box.shape = shape
	hit_box.disabled = true


func _configure_entity_hurt_box() -> void:
	if hurt_box == null or not ENTITY_HURT_BOXES.has(monster_kind):
		return
	var config: Array = ENTITY_HURT_BOXES[monster_kind]
	var shape := RectangleShape2D.new()
	hurt_box.position = config[0]
	shape.size = config[1]
	hurt_box.shape = shape


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


static func prewarm_frames(entity_ids: Array) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var warmed_models: Dictionary = {}
	for entity_value in entity_ids:
		var entity_id := int(entity_value)
		if not MODEL_BY_ENTITY.has(entity_id):
			continue
		var model := int(MODEL_BY_ENTITY[entity_id])
		if warmed_models.has(model):
			continue
		warmed_models[model] = true
		_get_frames_for_model(model)
		if tree != null:
			await tree.process_frame


func _build_animations() -> void:
	mr_ani.sprite_frames = _get_frames_for_model(_model_id())
	mr_ani.centered = true
	mr_ani.flip_h = true
	mr_ani.position = _visual_offset(&"wait")
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	var actions: Dictionary = MODEL_ACTIONS[_model_id()]
	for action_name: StringName in actions:
		if action_name == &"emerge":
			continue
		var action_data: Array = actions[action_name]
		var animation := _make_animation(action_name, int(action_data[1]), bool(action_data[2]))
		match action_name:
			&"death":
				_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
			&"hit1":
				_configure_attack_timeline(animation)
		library.add_animation(action_name, animation)
	if _model_id() == 3036:
		library.add_animation(&"Fly", _make_animation(&"walk", int(actions[&"walk"][1]), true))
		library.add_animation(&"Fly_wait", _make_animation(&"wait", int(actions[&"wait"][1]), true))
	mr_player.add_animation_library(&"", library)


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = SMALL_HURT_DURATION if action_name == &"hurt" else maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_frames", [action_name])
	return animation


func _configure_attack_timeline(animation: Animation) -> void:
	match _model_id():
		3036:
			_add_method_key(animation, _frame_time(12), &"_enable_attack_box")
			_add_method_key(animation, _frame_end_time(22), &"_disable_attack_box")
		3037:
			_add_method_key(animation, _frame_time(16), &"_start_scorpion_burrow")
		3038:
			_add_method_key(animation, _frame_time(16), &"_fire_monkey_shot")
		3039:
			_add_method_key(animation, _frame_time(12), &"_start_centipede_pulses")
		3047:
			_add_method_key(animation, _frame_time(13), &"_enable_attack_box")
			_add_method_key(animation, _frame_end_time(22), &"_disable_attack_box")


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


func _frame_end_time(frame_number: int) -> float:
	return float(frame_number) / SOURCE_FPS


func _play_frames(action_name: StringName) -> void:
	mr_ani.visible = true
	mr_ani.position = _visual_offset(action_name)
	var custom_speed := 1.0
	if action_name == &"hurt":
		custom_speed = float(MODEL_ACTIONS[_model_id()][&"hurt"][1]) / (SMALL_HURT_DURATION * SOURCE_FPS)
	mr_ani.play(action_name, custom_speed)


func _visual_offset(action_name: StringName) -> Vector2:
	var offsets: Dictionary = VISUAL_OFFSETS[_model_id()]
	var result: Vector2 = offsets.get(action_name, offsets[&"wait"])
	if mr_ani.flip_h:
		result.x = -result.x
	return result


func _model_id() -> int:
	return int(MODEL_BY_ENTITY[monster_kind])


static func _load_standard_frames(model: int, actions: Dictionary) -> SpriteFrames:
	var frames_path := ROOT.path_join(str(model)).path_join("atlas").path_join("swf_png_%d_frames.tres" % model)
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action_name: StringName in actions:
		var action_data: Array = actions[action_name]
		var sequence_name := StringName(str(action_data[0]))
		if not source.has_animation(sequence_name):
			return null
		frames.add_animation(action_name)
		frames.set_animation_speed(action_name, source.get_animation_speed(sequence_name))
		frames.set_animation_loop(action_name, bool(action_data[2]))
		for frame_index in range(source.get_frame_count(sequence_name)):
			frames.add_frame(action_name, source.get_frame_texture(sequence_name, frame_index))
	return frames


static func _get_frames_for_model(model: int) -> SpriteFrames:
	if _frames_cache.has(model):
		return _frames_cache[model] as SpriteFrames
	var actions: Dictionary = MODEL_ACTIONS[model]
	var standard := _load_standard_frames(model, actions)
	if standard != null:
		_frames_cache[model] = standard
		return standard
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action_name: StringName in actions:
		var action_data: Array = actions[action_name]
		frames.add_animation(action_name)
		frames.set_animation_loop(action_name, bool(action_data[2]))
		frames.set_animation_speed(action_name, SOURCE_FPS)
		var frame_root := ROOT.path_join(str(model)).path_join(str(action_data[0]))
		for frame_index in range(1, int(action_data[1]) + 1):
			var texture := Global.get_cached_texture(frame_root.path_join(str(frame_index) + ".png"))
			if texture != null:
				frames.add_frame(action_name, texture)
	_frames_cache[model] = frames
	return frames


func ai_think() -> void:
	if _busy or death() or RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	var target_x := float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var distance := absf(target_x - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	to_hero()
	var minimum_range := float(_runtime_config["min_range"])
	var maximum_range := float(_runtime_config["range"])
	if Time.get_ticks_msec() < _next_attack_msec:
		_move_for_range(distance, minimum_range, maximum_range)
		return
	if distance < minimum_range:
		_move_away_from_target(target_x)
	elif distance > maximum_range:
		have_target()
	elif (
		_model_id() == 3036
		and RoleProp.get_nearest_monster_target_position(global_position).y != null
		and absf(float(RoleProp.get_nearest_monster_target_position(global_position).y) - position.y) > 100.0
	):
		_move_flying_toward_target_y(float(RoleProp.get_nearest_monster_target_position(global_position).y))
	else:
		_start_attack()


func _move_for_range(distance: float, minimum_range: float, maximum_range: float) -> void:
	if distance < minimum_range and RoleProp.get_nearest_monster_target_position(global_position).x != null:
		_move_away_from_target(float(RoleProp.get_nearest_monster_target_position(global_position).x))
	elif distance > maximum_range:
		have_target()
	else:
		stop_move()


func _move_away_from_target(target_x: float) -> void:
	if target_x > position.x:
		move_left()
	else:
		move_right()


func _move_flying_toward_target_y(target_y: float) -> void:
	velocity.x = 0.0
	velocity.y = speed * 8.0 if target_y > position.y else -speed * 8.0
	mr_player.play(&"walk")


func _start_attack() -> void:
	if _busy or death():
		return
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	hit_name = "hit1"
	velocity = Vector2.ZERO
	_disable_attack_box()
	mr_player.play(&"hit1")
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_disable_attack_box()
	_busy = false
	is_attacking = false
	_next_attack_msec = Time.get_ticks_msec() + DEFAULT_AI_DELAY_MSEC
	stop_move()


func _enable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _start_centipede_pulses() -> void:
	_run_centipede_pulses(_attack_serial)


func _run_centipede_pulses(serial: int) -> void:
	var next_pulse_msec := Time.get_ticks_msec()
	for pulse_index in range(4):
		if death() or serial != _attack_serial:
			return
		_enable_attack_box()
		await get_tree().physics_frame
		await get_tree().physics_frame
		if not is_instance_valid(self) or death() or serial != _attack_serial:
			return
		_disable_attack_box()
		if pulse_index < 3:
			next_pulse_msec += 95
			var delay := maxf(float(next_pulse_msec - Time.get_ticks_msec()) / 1000.0, 0.0)
			if delay > 0.0:
				await get_tree().create_timer(delay, false).timeout


func _start_scorpion_burrow() -> void:
	if death() or _scorpion_burrow != null:
		return
	var facing := _facing_sign()
	var target_x := global_position.x + 150.0 * facing
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x) - 90.0 * facing
	var distance := absf(target_x - global_position.x)
	var duration := maxf(distance / SCORPION_BURROW_SPEED, 0.05)
	mr_ani.visible = false
	_scorpion_burrow = _spawn_projectile(
		{
			"position": global_position,
			"right": facing > 0.0,
			"hit_name": "hit1",
			"attack_data": _attack_entry(),
			"skill_name": "EmeiScorpionBurrow",
			"frame_root": ROOT.path_join("3037/arrow1"),
			"frame_count": 12,
			"visual_offset": PROJECTILE_OFFSETS[3037],
			"loop_visual": true,
			"velocity": Vector2((target_x - global_position.x) / duration, 0.0),
			"collision_size": Vector2(208.0, 68.0),
			"collision_offset": Vector2(2.0, -8.0),
			"lifetime": duration,
			"damage_duration": duration,
			"max_hits": 1,
			"expire_on_hit": false,
			"finished_callback": Callable(self, "_finish_scorpion_burrow"),
		}
	)


func _finish_scorpion_burrow(end_position: Vector2) -> void:
	_scorpion_burrow = null
	if death():
		return
	global_position = end_position
	mr_ani.visible = true
	mr_ani.position = _visual_offset(&"emerge")
	mr_ani.play(&"emerge")


func _cancel_scorpion_burrow() -> void:
	if _scorpion_burrow != null and is_instance_valid(_scorpion_burrow):
		_scorpion_burrow.queue_free()
	_scorpion_burrow = null
	mr_ani.visible = true


func _fire_monkey_shot() -> void:
	if death():
		return
	var facing := _facing_sign()
	var spawn_position := global_position + Vector2(68.0 * facing, -72.0)
	var target_position := spawn_position + Vector2(400.0 * facing, 0.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_position.x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	if RoleProp.get_nearest_monster_target_position(global_position).y != null:
		target_position.y = float(RoleProp.get_nearest_monster_target_position(global_position).y)
	_spawn_projectile(
		{
			"position": spawn_position,
			"right": facing > 0.0,
			"hit_name": "hit1",
			"attack_data": _attack_entry(),
			"skill_name": "EmeiMonkeyShot",
			"frame_root": ROOT.path_join("3038/arrow1"),
			"frame_count": 8,
			"visual_offset": PROJECTILE_OFFSETS[3038],
			"loop_visual": true,
			"velocity": (target_position - spawn_position) / MONKEY_SHOT_DURATION,
			"collision_size": Vector2(34.0, 34.0),
			"lifetime": MONKEY_SHOT_DURATION,
			"damage_duration": MONKEY_SHOT_DURATION,
			"hit_delay": 0.267,
		}
	)


func _spawn_projectile(config: Dictionary) -> NanhaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as NanhaiProjectile
	config["owner"] = self
	projectile.configure(config)
	bullet.add_child(projectile)
	return projectile


func _attack_entry() -> Dictionary:
	if obj_attack_dict.has("hit1"):
		return (obj_attack_dict["hit1"] as Dictionary).duplicate(true)
	return {}


func _facing_sign() -> float:
	return 1.0 if monster_dir.scale.x < 0.0 else -1.0


func _physics_process(delta: float) -> void:
	if _scorpion_burrow != null and is_instance_valid(_scorpion_burrow) and not death():
		global_position.x = _scorpion_burrow.global_position.x
	super._physics_process(delta)


func state_hurt() -> void:
	if death():
		return
	if _model_id() == 3037 and _scorpion_burrow != null:
		_attack_serial += 1
		_cancel_scorpion_burrow()
		_disable_attack_box()
		_busy = false
		is_attacking = false
		super.state_hurt()
		return
	if _busy:
		return
	super.state_hurt()


func _finish_hurt_reaction(hurt_generation: int) -> void:
	super._finish_hurt_reaction(hurt_generation)
	velocity.x = 0.0
	if is_fly:
		velocity.y = 0.0


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_attack_serial += 1
	_cancel_scorpion_burrow()
	_disable_attack_box()
	_busy = false
	is_attacking = false
	no_grav = false
	is_fly = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()


func get_ice_effect_offset() -> Vector2:
	match _model_id():
		3036:
			return Vector2(0.0, 5.0)
		3037:
			return Vector2(0.0, -4.0)
		3038:
			return Vector2(0.0, -5.0)
		3039:
			return Vector2(0.0, -7.0)
		3047:
			return Vector2(0.0, -6.0)
	return Vector2.ZERO

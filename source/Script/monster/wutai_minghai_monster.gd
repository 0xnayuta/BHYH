extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const SOURCE_FPS := 30.0
const ROOT := "res://Art/monster/swf_png"
const PROJECTILE_FRAMES := ROOT + "/3065/atlas/swf_png_3065_frames.tres"
const SMALL_HURT_DURATION := 0.28

const MODEL_BY_ENTITY := {
	3065: 3065,
	3066: 3066,
	3067: 3067,
	3068: 3068,
	3072: 3065,
	3073: 3067,
	3074: 3068,
	3075: 3066,
}

const MODEL_ACTIONS := {
	3065:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 18, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 33, false],
		&"hit1": ["attack1", 33, false]
	},
	3066:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 24, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 35, false],
		&"hit1": ["attack1", 36, false]
	},
	3067:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 16, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 35, false],
		&"hit1": ["attack1", 36, false]
	},
	3068:
	{
		&"wait": ["wait", 19, true],
		&"walk": ["walk", 18, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 35, false],
		&"hit1": ["attack1", 40, false]
	},
}

const VISUAL_OFFSETS := {
	3065:
	{
		&"walk": Vector2(2.1, -53.9),
		&"wait": Vector2(-3.1, -52.65),
		&"hurt": Vector2(-29.5, -38.2),
		&"death": Vector2(-34.95, -13.2),
		&"hit1": Vector2(-4.0, -49.95)
	},
	3066:
	{
		&"walk": Vector2(8.0, -23.45),
		&"wait": Vector2(4.7, -24.6),
		&"hurt": Vector2(-1.4, -23.4),
		&"death": Vector2(-2.4, -23.4),
		&"hit1": Vector2(55.35, -50.0)
	},
	3067:
	{
		&"walk": Vector2(-4.45, -54.35),
		&"wait": Vector2(-7.15, -55.15),
		&"hurt": Vector2(-21.6, -57.0),
		&"death": Vector2(-19.05, -21.25),
		&"hit1": Vector2(78.5, -53.4)
	},
	3068:
	{
		&"walk": Vector2(13.1, -33.35),
		&"wait": Vector2(12.2, -28.4),
		&"hurt": Vector2(-2.45, -25.9),
		&"death": Vector2(1.75, -25.55),
		&"hit1": Vector2(-8.0, -28.3)
	},
}

const PROJECTILE_OFFSETS := {
	3065: Vector2.ZERO,
}

const ENTITY_HURT_BOXES := {
	3072: [Vector2(-1.0, -50.0), Vector2(42.0, 105.0)],
	3073: [Vector2(-1.0, -53.0), Vector2(50.0, 110.0)],
	3074: [Vector2(-3.5, -30.0), Vector2(57.0, 65.0)],
	3075: [Vector2(0.0, -23.75), Vector2(90.0, 52.5)],
}

@export var monster_kind := 3065

static var _frames_cache: Dictionary = {}

var _runtime_config: Dictionary = {}
var _busy := false
var _death_started := false
var _attack_serial := 0
var _next_attack_msec := 0
var _charge_active := false
var _charge_time_left := 0.0
var _charge_direction := 1.0


func _ready() -> void:
	if not MODEL_BY_ENTITY.has(monster_kind):
		push_error("WutaiMinghaiMonster does not support entity %s" % monster_kind)
		return
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
	push_error("WutaiMinghaiMonster requires level monster config for %s" % monster_kind)
	return {}


func _configure_monster() -> void:
	if _runtime_config.is_empty():
		return
	var config := _runtime_config
	my_mr_name = str(config.get("name", "冥海怪物%d" % monster_kind))
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
	attack_range = roundi(float(config["range"]))
	mysee = roundi(float(config["sight"]))
	attack_desire = int(config["attack_desire"])
	add_exp = int(config["exp"])
	fall_coin = int(config["coin"])
	fall_pro = float(config["drop_rate"])
	fall_list = Array(config["drop_list"]).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	is_fly = _model_id() == 3065
	no_grav = is_fly
	obj_attack_dict.clear()
	var attacks: Dictionary = config["attacks"]
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		obj_attack_dict[attack_name] = {
			"power": roundi(float(attack_in) * float(attack["multiplier"])),
			"hurtBack": Array(attack["hurt_back"]).duplicate(),
			"attackKind": str(attack["kind"]),
			"HitProtect": int(attack["protect"]),
		}
	_configure_attack_box()
	_configure_entity_hurt_box()


func _configure_attack_box() -> void:
	if hit_box == null:
		return
	var shape := RectangleShape2D.new()
	match _model_id():
		3066:
			shape.size = Vector2(110.0, 82.0)
			hit_box.position = Vector2(-55.0, -41.0)
		3067:
			shape.size = Vector2(215.0, 105.0)
			hit_box.position = Vector2(-107.5, -52.5)
		3068:
			shape.size = Vector2(105.0, 75.0)
			hit_box.position = Vector2(-52.5, -37.5)
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
		var action_data: Array = actions[action_name]
		var animation := _make_animation(action_name, int(action_data[1]), bool(action_data[2]))
		if action_name == &"hit1":
			_configure_attack_timeline(animation)
		elif action_name == &"death":
			_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	if _model_id() == 3065:
		library.add_animation(&"Fly", _make_animation(&"walk", 18, true))
		library.add_animation(&"Fly_wait", _make_animation(&"wait", 20, true))
	mr_player.add_animation_library(&"", library)


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = SMALL_HURT_DURATION if action_name == &"hurt" else maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_frames", [action_name])
	return animation


func _configure_attack_timeline(animation: Animation) -> void:
	match _model_id():
		3065:
			_add_method_key(animation, _frame_time(16), &"_fire_harpy_volley")
		3066:
			_add_method_key(animation, 0.0, &"_start_attack_pulses", [2, 0.48])
		3067:
			_add_method_key(animation, _frame_time(19), &"_enable_attack_box")
			_add_method_key(animation, _frame_time(35), &"_disable_attack_box")
		3068:
			_add_method_key(animation, _frame_time(11), &"_start_walnut_charge")


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


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


static func _load_standard_frames(model: int) -> SpriteFrames:
	var frames_path := ROOT.path_join(str(model)).path_join("atlas").path_join("swf_png_%d_frames.tres" % model)
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames


static func _get_frames_for_model(model: int) -> SpriteFrames:
	if _frames_cache.has(model):
		return _frames_cache[model] as SpriteFrames
	var actions: Dictionary = MODEL_ACTIONS[model]
	var standard := _load_standard_frames(model)
	if standard != null:
		_frames_cache[model] = standard
		return standard
	return null


func ai_think() -> void:
	if (
		_busy
		or death()
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
		or _runtime_config.is_empty()
	):
		return
	var target_x := float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var distance := absf(target_x - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	to_hero()
	var minimum_range := float(_runtime_config.get("min_range", 0.0))
	var maximum_range := float(_runtime_config.get("range", attack_range))
	var vertical_range := float(_runtime_config.get("vertical_range", 100.0))
	if _model_id() == 3065 and RoleProp.get_nearest_monster_target_position(global_position).y != null:
		var target_y := float(RoleProp.get_nearest_monster_target_position(global_position).y)
		var vertical_distance := absf(target_y - position.y)
		if distance < minimum_range or distance > maximum_range or vertical_distance > vertical_range:
			_move_flying_for_attack_range(target_x, target_y, distance, minimum_range, maximum_range, vertical_range)
		elif Time.get_ticks_msec() < _next_attack_msec:
			stop_move()
		else:
			_start_attack()
		return
	if Time.get_ticks_msec() < _next_attack_msec:
		_move_for_range(distance, minimum_range, maximum_range, vertical_range)
		return
	if distance < minimum_range:
		_move_away_from_target(target_x)
	elif distance > maximum_range:
		have_target()
	elif (
		_model_id() == 3065
		and RoleProp.get_nearest_monster_target_position(global_position).y != null
		and absf(float(RoleProp.get_nearest_monster_target_position(global_position).y) - position.y) > vertical_range
	):
		_move_flying_toward_target_y(float(RoleProp.get_nearest_monster_target_position(global_position).y))
	else:
		_start_attack()


func _move_for_range(distance: float, minimum_range: float, maximum_range: float, vertical_range: float) -> void:
	if distance < minimum_range and RoleProp.get_nearest_monster_target_position(global_position).x != null:
		_move_away_from_target(float(RoleProp.get_nearest_monster_target_position(global_position).x))
	elif distance > maximum_range:
		have_target()
	elif (
		_model_id() == 3065
		and RoleProp.get_nearest_monster_target_position(global_position).y != null
		and absf(float(RoleProp.get_nearest_monster_target_position(global_position).y) - position.y) > vertical_range
	):
		_move_flying_toward_target_y(float(RoleProp.get_nearest_monster_target_position(global_position).y))
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


func _move_flying_for_attack_range(
	target_x: float,
	target_y: float,
	horizontal_distance: float,
	minimum_range: float,
	maximum_range: float,
	vertical_range: float
) -> void:
	var horizontal_velocity := 0.0
	if horizontal_distance < minimum_range:
		horizontal_velocity = -signf(target_x - position.x) * speed * 10.0
	elif horizontal_distance > maximum_range:
		horizontal_velocity = signf(target_x - position.x) * speed * 10.0
	var vertical_velocity := 0.0
	if absf(target_y - position.y) > vertical_range:
		vertical_velocity = signf(target_y - position.y) * speed * 8.0
	velocity = Vector2(horizontal_velocity, vertical_velocity)
	if horizontal_velocity > 0.0:
		base_damage_box.scale.x = -1.0
		monster_dir.scale.x = -1.0
	elif horizontal_velocity < 0.0:
		base_damage_box.scale.x = 1.0
		monster_dir.scale.x = 1.0
	mr_player.play(&"Fly")


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
	_finish_charge()
	_disable_attack_box()
	_busy = false
	is_attacking = false
	_next_attack_msec = Time.get_ticks_msec() + randi_range(1000, 3000)
	stop_move()


func _fire_harpy_volley() -> void:
	if death() or not _busy:
		return
	_spawn_harpy_projectile(Vector2(20.0, -37.0))
	_delayed_harpy_projectile(0.165, Vector2(3.0, 5.0), _attack_serial)
	_delayed_harpy_projectile(0.231, Vector2(40.0, -54.0), _attack_serial)


func _delayed_harpy_projectile(delay: float, source_offset: Vector2, serial: int) -> void:
	await get_tree().create_timer(delay, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_spawn_harpy_projectile(source_offset)


func _spawn_harpy_projectile(source_offset: Vector2) -> void:
	var facing := _facing_sign()
	var spawn_position := global_position + Vector2(source_offset.x * facing, source_offset.y)
	_spawn_projectile(
		{
			"position": spawn_position,
			"right": facing > 0.0,
			"hit_name": "hit1",
			"attack_data": _attack_entry(),
			"skill_name": "WutaiHarpyTripleShot",
			"frame_root": ROOT.path_join("3065/attack1_1"),
			"frame_count": 8,
			"loop_visual": true,
			"visual_offset": PROJECTILE_OFFSETS[3065],
			"visual_faces_right": facing > 0.0,
			"velocity": Vector2(120.0 * facing, 100.0),
			"orient_to_motion": true,
			"collision_size": Vector2(102.0, 31.0),
			"collision_offset": Vector2(-0.5, 0.0),
			"lifetime": 0.467,
			"damage_duration": 0.467,
		}
	)


func _start_attack_pulses(count: int, interval: float) -> void:
	_run_attack_pulses(_attack_serial, count, interval)


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


func _start_walnut_charge() -> void:
	if death() or not _busy:
		return
	_charge_direction = _facing_sign()
	_charge_active = true
	_charge_time_left = 1.0
	velocity.x = 120.0 * _charge_direction
	_start_attack_pulses(3, 0.333)


func _finish_charge() -> void:
	_charge_active = false
	_charge_time_left = 0.0
	velocity.x = 0.0
	_disable_attack_box()


func _spawn_projectile(config: Dictionary) -> WutaiMinghaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	config["owner"] = self
	config["visual_backend"] = WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES
	config["frames_resource"] = PROJECTILE_FRAMES
	config["frames_animation"] = str(config.get("frame_root", "")).get_file()
	config["frame_root"] = ""
	config["damage_enabled"] = not (config["attack_data"] as Dictionary).is_empty()
	if not projectile.configure(config):
		projectile.free()
		return null
	bullet.add_child(projectile)
	return projectile


func _attack_entry() -> Dictionary:
	if obj_attack_dict.has("hit1"):
		return (obj_attack_dict["hit1"] as Dictionary).duplicate(true)
	push_error("WutaiMinghaiMonster level config is missing attack hit1 for %s" % monster_kind)
	return {}


func _facing_sign() -> float:
	return 1.0 if monster_dir.scale.x < 0.0 else -1.0


func _enable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _physics_process(delta: float) -> void:
	if _charge_active and not death():
		velocity.x = 120.0 * _charge_direction
	super._physics_process(delta)
	if _charge_active:
		_charge_time_left -= delta
		if death() or _charge_time_left <= 0.0:
			_finish_charge()


func state_hurt() -> void:
	if death() or _busy:
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
	_busy = true
	_finish_charge()
	_disable_attack_box()
	no_grav = false
	is_fly = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()


func get_ice_effect_offset() -> Vector2:
	match _model_id():
		3065:
			return Vector2(0.0, 10.0)
		3066:
			return Vector2(0.0, 9.0)
		3067:
			return Vector2(0.0, 7.0)
		3068:
			return Vector2(0.0, 5.0)
	return Vector2.ZERO


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_frames_cache.clear()

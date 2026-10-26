extends BaseMonster
class_name NanhaiMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/nanhai_projectile.gd")
const SOURCE_FPS := 30.0
const ROOT := "res://Art/monster/swf_png"
const SMALL_HURT_DURATION := 0.28
const TIGER_SHARK_DASH_TIME := 0.667

const MODEL_FPS := {
	3028: 24.0,
	3030: 24.0,
	3031: 30.0,
	3032: 30.0,
	3049: 30.0,
}

const MODEL_BY_ENTITY := {
	3028: 3028,
	3030: 3030,
	3031: 3031,
	3032: 3032,
	3043: 3031,
	3044: 3030,
	3045: 3032,
	3046: 3028,
	3049: 3049,
}
const ENTITY_HURT_BOXES := {
	3043: [Vector2(-2.0, -48.15), Vector2(46.0, 113.0)],
	3044: [Vector2(2.2, -43.0), Vector2(68.4, 97.0)],
	3045: [Vector2(0.0, -48.4), Vector2(80.0, 114.0)],
	3046: [Vector2(-0.65, -24.85), Vector2(74.0, 61.0)],
}

const DATA := {
	3028:
	{
		"name": "贝壳",
		"model": 3028,
		"speed": 7.5,
		"min_range": 60.0,
		"range": 180.0,
		"multiplier": 0.33,
		"kind": "magic",
		"protect": 551,
		"hurt_back": [-3.0, -1.0]
	},
	3030:
	{
		"name": "蚌女",
		"model": 3030,
		"speed": 8.75,
		"min_range": 80.0,
		"range": 350.0,
		"multiplier": 1.0,
		"kind": "magic",
		"protect": 1112,
		"hurt_back": [-3.0, -1.0]
	},
	3031:
	{
		"name": "虾兵",
		"model": 3031,
		"speed": 11.25,
		"min_range": 90.0,
		"range": 420.0,
		"multiplier": 1.0,
		"kind": "physics",
		"protect": 3334,
		"hurt_back": [-3.0, -1.0]
	},
	3032:
	{
		"name": "夜叉",
		"model": 3032,
		"speed": 10.0,
		"min_range": 30.0,
		"range": 177.0,
		"multiplier": 1.0,
		"kind": "physics",
		"protect": 3334,
		"hurt_back": [-3.0, -1.0]
	},
	3043:
	{
		"name": "虾兵",
		"model": 3031,
		"speed": 11.25,
		"min_range": 90.0,
		"range": 420.0,
		"multiplier": 1.0,
		"kind": "physics",
		"protect": 3334,
		"hurt_back": [-3.0, -1.0]
	},
	3044:
	{
		"name": "蚌女",
		"model": 3030,
		"speed": 8.75,
		"min_range": 80.0,
		"range": 350.0,
		"multiplier": 1.0,
		"kind": "magic",
		"protect": 1112,
		"hurt_back": [-3.0, -1.0]
	},
	3045:
	{
		"name": "夜叉",
		"model": 3032,
		"speed": 10.0,
		"min_range": 30.0,
		"range": 177.0,
		"multiplier": 1.0,
		"kind": "physics",
		"protect": 3334,
		"hurt_back": [-3.0, -1.0]
	},
	3046:
	{
		"name": "贝壳",
		"model": 3028,
		"speed": 7.5,
		"min_range": 60.0,
		"range": 180.0,
		"multiplier": 0.33,
		"kind": "magic",
		"protect": 551,
		"hurt_back": [-3.0, -1.0]
	},
	3049:
	{
		"name": "虎鲨",
		"model": 3049,
		"speed": 20.0,
		"min_range": 0.0,
		"range": 480.0,
		"multiplier": 1.0,
		"kind": "physics",
		"protect": 3334,
		"hurt_back": [-3.0, -1.0]
	},
}

const MODEL_ACTIONS := {
	3028:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 18, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 35, false],
		&"hit1": ["attack1", 27, false]
	},
	3030:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 18, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 35, false],
		&"hit1": ["attack1", 37, false]
	},
	3031:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 18, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 35, false],
		&"hit1": ["attack1", 23, false]
	},
	3032:
	{
		&"wait": ["wait", 20, true],
		&"walk": ["walk", 18, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 34, false],
		&"hit1": ["attack1", 20, false]
	},
	3049:
	{
		&"wait": ["wait", 24, true],
		&"walk": ["walk", 24, true],
		&"hurt": ["hurt", 35, false],
		&"death": ["death", 35, false],
		&"hit1": ["attack1", 17, false]
	},
}

const VISUAL_OFFSETS := {
	3028:
	{
		&"wait": Vector2(-4.65, -30.85),
		&"walk": Vector2(-5.25, -36.25),
		&"hurt": Vector2(-13.0, -30.7),
		&"death": Vector2(-9.9, -26.85),
		&"hit1": Vector2(-4.1, -30.75)
	},
	3030:
	{
		&"wait": Vector2(-13.1, -44.5),
		&"walk": Vector2(-18.4, -47.25),
		&"hurt": Vector2(-18.75, -45.35),
		&"death": Vector2(-7.85, -38.8),
		&"hit1": Vector2(-24.35, -63.8)
	},
	3031:
	{
		&"wait": Vector2(-5.85, -51.15),
		&"walk": Vector2(11.85, -50.0),
		&"hurt": Vector2(-27.5, -47.1),
		&"death": Vector2(-24.3, -16.05),
		&"hit1": Vector2(-13.65, -48.3)
	},
	3032:
	{
		&"wait": Vector2(11.65, -50.4),
		&"walk": Vector2(21.0, -41.8),
		&"hurt": Vector2(-3.6, -51.65),
		&"death": Vector2(-1.55, -26.1),
		&"hit1": Vector2(62.55, -20.6)
	},
	3049:
	{
		&"wait": Vector2(30.15, -26.15),
		&"walk": Vector2(30.15, -26.15),
		&"hurt": Vector2(27.3, -38.2),
		&"death": Vector2(-29.1, -26.95),
		&"hit1": Vector2(25.45, -30.5)
	},
}

const PROJECTILE_OFFSETS := {
	3028: {"arrow1": Vector2(1.75, 0.7), "arrow2": Vector2(5.05, -2.25)},
	3030: {"arrow1": Vector2(-6.35, -0.1), "arrow2": Vector2(-0.5, -4.45)},
	3031: {"arrow1": Vector2(-12.3, 1.0)},
	3049: {"attack1_1": Vector2(25.45, -30.5)},
}

@export_enum("贝壳:3028", "蚌女:3030", "虾兵:3031", "夜叉:3032", "虾兵水中:3043", "蚌女变体:3044", "夜叉变体:3045", "贝壳变体:3046", "虎鲨:3049")
var monster_kind := 3028

signal tiger_shark_dash_completed

static var _frames_cache: Dictionary = {}

var _busy := false
var _next_attack_msec := 0
var _attack_serial := 0
var _death_started := false
var _dash_active := false
var _dash_projectile: NanhaiProjectile
var _runtime_config: Dictionary = {}


func _ready() -> void:
	if not DATA.has(monster_kind):
		push_error("NanhaiMonster does not support entity %s" % monster_kind)
		monster_kind = 3028
	_runtime_config = _resolve_runtime_config()
	_configure_monster()
	_build_animations()
	super._ready()


func _configure_monster() -> void:
	var config := _runtime_config
	if config.is_empty():
		return
	my_mr_name = str(config.get("name", "怪物%d" % monster_kind))
	level = int(config.get("level", 90))
	attack_in = int(config.get("attack", 20000))
	max_hp = int(config.get("hp", 4295000))
	hp = max_hp
	def = int(config.get("def", 1100))
	mdef = int(config.get("mdef", 1100))
	crit = int(config.get("crit", 300))
	miss = int(config.get("miss", 150))
	htarget = int(config.get("hit", 280))
	toughness = float(config.get("toughness", 0.0))
	crit_reduce = int(config.get("crit_reduce", 0))
	ar = int(config.get("armor_break", 900))
	sp = int(config.get("magic_break", 900))
	speed = float(config.get("speed", 0.0))
	attack_range = roundi(float(config.get("range", 0.0)))
	mysee = int(config.get("sight", 940))
	attack_desire = int(config.get("attack_desire", 100))
	add_exp = int(config.get("exp", 10))
	fall_coin = int(config.get("coin", 8))
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config.get("is_boss", false))
	boss_max_protect = float(config.get("max_protect", 100.0))
	var attack: Dictionary = (config.get("attacks", {}) as Dictionary).get("hit1", {})
	if attack.is_empty():
		attack = {
			"multiplier": config["multiplier"],
			"hurt_back": config["hurt_back"],
			"kind": config["kind"],
			"protect": config["protect"],
		}
	obj_attack_dict.clear()
	obj_attack_dict["hit1"] = {
		"power": int(float(attack_in) * float(attack["multiplier"])),
		"hurtBack": Array(attack["hurt_back"]).duplicate(),
		"attackKind": str(attack["kind"]),
		"HitProtect": int(attack["protect"]),
	}
	_configure_melee_box()
	_configure_entity_hurt_box()


func _resolve_runtime_config() -> Dictionary:
	var config: Dictionary = DATA[monster_kind].duplicate(true)
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if level_config is Dictionary:
			config.merge(level_config, true)
	return config


func _configure_melee_box() -> void:
	if hit_box == null:
		return
	var model := _model_id()
	if model != 3032:
		return
	var shape := RectangleShape2D.new()
	shape.size = Vector2(147.0, 80.0)
	hit_box.shape = shape
	hit_box.position = Vector2(-103.5, -40.0)


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
	var warmed_models := {}
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
		if action_name == &"death":
			_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		elif action_name == &"hit1":
			match _model_id():
				3028:
					_add_method_key(animation, _frame_time(9), &"_fire_shell_spread")
				3030:
					_add_method_key(animation, _frame_time(4), &"_fire_clam_shot")
				3031:
					_add_method_key(animation, _frame_time(9), &"_fire_shrimp_shot")
				3032:
					_add_attack_window(animation, 10, 19)
				3049:
					animation.length = maxf(animation.length, TIGER_SHARK_DASH_TIME)
					_add_method_key(animation, 0.0, &"_start_tiger_shark_dash")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	var model_fps := _model_fps(_model_id())
	animation.length = SMALL_HURT_DURATION if action_name == &"hurt" else maxf(float(frame_count) / model_fps, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_frames", [action_name])
	return animation


func _add_attack_window(animation: Animation, start_frame: int, end_frame: int) -> void:
	_add_method_key(animation, _frame_time(start_frame), &"_enable_attack_box")
	_add_method_key(animation, float(end_frame) / _model_fps(_model_id()), &"_disable_attack_box")


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / _model_fps(_model_id())


func _play_frames(action_name: StringName) -> void:
	mr_ani.visible = true
	mr_ani.position = _visual_offset(action_name)
	var custom_speed := 1.0
	if action_name == &"hurt":
		var frame_count := int(MODEL_ACTIONS[_model_id()][&"hurt"][1])
		custom_speed = float(frame_count) / (SMALL_HURT_DURATION * _model_fps(_model_id()))
	mr_ani.play(action_name, custom_speed)


func _visual_offset(action_name: StringName) -> Vector2:
	var offsets: Dictionary = VISUAL_OFFSETS[_model_id()]
	var result: Vector2 = offsets.get(action_name, offsets[&"wait"])
	if mr_ani.flip_h:
		result.x = -result.x
	return result


func _model_id() -> int:
	return int(MODEL_BY_ENTITY[monster_kind])


static func _model_fps(model: int) -> float:
	return float(MODEL_FPS.get(model, SOURCE_FPS))


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
	if _busy or death() or RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	var target_x := float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var distance := absf(target_x - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	to_hero()
	var config := _runtime_config
	var minimum_range := float(config["min_range"])
	var maximum_range := float(config["range"])
	if Time.get_ticks_msec() < _next_attack_msec:
		_move_for_range(distance, minimum_range, maximum_range)
		return
	if distance < minimum_range:
		_move_away_from_target(target_x)
	elif distance > maximum_range:
		have_target()
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


func _start_attack() -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	hit_name = "hit1"
	velocity.x = 0.0
	mr_player.play(&"hit1")
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	if _dash_active:
		await tiger_shark_dash_completed
		if not is_instance_valid(self) or death() or serial != _attack_serial:
			return
	_finish_attack()


func _finish_attack() -> void:
	_disable_attack_box()
	_busy = false
	is_attacking = false
	_next_attack_msec = Time.get_ticks_msec() + 1000
	stop_move()


func _enable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _fire_shell_spread() -> void:
	var facing := _facing_sign()
	var model := _model_id()
	for vertical_speed in [0.0, -120.0, -240.0]:
		_spawn_projectile(
			{
				"position": global_position + Vector2(56.0 * facing, -32.0),
				"right": facing > 0.0,
				"hit_name": "hit1",
				"attack_data": obj_attack_dict["hit1"],
				"skill_name": "NanhaiShellShot",
				"frame_root": _projectile_root(model, "arrow1"),
				"frame_count": 10,
				"visual_offset": PROJECTILE_OFFSETS[model]["arrow1"],
				"impact_frame_root": _projectile_root(model, "arrow2"),
				"impact_frame_count": 10,
				"impact_visual_offset": PROJECTILE_OFFSETS[model]["arrow2"],
				"velocity": Vector2(240.0 * facing, vertical_speed),
				"collision_size": Vector2(48.0, 38.0),
				"lifetime": 0.5,
				"damage_duration": 0.5,
			}
		)


func _fire_clam_shot() -> void:
	var facing := _facing_sign()
	var duration := 2.067
	var spawn_position := global_position + Vector2(47.0 * facing, -39.0)
	var target_position := spawn_position + Vector2(100.0 * facing, 0.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_position.x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	if RoleProp.get_nearest_monster_target_position(global_position).y != null:
		target_position.y = float(RoleProp.get_nearest_monster_target_position(global_position).y)
	var velocity := Vector2((target_position.x - spawn_position.x) / duration, -600.0)
	var acceleration_y := 2.0 * (target_position.y - spawn_position.y - velocity.y * duration) / (duration * duration)
	var model := _model_id()
	_spawn_projectile(
		{
			"position": spawn_position,
			"right": facing > 0.0,
			"hit_name": "hit1",
			"attack_data": obj_attack_dict["hit1"],
			"skill_name": "NanhaiClamShot",
			"frame_root": _projectile_root(model, "arrow1"),
			"frame_count": 8,
			"visual_offset": PROJECTILE_OFFSETS[model]["arrow1"],
			"impact_frame_root": _projectile_root(model, "arrow2"),
			"impact_frame_count": 10,
			"impact_visual_offset": PROJECTILE_OFFSETS[model]["arrow2"],
			"velocity": velocity,
			"acceleration": Vector2(0.0, acceleration_y),
			"orient_to_motion": true,
			"collision_size": Vector2(64.0, 46.0),
			"lifetime": duration,
			"damage_duration": duration,
		}
	)


func _fire_shrimp_shot() -> void:
	var facing := _facing_sign()
	var model := _model_id()
	_spawn_projectile(
		{
			"position": global_position + Vector2(43.0 * facing, -50.0),
			"right": facing > 0.0,
			"hit_name": "hit1",
			"attack_data": obj_attack_dict["hit1"],
			"skill_name": "NanhaiShrimpShot",
			"frame_root": _projectile_root(model, "arrow1"),
			"frame_count": 8,
			"visual_offset": PROJECTILE_OFFSETS[model]["arrow1"],
			"velocity": Vector2(150.0 * facing, 0.0),
			"collision_size": Vector2(110.0, 30.0),
			"lifetime": 3.334,
			"damage_duration": 3.334,
		}
	)


func _start_tiger_shark_dash() -> void:
	if _dash_active or death():
		return
	var facing := _facing_sign()
	var target_position := global_position + Vector2(480.0 * facing, 0.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_position.x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	if RoleProp.get_nearest_monster_target_position(global_position).y != null:
		target_position.y = float(RoleProp.get_nearest_monster_target_position(global_position).y) - 60.0
	var start_position := global_position
	var serial := _attack_serial
	_dash_active = true
	mr_ani.visible = false
	_disable_attack_box()
	_dash_projectile = _spawn_projectile(
		{
			"position": start_position,
			"right": facing > 0.0,
			"hit_name": "hit1",
			"attack_data": obj_attack_dict["hit1"],
			"skill_name": "NanhaiTigerSharkDash",
			"frame_root": _projectile_root(3049, "attack1_1"),
			"frame_count": 17,
			"visual_offset": PROJECTILE_OFFSETS[3049]["attack1_1"],
			"loop_visual": false,
			"velocity": (target_position - start_position) / TIGER_SHARK_DASH_TIME,
			"collision_size": Vector2(80.0, 100.0),
			"collision_offset": Vector2(0.0, -50.0),
			"lifetime": TIGER_SHARK_DASH_TIME,
			"damage_duration": TIGER_SHARK_DASH_TIME,
			"finished_callback": Callable(self, "_on_tiger_shark_dash_finished").bind(serial),
		}
	)


func _on_tiger_shark_dash_finished(end_position: Vector2, serial: int) -> void:
	if serial != _attack_serial or death():
		return
	global_position = end_position
	_dash_projectile = null
	_dash_active = false
	mr_ani.visible = true
	tiger_shark_dash_completed.emit()


func _cancel_tiger_shark_dash() -> void:
	if _dash_projectile != null and is_instance_valid(_dash_projectile):
		_dash_projectile.queue_free()
	_dash_projectile = null
	if _dash_active:
		_dash_active = false
		mr_ani.visible = true
		tiger_shark_dash_completed.emit()


func _spawn_projectile(config: Dictionary) -> NanhaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as NanhaiProjectile
	config["owner"] = self
	if not config.has("frame_fps"):
		config["frame_fps"] = _model_fps(_model_id())
	projectile.configure(config)
	bullet.add_child(projectile)
	return projectile


func _projectile_root(model: int, action: String) -> String:
	return ROOT.path_join(str(model)).path_join(action)


func _facing_sign() -> float:
	return 1.0 if monster_dir.scale.x < 0.0 else -1.0


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
	_cancel_tiger_shark_dash()
	_disable_attack_box()
	_busy = false
	is_attacking = false
	no_grav = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()


func get_ice_effect_offset() -> Vector2:
	return Vector2(0.0, -70.0)

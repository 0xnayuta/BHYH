extends BaseMonster

const FRAME_ROOT := "res://Art/monster/swf_png"
const SOURCE_FPS := 30.0
const SMALL_HURT_DURATION := 0.28
const SMALL_CORPSE_LIFETIME := 0.75
const BOSS_CORPSE_LIFETIME := 1.0

@export_enum("魔盾虎兵:3001", "牛铁枪:3003", "投石车:3004", "寅将军:3005") var monster_kind := 3001

const DATA := {
	3001:
	{
		"name": "魔盾虎兵",
		"level": 90,
		"hp": 4295000,
		"attack": 20000,
		"def": 1100,
		"mdef": 1100,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 12.0,
		"range": 105.0,
		"sight": 720.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4, -2], "kind": "physics", "protect": 80},
			"hit2": {"multiplier": 1.25, "hurt_back": [-6, -3], "kind": "physics", "protect": 110},
		},
		"animations":
		{
			&"wait": ["wait", 20, true],
			&"walk": ["walk", 16, true],
			&"hurt": ["hurt", 20, false],
			&"death": ["death", 27, false],
			&"hit1": ["attack1", 19, false],
			&"hit2": ["attack2", 18, false]
		},
	},
	3003:
	{
		"name": "牛铁枪",
		"level": 90,
		"hp": 4295000,
		"attack": 20000,
		"def": 1100,
		"mdef": 1100,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 12.0,
		"range": 155.0,
		"sight": 760.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4, -2], "kind": "physics", "protect": 80},
		},
		"animations":
		{
			&"wait": ["wait", 20, true],
			&"walk": ["walk", 16, true],
			&"hurt": ["hurt", 20, false],
			&"death": ["death", 35, false],
			&"hit1": ["attack1", 16, false]
		},
	},
	3004:
	{
		"name": "投石车",
		"level": 90,
		"hp": 7295000,
		"attack": 20000,
		"def": 1100,
		"mdef": 1100,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 7.0,
		"range": 520.0,
		"sight": 900.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"arrow": {"multiplier": 1.1, "hurt_back": [-3, -1], "kind": "physics", "protect": 70},
		},
		"animations":
		{
			&"wait": ["wait", 19, true],
			&"walk": ["walk", 15, true],
			&"hurt": ["wait", 19, false],
			&"death": ["death", 21, false],
			&"hit1": ["attack1", 45, false]
		},
	},
	3005:
	{
		"name": "寅将军",
		"level": 90,
		"hp": 18000000,
		"attack": 30000,
		"def": 4750,
		"mdef": 4750,
		"crit": 700,
		"miss": 150,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2900,
		"magic_break": 2900,
		"speed": 9.0,
		"range": 145.0,
		"sight": 1100.0,
		"attack_desire": 100,
		"exp": 100,
		"coin": 280,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "pgs", "min_value": 5, "max_value": 30, "chance": 0.33},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4, -2], "kind": "physics", "protect": 80},
			"hit2": {"multiplier": 1.25, "hurt_back": [-6, -3], "kind": "physics", "protect": 110},
			"hit3": {"multiplier": 1.5, "hurt_back": [-5, -2], "kind": "magic", "protect": 130},
		},
		"animations":
		{
			&"wait": ["wait", 20, true],
			&"walk": ["walk", 16, true],
			&"hurt": ["hurt", 20, false],
			&"death": ["death", 21, false],
			&"hit1": ["skill1", 31, false],
			&"hit2": ["skill2", 85, false],
			&"hit3": ["skill3", 40, false],
			&"dash": ["dash", 2, true],
			&"impact": ["skill2_impact", 12, false]
		},
	},
}

const VISUAL_OFFSETS := {
	3001:
	{
		&"wait": Vector2(-5.5, -39.75),
		&"walk": Vector2(6.5, -47.75),
		&"hurt": Vector2(-21.0, -47.0),
		&"death": Vector2(-1.0, -32.75),
		&"hit1": Vector2(11.75, -46.0),
		&"hit2": Vector2(21.75, -46.5),
	},
	3003:
	{
		&"wait": Vector2(15.75, -53.5),
		&"walk": Vector2(16.5, -41.5),
		&"hurt": Vector2(0.5, -53.75),
		&"death": Vector2(-19.0, -30.75),
		&"hit1": Vector2(26.25, -46.75),
	},
	3004:
	{
		&"wait": Vector2(-8.0, -62.0),
		&"walk": Vector2(-7.5, -59.5),
		&"hurt": Vector2(-8.0, -62.0),
		&"death": Vector2(-9.0, -48.75),
		&"hit1": Vector2(-11.0, -62.75),
	},
	3005:
	{
		&"wait": Vector2(-11.75, -52.5),
		&"walk": Vector2(-6.0, -49.25),
		&"hurt": Vector2(-33.0, -59.25),
		&"death": Vector2(-22.25, -36.25),
		&"hit1": Vector2(89.75, -121.0),
		&"hit2": Vector2(14.75, -55.25),
		&"hit3": Vector2(-10.5, -62.5),
		&"dash": Vector2(-38.25, -74.5),
		&"impact": Vector2(-7.5, -69.75),
	},
}

static var _legacy_frames_cache: Dictionary = {}

var _skill_busy := false
var _next_attack_msec := 0
var _attack_serial := 0
var _death_sequence_started := false
var _runtime_config: Dictionary = {}


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
	my_mr_name = str(config.get("name", "玄武门怪物%d" % monster_kind))
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
	fall_list = config["drop_list"].duplicate()
	independent_fall_list = config.get("independent_drop_list", []).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	_refresh_damage()


func _refresh_damage() -> void:
	var difficulty := clampi(int(MainSet.set_data.get("Difficult", 0)), 0, 3)
	var multiplier: float = [1.0, 2.0, 3.0, 1.0][difficulty]
	var config: Dictionary = _runtime_config
	var base_power: float = float(config["attack"]) * multiplier
	var attacks: Dictionary = config["attacks"]
	obj_attack_dict.clear()
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		obj_attack_dict[attack_name] = {
			"power": int(base_power * float(attack["multiplier"])),
			"hurtBack": attack["hurt_back"].duplicate(),
			"attackKind": str(attack["kind"]),
			"HitProtect": int(attack["protect"]),
		}


func monster_info_attack_values_include_difficulty() -> bool:
	return int(MainSet.set_data.get("Difficult", 0)) != BaseMonster.NIGHTMARE_DIFFICULTY


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


func _build_animations() -> void:
	var animations: Dictionary = DATA[monster_kind]["animations"]
	mr_ani.sprite_frames = _load_standard_frames()
	mr_ani.centered = true

	mr_ani.flip_h = true
	mr_ani.position = _visual_offset(&"wait")

	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for animation_name: StringName in animations:
		var animation_data: Array = animations[animation_name]
		var animation := _make_animation(animation_name, int(animation_data[1]), bool(animation_data[2]))
		if animation_name == &"death":
			_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		elif animation_name.begins_with("hit"):
			_add_attack_keys(animation, animation_name)
		library.add_animation(animation_name, animation)
	mr_player.add_animation_library(&"", library)


func _load_standard_frames() -> SpriteFrames:
	if _legacy_frames_cache.has(monster_kind):
		return _legacy_frames_cache[monster_kind] as SpriteFrames
	var frames_path := FRAME_ROOT.path_join(str(monster_kind)).path_join("atlas").path_join(
		"swf_png_%d_frames.tres" % monster_kind
	)
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null:
		return null
	_legacy_frames_cache[monster_kind] = source
	return source


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


func _add_attack_keys(animation: Animation, attack_name: StringName) -> void:
	if monster_kind == 3004:
		_add_method_key(animation, animation.length * 0.52, &"_fire_arrow")
		return
	if monster_kind == 3005 and attack_name == &"hit2":
		return
	var hit_start := animation.length * 0.3
	var hit_end := animation.length * 0.62
	if monster_kind == 3005 and attack_name == &"hit1":
		hit_start = 15.0 / SOURCE_FPS
		hit_end = 28.0 / SOURCE_FPS
	elif monster_kind == 3005 and attack_name == &"hit3":
		hit_start = 14.0 / SOURCE_FPS
		hit_end = 38.0 / SOURCE_FPS
	_add_method_key(animation, hit_start, &"_enable_attack_box", [attack_name])
	_add_method_key(animation, hit_end, &"_disable_attack_box")


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, animation.length - 0.001), {"method": method_name, "args": args}
	)


func _play_frames(animation_name: StringName) -> void:
	mr_ani.position = _visual_offset(animation_name)
	var custom_speed := 1.0
	if not is_boss and animation_name == &"hurt":
		var hurt_data: Array = DATA[monster_kind]["animations"][&"hurt"]
		custom_speed = float(hurt_data[1]) / (SMALL_HURT_DURATION * SOURCE_FPS)
	mr_ani.play(animation_name, custom_speed)


func _visual_offset(animation_name: StringName) -> Vector2:
	var offsets: Dictionary = VISUAL_OFFSETS[monster_kind]
	var offset: Vector2 = offsets.get(animation_name, offsets[&"wait"])

	if mr_ani.flip_h:
		offset.x = -offset.x
	return offset


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
	super.state_hurt()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if death() or _death_sequence_started:
		return
	super._on_hurt_box_area_entered(area)


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
	if monster_kind == 3005:
		if distance > 180.0 and distance <= 820.0 and Time.get_ticks_msec() >= _next_attack_msec:
			_start_attack(&"hit2")
		elif distance > 180.0:
			have_target()
		elif Time.get_ticks_msec() >= _next_attack_msec:
			_start_attack(&"hit1" if randi_range(0, 1) == 0 else &"hit3")
		else:
			stop_move()
		return
	if distance > float(attack_range):
		have_target()
	elif Time.get_ticks_msec() >= _next_attack_msec:
		_start_attack(_choose_attack())
	else:
		stop_move()


func _choose_attack() -> StringName:
	if monster_kind == 3001:
		return &"hit2" if randi_range(0, 1) == 1 else &"hit1"
	return &"hit1"


func _start_attack(attack_name: StringName) -> void:
	if not mr_player.has_animation(attack_name):
		return
	_attack_serial += 1
	var serial := _attack_serial
	_refresh_damage()
	hit_name = str(attack_name)
	velocity.x = 0
	is_attacking = true
	_skill_busy = true
	if is_boss:
		super_armor_active = true
		cannot_attract = true
	if monster_kind == 3005 and attack_name == &"hit2":
		await _run_boss_skill_2(serial)
		return
	mr_player.play(attack_name)
	await mr_player.animation_finished
	if not is_instance_valid(self) or serial != _attack_serial or death():
		return
	_finish_attack()


func _finish_attack() -> void:
	_disable_attack_box()
	is_attacking = false
	_skill_busy = false
	super_armor_active = false
	cannot_attract = false
	_next_attack_msec = Time.get_ticks_msec() + (650 if monster_kind != 3005 else 900)
	stop_move()


func _run_boss_skill_2(serial: int) -> void:
	mr_player.play(&"hit2")
	await get_tree().create_timer(15.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or serial != _attack_serial or death():
		return
	mr_player.stop()
	hit_name = "hit2"
	_play_frames(&"dash")
	_configure_boss_attack_box(&"hit2_dash")
	_enable_attack_box(&"hit2")
	var target_x := position.x + (240.0 if monster_direction else -240.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var dash_distance := absf(target_x - position.x)
	var dash_duration := clampf(dash_distance / 720.0, 0.18, 0.85)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position:x", target_x, dash_duration)
	await tween.finished
	if not is_instance_valid(self) or serial != _attack_serial or death():
		return
	_disable_attack_box()
	await get_tree().physics_frame
	_play_frames(&"impact")
	_configure_boss_attack_box(&"hit2_impact")
	_enable_attack_box(&"hit2")
	await get_tree().create_timer(12.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or serial != _attack_serial or death():
		return
	_finish_attack()


func is_control_immune() -> bool:
	return (is_boss and _skill_busy) or super.is_control_immune()


func _finish_hurt_reaction(hurt_generation: int) -> void:
	super._finish_hurt_reaction(hurt_generation)
	if not is_boss:
		velocity.x = 0.0


func get_ice_effect_offset() -> Vector2:
	return Vector2(0, 10)


func _enable_attack_box(attack_name: StringName) -> void:
	hit_name = str(attack_name)
	if monster_kind == 3005 and attack_name != &"hit2":
		_configure_boss_attack_box(attack_name)
	hit_box.disabled = false


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.disabled = true


func _configure_boss_attack_box(action: StringName) -> void:
	if monster_kind != 3005:
		return
	var shape := RectangleShape2D.new()
	match action:
		&"hit1":
			hit_box.position = Vector2(-105, -70)
			shape.size = Vector2(285, 145)
		&"hit3":
			hit_box.position = Vector2(0, -70)
			shape.size = Vector2(380, 140)
		&"hit2_impact":
			hit_box.position = Vector2(0, -70)
			shape.size = Vector2(330, 155)
		_:
			hit_box.position = Vector2(0, -68)
			shape.size = Vector2(190, 125)
	hit_box.shape = shape


func _fire_arrow() -> void:
	hit_name = "arrow"
	_refresh_damage()
	var offset := Vector2(100 if monster_direction else -100, -60)
	Global.add_bullet(
		"XuanwuGateArrow", bullet, monster_direction, 1.0, position + offset, "arrow", obj_attack_dict["arrow"]
	)


func little_blood_bar_control() -> void:
	super.little_blood_bar_control()
	if monster_blood_bar != null:
		monster_blood_bar.position = Vector2(-30, -175 if is_boss else -135)


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_legacy_frames_cache.clear()

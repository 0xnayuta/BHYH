extends BaseMonster
class_name JiuhuaMountainMonster

const SOURCE_FPS := 30.0
const FRAME_ROOT := "res://Art/monster/swf_png"
const SMALL_CORPSE_LIFETIME := 0.75
const SMALL_HURT_DURATION := 0.28
const BOSS_CORPSE_LIFETIME := 1.0
const BOSS_GUARD_DURATION := 8.0
const BOSS_GUARD_MAGIC_DAMAGE_MULTIPLIER := 4.0 / 9.0
const BOSS_GUARD_REFLECT_RATE := 0.1
const BOSS_GUARD_DEF_FLAT_SCALED := 1600
const BOSS_GUARD_REFLECT_FLAT_SCALED := 5470
const BOSS_LIFE_MARK_SCRIPT := preload("res://Script/monster/jiuhua_life_mark.gd")

@export_enum("蘑菇精:3008", "金钱松:3009", "闵老护法:3019") var monster_kind := 3008

const DATA := {
	3008:
	{
		"name": "蘑菇精",
		"level": 90,
		"hp": 5295000,
		"attack": 20000,
		"def": 1400,
		"mdef": 1400,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 11.0,
		"range": 85.0,
		"min_range": 0.0,
		"sight": 760.0,
		"exp": 10,
		"coin": 8,
		"is_boss": false,
		"max_protect": 100.0,
		"cooldown": 950,
		"attacks":
		{
			"hit1":
			{
				"multiplier": 0.5,
				"hurt_back": [-0.84, -2.8],
				"kind": "physics",
				"protect": 1112,
				"source_target_move": Vector2(21, 42),
				"source_stiff_seconds": 0.334,
			},
		},
		"animations":
		{
			&"wait": ["wait", 20, true],
			&"walk": ["walk", 16, true],
			&"hurt": ["hurt", 20, false],
			&"death": ["death", 19, false],
			&"hit1": ["attack1", 30, false]
		},
	},
	3009:
	{
		"name": "金钱松",
		"level": 90,
		"hp": 6295000,
		"attack": 21000,
		"def": 1400,
		"mdef": 1400,
		"crit": 300,
		"miss": 160,
		"hit": 290,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 10.0,
		"range": 330.0,
		"min_range": 0.0,
		"sight": 600.0,
		"exp": 10,
		"coin": 8,
		"is_boss": false,
		"max_protect": 100.0,
		"cooldown": 1200,
		"attacks":
		{
			"arrow": {"multiplier": 1.0, "hurt_back": [-3, -1], "kind": "physics", "protect": 70},
		},
		"animations":
		{
			&"wait": ["wait", 20, true],
			&"walk": ["walk", 18, true],
			&"hurt": ["hurt", 20, false],
			&"death": ["death", 20, false],
			&"hit1": ["attack1", 19, false]
		},
	},
	3019:
	{
		"name": "闵老护法",
		"level": 90,
		"hp": 18000000,
		"attack": 32000,
		"def": 4800,
		"mdef": 4800,
		"crit": 700,
		"miss": 160,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4000,
		"magic_break": 4000,
		"speed": 9.0,
		"range": 370.0,
		"min_range": 0.0,
		"sight": 1200.0,
		"exp": 100,
		"coin": 280,
		"is_boss": true,
		"max_protect": 240.0,
		"cooldown": 1600,
		"attacks":
		{
			"hit1": {"multiplier": 0.0, "hurt_back": [0, 0], "kind": "", "protect": 0},
			"hit2":
			{
				"multiplier": 1.0,
				"hurt_back": [-5, -2],
				"kind": "physics",
				"protect": 834,
				"source_target_move": Vector2(138, 120),
				"source_stiff_seconds": 1.0,
			},
			"hit3":
			{
				"multiplier": 0.5,
				"hurt_back": [-5, -2],
				"kind": "magic",
				"protect": 3334,
				"source_target_move": Vector2(206, 80),
				"source_stiff_seconds": 0.834,
			},
		},
		"animations":
		{
			&"wait": ["wait", 20, true],
			&"walk": ["walk", 16, true],
			&"hurt": ["hurt", 25, false],
			&"death": ["death", 25, false],
			&"hit1": ["attack1", 36, false],
			&"hit2": ["attack2", 33, false],
			&"hit3": ["attack3", 35, false]
		},
	},
}

const VISUAL_OFFSETS := {
	3008:
	{
		&"wait": Vector2(0, -52.5),
		&"walk": Vector2(0, -52),
		&"hurt": Vector2(0, -59),
		&"death": Vector2(0, -52.5),
		&"hit1": Vector2(27.5, -50.5)
	},
	3009:
	{
		&"wait": Vector2(0, -34.5),
		&"walk": Vector2(0, -37.5),
		&"hurt": Vector2(-8, -27),
		&"death": Vector2(0, -28.5),
		&"hit1": Vector2(9, -32)
	},
	3019:
	{
		&"wait": Vector2(0, -64.5),
		&"walk": Vector2(0, -65.5),
		&"hurt": Vector2(0, -73),
		&"death": Vector2(0, -50),
		&"hit1": Vector2(-10, -69),
		&"hit2": Vector2(30, -72.5),
		&"hit3": Vector2(102, -69)
	},
}

static var _frames_cache: Dictionary = {}
var _skill_busy := false
var _next_attack_msec := 0
var _attack_serial := 0
var _death_sequence_started := false
var _boss_guard_active := false
var _boss_guard_generation := 0
var _boss_skill_armor_active := false
var _pending_friendly_attacker_ref: WeakRef
var _boss_guard_effect: AnimatedSprite2D
var _boss_guard_effect_tween: Tween
var _runtime_config: Dictionary = {}


static func prewarm_frames(monster_kinds: Array) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	for kind_value in monster_kinds:
		var kind := int(kind_value)
		if not DATA.has(kind) or _frames_cache.has(kind):
			continue
		var warm_instance := JiuhuaMountainMonster.new()
		warm_instance.monster_kind = kind
		warm_instance._get_sprite_frames()
		warm_instance.free()
		if tree != null:
			await tree.process_frame


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
	attack_desire = 100
	add_exp = int(config["exp"])
	fall_coin = int(config["coin"])
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	_build_base_attack_data(config)
	_configure_regular_attack_box()


func _build_base_attack_data(config: Dictionary) -> void:
	obj_attack_dict.clear()
	var attacks: Dictionary = config["attacks"]
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		var attack_data := {
			"power": int(float(config["attack"]) * float(attack["multiplier"])),
			"hurtBack": attack["hurt_back"].duplicate(),
			"attackKind": str(attack["kind"]),
			"HitProtect": int(attack["protect"]),
		}
		if attack.has("source_target_move"):
			attack_data["sourceTargetMove"] = attack["source_target_move"]
		if attack.has("source_stiff_seconds"):
			attack_data["sourceStiffSeconds"] = attack["source_stiff_seconds"]
		obj_attack_dict[attack_name] = attack_data


func _configure_regular_attack_box() -> void:
	if hit_box == null:
		return
	var shape := RectangleShape2D.new()
	match monster_kind:
		3008:
			hit_box.position = Vector2(-42.5, -45.0)
			shape.size = Vector2(85.0, 90.0)
		3009:
			hit_box.position = Vector2(-195.0, -40.0)
			shape.size = Vector2(270.0, 80.0)
		_:
			return
	hit_box.shape = shape


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


func _build_animations() -> void:
	mr_ani.sprite_frames = _get_sprite_frames()
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
		elif monster_kind == 3008 and animation_name == &"hit1":
			_add_attack_frame_window(animation, &"hit1", 10, 15)
			_add_attack_frame_window(animation, &"hit1", 22, 28)
		elif monster_kind == 3009 and animation_name == &"hit1":
			_add_method_key(animation, _frame_start_time(6), &"_fire_arrow")
		elif monster_kind == 3019:
			match animation_name:
				&"hit1":
					_add_method_key(animation, _frame_start_time(15), &"_activate_boss_guard")
				&"hit2":
					_add_attack_frame_window(animation, &"hit2", 17, 27)
				&"hit3":
					_add_attack_frame_window(animation, &"hit3", 16, 30)

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


func _add_attack_frame_window(animation: Animation, attack_name: StringName, start_frame: int, end_frame: int) -> void:
	_add_method_key(animation, _frame_start_time(start_frame), &"_enable_attack_box", [attack_name])
	_add_method_key(animation, float(end_frame) / SOURCE_FPS, &"_disable_attack_box")


func _frame_start_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


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
	if Time.get_ticks_msec() < _next_attack_msec:
		if distance > float(attack_range):
			have_target()
		else:
			stop_move()
		return
	if monster_kind == 3019:
		if not _boss_guard_active:
			_start_attack(&"hit1")
		elif distance <= 130.0:
			_start_attack(&"hit2")
		elif distance >= 80.0 and distance <= 370.0:
			_start_attack(&"hit3")
		else:
			have_target()
		return
	var config: Dictionary = _runtime_config
	var minimum_range := float(config["min_range"])
	if minimum_range > 0.0 and distance < minimum_range:
		_move_away_from_hero()
	elif distance > float(attack_range):
		have_target()
	else:
		_start_attack(&"hit1")


func _move_away_from_hero() -> void:
	if float(RoleProp.get_nearest_monster_target_position(global_position).x) > position.x:
		move_left()
	else:
		move_right()


func _start_attack(attack_name: StringName) -> void:
	if not mr_player.has_animation(attack_name):
		return
	_attack_serial += 1
	var serial := _attack_serial
	hit_name = str(attack_name)
	velocity.x = 0.0
	is_attacking = true
	_skill_busy = true
	_boss_skill_armor_active = monster_kind == 3019 and attack_name in [&"hit2", &"hit3"]
	if monster_kind == 3019 and attack_name == &"hit2":
		await _run_boss_skill_2(serial)
		return
	mr_player.play(attack_name)
	await mr_player.animation_finished
	if not is_instance_valid(self) or serial != _attack_serial or death() or not _skill_busy:
		return
	_finish_attack()


func _finish_attack() -> void:
	_disable_attack_box()
	is_attacking = false
	_skill_busy = false
	_boss_skill_armor_active = false
	_next_attack_msec = Time.get_ticks_msec() + int(_runtime_config["cooldown"])
	stop_move()


func _run_boss_skill_2(serial: int) -> void:
	mr_player.play(&"hit2")
	await get_tree().create_timer(15.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or serial != _attack_serial or death():
		return
	var target_x := position.x + (100.0 if monster_direction else -100.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var motion := create_tween()
	motion.set_trans(Tween.TRANS_LINEAR)
	motion.tween_property(self, "position:x", target_x, 12.0 / SOURCE_FPS)
	await motion.finished
	if not is_instance_valid(self) or serial != _attack_serial or death():
		return
	await mr_player.animation_finished
	if not is_instance_valid(self) or serial != _attack_serial or death() or not _skill_busy:
		return
	_finish_attack()


func _enable_attack_box(attack_name: StringName) -> void:
	hit_name = str(attack_name)
	if monster_kind == 3019:
		_configure_boss_attack_box(attack_name)
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _configure_boss_attack_box(attack_name: StringName) -> void:
	var shape := RectangleShape2D.new()
	match attack_name:
		&"hit2":
			hit_box.position = Vector2(-65.0, -110.0)
			shape.size = Vector2(130.0, 220.0)
		&"hit3":
			hit_box.position = Vector2(-225.0, -78.0)
			shape.size = Vector2(290.0, 150.0)
		_:
			return
	hit_box.shape = shape


func _fire_arrow() -> void:
	if death():
		return
	var shoots_right := monster_dir.scale.x < 0.0
	var offset := Vector2(33.0 if shoots_right else -33.0, -20.0)

	var arrow = Global.add_bullet(
		"JiuhuaPineArrow", bullet, shoots_right, 1.0, position + offset, "arrow", obj_attack_dict["arrow"]
	)
	if (
		arrow != null
		and RoleProp.get_nearest_monster_target_position(global_position).x != null
		and arrow.has_method("set_source_shot_distance")
	):
		arrow.set_source_shot_distance(
			absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x)
		)


func is_control_immune() -> bool:
	return (
		(monster_kind == 3019 and _skill_busy)
		or _boss_guard_active
		or _boss_skill_armor_active
		or super.is_control_immune()
	)


func _finish_hurt_reaction(hurt_generation: int) -> void:
	super._finish_hurt_reaction(hurt_generation)
	if not is_boss:
		velocity.x = 0.0


func get_ice_effect_offset() -> Vector2:
	return Vector2(0, -79)


func _activate_boss_guard() -> void:
	if monster_kind != 3019 or death() or _boss_guard_active:
		return
	_boss_guard_generation += 1
	var generation := _boss_guard_generation
	_boss_guard_active = true
	_create_boss_guard_effect()

	def = roundi(float(_runtime_config["def"]) * 1.5) + BOSS_GUARD_DEF_FLAT_SCALED
	(
		Global
		. add_buff(
			buff,
			{
				"Name": "SuperArmor",
				"AddTime": BOSS_GUARD_DURATION,
				"reduce_interval": 0.0,
				"value": 0.0,
				"AttackKind": "",
				"CanAdd": false,
				"CanRemove": true,
				"DeBuff": false,
			}
		)
	)
	await get_tree().create_timer(BOSS_GUARD_DURATION, false).timeout
	if is_instance_valid(self) and generation == _boss_guard_generation:
		_deactivate_boss_guard()


func _deactivate_boss_guard() -> void:
	_boss_guard_generation += 1
	_boss_guard_active = false
	_remove_boss_guard_effect()
	if monster_kind == 3019:
		def = int(_runtime_config["def"])


func _create_boss_guard_effect() -> void:
	_remove_boss_guard_effect()
	_boss_guard_effect = AnimatedSprite2D.new()
	_boss_guard_effect.name = "BossGuardEffect"
	_boss_guard_effect.sprite_frames = mr_ani.sprite_frames
	_boss_guard_effect.centered = mr_ani.centered
	_boss_guard_effect.flip_h = mr_ani.flip_h
	_boss_guard_effect.scale = Vector2(1.12, 1.12)
	_boss_guard_effect.z_index = mr_ani.z_index - 1
	var additive_material := CanvasItemMaterial.new()
	additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_boss_guard_effect.material = additive_material
	monster_dir.add_child(_boss_guard_effect)
	_sync_boss_guard_effect()
	_boss_guard_effect.self_modulate = Color(1.0, 0.12, 0.12, 0.3)
	_boss_guard_effect_tween = create_tween().set_loops()
	_boss_guard_effect_tween.tween_property(_boss_guard_effect, "self_modulate", Color(1.0, 0.22, 0.12, 0.68), 0.32)
	_boss_guard_effect_tween.tween_property(_boss_guard_effect, "self_modulate", Color(1.0, 0.08, 0.08, 0.26), 0.32)


func _process(_delta: float) -> void:
	if _boss_guard_effect != null and is_instance_valid(_boss_guard_effect):
		_sync_boss_guard_effect()


func _sync_boss_guard_effect() -> void:
	if _boss_guard_effect == null or not is_instance_valid(_boss_guard_effect):
		return
	_boss_guard_effect.position = mr_ani.position
	_boss_guard_effect.flip_h = mr_ani.flip_h
	_boss_guard_effect.animation = mr_ani.animation
	_boss_guard_effect.frame = mr_ani.frame
	_boss_guard_effect.frame_progress = mr_ani.frame_progress


func _remove_boss_guard_effect() -> void:
	if _boss_guard_effect_tween != null and _boss_guard_effect_tween.is_valid():
		_boss_guard_effect_tween.kill()
	_boss_guard_effect_tween = null
	if _boss_guard_effect != null and is_instance_valid(_boss_guard_effect):
		_boss_guard_effect.queue_free()
	_boss_guard_effect = null


func _on_hurt_box_area_entered(area: Area2D) -> void:
	var incoming_kind := _get_incoming_attack_kind(area)
	var incoming_attacker := _get_incoming_attacker(area)
	var hp_before := hp
	var previous_hurt_multiplier := hurt_bl
	if _boss_guard_active and incoming_kind == "magic":
		hurt_bl *= BOSS_GUARD_MAGIC_DAMAGE_MULTIPLIER
	super._on_hurt_box_area_entered(area)
	hurt_bl = previous_hurt_multiplier
	var received_damage := maxi(hp_before - hp, 0)
	if not _boss_guard_active or received_damage <= 0:
		return
	_apply_boss_guard_reflection(incoming_attacker, received_damage)


func resolve_friendly_damage(base_damage: int, attack_kind: String, attacker: Node = null) -> int:
	_pending_friendly_attacker_ref = weakref(attacker) if attacker != null and is_instance_valid(attacker) else null
	var previous_hurt_multiplier := hurt_bl
	if _boss_guard_active and attack_kind == "magic":
		hurt_bl *= BOSS_GUARD_MAGIC_DAMAGE_MULTIPLIER
	var resolved_damage := super.resolve_friendly_damage(base_damage, attack_kind, attacker)
	hurt_bl = previous_hurt_multiplier
	if resolved_damage <= 0:
		_pending_friendly_attacker_ref = null
	return resolved_damage


func reduce_pet_hp(value: int, attack_kind: String) -> int:
	var attacker: Node = null
	if _pending_friendly_attacker_ref != null:
		attacker = _pending_friendly_attacker_ref.get_ref() as Node
	var hp_before := hp
	var received_damage := super.reduce_pet_hp(value, attack_kind)
	var actual_damage := maxi(hp_before - hp, 0)
	_pending_friendly_attacker_ref = null
	if _boss_guard_active and actual_damage > 0:
		_apply_boss_guard_reflection(attacker, actual_damage)
	return received_damage


func _apply_boss_guard_reflection(attacker: Node, received_damage: int) -> void:
	if attacker == null or not is_instance_valid(attacker) or received_damage <= 0:
		return
	var reflected_damage := int(float(received_damage) * BOSS_GUARD_REFLECT_RATE) + BOSS_GUARD_REFLECT_FLAT_SCALED
	if attacker.has_method("effect_reducehp"):
		attacker.effect_reducehp(reflected_damage, "physics")
	elif attacker.has_method("reduce_hp"):
		attacker.reduce_hp(reflected_damage, self)


func _get_incoming_attack_source(area: Area2D) -> Node:
	if area == null or not is_instance_valid(area):
		return null
	if area is BaseRoleHitBox or area is RolehmzBullet:
		return _get_damage_source_player(area)
	if area is MagicWeaponHit:
		return _get_damage_source_player(area)
	var parent := area.get_parent()
	if parent == null:
		return null
	if parent is Role1Shallow:
		return parent
	if area is RoleBullet1:
		return _get_damage_source_player(area)
	var grand_parent := parent.get_parent()
	if grand_parent is RoleBullet:
		return _get_damage_source_player(area)
	return null


func _get_incoming_attack_kind(area: Area2D) -> String:
	var source := _get_incoming_attack_source(area)
	if source == null or not is_instance_valid(source):
		return ""
	var hit_data: Variant = source.get("hit_dic")
	if hit_data is Dictionary:
		return str(hit_data.get("attackKind", ""))
	if source is BaseHero:
		var attack_data: Variant = source.obj_attack_dict.get(str(source.get("get_action")), {})
		if attack_data is Dictionary:
			return str(attack_data.get("attackKind", ""))
	return ""


func _get_incoming_attacker(area: Area2D) -> Node:
	var source := _get_incoming_attack_source(area)
	if source == null or not is_instance_valid(source):
		return get_player if get_player != null and is_instance_valid(get_player) else null
	if source is BaseHero:
		return source
	var player_value: Variant = source.get("Player")
	if player_value is BaseHero and is_instance_valid(player_value):
		return player_value
	var parent: Node = source
	var depth := 0
	while parent != null and depth < 8:
		if parent is BaseHero:
			return parent
		parent = parent.get_parent()
		depth += 1
	return get_player if get_player != null and is_instance_valid(get_player) else null


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	var target := super._on_hit_box_area_entered(area)
	if monster_kind == 3019 and hit_name == "hit3" and target is BaseHero:
		_add_boss_life_mark(target)
	return target


func _add_boss_life_mark(target: BaseHero) -> void:
	if target == null or not is_instance_valid(target) or target.no_debuff:
		return
	var life_mark := target.get_node_or_null("JiuhuaLifeMark")
	if life_mark != null and not life_mark.is_queued_for_deletion():
		life_mark.add_stack(_boss_life_mark_attack_power())
		return
	life_mark = BOSS_LIFE_MARK_SCRIPT.new()
	target.add_child(life_mark)
	life_mark.start(target, _boss_life_mark_attack_power())


func _boss_life_mark_attack_power() -> int:
	var hit2_data: Dictionary = obj_attack_dict.get("hit2", {})
	return maxi(int(hit2_data.get("power", attack_in)), 0)


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
	_boss_skill_armor_active = false
	if _boss_guard_active or _boss_guard_effect != null:
		_deactivate_boss_guard()
	no_grav = false
	velocity = Vector2.ZERO
	super.state_death()
	_ensure_death_cleanup()


func state_hurt() -> void:
	if death() or _death_sequence_started:
		return
	if is_control_immune():
		return
	if _skill_busy:
		_attack_serial += 1
		_skill_busy = false
		is_attacking = false
		_disable_attack_box()
	super.state_hurt()


func _ensure_death_cleanup() -> void:
	var corpse_lifetime := BOSS_CORPSE_LIFETIME if is_boss else SMALL_CORPSE_LIFETIME
	await get_tree().create_timer(corpse_lifetime, false).timeout
	if is_instance_valid(self) and not is_queued_for_deletion():
		settle_death_drops_and_free()


func _disable_death_collisions() -> void:
	_disable_attack_box()
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)


func little_blood_bar_control() -> void:
	super.little_blood_bar_control()
	if monster_blood_bar != null:
		monster_blood_bar.position = Vector2(-30.0, -190.0 if is_boss else -140.0)


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_frames_cache.clear()

extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const SOURCE_FPS := 24.0

const SOURCE_X_SCALE := 1.0
const ATTACK_RANGE_HYSTERESIS := 24.0

const SKILL_VISUAL_REGISTRATIONS := {
	163: {&"hit1": Vector2(-215.3, 0.0), &"hit2": Vector2(4.275, 117.7), &"hit3": Vector2(-4.1, 1.2)},
	164: {&"hit1": Vector2(-156.8, -3.4), &"hit2": Vector2(2.25, -20.0), &"hit3": Vector2(-4.225, 0.0)},
	165: {&"hit1": Vector2(-126.475, -17.475), &"hit2": Vector2(-76.725, -35.3), &"hit3": Vector2(3.0, -1.0)},
	166: {&"hit1": Vector2(-165.05, 0.9), &"hit2": Vector2(5.825, -97.925), &"hit3": Vector2(-0.45, 0.125)},
	168: {&"hit1": Vector2(-124.825, 1.75), &"hit2": Vector2(-183.25, 4.65), &"hit3": Vector2(3.8, -33.25)},
	169: {&"hit1": Vector2(-141.4, 1.25), &"hit2": Vector2.ZERO, &"hit3": Vector2(-140.6, 12.7)},
	174: {&"hit1": Vector2(-151.075, -5.525), &"hit2": Vector2(-108.125, 0.0), &"hit3": Vector2(11.85, 112.975)},
	175: {&"hit1": Vector2(-161.525, -3.625), &"hit2": Vector2.ZERO, &"hit3": Vector2.ZERO},
}

const BOSS_VISUAL_CONFIG := {
	163:
	{
		"name": "魔·吕洞宾",
		"offset": Vector2(24, -28),
		"body_frames": 7,
		"holds": [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 1, 10], [2, 2, 10], [2, 2, 30]],
		"effects": [20, 25, 1],
		"cooldown_ranges": [[6, 10], [8, 10]],
		"kinds": ["magic", "magic", "magic"],
		"powers": [10, 20, 15],
		"intervals": [999, 10, 10]
	},
	164:
	{
		"name": "魔·铁拐李",
		"offset": Vector2(4, -4),
		"body_frames": 7,
		"holds": [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 2, 10], [2, 10]],
		"effects": [15, 15, 150],
		"cooldown_ranges": [[6, 10], [8, 10]],
		"kinds": ["magic", "magic", "magic"],
		"powers": [10, 20, 15],
		"intervals": [999, 999, 24]
	},
	165:
	{
		"name": "魔·韩湘子",
		"offset": Vector2(4, -20),
		"body_frames": 7,
		"holds": [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 2, 10], [4, 4], [2, 2, 10]],
		"effects": [15, 1, 6],
		"cooldown_ranges": [[6, 9], [8, 11]],
		"kinds": ["physics", "physics", "magic"],
		"powers": [10, 20, 15],
		"intervals": [999, 999, 24]
	},
	166:
	{
		"name": "魔·汉钟离",
		"offset": Vector2(20, -20),
		"body_frames": 7,
		"holds": [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 2, 2, 10], [2, 10]],
		"effects": [20, 10, 20],
		"cooldown_ranges": [[6, 9], [8, 15]],
		"kinds": ["physics", "physics", "magic"],
		"powers": [10, 20, 15],
		"intervals": [999, 999, 24]
	},
	168:
	{
		"name": "魔·张果老",
		"offset": Vector2(-22, -20),
		"body_frames": 7,
		"holds": [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 2, 10], [2, 2, 2, 10], [2, 2, 2, 10]],
		"effects": [21, 25, 30],
		"cooldown_ranges": [[6, 9], [8, 11]],
		"kinds": ["physics", "physics", "magic"],
		"powers": [10, 20, 15],
		"intervals": [999, 999, 10]
	},
	169:
	{
		"name": "魔·蓝采和",
		"offset": Vector2(2, -40),
		"body_frames": 7,
		"holds": [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 10], [2, 2, 2, 2, 2, 2]],
		"effects": [50, 0, 50],
		"cooldown_ranges": [[6, 18], [8, 11]],
		"kinds": ["physics", "physics", "magic"],
		"powers": [10, 0, 5],
		"intervals": [999, 999, 10]
	},
	174:
	{
		"name": "魔·曹国舅",
		"offset": Vector2(5, -20),
		"body_frames": 7,
		"holds": [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 2, 2, 10], [2, 2, 10]],
		"effects": [20, 35, 26],
		"cooldown_ranges": [[6, 9], [8, 15]],
		"kinds": ["physics", "physics", "magic"],
		"powers": [10, 20, 15],
		"intervals": [999, 15, 5]
	},
	175:
	{
		"name": "魔·何仙姑",
		"offset": Vector2(5, -20),
		"body_frames": 7,
		"holds": [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 10], [2, 10]],
		"effects": [20, 0, 1],
		"cooldown_ranges": [[6, 14], [8, 10]],
		"kinds": ["physics", "physics", "magic"],
		"powers": [10, 20, 15],
		"intervals": [999, 15, 24]
	},
}

const BODY_FOOT_OFFSETS := {
	163: Vector2(-22, -16),
	164: Vector2(4, 7),
	165: Vector2(4, -2),
	166: Vector2(20, -7),
	168: Vector2(-22, -6),
	169: Vector2(2, -21),
	174: Vector2(5, -3),
	175: Vector2(5, -4),
}

const HE_XIANGU_ABSORB_FOOT_VISUAL_OFFSET := Vector2(0, 81)

const HAN_ZHONGLI_SHIELD_VISUAL_OFFSET := Vector2(0, 13)

@export var monster_id := 163

var _config: Dictionary
var _runtime_config: Dictionary = {}
var _skill_busy := false
var _absorb_active := false
var _full_invulnerability_active := false
var _attack_recovery_until_msec := 0
var _combat_range_latched := false


func _ready() -> void:
	_config = _resolve_config()
	if _config.is_empty():
		push_error("Unknown Eight Immortals boss id: %d" % monster_id)
		return
	_configure_visuals()
	_configure_animation_player()
	_configure_stats()
	set_meta("sssl_special_boss", true)
	set_meta("allow_role_special_control", true)

	super._ready()
	_reset_source_skill_cooldowns()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_keep_boss_inside_stage()


func _recover_interrupted_combat_state() -> void:
	if _skill_busy or Time.get_ticks_msec() < _attack_recovery_until_msec:
		return
	super._recover_interrupted_combat_state()


func get_knockback_direction_for_target(target_obj: Node, target_hero: BaseHero) -> int:
	return 1 if monster_direction else -1


func get_knockback_velocity_for_target(target_obj: Node, target_hero: BaseHero) -> Vector2:
	var direction := get_knockback_direction_for_target(target_obj, target_hero)
	var hurt_back: Array = []
	if target_obj != null and target_obj.has_method("get"):
		var hit_name_value: Variant = target_obj.get("hit_name")
		var attack_value: Variant = obj_attack_dict.get(str(hit_name_value), {})
		if attack_value is Dictionary:
			hurt_back = Array((attack_value as Dictionary).get("hurtBack", [])).duplicate()
	if hurt_back.size() < 2:
		return Vector2.ZERO
	var horizontal_value := -float(hurt_back[0]) * 25.0 if direction > 0 else float(hurt_back[0]) * 25.0
	var horizontal := clampf(horizontal_value, -90.0, 90.0)
	var vertical := clampf(float(hurt_back[1]) * 15.0, -45.0, 45.0)
	return Vector2(horizontal, vertical)


func _keep_boss_inside_stage() -> void:
	if not is_inside_tree():
		return

	global_position.x = clampf(global_position.x, 60.0, 1643.0)
	var level_node := get_level_node()
	var boat := level_node.get_node_or_null("stage501Boat") if level_node != null else null
	var collision := boat.get_node_or_null("CollisionShape2D") as CollisionShape2D if boat != null else null
	if collision != null and collision.shape != null:
		var boat_floor_y := collision.global_position.y - collision.shape.get_rect().size.y * 0.5
		var floor_offset := pz.position.y + pz.shape.get_rect().size.y * 0.5 if pz != null and pz.shape != null else 0.0
		var floor_origin_y := boat_floor_y - floor_offset
		if global_position.y > floor_origin_y:
			global_position.y = floor_origin_y
			velocity.y = 0.0
	elif global_position.y > 430.0:
		global_position.y = 430.0
		velocity.y = 0.0


func _configure_monster() -> void:
	_config = _resolve_config()
	if _config.is_empty():
		return
	_configure_stats()


func _configure_stats() -> void:
	var average_level := int(
		_config.get("level", clampi(int(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, 1)), 1, 85))
	)
	var level_step := ceili(float(average_level) / 10.0)
	is_boss = bool(_config.get("is_boss", true))
	cannot_attract = true
	my_mr_name = str(_config.get("name", "八仙首领"))
	level = average_level
	max_hp = int(_config.get("hp", level_step * level_step * 10000 * (0.4 + average_level * 0.01)))
	hp = max_hp
	attack_in = int(_config.get("attack", 0))
	def = int(_config.get("def", average_level * 4))
	mdef = int(_config.get("mdef", int(float(average_level) / 400.0)))
	crit = int(_config.get("crit", 0))
	miss = int(_config.get("miss", 0))
	lucky = int(_config.get("lucky", 0))
	htarget = int(_config.get("hit", 100))
	toughness = float(_config.get("toughness", 20.0))
	ar = int(_config.get("armor_break", average_level * 3))
	sp = int(_config.get("magic_break", average_level * 3))
	crit_reduce = int(_config.get("crit_reduce", 0))
	speed = float(_config.get("speed", 6.0))
	mysee = int(_config.get("sight", 1000))
	attack_range = int(_config.get("range", 250))
	attack_desire = int(_config.get("attack_desire", 65))
	behit_calmtime = float(_config.get("behit_calmtime", 0.25))
	self_rhp = 0
	add_exp = int(_config.get("exp", 0))
	fall_coin = int(_config.get("coin", 0))
	fall_pro = float(_config.get("drop_rate", 0.0))
	fall_list = Array(_config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(_config.get("independent_drop_list", [])).duplicate(true)
	fall_stone_pro = 0.0
	fall_stone = []
	boss_max_protect = float(_config.get("max_protect", 100.0))
	obj_attack_dict.clear()
	var attacks: Dictionary = _config.get("attacks", {})
	if not attacks.is_empty():
		for attack_name: String in attacks:
			var attack: Dictionary = attacks[attack_name]
			var hurt_back: Array = Array(attack.get("hurt_back", [-2, -1])).duplicate()
			if hurt_back.size() >= 2:
				hurt_back[0] = clampf(float(hurt_back[0]), -2.0, 2.0)
				hurt_back[1] = clampf(float(hurt_back[1]), -1.0, 1.0)
			obj_attack_dict[attack_name] = {
				"power": int(attack.get("power", attack_in)),
				"hurtBack": hurt_back,
				"attackKind": str(attack.get("kind", "physics")),
				"attackInterval": int(attack.get("interval", 999)),
				"hitMaxCount": int(attack.get("max_hits", 99)),
				"HitProtect": int(attack.get("protect", 0)),
			}
	else:
		var powers: Array = _config["powers"]
		var kinds: Array = _config["kinds"]
		var intervals: Array = _config["intervals"]
		for index in range(3):
			var power := average_level * int(powers[index])
			if index == 1:
				power = maxi(average_level * 20 - 150, 1)
			if monster_id == 169 and index == 1:
				power = 0
			if monster_id == 169 and index == 2:
				power = average_level * 5
			obj_attack_dict["hit%d" % (index + 1)] = {
				"power": power,
				"hurtBack": [-6, -5] if index == 0 else ([1, 0] if index == 1 else [-14, -5]),
				"attackKind": str(kinds[index]),
				"attackInterval": int(intervals[index]),
				"hitMaxCount": 99,
				"HitProtect": 0,
			}


func _resolve_config() -> Dictionary:
	var visual: Variant = BOSS_VISUAL_CONFIG.get(monster_id, {})
	var result: Dictionary = (visual as Dictionary).duplicate(true) if visual is Dictionary else {}
	if not _runtime_config.is_empty():
		result.merge(_runtime_config, true)
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_value: Variant = level_node.call("get_level_monster_config", monster_id)
		if level_value is Dictionary and not (level_value as Dictionary).is_empty():
			result.merge(level_value as Dictionary, true)
	return result


func _reset_source_skill_cooldowns() -> void:
	var ranges: Array = _config.get("cooldown_ranges", [[6, 10], [8, 10]])
	skill_1_cd = randi_range(int(ranges[0][0]), int(ranges[0][1]))
	skill_2_cd = randi_range(int(ranges[1][0]), int(ranges[1][1]))


func _configure_visuals() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var state_names: Array[StringName] = [&"wait", &"walk", &"hurt", &"death", &"hit1", &"hit2", &"hit3"]
	for state_name in state_names:
		var animation_name := state_name
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, animation_name in [&"wait", &"walk"])
		frames.set_animation_speed(animation_name, SOURCE_FPS)
		var frame_index := 1
		while ResourceLoader.exists(_body_action_path(state_name, frame_index)):
			var texture := Global.get_cached_texture(_body_action_path(state_name, frame_index)) as Texture2D
			if texture != null:
				if (
					monster_id == 166
					and state_name == &"hit2"
					and texture.get_width() == 250
					and texture.get_height() >= 250
				):
					var monster166_crop := AtlasTexture.new()
					monster166_crop.atlas = texture
					monster166_crop.region = Rect2(0, 0, 250, 250)
					frames.add_frame(animation_name, monster166_crop)

				elif monster_id == 168 and texture.get_width() == 330 and texture.get_height() == 200:
					var monster168_crop := AtlasTexture.new()
					monster168_crop.atlas = texture
					monster168_crop.region = Rect2(40, 0, 250, 200)
					frames.add_frame(animation_name, monster168_crop)
				else:
					frames.add_frame(animation_name, texture)
			frame_index += 1
		if frames.get_frame_count(animation_name) == 0:
			push_error("Missing Eight Immortals body action: Monster_%d/%s" % [monster_id, state_name])
	mr_ani.sprite_frames = frames
	mr_ani.animation = &"wait"

	mr_ani.centered = false
	mr_ani.offset = _body_registration_offset()
	mr_ani.frame = 0


func _body_registration_offset() -> Vector2:
	var wait_texture := Global.get_cached_texture(_body_action_path(&"wait", 1)) as Texture2D
	var registration: Vector2 = BODY_FOOT_OFFSETS.get(monster_id, _config["offset"])

	if monster_id == 166:
		registration.x = -20.0
	if monster_id == 168:
		registration.x = 22.0
	if wait_texture == null:
		return registration
	return registration - Vector2(wait_texture.get_width(), wait_texture.get_height()) * 0.5


func _configure_animation_player() -> void:
	for library_name in mr_player.get_animation_library_list():
		mr_player.remove_animation_library(library_name)
	var library := AnimationLibrary.new()
	var state_names: Array[StringName] = [&"wait", &"walk", &"hurt", &"death", &"hit1", &"hit2", &"hit3"]
	var holds: Array = _config["holds"]
	for index in range(state_names.size()):
		library.add_animation(
			state_names[index],
			_make_state_animation(state_names[index], holds[index], state_names[index] in [&"wait", &"walk"])
		)
	mr_player.add_animation_library(&"", library)


func _make_state_animation(state_name: StringName, frame_holds: Array, loops: bool) -> Animation:
	var animation := Animation.new()
	var duration := 0.0
	for hold in frame_holds:
		duration += float(hold) / SOURCE_FPS
	animation.length = maxf(duration, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if loops else Animation.LOOP_NONE
	var animation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(animation_track, NodePath("MonsterDir/mr_ani:animation"))
	animation.track_insert_key(animation_track, 0.0, state_name)
	animation.value_track_set_update_mode(animation_track, Animation.UPDATE_DISCRETE)
	var offset_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(offset_track, NodePath("MonsterDir/mr_ani:offset"))
	animation.track_insert_key(offset_track, 0.0, _body_animation_offset(state_name))
	animation.value_track_set_update_mode(offset_track, Animation.UPDATE_DISCRETE)
	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, NodePath("MonsterDir/mr_ani:frame"))
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	var elapsed := 0.0
	for frame_index in range(frame_holds.size()):
		var visual_frame_index := frame_index

		if monster_id == 163 and state_name == &"hit3" and frame_index == 2:
			visual_frame_index = 1
		animation.track_insert_key(frame_track, elapsed, visual_frame_index)
		elapsed += float(frame_holds[frame_index]) / SOURCE_FPS
	return animation


func _body_animation_offset(state_name: StringName) -> Vector2:
	return _body_registration_offset()


func ai_think() -> void:
	if _skill_busy or Time.get_ticks_msec() < _attack_recovery_until_msec or hp <= 0 or RoleProp.source_player == null:
		return
	var target := RoleProp.source_player as Node2D
	if target == null:
		return

	var horizontal_distance := absf(global_position.x - target.global_position.x)
	has_target = horizontal_distance < mysee
	if not has_target:
		_combat_range_latched = false
		normal_state()
		return
	if is_ice or is_sleep or is_stun or is_immobilize or islljy or cannotchangestatewhenattorbeatt():
		return
	if not _is_standing_on_boat():
		return
	if skill_1_cd <= 0 and horizontal_distance < 600.0:
		_use_attack(&"hit2", 0)
	elif skill_2_cd <= 0 and horizontal_distance < 600.0:
		_use_attack(&"hit3", 1)
	elif not _combat_range_latched and horizontal_distance <= float(attack_range):
		_combat_range_latched = true
		stop_move()
	elif _combat_range_latched and horizontal_distance > float(attack_range) + ATTACK_RANGE_HYSTERESIS:
		_combat_range_latched = false
		have_target()
	elif not _combat_range_latched:
		have_target()
	elif count % 45 == 0:
		attack_target()
	else:
		stop_move()


func _is_standing_on_boat() -> bool:
	if is_on_floor() or is_fly:
		return true

	var level_node := get_level_node()
	return level_node != null and level_node.get_node_or_null("stage501Boat") != null


func attack_target() -> void:
	_use_attack(&"hit1", -1)


func _use_attack(action: StringName, cooldown_index: int) -> void:
	if _skill_busy or hp <= 0:
		return
	_skill_busy = true
	to_hero()
	velocity.x = 0.0
	hit_name = String(action)
	is_attacking = true
	if cooldown_index >= 0:
		var cooldown_ranges: Array = _config.get("cooldown_ranges", [[6, 10], [8, 10]])
		var cooldown_range: Array = cooldown_ranges[cooldown_index]
		if cooldown_index == 0:
			skill_1_cd = randi_range(int(cooldown_range[0]), int(cooldown_range[1]))
		else:
			skill_2_cd = randi_range(int(cooldown_range[0]), int(cooldown_range[1]))
	mr_player.play(action)
	var action_length := _action_length(action)
	_drive_source_attack_movement(action, action_length)
	await _cast_source_action(action)
	if not is_inside_tree() or hp <= 0:
		is_attacking = false
		_skill_busy = false
		return
	await get_tree().create_timer(maxf(action_length - _source_trigger_time(action), 0.05), false).timeout
	if not is_inside_tree() or hp <= 0:
		is_attacking = false
		_skill_busy = false
		return
	is_attacking = false
	_skill_busy = false
	_attack_recovery_until_msec = Time.get_ticks_msec() + 180
	stop_move()


func _cast_source_action(action: StringName) -> void:
	var trigger_time := _source_trigger_time(action)

	if trigger_time > 0.0:
		await get_tree().create_timer(trigger_time, false).timeout
	if hp <= 0 or not is_inside_tree():
		return
	match monster_id:
		163:
			_cast_163(action)
		164:
			_cast_164(action)
		165:
			_cast_165(action)
		166:
			_cast_166(action)
		168:
			_cast_168(action)
		169:
			_cast_169(action)
		174:
			_cast_174(action)
		175:
			_cast_175(action)


func _source_trigger_time(action: StringName) -> float:
	var source_frames := {
		163: {&"hit1": 4.0, &"hit2": 4.0, &"hit3": 2.0},
		164: {&"hit1": 4.0, &"hit2": 4.0, &"hit3": 2.0},
		165: {&"hit1": 6.0, &"hit2": 0.0, &"hit3": 4.0},
		166: {&"hit1": 4.0, &"hit2": 6.0, &"hit3": 2.0},
		168: {&"hit1": 6.0, &"hit2": 0.0, &"hit3": 6.0},
		169: {&"hit1": 4.0, &"hit2": 2.0, &"hit3": 0.0},
		174: {&"hit1": 4.0, &"hit2": 6.0, &"hit3": 4.0},
		175: {&"hit1": 4.0, &"hit2": 2.0, &"hit3": 2.0},
	}
	return float(source_frames.get(monster_id, {}).get(action, 1.0)) / SOURCE_FPS


func _cast_163(action: StringName) -> void:
	if action == &"hit1":
		_fire(action, 20, _at_facing(50.0), {})
	elif action == &"hit2":
		_fire(action, 25, global_position + Vector2(0, -250), {})
	else:
		_fire(action, 1, global_position, {"follow_owner": true, "lifetime": 34.0 / SOURCE_FPS})
		velocity.x = _facing_sign() * 10.0 * SOURCE_FPS


func _cast_164(action: StringName) -> void:
	if action == &"hit1":
		_fire(action, 15, _at_facing(40.0), {})
	elif action == &"hit2":
		await _cast_164_rain()
	else:
		_start_164_pull()


func _cast_165(action: StringName) -> void:
	if action == &"hit1":
		_fire(action, 15, _at_facing(70.0, -20.0), {})
	elif action == &"hit2":
		_cast_165_sleep()
	else:
		for offset in [-225.0, -75.0, 75.0, 225.0]:
			_fire(action, 6, global_position + Vector2(offset * SOURCE_X_SCALE, 0), {"right": false})


func _cast_166(action: StringName) -> void:
	if action == &"hit1":
		_fire(action, 20, _at_facing(10.0, -15.0), {})
	elif action == &"hit2":
		await _cast_166_wind()
	else:
		_fire(
			action,
			20,
			global_position,
			{
				"right": false,
				"follow_owner": true,
				"hold_last_frame": true,
				"visual_offset": HAN_ZHONGLI_SHIELD_VISUAL_OFFSET,
				"remove_blue_background": true,
				"blue_background_threshold": 0.75,
				"blue_background_feather": 0.15,
				"lifetime": 8.0,
				"damage_duration": 8.0
			}
		)
		_start_full_invulnerability(8.0)


func _cast_168(action: StringName) -> void:
	if action == &"hit1":
		_fire(action, 21, _at_facing(40.0), {})
	elif action == &"hit2":
		_cast_168_multi()
	else:
		_fire(action, 30, global_position + Vector2(0, 30), {})


func _cast_169(action: StringName) -> void:
	if action == &"hit1":
		_fire(action, 50, _at_facing(50.0), {})
	elif action == &"hit2":
		_start_absorb_state()
	else:
		_fire(action, 50, _at_facing(50.0, -10.0), {})


func _cast_174(action: StringName) -> void:
	if action == &"hit1":
		_fire(action, 20, _at_facing(30.0), {})
	elif action == &"hit2":
		_fire(action, 35, _at_facing(30.0), {})
	else:
		var target := RoleProp.source_player as Node2D
		if target != null:
			_fire(action, 26, Vector2(target.global_position.x, _source_world_y(250.0)), {})


func _cast_175(action: StringName) -> void:
	if action == &"hit1":
		_fire(action, 20, _at_facing(30.0), {})
	elif action == &"hit2":
		_start_absorb_state()
	else:
		_cast_175_returning()


func _fire(
	action: StringName, frame_count: int, spawn_position: Vector2, options: Dictionary
) -> WutaiMinghaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var attack_data: Dictionary = obj_attack_dict.get(String(action), {})
	var visual_offset_value: Variant = options.get("visual_offset", Vector2.ZERO)
	var resolved_visual_offset := visual_offset_value as Vector2 if visual_offset_value is Vector2 else Vector2.ZERO
	var registration_value: Variant = options.get("visual_registration", _skill_visual_registration(action))
	var resolved_registration := registration_value as Vector2 if registration_value is Vector2 else Vector2.ZERO
	var facing_right := bool(options.get("right", monster_dir.scale.x < 0.0))
	var configured := (
		projectile
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": facing_right,
				"hit_name": String(action),
				"attack_data": attack_data,
				"skill_name": "EightImmortals%d%s" % [monster_id, String(action).capitalize()],
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_asset_id":
				FrameSequenceStore.directory_asset_id(str(options.get("frame_root", _effect_root(action)))),
				"frame_count": frame_count,
				"frame_fps": SOURCE_FPS,
				"loop_visual": bool(options.get("loop_visual", false)),
				"hold_last_frame": bool(options.get("hold_last_frame", false)),
				"visual_faces_right": false,
				"visual_offset": resolved_visual_offset,
				"visual_registration": resolved_registration,
				"remove_blue_background": bool(options.get("remove_blue_background", false)),
				"blue_background_threshold": float(options.get("blue_background_threshold", 0.8)),
				"blue_background_feather": float(options.get("blue_background_feather", 0.08)),
				"velocity": options.get("velocity", Vector2.ZERO),
				"acceleration": options.get("acceleration", Vector2.ZERO),
				"follow_owner": bool(options.get("follow_owner", false)),
				"damage_enabled":
				bool(options.get("damage_enabled", not attack_data.is_empty())) and not attack_data.is_empty(),
				"damage_duration": float(options.get("damage_duration", maxf(float(frame_count) / SOURCE_FPS, 0.15))),
				"lifetime": float(options.get("lifetime", maxf(float(frame_count) / SOURCE_FPS, 0.25))),
				"max_distance": float(options.get("max_distance", 0.0)),
				"collision_offset": options.get("collision_offset", resolved_visual_offset + resolved_registration),
				"hit_interval": float(attack_data.get("attackInterval", 999)) / SOURCE_FPS,
				"damage_pulse_interval": float(attack_data.get("attackInterval", 999)) / SOURCE_FPS,
				"poll_overlaps_on_damage_pulse": true,
				"max_hits": int(attack_data.get("hitMaxCount", 99)),
				"expire_on_hit": false,
				"finished_callback": options.get("finished_callback", Callable()),
				"hit_callback": options.get("hit_callback", Callable()),
			}
		)
	)
	if not configured:
		projectile.free()
		return null
	bullet.add_child(projectile)
	return projectile


func _at_facing(x_offset: float, y_offset: float = 0.0) -> Vector2:
	return global_position + Vector2(x_offset * SOURCE_X_SCALE * _facing_sign(), y_offset)


func _facing_sign() -> float:
	return 1.0 if monster_dir.scale.x < 0.0 else -1.0


func _skill_visual_registration(action: StringName) -> Vector2:
	var source_value: Variant = SKILL_VISUAL_REGISTRATIONS.get(monster_id, {})
	var source_map: Dictionary = source_value if source_value is Dictionary else {}
	var value: Variant = source_map.get(action, Vector2.ZERO)
	return value as Vector2 if value is Vector2 else Vector2.ZERO


func _source_world_y(source_y: float) -> float:
	var level_node := get_level_node()
	var boat := level_node.get_node_or_null("stage501Boat") if level_node != null else null
	var collision := boat.get_node_or_null("CollisionShape2D") as CollisionShape2D if boat != null else null
	if collision != null and collision.shape != null:
		return collision.global_position.y - collision.shape.get_rect().size.y * 0.5 + source_y - 500.0
	return source_y


func _cast_164_rain() -> void:
	var hits := randi_range(1, 3)
	for index in range(hits):
		var target := RoleProp.source_player as Node2D
		if target != null:
			_fire(
				&"hit2",
				15,
				Vector2(target.global_position.x + randf_range(-60.0, 60.0) * SOURCE_X_SCALE, _source_world_y(500.0)),
				{"right": false}
			)
		if index + 1 < hits:
			await get_tree().create_timer(0.5, false).timeout


func _cast_165_sleep() -> void:
	_fire(&"hit2", 1, global_position, {"damage_enabled": false})
	var targets := _active_pet_targets()
	if targets.is_empty():
		var player := RoleProp.source_player as BaseHero
		if player != null:
			targets.append(player)
	var sleep_damage := maxi(1, (level * 20 - 150) / 4)
	for target in targets:
		_apply_165_sleep(target, sleep_damage)


func _cast_166_wind() -> void:
	var start_x := global_position.x
	for index in range(4):
		_fire(
			&"hit2",
			10,
			Vector2(start_x + 40.0 * SOURCE_X_SCALE * _facing_sign(), _source_world_y(500.0)),
			{
				"right": false,
				"velocity": Vector2(10.0 * SOURCE_FPS * _facing_sign(), 0),
				"max_distance": 500.0,
				"lifetime": 1.5
			}
		)
		if index < 3:
			await get_tree().create_timer(0.3, false).timeout


func _cast_168_multi() -> void:
	_fire(&"hit2", 25, global_position, {})


func _cast_175_returning() -> void:
	var sign := _facing_sign()
	for side in [sign, -sign]:
		var projectile := _fire(
			&"hit3",
			1,
			global_position + Vector2(20.0 * SOURCE_X_SCALE * side, 0),
			{
				"velocity": Vector2(30.0 * SOURCE_FPS * side, 0),
				"acceleration": Vector2(-1.0 * SOURCE_FPS * SOURCE_FPS * side, 0),
				"max_distance": 9999.0,
				"lifetime": 12.0,
				"hit_callback": _heal_from_175_hit
			}
		)
		_drive_175_returning(projectile, side)


func _heal_from_175_hit(_projectile: Node, hit_role: BaseHero) -> void:
	if hit_role != null:
		cure_hp(maxi(1, int(obj_attack_dict["hit3"].get("power", 1))))


func _start_164_pull() -> void:
	var effect_position := Vector2(randf_range(150.0, 800.0) * SOURCE_X_SCALE, _source_world_y(500.0))
	var projectile := _fire(
		&"hit3", 150, effect_position, {"lifetime": 150.0 / SOURCE_FPS, "damage_duration": 150.0 / SOURCE_FPS}
	)
	_drive_164_pull(projectile)


func _drive_164_pull(projectile: WutaiMinghaiProjectile) -> void:
	while is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
		for player in _active_players():
			if player.global_position.distance_to(projectile.global_position) > 450.0 * SOURCE_X_SCALE:
				continue
			var pull_direction := signf(projectile.global_position.x - player.global_position.x)
			if is_zero_approx(pull_direction):
				continue

			player.velocity.x = pull_direction * (72.0 if player.is_on_floor() else 144.0)
		await get_tree().physics_frame
	for player in _active_players():
		player.velocity.x = 0.0


func _active_players() -> Array[BaseHero]:
	var players: Array[BaseHero] = []
	var candidate: Variant = RoleProp.source_player
	if candidate is BaseHero and is_instance_valid(candidate) and not candidate.is_death:
		players.append(candidate)
	return players


func _active_pet_targets() -> Array[Node]:
	var targets: Array[Node] = []
	var level_node := get_level_node()
	if level_node == null:
		return targets
	var monster_node := level_node.get("monster") as Node
	if monster_node == null:
		return targets
	for child in monster_node.get_children():
		if child.is_queued_for_deletion() or (not child.has_node("Buff") and not child.has_node("buff")):
			continue
		if (
			bool(child.get_meta("pet_tiger_unit", false))
			or bool(child.get_meta("pet_dragon_unit", false))
			or bool(child.get_meta("pet_phoenix_unit", false))
			or bool(child.get_meta("pet_turtle_unit", false))
			or bool(child.get_meta("pet_rabbit_unit", false))
			or bool(child.get_meta("pet_mouse_unit", false))
			or bool(child.get_meta("pet_neat_unit", false))
		):
			targets.append(child)
	return targets


func _apply_165_sleep(target: Node, sleep_damage: int) -> void:
	var buff_node := target.get_node_or_null("Buff")
	if buff_node == null:
		buff_node = target.get_node_or_null("buff")
	if buff_node == null:
		return
	Global.add_buff(
		buff_node,
		{
			"Name": "Immobilize",
			"AddTime": 4.0,
			"value": 0.0,
			"reduce_interval": 0.0,
			"CanRemove": true,
			"CanAdd": false,
			"DeBuff": true
		}
	)
	Global.add_buff(
		buff_node,
		{
			"Name": "hanxiangzisleep",
			"AddTime": 4.0,
			"value": sleep_damage,
			"reduce_interval": 1.0,
			"CanRemove": true,
			"CanAdd": false,
			"DeBuff": true
		}
	)


func _drive_175_returning(projectile: WutaiMinghaiProjectile, outward_direction: float) -> void:
	var is_returning := false
	var return_speed := 0.0
	while is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
		if not is_returning and projectile.motion_velocity.x * outward_direction <= 0.0:
			is_returning = true
			projectile.motion_velocity = Vector2.ZERO
			projectile.motion_acceleration = Vector2.ZERO
		if is_returning:
			if (
				not is_instance_valid(self)
				or hp <= 0
				or projectile.global_position.distance_to(global_position) <= 30.0
			):
				projectile.queue_free()
				return
			return_speed += SOURCE_FPS
			projectile.motion_velocity = projectile.global_position.direction_to(global_position) * return_speed
		await get_tree().create_timer(1.0 / SOURCE_FPS, false).timeout


func _start_absorb_state() -> void:
	_absorb_active = true
	is_indestructible = true
	var absorb_time := 5.0

	_fire(
		&"hit2",
		100,
		global_position,
		{
			"frame_asset_id": "dir/monster/game_3_monster/monster_169/hit2",
			"loop_visual": false,
			"hold_last_frame": true,
			"follow_owner": true,
			"visual_offset": HE_XIANGU_ABSORB_FOOT_VISUAL_OFFSET,
			"damage_enabled": false,
			"remove_black_background": true,
			"black_background_threshold": 0.14,
			"black_background_feather": 0.05,
			"lifetime": absorb_time,
		}
	)
	var state_token := Time.get_ticks_msec()
	set_meta("eight_immortals_absorb_token", state_token)
	call_deferred("_finish_absorb_state", state_token, absorb_time)


func _finish_absorb_state(state_token: int, absorb_time: float) -> void:
	await get_tree().create_timer(absorb_time, false).timeout
	if is_inside_tree() and int(get_meta("eight_immortals_absorb_token", -1)) == state_token:
		_absorb_active = false
		is_indestructible = false


func _start_full_invulnerability(duration: float) -> void:
	_full_invulnerability_active = true
	call_deferred("_finish_full_invulnerability", duration)


func _finish_full_invulnerability(duration: float) -> void:
	await get_tree().create_timer(duration, false).timeout
	if is_inside_tree():
		_full_invulnerability_active = false


func reduce_hp(value: int):
	if _full_invulnerability_active:
		return 0
	if _absorb_active:
		cure_hp(maxi(value, 0))
		return 0
	return super.reduce_hp(value)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if _full_invulnerability_active:
		return
	super._on_hurt_box_area_entered(area)


func resolve_friendly_damage(base_damage: int, attack_kind: String, attacker: Node = null) -> int:
	if _full_invulnerability_active:
		return 0
	return super.resolve_friendly_damage(base_damage, attack_kind, attacker)


func receive_friendly_damage(base_damage: int, attack_kind: String, attacker: Node = null) -> int:
	if _full_invulnerability_active:
		return 0
	if _absorb_active:
		var resolved := super.resolve_friendly_damage(base_damage, attack_kind, attacker)
		cure_hp(resolved)
		return 0
	return super.receive_friendly_damage(base_damage, attack_kind, attacker)


func receive_reflected_damage(base_damage: int, attack_kind: String, penetration: int = 0) -> int:
	if _full_invulnerability_active:
		return 0
	if _absorb_active:
		cure_hp(base_damage)
		return 0
	return super.receive_reflected_damage(base_damage, attack_kind, penetration)


func reduce_pet_hp(value: int, attack_kind: String) -> int:
	if _full_invulnerability_active:
		return 0
	if _absorb_active:
		cure_hp(value)
		return 0
	return super.reduce_pet_hp(value, attack_kind)


func hd_reduce(value):
	if _full_invulnerability_active:
		return 0
	if _absorb_active:
		cure_hp(int(value))
		return 0
	return super.hd_reduce(value)


func hurt_reduce_hp(value, target):
	if _full_invulnerability_active:
		_try_stun_166_attacker(target)
		return 0
	if _absorb_active:
		cure_hp(maxi(int(value), 0))
		return 0
	return super.hurt_reduce_hp(value, target)


func _drive_source_attack_movement(action: StringName, action_length: float) -> void:
	if not _source_action_allows_movement(action):
		return
	var movement_end := Time.get_ticks_msec() + int(action_length * 1000.0)
	while is_inside_tree() and _skill_busy and hit_name == String(action) and Time.get_ticks_msec() < movement_end:
		match monster_id:
			163:
				velocity.x = _facing_sign() * 10.0 * SOURCE_FPS

			168:
				pass

			_:
				pass
		await get_tree().physics_frame


func _source_action_allows_movement(action: StringName) -> bool:
	match monster_id:
		163:
			return action == &"hit3"
		168:
			return action == &"hit2"
	return false


func _try_stun_166_attacker(target: Variant) -> void:
	if monster_id != 166 or not _full_invulnerability_active:
		return
	if randf() >= 0.6:
		return
	var attacker := _resolve_attacker_hero(target)
	if attacker == null or attacker.is_death:
		return
	(
		Global
		. add_buff(
			attacker.buff,
			{
				"Name": "stun",
				"AddTime": 1.0,
				"value": 0.0,
				"reduce_interval": 0.0,
				"CanRemove": true,
				"CanAdd": true,
				"DeBuff": true,
			}
		)
	)


func _resolve_attacker_hero(target: Variant) -> BaseHero:
	var node := target as Node
	while node != null:
		if node is BaseHero:
			return node as BaseHero
		node = node.get_parent()
	var source_player := RoleProp.source_player as BaseHero
	return source_player


func _action_length(action: StringName) -> float:
	var animation := mr_player.get_animation(action)
	return animation.length if animation != null else 0.3


func _body_action_path(action: StringName, index: int) -> String:
	return "res://Art/monster/game_3_monster/monster_%d/body_actions/%s/%d.png" % [monster_id, String(action), index]


func _effect_root(action: StringName) -> String:
	return "res://Art/monster/game_3_monster/monster_%d/%s" % [monster_id, String(action)]

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

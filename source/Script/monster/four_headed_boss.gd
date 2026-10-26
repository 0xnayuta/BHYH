extends BaseMonster
class_name FourHeadedBoss

const ROOT := "res://Art/monster/swf_png/3034"
const SOURCE_FPS := 24.0
const HURT_REACTION_DURATION := 0.334
const SKILL2_DASH_SPEED := 240.0
const SKILL2_DASH_DURATION := 0.8
const SKILL2_HIT_COUNT := 6
const SKILL2_HIT_INTERVAL := 0.134
const HEAD_ROOTS := [
	"res://Art/monster/swf_png/3048",
	"res://Art/monster/swf_png/3050",
	"res://Art/monster/swf_png/3051",
]
const HEAD_OFFSETS := [
	{
		&"wait": Vector2(-32.45, -101.4),
		&"walk": Vector2(-31.75, -102.1),
		&"hurt": Vector2(-52.85, -89.4),
		&"death": Vector2(-60.6, -28.5),
		&"skill1": Vector2(-24.0, -89.0),
		&"skill2": Vector2(-30.25, -91.85),
		&"skill3": Vector2(-29.25, -100.2),
		&"skill4": Vector2(-28.1, -84.7),
	},
	{
		&"wait": Vector2(-23.8, -123.5),
		&"walk": Vector2(-23.2, -124.8),
		&"hurt": Vector2(-51.15, -114.5),
		&"death": Vector2(-79.5, -43.4),
		&"skill1": Vector2(-25.7, -112.6),
		&"skill2": Vector2(-29.2, -113.6),
		&"skill3": Vector2(-21.3, -122.6),
		&"skill4": Vector2(-35.3, -110.6),
	},
	{
		&"wait": Vector2(-0.3, -119.85),
		&"walk": Vector2(3.3, -119.15),
		&"hurt": Vector2(-26.1, -118.2),
		&"death": Vector2(-67.65, -59.15),
		&"skill1": Vector2(-1.2, -109.15),
		&"skill2": Vector2(-2.55, -115.7),
		&"skill3": Vector2(4.2, -116.95),
		&"skill4": Vector2(-10.6, -109.45),
	},
]

signal skill2_dash_completed

const ACTIONS := {
	&"wait": {"folder": "wait", "frames": 20, "offset": Vector2(32.1, -55.45), "loop": true},
	&"walk": {"folder": "walk", "frames": 16, "offset": Vector2(33.0, -55.35), "loop": true},
	&"hurt": {"folder": "hurt", "frames": 35, "offset": Vector2(-8.75, -63.25), "loop": false},
	&"death": {"folder": "death", "frames": 35, "offset": Vector2(-3.15, -22.5), "loop": false},
	&"skill1": {"folder": "effect1", "frames": 45, "offset": Vector2(49.9, -83.0), "loop": false},
	&"skill2": {"folder": "effect2", "frames": 42, "offset": Vector2(39.1, -53.15), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 39, "offset": Vector2(33.2, -52.2), "loop": false},
	&"skill4": {"folder": "effect4", "frames": 35, "offset": Vector2(16.0, -75.8), "loop": false},
}

var monster_kind := 3034
static var _frames_cache: SpriteFrames

var _heads: Array = []
var _remaining_heads := 3
var _busy := false
var _death_started := false
var _attack_serial := 0
var _skill_cycle := 0
var _next_attack_msec := 0
var _head_alive: Array[bool] = [true, true, true]
var _skill2_dash_active := false
var _skill2_dash_time_left := 0.0
var _skill2_dash_direction := 0.0
var _skill2_damage_active := false
var _skill_direction := -1.0
var _runtime_config: Dictionary = {}


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_boss()
	_build_animations()
	_create_heads()
	super._ready()


func _configure_boss() -> void:
	var config := _runtime_config
	my_mr_name = str(config.get("name", "四头虫"))
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
	mysee = int(config.get("sight", 0))
	attack_range = roundi(float(config.get("range", 0.0)))
	attack_desire = int(config.get("attack_desire", 0))
	add_exp = int(config.get("exp", 0))
	fall_coin = int(config.get("coin", 0))
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config.get("is_boss", true))
	boss_max_protect = float(config.get("max_protect", 100.0))
	obj_attack_dict.clear()
	var attacks: Dictionary = config.get("attacks", {})
	for attack_name: String in attacks:
		obj_attack_dict[attack_name] = _attack_data(attacks[attack_name])


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("FourHeadedBoss requires Level_54 LEVEL_54_MONSTER_DATA entry 3034")
	return {}


func _attack_data(attack: Dictionary) -> Dictionary:
	return {
		"power": roundi(float(attack_in) * float(attack.get("multiplier", 0.0))),
		"hurtBack": Array(attack.get("hurt_back", [0, 0])).duplicate(),
		"attackKind": str(attack.get("kind", "physics")),
		"HitProtect": int(attack.get("protect", 0)),
	}


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


static func prewarm_frames() -> void:
	_load_standard_frames()
	for i in range(3):
		_get_head_frames(i)


static func prewarm_effects() -> void:
	pass


static var _head_frames_cache: Array = [null, null, null]


static func _get_head_frames(index: int) -> SpriteFrames:
	if _head_frames_cache.has(index):
		return _head_frames_cache[index] as SpriteFrames
	var head_models := [3048, 3050, 3051]
	var head_model: int = head_models[index]
	var frames_path := "res://Art/monster/swf_png/%d/atlas/swf_png_%d_frames.tres" % [head_model, head_model]
	if not ResourceLoader.exists(frames_path):
		return null
	var frames := load(frames_path) as SpriteFrames
	_head_frames_cache[index] = frames
	return frames


func _create_heads() -> void:
	for index in range(3):
		var h_frames := _get_head_frames(index)
		if h_frames != null:
			var head := AnimatedSprite2D.new()
			head.name = "FollowerHead%d" % (index + 1)
			head.sprite_frames = h_frames
			head.centered = true
			head.flip_h = false
			head.z_index = -1
			head.position = HEAD_OFFSETS[index][&"wait"]
			head.play(&"wait")
			monster_dir.add_child(head)
			_heads.append(head)


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3034_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames


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
		if action_name == &"hurt":
			animation.length = HURT_REACTION_DURATION
		match action_name:
			&"skill1":
				_add_attack_window(animation, 7, 15, &"hit1", Vector2(230.0, 206.0), Vector2(62.75, -95.25))
				_add_attack_window(animation, 22, 30, &"hit1", Vector2(301.0, 124.0), Vector2(95.25, -56.5))
				_add_attack_window(animation, 37, 45, &"hit1", Vector2(252.0, 206.0), Vector2(21.75, -87.25))
			&"skill2":
				_add_method_key(animation, _frame_time(12), &"_start_blood_spike_dash")
				_add_method_key(animation, _frame_time(24), &"_stop_blood_spike_damage")
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


func _add_attack_window(
	animation: Animation, start_frame: int, end_frame: int, attack_name: StringName, size: Vector2, offset: Vector2
) -> void:
	_add_method_key(animation, _frame_time(start_frame), &"_enable_sized_attack_box", [attack_name, size, offset])
	_add_method_key(animation, _frame_time(end_frame), &"_disable_attack_box")


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
		_sync_heads(action_name)


func _sync_heads(action_name: StringName) -> void:
	var looped := bool(ACTIONS.get(action_name, ACTIONS[&"wait"])["loop"])
	for index in range(_heads.size()):
		if _head_alive[index]:
			_replace_head_action(index, action_name, looped)


func _replace_head_action(index: int, action_name: StringName, _looped: bool) -> void:
	var head = _heads[index]
	if head is AnimatedSprite2D:
		head.position = HEAD_OFFSETS[index].get(action_name, HEAD_OFFSETS[index][&"wait"])
		head.play(action_name)


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
		have_target()
		_face_role()
		return
	_start_skill(skill_index)


func _next_usable_skill(distance: float) -> int:
	var skill_ranges: Dictionary = _runtime_config.get("skill_ranges", {})
	for step in range(2):
		var candidate := ((_skill_cycle + step) % 2) + 1
		var fallback_range := 145.0 if candidate == 1 else 420.0
		if distance <= float(skill_ranges.get(candidate, fallback_range)):
			return candidate
	return 0


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_skill_cycle = skill_index % 2
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	_face_role()
	hit_name = "hit%d" % skill_index
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	if skill_index == 2 and _skill2_dash_active:
		await skill2_dash_completed
		if not is_instance_valid(self) or death() or serial != _attack_serial:
			return
	_disable_attack_box()
	_busy = false
	is_attacking = false
	_next_attack_msec = Time.get_ticks_msec() + 1000
	mr_player.play(&"wait")


func _enable_attack_box(attack_name: StringName) -> void:
	hit_name = str(attack_name)
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _enable_sized_attack_box(attack_name: StringName, size: Vector2, offset: Vector2) -> void:
	if hit_box != null:
		var shape := RectangleShape2D.new()
		shape.size = size
		hit_box.shape = shape
		hit_box.position = offset
	_enable_attack_box(attack_name)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _start_blood_spike_dash() -> void:
	if death() or _skill2_dash_active:
		return
	if hit_box != null:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(258.0, 161.0)
		hit_box.shape = shape
		hit_box.position = Vector2(66.5, -53.0)
	_skill2_dash_active = true
	_skill2_damage_active = true
	_skill2_dash_time_left = SKILL2_DASH_DURATION
	_skill2_dash_direction = _facing_sign()
	velocity.x = SKILL2_DASH_SPEED * _skill2_dash_direction
	_run_skill2_hit_pulses(_attack_serial)


func _run_skill2_hit_pulses(serial: int) -> void:
	var first_pulse_msec := Time.get_ticks_msec()
	for pulse_index in range(SKILL2_HIT_COUNT):
		if death() or serial != _attack_serial or not _skill2_damage_active:
			return
		_enable_attack_box(&"hit2")
		await get_tree().physics_frame
		if not is_instance_valid(self) or serial != _attack_serial or not _skill2_damage_active:
			return
		await get_tree().physics_frame
		if not is_instance_valid(self) or serial != _attack_serial:
			return
		_disable_attack_box()
		if pulse_index + 1 < SKILL2_HIT_COUNT:
			var next_pulse_msec := first_pulse_msec + roundi(float(pulse_index + 1) * SKILL2_HIT_INTERVAL * 1000.0)
			var wait_seconds := float(next_pulse_msec - Time.get_ticks_msec()) / 1000.0
			if wait_seconds > 0.0:
				await get_tree().create_timer(wait_seconds, false).timeout


func _stop_blood_spike_damage() -> void:
	_skill2_damage_active = false
	_disable_attack_box()


func _finish_skill2_dash() -> void:
	if not _skill2_dash_active:
		return
	_skill2_dash_active = false
	_stop_blood_spike_damage()
	_skill2_dash_time_left = 0.0
	velocity.x = 0.0
	_disable_attack_box()
	skill2_dash_completed.emit()


func _facing_sign() -> float:
	return _skill_direction


func _face_role() -> void:
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	_skill_direction = (
		1.0 if float(RoleProp.get_nearest_monster_target_position(global_position).x) >= global_position.x else -1.0
	)
	monster_dir.scale.x = _skill_direction
	base_damage_box.scale.x = _skill_direction


func _physics_process(delta: float) -> void:
	if hp <= 0 and not _death_started:
		if _remaining_heads > 0:
			_sacrifice_head()
		else:
			state_death()
	if _skill2_dash_active and not death():
		velocity.x = SKILL2_DASH_SPEED * _skill2_dash_direction
	super._physics_process(delta)
	if _skill2_dash_active:
		_skill2_dash_time_left -= delta
		if death() or _skill2_dash_time_left <= 0.0:
			_finish_skill2_dash()


func _sacrifice_head() -> void:
	if _busy and hp > 0:
		return
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	_finish_skill2_dash()
	hp = max_hp
	is_death = false
	var head_index := 3 - _remaining_heads
	_remaining_heads -= 1
	if head_index >= 0 and head_index < _heads.size():
		_replace_head_action(head_index, &"death", false)
		_head_alive[head_index] = false
	_disable_attack_box()
	mr_player.play(&"skill4")
	await mr_player.animation_finished
	if death() or _death_started or serial != _attack_serial:
		return
	_busy = false
	is_attacking = false
	_next_attack_msec = Time.get_ticks_msec() + 1000
	mr_player.play(&"wait")


func _resolve_lethal_head() -> void:
	if hp <= 0 and not _death_started and _remaining_heads > 0:
		_sacrifice_head()


func hurt_reduce_hp(value, target):
	var result = super.hurt_reduce_hp(value, target)
	_resolve_lethal_head()
	return result


func reduce_hp(value: int):
	var result = super.reduce_hp(value)
	_resolve_lethal_head()
	return result


func reduce_pet_hp(value: int, attack_kind: String) -> int:
	var result := super.reduce_pet_hp(value, attack_kind)
	_resolve_lethal_head()
	return result


func is_alive_for_stage_clear() -> bool:
	return not death()


func death():
	return hp <= 0 and _remaining_heads <= 0


func state_hurt() -> void:
	if death() or is_control_immune():
		return
	_attack_serial += 1
	_finish_skill2_dash()
	_busy = true
	is_attacking = false
	await super.state_hurt()
	if not is_instance_valid(self) or death() or _death_started:
		return
	_busy = false
	mr_player.play(&"wait")


func _finish_hurt_reaction(hurt_generation: int) -> void:
	super._finish_hurt_reaction(hurt_generation)
	velocity.x = 0.0


func state_death() -> void:
	if _death_started:
		return
	if _remaining_heads > 0:
		_sacrifice_head()
		return
	_death_started = true
	_attack_serial += 1
	_busy = true
	_finish_skill2_dash()
	_disable_attack_box()
	no_grav = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()


func get_ice_effect_offset() -> Vector2:
	return Vector2(0.0, -110.0)


func _exit_tree() -> void:
	for head in _heads:
		if head != null and is_instance_valid(head) and head.has_method("clear_texture"):
			head.clear_texture()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

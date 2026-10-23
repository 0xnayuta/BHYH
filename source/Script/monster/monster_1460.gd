extends BaseMonster

const FRAME_ROOT := "res://Art/monster/tongtian_3057"
const BODY_FRAMES_RES := FRAME_ROOT + "/atlas/tongtian_3057_frames.tres"
static var _body_frames_resource: SpriteFrames = null
const SOURCE_FPS := 30.0
const HURT_RECOVERY_SECONDS := 8.0 / SOURCE_FPS
const SOURCE_WALK_SPEED := 50.0
const PATROL_VIEW_RANGE := 470.0
const SEEK_VIEW_RANGE := 940.0
const VERTICAL_SCOPE := 300.0
const SKILL_1_SCOPE_MIN := 0.0
const SKILL_1_SCOPE_MAX := 150.0
const SKILL_2_SCOPE_MIN := 60.0
const SKILL_2_SCOPE_MAX := 960.0
const SKILL_1_POWER_FACTOR := 300
const SKILL_1_PROJECTILE_POWER_FACTOR := 310
const SKILL_2_POWER_FACTOR := 320
const SKILL_1_PROJECTILE_SPEED_X := 147.0

const SOURCE_SKILL_1_TARGET_MOVE := Vector2(125.0, 66.0)
const SOURCE_SKILL_1_PROJECTILE_TARGET_MOVE := Vector2(21.0, 42.0)
const SOURCE_SKILL_2_TARGET_MOVE := Vector2(240.0, 90.0)
const SKILL_1_SHOTS := [
	[80.0, -56.0, 0.0],
	[85.0, -126.0, -40.0],
	[87.0, -38.0, 40.0],
	[110.0, -67.0, 0.0],
	[102.0, -47.0, 20.0],
]

const SKILL_1_FIRE_TIME := (36.0 - 1.0) / SOURCE_FPS
const SKILL_2_FIRE_TIME := (49.0 - 1.0) / SOURCE_FPS
const SKILL_1_HITBOX_START := (18.0 - 1.0) / SOURCE_FPS
const SKILL_1_HITBOX_END := (26.0 - 1.0) / SOURCE_FPS

const LITTLE_BLOOD_OFFSET := Vector2(-30, -175)
const PROJECTILE_SCENE := preload("res://Scene/monster/monster_bullet_slim/tongtian3057_projectile.tscn")
const BEAM_SCENE := preload("res://Scene/monster/monster_bullet_slim/tongtian3057_beam.tscn")

enum AiPhase {
	OPENING_DELAY,
	APPROACH_SKILL_1,
	WAIT_AFTER_SKILL_1,
	FLEE_AFTER_SKILL_1,
	APPROACH_SKILL_2,
	WAIT_AFTER_SKILL_2,
}

const ANIMATION_DATA := {
	&"wait": ["idle", 20, true, Vector2(-5.25, -66.15)],
	&"walk": ["walk", 16, true, Vector2(-3.25, -68.15)],
	&"hurt": ["hurt", 32, false, Vector2(-39.6, -66.65)],
	&"death": ["dead", 32, false, Vector2(-34.05, -18.95)],
	&"skill_1": ["skill_1", 61, false, Vector2(32.5, -110.1)],
	&"skill_2": ["skill_2", 65, false, Vector2(8.45, -70.55)],
}

var _ai_phase: AiPhase = AiPhase.OPENING_DELAY
var _phase_time_left := 1.0
var _skill_2_range_time_left := 0.0
var _skill_busy := false
var _skill_1_fired := false
var _skill_2_fired := false
var _attack_generation := 0
var _death_started := false
var _skill_super_armor_active := false
var _cannot_attract_before_skill := false
var _body_frames_overlay: AnimatedSprite2D


func _ready() -> void:
	_configure_boss()
	_build_animations()
	super._ready()


func _configure_boss() -> void:
	is_boss = true
	boss_max_protect = 240.0
	my_mr_name = "通天教主"
	attack_in = 70
	level = 90
	max_hp = 17000000
	hp = max_hp
	def = 3227
	mdef = 3227
	crit = 400
	miss = 150
	lucky = 0
	htarget = 2000
	toughness = 0.01
	ar = 500
	sp = 500
	crit_reduce = 0
	speed = 26
	rush_speed = 180.0
	mysee = int(SEEK_VIEW_RANGE)
	attack_range = int(SKILL_1_SCOPE_MAX)
	attack_desire = 100
	behit_calmtime = 0
	add_exp = 0
	fall_coin = 0
	fall_pro = 0.0
	fall_list = []
	independent_fall_list = [
		{"name": "xyzyzzs", "value": 1, "chance": 0.1},
		{"name": "139300016", "value": 1, "chance": 0.1},
	]
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0
	skill_4_cd = 0
	_refresh_attack_powers()


func _refresh_attack_powers() -> void:
	var base_attack := maxf(float(attack_in), 0.0)
	var difficulty_multiplier := _get_difficulty_attack_multiplier()
	obj_attack_dict["skill_1"] = {
		"power": int(round(base_attack * SKILL_1_POWER_FACTOR * difficulty_multiplier)),
		"hurtBack": [-5.0, -4.4],
		"sourceTargetMove": SOURCE_SKILL_1_TARGET_MOVE,
		"sourceStiffSeconds": 0.6,
		"attackKind": "physics",
		"HitProtect": 1667,
	}
	obj_attack_dict["skill_1_projectile"] = {
		"power": int(round(base_attack * SKILL_1_PROJECTILE_POWER_FACTOR * difficulty_multiplier)),
		"hurtBack": [-0.84, -2.8],
		"sourceTargetMove": SOURCE_SKILL_1_PROJECTILE_TARGET_MOVE,
		"sourceStiffSeconds": 0.334,
		"attackKind": "magic",
		"HitProtect": 223,
	}
	obj_attack_dict["skill_2"] = {
		"power": int(round(base_attack * SKILL_2_POWER_FACTOR * difficulty_multiplier)),
		"hurtBack": [-9.6, -6.0],
		"sourceTargetMove": SOURCE_SKILL_2_TARGET_MOVE,
		"sourceStiffSeconds": 0.7,
		"attackKind": "magic",
		"HitProtect": 667,
	}


func _get_difficulty_attack_multiplier() -> float:
	match clampi(int(MainSet.set_data.get("Difficult", 0)), 0, 3):
		1:
			return 2.0
		2:
			return 3.0
		3:
			return 1.0
		_:
			return 1.0


func monster_info_attack_values_include_difficulty() -> bool:
	return int(MainSet.set_data.get("Difficult", 0)) != BaseMonster.NIGHTMARE_DIFFICULTY


func _build_animations() -> void:
	mr_ani.centered = true

	mr_ani.flip_h = true
	mr_ani.visible = false

	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_action(&"wait"))
	library.add_animation(&"walk", _make_action(&"walk"))
	library.add_animation(&"hurt", _make_action(&"hurt"))

	var death_animation := _make_action(&"death")
	_add_method_key(death_animation, death_animation.length - 0.001, &"_finish_death")
	library.add_animation(&"death", death_animation)

	var skill_1_animation := _make_action(&"skill_1")
	_add_method_key(skill_1_animation, SKILL_1_HITBOX_START, &"_enable_skill_1_hitbox")
	_add_method_key(skill_1_animation, SKILL_1_HITBOX_END, &"_disable_attack_hitbox")
	_add_method_key(skill_1_animation, SKILL_1_FIRE_TIME, &"_fire_skill_1_once")
	library.add_animation(&"skill_1", skill_1_animation)

	var skill_2_animation := _make_action(&"skill_2")
	_add_method_key(skill_2_animation, SKILL_2_FIRE_TIME, &"_fire_skill_2_once")
	library.add_animation(&"skill_2", skill_2_animation)
	mr_player.add_animation_library(&"", library)


func _make_action(anim_name: StringName) -> Animation:
	var animation := Animation.new()
	var data: Array = ANIMATION_DATA[anim_name]
	animation.loop_mode = Animation.LOOP_LINEAR if bool(data[2]) else Animation.LOOP_NONE
	var action_duration := float(data[1]) / SOURCE_FPS
	if anim_name == &"hurt":
		action_duration = HURT_RECOVERY_SECONDS
	animation.length = maxf(action_duration, 0.05)
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(method_track, 0.0, {"method": &"_play_sprite_animation", "args": [anim_name]})
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(
		method_track, clampf(time, 0.0, animation.length - 0.001), {"method": method_name, "args": []}
	)


func _play_sprite_animation(anim_name: StringName) -> void:
	_clear_body_stream()
	var data: Array = ANIMATION_DATA[anim_name]
	var source_offset: Vector2 = data[3]
	_setup_body_frames_overlay(anim_name, data, source_offset)


func _physics_process(delta: float) -> void:
	if _skill_busy:
		super_armor_active = true
		cannot_attract = true
	if not _death_started:
		_advance_ai_timers(delta)
	super._physics_process(delta)
	if _skill_busy:
		super_armor_active = true
		cannot_attract = true
	if death() and not _death_started:
		_begin_death()


func is_control_immune() -> bool:
	return _skill_busy or super.is_control_immune()


func _advance_ai_timers(delta: float) -> void:
	if _phase_time_left > 0.0:
		_phase_time_left = maxf(0.0, _phase_time_left - delta)
	if _skill_2_range_time_left > 0.0:
		_skill_2_range_time_left = maxf(0.0, _skill_2_range_time_left - delta)


func _set_phase(next_phase: AiPhase, duration: float = 0.0) -> void:
	_ai_phase = next_phase
	_phase_time_left = maxf(0.0, duration)


func _target_position() -> Vector2:
	var target_x := (
		float(RoleProp.get_nearest_monster_target_position(global_position).x)
		if RoleProp.get_nearest_monster_target_position(global_position).x != null
		else position.x
	)
	var target_y := (
		float(RoleProp.get_nearest_monster_target_position(global_position).y)
		if RoleProp.get_nearest_monster_target_position(global_position).y != null
		else position.y
	)
	return Vector2(target_x, target_y)


func _target_in_vertical_scope(target_position: Vector2) -> bool:
	return absf(target_position.y - position.y) <= VERTICAL_SCOPE


func _skill_1_in_range(horizontal_distance: float, target_position: Vector2) -> bool:
	return (
		horizontal_distance >= SKILL_1_SCOPE_MIN
		and horizontal_distance <= SKILL_1_SCOPE_MAX
		and _target_in_vertical_scope(target_position)
	)


func _skill_2_in_range(horizontal_distance: float, target_position: Vector2) -> bool:
	return (
		horizontal_distance >= SKILL_2_SCOPE_MIN
		and horizontal_distance <= SKILL_2_SCOPE_MAX
		and _target_in_vertical_scope(target_position)
	)


func ai_think() -> void:
	if _death_started or death() or _skill_busy:
		return
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		has_target = false
		_stop_source()
		return

	var target_position := _target_position()
	var sight_distance := position.distance_to(target_position)
	var horizontal_distance := absf(target_position.x - position.x)
	if not has_target:
		if sight_distance <= PATROL_VIEW_RANGE and _target_in_vertical_scope(target_position):
			has_target = true
		else:
			_stop_source()
			return
	elif sight_distance > SEEK_VIEW_RANGE or not _target_in_vertical_scope(target_position):
		has_target = false
		_stop_source()
		return

	match _ai_phase:
		AiPhase.OPENING_DELAY:
			_stop_source()
			if _phase_time_left <= 0.0:
				_set_phase(AiPhase.APPROACH_SKILL_1)
		AiPhase.APPROACH_SKILL_1:
			if _skill_1_in_range(horizontal_distance, target_position):
				_use_attack(&"skill_1")
			else:
				_move_toward_target(target_position)
		AiPhase.WAIT_AFTER_SKILL_1:
			_stop_source()
			if _phase_time_left <= 0.0:
				_set_phase(AiPhase.FLEE_AFTER_SKILL_1, randf_range(1.0, 2.0))
		AiPhase.FLEE_AFTER_SKILL_1:
			if _phase_time_left <= 0.0:
				_skill_2_range_time_left = 3.0
				_set_phase(AiPhase.APPROACH_SKILL_2)
			else:
				_move_away_from_target(target_position)
		AiPhase.APPROACH_SKILL_2:
			if _skill_2_in_range(horizontal_distance, target_position):
				_use_attack(&"skill_2")
			elif _skill_2_range_time_left <= 0.0:
				_set_phase(AiPhase.APPROACH_SKILL_1)
			elif horizontal_distance < SKILL_2_SCOPE_MIN:
				_move_away_from_target(target_position)
			else:
				_move_toward_target(target_position)
		AiPhase.WAIT_AFTER_SKILL_2:
			_stop_source()
			if _phase_time_left <= 0.0:
				_set_phase(AiPhase.APPROACH_SKILL_1)


func _move_toward_target(target_position: Vector2) -> void:
	var delta_x := target_position.x - position.x
	if absf(delta_x) <= 4.0:
		_stop_source()
		return
	_set_horizontal_velocity(signf(delta_x))


func _move_away_from_target(target_position: Vector2) -> void:
	if position.x <= 1450.0:
		_set_horizontal_velocity(1.0)
	elif position.x >= 2150.0:
		_set_horizontal_velocity(-1.0)
	else:
		_set_horizontal_velocity(-signf(target_position.x - position.x))


func _set_horizontal_velocity(direction: float) -> void:
	if _movement_command_is_blocked():
		velocity.x = 0.0
		return
	var sign_direction := signf(direction)
	if is_zero_approx(sign_direction):
		_stop_source()
		return
	velocity.x = sign_direction * SOURCE_WALK_SPEED
	if sign_direction < 0.0:
		base_damage_box.scale.x = 1.0
		monster_dir.scale.x = 1.0
		monster_direction = false
	else:
		base_damage_box.scale.x = -1.0
		monster_dir.scale.x = -1.0
		monster_direction = true
	if not is_attacking and not _skill_busy and mr_player.current_animation != &"walk":
		mr_player.play(&"walk")


func _stop_source() -> void:
	velocity.x = 0.0
	if not is_attacking and not _skill_busy and not _hurt_reaction_active and mr_player.current_animation != &"wait":
		mr_player.play(&"wait")


func _begin_skill_super_armor() -> void:
	if _skill_super_armor_active:
		return
	_skill_super_armor_active = true
	_cannot_attract_before_skill = cannot_attract
	cannot_attract = true
	super_armor_active = true
	is_be_attacking = false
	_cancel_hurt_reaction()
	_kill_control_movement_tweens()
	_release_control_movement_lock()


func _end_skill_super_armor() -> void:
	if not _skill_super_armor_active:
		return
	_skill_super_armor_active = false
	cannot_attract = _cannot_attract_before_skill
	super_armor_active = _has_other_super_armor_buff()


func _has_other_super_armor_buff() -> bool:
	if buff == null:
		return false
	for child in buff.get_children():
		if child == null:
			continue
		var buff_info = child.get("buff_info")
		if buff_info is Dictionary and str(buff_info.get("Name", "")) == "SuperArmor":
			return true
	return false


func _use_attack(action: StringName) -> void:
	if _skill_busy or is_attacking or _death_started:
		return
	_refresh_attack_powers()
	to_hero()
	_attack_generation += 1
	var generation := _attack_generation
	_skill_1_fired = false
	_skill_2_fired = false
	hit_box.disabled = true
	hit_name = str(action)
	velocity = Vector2.ZERO
	is_attacking = true
	_skill_busy = true
	_begin_skill_super_armor()
	mr_player.play(action)
	await mr_player.animation_finished
	if not is_instance_valid(self):
		return
	if generation != _attack_generation or death():
		return
	hit_box.disabled = true
	is_attacking = false
	_skill_busy = false
	_end_skill_super_armor()
	if action == &"skill_1":
		_set_phase(AiPhase.WAIT_AFTER_SKILL_1, randf_range(0.5, 1.0))
	else:
		_skill_2_range_time_left = 0.0
		_set_phase(AiPhase.WAIT_AFTER_SKILL_2, randf_range(1.0, 2.5))
	_stop_source()


func _enable_skill_1_hitbox() -> void:
	if not death() and not is_queued_for_deletion():
		hit_box.disabled = false


func _disable_attack_hitbox() -> void:
	if is_instance_valid(hit_box):
		hit_box.disabled = true


func _fire_skill_1_once() -> void:
	if _skill_1_fired or death():
		return
	_skill_1_fired = true
	_fire_skill_1_sequence(_attack_generation)


func _fire_skill_1_sequence(generation: int) -> void:
	var direction_sign := 1.0 if monster_dir.scale.x < 0.0 else -1.0
	for shot_index in range(SKILL_1_SHOTS.size()):
		if not is_instance_valid(self) or death() or generation != _attack_generation:
			return
		var shot: Array = SKILL_1_SHOTS[shot_index]
		_spawn_skill_1_projectile(
			global_position + Vector2(float(shot[0]) * direction_sign, float(shot[1])),
			Vector2(SKILL_1_PROJECTILE_SPEED_X * direction_sign, float(shot[2]))
		)
		if shot_index < SKILL_1_SHOTS.size() - 1:
			await get_tree().create_timer(0.099, false).timeout


func _spawn_skill_1_projectile(spawn_position: Vector2, projectile_velocity: Vector2) -> void:
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.att_list = obj_attack_dict["skill_1_projectile"].duplicate(true)
	projectile.hit_name = "skill_1_projectile"
	projectile.skill_name = "Tongtian3057Projectile"
	projectile.spawn_global_position = spawn_position
	projectile.travel_velocity = projectile_velocity
	projectile.my_father = self
	bullet.add_child(projectile)


func _fire_skill_2_once() -> void:
	if _skill_2_fired or death():
		return
	_skill_2_fired = true
	var beam = BEAM_SCENE.instantiate()
	beam.att_list = obj_attack_dict["skill_2"].duplicate(true)
	beam.hit_name = "skill_2"
	beam.skill_name = "Tongtian3057Beam"
	beam.spawn_global_position = global_position
	beam.facing_right = monster_dir.scale.x < 0.0
	beam.my_father = self
	bullet.add_child(beam)


func _begin_death() -> void:
	_death_started = true
	_attack_generation += 1
	_skill_busy = false
	_end_skill_super_armor()
	is_attacking = false
	velocity = Vector2.ZERO
	if is_instance_valid(hit_box):
		hit_box.disabled = true


func _finish_death() -> void:
	if is_instance_valid(hit_box):
		hit_box.disabled = true
	settle_death_drops_and_free()


func _interrupt_attack_state_on_hit() -> void:
	if is_control_immune():
		return
	var was_attacking := _skill_busy or is_attacking
	if was_attacking:
		_attack_generation += 1
		_skill_busy = false
		_end_skill_super_armor()
		_skill_1_fired = false
		_skill_2_fired = false
		hit_box.disabled = true
		_set_phase(AiPhase.APPROACH_SKILL_1, 0.15)
	super._interrupt_attack_state_on_hit()


func little_blood_bar_control():
	super.little_blood_bar_control()
	if monster_blood_bar != null:
		monster_blood_bar.position = LITTLE_BLOOD_OFFSET


func _show_pet_hit_blood_bar() -> void:
	super._show_pet_hit_blood_bar()
	if monster_blood_bar != null:
		monster_blood_bar.position = LITTLE_BLOOD_OFFSET


static func _get_body_frames_resource() -> SpriteFrames:
	if _body_frames_resource == null:
		_body_frames_resource = load(BODY_FRAMES_RES) as SpriteFrames
	return _body_frames_resource


func _setup_body_frames_overlay(anim_name: StringName, data: Array, source_offset: Vector2) -> bool:
	var frames := _get_body_frames_resource()
	var sequence := StringName(str(data[0]))
	if frames == null or not frames.has_animation(sequence):
		return false
	var overlay := AnimatedSprite2D.new()
	overlay.name = "BodyFrames"
	overlay.sprite_frames = frames
	overlay.animation = sequence
	overlay.centered = true
	overlay.flip_h = true
	overlay.position = Vector2(-source_offset.x, source_offset.y)
	var base_speed := frames.get_animation_speed(sequence)
	if base_speed > 0.0:
		var source_speed := float(data[1]) / HURT_RECOVERY_SECONDS if anim_name == &"hurt" else SOURCE_FPS
		overlay.speed_scale = source_speed / base_speed
	overlay.play(sequence)
	monster_dir.add_child(overlay)
	_body_frames_overlay = overlay
	return true


func _clear_body_stream() -> void:
	if _body_frames_overlay != null and is_instance_valid(_body_frames_overlay):
		_body_frames_overlay.stop()
		_body_frames_overlay.sprite_frames = null
		_body_frames_overlay.queue_free()
	_body_frames_overlay = null


func _exit_tree() -> void:
	_clear_body_stream()

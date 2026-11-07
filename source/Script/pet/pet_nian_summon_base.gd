extends "res://Script/pet/pet_turtle_summon_base.gd"
class_name PetNianSummonBase
const NIAN := preload("res://Script/pet/pet_nian_data.gd")
const EFFECT := preload("res://Script/pet/pet_nian_effect.gd")
var _nian_effect_durations: Dictionary = {}
var _nian_action_visual: Node2D
var _nian_ultimate_cast := false
var _nian_warm_banks: Array[RefCounted] = []
var _nian_volley_time := 0.0
var _nian_volley_shots_fired := 15
const NIAN_VOLLEY_SHOT_INTERVAL := 0.15


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_nian_unit", true)
	set_meta("is_summon", true)
	remove_from_group("monsters")
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	_setup_turtle_model_frames()
	_nian_action_visual = preload("res://Script/pet/pet_nian_parts.gd").new()
	monster_dir.add_child(_nian_action_visual)
	_nian_action_visual.load_set("nianshou%d" % turtle_stage)
	_nian_action_visual.hide()
	_warm_nian_banks()
	setup_skills()
	hurt_box.disabled = false
	hit_box.disabled = true


func _process(delta: float) -> void:
	_process_pet_turtle_recovery(delta)
	_process_nian_volley(delta)


func _process_nian_volley(delta: float) -> void:
	if hp <= 0:
		_nian_volley_shots_fired = 15
	if _nian_volley_shots_fired >= 15:
		return
	_nian_volley_time += delta
	while _nian_volley_shots_fired < 15:
		var region_index := _nian_volley_shots_fired % 5
		var shot_time := floorf(float(_nian_volley_shots_fired) / 5.0) + region_index * NIAN_VOLLEY_SHOT_INTERVAL
		if _nian_volley_time + 1e-06 < shot_time:
			break
		_nian_volley_shots_fired += 1
		_spawn_nian_ultimate_shot(region_index)


func _pet_stage_from_data(data: Dictionary, _fallback: int) -> int:
	return NIAN.stage_for_level(int(data.get(DataKeys.LEVEL, 1)))


func setup_pet_turtle(stage: int) -> void:
	super.setup_pet_turtle(stage)
	NIAN.normalize(pet_data)
	turtle_stage = int(pet_data[DataKeys.Pet.STAGE])
	my_mr_name = str(pet_data[DataKeys.ALT_NAME])
	attack_range = 0


func setup_skills() -> void:
	skill_1_cd = 3.0
	skill_2_cd = 5.0
	skill_3_cd = 0.0
	skill_4_cd = 20.0 * pet_skill_cooldown_multiplier if turtle_stage >= 4 else 0.0


func _nian_screen_bounds() -> Rect2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()


func _nian_target_visible(target: Node2D) -> bool:
	return is_instance_valid(target) and _nian_screen_bounds().has_point(target.global_position)


func _try_add_target(monster: Node) -> void:
	if monster is Node2D and _nian_target_visible(monster):
		super._try_add_target(monster)


func ai_think() -> void:
	if is_instance_valid(current_target) and not _nian_target_visible(current_target):
		current_target = null
		has_target = false
	super.ai_think()


func try_use_skills() -> void:
	if is_attacking or is_be_attacking or not is_instance_valid(current_target):
		return
	var fire_cost := PET_SKILL_PROGRESSION.mana_cost(50, PET_SKILL_PROGRESSION.get_level(pet_data, NIAN.SKILLS[1]))
	var blast_cost := PET_SKILL_PROGRESSION.mana_cost(90, PET_SKILL_PROGRESSION.get_level(pet_data, NIAN.SKILLS[2]))
	var ultimate_cost := PET_SKILL_PROGRESSION.mana_cost(120, PET_SKILL_PROGRESSION.get_level(pet_data, NIAN.SKILLS[3]))
	if turtle_stage >= 4 and skill_4_cd <= 0.0 and mp >= ultimate_cost and _nian_target_in_range(current_target, 3):
		mp -= ultimate_cost
		skill_4_cd = 20.0 * pet_skill_cooldown_multiplier
		_face_current_target()
		_nian_ultimate_cast = true
		hit_name = "nian_aoyi"
		_start_turtle_action("hit3")
	elif turtle_stage >= 3 and skill_2_cd <= 0.0 and mp >= blast_cost and _nian_target_in_range(current_target, 3):
		_nian_ultimate_cast = false
		mp -= blast_cost
		skill_2_cd = 12.0 * pet_skill_cooldown_multiplier
		_face_current_target()
		hit_name = "hit3"
		_start_turtle_action("hit3")
	elif turtle_stage >= 2 and skill_1_cd <= 0.0 and mp >= fire_cost and _nian_target_in_range(current_target, 2):
		mp -= fire_cost
		skill_1_cd = 8.0 * pet_skill_cooldown_multiplier
		_face_current_target()
		hit_name = "hit2"
		_start_turtle_action("hit2")


func _setup_turtle_model_frames() -> void:
	if not is_node_ready():
		return
	turtle_sprite.sprite_frames = load("res://Art/pet/pet_nian/model/pet_nian_stage%d_frames.tres" % turtle_stage)
	if is_instance_valid(_nian_action_visual):
		_nian_action_visual.load_set("nianshou%d" % turtle_stage)
	_play_turtle_model_animation("wait")


func _apply_turtle_stage_scene_layout() -> void:
	pass


func _sync_turtle_model_facing() -> void:
	if turtle_sprite != null:
		turtle_sprite.flip_h = true


func _nian_hit_size(skill: int) -> Vector2:
	return Vector2(100, 70) if skill == 1 else Vector2(1200, 120) if skill == 3 else Vector2(160, 110)


func _nian_attack_offset(skill: int) -> Vector2:
	if skill == 1:
		return [Vector2(45, -31), Vector2(65, -41), Vector2(125, -50), Vector2(155, -64)][turtle_stage - 1]
	return Vector2(650, -60) if skill == 3 else Vector2.ZERO


func _nian_effect_bank(skill: int) -> String:
	var root := "nianshou%d" % turtle_stage
	var bank_name := (
		root + "_effect1"
		if skill == 1
		else root if skill == 3 else root + "_effect2_1" if turtle_stage == 2 else root + "_effect2"
	)
	if skill == 1 and turtle_stage == 4:
		bank_name = "nianshou4_effect1_1"
	if not _nian_effect_durations.has(bank_name):
		var path := "res://Art/pet/pet_nian/official_parts/" + bank_name + "/poses.json"
		if not FileAccess.file_exists(path):
			bank_name = root + "_effect1"
			path = "res://Art/pet/pet_nian/official_parts/" + bank_name + "/poses.json"
		var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var action := "effect3" if skill == 3 else "attack"
		_nian_effect_durations[bank_name] = (
			1.8 if skill == 1 else maxf(0.1, float(manifest["animations"][action]["frames"].size()) / 30.0)
		)
	return bank_name


func _nian_target_in_range(target: Node2D, skill: int) -> bool:
	if not is_instance_valid(target):
		return false
	if skill == 2:
		return _nian_target_visible(target)
	var facing := 1.0 if target.global_position.x > global_position.x else -1.0
	var offset := _nian_attack_offset(skill)
	var center := global_position + Vector2(facing * offset.x, offset.y)
	var size := _nian_hit_size(skill)
	if skill == 1:
		var bank_name := _nian_effect_bank(skill)
		var travel := 260.0 * float(_nian_effect_durations[bank_name]) * 0.8
		center.x += facing * (travel - offset.x) * 0.5
		size.x += travel + offset.x
	var target_rect := Rect2(target.global_position, Vector2.ONE)
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape != null and hurt_shape.shape != null:
		target_rect = hurt_shape.global_transform * hurt_shape.shape.get_rect()
	return Rect2(center - size * 0.5, size).intersects(target_rect)


func _horizontal_attack_gap(target: Node2D) -> float:
	return 0.0 if _nian_target_in_range(target, 1) else INF


func _start_turtle_action(action_name: String) -> void:
	if turtle_sprite == null or not turtle_sprite.sprite_frames.has_animation(action_name):
		return
	is_attacking = action_name != "hurt" and action_name != "death"
	velocity.x = 0.0
	_turtle_action = action_name
	_turtle_action_tick = 0
	_turtle_action_accumulator = 0.0
	_turtle_action_triggered.clear()
	_set_turtle_action_visual(action_name, 0)


func _turtle_action_total_ticks(action_name: String) -> int:
	return turtle_sprite.sprite_frames.get_frame_count(action_name)


func _warm_nian_banks() -> void:
	var root := "res://Art/pet/pet_nian/official_parts/"
	var names: Array[String] = ["nianshou4_effect1_1" if turtle_stage == 4 else "nianshou%d_effect1" % turtle_stage]
	if turtle_stage >= 2:
		names.append("nianshou2_effect2_1" if turtle_stage == 2 else "nianshou%d_effect2" % turtle_stage)
		names.append("nianshou2_effect2_2" if turtle_stage == 2 else "nianshou%d_effect2_1" % turtle_stage)
	if turtle_stage == 4:
		names.append_array(["nianshou4_effect2_2", "nianshou4_effect2_3"])
		names.append("nianshou4_effect1_2")
	_nian_warm_banks.clear()
	for bank_name in names:
		var data: RefCounted = preload("res://Script/hero/ne_zha_official_parts_data.gd").get_set(bank_name, root)
		if data != null:
			_nian_warm_banks.append(data)
	for skill in range(1, mini(turtle_stage, 3) + 1):
		_nian_effect_bank(skill)


func _tick_turtle_action(delta: float) -> void:
	if _turtle_action.is_empty():
		return
	_turtle_action_accumulator += delta * 30.0
	while _turtle_action_accumulator >= 1.0 and not _turtle_action.is_empty():
		_turtle_action_accumulator -= 1.0
		_turtle_action_tick += 1
		_set_turtle_action_visual(_turtle_action, _turtle_action_tick)
		_process_turtle_action_triggers()
		if _turtle_action_tick >= _turtle_action_total_ticks(_turtle_action):
			_finish_turtle_action()


func _set_turtle_action_visual(action_name: String, action_tick: int) -> void:
	if not turtle_sprite.sprite_frames.has_animation(action_name):
		return
	turtle_sprite.animation = action_name
	turtle_sprite.pause()
	turtle_sprite.frame = mini(action_tick, turtle_sprite.sprite_frames.get_frame_count(action_name) - 1)
	_sync_turtle_model_facing()
	if is_instance_valid(_nian_action_visual):
		var source_action := "effect" + action_name.trim_prefix("hit") if action_name.begins_with("hit") else ""
		_nian_action_visual.visible = not source_action.is_empty()
		turtle_sprite.visible = source_action.is_empty()
		if not source_action.is_empty():
			_nian_action_visual.hide_beam = _nian_ultimate_cast
			_nian_action_visual.scale = Vector2(-1, 1)
			_nian_action_visual.set_pose(source_action, action_tick)


func _play_turtle_model_animation(animation_name: String) -> void:
	_nian_ultimate_cast = false
	if is_instance_valid(_nian_action_visual):
		_nian_action_visual.hide()
	if turtle_sprite != null:
		turtle_sprite.show()
	super._play_turtle_model_animation(animation_name)


func _process_turtle_action_triggers() -> void:
	var trigger_tick := (
		1
		if _turtle_action == "hit3"
		else (
			30
			if _turtle_action == "hit1" and turtle_stage == 4
			else 28 if _turtle_action == "hit1" and turtle_stage == 3 else 8
		)
	)
	if _turtle_action.begins_with("hit") and _trigger_once("nian_attack", trigger_tick):
		_spawn_nian_attack(4 if _nian_ultimate_cast else int(_turtle_action.trim_prefix("hit")))


func _spawn_normal_attack() -> void:
	_spawn_nian_attack(1)


func do_hit_1() -> void:
	_face_current_target()
	hit_name = "hit1"
	_start_turtle_action("hit1")


func _spawn_nian_attack(skill: int) -> void:
	if skill == 4:
		_nian_volley_time = 0.0
		_nian_volley_shots_fired = 0
		_process_nian_volley(0.0)
		var ultimate := preload("res://Script/pet/pet_nian_reflected_beam.gd").new()
		ultimate.summoner = self
		ultimate.direction = -1.0 if monster_direction else 1.0
		ultimate.power = PET_SKILL_PROGRESSION.scaled_power(
			int(attack_in * 9.0 * (1.0 + float(int(pet_data.get(DataKeys.Pet.BONE, 0))) * 0.02)),
			pet_data,
			NIAN.SKILLS[3]
		)
		bullet.add_child(ultimate)
		ultimate.global_position = global_position
		return
	var effect = preload("res://Script/pet/pet_nian_magic_ball.gd").new() if skill == 1 else EFFECT.new()
	if skill == 1:
		effect.stage = turtle_stage
	effect.summoner = self
	effect.direction = -1.0 if monster_direction else 1.0
	effect.bank = _nian_effect_bank(skill)
	var root_rate := 1.0 + float(int(pet_data.get(DataKeys.Pet.BONE, 0))) * 0.02
	effect.power = PET_SKILL_PROGRESSION.scaled_power(
		int(attack_in * (1.5 if skill == 1 else 6.0 if skill == 2 else 9.0) * root_rate),
		pet_data,
		NIAN.SKILLS[skill - 1]
	)
	effect.speed = 260.0 if skill == 1 else 0.0
	if skill == 1:
		effect.hurt_back = [6, -5]
	effect.hit_size = _nian_hit_size(skill)
	if skill == 3:
		effect.hit_interval = 0.25
		effect.action = "effect3"
		effect.embedded_beam = true
	elif skill == 2:
		effect.hit_interval = 0.2
		effect.initial_stun_duration = 3.0
		effect.hit_offset = Vector2(0, -55)
		effect.extra_banks = ["nianshou2_effect2_2"] if turtle_stage == 2 else ["nianshou%d_effect2_1" % turtle_stage]
		if turtle_stage == 4:
			effect.extra_banks.append("nianshou4_effect2_2")
			effect.extra_banks.append("nianshou4_effect2_3")
	bullet.add_child(effect)
	var offset := Vector2.ZERO if skill == 3 else _nian_attack_offset(skill)
	effect.global_position = global_position + Vector2(effect.direction * offset.x, offset.y)
	if skill == 2 and is_instance_valid(current_target):
		var feet := current_target.global_position
		var ground_shape := current_target.get_node_or_null("pz") as CollisionShape2D
		if ground_shape != null and ground_shape.shape != null:
			var body_bounds: Rect2 = ground_shape.global_transform * ground_shape.shape.get_rect()
			feet.y = body_bounds.end.y
		effect.global_position = feet + Vector2(0, 30)


func _spawn_nian_ultimate_shot(region_index: int) -> void:
	search_for_targets()
	var candidates := all_monsters.duplicate()
	if candidates.is_empty():
		return
	var bounds := _nian_screen_bounds()
	var target: BaseMonster = candidates.pick_random()
	_spawn_nian_attack(1)
	var shot: Node2D = bullet.get_child(-1)
	shot.set_meta("nian_ultimate_volley", true)
	shot.global_position = bounds.position + Vector2(bounds.size.x * (float(region_index) + 0.5) / 5.0 - 22.0, 40)
	var aim := target.global_position + Vector2(0, -35)
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape != null:
		aim = hurt_shape.global_position
	shot.flight_velocity = shot.global_position.direction_to(aim) * 600.0
	shot.direction = -1.0 if shot.flight_velocity.x < 0.0 else 1.0
	shot.duration = maxf(1.8, shot.global_position.distance_to(aim) / 600.0 + 0.4)
	shot.visual.scale = Vector2.ONE
	shot.visual.rotation = shot.flight_velocity.angle()


func _unlock_new_stage_skill_cooldowns(_previous: Array) -> void:
	pass

extends "res://Script/pet/pet_turtle_summon_base.gd"
class_name PetMouseSummonBase

const SKILL_SC := "sc"
const SKILL_HXFB := "hxfb"
const SKILL_ZSAOYI := "zsaoyi"
const MOUSE_SKILL_NAMES := {
	SKILL_SC: "鼠窜",
	SKILL_HXFB: "回旋飞镖",
	SKILL_ZSAOYI: "子鼠奥义",
}
const MOUSE_SKILL_COSTS := {SKILL_SC: 50, SKILL_HXFB: 70, SKILL_ZSAOYI: 100}
const MOUSE_SKILL_INITIAL_CDS := {SKILL_SC: 4.0, SKILL_HXFB: 4.0, SKILL_ZSAOYI: 6.0}
const MOUSE_SKILL_CDS := {SKILL_SC: 10.0, SKILL_HXFB: 10.0, SKILL_ZSAOYI: 9.0}
const MOUSE_STAGE_NAMES := {1: "子鼠元帅", 2: "子鼠大元帅"}
const MOUSE_LEVEL_SKILLS := {
	1: ["鼠窜"],
	30: ["鼠窜", "回旋飞镖"],
	50: ["鼠窜", "回旋飞镖", "子鼠奥义"],
}
const MOUSE_ACTIONS := {
	1:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 10],
		"hit2": [4, 4, 1, 10],
		"hit3": [2, 2, 10],
	},
	2:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 10],
		"hit2": [4, 4, 1, 10],
		"hit3": [2, 2, 10],
	},
}
const MOUSE_MODEL_FRAMES_RES := "res://Art/pet/pet_mouse/model/pet_mouse_stage%d_frames.tres"
const MOUSE_SCENE_RES := "res://Scene/pet/pet_mouse_summon_%d.tscn"
const PET_MOUSE_BULLET_SCENE := preload("res://Scene/pet/pet_mouse_bullet.tscn")
const MOUSE_ROLE_ORIGIN_Y := -35.0
const MOUSE_DASH_SPEED_PER_SECOND := 240.0

static var _mouse_scene_cache: Dictionary = {}

var _mouse_aoyi_step := 0


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_mouse_unit", true)
	set_meta("is_summon", true)
	if is_in_group("monsters"):
		remove_from_group("monsters")
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	setup_skills()
	_setup_turtle_model_frames()
	_get_mouse_stage_scene(turtle_stage)
	PetMouseBullet.warm_pet_mouse_frames(int(pet_data.get(DataKeys.LEVEL, 1)))
	if hurt_box != null:
		hurt_box.disabled = false
	if hit_box != null:
		hit_box.disabled = true


func _process(delta: float) -> void:
	_process_pet_turtle_recovery(delta)


func _pet_stage_from_data(data: Dictionary, _fallback: int) -> int:
	return 2 if int(data.get(DataKeys.LEVEL, 1)) >= 50 else 1


func setup_pet_turtle(stage: int) -> void:
	super.setup_pet_turtle(clampi(stage, 1, 2))
	turtle_stage = clampi(stage, 1, 2)
	pet_data["阶段"] = turtle_stage
	pet_data[DataKeys.TYPE] = "PetMouse"
	pet_data[DataKeys.ALT_NAME] = MOUSE_STAGE_NAMES[turtle_stage]
	pet_data[DataKeys.NAME] = MOUSE_STAGE_NAMES[turtle_stage]
	pet_data["技能"] = _mouse_skills_for_level(int(pet_data.get(DataKeys.LEVEL, 1)))
	my_mr_name = str(MOUSE_STAGE_NAMES[turtle_stage])
	speed = 12
	init_speed = speed
	attack_range = 200
	attack_desire = 70
	_rebuild_pet_turtle_attack_data()


func _mouse_skills_for_level(pet_level: int) -> Array:
	var unlock_level := 50 if pet_level >= 50 else 30 if pet_level >= 30 else 1
	return (MOUSE_LEVEL_SKILLS[unlock_level] as Array).duplicate(true)


func _rebuild_pet_turtle_attack_data() -> void:
	var root_rate := 1.0 + float(clampi(int(pet_data.get("根骨", 0)), 0, 25)) * 0.02
	var magic_add := int(pet_data.get("法术能量", pet_data.get("魔法加成", 0)))
	var normal_power := maxi(1, int(float(attack_in + magic_add) * root_rate))
	var dash_base := maxi(1, int(float(attack_in * 3 + magic_add) * root_rate))
	var boomerang_base := maxi(1, int(float(attack_in * 10 + magic_add) * root_rate))
	var dash_power := PET_SKILL_PROGRESSION.scaled_power(dash_base, pet_data, MOUSE_SKILL_NAMES[SKILL_SC])
	var boomerang_power := PET_SKILL_PROGRESSION.scaled_power(boomerang_base, pet_data, MOUSE_SKILL_NAMES[SKILL_HXFB])
	obj_attack_dict["hit1"] = _attack_dic(normal_power, [6, -5], "magic", 999)
	obj_attack_dict["hit2"] = _attack_dic(dash_power, [-10, 0], "physics", 5)
	obj_attack_dict["hit3"] = _attack_dic(boomerang_power, [-10, 0], "physics", 4)
	obj_attack_dict["hit3"]["damageHitCount"] = 2
	obj_attack_dict["aoyi_hit2"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(dash_base, pet_data, MOUSE_SKILL_NAMES[SKILL_ZSAOYI]), [-10, 0], "physics", 5
	)
	obj_attack_dict["aoyi_hit3"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(boomerang_base, pet_data, MOUSE_SKILL_NAMES[SKILL_ZSAOYI]),
		[-10, 0],
		"physics",
		4
	)
	obj_attack_dict["aoyi_hit3"]["damageHitCount"] = 2


func setup_skills() -> void:
	skill_1_cd = MOUSE_SKILL_INITIAL_CDS[SKILL_SC] * pet_skill_cooldown_multiplier
	skill_2_cd = MOUSE_SKILL_INITIAL_CDS[SKILL_HXFB] * pet_skill_cooldown_multiplier
	skill_3_cd = MOUSE_SKILL_INITIAL_CDS[SKILL_ZSAOYI] * pet_skill_cooldown_multiplier
	skill_4_cd = 0.0


func _unlock_new_stage_skill_cooldowns(previous_skills: Array) -> void:
	if not previous_skills.has(MOUSE_SKILL_NAMES[SKILL_HXFB]) and _has_skill(SKILL_HXFB):
		skill_2_cd = 0.0
	if not previous_skills.has(MOUSE_SKILL_NAMES[SKILL_ZSAOYI]) and _has_skill(SKILL_ZSAOYI):
		skill_3_cd = 0.0


func _has_skill(skill_id: String) -> bool:
	var skills = pet_data.get("技能", [])
	return skills is Array and (skills.has(skill_id) or skills.has(MOUSE_SKILL_NAMES[skill_id]))


func _skill_cost(skill_id: String) -> int:
	var custom_value = pet_data.get("技能蓝耗", {})
	var custom: Dictionary = custom_value if custom_value is Dictionary else {}
	if custom.has(skill_id) or custom.has(MOUSE_SKILL_NAMES[skill_id]):
		return int(custom.get(skill_id, custom.get(MOUSE_SKILL_NAMES[skill_id], MOUSE_SKILL_COSTS[skill_id])))
	return PET_SKILL_PROGRESSION.mana_cost(
		MOUSE_SKILL_COSTS[skill_id], PET_SKILL_PROGRESSION.get_level(pet_data, MOUSE_SKILL_NAMES[skill_id])
	)


func try_use_skills() -> void:
	if is_attacking or is_be_attacking or not is_instance_valid(current_target):
		return
	var distance := global_position.distance_to(current_target.global_position)
	if distance <= 400.0 and skill_3_cd <= 0.0 and _can_use_mouse_skill(SKILL_ZSAOYI):
		do_mouse_aoyi()
	elif distance <= 400.0 and skill_2_cd <= 0.0 and _can_use_mouse_skill(SKILL_HXFB):
		do_mouse_boomerang()
	elif skill_1_cd <= 0.0 and _can_use_mouse_skill(SKILL_SC) and (turtle_stage == 1 or distance <= 300.0):
		do_mouse_dash()


func _can_use_mouse_skill(skill_id: String) -> bool:
	return _has_skill(skill_id) and mp >= _skill_cost(skill_id)


func ai_think() -> void:
	if is_attacking or is_be_attacking:
		return
	if not is_instance_valid(current_target) or current_target.hp <= 0:
		current_target = null
		follow_player_when_idle()
		return
	if global_position.distance_to(current_target.global_position) >= mysee:
		current_target = null
		has_target = false
		follow_player_when_idle()
		return
	has_target = true
	try_use_skills()
	if is_attacking:
		return
	var distance := absf(current_target.global_position.x - global_position.x)
	if distance > float(attack_range):
		if current_target.global_position.x > global_position.x:
			move_right()
		else:
			move_left()
	else:
		stop_move()
		to_monster()
		if count % 48 == 0 and randi_range(0, 100) < attack_desire:
			do_hit_1()


func do_hit_1() -> void:
	_face_current_target()
	hit_name = "hit1"
	_start_turtle_action("hit1")


func do_mouse_dash(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana and not _consume_skill(SKILL_SC):
		return
	_face_current_target()
	if set_cooldown:
		skill_1_cd = MOUSE_SKILL_CDS[SKILL_SC] * pet_skill_cooldown_multiplier
	hit_name = "hit2"
	_start_turtle_action("hit2")


func do_mouse_boomerang(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana and not _consume_skill(SKILL_HXFB):
		return
	_face_current_target()
	if set_cooldown:
		skill_2_cd = MOUSE_SKILL_CDS[SKILL_HXFB] * pet_skill_cooldown_multiplier
	hit_name = "hit3"
	_start_turtle_action("hit3")


func do_mouse_aoyi() -> void:
	if not _consume_skill(SKILL_ZSAOYI):
		return
	_face_current_target()
	skill_3_cd = MOUSE_SKILL_CDS[SKILL_ZSAOYI] * pet_skill_cooldown_multiplier
	_mouse_aoyi_step = 1
	_spawn_mouse_effect("aoyi_buff", _mouse_role_origin(), "", {}, true)
	if _has_skill(SKILL_SC):
		do_mouse_dash(true, false)
	else:
		do_hit_1()


func _start_turtle_action(action_name: String) -> void:
	if not (MOUSE_ACTIONS[turtle_stage] as Dictionary).has(action_name):
		return
	if action_name != "hurt":
		is_attacking = true
	velocity.x = 0.0
	_turtle_action = action_name
	_turtle_action_tick = 0
	_turtle_action_accumulator = 0.0
	_turtle_action_triggered.clear()
	_set_turtle_action_visual(action_name, 0)


func _turtle_action_total_ticks(action_name: String) -> int:
	var total := 0
	for stop_count in (MOUSE_ACTIONS[turtle_stage] as Dictionary).get(action_name, []):
		total += int(stop_count)
	return total


func _set_turtle_action_visual(action_name: String, action_tick: int) -> void:
	var visual_action := "hit1" if turtle_stage == 1 and action_name == "hit3" else action_name
	if (
		turtle_sprite == null
		or turtle_sprite.sprite_frames == null
		or not turtle_sprite.sprite_frames.has_animation(visual_action)
	):
		return
	turtle_sprite.animation = visual_action
	turtle_sprite.pause()
	var running := 0
	var frame_index := 0
	for stop_count in (MOUSE_ACTIONS[turtle_stage] as Dictionary).get(action_name, []):
		running += int(stop_count)
		if action_tick <= running:
			break
		frame_index += 1
	turtle_sprite.frame = clampi(frame_index, 0, turtle_sprite.sprite_frames.get_frame_count(visual_action) - 1)
	_sync_turtle_model_facing()


func _process_turtle_action_triggers() -> void:
	match _turtle_action:
		"hit1":
			if _trigger_once("mouse_hit1", 5):
				_spawn_normal_attack()
		"hit2":
			if _turtle_action_tick <= 9:
				velocity.x = -MOUSE_DASH_SPEED_PER_SECOND if monster_direction else MOUSE_DASH_SPEED_PER_SECOND
			else:
				velocity.x = 0.0
			if _trigger_once("mouse_hit2", 10):
				_spawn_dash_attack()
		"hit3":
			if _trigger_once("mouse_hit3", 5):
				_spawn_boomerangs()


func _finish_turtle_action() -> void:
	var finished := _turtle_action
	super._finish_turtle_action()
	if _mouse_aoyi_step > 0 and hp > 0 and not is_queued_for_deletion():
		_continue_mouse_aoyi(finished)


func _continue_mouse_aoyi(finished: String) -> void:
	match finished:
		"hit1":
			_mouse_aoyi_step += 1
			if _mouse_aoyi_step == 4:
				if _has_skill(SKILL_SC):
					do_mouse_dash(true, false)
				else:
					_start_turtle_action("hit1")
			elif _mouse_aoyi_step > 7:
				_mouse_aoyi_step = 0
			elif _has_skill(SKILL_HXFB):
				do_mouse_boomerang(true, false)
			else:
				_start_turtle_action("hit1")
		"hit2":
			_mouse_aoyi_step += 1
			if _has_skill(SKILL_HXFB):
				do_mouse_boomerang(true, false)
			else:
				do_hit_1()
		"hit3":
			if _mouse_aoyi_step == 3:
				_mouse_aoyi_step = 4
				if _has_skill(SKILL_SC):
					do_mouse_dash(true, false)
				else:
					do_hit_1()
			elif _mouse_aoyi_step == 7:
				_mouse_aoyi_step = 0
			else:
				_mouse_aoyi_step += 1
				if _has_skill(SKILL_HXFB):
					do_mouse_boomerang(true, false)
				else:
					do_hit_1()


func _spawn_normal_attack() -> void:
	_spawn_mouse_effect(
		"pet_mouse_1_bullet_1", _mouse_role_origin() + _front_offset(20, 10), "hit1", obj_attack_dict["hit1"]
	)


func _spawn_dash_attack() -> void:
	var attack_key := "aoyi_hit2" if _mouse_aoyi_step > 0 else "hit2"
	_spawn_mouse_effect(
		"pet_mouse_1_bullet_2", _mouse_role_origin() + _front_offset(40, 10), attack_key, obj_attack_dict[attack_key]
	)


func _spawn_boomerangs() -> void:
	var attack_key := "aoyi_hit3" if _mouse_aoyi_step > 0 else "hit3"
	var x_velocity := -35.0 if monster_direction else 35.0
	var x_acceleration := 1.0 if monster_direction else -1.0
	for motion in [Vector2(x_velocity, 0), Vector2(x_velocity, -4), Vector2(x_velocity, -8)]:
		var y_acceleration := 0.0 if motion.y == 0.0 else 0.25 if motion.y == -4.0 else 0.125
		_spawn_mouse_effect(
			"pet_mouse_1_bullet_3",
			_mouse_role_origin() + _front_offset(20, 10),
			attack_key,
			obj_attack_dict[attack_key],
			false,
			{
				"pet_mouse_velocity_tick": motion,
				"pet_mouse_acceleration_tick": Vector2(x_acceleration, y_acceleration),
				"pet_mouse_return_offset": Vector2(0, MOUSE_ROLE_ORIGIN_Y),
			}
		)


func _spawn_mouse_effect(
	effect_name: String,
	effect_position: Vector2,
	attack_name: String,
	attack_data: Dictionary,
	follow: bool = false,
	spawn_meta: Dictionary = {}
) -> Node:
	if bullet == null:
		return null
	var instance = PET_MOUSE_BULLET_SCENE.instantiate()
	instance.att_list = attack_data
	instance.hit_name = attack_name
	instance.dir = monster_direction
	instance.skill_name = effect_name
	instance.speed = 1.0
	instance.set_meta("summoner", self)
	for meta_key in spawn_meta:
		instance.set_meta(meta_key, spawn_meta[meta_key])
	if follow:
		instance.set_meta("pet_mouse_follow_offset", effect_position - global_position)
	bullet.add_child(instance)
	instance.global_position = effect_position
	setup_bullet_collision(instance)
	return instance


func on_mouse_dash_hit(heal_value: int) -> void:
	cure_hp(maxi(1, heal_value))


func queue_mouse_boomerang_followup(
	target: BaseMonster,
	power: int,
	attack_kind: String,
	initial_actual_damage: int,
	remaining_hits: int,
	damage_interval: float
) -> void:
	var total_actual_damage := initial_actual_damage
	var target_ref: WeakRef = weakref(target)
	for _hit_index in range(maxi(0, remaining_hits)):
		var tree := get_tree()
		if tree == null:
			break
		await tree.create_timer(maxf(0.0, damage_interval), false).timeout
		var target_value = target_ref.get_ref()
		if not (target_value is BaseMonster):
			break
		var hit_target := target_value as BaseMonster
		if hit_target.hp <= 0 or hit_target.is_boss_protecting():
			break
		var resolved_damage := hit_target.resolve_friendly_damage(power, attack_kind, self)
		if resolved_damage <= 0:
			continue
		var remaining_hp := maxi(0, hit_target.hp)
		var actual_damage := hit_target.reduce_pet_hp(resolved_damage, attack_kind)
		if actual_damage > 0:
			total_actual_damage += mini(actual_damage, remaining_hp)
	on_mouse_boomerang_hit(total_actual_damage)


func on_mouse_boomerang_hit(actual_damage: int) -> void:
	var heal_value := int(float(actual_damage) * 0.05)
	if heal_value > 0:
		cure_hp(heal_value)


func _mouse_role_origin() -> Vector2:
	return global_position + Vector2(0, MOUSE_ROLE_ORIGIN_Y)


func _setup_turtle_model_frames() -> void:
	var frames := (
		ResourceLoader.load(MOUSE_MODEL_FRAMES_RES % turtle_stage, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE)
		as SpriteFrames
	)
	if frames == null:
		push_error("PetMouse SpriteFrames missing for stage %d" % turtle_stage)
		return
	turtle_sprite.sprite_frames = frames
	_play_turtle_model_animation("wait")


func _apply_turtle_stage_scene_layout() -> void:
	var packed := _get_mouse_stage_scene(turtle_stage)
	if packed == null:
		return
	var template := packed.instantiate()
	var template_sprite := template.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if template_sprite != null:
		turtle_sprite.position = template_sprite.position
		turtle_sprite.rotation = template_sprite.rotation
		turtle_sprite.offset = template_sprite.offset
		turtle_sprite.scale = template_sprite.scale
		turtle_sprite.centered = template_sprite.centered
	for path in ["BaseDamageBox/HitBox/HitBox", "BaseDamageBox/HurtBox/HurtBox", "pz"]:
		_copy_turtle_collision_layout(template, NodePath(path))
	template.free()


static func _get_mouse_stage_scene(stage: int) -> PackedScene:
	var safe_stage := clampi(stage, 1, 2)
	if _mouse_scene_cache.has(safe_stage):
		return _mouse_scene_cache[safe_stage] as PackedScene
	var scene := (
		ResourceLoader.load(MOUSE_SCENE_RES % safe_stage, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	)
	if scene != null:
		_mouse_scene_cache[safe_stage] = scene
	return scene


static func clear_cached_mouse_scenes() -> void:
	_mouse_scene_cache.clear()


func state_hurt(attacker: Node) -> void:
	_mouse_aoyi_step = 0
	super.state_hurt(attacker)


func _exit_tree() -> void:
	_mouse_aoyi_step = 0
	super._exit_tree()

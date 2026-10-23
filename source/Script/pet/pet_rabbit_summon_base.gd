extends "res://Script/pet/pet_turtle_summon_base.gd"
class_name PetRabbitSummonBase

const SKILL_YG := "yg"
const SKILL_JF := "jf"
const SKILL_BS := "bs"
const SKILL_YSAOYI := "ysaoyi"
const RABBIT_SKILL_NAMES := {SKILL_YG: "月光", SKILL_JF: "疾风", SKILL_BS: "冰陨", SKILL_YSAOYI: "月神奥义"}
const RABBIT_SKILL_COSTS := {SKILL_YG: 0, SKILL_JF: 70, SKILL_BS: 90, SKILL_YSAOYI: 100}
const RABBIT_SKILL_INITIAL_CDS := {SKILL_YG: 0.0, SKILL_JF: 8.0, SKILL_BS: 8.0, SKILL_YSAOYI: 30.0}
const RABBIT_SKILL_CDS := {SKILL_YG: 0.0, SKILL_JF: 20.0, SKILL_BS: 15.0, SKILL_YSAOYI: 60.0}

const RABBIT_ICE_FORWARD_RANGE := 323.95
const RABBIT_STAGE_NAMES := {1: "月兔", 2: "疾风兔", 3: "寒冰玉兔", 4: "冰霜月神"}
const RABBIT_STAGE_SKILLS := {
	1: ["月光"],
	2: ["月光", "疾风"],
	3: ["月光", "疾风", "冰陨"],
	4: ["月光", "疾风", "冰陨", "月神奥义"],
}
const RABBIT_MODEL_FRAMES_RES := "res://Art/pet/pet_rabbit/model/pet_rabbit_stage%d_frames.tres"
const RABBIT_SCENE_RES := "res://Scene/pet/pet_rabbit_summon_%d.tscn"
const PET_RABBIT_BULLET_SCENE := preload("res://Scene/pet/pet_rabbit_bullet.tscn")
const RABBIT_ACTIONS := {
	1:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [2, 2, 2, 3, 2, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 2, 10]
	},
	2:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 2, 2, 10]
	},
	3:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 2, 2, 2],
		"hit2": [1, 1, 1, 7, 1, 40]
	},
	4:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 2, 2, 2],
		"hit2": [1, 1, 1, 7, 1, 40]
	},
}
const RABBIT_OFFSETS := {1: Vector2(1, -10), 2: Vector2(1, -10), 3: Vector2(1, -28), 4: Vector2(-7, -41)}

const RABBIT_ROLE_ORIGIN_Y := {1: -15.0, 2: -35.0, 3: -35.0, 4: -50.0}

static var _rabbit_scene_cache: Dictionary = {}
var _jifeng_until_msec := 0
var _aoyi_until_msec_rabbit := 0
var _heal_accumulator := 0.0
var _aoyi_heal_ticks_remaining := 0
var _rabbit_ice_forced_fly := false
var _rabbit_ice_was_fly := false
var _rabbit_ice_start_y := 0.0


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_rabbit_unit", true)
	set_meta("is_summon", true)
	if is_in_group("monsters"):
		remove_from_group("monsters")
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	setup_skills()
	_setup_turtle_model_frames()
	_get_rabbit_stage_scene(turtle_stage)
	PetRabbitBullet.warm_pet_rabbit_frames(turtle_stage)
	if hurt_box != null:
		hurt_box.disabled = false
	if hit_box != null:
		hit_box.disabled = true


func _process(delta: float) -> void:
	_process_pet_turtle_recovery(delta)
	_process_rabbit_buffs(delta)


func _physics_process(delta: float) -> void:
	super(delta)
	if _rabbit_ice_forced_fly and _turtle_action == "hit2":
		global_position.y = _rabbit_ice_start_y - float(mini(_turtle_action_tick, 10) * 20)
		velocity.y = 0.0


func setup_pet_turtle(stage: int) -> void:
	super.setup_pet_turtle(stage)
	pet_data[DataKeys.TYPE] = "PetRabbit"
	pet_data[DataKeys.ALT_NAME] = RABBIT_STAGE_NAMES[turtle_stage]
	pet_data[DataKeys.NAME] = RABBIT_STAGE_NAMES[turtle_stage]
	pet_data["技能"] = (RABBIT_STAGE_SKILLS[turtle_stage] as Array).duplicate(true)
	my_mr_name = str(RABBIT_STAGE_NAMES[turtle_stage])
	attack_range = 350
	speed = 14
	init_speed = speed
	_rebuild_pet_turtle_attack_data()


func _rebuild_pet_turtle_attack_data() -> void:
	var root_rate := 1.0 + float(clampi(int(pet_data.get("根骨", 0)), 0, 25)) * 0.02
	var normal_power := PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * root_rate)), pet_data, RABBIT_SKILL_NAMES[SKILL_YG]
	)
	var moon_power := PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * 2.2 * root_rate)), pet_data, RABBIT_SKILL_NAMES[SKILL_JF]
	)
	var ice_power := PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * 6.0 * root_rate)), pet_data, RABBIT_SKILL_NAMES[SKILL_BS]
	)
	obj_attack_dict["hit1"] = _attack_dic(normal_power, [6, -5], "magic", 999)
	obj_attack_dict["hit2"] = _attack_dic(moon_power, [-10, 0], "magic", 7)
	obj_attack_dict["hit3"] = _attack_dic(ice_power, [-10, 0], "magic", 999)


func setup_skills() -> void:
	skill_1_cd = RABBIT_SKILL_INITIAL_CDS[SKILL_YG]
	skill_2_cd = RABBIT_SKILL_INITIAL_CDS[SKILL_JF] * pet_skill_cooldown_multiplier
	skill_3_cd = RABBIT_SKILL_INITIAL_CDS[SKILL_BS] * pet_skill_cooldown_multiplier
	skill_4_cd = RABBIT_SKILL_INITIAL_CDS[SKILL_YSAOYI] * pet_skill_cooldown_multiplier


func _unlock_new_stage_skill_cooldowns(previous_skills: Array) -> void:
	for skill_id in [SKILL_YG, SKILL_JF, SKILL_BS, SKILL_YSAOYI]:
		var skill_name := str(RABBIT_SKILL_NAMES[skill_id])
		if previous_skills.has(skill_id) or previous_skills.has(skill_name) or not _has_skill(skill_id):
			continue
		match skill_id:
			SKILL_YG:
				skill_1_cd = 0.0
			SKILL_JF:
				skill_2_cd = 0.0
			SKILL_BS:
				skill_3_cd = 0.0
			SKILL_YSAOYI:
				skill_4_cd = 0.0


func _has_skill(skill_id: String) -> bool:
	var skills = pet_data.get("技能", [])
	return skills is Array and (skills.has(skill_id) or skills.has(RABBIT_SKILL_NAMES[skill_id]))


func _skill_cost(skill_id: String) -> int:
	var custom = pet_data.get("技能蓝耗", {})
	var costs: Dictionary = custom if custom is Dictionary else {}
	if costs.has(skill_id) or costs.has(RABBIT_SKILL_NAMES[skill_id]):
		return int(costs.get(skill_id, costs.get(RABBIT_SKILL_NAMES[skill_id], RABBIT_SKILL_COSTS[skill_id])))
	return PET_SKILL_PROGRESSION.mana_cost(
		RABBIT_SKILL_COSTS[skill_id], PET_SKILL_PROGRESSION.get_level(pet_data, RABBIT_SKILL_NAMES[skill_id])
	)


func _consume_skill(skill_id: String) -> bool:
	var cost := _skill_cost(skill_id)
	if mp < cost:
		return false
	mp -= cost
	pet_data[DataKeys.MP] = mp
	return true


func try_use_skills() -> void:
	if is_attacking or is_be_attacking or not is_instance_valid(current_target):
		return
	if turtle_stage >= 4 and skill_4_cd <= 0.0 and _has_skill(SKILL_YSAOYI) and mp >= _skill_cost(SKILL_YSAOYI):
		do_rabbit_aoyi()
	elif _rabbit_ice_ready() and _rabbit_ice_target_in_range():
		do_rabbit_ice()
	elif turtle_stage >= 2 and skill_2_cd <= 0.0 and _has_skill(SKILL_JF) and mp >= _skill_cost(SKILL_JF):
		do_rabbit_jifeng()


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
	var gap := absf(current_target.global_position.x - global_position.x)

	var desired_range := RABBIT_ICE_FORWARD_RANGE if _rabbit_ice_ready() else float(attack_range)
	if gap > desired_range:
		if current_target.global_position.x > global_position.x:
			move_right()
		else:
			move_left()
	else:
		stop_move()
		to_monster()
		var interval := 34 if _jifeng_active() else 48
		if count % interval == 0 and randi_range(0, 100) < attack_desire:
			do_hit_1()


func _rabbit_ice_ready() -> bool:
	return turtle_stage >= 3 and skill_3_cd <= 0.0 and _has_skill(SKILL_BS) and mp >= _skill_cost(SKILL_BS)


func _rabbit_ice_target_in_range() -> bool:
	return (
		is_instance_valid(current_target)
		and absf(current_target.global_position.x - global_position.x) <= RABBIT_ICE_FORWARD_RANGE
	)


func do_rabbit_jifeng() -> void:
	if not _consume_skill(SKILL_JF):
		return
	skill_2_cd = RABBIT_SKILL_CDS[SKILL_JF] * pet_skill_cooldown_multiplier
	_jifeng_until_msec = Time.get_ticks_msec() + (5000 if turtle_stage == 2 else 10000)

	_spawn_rabbit_effect(
		"pet_pet_rabbit_jf_buff",
		_rabbit_role_origin() + Vector2(0, 20),
		{},
		Vector2.ZERO,
		true,
		float(_jifeng_until_msec - Time.get_ticks_msec()) / 1000.0
	)


func do_rabbit_ice() -> void:
	if not _consume_skill(SKILL_BS):
		return
	_face_current_target()
	skill_3_cd = RABBIT_SKILL_CDS[SKILL_BS] * pet_skill_cooldown_multiplier
	hit_name = "hit3"
	_start_turtle_action("hit2")
	_rabbit_ice_was_fly = is_fly
	_rabbit_ice_forced_fly = true
	_rabbit_ice_start_y = global_position.y
	is_fly = true


func do_rabbit_aoyi() -> void:
	if not _consume_skill(SKILL_YSAOYI):
		return
	skill_4_cd = RABBIT_SKILL_CDS[SKILL_YSAOYI] * pet_skill_cooldown_multiplier
	_aoyi_until_msec_rabbit = Time.get_ticks_msec() + 10000
	_heal_accumulator = 0.0
	_aoyi_heal_ticks_remaining = 10
	_find_pet_turtle_player_reference()

	_spawn_rabbit_effect(
		"pet_rabbit_4_aoyi_buff", _rabbit_role_origin() + Vector2(0, -120), {}, Vector2.ZERO, true, 10.0
	)


func _process_rabbit_buffs(delta: float) -> void:
	if _aoyi_heal_ticks_remaining <= 0:
		return
	_heal_accumulator += delta
	while _heal_accumulator >= 1.0 and _aoyi_heal_ticks_remaining > 0:
		_heal_accumulator -= 1.0
		_aoyi_heal_ticks_remaining -= 1

		var heal_multiplier := PET_SKILL_PROGRESSION.damage_multiplier(
			PET_SKILL_PROGRESSION.get_level(pet_data, RABBIT_SKILL_NAMES[SKILL_YSAOYI])
		)
		cure_hp(maxi(1, int(float(max_hp) * 0.1 * heal_multiplier)))
		_heal_rabbit_aoyi_player()


func _heal_rabbit_aoyi_player() -> void:
	if not is_instance_valid(player_reference):
		_find_pet_turtle_player_reference()
	if not is_instance_valid(player_reference) and RoleProp.source_player is BaseHero:
		player_reference = RoleProp.source_player as BaseHero
	if not is_instance_valid(player_reference):
		return
	var heal_multiplier := PET_SKILL_PROGRESSION.damage_multiplier(
		PET_SKILL_PROGRESSION.get_level(pet_data, RABBIT_SKILL_NAMES[SKILL_YSAOYI])
	)
	player_reference.cure_hp(maxi(1, int(float(RoleProp.roleprop.SHp) * 0.1 * heal_multiplier)))


func _jifeng_active() -> bool:
	return Time.get_ticks_msec() < _jifeng_until_msec


func _rabbit_aoyi_active() -> bool:
	return Time.get_ticks_msec() < _aoyi_until_msec_rabbit


func _turtle_action_total_ticks(action_name: String) -> int:
	var total := 0
	for stop_count in (RABBIT_ACTIONS[turtle_stage] as Dictionary).get(action_name, []):
		total += int(stop_count)
	return total


func _set_turtle_action_visual(action_name: String, action_tick: int) -> void:
	if (
		turtle_sprite == null
		or turtle_sprite.sprite_frames == null
		or not turtle_sprite.sprite_frames.has_animation(action_name)
	):
		return
	turtle_sprite.animation = action_name
	turtle_sprite.pause()
	var running := 0
	var frame_index := 0
	for stop_count in (RABBIT_ACTIONS[turtle_stage] as Dictionary).get(action_name, []):
		running += int(stop_count)
		if action_tick <= running:
			break
		frame_index += 1
	turtle_sprite.frame = clampi(frame_index, 0, turtle_sprite.sprite_frames.get_frame_count(action_name) - 1)
	_sync_turtle_model_facing()


func _process_turtle_action_triggers() -> void:
	if _turtle_action == "hit1":
		var trigger := 16 if turtle_stage == 1 else 18 if turtle_stage == 2 else 10
		if _trigger_once("rabbit_hit1", trigger):
			_spawn_normal_attack()
	elif _turtle_action == "hit2":
		if _trigger_once("rabbit_ice_buff", 10):
			_spawn_rabbit_effect(
				"pet_pet_rabbit_bullet_buff",
				_rabbit_role_origin() + _front_offset(20, -70),
				{},
				Vector2.ZERO,
				false,
				16.0 / 24.0
			)
		if _trigger_once("rabbit_ice", 11):
			_spawn_rabbit_effect(
				"pet_pet_rabbit_bullet_4",
				_rabbit_ice_impact_position(),
				obj_attack_dict["hit3"],
				Vector2(500, 250),
				false,
				40.0 / 24.0
			)


func _finish_turtle_action() -> void:
	var finished := _turtle_action
	super._finish_turtle_action()
	if finished == "hit2":
		_restore_rabbit_ice_gravity()


func _start_turtle_action(action_name: String) -> void:
	if _turtle_action == "hit2" and action_name != "hit2":
		_restore_rabbit_ice_gravity()
	super._start_turtle_action(action_name)


func _restore_rabbit_ice_gravity() -> void:
	if not _rabbit_ice_forced_fly:
		return
	_rabbit_ice_forced_fly = false
	is_fly = _rabbit_ice_was_fly
	velocity.y = 0.0


func _spawn_normal_attack() -> void:
	_spawn_rabbit_effect(
		"pet_pet_rabbit_bullet_1",
		_rabbit_role_origin() + _front_offset(30, 0),
		obj_attack_dict["hit1"],
		Vector2(70, 70),
		false,
		1.8
	)


func _rabbit_role_origin() -> Vector2:
	return global_position + Vector2(0, float(RABBIT_ROLE_ORIGIN_Y.get(turtle_stage, -15.0)))


func _rabbit_ice_impact_position() -> Vector2:
	var x_offset := 210.0 if monster_direction else -210.0
	var y_offset := -40.0 if turtle_stage == 3 else 50.0
	return _rabbit_role_origin() + Vector2(x_offset, y_offset)


func on_rabbit_attack_hit(hit_position: Vector2) -> void:
	if not _has_skill(SKILL_YG):
		return
	var chance: float = float({1: 0.15, 2: 0.2, 3: 0.25, 4: 0.3}.get(turtle_stage, 0.15))
	if _rabbit_aoyi_active():
		chance = 0.5
	if randf() < float(chance):
		_spawn_rabbit_effect(
			"monster_130_bullet_2",
			hit_position + Vector2(0, -40),
			obj_attack_dict["hit2"],
			Vector2(120, 220),
			false,
			1.3
		)


func _spawn_rabbit_effect(
	effect_name: String,
	effect_position: Vector2,
	attack_data: Dictionary,
	hit_size: Vector2,
	follow: bool,
	lifetime: float
) -> Node:
	if bullet == null:
		return null
	var instance = PET_RABBIT_BULLET_SCENE.instantiate()
	instance.att_list = attack_data
	instance.hit_name = (
		"hit2"
		if effect_name == "monster_130_bullet_2"
		else "hit3" if effect_name == "pet_pet_rabbit_bullet_4" else "hit1"
	)
	instance.dir = monster_direction
	instance.skill_name = effect_name
	instance.speed = 1.0
	instance.set_meta("summoner", self)
	instance.set_meta("pet_rabbit_hit_size", hit_size)
	instance.set_meta("pet_rabbit_follow", follow)
	instance.set_meta("pet_rabbit_lifetime", lifetime)
	if follow:
		instance.set_meta("pet_rabbit_follow_offset", effect_position - global_position)

	instance.position = effect_position
	bullet.add_child(instance)
	instance.global_position = effect_position
	setup_bullet_collision(instance)
	return instance


func _setup_turtle_model_frames() -> void:
	var frames := (
		ResourceLoader.load(RABBIT_MODEL_FRAMES_RES % turtle_stage, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE)
		as SpriteFrames
	)
	if frames == null:
		push_error("PetRabbit SpriteFrames missing for stage %d" % turtle_stage)
		return
	turtle_sprite.sprite_frames = frames
	_play_turtle_model_animation("wait")


func _apply_turtle_stage_scene_layout() -> void:
	var packed := _get_rabbit_stage_scene(turtle_stage)
	if packed == null:
		return
	var template := packed.instantiate()
	var template_sprite := template.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if template_sprite != null:
		turtle_sprite.position = template_sprite.position
		turtle_sprite.offset = template_sprite.offset
		turtle_sprite.scale = template_sprite.scale
	for path in ["BaseDamageBox/HitBox/HitBox", "BaseDamageBox/HurtBox/HurtBox", "pz"]:
		_copy_turtle_collision_layout(template, NodePath(path))
	template.free()


static func _get_rabbit_stage_scene(stage: int) -> PackedScene:
	if _rabbit_scene_cache.has(stage):
		return _rabbit_scene_cache[stage] as PackedScene
	var scene := (
		ResourceLoader.load(RABBIT_SCENE_RES % stage, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	)
	if scene != null:
		_rabbit_scene_cache[stage] = scene
	return scene


func _exit_tree() -> void:
	_restore_rabbit_ice_gravity()
	_jifeng_until_msec = 0
	_aoyi_until_msec_rabbit = 0
	_aoyi_heal_ticks_remaining = 0
	super._exit_tree()

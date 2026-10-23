extends "res://Script/base/summon_base_monster.gd"
class_name PetTurtleSummonBase

@export var turtle_stage: int = 1

const SKILL_SLD := "sld"
const SKILL_TXLJ := "txlj"
const SKILL_SYBH := "sybh"
const SKILL_XWAOYI := "xwaoyi"
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
const PET_LEARNED_SKILL_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const SKILL_NAMES := {
	SKILL_SLD: "水疗盾",
	SKILL_TXLJ: "同心链接",
	SKILL_SYBH: "水湮八荒",
	SKILL_XWAOYI: "玄武奥义",
}
const SKILL_MP_COSTS := {
	SKILL_SLD: 50,
	SKILL_TXLJ: 70,
	SKILL_SYBH: 90,
	SKILL_XWAOYI: 100,
}
const SKILL_INITIAL_COOLDOWNS := {
	SKILL_SLD: 5.0,
	SKILL_TXLJ: 5.0,
	SKILL_SYBH: 6.0,
	SKILL_XWAOYI: 30.0,
}
const SKILL_COOLDOWNS := {
	SKILL_SLD: 10.0,
	SKILL_TXLJ: 45.0,
	SKILL_SYBH: 12.0,
	SKILL_XWAOYI: 60.0,
}
const TURTLE_STAGE_NAMES := {1: "龟布", 2: "墨玄龟", 3: "玄武将军", 4: "玄武大帝"}
const TURTLE_STAGE_SKILLS := {
	1: ["水疗盾"],
	2: ["水疗盾", "同心链接"],
	3: ["水疗盾", "同心链接", "水湮八荒"],
	4: ["水疗盾", "同心链接", "水湮八荒", "玄武奥义"],
}
const TURTLE_ACTION_TICK_RATE := 24.0
const TURTLE_MODEL_FRAMES_RES := "res://Art/pet/pet_turtle/model/pet_turtle_stage%d_frames.tres"
const TURTLE_SCENE_RES := "res://Scene/pet/pet_turtle_summon_%d.tscn"
const TURTLE_BUFF_TEXTURE := "res://Art/pet/pet_turtle/effects/pet_turtle_2_buff/1.png"
const PET_TURTLE_BULLET_SCENE := preload("res://Scene/pet/pet_turtle_bullet.tscn")
const TURTLE_NORMAL_ATTACK_RANGES := {1: 40, 2: 70, 3: 70, 4: 70}
const TURTLE_WATER_SHIELD_HIT_SIZE := Vector2(500, 340)
const TURTLE_ORIGINAL_SPRITE_OFFSETS := {
	1: Vector2(1, -10),
	2: Vector2(1, -10),
	3: Vector2(21, 5),
	4: Vector2(21, -17),
}
const ACTION_STOP_COUNTS := {
	1:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [2, 2, 2, 3, 2, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 2],
		"hit1": [2, 2, 10],
		"hit2": [2, 2, 10],
	},
	2:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 2],
		"hit1": [2, 2, 2, 10],
		"hit2": [2, 2, 10],
	},
	3:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 2],
		"hit1": [2, 2, 2, 10],
		"hit2": [2, 2, 10],
		"hit3": [2, 2, 10],
	},
	4:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 2],
		"hit1": [2, 2, 2, 10],
		"hit2": [2, 2, 10],
		"hit3": [2, 2, 10],
	},
}

static var _turtle_scene_cache: Dictionary = {}

var pet_data: Dictionary = {}
var max_mp: int = 1
var mp: int = 1
var hp_recover_per_second: int = 0
var mp_recover_per_second: int = 0
var recovery_timer := 0.0
var pet_skill_cooldown_multiplier := 1.0
var is_aoyi := false

var _turtle_action := ""
var _turtle_action_tick := 0
var _turtle_action_accumulator := 0.0
var _turtle_action_triggered: Dictionary = {}
var _death_started := false
var _skill_cast_frame := -1
var _aoyi_token := 0
var _aoyi_until_msec := 0
var _link_until_msec := 0
var _link_percent := 0
var _turtle_link_visual: Sprite2D = null
var _hero_link_visual: Sprite2D = null
var _aoyi_visual: Sprite2D = null

@onready var turtle_sprite: AnimatedSprite2D = $MonsterDir/mr_ani


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_turtle_unit", true)
	set_meta("is_summon", true)
	if is_in_group("monsters"):
		remove_from_group("monsters")
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	setup_skills()
	_setup_turtle_model_frames()
	_get_turtle_stage_scene(turtle_stage)
	if hurt_box != null:
		hurt_box.disabled = false
	if hit_box != null:
		hit_box.disabled = true


func _initialize_summon_base() -> void:
	randomize()
	ran_num = randi_range(0, 100)
	rndi_count = randi_range(0, 100)
	if has_node("CalmHit"):
		$CalmHit.start(1.0)
	if not has_node("Buff"):
		var buff_node := Node.new()
		buff_node.name = "Buff"
		add_child(buff_node)
		buff = buff_node
	init_speed = speed
	if base_damage_box == null:
		base_damage_box = get_node_or_null("BaseDamageBox") as Node2D
	if monster_dir == null:
		monster_dir = get_node_or_null("MonsterDir") as Node2D
	if base_damage_box != null:
		base_damage_box.scale.x = 1
	if monster_dir != null:
		monster_dir.scale.x = 1
	_find_pet_turtle_player_reference()
	current_state = State.IDLE


func _physics_process(delta: float) -> void:
	if is_aoyi:
		velocity = Vector2.ZERO
	_tick_turtle_action(delta)
	super(delta)
	if is_aoyi:
		velocity = Vector2.ZERO


func _process(delta: float) -> void:
	_process_pet_turtle_recovery(delta)
	_process_turtle_link()
	_process_turtle_aoyi()


func _get_gravity() -> float:
	if is_aoyi:
		return 0.0
	return -2280.0 if can_set_gravity() else 0.0


func is_super_armor() -> bool:
	return is_aoyi or super()


func apply_pet_data(data: Dictionary) -> void:
	var previous_stage := turtle_stage
	var previous_skills := _learned_skills().duplicate(true)
	pet_data = data.duplicate(true)
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	if is_node_ready() and turtle_sprite != null:
		if previous_stage != turtle_stage:
			_apply_turtle_stage_scene_layout()
		_setup_turtle_model_frames()
		_unlock_new_stage_skill_cooldowns(previous_skills)


func _pet_stage_from_data(data: Dictionary, fallback: int) -> int:
	var pet_level := int(data.get(DataKeys.LEVEL, fallback))
	var level_stage := 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	return maxi(level_stage, clampi(int(data.get("阶段", fallback)), 1, 4))


func setup_pet_turtle(stage: int) -> void:
	turtle_stage = clampi(stage, 1, 4)
	pet_data["阶段"] = turtle_stage
	pet_data[DataKeys.TYPE] = "PetTurtle"
	pet_data[DataKeys.ALT_NAME] = TURTLE_STAGE_NAMES[turtle_stage]
	pet_data[DataKeys.NAME] = TURTLE_STAGE_NAMES[turtle_stage]
	pet_data["技能"] = (TURTLE_STAGE_SKILLS[turtle_stage] as Array).duplicate(true)
	var pet_level := int(pet_data.get(DataKeys.LEVEL, 1))
	var hp_max := int(pet_data.get("生命上限", 620))
	var mp_max := int(pet_data.get("魔法上限", 180))
	var equipment_bonus: Dictionary = {}
	if PlayerData.has_method("get_pet_equipment_bonuses"):
		equipment_bonus = PlayerData.get_pet_equipment_bonuses(pet_data)
	var hp_bonus := int(equipment_bonus.get(DataKeys.HP, 0))
	var mp_bonus := int(equipment_bonus.get(DataKeys.MP, 0))
	var passive_value = pet_data.get("被动技能", {})
	var passive: Dictionary = passive_value if passive_value is Dictionary else {}
	var passive_hp := int(PaSkill.get_value("热血", int(passive.get("热血", 0))))
	var passive_mp := int(PaSkill.get_value("魔泉", int(passive.get("魔泉", 0))))
	level = maxi(1, pet_level)
	my_mr_name = str(TURTLE_STAGE_NAMES[turtle_stage])
	attack_in = maxi(1, int(pet_data.get(DataKeys.ATTACK, 65)) + int(equipment_bonus.get(DataKeys.ATTACK, 0)))
	attack_in += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "天生蛮力", attack_in)
	max_hp = maxi(1, hp_max + hp_bonus + passive_hp)
	var learned_hp_bonus := PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "生命祝福", max_hp)
	max_hp += learned_hp_bonus
	var current_hp := int(pet_data.get(DataKeys.HP, hp_max))
	hp = 0 if current_hp <= 0 else clampi(current_hp + hp_bonus + passive_hp + learned_hp_bonus, 0, max_hp)
	max_mp = maxi(1, mp_max + mp_bonus + passive_mp)
	var learned_mp_bonus := PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "魔法庇佑", max_mp)
	max_mp += learned_mp_bonus
	var current_mp := int(pet_data.get(DataKeys.MP, mp_max))
	mp = 0 if current_mp <= 0 else clampi(current_mp + mp_bonus + passive_mp + learned_mp_bonus, 0, max_mp)
	hp_recover_per_second = (
		int(pet_data.get("回血", 2))
		+ int(equipment_bonus.get("回血", 0))
		+ int(PaSkill.get_value("永恒", int(passive.get("永恒", 0))))
	)
	mp_recover_per_second = (
		int(pet_data.get("回魔", 1))
		+ int(equipment_bonus.get("回魔", 0))
		+ int(PaSkill.get_value("辉煌", int(passive.get("辉煌", 0))))
	)
	self_rhp = hp_recover_per_second
	def = int(pet_data.get(DataKeys.DEFENSE, pet_data.get("物防", 60))) + int(equipment_bonus.get(DataKeys.DEFENSE, 0))
	def += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "自然守护", def)
	mdef = (
		int(pet_data.get("魔防", pet_data.get("魔抗", pet_data.get(DataKeys.DEFENSE, pet_data.get("物防", 60)))))
		+ int(equipment_bonus.get("魔防", 0))
	)
	mdef += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "自然守护", mdef)
	crit = (
		int(pet_data.get("暴击", 12))
		+ int(equipment_bonus.get("暴击", 0))
		+ int(PaSkill.get_value("狂暴", int(passive.get("狂暴", 0))))
	)
	miss = int(pet_data.get("闪避", 6)) + int(equipment_bonus.get("闪避", 0))
	htarget = (
		int(pet_data.get("命中", 0))
		+ int(equipment_bonus.get("命中", 0))
		+ int(PaSkill.get_value("敏锐", int(passive.get("敏锐", 0))))
	)
	lucky = int(pet_data.get("幸运", 10)) + int(equipment_bonus.get("幸运", 0))
	toughness = int(pet_data.get("韧性", 0)) + int(equipment_bonus.get("韧性", 0))
	ar = int(pet_data.get("破甲", 0)) + int(equipment_bonus.get("破甲", 0))
	sp = int(pet_data.get("破魔", 0)) + int(equipment_bonus.get("破魔", 0))
	crit_reduce = int(pet_data.get("暴免", 0)) + int(equipment_bonus.get("暴免", 0))
	pet_skill_cooldown_multiplier = 1.0 - float(clampi(int(pet_data.get("灵力", 0)), 0, 25)) * 0.02
	speed = 14
	init_speed = speed
	attack_range = int(TURTLE_NORMAL_ATTACK_RANGES.get(turtle_stage, 150))
	mysee = 99999
	attack_desire = 100
	is_boss = false
	add_exp = 0
	fall_coin = 0
	_rebuild_pet_turtle_attack_data()


func apply_pet_develop_effects(data: Dictionary) -> void:
	var previous_multiplier := maxf(0.01, pet_skill_cooldown_multiplier)
	for key in ["悟性", "根骨", "灵力"]:
		pet_data[key] = clampi(int(data.get(key, pet_data.get(key, 0))), 0, 25)
	pet_skill_cooldown_multiplier = 1.0 - float(pet_data["灵力"]) * 0.02
	var ratio := pet_skill_cooldown_multiplier / previous_multiplier
	skill_1_cd = maxf(0.0, skill_1_cd * ratio)
	skill_2_cd = maxf(0.0, skill_2_cd * ratio)
	skill_3_cd = maxf(0.0, skill_3_cd * ratio)
	skill_4_cd = maxf(0.0, skill_4_cd * ratio)
	_rebuild_pet_turtle_attack_data()
	if _link_active():
		_apply_turtle_link(true)


func _rebuild_pet_turtle_attack_data() -> void:
	var root_rate := 1.0 + float(clampi(int(pet_data.get("根骨", 0)), 0, 25)) * 0.02
	var normal_power := maxi(1, int(float(attack_in) * root_rate))
	var water_power := PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * 6.0 * root_rate)), pet_data, SKILL_NAMES[SKILL_SLD]
	)
	var sybh_power := PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * 6.0 * root_rate)), pet_data, SKILL_NAMES[SKILL_SYBH]
	)
	var aoyi_power := PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * 6.0 * root_rate)), pet_data, SKILL_NAMES[SKILL_XWAOYI]
	)
	obj_attack_dict["hit1"] = _attack_dic(normal_power, [6, -5], "physics", 24)
	obj_attack_dict["hit2"] = _attack_dic(water_power, [0, 0], "magic", 24)
	obj_attack_dict["hit3"] = _attack_dic(sybh_power, [0, 0], "magic", 24)
	obj_attack_dict["hit4"] = _attack_dic(aoyi_power, [0, 0], "magic", 24)


func _attack_dic(power: int, hurt_back: Array, kind: String, interval: int) -> Dictionary:
	return {
		"power": power,
		"hurtBack": hurt_back,
		"attackKind": kind,
		"attackInterval": interval,
		"hitMaxCount": 99,
		"HitProtect": 0,
	}


func setup_skills() -> void:
	skill_1_cd = SKILL_INITIAL_COOLDOWNS[SKILL_SLD] * pet_skill_cooldown_multiplier
	skill_2_cd = SKILL_INITIAL_COOLDOWNS[SKILL_TXLJ] * pet_skill_cooldown_multiplier
	skill_3_cd = SKILL_INITIAL_COOLDOWNS[SKILL_SYBH] * pet_skill_cooldown_multiplier
	skill_4_cd = SKILL_INITIAL_COOLDOWNS[SKILL_XWAOYI] * pet_skill_cooldown_multiplier


func _unlock_new_stage_skill_cooldowns(previous_skills: Array) -> void:
	for skill_id in [SKILL_SLD, SKILL_TXLJ, SKILL_SYBH, SKILL_XWAOYI]:
		var skill_name := str(SKILL_NAMES[skill_id])
		if previous_skills.has(skill_name) or previous_skills.has(skill_id) or not _has_skill(skill_id):
			continue
		match skill_id:
			SKILL_SLD:
				skill_1_cd = 0.0
			SKILL_TXLJ:
				skill_2_cd = 0.0
			SKILL_SYBH:
				skill_3_cd = 0.0
			SKILL_XWAOYI:
				skill_4_cd = 0.0


func _learned_skills() -> Array:
	var skills = pet_data.get("技能", [])
	return skills if skills is Array else []


func _has_skill(skill_id: String) -> bool:
	var skills := _learned_skills()
	return skills.has(skill_id) or skills.has(SKILL_NAMES[skill_id])


func _skill_cost(skill_id: String) -> int:
	var costs_value = pet_data.get("技能蓝耗", {})
	var costs: Dictionary = costs_value if costs_value is Dictionary else {}
	if costs.has(skill_id) or costs.has(SKILL_NAMES[skill_id]):
		return int(costs.get(skill_id, costs.get(SKILL_NAMES[skill_id], SKILL_MP_COSTS[skill_id])))
	return PET_SKILL_PROGRESSION.mana_cost(
		SKILL_MP_COSTS[skill_id], PET_SKILL_PROGRESSION.get_level(pet_data, SKILL_NAMES[skill_id])
	)


func _can_use_skill(skill_id: String) -> bool:
	return _has_skill(skill_id) and mp >= _skill_cost(skill_id)


func _consume_skill(skill_id: String) -> bool:
	var cost := _skill_cost(skill_id)
	if mp < cost:
		return false
	mp -= cost
	pet_data[DataKeys.MP] = mp
	return true


func _process_pet_turtle_recovery(delta: float) -> void:
	if hp <= 0:
		return
	recovery_timer += delta
	if recovery_timer < 1.0:
		return
	recovery_timer -= 1.0
	if hp_recover_per_second > 0 and hp < max_hp:
		cure_hp(hp_recover_per_second)
	if mp_recover_per_second > 0 and mp < max_mp:
		mp = mini(max_mp, mp + mp_recover_per_second)
		pet_data[DataKeys.MP] = mp


func try_use_skills() -> void:
	if is_aoyi or is_attacking or is_be_attacking or not is_instance_valid(current_target):
		return
	var physics_frame := Engine.get_physics_frames()
	if _skill_cast_frame == physics_frame:
		return
	if turtle_stage >= 4 and skill_4_cd <= 0.0 and _can_use_skill(SKILL_XWAOYI):
		do_xwaoyi()
	elif turtle_stage >= 3 and skill_3_cd <= 0.0 and _can_use_skill(SKILL_SYBH):
		do_sybh()
	elif turtle_stage >= 2 and skill_2_cd <= 0.0 and _can_use_skill(SKILL_TXLJ):
		do_txlj()
	elif skill_1_cd <= 0.0 and _is_target_in_water_shield_range(current_target) and _can_use_skill(SKILL_SLD):
		do_sld()


func ai_think() -> void:
	if is_aoyi or is_attacking or is_be_attacking:
		return
	if not is_instance_valid(current_target) or current_target.hp <= 0:
		current_target = null
		follow_player_when_idle()
		return
	var distance := global_position.distance_to(current_target.global_position)
	if distance >= mysee:
		current_target = null
		has_target = false
		follow_player_when_idle()
		return
	has_target = true
	try_use_skills()
	if is_attacking or is_aoyi or _skill_cast_frame == Engine.get_physics_frames():
		return
	var attack_gap := _horizontal_attack_gap(current_target)
	if attack_gap > attack_range:
		if current_target.global_position.x > global_position.x:
			move_right()
		else:
			move_left()
	else:
		stop_move()
		to_monster()
		if count % 48 == 0 and randi_range(0, 100) < attack_desire:
			do_hit_1()


func _horizontal_attack_gap(target: Node2D) -> float:
	if target == null:
		return INF
	var center_distance := absf(global_position.x - target.global_position.x)
	return maxf(0.0, center_distance - _body_collision_half_width(self) - _body_collision_half_width(target))


func _is_target_in_water_shield_range(target: Node2D) -> bool:
	if target == null:
		return false
	var target_position := target.global_position
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape != null:
		target_position = hurt_shape.global_position
	var shield_center := global_position + Vector2(0, _water_shield_y_offset())
	var local_delta := target_position - shield_center
	return (
		absf(local_delta.x) <= TURTLE_WATER_SHIELD_HIT_SIZE.x * 0.5
		and absf(local_delta.y) <= TURTLE_WATER_SHIELD_HIT_SIZE.y * 0.5
	)


func _body_collision_half_width(body: Node) -> float:
	if body == null:
		return 0.0
	var collision := body.get_node_or_null("pz") as CollisionShape2D
	if collision == null or collision.shape == null:
		return 0.0
	var half_width := 0.0
	if collision.shape is RectangleShape2D:
		half_width = (collision.shape as RectangleShape2D).size.x * 0.5
	elif collision.shape is CapsuleShape2D:
		half_width = (collision.shape as CapsuleShape2D).radius
	elif collision.shape is CircleShape2D:
		half_width = (collision.shape as CircleShape2D).radius
	return half_width * absf(collision.global_scale.x)


func do_hit_1() -> void:
	_face_current_target()
	hit_name = "hit1"
	_start_turtle_action("hit1")


func do_sld(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana and not _consume_skill(SKILL_SLD):
		return
	_skill_cast_frame = Engine.get_physics_frames()
	_face_current_target()
	if set_cooldown:
		skill_1_cd = SKILL_COOLDOWNS[SKILL_SLD] * pet_skill_cooldown_multiplier
	hit_name = "hit2"
	_start_turtle_action("hit2")


func do_txlj(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana and not _consume_skill(SKILL_TXLJ):
		return
	_skill_cast_frame = Engine.get_physics_frames()
	if set_cooldown:
		skill_2_cd = SKILL_COOLDOWNS[SKILL_TXLJ] * pet_skill_cooldown_multiplier
	_apply_turtle_link(false)


func do_sybh(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana and not _consume_skill(SKILL_SYBH):
		return
	_skill_cast_frame = Engine.get_physics_frames()
	_face_current_target()
	if set_cooldown:
		skill_3_cd = SKILL_COOLDOWNS[SKILL_SYBH] * pet_skill_cooldown_multiplier
	hit_name = "hit3"
	_start_turtle_action("hit3")


func do_xwaoyi() -> void:
	if not _consume_skill(SKILL_XWAOYI):
		return
	_skill_cast_frame = Engine.get_physics_frames()
	_face_current_target()
	skill_4_cd = SKILL_COOLDOWNS[SKILL_XWAOYI] * pet_skill_cooldown_multiplier
	_aoyi_token += 1
	var token := _aoyi_token
	is_aoyi = true
	_aoyi_until_msec = Time.get_ticks_msec() + 5000
	_show_aoyi_visual()
	if _has_skill(SKILL_SLD):
		do_sld(true, false)
		_delayed_aoyi_water_shield(2.0, token)
		_delayed_aoyi_water_shield(4.0, token)
	if _has_skill(SKILL_TXLJ):
		do_txlj(true, false)
	if _has_skill(SKILL_SYBH):
		_spawn_sybh(true)


func _delayed_aoyi_water_shield(delay: float, token: int) -> void:
	await get_tree().create_timer(delay, false).timeout
	if not is_inside_tree() or hp <= 0 or token != _aoyi_token or not is_aoyi:
		return
	do_sld(true, false)


func _process_turtle_aoyi() -> void:
	if not is_aoyi:
		return
	if hp <= 0 or Time.get_ticks_msec() >= _aoyi_until_msec:
		_cancel_aoyi()


func _cancel_aoyi() -> void:
	if not is_aoyi and _aoyi_visual == null:
		return
	is_aoyi = false
	_aoyi_token += 1
	_aoyi_until_msec = 0
	if is_instance_valid(_aoyi_visual):
		_aoyi_visual.queue_free()
	_aoyi_visual = null


func _show_aoyi_visual() -> void:
	if is_instance_valid(_aoyi_visual):
		_aoyi_visual.queue_free()
	_aoyi_visual = _create_link_visual("PetTurtleAoyiVisual", Vector2(0, -82))
	if _aoyi_visual != null:
		_aoyi_visual.modulate = Color(1.0, 1.0, 1.0, 0.8)


func _apply_turtle_link(refresh_only: bool = false) -> void:
	_find_pet_turtle_player_reference()
	if not is_instance_valid(player_reference):
		return
	if not refresh_only:
		_clear_turtle_link()
	var technique := maxi(1, int(pet_data.get("灵力", 0)))
	var warpower := maxi(1, int(pet_data.get("根骨", 0)))
	var link_multiplier := PET_SKILL_PROGRESSION.damage_multiplier(
		PET_SKILL_PROGRESSION.get_level(pet_data, SKILL_NAMES[SKILL_TXLJ])
	)
	_link_percent = clampi(int(round(float(5 * technique) * link_multiplier)), 5, 100)
	_link_until_msec = Time.get_ticks_msec() + int(round(float(4000 * warpower) * link_multiplier))
	player_reference.set_meta("pet_turtle_link_unit_ref", weakref(self))
	player_reference.set_meta("pet_turtle_link_percent", _link_percent)
	player_reference.set_meta("pet_turtle_link_until_msec", _link_until_msec)
	if not is_instance_valid(_turtle_link_visual):
		_turtle_link_visual = _create_link_visual("PetTurtleLinkVisual", Vector2(0, -50))
	if not is_instance_valid(_hero_link_visual):
		_hero_link_visual = _create_link_visual_for(player_reference, "PetTurtleLinkVisual", Vector2(0, -50))


func _link_active() -> bool:
	if hp <= 0 or _link_until_msec <= Time.get_ticks_msec():
		return false
	if not is_instance_valid(player_reference):
		return false
	var unit_ref = player_reference.get_meta("pet_turtle_link_unit_ref", null)
	if not (unit_ref is WeakRef):
		return false
	return unit_ref.get_ref() == self


func _process_turtle_link() -> void:
	if _link_until_msec > 0 and not _link_active():
		_clear_turtle_link()


func _clear_turtle_link() -> void:
	if is_instance_valid(player_reference):
		var unit_ref = player_reference.get_meta("pet_turtle_link_unit_ref", null)
		if unit_ref is WeakRef and unit_ref.get_ref() == self:
			for key in ["pet_turtle_link_unit_ref", "pet_turtle_link_percent", "pet_turtle_link_until_msec"]:
				if player_reference.has_meta(key):
					player_reference.remove_meta(key)
	if is_instance_valid(_turtle_link_visual):
		_turtle_link_visual.queue_free()
	if is_instance_valid(_hero_link_visual):
		_hero_link_visual.queue_free()
	_turtle_link_visual = null
	_hero_link_visual = null
	_link_until_msec = 0
	_link_percent = 0


func _create_link_visual(node_name: String, local_position: Vector2) -> Sprite2D:
	return _create_link_visual_for(self, node_name, local_position)


func _create_link_visual_for(target: Node, node_name: String, local_position: Vector2) -> Sprite2D:
	if target == null:
		return null
	var texture := ResourceLoader.load(TURTLE_BUFF_TEXTURE, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	if texture == null:
		return null
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.position = local_position
	sprite.z_index = 12
	target.add_child(sprite)
	return sprite


func receive_linked_damage(value: int) -> int:
	if value <= 0 or hp <= 0 or not _link_active():
		return 0
	var before := hp
	reduce_hp(value, player_reference)
	return maxi(0, before - hp)


func receive_linked_heal(value: int) -> int:
	if value <= 0 or hp <= 0 or not _link_active():
		return 0
	return cure_hp(value)


func _heal_linked_hero(value: int) -> void:
	if value <= 0 or not _link_active() or not is_instance_valid(player_reference):
		return
	var had_skip := bool(player_reference.get_meta("pet_turtle_skip_link_heal", false))
	player_reference.set_meta("pet_turtle_skip_link_heal", true)
	player_reference.cure_hp(value)
	if had_skip:
		player_reference.set_meta("pet_turtle_skip_link_heal", true)
	elif player_reference.has_meta("pet_turtle_skip_link_heal"):
		player_reference.remove_meta("pet_turtle_skip_link_heal")


func heal_from_water_shield_damage(value: int) -> void:
	if value <= 0:
		return
	cure_hp(value)
	_heal_linked_hero(value)


func _start_turtle_action(action_name: String) -> void:
	if not (ACTION_STOP_COUNTS[turtle_stage] as Dictionary).has(action_name):
		return
	if action_name != "hurt":
		is_attacking = true
	velocity.x = 0.0
	_turtle_action = action_name
	_turtle_action_tick = 0
	_turtle_action_accumulator = 0.0
	_turtle_action_triggered.clear()
	_set_turtle_action_visual(action_name, 0)


func _tick_turtle_action(delta: float) -> void:
	if _turtle_action.is_empty():
		return
	_turtle_action_accumulator += delta * TURTLE_ACTION_TICK_RATE
	while _turtle_action_accumulator >= 1.0 and not _turtle_action.is_empty():
		_turtle_action_accumulator -= 1.0
		_turtle_action_tick += 1
		_set_turtle_action_visual(_turtle_action, _turtle_action_tick)
		_process_turtle_action_triggers()
		if _turtle_action_tick >= _turtle_action_total_ticks(_turtle_action):
			_finish_turtle_action()


func _turtle_action_total_ticks(action_name: String) -> int:
	var total := 0
	for stop_count in (ACTION_STOP_COUNTS[turtle_stage] as Dictionary).get(action_name, []):
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
	for stop_count in (ACTION_STOP_COUNTS[turtle_stage] as Dictionary).get(action_name, []):
		running += int(stop_count)
		if action_tick <= running:
			break
		frame_index += 1
	turtle_sprite.frame = clampi(frame_index, 0, turtle_sprite.sprite_frames.get_frame_count(action_name) - 1)
	_sync_turtle_model_facing()


func _trigger_once(key: String, expected_tick: int) -> bool:
	if _turtle_action_tick != expected_tick or _turtle_action_triggered.has(key):
		return false
	_turtle_action_triggered[key] = true
	return true


func _process_turtle_action_triggers() -> void:
	match _turtle_action:
		"hit1":
			if _trigger_once("hit1", 10):
				_spawn_normal_attack()
		"hit2":
			if _trigger_once("sld", 10):
				_resolve_water_shield()
		"hit3":
			if _trigger_once("sybh", 10):
				_spawn_sybh(false)


func _finish_turtle_action() -> void:
	var finished := _turtle_action
	_turtle_action = ""
	velocity.x = 0.0
	if finished == "death":
		call_deferred("_handle_death")
		return
	if finished == "hurt":
		is_be_attacking = false
	else:
		is_attacking = false
		hit_name = ""
	_play_turtle_model_animation("wait")


func _spawn_normal_attack() -> void:
	var bullet_name := "pet_turtle_1_bullet_1" if turtle_stage == 1 else "pet_turtle_2_bullet_1"
	var x_offset := 85.0 if turtle_stage == 1 else 55.0 if turtle_stage == 2 else 65.0
	var y_offset := -40.0 if turtle_stage == 1 else -60.0 if turtle_stage == 2 else -75.0
	var hit_size := Vector2(190, 82) if turtle_stage == 1 else Vector2(108, 128)
	_add_turtle_bullet(
		bullet_name, global_position + _front_offset(x_offset, y_offset), "hit1", obj_attack_dict["hit1"], hit_size
	)


func _resolve_water_shield() -> void:
	var y_offset := _water_shield_y_offset()
	_add_turtle_bullet(
		"pet_turtle_1_bullet_2",
		global_position + Vector2(0, y_offset),
		"hit2",
		obj_attack_dict["hit2"],
		TURTLE_WATER_SHIELD_HIT_SIZE,
		true
	)


func _water_shield_y_offset() -> float:
	return -60.0 if turtle_stage == 1 else -75.0 if turtle_stage == 2 else -85.0


func _spawn_sybh(persistent: bool) -> void:
	var attack_key := "hit4" if persistent else "hit3"
	var instance := _add_turtle_bullet(
		"pet_turtle_3_bullet_3",
		global_position + Vector2(0, -20),
		attack_key,
		obj_attack_dict[attack_key],
		Vector2(560, 170)
	)
	if instance == null:
		return
	instance.set_meta("pet_turtle_repeat_count", 3)
	if persistent:
		instance.set_meta("pet_turtle_repeat_duration", 5.0)
		instance.set_meta("pet_turtle_repeat_interval", 2.0)
		instance.set_meta("pet_turtle_lifetime", 5.0)
	else:
		instance.set_meta("pet_turtle_repeat_interval", 0.22)
		instance.set_meta("pet_turtle_lifetime", 0.75)


func _add_turtle_bullet(
	bullet_name: String,
	bullet_position: Vector2,
	attack_name: String,
	attack_data: Dictionary,
	hit_size: Vector2,
	follow_self: bool = false
) -> Node:
	if bullet == null or PET_TURTLE_BULLET_SCENE == null:
		return null
	var instance = PET_TURTLE_BULLET_SCENE.instantiate()
	instance.att_list = attack_data
	instance.hit_name = attack_name
	instance.global_position = bullet_position
	instance.dir = monster_direction
	instance.skill_name = bullet_name
	instance.speed = 1.0
	instance.set_meta("summoner", self)
	instance.set_meta("pet_turtle_summon", true)
	instance.set_meta("pet_turtle_hit_size", hit_size)
	instance.set_meta("pet_turtle_follow_self", follow_self)
	if follow_self:
		instance.set_meta("pet_turtle_follow_offset", bullet_position - global_position)
	bullet.add_child(instance)
	setup_bullet_collision(instance)
	return instance


func setup_bullet_collision(bullet_instance) -> Node:
	if bullet_instance != null and bullet_instance.has_node("middle/HitBox"):
		var area := bullet_instance.get_node("middle/HitBox") as Area2D
		if area != null:
			area.collision_layer = 2
			area.collision_mask = 1024 | 2048
			bullet_instance.set_meta("is_summon_bullet", true)
			bullet_instance.set_meta("summoner", self)
	return bullet_instance


func _front_offset(x: float, y: float) -> Vector2:
	return Vector2(-x if monster_direction else x, y)


func _face_current_target() -> void:
	if is_instance_valid(current_target):
		to_monster()


func move_left() -> void:
	if is_aoyi:
		return
	_face_left()
	velocity.x = -speed * 10
	play_move_animation()


func move_right() -> void:
	if is_aoyi:
		return
	_face_right()
	velocity.x = speed * 10
	play_move_animation()


func to_monster() -> void:
	if not is_instance_valid(current_target) or is_aoyi:
		return
	if current_target.global_position.x > global_position.x:
		_face_right()
	else:
		_face_left()


func _face_left() -> void:
	monster_direction = true
	if base_damage_box != null:
		base_damage_box.scale.x = 1
	if monster_dir != null:
		monster_dir.scale.x = 1
	_sync_turtle_model_facing()


func _face_right() -> void:
	monster_direction = false
	if base_damage_box != null:
		base_damage_box.scale.x = -1
	if monster_dir != null:
		monster_dir.scale.x = -1
	_sync_turtle_model_facing()


func _sync_turtle_model_facing() -> void:
	if turtle_sprite != null:
		turtle_sprite.flip_h = false


func play_move_animation() -> void:
	if not is_attacking and not is_be_attacking and not _death_started:
		_play_turtle_model_animation("walk")


func stop_move() -> void:
	velocity.x = 0.0
	if not is_attacking and not is_be_attacking and not _death_started:
		_play_turtle_model_animation("wait")


func update_animation_and_direction() -> void:
	if is_attacking or is_be_attacking or _death_started:
		return
	if velocity.x > 0:
		_face_right()
	elif velocity.x < 0:
		_face_left()
	_play_turtle_model_animation("walk" if velocity.x != 0 else "wait")


func _play_turtle_model_animation(animation_name: String) -> void:
	if (
		turtle_sprite == null
		or turtle_sprite.sprite_frames == null
		or not turtle_sprite.sprite_frames.has_animation(animation_name)
	):
		return
	_sync_turtle_model_facing()
	if turtle_sprite.animation != animation_name:
		turtle_sprite.play(animation_name)
	elif not turtle_sprite.is_playing():
		turtle_sprite.play()


func _setup_turtle_model_frames() -> void:
	var frames := (
		ResourceLoader.load(TURTLE_MODEL_FRAMES_RES % turtle_stage, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE)
		as SpriteFrames
	)
	if frames == null:
		push_error("PetTurtle SpriteFrames missing for stage %d" % turtle_stage)
		return
	turtle_sprite.sprite_frames = frames
	for animation_name in frames.get_animation_names():
		for frame_index in range(frames.get_frame_count(animation_name)):
			var texture := frames.get_frame_texture(animation_name, frame_index)
			if texture != null:
				texture.get_rid()
	_play_turtle_model_animation("wait")


func state_hurt(attacker: Node) -> void:
	super.state_hurt(attacker)
	if hp <= 0:
		return
	_cancel_aoyi()
	is_attacking = false
	is_be_attacking = true
	hit_name = ""
	_start_turtle_action("hurt")


func reduce_hp(value: int, attacker = null) -> void:
	super.reduce_hp(value, attacker)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	var before := hp
	var was_attacking := is_attacking
	super._on_hurt_box_area_entered(area)
	if hp < before:
		if was_attacking and hp > 0 and not is_super_armor():
			state_hurt(null)


func process_death(_delta: float) -> void:
	velocity = Vector2.ZERO
	if _death_started:
		return
	_death_started = true
	_cancel_aoyi()
	_clear_turtle_link()
	is_be_attacking = false
	hit_name = ""
	_start_turtle_action("death")


func _apply_turtle_stage_scene_layout() -> void:
	var packed_scene := _get_turtle_stage_scene(turtle_stage)
	if packed_scene == null:
		return
	var template := packed_scene.instantiate()
	if template == null:
		return
	var ground_shape := get_node_or_null("pz") as CollisionShape2D
	var old_ground_bottom := _collision_shape_bottom(ground_shape)
	var template_sprite := template.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if template_sprite != null and turtle_sprite != null:
		turtle_sprite.position = template_sprite.position
		turtle_sprite.rotation = template_sprite.rotation
		turtle_sprite.scale = template_sprite.scale
		turtle_sprite.offset = template_sprite.offset
		turtle_sprite.centered = template_sprite.centered
	for path in ["BaseDamageBox/HitBox/HitBox", "BaseDamageBox/HurtBox/HurtBox", "pz"]:
		_copy_turtle_collision_layout(template, NodePath(path))
	var new_ground_bottom := _collision_shape_bottom(ground_shape)
	global_position.y += old_ground_bottom - new_ground_bottom
	template.free()


static func _get_turtle_stage_scene(stage: int) -> PackedScene:
	var cached := _turtle_scene_cache.get(stage) as PackedScene
	if cached != null:
		return cached
	_turtle_scene_cache.clear()
	var loaded := (
		ResourceLoader.load(TURTLE_SCENE_RES % stage, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	)
	if loaded != null:
		_turtle_scene_cache[stage] = loaded
	return loaded


static func clear_cached_scenes() -> void:
	_turtle_scene_cache.clear()


func _copy_turtle_collision_layout(template: Node, path: NodePath) -> void:
	var source := template.get_node_or_null(path) as CollisionShape2D
	var target := get_node_or_null(path) as CollisionShape2D
	if source == null or target == null:
		return
	target.position = source.position
	target.rotation = source.rotation
	target.scale = source.scale
	target.shape = source.shape


func _collision_shape_bottom(collision: CollisionShape2D) -> float:
	if collision == null or collision.shape == null:
		return 0.0
	var half_height := 0.0
	if collision.shape is RectangleShape2D:
		half_height = (collision.shape as RectangleShape2D).size.y * 0.5
	elif collision.shape is CapsuleShape2D:
		half_height = (collision.shape as CapsuleShape2D).height * 0.5
	elif collision.shape is CircleShape2D:
		half_height = (collision.shape as CircleShape2D).radius
	return collision.position.y + half_height * absf(collision.scale.y)


func _find_pet_turtle_player_reference() -> void:
	if is_instance_valid(player_reference):
		return
	var scene := get_tree().current_scene if get_tree() != null else null
	if scene == null or not scene.has_node("Hero"):
		return
	for child in scene.get_node("Hero").get_children():
		if child is BaseHero:
			player_reference = child
			return


func _exit_tree() -> void:
	_cancel_aoyi()
	_clear_turtle_link()
	super._exit_tree()

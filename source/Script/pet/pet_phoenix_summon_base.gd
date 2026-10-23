extends "res://Script/base/summon_base_monster.gd"
class_name PetPhoenixSummonBase

@export var phoenix_stage: int = 1

const PHOENIX_MODEL_FRAMES_RES := "res://Art/pet/pet_phoenix/model/pet_phoenix_stage%d_frames.tres"
const PHOENIX_SCENE_RES := "res://Scene/pet/pet_phoenix_summon_%d.tscn"
const PHOENIX_EFFECT_DIR := "res://Art/pet/pet_phoenix/effects"
const PET_PHOENIX_BULLET_SCENE := preload("res://Scene/pet/pet_tiger_bullet.tscn")
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
const PET_LEARNED_SKILL_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const PHOENIX_STAGE_NAMES := {1: "雀蛋", 2: "炎皇雀", 3: "朱雀将军", 4: "朱雀女皇"}
const SKILL_NAMES := {1: "涅槃", 2: "不死火鸟", 3: "地火燎原", 4: "朱雀奥义"}
const SKILL_MP_COSTS := {1: 35, 2: 45, 3: 65, 4: 90}
const SKILL_COOLDOWNS := {1: 30.0, 2: 12.0, 3: 15.0, 4: 45.0}
const PHOENIX_FALL_GRAVITY := -2280.0
const PHOENIX_FRAME_RATE := 24.0
const PHOENIX_AOYI_RISE_SPEED := -144.0
const PHOENIX_AOYI_DROP_SPEED := 600.0
const PHOENIX_AOYI_FATHER_FRAMES := 48
const PHOENIX_AOYI_HIT6_ALIGN_TIME := 3.0 / PHOENIX_FRAME_RATE
const PHOENIX_AOYI_RELEASE_COUNT := 2
const PHOENIX_SKILL_DAMAGE_INTERVAL := 0.14
const PHOENIX_NIRVANA_TRIGGER_HP_RATIO := 0.5
const PHOENIX_NIRVANA_HEAL_PER_SECOND_RATIO := 0.2
const PHOENIX_NIRVANA_MAX_TIME := 8.0
const PHOENIX_NIRVANA_EGG_BOTTOM_FROM_ORIGIN := 60.5
const PHOENIX_NIRVANA_EGG_CENTER_FROM_ORIGIN := Vector2(-1.5, 40.0)
const PHOENIX_NIRVANA_EGG_HURT_SIZE := Vector2(74.0, 56.0)
const PHOENIX_ATTACK_LOCK_FAILSAFE_TIME := 6.0
const PHOENIX_HURT_LOCK_FAILSAFE_TIME := 0.8

var pet_data: Dictionary = {}
var max_mp: int = 1
var mp: int = 1
var hp_recover_per_second: int = 0
var mp_recover_per_second: int = 0
var recovery_timer: float = 0.0
var pet_skill_cooldown_multiplier: float = 1.0
var _attack_lock: bool = false
var _phoenix_aoyi_active: bool = false
var _phoenix_aoyi_drop_started: bool = false
var _phoenix_aoyi_hit6_elapsed: float = 0.0
var _phoenix_aoyi_hit6_aligned: bool = false
var _phoenix_aoyi_releases_left: int = 0
var _phoenix_aoyi_hit4_damage_times: int = 1
var _phoenix_father_time: float = 0.0
var _phoenix_death_started: bool = false
var _phoenix_nirvana_active: bool = false
var _phoenix_nirvana_elapsed: float = 0.0
var _phoenix_nirvana_heal_timer: float = 0.0
var _phoenix_nirvana_effect_started: bool = false
var _phoenix_nirvana_effect: Node = null
var _phoenix_state_lock_timer: float = 0.0
var _phoenix_hurt_box_saved: bool = false
var _phoenix_hurt_box_position: Vector2 = Vector2.ZERO
var _phoenix_hurt_box_shape: Shape2D = null

@onready var phoenix_sprite: AnimatedSprite2D = $MonsterDir/mr_ani


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_phoenix_unit", true)
	set_meta("is_summon", true)
	if is_in_group("monsters"):
		remove_from_group("monsters")
	setup_pet_phoenix(_pet_stage_from_data(pet_data, phoenix_stage))
	_setup_phoenix_model_frames()
	if hurt_box != null:
		hurt_box.disabled = false
	if hit_box != null:
		hit_box.disabled = true
	if mr_player != null:
		var finished_cb := Callable(self, "_on_phoenix_animation_finished")
		if not mr_player.animation_finished.is_connected(finished_cb):
			mr_player.animation_finished.connect(finished_cb)


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
	_find_pet_phoenix_player_reference()
	setup_skills()
	current_state = State.IDLE


func _process(delta: float) -> void:
	_process_phoenix_nirvana(delta)
	_process_pet_phoenix_recovery(delta)
	_tick_skill_cooldowns(delta)


func _physics_process(delta: float) -> void:
	_tick_phoenix_father(delta)
	_tick_phoenix_state_failsafe(delta)
	super(delta)


func _get_gravity() -> float:
	if _phoenix_aoyi_active and (hit_name == "hit5" or hit_name == "hit6"):
		return 0.0
	return PHOENIX_FALL_GRAVITY if can_set_gravity() else 0.0


func apply_pet_data(data: Dictionary) -> void:
	var previous_stage := phoenix_stage
	pet_data = data.duplicate(true)
	setup_pet_phoenix(_pet_stage_from_data(pet_data, phoenix_stage))
	if is_node_ready() and phoenix_sprite != null:
		if previous_stage != phoenix_stage:
			_apply_phoenix_stage_scene_layout()
		_setup_phoenix_model_frames()


func _pet_stage_from_data(data: Dictionary, fallback: int) -> int:
	var level := int(_pet_get(data, ["等级", "Level", "level"], fallback))
	var level_stage := 1
	if level >= 50:
		level_stage = 4
	elif level >= 30:
		level_stage = 3
	elif level >= 15:
		level_stage = 2
	if data.has("阶段"):
		return max(clampi(int(_pet_get(data, ["阶段"], fallback)), 1, 4), level_stage)
	return max(clampi(fallback, 1, 4), level_stage)


func _phoenix_stage_skill_names(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["涅槃"]
		2:
			return ["涅槃", "不死火鸟"]
		3:
			return ["涅槃", "不死火鸟", "地火燎原"]
		_:
			return ["涅槃", "不死火鸟", "地火燎原", "朱雀奥义"]


func setup_pet_phoenix(stage: int) -> void:
	phoenix_stage = clampi(stage, 1, 4)
	pet_data["阶段"] = phoenix_stage
	pet_data[DataKeys.TYPE] = "PetPhoenix"
	pet_data[DataKeys.ALT_NAME] = PHOENIX_STAGE_NAMES[phoenix_stage]
	pet_data[DataKeys.NAME] = PHOENIX_STAGE_NAMES[phoenix_stage]
	pet_data["技能"] = _phoenix_stage_skill_names(phoenix_stage)
	var level_from_pet := int(_pet_get(pet_data, ["等级", "Level", "level"], 1))
	var attack_from_pet := int(_pet_get(pet_data, [DataKeys.ATTACK], 70))
	var hp_from_pet := int(_pet_get(pet_data, ["生命上限"], 620))
	var equipment_bonus: Dictionary = {}
	if PlayerData.has_method("get_pet_equipment_bonuses"):
		equipment_bonus = PlayerData.get_pet_equipment_bonuses(pet_data)
	var hp_bonus := int(equipment_bonus.get(DataKeys.HP, 0))
	var mp_bonus := int(equipment_bonus.get(DataKeys.MP, 0))
	var passive_value = _pet_get(pet_data, ["被动技能"], {})
	var passive: Dictionary = passive_value if passive_value is Dictionary else {}
	var passive_hp := _pet_passive_value("热血", int(passive.get("热血", 0)))
	var passive_mp := _pet_passive_value("魔泉", int(passive.get("魔泉", 0)))
	my_mr_name = str(_pet_get(pet_data, [DataKeys.ALT_NAME], PHOENIX_STAGE_NAMES[phoenix_stage]))
	attack_in = max(1, attack_from_pet + int(equipment_bonus.get(DataKeys.ATTACK, 0)))
	attack_in += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "天生蛮力", attack_in)
	pet_skill_cooldown_multiplier = 1.0 - float(clampi(int(_pet_get(pet_data, ["灵力"], 0)), 0, 25)) * 0.02
	level = max(1, level_from_pet)
	max_hp = max(1, hp_from_pet + hp_bonus + passive_hp)
	var learned_hp_bonus := PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "生命祝福", max_hp)
	max_hp += learned_hp_bonus
	var base_current_hp := int(_pet_get(pet_data, [DataKeys.HP], hp_from_pet))
	hp = 0 if base_current_hp <= 0 else clampi(base_current_hp + hp_bonus + passive_hp + learned_hp_bonus, 0, max_hp)
	var base_mp_max := int(_pet_get(pet_data, ["魔法上限"], 180))
	max_mp = max(1, base_mp_max + mp_bonus + passive_mp)
	var learned_mp_bonus := PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "魔法庇佑", max_mp)
	max_mp += learned_mp_bonus
	var base_current_mp := int(_pet_get(pet_data, [DataKeys.MP], base_mp_max))
	mp = 0 if base_current_mp <= 0 else clampi(base_current_mp + mp_bonus + passive_mp + learned_mp_bonus, 0, max_mp)
	hp_recover_per_second = (
		int(_pet_get(pet_data, ["回血"], 2))
		+ int(equipment_bonus.get("回血", 0))
		+ int(PaSkill.get_value("永恒", int(passive.get("永恒", 0))))
	)
	mp_recover_per_second = (
		int(_pet_get(pet_data, ["回魔"], 1))
		+ int(equipment_bonus.get("回魔", 0))
		+ int(PaSkill.get_value("辉煌", int(passive.get("辉煌", 0))))
	)
	self_rhp = hp_recover_per_second
	def = int(_pet_get(pet_data, ["物防", "防御"], 60)) + int(equipment_bonus.get(DataKeys.DEFENSE, 0))
	def += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "自然守护", def)
	mdef = int(_pet_get(pet_data, ["魔防", "魔抗"], 60)) + int(equipment_bonus.get("魔防", 0))
	mdef += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "自然守护", mdef)
	crit = (
		int(_pet_get(pet_data, ["暴击"], 12))
		+ int(equipment_bonus.get("暴击", 0))
		+ int(PaSkill.get_value("狂暴", int(passive.get("狂暴", 0))))
	)
	miss = int(_pet_get(pet_data, ["闪避"], 6)) + int(equipment_bonus.get("闪避", 0))
	htarget = (
		int(_pet_get(pet_data, ["命中"], 0))
		+ int(equipment_bonus.get("命中", 0))
		+ int(PaSkill.get_value("敏锐", int(passive.get("敏锐", 0))))
	)
	lucky = int(_pet_get(pet_data, ["幸运"], 10)) + int(equipment_bonus.get("幸运", 0))
	toughness = int(_pet_get(pet_data, ["韧性"], 0)) + int(equipment_bonus.get("韧性", 0))
	ar = int(_pet_get(pet_data, ["破甲"], 0)) + int(equipment_bonus.get("破甲", 0))
	sp = int(_pet_get(pet_data, ["破魔"], 0)) + int(equipment_bonus.get("破魔", 0))
	crit_reduce = int(_pet_get(pet_data, ["暴免"], 0)) + int(equipment_bonus.get("暴免", 0))
	speed = 15
	attack_range = 130
	mysee = 99999
	attack_desire = 100
	is_boss = false
	add_exp = 0
	fall_coin = 0
	_rebuild_pet_attack_data()


func _pet_get(data: Dictionary, keys: Array, fallback):
	for key in keys:
		if data.has(key):
			return data[key]
	return fallback


func _pet_passive_value(passive_name: String, passive_level: int) -> int:
	var passive_node := get_node_or_null("/root/PaSkill")
	if passive_node != null and passive_node.has_method("get_value"):
		return int(passive_node.get_value(passive_name, passive_level))
	return 0


func _process_pet_phoenix_recovery(delta: float) -> void:
	if hp <= 0 or _phoenix_nirvana_active:
		return
	recovery_timer += delta
	if recovery_timer < 1.0:
		return
	recovery_timer -= 1.0
	if hp_recover_per_second > 0 and hp < max_hp:
		cure_hp(hp_recover_per_second)
	if mp_recover_per_second > 0 and mp < max_mp:
		mp = min(max_mp, mp + mp_recover_per_second)
		pet_data[DataKeys.MP] = mp


func _process_phoenix_nirvana(delta: float) -> void:
	if not _phoenix_nirvana_active:
		return
	if hp <= 0:
		_clear_phoenix_nirvana_visual()
		return
	is_attacking = true
	_attack_lock = true
	hit_name = "hit2"
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.disabled = false
		_apply_phoenix_nirvana_hurt_box()
	_phoenix_nirvana_elapsed += delta
	_phoenix_nirvana_heal_timer += delta
	while _phoenix_nirvana_heal_timer >= 1.0 and hp < max_hp:
		_phoenix_nirvana_heal_timer -= 1.0
		var heal_rate := (
			PHOENIX_NIRVANA_HEAL_PER_SECOND_RATIO
			* PET_SKILL_PROGRESSION.damage_multiplier(PET_SKILL_PROGRESSION.get_level(pet_data, SKILL_NAMES[1]))
		)
		var heal_amount: int = maxi(1, int(ceil(float(max_hp) * heal_rate)))
		_apply_phoenix_nirvana_heal(heal_amount)
	if hp >= max_hp or _phoenix_nirvana_elapsed >= PHOENIX_NIRVANA_MAX_TIME:
		if hp < max_hp:
			_apply_phoenix_nirvana_heal(max_hp - hp)
		_finish_phoenix_nirvana()


func _apply_phoenix_nirvana_heal(value: int) -> int:
	if value <= 0 or hp <= 0:
		return 0
	var old_hp: int = hp
	hp = mini(max_hp, hp + value)
	pet_data[DataKeys.HP] = hp
	var actual_heal: int = hp - old_hp
	if actual_heal > 0:
		var level_node: Node = get_level_node()
		if level_node != null:
			call_deferred("_show_heal_text", level_node, Vector2(position.x, position.y - 110), actual_heal)
	return actual_heal


func _tick_skill_cooldowns(delta: float) -> void:
	skill_1_cd = maxf(0.0, skill_1_cd - delta)
	skill_2_cd = maxf(0.0, skill_2_cd - delta)
	skill_3_cd = maxf(0.0, skill_3_cd - delta)
	skill_4_cd = maxf(0.0, skill_4_cd - delta)


func setup_skills() -> void:
	skill_1_cd = 2.0
	skill_2_cd = 4.0
	skill_3_cd = 6.0
	skill_4_cd = 20.0


func _rebuild_pet_attack_data() -> void:
	var bone_multiplier: float = 1.0 + float(clampi(int(_pet_get(pet_data, ["根骨"], 0)), 0, 25)) * 0.02
	var stage_multiplier: float = 1.0 + float(phoenix_stage - 1) * 0.28
	var damage_bl := bone_multiplier * stage_multiplier
	obj_attack_dict["hit1"] = _attack_dic(int(attack_in * 2.0 * damage_bl), [4, -3], "physics", 8)
	obj_attack_dict["hit2"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * 4.5 * damage_bl), pet_data, SKILL_NAMES[1]),
		[0, 0],
		"physics",
		10
	)
	obj_attack_dict["hit3"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * 5.2 * damage_bl), pet_data, SKILL_NAMES[2]),
		[6, -4],
		"physics",
		10
	)
	obj_attack_dict["hit4"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * 6.0 * damage_bl), pet_data, SKILL_NAMES[3]),
		[8, -5],
		"physics",
		12
	)
	obj_attack_dict["hit5"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * 7.0 * damage_bl), pet_data, SKILL_NAMES[4]),
		[8, -5],
		"physics",
		12
	)


func _attack_dic(power: int, hurt_back: Array, kind: String, protect: int) -> Dictionary:
	return {"power": power, "hurtBack": hurt_back, "attackKind": kind, "HitProtect": protect}


func ai_think() -> void:
	if _attack_lock or is_attacking:
		return
	if not is_instance_valid(current_target) or current_target.hp <= 0:
		current_target = null
		follow_player_when_idle()
		return
	var distance: float = abs(position.x - current_target.position.x)
	if distance < mysee:
		has_target = true
		if not is_be_attacking:
			try_use_skills()
		if _attack_lock or is_attacking:
			return
		if distance > attack_range:
			if current_target.position.x > position.x:
				move_right()
			else:
				move_left()
		else:
			stop_move()
			to_monster()
			if not is_be_attacking and count % 45 == 0:
				do_hit_1()
	else:
		current_target = null
		has_target = false
		follow_player_when_idle()


func try_use_skills() -> void:
	if should_in_sky:
		return
	if not is_instance_valid(current_target):
		return
	var distance: float = abs(position.x - current_target.position.x)
	if (
		skill_1_cd <= 0
		and hp > 0
		and max_hp > 0
		and float(hp) / float(max_hp) <= PHOENIX_NIRVANA_TRIGGER_HP_RATIO
		and _can_use_pet_skill(_phoenix_skill_cost(1))
	):
		_use_phoenix_skill("hit2", 1)
	elif phoenix_stage >= 4 and skill_4_cd <= 0 and distance <= 500 and _can_use_pet_skill(_phoenix_skill_cost(4)):
		_use_phoenix_skill("hit5", 4)
	elif phoenix_stage >= 3 and skill_3_cd <= 0 and distance <= 500 and _can_use_pet_skill(_phoenix_skill_cost(3)):
		_use_phoenix_skill("hit4", 3)
	elif phoenix_stage >= 2 and skill_2_cd <= 0 and distance <= 400 and _can_use_pet_skill(_phoenix_skill_cost(2)):
		_use_phoenix_skill("hit3", 2)


func _can_use_pet_skill(cost: int) -> bool:
	return mp >= cost


func _phoenix_skill_cost(skill_index: int) -> int:
	var base_cost := int(SKILL_MP_COSTS.get(skill_index, 0))
	var skill_name := str(SKILL_NAMES.get(skill_index, ""))
	var custom_raw: Variant = pet_data.get("技能蓝耗", {})
	if custom_raw is Dictionary and custom_raw.has(skill_name):
		return int(custom_raw.get(skill_name, base_cost))
	return PET_SKILL_PROGRESSION.mana_cost(base_cost, PET_SKILL_PROGRESSION.get_level(pet_data, skill_name))


func _consume_pet_mp(cost: int) -> bool:
	if mp < cost:
		return false
	mp -= cost
	pet_data[DataKeys.MP] = mp
	return true


func _use_phoenix_skill(anim_name: String, skill_index: int) -> void:
	if not _consume_pet_mp(_phoenix_skill_cost(skill_index)):
		return
	var play_anim_name := anim_name
	var attack_anim_name := anim_name
	match skill_index:
		1:
			_start_phoenix_nirvana()
		2:
			skill_2_cd = SKILL_COOLDOWNS[2] * pet_skill_cooldown_multiplier
		3:
			skill_3_cd = SKILL_COOLDOWNS[3] * pet_skill_cooldown_multiplier
		4:
			skill_4_cd = SKILL_COOLDOWNS[4] * pet_skill_cooldown_multiplier
			_phoenix_aoyi_active = true
			_phoenix_aoyi_drop_started = false
			_phoenix_aoyi_hit6_elapsed = 0.0
			_phoenix_aoyi_hit6_aligned = false
			_phoenix_aoyi_releases_left = PHOENIX_AOYI_RELEASE_COUNT
			_phoenix_aoyi_hit4_damage_times = 2
			_set_phoenix_your_father(PHOENIX_AOYI_FATHER_FRAMES)
			play_anim_name = "hit4"
			attack_anim_name = "hit4"
	_do_phoenix_attack(play_anim_name, attack_anim_name)


func do_hit_1() -> void:
	_do_phoenix_attack("hit1", "hit1")


func _do_phoenix_attack(anim_name: String, attack_name: String) -> void:
	if _attack_lock or hp <= 0:
		return
	_attack_lock = true
	is_attacking = true
	hit_name = attack_name
	to_monster()
	if _play_phoenix_action(anim_name, true):
		return
	_spawn_phoenix_fallback(attack_name)
	_finish_phoenix_attack()


func _start_phoenix_nirvana() -> void:
	_phoenix_nirvana_active = true
	_phoenix_nirvana_elapsed = 0.0
	_phoenix_nirvana_heal_timer = 0.0
	_phoenix_nirvana_effect_started = false
	skill_1_cd = 0.0
	recovery_timer = 0.0
	_phoenix_father_time = 0.0
	_set_phoenix_model_visible(false)
	_apply_phoenix_nirvana_hurt_box()
	_show_phoenix_nirvana_start_effect()


func _finish_phoenix_nirvana() -> void:
	if not _phoenix_nirvana_active:
		return
	_phoenix_nirvana_active = false
	_phoenix_nirvana_elapsed = 0.0
	_phoenix_nirvana_heal_timer = 0.0
	_phoenix_nirvana_effect_started = false
	_clear_phoenix_nirvana_effect()
	_set_phoenix_model_visible(true)
	_restore_phoenix_hurt_box()
	skill_1_cd = SKILL_COOLDOWNS[1] * pet_skill_cooldown_multiplier
	_add_phoenix_bullet("PetPhoenix1Bullet2_2", position, "hit2", obj_attack_dict["hit2"], Vector2(210, 120), true)
	_finish_phoenix_attack()


func _show_phoenix_nirvana_start_effect() -> void:
	if _phoenix_nirvana_effect_started:
		return
	_phoenix_nirvana_effect_started = true
	_phoenix_nirvana_effect = _add_phoenix_bullet(
		"PetPhoenix1Bullet2_1",
		position + _phoenix_nirvana_egg_offset(),
		"hit2",
		obj_attack_dict["hit2"],
		Vector2(210, 120),
		true,
		0.0,
		1,
		false,
		true
	)


func _clear_phoenix_nirvana_visual() -> void:
	_phoenix_nirvana_active = false
	_phoenix_nirvana_elapsed = 0.0
	_phoenix_nirvana_heal_timer = 0.0
	_phoenix_nirvana_effect_started = false
	_clear_phoenix_nirvana_effect()
	_set_phoenix_model_visible(true)
	_restore_phoenix_hurt_box()


func _clear_phoenix_nirvana_effect() -> void:
	if _phoenix_nirvana_effect != null and is_instance_valid(_phoenix_nirvana_effect):
		_phoenix_nirvana_effect.queue_free()
	_phoenix_nirvana_effect = null


func _set_phoenix_model_visible(is_visible: bool) -> void:
	if phoenix_sprite != null:
		phoenix_sprite.visible = is_visible


func _phoenix_nirvana_egg_offset() -> Vector2:
	return Vector2(0.0, _phoenix_ground_y() - PHOENIX_NIRVANA_EGG_BOTTOM_FROM_ORIGIN)


func _phoenix_nirvana_egg_hurt_position() -> Vector2:
	return _phoenix_nirvana_egg_offset() + PHOENIX_NIRVANA_EGG_CENTER_FROM_ORIGIN


func _apply_phoenix_nirvana_hurt_box() -> void:
	if hurt_box == null:
		return
	if not _phoenix_hurt_box_saved:
		_phoenix_hurt_box_saved = true
		_phoenix_hurt_box_position = hurt_box.position
		_phoenix_hurt_box_shape = hurt_box.shape
	var egg_shape := RectangleShape2D.new()
	egg_shape.size = PHOENIX_NIRVANA_EGG_HURT_SIZE
	hurt_box.shape = egg_shape
	hurt_box.position = _phoenix_nirvana_egg_hurt_position()
	hurt_box.disabled = false


func _restore_phoenix_hurt_box() -> void:
	if hurt_box == null or not _phoenix_hurt_box_saved:
		return
	hurt_box.position = _phoenix_hurt_box_position
	hurt_box.shape = _phoenix_hurt_box_shape
	hurt_box.disabled = false
	_phoenix_hurt_box_saved = false


func _play_animation_if_exists(anim_name: String) -> bool:
	return _play_phoenix_action(anim_name, false)


func _play_phoenix_action(anim_name: String, restart: bool = false) -> bool:
	if mr_player == null or not mr_player.has_animation(anim_name):
		return false
	var sprite_needs_restart := restart or _phoenix_sprite_needs_restart(anim_name)
	if not sprite_needs_restart and _phoenix_sprite_is_looping_action(anim_name):
		return true
	if sprite_needs_restart:
		mr_player.stop()
	mr_player.play(anim_name)
	if sprite_needs_restart:
		_restart_phoenix_sprite(anim_name)
	return true


func _phoenix_sprite_is_looping_action(anim_name: String) -> bool:
	if phoenix_sprite == null:
		return false
	if str(phoenix_sprite.animation) != anim_name or not phoenix_sprite.is_playing():
		return false
	return (
		anim_name == "wait"
		or anim_name == "walk"
		or anim_name == "Fly"
		or anim_name == "fly"
		or anim_name == "Fly_wait"
		or anim_name == "fly_wait"
	)


func _phoenix_sprite_needs_restart(anim_name: String) -> bool:
	if phoenix_sprite == null:
		return false
	if str(phoenix_sprite.animation) != anim_name:
		return true
	if not phoenix_sprite.is_playing():
		return true
	return false


func _restart_phoenix_sprite(anim_name: String) -> void:
	if phoenix_sprite == null:
		return
	if phoenix_sprite.sprite_frames == null or not phoenix_sprite.sprite_frames.has_animation(anim_name):
		return
	phoenix_sprite.animation = StringName(anim_name)
	phoenix_sprite.set_frame_and_progress(0, 0.0)
	phoenix_sprite.play(anim_name)


func play_move_animation() -> void:
	if is_fly:
		if _play_phoenix_action("Fly", false) or _play_phoenix_action("fly", false):
			return
	_play_phoenix_action("walk", false)


func stop_move() -> void:
	velocity.x = 0
	if is_fly:
		if _play_phoenix_action("Fly_wait", false) or _play_phoenix_action("fly_wait", false):
			return
	_play_phoenix_action("wait", false)


func reset_attack_state() -> void:
	is_be_attacking = false
	is_attacking = false
	_attack_lock = false
	hit_name = ""
	if death() or should_in_sky:
		return
	if velocity.x != 0:
		play_move_animation()
	else:
		stop_move()


func update_animation_and_direction() -> void:
	if is_attacking or is_be_attacking:
		return
	if velocity.x != 0:
		play_move_animation()
	else:
		_play_phoenix_action("wait", false)
	if velocity.x > 0:
		_face_right()
	elif velocity.x < 0:
		_face_left()


func process_death(_delta: float) -> void:
	if _phoenix_death_started:
		velocity.x = 0
		velocity.y = 0
		return
	_phoenix_death_started = true
	_clear_phoenix_nirvana_visual()
	_attack_lock = false
	is_attacking = false
	is_be_attacking = false
	velocity.x = 0
	velocity.y = 0
	if hit_box != null:
		hit_box.disabled = true
	if hurt_box != null:
		hurt_box.disabled = true
	_play_phoenix_action("death", true)
	call_deferred("_handle_death")


func process_attack(delta: float) -> void:
	velocity.x = 0
	if hit_name == "hit5":
		velocity.y = PHOENIX_AOYI_RISE_SPEED
	elif hit_name == "hit6":
		if not _phoenix_aoyi_drop_started:
			_start_phoenix_aoyi_drop()
		_phoenix_aoyi_hit6_elapsed += delta
		if not _phoenix_aoyi_hit6_aligned and _phoenix_aoyi_hit6_elapsed >= PHOENIX_AOYI_HIT6_ALIGN_TIME:
			_align_phoenix_aoyi_to_target()
		velocity.y = PHOENIX_AOYI_DROP_SPEED


func _start_phoenix_aoyi_drop() -> void:
	_phoenix_aoyi_drop_started = true
	_phoenix_aoyi_hit6_elapsed = 0.0
	_phoenix_aoyi_hit6_aligned = false


func _align_phoenix_aoyi_to_target() -> void:
	_phoenix_aoyi_hit6_aligned = true
	var target: BaseMonster = _get_phoenix_aoyi_target()
	if target == null:
		return
	position.x = target.position.x
	current_target = target
	to_monster()


func _get_phoenix_aoyi_target() -> BaseMonster:
	var candidates: Array[BaseMonster] = []
	for monster_node in all_monsters:
		var monster: BaseMonster = monster_node as BaseMonster
		if _is_valid_phoenix_aoyi_target(monster):
			candidates.append(monster)
	if candidates.is_empty():
		var tree: SceneTree = get_tree()
		if tree != null:
			for node in tree.get_nodes_in_group("monsters"):
				var group_monster: BaseMonster = node as BaseMonster
				if _is_valid_phoenix_aoyi_target(group_monster):
					candidates.append(group_monster)
	if not candidates.is_empty():
		return candidates[randi_range(0, candidates.size() - 1)]
	if _is_valid_phoenix_aoyi_target(current_target):
		return current_target
	return null


func _is_valid_phoenix_aoyi_target(monster: BaseMonster) -> bool:
	return monster != null and is_instance_valid(monster) and monster.hp > 0 and not monster_is_summon(monster)


func _set_phoenix_your_father(frame_count: int) -> void:
	_phoenix_father_time = maxf(_phoenix_father_time, float(frame_count) / PHOENIX_FRAME_RATE)


func _tick_phoenix_father(delta: float) -> void:
	if _phoenix_father_time <= 0.0:
		return
	_phoenix_father_time = maxf(0.0, _phoenix_father_time - delta)


func _tick_phoenix_state_failsafe(delta: float) -> void:
	if hp <= 0 or _phoenix_nirvana_active:
		_phoenix_state_lock_timer = 0.0
		return
	if is_attacking or _attack_lock:
		_phoenix_state_lock_timer += delta
		if _phoenix_state_lock_timer >= PHOENIX_ATTACK_LOCK_FAILSAFE_TIME:
			_phoenix_aoyi_active = false
			_finish_phoenix_attack()
		return
	if is_be_attacking:
		_phoenix_state_lock_timer += delta
		if _phoenix_state_lock_timer >= PHOENIX_HURT_LOCK_FAILSAFE_TIME:
			reset_attack_state()
		return
	_phoenix_state_lock_timer = 0.0


func _phoenix_is_your_father() -> bool:
	return _phoenix_father_time > 0.0


func check_return_to_player() -> void:
	if _phoenix_aoyi_active:
		return
	super.check_return_to_player()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if _phoenix_is_your_father():
		return
	super._on_hurt_box_area_entered(area)


func state_hurt(attacker: Node) -> void:
	super.state_hurt(attacker)
	if hp <= 0 or _phoenix_nirvana_active or is_attacking:
		return
	is_be_attacking = true
	_attack_lock = false
	hit_name = ""
	velocity.x = 0
	if not _play_phoenix_action("hurt", true):
		reset_attack_state()


func call_hit_1_bullet() -> void:
	_add_phoenix_bullet(
		"PetPhoenix1Bullet1", position + _front_offset(75, -30), "hit1", obj_attack_dict["hit1"], Vector2(155, 90)
	)


func call_hy_bullet() -> void:
	if _phoenix_nirvana_active:
		_show_phoenix_nirvana_start_effect()
		return
	_add_phoenix_bullet(
		"PetPhoenix1Bullet2_1",
		position + Vector2(0, -60),
		"hit2",
		obj_attack_dict["hit2"],
		Vector2(210, 120),
		true,
		5.0
	)


func call_sxhz_hit() -> void:
	_add_phoenix_bullet(
		"PetPhoenix2Bullet3",
		position + _front_offset(130, -30),
		"hit3",
		obj_attack_dict["hit3"],
		Vector2(260, 120),
		false,
		0.0,
		2
	)
	if _phoenix_aoyi_active:
		_add_phoenix_bullet(
			"PetPhoenix4Bullet3_2",
			position + Vector2(0, -200),
			"hit3",
			obj_attack_dict["hit3"],
			Vector2(260, 140),
			false,
			0.0,
			2
		)
		_add_phoenix_bullet(
			"PetPhoenix4Bullet3_2",
			position + Vector2(200, -200),
			"hit3",
			obj_attack_dict["hit3"],
			Vector2(260, 140),
			false,
			0.0,
			2
		)
		_add_phoenix_bullet(
			"PetPhoenix4Bullet3_2",
			position + Vector2(-200, -200),
			"hit3",
			obj_attack_dict["hit3"],
			Vector2(260, 140),
			false,
			0.0,
			2
		)


func call_hsqj_bullet() -> void:
	_spawn_phoenix_ground_fire(3, _phoenix_current_hit4_damage_times())


func call_bhaoyi_hit() -> void:
	if hit_name == "hit5":
		_add_phoenix_bullet("PetPhoenix4Bullet5", position, "hit5", obj_attack_dict["hit5"], Vector2(420, 170), true)
	elif hit_name == "hit6":
		_spawn_phoenix_ground_fire(3, 3)


func _spawn_phoenix_fallback(attack_name: String) -> void:
	match attack_name:
		"hit1":
			call_hit_1_bullet()
		"hit2":
			call_hy_bullet()
		"hit3":
			call_sxhz_hit()
		"hit4":
			call_hsqj_bullet()
		"hit5", "hit6":
			call_bhaoyi_hit()


func _phoenix_current_hit4_damage_times() -> int:
	if _phoenix_aoyi_active:
		return max(1, _phoenix_aoyi_hit4_damage_times)
	return 2


func _spawn_phoenix_ground_fire(idx: int, damage_times: int = 1) -> void:
	_add_phoenix_ground_pair(idx, damage_times)
	for next_idx in range(idx - 1, -1, -1):
		_spawn_phoenix_ground_pair_after(float(idx - next_idx) * 0.3, next_idx, damage_times)


func _spawn_phoenix_ground_pair_after(delay: float, idx: int, damage_times: int) -> void:
	await get_tree().create_timer(delay, false).timeout
	if not is_inside_tree() or hp <= 0:
		return
	_add_phoenix_ground_pair(idx, damage_times)


func _add_phoenix_ground_pair(idx: int, damage_times: int = 1) -> void:
	var x_distance := 110 + (3 - idx) * 110
	var ground_y := _phoenix_ground_y()
	var fire_y := _phoenix_ground_effect_y("PetPhoenix3Bullet4", ground_y)
	_add_phoenix_bullet(
		"PetPhoenix3Bullet4",
		position + Vector2(-x_distance, fire_y),
		"hit4",
		obj_attack_dict["hit4"],
		Vector2(180, 150),
		false,
		0.0,
		damage_times
	)
	_add_phoenix_bullet(
		"PetPhoenix3Bullet4",
		position + Vector2(x_distance, fire_y),
		"hit4",
		obj_attack_dict["hit4"],
		Vector2(180, 150),
		false,
		0.0,
		damage_times
	)
	if _phoenix_aoyi_active:
		var aoyi_fire_y := _phoenix_ground_effect_y("PetPhoenix4Bullet6", ground_y)
		_add_phoenix_bullet(
			"PetPhoenix4Bullet6",
			position + Vector2(-x_distance, aoyi_fire_y),
			"hit4",
			obj_attack_dict["hit4"],
			Vector2(180, 150),
			false,
			0.0,
			1
		)
		_add_phoenix_bullet(
			"PetPhoenix4Bullet6",
			position + Vector2(x_distance, aoyi_fire_y),
			"hit4",
			obj_attack_dict["hit4"],
			Vector2(180, 150),
			false,
			0.0,
			1
		)


func _phoenix_ground_y() -> float:
	return _phoenix_collision_shape_bottom(get_node_or_null("pz") as CollisionShape2D)


func _phoenix_ground_effect_y(effect_name: String, ground_y: float) -> float:
	match effect_name:
		"PetPhoenix3Bullet4":
			return ground_y - 57.0
		"PetPhoenix4Bullet6":
			return ground_y - 332.0
	return ground_y


func _add_phoenix_bullet(
	bullet_name: String,
	bullet_position: Vector2,
	attack_name: String,
	attack_data: Dictionary,
	hit_size: Vector2,
	follow_self: bool = false,
	lifetime: float = 0.0,
	damage_times: int = 1,
	damage_enabled: bool = true,
	hold_last_frame: bool = false
) -> Node:
	_sync_attack_facing()
	if bullet == null or PET_PHOENIX_BULLET_SCENE == null:
		return null
	var instance = PET_PHOENIX_BULLET_SCENE.instantiate()
	instance.att_list = attack_data
	instance.hit_name = attack_name
	instance.position = bullet_position
	instance.dir = monster_direction
	instance.skill_name = bullet_name
	instance.speed = 1.0
	instance.set_meta("summoner", self)
	instance.set_meta("pet_phoenix_summon", true)
	instance.set_meta("pet_phoenix_hit_size", hit_size)
	instance.set_meta("pet_phoenix_follow_self", follow_self)
	instance.set_meta("pet_phoenix_damage_times", max(1, damage_times))
	instance.set_meta("pet_phoenix_damage_interval", PHOENIX_SKILL_DAMAGE_INTERVAL)
	if hold_last_frame:
		instance.set_meta("pet_phoenix_hold_last", true)
	if not damage_enabled:
		instance.set_meta("pet_phoenix_disabled", true)
	if follow_self:
		instance.set_meta("pet_phoenix_follow_offset", bullet_position - position)
	if lifetime > 0.0:
		instance.set_meta("pet_phoenix_lifetime", lifetime)
	bullet.add_child(instance)
	setup_bullet_collision(instance)
	return instance


func setup_bullet_collision(bullet_instance) -> Node:
	if bullet_instance and bullet_instance.has_node("middle/HitBox"):
		var area := bullet_instance.get_node("middle/HitBox") as Area2D
		if area != null:
			area.collision_layer = 2
			area.collision_mask = 1024 | 2048
			bullet_instance.set_meta("is_summon_bullet", true)
			bullet_instance.set_meta("summoner", self)
	return bullet_instance


func _sync_attack_facing() -> void:
	if is_instance_valid(current_target):
		to_monster()


func _front_offset(x: float, y: float) -> Vector2:
	return Vector2(-x if monster_direction else x, y)


func move_left() -> void:
	_face_left()
	velocity.x = -speed * 10
	play_move_animation()


func move_right() -> void:
	_face_right()
	velocity.x = speed * 10
	play_move_animation()


func to_monster() -> void:
	if not is_instance_valid(current_target):
		return
	if current_target.position.x > position.x:
		_face_right()
	else:
		_face_left()


func _face_left() -> void:
	monster_direction = true
	if base_damage_box != null:
		base_damage_box.scale.x = 1
	if monster_dir != null:
		monster_dir.scale.x = 1
	_sync_phoenix_model_facing()


func _face_right() -> void:
	monster_direction = false
	if base_damage_box != null:
		base_damage_box.scale.x = -1
	if monster_dir != null:
		monster_dir.scale.x = -1
	_sync_phoenix_model_facing()


func _sync_phoenix_model_facing() -> void:
	if phoenix_sprite == null:
		return
	phoenix_sprite.flip_h = false


func _on_phoenix_animation_finished(anim_name: StringName) -> void:
	var finished_name := str(anim_name)
	if finished_name == "hit2":
		if _phoenix_nirvana_active:
			if hp >= max_hp:
				_finish_phoenix_nirvana()
			else:
				_play_phoenix_action("hit2", true)
		else:
			_finish_phoenix_attack()
	elif finished_name == "hit4":
		if _phoenix_aoyi_active and _phoenix_aoyi_releases_left > 1:
			_phoenix_aoyi_releases_left -= 1
			_phoenix_aoyi_hit4_damage_times = 1
			hit_name = "hit4"
			velocity = Vector2.ZERO
			_play_phoenix_action("hit4", true)
		else:
			_phoenix_aoyi_active = false
			_phoenix_aoyi_releases_left = 0
			_phoenix_aoyi_hit4_damage_times = 1
			_finish_phoenix_attack()
	elif finished_name == "hit5":
		if phoenix_stage >= 3 and mr_player != null and mr_player.has_animation("hit6"):
			hit_name = "hit6"
			velocity = Vector2.ZERO
			_start_phoenix_aoyi_drop()
			_play_phoenix_action("hit6", true)
		elif phoenix_stage >= 2 and mr_player != null and mr_player.has_animation("hit3"):
			hit_name = "hit3"
			_play_phoenix_action("hit3", true)
		else:
			_phoenix_aoyi_active = false
			_finish_phoenix_attack()
	elif finished_name == "hit6":
		_phoenix_aoyi_active = false
		_finish_phoenix_attack()
	elif finished_name == "hit3":
		_phoenix_aoyi_active = false
		_finish_phoenix_attack()
	elif finished_name.begins_with("hit"):
		_finish_phoenix_attack()
	elif finished_name == "hurt":
		_phoenix_aoyi_active = false
		_finish_phoenix_attack()


func _finish_phoenix_attack() -> void:
	is_attacking = false
	is_be_attacking = false
	_attack_lock = false
	hit_name = ""
	_phoenix_aoyi_active = false
	_phoenix_aoyi_drop_started = false
	_phoenix_aoyi_hit6_elapsed = 0.0
	_phoenix_aoyi_hit6_aligned = false
	_phoenix_aoyi_releases_left = 0
	_phoenix_aoyi_hit4_damage_times = 1
	_phoenix_father_time = 0.0
	_phoenix_nirvana_active = false
	_phoenix_nirvana_elapsed = 0.0
	_phoenix_nirvana_heal_timer = 0.0
	_phoenix_state_lock_timer = 0.0
	velocity.y = 0
	if hit_box != null:
		hit_box.disabled = true
	if mr_player != null and mr_player.has_animation("wait"):
		_play_phoenix_action("wait", true)


func _find_pet_phoenix_player_reference() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var current_scene := tree.current_scene
	if current_scene == null or not current_scene.has_node("Hero"):
		return
	var hero_node := current_scene.get_node("Hero")
	for child in hero_node.get_children():
		if child is BaseHero:
			player_reference = child
			return


func _setup_phoenix_model_frames() -> void:
	if phoenix_sprite == null:
		return
	var frames := load(PHOENIX_MODEL_FRAMES_RES % phoenix_stage) as SpriteFrames
	if frames == null:
		push_error("PetPhoenix SpriteFrames missing for stage %d" % phoenix_stage)
		return
	phoenix_sprite.sprite_frames = frames
	if frames.has_animation("wait"):
		phoenix_sprite.play("wait")


func _apply_phoenix_stage_scene_layout() -> void:
	var packed_scene := load(PHOENIX_SCENE_RES % phoenix_stage) as PackedScene
	if packed_scene == null:
		_setup_phoenix_model_frames()
		return
	var template := packed_scene.instantiate()
	if template == null:
		_setup_phoenix_model_frames()
		return
	var ground_shape := get_node_or_null("pz") as CollisionShape2D
	var old_ground_bottom := _phoenix_collision_shape_bottom(ground_shape)
	var template_sprite := template.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if template_sprite != null and phoenix_sprite != null:
		phoenix_sprite.position = template_sprite.position
		phoenix_sprite.rotation = template_sprite.rotation
		phoenix_sprite.scale = template_sprite.scale
		phoenix_sprite.offset = template_sprite.offset
		phoenix_sprite.centered = template_sprite.centered
	for path in ["BaseDamageBox/HitBox/HitBox", "BaseDamageBox/HurtBox/HurtBox", "pz"]:
		_copy_phoenix_collision_layout(template, NodePath(path))
	var new_ground_bottom := _phoenix_collision_shape_bottom(ground_shape)
	global_position.y += old_ground_bottom - new_ground_bottom
	velocity.y = 0.0
	floor_snap_length = maxf(floor_snap_length, 32.0)
	apply_floor_snap()
	template.free()
	_setup_phoenix_model_frames()


func _copy_phoenix_collision_layout(template: Node, path: NodePath) -> void:
	var source := template.get_node_or_null(path) as CollisionShape2D
	var target := get_node_or_null(path) as CollisionShape2D
	if source == null or target == null:
		return
	var was_disabled := target.disabled
	target.position = source.position
	target.rotation = source.rotation
	target.scale = source.scale
	target.shape = source.shape
	target.disabled = was_disabled


func _phoenix_collision_shape_bottom(collision: CollisionShape2D) -> float:
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

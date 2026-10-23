extends "res://Script/base/summon_base_monster.gd"
class_name PetTigerSummonBase

@export var tiger_stage: int = 4

const SKILL_HY := "hy"
const SKILL_SXHZ := "sxhz"
const SKILL_HSQJ := "hsqj"
const SKILL_BHAOYI := "bhaoyi"
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
const PET_LEARNED_SKILL_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const SKILL_NAMES := {
	"hit1": "猛扑",
	SKILL_HY: "虎啸",
	SKILL_SXHZ: "嗜血虎爪",
	SKILL_HSQJ: "横扫千军",
	SKILL_BHAOYI: "奥义",
}
const SKILL_HY_MP_COST := 25
const SKILL_SXHZ_MP_COST := 30
const SKILL_HSQJ_MP_COST := 35
const SKILL_BHAOYI_MP_COST := 45
const TIGER_MODEL_FRAMES_RES := "res://Art/pet/pet_tiger/model/pet_tiger_stage%d_frames.tres"
const TIGER_SCENE_RES := "res://Scene/pet/pet_tiger_summon_%d.tscn"
const PET_TIGER_BULLET_SCENE := preload("res://Scene/pet/pet_tiger_bullet.tscn")
const TIGER_FRAME_SPEED := 10.0
const TIGER_FALL_GRAVITY := -2280.0
const TIGER_ACTIONS := [
	{},
	{
		"wait": [0, 6],
		"walk": [0, 6],
		"hurt": [1, 1],
		"death": [2, 4],
		"hit1": [3, 4],
		"hit2": [4, 4],
		"hit3_1": [4, 4],
		"hit3_2": [4, 4],
		"hit4": [4, 4]
	},
	{
		"wait": [0, 6],
		"walk": [1, 4],
		"hurt": [2, 1],
		"death": [3, 5],
		"hit1": [4, 4],
		"hit2": [5, 3],
		"hit3_1": [6, 3],
		"hit3_2": [6, 3],
		"hit4": [6, 3]
	},
	{
		"wait": [0, 6],
		"walk": [1, 4],
		"hurt": [2, 1],
		"death": [3, 5],
		"hit1": [4, 4],
		"hit2": [5, 4],
		"hit3_1": [6, 3],
		"hit3_2": [6, 3],
		"hit4": [7, 5]
	},
	{
		"wait": [0, 6],
		"walk": [1, 4],
		"hurt": [2, 1],
		"death": [3, 5],
		"hit1": [4, 4],
		"hit2": [4, 4],
		"hit3_1": [5, 3],
		"hit3_2": [5, 3],
		"hit4": [6, 5]
	}
]

var pet_data: Dictionary = {}
var max_mp: int = 1
var mp: int = 1
var hp_recover_per_second: int = 0
var mp_recover_per_second: int = 0
var recovery_timer: float = 0.0
var bhaoyi_running: bool = false
var pet_skill_cooldown_multiplier: float = 1.0
@onready var tiger_sprite: AnimatedSprite2D = $MonsterDir/mr_ani


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_tiger_unit", true)
	set_meta("is_summon", true)
	if is_in_group("monsters"):
		remove_from_group("monsters")
	setup_pet_tiger(int(pet_data.get("阶段", tiger_stage)))
	_setup_tiger_model_frames()
	if hurt_box != null:
		hurt_box.disabled = false
	if hit_box != null:
		hit_box.disabled = true
	if mr_player != null:
		var anim_started_cb := Callable(self, "_on_tiger_animation_started")
		if not mr_player.animation_started.is_connected(anim_started_cb):
			mr_player.animation_started.connect(anim_started_cb)


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
	_find_pet_tiger_player_reference()
	setup_skills()
	current_state = State.IDLE


func _process(delta: float) -> void:
	_process_pet_tiger_recovery(delta)


func _process_pet_tiger_recovery(delta: float) -> void:
	if hp <= 0:
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


func _get_gravity() -> float:
	return TIGER_FALL_GRAVITY if can_set_gravity() else 0.0


func _find_pet_tiger_player_reference() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var current_scene := tree.current_scene
	if current_scene == null or not current_scene.has_node("Hero"):
		return
	var hero_node := current_scene.get_node("Hero")
	if hero_node == null:
		return
	for child in hero_node.get_children():
		if child is BaseHero:
			player_reference = child
			return


func apply_pet_data(data: Dictionary) -> void:
	var previous_stage := tiger_stage
	pet_data = data.duplicate(true)
	setup_pet_tiger(_pet_stage_from_data(pet_data, 1))
	if is_node_ready() and tiger_sprite != null:
		if tiger_stage != previous_stage:
			_apply_tiger_stage_scene_layout()
		_setup_tiger_model_frames()


func _pet_stage_from_data(data: Dictionary, fallback: int) -> int:
	var stage_key := String.chr(38454) + String.chr(27573)
	if data.has(stage_key):
		return clampi(int(data.get(stage_key, fallback)), 1, 4)
	var level_key := String.chr(31561) + String.chr(32423)
	var pet_level := int(data.get(level_key, 0))
	if pet_level >= 50:
		return 4
	if pet_level >= 30:
		return 3
	if pet_level >= 15:
		return 2
	if pet_level >= 1:
		return 1
	return clampi(fallback, 1, 4)


func _tiger_stage_name(stage: int) -> String:
	match clampi(stage, 1, 4):
		1:
			return "虎丸"
		2:
			return "白灵虎"
		3:
			return "白虎将军"
		4:
			return "白虎战神"
		_:
			return "虎丸"


func apply_pet_develop_effects(data: Dictionary) -> void:
	var previous_cooldown_multiplier: float = maxf(0.01, pet_skill_cooldown_multiplier)
	pet_data["悟性"] = clampi(int(data.get("悟性", 0)), 0, 25)
	pet_data["根骨"] = clampi(int(data.get("根骨", 0)), 0, 25)
	pet_data["灵力"] = clampi(int(data.get("灵力", 0)), 0, 25)
	var new_cooldown_multiplier: float = 1.0 - float(pet_data["灵力"]) * 0.02
	var cooldown_ratio: float = new_cooldown_multiplier / previous_cooldown_multiplier
	pet_skill_cooldown_multiplier = new_cooldown_multiplier
	skill_1_cd = maxf(0.0, skill_1_cd * cooldown_ratio)
	skill_2_cd = maxf(0.0, skill_2_cd * cooldown_ratio)
	skill_3_cd = maxf(0.0, skill_3_cd * cooldown_ratio)
	skill_4_cd = maxf(0.0, skill_4_cd * cooldown_ratio)
	_rebuild_pet_attack_data()


func setup_pet_tiger(stage: int) -> void:
	tiger_stage = clampi(stage, 1, 4)
	var level_from_pet := int(pet_data.get(DataKeys.LEVEL, 40 + tiger_stage * 5))
	var attack_from_pet := int(pet_data.get(DataKeys.ATTACK, 65))
	var hp_from_pet := int(pet_data.get("生命上限", 1200))
	var equipment_bonus: Dictionary = {}
	if PlayerData.has_method("get_pet_equipment_bonuses"):
		equipment_bonus = PlayerData.get_pet_equipment_bonuses(pet_data)
	var hp_bonus := int(equipment_bonus.get(DataKeys.HP, 0))
	var mp_bonus := int(equipment_bonus.get(DataKeys.MP, 0))
	my_mr_name = str(pet_data.get(DataKeys.NAME, _tiger_stage_name(tiger_stage)))
	var passive: Dictionary = pet_data.get("被动技能", {}) if pet_data.get("被动技能", {}) is Dictionary else {}
	var passive_hp := int(PaSkill.get_value("热血", int(passive.get("热血", 0))))
	var passive_mp := int(PaSkill.get_value("魔泉", int(passive.get("魔泉", 0))))
	attack_in = max(1, attack_from_pet + int(equipment_bonus.get(DataKeys.ATTACK, 0)))
	attack_in += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "天生蛮力", attack_in)
	pet_skill_cooldown_multiplier = 1.0 - float(clampi(int(pet_data.get("灵力", 0)), 0, 25)) * 0.02
	level = max(1, level_from_pet)
	max_hp = max(1, hp_from_pet + hp_bonus + passive_hp)
	var learned_hp_bonus := PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "生命祝福", max_hp)
	max_hp += learned_hp_bonus
	var base_current_hp := int(pet_data.get(DataKeys.HP, hp_from_pet))
	hp = 0 if base_current_hp <= 0 else clampi(base_current_hp + hp_bonus + passive_hp + learned_hp_bonus, 0, max_hp)
	var base_mp_max := int(pet_data.get("魔法上限", pet_data.get(DataKeys.MP, 1)))
	max_mp = max(1, base_mp_max + mp_bonus + passive_mp)
	var learned_mp_bonus := PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "魔法庇佑", max_mp)
	max_mp += learned_mp_bonus
	var base_current_mp := int(pet_data.get(DataKeys.MP, base_mp_max))
	mp = 0 if base_current_mp <= 0 else clampi(base_current_mp + mp_bonus + passive_mp + learned_mp_bonus, 0, max_mp)
	hp_recover_per_second = (
		int(pet_data.get("回血", 0))
		+ int(equipment_bonus.get("回血", 0))
		+ int(PaSkill.get_value("永恒", int(passive.get("永恒", 0))))
	)
	mp_recover_per_second = (
		int(pet_data.get("回魔", 0))
		+ int(equipment_bonus.get("回魔", 0))
		+ int(PaSkill.get_value("辉煌", int(passive.get("辉煌", 0))))
	)
	self_rhp = hp_recover_per_second
	def = int(pet_data.get(DataKeys.DEFENSE, pet_data.get("物防", 120))) + int(equipment_bonus.get(DataKeys.DEFENSE, 0))
	def += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "自然守护", def)
	mdef = int(pet_data.get("魔防", pet_data.get("魔抗", 120))) + int(equipment_bonus.get("魔防", 0))
	mdef += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "自然守护", mdef)
	crit = (
		int(pet_data.get("暴击", 30))
		+ int(equipment_bonus.get("暴击", 0))
		+ int(PaSkill.get_value("狂暴", int(passive.get("狂暴", 0))))
	)
	miss = int(pet_data.get("闪避", 8)) + int(equipment_bonus.get("闪避", 0))
	htarget = int(equipment_bonus.get("命中", 0)) + int(PaSkill.get_value("敏锐", int(passive.get("敏锐", 0))))
	lucky = int(pet_data.get("幸运", 20)) + int(equipment_bonus.get("幸运", 0))
	toughness = int(equipment_bonus.get("韧性", 0))
	ar = int(equipment_bonus.get("破甲", 0))
	sp = int(equipment_bonus.get("破魔", 0))
	crit_reduce = int(equipment_bonus.get("暴免", 0))
	speed = 14
	attack_range = 95
	mysee = 99999
	attack_desire = 100
	is_boss = false
	add_exp = 0
	fall_coin = 0
	_rebuild_pet_attack_data()


func _rebuild_pet_attack_data() -> void:
	var bone_multiplier: float = 1.0 + float(clampi(int(pet_data.get("根骨", 0)), 0, 25)) * 0.02
	var damage_bl: float = (1.0 + float(tiger_stage - 1) * 0.3) * bone_multiplier
	obj_attack_dict["hit1"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * 2.2 * damage_bl), pet_data, SKILL_NAMES["hit1"]),
		[2, 0],
		"physics",
		8
	)
	obj_attack_dict[SKILL_HY] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * 6.3 * damage_bl), pet_data, SKILL_NAMES[SKILL_HY]),
		[2, 0],
		"physics",
		8
	)
	obj_attack_dict[SKILL_SXHZ] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * damage_bl), pet_data, SKILL_NAMES[SKILL_SXHZ]),
		[0, 0],
		"physics",
		4
	)
	obj_attack_dict[SKILL_HSQJ] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * 5.8 * damage_bl), pet_data, SKILL_NAMES[SKILL_HSQJ]),
		[2, 0],
		"physics",
		10
	)
	obj_attack_dict[SKILL_BHAOYI] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(int(attack_in * 5.8 * damage_bl), pet_data, SKILL_NAMES[SKILL_BHAOYI]),
		[2, 0],
		"physics",
		10
	)


func _attack_dic(power: int, hurt_back: Array, kind: String, protect: int) -> Dictionary:
	return {"power": power, "hurtBack": hurt_back, "attackKind": kind, "HitProtect": protect}


func setup_skills() -> void:
	skill_1_cd = 0.4 * pet_skill_cooldown_multiplier
	skill_2_cd = 2.5 * pet_skill_cooldown_multiplier
	skill_3_cd = 5.0 * pet_skill_cooldown_multiplier
	skill_4_cd = 7.0 * pet_skill_cooldown_multiplier


func try_use_skills() -> void:
	if should_in_sky or bhaoyi_running or not is_instance_valid(current_target):
		return
	var distance: float = abs(position.x - current_target.position.x)
	if tiger_stage >= 4 and skill_4_cd <= 0:
		do_bhaoyi()
	elif tiger_stage >= 3 and skill_3_cd <= 0 and distance <= 450:
		do_hsqj()
	elif tiger_stage >= 2 and skill_2_cd <= 0 and distance <= 80:
		do_sxhz()
	elif skill_1_cd <= 0 and distance >= 50 and distance <= 100:
		do_hy()


func ai_think() -> void:
	if is_attacking:
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
		if is_attacking:
			return
		if distance > attack_range:
			if current_target.position.x > position.x:
				move_right()
			else:
				move_left()
		else:
			stop_move()
			to_monster()
			if not is_be_attacking and count % 55 == 0 and randi_range(0, 100) < attack_desire:
				do_hit_1()
	else:
		current_target = null
		has_target = false
		follow_player_when_idle()


func _can_use_pet_skill(cost: int) -> bool:
	return mp >= cost


func _consume_pet_skill_mp(cost: int) -> bool:
	if not _can_use_pet_skill(cost):
		return false
	mp = max(0, mp - cost)
	pet_data[DataKeys.MP] = mp
	return true


func _tiger_skill_cost(skill_id: String, base_cost: int) -> int:
	var custom_raw: Variant = pet_data.get("技能蓝耗", {})
	if custom_raw is Dictionary:
		if custom_raw.has(skill_id):
			return int(custom_raw.get(skill_id, base_cost))
		var skill_name := str(SKILL_NAMES.get(skill_id, ""))
		if custom_raw.has(skill_name):
			return int(custom_raw.get(skill_name, base_cost))
	var resolved_name := str(SKILL_NAMES.get(skill_id, ""))
	return PET_SKILL_PROGRESSION.mana_cost(base_cost, PET_SKILL_PROGRESSION.get_level(pet_data, resolved_name))


func do_hit_1() -> void:
	is_attacking = true
	velocity.x = 0
	hit_name = "hit1"
	to_monster()
	_play_attack_animation("hit1", Callable(self, "call_hit_1_bullet"))


func do_hy() -> void:
	if not _consume_pet_skill_mp(_tiger_skill_cost(SKILL_HY, SKILL_HY_MP_COST)):
		return
	is_attacking = true
	velocity.x = 0
	hit_name = SKILL_HY
	skill_1_cd = randf_range(5.0, 7.0) * pet_skill_cooldown_multiplier
	to_monster()
	_play_attack_animation("hit2", Callable(self, "call_hy_bullet"))


func do_sxhz() -> void:
	if not _consume_pet_skill_mp(_tiger_skill_cost(SKILL_SXHZ, SKILL_SXHZ_MP_COST)):
		return
	is_attacking = true
	velocity.x = 0
	hit_name = SKILL_SXHZ
	skill_2_cd = randf_range(8.0, 11.0) * pet_skill_cooldown_multiplier
	to_monster()
	await _play_attack_animation("hit3_1", Callable(self, "call_sxhz_hit"))
	is_attacking = true
	await _play_attack_animation("hit3_2", Callable(self, "call_sxhz_hit"))
	if not is_queued_for_deletion() and hp > 0:
		cure_hp(max(1, int(max_hp * 0.025)))
	is_attacking = false


func do_hsqj() -> void:
	if not _consume_pet_skill_mp(_tiger_skill_cost(SKILL_HSQJ, SKILL_HSQJ_MP_COST)):
		return
	is_attacking = true
	velocity.x = 0
	hit_name = SKILL_HSQJ
	skill_3_cd = randf_range(10.0, 13.0) * pet_skill_cooldown_multiplier
	to_monster()
	_play_attack_animation("hit4", Callable(self, "call_hsqj_bullet"))


func do_bhaoyi() -> void:
	if not is_instance_valid(current_target):
		return
	if not _consume_pet_skill_mp(_tiger_skill_cost(SKILL_BHAOYI, SKILL_BHAOYI_MP_COST)):
		return
	bhaoyi_running = true
	_clear_tiger_skill_cooldowns()
	hit_name = SKILL_HSQJ
	velocity.x = 0
	is_attacking = true
	_to_target_side()
	await _play_attack_animation("hit4", Callable(self, "call_hsqj_bullet"))
	await get_tree().create_timer(0.12, false).timeout
	is_attacking = true
	_to_target_side()
	await _play_attack_animation("hit4", Callable(self, "call_hsqj_bullet"))
	skill_1_cd = randf_range(5.0, 7.0) * pet_skill_cooldown_multiplier
	skill_2_cd = randf_range(8.0, 11.0) * pet_skill_cooldown_multiplier
	skill_3_cd = randf_range(10.0, 13.0) * pet_skill_cooldown_multiplier
	skill_4_cd = randf_range(20.0, 26.0) * pet_skill_cooldown_multiplier
	is_attacking = false
	bhaoyi_running = false


func _clear_tiger_skill_cooldowns() -> void:
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0
	skill_4_cd = 0


func _to_target_side() -> void:
	if not is_instance_valid(current_target):
		return
	var side := -1
	if randi_range(0, 1) == 1:
		side = 1
	position.x = current_target.position.x + 70 * side
	position.y = current_target.position.y
	to_monster()


func _play_attack_animation(animation_name: String, fallback_call: Callable) -> void:
	_play_tiger_model_animation(animation_name)
	if mr_player != null and mr_player.has_animation(animation_name):
		mr_player.play(animation_name)
		var wait_time: float = max(0.28, mr_player.current_animation_length)
		await get_tree().create_timer(wait_time, false).timeout
	else:
		fallback_call.call()
		await get_tree().create_timer(0.35, false).timeout
	is_attacking = false
	if velocity.x != 0:
		_play_tiger_model_animation("walk")
	else:
		_play_tiger_model_animation("wait")


func call_hit_1_bullet() -> void:
	_sync_attack_facing()
	var bullet_name := "PetTiger1Bullet1" if tiger_stage == 1 else "PetTiger2Bullet1"
	var offset := Vector2(60.0, -25.0)
	if tiger_stage == 2:
		offset = Vector2(120.0, -80.0)
	elif tiger_stage >= 3:
		offset = Vector2(130.0, -70.0)
	_add_tiger_bullet(bullet_name, position + _front_offset(offset.x, offset.y), "hit1", obj_attack_dict["hit1"])


func call_hy_bullet() -> void:
	_sync_attack_facing()
	var offset := Vector2(150.0, -75.0)
	if tiger_stage >= 2:
		offset = Vector2(190.0, -80.0)
	_add_tiger_bullet(
		"PetTiger1Bullet2", position + _front_offset(offset.x, offset.y), SKILL_HY, obj_attack_dict[SKILL_HY]
	)


func call_sxhz_hit() -> void:
	_sync_attack_facing()
	var first_y := -45.0 if tiger_stage == 2 else -65.0
	_add_tiger_bullet(
		"PetTiger2Bullet3_1", position + _front_offset(50.0, first_y), SKILL_SXHZ, obj_attack_dict[SKILL_SXHZ]
	)
	_add_tiger_bullet(
		"PetTiger2Bullet3_2", position + _front_offset(200.0, -200.0), SKILL_SXHZ, obj_attack_dict[SKILL_SXHZ]
	)


func call_hsqj_bullet() -> void:
	_sync_attack_facing()
	var attack_key := SKILL_BHAOYI if bhaoyi_running else SKILL_HSQJ
	var mark = _add_tiger_bullet(
		"PetTiger3Bullet4_1", position + _front_offset(85.0, -130.0), attack_key, obj_attack_dict[attack_key]
	)
	if mark != null:
		mark.set_meta("pet_tiger_disabled", true)
	_add_tiger_bullet(
		"PetTiger3Bullet4_2", position + _front_offset(105.0, -2.0), attack_key, obj_attack_dict[attack_key]
	)


func _add_tiger_bullet(bullet_name: String, bullet_position: Vector2, attack_name: String, attack_data: Dictionary):
	_sync_attack_facing()
	if bullet == null or PET_TIGER_BULLET_SCENE == null:
		return null
	var b = PET_TIGER_BULLET_SCENE.instantiate()
	b.att_list = attack_data
	b.hit_name = attack_name
	b.position = bullet_position
	b.dir = monster_direction
	b.skill_name = bullet_name
	b.speed = 1.0
	b.set_meta("summoner", self)
	b.set_meta("pet_tiger_summon", true)
	bullet.add_child(b)
	setup_bullet_collision(b)
	return b


func setup_bullet_collision(bullet_instance) -> Node:
	if bullet_instance and bullet_instance.has_node("middle/HitBox"):
		var hit_box_area = bullet_instance.get_node("middle/HitBox") as Area2D
		if hit_box_area:
			hit_box_area.collision_layer = 2
			hit_box_area.collision_mask = 1024 | 2048
			bullet_instance.set_meta("is_summon_bullet", true)
			bullet_instance.set_meta("summoner", self)
	return bullet_instance


func _sync_attack_facing() -> void:
	if is_instance_valid(current_target):
		to_monster()
	else:
		_sync_tiger_model_facing()


func _front_offset(x: float, y: float) -> Vector2:
	return Vector2(-x if monster_direction else x, y)


func _apply_tiger_stage_scene_layout() -> void:
	var packed_scene := load(TIGER_SCENE_RES % tiger_stage) as PackedScene
	if packed_scene == null:
		return
	var template := packed_scene.instantiate()
	if template == null:
		return
	var ground_shape := get_node_or_null("pz") as CollisionShape2D
	var old_ground_bottom := _tiger_collision_shape_bottom(ground_shape)
	var template_sprite := template.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if template_sprite != null and tiger_sprite != null:
		tiger_sprite.position = template_sprite.position
		tiger_sprite.rotation = template_sprite.rotation
		tiger_sprite.scale = template_sprite.scale
		tiger_sprite.offset = template_sprite.offset
		tiger_sprite.centered = template_sprite.centered
	for path in ["BaseDamageBox/HitBox/HitBox", "BaseDamageBox/HurtBox/HurtBox", "pz"]:
		_copy_tiger_collision_layout(template, NodePath(path))
	var new_ground_bottom := _tiger_collision_shape_bottom(ground_shape)
	global_position.y += old_ground_bottom - new_ground_bottom
	velocity.y = 0.0
	floor_snap_length = maxf(floor_snap_length, 32.0)
	apply_floor_snap()
	template.free()


func _copy_tiger_collision_layout(template: Node, path: NodePath) -> void:
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


func _tiger_collision_shape_bottom(collision: CollisionShape2D) -> float:
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


func _setup_tiger_model_frames() -> void:
	var frame_path := TIGER_MODEL_FRAMES_RES % tiger_stage
	var frames := load(frame_path) as SpriteFrames
	if frames == null:
		push_error("PetTiger SpriteFrames missing: %s" % frame_path)
		return
	tiger_sprite.sprite_frames = frames
	_play_tiger_model_animation("wait")


func _on_tiger_animation_started(animation_name: StringName) -> void:
	_play_tiger_model_animation(String(animation_name))


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
	_sync_tiger_model_facing()


func _face_right() -> void:
	monster_direction = false
	if base_damage_box != null:
		base_damage_box.scale.x = -1
	if monster_dir != null:
		monster_dir.scale.x = -1
	_sync_tiger_model_facing()


func _sync_tiger_model_facing() -> void:
	if tiger_sprite == null:
		return
	var sx: float = absf(tiger_sprite.scale.x)
	if sx <= 0.0:
		sx = 1.1
	tiger_sprite.scale.x = sx
	tiger_sprite.flip_h = false


func play_move_animation() -> void:
	if is_attacking:
		return
	if mr_player != null and mr_player.has_animation("walk") and mr_player.current_animation != "walk":
		mr_player.play("walk")
	_play_tiger_model_animation("walk")


func stop_move() -> void:
	velocity.x = 0
	if not is_attacking and not is_be_attacking:
		if mr_player != null and mr_player.has_animation("wait") and mr_player.current_animation != "wait":
			mr_player.play("wait")
		_play_tiger_model_animation("wait")


func _play_tiger_model_animation(animation_name: String) -> void:
	if (
		tiger_sprite != null
		and tiger_sprite.sprite_frames != null
		and tiger_sprite.sprite_frames.has_animation(animation_name)
	):
		_sync_tiger_model_facing()
		if tiger_sprite.animation != animation_name:
			tiger_sprite.play(animation_name)
		elif not tiger_sprite.is_playing():
			tiger_sprite.play()

extends "res://Script/base/summon_base_monster.gd"
class_name PetDragonSummonBase

@export var dragon_stage: int = 1

const SKILL_FS := "fs"
const SKILL_SDCC := "sdcc"
const SKILL_LTWJ := "ltwj"
const SKILL_QLAOYI := "qlaoyi"
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
const PET_LEARNED_SKILL_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const SKILL_NAMES := {
	SKILL_FS: "分身",
	SKILL_SDCC: "闪电冲刺",
	SKILL_LTWJ: "雷霆万钧",
	SKILL_QLAOYI: "青龙奥义",
}
const SKILL_MP_COSTS := {
	SKILL_FS: 50,
	SKILL_SDCC: 70,
	SKILL_LTWJ: 90,
	SKILL_QLAOYI: 100,
}
const SKILL_INITIAL_COOLDOWNS := {
	SKILL_FS: 2.0,
	SKILL_SDCC: 5.0,
	SKILL_LTWJ: 8.0,
	SKILL_QLAOYI: 30.0,
}
const SKILL_COOLDOWNS := {
	SKILL_FS: 20.0,
	SKILL_SDCC: 10.0,
	SKILL_LTWJ: 16.0,
	SKILL_QLAOYI: 60.0,
}
const DRAGON_ACTION_TICK_RATE := 24.0
const DRAGON_RUSH_SPEED := 240.0
const DRAGON_AOYI_RISE_SPEED := -120.0
const DRAGON_FALL_GRAVITY := -2280.0
const LTWJ_DAMAGE_FREQUENCY_MULTIPLIER := 2
const LTWJ_DAMAGE_REPEAT_INTERVAL := 0.1
const DRAGON_MODEL_FRAMES_RES := "res://Art/pet/pet_dragon/model/pet_dragon_stage%d_frames.tres"
const PET_DRAGON_BULLET_SCENE := preload("res://Scene/pet/pet_dragon_bullet.tscn")
const DRAGON_SCENE_RES := "res://Scene/pet/pet_dragon_summon_%d.tscn"
static var _dragon_scene_cache: Dictionary = {}
const DRAGON_ORIGINAL_SPRITE_OFFSET_Y := {1: -5.0, 2: -5.0, 3: -15.0, 4: -25.0}
const DRAGON_NORMAL_ATTACK_RANGES := {1: 80, 2: 95, 3: 75, 4: 110}

const ACTION_STOP_COUNTS := {
	1:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [2, 2, 2, 3, 2, 4],
		"hurt": [8],
		"death": [2, 2, 2, 10],
		"hit1": [2, 2, 2, 10],
		"hit2": [2, 2, 2, 2, 10],
	},
	2:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 2, 10],
		"hit2": [2, 2, 2, 2, 10],
		"hit3": [30],
	},
	3:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 7, 2, 2, 10],
		"hit2": [2, 2, 2, 2, 10],
		"hit3": [30],
		"hit4": [2, 2, 30],
	},
	4:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 7, 2, 2, 10],
		"hit2": [2, 2, 2, 2, 10],
		"hit3": [30],
		"hit4": [2, 2, 30],
		"hit5": [48],
		"hit6": [2, 40],
	},
}

const LTWJ_WAVES := [
	{"delay": 0.0, "offsets": [Vector2(0, 0)]},
	{"delay": 0.2, "offsets": [Vector2(-150, -10), Vector2(90, -25)]},
	{"delay": 0.4, "offsets": [Vector2(-90, -25), Vector2(150, -10)]},
	{"delay": 0.6, "offsets": [Vector2(-270, -25), Vector2(210, -10)]},
	{"delay": 0.8, "offsets": [Vector2(-210, -25), Vector2(270, -10)]},
]
const LTWJ_CLONE_WAVES := [
	{"delay": 0.0, "offsets": [Vector2(0, 0)]},
	{"delay": 0.25, "offsets": [Vector2(-120, -15), Vector2(120, -15)]},
	{"delay": 0.5, "offsets": [Vector2(-210, -20), Vector2(210, -20)]},
]

var pet_data: Dictionary = {}
var max_mp: int = 1
var mp: int = 1
var hp_recover_per_second: int = 0
var mp_recover_per_second: int = 0
var recovery_timer: float = 0.0
var pet_skill_cooldown_multiplier: float = 1.0

var is_dragon_clone: bool = false
var dragon_clone_owner: PetDragonSummonBase = null
var dragon_clone_lifetime: float = 0.0
var dragon_clone_elapsed: float = 0.0
var dragon_clone_settled: bool = false
var dragon_dealt_damage: int = 0
var is_aoyi: bool = false

var _dragon_action: String = ""
var _dragon_action_tick: int = 0
var _dragon_action_accumulator: float = 0.0
var _dragon_action_triggered: Dictionary = {}

@onready var dragon_sprite: AnimatedSprite2D = $MonsterDir/mr_ani


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_dragon_unit", true)
	set_meta("is_summon", true)
	if is_in_group("monsters"):
		remove_from_group("monsters")
	setup_pet_dragon(int(pet_data.get("阶段", dragon_stage)))
	setup_skills()
	_setup_dragon_model_frames()
	_get_dragon_stage_scene(dragon_stage)
	MonsterBullet.warm_pet_dragon_dash_textures()
	_warm_dragon_action_textures("hit3")
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
	_find_pet_dragon_player_reference()
	current_state = State.IDLE


func _physics_process(delta: float) -> void:
	_tick_dragon_action(delta)
	super(delta)


func _process(delta: float) -> void:
	_process_pet_dragon_recovery(delta)
	_process_dragon_clone(delta)


func _process_pet_dragon_recovery(delta: float) -> void:
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


func _process_dragon_clone(delta: float) -> void:
	if not is_dragon_clone or dragon_clone_settled:
		return
	if hp <= 0:
		dragon_clone_settled = true
		return
	dragon_clone_elapsed += delta
	if dragon_clone_elapsed < dragon_clone_lifetime:
		return
	dragon_clone_settled = true
	if is_instance_valid(dragon_clone_owner) and dragon_clone_owner.hp > 0:
		dragon_clone_owner.cure_hp(int(dragon_dealt_damage / 10.0))
		if dragon_stage >= 4:
			dragon_clone_owner.pet_data[DataKeys.EXP] = (
				int(dragon_clone_owner.pet_data.get(DataKeys.EXP, 0)) + int(pet_data.get(DataKeys.EXP, 0))
			)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)


func record_pet_dragon_damage(value: int) -> void:
	if is_dragon_clone and value > 0:
		dragon_dealt_damage += value


func _get_gravity() -> float:
	return DRAGON_FALL_GRAVITY if can_set_gravity() else 0.0


func _find_pet_dragon_player_reference() -> void:
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


func apply_pet_data(data: Dictionary) -> void:
	var previous_stage := dragon_stage
	var previous_skills := _learned_skills().duplicate(true)
	pet_data = data.duplicate(true)
	setup_pet_dragon(int(pet_data.get("阶段", dragon_stage)))
	if is_node_ready() and dragon_sprite != null:
		if dragon_stage != previous_stage:
			_apply_dragon_stage_scene_layout()
		_setup_dragon_model_frames()
		_unlock_new_stage_skill_cooldowns(previous_skills)


func _unlock_new_stage_skill_cooldowns(previous_skills: Array) -> void:
	for skill_id in [SKILL_FS, SKILL_SDCC, SKILL_LTWJ, SKILL_QLAOYI]:
		var skill_name := str(SKILL_NAMES[skill_id])
		if previous_skills.has(skill_id) or previous_skills.has(skill_name) or not _has_skill(skill_id):
			continue
		match skill_id:
			SKILL_FS:
				skill_1_cd = 0.0
			SKILL_SDCC:
				skill_2_cd = 0.0
			SKILL_LTWJ:
				skill_3_cd = 0.0
			SKILL_QLAOYI:
				skill_4_cd = 0.0


func _apply_dragon_stage_scene_layout() -> void:
	var packed_scene := _get_dragon_stage_scene(dragon_stage)
	if packed_scene == null:
		return
	var template := packed_scene.instantiate()
	if template == null:
		return
	var ground_shape := get_node_or_null("pz") as CollisionShape2D
	var old_ground_bottom := _collision_shape_bottom(ground_shape)
	var template_sprite := template.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if template_sprite != null and dragon_sprite != null:
		dragon_sprite.position = template_sprite.position
		dragon_sprite.rotation = template_sprite.rotation
		dragon_sprite.scale = template_sprite.scale
		dragon_sprite.offset = template_sprite.offset
		dragon_sprite.centered = template_sprite.centered
	for path in ["BaseDamageBox/HitBox/HitBox", "BaseDamageBox/HurtBox/HurtBox", "pz"]:
		_copy_dragon_collision_layout(template, NodePath(path))
	var new_ground_bottom := _collision_shape_bottom(ground_shape)
	global_position.y += old_ground_bottom - new_ground_bottom
	template.free()


static func _get_dragon_stage_scene(stage: int) -> PackedScene:
	var cached := _dragon_scene_cache.get(stage) as PackedScene
	if cached != null:
		return cached

	_dragon_scene_cache.clear()
	var loaded := (
		ResourceLoader.load(DRAGON_SCENE_RES % stage, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	)
	if loaded != null:
		_dragon_scene_cache[stage] = loaded
	return loaded


static func clear_cached_scenes() -> void:
	_dragon_scene_cache.clear()


func _copy_dragon_collision_layout(template: Node, path: NodePath) -> void:
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


func _dragon_stage_name(stage: int) -> String:
	return ["", "龙仔", "绿英龙", "青龙将军", "青龙妖圣"][clampi(stage, 1, 4)]


func apply_pet_develop_effects(data: Dictionary) -> void:
	var previous_multiplier := maxf(0.01, pet_skill_cooldown_multiplier)
	pet_data["悟性"] = clampi(int(data.get("悟性", 0)), 0, 25)
	pet_data["根骨"] = clampi(int(data.get("根骨", 0)), 0, 25)
	pet_data["灵力"] = clampi(int(data.get("灵力", 0)), 0, 25)
	pet_skill_cooldown_multiplier = 1.0 - float(pet_data["灵力"]) * 0.02
	var ratio := pet_skill_cooldown_multiplier / previous_multiplier
	skill_1_cd = maxf(0.0, skill_1_cd * ratio)
	skill_2_cd = maxf(0.0, skill_2_cd * ratio)
	skill_3_cd = maxf(0.0, skill_3_cd * ratio)
	skill_4_cd = maxf(0.0, skill_4_cd * ratio)
	_rebuild_pet_dragon_attack_data()


func setup_pet_dragon(stage: int) -> void:
	dragon_stage = clampi(stage, 1, 4)
	var level_from_pet := int(pet_data.get(DataKeys.LEVEL, 40 + dragon_stage * 5))
	var attack_from_pet := int(pet_data.get(DataKeys.ATTACK, 65))
	var hp_from_pet := int(pet_data.get("生命上限", 1200))
	var equipment_bonus: Dictionary = {}
	if not is_dragon_clone and PlayerData.has_method("get_pet_equipment_bonuses"):
		equipment_bonus = PlayerData.get_pet_equipment_bonuses(pet_data)
	var hp_bonus := int(equipment_bonus.get(DataKeys.HP, 0))
	var mp_bonus := int(equipment_bonus.get(DataKeys.MP, 0))
	my_mr_name = str(pet_data.get(DataKeys.ALT_NAME, _dragon_stage_name(dragon_stage)))
	var passive: Dictionary = pet_data.get("被动技能", {}) if pet_data.get("被动技能", {}) is Dictionary else {}
	var passive_hp := int(PaSkill.get_value("热血", int(passive.get("热血", 0))))
	var passive_mp := int(PaSkill.get_value("魔泉", int(passive.get("魔泉", 0))))
	attack_in = max(1, attack_from_pet + int(equipment_bonus.get(DataKeys.ATTACK, 0)))
	if not is_dragon_clone:
		attack_in += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "天生蛮力", attack_in)
	pet_skill_cooldown_multiplier = 1.0 - float(clampi(int(pet_data.get("灵力", 0)), 0, 25)) * 0.02
	level = max(1, level_from_pet)
	max_hp = max(1, hp_from_pet + hp_bonus + passive_hp)
	var learned_hp_bonus := (
		0 if is_dragon_clone else PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "生命祝福", max_hp)
	)
	max_hp += learned_hp_bonus
	var current_hp := int(pet_data.get(DataKeys.HP, hp_from_pet))
	hp = 0 if current_hp <= 0 else clampi(current_hp + hp_bonus + passive_hp + learned_hp_bonus, 0, max_hp)
	var mp_max := int(pet_data.get("魔法上限", pet_data.get(DataKeys.MP, 1)))
	max_mp = max(1, mp_max + mp_bonus + passive_mp)
	var learned_mp_bonus := (
		0 if is_dragon_clone else PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "魔法庇佑", max_mp)
	)
	max_mp += learned_mp_bonus
	var current_mp := int(pet_data.get(DataKeys.MP, mp_max))
	mp = 0 if current_mp <= 0 else clampi(current_mp + mp_bonus + passive_mp + learned_mp_bonus, 0, max_mp)
	if is_dragon_clone:
		var clone_hp: int = maxi(1, int(pet_data.get("_dragon_clone_hp", hp)))
		var clone_mp: int = maxi(0, int(pet_data.get("_dragon_clone_mp", mp)))
		max_hp = clone_hp
		hp = clone_hp
		max_mp = max(1, clone_mp)
		mp = clampi(clone_mp, 0, max_mp)
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
	def = int(pet_data.get(DataKeys.DEFENSE, 120)) + int(equipment_bonus.get(DataKeys.DEFENSE, 0))
	if not is_dragon_clone:
		def += PET_LEARNED_SKILL_RUNTIME.permanent_stat_bonus(pet_data, "自然守护", def)
	mdef = int(pet_data.get("魔防", 120)) + int(equipment_bonus.get("魔防", 0))
	if not is_dragon_clone:
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
	attack_range = int(DRAGON_NORMAL_ATTACK_RANGES.get(dragon_stage, 80))
	mysee = 99999
	attack_desire = 100
	is_boss = false
	add_exp = 0
	fall_coin = 0
	_rebuild_pet_dragon_attack_data()


func _rebuild_pet_dragon_attack_data() -> void:
	var root_rate := 1.0 + float(clampi(int(pet_data.get("根骨", 0)), 0, 25)) * 0.02
	var hit1_power: int = maxi(1, int(float(attack_in) * 2.3 * root_rate))
	var sdcc_power: int = PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * 12.0 * root_rate)), pet_data, SKILL_NAMES[SKILL_SDCC]
	)
	var ltwj_power: int = PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * 7.0 * root_rate)), pet_data, SKILL_NAMES[SKILL_LTWJ]
	)
	var aoyi_power: int = PET_SKILL_PROGRESSION.scaled_power(
		maxi(1, int(float(attack_in) * 7.0 * root_rate)), pet_data, SKILL_NAMES[SKILL_QLAOYI]
	)
	obj_attack_dict["hit1"] = _attack_dic(hit1_power, [2, 0], "physics", 999 if dragon_stage <= 2 else 10)
	obj_attack_dict["hit2"] = _attack_dic(sdcc_power, [2, 0], "magic", 8)
	obj_attack_dict["hit3"] = _attack_dic(ltwj_power, [2, 0], "magic", 999)
	obj_attack_dict["hit4"] = _attack_dic(aoyi_power, [-10, -5], "magic", 999)


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
	skill_1_cd = SKILL_INITIAL_COOLDOWNS[SKILL_FS] * pet_skill_cooldown_multiplier
	skill_2_cd = SKILL_INITIAL_COOLDOWNS[SKILL_SDCC] * pet_skill_cooldown_multiplier
	skill_3_cd = SKILL_INITIAL_COOLDOWNS[SKILL_LTWJ] * pet_skill_cooldown_multiplier
	skill_4_cd = SKILL_INITIAL_COOLDOWNS[SKILL_QLAOYI] * pet_skill_cooldown_multiplier


func _learned_skills() -> Array:
	var skills = pet_data.get("技能", [])
	return skills if skills is Array else []


func _has_skill(skill_id: String) -> bool:
	var skills := _learned_skills()
	return skills.has(skill_id) or skills.has(SKILL_NAMES[skill_id])


func _skill_cost(skill_id: String) -> int:
	var costs: Dictionary = pet_data.get("技能蓝耗", {}) if pet_data.get("技能蓝耗", {}) is Dictionary else {}
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


func try_use_skills() -> void:
	if should_in_sky or is_aoyi or not is_instance_valid(current_target):
		return
	var distance := global_position.distance_to(current_target.global_position)
	if (
		not is_dragon_clone
		and dragon_stage >= 4
		and skill_4_cd <= 0.0
		and distance <= 200.0
		and _can_use_skill(SKILL_QLAOYI)
	):
		do_qlaoyi()
	elif dragon_stage >= 3 and skill_3_cd <= 0.0 and distance <= 500.0 and _can_use_skill(SKILL_LTWJ):
		do_ltwj()
	elif dragon_stage >= 2 and skill_2_cd <= 0.0 and distance <= 300.0 and _can_use_skill(SKILL_SDCC):
		do_sdcc()
	elif not is_dragon_clone and skill_1_cd <= 0.0 and _can_use_skill(SKILL_FS):
		do_fs()


func ai_think() -> void:
	if is_attacking:
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
	if not is_be_attacking:
		try_use_skills()
	if is_attacking:
		return
	if distance > attack_range:
		if current_target.global_position.x > global_position.x:
			move_right()
		else:
			move_left()
	else:
		stop_move()
		to_monster()
		if not is_be_attacking and count % 55 == 0 and randi_range(0, 100) < attack_desire:
			do_hit_1()


func do_hit_1() -> void:
	_face_current_target()
	hit_name = "hit1"
	_start_dragon_action("hit1")


func do_fs() -> void:
	if is_dragon_clone or not _consume_skill(SKILL_FS):
		return
	_face_current_target()
	skill_1_cd = SKILL_COOLDOWNS[SKILL_FS] * pet_skill_cooldown_multiplier
	hit_name = SKILL_FS
	_start_dragon_action("hit2")


func do_sdcc(without_mana: bool = false) -> void:
	if not without_mana and not _consume_skill(SKILL_SDCC):
		return
	_face_current_target()
	if not without_mana:
		skill_2_cd = SKILL_COOLDOWNS[SKILL_SDCC] * pet_skill_cooldown_multiplier
	hit_name = "hit2"
	_start_dragon_action("hit3")


func do_ltwj(without_mana: bool = false) -> void:
	if not without_mana and not _consume_skill(SKILL_LTWJ):
		return
	_face_current_target()
	if not without_mana:
		skill_3_cd = SKILL_COOLDOWNS[SKILL_LTWJ] * pet_skill_cooldown_multiplier
	hit_name = "hit3"
	_start_dragon_action("hit4")


func do_qlaoyi() -> void:
	if is_dragon_clone or not _consume_skill(SKILL_QLAOYI):
		return
	_face_current_target()
	skill_4_cd = SKILL_COOLDOWNS[SKILL_QLAOYI] * pet_skill_cooldown_multiplier
	is_aoyi = true
	hit_name = "hit4"
	_start_dragon_action("hit5")


func _start_dragon_action(action_name: String) -> void:
	if not ACTION_STOP_COUNTS[dragon_stage].has(action_name):
		return
	is_attacking = true
	velocity.x = 0.0
	_dragon_action = action_name
	_dragon_action_tick = 0
	_dragon_action_accumulator = 0.0
	_dragon_action_triggered.clear()
	_set_dragon_action_visual(action_name, 0)


func _tick_dragon_action(delta: float) -> void:
	if _dragon_action.is_empty() or not is_attacking:
		return
	if _dragon_action == "hit3":
		velocity.x = -DRAGON_RUSH_SPEED if monster_direction else DRAGON_RUSH_SPEED
	elif _dragon_action == "hit5":
		velocity.x = 0.0
		velocity.y = DRAGON_AOYI_RISE_SPEED
	elif _dragon_action == "hit6" and is_on_floor():
		do_ltwj(true)
		return
	_dragon_action_accumulator += delta * DRAGON_ACTION_TICK_RATE
	while _dragon_action_accumulator >= 1.0 and not _dragon_action.is_empty():
		_dragon_action_accumulator -= 1.0
		_dragon_action_tick += 1
		_set_dragon_action_visual(_dragon_action, _dragon_action_tick)
		_process_dragon_action_triggers()
		if _dragon_action_tick >= _dragon_action_total_ticks(_dragon_action):
			_finish_dragon_action()


func _dragon_action_total_ticks(action_name: String) -> int:
	var total := 0
	for stop_count in ACTION_STOP_COUNTS[dragon_stage].get(action_name, []):
		total += int(stop_count)
	return total


func _set_dragon_action_visual(action_name: String, action_tick: int) -> void:
	if (
		dragon_sprite == null
		or dragon_sprite.sprite_frames == null
		or not dragon_sprite.sprite_frames.has_animation(action_name)
	):
		return
	dragon_sprite.animation = action_name
	dragon_sprite.pause()
	var running := 0
	var frame_index := 0
	for stop_count in ACTION_STOP_COUNTS[dragon_stage].get(action_name, []):
		running += int(stop_count)
		if action_tick <= running:
			break
		frame_index += 1
	dragon_sprite.frame = clampi(frame_index, 0, dragon_sprite.sprite_frames.get_frame_count(action_name) - 1)
	_sync_dragon_model_facing()


func _trigger_once(key: String, expected_tick: int) -> bool:
	if _dragon_action_tick != expected_tick or _dragon_action_triggered.has(key):
		return false
	_dragon_action_triggered[key] = true
	return true


func _process_dragon_action_triggers() -> void:
	match _dragon_action:
		"hit1":
			var trigger_tick := 16 if dragon_stage <= 2 else 11
			if _trigger_once("hit1", trigger_tick):
				_spawn_hit1()
		"hit2":
			if _trigger_once("fs", 10):
				_spawn_dragon_clone()
		"hit3":
			if _trigger_once("sdcc", 24):
				_spawn_sdcc_bullet()
		"hit4":
			if _trigger_once("ltwj", 24):
				_spawn_ltwj_waves()
		"hit5":
			for trigger_tick in [12, 24, 36, 48]:
				if _trigger_once("aoyi_%d" % trigger_tick, trigger_tick):
					_spawn_qlaoyi_step(trigger_tick)


func _finish_dragon_action() -> void:
	var finished := _dragon_action
	_dragon_action = ""
	velocity.x = 0.0
	match finished:
		"hit3":
			if is_aoyi:
				if _has_skill(SKILL_LTWJ):
					do_ltwj(true)
				else:
					is_aoyi = false
					_end_dragon_attack()
			else:
				_end_dragon_attack()
		"hit4":
			is_aoyi = false
			_end_dragon_attack()
		"hit5":
			if is_aoyi and _has_skill(SKILL_SDCC):
				do_sdcc(true)
			elif is_aoyi and _has_skill(SKILL_LTWJ):
				_start_dragon_action("hit6")
			else:
				is_aoyi = false
				_end_dragon_attack()
		"hit6":
			do_ltwj(true)
		_:
			_end_dragon_attack()


func _end_dragon_attack() -> void:
	is_attacking = false
	hit_name = ""
	_play_dragon_model_animation("wait")


func _spawn_hit1() -> void:
	var bullet_name := "PetDragon1Bullet1"
	if dragon_stage == 2:
		bullet_name = "PetDragon2Bullet1"
	elif dragon_stage >= 3:
		bullet_name = "PetDragon3Bullet1"
	var x_offset := 65.0 if dragon_stage == 4 else 30.0
	var y_offset := -15.0 if dragon_stage == 4 else 0.0
	_add_dragon_bullet(
		bullet_name, _dragon_skill_origin() + _front_offset(x_offset, y_offset), "hit1", obj_attack_dict["hit1"]
	)


func _spawn_sdcc_bullet() -> void:
	_add_dragon_bullet("PetDragon2Bullet2", _dragon_skill_origin() + Vector2(0, 10), "hit2", obj_attack_dict["hit2"])


func _spawn_ltwj_waves() -> void:
	var base_point := global_position + Vector2(0, 40)
	var face_left := monster_direction
	var waves := LTWJ_CLONE_WAVES if is_dragon_clone else LTWJ_WAVES
	var repeat_count := 1 if is_dragon_clone else LTWJ_DAMAGE_FREQUENCY_MULTIPLIER
	for wave in waves:
		for repeat_index in range(repeat_count):
			var delay := float(wave["delay"]) + float(repeat_index) * LTWJ_DAMAGE_REPEAT_INTERVAL
			_spawn_ltwj_wave_after(delay, Array(wave["offsets"]), base_point, face_left)


func _spawn_ltwj_wave_after(delay: float, offsets: Array, base_point: Vector2, face_left: bool) -> void:
	var tree := get_tree()
	if tree == null:
		return
	if delay > 0.0:
		await tree.create_timer(delay, false).timeout
	if not is_inside_tree() or is_queued_for_deletion() or hp <= 0 or int(pet_data.get("isFight", 1)) != 1:
		return
	for offset in offsets:
		if not is_inside_tree() or is_queued_for_deletion() or hp <= 0 or int(pet_data.get("isFight", 1)) != 1:
			return
		_add_dragon_bullet(
			"PetDragon3Bullet3", base_point + Vector2(offset), "hit3", obj_attack_dict["hit3"], face_left
		)
		await tree.process_frame


func _spawn_qlaoyi_step(trigger_tick: int) -> void:
	if trigger_tick == 48:
		var ultimate = _add_dragon_bullet("PetDragonBullet4", _dragon_skill_origin(), "hit4", obj_attack_dict["hit4"])
		if ultimate != null:
			ultimate.set_meta("pet_dragon_ignore_hurt_interrupt", true)
	if not _has_skill(SKILL_FS):
		return
	var clone := _spawn_dragon_clone()
	if clone == null:
		return
	if trigger_tick == 12 or trigger_tick == 36:
		clone._face_right()
	else:
		clone._face_left()
	clone.is_aoyi = true
	if clone._has_skill(SKILL_SDCC):
		clone.do_sdcc(true)
	elif clone._has_skill(SKILL_LTWJ):
		clone._start_dragon_action("hit6")
	else:
		clone.is_aoyi = false
		is_aoyi = false


func _spawn_dragon_clone() -> PetDragonSummonBase:
	var scene := _dragon_scene_cache.get(dragon_stage) as PackedScene
	if scene == null or get_parent() == null:
		return null
	var clone := scene.instantiate() as PetDragonSummonBase
	if clone == null:
		return null
	clone.is_dragon_clone = true
	clone.dragon_clone_owner = self if not is_dragon_clone else dragon_clone_owner
	clone.dragon_clone_lifetime = 10.0 if dragon_stage <= 2 else 12.0
	clone.dragon_stage = dragon_stage
	clone.pet_data = pet_data.duplicate(true)
	clone.pet_data[DataKeys.HP] = hp
	clone.pet_data["生命上限"] = hp
	clone.pet_data[DataKeys.MP] = mp
	clone.pet_data["魔法上限"] = mp
	clone.pet_data["_dragon_clone_hp"] = hp
	clone.pet_data["_dragon_clone_mp"] = mp
	clone.pet_data[DataKeys.ATTACK] = int(
		round(
			(
				float(attack_in)
				* PET_SKILL_PROGRESSION.damage_multiplier(
					PET_SKILL_PROGRESSION.get_level(pet_data, SKILL_NAMES[SKILL_FS])
				)
			)
		)
	)
	clone.pet_data["技能"] = _learned_skills().duplicate(true) if dragon_stage >= 2 else []
	clone.pet_data["isFight"] = 1
	if dragon_stage >= 4:
		clone.pet_data[DataKeys.EXP] = 0
	get_parent().add_child(clone)
	clone.global_position = global_position + Vector2(randf_range(-150.0, 150.0), -50.0)
	clone.modulate.a = 0.5
	return clone


func _add_dragon_bullet(
	bullet_name: String, bullet_position: Vector2, attack_name: String, attack_data: Dictionary, forced_face_left = null
):
	if bullet == null or PET_DRAGON_BULLET_SCENE == null:
		return null
	var instance = PET_DRAGON_BULLET_SCENE.instantiate()
	instance.att_list = attack_data
	instance.hit_name = attack_name
	instance.global_position = bullet_position
	instance.dir = monster_direction if forced_face_left == null else bool(forced_face_left)
	instance.skill_name = bullet_name
	instance.speed = 1.0
	instance.set_meta("summoner", self)
	instance.set_meta("pet_dragon_summon", true)
	instance.set_meta("pet_dragon_follow_offset", bullet_position - global_position)
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


func _front_offset(x: float, y: float) -> Vector2:
	return Vector2(-x if monster_direction else x, y)


func _dragon_skill_origin() -> Vector2:
	if dragon_sprite == null:
		return global_position
	var original_offset_y := float(DRAGON_ORIGINAL_SPRITE_OFFSET_Y.get(dragon_stage, 0.0))
	var visual_height_delta := (
		dragon_sprite.position.y + (dragon_sprite.offset.y - original_offset_y) * dragon_sprite.scale.y
	)
	return global_position + Vector2(0.0, visual_height_delta)


func _face_current_target() -> void:
	if is_instance_valid(current_target):
		to_monster()


func _setup_dragon_model_frames() -> void:
	var frames := load(DRAGON_MODEL_FRAMES_RES % dragon_stage) as SpriteFrames
	if frames == null:
		push_error("PetDragon SpriteFrames missing for stage %d" % dragon_stage)
		return
	dragon_sprite.sprite_frames = frames
	_play_dragon_model_animation("wait")


func _warm_dragon_action_textures(animation_name: StringName) -> void:
	if dragon_sprite == null or dragon_sprite.sprite_frames == null:
		return
	if not dragon_sprite.sprite_frames.has_animation(animation_name):
		return
	var frame_count := dragon_sprite.sprite_frames.get_frame_count(animation_name)
	for frame_index in range(frame_count):
		var texture := dragon_sprite.sprite_frames.get_frame_texture(animation_name, frame_index)
		if texture != null:
			texture.get_rid()


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
	_sync_dragon_model_facing()


func _face_right() -> void:
	monster_direction = false
	if base_damage_box != null:
		base_damage_box.scale.x = -1
	if monster_dir != null:
		monster_dir.scale.x = -1
	_sync_dragon_model_facing()


func _sync_dragon_model_facing() -> void:
	if dragon_sprite == null:
		return
	dragon_sprite.flip_h = false


func play_move_animation() -> void:
	if not is_attacking:
		_play_dragon_model_animation("walk")


func stop_move() -> void:
	velocity.x = 0
	if not is_attacking and not is_be_attacking:
		_play_dragon_model_animation("wait")


func _play_dragon_model_animation(animation_name: String) -> void:
	if (
		dragon_sprite == null
		or dragon_sprite.sprite_frames == null
		or not dragon_sprite.sprite_frames.has_animation(animation_name)
	):
		return
	_sync_dragon_model_facing()
	if dragon_sprite.animation != animation_name:
		dragon_sprite.play(animation_name)
	elif not dragon_sprite.is_playing():
		dragon_sprite.play()

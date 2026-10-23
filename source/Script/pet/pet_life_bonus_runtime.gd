extends Node

const COOLDOWN_SECONDS := 30.0
const BONUS_RATE_PER_LEVEL := 0.02
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
const LEARNED_SKILLS_KEY := "已学习技能"
const LEARNABLE_SKILLS := ["生命加成", "攻击加成", "防御加成", "魔法庇佑", "嗜血狂爆", "法术能量", "天生蛮力", "自然守护", "生命祝福", "魔法加成"]
const OWNER_BUFFS := {
	"生命加成": "PetLifeBonus", "攻击加成": "PetAttackBonus", "防御加成": "PetDefenseBonus", "魔法加成": "PetManaBonus"
}

var pet_data: Dictionary = {}
var _cooldown_timer: Timer
var _pet_effects_applied := false


static func scaled_bonus(base_value: int, skill_level: int) -> int:
	return maxi(1, roundi(float(maxi(1, base_value)) * float(clampi(skill_level, 1, 10)) * BONUS_RATE_PER_LEVEL))


static func active_scaled_bonus(base_value: int, skill_level: int, root_bone: int) -> int:
	var root_multiplier := 1.0 + float(clampi(root_bone, 0, 25)) * 0.02
	return maxi(
		1,
		roundi(float(maxi(1, base_value)) * float(clampi(skill_level, 1, 10)) * BONUS_RATE_PER_LEVEL * root_multiplier)
	)


static func learned_cooldown_seconds(data: Dictionary) -> float:
	return COOLDOWN_SECONDS * (1.0 - float(clampi(int(data.get("灵力", 0)), 0, 25)) * 0.02)


static func defense_bonuses(physical_defense: int, magic_defense: int, skill_level: int) -> Dictionary:
	return {"physical": scaled_bonus(physical_defense, skill_level), "magic": scaled_bonus(magic_defense, skill_level)}


static func bonus_health(pet_health: int, skill_level: int) -> int:
	return scaled_bonus(pet_health, skill_level)


static func duration_seconds(skill_level: int) -> float:
	return float(clampi(skill_level, 1, 10) * 10 + 20)


static func permanent_stat_bonus(data: Dictionary, skill_name: String, base_value: int) -> int:
	if not learned_skill_names(data).has(skill_name):
		return 0
	return scaled_bonus(base_value, PET_SKILL_PROGRESSION.get_level(data, skill_name))


static func learned_skill_names(data: Dictionary) -> Array:
	var result: Array = []
	for source_key in [LEARNED_SKILLS_KEY, "技能"]:
		var skills_value: Variant = data.get(source_key, [])
		if skills_value is Array:
			for skill in skills_value:
				var skill_name := str(skill)
				if skill_name in LEARNABLE_SKILLS and not result.has(skill_name):
					result.append(skill_name)
	var levels: Variant = data.get(PET_SKILL_PROGRESSION.LEVELS_KEY, {})
	if levels is Dictionary:
		for skill in levels.keys():
			var skill_name := str(skill)
			if skill_name in LEARNABLE_SKILLS and not result.has(skill_name):
				result.append(skill_name)
	return result


func setup(data: Dictionary) -> void:
	pet_data = data.duplicate(true)


func refresh_after_pet_reset(data: Dictionary) -> void:
	pet_data = data.duplicate(true)
	_pet_effects_applied = false
	call_deferred("_apply_pet_effects")
	call_deferred("_activate_owner_skills")


func _ready() -> void:
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_activate_timed_skills)
	add_child(_cooldown_timer)
	call_deferred("_start_skills")


func _start_skills() -> void:
	if learned_skill_names(pet_data).is_empty():
		queue_free()
		return
	_apply_pet_effects()
	_activate_timed_skills()


func _has_skill(skill_name: String) -> bool:
	return learned_skill_names(pet_data).has(skill_name)


func _skill_level(skill_name: String) -> int:
	return PET_SKILL_PROGRESSION.get_level(pet_data, skill_name)


func cooldown_left() -> float:
	return _cooldown_timer.time_left if _cooldown_timer != null else 0.0


func cooldown_max() -> float:
	return learned_cooldown_seconds(pet_data)


func _apply_pet_effects() -> void:
	if _pet_effects_applied:
		return
	var pet: Node = get_parent()
	if pet == null:
		return
	var root_bone := int(pet_data.get("根骨", 0))
	if _has_skill("嗜血狂爆") and pet.get("crit") != null:
		pet.set(
			"crit", int(pet.get("crit")) + active_scaled_bonus(int(pet.get("crit")), _skill_level("嗜血狂爆"), root_bone)
		)
	if _has_skill("法术能量"):
		var root_multiplier := 1.0 + float(clampi(root_bone, 0, 25)) * 0.02
		_apply_skill_damage_bonus(pet, 1.0 + float(_skill_level("法术能量")) * BONUS_RATE_PER_LEVEL * root_multiplier)
	_pet_effects_applied = true


func _apply_skill_damage_bonus(pet: Node, multiplier: float) -> void:
	var attacks_value: Variant = pet.get("obj_attack_dict")
	if not (attacks_value is Dictionary):
		return
	for attack_key in attacks_value:
		if str(attack_key) == "hit1":
			continue
		var attack_value: Variant = attacks_value[attack_key]
		if attack_value is Dictionary and attack_value.has("power"):
			attack_value["power"] = maxi(1, roundi(float(attack_value.get("power", 1)) * multiplier))


func _activate_timed_skills() -> void:
	_apply_pet_effects()
	_activate_owner_skills()
	_cooldown_timer.start(learned_cooldown_seconds(pet_data))


func _activate_owner_skills() -> void:
	var pet: Node = get_parent()
	if pet == null:
		return
	var owner_props: Node = pet.get("RoleProp") as Node
	if owner_props == null:
		return
	var hero: Node = owner_props.get("source_player") as Node
	if not is_instance_valid(hero) or bool(hero.get("is_death")):
		return
	var buff_parent: Node = hero.get("buff") as Node
	if buff_parent == null:
		return
	for skill_name in OWNER_BUFFS:
		if not _has_skill(skill_name):
			continue
		var base_value := _owner_bonus_base_value(pet, skill_name)
		var level := _skill_level(skill_name)
		var root_bone := int(pet_data.get("根骨", 0))
		var buff_info := {
			"Name": OWNER_BUFFS[skill_name],
			"value": active_scaled_bonus(base_value, level, root_bone),
			"AddTime": duration_seconds(level),
			"reduce_interval": 1.0,
			"AttackKind": "",
			"CanAdd": false
		}
		if skill_name == "防御加成":
			var magic_defense: Variant = pet.get("mdef")
			buff_info["value"] = active_scaled_bonus(base_value, level, root_bone)
			buff_info["magic_value"] = active_scaled_bonus(
				int(magic_defense) if magic_defense != null else base_value, level, root_bone
			)
		Global.add_buff(buff_parent, buff_info)


func _owner_bonus_base_value(pet: Node, skill_name: String) -> int:
	match skill_name:
		"生命加成":
			return int(pet.get("max_hp"))
		"攻击加成":
			return int(pet.get("attack_in"))
		"防御加成":
			return int(pet.get("def"))
		"魔法加成":
			return int(pet.get("max_mp"))
	return 1

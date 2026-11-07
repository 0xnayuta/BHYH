class_name PetNianFamily
extends RefCounted
## 年兽系宠物规则：四阶、阶段技能、归一化、进化、场景路径与死亡别名。
## 只处理档案数据与规则，不持有场景树；调用方必须显式传入所属档案，避免 1P/2P 回落。

const KIND := "PetNian"
const UNIT_META := "pet_nian_unit"
const SCENE_PATH := "res://Scene/pet/pet_nian_summon_%d.tscn"
const DATA := preload("res://Script/pet/pet_nian_data.gd")
const BASE_STAT_LIMITS := {"生命": 3500, "魔法": 2800, "攻击": 4000, "防御": 2800}


static func matches(pet: Dictionary) -> bool:
	return DATA.matches(pet)


static func is_name(pet_name: String) -> bool:
	var clean_name := pet_name.strip_edges()
	return DATA.NAMES.values().has(clean_name) or DATA.LEGACY_NAMES.has(clean_name)


static func stage_for_level(level: int) -> int:
	return DATA.stage_for_level(level)


static func stage_name(stage: int) -> String:
	return str(DATA.NAMES[clampi(stage, 1, 4)])


static func stage_skills(stage: int) -> Array:
	return DATA.SKILLS.slice(0, clampi(stage, 1, 4))


static func scene_path(stage: int) -> String:
	return SCENE_PATH % clampi(stage, 1, 4)


static func normalize_spawn(pet: Dictionary, profile: Node) -> void:
	if profile == null or not matches(pet):
		return
	var active_key := str(PlayerDataStore.ACTIVE_PET_KEY)
	var active_name := str(profile.player_data.get(active_key, ""))
	var keep_fighting := bool(pet.get(DataKeys.DEPLOYED, false)) or active_name == KIND or is_name(active_name)
	DATA.normalize(pet)
	for stat_name in BASE_STAT_LIMITS:
		pet["%s资质基础上限" % stat_name] = int(BASE_STAT_LIMITS[stat_name])
	pet[DataKeys.DEPLOYED] = keep_fighting


static func evolve(pet: Dictionary, profile: Node) -> void:
	if profile == null or not matches(pet):
		return
	normalize_spawn(pet, profile)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		var active_key := str(PlayerDataStore.ACTIVE_PET_KEY)
		profile.player_data[active_key] = KIND
		profile.player_data["出战宠物"] = KIND


static func append_death_aliases(aliases: Array[String], pet_name: String) -> void:
	if pet_name != KIND and not is_name(pet_name):
		return
	if not aliases.has(KIND):
		aliases.append(KIND)
	for name in DATA.NAMES.values():
		if not aliases.has(str(name)):
			aliases.append(str(name))


static func setup(unit: Node, stage: int) -> void:
	if unit != null and unit.has_method("setup_pet_turtle"):
		unit.call("setup_pet_turtle", stage)

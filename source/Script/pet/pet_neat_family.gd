class_name PetNeatFamily
extends RefCounted
## 丑牛系宠物规则：四阶、阶段技能、归一化、进化、场景路径与死亡别名。
## 只处理档案数据，不持有场景树；调用方必须显式传入所属档案，避免 1P/2P 回落。

const KIND := "PetNeat"
const UNIT_META := "pet_neat_unit"
const SCENE_PATH := "res://Scene/pet/pet_neat_summon_%d.tscn"
const STAGE_NAMES := {1: "丑牛元帅", 2: "丑牛元帅", 3: "丑牛元帅", 4: "丑牛大元帅"}
const STAGE_SKILLS := {
	1: ["蛮牛冲撞"],
	2: ["蛮牛冲撞"],
	3: ["蛮牛冲撞", "蛮力践踏"],
	4: ["蛮牛冲撞", "蛮力践踏", "丑牛奥义"],
}


static func matches(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == KIND:
		return true
	return is_name(str(pet.get(DataKeys.ALT_NAME, ""))) or is_name(str(pet.get(DataKeys.NAME, "")))


static func is_name(pet_name: String) -> bool:
	return pet_name.strip_edges() in ["丑牛", "丑牛元帅", "丑牛大元帅"]


static func stage_for_level(level: int) -> int:
	if level >= 50:
		return 4
	if level >= 30:
		return 3
	if level >= 15:
		return 2
	return 1


static func stage_name(stage: int) -> String:
	return str(STAGE_NAMES[clampi(stage, 1, 4)])


static func stage_skills(stage: int) -> Array:
	return (STAGE_SKILLS[clampi(stage, 1, 4)] as Array).duplicate(true)


static func scene_path(stage: int) -> String:
	return SCENE_PATH % clampi(stage, 1, 4)


static func normalize_spawn(pet: Dictionary, profile: Node) -> void:
	if profile == null or not matches(pet):
		return
	var active_key := str(PlayerDataStore.ACTIVE_PET_KEY)
	var active_name := str(profile.player_data.get(active_key, ""))
	var keep_fighting := bool(pet.get(DataKeys.DEPLOYED, false)) or active_name == KIND or is_name(active_name)
	var stage := stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = KIND
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = stage_name(stage)
	pet[DataKeys.NAME] = stage_name(stage)
	pet["技能"] = stage_skills(stage)
	pet[DataKeys.DEPLOYED] = keep_fighting


static func evolve(pet: Dictionary, profile: Node) -> void:
	if profile == null or not matches(pet):
		return
	normalize_spawn(pet, profile)
	var stage := stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = KIND
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = stage_name(stage)
	pet[DataKeys.NAME] = stage_name(stage)
	pet["技能"] = stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		var active_key := str(PlayerDataStore.ACTIVE_PET_KEY)
		profile.player_data[active_key] = KIND
		profile.player_data["出战宠物"] = KIND


static func append_death_aliases(aliases: Array[String], pet_name: String) -> void:
	if pet_name != KIND and not is_name(pet_name):
		return
	if not aliases.has(KIND):
		aliases.append(KIND)
	for name in STAGE_NAMES.values():
		if not aliases.has(str(name)):
			aliases.append(str(name))


static func setup(unit: Node, stage: int) -> void:
	if unit != null and unit.has_method("setup_pet_turtle"):
		unit.call("setup_pet_turtle", stage)

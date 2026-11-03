class_name PetTurtleFamily
extends RefCounted
## 龟布系宠物规则：阶段、技能、归一化、进化与场景路径。
## 只处理档案数据，不持有场景树；调用方必须显式传入所属档案，避免 1P/2P 回落。

const KIND := "PetTurtle"
const UNIT_META := "pet_turtle_unit"
const SCENE_PATH := "res://Scene/pet/pet_turtle_summon_%d.tscn"
const STAGE_NAMES := {1: "龟布", 2: "墨玄龟", 3: "玄武将军", 4: "玄武大帝"}
const STAGE_SKILLS := {
	1: ["水疗盾"],
	2: ["水疗盾", "同心链接"],
	3: ["水疗盾", "同心链接", "水湮八荒"],
	4: ["水疗盾", "同心链接", "水湮八荒", "玄武奥义"],
}
const BASE_STAT_LIMITS := {
	"生命": 4000,
	"魔法": 1800,
	"攻击": 1500,
	"防御": 4000,
}


static func matches(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == KIND:
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return pet_name.begins_with("玄武") or pet_name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]


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
	var active_key := active_pet_name_key()
	var keep_fighting := bool(pet.get(DataKeys.DEPLOYED, false)) or str(profile.player_data.get(active_key, "")) == KIND
	var stage := stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = KIND
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = stage_name(stage)
	pet[DataKeys.NAME] = stage_name(stage)
	pet["技能"] = stage_skills(stage)
	for stat_name in BASE_STAT_LIMITS:
		pet["%s资质基础上限" % stat_name] = int(BASE_STAT_LIMITS[stat_name])
	pet[DataKeys.DEPLOYED] = keep_fighting


static func evolve(pet: Dictionary, profile: Node) -> void:
	if profile == null or not matches(pet):
		return
	normalize_spawn(pet, profile)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		var active_key := active_pet_name_key()
		profile.player_data[active_key] = KIND
		profile.player_data["出战宠物"] = KIND


static func setup(unit: Node, stage: int) -> void:
	if unit != null and unit.has_method("setup_pet_turtle"):
		unit.call("setup_pet_turtle", stage)


static func active_pet_name_key() -> String:
	return str(PlayerDataStore.ACTIVE_PET_KEY)

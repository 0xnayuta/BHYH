class_name PetDragonFamily
extends RefCounted
## 青龙系宠物规则：阶段、技能、归一化、进化与场景路径。
## 只处理档案数据，不持有场景树；调用方必须显式传入所属档案，避免 1P/2P 回落。

const KIND := "PetDragon"
const UNIT_META := "pet_dragon_unit"
const SCENE_PATH := "res://Scene/pet/pet_dragon_summon_%d.tscn"
const STAGE_NAMES := {1: "龙仔", 2: "绿英龙", 3: "青龙将军", 4: "青龙妖圣"}
const STAGE_SKILLS := {
	1: ["分身"],
	2: ["分身", "闪电冲刺"],
	3: ["分身", "闪电冲刺", "雷霆万钧"],
	4: ["分身", "闪电冲刺", "雷霆万钧", "青龙奥义"],
}
const BASE_STAT_LIMITS := {
	"生命": 2500,
	"魔法": 1800,
	"攻击": 3000,
	"防御": 1800,
}


static func matches(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == KIND:
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return pet_name.begins_with("辰龙") or pet_name in STAGE_NAMES.values()


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
	var keep_fighting := bool(pet.get(DataKeys.DEPLOYED, true))
	pet[DataKeys.TYPE] = KIND
	if not pet.has(DataKeys.ALT_NAME):
		pet[DataKeys.ALT_NAME] = stage_name(1)
	if not pet.has("阶段"):
		pet["阶段"] = 1
	if not pet.has(DataKeys.LEVEL):
		pet[DataKeys.LEVEL] = int(pet.get("阶段", 1))
	for stat_name in BASE_STAT_LIMITS:
		pet["%s资质基础上限" % stat_name] = int(BASE_STAT_LIMITS[stat_name])
	pet[DataKeys.DEPLOYED] = keep_fighting


static func evolve(pet: Dictionary, profile: Node) -> void:
	if profile == null or not matches(pet):
		return
	normalize_spawn(pet, profile)
	var stage := stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet["阶段"] = stage
	pet[DataKeys.TYPE] = KIND
	pet[DataKeys.ALT_NAME] = stage_name(stage)
	pet["技能"] = stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		var active_key := str(PlayerDataStore.ACTIVE_PET_KEY)
		profile.player_data[active_key] = KIND
		profile.player_data["出战宠物"] = KIND


static func setup(unit: Node, stage: int) -> void:
	if unit != null and unit.has_method("setup_pet_dragon"):
		unit.call("setup_pet_dragon", stage)

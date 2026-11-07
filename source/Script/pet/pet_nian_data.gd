extends RefCounted
class_name PetNianData

const NAMES := {1: "年宝", 2: "小年兽", 3: "年兽", 4: "大年兽"}
const LEGACY_NAMES := ["年兽幼崽", "年兽·三阶", "年兽·四阶"]
const LEARNED_SKILLS_KEY := "已学习技能"
const SKILLS := ["年兽扑击", "年兽烈焰", "年兽爆炎", "年兽奥义"]
const BASE_QUALITY_CAPS := {"生命": 3500, "魔法": 2800, "攻击": 4000, "防御": 2800}


static func skill_icon_path(stage: int, skill: int) -> String:
	if skill == 4:
		return "res://Art/pet/skillicon/aoyi.png"
	var first_icon: int = [1, 2, 4, 7][clampi(stage, 1, 4) - 1]
	return "res://Art/pet/pet_nian/icons/skill%d.png" % (first_icon + skill - 1)


static func matches(pet: Dictionary) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	return str(pet.get(DataKeys.TYPE, "")) == "PetNian" or NAMES.values().has(pet_name) or LEGACY_NAMES.has(pet_name)


static func stage_for_level(level: int) -> int:
	return 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1


static func normalize(pet: Dictionary) -> void:
	var wisdom_bonus := clampi(int(pet.get(DataKeys.Pet.SAVVY, 0)), 0, 25) * 100
	for quality: String in BASE_QUALITY_CAPS:
		pet[quality + "资质基础上限"] = BASE_QUALITY_CAPS[quality]
		pet[quality + "资质上限"] = int(BASE_QUALITY_CAPS[quality]) + wisdom_bonus
	var stage := stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetNian"
	pet[DataKeys.Pet.STAGE] = stage
	pet[DataKeys.ALT_NAME] = NAMES[stage]
	pet[DataKeys.NAME] = NAMES[stage]
	var skills: Array = SKILLS.slice(0, stage)
	for learned: String in pet.get(LEARNED_SKILLS_KEY, []):
		if not skills.has(learned):
			skills.append(learned)
	pet[DataKeys.Skill.SKILL] = skills

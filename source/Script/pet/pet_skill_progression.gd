extends RefCounted

const LEVELS_KEY := "技能等级"
const LEARNED_SKILLS_KEY := "已学习技能"
const MAX_LEVEL := 10


static func ensure_levels(pet: Dictionary) -> Dictionary:
	var raw_levels: Variant = pet.get(LEVELS_KEY, {})
	var levels: Dictionary = raw_levels if raw_levels is Dictionary else {}
	for source_key in ["技能", LEARNED_SKILLS_KEY]:
		var raw_skills: Variant = pet.get(source_key, [])
		if raw_skills is Array:
			for raw_skill in raw_skills:
				var skill_name := str(raw_skill)
				if skill_name.is_empty():
					continue
				levels[skill_name] = clampi(int(levels.get(skill_name, 1)), 1, MAX_LEVEL)
	pet[LEVELS_KEY] = levels
	return levels


static func get_level(pet: Dictionary, skill_name: String) -> int:
	if skill_name.is_empty():
		return 1
	var levels := ensure_levels(pet)
	return clampi(int(levels.get(skill_name, 1)), 1, MAX_LEVEL)


static func mana_cost(base_cost: int, level: int) -> int:
	if base_cost <= 0:
		return 0
	var upgrade_count := maxi(0, clampi(level, 1, MAX_LEVEL) - 1)
	return base_cost + (3 + 2 * upgrade_count) * upgrade_count


static func upgrade_cost(skill_index: int, current_level: int) -> int:
	return 100 + maxi(0, skill_index) * 300 + 500 * clampi(current_level, 1, MAX_LEVEL)


static func damage_multiplier(level: int) -> float:
	return 1.0 + float(maxi(0, clampi(level, 1, MAX_LEVEL) - 1)) * 0.1


static func scaled_power(base_power: int, pet: Dictionary, skill_name: String) -> int:
	if base_power <= 0:
		return 0
	return maxi(1, int(round(float(base_power) * damage_multiplier(get_level(pet, skill_name)))))

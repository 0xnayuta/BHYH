extends RefCounted

## 7.1 北俱芦洲持续成长：以云川（Level_74）同类型怪物为基线，按阶段复利叠加 10%。

const GROWTH_STEP := 1.1
const INTEGER_STATS := ["hp", "attack", "def", "mdef", "crit", "miss", "hit", "armor_break", "magic_break"]
const RATIO_STATS := ["toughness", "crit_reduce", "damage_bonus", "damage_reduction"]


static func apply(config: Dictionary, steps: int) -> Dictionary:
	var result := config.duplicate(true)
	if steps <= 0 or config.is_empty():
		return result
	var previous: Game4EastLateLevel = load("res://Script/level/level_74.gd").new() as Game4EastLateLevel
	if previous == null:
		return result
	var baseline := previous.get_level_monster_config(3343 if bool(config.get("is_boss", false)) else 3340)
	previous.free()
	for _step in range(steps):
		for stat: String in INTEGER_STATS:
			if baseline.has(stat):
				baseline[stat] = roundi(float(baseline[stat]) * GROWTH_STEP)
		for stat: String in RATIO_STATS:
			if baseline.has(stat):
				baseline[stat] = float(baseline[stat]) * GROWTH_STEP
	for stat: String in INTEGER_STATS + RATIO_STATS:
		if baseline.has(stat):
			result[stat] = baseline[stat]
	return result

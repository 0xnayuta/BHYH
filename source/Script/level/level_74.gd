extends Game4EastLateLevel


func _init() -> void:
	stage_number = 74


const LEVEL_74_MONSTER_DATA := {
	3340:
	{
		"hp": 79720245,
		"attack": 113379,
		"def": 18602,
		"mdef": 18602,
		"armor_break": 25688,
		"magic_break": 25688,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3341:
	{
		"hp": 79720245,
		"attack": 113379,
		"def": 18602,
		"mdef": 18602,
		"armor_break": 25688,
		"magic_break": 25688,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3342:
	{
		"hp": 79720245,
		"attack": 113379,
		"def": 18602,
		"mdef": 18602,
		"armor_break": 25688,
		"magic_break": 25688,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3343:
	{
		"hp": 389743420,
		"attack": 168299,
		"def": 21613,
		"mdef": 21613,
		"armor_break": 29231,
		"magic_break": 29231,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": true
	},
}


func get_level_monster_config(monster_id: int) -> Dictionary:
	return _get_monster_config_with_level_data(monster_id, LEVEL_74_MONSTER_DATA)

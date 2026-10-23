extends Game4EastLateLevel


func _init() -> void:
	stage_number = 73


const LEVEL_73_MONSTER_DATA := {
	3320:
	{
		"hp": 72472950,
		"attack": 103072,
		"def": 16911,
		"mdef": 16911,
		"armor_break": 23353,
		"magic_break": 23353,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3321:
	{
		"hp": 72472950,
		"attack": 103072,
		"def": 16911,
		"mdef": 16911,
		"armor_break": 23353,
		"magic_break": 23353,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3322:
	{
		"hp": 72472950,
		"attack": 103072,
		"def": 16911,
		"mdef": 16911,
		"armor_break": 23353,
		"magic_break": 23353,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3323:
	{
		"hp": 354312200,
		"attack": 152999,
		"def": 19648,
		"mdef": 19648,
		"armor_break": 26574,
		"magic_break": 26574,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": true
	},
}


func get_level_monster_config(monster_id: int) -> Dictionary:
	return _get_monster_config_with_level_data(monster_id, LEVEL_73_MONSTER_DATA)

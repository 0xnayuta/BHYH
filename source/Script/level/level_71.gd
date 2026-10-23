extends Game4EastLateLevel


func _init() -> void:
	stage_number = 71


const LEVEL_71_MONSTER_DATA := {
	3274:
	{
		"hp": 59895000,
		"attack": 85184,
		"def": 12705,
		"mdef": 12705,
		"armor_break": 19300,
		"magic_break": 19300,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3275:
	{
		"hp": 59895000,
		"attack": 85184,
		"def": 12705,
		"mdef": 12705,
		"armor_break": 19300,
		"magic_break": 19300,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3276:
	{
		"hp": 59895000,
		"attack": 85184,
		"def": 12705,
		"mdef": 12705,
		"armor_break": 19300,
		"magic_break": 19300,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3277:
	{
		"hp": 292820000,
		"attack": 126445,
		"def": 15238,
		"mdef": 15238,
		"armor_break": 21962,
		"magic_break": 21962,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"independent_drop_list":
		[
			{"name": "ygwqsszzs", "value": 1, "chance": 0.1},
			{"name": "ygwqblzzs", "value": 1, "chance": 0.1},
			{"name": "ygwqnzzzs", "value": 1, "chance": 0.1}
		],
		"is_boss": true
	},
}


func get_level_monster_config(monster_id: int) -> Dictionary:
	return _get_monster_config_with_level_data(monster_id, LEVEL_71_MONSTER_DATA)

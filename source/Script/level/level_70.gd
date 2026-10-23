extends Game4EastLateLevel


func _init() -> void:
	stage_number = 70


const LEVEL_70_MONSTER_DATA := {
	3221:
	{
		"hp": 54450000,
		"attack": 77440,
		"def": 12705,
		"mdef": 12705,
		"armor_break": 17545,
		"magic_break": 17545,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3222:
	{
		"hp": 54450000,
		"attack": 77440,
		"def": 12705,
		"mdef": 12705,
		"armor_break": 17545,
		"magic_break": 17545,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3226:
	{
		"hp": 54450000,
		"attack": 77440,
		"def": 12705,
		"mdef": 12705,
		"armor_break": 17545,
		"magic_break": 17545,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3223:
	{
		"hp": 266200000,
		"attack": 114950,
		"def": 14762,
		"mdef": 14762,
		"armor_break": 19965,
		"magic_break": 19965,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"independent_drop_list":
		[
			{"name": "ygwqwkzzs", "value": 1, "chance": 0.1},
			{"name": "ygwqtszzs", "value": 1, "chance": 0.1},
			{"name": "ygwqbjzzs", "value": 1, "chance": 0.1}
		],
		"is_boss": true
	},
}


func get_level_monster_config(monster_id: int) -> Dictionary:
	return _get_monster_config_with_level_data(monster_id, LEVEL_70_MONSTER_DATA)

extends Game4EastLateLevel


func _init() -> void:
	stage_number = 72


const LEVEL_72_MONSTER_DATA := {
	3308:
	{
		"hp": 65884500,
		"attack": 93702,
		"def": 12705,
		"mdef": 12705,
		"armor_break": 21230,
		"magic_break": 21230,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3309:
	{
		"hp": 65884500,
		"attack": 93702,
		"def": 12705,
		"mdef": 12705,
		"armor_break": 21230,
		"magic_break": 21230,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3310:
	{
		"hp": 322102000,
		"attack": 139090,
		"def": 15862,
		"mdef": 15862,
		"armor_break": 24158,
		"magic_break": 24158,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"independent_drop_list": [{"name": "pgs_9", "min_value": 2, "max_value": 5, "chance": 0.15}],
		"is_boss": true
	},
}


func get_level_monster_config(monster_id: int) -> Dictionary:
	return _get_monster_config_with_level_data(monster_id, LEVEL_72_MONSTER_DATA)

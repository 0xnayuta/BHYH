extends Game4EastLateLevel


func _init() -> void:
	stage_number = 69


const LEVEL_69_MONSTER_DATA := {
	3198:
	{
		"hp": 49500000,
		"attack": 70400,
		"def": 11550,
		"mdef": 11550,
		"armor_break": 15950,
		"magic_break": 15950,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3199:
	{
		"hp": 49500000,
		"attack": 70400,
		"def": 11550,
		"mdef": 11550,
		"armor_break": 15950,
		"magic_break": 15950,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3201:
	{
		"hp": 49500000,
		"attack": 70400,
		"def": 11550,
		"mdef": 11550,
		"armor_break": 15950,
		"magic_break": 15950,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false
	},
	3200:
	{
		"hp": 242000000,
		"attack": 104500,
		"def": 13420,
		"mdef": 13420,
		"armor_break": 18150,
		"magic_break": 18150,
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"independent_drop_list": [{"name": "pgs_8", "min_value": 2, "max_value": 5, "chance": 0.15}],
		"is_boss": true
	},
}


func get_level_monster_config(monster_id: int) -> Dictionary:
	return _get_monster_config_with_level_data(monster_id, LEVEL_69_MONSTER_DATA)

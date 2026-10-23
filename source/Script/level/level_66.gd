extends Game4ImportedLevel

const STAGE_COUNT := 5
const SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 4000.0]
const SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4911.0]
const STAGE_TRIGGER_X := [418.0, 1356.0, 2498.0, 3385.0, 4424.0]

const LEVEL_66_MONSTER_DATA := {
	3159:
	{
		"name": "猴妖",
		"level": 90,
		"hp": 45000000,
		"attack": 54000,
		"def": 9850,
		"mdef": 9850,
		"crit": 340,
		"miss": 180,
		"hit": 2500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 14500,
		"magic_break": 14500,
		"speed": 12.0,
		"min_range": 0.0,
		"range": 140.0,
		"sight": 820.0,
		"attack_desire": 100,
		"exp": 12,
		"coin": 10,
		"drop_rate": 0.0,
		"drop_list": [],
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false,
		"max_protect": 100.0,
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}},
	},
	3160:
	{
		"name": "银杏精",
		"level": 90,
		"hp": 45000000,
		"attack": 54000,
		"def": 9850,
		"mdef": 9850,
		"crit": 340,
		"miss": 180,
		"hit": 2500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 14500,
		"magic_break": 14500,
		"speed": 12.0,
		"min_range": 0.0,
		"range": 160.0,
		"sight": 820.0,
		"attack_desire": 100,
		"exp": 12,
		"coin": 10,
		"drop_rate": 0.0,
		"drop_list": [],
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": false,
		"max_protect": 100.0,
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}},
	},
	3161:
	{
		"name": "通臂白猿",
		"level": 90,
		"hp": 220000000,
		"attack": 95000,
		"def": 10850,
		"mdef": 10850,
		"crit": 500,
		"miss": 180,
		"hit": 2500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 15500,
		"magic_break": 15500,
		"speed": 10.0,
		"min_range": 0.0,
		"range": 180.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 120,
		"coin": 320,
		"drop_rate": 0.0,
		"drop_list": [],
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"independent_drop_list": [{"name": "pgs_7", "min_value": 2, "max_value": 5, "chance": 0.15}],
		"is_boss": true,
		"max_protect": 250.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
			"hit2": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
			"hit3": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
		},
	},
}

const BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3159,
		"position": Vector2(825, 409),
		"total": 6,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3159,
		"position": Vector2(221, 401),
		"total": 6,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 3,
		"stage": 2,
		"monster": 3160,
		"position": Vector2(1211, 437),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 4,
		"stage": 2,
		"monster": 3159,
		"position": Vector2(1942, 430),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3159,
		"position": Vector2(1169, 437),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 3
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3159,
		"position": Vector2(1984, 427),
		"total": 2,
		"face": -1,
		"after_spawn": 5,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3160,
		"position": Vector2(1136, 438),
		"total": 2,
		"face": 1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3160,
		"position": Vector2(2023, 426),
		"total": 2,
		"face": -1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3160,
		"position": Vector2(2256, 439),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3159,
		"position": Vector2(3082, 432),
		"total": 4,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3159,
		"position": Vector2(2298, 441),
		"total": 4,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 10
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3160,
		"position": Vector2(3040, 438),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 9
	},
	{
		"point": 13,
		"stage": 4,
		"monster": 3159,
		"position": Vector2(3198, 427),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 4,
		"monster": 3159,
		"position": Vector2(4016, 432),
		"total": 2,
		"face": -1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3160,
		"position": Vector2(4094, 429),
		"total": 2,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3160,
		"position": Vector2(3234, 425),
		"total": 2,
		"face": 1,
		"after_spawn": 15,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3159,
		"position": Vector2(4070, 430),
		"total": 2,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 14
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3159,
		"position": Vector2(3278, 425),
		"total": 2,
		"face": 1,
		"after_spawn": 17,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 4,
		"monster": 3160,
		"position": Vector2(3250, 426),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 16
	},
	{
		"point": 20,
		"stage": 4,
		"monster": 3160,
		"position": Vector2(4045, 430),
		"total": 2,
		"face": -1,
		"after_spawn": 19,
		"after_dead": 0
	},
	{
		"point": 50,
		"stage": 5,
		"monster": 3161,
		"position": Vector2(4610, 448),
		"total": 1,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _stage_count() -> int:
	return STAGE_COUNT


func _screen_starts() -> Array:
	return SCREEN_STARTS


func _screen_rights() -> Array:
	return SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return STAGE_TRIGGER_X


func _birth_points() -> Array:
	return BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_66_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _level_number() -> int:
	return 66

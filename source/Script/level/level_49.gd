extends Game4ImportedLevel

const WEIYANG_STAGE_COUNT := 5
const WEIYANG_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const WEIYANG_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const WEIYANG_TRIGGER_X := [202.0, 1548.0, 2532.0, 3511.0, 4308.0]

const LEVEL_49_MONSTER_DATA := {
	3001:
	{
		"name": "魔盾虎兵",
		"level": 90,
		"hp": 4295000,
		"attack": 20000,
		"def": 1100,
		"mdef": 1100,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 12.0,
		"range": 105.0,
		"sight": 720.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4, -2], "kind": "physics", "protect": 80},
			"hit2": {"multiplier": 1.25, "hurt_back": [-6, -3], "kind": "physics", "protect": 110},
		},
	},
	3002:
	{
		"name": "猛虎射手",
		"level": 90,
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"crit": 340,
		"miss": 170,
		"hit": 330,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 1100,
		"magic_break": 1100,
		"speed": 12.0,
		"min_range": 130.0,
		"range": 400.0,
		"sight": 820.0,
		"attack_desire": 100,
		"cooldown": 1050,
		"exp": 12,
		"coin": 10,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"arrow": {"multiplier": 1.0, "hurt_back": [-3, -1], "kind": "physics", "protect": 70},
		},
	},
	3004:
	{
		"name": "投石车",
		"level": 90,
		"hp": 7295000,
		"attack": 20000,
		"def": 1100,
		"mdef": 1100,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 7.0,
		"range": 520.0,
		"sight": 900.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"arrow": {"multiplier": 1.1, "hurt_back": [-3, -1], "kind": "physics", "protect": 70},
		},
	},
	3007:
	{
		"name": "金之祖巫",
		"level": 90,
		"hp": 18000000,
		"attack": 35000,
		"def": 4950,
		"mdef": 4950,
		"crit": 700,
		"miss": 150,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 3300,
		"magic_break": 3300,
		"speed": 0.0,
		"range": 1200.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 100,
		"coin": 280,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "1_jns", "chance": 0.2, "min_value": 1, "max_value": 1},
			{"name": "139300014V1", "chance": 0.1, "min_value": 1, "max_value": 1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.5, "hurt_back": [-4, -2], "kind": "magic", "protect": 80},
			"hit2": {"multiplier": 1.5, "hurt_back": [-4, -2], "kind": "magic", "protect": 80},
			"hit3": {"multiplier": 1.0, "hurt_back": [-5, -2], "kind": "magic", "protect": 130},
		},
	},
}

const WEIYANG_BIRTH_POINTS := [
	{
		"point": 3,
		"stage": 1,
		"monster": 3001,
		"position": Vector2(864, 321),
		"total": 4,
		"interval": 0.6,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 1,
		"stage": 1,
		"monster": 3004,
		"position": Vector2(716, 323),
		"total": 4,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3002,
		"position": Vector2(2024, 320),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3004,
		"position": Vector2(2012, 320),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 2,
		"monster": 3002,
		"position": Vector2(1406, 323),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 11,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 2,
		"monster": 3004,
		"position": Vector2(1413, 321),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 6
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3001,
		"position": Vector2(2987, 321),
		"total": 3,
		"interval": 0.6,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 3,
		"monster": 3002,
		"position": Vector2(2382, 316),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 14
	},
	{
		"point": 15,
		"stage": 3,
		"monster": 3001,
		"position": Vector2(2389, 317),
		"total": 3,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 17,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 3,
		"monster": 3002,
		"position": Vector2(2961, 322),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 4,
		"monster": 3002,
		"position": Vector2(3372, 326),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3004,
		"position": Vector2(3369, 330),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 21,
		"stage": 4,
		"monster": 3002,
		"position": Vector2(3907, 327),
		"total": 1,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 22,
		"stage": 4,
		"monster": 3001,
		"position": Vector2(3381, 327),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 20
	},
	{
		"point": 23,
		"stage": 4,
		"monster": 3002,
		"position": Vector2(3370, 328),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 22,
		"after_dead": 0
	},
	{
		"point": 24,
		"stage": 4,
		"monster": 3002,
		"position": Vector2(3932, 328),
		"total": 1,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 23,
		"after_dead": 0
	},
	{
		"point": 25,
		"stage": 4,
		"monster": 3004,
		"position": Vector2(3924, 326),
		"total": 2,
		"interval": 2.0,
		"face": -1,
		"after_spawn": 24,
		"after_dead": 0
	},
	{
		"point": 20,
		"stage": 4,
		"monster": 3001,
		"position": Vector2(3967, 323),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 26,
		"stage": 5,
		"monster": 3007,
		"position": Vector2(4472, 400),
		"total": 1,
		"interval": 0.1,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _stage_count() -> int:
	return WEIYANG_STAGE_COUNT


func _screen_starts() -> Array:
	return WEIYANG_SCREEN_STARTS


func _screen_rights() -> Array:
	return WEIYANG_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return WEIYANG_TRIGGER_X


func _birth_points() -> Array:
	return WEIYANG_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_49_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _level_number() -> int:
	return 49

extends Game4ImportedLevel

const STAGE_COUNT := 5
const SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 4000.0]
const SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4911.0]
const STAGE_TRIGGER_X := [418.0, 1356.0, 2498.0, 3385.0, 4424.0]
const LEVEL_63_MONSTER_DATA := {
	3118:
	{
		"name": "鼠精",
		"level": 90,
		"hp": 34500000,
		"attack": 54000,
		"def": 8500,
		"mdef": 8500,
		"crit": 340,
		"miss": 180,
		"hit": 1500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 12500,
		"magic_break": 12500,
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
	3119:
	{
		"name": "煞人蜂",
		"level": 90,
		"hp": 34500000,
		"attack": 54000,
		"def": 8500,
		"mdef": 8500,
		"crit": 340,
		"miss": 180,
		"hit": 1500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 12500,
		"magic_break": 12500,
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
		"is_flying": true,
		"max_protect": 100.0,
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}},
	},
	3120:
	{
		"name": "黄风大王",
		"level": 90,
		"hp": 123000000,
		"attack": 82000,
		"def": 9500,
		"mdef": 9500,
		"crit": 700,
		"miss": 480,
		"hit": 2480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 15300,
		"magic_break": 15300,
		"speed": 12.5,
		"min_range": 0.0,
		"range": 720.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "pgs_6", "min_value": 2, "max_value": 5, "chance": 0.15},
			{"name": "469000011", "value": 1, "chance": 0.1},
		],
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": true,
		"max_protect": 240.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false]
		},
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 1.0, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
		},
	},
}
const BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3118,
		"position": Vector2(966, 455),
		"total": 5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3118,
		"position": Vector2(347, 458),
		"total": 5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 3,
		"stage": 2,
		"monster": 3118,
		"position": Vector2(1191, 438),
		"total": 4,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 4,
		"stage": 2,
		"monster": 3119,
		"position": Vector2(2006, 301),
		"total": 2,
		"face": -1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3118,
		"position": Vector2(2005, 442),
		"total": 4,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 4
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3119,
		"position": Vector2(1194, 311),
		"total": 2,
		"face": 1,
		"after_spawn": 5,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 3,
		"monster": 3118,
		"position": Vector2(2298, 441),
		"total": 4,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 3,
		"monster": 3119,
		"position": Vector2(2986, 284),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3119,
		"position": Vector2(2297, 283),
		"total": 3,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 8
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3118,
		"position": Vector2(2979, 446),
		"total": 4,
		"face": -1,
		"after_spawn": 9,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 4,
		"monster": 3118,
		"position": Vector2(3211, 452),
		"total": 2,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 12,
		"stage": 4,
		"monster": 3118,
		"position": Vector2(3900, 443),
		"total": 2,
		"face": -1,
		"after_spawn": 11,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 4,
		"monster": 3119,
		"position": Vector2(3579, 281),
		"total": 4,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 4,
		"monster": 3118,
		"position": Vector2(3207, 445),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 13
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3118,
		"position": Vector2(3907, 442),
		"total": 2,
		"face": -1,
		"after_spawn": 14,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3119,
		"position": Vector2(3572, 281),
		"total": 4,
		"face": 1,
		"after_spawn": 15,
		"after_dead": 0
	},
	{
		"point": 50,
		"stage": 5,
		"monster": 3120,
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
	var source: Variant = LEVEL_63_MONSTER_DATA.get(monster_id, {})
	return (source as Dictionary).duplicate(true) if source is Dictionary else {}


func _level_number() -> int:
	return 63

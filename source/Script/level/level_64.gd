extends Game4ImportedLevel

const STAGE_COUNT := 5
const SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 4000.0]
const SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4911.0]
const STAGE_TRIGGER_X := [418.0, 1356.0, 2498.0, 3385.0, 4424.0]
const BOSS_3125_ANIMATIONS := {
	&"wait": ["wait", true],
	&"walk": ["walk", true],
	&"hurt": ["hurt", false],
	&"death": ["death", false],
	&"hit1": ["hit1", false],
	&"hit2": ["hit2", false],
	&"hit3": ["hit3", false]
}
const LEVEL_64_MONSTER_DATA := {
	3121:
	{
		"name": "花骨朵",
		"level": 90,
		"hp": 34500000,
		"attack": 54000,
		"def": 8050,
		"mdef": 8050,
		"crit": 340,
		"miss": 180,
		"hit": 1500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 12500,
		"magic_break": 12500,
		"speed": 12.0,
		"min_range": 0.0,
		"range": 180.0,
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
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}}
	},
	3122:
	{
		"name": "毒毛虫",
		"level": 90,
		"hp": 34500000,
		"attack": 54000,
		"def": 8050,
		"mdef": 8050,
		"crit": 340,
		"miss": 180,
		"hit": 1500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 12500,
		"magic_break": 12500,
		"speed": 12.0,
		"min_range": 0.0,
		"range": 180.0,
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
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}}
	},
	3126:
	{
		"name": "煞人蜂",
		"level": 90,
		"hp": 34500000,
		"attack": 54000,
		"def": 8050,
		"mdef": 8050,
		"crit": 340,
		"miss": 180,
		"hit": 1500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 12500,
		"magic_break": 12500,
		"speed": 12.0,
		"min_range": 0.0,
		"range": 180.0,
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
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}}
	},
	3123:
	{
		"name": "百仙虫",
		"level": 90,
		"hp": 122000000,
		"attack": 75000,
		"def": 9200,
		"mdef": 9200,
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
		"is_boss": true,
		"max_protect": 250.0,
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}}
	},
	3125:
	{
		"name": "百仙碟",
		"level": 90,
		"hp": 122000000,
		"attack": 75000,
		"def": 9200,
		"mdef": 9200,
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
		"independent_drop_list": [{"name": "2_jns", "chance": 0.2, "min_value": 1, "max_value": 3}],
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": true,
		"max_protect": 250.0,
		"animations": BOSS_3125_ANIMATIONS,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
			"hit2": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
			"hit3": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}
		}
	},
}
const BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3121,
		"position": Vector2(825, 409),
		"total": 6,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3121,
		"position": Vector2(221, 401),
		"total": 6,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 3,
		"stage": 2,
		"monster": 3122,
		"position": Vector2(1211, 437),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 4,
		"stage": 2,
		"monster": 3121,
		"position": Vector2(1994, 429),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3122,
		"position": Vector2(1141, 436),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 3
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3121,
		"position": Vector2(1949, 429),
		"total": 2,
		"face": -1,
		"after_spawn": 5,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3122,
		"position": Vector2(1172, 436),
		"total": 2,
		"face": 1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3121,
		"position": Vector2(2037, 431),
		"total": 2,
		"face": -1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3121,
		"position": Vector2(2298, 441),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3122,
		"position": Vector2(3040, 438),
		"total": 2,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3126,
		"position": Vector2(2986, 284),
		"total": 3,
		"face": -1,
		"after_spawn": 9,
		"after_dead": 0
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3122,
		"position": Vector2(2256, 439),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 11
	},
	{
		"point": 13,
		"stage": 3,
		"monster": 3121,
		"position": Vector2(3082, 432),
		"total": 2,
		"face": -1,
		"after_spawn": 12,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 3,
		"monster": 3126,
		"position": Vector2(2297, 283),
		"total": 3,
		"face": 1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3122,
		"position": Vector2(3210, 442),
		"total": 1,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3122,
		"position": Vector2(3994, 427),
		"total": 1,
		"face": -1,
		"after_spawn": 15,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3126,
		"position": Vector2(3976, 271),
		"total": 2,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3126,
		"position": Vector2(3223, 282),
		"total": 2,
		"face": 1,
		"after_spawn": 17,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 4,
		"monster": 3121,
		"position": Vector2(3251, 441),
		"total": 1,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 20,
		"stage": 4,
		"monster": 3121,
		"position": Vector2(3937, 425),
		"total": 1,
		"face": -1,
		"after_spawn": 25,
		"after_dead": 0
	},
	{
		"point": 25,
		"stage": 4,
		"monster": 3122,
		"position": Vector2(3217, 433),
		"total": 1,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 18
	},
	{
		"point": 26,
		"stage": 4,
		"monster": 3121,
		"position": Vector2(3244, 432),
		"total": 1,
		"face": 1,
		"after_spawn": 25,
		"after_dead": 0
	},
	{
		"point": 21,
		"stage": 4,
		"monster": 3122,
		"position": Vector2(3957, 432),
		"total": 1,
		"face": -1,
		"after_spawn": 26,
		"after_dead": 0
	},
	{
		"point": 22,
		"stage": 4,
		"monster": 3121,
		"position": Vector2(3967, 427),
		"total": 1,
		"face": -1,
		"after_spawn": 21,
		"after_dead": 0
	},
	{
		"point": 23,
		"stage": 4,
		"monster": 3126,
		"position": Vector2(3261, 281),
		"total": 2,
		"face": 1,
		"after_spawn": 22,
		"after_dead": 0
	},
	{
		"point": 24,
		"stage": 4,
		"monster": 3126,
		"position": Vector2(3940, 271),
		"total": 2,
		"face": -1,
		"after_spawn": 23,
		"after_dead": 0
	},
	{
		"point": 50,
		"stage": 5,
		"monster": 3123,
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
	var source: Variant = LEVEL_64_MONSTER_DATA.get(monster_id, {})
	return (source as Dictionary).duplicate(true) if source is Dictionary else {}


func _level_number() -> int:
	return 64

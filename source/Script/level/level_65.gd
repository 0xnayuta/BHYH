extends Game4ImportedLevel

const STAGE_COUNT := 5
const SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 4000.0]
const SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4911.0]
const STAGE_TRIGGER_X := [397.0, 1337.0, 2387.0, 3392.0, 4424.0]
const LEVEL_65_MONSTER_DATA := {
	3144:
	{
		"name": "银甲守卫",
		"level": 90,
		"hp": 44500000,
		"attack": 54000,
		"def": 9050,
		"mdef": 9050,
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
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}}
	},
	3145:
	{
		"name": "花骨朵",
		"level": 90,
		"hp": 44500000,
		"attack": 54000,
		"def": 9050,
		"mdef": 9050,
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
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}}
	},
	3146:
	{
		"name": "毒毛虫",
		"level": 90,
		"hp": 44500000,
		"attack": 84000,
		"def": 9550,
		"mdef": 9550,
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
		"attacks": {"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90}}
	},
	3136:
	{
		"name": "傲来国阵眼",
		"level": 90,
		"hp": 132000000,
		"attack": 85000,
		"def": 10200,
		"mdef": 10200,
		"crit": 500,
		"miss": 180,
		"hit": 2500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 15500,
		"magic_break": 15500,
		"speed": 0.0,
		"min_range": 0.0,
		"range": 1200.0,
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
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["wait", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit1", false],
			&"hit3": ["hit1", false]
		},
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "magic", "protect": 90},
			"hit2": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "magic", "protect": 90},
			"hit3": {"multiplier": 1.2, "hurt_back": [-6.0, -3.0], "kind": "magic", "protect": 110}
		}
	},
}
const BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3144,
		"position": Vector2(890, 415),
		"total": 6,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3144,
		"position": Vector2(190, 414),
		"total": 6,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 3,
		"stage": 2,
		"monster": 3144,
		"position": Vector2(1205, 404),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 4,
		"stage": 2,
		"monster": 3145,
		"position": Vector2(1865, 409),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3145,
		"position": Vector2(1166, 405),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 4
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3144,
		"position": Vector2(1934, 406),
		"total": 2,
		"face": -1,
		"after_spawn": 5,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3145,
		"position": Vector2(1903, 404),
		"total": 2,
		"face": -1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3144,
		"position": Vector2(1132, 406),
		"total": 2,
		"face": 1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3146,
		"position": Vector2(3050, 429),
		"total": 2,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3145,
		"position": Vector2(2241, 415),
		"total": 2,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3144,
		"position": Vector2(3028, 428),
		"total": 4,
		"face": -1,
		"after_spawn": 10,
		"after_dead": 0
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3144,
		"position": Vector2(2263, 412),
		"total": 4,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 11
	},
	{
		"point": 13,
		"stage": 3,
		"monster": 3145,
		"position": Vector2(2985, 427),
		"total": 2,
		"face": -1,
		"after_spawn": 12,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 3,
		"monster": 3146,
		"position": Vector2(2254, 408),
		"total": 2,
		"face": 1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 20,
		"stage": 4,
		"monster": 3145,
		"position": Vector2(3878, 411),
		"total": 3,
		"face": -1,
		"after_spawn": 21,
		"after_dead": 0
	},
	{
		"point": 21,
		"stage": 4,
		"monster": 3146,
		"position": Vector2(3176, 420),
		"total": 3,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 22,
		"stage": 4,
		"monster": 3144,
		"position": Vector2(3212, 415),
		"total": 3,
		"face": 1,
		"after_spawn": 20,
		"after_dead": 0
	},
	{
		"point": 23,
		"stage": 4,
		"monster": 3144,
		"position": Vector2(3853, 406),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 22
	},
	{
		"point": 24,
		"stage": 4,
		"monster": 3145,
		"position": Vector2(3152, 416),
		"total": 3,
		"face": 1,
		"after_spawn": 23,
		"after_dead": 0
	},
	{
		"point": 25,
		"stage": 4,
		"monster": 3146,
		"position": Vector2(3903, 408),
		"total": 3,
		"face": -1,
		"after_spawn": 24,
		"after_dead": 0
	},
	{
		"point": 50,
		"stage": 5,
		"monster": 3136,
		"position": Vector2(4487, 448),
		"total": 1,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0,
		"ignore_count_multiplier": true
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
	var source: Variant = LEVEL_65_MONSTER_DATA.get(monster_id, {})
	var config := (source as Dictionary).duplicate(true) if source is Dictionary else {}
	if monster_id == 3136:
		config["name"] = "风之祖巫"
	return config


func _level_number() -> int:
	return 65

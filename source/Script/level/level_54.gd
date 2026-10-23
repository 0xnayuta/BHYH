extends Game4ImportedLevel

const NANHAI_MONSTER_SCRIPT := preload("res://Script/monster/nanhai_monster.gd")
const FOUR_HEADED_BOSS_SCRIPT := preload("res://Script/monster/four_headed_boss.gd")

const JIULONG_STAGE_COUNT := 5
const JIULONG_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const JIULONG_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const JIULONG_TRIGGER_X := [295.0, 1428.0, 2299.0, 3526.0, 4710.0]

const LEVEL_54_MONSTER_DATA := {
	3028:
	{
		"name": "贝壳",
		"level": 90,
		"hp": 7295000,
		"attack": 20000,
		"def": 2300,
		"mdef": 2300,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2300,
		"magic_break": 2300,
		"speed": 7.5,
		"min_range": 60.0,
		"range": 180.0,
		"sight": 940,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.33, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 551},
		},
	},
	3032:
	{
		"name": "夜叉",
		"level": 90,
		"hp": 7295000,
		"attack": 20000,
		"def": 2300,
		"mdef": 2300,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2300,
		"magic_break": 2300,
		"speed": 10.0,
		"min_range": 30.0,
		"range": 177.0,
		"sight": 940,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 3334},
		},
	},
	3043:
	{
		"name": "虾兵",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2300,
		"mdef": 2300,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2300,
		"magic_break": 2300,
		"speed": 11.25,
		"min_range": 90.0,
		"range": 420.0,
		"sight": 940,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 3334},
		},
	},
	3034:
	{
		"name": "四头虫",
		"level": 90,
		"hp": 14000000,
		"attack": 32000,
		"def": 4900,
		"mdef": 4900,
		"crit": 700,
		"miss": 490,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4900,
		"magic_break": 4900,
		"speed": 15.0,
		"range": 999.0,
		"sight": 1200,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "ymqzq", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"skill_ranges": {1: 145.0, 2: 420.0},
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-4, -2], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 0.25, "hurt_back": [-2, -1], "kind": "physics", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-3, -2], "kind": "magic", "protect": 6668},
			"hit4": {"multiplier": 1.0, "hurt_back": [0, 0], "kind": "physics", "protect": 6668},
		},
	},
}

const JIULONG_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3032,
		"position": Vector2(1017, 407),
		"total": 2,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 24,
		"stage": 1,
		"monster": 3032,
		"position": Vector2(916, 409),
		"total": 2,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 1,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3032,
		"position": Vector2(240, 412),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 24
	},
	{
		"point": 25,
		"stage": 1,
		"monster": 3032,
		"position": Vector2(92, 412),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 2,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 2,
		"monster": 3032,
		"position": Vector2(1233, 399),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 4,
		"stage": 2,
		"monster": 3028,
		"position": Vector2(2116, 402),
		"total": 1,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3043,
		"position": Vector2(2091, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3032,
		"position": Vector2(1251, 399),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 5
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3028,
		"position": Vector2(2039, 399),
		"total": 1,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3043,
		"position": Vector2(2059, 399),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3043,
		"position": Vector2(3031, 412),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3028,
		"position": Vector2(2979, 408),
		"total": 1,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 9,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3032,
		"position": Vector2(2931, 410),
		"total": 3,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 3,
		"monster": 3032,
		"position": Vector2(2256, 402),
		"total": 3,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 11
	},
	{
		"point": 14,
		"stage": 3,
		"monster": 3043,
		"position": Vector2(2229, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 3,
		"monster": 3028,
		"position": Vector2(2205, 399),
		"total": 1,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 14,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3032,
		"position": Vector2(3336, 405),
		"total": 3,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3043,
		"position": Vector2(3298, 402),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3028,
		"position": Vector2(4011, 388),
		"total": 2,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 4,
		"monster": 3028,
		"position": Vector2(3251, 403),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 17
	},
	{
		"point": 20,
		"stage": 4,
		"monster": 3032,
		"position": Vector2(3976, 389),
		"total": 3,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 19,
		"after_dead": 0
	},
	{
		"point": 21,
		"stage": 4,
		"monster": 3043,
		"position": Vector2(4045, 389),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 20,
		"after_dead": 0
	},
	{
		"point": 23,
		"stage": 5,
		"monster": 3034,
		"position": Vector2(4796, 289),
		"total": 1,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _stage_count() -> int:
	return JIULONG_STAGE_COUNT


func _screen_starts() -> Array:
	return JIULONG_SCREEN_STARTS


func _screen_rights() -> Array:
	return JIULONG_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return JIULONG_TRIGGER_X


func _birth_points() -> Array:
	return JIULONG_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_54_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _preload_level_resources() -> void:
	await super._preload_level_resources()
	await _prewarm_stage_runtime(monster_group.get("stage_1", []))


func _preload_stage_resources(monster_ids: Array) -> void:
	await super._preload_stage_resources(monster_ids)
	await _prewarm_stage_runtime(monster_ids)


func _prewarm_stage_runtime(monster_ids: Array) -> void:
	var nanhai_kinds: Array = []
	var needs_boss := false
	for monster_id_value in monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id in [3028, 3032, 3043] and not nanhai_kinds.has(monster_id):
			nanhai_kinds.append(monster_id)
		elif monster_id == 3034:
			needs_boss = true
	if not nanhai_kinds.is_empty():
		await NANHAI_MONSTER_SCRIPT.prewarm_frames(nanhai_kinds)
	if needs_boss:
		await FOUR_HEADED_BOSS_SCRIPT.prewarm_frames()
		await FOUR_HEADED_BOSS_SCRIPT.prewarm_effects()


func _level_number() -> int:
	return 54

extends Game4ImportedLevel

const JIUHUA_MONSTER_SCRIPT := preload("res://Script/monster/jiuhua_mountain_monster.gd")
const SHUANGXI_MONSTER_SCRIPT := preload("res://Script/monster/shuangxi_temple_monster.gd")
const SHENGUANG_BOSS_SCRIPT := preload("res://Script/monster/shenguang_jinling_boss.gd")

const SHENGUANG_STAGE_COUNT := 5
const SHENGUANG_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const SHENGUANG_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const SHENGUANG_TRIGGER_X := [310.0, 1548.0, 2396.0, 3436.0, 4419.0]

const LEVEL_52_MONSTER_DATA := {
	3009:
	{
		"name": "金钱松",
		"level": 90,
		"hp": 6295000,
		"attack": 21000,
		"def": 2000,
		"mdef": 2000,
		"crit": 300,
		"miss": 160,
		"hit": 290,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2000,
		"magic_break": 2000,
		"speed": 10.0,
		"min_range": 0.0,
		"range": 330.0,
		"sight": 600.0,
		"attack_desire": 100,
		"cooldown": 1200,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"arrow": {"multiplier": 1.0, "hurt_back": [-3, -1], "kind": "physics", "protect": 70},
		},
	},
	3010:
	{
		"name": "人形藤蔓",
		"level": 90,
		"hp": 5295000,
		"attack": 30000,
		"def": 2000,
		"mdef": 2000,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2000,
		"magic_break": 2000,
		"speed": 8.5,
		"min_range": 0.0,
		"range": 125.0,
		"sight": 760.0,
		"attack_desire": 100,
		"cooldown": 1000,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-0.84, -2.8], "kind": "physics", "protect": 1112},
		},
	},
	3011:
	{
		"name": "苍耳妖",
		"level": 90,
		"hp": 5295000,
		"attack": 30000,
		"def": 2000,
		"mdef": 2000,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2000,
		"magic_break": 2000,
		"speed": 10.0,
		"min_range": 0.0,
		"range": 250.0,
		"sight": 760.0,
		"attack_desire": 100,
		"cooldown": 1000,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.33, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 1112},
		},
	},
	3021:
	{
		"name": "木之祖巫",
		"level": 90,
		"hp": 22000000,
		"attack": 32000,
		"def": 5300,
		"mdef": 5300,
		"crit": 700,
		"miss": 260,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4200,
		"magic_break": 4200,
		"speed": 0.0,
		"range": 999.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "105400003", "value": 1, "chance": 0.1},
			{"name": "139300012", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-5, -2], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 0.5, "hurt_back": [-5, -2], "kind": "physics", "protect": 6668},
			"hit3": {"multiplier": 0.5, "hurt_back": [-1, -8], "kind": "physics", "protect": 6668},
			"hit4": {"multiplier": 0.5, "hurt_back": [0, 0], "kind": "magic", "protect": 6668},
		},
	},
}

const SHENGUANG_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3009,
		"position": Vector2(842, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3011,
		"position": Vector2(849, 400),
		"total": 2,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3009,
		"position": Vector2(277, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 2
	},
	{
		"point": 4,
		"stage": 1,
		"monster": 3011,
		"position": Vector2(253, 400),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3010,
		"position": Vector2(2007, 400),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3011,
		"position": Vector2(2002, 400),
		"total": 2,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3010,
		"position": Vector2(1433, 400),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 6
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3011,
		"position": Vector2(1423, 400),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3009,
		"position": Vector2(2931, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3010,
		"position": Vector2(2902, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 11,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3011,
		"position": Vector2(2918, 400),
		"total": 2,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3009,
		"position": Vector2(2329, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 10
	},
	{
		"point": 13,
		"stage": 3,
		"monster": 3011,
		"position": Vector2(2306, 400),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 12,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 3,
		"monster": 3010,
		"position": Vector2(2352, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3011,
		"position": Vector2(4079, 400),
		"total": 3,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3011,
		"position": Vector2(3330, 400),
		"total": 3,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3009,
		"position": Vector2(3329, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 16
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3009,
		"position": Vector2(4071, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 17,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 4,
		"monster": 3010,
		"position": Vector2(3332, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 18,
		"after_dead": 0
	},
	{
		"point": 20,
		"stage": 4,
		"monster": 3010,
		"position": Vector2(4061, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 19,
		"after_dead": 0
	},
	{
		"point": 21,
		"stage": 5,
		"monster": 3021,
		"position": Vector2(4514, 354),
		"total": 1,
		"interval": 2.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _stage_count() -> int:
	return SHENGUANG_STAGE_COUNT


func _screen_starts() -> Array:
	return SHENGUANG_SCREEN_STARTS


func _screen_rights() -> Array:
	return SHENGUANG_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return SHENGUANG_TRIGGER_X


func _birth_points() -> Array:
	return SHENGUANG_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_52_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _preload_level_resources() -> void:
	await super._preload_level_resources()
	await _prewarm_stage_runtime(monster_group.get("stage_1", []))


func _preload_stage_resources(monster_ids: Array) -> void:
	await super._preload_stage_resources(monster_ids)
	await _prewarm_stage_runtime(monster_ids)


func _prewarm_stage_runtime(monster_ids: Array) -> void:
	var jiuhua_kinds: Array = []
	var shuangxi_kinds: Array = []
	var needs_boss := false
	for monster_id_value in monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id == 3009 and not jiuhua_kinds.has(monster_id):
			jiuhua_kinds.append(monster_id)
		elif monster_id in [3010, 3011] and not shuangxi_kinds.has(monster_id):
			shuangxi_kinds.append(monster_id)
		elif monster_id == 3021:
			needs_boss = true
	if not jiuhua_kinds.is_empty():
		await JIUHUA_MONSTER_SCRIPT.prewarm_frames(jiuhua_kinds)
	if not shuangxi_kinds.is_empty():
		await SHUANGXI_MONSTER_SCRIPT.prewarm_frames(shuangxi_kinds)
	if needs_boss:
		await SHENGUANG_BOSS_SCRIPT.prewarm_frames()
		await SHENGUANG_BOSS_SCRIPT.prewarm_effects()


func _level_number() -> int:
	return 52

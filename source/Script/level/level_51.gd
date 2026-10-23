extends Game4ImportedLevel

const SHUANGXI_MONSTER_SCRIPT := preload("res://Script/monster/shuangxi_temple_monster.gd")
const SHUANGXI_BOSS_ARROW_SCRIPT := preload("res://Script/monster/shuangxi_boss_arrow.gd")
const JIUHUA_MONSTER_SCRIPT := preload("res://Script/monster/jiuhua_mountain_monster.gd")

const SHUANGXI_STAGE_COUNT := 5
const SHUANGXI_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const SHUANGXI_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const SHUANGXI_TRIGGER_X := [418.0, 1500.0, 2432.0, 3312.0, 4424.0]

const LEVEL_51_MONSTER_DATA := {
	3008:
	{
		"name": "蘑菇精",
		"level": 90,
		"hp": 5295000,
		"attack": 20000,
		"def": 1700,
		"mdef": 1700,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 1900,
		"magic_break": 1900,
		"speed": 11.0,
		"min_range": 0.0,
		"range": 85.0,
		"sight": 760.0,
		"attack_desire": 100,
		"cooldown": 950,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1":
			{
				"multiplier": 0.5,
				"hurt_back": [-0.84, -2.8],
				"kind": "physics",
				"protect": 1112,
				"source_target_move": Vector2(21, 42),
				"source_stiff_seconds": 0.334,
			},
		},
	},
	3010:
	{
		"name": "人形藤蔓",
		"level": 90,
		"hp": 5295000,
		"attack": 30000,
		"def": 1700,
		"mdef": 1700,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 1900,
		"magic_break": 1900,
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
		"def": 1700,
		"mdef": 1700,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 1900,
		"magic_break": 1900,
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
	3020:
	{
		"name": "道明妖僧",
		"level": 90,
		"hp": 19000000,
		"attack": 42000,
		"def": 4990,
		"mdef": 4990,
		"crit": 700,
		"miss": 160,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4000,
		"magic_break": 4000,
		"speed": 16.0,
		"min_range": 0.0,
		"range": 370.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"cooldown": 1600,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "dzyl", "chance": 0.1, "min_value": 1, "max_value": 1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"skill_ranges": [750.0, 500.0, 200.0],
		"attacks":
		{
			"hit1": {"power": 16000, "hurt_back": [-5.0, -2.0], "kind": "magic", "protect": 6668},
			"hit2": {"power": 32000, "hurt_back": [-5.0, -2.0], "kind": "magic", "protect": 6668},
			"hit3": {"power": 48000, "hurt_back": [-5.0, -2.0], "kind": "magic", "protect": 6668},
		},
	},
}

const SHUANGXI_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3008,
		"position": Vector2(966, 400),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3011,
		"position": Vector2(977, 400),
		"total": 1,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3011,
		"position": Vector2(347, 400),
		"total": 1,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 4,
		"stage": 1,
		"monster": 3008,
		"position": Vector2(350, 400),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3011,
		"position": Vector2(2054, 400),
		"total": 2,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3008,
		"position": Vector2(2038, 400),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3011,
		"position": Vector2(1418, 400),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 6
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3008,
		"position": Vector2(1414, 400),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3010,
		"position": Vector2(2294, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3008,
		"position": Vector2(3076, 400),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3008,
		"position": Vector2(2284, 400),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 10
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3010,
		"position": Vector2(3033, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 11,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 4,
		"monster": 3010,
		"position": Vector2(3335, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 4,
		"monster": 3008,
		"position": Vector2(3330, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3011,
		"position": Vector2(3326, 400),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 14,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3011,
		"position": Vector2(3931, 400),
		"total": 2,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 15
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3008,
		"position": Vector2(3937, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 16,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3010,
		"position": Vector2(3911, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 17,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 5,
		"monster": 3020,
		"position": Vector2(4610, 400),
		"total": 1,
		"interval": 2.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _stage_count() -> int:
	return SHUANGXI_STAGE_COUNT


func _screen_starts() -> Array:
	return SHUANGXI_SCREEN_STARTS


func _screen_rights() -> Array:
	return SHUANGXI_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return SHUANGXI_TRIGGER_X


func _birth_points() -> Array:
	return SHUANGXI_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_51_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _preload_level_resources() -> void:
	await super._preload_level_resources()
	await _prewarm_stage_runtime(monster_group.get("stage_1", []))


func _preload_stage_resources(monster_ids: Array) -> void:
	await super._preload_stage_resources(monster_ids)
	await _prewarm_stage_runtime(monster_ids)


func _prewarm_stage_runtime(monster_ids: Array) -> void:
	var shuangxi_kinds: Array = []
	var jiuhua_kinds: Array = []
	for monster_id_value in monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id in [3010, 3011, 3020] and not shuangxi_kinds.has(monster_id):
			shuangxi_kinds.append(monster_id)
		elif monster_id == 3008 and not jiuhua_kinds.has(monster_id):
			jiuhua_kinds.append(monster_id)
	if not jiuhua_kinds.is_empty():
		await JIUHUA_MONSTER_SCRIPT.prewarm_frames(jiuhua_kinds)
	if not shuangxi_kinds.is_empty():
		await SHUANGXI_MONSTER_SCRIPT.prewarm_frames(shuangxi_kinds)
	if shuangxi_kinds.has(3020):
		await SHUANGXI_BOSS_ARROW_SCRIPT.prewarm_frames()


func _level_number() -> int:
	return 51

extends Game4ImportedLevel

const EMEI_MONSTER_SCRIPT := preload("res://Script/monster/emei_mountain_monster.gd")
const EMEI_BOSS_SCRIPT := preload("res://Script/monster/emei_boss3041.gd")

const QINGYIN_STAGE_COUNT := 5
const QINGYIN_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const QINGYIN_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const QINGYIN_TRIGGER_X := [302.0, 1705.0, 2600.0, 3472.0, 4495.0]

const LEVEL_57_MONSTER_DATA := {
	3036:
	{
		"name": "火焰鸟",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2700,
		"mdef": 2700,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2700,
		"magic_break": 2700,
		"speed": 12.5,
		"min_range": 48.0,
		"range": 157.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 3334},
		},
	},
	3037:
	{
		"name": "蝎子精",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2700,
		"mdef": 2700,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2700,
		"magic_break": 2700,
		"speed": 10.0,
		"min_range": 150.0,
		"range": 400.0,
		"sight": 940.0,
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
	3039:
	{
		"name": "百足蜈蚣",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2700,
		"mdef": 2700,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2700,
		"magic_break": 2700,
		"speed": 10.0,
		"min_range": 0.0,
		"range": 105.0,
		"sight": 940.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.25, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 334},
		},
	},
	3041:
	{
		"name": "噬火毒蝎",
		"level": 90,
		"hp": 23000000,
		"attack": 42000,
		"def": 5500,
		"mdef": 5500,
		"crit": 700,
		"miss": 480,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 5300,
		"magic_break": 5300,
		"speed": 12.5,
		"range": 720.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "zqfjsszzs", "value": 1, "chance": 0.1},
			{"name": "zqfjblzzs", "value": 1, "chance": 0.1},
			{"name": "zqfjnzzzs", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 6668},
			"hit2_2": {"multiplier": 1.5, "hurt_back": [-4.0, -3.0], "kind": "magic", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
		},
	},
}

const QINGYIN_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3039,
		"position": Vector2(1077, 477),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3039,
		"position": Vector2(136, 464),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3037,
		"position": Vector2(140, 468),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 2
	},
	{
		"point": 4,
		"stage": 1,
		"monster": 3039,
		"position": Vector2(1087, 475),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 1,
		"monster": 3037,
		"position": Vector2(1063, 478),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 4,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 1,
		"monster": 3039,
		"position": Vector2(140, 464),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 5,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3036,
		"position": Vector2(1124, 336),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3039,
		"position": Vector2(2093, 468),
		"total": 3,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 2,
		"monster": 3036,
		"position": Vector2(2155, 336),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 7
	},
	{
		"point": 10,
		"stage": 2,
		"monster": 3039,
		"position": Vector2(2053, 470),
		"total": 3,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 8
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3036,
		"position": Vector2(2281, 336),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3039,
		"position": Vector2(3159, 467),
		"total": 3,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 3,
		"monster": 3036,
		"position": Vector2(3173, 336),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 11
	},
	{
		"point": 14,
		"stage": 3,
		"monster": 3039,
		"position": Vector2(3121, 465),
		"total": 3,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3037,
		"position": Vector2(3358, 464),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3037,
		"position": Vector2(4030, 463),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 15,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3039,
		"position": Vector2(4122, 466),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3039,
		"position": Vector2(3395, 462),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 17,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 4,
		"monster": 3037,
		"position": Vector2(3351, 461),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 18
	},
	{
		"point": 20,
		"stage": 4,
		"monster": 3039,
		"position": Vector2(4091, 465),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 19,
		"after_dead": 0
	},
	{
		"point": 21,
		"stage": 4,
		"monster": 3037,
		"position": Vector2(4064, 463),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 20,
		"after_dead": 0
	},
	{
		"point": 22,
		"stage": 4,
		"monster": 3039,
		"position": Vector2(3376, 463),
		"total": 2,
		"interval": 0.7,
		"face": 1,
		"after_spawn": 21,
		"after_dead": 0
	},
	{
		"point": 23,
		"stage": 5,
		"monster": 3041,
		"position": Vector2(4836, 456),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _stage_count() -> int:
	return QINGYIN_STAGE_COUNT


func _screen_starts() -> Array:
	return QINGYIN_SCREEN_STARTS


func _screen_rights() -> Array:
	return QINGYIN_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return QINGYIN_TRIGGER_X


func _birth_points() -> Array:
	return QINGYIN_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_57_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _preload_level_resources() -> void:
	await super._preload_level_resources()
	await _prewarm_stage_runtime(monster_group.get("stage_1", []))


func _preload_stage_resources(monster_ids: Array) -> void:
	await super._preload_stage_resources(monster_ids)
	await _prewarm_stage_runtime(monster_ids)


func _prewarm_stage_runtime(monster_ids: Array) -> void:
	var small_monsters: Array = []
	var needs_boss := false
	for monster_id_value in monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id in [3036, 3037, 3039] and not small_monsters.has(monster_id):
			small_monsters.append(monster_id)
		elif monster_id == 3041:
			needs_boss = true
	if not small_monsters.is_empty():
		await EMEI_MONSTER_SCRIPT.prewarm_frames(small_monsters)
	if needs_boss:
		EMEI_BOSS_SCRIPT.prewarm_frames()
		EMEI_BOSS_SCRIPT.prewarm_effects()


func _level_number() -> int:
	return 57


func _on_fall_death_body_entered(body: Node2D) -> void:
	if body == _role:
		RoleProp.roleprop.Hp = 0

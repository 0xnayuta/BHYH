extends Game4ImportedLevel

const EMEI_MONSTER_SCRIPT := preload("res://Script/monster/emei_mountain_monster.gd")
const FIRE_ANCESTOR_SCRIPT := preload("res://Script/monster/fire_ancestor_boss.gd")
const FIRE_ANCESTOR_ORB_SCRIPT := preload("res://Script/monster/fire_ancestor_orb.gd")

const JINDING_STAGE_COUNT := 5
const JINDING_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const JINDING_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const JINDING_TRIGGER_X := [291.0, 1239.0, 2518.0, 3357.0, 4425.0]

const LEVEL_58_MONSTER_DATA := {
	3047:
	{
		"name": "岩石怪",
		"level": 90,
		"hp": 9295000,
		"attack": 22000,
		"def": 2800,
		"mdef": 2800,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2800,
		"magic_break": 2800,
		"speed": 8.75,
		"min_range": 20.0,
		"range": 195.0,
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
			"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 3334},
		},
	},
	3038:
	{
		"name": "忍猴",
		"level": 90,
		"hp": 9295000,
		"attack": 22000,
		"def": 2800,
		"mdef": 2800,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2800,
		"magic_break": 2800,
		"speed": 11.25,
		"min_range": 130.0,
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
	3036:
	{
		"name": "火焰鸟",
		"level": 90,
		"hp": 9295000,
		"attack": 22000,
		"def": 2800,
		"mdef": 2800,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2800,
		"magic_break": 2800,
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
	3039:
	{
		"name": "百足蜈蚣",
		"level": 90,
		"hp": 9295000,
		"attack": 22000,
		"def": 2800,
		"mdef": 2800,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2800,
		"magic_break": 2800,
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
	3042:
	{
		"name": "火之祖巫",
		"level": 90,
		"hp": 25000000,
		"attack": 44000,
		"def": 5600,
		"mdef": 5600,
		"crit": 700,
		"miss": 490,
		"hit": 500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 5500,
		"magic_break": 5500,
		"speed": 0.0,
		"range": 1200.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "zqwqwkzzs", "value": 1, "chance": 0.1},
			{"name": "zqwqtszzs", "value": 1, "chance": 0.1},
			{"name": "zqwqbjzzs", "value": 1, "chance": 0.1},
			{"name": "139300021", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-4.0, -3.0], "kind": "magic", "protect": 6668},
		},
	},
	3056:
	{
		"name": "祖巫火球",
		"level": 90,
		"hp": 35270,
		"attack": 547,
		"def": 80,
		"mdef": 80,
		"crit": 0,
		"miss": 0,
		"hit": 0,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 0,
		"magic_break": 0,
		"speed": 25.0,
		"range": 98.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [0.0, 0.0], "kind": "physics", "protect": 0},
		},
	},
}

const JINDING_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3038,
		"position": Vector2(174, 458),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3047,
		"position": Vector2(984, 471),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3047,
		"position": Vector2(316, 459),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 4,
		"stage": 1,
		"monster": 3038,
		"position": Vector2(997, 472),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3039,
		"position": Vector2(1997, 463),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3036,
		"position": Vector2(1259, 336),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3036,
		"position": Vector2(1981, 336),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 6
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3038,
		"position": Vector2(1984, 463),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3036,
		"position": Vector2(2234, 336),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3039,
		"position": Vector2(3010, 478),
		"total": 4,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3036,
		"position": Vector2(3057, 336),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 9
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3038,
		"position": Vector2(2786, 479),
		"total": 4,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 11,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 4,
		"monster": 3036,
		"position": Vector2(3168, 336),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 4,
		"monster": 3047,
		"position": Vector2(3908, 480),
		"total": 4,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3038,
		"position": Vector2(3178, 468),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3047,
		"position": Vector2(3157, 469),
		"total": 4,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 15
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3036,
		"position": Vector2(3913, 336),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 16,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3038,
		"position": Vector2(3898, 483),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 17,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 5,
		"monster": 3042,
		"position": Vector2(4481, 520.5),
		"total": 1,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _stage_count() -> int:
	return JINDING_STAGE_COUNT


func _screen_starts() -> Array:
	return JINDING_SCREEN_STARTS


func _screen_rights() -> Array:
	return JINDING_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return JINDING_TRIGGER_X


func _birth_points() -> Array:
	return JINDING_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_58_MONSTER_DATA.get(monster_id, {})
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
		if monster_id in [3047, 3038, 3036, 3039] and not small_monsters.has(monster_id):
			small_monsters.append(monster_id)
		elif monster_id == 3042:
			needs_boss = true
	if not small_monsters.is_empty():
		await EMEI_MONSTER_SCRIPT.prewarm_frames(small_monsters)
	if needs_boss:
		FIRE_ANCESTOR_SCRIPT.prewarm_frames()
		FIRE_ANCESTOR_SCRIPT.prewarm_effects()
		await FIRE_ANCESTOR_ORB_SCRIPT.prewarm_frames()


func _level_number() -> int:
	return 58


func _on_fall_death_body_entered(body: Node2D) -> void:
	if body == _role:
		RoleProp.roleprop.Hp = 0

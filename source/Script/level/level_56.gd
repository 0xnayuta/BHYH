extends Game4ImportedLevel

const EMEI_MONSTER_SCRIPT := preload("res://Script/monster/emei_mountain_monster.gd")
const EMEI_BOSS_SCRIPT := preload("res://Script/monster/emei_boss3040.gd")

const EMEI_STAGE_COUNT := 5
const EMEI_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const EMEI_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const EMEI_TRIGGER_X := [367.0, 1557.0, 2583.0, 3340.0, 4411.0]

const LEVEL_56_MONSTER_DATA := {
	3038:
	{
		"name": "忍猴",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2600,
		"mdef": 2600,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2600,
		"magic_break": 2600,
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
	3047:
	{
		"name": "岩石怪",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2600,
		"mdef": 2600,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2600,
		"magic_break": 2600,
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
	3040:
	{
		"name": "赤炎金刚",
		"level": 90,
		"hp": 23000000,
		"attack": 42000,
		"def": 5400,
		"mdef": 5400,
		"crit": 700,
		"miss": 470,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 5200,
		"magic_break": 5200,
		"speed": 12.5,
		"range": 600.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "pgs_4", "min_value": 2, "max_value": 5, "chance": 0.15},
			{"name": "zqfjwkzzs", "value": 1, "chance": 0.1},
			{"name": "zqfjtszzs", "value": 1, "chance": 0.1},
			{"name": "zqfjbjzzs", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 0.25, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 6668},
			"hit3": {"multiplier": 0.5, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 6668},
		},
	},
}

const EMEI_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3047,
		"position": Vector2(928, 469),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3047,
		"position": Vector2(1044, 471),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 1,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3047,
		"position": Vector2(279, 467),
		"total": 4,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 2
	},
	{
		"point": 4,
		"stage": 2,
		"monster": 3038,
		"position": Vector2(2095, 447),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3047,
		"position": Vector2(1963, 448),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3047,
		"position": Vector2(1354, 463),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 4
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3038,
		"position": Vector2(1172, 470),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 3,
		"monster": 3038,
		"position": Vector2(2342, 450),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3047,
		"position": Vector2(3087, 445),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3047,
		"position": Vector2(2287, 449),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 8
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3038,
		"position": Vector2(3017, 445),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 10,
		"after_dead": 0
	},
	{
		"point": 12,
		"stage": 4,
		"monster": 3038,
		"position": Vector2(3211, 446),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 4,
		"monster": 3038,
		"position": Vector2(3957, 443),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 4,
		"monster": 3047,
		"position": Vector2(3216, 444),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 12
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3038,
		"position": Vector2(3199, 446),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 14,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3047,
		"position": Vector2(3979, 440),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 15,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3038,
		"position": Vector2(3966, 442),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 16,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 5,
		"monster": 3040,
		"position": Vector2(4636, 445),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _stage_count() -> int:
	return EMEI_STAGE_COUNT


func _screen_starts() -> Array:
	return EMEI_SCREEN_STARTS


func _screen_rights() -> Array:
	return EMEI_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return EMEI_TRIGGER_X


func _birth_points() -> Array:
	return EMEI_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_56_MONSTER_DATA.get(monster_id, {})
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
		if monster_id in [3038, 3047] and not small_monsters.has(monster_id):
			small_monsters.append(monster_id)
		elif monster_id == 3040:
			needs_boss = true
	if not small_monsters.is_empty():
		await EMEI_MONSTER_SCRIPT.prewarm_frames(small_monsters)
	if needs_boss:
		EMEI_BOSS_SCRIPT.prewarm_frames()
		EMEI_BOSS_SCRIPT.prewarm_effects()


func _level_number() -> int:
	return 56


func _on_fall_death_body_entered(body: Node2D) -> void:
	if body == _role:
		RoleProp.roleprop.Hp = 0

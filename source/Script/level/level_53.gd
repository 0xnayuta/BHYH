extends Game4ImportedLevel

const NANHAI_MONSTER_SCRIPT := preload("res://Script/monster/nanhai_monster.gd")
const LINGGAN_BOSS_SCRIPT := preload("res://Script/monster/linggan_king_boss.gd")

const PUTUO_STAGE_COUNT := 5
const PUTUO_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const PUTUO_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const PUTUO_TRIGGER_X := [383.0, 1465.0, 2646.0, 3412.0, 4480.0]
const PUTUO_ROLE_BIRTH := Vector2(32.0, 44.0)

const LEVEL_53_MONSTER_DATA := {
	3031:
	{
		"name": "虾兵",
		"level": 90,
		"hp": 7295000,
		"attack": 20000,
		"def": 2100,
		"mdef": 2100,
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
	3043:
	{
		"name": "虾兵",
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
		"speed": 11.25,
		"min_range": 90.0,
		"range": 420.0,
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
	3049:
	{
		"name": "虎鲨",
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
		"speed": 20.0,
		"min_range": 0.0,
		"range": 480.0,
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
	3033:
	{
		"name": "灵感大王",
		"level": 90,
		"hp": 22000000,
		"attack": 32000,
		"def": 5200,
		"mdef": 5200,
		"crit": 700,
		"miss": 270,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 5000,
		"magic_break": 5000,
		"speed": 15.0,
		"range": 999.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "pgs_3", "min_value": 2, "max_value": 5, "chance": 0.15},
			{"name": "105400005V1", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-5, -2], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 0.15, "hurt_back": [-3, -1], "kind": "physics", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-3, -2], "kind": "magic", "protect": 6668},
			"hit4": {"multiplier": 1.0, "hurt_back": [-5, -3], "kind": "physics", "protect": 6668},
		},
	},
}

const PUTUO_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3031,
		"position": Vector2(305, 19),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3031,
		"position": Vector2(900, 21),
		"total": 2,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3031,
		"position": Vector2(279, 20),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 2
	},
	{
		"point": 4,
		"stage": 1,
		"monster": 3031,
		"position": Vector2(920, 25),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3049,
		"position": Vector2(1338, 414),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3049,
		"position": Vector2(1897, 410),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3049,
		"position": Vector2(1336, 417),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 6
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3049,
		"position": Vector2(1899, 415),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3031,
		"position": Vector2(3026, 48),
		"total": 2,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 3,
		"monster": 3049,
		"position": Vector2(3014, 415),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3049,
		"position": Vector2(2376, 413),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 10
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3031,
		"position": Vector2(2412, 34),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 11,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 4,
		"monster": 3043,
		"position": Vector2(3817, 400),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 4,
		"monster": 3043,
		"position": Vector2(3285, 403),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3043,
		"position": Vector2(3296, 403),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 14
	},
	{
		"point": 16,
		"stage": 4,
		"monster": 3043,
		"position": Vector2(3826, 399),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 15,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 5,
		"monster": 3033,
		"position": Vector2(4695, 55),
		"total": 1,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _ready() -> void:
	super._ready()
	if _role != null:
		_role.position = PUTUO_ROLE_BIRTH
		_role.velocity = Vector2.ZERO


func _stage_count() -> int:
	return PUTUO_STAGE_COUNT


func _screen_starts() -> Array:
	return PUTUO_SCREEN_STARTS


func _screen_rights() -> Array:
	return PUTUO_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return PUTUO_TRIGGER_X


func _birth_points() -> Array:
	return PUTUO_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_53_MONSTER_DATA.get(monster_id, {})
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
		if monster_id in [3031, 3043, 3049] and not nanhai_kinds.has(monster_id):
			nanhai_kinds.append(monster_id)
		elif monster_id == 3033:
			needs_boss = true
	if not nanhai_kinds.is_empty():
		await NANHAI_MONSTER_SCRIPT.prewarm_frames(nanhai_kinds)
	if needs_boss:
		LINGGAN_BOSS_SCRIPT.prewarm_frames()
		LINGGAN_BOSS_SCRIPT.prewarm_effects()


func _level_number() -> int:
	return 53

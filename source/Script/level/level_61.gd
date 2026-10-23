extends Game4ImportedLevel

const WANFO_STAGE_COUNT := 5
const WANFO_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const WANFO_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const WANFO_TRIGGER_X := [334.0, 1372.0, 2633.0, 3738.0, 4419.0]

const WANFO_RUNTIME_MONSTER_IDS := [3071, 3076, 3077, 3078, 3080, 3081, 3082]

const LEVEL_61_MONSTER_DATA := {
	3067:
	{
		"name": "花妖",
		"level": 90,
		"hp": 12295000,
		"attack": 32000,
		"def": 4600,
		"mdef": 4600,
		"crit": 300,
		"miss": 150,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4600,
		"magic_break": 4600,
		"speed": 12.5,
		"min_range": 20.0,
		"range": 215.0,
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
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 3334},
		},
	},
	3068:
	{
		"name": "核桃精",
		"level": 90,
		"hp": 12295000,
		"attack": 32000,
		"def": 4600,
		"mdef": 4600,
		"crit": 300,
		"miss": 150,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4600,
		"magic_break": 4600,
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
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 3334},
		},
	},
	3066:
	{
		"name": "泥偶精",
		"level": 90,
		"hp": 12295000,
		"attack": 32000,
		"def": 4600,
		"mdef": 4600,
		"crit": 300,
		"miss": 150,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4600,
		"magic_break": 4600,
		"speed": 8.75,
		"min_range": 20.0,
		"range": 110.0,
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
	3071:
	{
		"name": "土之祖巫",
		"level": 90,
		"hp": 30000000,
		"attack": 60000,
		"def": 6700,
		"mdef": 6700,
		"crit": 700,
		"miss": 490,
		"hit": 500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 6700,
		"magic_break": 6700,
		"speed": 0.0,
		"min_range": 0.0,
		"range": 1200.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-4.0, -3.0], "kind": "magic", "protect": 6668},
		},
	},
	3076:
	{
		"name": "守卫",
		"level": 90,
		"hp": 12295000,
		"attack": 52000,
		"def": 6000,
		"mdef": 6000,
		"crit": 300,
		"miss": 150,
		"hit": 580,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 6600,
		"magic_break": 6600,
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
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 3334},
			"hit2": {"multiplier": 0.5, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 3334},
			"hit3": {"multiplier": 1.0, "hurt_back": [-4.0, -3.0], "kind": "physics", "protect": 3334},
		},
	},
	3077:
	{
		"name": "土之祖巫",
		"level": 90,
		"hp": 25000000,
		"attack": 44000,
		"def": 5600,
		"mdef": 5600,
		"crit": 700,
		"miss": 490,
		"hit": 700,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 6500,
		"magic_break": 6500,
		"speed": 0.0,
		"min_range": 0.0,
		"range": 1200.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit3": {"multiplier": 0.5, "hurt_back": [-4.0, -3.0], "kind": "magic", "protect": 667},
		},
	},
	3078:
	{
		"name": "土之祖巫",
		"level": 90,
		"hp": 30000000,
		"attack": 64000,
		"def": 6000,
		"mdef": 6000,
		"crit": 700,
		"miss": 490,
		"hit": 700,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 6000,
		"magic_break": 6000,
		"speed": 0.0,
		"min_range": 0.0,
		"range": 1200.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "139300017", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit2": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 3334},
		},
	},
	3080:
	{
		"name": "后土小风",
		"level": 90,
		"hp": 1,
		"attack": 44000,
		"def": 5600,
		"mdef": 5600,
		"crit": 700,
		"miss": 490,
		"hit": 700,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 5500,
		"magic_break": 5500,
		"speed": 6.0,
		"min_range": 0.0,
		"range": 1200.0,
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
			"hit1": {"multiplier": 0.33, "hurt_back": [-1.0, -1.0], "kind": "magic", "protect": 1667},
		},
	},
	3081:
	{
		"name": "后土大风",
		"level": 90,
		"hp": 1,
		"attack": 44000,
		"def": 5600,
		"mdef": 5600,
		"crit": 700,
		"miss": 490,
		"hit": 700,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 5500,
		"magic_break": 5500,
		"speed": 3.0,
		"min_range": 0.0,
		"range": 1200.0,
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
			"hit1": {"multiplier": 0.33, "hurt_back": [-1.0, -1.0], "kind": "magic", "protect": 1667},
		},
	},
	3082:
	{
		"name": "石墙",
		"level": 90,
		"hp": 1,
		"attack": 64000,
		"def": 5600,
		"mdef": 5600,
		"crit": 700,
		"miss": 490,
		"hit": 700,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 6000,
		"magic_break": 6000,
		"speed": 0.5,
		"min_range": 0.0,
		"range": 1200.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"projectile_speed": 120.0,
		"projectile_lifetime": 5.0,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.75, "hurt_back": [-1.0, -1.0], "kind": "magic", "protect": 3334},
		},
	},
}

const WANFO_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3066,
		"position": Vector2(55, 444),
		"total": 2,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3068,
		"position": Vector2(179, 444),
		"total": 1,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3066,
		"position": Vector2(1017, 449),
		"total": 2,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 1,
		"after_dead": 0
	},
	{
		"point": 4,
		"stage": 1,
		"monster": 3068,
		"position": Vector2(894, 450),
		"total": 1,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 1,
		"monster": 3066,
		"position": Vector2(38, 443),
		"total": 1,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 4
	},
	{
		"point": 6,
		"stage": 1,
		"monster": 3068,
		"position": Vector2(200, 446),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 5,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 1,
		"monster": 3066,
		"position": Vector2(1064, 449),
		"total": 1,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 1,
		"monster": 3068,
		"position": Vector2(948, 448),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 7,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 2,
		"monster": 3066,
		"position": Vector2(1091, 448),
		"total": 3,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 10,
		"stage": 2,
		"monster": 3067,
		"position": Vector2(2072, 438),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 9,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 2,
		"monster": 3067,
		"position": Vector2(1086, 448),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 10
	},
	{
		"point": 12,
		"stage": 2,
		"monster": 3067,
		"position": Vector2(2019, 438),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 11,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 2,
		"monster": 3068,
		"position": Vector2(1746, 445),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 12,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 2,
		"monster": 3068,
		"position": Vector2(2122, 440),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 13,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 3,
		"monster": 3068,
		"position": Vector2(2195, 439),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 16,
		"stage": 3,
		"monster": 3067,
		"position": Vector2(3033, 454),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 3,
		"monster": 3066,
		"position": Vector2(3112, 455),
		"total": 2,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 16,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 3,
		"monster": 3068,
		"position": Vector2(2315, 438),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 15
	},
	{
		"point": 19,
		"stage": 3,
		"monster": 3067,
		"position": Vector2(2249, 440),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 18,
		"after_dead": 0
	},
	{
		"point": 20,
		"stage": 3,
		"monster": 3066,
		"position": Vector2(3070, 455),
		"total": 3,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 19,
		"after_dead": 0
	},
	{
		"point": 21,
		"stage": 4,
		"monster": 3066,
		"position": Vector2(3225, 456),
		"total": 1,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 22,
		"stage": 4,
		"monster": 3066,
		"position": Vector2(4121, 439),
		"total": 1,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 21,
		"after_dead": 0
	},
	{
		"point": 23,
		"stage": 4,
		"monster": 3068,
		"position": Vector2(3764, 451),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 24,
		"after_dead": 0
	},
	{
		"point": 24,
		"stage": 4,
		"monster": 3068,
		"position": Vector2(4014, 443),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 22,
		"after_dead": 0
	},
	{
		"point": 25,
		"stage": 4,
		"monster": 3067,
		"position": Vector2(3199, 457),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 26,
		"stage": 4,
		"monster": 3067,
		"position": Vector2(4070, 441),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 25,
		"after_dead": 0
	},
	{
		"point": 27,
		"stage": 4,
		"monster": 3066,
		"position": Vector2(3164, 457),
		"total": 1,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 23
	},
	{
		"point": 28,
		"stage": 4,
		"monster": 3066,
		"position": Vector2(4034, 444),
		"total": 1,
		"interval": 0.6,
		"face": 1,
		"after_spawn": 27,
		"after_dead": 0
	},
	{
		"point": 29,
		"stage": 4,
		"monster": 3068,
		"position": Vector2(4056, 441),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 28,
		"after_dead": 0
	},
	{
		"point": 30,
		"stage": 4,
		"monster": 3068,
		"position": Vector2(3729, 451),
		"total": 2,
		"interval": 1.5,
		"face": 1,
		"after_spawn": 29,
		"after_dead": 0
	},
	{
		"point": 31,
		"stage": 4,
		"monster": 3067,
		"position": Vector2(3175, 456),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 30,
		"after_dead": 0
	},
	{
		"point": 32,
		"stage": 4,
		"monster": 3067,
		"position": Vector2(4097, 439),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 31,
		"after_dead": 0
	},
	{
		"point": 50,
		"stage": 5,
		"monster": 3071,
		"position": Vector2(4389, 346),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _ready() -> void:
	super._ready()
	if _role != null:
		_role.position = Vector2(31, 446)


func _stage_count() -> int:
	return WANFO_STAGE_COUNT


func _screen_starts() -> Array:
	return WANFO_SCREEN_STARTS


func _screen_rights() -> Array:
	return WANFO_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return WANFO_TRIGGER_X


func _birth_points() -> Array:
	return WANFO_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_61_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _level_number() -> int:
	return 61


func _preload_level_resources() -> void:
	await super._preload_level_resources()
	await Global.preload_level_monster_runtime_resources(WANFO_RUNTIME_MONSTER_IDS)


func _on_fall_death_body_entered(body: Node2D) -> void:
	if body == _role:
		RoleProp.roleprop.Hp = 0

extends Game4ImportedLevel

const JIUHUA_STAGE_COUNT := 5
const JIUHUA_BGM_PATH := "res://Music/level/original_bg_02.mp3"
const JIUHUA_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0, 3784.0]
const JIUHUA_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0, 4984.0]
const JIUHUA_TRIGGER_X := [187.0, 1218.0, 2366.0, 3513.0, 4411.0]

const LEVEL_50_MONSTER_DATA := {
	3008:
	{
		"name": "蘑菇精",
		"level": 90,
		"hp": 5295000,
		"attack": 20000,
		"def": 1400,
		"mdef": 1400,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
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
	3009:
	{
		"name": "金钱松",
		"level": 90,
		"hp": 6295000,
		"attack": 21000,
		"def": 1400,
		"mdef": 1400,
		"crit": 300,
		"miss": 160,
		"hit": 290,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
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
	3019:
	{
		"name": "闵老护法",
		"level": 90,
		"hp": 18000000,
		"attack": 32000,
		"def": 4800,
		"mdef": 4800,
		"crit": 700,
		"miss": 160,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4000,
		"magic_break": 4000,
		"speed": 9.0,
		"min_range": 0.0,
		"range": 370.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"cooldown": 1600,
		"exp": 100,
		"coin": 280,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "pgs_2", "min_value": 2, "max_value": 5, "chance": 0.15},
			{"name": "7_bsjh", "chance": 0.25, "min_value": 1, "max_value": 1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.0, "hurt_back": [0, 0], "kind": "", "protect": 0},
			"hit2":
			{
				"multiplier": 1.0,
				"hurt_back": [-5, -2],
				"kind": "physics",
				"protect": 834,
				"source_target_move": Vector2(138, 120),
				"source_stiff_seconds": 1.0,
			},
			"hit3":
			{
				"multiplier": 0.5,
				"hurt_back": [-5, -2],
				"kind": "magic",
				"protect": 3334,
				"source_target_move": Vector2(206, 80),
				"source_stiff_seconds": 0.834,
			},
		},
	},
}

const JIUHUA_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3008,
		"position": Vector2(735, 400),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3008,
		"position": Vector2(644, 400),
		"total": 1,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3008,
		"position": Vector2(849, 400),
		"total": 4,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 4,
		"stage": 2,
		"monster": 3008,
		"position": Vector2(1815, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3009,
		"position": Vector2(1849, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3008,
		"position": Vector2(1199, 400),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 5
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3009,
		"position": Vector2(1201, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 3,
		"monster": 3008,
		"position": Vector2(2980, 400),
		"total": 3,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 3,
		"monster": 3009,
		"position": Vector2(2311, 400),
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
		"position": Vector2(2325, 400),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 9
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3009,
		"position": Vector2(2928, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 10,
		"after_dead": 0
	},
	{
		"point": 12,
		"stage": 4,
		"monster": 3008,
		"position": Vector2(4033, 400),
		"total": 3,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 4,
		"monster": 3008,
		"position": Vector2(3317, 400),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 4,
		"monster": 3009,
		"position": Vector2(3303, 400),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 12
	},
	{
		"point": 15,
		"stage": 4,
		"monster": 3009,
		"position": Vector2(4043, 400),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 13
	},
	{
		"point": 16,
		"stage": 5,
		"monster": 3019,
		"position": Vector2(4612, 400),
		"total": 1,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
]


func _ready() -> void:
	super._ready()


func _level_bgm_path() -> String:
	return JIUHUA_BGM_PATH


func _stage_count() -> int:
	return JIUHUA_STAGE_COUNT


func _screen_starts() -> Array:
	return JIUHUA_SCREEN_STARTS


func _screen_rights() -> Array:
	return JIUHUA_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return JIUHUA_TRIGGER_X


func _birth_points() -> Array:
	return JIUHUA_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_50_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _level_number() -> int:
	return 50

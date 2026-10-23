extends Game4ImportedLevel

const STAGE_COUNT := 4
const ROOM_WIDTH := 1200.0
const LEVEL_68_MONSTER_DATA := {
	3181:
	{
		"name": "骨刺兽",
		"level": 90,
		"hp": 45000000,
		"attack": 64000,
		"def": 10500,
		"mdef": 10500,
		"crit": 340,
		"miss": 180,
		"hit": 2500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 14500,
		"magic_break": 14500,
		"speed": 12.0,
		"min_range": 0.0,
		"range": 150.0,
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
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
			"hit2": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
		},
	},
	3183:
	{
		"name": "蘑菇长老",
		"level": 90,
		"hp": 45000000,
		"attack": 64000,
		"def": 10500,
		"mdef": 10500,
		"crit": 340,
		"miss": 180,
		"hit": 2500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 14500,
		"magic_break": 14500,
		"speed": 12.0,
		"min_range": 0.0,
		"range": 520.0,
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
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
			"hit2": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 90},
		},
	},
	3182:
	{
		"name": "雨之祖巫",
		"level": 90,
		"hp": 220000000,
		"attack": 95000,
		"def": 12200,
		"mdef": 12200,
		"crit": 500,
		"miss": 180,
		"hit": 2500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 16500,
		"magic_break": 16500,
		"speed": 0.0,
		"min_range": 0.0,
		"range": 1200.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 120,
		"coin": 320,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "ygfjsszzs", "value": 1, "chance": 0.1},
			{"name": "ygfjblzzs", "value": 1, "chance": 0.1},
			{"name": "ygfjnzzzs", "value": 1, "chance": 0.1}
		],
		"damage_bonus": 0.6,
		"damage_reduction": 0.6,
		"is_boss": true,
		"max_protect": 250.0,
		"attacks":
		{
			"hit1":
			{
				"multiplier": 1.0,
				"hurt_back": [-4.0, -2.0],
				"kind": "physics",
				"protect": 90,
				"source_target_move": [32, 42]
			},
			"hit2":
			{
				"multiplier": 0.75,
				"hurt_back": [-4.0, -2.0],
				"kind": "physics",
				"protect": 90,
				"source_target_move": [32, 42]
			},
			"hit3":
			{
				"multiplier": 1.0,
				"hurt_back": [-4.0, -2.0],
				"kind": "physics",
				"protect": 90,
				"source_target_move": [33, 66]
			},
			"hit4": {"multiplier": 0.1, "hurt_back": [0.0, 0.0], "kind": "real", "protect": 0},
			"hit5": {"multiplier": 0.0, "hurt_back": [0.0, 0.0], "kind": "real", "protect": 0},
		},
	},
}
const BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3181,
		"position": Vector2(260, 448),
		"total": 3,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3183,
		"position": Vector2(900, 448),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 2,
		"monster": 3183,
		"position": Vector2(320, 448),
		"total": 3,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 4,
		"stage": 2,
		"monster": 3181,
		"position": Vector2(860, 448),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 3,
		"monster": 3181,
		"position": Vector2(220, 448),
		"total": 3,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 3,
		"monster": 3183,
		"position": Vector2(600, 448),
		"total": 2,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 3,
		"monster": 3181,
		"position": Vector2(980, 448),
		"total": 3,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 50,
		"stage": 4,
		"monster": 3182,
		"position": Vector2(900, 563),
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
	return [0.0, 0.0, 0.0, 0.0]


func _screen_rights() -> Array:
	return [ROOM_WIDTH, ROOM_WIDTH, ROOM_WIDTH, ROOM_WIDTH]


func _stage_trigger_x() -> Array:
	return [0.0, 0.0, 0.0, 0.0]


func _birth_points() -> Array:
	return BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var source: Variant = LEVEL_68_MONSTER_DATA.get(monster_id, {})
	return (source as Dictionary).duplicate(true) if source is Dictionary else {}


func _level_number() -> int:
	return 68


func _update_stage_progression() -> void:
	if not _spawn_runtime_ready or _role == null:
		return
	if current_stage == 0:
		_start_stage(1)
		return
	if current_stage < _stage_count() and check_can_pass():
		_start_stage(current_stage + 1)

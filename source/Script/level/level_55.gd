extends Game4ImportedLevel

const BOSS_SCENE_PATH := "res://Scene/level/level_55_boss.tscn"
const BOSS_SOURCE_MAP := "fahualingdong_boss_v1"
const BOSS_MONSTER_SCENE_PATH := "res://Scene/monster/monster_3035.tscn"
const NANHAI_MONSTER_SCRIPT_PATH := "res://Script/monster/nanhai_monster.gd"

const MAIN_STAGE_COUNT := 4
const MAIN_SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0]
const MAIN_SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0]
const MAIN_TRIGGER_X := [397.0, 1337.0, 2387.0, 3392.0]

const BOSS_STAGE_COUNT := 1
const BOSS_SCREEN_STARTS := [0.0]
const BOSS_SCREEN_RIGHTS := [1200.0]
const BOSS_TRIGGER_X := [700.0]

const LEVEL_55_MONSTER_DATA := {
	3030:
	{
		"name": "蚌女",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2500,
		"mdef": 2500,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2500,
		"magic_break": 2500,
		"speed": 8.75,
		"min_range": 80.0,
		"range": 350.0,
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
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 1112},
		},
	},
	3032:
	{
		"name": "夜叉",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2500,
		"mdef": 2500,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2500,
		"magic_break": 2500,
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
	3028:
	{
		"name": "贝壳",
		"level": 90,
		"hp": 8295000,
		"attack": 20000,
		"def": 2500,
		"mdef": 2500,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2500,
		"magic_break": 2500,
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
	3035:
	{
		"name": "水之祖巫",
		"level": 90,
		"hp": 23000000,
		"attack": 42000,
		"def": 5200,
		"mdef": 5200,
		"crit": 700,
		"miss": 460,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 5000,
		"magic_break": 5000,
		"speed": 0.0,
		"range": 1200.0,
		"sight": 1200,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "hhyq", "value": 1, "chance": 0.1},
			{"name": "139300018", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-5, -2], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 0.67, "hurt_back": [-3, -1], "kind": "magic", "protect": 6668},
			"hit3": {"multiplier": 1.5, "hurt_back": [-2, -6], "kind": "magic", "protect": 6668},
		},
	},
}

const MAIN_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3030,
		"position": Vector2(933, 322),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3032,
		"position": Vector2(940, 323),
		"total": 3,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 3,
		"stage": 1,
		"monster": 3032,
		"position": Vector2(81, 314),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 1
	},
	{
		"point": 4,
		"stage": 1,
		"monster": 3030,
		"position": Vector2(66, 319),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 3,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3028,
		"position": Vector2(1882, 341),
		"total": 1,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3030,
		"position": Vector2(1110, 327),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 2,
		"monster": 3030,
		"position": Vector2(1859, 343),
		"total": 2,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 8,
		"stage": 2,
		"monster": 3028,
		"position": Vector2(1101, 322),
		"total": 1,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 9,
		"stage": 2,
		"monster": 3032,
		"position": Vector2(1090, 319),
		"total": 3,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 6
	},
	{
		"point": 10,
		"stage": 2,
		"monster": 3032,
		"position": Vector2(1868, 344),
		"total": 3,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 9,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 3,
		"monster": 3028,
		"position": Vector2(2928, 350),
		"total": 1,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 12,
		"stage": 3,
		"monster": 3030,
		"position": Vector2(2954, 347),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 13,
		"stage": 3,
		"monster": 3028,
		"position": Vector2(2142, 343),
		"total": 1,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 14,
		"stage": 3,
		"monster": 3030,
		"position": Vector2(2133, 346),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 15,
		"stage": 3,
		"monster": 3032,
		"position": Vector2(2155, 348),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 14
	},
	{
		"point": 16,
		"stage": 3,
		"monster": 3032,
		"position": Vector2(2941, 368),
		"total": 2,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 15,
		"after_dead": 0
	},
	{
		"point": 17,
		"stage": 4,
		"monster": 3032,
		"position": Vector2(3169, 354),
		"total": 2,
		"interval": 0.5,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 18,
		"stage": 4,
		"monster": 3030,
		"position": Vector2(3166, 350),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 19,
		"stage": 4,
		"monster": 3028,
		"position": Vector2(3862, 331),
		"total": 2,
		"interval": 0.8,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 20,
		"stage": 4,
		"monster": 3032,
		"position": Vector2(3834, 326),
		"total": 2,
		"interval": 0.5,
		"face": -1,
		"after_spawn": 0,
		"after_dead": 18
	},
	{
		"point": 21,
		"stage": 4,
		"monster": 3030,
		"position": Vector2(3809, 330),
		"total": 3,
		"interval": 1.0,
		"face": -1,
		"after_spawn": 20,
		"after_dead": 0
	},
	{
		"point": 22,
		"stage": 4,
		"monster": 3028,
		"position": Vector2(3171, 349),
		"total": 2,
		"interval": 0.8,
		"face": 1,
		"after_spawn": 21,
		"after_dead": 0
	},
]

const BOSS_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3035,
		"position": Vector2(1051, 413),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
]

var _boss_scene_preload_requested := false
var _missing_boss_scene_reported := false


func _ready() -> void:
	is_two_scene = not _is_boss_map()
	super._ready()
	_ensure_boss_battle_hud()


func _ensure_boss_battle_hud() -> void:
	if not _is_boss_map():
		return
	var hud := get_node_or_null("CanvasLayer") as CanvasLayer
	if hud != null:
		hud.visible = true
	if role_information == null:
		role_information = Global.add_role_information(self, Vector2.ZERO)
	if role_information != null and role_information.has_method("reveal_after_scene_loaded"):
		role_information.call("reveal_after_scene_loaded")
	elif role_information is CanvasItem:
		(role_information as CanvasItem).visible = true


func _physics_process(delta: float) -> void:
	if not _is_boss_map() and can_exit and Input.is_action_just_pressed("Exit"):
		_enter_boss_map()
		return
	super._physics_process(delta)
	if not _is_boss_map() and check_can_exit():
		exit.visible = true
		exit_2.disabled = false
		if _is_auto_battle_enabled():
			_enter_boss_map()
			return


func _start_stage(stage: int) -> void:
	super._start_stage(stage)
	if not _is_boss_map() and stage == MAIN_STAGE_COUNT:
		_request_boss_scene_preload()
		call_deferred("_prewarm_boss_runtime")


func _stage_count() -> int:
	return BOSS_STAGE_COUNT if _is_boss_map() else MAIN_STAGE_COUNT


func _screen_starts() -> Array:
	return BOSS_SCREEN_STARTS if _is_boss_map() else MAIN_SCREEN_STARTS


func _screen_rights() -> Array:
	return BOSS_SCREEN_RIGHTS if _is_boss_map() else MAIN_SCREEN_RIGHTS


func _stage_trigger_x() -> Array:
	return BOSS_TRIGGER_X if _is_boss_map() else MAIN_TRIGGER_X


func _birth_points() -> Array:
	return BOSS_BIRTH_POINTS if _is_boss_map() else MAIN_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_55_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _preload_level_resources() -> void:
	await super._preload_level_resources()
	await _prewarm_stage_runtime(monster_group.get("stage_1", []))


func _preload_stage_resources(monster_ids: Array) -> void:
	await super._preload_stage_resources(monster_ids)
	await _prewarm_stage_runtime(monster_ids)


func _prewarm_stage_runtime(monster_ids: Array) -> void:
	var nanhai_kinds: Array = []
	for monster_id_value in monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id in [3030, 3032, 3028] and not nanhai_kinds.has(monster_id):
			nanhai_kinds.append(monster_id)
	if nanhai_kinds.is_empty() or not ResourceLoader.exists(NANHAI_MONSTER_SCRIPT_PATH):
		return
	var runtime_script: Variant = load(NANHAI_MONSTER_SCRIPT_PATH)
	var prewarm_frames := Callable(runtime_script, "prewarm_frames")
	if prewarm_frames.is_valid():
		await prewarm_frames.call(nanhai_kinds)


func one_check_can_exit() -> bool:
	if _is_boss_map():
		return super.one_check_can_exit()
	return false


func _level_number() -> int:
	return 55


func _is_boss_map() -> bool:
	return source_map == BOSS_SOURCE_MAP


func _request_boss_scene_preload() -> void:
	if _boss_scene_preload_requested:
		return
	_boss_scene_preload_requested = true
	if not ResourceLoader.exists(BOSS_SCENE_PATH):
		_report_missing_boss_scene()
		return
	Global.preload_next(BOSS_SCENE_PATH)


func _prewarm_boss_runtime() -> void:
	if not ResourceLoader.exists(BOSS_MONSTER_SCENE_PATH):
		return
	await Global.preload_level_monster_runtime_resources([3035])


func _enter_boss_map() -> void:
	if not ResourceLoader.exists(BOSS_SCENE_PATH):
		_report_missing_boss_scene()
		return
	can_exit = false
	exit.visible = false
	exit_2.set_deferred("disabled", true)
	Global.change_scene(BOSS_SCENE_PATH)


func _report_missing_boss_scene() -> void:
	if _missing_boss_scene_reported:
		return
	_missing_boss_scene_reported = true
	push_error("Level 55 requires %s and its fahualingdong_bossV1 background resources" % BOSS_SCENE_PATH)

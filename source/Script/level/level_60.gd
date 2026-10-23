extends Game4ImportedLevel

const HAZARD_1022_PROJECTILE_SCRIPT := preload("res://Script/level/level60_hazard1022_projectile.gd")

const JINXIU_STAGE_COUNT := 5
const DAT_Y_OFFSET := 2912.0
const MAP_WIDTH := 1200.0
const MAP_SOURCE_WIDTH := 1056.0
const MAP_SOURCE_HEIGHT := 3840.0
const LEVEL_ROOT_OFFSET_Y := 112.0

const JINXIU_TRIGGER_Y := [289.0, -241.0, -943.0, -1565.0, -2586.0]
const JINXIU_FORWARD_TOPS := [-600.0, -1200.0, -1800.0, -2400.0, -2912.0]
const JINXIU_BACK_BOTTOMS := [590.0, 0.0, -600.0, -1200.0, -2322.0]

const LEVEL_60_SOURCE_SCENE_MAP := {
	3067: "res://Scene/monster/monster_3067.tscn",
	3065: "res://Scene/monster/monster_3065.tscn",
	3070: "res://Scene/monster/monster_3070.tscn",
}

const LEVEL_60_MONSTER_DATA := {
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
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4600,
		"magic_break": 4600,
		"speed": 10.0,
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
	3065:
	{
		"name": "鸟身女妖",
		"source_monster_id": 3072,
		"level": 90,
		"hp": 12295000,
		"attack": 22000,
		"def": 4600,
		"mdef": 4600,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4600,
		"magic_break": 4600,
		"speed": 12.5,
		"min_range": 75.0,
		"range": 100.0,
		"vertical_range": 100.0,
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
			"hit1": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "physics", "protect": 3334},
		},
	},
	3070:
	{
		"name": "芙蓉仙子",
		"level": 90,
		"hp": 27000000,
		"attack": 50000,
		"def": 6600,
		"mdef": 6600,
		"crit": 700,
		"miss": 490,
		"hit": 500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 6800,
		"magic_break": 6800,
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
			{"name": "469000004", "value": 1, "chance": 0.1},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-4.0, -2.0], "kind": "physics", "protect": 6668},
			"hit4": {"multiplier": 1.0, "hurt_back": [-4.0, -3.0], "kind": "magic", "protect": 6668},
		},
	},
}

const JINXIU_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3067,
		"position": Vector2(1043, 331),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 2,
		"stage": 1,
		"monster": 3067,
		"position": Vector2(156, 203),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 1,
		"after_dead": 0
	},
	{
		"point": 4,
		"stage": 1,
		"monster": 3067,
		"position": Vector2(1034, -10),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 2,
		"after_dead": 0
	},
	{
		"point": 50,
		"stage": 1,
		"monster": 3065,
		"source_monster": 3072,
		"position": Vector2(1060, 177),
		"total": 2,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 5,
		"stage": 2,
		"monster": 3067,
		"position": Vector2(62, -187),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 6,
		"stage": 2,
		"monster": 3067,
		"position": Vector2(1012, -488),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 5,
		"after_dead": 0
	},
	{
		"point": 53,
		"stage": 2,
		"monster": 3065,
		"source_monster": 3072,
		"position": Vector2(125, -622),
		"total": 3,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 70,
		"stage": 2,
		"monster": 3067,
		"position": Vector2(581, -721),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 6,
		"after_dead": 0
	},
	{
		"point": 7,
		"stage": 3,
		"monster": 3067,
		"position": Vector2(623, -1225),
		"total": 3,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 55,
		"stage": 3,
		"monster": 3065,
		"source_monster": 3072,
		"position": Vector2(116, -1301),
		"total": 2,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 56,
		"stage": 3,
		"monster": 3065,
		"source_monster": 3072,
		"position": Vector2(785, -1315),
		"total": 2,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 55,
		"after_dead": 0
	},
	{
		"point": 11,
		"stage": 4,
		"monster": 3067,
		"position": Vector2(596, -1800),
		"total": 2,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 59,
		"stage": 4,
		"monster": 3065,
		"source_monster": 3072,
		"position": Vector2(238, -1819),
		"total": 2,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 60,
		"stage": 4,
		"monster": 3065,
		"source_monster": 3072,
		"position": Vector2(1027, -1798),
		"total": 2,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 59,
		"after_dead": 0
	},
	{
		"point": 61,
		"stage": 4,
		"monster": 3065,
		"source_monster": 3072,
		"position": Vector2(199, -2232),
		"total": 2,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 60
	},
	{
		"point": 62,
		"stage": 4,
		"monster": 3065,
		"source_monster": 3072,
		"position": Vector2(991, -2245),
		"total": 2,
		"interval": 2.0,
		"face": 1,
		"after_spawn": 61,
		"after_dead": 0
	},
	{
		"point": 71,
		"stage": 4,
		"monster": 3067,
		"position": Vector2(579, -2166),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
	{
		"point": 40,
		"stage": 5,
		"monster": 3070,
		"position": Vector2(963, -2479),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
]

const HAZARD_1022_COOLDOWN_SECONDS := 5.0
const HAZARD_1022_SHOOT_TIME_SECONDS := 5.0
const HAZARD_1022_HORIZONTAL_SPEED := 40.0
const HAZARD_1022_DAMAGE := 107
const HAZARD_1022_START_OFFSETS := [Vector2(-17.0, 9.0), Vector2(17.0, 9.0)]
const HAZARD_1022_TRIGGER_RECTS := [
	Rect2(-20.0, 2994.0, 1249.0, 321.0),
	Rect2(-7.0, 2591.0, 1223.0, 257.0),
	Rect2(-17.0, 2010.0, 1237.0, 238.0),
	Rect2(-37.0, 1347.0, 1264.0, 417.0),
	Rect2(-322.0, 836.0, 1209.0, 322.0),
	Rect2(54.0, 836.0, 1205.0, 322.0),
]

var _screen_top_wall: CollisionShape2D
var _screen_bottom_wall: CollisionShape2D
var _hazard_1022_active: Array[bool] = []
var _hazard_1022_ready: Array[bool] = []
var _hazard_1022_emitters: Array[Node2D] = []
var _hazard_1022_timers: Array[Timer] = []


func _ready() -> void:
	super._ready()
	if _role != null:
		_role.position = Vector2(31, 446)
	_setup_hazard_1022()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = false


func _stage_count() -> int:
	return JINXIU_STAGE_COUNT


func _birth_points() -> Array:
	return JINXIU_BIRTH_POINTS


func _stage_trigger_x() -> Array:
	return [600.0, 600.0, 600.0, 600.0, 600.0]


func _stage_trigger_positions() -> Array:
	var result: Array = []
	for trigger_y in JINXIU_TRIGGER_Y:
		result.append(Vector2(600.0, float(trigger_y) - 20.0))
	return result


func _screen_starts() -> Array:
	return [0.0, 0.0, 0.0, 0.0, 0.0]


func _screen_rights() -> Array:
	return [MAP_WIDTH, MAP_WIDTH, MAP_WIDTH, MAP_WIDTH, MAP_WIDTH]


func get_level_monster_config(monster_id: int) -> Dictionary:
	var runtime_monster_id := 3065 if monster_id == 3072 else monster_id
	var config: Variant = LEVEL_60_MONSTER_DATA.get(runtime_monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _level_number() -> int:
	return 60


func _update_stage_progression() -> void:
	if not _spawn_runtime_ready or _role == null:
		return
	var role_y := float(_role.position.y)
	if current_stage == 0:
		if role_y <= JINXIU_TRIGGER_Y[0]:
			_start_stage(1)
		return
	if current_stage < _stage_count() and check_can_pass():
		var next_trigger_y: float = JINXIU_TRIGGER_Y[current_stage]
		if role_y <= next_trigger_y:
			_start_stage(current_stage + 1)


func _create_screen_walls() -> void:
	var wall_node := get_node_or_null("wall") as StaticBody2D
	if wall_node == null:
		return
	var wall_shape := RectangleShape2D.new()
	wall_shape.size = Vector2(MAP_WIDTH + 400.0, 10.0)
	_screen_top_wall = CollisionShape2D.new()
	_screen_top_wall.name = "screen_top_wall"
	_screen_top_wall.shape = wall_shape
	wall_node.add_child(_screen_top_wall)

	_screen_bottom_wall = CollisionShape2D.new()
	_screen_bottom_wall.name = "screen_bottom_wall"
	_screen_bottom_wall.shape = wall_shape.duplicate()
	wall_node.add_child(_screen_bottom_wall)


func _update_screen_bounds(_delta: float = 0.0) -> void:
	var stage_for_bounds := clampi(current_stage, 1, _stage_count())
	var screen_index := stage_for_bounds - 1
	var forward_top: float = JINXIU_FORWARD_TOPS[screen_index]
	var stage_clear := current_stage >= 1 and check_can_pass()
	var open_top := forward_top
	if current_stage >= 1 and current_stage < _stage_count() and stage_clear:
		open_top = float(JINXIU_FORWARD_TOPS[screen_index + 1])
	var back_bottom: float = JINXIU_BACK_BOTTOMS[screen_index]

	if is_instance_valid(_screen_top_wall):
		_screen_top_wall.position = Vector2(MAP_WIDTH * 0.5 - 1.0, open_top - LEVEL_ROOT_OFFSET_Y - 5.0)
		_screen_top_wall.disabled = false
	if is_instance_valid(_screen_bottom_wall):
		_screen_bottom_wall.position = Vector2(MAP_WIDTH * 0.5 - 1.0, back_bottom - LEVEL_ROOT_OFFSET_Y + 5.0)
		_screen_bottom_wall.disabled = false
	if my_camera != null:
		my_camera.max_left = 0.0
		my_camera.max_right = MAP_WIDTH
		my_camera.max_top = -DAT_Y_OFFSET
		my_camera.max_bottom = 590.0


func _setup_hazard_1022() -> void:
	_hazard_1022_active.resize(HAZARD_1022_TRIGGER_RECTS.size())
	_hazard_1022_active.fill(false)
	_hazard_1022_ready.resize(HAZARD_1022_TRIGGER_RECTS.size())
	_hazard_1022_ready.fill(true)

	for hazard_index in range(HAZARD_1022_TRIGGER_RECTS.size()):
		var emitter := get_node_or_null("TerrainHazards/Hazard1022_%d" % (hazard_index + 1)) as Node2D
		_hazard_1022_emitters.append(emitter)

		var source_rect: Rect2 = HAZARD_1022_TRIGGER_RECTS[hazard_index]
		var trigger := Area2D.new()
		trigger.name = "Hazard1022Trigger%d" % (hazard_index + 1)
		trigger.collision_layer = 0
		trigger.collision_mask = 18
		trigger.monitoring = true
		trigger.monitorable = false
		add_child(trigger)
		trigger.global_position = source_rect.get_center() - Vector2(0.0, DAT_Y_OFFSET)

		var trigger_shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = source_rect.size
		trigger_shape.shape = rectangle
		trigger.add_child(trigger_shape)
		trigger.body_entered.connect(_on_hazard_1022_trigger_entered.bind(hazard_index))
		trigger.body_exited.connect(_on_hazard_1022_trigger_exited.bind(hazard_index))

		var timer := Timer.new()
		timer.name = "Hazard1022Timer%d" % (hazard_index + 1)
		timer.wait_time = HAZARD_1022_COOLDOWN_SECONDS
		timer.one_shot = true
		timer.timeout.connect(_on_hazard_1022_timer_timeout.bind(hazard_index))
		trigger.add_child(timer)
		_hazard_1022_timers.append(timer)


func _on_hazard_1022_trigger_entered(body: Node2D, hazard_index: int) -> void:
	if body != _role or _hazard_1022_active[hazard_index]:
		return
	_hazard_1022_active[hazard_index] = true
	if _hazard_1022_ready[hazard_index]:
		_fire_hazard_1022(hazard_index)


func _on_hazard_1022_trigger_exited(body: Node2D, hazard_index: int) -> void:
	if body == _role:
		_hazard_1022_active[hazard_index] = false


func _on_hazard_1022_timer_timeout(hazard_index: int) -> void:
	_hazard_1022_ready[hazard_index] = true
	if _hazard_1022_active[hazard_index]:
		_fire_hazard_1022(hazard_index)


func _fire_hazard_1022(hazard_index: int) -> void:
	if not _hazard_1022_ready[hazard_index]:
		return
	var emitter := _hazard_1022_emitters[hazard_index]
	if emitter == null or not is_instance_valid(emitter) or _role == null:
		return
	var emitter_sprite := emitter.get_node_or_null("Sprite2D") as Sprite2D
	if emitter_sprite == null:
		return
	_hazard_1022_ready[hazard_index] = false
	_hazard_1022_timers[hazard_index].start()
	var source_position := emitter_sprite.global_position
	for start_offset in HAZARD_1022_START_OFFSETS:
		var horizontal_direction := signf(start_offset.x)
		var projectile = HAZARD_1022_PROJECTILE_SCRIPT.new()
		projectile.configure(
			source_position + start_offset,
			Vector2(horizontal_direction * HAZARD_1022_HORIZONTAL_SPEED, 0.0),
			_role,
			HAZARD_1022_DAMAGE,
			HAZARD_1022_SHOOT_TIME_SECONDS
		)
		call_deferred("add_child", projectile)

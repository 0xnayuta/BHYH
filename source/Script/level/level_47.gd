extends BaseLevel

const SCREEN_STARTS := [0.0, 1000.0, 2000.0, 3000.0]
const SCREEN_RIGHTS := [1200.0, 2200.0, 3200.0, 4200.0]
const STAGE_TRIGGER_X := [312.0, 1450.0, 2467.0, 3616.0]
const CAMERA_VIEW_WIDTH := 1200.0
const CAMERA_LIMIT_SPEED := 600.0
const CAMERA_UNLOCK_MARGIN := 100.0
const LAST_SCREEN_RIGHT := 4200.0
const LEVEL_47_BGM_PATH := "res://Music/level/original_bg_01.mp3"

const LEVEL_47_MONSTER_DATA := {
	3001:
	{
		"name": "魔盾虎兵",
		"level": 90,
		"hp": 4295000,
		"attack": 20000,
		"def": 1100,
		"mdef": 1100,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 12.0,
		"range": 105.0,
		"sight": 720.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4, -2], "kind": "physics", "protect": 80},
			"hit2": {"multiplier": 1.25, "hurt_back": [-6, -3], "kind": "physics", "protect": 110},
		},
	},
	3003:
	{
		"name": "牛铁枪",
		"level": 90,
		"hp": 4295000,
		"attack": 20000,
		"def": 1100,
		"mdef": 1100,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 12.0,
		"range": 155.0,
		"sight": 760.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4, -2], "kind": "physics", "protect": 80},
		},
	},
	3004:
	{
		"name": "投石车",
		"level": 90,
		"hp": 7295000,
		"attack": 20000,
		"def": 1100,
		"mdef": 1100,
		"crit": 300,
		"miss": 150,
		"hit": 280,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 900,
		"magic_break": 900,
		"speed": 7.0,
		"range": 520.0,
		"sight": 900.0,
		"attack_desire": 100,
		"exp": 10,
		"coin": 8,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": false,
		"max_protect": 100.0,
		"attacks":
		{
			"arrow": {"multiplier": 1.1, "hurt_back": [-3, -1], "kind": "physics", "protect": 70},
		},
	},
	3005:
	{
		"name": "寅将军",
		"level": 90,
		"hp": 18000000,
		"attack": 30000,
		"def": 4750,
		"mdef": 4750,
		"crit": 700,
		"miss": 150,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 2900,
		"magic_break": 2900,
		"speed": 9.0,
		"range": 145.0,
		"sight": 1100.0,
		"attack_desire": 100,
		"exp": 100,
		"coin": 280,
		"drop_rate": 0.0,
		"drop_list": [],
		"independent_drop_list":
		[
			{"name": "pgs", "min_value": 2, "max_value": 5, "chance": 0.15},
		],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "hurt_back": [-4, -2], "kind": "physics", "protect": 80},
			"hit2": {"multiplier": 1.25, "hurt_back": [-6, -3], "kind": "physics", "protect": 110},
			"hit3": {"multiplier": 1.5, "hurt_back": [-5, -2], "kind": "magic", "protect": 130},
		},
	},
}

var _screen_left_wall: CollisionShape2D
var _screen_right_wall: CollisionShape2D
var _camera_left_limit := 0.0
var _camera_room := 1


func _ready() -> void:
	var bgm_stream := Global.get_cached_audio(LEVEL_47_BGM_PATH)
	if bgm_stream is AudioStreamMP3:
		bgm_stream.loop = true
	Global.add_bgm(self, LEVEL_47_BGM_PATH)
	_create_screen_walls()
	Global.current_level = "玄武门"
	level_stage = 47
	Global.game_over = 1
	monster_group = {
		"stage_1": [3003, 3003, 3003, 3003, 3003, 3003, 3003, 3003, 3001, 3001],
		"stage_2": [3003, 3003, 3001, 3001, 3003, 3003, 3003, 3004, 3003, 3003, 3003],
		"stage_3": [3003, 3003, 3003, 3004, 3001, 3001, 3003, 3003, 3003, 3001, 3001],
		"stage_4": [3005],
	}
	monster_position_x = {
		"stage_1": [560, 590, 620, 650, 680, 710, 840, 880, 860, 910],
		"stage_2": [1250, 1290, 1220, 1270, 1430, 1470, 1510, 1800, 1730, 1770, 1810],
		"stage_3": [2130, 2170, 2210, 2690, 2660, 2720, 2100, 2140, 2180, 2680, 2740],
		"stage_4": [3973],
	}
	monster_position_y = {
		"stage_1": [400, 400, 400, 400, 400, 400, 400, 400, 400, 400],
		"stage_2": [400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400],
		"stage_3": [400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400],
		"stage_4": [399],
	}
	super._ready()
	_update_screen_bounds()


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_47_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _create_screen_walls() -> void:
	var wall_node := get_node_or_null("wall") as StaticBody2D
	if wall_node == null:
		return
	var left_shape := RectangleShape2D.new()
	left_shape.size = Vector2(10, 1800)
	_screen_left_wall = CollisionShape2D.new()
	_screen_left_wall.name = "screen_left_wall"
	_screen_left_wall.position = Vector2(0, -400)
	_screen_left_wall.shape = left_shape
	wall_node.add_child(_screen_left_wall)
	var right_shape := RectangleShape2D.new()
	right_shape.size = Vector2(10, 1800)
	_screen_right_wall = CollisionShape2D.new()
	_screen_right_wall.name = "screen_right_wall"
	_screen_right_wall.position = Vector2(SCREEN_RIGHTS[0], -400)
	_screen_right_wall.shape = right_shape
	wall_node.add_child(_screen_right_wall)


func _stage_trigger_x() -> Array:
	return STAGE_TRIGGER_X


func _screen_starts() -> Array:
	return SCREEN_STARTS


func _screen_rights() -> Array:
	return SCREEN_RIGHTS


func _update_screen_bounds(delta: float = 0.0) -> void:
	if current_stage < 1 or current_stage > SCREEN_STARTS.size():
		return
	var screen_index: int = int(current_stage) - 1
	var screen_left: float = SCREEN_STARTS[screen_index]
	var screen_right: float = SCREEN_RIGHTS[screen_index]
	var stage_clear: bool = bool(check_can_pass())
	var open_right: float = screen_right
	if current_stage < 4 and stage_clear:
		open_right = float(SCREEN_RIGHTS[screen_index + 1])
	elif current_stage == 4 and stage_clear:
		open_right = LAST_SCREEN_RIGHT
	if current_stage < 4 and stage_clear and _role != null:
		if float(_role.position.x) >= screen_right - CAMERA_UNLOCK_MARGIN:
			_camera_room = maxi(_camera_room, int(current_stage) + 1)
	_camera_room = clampi(maxi(_camera_room, int(current_stage)), 1, SCREEN_STARTS.size())
	var camera_target_left: float = float(SCREEN_STARTS[_camera_room - 1])
	if delta > 0.0:
		_camera_left_limit = move_toward(_camera_left_limit, camera_target_left, CAMERA_LIMIT_SPEED * delta)
	if is_instance_valid(_screen_left_wall):
		_screen_left_wall.position.x = _camera_left_limit - 5.0
		_screen_left_wall.disabled = false
	if is_instance_valid(_screen_right_wall):
		_screen_right_wall.position.x = open_right + 5.0
		_screen_right_wall.disabled = false
	if my_camera != null:
		my_camera.max_left = _camera_left_limit
		var camera_right: float = float(SCREEN_RIGHTS[_camera_room - 1])
		if current_stage == 4 and stage_clear:
			camera_right = LAST_SCREEN_RIGHT
		my_camera.max_right = maxf(camera_right, CAMERA_VIEW_WIDTH)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_screen_bounds(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = current_stage < 4 and check_can_pass()


func _on_create_control_timeout() -> void:
	if _role == null:
		return
	var role_x: float = float(_role.position.x)
	if current_stage == 0 and role_x >= STAGE_TRIGGER_X[0]:
		current_stage = 1
	elif current_stage < 4 and check_can_pass() and role_x >= STAGE_TRIGGER_X[current_stage]:
		current_stage += 1
	_update_screen_bounds()
	if current_stage >= 1 and current_stage <= 4:
		_request_stage_resource_preload(current_stage + 1)
		if check_can_create(current_stage):
			level_create_monster(current_stage)


func set_through() -> void:
	pass

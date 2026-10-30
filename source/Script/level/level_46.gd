extends BaseLevel

const TUTORIAL_BACKGROUND_ROOT := "res://Art/level/game_3_level/level_xinshou"
const SECOND_WAVE_TRIGGER_RECT := Rect2(1760.0, 0.0, 450.0, 500.0)
const BOSS_STAGE := 2
const BOSS_MONSTER_ID := 1460
const BOSS_SPAWN_POSITION := Vector2(1676.0, 305.0)
const BOSS_BACKGROUND_DIR := "bg30_frames"
const BOSS_ROOM_LEFT := 1200
const BOSS_ROOM_RIGHT := 2400
const TUTORIAL_BACKGROUND_PARTS := [
	{"dir": "bg30_frames", "position": Vector2(1800.0, 295.0), "fps": 30.0, "z": -1},
	{"dir": "bg12_frames", "position": Vector2(2237.0, 416.0), "fps": 30.0, "z": -1},
	{"dir": "bg13_frames", "position": Vector2(1294.0, 506.5), "fps": 30.0, "z": -1},
	{"dir": "bg14_frames", "position": Vector2(1365.5, 399.5), "fps": 30.0, "z": -1},
	{"dir": "bg15_frames", "position": Vector2(2156.0, 366.0), "fps": 30.0, "z": -1},
	{"dir": "bg16_frames", "position": Vector2(1439.0, 366.5), "fps": 30.0, "z": -1},
	{"dir": "bg17_frames", "position": Vector2(2289.0, 512.5), "fps": 30.0, "z": -1},
]

@onready var stop_left: CollisionShape2D = $wall/stop_left
@onready var stop_right: CollisionShape2D = $wall/stop_right

var _arena_locked := false
var _camera_locked_to_boss_room := false
var _second_wave_started := false

var _boss_spawned := false
var _boss_instance: BaseMonster = null
var _background_nodes: Array[Node] = []
var _boss_background: AnimatedSprite2D = null


func _ready() -> void:
	Global.set_current_level_name("通天教主")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/10_bg4.mp3")
	level_stage = 48
	is_two_scene = false
	Global.game_over = 1
	monster_group = {
		"stage_1": [],
		"stage_2": [BOSS_MONSTER_ID],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [],
		"stage_2": [BOSS_SPAWN_POSITION.x],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [],
		"stage_2": [BOSS_SPAWN_POSITION.y],
		"stage_3": [],
		"stage_4": [],
	}
	current_stage = 1
	super._ready()
	stop_left.disabled = true
	_setup_tutorial_background()


func _preload_level_resources() -> void:
	_stage_preload_requested[BOSS_STAGE] = true
	await Global.preload_level_monster_runtime_resources([BOSS_MONSTER_ID])


func _on_create_control_timeout() -> void:
	if _role == null:
		return
	if not _second_wave_started:
		if not _role_inside_second_wave_trigger():
			return
		_begin_second_wave()
	_spawn_boss_if_pending()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = false

	if not _second_wave_started and _role_inside_second_wave_trigger():
		_begin_second_wave()
		_spawn_boss_if_pending()

	_update_camera_limits()


func _role_inside_second_wave_trigger() -> bool:
	return _role != null and SECOND_WAVE_TRIGGER_RECT.has_point(_role.position)


func _begin_second_wave() -> void:
	if _second_wave_started:
		return
	_second_wave_started = true
	current_stage = BOSS_STAGE


func _spawn_boss_if_pending() -> void:
	if not _second_wave_started or not check_can_create(BOSS_STAGE):
		return
	var stage_key := "stage_%d" % BOSS_STAGE
	var pending_count: int = monster_group[stage_key].size()
	var pending_x: float = (
		float(monster_position_x[stage_key][0])
		if not monster_position_x[stage_key].is_empty()
		else BOSS_SPAWN_POSITION.x
	)
	var pending_y: float = (
		float(monster_position_y[stage_key][0])
		if not monster_position_y[stage_key].is_empty()
		else BOSS_SPAWN_POSITION.y
	)
	mr = null
	level_create_monster(BOSS_STAGE)
	if not is_instance_valid(mr):
		if monster_group[stage_key].size() < pending_count:
			monster_group[stage_key].push_front(BOSS_MONSTER_ID)
			monster_position_x[stage_key].push_front(pending_x)
			monster_position_y[stage_key].push_front(pending_y)
		push_error("通天教主创建失败，已恢复待刷队列")
		return

	_boss_spawned = true
	_boss_instance = mr
	stop_left.disabled = false
	stop_right.disabled = false
	_arena_locked = true
	_lock_camera_to_boss_room()
	if _boss_background != null:
		_boss_background.play(&"play")


func one_check_can_exit() -> bool:
	if not _boss_spawned:
		return false
	if not super.one_check_can_exit():
		return false
	return true


func _update_camera_limits() -> void:
	if my_camera == null:
		return
	if _arena_locked:
		_lock_camera_to_boss_room()
	else:
		my_camera.max_left = 0
		my_camera.max_right = BOSS_ROOM_RIGHT


func _lock_camera_to_boss_room() -> void:
	if my_camera == null:
		return
	if not _camera_locked_to_boss_room:
		my_camera.limit_smoothed = false
		my_camera.position_smoothing_enabled = false
		_camera_locked_to_boss_room = true
	my_camera.max_left = BOSS_ROOM_LEFT
	my_camera.max_right = BOSS_ROOM_RIGHT


func set_through() -> void:
	if not _arena_locked:
		return
	stop_left.disabled = false
	stop_right.disabled = false
	_lock_camera_to_boss_room()


func _setup_tutorial_background() -> void:
	if front == null:
		return

	for part in TUTORIAL_BACKGROUND_PARTS:
		var animation := AnimatedSprite2D.new()
		animation.name = str(part["dir"])
		animation.sprite_frames = (
			load(TUTORIAL_BACKGROUND_ROOT.path_join(str(part["dir"])).path_join("play_frames.tres")) as SpriteFrames
		)
		animation.animation = &"play"
		animation.centered = true
		animation.position = part["position"]
		animation.z_index = int(part["z"])
		front.add_child(animation)
		if str(part["dir"]) == BOSS_BACKGROUND_DIR:
			animation.frame = 0
			animation.pause()
			_boss_background = animation
		else:
			animation.play()
		_background_nodes.append(animation)


func _exit_tree() -> void:
	_boss_instance = null
	_boss_background = null
	for background_node in _background_nodes:
		if is_instance_valid(background_node):
			if background_node is AnimatedSprite2D:
				background_node.sprite_frames = null
			background_node.queue_free()
	_background_nodes.clear()

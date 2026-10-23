extends BaseLevel

@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_5: CollisionShape2D = $wall/stop5

var is_set = false


func _ready() -> void:
	Global.current_level = "牛魔谷"
	Global.add_bgm(self, "res://Music/level/bgm_1405.MP3")
	self.is_two_scene = true

	Global.game_over == 1
	super._ready()
	monster_group = {
		"stage_1": [],
		"stage_2": [1405],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1":
		[
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
			500,
			700,
			100,
			300,
		],
		"stage_2": [1700],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1":
		[
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
		],
		"stage_2": [300],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if current_stage >= 1:
		if check_can_pass() and current_stage < 2:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func set_through():
	if current_stage == 1:
		if check_can_pass():
			stop_1.disabled = true
	if current_stage == 2:
		if not is_set:
			my_camera.limit_smoothed = false
			my_camera.position_smoothing_enabled = false
			is_set = true
		my_camera.max_left = 1000
		stop_1.disabled = false
		stop_5.disabled = false
		my_camera.max_right = 1870

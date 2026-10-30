extends BaseLevel
@onready var stop_5: CollisionShape2D = $wall/stop5

@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3


func _ready() -> void:
	Global.set_current_level_name("无常巷")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/26_bg1.mp3")
	self.level_stage = 12
	super._ready()
	monster_group = {
		"stage_1": [26, 26, 26, 26],
		"stage_2": [26, 27, 28, 26, 27, 28, 26, 27, 28, 27, 27, 27, 27, 27, 28, 27, 27, 27, 27, 27, 28, 28],
		"stage_3": [27, 27, 28, 27, 27, 28, 27, 27, 28, 28, 28, 28, 28, 28, 28, 28, 27, 27, 27, 27, 28, 28],
		"stage_4": [30, 31],
	}
	monster_position_x = {
		"stage_1": [600, 600, 600, 600],
		"stage_2":
		[
			1250,
			1650,
			2150,
			1250,
			1650,
			2150,
			1250,
			1650,
			2150,
			1250,
			1650,
			2150,
			1250,
			1650,
			2150,
			1250,
			1650,
			2150,
			1250,
			1650,
			2150,
			1250,
			1650,
			2150,
			1250,
			1650,
			2150
		],
		"stage_3":
		[
			2500,
			2900,
			3300,
			2500,
			2900,
			3300,
			2500,
			2900,
			3300,
			2500,
			2900,
			3300,
			2500,
			2900,
			3300,
			2500,
			2900,
			3300,
			2500,
			2900,
			3300,
			2500,
			2900,
			3300,
			2500,
			2900,
			3300
		],
		"stage_4": [3650, 4500],
	}
	monster_position_y = {
		"stage_1": [360, 360, 360, 360],
		"stage_2":
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
			300
		],
		"stage_3":
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
			300
		],
		"stage_4": [300, 300],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if current_stage >= 1:
		if check_can_pass() and current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func set_through():
	if current_stage == 1:
		if check_can_pass():
			stop_1.disabled = true
	elif current_stage == 2:
		if check_can_pass():
			stop_2.disabled = true
	elif current_stage == 3:
		if check_can_pass():
			stop_3.disabled = true
	elif current_stage == 4:
		my_camera.max_left = 3500
		stop_5.disabled = false

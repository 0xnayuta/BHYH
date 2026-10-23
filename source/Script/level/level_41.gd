extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var stop_5: CollisionShape2D = $wall/stop5


func _ready() -> void:
	Global.current_level = "紫晶门"
	Global.add_bgm(self, "res://Music/level/floor1_3.mp3")
	self.level_stage = 23
	super._ready()
	monster_group = {
		"stage_1": [118, 118, 118, 118, 118, 118],
		"stage_2": [118, 118, 118, 118, 118, 118],
		"stage_3": [118, 118, 118, 118, 118, 118],
		"stage_4": [147],
	}
	monster_position_x = {
		"stage_1":
		[250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000],
		"stage_2":
		[
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150
		],
		"stage_3":
		[
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
		],
		"stage_4": [4450],
	}
	monster_position_y = {
		"stage_1":
		[
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475
		],
		"stage_2":
		[
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475
		],
		"stage_3":
		[
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475
		],
		"stage_4": [470],
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
		stop_3.disabled = false
		stop_5.disabled = false

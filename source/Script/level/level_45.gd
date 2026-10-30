extends BaseLevel

@onready var stop_left: CollisionShape2D = $wall/stop_left
@onready var stop_right: CollisionShape2D = $wall/stop_right
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3


func _ready() -> void:
	Global.set_current_level_name("绝境宫")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/10_bg4.mp3")
	self.level_stage = 47
	Global.game_over = 1
	super._ready()
	monster_group = {
		"stage_1": [118, 118, 118, 118, 118, 118],
		"stage_2": [118, 118, 118, 118, 118, 118],
		"stage_3": [118, 118, 118, 118, 118, 118],
		"stage_4": [215],
	}
	monster_position_x = {
		"stage_1": [350, 900, 450, 850, 550, 800],
		"stage_2": [1750, 2200, 1850, 2150, 1950, 2100],
		"stage_3": [2850, 3500, 3000, 3450, 3150, 3400],
		"stage_4": [4300],
	}
	monster_position_y = {
		"stage_1": [300, 300, 300, 300, 300, 300],
		"stage_2": [300, 300, 300, 300, 300, 300],
		"stage_3": [300, 300, 300, 300, 300, 300],
		"stage_4": [300],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = current_stage >= 1 and current_stage < 4 and check_can_pass()


func set_through() -> void:
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
		my_camera.max_right = 4700
		stop_3.disabled = false
		stop_left.disabled = false
		stop_right.disabled = false

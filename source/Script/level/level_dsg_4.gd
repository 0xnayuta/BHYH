extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var stop_5: CollisionShape2D = $wall/stop5


func _ready() -> void:
	Global.set_current_level_name("兜率宫4")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/12_bg7.mp3")
	self.level_stage = 34
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if (
		current_stage >= 1
		and role_information != null
		and is_instance_valid(role_information)
		and role_information.gogo != null
	):
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
		if my_camera != null and is_instance_valid(my_camera):
			my_camera.max_left = 3500
		stop_5.disabled = false

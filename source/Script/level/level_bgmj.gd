extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
var is_cc = false


func _ready() -> void:
	Global.set_current_level_name("白骨秘境")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/34_bg5.mp3")
	load("res://Scene/monster/monster_32.tscn")
	self.level_stage = 11
	super._ready()


func _physics_process(delta: float) -> void:
	if not is_cc:
		if _role.position.x >= 600:
			create_control.wait_time = 3
			create_control.start()
			is_cc = true
			role_information.gogo.visible = false
		else:
			create_control.wait_time = 3
			create_control.start()
	super._physics_process(delta)
	my_camera.max_right = 940
	if current_stage >= 1:
		if check_can_pass() and current_stage < 1:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false

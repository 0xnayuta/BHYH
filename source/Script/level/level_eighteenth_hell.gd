extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
var is_cc = false


func _ready() -> void:
	Global.current_level = ""
	Global.add_bgm(self, "res://Music/level/12_bg7.mp3")
	preload("res://Scene/monster/monster_42.tscn")
	self.level_stage = 11
	super._ready()
	monster_group = {
		"stage_1": [60],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [850, 850],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [200, 200],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}


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
	my_camera.max_right = 936
	if current_stage >= 1:
		if check_can_pass() and current_stage < 1:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false

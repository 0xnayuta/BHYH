extends BaseLevel
class_name LevelNMGHDGQ
@onready var stop_1: CollisionShape2D = $wall/stop1
var is_cc = false


func _ready() -> void:
	Global.add_bgm(self, "res://Music/level/10_bg4.mp3")
	load("res://Scene/monster/monster_141.tscn")
	load("res://Scene/monster/monster_22.tscn")
	load("res://Scene/monster/monster_23.tscn")
	load("res://Scene/monster/monster_24.tscn")
	load("res://Scene/monster/monster_25.tscn")
	Global.current_level = ""
	self.level_stage = 1
	super._ready()
	monster_group = {
		"stage_1": [22],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [850],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [200],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	if PlayerData.check_eq_zb("头衔", "xczg"):
		Global.change_scene("res://Scene/main_menu/main_menu.tscn")
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

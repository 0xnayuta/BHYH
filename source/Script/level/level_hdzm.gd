extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
var is_cc = false


func _return_to_current_map() -> void:
	var map_num = int(PlayerData.player_data.get("Map_num", 4))
	map_num = clamp(map_num, 1, 9)
	if map_num == 8 and PlayerData.player_data.get("Map_variant", "") == "Map_8_1":
		Global.change_scene("res://Scene/main_menu/map_8_1.tscn")
		return
	if map_num == 9 and PlayerData.player_data.get("Map_variant", "") == "Map_9_1":
		Global.change_scene("res://Scene/main_menu/map_9_1.tscn")
		return
	Global.change_scene("res://Scene/main_menu/map_" + str(map_num) + ".tscn")


func _ready() -> void:
	Global.current_level = ""
	Global.add_bgm(self, "res://Music/level/17_bg6.mp3")
	self.level_stage = 1
	super._ready()
	monster_group = {
		"stage_1": [132],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [500],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [450],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	if PlayerData.check_eq_zb("头衔", "xczg"):
		_return_to_current_map()
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
	my_camera.max_right = 1040
	my_camera.max_top = -550
	if current_stage >= 1:
		if check_can_pass() and current_stage < 1:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false

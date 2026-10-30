extends BaseLevel
class_name Level20
@onready var stop_1: CollisionShape2D = $wall/stop4
@onready var stop_2: CollisionShape2D = $wall/stop4
@onready var stop_3: CollisionShape2D = $wall/stop4
var color_list = ["00ffff"]

var can_pass = false


func _ready() -> void:
	Global.current_level = ""
	var role_id = PlayerData.player_data["Myself"]
	_role = Global.call_hero("role_" + str(role_id), hero, Vector2(4100, 340), false)
	self.modulate = Color(1, 1, 1, 1)
	front.modulate = Color(1, 1, 1, 1)
	floor_2.modulate = Color(1, 1, 1, 1)
	end.modulate = Color(1, 1, 1, 1)
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 3)
	tween.tween_property(end, "modulate", Color("00ffff"), 3)
	tween.tween_property(floor_2, "modulate", Color("00ffff"), 3)
	tween.tween_property(front, "modulate", Color("00ffff"), 3)
	current_stage = 4
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/9_bg3.mp3")
	self.level_stage = 1
	if _role != null:
		my_camera = Global.add_camera(_role, Vector2(0, 0), 1200)
		my_camera.max_left = 0
		my_camera.max_top = 0
		my_camera.max_bottom = 590
		my_camera.max_right = 4600
	if role_information == null:
		role_information = Global.add_role_information(self, Vector2(0, 0))
	RoleProp.roleprop.Hp = RoleProp.current_hp
	RoleProp.roleprop.Mp = RoleProp.current_mp
	monster_group = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [49],
	}
	monster_position_x = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [4550],
	}
	monster_position_y = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [250],
	}
	Global.last_level_path = "res://Scene/level/level_19.tscn"


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if current_stage >= 1:
		if check_can_pass() and current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func set_through():
	pass

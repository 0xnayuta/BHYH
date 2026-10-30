extends BaseLevel
var is_cc = false
var wang_wang: Monster144


func _ready() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/bgm_normal.mp3")
	Global.set_current_level_name("")
	self.level_stage = 0
	super._ready()
	monster_group = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [100],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [100],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	my_camera.max_right = 2800
	my_camera.max_top = -930
	role_information.gogo.visible = false

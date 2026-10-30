extends BaseLevel

@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_5: CollisionShape2D = $wall/stop5

var is_set = false


func _ready() -> void:
	Global.current_level = "陷仙门"
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/10_bg4.mp3")
	self.is_two_scene = true
	self.level_stage = 46
	Global.game_over = 1
	super._ready()
	monster_group = {
		"stage_1": [212],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [1250],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [300],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = false


func set_through() -> void:
	if current_stage == 1:
		if not is_set:
			my_camera.limit_smoothed = false
			my_camera.position_smoothing_enabled = false
			is_set = true
		my_camera.max_left = 0
		stop_1.disabled = true
		stop_5.disabled = false
		my_camera.max_right = 1400

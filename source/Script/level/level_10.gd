extends BaseLevel
class_name Level10

@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_5: CollisionShape2D = $wall/stop5

var is_set = false


func _ready() -> void:
	Global.current_level = "牛魔谷"
	Global.add_bgm(self, "res://Music/level/10_bg4.mp3")
	self.is_two_scene = true
	self.level_stage = 10
	Global.game_over = 1
	super._ready()
	monster_group = {
		"stage_1":
		[
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
			21,
		],
		"stage_2": [22],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1":
		[
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
			150,
			900,
		],
		"stage_2": [1700],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1":
		[
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
		],
		"stage_2": [300],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if current_stage >= 1:
		if check_can_pass() and current_stage < 2:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func set_through():
	if current_stage == 1:
		if check_can_pass():
			stop_1.disabled = true
	if current_stage == 2:
		if not is_set:
			my_camera.limit_smoothed = false
			my_camera.position_smoothing_enabled = false
			is_set = true
		my_camera.max_left = 1000
		stop_5.disabled = false
		my_camera.max_right = 1870


func one_check_can_exit():
	if not super.one_check_can_exit():
		return false
	return not _has_pending_boss_form()


func _has_pending_boss_form() -> bool:
	if monster == null:
		return false
	for child in monster.get_children():
		if child is Monster22 and child.death() and child.boss_2 == null:
			return true
		if child is Monster23 and child.death() and child.boss_3 == null:
			return true
	return false

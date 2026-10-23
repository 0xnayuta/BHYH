extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var stop_5: CollisionShape2D = $wall/stop5


func _ready() -> void:
	Global.current_level = "水帘洞"
	bgm_node = Global.add_bgm(self, "res://Music/level/1_music.mp3")
	self.level_stage = 2
	super._ready()
	monster_group = {
		"stage_1": [1, 1, 1, 1, 1, 1, 1, 1],
		"stage_2": [2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 2, 2],
		"stage_3": [2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3],
		"stage_4": [4],
	}
	monster_position_x = {
		"stage_1": [700, 700, 700, 700, 700, 700, 700, 700],
		"stage_2": [1200, 1200, 1500, 1500, 1200, 1500, 1400, 1400, 1400, 1600, 1600, 1600, 1400, 1800, 1800, 1800],
		"stage_3": [2000, 2175, 2350, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000],
		"stage_4": [4550],
	}
	monster_position_y = {
		"stage_1": [300, 300, 300, 300, 300, 300, 300, 300],
		"stage_2": [250, 250, 250, 250, 250, 250, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300],
		"stage_3": [200, 200, 200, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300, 300],
		"stage_4": [300],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if current_stage >= 1:
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
		stop_5.disabled = false
		my_camera.max_left = 3500
		stop_3.disabled = true

		if not bgm_changed_for_stage_4:
			bgm_changed_for_stage_4 = true

			if bgm_node != null:
				bgm_node.queue_free()
				bgm_node = null

			bgm_node = Global.add_bgm(self, "res://Music/level/2_music.mp3")


func _on_area_2d_body_entered(body: Node2D) -> void:
	Global.change_scene("res://Scene/level/level_sjg.tscn")

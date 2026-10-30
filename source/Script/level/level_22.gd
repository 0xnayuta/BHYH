extends BaseLevel
class_name Level22
@onready var floor: Node2D = $Floor
var is_set: bool
var call_count: int = 0


func _ready() -> void:
	Global.current_level = "九重天"
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/floor1_3.mp3")
	self.level_stage = 1
	super._ready()
	monster_group = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [700],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [-5100],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	add_stage()
	is_set = true
	my_camera.max_top = -5426
	my_camera.max_right = 940
	role_information.gogo.visible = false


func _physics_process(delta: float) -> void:
	call_count += 1
	if call_count % 360 == 0:
		for i in range(randi_range(1, 2)):
			Global.create_monster(73, monster, _role.position + Vector2(randi_range(-120, 102), randi_range(-125, 155)))
	if _role.position.y <= -4900:
		my_camera.max_bottom = -4835
	super._physics_process(delta)


func set_through():
	return


func _on_area_2d_body_entered(body: Node2D) -> void:
	return


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass


func add_stage():
	randomize()
	var stage_info = [
		{"Type": "an_" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), 190)},
		{"Type": "an_4" + str(randi_range(1, 5)), "Position": Vector2(randi_range(450, 595), -50)},
		{"Type": "an_4" + str(randi_range(1, 5)), "Position": Vector2(randi_range(305, 340), -290)},
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 440), -530)},
		{"Type": "an_3" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -770)},
		{"Type": "an_4" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -1010)},
		{"Type": "an_3" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -1250)},
		{"Type": "an_3" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -1490)},
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -1730)},
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(435, 595), -1970)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(305, 495), -2210)},
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(315, 375), -2450)},
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(365, 495), -2690)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(295, 395), -2930)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(465, 525), -3170)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(265, 495), -3410)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(265, 495), -3650)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(565, 695), -3890)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(565, 695), -4130)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(565, 695), -4370)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(565, 695), -4610)},
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(465, 595), -4810)},
	]
	var stage
	for i in stage_info:
		var ta = "an_" + str(randi_range(1, 5))
		stage = Global.add_stage(floor, "an_" + str(randi_range(1, 5)), i["Position"])
		if randi_range(0, 50) > 25:
			stage.scale.x = -1
		await get_tree().create_timer(randf_range(0.5, 1)).timeout

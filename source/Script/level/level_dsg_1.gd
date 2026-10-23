extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var stop_5: CollisionShape2D = $wall/stop5


func _ready() -> void:
	Global.current_level = "兜率宫1"
	Global.add_bgm(self, "res://Music/level/12_bg7.mp3")
	self.level_stage = 31
	monster_group = {
		"stage_1":
		[
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113
		],
		"stage_2":
		[
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113
		],
		"stage_3":
		[
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113,
			104,
			105,
			106,
			109,
			111,
			113
		],
		"stage_4": [107],
	}
	monster_position_x = {
		"stage_1":
		[
			150,
			300,
			450,
			600,
			750,
			900,
			150,
			300,
			450,
			600,
			750,
			900,
			150,
			300,
			450,
			600,
			750,
			900,
			150,
			300,
			450,
			600,
			750,
			900,
			150,
			300,
			450,
			600,
			750,
			900
		],
		"stage_2":
		[
			1300,
			1500,
			1650,
			1800,
			1950,
			2100,
			1300,
			1500,
			1650,
			1800,
			1950,
			2100,
			1300,
			1500,
			1650,
			1800,
			1950,
			2100,
			1300,
			1500,
			1650,
			1800,
			1950,
			2100,
			1300,
			1500,
			1650,
			1800,
			1950,
			2100
		],
		"stage_3":
		[
			2500,
			2650,
			2800,
			2950,
			3100,
			3250,
			2500,
			2650,
			2800,
			2950,
			3100,
			3250,
			2500,
			2650,
			2800,
			2950,
			3100,
			3250,
			2500,
			2650,
			2800,
			2950,
			3100,
			3250,
			2500,
			2650,
			2800,
			2950,
			3100,
			3250
		],
		"stage_4": [4500],
	}
	monster_position_y = {
		"stage_1":
		[
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420
		],
		"stage_2":
		[
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420
		],
		"stage_3":
		[
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420
		],
		"stage_4": [420],
	}
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if (
		current_stage >= 1
		and role_information != null
		and is_instance_valid(role_information)
		and role_information.gogo != null
	):
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
		if my_camera != null and is_instance_valid(my_camera):
			my_camera.max_left = 3500
		stop_5.disabled = false

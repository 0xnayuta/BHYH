extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var stop_5: CollisionShape2D = $wall/stop5

var normal_hp_multiplier: float = 3.0


func level_create_monster(stage: int):
	super.level_create_monster(stage)

	if self.mr and not self.mr.is_boss:
		call_deferred("_apply_hp_multiplier", self.mr)


func _apply_hp_multiplier(monster: BaseMonster):
	if monster and not monster.is_boss:
		monster.max_hp = int(monster.max_hp * normal_hp_multiplier)
		monster.hp = monster.max_hp


func _ready() -> void:
	load("res://Scene/monster/monster_119.tscn")
	load("res://Scene/monster/monster_118.tscn")
	load("res://Scene/monster/monster_120.tscn")
	load("res://Scene/monster/monster_122.tscn")
	Global.current_level = "蓬莱仙境"
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/34_bg5.mp3")
	self.level_stage = 44
	super._ready()
	monster_group = {
		"stage_1": [118, 119, 120, 118, 119, 120, 118, 119, 120, 118, 119, 122, 118, 119, 122, 118, 119, 122],
		"stage_2":
		[
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			122,
			118,
			119,
			122,
			118,
			119,
			122,
			118,
			119,
			122,
			118,
			119,
			122
		],
		"stage_3":
		[
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			120,
			118,
			119,
			122,
			118,
			119,
			122,
			118,
			119,
			122,
			118,
			119,
			122,
			118,
			119,
			122,
			118,
			119,
			122
		],
		"stage_4": [1410],
	}
	monster_position_x = {
		"stage_1": [400, 750, 320, 830, 450, 700, 150, 950, 200, 900, 250, 850, 180, 980, 220, 880, 280, 780],
		"stage_2":
		[
			1300,
			1650,
			1850,
			2100,
			1400,
			1750,
			1950,
			2200,
			1350,
			1600,
			1800,
			2050,
			1450,
			1700,
			1900,
			2150,
			1320,
			1680,
			1880,
			2180,
			1380,
			1620,
			1820,
			2080,
			1420,
			1720,
			1920,
			2220,
			1360,
			1660,
			1860,
			2120,
			1460
		],
		"stage_3":
		[
			2700,
			2950,
			3150,
			3350,
			2750,
			3000,
			3200,
			3400,
			2800,
			3050,
			3250,
			3450,
			2720,
			2980,
			3180,
			3380,
			2780,
			3030,
			3230,
			3430,
			2830,
			3080,
			3280,
			3480,
			2760,
			2960,
			3160,
			3360,
			2820,
			3020,
			3220,
			3420,
			2740,
			2990,
			3190,
			3390,
			2810,
			3060,
			3260,
			3460
		],
		"stage_4": [4300, 4400, 4500, 4600, 4700, 4450, 4550, 4650, 4350, 4480, 4580, 4680],
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
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
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
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420
		],
		"stage_4": [450, 450, 450, 450, 450, 450, 450, 450, 450, 450],
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
		my_camera.max_left = 3500
		stop_5.disabled = false

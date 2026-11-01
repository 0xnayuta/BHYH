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
	Global.set_current_level_name("蓬莱仙境")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/34_bg5.mp3")
	self.level_stage = 44
	super._ready()


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

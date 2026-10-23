extends BaseLevel

@export var boss_scene_id := 13101
@export var boss_spawn_y := 200

@onready var stop_1: CollisionShape2D = $wall/stop1

var is_cc := false


func _ready() -> void:
	Global.current_level = ""
	Global.add_bgm(self, "res://Music/level/bgm_normal.mp3")
	Global.load_level_monster_scene("res://Scene/monster/monster_%d.tscn" % boss_scene_id)
	level_stage = 1
	super._ready()
	monster_group = {
		"stage_1": [boss_scene_id],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [850],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [boss_spawn_y],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	if PlayerData.check_eq_zb("头衔", "xczg"):
		Global.change_scene("res://Scene/main_menu/main_menu.tscn")
	if not is_cc:
		create_control.stop()
		if _role.position.x >= 600:
			is_cc = true
			role_information.gogo.visible = false
			create_control.start(3.0)
	super._physics_process(delta)
	my_camera.max_right = 1000
	if current_stage >= 1:
		role_information.gogo.visible = check_can_pass() and current_stage < 1

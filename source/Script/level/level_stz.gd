extends BaseLevel

const PRINCE_IDS := [4401, 4402, 4403]

@onready var background_nezha: Sprite2D = $BackGround/front/BackgroundNezha
@onready var background_muzha: Sprite2D = $BackGround/front/BackgroundMuzha
@onready var background_jinzha: Sprite2D = $BackGround/front/BackgroundJinzha
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_5: CollisionShape2D = $wall/stop5

var selected_prince_id: int = 4401
var _endless_restart_pending := false
var _monster_count_multiplier := 1


func _ready() -> void:
	selected_prince_id = int(Global.selected_three_prince_id)
	if selected_prince_id not in PRINCE_IDS:
		selected_prince_id = 4401
	_monster_count_multiplier = clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	monster_group = {
		"stage_1": [selected_prince_id],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [500],
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
	Global.current_level = "挑战三太子"
	Global.game_over = 1
	level_stage = 44
	_set_selected_background()
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/music_emsd.mp3")
	super._ready()


func _set_selected_background() -> void:
	background_nezha.visible = selected_prince_id == 4401
	background_muzha.visible = selected_prince_id == 4402
	background_jinzha.visible = selected_prince_id == 4403


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = false


func _exit_tree() -> void:
	Global.three_prince_endless_mode = false


func _restart_endless_round() -> void:
	if not is_inside_tree() or not Global.three_prince_endless_mode:
		_endless_restart_pending = false
		return
	for _index in range(_monster_count_multiplier):
		monster_group["stage_1"].append(selected_prince_id)
		monster_position_x["stage_1"].append(500)
		monster_position_y["stage_1"].append(300)
	can_exit = false
	exit.visible = false
	exit_2.disabled = true
	_endless_restart_pending = false


func set_through() -> void:
	if my_camera != null:
		my_camera.max_left = 0
		my_camera.max_right = 1200
	stop_5.disabled = false
	stop_1.disabled = one_check_can_exit()


func one_check_can_exit() -> bool:
	if not monster_group.has("stage_1") or monster_group["stage_1"].size() > 0:
		return false
	if _get_alive_stage_monster_count() != 0:
		return false
	if Global.three_prince_endless_mode:
		if not _endless_restart_pending:
			_endless_restart_pending = true
			call_deferred("_restart_endless_round")
		return false
	return true

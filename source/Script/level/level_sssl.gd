extends BaseLevel

@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_5: CollisionShape2D = $wall/stop5

const LEVEL_RIGHT := 4700
const END_WALL_THICKNESS := 600.0
const SSSL_BOSS_IDS := [150, 151, 152, 153]
const ENDLESS_BOSS_POSITION := Vector2(780, 340)
var _preloaded_sssl_stages: Dictionary = {}
var _sssl_preloading_stage: int = 0
var _stage_walls: Array[CollisionShape2D] = []
var _endless_boss_index := 0
var _endless_restart_pending := false


func _ready() -> void:
	_create_stage_walls()
	if stop_2 != null:
		stop_2.position.x = LEVEL_RIGHT + END_WALL_THICKNESS * 0.5
		var end_wall_shape := RectangleShape2D.new()
		end_wall_shape.size = Vector2(END_WALL_THICKNESS, 1786)
		stop_2.shape = end_wall_shape
		stop_2.disabled = false
	if Global.sss_lendless_mode:
		monster_group = {"stage_1": [SSSL_BOSS_IDS[0]], "stage_2": [], "stage_3": [], "stage_4": []}
		monster_position_x = {"stage_1": [ENDLESS_BOSS_POSITION.x], "stage_2": [], "stage_3": [], "stage_4": []}
		monster_position_y = {"stage_1": [ENDLESS_BOSS_POSITION.y], "stage_2": [], "stage_3": [], "stage_4": []}
	else:
		monster_group = {
			"stage_1": [150],
			"stage_2": [151],
			"stage_3": [152],
			"stage_4": [153],
		}
		monster_position_x = {
			"stage_1": [780],
			"stage_2": [2200],
			"stage_3": [3600],
			"stage_4": [4400],
		}
		monster_position_y = {
			"stage_1": [340],
			"stage_2": [340],
			"stage_3": [340],
			"stage_4": [340],
		}
	Global.current_level = "神兽森林"
	Global.add_bgm(self, "res://Music/level/music_emsd.mp3")
	self.level_stage = 45
	super._ready()


func _create_stage_walls() -> void:
	var wall_node := get_node_or_null("wall") as StaticBody2D
	if wall_node == null:
		return
	for wall_index in range(2):
		var stage_wall := CollisionShape2D.new()
		var wall_shape := RectangleShape2D.new()
		wall_shape.size = Vector2(17, 1786)
		stage_wall.name = "stage_wall_" + str(wall_index + 2)
		stage_wall.position = Vector2(2300 if wall_index == 0 else 3600, -406)
		stage_wall.shape = wall_shape
		stage_wall.disabled = true
		wall_node.add_child(stage_wall)
		_stage_walls.append(stage_wall)


func _exit_tree() -> void:
	Global.sss_lendless_mode = false


func _update_stage_walls() -> void:
	for wall_index in range(_stage_walls.size()):
		var stage_wall := _stage_walls[wall_index]
		if is_instance_valid(stage_wall):
			stage_wall.disabled = current_stage != wall_index + 2 or check_can_pass()


func _preload_level_resources() -> void:
	if Global.sss_lendless_mode:
		await Global.preload_level_monster_scenes(SSSL_BOSS_IDS)
		for stage in range(1, 5):
			_preload_sssl_boss_body_frames(SSSL_BOSS_IDS[stage - 1])
			_preloaded_sssl_stages[stage] = true
	else:
		await Global.preload_level_monster_scenes([150])
		_preload_sssl_boss_body_frames(150)
		_preloaded_sssl_stages[1] = true


func _preload_sssl_boss_body_frames(_monster_id: int) -> void:
	# Boss 主体动画已迁移到标准 SpriteFrames.tres，由各 Boss 脚本自行预热；
	# 旧的逐帧 PNG 路径已不存在，不能再在关卡加载阶段扫描。
	pass


func _preload_sssl_stage(stage: int) -> void:
	if stage < 1 or stage > 4 or _preloaded_sssl_stages.has(stage):
		return
	if _sssl_preloading_stage == stage:
		return
	_sssl_preloading_stage = stage
	var monster_id := 149 + stage
	await Global.preload_level_monster_scenes([monster_id])
	_preload_sssl_boss_body_frames(monster_id)
	_preloaded_sssl_stages[stage] = true
	if _sssl_preloading_stage == stage:
		_sssl_preloading_stage = 0


func _is_sssl_stage_ready(stage: int) -> bool:
	if stage < 1 or stage > 4:
		return false
	if _preloaded_sssl_stages.has(stage):
		return true
	if _sssl_preloading_stage != stage:
		call_deferred("_preload_sssl_stage", stage)
	return false


func level_create_monster(stage):
	super.level_create_monster(stage)
	if mr != null and is_instance_valid(mr) and mr is BaseMonster:
		mr.set_meta("sssl_special_boss", true)
		mr.set_meta("sssl_stage", stage)
		if stage > 1:
			Global.add_message_show(self, str(mr.my_mr_name) + " 出现", 1.2, Vector2(470, 300))


func _on_create_control_timeout() -> void:
	if _role == null:
		return
	if Global.sss_lendless_mode:
		current_stage = 1
		_set_endless_camera_limits()
		if not _preloaded_sssl_stages.has(_endless_boss_index + 1):
			return
		if check_can_create(1):
			level_create_monster(1)
		return
	if current_stage == 0:
		current_stage = 1
	elif current_stage == 1 and _role.position.x >= 1600 and check_can_pass():
		current_stage = 2
	elif current_stage == 2 and _role.position.x >= 2700 and check_can_pass():
		current_stage = 3
	elif current_stage == 3 and _role.position.x >= 4000 and check_can_pass():
		current_stage = 4
	_update_stage_walls()
	if current_stage >= 1 and current_stage <= 4 and not _is_sssl_stage_ready(current_stage):
		return
	if current_stage >= 1 and current_stage <= 4 and check_can_create(current_stage):
		level_create_monster(current_stage)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if Global.sss_lendless_mode:
		_set_endless_camera_limits()
	check_monster_death()
	_update_stage_walls()
	if _role != null:
		RoleProp.role_pos_x = _role.position.x
		RoleProp.role_pos_y = _role.position.y
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = current_stage >= 1 and current_stage < 4 and check_can_pass()


func set_through():
	if Global.sss_lendless_mode:
		_set_endless_camera_limits()
		stop_1.disabled = true
		stop_5.disabled = true
		return
	if current_stage == 1:
		if check_can_pass():
			stop_1.disabled = true
	elif current_stage == 2:
		if check_can_pass():
			_update_stage_walls()
	elif current_stage == 3:
		if check_can_pass():
			_update_stage_walls()
	elif current_stage == 4:
		if my_camera != null:
			my_camera.max_left = 3500
			my_camera.max_right = LEVEL_RIGHT
		stop_5.disabled = false


func check_can_pass():
	if Global.sss_lendless_mode:
		return monster_group.get("stage_1", []).is_empty() and _get_alive_stage_monster_count() == 0
	if current_stage < 1 or current_stage > 4:
		return false
	var stage_key := "stage_%d" % current_stage
	if not monster_group.has(stage_key) or monster_group[stage_key].size() > 0:
		return false
	return _get_alive_stage_monster_count() == 0


func check_can_exit():
	if Global.sss_lendless_mode:
		return false
	return current_stage == 4 and check_can_pass()


func one_check_can_exit():
	if Global.sss_lendless_mode:
		if check_can_pass() and not _endless_restart_pending:
			_endless_restart_pending = true
			call_deferred("_queue_next_endless_boss")
		return false
	return check_can_exit()


func _set_endless_camera_limits() -> void:
	if my_camera == null:
		return
	my_camera.limit_smoothed = false
	my_camera.position_smoothing_enabled = false
	my_camera.max_left = 0
	my_camera.max_right = 1200


func _queue_next_endless_boss() -> void:
	if not is_inside_tree() or not Global.sss_lendless_mode:
		_endless_restart_pending = false
		return
	await get_tree().process_frame
	if not is_inside_tree() or not Global.sss_lendless_mode:
		_endless_restart_pending = false
		return
	_endless_boss_index = (_endless_boss_index + 1) % SSSL_BOSS_IDS.size()
	monster_group["stage_1"].clear()
	monster_position_x["stage_1"].clear()
	monster_position_y["stage_1"].clear()
	var spawn_count := clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	for _index in range(spawn_count):
		monster_group["stage_1"].append(SSSL_BOSS_IDS[_endless_boss_index])
		monster_position_x["stage_1"].append(ENDLESS_BOSS_POSITION.x)
		monster_position_y["stage_1"].append(ENDLESS_BOSS_POSITION.y)
	_endless_restart_pending = false

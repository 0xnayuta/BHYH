extends BaseLevel

var platforms = {}


func _ready() -> void:
	Global.set_current_level_name("仙幻岛")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/bgm_normal.mp3")
	load("res://Scene/monster/monster_1406.tscn")

	self.level_stage = 41

	super._ready()

	_init_platforms()

	monster_group = {
		"stage_1": [124, 124, 124, 124, 124, 124, 124, 124],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [1406],
	}
	monster_position_x = {
		"stage_1": [250, 1000, 250, 1000, 250, 1000, 250, 1000],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [850],
	}
	monster_position_y = {
		"stage_1": [300, 500, 300, 500, 300, 500, 300, 500],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [200],
	}

	print("关卡36初始化：总阶段数 =", level_stage)


func _init_platforms():
	"初始化所有平台"

	_add_platform("stage0", Vector2(-50, 450), Vector2(1300, 450), 100)
	_add_platform("stage1", Vector2(200, 350), Vector2(1000, 350), 120)
	_add_platform("stage2", Vector2(1400, 250), Vector2(-150, 250), 100)

	print("平台初始化完成")


func _add_platform(name: String, start_pos: Vector2, end_pos: Vector2, speed: int):
	"添加一个新平台，支持二维移动"
	var platform_node = get_node_or_null(name)
	if not platform_node:
		print("警告：找不到平台节点", name)
		return

	platform_node.position = start_pos

	platforms[name] = {
		"node": platform_node,
		"speed": speed,
		"start_pos": start_pos,
		"end_pos": end_pos,
		"direction_x": 1 if start_pos.x <= end_pos.x else -1,
		"direction_y": 1 if start_pos.y <= end_pos.y else -1,
		"player": null,
		"player_on": false
	}

	var area2d = platform_node.get_node("Area2D")
	if area2d:
		area2d.body_entered.connect(_on_platform_body_entered.bind(name))
		area2d.body_exited.connect(_on_platform_body_exited.bind(name))

	print("添加平台:", name, " 速度:", speed)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	_update_platforms(delta)

	my_camera.max_right = 1200

	if current_stage >= 1:
		if check_can_pass() and current_stage < level_stage:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false

		handle_stage_transition()

	if _role and not _role.is_death and _role.position.y > 800:
		_role.effect_reducehp(999999, "real")


func handle_stage_transition():
	"处理阶段切换 - 参考Level31的模式"

	if check_can_pass():
		if current_stage < level_stage:
			print("阶段", current_stage, "完成，进入阶段", current_stage + 1)
			current_stage += 1

			create_control.wait_time = 1.0
			create_control.start()

			if current_stage == 4:
				print("========== 进入BOSS战阶段！ ==========")
				role_information.gogo.visible = false
			elif current_stage < level_stage:
				role_information.gogo.visible = true


func _update_platforms(delta: float):
	"更新所有平台移动"
	for platform_name in platforms:
		var platform_data = platforms[platform_name]
		_update_single_platform(platform_name, platform_data, delta)


func _update_single_platform(platform_name: String, platform_data: Dictionary, delta: float):
	"更新单个平台 - 支持二维移动"
	var platform = platform_data["node"]
	if not platform:
		return

	var old_position = platform.position

	var move_distance = platform_data["speed"] * delta

	var move_x = platform_data["direction_x"] * move_distance
	platform.position.x += move_x

	if platform_data["direction_x"] > 0:
		if platform.position.x >= max(platform_data["start_pos"].x, platform_data["end_pos"].x):
			platform_data["direction_x"] = -1
			platform.position.x = max(platform_data["start_pos"].x, platform_data["end_pos"].x)
	else:
		if platform.position.x <= min(platform_data["start_pos"].x, platform_data["end_pos"].x):
			platform_data["direction_x"] = 1
			platform.position.x = min(platform_data["start_pos"].x, platform_data["end_pos"].x)

	var move_y = platform_data["direction_y"] * move_distance
	platform.position.y += move_y

	if platform_data["direction_y"] > 0:
		if platform.position.y >= max(platform_data["start_pos"].y, platform_data["end_pos"].y):
			platform_data["direction_y"] = -1
			platform.position.y = max(platform_data["start_pos"].y, platform_data["end_pos"].y)
	else:
		if platform.position.y <= min(platform_data["start_pos"].y, platform_data["end_pos"].y):
			platform_data["direction_y"] = 1
			platform.position.y = min(platform_data["start_pos"].y, platform_data["end_pos"].y)

	var position_delta = platform.position - old_position

	if platform_data["player_on"] and platform_data["player"] and is_instance_valid(platform_data["player"]):
		platform_data["player"].position += position_delta


func _on_platform_body_entered(body: Node2D, platform_name: String):
	"玩家登上平台"
	if body is BaseHero and platform_name in platforms:
		platforms[platform_name]["player_on"] = true
		platforms[platform_name]["player"] = body
		print("玩家登上平台:", platform_name)


func _on_platform_body_exited(body: Node2D, platform_name: String):
	"玩家离开平台"
	if platform_name in platforms and body == platforms[platform_name]["player"]:
		platforms[platform_name]["player_on"] = false
		platforms[platform_name]["player"] = null
		print("玩家离开平台:", platform_name)


func set_platform_speed(platform_name: String, speed: int):
	"设置平台速度"
	if platform_name in platforms:
		platforms[platform_name]["speed"] = speed
		print("设置平台", platform_name, "速度为:", speed)


func reset_platform(platform_name: String):
	"重置平台位置"
	if platform_name in platforms:
		var data = platforms[platform_name]
		data["node"].position = data["start_pos"]
		data["direction_x"] = 1 if data["start_pos"].x <= data["end_pos"].x else -1
		data["direction_y"] = 1 if data["start_pos"].y <= data["end_pos"].y else -1
		print("重置平台:", platform_name)

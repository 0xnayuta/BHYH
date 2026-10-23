extends BaseLevel

var platforms = {}
var platform_target_positions = {}

var stage5_timer = 0.0
var stage5_cooldown = 0.0
var stage5_active = false
var jjc01_original_pos: Vector2 = Vector2.ZERO
var jjc02_original_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	Global.current_level = "仙树岛"
	Global.add_bgm(self, "res://Music/level/bgm_normal.mp3")
	load("res://Scene/monster/monster_1406.tscn")

	self.level_stage = 42

	super._ready()

	_init_platforms()

	monster_group = {
		"stage_1":
		[
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123,
			124,
			123
		],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [1407],
	}
	monster_position_x = {
		"stage_1":
		[
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000,
			250,
			1000
		],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [850],
	}
	monster_position_y = {
		"stage_1":
		[300, 500, 300, 500, 300, 500, 300, 500, 300, 500, 300, 500, 0, 200, 0, 200, 0, 200, 0, 200, 0, 200, 0, 200],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [100],
	}

	print("关卡37初始化：总阶段数 =", level_stage)


func _init_platforms():
	"初始化所有平台"

	_add_platform("stage0", "down")

	_add_platform("stage1", "horizontal", 1)

	_add_platform("stage2", "static")

	_add_platform("stage3", "horizontal", 2)

	_add_platform("stage4", "down")

	_add_platform("stage5", "special")

	print("平台初始化完成")

	_init_stage5_mechanism()


func _add_platform(name: String, type: String, horizontal_init_direction: int = 0):
	"添加一个新平台，根据类型设置行为"
	var platform_node = get_node_or_null(name)
	if not platform_node:
		print("警告：找不到平台节点", name)
		return

	var original_pos = platform_node.position

	platforms[name] = {
		"node": platform_node,
		"type": type,
		"original_pos": original_pos,
		"player_on": false,
		"player": null,
		"horizontal_direction": 0,
		"horizontal_init_direction": horizontal_init_direction,
		"move_speed": 60,
		"down_speed": 40,
		"return_speed": 30,
		"min_x": 0,
		"max_x": 942
	}

	platform_target_positions[name] = original_pos

	var area2d = platform_node.get_node("Area2D")
	if area2d:
		area2d.body_entered.connect(_on_platform_body_entered.bind(name))
		area2d.body_exited.connect(_on_platform_body_exited.bind(name))

	print("添加平台:", name, " 类型:", type, " 初始方向:", horizontal_init_direction)


func _init_stage5_mechanism():
	"初始化stage5的机关机制"

	var stage5_node = get_node_or_null("stage5")
	if not stage5_node:
		print("警告：找不到stage5节点")
		return

	var jjc01 = stage5_node.get_node_or_null("StaticBody2D/jjc01")
	var jjc02 = stage5_node.get_node_or_null("StaticBody2D/jjc02")

	if jjc01:
		jjc01_original_pos = jjc01.position

		jjc01.position.y = -600
		print("jjc01原始位置:", jjc01_original_pos, " 移动到:", jjc01.position)

	if jjc02:
		jjc02_original_pos = jjc02.position

		jjc02.position.y = -600
		print("jjc02原始位置:", jjc02_original_pos, " 移动到:", jjc02.position)

	print("stage5机关初始化完成")


func _set_stage5_collision_state(active: bool):
	"设置stage5碰撞体状态"
	var stage5_node = get_node_or_null("stage5")
	if not stage5_node:
		return

	var jjc01 = stage5_node.get_node_or_null("StaticBody2D/jjc01")
	var jjc02 = stage5_node.get_node_or_null("StaticBody2D/jjc02")

	if active:
		if jjc01:
			jjc01.position = jjc01_original_pos
		if jjc02:
			jjc02.position = jjc02_original_pos
		stage5_active = true
		print("stage5机关已激活，jjc01和jjc02回到原位")
	else:
		if jjc01:
			jjc01.position.y = -600
		if jjc02:
			jjc02.position.y = -600
		stage5_active = false
		print("stage5机关已关闭，jjc01和jjc02移动到屏幕外")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	_update_platforms(delta)

	my_camera.max_right = 942
	my_camera.max_top = -452

	_update_stage5_timers(delta)

	if current_stage >= 1:
		if check_can_pass() and current_stage < level_stage:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false

		handle_stage_transition()

	if _role and not _role.is_death and _role.position.y > 800:
		_role.effect_reducehp(999999, "real")


func _update_stage5_timers(delta: float):
	"更新stage5的计时器和冷却计时器"

	if stage5_timer > 0:
		stage5_timer -= delta
		if stage5_timer <= 0:
			stage5_timer = 0

			_set_stage5_collision_state(false)
			stage5_cooldown = 20.0
			print("stage5机关效果结束，进入20秒冷却")

	if stage5_cooldown > 0:
		stage5_cooldown -= delta
		if stage5_cooldown <= 0:
			stage5_cooldown = 0
			print("stage5冷却结束，可以再次触发")


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
	"更新单个平台 - 根据类型进行不同移动"
	var platform = platform_data["node"]
	if not platform:
		return

	if platform_name == "stage5" and stage5_cooldown > 0:
		return

	var old_position = platform.position
	var new_position = old_position

	if platform_data["type"] == "down":
		if platform_data["player_on"]:
			var target_pos = platform_data["original_pos"] + Vector2(0, 100)
			new_position = old_position.move_toward(target_pos, platform_data["down_speed"] * delta)
		else:
			new_position = old_position.move_toward(
				platform_data["original_pos"], platform_data["return_speed"] * delta
			)

	elif platform_data["type"] == "horizontal":
		if platform_data["player_on"]:
			var current_direction = platform_data["horizontal_direction"]

			if current_direction == 0:
				if platform_data["horizontal_init_direction"] == 1:
					current_direction = -1
				elif platform_data["horizontal_init_direction"] == 2:
					current_direction = 1
				platform_data["horizontal_direction"] = current_direction

			var move_distance = platform_data["move_speed"] * delta * current_direction
			new_position.x = old_position.x + move_distance

			if new_position.x < platform_data["min_x"]:
				new_position.x = platform_data["min_x"]
				platform_data["horizontal_direction"] = 1
			elif new_position.x > platform_data["max_x"]:
				new_position.x = platform_data["max_x"]
				platform_data["horizontal_direction"] = -1

		else:
			new_position = old_position.move_toward(
				platform_data["original_pos"], platform_data["return_speed"] * delta
			)

			platform_data["horizontal_direction"] = 0

	elif platform_data["type"] == "special":
		if platform_data["player_on"] and not stage5_active and stage5_cooldown <= 0:
			_set_stage5_collision_state(true)
			stage5_timer = 30.0
			print("stage5机关激活，持续30秒")

	platform.position = new_position

	if platform_data["player_on"] and platform_data["player"] and is_instance_valid(platform_data["player"]):
		var move_delta = new_position - old_position
		platform_data["player"].position += move_delta


func _on_platform_body_entered(body: Node2D, platform_name: String):
	"玩家登上平台"
	if body is BaseHero and platform_name in platforms:
		var platform_data = platforms[platform_name]
		platform_data["player_on"] = true
		platform_data["player"] = body

		print("玩家登上平台:", platform_name, " 类型:", platform_data["type"])

		if platform_name == "stage5" and not stage5_active and stage5_cooldown <= 0:
			print("注意：站在stage5上会触发机关！")


func _on_platform_body_exited(body: Node2D, platform_name: String):
	"玩家离开平台"
	if platform_name in platforms:
		var platform_data = platforms[platform_name]
		platform_data["player_on"] = false
		platform_data["player"] = null

		print("玩家离开平台:", platform_name)


func reset_platform(platform_name: String):
	"重置平台位置"
	if platform_name in platforms:
		var data = platforms[platform_name]
		data["node"].position = data["original_pos"]
		data["horizontal_direction"] = 0

		if platform_name == "stage5":
			_set_stage5_collision_state(false)
			stage5_timer = 0
			stage5_cooldown = 0

		print("重置平台:", platform_name)

extends BaseLevel

const XYDSTAGE_SCENE = preload("res://Scene/level/xyd_stage.tscn")

var stage_nodes: Array[StageNode] = []
@onready var yf_list_node = $CanvasLayer/ActivityButton/YFList

var stage1_monster_killed_count: int = 0
var assigned_image_indices: Array[int] = []
var pending_note_indices: Array[int] = []
var max_note_stage_gap: int = 2

var player_on_stage: Dictionary = {}
var current_stage_indices: Array = []

var puzzle_solved: bool = false
var current_puzzle_step: int = 0
var image_sequence: Array[int] = []
var puzzle_in_progress: bool = false
var has_shown_start_hint: bool = false


func _ready() -> void:
	load("res://Scene/monster/monster_123.tscn")
	load("res://Scene/monster/monster_1404.tscn")
	Global.current_level = "仙音岛"
	Global.add_bgm(self, "res://Music/level/floor1_3.mp3")
	self.level_stage = 40
	self.is_two_scene = true

	super._ready()
	create_xyd_stages()
	connect_stage_signals()
	init_puzzle()

	monster_group = {
		"stage_1": [123, 123, 123, 123, 123, 123, 123],
		"stage_2": [1404],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1":
		[250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000],
		"stage_2": [1048],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1":
		[
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300,
			300
		],
		"stage_2": [400],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	my_camera.max_right = 1144
	check_stage1_monster_kills()
	update_puzzle_hint()

	if current_stage >= 1:
		if check_can_pass() and current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false

	if _role and not _role.is_death and _role.position.y > 700:
		_role.effect_reducehp(999999, "real")


func create_xyd_stages():
	var stage_data = [
		{"pos": Vector2(0, 0), "texture": "res://Art/level/game_3_level/level_35/s1.png"},
		{"pos": Vector2(160, 0), "texture": "res://Art/level/game_3_level/level_35/s2.png"},
		{"pos": Vector2(320, 0), "texture": "res://Art/level/game_3_level/level_35/s3.png"},
		{"pos": Vector2(480, 0), "texture": "res://Art/level/game_3_level/level_35/s4.png"},
		{"pos": Vector2(640, 0), "texture": "res://Art/level/game_3_level/level_35/s5.png"},
		{"pos": Vector2(800, 0), "texture": "res://Art/level/game_3_level/level_35/s6.png"},
		{"pos": Vector2(960, 0), "texture": "res://Art/level/game_3_level/level_35/s7.png"},
	]

	var stage_parent = $Stage
	if not stage_parent:
		stage_parent = Node2D.new()
		stage_parent.name = "Stage"
		add_child(stage_parent)

	for i in range(7):
		var stage_index = i + 1
		var data = stage_data[i]
		var stage_instance: StageNode = XYDSTAGE_SCENE.instantiate()
		stage_instance.stage_index = stage_index
		stage_instance.position = data["pos"]
		stage_instance.name = "Stage_%d" % stage_index

		var texture = load(data["texture"])
		if texture:
			stage_instance.sprite_texture = texture

		stage_parent.add_child(stage_instance)
		stage_nodes.append(stage_instance)


func connect_stage_signals():
	for stage in stage_nodes:
		if stage:
			stage.player_entered.connect(_on_stage_player_entered)
			stage.player_exited.connect(_on_stage_player_exited)


func _on_stage_player_entered(stage_index: int, body: Node2D):
	if not stage_index in current_stage_indices:
		current_stage_indices.append(stage_index)

	player_on_stage[body] = stage_index

	var stage_node = get_stage_node_by_index(stage_index)
	if stage_node:
		stage_node.set_feedback_color(Color(0.8, 1.0, 0.8, 1.0), 0.3)

	handle_puzzle_stage(stage_index)


func _on_stage_player_exited(stage_index: int, body: Node2D):
	var idx = current_stage_indices.find(stage_index)
	if idx != -1:
		current_stage_indices.remove_at(idx)

	if player_on_stage.get(body) == stage_index:
		player_on_stage.erase(body)

	var stage_node = get_stage_node_by_index(stage_index)
	if stage_node:
		stage_node.set_feedback_color(Color(1.0, 0.8, 0.8, 1.0), 0.3)


func init_puzzle():
	puzzle_solved = false
	current_puzzle_step = 0
	image_sequence = []
	puzzle_in_progress = false

	has_shown_start_hint = false


func handle_puzzle_stage(stage_index: int):
	if puzzle_solved or stage1_monster_killed_count < 7:
		return

	if not puzzle_in_progress:
		start_puzzle()

	if stage_index == image_sequence[current_puzzle_step]:
		on_correct_stage(stage_index)
	else:
		on_wrong_stage()


func start_puzzle():
	if puzzle_in_progress:
		return

	image_sequence = yf_list_node.get_current_image_sequence()
	yf_list_node.reset_all_opacities()
	current_puzzle_step = 0
	puzzle_in_progress = true

	if not has_shown_start_hint:
		show_puzzle_hint("请按照音符显示的顺序踩踏舞台", 1.0)

		has_shown_start_hint = true


func on_correct_stage(stage_index: int):
	var stage_node = get_stage_node_by_index(stage_index)
	if stage_node:
		stage_node.set_puzzle_correct()

	yf_list_node.set_node_opacity(current_puzzle_step + 1, 0.3)
	current_puzzle_step += 1

	if current_puzzle_step >= 7:
		on_puzzle_completed()


func on_wrong_stage():
	if current_stage_indices.size() > 0:
		var wrong_stage_index = current_stage_indices[-1]
		var stage_node = get_stage_node_by_index(wrong_stage_index)
		if stage_node:
			stage_node.set_puzzle_wrong()

	current_puzzle_step = 0
	puzzle_in_progress = false
	yf_list_node.reset_all_opacities()
	show_puzzle_hint("踩错了！请重新开始", 1.0)


func on_puzzle_completed():
	puzzle_solved = true
	puzzle_in_progress = false
	show_puzzle_hint("解密完成！Boss出现", 1.0)
	current_stage = 2
	call_deferred("spawn_final_boss")


func spawn_final_boss():
	if monster_group["stage_2"].size() > 0:
		level_create_monster(2)


func show_puzzle_hint(text: String, duration: float = 2.0):
	Global.add_message_show(self, text, duration, Vector2(470, 300))


func update_puzzle_hint():
	pass


func get_stage_node_by_index(index: int) -> StageNode:
	if index >= 1 and index <= stage_nodes.size():
		return stage_nodes[index - 1]
	return null


func check_stage1_monster_kills():
	var current_monster_count = _get_alive_stage_monster_count()
	var original_monster_count = 7
	var killed_count = original_monster_count - (monster_group["stage_1"].size() + current_monster_count)
	killed_count = clamp(killed_count, 0, 7)

	if killed_count > stage1_monster_killed_count:
		var newly_killed = killed_count - stage1_monster_killed_count
		for i in range(newly_killed):
			var node_num = stage1_monster_killed_count + 1
			var image_num = get_unique_random_image_num()
			yf_list_node.assign_image_to_rect(node_num, image_num)
			stage1_monster_killed_count += 1

			if stage1_monster_killed_count >= 7:
				show_puzzle_hint("7个音符已集齐！请按照音符顺序踩踏舞台", 1.0)
				break


func get_unique_random_image_num() -> int:
	if pending_note_indices.size() == 0:
		pending_note_indices = build_reachable_note_sequence()
		assigned_image_indices.clear()

	var selected_num = pending_note_indices.pop_front()
	assigned_image_indices.append(selected_num)
	return selected_num


func build_reachable_note_sequence() -> Array[int]:
	var start_nums: Array[int] = [1, 2, 3, 4, 5, 6, 7]
	start_nums.shuffle()

	for start_num in start_nums:
		var path: Array[int] = [start_num]
		var available_nums: Array[int] = []
		for num in range(1, 8):
			if num != start_num:
				available_nums.append(num)
		if fill_reachable_note_sequence(path, available_nums):
			return path

	return [1, 2, 3, 4, 5, 6, 7]


func fill_reachable_note_sequence(path: Array[int], available_nums: Array[int]) -> bool:
	if available_nums.size() == 0:
		return true

	var last_num = path[-1]
	var candidates: Array[int] = []
	for num in available_nums:
		if abs(num - last_num) <= max_note_stage_gap:
			candidates.append(num)
	candidates.shuffle()

	for candidate in candidates:
		path.append(candidate)
		var next_available = available_nums.duplicate()
		next_available.erase(candidate)
		if fill_reachable_note_sequence(path, next_available):
			return true
		path.pop_back()

	return false


func _on_create_control_timeout() -> void:
	super._on_create_control_timeout()

	if (
		current_stage == 2
		and puzzle_solved
		and monster_group["stage_2"].size() > 0
		and _get_alive_stage_monster_count() == 0
	):
		if check_can_create(2):
			level_create_monster(2)


func check_can_create(stage: int) -> bool:
	var stage_key = "stage_" + str(stage)
	if not monster_group.has(stage_key):
		return false
	return _get_alive_stage_monster_count() < 6 and monster_group[stage_key].size() > 0


func reset_note_assignment():
	stage1_monster_killed_count = 0
	assigned_image_indices.clear()
	pending_note_indices.clear()
	init_puzzle()

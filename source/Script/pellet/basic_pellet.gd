extends Node2D
class_name BasicPellet
const FULLSCREEN_DESIGN_SIZE := Vector2(944.0, 592.0)
@onready var prop_stage_1: Label = $BG/AllPellet/AllPelletProp/PropStage_1
@onready var prop_stage_2: Label = $BG/AllPellet/AllPelletProp/PropStage_2
@onready var prop_stage_3: Label = $BG/AllPellet/AllPelletProp/PropStage_3
@onready var prop_stage_4: Label = $BG/AllPellet/AllPelletProp/PropStage_4
@onready var prop_stage_5: Label = $BG/AllPellet/AllPelletProp/PropStage_5
@onready var hp: Label = $BG/TotalProp/TotalProps/Hp
@onready var mp: Label = $BG/TotalProp/TotalProps/Mp
@onready var att: Label = $BG/TotalProp/TotalProps/Att
@onready var crit: Label = $BG/TotalProp/TotalProps/Crit
@onready var lucky: Label = $BG/TotalProp/TotalProps/Lucky
@onready var emp: Label = $BG/TotalProp/TotalProps/Emp
@onready var all_pellets_box: VBoxContainer = $BG/AllPelletsBox
@onready var one_key_eat_button: TextureButton = $BG/Eat_all

var current_pellet_type: String = "生命"
var current_in_type = "smd_"


func _increment_pellet_counts(stage: int) -> void:
	var key := current_pellet_type + "丹" + str(stage)
	var coop := get_node_or_null("/root/LocalCoop")
	if coop != null and coop.has_method("is_enabled") and coop.is_enabled():
		coop.increment_pellet_count(key)
	else:
		PlayerData.player_data[key] = mini(5, int(PlayerData.player_data.get(key, 0)) + 1)


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / FULLSCREEN_DESIGN_SIZE.x, viewport_size.y / FULLSCREEN_DESIGN_SIZE.y)
	var page_size = FULLSCREEN_DESIGN_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - page_size) * 0.5


func _ready() -> void:
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	set_info()


func set_info():
	set_every_prop_text()
	add_box()


func _physics_process(delta: float) -> void:
	match current_pellet_type:
		"生命":
			current_in_type = "smd_"
		"魔法":
			current_in_type = "fld_"
		"攻击":
			current_in_type = "gjd_"
		"暴击":
			current_in_type = "bjd_"
		"幸运":
			current_in_type = "xyd_"
		"回魔":
			current_in_type = "hmd_"


func set_every_prop_text():
	prop_stage_1.text = (
		"一品提供："
		+ str(
			PlayerData.player_data[str(current_pellet_type) + "丹1"] * RoleProp.pellet_props["1品丹"][current_pellet_type]
		)
		+ str(current_pellet_type)
	)
	prop_stage_2.text = (
		"二品提供："
		+ str(
			PlayerData.player_data[str(current_pellet_type) + "丹2"] * RoleProp.pellet_props["2品丹"][current_pellet_type]
		)
		+ str(current_pellet_type)
	)
	prop_stage_3.text = (
		"三品提供："
		+ str(
			PlayerData.player_data[str(current_pellet_type) + "丹3"] * RoleProp.pellet_props["3品丹"][current_pellet_type]
		)
		+ str(current_pellet_type)
	)
	prop_stage_4.text = (
		"四品提供："
		+ str(
			PlayerData.player_data[str(current_pellet_type) + "丹4"] * RoleProp.pellet_props["4品丹"][current_pellet_type]
		)
		+ str(current_pellet_type)
	)
	prop_stage_5.text = (
		"五品提供："
		+ str(
			PlayerData.player_data[str(current_pellet_type) + "丹5"] * RoleProp.pellet_props["5品丹"][current_pellet_type]
		)
		+ str(current_pellet_type)
	)
	hp.text = "生命：" + str(RoleProp.get_pellet_prop()[0])
	mp.text = "魔法：" + str(RoleProp.get_pellet_prop()[1])
	att.text = "攻击：" + str(RoleProp.get_pellet_prop()[2])
	crit.text = "暴击：" + str(RoleProp.get_pellet_prop()[3])
	lucky.text = "幸运：" + str(RoleProp.get_pellet_prop()[4])
	emp.text = "回魔：" + str(RoleProp.get_pellet_prop()[5])


func add_box():
	remove_box()
	var num_list = [PlayerData.player_data[str(current_pellet_type) + "丹1"]]
	for i in range(6):
		if i > 0:
			for u in range(PlayerData.player_data[str(current_pellet_type) + "丹" + str(i)]):
				var parent_node = all_pellets_box.get_node("Stage_" + str(i))
				var box = Global.add_level_fall_box(
					parent_node, true, true, current_in_type + str(i), 0, [], AE.all_equipment[current_in_type + str(i)]
				)
				box.set_button_icon(load_item_icon(current_in_type + str(i)))


func remove_box():
	for i in range(6):
		if i > 0:
			var parent_node = all_pellets_box.get_node("Stage_" + str(i))
			for u in parent_node.get_children():
				u.queue_free()


func _on_hp_dy_pressed() -> void:
	current_pellet_type = "生命"
	current_in_type = "smd_"
	set_info()


func _on_mp_dy_pressed() -> void:
	current_pellet_type = "魔法"
	current_in_type = "fld_"
	set_info()


func _on_att_dy_pressed() -> void:
	current_pellet_type = "攻击"
	current_in_type = "gjd_"
	set_info()


func _on_crit_dy_pressed() -> void:
	current_pellet_type = "暴击"
	current_in_type = "bjd_"
	set_info()


func _on_lucky_dy_pressed() -> void:
	current_pellet_type = "幸运"
	current_in_type = "xyd_"
	set_info()


func _on_emp_dy_pressed() -> void:
	current_pellet_type = "回魔"
	current_in_type = "hmd_"
	set_info()


func _on_eat_1_pressed() -> void:
	if PlayerData.player_data[current_pellet_type + "丹1"] < 5:
		if PlayerData.get_dj_page(str(current_in_type) + "1") != 0:
			_increment_pellet_counts(1)
			PlayerData.remove_dj(str(current_in_type) + "1", PlayerData.get_dj_page(str(current_in_type) + "1"), 1)
			Global.add_message_show(Global.windows, "成功服用一品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		else:
			Global.add_message_show(Global.windows, "一品" + str(current_pellet_type) + "丹不足！！", 1.5, Vector2(500, 305))
	else:
		Global.add_message_show(Global.windows, "一品" + str(current_pellet_type) + "丹已达服用上限！！", 1.5, Vector2(500, 305))
	set_info()


func _on_eat_2_pressed() -> void:
	if PlayerData.player_data[current_pellet_type + "丹1"] < 5:
		Global.add_message_show(Global.windows, "请先服用完一品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		return
	if PlayerData.player_data[current_pellet_type + "丹2"] < 5:
		if PlayerData.get_dj_page(str(current_in_type) + "2") != 0:
			_increment_pellet_counts(2)
			PlayerData.remove_dj(str(current_in_type) + "2", PlayerData.get_dj_page(str(current_in_type) + "2"), 1)
			Global.add_message_show(Global.windows, "成功服用二品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		else:
			Global.add_message_show(Global.windows, "二品" + str(current_pellet_type) + "丹不足！！", 1.5, Vector2(500, 305))
	else:
		Global.add_message_show(Global.windows, "二品" + str(current_pellet_type) + "丹已达服用上限！！", 1.5, Vector2(500, 305))

	set_info()


func _on_eat_3_pressed() -> void:
	if PlayerData.player_data[current_pellet_type + "丹2"] < 5:
		Global.add_message_show(Global.windows, "请先服用完二品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		return
	if PlayerData.player_data[current_pellet_type + "丹3"] < 5:
		if PlayerData.get_dj_page(str(current_in_type) + "3") != 0:
			_increment_pellet_counts(3)
			PlayerData.remove_dj(str(current_in_type) + "3", PlayerData.get_dj_page(str(current_in_type) + "3"), 1)
			Global.add_message_show(Global.windows, "成功服用三品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		else:
			Global.add_message_show(Global.windows, "三品" + str(current_pellet_type) + "丹不足！！", 1.5, Vector2(500, 305))
	else:
		Global.add_message_show(Global.windows, "三品" + str(current_pellet_type) + "丹已达服用上限！！", 1.5, Vector2(500, 305))

	set_info()


func _on_eat_4_pressed() -> void:
	if PlayerData.player_data[current_pellet_type + "丹3"] < 5:
		Global.add_message_show(Global.windows, "请先服用完三品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		return

	if PlayerData.player_data[current_pellet_type + "丹4"] < 5:
		if PlayerData.get_dj_page(str(current_in_type) + "4") != 0:
			_increment_pellet_counts(4)
			PlayerData.remove_dj(str(current_in_type) + "4", PlayerData.get_dj_page(str(current_in_type) + "4"), 1)
			Global.add_message_show(Global.windows, "成功服用四品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		else:
			Global.add_message_show(Global.windows, "四品" + str(current_pellet_type) + "丹不足！！", 1.5, Vector2(500, 305))
	else:
		Global.add_message_show(Global.windows, "四品" + str(current_pellet_type) + "丹已达服用上限！！", 1.5, Vector2(500, 305))

	set_info()


func _on_eat_5_pressed() -> void:
	if PlayerData.player_data[current_pellet_type + "丹4"] < 5:
		Global.add_message_show(Global.windows, "请先服用完四品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		return

	if PlayerData.player_data[current_pellet_type + "丹5"] < 5:
		if PlayerData.get_dj_page(str(current_in_type) + "5") != 0:
			_increment_pellet_counts(5)
			PlayerData.remove_dj(str(current_in_type) + "5", PlayerData.get_dj_page(str(current_in_type) + "5"), 1)
			Global.add_message_show(Global.windows, "成功服用五品" + str(current_pellet_type) + "丹！！", 1.5, Vector2(500, 305))
		else:
			Global.add_message_show(Global.windows, "五品" + str(current_pellet_type) + "丹不足！！", 1.5, Vector2(500, 305))
	else:
		Global.add_message_show(Global.windows, "五品" + str(current_pellet_type) + "丹已达服用上限！！", 1.5, Vector2(500, 305))

	set_info()


func _on_close_pressed() -> void:
	queue_free()


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func _on_one_key_auto_eat_pressed() -> void:
	var total_eaten = 0
	var current_grade = 1
	var can_continue = true

	while current_grade <= 5 and can_continue:
		var grade_key = current_pellet_type + "丹" + str(current_grade)
		var item_id = current_in_type + str(current_grade)

		if PlayerData.player_data[grade_key] >= 5:
			current_grade += 1
			continue

		if current_grade > 1:
			var prev_grade_key = current_pellet_type + "丹" + str(current_grade - 1)
			if PlayerData.player_data[prev_grade_key] < 5:
				can_continue = false
				Global.add_message_show(
					Global.windows,
					"无法继续：请先服用完" + str(current_grade - 1) + "品" + current_pellet_type + "丹",
					1.5,
					Vector2(500, 305)
				)
				break

		while PlayerData.player_data[grade_key] < 5:
			var item_count = PlayerData.get_dj_page(item_id)
			if item_count == 0:
				can_continue = false
				break

			_increment_pellet_counts(current_grade)
			PlayerData.remove_dj(item_id, PlayerData.get_dj_page(item_id), 1)
			total_eaten += 1

		if PlayerData.player_data[grade_key] >= 5:
			current_grade += 1

	if total_eaten > 0:
		var message = ""
		if current_grade > 5:
			message = "🎉 所有品级" + current_pellet_type + "丹均已服用满！"
		else:
			message = "已服用" + str(total_eaten) + "颗" + current_pellet_type + "丹"

		Global.add_message_show(Global.windows, message, 2.0, Vector2(500, 305))
		set_info()
	elif total_eaten == 0 and not can_continue:
		pass
	else:
		Global.add_message_show(Global.windows, "没有可服用的" + current_pellet_type + "丹", 1.5, Vector2(500, 305))

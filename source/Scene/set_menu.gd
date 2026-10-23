extends CanvasLayer

@onready var enable: Button = $bg/box/enable
@onready var big: Button = $bg/box/HBoxContainer/big
@onready var mid: Button = $bg/box/HBoxContainer/mid
@onready var small: Button = $bg/box/HBoxContainer/small
@onready var role_btn: Button = $bg/box/RoleP2
@onready var set_key: Button = $bg/box/SetKey

var set_key_tscn: PackedScene = preload("res://Scene/tools/set_com.tscn")
var auto_battle_tscn: PackedScene = preload("res://Scene/auto_battle_config.tscn")
var tree: SceneTree
var icon_scale: float = 1.0
var joy_enabled: bool = true


func _ready() -> void:
	tree = get_tree()
	process_mode = Node.PROCESS_MODE_ALWAYS
	joy_enabled = _current_joy_enabled()
	if role_btn != null:
		role_btn.disabled = false
		_refresh_auto_battle_button()
	_refresh_mobile_buttons()


func _physics_process(_delta: float) -> void:
	$bg/box/BGMControl.text = "关闭音乐" if MainSet.set_data.get("BackGroundMusic", true) else "打开音乐"
	$bg/box/RoleOrMonsterControl.text = "关闭音效" if MainSet.set_data.get("RoleOrMonsterHit", true) else "打开音效"


func _process(_delta: float) -> void:
	_refresh_mobile_buttons()
	_refresh_auto_battle_button()


func _refresh_mobile_buttons() -> void:
	var is_android: bool = _use_old_touch_hud()
	if set_key != null:
		set_key.disabled = not is_android
	if enable != null:
		enable.disabled = not is_android
		enable.text = "关闭摇杆" if joy_enabled else "开启摇杆"
	if big != null:
		big.disabled = not is_android or is_equal_approx(icon_scale, 1.3)
	if mid != null:
		mid.disabled = not is_android or is_equal_approx(icon_scale, 1.15)
	if small != null:
		small.disabled = not is_android or is_equal_approx(icon_scale, 1.0)


func _on_close_pressed() -> void:
	queue_free()


func _on_continue_game_pressed() -> void:
	queue_free()


func _on_continue_game_2_pressed() -> void:
	tree.paused = false
	if Global.current_level == "镇妖塔":
		Global.change_scene("res://Scene/main_menu/map_0.tscn")
		return
	var target_map := "res://Scene/main_menu/map_1.tscn"
	match int(PlayerData.player_data.get("Map_num", 1)):
		2:
			if PlayerData.player_data.get("地府", false):
				target_map = "res://Scene/main_menu/map_2.tscn"
		3:
			if PlayerData.player_data.get("天庭", false):
				target_map = "res://Scene/main_menu/map_3.tscn"
		4:
			if PlayerData.player_data.get("截教天镜", false):
				target_map = "res://Scene/main_menu/map_4.tscn"
		5:
			if PlayerData.player_data.get("碧游宫", false):
				target_map = "res://Scene/main_menu/map_5.tscn"
		6:
			if int(PlayerData.player_data.get("通天教主", 0)) == 1:
				target_map = "res://Scene/main_menu/map_6.tscn"
		7:
			target_map = "res://Scene/main_menu/map_7.tscn"
		8:
			if PlayerData.player_data.get("Map_variant", "") == "Map_8_1":
				target_map = "res://Scene/main_menu/map_8_1.tscn"
			else:
				target_map = "res://Scene/main_menu/map_8.tscn"
		9:
			if PlayerData.player_data.get("Map_variant", "") == "Map_9_1":
				target_map = "res://Scene/main_menu/map_9_1.tscn"
			else:
				target_map = "res://Scene/main_menu/map_9.tscn"
	Global.change_scene(target_map)


func _on_continue_game_4_pressed() -> void:
	tree.paused = false
	Global.change_scene("res://Scene/main_menu/main_menu.tscn")


func _on_bgm_control_pressed() -> void:
	MainSet.set_data["BackGroundMusic"] = not MainSet.set_data.get("BackGroundMusic", true)
	MemoryClass.main_bc()


func _on_role_or_monster_control_pressed() -> void:
	MainSet.set_data["RoleOrMonsterHit"] = not MainSet.set_data.get("RoleOrMonsterHit", true)
	MemoryClass.main_bc()


func _on_big_pressed() -> void:
	_set_icon_scale(1.3)


func _on_mid_pressed() -> void:
	_set_icon_scale(1.15)


func _on_small_pressed() -> void:
	_set_icon_scale(1.0)


func _on_enable_pressed() -> void:
	joy_enabled = not joy_enabled
	for node in get_tree().get_nodes_in_group("TouchControlSetCom"):
		if node.has_method("set_joy_enabled"):
			node.set_joy_enabled(joy_enabled)


func _on_rolep2_pressed() -> void:
	if MainSet.is_auto_battle_enabled():
		MainSet.set_auto_battle_enabled(false)
		_refresh_auto_battle_button()
		return
	if auto_battle_tscn == null:
		return
	var config = auto_battle_tscn.instantiate()
	if config == null:
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(config)
	if config is CanvasLayer:
		config.layer = 20


func _refresh_auto_battle_button() -> void:
	if role_btn == null:
		return
	role_btn.disabled = false
	role_btn.text = "关闭自动战斗" if MainSet.is_auto_battle_enabled() else "开启自动战斗"


func _on_set_key_pressed() -> void:
	if not _use_old_touch_hud():
		return
	var node = set_key_tscn.instantiate()
	node.is_set = true
	var role_info = get_tree().get_first_node_in_group("RoleInformation")
	if role_info != null:
		role_info.is_stop = true
		if role_info.get("set_com_node") != null and is_instance_valid(role_info.set_com_node):
			role_info.set_com_node.visible = false
			node.tree_exited.connect(func(): if is_instance_valid(role_info.set_com_node): role_info.set_com_node.visible = true)
	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = "SetKeyCanvasLayer"
	canvas_layer.layer = 30
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas_layer.add_child(node)
	node.tree_exited.connect(canvas_layer.queue_free)
	get_tree().root.add_child(canvas_layer)
	queue_free()


func _use_old_touch_hud() -> bool:
	return true


func _set_icon_scale(value: float) -> void:
	icon_scale = value
	for node in get_tree().get_nodes_in_group("TouchControlSetCom"):
		if node.has_method("apply_global_scale"):
			node.apply_global_scale(icon_scale)


func _current_joy_enabled() -> bool:
	for node in get_tree().get_nodes_in_group("TouchControlSetCom"):
		var joy = node.get_node_or_null("joy_left")
		if joy != null:
			return joy.visible
	return true

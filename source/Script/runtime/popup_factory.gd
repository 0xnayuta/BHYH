class_name PopupFactory
extends Node

## 弹窗/文本提示族的场景工厂：持有 message_show、choose_text、moment_text、
## touch_text、liji、combo 与游戏公告的运行时场景缓存。由 Global 作为普通子节点持有，
## 不是 Autoload；业务代码仍通过 Global.add_* 正式入口调用。

const MESSAGE_SHOW_PATH := "res://Scene/show_text/message_show.tscn"
const MOMENT_TEXT_PATH := "res://Scene/show_text/moment_text.tscn"
const LIJI_PATH := "res://Scene/show_text/liji.tscn"
const COMBO_PATH := "res://Scene/show_text/combo.tscn"
const COMBO_NUM_PATH := "res://Scene/show_text/combo_num.tscn"
const CHOOSE_TEXT_PATH := "res://Scene/show_text/choose_scene.tscn"
const TOUCH_TEXT_PATH := "res://Scene/show_text/touch_text.tscn"
const BUFF_INFOR_PATH := "res://Scene/other_scene/buff_information.tscn"
const GAME_ANNOUNCEMENT_PATH := "res://Scene/main_menu/game_announcement.tscn"

var _host: Node = null
var _scenes: Dictionary = {}


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_scenes.clear()


## 目标节点可能尚未进入场景树（instance_scene 走延迟 add_child），
## 暂停判定统一取宿主树，语义与拆分前的 get_tree() 一致。
func _is_tree_paused() -> bool:
	var tree := _host.get_tree()
	return tree != null and tree.paused


func _scene(path: String) -> PackedScene:
	var cached: Variant = _scenes.get(path)
	if cached is PackedScene:
		return cached as PackedScene
	var scene: PackedScene = _host.load_cached_scene(path)
	if scene != null:
		_scenes[path] = scene
	return scene


func add_message_show(parent_node, need_text: String, time: float, target_pos: Vector2):
	var target = _host.instance_scene(_scene(MESSAGE_SHOW_PATH), parent_node)
	if target == null:
		return null
	target.z_index = 999
	if target_pos == Vector2.ZERO or target_pos == Vector2(470, 300):
		target.position = _host.viewport_center_for_parent(parent_node)
	else:
		target.position = target_pos
	target.show_text = need_text
	target.last_time = time
	_host.center_popup_texts(target)
	return target


func add_buff_info(parent, _position, message_text: String):
	return add_message_show(parent, message_text, 1.5, _position)


func add_game_announcement(parent, position):
	var target = _host.instance_scene(_scene(GAME_ANNOUNCEMENT_PATH), parent)
	if target == null:
		return null
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	if target is CanvasLayer:
		target.offset = position
	elif target is Node2D or target is Control:
		target.position = position
	return target


func add_buff_information(parent, position, data):
	var target = _host.instance_scene(_scene(BUFF_INFOR_PATH), parent)
	if target == null:
		return null
	target.data_list = data
	_host.apply_popup_screen_layout(target, position, Vector2(320, 120))
	_host.prepare_hover_info_popup(target, true)
	return target


func add_choose_text(parent, _position, text_, calm_time):
	var target = _host.instance_scene(_scene(CHOOSE_TEXT_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = _position
	target.my_text = text_
	target.calm_time = calm_time
	_host.get_ui_runtime().register_transient_ui(target)
	if is_instance_valid(target) and _is_tree_paused():
		target.process_mode = Node.PROCESS_MODE_ALWAYS
	return target


func add_moment_text(parent, position, text, last_time):
	var target = _host.instance_scene(_scene(MOMENT_TEXT_PATH), parent)
	if target == null:
		return null
	target.position = position
	target.show_text = text
	target.last_time = last_time
	target.z_index = 99
	return target


func add_touch_text(parent, position, text):
	var target = _host.instance_scene(_scene(TOUCH_TEXT_PATH), parent)
	if target == null:
		return null
	target.position = position
	target.z_index = 99
	target.tt = text
	return target


func add_lj(parent, _position):
	var target = _host.instance_scene(_scene(LIJI_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = _position
	return target


func add_combo(parent, combo_num_, position):
	for child in parent.get_children():
		if child is Node2D and child.has_method(&"set_combo_num"):
			child.set_combo_num(combo_num_)
			child.position = position
			return child
	var combo_scene := _scene(COMBO_PATH)
	if combo_scene == null:
		return null
	var target = combo_scene.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.position = position
	if target.has_method(&"set_combo_num"):
		target.set_combo_num(combo_num_)
	else:
		target.combo_num = combo_num_
	return target


func add_combo_num(parent, combo_num_):
	var target = _host.instance_scene(_scene(COMBO_NUM_PATH), parent)
	if target == null:
		return null
	target.combo_num = combo_num_
	return target

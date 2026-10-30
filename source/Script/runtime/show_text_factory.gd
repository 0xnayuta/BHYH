class_name ShowTextFactory
extends Node

## 展示文本族场景工厂：任务标题、评分文字、自定义字体文本、怪物帮助与玩家信件。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 缓存槽位与迁移前的 Global.task_title/pj/add_font/some_monster_help/letter_for_player 一致。

const TASK_TITLE_SCENE_PATH := "res://Scene/task/task_title.tscn"
const PING_JIA_SCENE_PATH := "res://Scene/other_scene/ping_jia.tscn"
const MESSAGE_INFO_SCENE_PATH := "res://Scene/show_text/message_info.tscn"
const SOME_MONSTER_HELP_SCENE_PATH := "res://Scene/monster/some_monster_help.tscn"
const LETTER_FOR_PLAYER_SCENE_PATH := "res://Scene/other_scene/a_letter_for_all_players.tscn"

var _host = null
var _task_title_scene: PackedScene = null
var _ping_jia_scene: PackedScene = null
var _message_info_scene: PackedScene = null
var _some_monster_help_scene: PackedScene = null
var _letter_for_player_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_task_title_scene = null
	_ping_jia_scene = null
	_message_info_scene = null
	_some_monster_help_scene = null
	_letter_for_player_scene = null


func get_task_title_scene() -> PackedScene:
	if _task_title_scene == null:
		_task_title_scene = _host.load_cached_scene(TASK_TITLE_SCENE_PATH)
	return _task_title_scene


func get_ping_jia_scene() -> PackedScene:
	if _ping_jia_scene == null:
		_ping_jia_scene = _host.load_cached_scene(PING_JIA_SCENE_PATH)
	return _ping_jia_scene


func get_message_info_scene() -> PackedScene:
	if _message_info_scene == null:
		_message_info_scene = _host.load_cached_scene(MESSAGE_INFO_SCENE_PATH)
	return _message_info_scene


func get_some_monster_help_scene() -> PackedScene:
	if _some_monster_help_scene == null:
		_some_monster_help_scene = _host.load_cached_scene(SOME_MONSTER_HELP_SCENE_PATH)
	return _some_monster_help_scene


func get_letter_for_player_scene() -> PackedScene:
	if _letter_for_player_scene == null:
		_letter_for_player_scene = _host.load_cached_scene(LETTER_FOR_PLAYER_SCENE_PATH)
	return _letter_for_player_scene


func add_task_title(parent, task_type, task_name, my_father):
	var target = _host.instance_scene(get_task_title_scene(), parent)
	if target == null:
		return null
	target.task_name = task_name
	target.task_type = task_type
	target.my_father = my_father
	target.z_index = 99
	return target


func add_ping_jia(parent, position, num):
	var target = _host.instance_scene(get_ping_jia_scene(), parent)
	if target == null:
		return null
	target.num = num
	target.position = position
	return target


func add_some_monster_help(parent, position):
	var target = _host.instance_scene(get_some_monster_help_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_letter_for_player(parent, position):
	var target = _host.instance_scene(get_letter_for_player_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_font_instance(parent, text, font_path, font_size, font_color, out_line_size, out_line_color):
	var target = _host.instance_scene(get_message_info_scene(), parent)
	if target == null:
		return null
	if font_path == null:
		target.font = null
	else:
		target.font = load(font_path)
	target.show_text = text
	target.font_color = font_color
	target.out_line_size = out_line_size
	target.out_line_color = out_line_color
	target.font_size = font_size
	return target

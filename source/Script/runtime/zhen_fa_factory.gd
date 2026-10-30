class_name ZhenFaFactory
extends Node

## 阵法面板族场景工厂：阵法说明、突破提示、阵眼疗伤等级、阵法信息、阵法类型按钮与阵眼按钮。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 六个场景槽位常驻，与迁移前的 Global.zhen_fa_* / zhenyanbutton 一致。

const HELP_SCENE_PATH := "res://Scene/other_scene/zhen_fa_help.tscn"
const TU_PO_SCENE_PATH := "res://Scene/other_scene/zhen_fa_tu_po.tscn"
const CURE_LEVEL_SCENE_PATH := "res://Scene/other_scene/zhen_yan_cure_level.tscn"
const INFO_SCENE_PATH := "res://Scene/other_scene/zhenfainfo.tscn"
const LX_BUTTON_SCENE_PATH := "res://Scene/other_scene/zhenfalxbutton.tscn"
const EYE_BUTTON_SCENE_PATH := "res://Scene/other_scene/zhenyanbutton.tscn"

var _host = null
var _help_scene: PackedScene = null
var _tu_po_scene: PackedScene = null
var _cure_level_scene: PackedScene = null
var _info_scene: PackedScene = null
var _lx_button_scene: PackedScene = null
var _eye_button_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func get_help_scene() -> PackedScene:
	if _help_scene == null:
		_help_scene = _host.load_cached_scene(HELP_SCENE_PATH)
	return _help_scene


func get_tu_po_scene() -> PackedScene:
	if _tu_po_scene == null:
		_tu_po_scene = _host.load_cached_scene(TU_PO_SCENE_PATH)
	return _tu_po_scene


func get_cure_level_scene() -> PackedScene:
	if _cure_level_scene == null:
		_cure_level_scene = _host.load_cached_scene(CURE_LEVEL_SCENE_PATH)
	return _cure_level_scene


func get_info_scene() -> PackedScene:
	if _info_scene == null:
		_info_scene = _host.load_cached_scene(INFO_SCENE_PATH)
	return _info_scene


func get_lx_button_scene() -> PackedScene:
	if _lx_button_scene == null:
		_lx_button_scene = _host.load_cached_scene(LX_BUTTON_SCENE_PATH)
	return _lx_button_scene


func get_eye_button_scene() -> PackedScene:
	if _eye_button_scene == null:
		_eye_button_scene = _host.load_cached_scene(EYE_BUTTON_SCENE_PATH)
	return _eye_button_scene


func add_help(parent, position):
	var target = _host.instance_scene(get_help_scene(), parent)
	target.position = position
	return target


func add_tu_po(parent, position, father):
	var target = _host.instance_scene(get_tu_po_scene(), parent)
	target.position = position
	target.father = father
	return target


func add_cure_level(parent, position, father):
	var target = _host.instance_scene(get_cure_level_scene(), parent)
	target.position = position
	target.father = father
	return target


func add_info(parent, position, father):
	var target = _host.instance_scene(get_info_scene(), parent)
	target.position = position
	target.father = father
	return target


func add_lx_button(parent, zhenfa_name, father):
	var target = _host.instance_scene(get_lx_button_scene(), parent)
	target.zhenfa_name = zhenfa_name
	target.father = father
	return target


func add_eye_button(parent, position, loc_num, father):
	var target = _host.instance_scene(get_eye_button_scene(), parent)
	target.position = position
	target.loc_num = loc_num
	target.father = father
	return target

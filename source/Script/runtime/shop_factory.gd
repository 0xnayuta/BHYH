class_name ShopFactory
extends Node

## 商店与合成族的场景工厂：持有商店、神秘商店、购买选择、合成、强化与
## 确认提示的运行时场景缓存。由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码仍通过 Global.add_* 正式入口调用。

const SHOP_PATH := "res://Scene/shop/shop.tscn"
const SHOP_ITEM_PATH := "res://Scene/shop/shop_item.tscn"
const MYSTERY_SHOP_PATH := "res://Scene/shop/mystery_shop.tscn"
const CHOOSE_ITEM_PATH := "res://Scene/shop/choose_item.tscn"
const SYNTHESIS_PATH := "res://Scene/ldl/synthesis.tscn"
const STRENGTH_PATH := "res://Scene/ldl/strength.tscn"
const YES_NO_HELP_PATH := "res://Scene/ldl/s_yn_help.tscn"

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


func add_shop(parent, position):
	var target = _host.instance_scene(_scene(SHOP_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	return target


func add_shop_items(parent, position, _name: String, need_):
	var target = _host.instance_scene(_scene(SHOP_ITEM_PATH), parent)
	if target == null:
		return null
	target.position = position
	target._item_name = _name
	target.need_lh = int(need_)
	return target


func add_mystery_shop(parent, position):
	var target = _host.instance_scene(_scene(MYSTERY_SHOP_PATH), parent)
	if target == null:
		return null
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = _host.viewport_center_for_parent(parent) - Vector2(458, 293)
	else:
		target.position = position
	return target


func add_choose_item(parent, position, list, _name, page):
	list = preload("res://Script/data/yutu_equipment_data.gd").expand_drop_entries(list, "名字")
	var target = _host.instance_scene(_scene(CHOOSE_ITEM_PATH), parent)
	if target == null:
		return null
	target._name = _name
	target.page = page
	target._list = list
	target.z_index = 99
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	if position == Vector2.ZERO or position == Vector2(460, 260):
		target.position = _host.viewport_center_for_parent(parent)
	else:
		target.position = position
	if is_instance_valid(target) and _is_tree_paused():
		target.process_mode = Node.PROCESS_MODE_ALWAYS
	return target


func add_synthesis(parent, position):
	var target = _host.instance_scene(_scene(SYNTHESIS_PATH), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_strength(parent, position):
	var target = _host.instance_scene(_scene(STRENGTH_PATH), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_s_y_n_help(parent, position):
	var target = _host.instance_scene(_scene(YES_NO_HELP_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	return target

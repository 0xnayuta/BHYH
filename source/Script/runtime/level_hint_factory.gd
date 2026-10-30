class_name LevelHintFactory
extends Node

## 关卡提示族场景工厂：掉落箱/道具箱、进入条件提示、回收提示与物品悬浮提示。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 四个场景槽位常驻，与迁移前的 Global.level_fall_box/game_need_know/hc_help/help_thing 一致。

const BOX_SCENE_PATH := "res://Scene/back_pack/box_1.tscn"
const GAME_NEED_KNOW_SCENE_PATH := "res://Scene/other_scene/game_need_know.tscn"
const HC_HELP_SCENE_PATH := "res://Scene/other_scene/hc_help.tscn"
const HELP_THING_SCENE_PATH := "res://Scene/other_scene/help_things.tscn"

var _host = null
var _box_scene: PackedScene = null
var _game_need_know_scene: PackedScene = null
var _hc_help_scene: PackedScene = null
var _help_thing_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func get_box_scene() -> PackedScene:
	if _box_scene == null:
		_box_scene = _host.load_cached_scene(BOX_SCENE_PATH)
	return _box_scene


func get_game_need_know_scene() -> PackedScene:
	if _game_need_know_scene == null:
		_game_need_know_scene = _host.load_cached_scene(GAME_NEED_KNOW_SCENE_PATH)
	return _game_need_know_scene


func get_hc_help_scene() -> PackedScene:
	if _hc_help_scene == null:
		_hc_help_scene = _host.load_cached_scene(HC_HELP_SCENE_PATH)
	return _hc_help_scene


func get_help_thing_scene() -> PackedScene:
	if _help_thing_scene == null:
		_help_thing_scene = _host.load_cached_scene(HELP_THING_SCENE_PATH)
	return _help_thing_scene


## 关卡掉落箱：预览掉落物，不携带总数量。
func add_level_fall_box(parent, in_ldl, in_hhgz, item_name, quality_level, wuxing, equipment_prop):
	var target = _host.instance_scene(get_box_scene(), parent)
	target.is_in_ldl_gz = in_ldl
	target.is_in_hhgz = in_hhgz
	target.qh_level = quality_level
	target.wx = wuxing
	target.eq_prop = equipment_prop
	target.get_item_name = item_name
	target.set_meta("item_name", item_name)
	target.set_meta("level_fall_box", true)
	return target


## 道具箱：与掉落箱共用场景，额外写总数量，且不写 level_fall_box 标记。
func add_item_box(parent, in_ldl, in_hhgz, item_name, quality_level, total_number, wuxing, equipment_prop):
	var target = _host.instance_scene(get_box_scene(), parent)
	target.is_in_ldl_gz = in_ldl
	target.is_in_hhgz = in_hhgz
	target.qh_level = quality_level
	target.total_number = total_number
	target.wx = wuxing
	target.eq_prop = equipment_prop
	target.get_item_name = item_name
	target.set_meta("item_name", item_name)
	return target


func add_game_need_know(parent, position):
	var target = _host.instance_scene(get_game_need_know_scene(), parent)
	target.position = position
	return target


func add_hc_help(parent, position):
	var target = _host.instance_scene(get_hc_help_scene(), parent)
	target.position = position
	return target


func add_help_thing(parent, position, item_info):
	var target = _host.instance_scene(get_help_thing_scene(), parent)
	target.item_info = item_info
	target.position = position
	return target

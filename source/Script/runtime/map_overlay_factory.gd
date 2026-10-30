class_name MapOverlayFactory
extends Node

## 主菜单地图浮层族场景工厂：活动之谜、`lsh` 与 `lxdy`。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 缓存槽位与迁移前的 Global._hdzm/_lsh/_lxdy 一致。
## 三个入口均登记为临时 UI；活动之谜另挂窗口守卫。

const HDZM_SCENE_PATH := "res://Scene/level/hdzm.tscn"
const LSH_SCENE_PATH := "res://Scene/other_scene/lsh.tscn"
const LXDY_SCENE_PATH := "res://Scene/other_scene/lxdy.tscn"
const HDZM_WINDOW_GUARD_SCRIPT := preload("res://Script/level/hdzm_window_guard.gd")

var _host = null
var _hdzm_scene: PackedScene = null
var _lsh_scene: PackedScene = null
var _lxdy_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_hdzm_scene = null
	_lsh_scene = null
	_lxdy_scene = null


func get_hdzm_scene() -> PackedScene:
	if _hdzm_scene == null:
		_hdzm_scene = _host.load_cached_scene(HDZM_SCENE_PATH)
	return _hdzm_scene


func get_lsh_scene() -> PackedScene:
	if _lsh_scene == null:
		_lsh_scene = _host.load_cached_scene(LSH_SCENE_PATH)
	return _lsh_scene


func get_lxdy_scene() -> PackedScene:
	if _lxdy_scene == null:
		_lxdy_scene = _host.load_cached_scene(LXDY_SCENE_PATH)
	return _lxdy_scene


func add_hdzm(parent, parent_node):
	var target = _host.instance_scene(get_hdzm_scene(), parent)
	if target == null:
		return null
	target.scale = Vector2.ONE
	target.position = _host.viewport_center_for_parent(parent) - Vector2(493, 260)
	target.parent_node = parent_node
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	var guard = HDZM_WINDOW_GUARD_SCRIPT.new()
	_host.get_tree().root.add_child(guard)
	guard.setup(target)
	return target


func add_lsh(parent, _parent_node):
	var target = _host.instance_scene(get_lsh_scene(), parent)
	if target == null:
		return null
	target.scale = Vector2.ONE
	target.position = _host.viewport_center_for_parent(parent) - Vector2(492, 254)
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	return target


func add_lxdy(parent, _parent_node):
	var target = _host.instance_scene(get_lxdy_scene(), parent)
	if target == null:
		return null
	target.scale = Vector2.ONE
	target.position = _host.viewport_center_for_parent(parent) - Vector2(461, 282)
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	return target

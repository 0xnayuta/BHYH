class_name ForgeFactory
extends Node

## 锻造/分解面板场景工厂：锻造说明、锻造主面板、分解说明与分解主面板。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 四个场景槽位常驻，与迁移前的 Global.forge_help/forges/decompose_help/decompose 一致。

const FORGE_HELP_SCENE_PATH := "res://Scene/ldl/forge_help.tscn"
const FORGES_SCENE_PATH := "res://Scene/ldl/forge.tscn"
const DECOMPOSE_HELP_SCENE_PATH := "res://Scene/ldl/decompose_help.tscn"
const DECOMPOSE_SCENE_PATH := "res://Scene/ldl/decompose.tscn"

var _host = null
var _forge_help_scene: PackedScene = null
var _forges_scene: PackedScene = null
var _decompose_help_scene: PackedScene = null
var _decompose_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func get_forge_help_scene() -> PackedScene:
	if _forge_help_scene == null:
		_forge_help_scene = _host.load_cached_scene(FORGE_HELP_SCENE_PATH)
	return _forge_help_scene


func get_forges_scene() -> PackedScene:
	if _forges_scene == null:
		_forges_scene = _host.load_cached_scene(FORGES_SCENE_PATH)
	return _forges_scene


func get_decompose_help_scene() -> PackedScene:
	if _decompose_help_scene == null:
		_decompose_help_scene = _host.load_cached_scene(DECOMPOSE_HELP_SCENE_PATH)
	return _decompose_help_scene


func get_decompose_scene() -> PackedScene:
	if _decompose_scene == null:
		_decompose_scene = _host.load_cached_scene(DECOMPOSE_SCENE_PATH)
	return _decompose_scene


func add_help(parent, position):
	var target = _host.instance_scene(get_forge_help_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_forges(parent, position):
	var target = _host.instance_scene(get_forges_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_decompose_help(parent, position):
	var target = _host.instance_scene(get_decompose_help_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_decompose(parent, position):
	var target = _host.instance_scene(get_decompose_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target

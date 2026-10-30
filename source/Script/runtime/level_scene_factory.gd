class_name LevelSceneFactory
extends Node

## 关卡场景族工厂：极彩天关卡地板、逐浪飞行地板、招照镜台陷阱、关卡选择面板
## 与关卡相机。
## 相机归关卡场景所有：由调用方挂到角色节点，工厂只负责场景缓存与初始化字段。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 缓存槽位与迁移前的 Global.stage/z_lw_stage/zztwtrap/dsg_choose 一致。

const STAGE_SCENE_PATH := "res://Scene/level/jctfloor_1.tscn"
const FLY_STAGE_SCENE_PATH := "res://Scene/level/zlw_fly_floor.tscn"
const TRAP_SCENE_PATH := "res://Scene/level/zztw_trap.tscn"
const DSG_CHOOSE_SCENE_PATH := "res://Scene/level/dsg_choose.tscn"
const CAMERA_SCENE_PATH := "res://Scene/level/camera.tscn"

var _host = null
var _stage_scene: PackedScene = null
var _fly_stage_scene: PackedScene = null
var _trap_scene: PackedScene = null
var _dsg_choose_scene: PackedScene = null
var _camera_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_stage_scene = null
	_fly_stage_scene = null
	_trap_scene = null
	_dsg_choose_scene = null
	_camera_scene = null


func get_stage_scene() -> PackedScene:
	if _stage_scene == null:
		_stage_scene = _host.load_cached_scene(STAGE_SCENE_PATH)
	return _stage_scene


func get_fly_stage_scene() -> PackedScene:
	if _fly_stage_scene == null:
		_fly_stage_scene = _host.load_cached_scene(FLY_STAGE_SCENE_PATH)
	return _fly_stage_scene


func get_trap_scene() -> PackedScene:
	if _trap_scene == null:
		_trap_scene = _host.load_cached_scene(TRAP_SCENE_PATH)
	return _trap_scene


func get_dsg_choose_scene() -> PackedScene:
	if _dsg_choose_scene == null:
		_dsg_choose_scene = _host.load_cached_scene(DSG_CHOOSE_SCENE_PATH)
	return _dsg_choose_scene


func get_camera_scene() -> PackedScene:
	if _camera_scene == null:
		_camera_scene = _host.load_cached_scene(CAMERA_SCENE_PATH)
	return _camera_scene


func add_camera(parent, position, right):
	var target = _host.instance_scene(get_camera_scene(), parent)
	if target == null:
		return null
	target.position = position
	target.max_right = right
	return target


func add_stage(parent, stage_type: String, position: Vector2):
	var target = _host.instance_scene(get_stage_scene(), parent)
	if target == null:
		return null
	target.type = stage_type
	target.position = position
	return target


func add_fly_stage(parent, position, speed, dir, max_num, pd):
	var target = _host.instance_scene(get_fly_stage_scene(), parent)
	if target == null:
		return null
	target.position = position
	target.direction = dir
	target.speed = speed
	target.max_position_x = max_num
	target.pd = pd
	return target


func add_trap(parent, trap_name, position):
	var target = _host.instance_scene(get_trap_scene(), parent)
	if target == null:
		return null
	target.my_name = trap_name
	target.position = position
	return target


func add_dsg_choose(parent):
	var target = _host.instance_scene(get_dsg_choose_scene(), parent)
	if target == null:
		return null
	target.position = Vector2(0, 0)
	return target

class_name MonsterDisplayFactory
extends Node

## 怪物展示族场景工厂：怪物头像属性面板、Boss 信息面板与通用提示文本。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 三个场景槽位常驻，与迁移前的 Global.monster_head/monster_info/basic_monment_info 一致，不随关卡清理。

const MONSTER_HEAD_SCENE_PATH := "res://Scene/other_scene/monster_head_info.tscn"
const MONSTER_INFO_SCENE_PATH := "res://Scene/monster/boss_info.tscn"
const BASIC_MOMENT_INFO_SCENE_PATH := "res://Scene/other_scene/basic_monment_info.tscn"

var _host = null
var _monster_head_scene: PackedScene = null
var _monster_info_scene: PackedScene = null
var _basic_moment_info_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func get_monster_head_scene() -> PackedScene:
	if _monster_head_scene == null:
		_monster_head_scene = _host.load_cached_scene(MONSTER_HEAD_SCENE_PATH)
	return _monster_head_scene


func get_monster_info_scene() -> PackedScene:
	if _monster_info_scene == null:
		_monster_info_scene = _host.load_cached_scene(MONSTER_INFO_SCENE_PATH)
	return _monster_info_scene


func get_basic_moment_info_scene() -> PackedScene:
	if _basic_moment_info_scene == null:
		_basic_moment_info_scene = _host.load_cached_scene(BASIC_MOMENT_INFO_SCENE_PATH)
	return _basic_moment_info_scene


func add_monster_head(parent, monster_name, is_boss, scene_path := ""):
	var target = _host.instance_scene(get_monster_head_scene(), parent)
	target.monster_name = monster_name
	target.is_boss = is_boss
	target.monster_scene_path = scene_path
	return target


func add_monster_info(parent, monster_name, position):
	var target = _host.instance_scene(get_monster_info_scene(), parent)
	target.monster_name = monster_name
	target.position = position
	return target


func add_basic_moment_info(parent, show_text, position):
	var target = _host.instance_scene(get_basic_moment_info_scene(), parent)
	target.show_text = show_text
	target.position = position
	return target

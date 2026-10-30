class_name SkillPanelFactory
extends Node

## 技能面板族场景工厂：角色/变身技能面板与法宝说明面板。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 缓存槽位与迁移前的 Global.zd_skill/bd_skill/magic_help 一致。
## 角色技能图标线程预热完成后，用 prime_* 方法接管已缓存场景，未命中时按需加载。

const ZD_SKILL_SCENE_PATH := "res://Scene/skill/zd_skill.tscn"
const BD_SKILL_SCENE_PATH := "res://Scene/skill/bd_skill.tscn"
const MAGIC_HELP_SCENE_PATH := "res://Scene/magic_weapon/magic_help.tscn"

var _host = null
var _zd_skill_scene: PackedScene = null
var _bd_skill_scene: PackedScene = null
var _magic_help_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_zd_skill_scene = null
	_bd_skill_scene = null
	_magic_help_scene = null


func get_zd_skill_scene() -> PackedScene:
	if _zd_skill_scene == null:
		_zd_skill_scene = _host.load_cached_scene(ZD_SKILL_SCENE_PATH)
	return _zd_skill_scene


func get_bd_skill_scene() -> PackedScene:
	if _bd_skill_scene == null:
		_bd_skill_scene = _host.load_cached_scene(BD_SKILL_SCENE_PATH)
	return _bd_skill_scene


func get_magic_help_scene() -> PackedScene:
	if _magic_help_scene == null:
		_magic_help_scene = _host.load_cached_scene(MAGIC_HELP_SCENE_PATH)
	return _magic_help_scene


## 角色技能图标线程预热完成后调用：只接受已缓存场景，未命中时保持为空。
func prime_skill_scenes() -> void:
	_zd_skill_scene = _host.get_cached_packed_scene(ZD_SKILL_SCENE_PATH)
	_bd_skill_scene = _host.get_cached_packed_scene(BD_SKILL_SCENE_PATH)


func add_zd_skill(parent, position):
	var target = _host.instance_scene(get_zd_skill_scene(), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	return target


func add_bd_skill(parent, position):
	var target = _host.instance_scene(get_bd_skill_scene(), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	return target


func add_magic_help(parent, position):
	var target = _host.instance_scene(get_magic_help_scene(), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	return target

class_name EffectFactory
extends Node

## 战斗效果场景工厂：灵魄光效、灵魄获取提示、技能特效、Boss 光环、无双特效、线性特效
## 与角色 1/2 浅攻载体。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 缓存槽位与迁移前的 Global.monster141_aura/smb_effect/role_special_effect/ws_effect/line 一致。
## 灵魄数值加成仍由 PaSkill 统一计算，本工厂只负责实例化与字段写入。

const MONSTER141_AURA_SCENE_PATH := "res://Scene/other_scene/nmw_aura.tscn"
const AURA_PATH := "res://Scene/other_scene/auras.tscn"
const SMB_EFFECT_SCENE_PATH := "res://Scene/hero/role_2/smb_effect.tscn"
const ROLE_SPECIAL_EFFECT_SCENE_PATH := "res://Scene/hero/role_special_effect.tscn"
const WS_EFFECT_SCENE_PATH := "res://Scene/hero/role_1/ws_effect.tscn"
const LINE_EFFECT_SCENE_PATH := "res://Scene/level/line_effect.tscn"
const ROLE3_SD_SLIM_PATH := "res://Scene/hero/role3_sd_slim.tscn"
const ROLE3_ZZNH_SLIM_PATH := "res://Scene/hero/role3_zznh_slim.tscn"
const ROLE_SPECIAL_EFFECT_SLIM_DIR := "res://Scene/hero/role_special_effect_slim"
const ROLE1_SHALLOW_PATH := "res://Scene/hero/role1_s_hallow.tscn"
const ROLE2_SHALLOW_PATH := "res://Scene/base/role2shallow.tscn"

var _host = null
var _monster141_aura_scene: PackedScene = null
var _smb_effect_scene: PackedScene = null
var _role_special_effect_scene: PackedScene = null
var _ws_effect_scene: PackedScene = null
var _line_scene: PackedScene = null
var _role1_shallow_scene: PackedScene = null
var _role2_shallow_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_monster141_aura_scene = null
	_smb_effect_scene = null
	_role_special_effect_scene = null
	_ws_effect_scene = null
	_line_scene = null
	_role1_shallow_scene = null
	_role2_shallow_scene = null


func get_monster141_aura_scene() -> PackedScene:
	if _monster141_aura_scene == null:
		_monster141_aura_scene = _host.load_cached_scene(MONSTER141_AURA_SCENE_PATH)
	return _monster141_aura_scene


func get_smb_effect_scene() -> PackedScene:
	if _smb_effect_scene == null:
		_smb_effect_scene = _host.load_cached_scene(SMB_EFFECT_SCENE_PATH)
	return _smb_effect_scene


func get_role_special_effect_scene() -> PackedScene:
	if _role_special_effect_scene == null:
		_role_special_effect_scene = _host.load_cached_scene(ROLE_SPECIAL_EFFECT_SCENE_PATH)
	return _role_special_effect_scene


func get_ws_effect_scene() -> PackedScene:
	if _ws_effect_scene == null:
		_ws_effect_scene = _host.load_cached_scene(WS_EFFECT_SCENE_PATH)
	return _ws_effect_scene


func get_line_scene() -> PackedScene:
	if _line_scene == null:
		_line_scene = _host.load_cached_scene(LINE_EFFECT_SCENE_PATH)
	return _line_scene


func get_role1_shallow_scene() -> PackedScene:
	if _role1_shallow_scene == null:
		_role1_shallow_scene = _host.load_cached_scene(ROLE1_SHALLOW_PATH)
	return _role1_shallow_scene


func get_role2_shallow_scene() -> PackedScene:
	if _role2_shallow_scene == null:
		_role2_shallow_scene = _host.load_cached_scene(ROLE2_SHALLOW_PATH)
	return _role2_shallow_scene


func add_role1_shallow(parent, position, dir, int_action, source_player: BaseHero = null):
	var target = _host.instance_scene(get_role1_shallow_scene(), parent)
	if target == null:
		return null
	target.position = position
	target.iniaction = int_action
	target.direction = dir
	_host._assign_attack_source(target, parent, source_player)
	return target


func add_role2_shallow(parent, position, dir):
	var target = _host.instance_scene(get_role2_shallow_scene(), parent)
	if target == null:
		return null
	target.position = position
	target.dir = dir
	return target


func add_monster141_aura(parent, position, target_monster):
	var target = _host.instance_scene(get_monster141_aura_scene(), parent)
	if target == null:
		return null
	target.target_monster = target_monster
	target.position = position
	return target


func add_aura(parent, position, value_in, color_type = 0):
	var target = _host.instance_scene(_host.load_cached_scene(AURA_PATH), parent)
	if target == null:
		return null
	target.value = PaSkill.apply_soul_gain_bonus(int(value_in))
	target.set_meta("base_soul_value", int(value_in))
	target.color_type = color_type
	target.position = position
	return target


func add_smb_effect(parent, position, dir):
	var target = _host.instance_scene(get_smb_effect_scene(), parent)
	if target == null:
		return null
	target.position = position
	target.dir = dir
	return target


func add_role_special_effect(parent, position, dir, effect_name):
	var resolved_name := str(effect_name)
	var scene = null
	if resolved_name in ["sd", "sd2"]:
		scene = _host.load_scene_uncached(ROLE3_SD_SLIM_PATH)
	elif resolved_name == "zznh":
		scene = _host.load_scene_uncached(ROLE3_ZZNH_SLIM_PATH)
	else:
		var slim_path := ROLE_SPECIAL_EFFECT_SLIM_DIR.path_join(resolved_name + ".tscn")
		scene = _host.load_scene_uncached(slim_path) if ResourceLoader.exists(slim_path) else null
	if scene == null:
		scene = get_role_special_effect_scene()
	var target = _host.instance_scene(scene, parent)
	if target == null:
		return null
	target.position = position
	target.special_effect_name = effect_name
	target.dir = dir
	return target


func add_ws_effect(parent):
	var target = _host.instance_scene(get_ws_effect_scene(), parent)
	if target == null:
		return null
	return target


func add_line(parent, monster, line_type):
	var target = _host.instance_scene(get_line_scene(), parent)
	if target == null:
		return null
	target.position = Vector2(0, 0)
	target.type = line_type
	target.monster = monster
	return target

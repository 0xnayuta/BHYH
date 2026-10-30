class_name MenuPanelFactory
extends Node

## 菜单与设置面板族场景工厂：游戏设置、技能键位、音乐设置、炼丹炉、游戏说明、学习技能、
## 镶嵌帮助/镶嵌面板、存档按钮、背景切换与读档界面。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 缓存槽位与迁移前的 Global.game_set/skill_key_set/music_set/ldl/game_information/skill_learn 一致。
## 临时 UI 登记仍经 UiRuntime；游戏说明根节点是 CanvasLayer，position/z_index 的赋值与迁移前一致（无效属性不生效）。

const GAME_SET_SCENE_PATH := "res://Scene/main_menu/game_set.tscn"
const SKILL_KEY_SET_SCENE_PATH := "res://Scene/skill/skill_key_set.tscn"
const MUSIC_SET_SCENE_PATH := "res://Scene/other_scene/choose_music.tscn"
const LDL_SCENE_PATH := "res://Scene/ldl/ldl.tscn"
const GAME_INFORMATION_SCENE_PATH := "res://Scene/main_menu/game_information.tscn"
const LEARN_SKILL_SCENE_PATH := "res://Scene/skill/learn_skill.tscn"
const MOSAIC_HELP_SCENE_PATH := "res://Scene/ldl/mosaic_help.tscn"
const MOSAIC_SCENE_PATH := "res://Scene/ldl/mosaic.tscn"
const BASIC_AR_BUTTON_PATH := "res://Scene/other_scene/bacis_ar_button.tscn"
const CHANGE_BG_PATH := "res://Scene/other_scene/change_back_ground.tscn"
const CD_JM_PATH := "res://Scene/archive_interface/read_archive_interface.tscn"

const GAME_SET_DESIGN_SIZE := Vector2(942, 589)

var _host = null
var _game_set_scene: PackedScene = null
var _skill_key_set_scene: PackedScene = null
var _music_set_scene: PackedScene = null
var _ldl_scene: PackedScene = null
var _game_information_scene: PackedScene = null
var _learn_skill_scene: PackedScene = null
var _mosaic_help_scene: PackedScene = null
var _mosaic_scene: PackedScene = null
var _basic_ar_button_scene: PackedScene = null
var _change_bg_scene: PackedScene = null
var _cd_jm_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_game_set_scene = null
	_skill_key_set_scene = null
	_music_set_scene = null
	_ldl_scene = null
	_game_information_scene = null
	_learn_skill_scene = null
	_mosaic_help_scene = null
	_mosaic_scene = null
	_basic_ar_button_scene = null
	_change_bg_scene = null
	_cd_jm_scene = null


func get_game_set_scene() -> PackedScene:
	if _game_set_scene == null:
		_game_set_scene = _host.load_cached_scene(GAME_SET_SCENE_PATH)
	return _game_set_scene


func get_skill_key_set_scene() -> PackedScene:
	if _skill_key_set_scene == null:
		_skill_key_set_scene = _host.load_cached_scene(SKILL_KEY_SET_SCENE_PATH)
	return _skill_key_set_scene


func get_music_set_scene() -> PackedScene:
	if _music_set_scene == null:
		_music_set_scene = _host.load_cached_scene(MUSIC_SET_SCENE_PATH)
	return _music_set_scene


func get_ldl_scene() -> PackedScene:
	if _ldl_scene == null:
		_ldl_scene = _host.load_cached_scene(LDL_SCENE_PATH)
	return _ldl_scene


func get_game_information_scene() -> PackedScene:
	if _game_information_scene == null:
		_game_information_scene = _host.load_cached_scene(GAME_INFORMATION_SCENE_PATH)
	return _game_information_scene


func get_learn_skill_scene() -> PackedScene:
	if _learn_skill_scene == null:
		_learn_skill_scene = _host.load_cached_scene(LEARN_SKILL_SCENE_PATH)
	return _learn_skill_scene


func get_mosaic_help_scene() -> PackedScene:
	if _mosaic_help_scene == null:
		_mosaic_help_scene = _host.load_cached_scene(MOSAIC_HELP_SCENE_PATH)
	return _mosaic_help_scene


func get_mosaic_scene() -> PackedScene:
	if _mosaic_scene == null:
		_mosaic_scene = _host.load_cached_scene(MOSAIC_SCENE_PATH)
	return _mosaic_scene


func get_basic_ar_button_scene() -> PackedScene:
	if _basic_ar_button_scene == null:
		_basic_ar_button_scene = _host.load_cached_scene(BASIC_AR_BUTTON_PATH)
	return _basic_ar_button_scene


func get_change_bg_scene() -> PackedScene:
	if _change_bg_scene == null:
		_change_bg_scene = _host.load_cached_scene(CHANGE_BG_PATH)
	return _change_bg_scene


func get_cd_jm_scene() -> PackedScene:
	if _cd_jm_scene == null:
		_cd_jm_scene = _host.load_cached_scene(CD_JM_PATH)
	return _cd_jm_scene


## 角色技能图标线程预热完成后调用：只接受已缓存场景，未命中时保持为空，由入口按需加载。
func prime_learn_skill_scene() -> void:
	_learn_skill_scene = _host.get_cached_packed_scene(LEARN_SKILL_SCENE_PATH)


func add_game_set(parent, position):
	var target = _host.instance_scene(get_game_set_scene(), parent)
	if target == null:
		return null
	_host.get_ui_runtime().register_transient_ui(target, &"_on_return_pressed")
	var viewport_size: Vector2 = _host.get_viewport().get_visible_rect().size
	var fit_scale: float = min(viewport_size.x / GAME_SET_DESIGN_SIZE.x, viewport_size.y / GAME_SET_DESIGN_SIZE.y)
	if target is Node2D:
		target.scale = Vector2(fit_scale, fit_scale)
		target.position = _host.viewport_center_for_parent(parent) - GAME_SET_DESIGN_SIZE * fit_scale * 0.5
	else:
		target.position = position
	return target


func add_skill_key_set(parent, position, panel_name):
	var target = _host.instance_scene(get_skill_key_set_scene(), parent)
	if target == null:
		return null
	target.position = position
	target.need_name = panel_name
	return target


func add_music_set(parent, position):
	var target = _host.instance_scene(get_music_set_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_ldl(parent, position):
	var target = _host.instance_scene(get_ldl_scene(), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	_host.get_ui_runtime().register_transient_ui(target, &"_on_return_pressed")
	return target


func add_mosaic_help(parent, position):
	var target = _host.instance_scene(get_mosaic_help_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_mosaic_instance(parent, position):
	var target = _host.instance_scene(get_mosaic_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_basic_ar_button(parent, Num):
	var target = _host.instance_scene(get_basic_ar_button_scene(), parent)
	if target == null:
		return null
	target.archive_num = Num
	return target


func add_change_bg(parent, position):
	var target = _host.instance_scene(get_change_bg_scene(), parent)
	if target == null:
		return null
	if target is CanvasLayer:
		target.offset = position
	else:
		target.position = position
	return target


func add_cd_jm(parent, position):
	var target = _host.instance_scene(get_cd_jm_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_gm_infor(parent, position):
	var target = _host.instance_scene(get_game_information_scene(), parent)
	if target == null:
		return null
	# 根节点为 CanvasLayer，没有 position/z_index；迁移前的赋值是静默无效，
	# 其中 z_index 还会触发 SCRIPT ERROR，这里只在 CanvasItem 上写入。
	if target is CanvasItem:
		target.z_index = 99
		target.position = position
	return target


func add_learn_skill(parent, position):
	var target = _host.instance_scene(get_learn_skill_scene(), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	return target

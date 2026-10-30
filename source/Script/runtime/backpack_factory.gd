class_name BackpackFactory
extends Node

## 背包/装备族的场景工厂：持有背包主页、主背包、装备信息、出售、使用法宝、
## 技能选择、角色信息与幻化面板等运行时场景缓存。由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码仍通过 Global.add_* 正式入口调用。

const DataKeys := preload("res://Script/base/data_keys.gd")

const BACK_PACK_PATH := "res://Scene/back_pack/back_pack.tscn"
const MAIN_BACKPACK_PATH := "res://Scene/back_pack/main_backpack.tscn"
const DJ_INFOR_PATH := "res://Scene/back_pack/dj_information.tscn"
const DJ_SELL_PATH := "res://Scene/back_pack/dj_sell.tscn"
const EQU_PROPERTIES_PATH := "res://Scene/back_pack/equipment_properies.tscn"
const PL_SELL_PATH := "res://Scene/back_pack/pl_sell.tscn"
const MAGIC_WEAPON_INFOR_PATH := "res://Scene/back_pack/magic_weapon_infor.tscn"
const BUFF_ICON_PATH := "res://Scene/back_pack/buff.tscn"
const USE_MAGIC_WEAPON_PATH := "res://Scene/back_pack/use_magic_weapon.tscn"
const SKILL_SELECT_PATH := "res://Scene/back_pack/skill_select.tscn"
const SELL_OR_EQU_PATH := "res://Scene/back_pack/sell_or_equ.tscn"
const ROLE_INFORMATION_PATH := "res://Scene/level/role_information.tscn"
const H_HJM_PATH := "res://Scene/other_scene/transmogrified.tscn"

var _host: Node = null
var _scenes: Dictionary = {}


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_scenes.clear()


func _scene(path: String) -> PackedScene:
	var cached: Variant = _scenes.get(path)
	if cached is PackedScene:
		return cached as PackedScene
	var scene: PackedScene = _host.load_cached_scene(path)
	if scene != null:
		_scenes[path] = scene
	return scene


func add_back_pack(parent, position):
	var target = _host.instance_scene(_scene(BACK_PACK_PATH), parent)
	if target == null:
		return null
	_host.configure_backpack_role_preview(target)
	target.position = position - Vector2(481, 297)
	target.z_index = 10
	return target


func add_main_backpack(parent, position):
	var target = _host.instance_scene(_scene(MAIN_BACKPACK_PATH), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_dj_infor(parent, position, _name):
	var target = _host.instance_scene(_scene(DJ_INFOR_PATH), parent)
	if target == null:
		return null
	target.my_name = _name
	target.z_index = 99
	target.position = position
	_host.left_align_popup_texts(target)
	return target


func add_dj_sell(parent, position, _name, _page):
	_host.close_backpack_click_menus(parent)
	var target = _host.instance_scene(_scene(DJ_SELL_PATH), parent)
	if target == null:
		return null
	target.my_page = _page
	target.my_name = _name
	target.z_index = 99
	target.position = position
	return target


func add_equ_propeties_box(parent, position, _name, qh_level, wx, Data):
	var target = _host.instance_scene(_scene(EQU_PROPERTIES_PATH), parent)
	if target == null:
		return null
	target.z_index = 199
	var item_data: Dictionary = Data.duplicate(true) if Data is Dictionary else {}
	var template: Dictionary = AE.all_equipment.get(str(_name), {})
	if item_data.is_empty() and str(template.get("所属", "")) == "宠物装备":
		item_data = template.duplicate(true)
	var item_type := str(item_data.get(DataKeys.TYPE, template.get(DataKeys.TYPE, "")))
	var belongs_to := str(item_data.get("所属", template.get("所属", "")))
	if (item_type == "宠物装备" or belongs_to == "宠物装备") and target.has_method("setup_pet_equipment"):
		var slot_type := str(item_data.get("装备类型", template.get("装备类型", ""))).strip_edges()
		var pet_instance := {
			"名字": str(item_data.get(DataKeys.NAME, template.get(DataKeys.NAME, _name))),
			"强化等级": int(qh_level),
			"类型": slot_type,
			"装备类型": slot_type,
			"Data": item_data,
		}
		if item_data.has("随机属性") and item_data["随机属性"] is Array:
			pet_instance["随机属性"] = (item_data["随机属性"] as Array).duplicate(true)
		target.call("setup_pet_equipment", pet_instance, maxi(0, int(item_data.get("售价", template.get("售价", 0)))))
	else:
		target.qh_level = qh_level
		target.nam = _name
		target.wx = wx
		target.eq_prop = Data
	target.position = position
	_host.left_align_popup_texts(target)
	return target


func add_se_eq_jm(parent, position, _name, _page, _number):
	_host.close_backpack_click_menus(parent)
	var target = _host.instance_scene(_scene(SELL_OR_EQU_PATH), parent)
	if target == null:
		return null
	target.page = _page
	target.number = _number
	target._get_name = _name
	target.z_index = 99
	target.position = position
	return target


func add_pl_sell(parent, position):
	var target = _host.instance_scene(_scene(PL_SELL_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	return target


func add_magp_infor(parent, position):
	var target = _host.instance_scene(_scene(MAGIC_WEAPON_INFOR_PATH), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_use_magic_weapon(parent, position):
	var target = _host.instance_scene(_scene(USE_MAGIC_WEAPON_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = position
	return target


func add_skill_select(parent, position, _name):
	var target = _host.instance_scene(_scene(SKILL_SELECT_PATH), parent)
	if target == null:
		return null
	target.weapon_name = str(_name)
	target.position = position
	return target


func add_role_information(parent, position):
	# 该面板在 _ready 中初始化 buff_box；迁移前就是同步 add_child，保持同步语义。
	var scene: PackedScene = _scene(ROLE_INFORMATION_PATH)
	if scene == null or parent == null or not is_instance_valid(parent):
		return null
	var target = scene.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.z_index = 99
	target.position = position
	return target


func add_h_hjm(parent, position):
	var target = _host.instance_scene(_scene(H_HJM_PATH), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_buff_icon_text(parent, text_):
	var target = _host.instance_scene(_scene(BUFF_ICON_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target._texture = text_
	return target

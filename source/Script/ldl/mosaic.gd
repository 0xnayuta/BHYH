extends Node2D
class_name Mosaic

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var bs_1: Button = $bs_1/bs_1
@onready var bs_2: Button = $bs_2/bs_2
@onready var bs_3: Button = $bs_3/bs_3
@onready var bs_4: Button = $bs_4/bs_4

@onready var bs_5: Button = $bs_5/bs_5
@onready var bs_6: Button = $bs_6/bs_6
@onready var bs_7: Button = $bs_7/bs_7
@onready var bs_8: Button = $bs_8/bs_8
@onready var zb: Button = $zb/Zb

const PET_GENERIC_EQUIPMENT_ICON := preload("res://Art/pet/pet_page_resources/pet_interfacev1270_id267_jpeg3_64x64.png")


func _physics_process(_delta: float) -> void:
	set_box_in_ld_l()

	if PlayerData.player_data[DataKeys.INLAY_LIST].size() != 0:
		set_zb_properies()
		set_other_prop()
	else:
		remove_infomation()


func set_box_in_ld_l():
	bs_1.is_in_ldl_gz = true
	bs_2.is_in_ldl_gz = true
	bs_3.is_in_ldl_gz = true
	bs_4.is_in_ldl_gz = true
	zb.is_in_ldl_gz = true

	bs_5.is_in_ldl_gz = true
	bs_6.is_in_ldl_gz = true
	bs_7.is_in_ldl_gz = true
	bs_8.is_in_ldl_gz = true


func set_zb_properies():
	var selected: Dictionary = PlayerData.player_data[DataKeys.INLAY_LIST][0]
	zb.qh_level = int(selected[DataKeys.ENHANCE_LEVEL])
	zb.get_item_name = str(selected[DataKeys.NAME])
	zb.strength_source = str(selected.get("来源", "装备背包"))
	zb.strength_index = int(selected.get("位置", -1))
	zb.set_meta("equipped_type", str(selected.get("穿戴栏", "")))
	if zb.strength_source == "宠物背包" and selected.get("宠物装备", {}) is Dictionary:
		var pet_item: Dictionary = selected["宠物装备"]
		zb.set_button_icon(_pet_item_icon(pet_item, zb.get_item_name))
		zb.eq_prop = pet_item
	else:
		zb.set_button_icon(load_item_icon(zb.get_item_name))
		zb.eq_prop = selected["Data"]


func set_other_prop():
	var b_ssize = PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM].size()
	var bs_list = [bs_1, bs_2, bs_3, bs_4, bs_5, bs_6, bs_7, bs_8]
	for i in range(bs_list.size()):
		if i < b_ssize:
			bs_list[i].set_button_icon(
				load_item_icon(str(PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM][i]))
			)
		else:
			bs_list[i].set_button_icon(load_item_icon(str("empty")))


func remove_infomation():
	PlayerData.restore_mosaic_equipment()
	zb.set_button_icon(load_item_icon(str("empty")))
	zb.get_item_name = "empty"
	zb.qh_level = 0
	zb.eq_prop = {}
	zb.strength_source = "装备背包"
	zb.strength_index = -1
	zb.set_meta("equipped_type", "")
	bs_1.set_button_icon(load_item_icon(str("empty")))
	bs_2.set_button_icon(load_item_icon(str("empty")))
	bs_3.set_button_icon(load_item_icon(str("empty")))
	bs_4.set_button_icon(load_item_icon(str("empty")))

	bs_5.set_button_icon(load_item_icon(str("empty")))
	bs_6.set_button_icon(load_item_icon(str("empty")))
	bs_7.set_button_icon(load_item_icon(str("empty")))
	bs_8.set_button_icon(load_item_icon(str("empty")))
	PlayerData.player_data[DataKeys.INLAY_LIST].clear()


func _pet_item_icon(item: Dictionary, item_id: String) -> Texture2D:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	for source in [item, data]:
		for key in ["图标", "图标路径", "icon", "Icon"]:
			var icon_path := str(source.get(key, "")).strip_edges()
			if icon_path == "":
				continue
			if not icon_path.begins_with("res://"):
				icon_path = "res://Art/backpack/all_items/" + icon_path
				if icon_path.get_extension() == "":
					icon_path += ".png"
			if ResourceLoader.exists(icon_path):
				return load(icon_path) as Texture2D
	var item_path := "res://Art/backpack/all_items/%s.png" % item_id
	if ResourceLoader.exists(item_path):
		return load(item_path) as Texture2D
	return PET_GENERIC_EQUIPMENT_ICON


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func _on_help_pressed() -> void:
	Global.add_mosaic_help(NodeUtils.ancestor(self, 3), Vector2(0, 0))

extends TextureRect
var _item_hover_inside := false
@onready var item_box: Button = $ItemBox
var _item_hover_popup
@onready var item_num: Label = $Num
@onready var need_value: Label = $Need
@onready var purchase_button: Button = $Purchase
var all_item_list = {
	"Box_1":
	[
		{"Name": "xuantie", "Value": 5, "WX": [], "Level": 0, "Need": 500},
		{"Name": "sichou", "Value": 5, "WX": [], "Level": 0, "Need": 500},
		{"Name": "tanmu", "Value": 5, "WX": [], "Level": 0, "Need": 500}
	],
	"Box_2":
	[
		{"Name": "xuantie", "Value": 10, "WX": [], "Level": 0, "Need": 1000},
		{"Name": "sichou", "Value": 5, "WX": [], "Level": 0, "Need": 1000},
		{"Name": "tanmu", "Value": 10, "WX": [], "Level": 0, "Need": 1000}
	],
	"Box_3":
	[
		{"Name": "xuantie", "Value": 20, "WX": [], "Level": 0, "Need": 2000},
		{"Name": "sichou", "Value": 20, "WX": [], "Level": 0, "Need": 2000},
		{"Name": "tanmu", "Value": 20, "WX": [], "Level": 0, "Need": 2000}
	],
	"Box_4":
	[
		{"Name": "bsd_1", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "bsd_2", "Value": 1, "WX": [], "Level": 0, "Need": 120000},
		{"Name": "qhs_1", "Value": 1, "WX": [], "Level": 0, "Need": 3000},
		{"Name": "qhs_2", "Value": 1, "WX": [], "Level": 0, "Need": 8000},
		{"Name": "qhs_3", "Value": 1, "WX": [], "Level": 0, "Need": 22000},
		{"Name": "qhs_4", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "sms_1", "Value": 1, "WX": [], "Level": 0, "Need": 15000},
		{"Name": "sms_2", "Value": 1, "WX": [], "Level": 0, "Need": 40000},
		{"Name": "fls_1", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "fls_2", "Value": 1, "WX": [], "Level": 0, "Need": 54000},
		{"Name": "gjs_1", "Value": 1, "WX": [], "Level": 0, "Need": 18000},
		{"Name": "gjs_2", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "wfs_1", "Value": 1, "WX": [], "Level": 0, "Need": 12000},
		{"Name": "wfs_2", "Value": 1, "WX": [], "Level": 0, "Need": 32000},
		{"Name": "mfs_1", "Value": 1, "WX": [], "Level": 0, "Need": 12000},
		{"Name": "mfs_2", "Value": 1, "WX": [], "Level": 0, "Need": 32000},
		{"Name": "hxs_1", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "hxs_2", "Value": 1, "WX": [], "Level": 0, "Need": 54000},
		{"Name": "mpyj", "Value": 1, "WX": [], "Level": 0, "Need": 3000},
		{"Name": "yll", "Value": 1, "WX": [], "Level": 0, "Need": 4000},
		{"Name": "renshen", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "shougong", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "lingli", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "liuhuang", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "leizong", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "xianmao", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "dudan", "Value": 3, "WX": [], "Level": 0, "Need": 120000},
		{"Name": "llzsp", "Value": 1, "WX": [], "Level": 0, "Need": 30000},
		{"Name": "flzsp", "Value": 1, "WX": [], "Level": 0, "Need": 30000},
		{"Name": "slzsp", "Value": 1, "WX": [], "Level": 0, "Need": 25000},
		{"Name": "hlzsp", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "tlzsp", "Value": 1, "WX": [], "Level": 0, "Need": 10000},
		{"Name": "rls", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "bsz", "Value": 1, "WX": [], "Level": 0, "Need": 3000}
	],
	"Box_5":
	[
		{"Name": "bsd_5", "Value": 1, "WX": [], "Level": 0, "Need": 2200000},
		{"Name": "bsd_4", "Value": 1, "WX": [], "Level": 0, "Need": 800000},
		{"Name": "bsd_3", "Value": 1, "WX": [], "Level": 0, "Need": 320000},
		{"Name": "llzsp", "Value": 1, "WX": [], "Level": 0, "Need": 30000},
		{"Name": "flzsp", "Value": 1, "WX": [], "Level": 0, "Need": 30000},
		{"Name": "slzsp", "Value": 1, "WX": [], "Level": 0, "Need": 25000},
		{"Name": "hlzsp", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "tlzsp", "Value": 1, "WX": [], "Level": 0, "Need": 10000},
		{"Name": "llz", "Value": 1, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "flz", "Value": 1, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "slz", "Value": 1, "WX": [], "Level": 0, "Need": 60000},
		{"Name": "hlz", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "tlz", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "tss", "Value": 1, "WX": [], "Level": 0, "Need": 70000},
		{"Name": "yhs", "Value": 1, "WX": [], "Level": 0, "Need": 70000},
		{"Name": "putongnmwsz", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "putongzlwsz", "Value": 1, "WX": [], "Level": 0, "Need": 50000}
	]
}
var my_num: int
var new_list = {}
var my_father
var is_open: bool
@onready var mystery_shop_item_box: TextureRect = $"."


func open():
	is_open = true
	item_box.disabled = false
	item_box.visible = true
	item_num.visible = true
	need_value.visible = true
	purchase_button.disabled = false
	purchase_button.visible = true
	mystery_shop_item_box.texture = load("res://Art/shop/shop_item_box.png")
	self.set_box()
	item_num.text = str(AE.all_equipment[new_list["Name"]][DataKeys.NAME]) + "×" + str(new_list["Value"])
	need_value.text = str(new_list["Need"]) + "灵魂"


func close():
	is_open = false
	mystery_shop_item_box.texture = load("res://Art/shop/close_item_box.png")
	item_box.disabled = true
	item_box.visible = false
	item_num.text = ""
	item_num.visible = false
	need_value.text = ""
	need_value.visible = false
	purchase_button.disabled = true
	purchase_button.visible = false


func _ready() -> void:
	basic_set()


func get_list():
	return all_item_list["Box_" + str(my_num)]


func basic_set():
	item_box.is_in_ldl_gz = true
	item_box.is_in_hhgz = true


func set_box():
	var current_list = all_item_list["Box_" + str(my_num)]
	new_list = current_list[randi_range(0, current_list.size() - 1)]
	var type = AE.all_equipment[new_list["Name"]][DataKeys.TYPE]
	match type:
		"武器", "饰品", "防具", "时装", "头衔":
			item_box.qh_level = new_list["Level"]
			item_box.wx = []
		"法宝":
			item_box.wx = new_list["WX"]
		"道具", "消耗品":
			item_box.total_number = new_list["Value"]
	item_box.eq_prop = AE.all_equipment[new_list["Name"]]
	item_box.get_item_name = new_list["Name"]
	item_box.set_meta("item_name", new_list["Name"])
	item_box.set_button_icon(load_item_icon(new_list["Name"]))


func _on_purchase_pressed() -> void:
	if new_list.is_empty():
		Global.add_message_show(Global.windows, "商品信息错误！！", 1.5, Vector2(470, 300))
		return
	var item_name := str(new_list.get("Name", ""))
	var item_data_value: Variant = AE.all_equipment.get(item_name, {})
	if not item_data_value is Dictionary:
		Global.add_message_show(Global.windows, "商品信息错误！！", 1.5, Vector2(470, 300))
		return
	var item_data: Dictionary = item_data_value
	var item_type := str(item_data.get(DataKeys.TYPE, ""))
	var quantity := 1 if item_type in ["武器", "饰品", "防具", "时装", "头衔", "法宝"] else int(new_list.get("Value", 1))
	var result: Dictionary = ShopPurchaseCommand.execute_mystery(
		item_name,
		quantity,
		int(new_list.get("Need", 0)),
		int(new_list.get("Level", 0)),
		new_list.get("WX", []) if new_list.get("WX", []) is Array else []
	)
	if not bool(result.get("ok", false)):
		Global.add_message_show(Global.windows, str(result.get("message", "购买失败！！")), 2.0, Vector2(520, 340))
		return
	Global.add_message_show(Global.windows, "购买成功", 1.5, Vector2(520, 340))
	open_and_close_box()


func open_and_close_box():
	match int(my_num):
		1:
			for i in my_father.child_list1:
				if i.is_open:
					i.open()
			for i in my_father.child_list2:
				if i.is_open:
					return
			if randi_range(0, 100) < 50:
				my_father.item_2.open()
		2:
			self.close()
			my_father.item_1.open()
			if randi_range(0, 100) < 50:
				my_father.item_3.open()
		3:
			self.close()
			my_father.item_1.open()
			if randi_range(0, 100) < 40:
				my_father.item_4.open()
		4:
			self.close()
			my_father.item_1.open()
			if randi_range(0, 100) < 10:
				my_father.item_5.open()
		5:
			self.close()
			my_father.item_1.open()


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func _drive_item_hover(item_box) -> void:
	if item_box == null or not is_instance_valid(item_box):
		return
	if not item_box.visible:
		if _item_hover_inside:
			_item_hover_inside = false
			_hide_item_info()
		return
	var inside = item_box.get_global_rect().has_point(item_box.get_global_mouse_position())
	if inside and not _item_hover_inside:
		_item_hover_inside = true
		_show_item_info(item_box)
	elif inside and _item_hover_popup != null and is_instance_valid(_item_hover_popup):
		Global.apply_popup_screen_layout(_item_hover_popup, Global.screen_popup_position(), _hover_popup_size(item_box))
	elif not inside and _item_hover_inside:
		_item_hover_inside = false
		_hide_item_info()


func _hover_popup_size(item_box) -> Vector2:
	if item_box != null and is_instance_valid(item_box):
		var eq_prop = item_box.eq_prop
		if eq_prop != null and eq_prop.size() > 0 and item_box.item_menu_kind != "item":
			return Vector2(260, 560)
	return Vector2(235, 240)


func _show_item_info(item_box) -> void:
	if item_box == null or not is_instance_valid(item_box):
		return
	if _item_hover_popup != null and is_instance_valid(_item_hover_popup):
		return
	var item_name = item_box.get_item_name
	if (item_name == "" or item_name == "empty") and item_box.has_meta("item_name"):
		item_name = str(item_box.get_meta("item_name"))
	if item_name == "" or item_name == "empty" or not AE.all_equipment.has(item_name):
		return
	var parent_node = Global.get_ui_popup_layer()
	var popup_pos = Global.screen_popup_position()
	var eq_prop = item_box.eq_prop
	if eq_prop != null and eq_prop.size() > 0 and item_box.item_menu_kind != "item":
		_item_hover_popup = Global.add_equ_propeties_box(
			parent_node, popup_pos, item_name, item_box.qh_level, item_box.wx, eq_prop
		)
	else:
		_item_hover_popup = Global.add_dj_infor(parent_node, popup_pos, item_name)
	if _item_hover_popup != null:
		Global.register_hover_popup(_item_hover_popup)
		_item_hover_popup.top_level = true
		_item_hover_popup.z_index = 9999
		_item_hover_popup.visible = true


func _hide_item_info() -> void:
	Global.clear_hover_popup()
	_item_hover_popup = null

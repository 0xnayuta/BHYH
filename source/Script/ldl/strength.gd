extends Node2D
class_name Strength

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

const PET_GENERIC_EQUIPMENT_ICON := preload("res://Art/pet/pet_page_resources/pet_interfacev1270_id267_jpeg3_64x64.png")
@onready var lh_text = $need_lh/lh
@onready var old_zb = $old_zb/old_zb
@onready var new_zb = $new_zb/new_zb
@onready var n_q_1: Button = $n_q_1/n_q_1
@onready var n_q_2: Button = $n_q_2/n_q_2
@onready var num_b1 = $n_q_1/n_q_1/number
@onready var num_b2 = $n_q_2/n_q_2/number2
var old_zb_name = "empty"
var new_zb_name = "empty"
var qhs_1_name = "empty"
var qhs_2_name = "empty"
var data = {}
var qh_level = -1
var qhs_1_num = 0
var qhs_2_num = 0
var need_lh: int


func _get_strength_max_level(item_name: String) -> int:
	var item: Dictionary = MLdl.qh_list.get("Data", {}) if MLdl.qh_list.get("Data", {}) is Dictionary else {}
	return PlayerData.get_equipment_strength_max_level(item, item_name)


func _ready() -> void:
	n_q_1.is_in_ldl_gz = true
	n_q_2.is_in_ldl_gz = true
	old_zb.is_in_ldl_gz = true
	new_zb.is_in_ldl_gz = true


func _physics_process(_delta: float) -> void:
	n_q_1.is_in_ldl_gz = true
	n_q_2.is_in_ldl_gz = true
	old_zb.is_in_ldl_gz = true
	new_zb.is_in_ldl_gz = true
	if MLdl.qh_list[DataKeys.NAME] != "":
		old_zb_name = MLdl.qh_list[DataKeys.NAME]
	qh_level = MLdl.qh_list[DataKeys.ENHANCE_LEVEL]
	data = MLdl.qh_list["Data"]
	get_qhs_name()
	set_color()
	set_str_info()


func set_str_info():
	new_zb_name = old_zb_name
	n_q_1.set_button_icon(load_item_icon(str(qhs_1_name)))
	n_q_2.set_button_icon(load_item_icon(str(qhs_2_name)))
	var equipment_icon := _selected_equipment_icon()
	old_zb.set_button_icon(equipment_icon)
	old_zb.get_item_name = old_zb_name
	old_zb.set_meta("item_name", old_zb_name)
	old_zb.qh_level = qh_level
	old_zb.eq_prop = data
	old_zb.strength_source = str(MLdl.qh_list.get("来源", "装备背包"))
	old_zb.strength_index = int(MLdl.qh_list.get("位置", -1))
	new_zb.set_button_icon(equipment_icon)
	new_zb.get_item_name = new_zb_name
	new_zb.set_meta("item_name", new_zb_name)
	new_zb.eq_prop = data
	new_zb.strength_source = old_zb.strength_source
	new_zb.strength_index = old_zb.strength_index
	var max_level = _get_strength_max_level(old_zb_name)
	new_zb.qh_level = min(qh_level + 1, max_level)
	if qh_level >= max_level:
		num_b1.text = "已满级"
		num_b2.text = ""
		lh_text.text = "0"
		return
	if qhs_1_num > 0:
		num_b1.text = str(PlayerData.get_item_data(qhs_1_name)) + "/" + str(qhs_1_num)
	else:
		num_b1.text = ""
	if qhs_2_num > 0:
		num_b2.text = str(PlayerData.get_item_data(qhs_2_name)) + "/" + str(qhs_2_num)
	else:
		num_b2.text = ""
	lh_text.text = str(need_lh)


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func _selected_equipment_icon() -> Texture2D:
	if str(MLdl.qh_list.get("来源", "装备背包")) != "宠物背包":
		return load_item_icon(str(old_zb_name))
	var item: Dictionary = data if data is Dictionary else {}
	var nested: Dictionary = item.get("data", {}) if item.get("data", {}) is Dictionary else {}
	for source in [item, nested]:
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
	var named_path := "res://Art/backpack/all_items/%s.png" % old_zb_name
	if ResourceLoader.exists(named_path):
		return load(named_path) as Texture2D
	return PET_GENERIC_EQUIPMENT_ICON


func set_color():
	if PlayerData.get_item_data(qhs_1_name) < qhs_1_num:
		num_b1.add_theme_color_override("font_color", Color("FF0000"))
	else:
		num_b1.add_theme_color_override("font_color", Color("00FF00"))
	if PlayerData.get_item_data(qhs_2_name) < qhs_2_num:
		num_b2.add_theme_color_override("font_color", Color("FF0000"))
	else:
		num_b2.add_theme_color_override("font_color", Color("00FF00"))


func _on_qh_pressed() -> void:
	var selected_name: String = str(MLdl.qh_list.get(DataKeys.NAME, ""))
	var selected_data: Dictionary = MLdl.qh_list.get("Data", {}) if MLdl.qh_list.get("Data", {}) is Dictionary else {}
	var template_data: Dictionary = AE.all_equipment.get(selected_name, {})
	if (
		bool(selected_data.get("不可强化", template_data.get("不可强化", false)))
		and selected_name not in ["cjxianjie", "cdxianjie", "zhxianjie"]
	):
		Global.add_message_show(get_parent(), "该装备无法强化！", 1.5, Vector2(15, -45))
		return
	if old_zb_name == "empty" or new_zb_name == "empty" or selected_name == "":
		Global.add_message_show(Global.windows, "请先选择一件装备！！！", 1.5, Vector2(470, 295))
		return
	var position_index: int = int(MLdl.qh_list.get("位置", -1))
	var equipment: Variant = _get_selected_equipment(position_index)
	if not (equipment is Dictionary):
		_show_invalid_strength_selection()
		return
	var current_level = int(equipment.get(DataKeys.ENHANCE_LEVEL, 0))
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = current_level
	qh_level = current_level
	var type = AE.all_equipment.get(MLdl.qh_list[DataKeys.NAME], {}).get(DataKeys.QUALITY, "")
	var max_level: int = _get_strength_max_level(MLdl.qh_list[DataKeys.NAME])
	if current_level >= max_level:
		Global.add_message_show(get_parent(), str(type) + "品质装备最高强化" + str(max_level) + "级！！", 1.5, Vector2(15, -45))
		return
	old_zb_name = MLdl.qh_list[DataKeys.NAME]
	if PlayerData.get_item_data(qhs_1_name) < qhs_1_num or PlayerData.get_item_data(qhs_2_name) < qhs_2_num:
		Global.add_message_show(get_parent(), "强化石数量不足！！", 1.5, Vector2(15, -45))
		return
	if PlayerData.get_soul() < need_lh:
		Global.add_message_show(get_parent(), "灵魂不足！无法强化！！", 1.5, Vector2(15, -45))
		return

	var snapshot: Dictionary = PlayerData.snapshot_state()
	equipment[DataKeys.ENHANCE_LEVEL] = current_level + 1
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = current_level + 1
	qh_level = current_level + 1
	if not PlayerData.spend_soul(need_lh):
		PlayerData.restore_state(snapshot)
		Global.add_message_show(get_parent(), "灵魂不足！无法强化！！", 1.5, Vector2(15, -45))
		return
	var removed_1: Dictionary = PlayerData.remove_dj(qhs_1_name, PlayerData.get_dj_page(qhs_1_name), qhs_1_num)
	var removed_2: Dictionary = PlayerData.remove_dj(qhs_2_name, PlayerData.get_dj_page(qhs_2_name), qhs_2_num)
	if int(removed_1.get("卖出数量", 0)) < qhs_1_num or int(removed_2.get("卖出数量", 0)) < qhs_2_num:
		PlayerData.restore_state(snapshot)
		get_qhs_name()
		set_str_info()
		Global.add_message_show(get_parent(), "强化石数量不足！！", 1.5, Vector2(15, -45))
		return
	get_qhs_name()
	set_str_info()
	_refresh_equipped_strength()
	if not MemoryClass.request_save("ldl_strength"):
		PlayerData.restore_state(snapshot)
		get_qhs_name()
		set_str_info()
		_refresh_equipped_strength()
		Global.add_message_show(
			get_parent(), "存档保存失败，本次强化已撤销：%s" % MemoryClass.describe_save_error(), 2.0, Vector2(15, -45)
		)
		return
	Global.add_message_show(get_parent(), "强化成功！！", 1.5, Vector2(15, -45))


func _refresh_equipped_strength() -> void:
	if str(MLdl.qh_list.get("来源", "装备背包")) != "人物穿戴":
		return
	RoleProp.get_equ_last_pro()
	RoleProp.get_last_prop()
	if is_instance_valid(RoleProp.source_player):
		RoleProp.source_player.on_eqchange()


func _get_selected_equipment(position_index: int) -> Variant:
	var source := str(MLdl.qh_list.get("来源", "装备背包"))
	var equipment_list: Variant
	if source == "宠物背包":
		equipment_list = PlayerData.ensure_shared_pet_backpack()
	elif source == "人物穿戴":
		var slot_type := str(MLdl.qh_list.get("穿戴栏", ""))
		var equipped_value: Variant = PlayerData.player_data.get(slot_type, [])
		if not (equipped_value is Array):
			return null
		equipment_list = equipped_value
		position_index = 0
	else:
		var equipment_pages: Variant = PlayerData.player_data.get(DataKeys.EQUIPMENT_LIST, {})
		var page_number: int = int(MLdl.qh_list.get("页码", 0))
		var page_key := "页码" + str(page_number)
		if page_number < 1 or not (equipment_pages is Dictionary) or not equipment_pages.has(page_key):
			return null
		equipment_list = equipment_pages[page_key]
	if not (equipment_list is Array) or position_index < 0 or position_index >= equipment_list.size():
		return null
	var equipment: Variant = equipment_list[position_index]
	if not (equipment is Dictionary):
		return null
	if source == "宠物背包":
		if not is_same(equipment, MLdl.qh_list.get("Data", {})):
			return null
	elif str(equipment.get(DataKeys.NAME, "")) != str(MLdl.qh_list.get(DataKeys.NAME, "")):
		return null
	return equipment


func _show_invalid_strength_selection() -> void:
	Global.add_message_show(Global.windows, "装备位置已变化，请重新选择装备！", 1.5, Vector2(470, 295))
	remove_infomation()


func get_qhs_name():
	if qh_level == -1:
		qhs_1_name = "empty"
		qhs_2_name = "empty"
		qhs_1_num = 0
		qhs_2_num = 0
		need_lh = int("???")
	elif qh_level == 0:
		qhs_1_name = "qhs_1"
		qhs_2_name = "qhs_2"
		qhs_1_num = 4
		qhs_2_num = 2
		need_lh = 0
	elif qh_level == 1:
		qhs_1_name = "qhs_1"
		qhs_2_name = "qhs_2"
		qhs_1_num = 6
		qhs_2_num = 4
		need_lh = 300
	elif qh_level == 2:
		qhs_1_name = "qhs_2"
		qhs_2_name = "qhs_3"
		qhs_1_num = 9
		qhs_2_num = 6
		need_lh = 600
	elif qh_level == 3:
		qhs_1_name = "qhs_2"
		qhs_2_name = "qhs_3"
		qhs_1_num = 12
		qhs_2_num = 9
		need_lh = 900
	elif qh_level == 4:
		qhs_1_name = "qhs_2"
		qhs_2_name = "qhs_3"
		qhs_1_num = 18
		qhs_2_num = 12
		need_lh = 1500
	elif qh_level == 5:
		qhs_1_name = "qhs_3"
		qhs_2_name = "qhs_4"
		qhs_1_num = 24
		qhs_2_num = 18
		need_lh = 20000
	elif qh_level >= 6:
		qhs_1_name = "qhs_3"
		qhs_2_name = "qhs_4"
		qhs_1_num = 60 + (qh_level - 6) * 10
		qhs_2_num = 36 + (qh_level - 6) * 10
		need_lh = 100000 + (qh_level - 6) * 10000


func remove_infomation():
	old_zb_name = "empty"
	new_zb_name = "empty"
	qhs_1_name = "empty"
	qhs_2_name = "empty"
	qh_level = -1
	qhs_1_num = 0
	qhs_2_num = 0
	MLdl.qh_list[DataKeys.NAME] = ""
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = -1
	MLdl.qh_list["页码"] = 0
	MLdl.qh_list["位置"] = 0
	MLdl.qh_list["来源"] = "装备背包"
	MLdl.qh_list["穿戴栏"] = ""
	MLdl.qh_list["Data"] = {}
	MemoryClass.request_save("ldl_strength_remove")

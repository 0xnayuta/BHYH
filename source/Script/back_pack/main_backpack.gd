extends Control
@onready var coin_number: Label = $coin_text/coin_number
@onready var tab_bar: TabBar = $MarginContainer/VBoxContainer/TabBar
@onready var current_page_text: Label = $ChangePage/CurrentPageText
@onready var title: Label = $MarginContainer/VBoxContainer/title
@onready var pl_sell = $MarginContainer/VBoxContainer/HBoxContainer/pl_sell
@onready var pet_backpack_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/pet_backpack
@onready var timer: Timer = $Timer
@onready var sort_button: Button = $SortButton

const PET_ITEMS_PER_PAGE := 25
const PET_GENERIC_EQUIPMENT_ICON := preload("res://Art/pet/pet_page_resources/pet_interfacev1270_id267_jpeg3_64x64.png")
const EQUIPMENT_ITEMS_PER_PAGE := 25
const LDL_EQUIPPED_SLOT_TYPES := ["武器", "防具", "饰品", "神骨", "法宝", "头衔", "时装", "翅膀"]
var current_fl = 0
var current_page = 1
var max_page: int = 20
var sell_panel
var is_in_ldl
var message
var choose_list = []
var choose_ms: bool
var pet_item_id_cache: Dictionary = {}


func _ready() -> void:
	title.text = "装备背包"
	sort_button.pressed.connect(_on_sort_pressed)

	set_box_data()


func _physics_process(_delta: float) -> void:
	sort_button.disabled = Global.is_in_ldl or choose_ms or is_instance_valid(sell_panel)
	if not PlayerData.player_data["ieho"]:
		if PlayerData.check_have_zb("xczg")[0]:
			PlayerData.player_data["ieho"] = true
	var show_pet_backpack: bool = Global.is_in_ldl == true and str(MLdl.current_mode) in ["强化", "镶嵌"]
	pet_backpack_button.visible = show_pet_backpack
	pl_sell.visible = not show_pet_backpack
	if current_fl == 3 and not show_pet_backpack:
		current_fl = 0
		current_page = 1
	_update_max_page()
	current_page_text.text = str(current_page) + "/" + str(max_page)
	if Global.is_in_ldl:
		pl_sell.disabled = true
	else:
		pl_sell.disabled = false
	coin_number.text = str(PlayerData.get_soul())


func _set_box_item(box, item_name: String, qh_level := 0, total_num := 0, eq_prop = {}, wx_list := []) -> void:
	box.set_button_icon(load_item_icon(item_name))
	box.get_item_name = item_name
	box.set_meta("item_name", item_name)
	box.qh_level = qh_level
	box.total_number = total_num
	box.eq_prop = eq_prop
	box.item_locked = eq_prop is Dictionary and bool(eq_prop.get("锁定", false))
	box.wx = wx_list
	box.strength_source = "装备背包"
	box.strength_index = -1


func _set_pet_box_item(box, item: Dictionary, item_index: int) -> void:
	var item_id := _pet_item_id(item)
	box.set_button_icon(_pet_item_icon(item, item_id))
	box.get_item_name = item_id
	box.set_meta("item_name", item_id)
	box.qh_level = int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	box.total_number = 0
	box.eq_prop = item
	box.item_locked = false
	box.wx = []
	box.current_page = current_page
	box.strength_source = "宠物背包"
	box.strength_index = item_index


func _pet_item_id(item: Dictionary) -> String:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	for source in [item, data]:
		for key in ["物品ID", "ID", "id"]:
			var candidate := str(source.get(key, "")).strip_edges()
			if AE.all_equipment.has(candidate):
				return candidate
		for key in ["图标", "图标路径", "icon", "Icon"]:
			var candidate := str(source.get(key, "")).get_file().get_basename()
			if AE.all_equipment.has(candidate):
				return candidate
	var stored_name := (
		str(
			item.get(
				DataKeys.NAME, item.get(DataKeys.ALT_NAME, data.get(DataKeys.NAME, data.get(DataKeys.ALT_NAME, "")))
			)
		)
		. strip_edges()
	)
	if AE.all_equipment.has(stored_name):
		return stored_name
	if pet_item_id_cache.has(stored_name):
		return str(pet_item_id_cache[stored_name])
	for item_id in AE.all_equipment:
		if str(AE.all_equipment[item_id].get(DataKeys.NAME, "")) == stored_name:
			pet_item_id_cache[stored_name] = str(item_id)
			return str(item_id)
	var fallback := stored_name if stored_name != "" else "宠物装备"
	pet_item_id_cache[stored_name] = fallback
	return fallback


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


func _set_box_empty(box) -> void:
	box.set_button_icon(load_item_icon("empty"))
	box.get_item_name = "empty"
	box.set_meta("item_name", "empty")
	box.qh_level = 0
	box.total_number = 0
	box.eq_prop = {}
	box.item_locked = false
	box.wx = []
	box.strength_source = "装备背包"
	box.strength_index = -1
	box.set_meta("equipped_type", "")
	box.set_meta("backpack_page", 0)
	box.set_meta("backpack_index", -1)


func _mark_box_kind(box, kind: String) -> void:
	box.strength_source = "宠物背包" if kind == "pet_equipment" else "装备背包"
	if kind != "pet_equipment":
		box.strength_index = -1


func _get_ldl_equipment_entries() -> Array:
	var entries: Array = []
	var ldl_type_filter := "神骨" if str(MLdl.current_mode) == "淬骨" else ""
	for slot_type in LDL_EQUIPPED_SLOT_TYPES:
		var equipped_value: Variant = PlayerData.player_data.get(slot_type, [])
		if not (equipped_value is Array) or (equipped_value as Array).is_empty():
			continue
		var equipped_item: Variant = (equipped_value as Array)[0]
		if not (equipped_item is Dictionary):
			continue
		var item_name := str((equipped_item as Dictionary).get(DataKeys.NAME, ""))
		if item_name == "" or not AE.all_equipment.has(item_name):
			continue
		if ldl_type_filter != "" and str(AE.all_equipment[item_name].get(DataKeys.TYPE, "")) != ldl_type_filter:
			continue
		(
			entries
			. push_back(
				{
					"item": equipped_item,
					"source": "人物穿戴",
					"page": 0,
					"index": 0,
					"装备栏": slot_type,
				}
			)
		)

	var equipment_pages: Variant = PlayerData.player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if equipment_pages is Dictionary:
		for page_index in range(equipment_pages.size()):
			var page_number: int = page_index + 1
			var page_value: Variant = equipment_pages.get("页码" + str(page_number), [])
			if not (page_value is Array):
				continue
			var page: Array = page_value
			for item_index in range(page.size()):
				var item_value: Variant = page[item_index]
				if item_value is Dictionary:
					var item_name := str((item_value as Dictionary).get(DataKeys.NAME, ""))
					if (
						ldl_type_filter != ""
						and (
							not AE.all_equipment.has(item_name)
							or str(AE.all_equipment[item_name].get(DataKeys.TYPE, "")) != ldl_type_filter
						)
					):
						continue
					(
						entries
						. push_back(
							{
								"item": item_value,
								"source": "装备背包",
								"page": page_number,
								"index": item_index,
								"装备栏": "",
							}
						)
					)
	return entries


func _set_ldl_equipment_box_data() -> void:
	title.text = "装备背包"
	var entries := _get_ldl_equipment_entries()
	var first_index: int = (int(current_page) - 1) * EQUIPMENT_ITEMS_PER_PAGE
	var last_index: int = mini(first_index + EQUIPMENT_ITEMS_PER_PAGE, entries.size())
	var x := 1
	for entry_index in range(first_index, last_index):
		var entry: Dictionary = entries[entry_index]
		var item: Dictionary = entry.get("item", {})
		var item_name := str(item.get(DataKeys.NAME, ""))
		if item_name == "" or not AE.all_equipment.has(item_name):
			continue
		var item_data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
		var item_type := str(AE.all_equipment[item_name].get(DataKeys.TYPE, ""))
		var wx_list: Variant = item.get(DataKeys.FIVE_ELEMENTS, []) if item_type == "法宝" else []
		var box = target_box(x)
		_set_box_item(box, item_name, int(item.get(DataKeys.ENHANCE_LEVEL, 0)), 0, item_data, wx_list)
		box.current_page = int(entry.get("page", 0))
		box.strength_source = str(entry.get("source", "装备背包"))
		box.strength_index = int(entry.get("index", -1))
		box.set_meta("equipped_type", str(entry.get("装备栏", "")))
		box.set_meta("backpack_page", int(entry.get("page", 0)))
		box.set_meta("backpack_index", int(entry.get("index", -1)))
		x += 1
	while x < 26:
		_set_box_empty(target_box(x))
		target_box(x).current_page = current_page
		x += 1


func set_box_data():
	match current_fl:
		0:
			if Global.is_in_ldl:
				_set_ldl_equipment_box_data()
				return
			title.text = "装备背包"
			var x = 1
			for i in PlayerData.player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(current_page)]:
				target_box(x).set_button_icon(load_item_icon(str(i.名字)))
				target_box(x).get_item_name = str(i.名字)
				target_box(x).set_meta("item_name", str(i.名字))
				target_box(x).qh_level = i.强化等级
				target_box(x).eq_prop = i.Data
				target_box(x).item_locked = bool(i.Data.get("锁定", false))
				if AE.all_equipment[i.名字][DataKeys.TYPE] == "法宝":
					target_box(x).wx = i.五行
				else:
					target_box(x).wx = []
				target_box(x).current_page = current_page
				_mark_box_kind(target_box(x), "equipment")
				x += 1
			while x < 26:
				_set_box_empty(target_box(x))
				_mark_box_kind(target_box(x), "")
				target_box(x).current_page = current_page
				x += 1
		1:
			title.text = "道具背包"
			var x = 1
			for i in PlayerData.player_data[DataKeys.ITEM_LIST]["页码" + str(current_page)]:
				target_box(x).set_button_icon(load_item_icon(str(i.名字)))
				target_box(x).get_item_name = str(i.名字)
				target_box(x).set_meta("item_name", str(i.名字))
				target_box(x).total_number = i.数量
				target_box(x).item_locked = bool(i.get("锁定", false))
				target_box(x).current_page = current_page
				_mark_box_kind(target_box(x), "item")
				target_box(x).eq_prop = {}
				x += 1
			while x < 26:
				_set_box_empty(target_box(x))
				_mark_box_kind(target_box(x), "")
				target_box(x).current_page = current_page
				x += 1
			pass
		2:
			title.text = "消耗品背包"
			var x = 1
			for i in PlayerData.player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(current_page)]:
				target_box(x).set_button_icon(load_item_icon(str(i.名字)))
				target_box(x).get_item_name = str(i.名字)
				target_box(x).set_meta("item_name", str(i.名字))
				target_box(x).total_number = i.数量
				target_box(x).eq_prop = {}
				target_box(x).item_locked = bool(i.get("锁定", false))
				target_box(x).current_page = current_page
				_mark_box_kind(target_box(x), "item")
				x += 1
			while x < 26:
				_set_box_empty(target_box(x))
				_mark_box_kind(target_box(x), "")
				target_box(x).current_page = current_page
				x += 1
			pass
		3:
			title.text = "宠物背包"
			var pet_backpack: Array = PlayerData.ensure_shared_pet_backpack()
			var first_index: int = (current_page - 1) * PET_ITEMS_PER_PAGE
			var last_index: int = mini(first_index + PET_ITEMS_PER_PAGE, pet_backpack.size())
			var x = 1
			for item_index in range(first_index, last_index):
				var item: Variant = pet_backpack[item_index]
				if item is Dictionary:
					_set_pet_box_item(target_box(x), item, item_index)
					_mark_box_kind(target_box(x), "pet_equipment")
					x += 1
			while x < 26:
				_set_box_empty(target_box(x))
				_mark_box_kind(target_box(x), "")
				target_box(x).current_page = current_page
				x += 1


func target_box(num):
	var target = get_node("MarginContainer/VBoxContainer/MarginContainer/Sc_Box/Gd_Box/box_" + str(num))
	return target


func set_empty_box():
	for i in range(25):
		_set_box_empty(target_box(i + 1))
		_mark_box_kind(target_box(i + 1), "")


func load_item_icon(_name):
	var item_id := str(_name)
	var item_data: Dictionary = AE.all_equipment.get(item_id, {})
	var data_icon_path := str(item_data.get("图标", ""))
	if data_icon_path != "" and ResourceLoader.exists(data_icon_path):
		return load(data_icon_path)
	var icon_path := "res://Art/backpack/all_items/" + item_id + ".png"
	if ResourceLoader.exists(icon_path):
		return load(icon_path)
	return load("res://Art/backpack/all_items/empty.png")


func _on_button_pressed() -> void:
	randomize()


func _on_add_xhp_pressed() -> void:
	pass


func _on_add_dj_pressed() -> void:
	randomize()
	PlayerData.add_dj("qhs_1", 2)


func _on_bulk_sell_pressed() -> void:
	if sell_panel == null:
		sell_panel = Global.add_pl_sell(pl_sell, Vector2(90, 0))
		sell_panel.main_back = self
		sell_panel.tree_exited.connect(_on_sell_panel_exited, CONNECT_ONE_SHOT)
	elif sell_panel != null:
		remove_choose()
		sell_panel.queue_free()


func _on_sell_panel_exited() -> void:
	sell_panel = null


func remove_choose():
	choose_ms = false
	choose_list.clear()


func _on_sort_pressed() -> void:
	if Global.is_in_ldl or choose_ms or is_instance_valid(sell_panel):
		return
	if not PlayerData.organize_backpack():
		return
	remove_choose()
	current_page = 1
	set_box_data()
	MemoryClass.request_save("back_pack_sort")


func _on_zb_pressed() -> void:
	current_fl = 0
	current_page = 1
	PlayerData.zl_zb()
	PlayerData.zl_dj()
	PlayerData.zl_xhp()


func _on_dj_pressed() -> void:
	current_fl = 1
	current_page = 1
	PlayerData.zl_zb()
	PlayerData.zl_dj()
	PlayerData.zl_xhp()


func _on_xhp_pressed() -> void:
	current_fl = 2
	current_page = 1
	PlayerData.zl_zb()
	PlayerData.zl_dj()
	PlayerData.zl_xhp()


func _on_pet_backpack_pressed() -> void:
	if not Global.is_in_ldl or str(MLdl.current_mode) not in ["强化", "镶嵌"]:
		return
	current_fl = 3
	current_page = 1
	set_box_data()


func _update_max_page() -> void:
	if current_fl == 3:
		var pet_backpack: Array = PlayerData.ensure_shared_pet_backpack()
		max_page = maxi(1, ceili(float(pet_backpack.size()) / PET_ITEMS_PER_PAGE))
	elif current_fl == 0 and Global.is_in_ldl:
		var equipment_count := _get_ldl_equipment_entries().size()
		max_page = maxi(1, ceili(float(equipment_count) / EQUIPMENT_ITEMS_PER_PAGE))
	else:
		max_page = 20
	current_page = clampi(current_page, 1, max_page)


func _on_timer_timeout() -> void:
	set_box_data()


func add_text(parent, text):
	if message == null:
		message = Global.add_touch_text(parent, Vector2(120, 40), text)


func remove_message():
	if message != null:
		message.queue_free()


func _on_last_page_pressed() -> void:
	if current_page > 1:
		current_page -= 1
	if current_page <= 1:
		current_page = 1
	set_box_data()


func _on_next_page_pressed() -> void:
	if current_page < max_page:
		current_page += 1
	if current_page >= max_page:
		current_page = max_page
	set_box_data()

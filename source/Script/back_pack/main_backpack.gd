extends Control

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

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
## 已填格内容的显示投影快照：与实时投影逐值比较，完全相等才跳过重填。
var _grid_snapshot: Array = []
## 已填格交给 box 的容器引用（Data / 法宝五行 / 宠物装备字典）：用 `is_same()` 查身份替换。
var _grid_refs: Array = []


func _ready() -> void:
	title.text = "装备背包"
	sort_button.pressed.connect(_on_sort_pressed)

	set_box_data()


func _physics_process(_delta: float) -> void:
	sort_button.disabled = Global.get_ui_runtime().is_ldl_mode_active() or choose_ms or is_instance_valid(sell_panel)
	if not PlayerData.player_data["ieho"]:
		if PlayerData.check_have_zb("xczg")[0]:
			PlayerData.player_data["ieho"] = true
	var show_pet_backpack: bool = (
		Global.get_ui_runtime().is_ldl_mode_active() == true and str(MLdl.current_mode) in ["强化", "镶嵌"]
	)
	pet_backpack_button.visible = show_pet_backpack
	pl_sell.visible = not show_pet_backpack
	if current_fl == 3 and not show_pet_backpack:
		current_fl = 0
		current_page = 1
	_update_max_page()
	current_page_text.text = str(current_page) + "/" + str(max_page)
	if Global.get_ui_runtime().is_ldl_mode_active():
		pl_sell.disabled = true
	else:
		pl_sell.disabled = false
	coin_number.text = str(PlayerData.get_soul())


func _set_box_item(box, item_name: String, qh_level := 0, total_num := 0, eq_prop = {}, wx_list := []) -> void:
	box.set_button_icon(ItemUtils.item_icon_with_empty_fallback(item_name))
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
			if EquipmentService.has(candidate):
				return candidate
		for key in ["图标", "图标路径", "icon", "Icon"]:
			var candidate := str(source.get(key, "")).get_file().get_basename()
			if EquipmentService.has(candidate):
				return candidate
	var stored_name := (
		str(
			item.get(
				DataKeys.NAME, item.get(DataKeys.ALT_NAME, data.get(DataKeys.NAME, data.get(DataKeys.ALT_NAME, "")))
			)
		)
		. strip_edges()
	)
	if EquipmentService.has(stored_name):
		return stored_name
	if pet_item_id_cache.has(stored_name):
		return str(pet_item_id_cache[stored_name])
	for item_id in EquipmentService.ids():
		if str(EquipmentService.data(item_id).get(DataKeys.NAME, "")) == stored_name:
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
	box.set_button_icon(ItemUtils.item_icon_with_empty_fallback("empty"))
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


## 当前视图状态：[显示投影, 引用列表]。
## 显示投影只取真正写进 25 格的显示字段，可变子数据保存实时引用，与 `_grid_snapshot` 深拷贝逐值比较；
## 引用列表保存填格时交给 box 的容器引用，供 `is_same()` 识别“同内容但换了字典/数组”的替换。
func _current_grid_state() -> Array:
	var ldl_active := Global.get_ui_runtime().is_ldl_mode_active()
	var projection: Array = [int(current_fl), int(current_page), ldl_active]
	var refs: Array = []
	match int(current_fl):
		0:
			if ldl_active:
				projection.push_back(str(MLdl.current_mode))
				var window: Array = _scan_ldl_equipment(false)[1] as Array
				projection.append_array(window)
				# 每条窗口条目为 5 个扁平值；填格把 Data（法宝再加五行）引用直接交给 box。
				for window_index in range(0, window.size(), 5):
					var window_item: Dictionary = window[window_index]
					var window_data: Variant = window_item.get("Data", null)
					if window_data is Dictionary:
						refs.push_back(window_data)
					if _is_magic_weapon_item(window_item) and window_item.has(DataKeys.FIVE_ELEMENTS):
						refs.push_back(window_item[DataKeys.FIVE_ELEMENTS])
				return [projection, refs]
			var page_items: Variant = _page_items(DataKeys.EQUIPMENT_LIST)
			if not (page_items is Array):
				return [projection, refs]
			for item in page_items:
				if not (item is Dictionary):
					projection.push_back(item)
					continue
				var item_dict: Dictionary = item
				var item_name := str(item_dict.get(DataKeys.NAME, ""))
				var is_magic_weapon := _is_magic_weapon_item(item_dict)
				var item_wx: Variant = item_dict.get(DataKeys.FIVE_ELEMENTS, []) if is_magic_weapon else []
				# 填格读取名字、强化等级、Data（含锁定）与法宝五行。
				projection.push_back(item_name)
				projection.push_back(item_dict.get(DataKeys.ENHANCE_LEVEL, 0))
				projection.push_back(item_dict.get("Data", {}))
				projection.push_back(item_wx)
				# 只在键存在时登记，避免把 `get()` 的临时默认值当成模型引用。
				if item_dict.has("Data"):
					refs.push_back(item_dict["Data"])
				if is_magic_weapon and item_dict.has(DataKeys.FIVE_ELEMENTS):
					refs.push_back(item_dict[DataKeys.FIVE_ELEMENTS])
			return [projection, refs]
		1:
			_append_material_projection(projection, DataKeys.ITEM_LIST)
			return [projection, refs]
		2:
			_append_material_projection(projection, DataKeys.CONSUMABLE_LIST)
			return [projection, refs]
		3:
			var shared: Variant = PlayerData.player_data.get(PlayerDataStore.PET_BACKPACK_KEY, null)
			if not (shared is Array):
				return [projection, refs]
			var pet_backpack: Array = shared
			var first_index: int = (int(current_page) - 1) * PET_ITEMS_PER_PAGE
			var last_index: int = mini(first_index + PET_ITEMS_PER_PAGE, pet_backpack.size())
			for item_index in range(first_index, last_index):
				# 宠物格由整份物品字典填格（图标、强化等级、eq_prop 均取自它）。
				var pet_item: Variant = pet_backpack[item_index]
				projection.push_back(pet_item)
				refs.push_back(pet_item)
			return [projection, refs]
	return [projection, refs]


## 快照命中：显示投影逐值相等，且 25 格交给 box 的引用身份全部未变。
func _grid_state_matches() -> bool:
	var state := _current_grid_state()
	if state[0] != _grid_snapshot:
		return false
	var live_refs: Array = state[1]
	if live_refs.size() != _grid_refs.size():
		return false
	for ref_index in range(live_refs.size()):
		if not is_same(live_refs[ref_index], _grid_refs[ref_index]):
			return false
	return true


## 道具/消耗品页：填格只写名字、数量与顶层锁定。
func _append_material_projection(projection: Array, list_key: String) -> void:
	var page_items: Variant = _page_items(list_key)
	if not (page_items is Array):
		return
	for item in page_items:
		if not (item is Dictionary):
			projection.push_back(item)
			continue
		projection.push_back(str((item as Dictionary).get(DataKeys.NAME, "")))
		projection.push_back((item as Dictionary).get(DataKeys.COUNT, 0))
		projection.push_back(bool((item as Dictionary).get("锁定", false)))


## 取当前背包页数组；缺失时返回 null，填格保持原有失败语义。
func _page_items(list_key: String) -> Variant:
	var lists: Variant = PlayerData.player_data.get(list_key, null)
	if not (lists is Dictionary):
		return null
	return (lists as Dictionary).get("页码" + str(current_page), null)


## ldl 装备类型：等价旧 `EquipmentService.data(id)["类型"]`，但只读定义、不做深拷贝。
func _ldl_item_type(item_name: String) -> String:
	var definition := EquipmentService.definition(item_name)
	if definition == null or not definition.has_defined_field(DataKeys.TYPE):
		return ""
	return definition.category


func _ldl_type_filter() -> String:
	return "神骨" if str(MLdl.current_mode) == "淬骨" else ""


## 填格用的法宝判定：与 `EquipmentService.data(名字)["类型"] == "法宝"` 等价，但不做深拷贝。
func _is_magic_weapon_item(item: Dictionary) -> bool:
	return _ldl_item_type(str(item.get(DataKeys.NAME, ""))) == "法宝"


## 背包条目过滤：无过滤时保留原有“未知名字也显示”的语义，淬骨只留神骨。
func _ldl_backpack_entry_visible(item_name: String, ldl_type_filter: String) -> bool:
	if ldl_type_filter == "":
		return true
	return EquipmentService.has(item_name) and _ldl_item_type(item_name) == ldl_type_filter


## ldl 装备视图遍历：先已穿戴槽位，再按背包页码顺序。
## 返回 [条目数, 可见窗口投影, entries]；窗口投影为扁平的 [item, source, page, index, 装备栏]，
## entries 只在填格时构造，页数计算与轮询都不会生成全量条目字典。
func _scan_ldl_equipment(collect_entries: bool) -> Array:
	var entries: Array = []
	var window: Array = []
	var ldl_type_filter := _ldl_type_filter()
	var player_data: Dictionary = PlayerData.player_data
	var first_index: int = (int(current_page) - 1) * EQUIPMENT_ITEMS_PER_PAGE
	var last_index: int = first_index + EQUIPMENT_ITEMS_PER_PAGE
	var entry_count := 0
	for slot_type in LDL_EQUIPPED_SLOT_TYPES:
		var equipped_value: Variant = player_data.get(slot_type, [])
		if not (equipped_value is Array) or (equipped_value as Array).is_empty():
			continue
		var equipped_item: Variant = (equipped_value as Array)[0]
		if not (equipped_item is Dictionary):
			continue
		var item_name := str((equipped_item as Dictionary).get(DataKeys.NAME, ""))
		if item_name == "" or not EquipmentService.has(item_name):
			continue
		if ldl_type_filter != "" and _ldl_item_type(item_name) != ldl_type_filter:
			continue
		if entry_count >= first_index and entry_count < last_index:
			window.push_back(equipped_item)
			window.push_back("人物穿戴")
			window.push_back(0)
			window.push_back(0)
			window.push_back(slot_type)
		if collect_entries:
			entries.push_back({"item": equipped_item, "source": "人物穿戴", "page": 0, "index": 0, "装备栏": slot_type})
		entry_count += 1

	var equipment_pages: Variant = player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if equipment_pages is Dictionary:
		for page_index in range((equipment_pages as Dictionary).size()):
			var page_number: int = page_index + 1
			var page_value: Variant = (equipment_pages as Dictionary).get("页码" + str(page_number), [])
			if not (page_value is Array):
				continue
			var page: Array = page_value
			for item_index in range(page.size()):
				var item_value: Variant = page[item_index]
				if not (item_value is Dictionary):
					continue
				if ldl_type_filter != "":
					var filtered_name := str((item_value as Dictionary).get(DataKeys.NAME, ""))
					if not _ldl_backpack_entry_visible(filtered_name, ldl_type_filter):
						continue
				if collect_entries:
					entries.push_back(
						{"item": item_value, "source": "装备背包", "page": page_number, "index": item_index, "装备栏": ""}
					)
				if entry_count >= first_index and entry_count < last_index:
					window.push_back(item_value)
					window.push_back("装备背包")
					window.push_back(page_number)
					window.push_back(item_index)
					window.push_back("")
				entry_count += 1
	return [entry_count, window, entries]


func _get_ldl_equipment_entries() -> Array:
	return _scan_ldl_equipment(true)[2] as Array


## 页数只需要条目数量：不构造 entries，也不写玩家数据。
func _count_ldl_equipment_entries() -> int:
	return int(_scan_ldl_equipment(false)[0])


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
		if item_name == "" or not EquipmentService.has(item_name):
			continue
		var item_data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
		var item_type := _ldl_item_type(item_name)
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


## 公开契约：调用方改完数据即可直接调用；填格后同步保存显示投影快照与引用快照，供 Timer 精确比对。
func set_box_data():
	_fill_box_data()
	var state := _current_grid_state()
	_grid_snapshot = (state[0] as Array).duplicate(true)
	_grid_refs = (state[1] as Array).duplicate()


func _fill_box_data() -> void:
	match current_fl:
		0:
			if Global.get_ui_runtime().is_ldl_mode_active():
				_set_ldl_equipment_box_data()
				return
			title.text = "装备背包"
			var x = 1
			for i in PlayerData.player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(current_page)]:
				target_box(x).set_button_icon(ItemUtils.item_icon_with_empty_fallback(str(i.名字)))
				target_box(x).get_item_name = str(i.名字)
				target_box(x).set_meta("item_name", str(i.名字))
				target_box(x).qh_level = i.强化等级
				target_box(x).eq_prop = i.Data
				target_box(x).item_locked = bool(i.Data.get("锁定", false))
				if EquipmentService.data(i.名字)[DataKeys.TYPE] == "法宝":
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
				target_box(x).set_button_icon(ItemUtils.item_icon_with_empty_fallback(str(i.名字)))
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
				target_box(x).set_button_icon(ItemUtils.item_icon_with_empty_fallback(str(i.名字)))
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
	if Global.get_ui_runtime().is_ldl_mode_active() or choose_ms or is_instance_valid(sell_panel):
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
	if not Global.get_ui_runtime().is_ldl_mode_active() or str(MLdl.current_mode) not in ["强化", "镶嵌"]:
		return
	current_fl = 3
	current_page = 1
	set_box_data()


func _update_max_page() -> void:
	var page_count := _compute_max_page()
	if page_count != max_page:
		max_page = page_count
	current_page = clampi(current_page, 1, max_page)


## 页数只取决于条目数量：每帧只做计数投影（不构造 entries、不深拷贝页数组、不写玩家数据）。
## 这里刻意不调用 `ensure_shared_pet_backpack`：迁移由存档加载与填格路径负责，轮询只读。
func _compute_max_page() -> int:
	match int(current_fl):
		3:
			var shared: Variant = PlayerData.player_data.get(PlayerDataStore.PET_BACKPACK_KEY, null)
			var pet_count: int = (shared as Array).size() if shared is Array else 0
			return maxi(1, ceili(float(pet_count) / PET_ITEMS_PER_PAGE))
		0:
			if Global.get_ui_runtime().is_ldl_mode_active():
				return maxi(1, ceili(float(_count_ldl_equipment_entries()) / EQUIPMENT_ITEMS_PER_PAGE))
	return 20


## Timer 兜底轮询：显示投影与引用身份都未变才跳过，省掉每 51ms 的图标解析与装备数据深拷贝。
func _on_timer_timeout() -> void:
	if _grid_state_matches():
		return
	set_box_data()


func add_text(parent, text):
	if message == null:
		message = Global.add_touch_text(parent, Vector2(120, 40), text)


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

extends Node2D
class_name OneKeySynthesis

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

const TARGET_POPUP_MARGIN := 12.0
const TARGET_POPUP_MIN_HEIGHT := 96.0
const TARGET_POPUP_MAX_HEIGHT := 180.0

const DAN_RECIPES = {
	"smd_1": {"renshen": 3},
	"smd_2": {"dudan": 1, "smd_1": 1, "renshen": 1},
	"smd_3": {"dudan": 1, "smd_2": 1, "renshen": 1},
	"smd_4": {"dudan": 1, "smd_3": 1, "renshen": 1},
	"smd_5": {"dudan": 1, "smd_4": 1, "renshen": 1},
	"fld_1": {"xianmao": 3},
	"fld_2": {"dudan": 1, "fld_1": 1, "xianmao": 1},
	"fld_3": {"dudan": 1, "fld_2": 1, "xianmao": 1},
	"fld_4": {"dudan": 1, "fld_3": 1, "xianmao": 1},
	"fld_5": {"dudan": 1, "fld_4": 1, "xianmao": 1},
	"gjd_1": {"lingli": 3},
	"gjd_2": {"dudan": 1, "gjd_1": 1, "lingli": 1},
	"gjd_3": {"dudan": 1, "gjd_2": 1, "lingli": 1},
	"gjd_4": {"dudan": 1, "gjd_3": 1, "lingli": 1},
	"gjd_5": {"dudan": 1, "gjd_4": 1, "lingli": 1},
	"bjd_1": {"leizong": 3},
	"bjd_2": {"dudan": 1, "bjd_1": 1, "leizong": 1},
	"bjd_3": {"dudan": 1, "bjd_2": 1, "leizong": 1},
	"bjd_4": {"dudan": 1, "bjd_3": 1, "leizong": 1},
	"bjd_5": {"dudan": 1, "bjd_4": 1, "leizong": 1},
	"xyd_1": {"liuhuang": 3},
	"xyd_2": {"dudan": 1, "xyd_1": 1, "liuhuang": 1},
	"xyd_3": {"dudan": 1, "xyd_2": 1, "liuhuang": 1},
	"xyd_4": {"dudan": 1, "xyd_3": 1, "liuhuang": 1},
	"xyd_5": {"dudan": 1, "xyd_4": 1, "liuhuang": 1},
	"hmd_1": {"shougong": 3},
	"hmd_2": {"dudan": 1, "hmd_1": 1, "shougong": 1},
	"hmd_3": {"dudan": 1, "hmd_2": 1, "shougong": 1},
	"hmd_4": {"dudan": 1, "hmd_3": 1, "shougong": 1},
	"hmd_5": {"dudan": 1, "hmd_4": 1, "shougong": 1},
	"qhs_2": {"qhs_1": 3},
	"qhs_3": {"qhs_2": 3},
	"qhs_4": {"qhs_3": 3},
	"sms_7": {"sms_6": 2, "7_bsjh": 1},
	"fls_7": {"fls_6": 2, "7_bsjh": 1},
	"gjs_7": {"gjs_6": 2, "7_bsjh": 1},
	"wfs_7": {"wfs_6": 2, "7_bsjh": 1},
	"mfs_7": {"mfs_6": 2, "7_bsjh": 1},
	"bjs_7": {"bjs_6": 2, "7_bsjh": 1},
	"sbs_7": {"sbs_6": 2, "7_bsjh": 1},
	"rxs_7": {"rxs_6": 2, "7_bsjh": 1},
	"hxs_7": {"hxs_6": 2, "7_bsjh": 1},
	"hms_7": {"hms_6": 2, "7_bsjh": 1},
	"xys_7": {"xys_6": 2, "7_bsjh": 1},
	"mzs_7": {"mzs_6": 2, "7_bsjh": 1},
	"bms_7": {"bms_6": 2, "7_bsjh": 1},
	"pjs_7": {"pjs_6": 2, "7_bsjh": 1},
	"pms_7": {"pms_6": 2, "7_bsjh": 1}
}

@onready var target_dan: Button = $TargetDan
@onready var spin_box: SpinBox = $SpinBox
@onready var max_label: Label = $MaxLabel
@onready var onekey_syn: TextureButton = $OneKeySyn
@onready var item_1: Button = $cl_1/item_1
@onready var item_2: Button = $cl_2/item_2
@onready var item_3: Button = $cl_3/item_3
@onready var item_4: Button = $scw/item_4

var target_keys: Array = []
var selected_target_index: int = 0
var target_list_panel: PanelContainer
var target_list_scroll: ScrollContainer
var target_list_box: VBoxContainer


func _ready():
	target_keys = DAN_RECIPES.keys()
	_create_target_list()
	if not target_dan.pressed.is_connected(_toggle_target_list):
		target_dan.pressed.connect(_toggle_target_list)

	spin_box.min_value = 1
	spin_box.value = 1

	_select_target(0)


func _get_target_name(index: int) -> String:
	if index < 0 or index >= target_keys.size():
		return ""
	var item_name: String = target_keys[index]
	if not AE.all_equipment.has(item_name):
		return item_name
	var item_data: Dictionary = AE.all_equipment[item_name]
	var keys: Array = item_data.keys()
	if keys.size() > 0:
		return str(item_data[keys[0]])
	return item_name


func _create_target_list() -> void:
	target_list_panel = PanelContainer.new()
	target_list_panel.visible = false
	target_list_panel.z_index = 100
	target_list_panel.position = target_dan.position + Vector2(0.0, target_dan.size.y + 2.0)
	target_list_panel.custom_minimum_size = Vector2(180.0, TARGET_POPUP_MAX_HEIGHT)
	target_list_panel.size = Vector2(180.0, TARGET_POPUP_MAX_HEIGHT)
	add_child(target_list_panel)

	target_list_scroll = ScrollContainer.new()
	target_list_scroll.custom_minimum_size = Vector2(180.0, TARGET_POPUP_MAX_HEIGHT)
	target_list_scroll.size = Vector2(180.0, TARGET_POPUP_MAX_HEIGHT)
	target_list_panel.add_child(target_list_scroll)

	target_list_box = VBoxContainer.new()
	target_list_scroll.add_child(target_list_box)

	for i in range(target_keys.size()):
		var item_button := Button.new()
		item_button.text = _get_target_name(i)
		item_button.custom_minimum_size = Vector2(160.0, 28.0)
		item_button.pressed.connect(_on_target_list_item_pressed.bind(i))
		target_list_box.add_child(item_button)


func _toggle_target_list() -> void:
	if target_list_panel == null:
		return
	target_list_panel.visible = not target_list_panel.visible


func _on_target_list_item_pressed(index: int) -> void:
	_select_target(index)
	if target_list_panel != null:
		target_list_panel.visible = false


func _select_target(index: int) -> void:
	selected_target_index = int(clamp(index, 0, max(0, target_keys.size() - 1)))
	target_dan.text = _get_target_name(selected_target_index)
	_on_target_dan_selected(selected_target_index)


func load_icon(item_name: String) -> Texture2D:
	var path = "res://Art/backpack/all_items/" + item_name + ".png"
	if ResourceLoader.exists(path):
		return load(path)
	else:
		return load("res://Art/backpack/all_items/empty.png")


func update_icons(target: String):
	var recipe = DAN_RECIPES.get(target, {})
	var materials = recipe.keys()
	var material_icons = [load_icon("empty"), load_icon("empty"), load_icon("empty")]
	var material_names = ["", "", ""]

	if materials.size() == 1 and recipe[materials[0]] == 3:
		var mat = materials[0]
		material_icons[0] = load_icon(mat)
		material_icons[1] = load_icon(mat)
		material_icons[2] = load_icon(mat)
		material_names[0] = mat
		material_names[1] = mat
		material_names[2] = mat
	else:
		var idx = 0
		for mat in materials:
			if idx < 3:
				material_icons[idx] = load_icon(mat)
				material_names[idx] = mat
			idx += 1

	item_1.set_button_icon(material_icons[0])
	item_2.set_button_icon(material_icons[1])
	item_3.set_button_icon(material_icons[2])

	item_4.set_button_icon(load_icon(target))

	item_1.tooltip_text = material_names[0] if material_names[0] != "" else "无"
	item_2.tooltip_text = material_names[1] if material_names[1] != "" else "无"
	item_3.tooltip_text = material_names[2] if material_names[2] != "" else "无"
	item_4.tooltip_text = AE.all_equipment[target][DataKeys.NAME] if AE.all_equipment.has(target) else target


func get_item_count(item_name: String) -> int:
	var total = 0
	for page in PlayerData.player_data[DataKeys.CONSUMABLE_LIST].values():
		for item in page:
			if item[DataKeys.NAME] == item_name:
				total += item[DataKeys.COUNT]
	for page in PlayerData.player_data[DataKeys.ITEM_LIST].values():
		for item in page:
			if item[DataKeys.NAME] == item_name:
				total += item[DataKeys.COUNT]
	return total


func _collect_materials(dan: String, times: int, dict: Dictionary):
	if not DAN_RECIPES.has(dan):
		return
	var recipe = DAN_RECIPES[dan]
	for mat in recipe:
		var need = recipe[mat] * times
		if DAN_RECIPES.has(mat) and not dan.begins_with("qhs_"):
			_collect_materials(mat, need, dict)
		else:
			dict[mat] = dict.get(mat, 0) + need


func get_max_synthesis(target: String, stock: Dictionary) -> int:
	var required_base = {}
	_collect_materials(target, 1, required_base)
	var max_times = 1000000
	for mat in required_base:
		var need = required_base[mat]
		var have = stock.get(mat, 0)
		if have < need:
			return 0
		var possible = floor(have / need)
		if possible < max_times:
			max_times = possible
	return max_times


func perform_onekey_synthesis(target_dan_name: String, times: int):
	var materials_needed = {}
	_collect_materials(target_dan_name, times, materials_needed)

	for mat in materials_needed:
		if not PlayerData.remove_item(mat, materials_needed[mat]):
			Global.add_message_show(Global.windows, "材料不足，扣除失败！", 1.5, Vector2(470, 300))
			return

	PlayerData.add_dj(target_dan_name, times)
	MemoryClass.request_save("ldl_one_key_synthesis")
	Global.add_message_show(
		Global.windows,
		"一键合成成功！获得 " + AE.all_equipment[target_dan_name][DataKeys.NAME] + " x" + str(times),
		1.5,
		Vector2(470, 300)
	)


func _on_target_dan_selected(index: int):
	if index < 0:
		max_label.text = "最大: 0"
		spin_box.max_value = 0
		update_icons("")
		return

	var target = target_keys[index]
	update_icons(target)

	var all_mats = []
	for recipe in DAN_RECIPES.values():
		for mat in recipe.keys():
			if not mat in all_mats:
				all_mats.append(mat)

	var stock = {}
	for mat in all_mats:
		stock[mat] = get_item_count(mat)

	var max_times = get_max_synthesis(target, stock)
	max_label.text = "最大: " + str(max_times)
	spin_box.max_value = max_times
	if spin_box.value > max_times:
		spin_box.value = max_times


func _on_onekey_syn_pressed():
	var idx: int = selected_target_index
	if idx < 0:
		Global.add_message_show(Global.windows, "请选择目标丹药！", 1.5, Vector2(470, 300))
		return

	var target = target_keys[idx]
	var times = int(spin_box.value)

	var all_mats = []
	for recipe in DAN_RECIPES.values():
		for mat in recipe.keys():
			if not mat in all_mats:
				all_mats.append(mat)
	var stock = {}
	for mat in all_mats:
		stock[mat] = get_item_count(mat)
	var max_times = get_max_synthesis(target, stock)

	if times <= 0:
		Global.add_message_show(Global.windows, "次数必须大于0！", 1.5, Vector2(470, 300))
		return
	if times > max_times:
		Global.add_message_show(Global.windows, "材料不足，最多合成 " + str(max_times) + " 次", 1.5, Vector2(470, 300))
		times = max_times
		spin_box.value = times

	if times > 0:
		perform_onekey_synthesis(target, times)
		_on_target_dan_selected(idx)


func _on_close_pressed():
	queue_free()

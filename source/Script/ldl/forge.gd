extends Node2D
class_name Forge

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

const FORGE_ITEM_BOX_SCENE: PackedScene = preload("res://Scene/back_pack/box_1.tscn")
const FORGE_MATERIAL_BOX_SCENE: PackedScene = preload("res://Scene/ldl/forge_material_box.tscn")
@onready var scw: Button = $LastItem/scw
@onready var zzs: TextureRect = $Zzs
@onready var last_item: TextureRect = $LastItem
@onready var item_name_label: Label = $LastItem/Name/ItemName
@onready var basic_material: HBoxContainer = $BasicMaterial/BasicMaterial
@onready var lh: Label = $LastItem/Need/LH
@onready var bs_box: HBoxContainer = $BSBox
var item_data = {}
var item_material_list = {
	"tfljzzs": {"xuantie": 40, "tanmu": 40},
	"mgzhzzs": {"tanmu": 40, "sichou": 40},
	"tdlzjzzs": {"xuantie": 30, "tanmu": 30, "sichou": 30},
	"wsjgzzs": {"xuantie": 80, "tanmu": 60},
	"hljhzzs": {"tanmu": 60, "sichou": 80},
	"zjbtgzzs": {"xuantie": 140},
	"zjxmczzs": {"xuantie": 140},
	"blmqzzs": {"xuantie": 140},
	"eyzzs": {"xuantie": 240, "sichou": 240},
	"thzzs": {"xuantie": 300, "tanmu": 180},
	"tczzs": {"xuantie": 300, "tanmu": 180},
	"czzzs": {"sichou": 480},
	"tzzzs": {"xuantie": 480},
	"ryzzs": {"xuantie": 300, "tanmu": 180},
	"tszzs": {"xuantie": 160, "sichou": 160, "tanmu": 160},
	"yjzzs": {"xuantie": 160, "sichou": 160, "tanmu": 160},
	"tqzzs": {"xuantie": 160, "sichou": 160, "tanmu": 160},
	"zezzs": {"xuantie": 160, "sichou": 160, "tanmu": 160},
	"llyzzs": {"xuantie": 160, "sichou": 160, "tanmu": 160, "tss": 5, "yhs": 5},
	"230007003zzs": {"xuantie": 300, "tanmu": 180},
	"231007003zzs": {"xuantie": 240, "sichou": 240},
	"nmwdnhzzs": {"nmwdnhsp": 60, "nmwjh": 1},
	"zlwdahzzs": {"zlwdahsp1": 30, "zlwdahsp2": 30, "zlwdahsp3": 10},
	"sqzlwzzs": {"zlwdahsp1": 99, "zlwdahsp2": 99, "zlwdahsp3": 33},
	"sqnmwdnhzzs": {"nmwdnhsp": 180, "nmwjh": 3},
	"cjshenjzzs": {"xuantie": 999, "sichou": 999, "tanmu": 999},
	"cdshenjzzs": {"xuantie": 999, "sichou": 999, "tanmu": 999},
	"zhshenjzzs": {"xuantie": 999, "sichou": 999, "tanmu": 999},
	"xyfjwkzzs": {"yhs": 66, "tss": 66},
	"xyfjbjzzs": {"yhs": 66, "tss": 66},
	"xyfjtszzs": {"yhs": 66, "tss": 66},
	"xyfjsszzs": {"yhs": 66, "tss": 66},
	"xyfjblzzs": {"yhs": 66, "tss": 66},
	"341071301zzs": {"yhs": 66, "tss": 66},
	"cswkxyhbzzs": {"yhs": 66, "tss": 66},
	"cstsxyhbzzs": {"yhs": 66, "tss": 66},
	"csbjxyhbzzs": {"yhs": 66, "tss": 66},
	"csssxyhbzzs": {"yhs": 66, "tss": 66},
	"csblxyhbzzs": {"yhs": 66, "tss": 66},
	"342071301zzs": {"yhs": 66, "tss": 66},
	"xyzyzzs": {"yhs": 66, "tss": 66},
	"ygfjwkzzs": {"yhs": 66, "tss": 66},
	"ygwqwkzzs": {"yhs": 66, "tss": 66},
	"ygfjtszzs": {"yhs": 66, "tss": 66},
	"ygwqtszzs": {"yhs": 66, "tss": 66},
	"ygfjbjzzs": {"yhs": 66, "tss": 66},
	"ygwqbjzzs": {"yhs": 66, "tss": 66},
	"ygfjsszzs": {"yhs": 66, "tss": 66},
	"ygwqsszzs": {"yhs": 66, "tss": 66},
	"ygfjblzzs": {"yhs": 66, "tss": 66},
	"ygwqblzzs": {"yhs": 66, "tss": 66},
	"ygfjnzzzs": {"yhs": 66, "tss": 66},
	"ygwqnzzzs": {"yhs": 66, "tss": 66},
	"zqfjwkzzs": {"yhs": 66, "tss": 66},
	"zqfjtszzs": {"yhs": 66, "tss": 66},
	"zqfjbjzzs": {"yhs": 66, "tss": 66},
	"zqfjsszzs": {"yhs": 66, "tss": 66},
	"zqfjblzzs": {"yhs": 66, "tss": 66},
	"zqfjnzzzs": {"yhs": 66, "tss": 66},
	"zqwqwkzzs": {"yhs": 66, "tss": 66},
	"zqwqtszzs": {"yhs": 66, "tss": 66},
	"zqwqbjzzs": {"yhs": 66, "tss": 66},
	"zqwqsszzs": {"yhs": 66, "tss": 66},
	"zqwqblzzs": {"yhs": 66, "tss": 66},
	"zqwqnzzzs": {"yhs": 66, "tss": 66},
	"zhhzzzs": {"xuantie": 600, "ygs": 30},
	"phhlzzs": {"xuantie": 600, "ygs": 30},
	"bxhyzzs": {"xuantie": 600, "ygs": 30},
	"qlgzzs": {"xuantie": 600, "tanmu": 300},
	"qljzzs": {"xuantie": 300, "tanmu": 300, "sichou": 300},
	"230007004zzs": {"xuantie": 600, "tanmu": 300},
	"231007004zzs": {"xuantie": 300, "tanmu": 300, "sichou": 300},
	"plzzzs": {"xuantie": 450, "tanmu": 450},
	"plpzzs": {"sichou": 900},
	"ylfzzs": {"xuantie": 900},
	"ylkzzs": {"xuantie": 600, "tanmu": 300},
	"jlczzs": {"xuantie": 300, "sichou": 300, "tanmu": 300},
	"jljzzs": {"xuantie": 300, "sichou": 300, "tanmu": 300},
	"tlqzzs": {"xuantie": 300, "sichou": 300, "tanmu": 300},
	"tljzzs": {"xuantie": 300, "sichou": 300, "tanmu": 300},
	"doushuaiziyanzzs": {"ziyanyujin": 1500},
	"zjhlzzs": {"xuantie": 600, "tanmu": 300},
	"canglongjiezzs": {"canglonglingpo": 10, "tss": 5, "yhs": 5, "xuantie": 500, "tanmu": 500, "sichou": 500},
	"qszzs": {"xuantie": 1200, "tanmu": 900, "tss": 20},
	"240007001zzs": {"xuantie": 1200, "tanmu": 900, "tss": 20},
	"241007001zzs": {"xuantie": 700, "tanmu": 700, "sichou": 700, "yhs": 20},
	"dzzzs": {"xuantie": 700, "tanmu": 700, "sichou": 700, "yhs": 20},
	"rczzs": {"xuantie": 1050, "tanmu": 1050, "tss": 20},
	"ztzzs": {"sichou": 2100, "yhs": 20},
	"ytzzs": {"xuantie": 2100, "tss": 20},
	"jtzzs": {"xuantie": 1500, "tanmu": 600, "yhs": 20},
	"llzzs": {"xuantie": 700, "sichou": 700, "tanmu": 700, "tss": 20},
	"jszzs": {"xuantie": 700, "sichou": 700, "tanmu": 700, "yhs": 20},
	"ldzzs": {"xuantie": 2100, "tss": 20},
	"tlzzs": {"xuantie": 700, "sichou": 700, "tss": 10, "yhs": 10},
	"slshgzzs": {"xuantie": 1400, "tanmu": 1300, "tss": 30},
	"240007005zzs": {"xuantie": 1400, "tanmu": 1300, "tss": 30},
	"241007005zzs": {"xuantie": 900, "tanmu": 900, "sichou": 900, "yhs": 30},
	"slshjzzs": {"xuantie": 900, "tanmu": 900, "sichou": 900, "yhs": 30},
	"slfmzzzs": {"xuantie": 1350, "tanmu": 1350, "tss": 30},
	"sljszzs": {"sichou": 2700, "yhs": 30},
	"slcpzzs": {"xuantie": 1300, "sichou": 1400, "tss": 15, "yhs": 15},
	"slhlqzzs": {"xuantie": 2700, "tss": 30},
	"slxjczzs": {"xuantie": 900, "sichou": 900, "tanmu": 900, "tss": 30},
	"slyszzs": {"xuantie": 900, "sichou": 900, "tanmu": 900, "yhs": 30},
	"sllypzzs": {"xuantie": 2700, "tss": 30},
	"slfkzzs": {"xuantie": 1800, "tanmu": 900, "yhs": 30},
}


func _init() -> void:
	preload("res://Script/data/yutu_equipment_data.gd").add_forge_materials(item_material_list)


func _ready() -> void:
	Global.forge = self
	addbzpic()
	lh.text = str(5000)
	remove_name_and_need()

	scw.is_in_ldl_gz = true
	scw.hide_prop = false


var current_book: String = ""


func _physics_process(_delta):
	if zzs.get_child_count() > 0:
		var book_name := _get_current_book_name()
		if book_name != current_book:
			current_book = book_name
			load_material_box()
			add_item_box()
	elif current_book != "":
		current_book = ""
		rmove_box()
		remove_material_box()
		remove_name_and_need()


func load_material_box():
	if zzs.get_children().size() == 0:
		return
	_clear_children_now(basic_material)

	var book_name := _get_current_book_name()
	var material_list := _get_material_list(book_name)
	var material_names: Array = material_list.keys()
	for material_name in material_names:
		_add_forge_material_box(basic_material, str(material_name), int(material_list[material_name]))

	if basic_material.get_child_count() == 2:
		basic_material.add_theme_constant_override("separation", 50)
	elif basic_material.get_child_count() == 3:
		basic_material.add_theme_constant_override("separation", 55)
	else:
		basic_material.add_theme_constant_override("separation", 15)


func add_item_box():
	var book_name := _get_current_book_name()
	var item_name := book_name.split("zzs")[0] if book_name != "" else ""
	if item_name == "" or not AE.all_equipment.has(item_name):
		scw.get_item_name = "empty"
		scw.icon = load_item_icon("empty")
		scw.eq_prop = {}
		remove_name_and_need()
		return

	if PlayerData.player_data["宝珠列表"].size() <= 0:
		item_data = get_eq_prop()
	else:
		item_data = get_bz_prop()

	scw.get_item_name = item_name
	scw.icon = load_item_icon(str(item_name))
	scw.eq_prop = item_data
	scw.is_in_ldl_gz = true

	refresh_name()


func refresh_name():
	if zzs.get_children().size() == 0:
		remove_name_and_need()
		return

	var book_name := _get_current_book_name()
	var item_name := book_name.split("zzs")[0] if book_name != "" else ""
	if item_name == "" or not AE.all_equipment.has(item_name):
		remove_name_and_need()
		return
	var item_display_name = AE.all_equipment[item_name][DataKeys.NAME]
	var color = AE.all_equipment[item_name]["颜色"]
	item_name_label.text = str(item_display_name)
	item_name_label.add_theme_color_override("font_color", color)


func addbzpic():
	remove_all_bspic()
	var bz_value: Variant = PlayerData.player_data.get("宝珠列表", [])
	if not bz_value is Array:
		return
	var bz_list: Array = bz_value
	if bz_list.size() == 0:
		return
	for idx in range(bz_list.size()):
		var jewel_value: Variant = bz_list[idx]
		var jewel: Dictionary = jewel_value if jewel_value is Dictionary else {}
		var item_name := str(jewel.get(DataKeys.NAME, ""))
		var data_value: Variant = jewel.get("Data", {})
		var data: Dictionary = data_value if data_value is Dictionary else {}
		var item_box := _add_forge_item_box(bs_box, str(item_name), 0, 1, [], data, true, false)
		if item_box == null or not is_instance_valid(item_box):
			continue
		var icon_path := "res://Art/backpack/all_items/%s.png" % str(item_name)
		item_box.set("icon", ResourceLoader.load(icon_path) as Texture2D if ResourceLoader.exists(icon_path) else null)
		item_box.forge_bzid = idx
		item_box.is_in_ldl_gz = true


func remove_bspic(id: int):
	var bz_value: Variant = PlayerData.player_data.get("宝珠列表", [])
	if not bz_value is Array:
		return
	var bz_list: Array = bz_value
	if id < 0 or id >= bz_list.size():
		print("警告：尝试移除无效索引 ", id)
		return

	var jewel_value: Variant = bz_list[id]
	if not jewel_value is Dictionary:
		print("警告：宝珠数据格式无效，跳过移除索引 ", id)
		return
	var jewel: Dictionary = jewel_value
	var jewel_name := str(jewel.get(DataKeys.NAME, ""))
	if jewel_name == "" or not AE.all_equipment.has(jewel_name):
		print("警告：宝珠名称无效，跳过移除索引 ", id)
		return
	if id < bs_box.get_child_count():
		var child = bs_box.get_child(id)
		if child != null and is_instance_valid(child):
			bs_box.remove_child(child)
			child.queue_free()
	else:
		addbzpic()
		return
	PlayerData.add_dj(jewel_name, 1)
	bz_list.remove_at(id)
	addbzpic()


func remove_infomation():
	var bz_value: Variant = PlayerData.player_data.get("宝珠列表", [])
	if not bz_value is Array or (bz_value as Array).is_empty():
		return
	var bz_list: Array = bz_value
	for jewel_value in bz_list:
		if not jewel_value is Dictionary:
			continue
		var jewel: Dictionary = jewel_value
		var item_name := str(jewel.get(DataKeys.NAME, ""))
		if item_name != "" and AE.all_equipment.has(item_name):
			PlayerData.add_dj(item_name, 1)
	bz_list.clear()
	MemoryClass.request_save("ldl_forge_remove")


func remove_all_bspic():
	_clear_children_now(bs_box)


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func check_full_material() -> bool:
	if zzs == null or zzs.get_child_count() != 1:
		return false
	var book_name := _get_current_book_name()
	var material_list := _get_material_list(book_name)
	if book_name == "" or material_list.is_empty():
		return false
	if _get_forge_item_count(book_name) < 1:
		return false
	for material_name in material_list.keys():
		var need_num := int(material_list[material_name])
		if _get_forge_item_count(str(material_name)) < need_num:
			return false
	return true


func _get_forge_item_count(item_name: String) -> int:
	if item_name == "":
		return 0
	var pages_value: Variant = PlayerData.player_data.get(DataKeys.ITEM_LIST, {})
	if not pages_value is Dictionary:
		return 0
	var total := 0
	var pages: Dictionary = pages_value
	for page_value in pages.values():
		if not page_value is Array:
			continue
		var page: Array = page_value
		for item_value in page:
			if not item_value is Dictionary:
				continue
			var item: Dictionary = item_value
			if str(item.get(DataKeys.NAME, "")) == item_name:
				total += maxi(int(item.get(DataKeys.COUNT, 0)), 0)
	return total


func _consume_forge_item(item_name: String, amount: int) -> bool:
	if item_name == "" or amount <= 0:
		return amount <= 0
	var pages_value: Variant = PlayerData.player_data.get(DataKeys.ITEM_LIST, {})
	if not pages_value is Dictionary:
		return false
	var remaining := amount
	var pages: Dictionary = pages_value
	for page_key in pages.keys():
		var page_value: Variant = pages.get(page_key, [])
		if not page_value is Array:
			continue
		var page: Array = page_value
		for index in range(page.size() - 1, -1, -1):
			var item_value: Variant = page[index]
			if not item_value is Dictionary:
				continue
			var item: Dictionary = item_value
			if str(item.get(DataKeys.NAME, "")) != item_name:
				continue
			var available := maxi(int(item.get(DataKeys.COUNT, 0)), 0)
			if available <= 0:
				continue
			var consumed := mini(available, remaining)
			item[DataKeys.COUNT] = available - consumed
			remaining -= consumed
			if int(item[DataKeys.COUNT]) <= 0:
				page.remove_at(index)
			if remaining <= 0:
				return true
	return false


func _restore_player_data(snapshot: Dictionary) -> void:
	PlayerData.player_data.clear()
	PlayerData.player_data.merge(snapshot.duplicate(true), true)


func _restore_forge_state(snapshot: Dictionary, book_name: String, book_level: int, book_props: Dictionary) -> void:
	_restore_player_data(snapshot)
	replace_book(book_name, book_level, book_props)
	addbzpic()


func remove_zzs_box():
	_clear_children_now(zzs)
	current_book = ""


func remove_material_box():
	_clear_children_now(basic_material)
	for i in range(4):
		_add_forge_material_box(basic_material, "", 0)
	if basic_material.get_child_count() == 2:
		basic_material.add_theme_constant_override("separation", 50)
	elif basic_material.get_child_count() == 3:
		basic_material.add_theme_constant_override("separation", 55)
	else:
		basic_material.add_theme_constant_override("separation", 15)


func rmove_box():
	scw.get_item_name = "empty"
	scw.icon = load_item_icon("empty")
	scw.eq_prop = {}


func remove_name_and_need():
	item_name_label.text = ""


func remove_all() -> bool:
	var book_name := _get_current_book_name()
	if book_name == "":
		return false
	var material_list := _get_material_list(book_name)
	if material_list.is_empty():
		return false

	var snapshot: Dictionary = PlayerData.player_data.duplicate(true)
	for material_name in material_list.keys():
		if not _consume_forge_item(str(material_name), int(material_list[material_name])):
			_restore_player_data(snapshot)
			return false
	if not _consume_forge_item(book_name, 1):
		_restore_player_data(snapshot)
		return false

	var jewels_value: Variant = PlayerData.player_data.get("宝珠列表", [])
	if not jewels_value is Array:
		_restore_player_data(snapshot)
		return false
	var jewels: Array = jewels_value
	jewels.clear()
	addbzpic()
	item_data = {}
	remove_zzs_box()
	remove_material_box()
	return true


func replace_book(book_name: String, level: int, props: Dictionary) -> void:
	if book_name == "" or not is_instance_valid(zzs):
		return
	_clear_children_now(zzs)
	var book_box := _add_forge_item_box(zzs, book_name, level, 1, [], props, true, true)
	if book_box != null and is_instance_valid(book_box):
		book_box.set("position", Vector2(8, 8))
	current_book = book_name
	load_material_box()
	add_item_box()


func _add_forge_item_box(
	parent: Node,
	item_name: String,
	level: int,
	number: int,
	elements: Array,
	props: Variant,
	in_ldl: bool,
	in_hhgz: bool
) -> Node:
	if parent == null or not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	var target: Node = FORGE_ITEM_BOX_SCENE.instantiate()
	target.set("is_in_ldl_gz", in_ldl)
	target.set("is_in_hhgz", in_hhgz)
	target.set("qh_level", level)
	target.set("total_number", number)
	target.set("wx", elements)
	target.set("eq_prop", props)
	target.set("get_item_name", item_name)
	target.set_meta("item_name", item_name)
	var icon_path := "res://Art/backpack/all_items/%s.png" % item_name
	target.set("icon", ResourceLoader.load(icon_path) as Texture2D if ResourceLoader.exists(icon_path) else null)
	parent.add_child(target)
	return target


func _add_forge_material_box(parent: Node, material_name: String, need_num: int) -> Node:
	if parent == null or not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	var target: Node = FORGE_MATERIAL_BOX_SCENE.instantiate()
	target.set("ItemName", material_name)
	target.set("need_num", need_num)
	parent.add_child(target)
	return target


func _clear_children_now(parent: Node) -> void:
	if parent == null or not is_instance_valid(parent):
		return
	for child in parent.get_children():
		if child != null and is_instance_valid(child):
			parent.remove_child(child)
			child.queue_free()


func _on_froge_pressed() -> void:
	if zzs == null or zzs.get_child_count() != 1:
		Global.add_message_show(Global.get_ui_runtime().windows, "请先放入制作书！！", 1.5, Vector2(500, 305))
		return

	var book_box: Node = zzs.get_child(0)
	var book_name := _get_current_book_name()
	var item_name := book_name.split("zzs")[0] if book_name != "" else ""
	if (
		book_name == ""
		or item_name == ""
		or not item_material_list.has(book_name)
		or not AE.all_equipment.has(item_name)
	):
		Global.add_message_show(Global.get_ui_runtime().windows, "制作书数据异常，无法打造！！", 1.5, Vector2(500, 305))
		return
	if PlayerData.get_soul() < 5000:
		Global.add_message_show(Global.get_ui_runtime().windows, "灵魂不足！！", 1.5, Vector2(500, 305))
		return
	if not check_full_material():
		Global.add_message_show(Global.get_ui_runtime().windows, "材料或制作书不足！！", 1.5, Vector2(500, 305))
		return

	var item_data: Dictionary = AE.all_equipment[item_name] as Dictionary
	var equipment_type := str(item_data.get(DataKeys.TYPE, ""))
	var jewels_value: Variant = PlayerData.player_data.get("宝珠列表", [])
	if not jewels_value is Array:
		Global.add_message_show(Global.get_ui_runtime().windows, "宝珠数据异常，无法打造！！", 1.5, Vector2(500, 305))
		return

	var snapshot: Dictionary = PlayerData.player_data.duplicate(true)
	var book_level := int(book_box.get("qh_level"))
	var book_props_value: Variant = book_box.get("eq_prop")
	var book_props: Dictionary = book_props_value if book_props_value is Dictionary else {}
	var new_equip_data: Dictionary = item_data.duplicate(true)
	var strengthen_value: Variant = new_equip_data.get(DataKeys.ENHANCE_PROP, {})
	var strengthen: Dictionary = strengthen_value if strengthen_value is Dictionary else {}
	new_equip_data[DataKeys.ENHANCE_PROP] = strengthen
	var jewels: Array = jewels_value
	for jewel_value in jewels:
		if not jewel_value is Dictionary:
			Global.add_message_show(Global.get_ui_runtime().windows, "宝珠数据异常，无法打造！！", 1.5, Vector2(500, 305))
			return
		var jewel: Dictionary = jewel_value
		var jewel_name := str(jewel.get(DataKeys.NAME, ""))
		if jewel_name == "" or not AE.all_equipment.has(jewel_name):
			Global.add_message_show(Global.get_ui_runtime().windows, "宝珠数据异常，无法打造！！", 1.5, Vector2(500, 305))
			return
		var jewel_data_value: Variant = AE.all_equipment.get(jewel_name, {})
		if not jewel_data_value is Dictionary:
			Global.add_message_show(Global.get_ui_runtime().windows, "宝珠数据异常，无法打造！！", 1.5, Vector2(500, 305))
			return
		var jewel_data: Dictionary = jewel_data_value
		for prop in AE.prop_list_name:
			if jewel_data.has(prop):
				new_equip_data[prop] = new_equip_data.get(prop, 0) + jewel_data[prop]
		var jewel_strength_value: Variant = jewel_data.get(DataKeys.ENHANCE_PROP, {})
		if jewel_strength_value is Dictionary:
			var jewel_strength: Dictionary = jewel_strength_value
			for key in jewel_strength.keys():
				strengthen[key] = strengthen.get(key, 0) + jewel_strength[key]

	var added := false
	match equipment_type:
		"法宝":
			added = PlayerData.add_fb(item_name, 0, AE.get_wx(), new_equip_data)
		"武器", "防具", "饰品", "神骨", "时装", "头衔", "翅膀":
			added = PlayerData.add_zb(item_name, 0, new_equip_data)
		_:
			Global.add_message_show(Global.get_ui_runtime().windows, "该制作书的装备类型不支持打造！！", 1.5, Vector2(500, 305))
			return
	if not added:
		Global.add_message_show(Global.get_ui_runtime().windows, "装备栏已满或装备数据无效，未扣除材料！！", 1.5, Vector2(500, 305))
		return

	if not remove_all() or not PlayerData.spend_soul(5000):
		_restore_forge_state(snapshot, book_name, book_level, book_props)
		Global.add_message_show(Global.get_ui_runtime().windows, "打造失败，材料未扣除！！", 1.5, Vector2(500, 305))
		return
	if not MemoryClass.request_save("forge", false):
		_restore_forge_state(snapshot, book_name, book_level, book_props)
		Global.add_message_show(
			Global.get_ui_runtime().windows,
			"存档保存失败，本次打造已撤销：%s" % MemoryClass.describe_save_error(),
			2.0,
			Vector2(500, 305)
		)
		return
	Global.add_message_show(Global.get_ui_runtime().windows, "打造成功！！", 1.5, Vector2(500, 305))


func _get_material_list(book_name: String) -> Dictionary:
	var material_list: Variant = item_material_list.get(book_name, {})
	if material_list is Dictionary:
		return material_list
	return {}


func _get_current_book_name() -> String:
	if zzs == null or zzs.get_child_count() == 0:
		return ""
	var book_box := zzs.get_child(0)
	var book_name := str(book_box.get("get_item_name"))
	if book_name == "" or book_name == "empty":
		var metadata_name := str(book_box.get_meta("item_name", ""))
		if metadata_name != "":
			book_name = metadata_name
	return book_name


func get_bz_prop_legacy():
	if PlayerData.player_data["宝珠列表"].size() <= 0:
		return
	var bz_prop = {}
	for i in AE.prop_list_name:
		bz_prop[i] = 0
	for i in PlayerData.player_data["宝珠列表"]:
		i["Data"] = AE.all_equipment[i[DataKeys.NAME]]
		for u in AE.prop_list_name:
			bz_prop[u] += i["Data"][u]
	var book_name := _get_current_book_name()
	if book_name == "":
		return
	var item_name := book_name.split("zzs")[0]
	if not AE.all_equipment.has(item_name):
		return
	var prop_list = AE.all_equipment[item_name].duplicate(true)
	for i in AE.prop_list_name:
		prop_list[i] += bz_prop[i]
	return prop_list


func get_bz_prop() -> Dictionary:
	var jewels_value: Variant = PlayerData.player_data.get("宝珠列表", [])
	if not jewels_value is Array:
		return {}
	var jewels: Array = jewels_value
	if jewels.is_empty():
		return {}

	var bonus: Dictionary = {}
	for prop in AE.prop_list_name:
		bonus[prop] = 0
	for jewel_value in jewels:
		if not jewel_value is Dictionary:
			return {}
		var jewel: Dictionary = jewel_value
		var jewel_name := str(jewel.get(DataKeys.NAME, ""))
		if jewel_name == "" or not AE.all_equipment.has(jewel_name):
			return {}
		var jewel_data_value: Variant = AE.all_equipment.get(jewel_name, {})
		if not jewel_data_value is Dictionary:
			return {}
		var jewel_data: Dictionary = jewel_data_value
		for prop in AE.prop_list_name:
			if jewel_data.has(prop):
				bonus[prop] = bonus.get(prop, 0) + jewel_data[prop]

	var book_name := _get_current_book_name()
	var item_name := book_name.split("zzs")[0] if book_name != "" else ""
	if item_name == "" or not AE.all_equipment.has(item_name):
		return {}
	var prop_list: Dictionary = (AE.all_equipment[item_name] as Dictionary).duplicate(true)
	for prop in AE.prop_list_name:
		if prop_list.has(prop):
			prop_list[prop] += bonus.get(prop, 0)
	return prop_list


func get_eq_prop():
	var book_name := _get_current_book_name()
	if book_name == "":
		return
	var item_name := book_name.split("zzs")[0]
	if not AE.all_equipment.has(item_name):
		return
	return AE.all_equipment[item_name]


func _on_help_pressed() -> void:
	Global.add_forge_help(NodeUtils.ancestor(self, 3), Vector2(455, 265))

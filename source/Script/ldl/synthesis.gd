extends Node2D
class_name Synthesis

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

const RecipeData = preload("res://Script/ldl/recipe_data.gd")

var prop_list_name = [
	"SHp",
	"SMp",
	"power",
	"Def",
	"Mdef",
	"Crit",
	"Miss",
	"R_hp",
	"R_mp",
	"vampirism",
	"Lucky",
	"toughness",
	"htarget",
	"CritReduce",
	"ar",
	"sp"
]

@onready var item_1: Button = $cl_1/item_1
@onready var item_2: Button = $cl_2/item_2
@onready var item_3: Button = $cl_3/item_3
@onready var item_4: Button = $scw/item_4
@onready var _name: Label = $infor/name_
@onready var need_lh: Label = $infor/need_lh


func _ready() -> void:
	item_1.is_in_ldl_gz = true
	item_2.is_in_ldl_gz = true
	item_3.is_in_ldl_gz = true


func _physics_process(_delta: float) -> void:
	item_1.is_in_ldl_gz = true
	item_2.is_in_ldl_gz = true
	item_3.is_in_ldl_gz = true
	item_4.is_in_ldl_gz = true

	set_cailiao_pic()
	_get_display_name()


func remove_infomation():
	for i in PlayerData.player_data["放入列表"]:
		if PlayerData.player_data["放入列表"][i].size() != 0:
			var new_list = PlayerData.player_data["放入列表"][i]
			var get_tt := EquipmentService.definition(StringName(new_list[0])).category
			if get_tt == "武器" or get_tt == "防具" or get_tt == "饰品" or get_tt == "翅膀" or get_tt == "头衔" or get_tt == "时装":
				PlayerData.add_zb(new_list[0], new_list[3], new_list[4])
			elif get_tt == "道具" or get_tt == "消耗品":
				PlayerData.add_dj(new_list[0], 1)
	PlayerData.player_data["放入列表"]["物品1"].clear()
	PlayerData.player_data["放入列表"]["物品2"].clear()
	PlayerData.player_data["放入列表"]["物品3"].clear()
	MemoryClass.request_save("ldl_synthesis_remove")


func _get_display_name():
	var name_1: String = ""
	var name_2: String = ""
	var name_3: String = ""
	var list_1 = PlayerData.player_data["放入列表"]["物品1"]
	var list_2 = PlayerData.player_data["放入列表"]["物品2"]
	var list_3 = PlayerData.player_data["放入列表"]["物品3"]
	if list_1.size() != 0:
		name_1 = list_1[0]
	if list_2.size() != 0:
		name_2 = list_2[0]
	if list_3.size() != 0:
		name_3 = list_3[0]

	if list_1.size() != 0 and list_2.size() != 0 and list_3.size() != 0:
		var recipe_info = get_recipe(name_1, name_2, name_3)
		if recipe_info[0]:
			var result_item = recipe_info[1]
			var result_definition := EquipmentService.definition(StringName(result_item))

			_name.text = result_definition.display_name
			item_4.set_button_icon(ItemUtils.equipment_icon_or_item_icon(str(result_item)))
			var lx := result_definition.category
			need_lh.text = str(recipe_info[2])

			match lx:
				"道具", "消耗品":
					item_4.eq_prop = EquipmentService.data(StringName(result_item))
				"法宝":
					item_4.eq_prop = get_fb_prop(result_item)
				"武器", "饰品", "防具", "时装", "头衔", "翅膀":
					if result_item in ["cjxianjie", "cdxianjie", "zhxianjie"]:
						item_4.eq_prop = get_xianjie_prop(result_item)
					else:
						match result_item:
							"dzjj", "huayan", "cjjj":
								item_4.eq_prop = get_equipment_prop(result_item)
								return
						item_4.eq_prop = EquipmentService.data(StringName(result_item))
		else:
			item_4.eq_prop = {}
			_name.text = ""
			need_lh.text = ""
			item_4.set_button_icon(ItemUtils.equipment_icon_or_item_icon("empty"))
	else:
		_name.text = ""
		need_lh.text = ""
		item_4.set_button_icon(ItemUtils.equipment_icon_or_item_icon("empty"))


func _on_syn_pressed() -> void:
	var name_1: String = ""
	var name_2: String = ""
	var name_3: String = ""
	var list_1 = PlayerData.player_data["放入列表"]["物品1"]
	var list_2 = PlayerData.player_data["放入列表"]["物品2"]
	var list_3 = PlayerData.player_data["放入列表"]["物品3"]
	if list_1.size() != 0:
		name_1 = list_1[0]
	if list_2.size() != 0:
		name_2 = list_2[0]
	if list_3.size() != 0:
		name_3 = list_3[0]

	var recipe_info = get_recipe(name_1, name_2, name_3)
	if not recipe_info[0]:
		Global.add_message_show(get_parent(), "合成公式错误！", 1.5, Vector2(15, -45))
		return
	var nn_lh = recipe_info[2]
	if PlayerData.get_soul() < nn_lh:
		Global.add_message_show(get_parent(), "灵魂不足！！！", 1.5, Vector2(15, -45))
		return
	var snapshot := PlayerData.snapshot_state()
	if not PlayerData.spend_soul(nn_lh):
		PlayerData.restore_state(snapshot)
		Global.add_message_show(get_parent(), "灵魂不足！！！", 1.5, Vector2(15, -45))
		return
	var _item = recipe_info[1]
	var get_tt := EquipmentService.definition(StringName(_item)).category
	var granted := false
	if get_tt == "武器" or get_tt == "防具" or get_tt == "饰品" or get_tt == "时装" or get_tt == "头衔" or get_tt == "翅膀":
		granted = PlayerData.add_zb(_item, 0, item_4.eq_prop)
	elif get_tt == "道具" or get_tt == "消耗品":
		granted = PlayerData.add_dj(_item, 1)
	elif get_tt == "法宝":
		granted = PlayerData.add_fb(_item, 0, EquipmentService.rules().get_wx(), item_4.eq_prop)
	if not granted:
		PlayerData.restore_state(snapshot)
		Global.add_message_show(get_parent(), "背包已满，合成已撤销！", 1.5, Vector2(15, -45))
		return

	PlayerData.player_data["放入列表"]["物品1"].clear()
	PlayerData.player_data["放入列表"]["物品2"].clear()
	PlayerData.player_data["放入列表"]["物品3"].clear()
	if not MemoryClass.request_save("ldl_synthesis", false):
		PlayerData.restore_state(snapshot)
		Global.add_message_show(
			get_parent(), "存档保存失败，合成已撤销：" + MemoryClass.describe_save_error(), 1.5, Vector2(15, -45)
		)
		return
	Global.add_message_show(
		get_parent(),
		"合成成功！获得：" + EquipmentService.definition(StringName(_item)).display_name + " × 1！",
		1.5,
		Vector2(15, -45)
	)


func _on_help_pressed() -> void:
	Global.add_hc_help(NodeUtils.ancestor(self, 3), Vector2(455, 265))


func set_cailiao_pic():
	var list_1 = PlayerData.player_data["放入列表"]["物品1"]
	var list_2 = PlayerData.player_data["放入列表"]["物品2"]
	var list_3 = PlayerData.player_data["放入列表"]["物品3"]
	if list_1.size() == 0:
		item_1.set_button_icon(ItemUtils.equipment_icon_or_item_icon("empty"))
	else:
		item_1.set_button_icon(ItemUtils.equipment_icon_or_item_icon(list_1[0]))
	if list_2.size() == 0:
		item_2.set_button_icon(ItemUtils.equipment_icon_or_item_icon("empty"))
	else:
		item_2.set_button_icon(ItemUtils.equipment_icon_or_item_icon(list_2[0]))
	if list_3.size() == 0:
		item_3.set_button_icon(ItemUtils.equipment_icon_or_item_icon("empty"))
	else:
		item_3.set_button_icon(ItemUtils.equipment_icon_or_item_icon(list_3[0]))
	if list_1.size() > 3:
		item_1.qh_level = int(list_1[3])
		item_1.eq_prop = list_1[4]
	else:
		item_1.qh_level = 0
		item_1.eq_prop = {}
	if list_2.size() > 3:
		item_2.qh_level = int(list_2[3])
		item_2.eq_prop = list_2[4]
	else:
		item_2.qh_level = 0
		item_2.eq_prop = {}
	if list_3.size() > 3:
		item_3.qh_level = int(list_3[3])
		item_3.eq_prop = list_3[4]
	else:
		item_3.qh_level = 0
		item_3.eq_prop = {}


func get_xianjie_prop(result_item: String) -> Dictionary:
	var source_by_result := {
		"cjxianjie": "cjshenj",
		"cdxianjie": "cdshenj",
		"zhxianjie": "zhshenj",
	}
	var source_name := str(source_by_result.get(result_item, ""))
	var source_list: Array = []
	for list_name in ["物品1", "物品2", "物品3"]:
		var material_list: Variant = PlayerData.player_data["放入列表"].get(list_name, [])
		if material_list is Array and not (material_list as Array).is_empty():
			var candidate: Array = material_list as Array
			if str(candidate[0]) == source_name:
				source_list = candidate
				break

	var result := EquipmentService.data(StringName(result_item))
	if source_list.size() < 5:
		return result
	var source_data_value: Variant = source_list[4]
	var source_data: Dictionary = source_data_value if source_data_value is Dictionary else {}
	var source_level := int(source_list[3])
	var current_properties: Dictionary = EquipmentService.rules().get_divine_forge_properties(
		StringName(source_name), source_level, source_data, true
	)
	for property_name in prop_list_name:
		result[property_name] = current_properties.get(property_name, 0) * 2
	result[DataKeys.GEM] = []
	result.erase("神铸阶段")
	return result


func get_recipe(n_1: String, n_2: String, n_3: String) -> Array:
	var mats = [n_1, n_2, n_3]
	mats.sort()
	for recipe in RecipeData.RECIPES:
		if recipe.has("use_same_type") and recipe["use_same_type"]:
			if get_same_type(n_1, n_2, n_3, recipe["result"]):
				return [true, recipe["result"], recipe["cost"]]

		var recipe_mats = recipe["materials"].duplicate()
		recipe_mats.sort()
		if mats == recipe_mats:
			return [true, recipe["result"], recipe["cost"]]
	return [false, "", 0]


func get_fb_prop(name1):
	var list_1 = PlayerData.player_data["放入列表"]["物品1"]
	var list_2 = PlayerData.player_data["放入列表"]["物品2"]
	var list_3 = PlayerData.player_data["放入列表"]["物品3"]

	var prop1_dict = {}
	var prop2_dict = {}
	var prop3_dict = {}
	for attr in prop_list_name:
		prop1_dict[attr] = 0
		prop2_dict[attr] = 0
		prop3_dict[attr] = 0

	if list_1.size() >= 5:
		var prop1 = EquipmentService.rules().get_last_equ_pro(StringName(list_1[0]), list_1[3], list_1[4])
		for attr in prop_list_name:
			prop1_dict[attr] = prop1.get(attr, 0) if prop1 and prop1.has(attr) else 0
	if list_2.size() >= 5:
		var prop2 = EquipmentService.rules().get_last_equ_pro(StringName(list_2[0]), list_2[3], list_2[4])
		for attr in prop_list_name:
			prop2_dict[attr] = prop2.get(attr, 0) if prop2 and prop2.has(attr) else 0
	if list_3.size() >= 5:
		var prop3 = EquipmentService.rules().get_last_equ_pro(StringName(list_3[0]), list_3[3], list_3[4])
		for attr in prop_list_name:
			prop3_dict[attr] = prop3.get(attr, 0) if prop3 and prop3.has(attr) else 0

	var new_list = {}
	for attr in prop_list_name:
		var avg_val = int((prop1_dict[attr] + prop2_dict[attr] + prop3_dict[attr]) / 3)
		new_list[attr] = avg_val

	var proplist := EquipmentService.data(StringName(name1))
	for i in new_list:
		if proplist.has(i):
			proplist[i] += new_list[i]
		else:
			proplist[i] = new_list[i]

	return proplist


func get_equipment_prop(name_1):
	var list_1 = PlayerData.player_data["放入列表"]["物品1"]
	var list_2 = PlayerData.player_data["放入列表"]["物品2"]
	var list_3 = PlayerData.player_data["放入列表"]["物品3"]
	var proplist := EquipmentService.data(StringName(name_1))
	var name_prop_list: Array = prop_list_name
	var prop_old = {}

	for i in name_prop_list:
		var v1 = get_prop(list_1, i)
		var v2 = get_prop(list_2, i)
		var v3 = get_prop(list_3, i)
		var sum = v1 + v2 + v3

		if name_1 == "dzjj":
			prop_old[i] = int(sum)
		elif name_1 == "cjjj":
			prop_old[i] = int(sum * 2.0)
		else:
			prop_old[i] = int(sum * 3.0 / 4.0)

	for i in name_prop_list:
		if proplist.has(i):
			proplist[i] += prop_old[i]
		else:
			proplist[i] = prop_old[i]

	return proplist


func get_wx():
	randomize()
	var wx = {"金": false, "木": false, "水": false, "火": false, "土": false}
	var rr = randi_range(0, 100)
	if rr <= 4:
		var wx_lst = ["金", "木", "水", "火", "土"]
		var aa = randi_range(0, 4)
		var wx_1 = wx_lst[aa]
		wx_lst.erase(wx_1)
		var bb = randi_range(0, 3)
		var wx_2 = wx_lst[bb]
		wx_lst.erase(wx_2)
		var cc = randi_range(0, 2)
		var wx_3 = wx_lst[cc]
		wx[wx_1] = true
		wx[wx_2] = true
		wx[wx_3] = true
		var new_list = []
		for i in wx:
			if wx[i]:
				new_list.push_back(i)
		return new_list
	elif rr > 4 and rr < 10:
		var wx_lst = ["金", "木", "水", "火", "土"]
		var aa = randi_range(0, 4)
		var wx_1 = wx_lst[aa]
		wx_lst.erase(wx_1)
		var bb = randi_range(0, 3)
		var wx_2 = wx_lst[bb]
		wx[wx_1] = true
		wx[wx_2] = true
		var new_list = []
		for i in wx:
			if wx[i]:
				new_list.push_back(i)
		return new_list
	else:
		var new_list = []
		var wx_lst = ["金", "木", "水", "火", "土"]
		var aa = randi_range(0, 4)
		new_list.push_back(wx_lst[aa])
		return new_list


func get_same_type(Name_1, Name_2, Name_3, need: String):
	if Name_1 == null or Name_2 == null or Name_3 == null:
		return false
	if Name_1 == "" or Name_2 == "" or Name_3 == "":
		return false
	if Name_1 == Name_2 or Name_1 == Name_3 or Name_2 == Name_3:
		return false
	var definition_1 := EquipmentService.definition(StringName(str(Name_1)))
	var definition_2 := EquipmentService.definition(StringName(str(Name_2)))
	var definition_3 := EquipmentService.definition(StringName(str(Name_3)))
	if (
		definition_1 == null
		or definition_2 == null
		or definition_3 == null
		or not definition_1.has_defined_field(&"FBTYPE")
		or not definition_2.has_defined_field(&"FBTYPE")
		or not definition_3.has_defined_field(&"FBTYPE")
	):
		return false

	return definition_1.fb_type == need and definition_2.fb_type == need and definition_3.fb_type == need


func get_prop(list, need):
	var q_hlevel: int
	if EquipmentService.definition(StringName(list[0])).category == "道具":
		q_hlevel = 0
	else:
		q_hlevel = list[3]
	var prop_data: Dictionary = EquipmentService.rules().get_last_equ_pro(StringName(list[0]), q_hlevel, list[4])
	return prop_data[need] if prop_data.has(need) else 0

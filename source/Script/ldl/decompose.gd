extends Node2D
class_name Decompose

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var remove_items: Button = $scw/RemoveItems
@onready var item_list: GridContainer = $ScrollContainer/ItemList
@onready var lh: Label = $DecomposeButton/need_lh/lh
@onready var wait: Timer = $wait
var can_de: bool = true
var bs_list = ["sms_1", "fls_1", "mfs_1", "wfs_1", "gjs_1", "bjs_1", "sbs_1"]
var normal_items = {
	"qhs_2": {"Value": [{"name": "qhs_1", "num": 3}], "Need": 1000},
	"qhs_3": {"Value": [{"name": "qhs_2", "num": 3}], "Need": 1000},
	"qhs_4": {"Value": [{"name": "qhs_3", "num": 3}], "Need": 1000},
	"ttlp":
	{"Value": [{"name": "ttlp1", "num": 1}, {"name": "ttlp2", "num": 1}, {"name": "ttlp3", "num": 1}], "Need": 100},
}
var item_data = []
var need_lh: int
var is_set: bool


func _ready() -> void:
	remove_items.is_in_ldl_gz = true


func _physics_process(delta: float) -> void:
	if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
		is_set = false
		set_remove_items_properies()
		if Global.get_forge_factory().consume_decompose_item_changed():
			change_item_list()
	else:
		if not is_set:
			remove_l_ist()
			add_empty()
			is_set = true
		remove_infomation()


func pushqhs(name_str, Level):
	var refund := Strength.get_decompose_stone_refund(int(Level))
	for item_id in refund:
		item_data.push_back({"name": item_id, "num": int(refund[item_id])})


func add_empty():
	for i in range(8):
		Global.add_item_box(item_list, true, true, "empty", 0, 0, [], [])


func push_bs(name_str, type):
	match type:
		"传说", "神器":
			if randi_range(0, 100) < 30:
				for i in range(randi_range(1, 3)):
					item_data.push_back({"name": bs_list[randi_range(0, bs_list.size() - 1)], "num": 1})
		"魂器", "邪灵":
			if randi_range(0, 100) < 40:
				for i in range(randi_range(1, 2)):
					item_data.push_back({"name": bs_list[randi_range(0, bs_list.size() - 1)], "num": 1})


func push_basic_item(type):
	var basic_item_list = ["xuantie", "sichou", "tanmu"]
	match type:
		"普通":
			item_data.push_back({"name": basic_item_list[randi_range(0, 2)], "num": 1})
			return
		"优秀":
			item_data.push_back({"name": basic_item_list[randi_range(0, 2)], "num": 3})
			return
		"精良":
			item_data.push_back({"name": basic_item_list[randi_range(0, 2)], "num": 5})
			return
		"史诗":
			item_data.push_back({"name": basic_item_list[randi_range(0, 2)], "num": 7})
			return
		"传说":
			for i in range(randi_range(1, 2)):
				item_data.push_back({"name": basic_item_list[randi_range(0, 2)], "num": 7})
			return

	for i in range(randi_range(1, 3)):
		item_data.push_back({"name": basic_item_list[randi_range(0, 2)], "num": randi_range(5, 10)})


func bs_fj(name_str):
	var base := EquipmentService.definition(StringName(name_str)).origin
	if base != "宝石":
		return
	var name_list = str(name_str).split("_")
	var cur_level = name_list[1]
	var item_name = name_list[0]
	if base != "宝石":
		return
	if int(cur_level) <= 1:
		return
	normal_items[name_str] = {"Value": [], "Need": 100}
	for i in range(3):
		normal_items[name_str]["Value"].push_back({"name": str(item_name) + "_" + str(int(cur_level) - 1), "num": 1})


func change_item_list():
	remove_l_ist()
	item_data = []

	if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
		var name_str = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]
		var cur_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]
		var item_definition := EquipmentService.definition(StringName(name_str))
		var get_tt := item_definition.category
		if normal_items.has(name_str):
			if normal_items[name_str].has("Need"):
				need_lh = normal_items[name_str]["Need"]
				lh.text = str(normal_items[name_str]["Need"])
			else:
				need_lh = 1000
				lh.text = str(1000)
		else:
			need_lh = 1000
			lh.text = str(1000)
		var num: int = 0
		match get_tt:
			"武器", "饰品", "防具":
				pushqhs(name_str, cur_level)
				push_bs(name_str, item_definition.quality)
				push_basic_item(item_definition.quality)
				if item_data.size() != 0:
					for i in item_data:
						var item_name = i["name"]
						var type := EquipmentService.definition(StringName(item_name)).category
						var target_count = i["num"]
						var item_box_data := EquipmentService.data(StringName(item_name))
						var box
						match type:
							"武器", "饰品", "防具":
								box = Global.add_item_box(
									item_list, true, true, item_name, target_count, 0, [], item_box_data
								)
								box.set_button_icon(ItemUtils.item_icon(item_name))
							"道具":
								box = Global.add_item_box(
									item_list, true, true, item_name, 0, target_count, [], item_box_data
								)
								box.set_button_icon(ItemUtils.item_icon(item_name))
						num += 1
					if 8 - num > 0:
						for i in range(8 - num):
							Global.add_item_box(item_list, true, true, "empty", 0, 0, [], [])
				else:
					for i in range(8):
						Global.add_item_box(item_list, true, true, "empty", 0, 0, [], [])

			"道具":
				bs_fj(name_str)
				if not normal_items.has(name_str):
					for i in range(8):
						Global.add_item_box(item_list, true, true, "empty", 0, 0, [], [])
					return
				else:
					for i in normal_items[name_str]["Value"]:
						var box = Global.add_item_box(
							item_list,
							true,
							true,
							i["name"],
							0,
							i["num"],
							[],
							EquipmentService.data(StringName(i["name"]))
						)
						box.set_button_icon(ItemUtils.item_icon(i["name"]))
						num += 1
					if 8 - num > 0:
						for i in range(8 - num):
							Global.add_item_box(item_list, true, true, "empty", 0, 0, [], [])


func remove_l_ist():
	item_data = []
	for i in item_list.get_children():
		if i != null:
			i.free()


func set_remove_items_properies():
	remove_items.set_button_icon(
		ItemUtils.item_icon(str(PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]))
	)
	remove_items.qh_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
	remove_items.eq_prop = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]


func _on_decompose_button_pressed() -> void:
	if not can_de:
		Global.add_message_show(Global.get_ui_runtime().windows, "点击过快！", 1.5)
		return
	else:
		can_de = false
		wait.start(0.1)
	if PlayerData.get_soul() < need_lh:
		Global.add_message_show(Global.get_ui_runtime().windows, "灵魂不足！", 1.5)
		return

	if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
		var name_str = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]
		var cur_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]
		var item_definition := EquipmentService.definition(StringName(name_str))
		var get_tt := item_definition.category
		var typee := item_definition.category
		var item_name := item_definition.display_name
		if cur_level > 0:
			var dialog_enhanced = Global.add_choose_text(
				NodeUtils.ancestor(self, 3), Vector2(0, 0), "确定要分解" + str(item_name) + "吗？（返还累计消耗强化石的80%，各等级分别向下取整）", 0
			)
			if dialog_enhanced != null:
				dialog_enhanced.confirmed.connect(fj)
		else:
			var dialog_plain = Global.add_choose_text(
				NodeUtils.ancestor(self, 3), Vector2(0, 0), "确定要分解" + str(item_name) + "吗？", 0
			)
			if dialog_plain != null:
				dialog_plain.confirmed.connect(fj)
	else:
		Global.add_message_show(Global.get_ui_runtime().windows, "先放点什么吧～", 1.5)


func fj():
	if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
		var list = []
		var name_str = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]
		var cur_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]
		var item_definition := EquipmentService.definition(StringName(name_str))
		var get_tt := item_definition.category
		var typee := item_definition.category
		var item_name := item_definition.display_name
		match get_tt:
			"武器", "饰品", "防具":
				if item_data.size() != 0:
					for i in item_data:
						var sub_item_name = i["name"]
						var type := EquipmentService.definition(StringName(sub_item_name)).category
						var target_count = i["num"]
						var box
						match type:
							"武器", "饰品", "防具":
								list.push_back(
									{
										"Name": sub_item_name,
										"Value": 1,
										"Prop": EquipmentService.data(StringName(sub_item_name)),
										"WX": [],
										"strength_value": target_count
									}
								)
								PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
							"道具":
								list.push_back(
									{
										"Name": item_name,
										"Value": target_count,
										"Prop": [],
										"WX": [],
										"strength_value": 0
									}
								)
								PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
					Global.add_reward_info(NodeUtils.ancestor(self, 3), Vector2(0, 0), list, null, null)
					Global.add_message_show(Global.get_ui_runtime().windows, "分解成功！！", 1.5)
					PlayerData.spend_soul(need_lh)
				else:
					Global.add_message_show(
						Global.get_ui_runtime().windows, str(typee) + str(item_name) + "不会分解出任何物品！！", 1.5
					)

			"道具":
				bs_fj(name_str)
				if not normal_items.has(name_str):
					var _name := item_definition.display_name
					var type := item_definition.category
					Global.add_message_show(Global.get_ui_runtime().windows, str(type) + str(_name) + "不可以进行分解！！", 1.5)
					return
				else:
					PlayerData.spend_soul(need_lh)
					for i in normal_items[name_str]["Value"]:
						var loop_item_name = i["name"]
						var target_count = i["num"]
						list.push_back(
							{"Name": loop_item_name, "Value": target_count, "Prop": [], "WX": [], "strength_value": 0}
						)
					Global.add_reward_info(NodeUtils.ancestor(self, 3), Vector2(0, 0), list, null, null)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
					Global.add_message_show(Global.get_ui_runtime().windows, "分解成功！！", 1.5)


func remove_infomation():
	if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
		var name_str = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]
		var cur_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]
		var get_tt := EquipmentService.definition(StringName(name_str)).category
		match get_tt:
			"武器", "饰品", "防具":
				PlayerData.add_zb(name_str, cur_level, data)
				PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
			"道具":
				PlayerData.add_dj(name_str, 1)
	remove_items.set_button_icon(ItemUtils.item_icon(str("empty")))
	PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()


func _on_help_pressed() -> void:
	Global.add_decompose_help(NodeUtils.ancestor(self, 3), Vector2(485, 290))


func _on_wait_timeout() -> void:
	print("123")
	can_de = true

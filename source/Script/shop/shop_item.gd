extends Node2D

@onready var item_name: Label = $BG/name_
@onready var lh_need: Label = $BG/lh_value
@onready var need_num = $BG/num_/num_kj/num_
@onready var items: Button = $BG/bgg/Items

const MAX_SHOP_BUY_NUM: int = 9999

var eq_prop = {}
var total_num: int = 1
var _item_name: String
var choose_jm
var need_lh: int


func _ready() -> void:
	items.is_in_shop = true


func _physics_process(_delta: float) -> void:
	items.is_in_shop = true
	if not need_num.has_focus():
		if total_num <= 1:
			_set_total_num(1)
		elif total_num > MAX_SHOP_BUY_NUM:
			_set_total_num(MAX_SHOP_BUY_NUM)
	if _item_name != "" and AE.all_equipment.has(_item_name):
		item_name.text = str(AE.all_equipment[_item_name].get(DataKeys.NAME, _item_name))
		items.set_button_icon(load_item_icon(_item_name))
		items.qh_level = 0
		items.wx = []
		items.eq_prop = AE.all_equipment[_item_name]
	lh_need.text = str(_effective_price())


func _effective_price() -> int:
	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_FREE_SHOP):
		return 0
	return maxi(0, need_lh)


func _set_total_num(value: int) -> void:
	total_num = clampi(value, 1, MAX_SHOP_BUY_NUM)
	if need_num != null and need_num.text != str(total_num):
		need_num.text = str(total_num)


func _get_safe_buy_num() -> int:
	return clampi(total_num, 1, MAX_SHOP_BUY_NUM)


func _get_safe_total_cost(buy_num: int) -> int:
	var unit_price := _effective_price()
	if unit_price <= 0:
		return 0
	return unit_price * buy_num


func _can_pay_for_count(buy_num: int) -> bool:
	if buy_num <= 0:
		return false
	var unit_price := _effective_price()
	if unit_price <= 0:
		return true
	var coin_num: int = PlayerData.get_soul()
	return buy_num <= int(coin_num / unit_price)


func _get_backpack_list_name(item_type: String) -> String:
	match item_type:
		"武器", "防具", "饰品", "翅膀", "头衔", "时装", "法宝":
			return "装备列表"
		"道具":
			return "道具列表"
		"消耗品":
			return "消耗品列表"
		"宠物装备":
			return PlayerData.PET_BACKPACK_KEY
		_:
			return "装备列表"


func _get_free_item_capacity(item_type: String, list_name: String) -> int:
	if item_type == "宠物装备":
		return maxi(0, 40 - PlayerData.ensure_shared_pet_backpack().size())
	var pages_value: Variant = PlayerData.player_data.get(list_name, {})
	if not pages_value is Dictionary:
		return 0
	var free_slots := 0
	for page_value: Variant in (pages_value as Dictionary).values():
		if page_value is Array:
			free_slots += maxi(0, 25 - page_value.size())
	return free_slots


func _on_cure_num_pressed() -> void:
	_set_total_num(total_num + 1)


func _on_reduce_num_pressed() -> void:
	_set_total_num(total_num - 1)


func _on_num_text_changed(new_text: String) -> void:
	var clean_text := new_text.strip_edges()
	if clean_text == "":
		return
	total_num = clampi(int(clean_text), 1, MAX_SHOP_BUY_NUM)


func _on_num_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_set_total_num(total_num)


func _on_goumai_pressed() -> void:
	var _parent = Global.get_ancestor(self, 3)
	var buy_num := _get_safe_buy_num()
	if not _can_pay_for_count(buy_num):
		Global.add_message_show(_parent, "灵魂不足！", 1.5, Vector2(485, 295))
		return
	Signals.connect_choose_box_signal(self, "gm")
	choose_jm = Global.add_choose_text(
		_parent,
		Vector2(0, 0),
		"确定花费" + str(_get_safe_total_cost(buy_num)) + "灵魂购买" + str(buy_num) + "个" + str(item_name.text) + "吗？",
		0
	)


func add_item_toplayer(times):
	var _parent = Global.get_ancestor(self, 3)
	if _item_name == "" or not AE.all_equipment.has(_item_name):
		Global.add_message_show(_parent, "商品信息错误！", 1.5, Vector2(485, 295))
		return

	var buy_num := clampi(int(times), 1, MAX_SHOP_BUY_NUM)
	_set_total_num(buy_num)
	var item_data: Dictionary = AE.all_equipment[_item_name]
	var lx = str(item_data.get(DataKeys.TYPE, ""))
	var cklb := _get_backpack_list_name(lx)

	if not _can_pay_for_count(buy_num):
		Global.add_message_show(_parent, "灵魂不足！", 1.5, Vector2(485, 295))
		return

	var free_slot_count := _get_free_item_capacity(lx, cklb)
	if free_slot_count == 0:
		Global.add_message_show(_parent, "背包已满！", 1.5, Vector2(485, 295))
		return
	if lx in ["武器", "防具", "饰品", "翅膀", "头衔", "时装", "法宝", "宠物装备"] and buy_num > free_slot_count:
		Global.add_message_show(_parent, "背包空位不足！", 1.5, Vector2(485, 295))
		return

	PlayerData.spend_soul(_get_safe_total_cost(buy_num))

	match lx:
		"武器", "防具", "饰品", "翅膀", "头衔", "时装":
			for i in range(buy_num):
				PlayerData.add_zb(_item_name, 0, {})
		"法宝":
			for i in range(buy_num):
				PlayerData.add_fb(_item_name, 0, AE.get_wx(), {})
		"道具":
			PlayerData.add_dj(_item_name, buy_num)
		"消耗品":
			PlayerData.add_xhp(_item_name, buy_num)
		"宠物装备":
			PlayerData.add_pet_backpack_item(_item_name, buy_num)
		_:
			for i in range(buy_num):
				PlayerData.add_zb(_item_name, 0, {})

	Global.add_message_show(_parent, "购买成功！", 1.5, Vector2(485, 295))


func load_item_icon(_name):
	return load("res://Art/backpack/all_items/" + str(_name) + ".png")


func gm():
	add_item_toplayer(total_num)

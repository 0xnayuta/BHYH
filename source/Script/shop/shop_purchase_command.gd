class_name ShopPurchaseCommand
extends RefCounted

## 普通商店购买的唯一提交命令：校验 → 快照 → 扣费 → 产出 → 保存。
## 任一产出或保存失败都恢复 1P/2P 档案与共享容器，不留下部分扣费或物品。

const MAX_BUY_NUM := 9999
const SAVE_REASON := "shop_purchase"
const MYSTERY_SAVE_REASON := "shop_mystery_purchase"
const EQUIPMENT_TYPES := ["武器", "防具", "饰品", "翅膀", "头衔", "时装", "法宝", "宠物装备"]


static func execute(item_name: String, buy_num: int, unit_price: int) -> Dictionary:
	return _execute(item_name, buy_num, unit_price, SAVE_REASON, 0, [], false)


static func execute_mystery(
	item_name: String, quantity: int, unit_price: int, item_level: int = 0, item_wx: Array = []
) -> Dictionary:
	return _execute(item_name, quantity, unit_price, MYSTERY_SAVE_REASON, item_level, item_wx, true)


static func _execute(
	item_name: String,
	buy_num: int,
	unit_price: int,
	save_reason: String,
	item_level: int,
	item_wx: Array,
	use_purchase_count: bool
) -> Dictionary:
	if item_name == "" or not AE.all_equipment.has(item_name):
		return _failure("商品信息错误！")
	if use_purchase_count and int(PlayerData.player_data.get(DataKeys.SHOP_PURCHASE_COUNT, 0)) <= 0:
		return _failure("购买次数不足！！")
	var count := clampi(buy_num, 1, MAX_BUY_NUM)
	var item_data: Dictionary = AE.all_equipment[item_name]
	var item_type := str(item_data.get(DataKeys.TYPE, ""))
	var free_slots := _free_slot_count(item_type, item_name)
	if not _can_receive(item_type, item_name, count, free_slots):
		if free_slots == 0 and not _has_existing_stack(item_type, item_name):
			return _failure("背包已满！")
		return _failure("背包空位不足！")

	var cost := maxi(0, unit_price) * count
	if PlayerData.get_soul() < cost:
		return _failure("灵魂不足！")

	var snapshot := PlayerData.snapshot_state()
	if not PlayerData.spend_soul(cost):
		PlayerData.restore_state(snapshot)
		return _failure("灵魂不足！")
	if use_purchase_count:
		PlayerData.player_data[DataKeys.SHOP_PURCHASE_COUNT] = (
			int(PlayerData.player_data.get(DataKeys.SHOP_PURCHASE_COUNT, 0)) - 1
		)
	if not _grant_items(item_name, item_type, count, item_level, item_wx):
		PlayerData.restore_state(snapshot)
		return _failure("背包已满，本次购买已撤销！")
	if not MemoryClass.request_save(save_reason):
		PlayerData.restore_state(snapshot)
		return _failure("存档保存失败，本次购买已撤销：%s" % MemoryClass.describe_save_error())
	return {"ok": true, "count": count, "cost": cost}


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}


static func _has_existing_stack(item_type: String, item_name: String) -> bool:
	if item_type == "道具":
		return PlayerData.get_dj_page(item_name) != 0
	if item_type == "消耗品":
		return PlayerData.get_xhp_page(item_name) != 0
	return false


static func _free_slot_count(item_type: String, item_name: String) -> int:
	if _has_existing_stack(item_type, item_name):
		return 1
	if item_type == "宠物装备":
		return maxi(0, 40 - PlayerData.ensure_shared_pet_backpack().size())
	var list_name := _backpack_list_name(item_type)
	var pages_value: Variant = PlayerData.player_data.get(list_name, {})
	if not pages_value is Dictionary:
		return 0
	var free_slots := 0
	for page_value: Variant in (pages_value as Dictionary).values():
		if page_value is Array:
			free_slots += maxi(0, 25 - (page_value as Array).size())
	return free_slots


static func _backpack_list_name(item_type: String) -> String:
	match item_type:
		"道具":
			return DataKeys.ITEM_LIST
		"消耗品":
			return DataKeys.CONSUMABLE_LIST
		"宠物装备":
			return PlayerData.PET_BACKPACK_KEY
		_:
			return DataKeys.EQUIPMENT_LIST


static func _can_receive(item_type: String, item_name: String, count: int, free_slots: int) -> bool:
	if item_type in EQUIPMENT_TYPES:
		return count <= free_slots
	if item_type in ["道具", "消耗品"]:
		return _has_existing_stack(item_type, item_name) or free_slots > 0
	return count <= free_slots


static func _grant_items(item_name: String, item_type: String, count: int, item_level: int, item_wx: Array) -> bool:
	match item_type:
		"武器", "防具", "饰品", "翅膀", "头衔", "时装":
			for _index in range(count):
				if not PlayerData.add_zb(item_name, item_level, {}):
					return false
		"法宝":
			var wx: Array = item_wx if not item_wx.is_empty() else AE.get_wx()
			for _index in range(count):
				if not PlayerData.add_fb(item_name, item_level, wx, {}):
					return false
		"道具":
			return PlayerData.add_dj(item_name, count)
		"消耗品":
			return PlayerData.add_xhp(item_name, count)
		"宠物装备":
			return PlayerData.add_pet_backpack_item(item_name, count) == count
		_:
			for _index in range(count):
				if not PlayerData.add_zb(item_name, 0, {}):
					return false
	return true

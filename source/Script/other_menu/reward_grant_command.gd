class_name RewardGrantCommand
extends RefCounted

## 奖励界面的唯一提交命令：校验 → 快照 → 发放 → 扣除使用物 → 保存。
## 任一发放、扣除或保存失败都恢复 1P/2P 档案，不留下部分奖励或误扣使用物。

const SAVE_REASON := "reward_interface"
const ALL_TYPES := ["武器", "防具", "饰品", "神骨", "翅膀", "头衔", "时装", "法宝", "道具", "消耗品", "宠物装备"]


static func execute(reward_items: Array, use_item_name: String, use_num: int) -> Dictionary:
	var normalized: Array = []
	for entry in reward_items:
		if not entry is Dictionary:
			return _failure("奖励数据异常，未发放")
		var reward: Dictionary = entry
		var item_name := str(reward.get("Name", ""))
		if item_name == "" or not AE.all_equipment.has(item_name):
			return _failure("奖励物品不存在，未发放")
		var item_type := str(AE.all_equipment[item_name].get(DataKeys.TYPE, ""))
		if item_type not in ALL_TYPES:
			return _failure("奖励类型不支持，未发放")
		(
			normalized
			. append(
				{
					"name": item_name,
					"type": item_type,
					"value": maxi(1, int(reward.get("Value", 1))),
					"strength": int(reward.get("strength_value", 0)),
					"prop": reward.get("Prop", {}),
					"wx": reward.get("WX", []),
				}
			)
		)
	if use_item_name != "":
		if not AE.all_equipment.has(use_item_name) or use_num <= 0:
			return _failure("使用道具数据异常，未发放")
		var use_type := str(AE.all_equipment[use_item_name].get(DataKeys.TYPE, ""))
		var owned: int = (
			PlayerData.get_item_data(use_item_name)
			if use_type == "道具"
			else PlayerData.get_xhp_data(use_item_name) if use_type == "消耗品" else 0
		)
		if owned < use_num:
			return _failure("使用道具数量不足，未发放")

	var snapshot := PlayerData.snapshot_state()
	for reward in normalized:
		if not _grant(reward):
			PlayerData.restore_state(snapshot)
			return _failure("背包已满，本次奖励已撤销")
	if use_item_name != "" and not PlayerData.remove_item(use_item_name, use_num):
		PlayerData.restore_state(snapshot)
		return _failure("使用道具数量不足，本次奖励已撤销")
	if not MemoryClass.request_save(SAVE_REASON):
		PlayerData.restore_state(snapshot)
		return _failure("存档保存失败，本次奖励已撤销：%s" % MemoryClass.describe_save_error())
	return {"ok": true}


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}


static func _grant(reward: Dictionary) -> bool:
	var item_name: String = reward["name"]
	var item_type: String = reward["type"]
	var value: int = reward["value"]
	match item_type:
		"武器", "防具", "饰品", "神骨", "翅膀", "头衔", "时装":
			for _index in range(value):
				if not PlayerData.add_zb(item_name, reward["strength"], reward["prop"]):
					return false
		"法宝":
			for _index in range(value):
				if not PlayerData.add_fb(item_name, reward["strength"], reward["wx"], reward["prop"]):
					return false
		"道具":
			return PlayerData.add_dj(item_name, value)
		"消耗品":
			return PlayerData.add_xhp(item_name, value)
		"宠物装备":
			return PlayerData.add_pet_backpack_item(item_name, value) == value
		_:
			return false
	return true

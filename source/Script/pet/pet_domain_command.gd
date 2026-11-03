class_name PetDomainCommand
extends RefCounted

## 宠物域显式命令：出战、休息与成长提交。
## 命令只修改调用方提供的档案，并在保存失败时恢复档案快照；加载、补全与保存实现仍归 PlayerData/MemoryClass。

const SAVE_REASON_DEPLOY := "pet_deploy"
const SAVE_REASON_REST := "pet_rest"
const SAVE_REASON_GROWTH := "pet_growth"
const SAVE_REASON_FORMATION := "pet_formation"
const FORMATION_MAX_LEVEL := 100
const FORMATION_DEFINITIONS := [
	{"stat": "生命", "gain": 400, "stone": "zqjs", "core": "zqjh", "stone_name": "朱雀晶石", "core_name": "朱雀晶核"},
	{"stat": "攻击", "gain": 50, "stone": "zqjs", "core": "zqjh", "stone_name": "朱雀晶石", "core_name": "朱雀晶核"},
	{"stat": "暴击", "gain": 5, "stone": "zqjs", "core": "zqjh", "stone_name": "朱雀晶石", "core_name": "朱雀晶核"},
	{"stat": "幸运", "gain": 5, "stone": "zqjs", "core": "zqjh", "stone_name": "朱雀晶石", "core_name": "朱雀晶核"},
	{"stat": "破甲", "gain": 5, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
	{"stat": "破魔", "gain": 5, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
	{"stat": "闪避", "gain": 5, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
	{"stat": "物防", "gain": 25, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
	{"stat": "魔防", "gain": 25, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
]


static func formation_definition(stat_name: String) -> Dictionary:
	for definition in FORMATION_DEFINITIONS:
		if str(definition.get("stat", "")) == stat_name:
			return definition
	return {}


static func formation_cost(level: int) -> Vector2i:
	var stone_cost := clampi(level, 0, FORMATION_MAX_LEVEL) + 2
	return Vector2i(stone_cost, ceili(float(stone_cost) * 0.5))


## 阵法升级：按可负担级数一次性扣除材料、升级并保存；保存失败恢复全部档案快照。
static func upgrade_formation(
	profile: PlayerDataStore, stat_name: String, requested_count: int = 1, save_request: Callable = Callable()
) -> Dictionary:
	if profile == null or not is_instance_valid(profile):
		return _failure("宠物档案不可用")
	var definition := formation_definition(stat_name)
	if definition.is_empty():
		return _failure("未知阵法属性")
	var levels := profile.get_pet_formation_levels()
	var level := clampi(int(levels.get(stat_name, 0)), 0, FORMATION_MAX_LEVEL)
	if level >= FORMATION_MAX_LEVEL:
		return _failure("%s阵法已满级" % stat_name)
	var stone_id := str(definition.get("stone", ""))
	var core_id := str(definition.get("core", ""))
	var stone_available := int(profile.count_item_amount(stone_id))
	var core_available := int(profile.count_item_amount(core_id))
	var max_steps := mini(maxi(requested_count, 1), FORMATION_MAX_LEVEL - level)
	var stone_total := 0
	var core_total := 0
	var steps := 0
	for offset in range(max_steps):
		var cost := formation_cost(level + offset)
		if stone_available < stone_total + cost.x or core_available < core_total + cost.y:
			break
		stone_total += cost.x
		core_total += cost.y
		steps += 1
	if steps <= 0:
		var next_cost := formation_cost(level)
		return _failure(
			(
				"材料不足：需要%s×%d、%s×%d"
				% [
					str(definition.get("stone_name", stone_id)),
					next_cost.x,
					str(definition.get("core_name", core_id)),
					next_cost.y
				]
			)
		)

	var snapshot := _shared_snapshot(profile)
	var stone_page := int(profile.get_dj_page(stone_id))
	var core_page := int(profile.get_dj_page(core_id))
	if stone_page <= 0 or core_page <= 0:
		return _failure("阵法材料不在道具页")
	profile.remove_dj(stone_id, stone_page, stone_total)
	profile.remove_dj(core_id, int(profile.get_dj_page(core_id)), core_total)
	if (
		int(profile.count_item_amount(stone_id)) != stone_available - stone_total
		or int(profile.count_item_amount(core_id)) != core_available - core_total
	):
		_restore_shared(profile, snapshot)
		return _failure("阵法材料扣除不完整，本次升级已撤销")
	levels[stat_name] = level + steps
	profile.player_data[PlayerDataStore.PET_FORMATION_LEVELS_KEY] = levels
	var save_result := _request_save_result(SAVE_REASON_FORMATION, save_request)
	if not bool(save_result.get("ok", false)):
		_restore_shared(profile, snapshot)
		return _failure("存档保存失败，本次阵法升级已撤销：" + _save_message(save_result))
	return {
		"ok": true,
		"changed": true,
		"reason": SAVE_REASON_FORMATION,
		"upgraded_count": steps,
		"level": level + steps,
	}


static func deploy(
	profile: PlayerDataStore, pet_index: int, active_name: String, save_request: Callable = Callable()
) -> Dictionary:
	var pets := _pets(profile)
	if pets.is_empty() or pet_index < 0 or pet_index >= pets.size() or not (pets[pet_index] is Dictionary):
		return _failure("宠物数据不存在")
	if active_name.strip_edges() == "":
		return _failure("宠物出战名称为空")
	var pet: Dictionary = pets[pet_index]
	var snapshot := _snapshot(profile)
	var active_before := _active_name(profile)
	var changed := active_before != active_name
	for index in pets.size():
		var item_value: Variant = pets[index]
		if not (item_value is Dictionary):
			continue
		var item: Dictionary = item_value
		var should_deploy := index == pet_index
		if bool(item.get(DataKeys.DEPLOYED, false)) != should_deploy:
			changed = true
		item[DataKeys.DEPLOYED] = should_deploy
	profile.player_data[PlayerDataStore.ACTIVE_PET_KEY] = active_name
	if not changed:
		return {"ok": true, "changed": false, "active_name": active_name}
	return _commit_or_restore(
		profile, SAVE_REASON_DEPLOY, save_request, {"snapshot": snapshot, "active_name": active_name}
	)


static func rest(profile: PlayerDataStore, pet_index: int, save_request: Callable = Callable()) -> Dictionary:
	var pets := _pets(profile)
	if pets.is_empty() or pet_index < 0 or pet_index >= pets.size() or not (pets[pet_index] is Dictionary):
		return _failure("宠物数据不存在")
	var pet: Dictionary = pets[pet_index]
	var snapshot := _snapshot(profile)
	var active_before := _active_name(profile)
	var changed := bool(pet.get(DataKeys.DEPLOYED, false))
	pet[DataKeys.DEPLOYED] = false
	if active_before != "" and _matches_active(pet, active_before):
		profile.player_data[PlayerDataStore.ACTIVE_PET_KEY] = ""
		changed = true
	if not changed:
		return {"ok": true, "changed": false}
	return _commit_or_restore(profile, SAVE_REASON_REST, save_request, {"snapshot": snapshot})


static func commit_growth(
	profile: PlayerDataStore,
	pet_index: int,
	apply: Callable,
	reason: String = SAVE_REASON_GROWTH,
	save_request: Callable = Callable()
) -> Dictionary:
	var pets := _pets(profile)
	if pets.is_empty() or pet_index < 0 or pet_index >= pets.size() or not (pets[pet_index] is Dictionary):
		return _failure("宠物数据不存在")
	if not apply.is_valid():
		return _failure("成长提交回调无效")
	var snapshot := _snapshot(profile)
	var result: Variant = apply.call(pets[pet_index])
	if result is bool and not bool(result):
		_restore(profile, snapshot)
		return {"ok": false, "cancelled": true, "message": "成长提交已取消"}
	if result is Dictionary and not bool((result as Dictionary).get("ok", true)):
		_restore(profile, snapshot)
		return result
	return _commit_or_restore(profile, reason, save_request, {"snapshot": snapshot})


static func _commit_or_restore(
	profile: PlayerDataStore, reason: String, save_request: Callable, result: Dictionary
) -> Dictionary:
	var snapshot: Dictionary = result.get("snapshot", {})
	if snapshot.is_empty():
		snapshot = _snapshot(profile)
	if _request_save(reason, save_request):
		result["ok"] = true
		result.erase("snapshot")
		return result
	_restore(profile, snapshot)
	return _failure("存档保存失败：" + _describe_save_error())


static func _request_save(reason: String, save_request: Callable) -> bool:
	if save_request.is_valid():
		return bool(save_request.call(reason))
	return bool(_default_save_result(reason).get("ok", false))


static func _request_save_result(reason: String, save_request: Callable) -> Dictionary:
	if save_request.is_valid():
		var result: Variant = save_request.call(reason)
		if result is Dictionary:
			return result
		return {"ok": bool(result), "message": "" if bool(result) else _describe_save_error()}
	return _default_save_result(reason)


static func _default_save_result(reason: String) -> Dictionary:
	var memory := _memory_class()
	if memory == null or not memory.has_method("request_save_result"):
		return {"ok": false, "message": ""}
	var result: Variant = memory.call("request_save_result", reason, false)
	return result if result is Dictionary else {"ok": false, "message": ""}


static func _describe_save_error() -> String:
	var memory := _memory_class()
	if memory == null or not memory.has_method("describe_save_error"):
		return ""
	return str(memory.call("describe_save_error"))


static func _memory_class() -> Node:
	var loop := Engine.get_main_loop()
	if not (loop is SceneTree):
		return null
	return (loop as SceneTree).root.get_node_or_null("MemoryClass")


static func _save_message(save_result: Dictionary) -> String:
	var message := str(save_result.get("message", ""))
	return message if message != "" else _describe_save_error()


static func _shared_snapshot(profile: PlayerDataStore) -> Dictionary:
	var primary := _primary_profile()
	if primary != null and is_instance_valid(primary):
		return primary.snapshot_state()
	return _snapshot(profile)


static func _restore_shared(profile: PlayerDataStore, snapshot: Dictionary) -> void:
	var primary := _primary_profile()
	if primary != null and is_instance_valid(primary) and not snapshot.is_empty():
		primary.restore_state(snapshot)
		return
	_restore(profile, snapshot)


static func _primary_profile() -> PlayerDataStore:
	var loop := Engine.get_main_loop()
	if not (loop is SceneTree):
		return null
	return (loop as SceneTree).root.get_node_or_null("PlayerData") as PlayerDataStore


static func _snapshot(profile: PlayerDataStore) -> Dictionary:
	return profile.snapshot_state() if profile != null and is_instance_valid(profile) else {}


static func _restore(profile: PlayerDataStore, snapshot: Dictionary) -> void:
	if not snapshot.is_empty() and profile != null and is_instance_valid(profile):
		profile.restore_state(snapshot)


static func _pets(profile: PlayerDataStore) -> Array:
	if profile == null or not is_instance_valid(profile) or not (profile.player_data is Dictionary):
		return []
	var value: Variant = profile.player_data.get(PlayerDataStore.PET_LIST_KEY, [])
	return value if value is Array else []


static func _active_name(profile: PlayerDataStore) -> String:
	if profile == null or not is_instance_valid(profile):
		return ""
	return str(profile.player_data.get(PlayerDataStore.ACTIVE_PET_KEY, ""))


static func _matches_active(pet: Dictionary, active: String) -> bool:
	return (
		str(pet.get(DataKeys.TYPE, "")) == active
		or str(pet.get(DataKeys.ALT_NAME, "")) == active
		or str(pet.get(DataKeys.NAME, "")) == active
	)


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}

class_name PetDomainCommand
extends RefCounted

## 宠物域显式命令：出战、休息与成长提交。
## 命令只修改调用方提供的档案，并在保存失败时恢复档案快照；加载、补全与保存实现仍归 PlayerData/MemoryClass。

const SAVE_REASON_DEPLOY := "pet_deploy"
const SAVE_REASON_REST := "pet_rest"
const SAVE_REASON_GROWTH := "pet_growth"


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
	return _failure("存档保存失败：" + MemoryClass.describe_save_error())


static func _request_save(reason: String, save_request: Callable) -> bool:
	if save_request.is_valid():
		return bool(save_request.call(reason))
	return MemoryClass.request_save(reason, false)


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

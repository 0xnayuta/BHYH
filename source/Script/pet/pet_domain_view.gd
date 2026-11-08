class_name PetDomainView
extends RefCounted

## PlayerData 宠物域的只读视图：只暴露副本与标量，不返回可写档案字典。
## 生命周期与槽位由调用方提供的 PlayerDataStore 决定；View 不保存、不补全、不修改宠物。

var _profile: PlayerDataStore


func _init(profile: PlayerDataStore) -> void:
	_profile = profile


func is_valid() -> bool:
	return _profile != null and is_instance_valid(_profile) and _profile.player_data is Dictionary


func is_empty() -> bool:
	return pet_count() == 0


func pet_count() -> int:
	var pets := _pets_value()
	return pets.size()


func active_name() -> String:
	if not is_valid():
		return ""
	return str(_profile.player_data.get(PlayerDataStore.ACTIVE_PET_KEY, ""))


func active_index() -> int:
	var active := active_name()
	if active == "":
		return -1
	var pets := _pets_value()
	for index in pets.size():
		if pets[index] is Dictionary and _matches_active(pets[index], active):
			return index
	return -1


func pets() -> Array:
	return _pets_value().duplicate(true)


func pet_at(index: int) -> Dictionary:
	var pets := _pets_value()
	if index < 0 or index >= pets.size() or not (pets[index] is Dictionary):
		return {}
	return (pets[index] as Dictionary).duplicate(true)


func find_index(pet_name: String) -> int:
	var clean_name := pet_name.strip_edges()
	if clean_name == "":
		return -1
	var pets := _pets_value()
	for index in pets.size():
		var pet: Variant = pets[index]
		if not (pet is Dictionary):
			continue
		if (
			str(pet.get(DataKeys.TYPE, "")) == clean_name
			or str(pet.get(DataKeys.ALT_NAME, "")) == clean_name
			or str(pet.get(DataKeys.NAME, "")) == clean_name
		):
			return index
	return -1


func is_deployed(index: int) -> bool:
	var pets := _pets_value()
	if index < 0 or index >= pets.size() or not (pets[index] is Dictionary):
		return false
	return bool((pets[index] as Dictionary).get(DataKeys.DEPLOYED, false))


func _pets_value() -> Array:
	if not is_valid():
		return []
	var value: Variant = _profile.player_data.get(PlayerDataStore.PET_LIST_KEY, [])
	return value if value is Array else []


func _matches_active(pet_value: Variant, active: String) -> bool:
	if not (pet_value is Dictionary):
		return false
	var pet: Dictionary = pet_value
	return (
		str(pet.get(DataKeys.TYPE, "")) == active
		or str(pet.get(DataKeys.ALT_NAME, "")) == active
		or str(pet.get(DataKeys.NAME, "")) == active
	)

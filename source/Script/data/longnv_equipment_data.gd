extends RefCounted
class_name LongnvEquipmentData

## 小龙女（Role8）的运行时装备辅助数据。
## 静态装备定义由 `scripts/equipment_sources.json` + `equipment_catalog.tres` 承担；
## 本类只服务掉落映射、外观、炼丹炉与图鉴来源查询，不保存运行时物品字典。

const DEFINITIONS := "res://Art/hero_picture/role_8/equipment.json"
static var _definitions: Array = []


static func definitions() -> Array:
	if _definitions.is_empty():
		_definitions = JSON.parse_string(FileAccess.get_file_as_string(DEFINITIONS))
	return _definitions


static func item_ids() -> Array:
	var result: Array = []
	for entry: Dictionary in definitions():
		result.append(str(entry.id))
	return result


static func add_forge_materials(materials: Dictionary) -> void:
	for entry: Dictionary in definitions():
		if not bool(entry.book):
			continue
		var source_key: String = str(entry.get("source_base", entry.base)) + "zzs"
		var fallback: String = "240007001zzs" if str(entry.part) == "武器" else "241007001zzs"
		var material_source: Dictionary = materials.get(source_key, materials.get(fallback, {}))
		materials[str(entry.id) + "zzs"] = material_source.duplicate(true)


static func from_nezha(item_id: String) -> String:
	var book := item_id.ends_with("zzs")
	var source := item_id.trim_suffix("zzs") if book else item_id
	for entry: Dictionary in YutuEquipmentData.definitions():
		if str(entry.id) == source:
			source = str(entry.get("source_base", entry.base))
			break
	for entry: Dictionary in definitions():
		if str(entry.get("source_base", entry.base)) == source and (not book or bool(entry.book)):
			return str(entry.id) + ("zzs" if book else "")
	return item_id


static func expand_drop_entries(entries: Array, name_key: String = "name") -> Array:
	var result: Array = entries.duplicate()
	var existing: Dictionary = {}
	for entry: Dictionary in entries:
		existing[str(entry.get(name_key, ""))] = true
	for entry: Dictionary in entries:
		var source_id := str(entry.get(name_key, ""))
		var longnv_id := from_nezha(source_id)
		if longnv_id == source_id or existing.has(longnv_id):
			continue
		var extra: Dictionary = entry.duplicate(true)
		extra[name_key] = longnv_id
		result.append(extra)
		existing[longnv_id] = true
	return result


static func appearance(item_id: String, part: String) -> String:
	for entry: Dictionary in definitions():
		if entry.part == part and item_id in [str(entry.id), str(entry.name)]:
			return str(entry.appearance)
	return "gear_1"


static func stage_book_drops(stage: String) -> Array:
	var books := {
		"仙音岛": ["240007002zzs", "241007002zzs"],
		"仙幻岛": ["240007003zzs", "241007003zzs"],
		"仙树岛": ["240007004zzs", "241007004zzs"],
	}
	var result: Array = []
	for source in books.get(stage, []):
		result.append({"name": from_nezha(source), "value": 1, "chance": 0.1})
	return result

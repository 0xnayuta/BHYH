extends RefCounted
class_name YutuEquipmentData

const DEFINITIONS := "res://Art/hero_picture/role_7/equipment.json"
const PROPERTIES := [
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
		if bool(entry.book):
			var fallback := "240007001zzs" if entry.part == "武器" else "241007001zzs"
			var source: Dictionary = materials.get(
				str(entry.base) + "zzs", materials.get(fallback, {"xuantie": 900, "tanmu": 600, "sichou": 600})
			)
			materials[str(entry.id) + "zzs"] = source.duplicate(true)


static func from_nezha(item_id: String) -> String:
	var book := item_id.ends_with("zzs")
	var source := item_id.trim_suffix("zzs") if book else item_id
	for entry: Dictionary in definitions():
		if str(entry.get("source_base", entry.base)) == source and (not book or bool(entry.book)):
			return str(entry.id) + ("zzs" if book else "")
	return item_id


static func role_drop(item_id: String) -> String:
	return item_id


static func expand_drop_entries(entries: Array, name_key: String = "name") -> Array:
	var result: Array = entries.duplicate()
	var existing: Dictionary = {}
	for entry: Dictionary in entries:
		existing[str(entry.get(name_key, ""))] = true
	for entry: Dictionary in entries:
		var source_id := str(entry.get(name_key, ""))
		var yutu_id := from_nezha(source_id)
		if yutu_id == source_id or existing.has(yutu_id):
			continue
		var extra: Dictionary = entry.duplicate(true)
		extra[name_key] = yutu_id
		result.append(extra)
		existing[yutu_id] = true
	return result


static func appearance(item_id: String, part: String) -> String:
	for entry: Dictionary in definitions():
		if entry.part == part and item_id in [str(entry.id), str(entry.name)]:
			return str(entry.appearance)
	return "gear_1"


static func stage_book_drops(stage: String) -> Array:
	var books := {
		"仙音岛": ["240006102zzs", "241006002zzs"],
		"仙幻岛": ["240006103zzs", "241006003zzs"],
		"仙树岛": ["240006104zzs", "241006004zzs"],
	}
	var result: Array = []
	for item_id in books.get(stage, []):
		result.append({"name": item_id, "value": 1, "chance": 0.1})
	return result

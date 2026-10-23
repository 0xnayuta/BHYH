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


static func add_items(items: Dictionary) -> void:
	for entry: Dictionary in definitions():
		var base_item: Variant = items.get(str(entry.base))
		if not base_item is Dictionary:
			base_item = items.get("240007005" if str(entry.part) == "武器" else "241007005")
		if not base_item is Dictionary:
			continue
		var item: Dictionary = base_item.duplicate(true)
		if entry.has("end_base"):
			var end: Variant = items.get(str(entry.end_base))
			if end is Dictionary:
				var ratio := float(entry.get("ratio", 0.0))
				for key in PROPERTIES:
					item[key] = int(ceil(lerpf(float(item.get(key, 0)), float(end.get(key, 0)), ratio)))
				var strength: Dictionary = item.get("强化属性", {})
				var end_strength: Dictionary = end.get("强化属性", {})
				for key in end_strength:
					strength[key] = int(ceil(lerpf(float(strength.get(key, 0)), float(end_strength[key]), ratio)))
				item["强化属性"] = strength
		item["名字"] = str(entry.name)
		item["所属"] = "玉兔"
		item["图标"] = "res://Art/backpack/all_items/%s.png" % str(entry.id)
		item["描述"] = "玉兔的%s，%s。" % [str(entry.name), "双刃映月，寒芒破邪" if entry.part == "武器" else "月华凝裳，护身御敌"]
		items[str(entry.id)] = item
		if bool(entry.book):
			var book_source: Variant = items.get(str(entry.base) + "zzs")
			if not book_source is Dictionary:
				book_source = items.get("230007003zzs", {})
			var book: Dictionary = book_source.duplicate(true)
			book["名字"] = str(entry.name) + "制作书"
			book["品质"] = item["品质"]
			book["颜色"] = item["颜色"]
			book["图标"] = "res://Art/backpack/all_items/%szzs.png" % str(entry.id)
			book["描述"] = "在炼丹炉中消耗指定材料可以打造%s。" % str(entry.name)
			items[str(entry.id) + "zzs"] = book


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
	if item_id in ["zqfjnzzzs", "zqwqnzzzs", "ygfjnzzzs", "ygwqnzzzs"]:
		return item_id
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		var player_data_node = main_loop.root.get_node_or_null("PlayerData")
		if player_data_node != null and int(player_data_node.player_data.get("Myself", 1)) == 7:
			return from_nezha(item_id)
	return item_id


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

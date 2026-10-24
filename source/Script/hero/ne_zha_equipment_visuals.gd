extends RefCounted
class_name NeZhaEquipmentVisuals

const CATALOG_SCRIPT := preload("res://Art/hero_picture/role_6/equipment_atlas/ne_zha_equipment_catalog.gd")
const PARTS_DATA := preload("res://Script/hero/ne_zha_official_parts_data.gd")
const FRAME_ROOT := "res://Art/hero_picture/role_6/equipment_atlas"
const LEGACY_NAME_ALIASES := {
	"莲衣": "nzly",
	"火尖枪": "nzhjq",
	"zqfjnz": "341071501",
	"zqwqnz": "342071501",
	"ygfjnz": "341071601",
	"ygwqnz": "342071601",
	"仙域防具哪吒": "341071301",
	"仙域武器哪吒": "342071301",
	"仙域时装": "341071301",
	"仙域幻兵": "342071301",
}
static var _frames_cache: Dictionary = {}


static func clear_cached_frames() -> void:
	_frames_cache.clear()
	PARTS_DATA.clear_cache()


static func get_body_frames(equipment_id: String) -> SpriteFrames:
	return _get_frames(equipment_id, "body")


static func get_body_front_frames(equipment_id: String) -> SpriteFrames:
	return _get_frames(equipment_id, "body_front")


static func get_weapon_frames(equipment_id: String) -> SpriteFrames:
	return _get_frames(equipment_id, "weapon")


static func resolve_set(equipment_id: String, layer: String) -> String:
	var item := _get_item(equipment_id)
	var item_layer := "body" if layer == "body_front" else layer
	if item.is_empty() or str(item.get("layer", "")) != item_layer or not bool(item.get("available", false)):
		return "default"
	return str(item.get("set", "default"))


static func available_item_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id in CATALOG_SCRIPT.DATA["items"]:
		var item: Dictionary = CATALOG_SCRIPT.DATA["items"][item_id]
		if bool(item.get("available", false)):
			result.append(str(item_id))
	return result


static func _get_frames(equipment_id: String, layer: String) -> SpriteFrames:
	var set_name := resolve_set(equipment_id, layer)
	var frames_path := "%s/%s_%s/%s_%s.tres" % [FRAME_ROOT, set_name, layer, set_name, layer]
	if _frames_cache.has(frames_path):
		return _frames_cache[frames_path] as SpriteFrames
	var frames := ResourceLoader.load(frames_path, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE) as SpriteFrames
	if frames == null:
		return null
	_frames_cache[frames_path] = frames
	return frames


static func _get_item(equipment_id: String) -> Dictionary:
	var aliases: Dictionary = CATALOG_SCRIPT.DATA["aliases"]
	if aliases.has(equipment_id):
		var alias: Dictionary = aliases[equipment_id].duplicate(true)
		alias["available"] = CATALOG_SCRIPT.DATA["available_sets"].has(alias["set"])
		return alias
	var items: Dictionary = CATALOG_SCRIPT.DATA["items"]
	if items.has(equipment_id):
		return items[equipment_id]
	if LEGACY_NAME_ALIASES.has(equipment_id):
		var legacy_id: String = LEGACY_NAME_ALIASES[equipment_id]
		if items.has(legacy_id):
			return items[legacy_id]
		var legacy_alias: Dictionary = aliases[legacy_id].duplicate(true)
		legacy_alias["available"] = CATALOG_SCRIPT.DATA["available_sets"].has(legacy_alias["set"])
		return legacy_alias
	for item_id: String in items:
		var item: Dictionary = items[item_id]
		if str(item.get("name", "")) == equipment_id:
			return item
	return {}

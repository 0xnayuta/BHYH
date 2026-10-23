extends RefCounted
class_name NeZhaEquipmentVisuals

const CATALOG_SCRIPT := preload("res://Art/hero_picture/role_6/equipment_atlas/ne_zha_equipment_catalog.gd")
const PARTS_DATA := preload("res://Script/hero/ne_zha_official_parts_data.gd")
const ATLAS_ROOT := "res://Art/hero_picture/role_6/official_parts_trial"
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
	var layer_index := ["body", "weapon", "body_front"].find(layer)
	var directory := "%s/%s/" % [ATLAS_ROOT, set_name]
	var cache_key := directory + str(layer_index)
	if _frames_cache.has(cache_key):
		return _frames_cache[cache_key] as SpriteFrames
	var metadata: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(directory + "preview_%d.json" % layer_index)
	)
	if not metadata is Dictionary:
		return null
	var atlas := load(directory + "preview_%d.png" % layer_index) as Texture2D
	if atlas == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action: String in metadata:
		frames.add_animation(action)
		frames.set_animation_speed(action, 30.0)
		frames.set_animation_loop(action, action == "wait")
		for entry: Dictionary in metadata[action]:
			var texture := AtlasTexture.new()
			texture.atlas = atlas
			var region: Array = entry["region"]
			var margin: Array = entry["margin"]
			texture.region = Rect2(region[0], region[1], region[2], region[3])
			texture.margin = Rect2(margin[0], margin[1], margin[2], margin[3])
			frames.add_frame(action, texture)
	_frames_cache[cache_key] = frames
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

extends RefCounted

const TEXTURE_ALIASES := preload("res://Script/monster/duplicate_texture_aliases.gd")

const ROOT := "res://Art/hero_picture/role_6/official_parts_trial/"
const STRIDE := 9
const RECENT_BYTE_LIMIT := 64 * 1024 * 1024
const RECENT_SET_LIMIT := 16
static var _cache: Dictionary = {}
static var _recent: Dictionary = {}
var atlas: Texture2D
var poses := PackedFloat32Array()
var regions: Array[Rect2] = []
var animations: Dictionary = {}
var max_parts := 0
var atlas_size := Vector2i.ZERO
var set_name := ""


static func get_set(name: String, root: String = ROOT) -> RefCounted:
	var cache_key := root + name
	if _cache.has(cache_key):
		var cached: Variant = _cache[cache_key].get_ref()
		if cached != null:
			_retain_recent(cache_key, cached)
			return cached
	var directory := root + name + "/"
	if not FileAccess.file_exists(directory + "poses.json"):
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(directory + "poses.json"))
	if not parsed is Dictionary or int(parsed.get("version", 0)) != 2:
		return null
	var data := new()
	data.set_name = name
	data.poses = FileAccess.get_file_as_bytes(directory + "poses.bin").to_float32_array()
	data.atlas = load(TEXTURE_ALIASES.resolve(str(parsed.get("atlas", directory + "parts.png")))) as Texture2D
	if data.atlas == null or data.poses.is_empty() or data.poses.size() % STRIDE != 0:
		return null
	for region: Array in parsed["regions"]:
		data.regions.append(Rect2(region[0], region[1], region[2], region[3]))
	for action: Dictionary in parsed["animations"].values():
		if action["frames"].is_empty():
			return null
		for frame: Array in action["frames"]:
			if int(frame[0]) < 0 or int(frame[1]) < 0 or (int(frame[0]) + int(frame[1])) * STRIDE > data.poses.size():
				return null
	for index in range(0, data.poses.size(), STRIDE):
		if int(data.poses[index]) < 0 or int(data.poses[index]) >= data.regions.size():
			return null
		for component in range(1, STRIDE):
			if not is_finite(data.poses[index + component]):
				return null
	data.animations = parsed["animations"]
	data.max_parts = int(parsed["max_parts"])
	data.atlas_size = data.atlas.get_size()
	_cache[cache_key] = weakref(data)
	_retain_recent(cache_key, data)
	return data


static func _retain_recent(key: String, data: RefCounted) -> void:
	if _recent.has(key):
		_recent.erase(key)
		_recent[key] = data
		return
	_recent[key] = data
	while _recent.size() > RECENT_SET_LIMIT or _recent_bytes() > RECENT_BYTE_LIMIT:
		_recent.erase(_recent.keys()[0])


static func _recent_bytes() -> int:
	var bytes := 0
	var atlases: Dictionary = {}
	for data: RefCounted in _recent.values():
		bytes += data.poses.size() * 4
		var id: int = data.atlas.get_instance_id()
		if not atlases.has(id):
			atlases[id] = true
			bytes += data.atlas_size.x * data.atlas_size.y * 4
	return bytes


static func clear_cache() -> void:
	_cache.clear()
	_recent.clear()

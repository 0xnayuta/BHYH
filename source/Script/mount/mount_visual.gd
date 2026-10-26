class_name MountVisual
extends Node2D

signal animation_finished(animation_name: String)

const RUNTIME_ROOT := "res://Art/mount/runtime/mounts"
const EFFECT_RUNTIME_ROOT := "res://Art/mount/runtime/effects"
const PARTS_ROOT := "res://Art/mount/official_parts/"
const PARTS_DATA := preload("res://Script/hero/ne_zha_official_parts_data.gd")
const MOUNT_RIDER_LAYER := preload("res://Script/mount/mount_rider_layer.gd")
const RIDER_SLOT_ORIGINS := {
	"1002200": Vector2(-46.65, -51.15),
	"1002700": Vector2(-0.05, -0.1),
	"1003100": Vector2(-46.65, -51.15),
	"1003600": Vector2(-6.15, 30.2),
	"1004700": Vector2(-3.65, 33.8),
}
const STREAM_LOOKAHEAD_FRAMES := 45
const STREAM_READY_LIMIT := 2

static var _metadata_cache: Dictionary = {}
static var _bone_index_cache: Dictionary = {}
static var _stream_scope := ""
static var _stream_generation := 0
static var _stream_pending: Dictionary = {}
static var _stream_ready: Dictionary = {}
static var _stream_retained: Dictionary = {}
static var _stream_queue: Array[Dictionary] = []
static var _stream_last_used: Dictionary = {}
static var _stream_clock := 0

var mount_id := ""
var animation_name := ""
var frame_index := 0
var speed_scale := 1.0
var force_loop := false
var lightning_active := false

var _elapsed := 0.0
var _animation_data: Dictionary = {}
var _animation_cache: Dictionary = {}
var _bone_index: Dictionary = {}
var _combat_parts: Array[RefCounted] = []
var _combat_mount_ids: Array[String] = []
var _back_atlases: Array[Texture2D] = []
var _front_atlases: Array[Texture2D] = []
var _back_sprite: Sprite2D
var _front_sprite: Sprite2D
var _bone_back: Node2D
var _bone_front: Node2D
var _rider: Node2D
var _rider_pose: Node2D
var _rider_body: Sprite2D
var _rider_body_front: Sprite2D
var _rider_pose_source := ""
var _official_rider: Node2D
var _official_rider_data: RefCounted
var _official_weapon_data: RefCounted
var _registration_anchor := Vector2.ZERO
var _has_registration_anchor := false
var _runtime_root := RUNTIME_ROOT
var _atlas_base_path := ""
var _back_atlas_names: Array = []
var _front_atlas_names: Array = []
var async_texture_loading := false


func _ready() -> void:
	_ensure_sprites()


func setup(
	active_mount_id: String,
	initial_animation := "idle",
	runtime_root := RUNTIME_ROOT,
	use_async_texture_loading := false
) -> bool:
	_ensure_sprites()
	async_texture_loading = use_async_texture_loading
	_runtime_root = runtime_root
	mount_id = active_mount_id
	if not _combat_mount_ids.has(mount_id):
		_combat_parts.clear()
		_combat_mount_ids.clear()
	var index := _get_bone_index(mount_id)
	_bone_index = index.get("Effects" if runtime_root == EFFECT_RUNTIME_ROOT else "Mounts", {})
	animation_name = ""
	frame_index = 0
	_elapsed = 0.0
	_animation_data.clear()
	_animation_cache.clear()
	_back_atlases.clear()
	_front_atlases.clear()
	_back_atlas_names.clear()
	_front_atlas_names.clear()
	_atlas_base_path = ""
	_registration_anchor = Vector2.ZERO

	_has_registration_anchor = true
	_load_animation("idle")
	return play(initial_animation, true)


func set_async_texture_loading(enabled: bool) -> void:
	async_texture_loading = enabled


static func _get_bone_index(mount_id_value: String) -> Dictionary:
	if _bone_index_cache.has(mount_id_value):
		return _bone_index_cache[mount_id_value]
	var index_path := PARTS_ROOT + mount_id_value + "/index.json"
	if FileAccess.file_exists(index_path):
		var parsed_index: Variant = JSON.parse_string(FileAccess.get_file_as_string(index_path))
		if parsed_index is Dictionary:
			_bone_index_cache[mount_id_value] = parsed_index
			return parsed_index
	return {}


static func prewarm_mount_assets(active_mount_id: String) -> void:
	var scope := str(active_mount_id)
	if scope == "" or scope == _stream_scope:
		return
	_stream_scope = scope
	_stream_generation += 1
	_stream_pending.clear()
	_stream_ready.clear()
	_stream_retained.clear()
	_stream_queue.clear()
	_stream_last_used.clear()


func prewarm_combat_assets(related_mount_id: String = "") -> void:
	var mount_ids: Array[String] = [mount_id]
	if related_mount_id != "" and related_mount_id != mount_id:
		mount_ids.append(related_mount_id)
	var prepared: Array[RefCounted] = []
	for id: String in mount_ids:
		var folders: Dictionary = {}
		var index := _get_bone_index(id)
		for category: String in ["Mounts", "Effects"]:
			for entry: Variant in index.get(category, {}).values():
				if not (entry is Dictionary):
					continue
				var folder := str(entry.get("folder", ""))
				if folder == "" or folders.has(folder):
					continue
				folders[folder] = true
				var parts := PARTS_DATA.get_set(id + "/" + folder, PARTS_ROOT)
				if parts != null:
					prepared.append(parts)
	_combat_parts = prepared
	_combat_mount_ids = mount_ids


static func _queue_stream_path(path: String, retain: bool, priority: bool) -> void:
	if path == "" or _stream_pending.has(path) or _stream_ready.has(path):
		if retain:
			_stream_retained[path] = true
		return
	for entry_value in _stream_queue:
		if entry_value is Dictionary and str(entry_value.get("path", "")) == path:
			if retain:
				entry_value["retain"] = true
				_stream_retained[path] = true
			return
	var entry := {"path": path, "retain": retain, "generation": _stream_generation}
	if retain:
		_stream_retained[path] = true
	if priority:
		_stream_queue.push_front(entry)
	else:
		_stream_queue.append(entry)


static func _pump_stream_requests() -> void:
	_collect_stream_requests()

	var pending_limit := 2
	while _stream_pending.size() < pending_limit and not _stream_queue.is_empty():
		var entry: Dictionary = _stream_queue.pop_front()
		var path := str(entry.get("path", ""))
		if path == "" or not ResourceLoader.exists(path):
			continue
		var cache_mode := (
			ResourceLoader.CACHE_MODE_REUSE if bool(entry.get("retain", false)) else ResourceLoader.CACHE_MODE_IGNORE
		)
		var request_error := ResourceLoader.load_threaded_request(path, "Texture2D", false, cache_mode)
		var status := ResourceLoader.load_threaded_get_status(path)
		if request_error == OK or status != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_stream_pending[path] = entry


static func _collect_stream_requests() -> void:
	for path_value in _stream_pending.keys():
		var path := str(path_value)
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			continue
		var entry: Dictionary = _stream_pending[path]
		var texture: Texture2D = null
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			texture = ResourceLoader.load_threaded_get(path) as Texture2D
		_stream_pending.erase(path)
		if texture != null and int(entry.get("generation", -1)) == _stream_generation:
			_stream_ready[path] = texture
			_touch_stream_path(path)
	_prune_stream_ready()


static func _take_stream_texture(path: String) -> Texture2D:
	_pump_stream_requests()
	var texture := _stream_ready.get(path) as Texture2D
	if texture != null:
		_touch_stream_path(path)
	return texture


static func _touch_stream_path(path: String) -> void:
	_stream_clock += 1
	_stream_last_used[path] = _stream_clock


static func _prune_stream_ready() -> void:
	var removable: Array[String] = []
	for path_value in _stream_ready.keys():
		var path := str(path_value)
		if not _stream_retained.has(path):
			removable.append(path)
	while removable.size() > STREAM_READY_LIMIT:
		var oldest_path := removable[0]
		var oldest_tick := int(_stream_last_used.get(oldest_path, 0))
		for path in removable:
			var tick := int(_stream_last_used.get(path, 0))
			if tick < oldest_tick:
				oldest_path = path
				oldest_tick = tick
		_stream_ready.erase(oldest_path)
		_stream_last_used.erase(oldest_path)
		removable.erase(oldest_path)


static func _request_stream_texture(path: String) -> void:
	_queue_stream_path(path, false, true)
	_pump_stream_requests()


func has_animation(candidate: String) -> bool:
	if mount_id == "" or candidate == "":
		return false
	return _bone_index.has(candidate) or ResourceLoader.exists(_metadata_path(candidate))


func play(candidate: String, restart := false) -> bool:
	if candidate == "" or mount_id == "":
		return false
	if candidate == animation_name and not restart:
		return true
	var loaded: Dictionary = _load_animation(candidate)
	if loaded.is_empty():
		return false
	if not _has_registration_anchor:
		var fallback_bounds := _frame_bounds(loaded, 0)
		if fallback_bounds.size.x > 0.0 and fallback_bounds.size.y > 0.0:
			_registration_anchor = Vector2(
				fallback_bounds.position.x + fallback_bounds.size.x * 0.5,
				fallback_bounds.position.y + fallback_bounds.size.y
			)
			_has_registration_anchor = true
	animation_name = candidate
	_animation_data = loaded
	_back_atlases.clear()
	_front_atlases.clear()
	_atlas_base_path = str(loaded.get("_base_path", ""))
	_back_atlas_names = Array(loaded.get("back_atlases", [])).duplicate()
	_front_atlas_names = Array(loaded.get("front_atlases", [])).duplicate()
	_back_atlases.resize(_back_atlas_names.size())
	_front_atlases.resize(_front_atlas_names.size())
	frame_index = 0
	_elapsed = 0.0
	if async_texture_loading:
		_request_lookahead_atlases(0)
	_apply_frame()
	set_process(true)
	return true


func _process(delta: float) -> void:
	if _animation_data.is_empty():
		return
	var frames_value: Variant = _animation_data.get("frames", [])
	if not (frames_value is Array) or frames_value.is_empty():
		return
	var fps := maxf(1.0, float(_animation_data.get("fps", 30.0)))
	if async_texture_loading:
		_pump_stream_requests()
		_request_lookahead_atlases(frame_index)
	_elapsed += delta * maxf(speed_scale, 0.0)
	var next_frame := int(floor(_elapsed * fps))
	var frame_count := int(_animation_data.get("frame_count", frames_value.size()))
	if frame_count <= 0:
		set_process(false)
		return
	if next_frame < frame_count:
		if next_frame != frame_index:
			frame_index = next_frame
			_apply_frame()
		return
	if force_loop or bool(_animation_data.get("loop", false)):
		_elapsed = fmod(_elapsed, float(frame_count) / fps)
		frame_index = mini(int(floor(_elapsed * fps)), frame_count - 1)
		_apply_frame()
		return
	frame_index = frame_count - 1
	_apply_frame()
	set_process(false)
	animation_finished.emit(animation_name)


func _ensure_sprites() -> void:
	if _back_sprite != null:
		return
	_back_sprite = Sprite2D.new()
	_back_sprite.name = "Back"
	_back_sprite.centered = true
	_back_sprite.region_enabled = true
	_back_sprite.z_index = 0
	add_child(_back_sprite)
	_rider = Node2D.new()
	_rider.name = "Rider"
	_rider.z_index = 1
	_rider.visible = false
	add_child(_rider)
	_front_sprite = Sprite2D.new()
	_front_sprite.name = "Front"
	_front_sprite.centered = true
	_front_sprite.region_enabled = true
	_front_sprite.z_index = 2
	add_child(_front_sprite)
	_bone_back = MOUNT_RIDER_LAYER.new()
	_bone_back.name = "BoneBack"
	add_child(_bone_back)
	_bone_front = MOUNT_RIDER_LAYER.new()
	_bone_front.name = "BoneFront"
	_bone_front.z_index = 2
	add_child(_bone_front)


func set_official_rider(body: RefCounted, weapon: RefCounted) -> void:
	_ensure_sprites()
	if (
		body != null
		and body == _official_rider_data
		and weapon == _official_weapon_data
		and is_instance_valid(_official_rider)
	):
		_apply_rider_frame()
		return
	clear_rider_pose()
	_official_rider_data = body
	_official_weapon_data = weapon
	if body == null:
		return
	_official_rider = Node2D.new()
	_official_rider.name = "OfficialRider"
	_rider.add_child(_official_rider)
	for draw_layer in range(3):
		var layer: Node2D = MOUNT_RIDER_LAYER.new()
		layer.name = "Layer%d" % draw_layer
		_official_rider.add_child(layer)
		layer.call("show_pose", weapon if draw_layer == 1 else body, "ride", 0, draw_layer)
	_apply_rider_frame()


func set_rider_pose(
	pose_scene: PackedScene,
	pose_source: String,
	body_texture: Texture2D,
	body_front_texture: Texture2D,
	horizontal_frames: int,
	vertical_frames: int,
	pose_frame: int
) -> void:
	_ensure_sprites()
	_clear_official_rider()
	if pose_scene == null:
		clear_rider_pose()
		return
	if _rider_pose == null or _rider_pose_source != pose_source:
		_replace_rider_pose(pose_scene, pose_source)
	if _rider_body == null:
		clear_rider_pose()
		return
	if body_texture != null:
		_rider_body.texture = body_texture
	_rider_body.hframes = maxi(1, horizontal_frames)
	_rider_body.vframes = maxi(1, vertical_frames)
	var max_frame := maxi(0, horizontal_frames * vertical_frames - 1)
	_rider_body.frame = clampi(pose_frame, 0, max_frame)
	if _rider_body_front != null and body_front_texture != null:
		_rider_body_front.texture = body_front_texture
	_apply_rider_frame()


func clear_rider_pose() -> void:
	if _rider == null:
		return
	_rider.visible = false
	_clear_official_rider()
	if _rider_pose != null:
		_rider_pose.queue_free()
	_rider_pose = null
	_rider_body = null
	_rider_body_front = null
	_rider_pose_source = ""


func _clear_official_rider() -> void:
	if is_instance_valid(_official_rider):
		_official_rider.free()
	_official_rider = null
	_official_rider_data = null
	_official_weapon_data = null


func _replace_rider_pose(pose_scene: PackedScene, pose_source: String) -> void:
	if _rider_pose != null:
		_rider_pose.free()
	var adjustment := pose_scene.instantiate() as Node2D
	if adjustment == null:
		return
	var pose := adjustment.get_node_or_null("Pose") as Node2D
	if pose == null:
		adjustment.free()
		return
	adjustment.remove_child(pose)
	adjustment.free()
	pose.name = "Pose"
	_rider.add_child(pose)
	_rider_pose = pose
	_rider_body = pose.get_node_or_null("Body") as Sprite2D
	_rider_body_front = pose.get_node_or_null("BodyFront") as Sprite2D
	_rider_pose_source = pose_source


func _load_animation(candidate: String) -> Dictionary:
	if _animation_cache.has(candidate):
		return _animation_cache[candidate]
	if _bone_index.has(candidate):
		var entry: Dictionary = _bone_index[candidate]
		var parts: RefCounted = PARTS_DATA.get_set(mount_id + "/" + str(entry.get("folder", "")), PARTS_ROOT)
		var part_action := str(entry.get("animation", ""))
		if parts != null and parts.animations.has(part_action):
			var animation: Dictionary = parts.animations[part_action]
			var bone_data := {
				"_parts": parts,
				"_part_action": part_action,
				"frames": animation.get("frame_info", animation.get("frames", [])),
				"fps": 30.0,
				"loop": bool(animation.get("loop", false)),
			}
			_animation_cache[candidate] = bone_data
			return bone_data
	var metadata_path := _metadata_path(candidate)
	if not ResourceLoader.exists(metadata_path):
		return {}
	var data: Dictionary = _metadata_cache.get(metadata_path, {})
	if data.is_empty():
		# 失败细节由 AtlasMetadataStore 统一记录，此处不再重复报错。
		data = AtlasMetadataStore.data_for(metadata_path).duplicate(true)
		if data.is_empty():
			return {}
		data["_base_path"] = metadata_path.get_base_dir()
		_metadata_cache[metadata_path] = data
	_animation_cache[candidate] = data
	return data


func _apply_frame() -> void:
	var frames_value: Variant = _animation_data.get("frames", [])
	if not (frames_value is Array) or frames_value.is_empty():
		_back_sprite.visible = false
		_front_sprite.visible = false
		return
	var frames: Array = frames_value
	var safe_index := clampi(frame_index, 0, frames.size() - 1)
	var frame_value: Variant = frames[safe_index]
	if not (frame_value is Dictionary):
		return
	var frame: Dictionary = frame_value
	if _animation_data.has("_parts"):
		_back_sprite.visible = false
		_front_sprite.visible = false
		var parts: RefCounted = _animation_data.get("_parts")
		var part_action := str(_animation_data.get("_part_action", ""))
		var visible_flags := 8 if lightning_active else 0
		_bone_back.call("show_pose", parts, part_action, safe_index, 0, visible_flags)
		_bone_front.call("show_pose", parts, part_action, safe_index, 1, visible_flags)
		_apply_rider_frame(frame.get("ride", null))
		return
	_bone_back.call("hide_parts")
	_bone_front.call("hide_parts")
	_apply_layer(_back_sprite, frame.get("back", null), _back_atlas_names, _back_atlases)
	_apply_layer(_front_sprite, frame.get("front", null), _front_atlas_names, _front_atlases)
	_apply_rider_frame(frame.get("ride", null))


func _apply_official_rider_frame() -> void:
	var attachment: Variant = null
	if not _animation_data.is_empty():
		var frames_value: Variant = _animation_data.get("frames", [])
		if frames_value is Array and not frames_value.is_empty():
			var frame_value: Variant = frames_value[clampi(frame_index, 0, frames_value.size() - 1)]
			if frame_value is Dictionary:
				attachment = (frame_value as Dictionary).get("official_ride", null)
	_rider.visible = attachment is Dictionary
	if not (attachment is Dictionary):
		return
	var attachment_data: Dictionary = attachment
	_rider.transform = Transform2D(
		Vector2(float(attachment_data.get("a", 1.0)), float(attachment_data.get("b", 0.0))),
		Vector2(float(attachment_data.get("c", 0.0)), float(attachment_data.get("d", 1.0))),
		Vector2(float(attachment_data.get("tx", 0.0)), float(attachment_data.get("ty", 0.0)))
	)


func _apply_rider_frame(ride_value: Variant = null) -> void:
	if is_instance_valid(_official_rider):
		_apply_official_rider_frame()
		return
	if _rider == null or _rider_body == null or _rider_body.texture == null:
		if _rider != null:
			_rider.visible = false
		return
	if ride_value == null and not _animation_data.is_empty():
		var frames_value: Variant = _animation_data.get("frames", [])
		if frames_value is Array and not frames_value.is_empty():
			var frame_value: Variant = frames_value[clampi(frame_index, 0, frames_value.size() - 1)]
			if frame_value is Dictionary:
				ride_value = frame_value.get("ride", null)
	if not (ride_value is Dictionary):
		_rider.visible = false
		return
	var ride: Dictionary = ride_value
	var rider_transform := Transform2D(
		Vector2(float(ride.get("a", 1.0)), float(ride.get("b", 0.0))),
		Vector2(float(ride.get("c", 0.0)), float(ride.get("d", 1.0))),
		Vector2(float(ride.get("tx", 0.0)), float(ride.get("ty", 0.0)))
	)
	var origin_value: Variant = ride.get("origin", null)
	if origin_value is Dictionary:
		var origin: Dictionary = origin_value
		rider_transform *= Transform2D(
			Vector2(float(origin.get("a", 1.0)), float(origin.get("b", 0.0))),
			Vector2(float(origin.get("c", 0.0)), float(origin.get("d", 1.0))),
			Vector2(float(origin.get("tx", 0.0)), float(origin.get("ty", 0.0)))
		)
	else:
		var slot_origin: Vector2 = RIDER_SLOT_ORIGINS.get(mount_id, Vector2.ZERO)
		rider_transform *= Transform2D(0.0, slot_origin)
	_rider.transform = rider_transform
	_rider.visible = true


func _request_lookahead_atlases(current_frame: int) -> void:
	if _animation_data.has("_parts"):
		return
	var frames_value: Variant = _animation_data.get("frames", [])
	if not (frames_value is Array) or frames_value.is_empty():
		return
	var frames: Array = frames_value
	var safe_frame := clampi(current_frame, 0, frames.size() - 1)
	_request_layer_lookahead(frames, safe_frame, "back", _back_atlas_names, _back_atlases)
	_request_layer_lookahead(frames, safe_frame, "front", _front_atlas_names, _front_atlases)


func _request_layer_lookahead(
	frames: Array, safe_frame: int, layer_name: String, atlas_names: Array, atlases: Array[Texture2D]
) -> void:
	var current_entry: Variant = (frames[safe_frame] as Dictionary).get(layer_name, null)
	var current_page := int(current_entry.get("page", -1)) if current_entry is Dictionary else -1
	for index in range(safe_frame, mini(frames.size(), safe_frame + STREAM_LOOKAHEAD_FRAMES + 1)):
		var entry_value: Variant = (frames[index] as Dictionary).get(layer_name, null)
		if not (entry_value is Dictionary):
			continue
		var page := int(entry_value.get("page", -1))
		if page < 0 or page >= atlas_names.size() or (index > safe_frame and page == current_page):
			continue
		if page < atlases.size() and atlases[page] != null:
			if page != current_page:
				break
			continue
		_request_stream_texture(_atlas_base_path.path_join(str(atlas_names[page])))
		if page != current_page:
			break


func get_registration_anchor() -> Vector2:
	return _registration_anchor


func get_current_visual_bounds() -> Rect2:
	if _animation_data.is_empty():
		return Rect2()
	var bounds := _frame_bounds(_animation_data, frame_index)
	if bounds.size.x > 0.0 and bounds.size.y > 0.0:
		bounds.position -= _registration_anchor
	return bounds


func get_animation_visual_bounds() -> Rect2:
	if _animation_data.is_empty():
		return Rect2()
	var frames_value: Variant = _animation_data.get("frames", [])
	if not (frames_value is Array) or frames_value.is_empty():
		return Rect2()
	var result := Rect2()
	var has_bounds := false
	for index in range(frames_value.size()):
		var frame_bounds := _frame_bounds(_animation_data, index)
		if frame_bounds.size.x <= 0.0 or frame_bounds.size.y <= 0.0:
			continue
		result = frame_bounds if not has_bounds else result.merge(frame_bounds)
		has_bounds = true
	if has_bounds:
		result.position -= _registration_anchor
	return result if has_bounds else Rect2()


func _apply_layer(sprite: Sprite2D, entry_value: Variant, atlas_names: Array, atlases: Array[Texture2D]) -> void:
	if not (entry_value is Dictionary):
		sprite.visible = false
		return
	var entry: Dictionary = entry_value
	var page := int(entry.get("page", -1))
	var region_value: Variant = entry.get("region", [])
	var offset_value: Variant = entry.get("offset", [])
	if (
		page < 0
		or page >= atlas_names.size()
		or not (region_value is Array)
		or region_value.size() < 4
		or not (offset_value is Array)
		or offset_value.size() < 2
	):
		sprite.visible = false
		return
	if page >= atlases.size():
		atlases.resize(atlas_names.size())
	if atlases[page] == null:
		var atlas_path := _atlas_base_path.path_join(str(atlas_names[page]))
		atlases[page] = _take_stream_texture(atlas_path)
		if atlases[page] == null and async_texture_loading:
			_request_stream_texture(atlas_path)
			return
		if atlases[page] == null:
			atlases[page] = load(atlas_path) as Texture2D
		if atlases[page] == null:
			push_error("坐骑动画图集无法加载: %s" % atlas_path)
			sprite.visible = false
			return

	for index in range(atlases.size()):
		if index != page:
			atlases[index] = null
	var region := Rect2(float(region_value[0]), float(region_value[1]), float(region_value[2]), float(region_value[3]))
	sprite.texture = atlases[page]
	sprite.region_rect = region
	sprite.position = Vector2(float(offset_value[0]), float(offset_value[1])) + region.size * 0.5 - _registration_anchor
	sprite.visible = sprite.texture != null


func _frame_bounds(data: Dictionary, requested_frame: int) -> Rect2:
	var frames_value: Variant = data.get("frames", [])
	if not (frames_value is Array) or frames_value.is_empty():
		return Rect2()
	var frames: Array = frames_value
	var safe_index := clampi(requested_frame, 0, frames.size() - 1)
	var frame_value: Variant = frames[safe_index]
	if not (frame_value is Dictionary):
		return Rect2()
	var frame: Dictionary = frame_value
	var result := Rect2()
	var has_bounds := false
	for layer_name in ["back", "front"]:
		var entry_value: Variant = frame.get(layer_name, null)
		if not (entry_value is Dictionary):
			continue
		var entry: Dictionary = entry_value
		var region_value: Variant = entry.get("region", [])
		var offset_value: Variant = entry.get("offset", [])
		if (
			not (region_value is Array)
			or region_value.size() < 4
			or not (offset_value is Array)
			or offset_value.size() < 2
		):
			continue
		var layer_bounds := Rect2(
			float(offset_value[0]), float(offset_value[1]), float(region_value[2]), float(region_value[3])
		)
		result = layer_bounds if not has_bounds else result.merge(layer_bounds)
		has_bounds = true
	return result if has_bounds else Rect2()


func _metadata_path(candidate: String) -> String:
	return "%s/%s/%s/metadata.tres" % [_runtime_root, mount_id, candidate]

class_name AtlasMetadataView
extends RefCounted

## AtlasMetadata 的只读运行时视图。
## 源数据仍由 AtlasMetadata.data 序列化保存；本类只提供经过校验的值查询，
## 不复制整份帧数据，也不向调用方暴露可写字典。

enum SchemaKind { SEQUENCES, ANIMATION }

var _data: Dictionary = {}
var _sequences: Dictionary = {}
var _geometry: Dictionary = {}
var _masks: Dictionary = {}
var _animation: Dictionary = {}
var _animation_frames: Array = []
var _animation_back_atlases: Array = []
var _animation_front_atlases: Array = []
var _errors: Array[String] = []
var _valid := false
var _kind := SchemaKind.SEQUENCES
var source_path := ""


func _init(metadata: AtlasMetadata, path: String = "") -> void:
	source_path = path
	if metadata == null:
		_errors.append("metadata is null")
		return
	_data = metadata.data
	_validate()


func is_valid() -> bool:
	return _valid


func is_animation() -> bool:
	return _kind == SchemaKind.ANIMATION


func error_message() -> String:
	return "; ".join(_errors)


func has_sequence(animation: StringName) -> bool:
	return _sequences.has(String(animation))


func sequence_frame_count(animation: StringName) -> int:
	var sequence: Variant = _sequences.get(String(animation), null)
	if not sequence is Dictionary:
		return 0
	var frames: Variant = (sequence as Dictionary).get("frames", null)
	return (frames as Array).size() if frames is Array else 0


func frame_size(animation: StringName, frame_index: int) -> Vector2:
	var frame := _frame_entry(animation, frame_index)
	if frame.size() < 6:
		return Vector2.ZERO
	return Vector2(float(frame[4]), float(frame[5]))


func frame_margin(animation: StringName, frame_index: int) -> Rect2:
	var frame := _frame_entry(animation, frame_index)
	if frame.size() < 10:
		return Rect2()
	return Rect2(float(frame[6]), float(frame[7]), float(frame[8]), float(frame[9]))


func frame_center(animation: StringName, frame_index: int) -> Vector2:
	var frame := _frame_entry(animation, frame_index)
	if frame.size() < 10:
		return Vector2.ZERO
	var used_size := Vector2(float(frame[4]), float(frame[5]))
	var original_size := used_size + Vector2(float(frame[8]), float(frame[9]))
	return Vector2(float(frame[6]), float(frame[7])) + used_size * 0.5 - original_size * 0.5


func frame_reg_anchor(animation: StringName, frame_index: int) -> Vector2:
	var frame := _frame_entry(animation, frame_index)
	if frame.size() < 10:
		return Vector2.ZERO
	var used_size := Vector2(float(frame[4]), float(frame[5]))
	var margin := Rect2(float(frame[6]), float(frame[7]), float(frame[8]), float(frame[9]))
	var canvas_size := used_size + margin.size
	return Vector2(
		margin.position.x + used_size.x * 0.5 - canvas_size.x * 0.5,
		margin.position.y + used_size.y - canvas_size.y * 0.5
	)


func has_geometry(animation: StringName) -> bool:
	var entry: Variant = _geometry.get(String(animation), null)
	return entry is Dictionary and _valid_geometry_entry(entry as Dictionary)


func geometry_center(animation: StringName) -> Vector2:
	var entry: Variant = _geometry.get(String(animation), null)
	if not entry is Dictionary:
		return Vector2.ZERO
	var center_value: Variant = (entry as Dictionary).get("center", null)
	if not center_value is Array:
		return Vector2.ZERO
	var center: Array = center_value as Array
	return Vector2(float(center[0]), float(center[1])) if center.size() >= 2 else Vector2.ZERO


func has_mask_sequence(animation: StringName) -> bool:
	return _masks.has(String(animation))


func mask_frame_count(animation: StringName) -> int:
	var frames_value: Variant = _masks.get(String(animation), null)
	return (frames_value as Array).size() if frames_value is Array else 0


func mask_frame_is_empty(animation: StringName, frame_index: int) -> bool:
	var frames_value: Variant = _masks.get(String(animation), null)
	if not frames_value is Array:
		return true
	var frames: Array = frames_value as Array
	if frame_index < 0 or frame_index >= frames.size():
		return true
	var mask: Variant = frames[frame_index]
	return not mask is Array or (mask as Array).is_empty()


func mask_frame_rect(animation: StringName, frame_index: int) -> Rect2:
	var frames_value: Variant = _masks.get(String(animation), null)
	if not frames_value is Array:
		return Rect2()
	var frames: Array = frames_value as Array
	if frame_index < 0 or frame_index >= frames.size():
		return Rect2()
	var mask: Variant = frames[frame_index]
	if not mask is Array:
		return Rect2()
	var values: Array = mask as Array
	if values.size() < 4:
		return Rect2()
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


func animation_fps() -> float:
	return maxf(0.0, float(_animation.get("fps", 30.0)))


func animation_loop() -> bool:
	return bool(_animation.get("loop", false))


func animation_frame_count() -> int:
	return int(_animation.get("frame_count", _animation_frames.size()))


func animation_back_atlas_names() -> Array:
	return _animation_back_atlases.duplicate()


func animation_front_atlas_names() -> Array:
	return _animation_front_atlases.duplicate()


func animation_layer_has(frame_index: int, layer: StringName) -> bool:
	return not _layer_entry(frame_index, layer).is_empty()


func animation_layer_page(frame_index: int, layer: StringName) -> int:
	var entry := _layer_entry(frame_index, layer)
	return int(entry.get("page", -1)) if not entry.is_empty() else -1


func animation_layer_region(frame_index: int, layer: StringName) -> Rect2:
	var entry := _layer_entry(frame_index, layer)
	if entry.is_empty():
		return Rect2()
	var region_value: Variant = entry.get("region", null)
	if not region_value is Array:
		return Rect2()
	var region: Array = region_value as Array
	return (
		Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])) if region.size() >= 4 else Rect2()
	)


func animation_layer_offset(frame_index: int, layer: StringName) -> Vector2:
	var entry := _layer_entry(frame_index, layer)
	if entry.is_empty():
		return Vector2.ZERO
	var offset_value: Variant = entry.get("offset", null)
	if not offset_value is Array:
		return Vector2.ZERO
	var offset: Array = offset_value as Array
	return Vector2(float(offset[0]), float(offset[1])) if offset.size() >= 2 else Vector2.ZERO


func animation_frame_bounds(frame_index: int) -> Rect2:
	var result := Rect2()
	var has_bounds := false
	for layer in [&"back", &"front"]:
		if not animation_layer_has(frame_index, layer):
			continue
		var region := animation_layer_region(frame_index, layer)
		var offset := animation_layer_offset(frame_index, layer)
		var layer_bounds := Rect2(offset, region.size)
		result = layer_bounds if not has_bounds else result.merge(layer_bounds)
		has_bounds = true
	return result if has_bounds else Rect2()


func animation_has_ride(frame_index: int) -> bool:
	var frame := _animation_frame(frame_index)
	return not frame.is_empty() and frame.get("ride", null) is Dictionary


func animation_ride_transform(frame_index: int) -> Transform2D:
	var frame := _animation_frame(frame_index)
	if frame.is_empty():
		return _identity_transform()
	return _transform_from_entry(frame.get("ride", null))


func animation_ride_has_origin(frame_index: int) -> bool:
	var ride := _ride_entry(frame_index)
	return not ride.is_empty() and ride.get("origin", null) is Dictionary


func animation_ride_origin_transform(frame_index: int) -> Transform2D:
	var ride := _ride_entry(frame_index)
	if ride.is_empty():
		return _identity_transform()
	return _transform_from_entry(ride.get("origin", null))


func animation_has_official_ride(frame_index: int) -> bool:
	var frame := _animation_frame(frame_index)
	return not frame.is_empty() and frame.get("official_ride", null) is Dictionary


func animation_official_ride_transform(frame_index: int) -> Transform2D:
	var frame := _animation_frame(frame_index)
	if frame.is_empty():
		return _identity_transform()
	return _transform_from_entry(frame.get("official_ride", null))


func _frame_entry(animation: StringName, frame_index: int) -> Array:
	var sequence: Variant = _sequences.get(String(animation), null)
	if not sequence is Dictionary:
		return []
	var frames_value: Variant = (sequence as Dictionary).get("frames", null)
	if not frames_value is Array:
		return []
	var frames: Array = frames_value as Array
	if frame_index < 0 or frame_index >= frames.size():
		return []
	var frame: Variant = frames[frame_index]
	return frame as Array if frame is Array else []


func _animation_frame(frame_index: int) -> Dictionary:
	if frame_index < 0 or frame_index >= _animation_frames.size():
		return {}
	var frame: Variant = _animation_frames[frame_index]
	return frame as Dictionary if frame is Dictionary else {}


func _layer_entry(frame_index: int, layer: StringName) -> Dictionary:
	var frame := _animation_frame(frame_index)
	if frame.is_empty():
		return {}
	var entry: Variant = frame.get(String(layer), null)
	return entry as Dictionary if entry is Dictionary else {}


func _ride_entry(frame_index: int) -> Dictionary:
	var frame := _animation_frame(frame_index)
	var entry: Variant = frame.get("ride", null) if not frame.is_empty() else null
	return entry as Dictionary if entry is Dictionary else {}


func _transform_from_entry(value: Variant) -> Transform2D:
	if not value is Dictionary:
		return _identity_transform()
	var entry: Dictionary = value as Dictionary
	return Transform2D(
		Vector2(float(entry.get("a", 1.0)), float(entry.get("b", 0.0))),
		Vector2(float(entry.get("c", 0.0)), float(entry.get("d", 1.0))),
		Vector2(float(entry.get("tx", 0.0)), float(entry.get("ty", 0.0)))
	)


static func _identity_transform() -> Transform2D:
	return Transform2D(Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2.ZERO)


func _validate() -> void:
	if _data.has("animation") and _data.has("frames"):
		_kind = SchemaKind.ANIMATION
		_validate_animation()
		return
	if _data.has("pages") and _data.has("sequences"):
		_kind = SchemaKind.SEQUENCES
		_validate_sequences()
		return
	_errors.append("runtime view requires pages+sequences or animation+frames")


func _validate_sequences() -> void:
	var pages_value: Variant = _data.get("pages", null)
	if not pages_value is Array or (pages_value as Array).is_empty():
		_errors.append("pages must be a non-empty Array")
		return
	var pages: Array = pages_value as Array
	for index in range(pages.size()):
		if not _valid_page(pages[index]):
			_errors.append("invalid pages[%d]" % index)
			return
	var sequences_value: Variant = _data.get("sequences", null)
	if not sequences_value is Dictionary or (sequences_value as Dictionary).is_empty():
		_errors.append("sequences must be a non-empty Dictionary")
		return
	_sequences = sequences_value as Dictionary
	for key: Variant in _sequences:
		var sequence_name := str(key)
		if sequence_name.is_empty():
			_errors.append("sequence name must be non-empty")
			return
		if not _valid_sequence(_sequences[key], pages.size()):
			_errors.append("invalid sequence: " + sequence_name)
			return
	var geometry_value: Variant = _data.get("geometry", null)
	if geometry_value != null:
		if not geometry_value is Dictionary:
			_errors.append("geometry must be a Dictionary")
			return
		_geometry = geometry_value as Dictionary
		for key: Variant in _geometry:
			if not _valid_geometry_entry(_geometry[key]):
				_errors.append("invalid geometry: " + str(key))
				return
	var masks_value: Variant = _data.get("masks", null)
	if masks_value != null:
		if not masks_value is Dictionary:
			_errors.append("masks must be a Dictionary")
			return
		_masks = masks_value as Dictionary
		for key: Variant in _masks:
			if not _valid_masks(_masks[key], str(key)):
				return
	_valid = true


func _validate_animation() -> void:
	var animation_value: Variant = _data.get("animation", null)
	if not animation_value is String or (animation_value as String).is_empty():
		_errors.append("animation must be a non-empty String")
		return
	var fps_value: Variant = _data.get("fps", null)
	if not _is_number(fps_value) or float(fps_value) <= 0.0:
		_errors.append("fps must be a positive number")
		return
	if typeof(_data.get("loop", null)) != TYPE_BOOL:
		_errors.append("loop must be a bool")
		return
	var frames_value: Variant = _data.get("frames", null)
	if not frames_value is Array or (frames_value as Array).is_empty():
		_errors.append("frames must be a non-empty Array")
		return
	_animation = _data
	_animation_frames = frames_value as Array
	var frame_count_value: Variant = _data.get("frame_count", null)
	if (
		typeof(frame_count_value) != TYPE_INT
		or int(frame_count_value) <= 0
		or int(frame_count_value) != _animation_frames.size()
	):
		_errors.append("frame_count must equal the frames length")
		return
	if not _validate_atlas_names(_data.get("back_atlases", null), "back_atlases", true):
		return
	if not _validate_atlas_names(_data.get("front_atlases", null), "front_atlases", true):
		return
	_animation_back_atlases = _data.get("back_atlases") as Array
	_animation_front_atlases = _data.get("front_atlases") as Array
	for frame_index in range(_animation_frames.size()):
		if not _valid_animation_frame(_animation_frames[frame_index], frame_index):
			return
	_valid = true


func _validate_atlas_names(value: Variant, label: String, required: bool) -> bool:
	if value == null and not required:
		return true
	if not value is Array:
		_errors.append(label + " must be an Array")
		return false
	for item: Variant in value as Array:
		if not item is String or (item as String).is_empty():
			_errors.append(label + " must contain non-empty Strings")
			return false
	return true


func _valid_animation_frame(value: Variant, frame_index: int) -> bool:
	if not value is Dictionary:
		_errors.append("invalid animation frame: %d" % frame_index)
		return false
	var frame: Dictionary = value as Dictionary
	for layer in ["back", "front"]:
		var layer_value: Variant = frame.get(layer, null)
		if layer_value == null:
			continue
		if not _valid_layer(layer_value, layer, frame_index):
			return false
	for transform_key in ["ride", "official_ride"]:
		var transform_value: Variant = frame.get(transform_key, null)
		if transform_value == null:
			continue
		if not _valid_optional_transform(transform_value):
			_errors.append("invalid %s: %d" % [transform_key, frame_index])
			return false
	return true


func _valid_layer(value: Variant, layer: String, frame_index: int) -> bool:
	if not value is Dictionary:
		_errors.append("invalid %s layer: %d" % [layer, frame_index])
		return false
	var entry: Dictionary = value as Dictionary
	var names: Array = _animation_back_atlases if layer == "back" else _animation_front_atlases
	var page_value: Variant = entry.get("page", null)
	if typeof(page_value) != TYPE_INT or int(page_value) < 0 or int(page_value) >= names.size():
		_errors.append("invalid %s page: %d" % [layer, frame_index])
		return false
	return _valid_rect(entry.get("region", null)) and _valid_vec2(entry.get("offset", null))


func _valid_optional_transform(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var entry: Dictionary = value as Dictionary
	for key in ["a", "b", "c", "d", "tx", "ty"]:
		if entry.has(key) and not _is_number(entry[key]):
			return false
	var origin: Variant = entry.get("origin", null)
	return origin == null or (origin is Dictionary and _valid_optional_transform(origin))


func _valid_page(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var path_value: Variant = (value as Dictionary).get("path", null)
	return path_value is String and not (path_value as String).is_empty()


func _valid_sequence(value: Variant, page_count: int) -> bool:
	if not value is Dictionary:
		return false
	var frames_value: Variant = (value as Dictionary).get("frames", null)
	if not frames_value is Array or (frames_value as Array).is_empty():
		return false
	var frames: Array = frames_value as Array
	for frame: Variant in frames:
		if not frame is Array:
			return false
		var entry: Array = frame as Array
		if entry.size() < 10:
			return false
		for index in range(10):
			if not _is_number(entry[index]):
				return false
		var page_index := int(entry[1])
		if float(entry[1]) != float(page_index) or page_index < 0 or page_index >= page_count:
			return false
	return true


func _valid_geometry_entry(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	for field in ["center", "size", "origin"]:
		var field_value: Variant = (value as Dictionary).get(field, null)
		if not field_value is Array:
			return false
		var values: Array = field_value as Array
		if values.size() < 2 or not _is_number(values[0]) or not _is_number(values[1]):
			return false
	return true


func _valid_masks(value: Variant, sequence_name: String) -> bool:
	if not value is Array:
		_errors.append("masks must be an Array: " + sequence_name)
		return false
	var frames: Array = value as Array
	for frame_index in range(frames.size()):
		var mask: Variant = frames[frame_index]
		if not mask is Array:
			_errors.append("invalid mask: %s[%d]" % [sequence_name, frame_index])
			return false
		var values: Array = mask as Array
		if values.is_empty():
			continue
		if values.size() < 4:
			_errors.append("invalid mask size: %s[%d]" % [sequence_name, frame_index])
			return false
		for index in range(4):
			if not _is_number(values[index]):
				_errors.append("invalid mask value: %s[%d]" % [sequence_name, frame_index])
				return false
	return true


func _valid_rect(value: Variant) -> bool:
	return (
		value is Array
		and (value as Array).size() >= 4
		and _is_number((value as Array)[0])
		and _is_number((value as Array)[1])
		and _is_number((value as Array)[2])
		and _is_number((value as Array)[3])
	)


func _valid_vec2(value: Variant) -> bool:
	return (
		value is Array
		and (value as Array).size() >= 2
		and _is_number((value as Array)[0])
		and _is_number((value as Array)[1])
	)


static func _is_number(value: Variant) -> bool:
	var value_type := typeof(value)
	return value_type == TYPE_INT or value_type == TYPE_FLOAT

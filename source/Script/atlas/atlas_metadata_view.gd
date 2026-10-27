class_name AtlasMetadataView
extends RefCounted

## AtlasMetadata 的只读运行时视图。
## 源数据仍由 AtlasMetadata.data 序列化保存；本类只提供经过校验的值查询，
## 不复制整份帧数据，也不向调用方暴露可写字典。

var _data: Dictionary = {}
var _sequences: Dictionary = {}
var _geometry: Dictionary = {}
var _masks: Dictionary = {}
var _errors: Array[String] = []
var _valid := false


func _init(metadata: AtlasMetadata) -> void:
	if metadata == null:
		_errors.append("metadata is null")
		return
	_data = metadata.data
	_validate()


func is_valid() -> bool:
	return _valid


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


func _validate() -> void:
	if not _data.has("pages") or not _data.has("sequences"):
		_errors.append("runtime view requires pages + sequences")
		return
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


static func _is_number(value: Variant) -> bool:
	var value_type := typeof(value)
	return value_type == TYPE_INT or value_type == TYPE_FLOAT

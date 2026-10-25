class_name FrameSequence
extends Resource

## 构建期生成的共享只读数据；播放器状态不得回写此资源。
@export var frame_paths: PackedStringArray = PackedStringArray()
@export var frame_regions: Array[Rect2] = []
@export var frame_margins: Array[Rect2] = []
@export var frame_has_visual: Array[bool] = []
@export var fps: float = 24.0
@export var loop: bool = false
@export var hold_last_frame: bool = false
@export var prefetch_frames: int = 2


func count() -> int:
	return frame_paths.size()


func validate() -> Array[String]:
	var errors: Array[String] = []
	if frame_paths.is_empty():
		errors.append("frame_paths must not be empty")
	for path in frame_paths:
		if not path.begins_with("res://") or path.contains("..") or path.contains("\\"):
			errors.append("invalid frame path: " + path)
	if not frame_regions.is_empty() and frame_regions.size() != frame_paths.size():
		errors.append("frame_regions must be empty or match frame_paths")
	if not frame_margins.is_empty() and frame_margins.size() != frame_paths.size():
		errors.append("frame_margins must be empty or match frame_paths")
	if not frame_margins.is_empty() and frame_regions.is_empty():
		errors.append("frame_margins requires frame_regions")
	if not frame_has_visual.is_empty() and frame_has_visual.size() != frame_paths.size():
		errors.append("frame_has_visual must be empty or match frame_paths")
	for region in frame_regions:
		if (
			not region.position.is_finite()
			or not region.size.is_finite()
			or region.position.x < 0.0
			or region.position.y < 0.0
		):
			errors.append("frame region must be finite and non-negative")
		if region.size.x <= 0.0 or region.size.y <= 0.0:
			errors.append("frame region size must be positive")
	for margin in frame_margins:
		if not margin.position.is_finite() or not margin.size.is_finite() or margin.size.x < 0.0 or margin.size.y < 0.0:
			errors.append("frame margin must be finite with non-negative size")
	if not is_finite(fps) or fps <= 0.0:
		errors.append("fps must be finite and positive")
	if prefetch_frames < 0:
		errors.append("prefetch_frames must be non-negative")
	return errors

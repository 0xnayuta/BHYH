class_name FrameSequence
extends Resource

## 超大帧序列的只读资源；由构建期转换器生成，运行时不得回写。
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
	if not frame_regions.is_empty() and frame_regions.size() != frame_paths.size():
		errors.append("frame_regions must be empty or match frame_paths")
	if not frame_margins.is_empty() and frame_margins.size() != frame_paths.size():
		errors.append("frame_margins must be empty or match frame_paths")
	if not frame_has_visual.is_empty() and frame_has_visual.size() != frame_paths.size():
		errors.append("frame_has_visual must be empty or match frame_paths")
	if fps <= 0.0:
		errors.append("fps must be positive")
	if prefetch_frames < 0:
		errors.append("prefetch_frames must be non-negative")
	return errors

@tool
extends Node2D

@export var mount_id: String = "":
	set(value):
		mount_id = value
		if is_node_ready():
			_load_pose()

var _atlas: Texture2D
var _regions: Array = []
var _poses := PackedFloat32Array()
var _frame: Array = []


func _ready() -> void:
	_load_pose()


func _load_pose() -> void:
	_atlas = null
	_frame = []
	var folder := "res://Art/mount/official_parts/" + mount_id + "/"
	var index: Variant = JSON.parse_string(FileAccess.get_file_as_string(folder + "index.json"))
	if index is Dictionary and index.get("Mounts", {}).has("idle"):
		var entry: Dictionary = index.Mounts.idle
		var pose_folder := folder + str(entry.folder) + "/"
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(pose_folder + "poses.json"))
		if data is Dictionary:
			_atlas = load(str(data.atlas)) as Texture2D
			_regions = data.regions
			_poses = FileAccess.get_file_as_bytes(pose_folder + "poses.bin").to_float32_array()
			_frame = data.animations[str(entry.animation)].frames[0]
	queue_redraw()


func _draw() -> void:
	if _atlas == null or _frame.is_empty():
		return
	for part in range(int(_frame[0]), int(_frame[0]) + int(_frame[1])):
		var offset := part * 9
		var region: Array = _regions[int(_poses[offset])]
		var source := Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
		draw_set_transform_matrix(
			Transform2D(
				Vector2(_poses[offset + 1], _poses[offset + 2]),
				Vector2(_poses[offset + 3], _poses[offset + 4]),
				Vector2(_poses[offset + 5], _poses[offset + 6])
			)
		)
		draw_texture_rect_region(_atlas, Rect2(Vector2.ZERO, source.size), source, Color(1, 1, 1, _poses[offset + 7]))

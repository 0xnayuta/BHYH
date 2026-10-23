extends Node2D

const ROOT := "res://Art/hero_picture/role_6/official_parts_trial/"
const SETS := ["default", "y2V500", "y36"]
const DATA := preload("res://Script/hero/ne_zha_official_parts_data.gd")
const STRIDE := 9
var _data: RefCounted
@export var source_set := ""
@export var layer := -1
@export var visibility_source: NodePath
var _pose_key := "wait:0"
@export var pose_key := "wait:0":
	get:
		return _pose_key
	set(value):
		_pose_key = value
		var pair := value.rsplit(":", true, 1)
		if pair.size() == 2:
			set_pose(pair[0], int(pair[1]))

var animation_name := "wait"
var frame_index := -1
var animation_names: Array[String] = []
var max_parts := 0
var pose_bytes := 0
var atlas_size := Vector2i.ZERO
var _atlas: Texture2D
var _poses := PackedFloat32Array()
var _regions: Array[Rect2] = []
var _animations: Dictionary = {}
var _offset := 0
var _count := 0


func _ready() -> void:
	if source_set != "":
		var saved_pose := _pose_key
		if load_set(source_set):
			pose_key = saved_pose


func _process(_delta: float) -> void:
	if not visibility_source.is_empty():
		var source := get_node_or_null(visibility_source) as Sprite2D
		if is_instance_valid(source):
			visible = source.visible
			self_modulate = source.self_modulate


func load_set(set_name: String) -> bool:
	if _data != null and source_set == set_name:
		return true
	var data = DATA.get_set(set_name, _get_data_root())
	if data == null:
		return false
	_data = data
	source_set = set_name
	_atlas = data.atlas
	_poses = data.poses
	_regions = data.regions
	_animations = data.animations
	animation_names.assign(_animations.keys())
	max_parts = data.max_parts
	pose_bytes = _poses.size() * 4
	atlas_size = data.atlas_size
	frame_index = -1
	set_pose("wait", 0)
	return true


func _get_data_root() -> String:
	return ROOT


func get_frame_count(action: String) -> int:
	return _animations[action]["frames"].size() if _animations.has(action) else 0


func set_time(action: String, seconds: float) -> void:
	if not _animations.has(action):
		return
	var count := get_frame_count(action)
	var index := maxi(0, int(seconds * 30.0))
	if bool(_animations[action]["loop"]):
		index %= count
	set_pose(action, mini(index, count - 1))


func set_pose(action: String, index: int) -> void:
	if not _animations.has(action):
		return
	index = clampi(index, 0, get_frame_count(action) - 1)
	if animation_name == action and frame_index == index:
		return
	animation_name = action
	frame_index = index
	_pose_key = action + ":" + str(index)
	var frame: Array = _animations[action]["frames"][index]
	_offset = int(frame[0]) * STRIDE
	_count = int(frame[1])
	queue_redraw()


func _draw() -> void:
	if _atlas == null:
		return
	for index in range(_offset, _offset + _count * STRIDE, STRIDE):
		if layer >= 0 and int(_poses[index + 8]) != layer:
			continue
		var region := _regions[int(_poses[index])]
		draw_set_transform_matrix(
			Transform2D(
				Vector2(_poses[index + 1], _poses[index + 2]),
				Vector2(_poses[index + 3], _poses[index + 4]),
				(
					Vector2(_poses[index + 5], _poses[index + 6])
					+ (get("offset") + Vector2(0, 188) if get_class() == "Sprite2D" else Vector2.ZERO)
				)
			)
		)
		draw_texture_rect_region(
			_atlas, Rect2(Vector2.ZERO, region.size), region, Color(1, 1, 1, _poses[index + 7]), false, true
		)
	draw_set_transform_matrix(Transform2D.IDENTITY)

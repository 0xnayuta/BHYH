extends "res://Script/hero/ne_zha_official_parts.gd"

## 小龙女官方部件绘制：双刃形态合并身体/武器图层，圆刃形态切换到 ring 数据根。

@export var body_equipment := "Empty"
@export var weapon_equipment := "Empty"
var _body_data: RefCounted
var _weapon_data: RefCounted
var ring_form := false
const ROLE8_ROOT := "res://Art/hero_picture/role_8/official_parts/"
const ROLE8_RING_ROOT := ROLE8_ROOT + "ring/"


func set_ring_form(enabled: bool) -> void:
	if ring_form == enabled:
		return
	ring_form = enabled
	_data = null
	load_set("default")
	set_equipment(body_equipment, weapon_equipment)


func _ready() -> void:
	super._ready()
	if source_set == "default":
		set_equipment(body_equipment, weapon_equipment)


func set_equipment(body_id: String, weapon_id: String) -> void:
	body_equipment = body_id
	weapon_equipment = weapon_id
	_body_data = DATA.get_set(LongnvEquipmentData.appearance(body_id, "防具"), _get_data_root())
	_weapon_data = DATA.get_set(LongnvEquipmentData.appearance(weapon_id, "武器"), _get_data_root())
	queue_redraw()


func _draw() -> void:
	if source_set != "default" or _body_data == null or _weapon_data == null:
		super._draw()
		return
	if not _body_data.animations.has(animation_name) or not _weapon_data.animations.has(animation_name):
		return
	var body_frames: Array = _body_data.animations[animation_name].frames
	var weapon_frames: Array = _weapon_data.animations[animation_name].frames
	var body_frame: Array = body_frames[clampi(frame_index, 0, body_frames.size() - 1)]
	var weapon_frame: Array = weapon_frames[clampi(frame_index, 0, weapon_frames.size() - 1)]
	var body_index := int(body_frame[0]) * STRIDE
	var weapon_index := int(weapon_frame[0]) * STRIDE
	var body_end := body_index + int(body_frame[1]) * STRIDE
	var weapon_end := weapon_index + int(weapon_frame[1]) * STRIDE
	var draw_offset: Vector2 = get("offset") + Vector2(0, 188)
	while body_index < body_end or weapon_index < weapon_end:
		while body_index < body_end and int(_body_data.poses[body_index + 8]) % 2 != 0:
			body_index += STRIDE
		while weapon_index < weapon_end and int(_weapon_data.poses[weapon_index + 8]) % 2 != 1:
			weapon_index += STRIDE
		if body_index >= body_end and weapon_index >= weapon_end:
			break
		var use_body: bool = (
			weapon_index >= weapon_end
			or (body_index < body_end and _body_data.poses[body_index + 8] <= _weapon_data.poses[weapon_index + 8])
		)
		var data: RefCounted = _body_data if use_body else _weapon_data
		var index := body_index if use_body else weapon_index
		var poses: PackedFloat32Array = data.poses
		var region: Rect2 = data.regions[int(poses[index])]
		draw_set_transform_matrix(
			Transform2D(
				Vector2(poses[index + 1], poses[index + 2]),
				Vector2(poses[index + 3], poses[index + 4]),
				Vector2(poses[index + 5], poses[index + 6]) + draw_offset
			)
		)
		draw_texture_rect_region(
			data.atlas, Rect2(Vector2.ZERO, region.size), region, Color(1, 1, 1, poses[index + 7]), false, true
		)
		if use_body:
			body_index += STRIDE
		else:
			weapon_index += STRIDE
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _get_data_root() -> String:
	return ROLE8_RING_ROOT if ring_form else ROLE8_ROOT

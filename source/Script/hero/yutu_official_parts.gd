extends "res://Script/hero/ne_zha_official_parts.gd"

@export var body_equipment := "Empty"
@export var weapon_equipment := "Empty"
var _body_data: RefCounted
var _weapon_data: RefCounted


func _ready() -> void:
	super._ready()
	if source_set == "default":
		set_equipment(body_equipment, weapon_equipment)


func set_equipment(body_id: String, weapon_id: String) -> void:
	body_equipment = body_id
	weapon_equipment = weapon_id
	_body_data = DATA.get_set(YutuEquipmentData.appearance(body_id, "防具"), _get_data_root())
	_weapon_data = DATA.get_set(YutuEquipmentData.appearance(weapon_id, "武器"), _get_data_root())
	queue_redraw()


func _draw() -> void:
	if source_set != "default" or _body_data == null or _weapon_data == null:
		super._draw()
		return

	var offset_value: Vector2 = get("offset")
	var draw_offset := offset_value + Vector2(0, 188)
	for draw_layer in range(3):
		var data: RefCounted = _weapon_data if draw_layer == 1 else _body_data
		if not data.animations.has(animation_name):
			continue
		var frames: Array = data.animations[animation_name].frames
		var frame: Array = frames[clampi(frame_index, 0, frames.size() - 1)]
		var poses: PackedFloat32Array = data.poses
		var start := int(frame[0]) * STRIDE
		for index in range(start, start + int(frame[1]) * STRIDE, STRIDE):
			if int(poses[index + 8]) != draw_layer:
				continue
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
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _get_data_root() -> String:
	return "res://Art/hero_picture/role_7/official_parts/"

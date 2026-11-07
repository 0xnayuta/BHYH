extends "res://Script/hero/ne_zha_official_parts.gd"
class_name PetNianParts
var hide_beam := false
var part_index := -1


func beam_sample() -> Dictionary:
	for index in range(_offset, _offset + _count * STRIDE, STRIDE):
		var region := _regions[int(_poses[index])]
		if region.size.x > 400:
			return {
				"texture": _atlas,
				"region": region,
				"transform":
				Transform2D(
					Vector2(_poses[index + 1], _poses[index + 2]),
					Vector2(_poses[index + 3], _poses[index + 4]),
					Vector2(_poses[index + 5], _poses[index + 6])
				)
			}
	return {}


func _draw() -> void:
	if not hide_beam and part_index < 0:
		super._draw()
		return
	if _atlas == null:
		return
	for index in range(_offset, _offset + _count * STRIDE, STRIDE):
		if part_index >= 0 and (index - _offset) / STRIDE != part_index:
			continue
		var region := _regions[int(_poses[index])]
		if hide_beam and region.size.x > 400:
			continue
		draw_set_transform_matrix(
			Transform2D(
				Vector2(_poses[index + 1], _poses[index + 2]),
				Vector2(_poses[index + 3], _poses[index + 4]),
				Vector2(_poses[index + 5], _poses[index + 6])
			)
		)
		draw_texture_rect_region(
			_atlas, Rect2(Vector2.ZERO, region.size), region, Color(1, 1, 1, _poses[index + 7]), false, true
		)
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _get_data_root() -> String:
	return "res://Art/pet/pet_nian/official_parts/"


func beam_rect() -> Rect2:
	var result := Rect2()
	for index in range(_offset, _offset + _count * STRIDE, STRIDE):
		var region := _regions[int(_poses[index])]
		if region.size.x < 400:
			continue
		var pose := Transform2D(
			Vector2(_poses[index + 1], _poses[index + 2]),
			Vector2(_poses[index + 3], _poses[index + 4]),
			Vector2(_poses[index + 5], _poses[index + 6])
		)
		var bounds := pose * Rect2(Vector2.ZERO, region.size)
		result = bounds if not result.has_area() else result.merge(bounds)
	return result

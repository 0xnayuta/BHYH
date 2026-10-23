extends Node2D
class_name MountRiderLayer

## 官方骑乘部件层：按官方骨架数据绘制单个 draw_layer 的部件。
## 数据由 NeZhaOfficialPartsData 解析，本节点只负责渲染，不持有业务状态。

const DATA_STRIDE := 9

var _sprites: Array[Sprite2D] = []
var _additive_material: CanvasItemMaterial
var _last_data: RefCounted
var _last_action := ""
var _last_frame := -1
var _last_layer := -1
var _last_flags := 0


func show_pose(
	data: RefCounted, action: String, frame_index: int, draw_layer: int = -1, visible_flags: int = 0
) -> void:
	if data == null or not data.animations.has(action):
		hide_parts()
		return
	var frames: Array = data.animations[action]["frames"]
	var safe_frame := clampi(frame_index, 0, frames.size() - 1)
	if (
		_last_data == data
		and _last_action == action
		and _last_frame == safe_frame
		and _last_layer == draw_layer
		and _last_flags == visible_flags
	):
		return
	_last_data = data
	_last_action = action
	_last_frame = safe_frame
	_last_layer = draw_layer
	_last_flags = visible_flags
	var frame: Array = frames[safe_frame]
	var poses: PackedFloat32Array = data.poses
	var used := 0
	for index in range(int(frame[0]) * DATA_STRIDE, (int(frame[0]) + int(frame[1])) * DATA_STRIDE, DATA_STRIDE):
		var part_layer := int(poses[index + 8])
		if draw_layer >= 0 and part_layer % 4 != draw_layer:
			continue
		if (part_layer & 8) != 0 and (visible_flags & 8) == 0:
			continue
		if used == _sprites.size():
			var sprite := Sprite2D.new()
			sprite.centered = false
			sprite.region_enabled = true
			sprite.region_filter_clip_enabled = true
			add_child(sprite)
			_sprites.append(sprite)
		var sprite: Sprite2D = _sprites[used]
		if sprite.texture != data.atlas:
			sprite.texture = data.atlas
		sprite.region_rect = data.regions[int(poses[index])]
		sprite.transform = Transform2D(
			Vector2(poses[index + 1], poses[index + 2]),
			Vector2(poses[index + 3], poses[index + 4]),
			Vector2(poses[index + 5], poses[index + 6])
		)
		if sprite.modulate.a != poses[index + 7]:
			sprite.modulate.a = poses[index + 7]
		if (part_layer & 4) != 0 and _additive_material == null:
			_additive_material = CanvasItemMaterial.new()
			_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		var blend_material: CanvasItemMaterial = _additive_material if (part_layer & 4) != 0 else null
		if sprite.material != blend_material:
			sprite.material = blend_material
		if not sprite.visible:
			sprite.visible = true
		used += 1
	for index in range(used, _sprites.size()):
		if _sprites[index].visible:
			_sprites[index].visible = false


func hide_parts() -> void:
	_last_data = null
	_last_frame = -1
	for sprite in _sprites:
		if sprite.visible:
			sprite.visible = false

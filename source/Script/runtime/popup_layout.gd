class_name PopupLayout
extends RefCounted

## 统一浮层/tooltip 的视口避让：优先向右下展开，越界时翻到左侧/上方，
## 最后钳制在视口内。调用方传入以屏幕坐标表示的锚点与实际可见尺寸。

const DEFAULT_MARGIN := 8.0


## 将 Control/Node2D 放到屏幕锚点处，并按视口做翻转与钳制。
## visual_offset 是“节点原点 → 实际可见矩形左上角”的屏幕偏移。
static func place_screen(
	node: CanvasItem,
	anchor_screen: Vector2,
	size: Vector2,
	margin: float = DEFAULT_MARGIN,
	flip: bool = true,
	visual_offset: Vector2 = Vector2.ZERO
) -> void:
	if node == null or not is_instance_valid(node):
		return
	var viewport := node.get_viewport()
	if viewport == null:
		return
	var viewport_rect := viewport.get_visible_rect()
	var safe_size := Vector2(maxf(size.x, 0.0), maxf(size.y, 0.0))
	var target := anchor_screen
	if flip:
		if target.x + safe_size.x > viewport_rect.end.x - margin:
			target.x = anchor_screen.x - safe_size.x
		if target.y + safe_size.y > viewport_rect.end.y - margin:
			target.y = anchor_screen.y - safe_size.y
	var min_x := viewport_rect.position.x + margin
	var min_y := viewport_rect.position.y + margin
	var max_x := maxf(min_x, viewport_rect.end.x - safe_size.x - margin)
	var max_y := maxf(min_y, viewport_rect.end.y - safe_size.y - margin)
	target.x = clampf(target.x, min_x, max_x)
	target.y = clampf(target.y, min_y, max_y)
	var final_position := target - visual_offset
	if node is Control:
		(node as Control).global_position = final_position
	elif node is Node2D:
		(node as Node2D).global_position = final_position


## 锚点使用父节点局部坐标，适用于 box/tooltip 的鼠标定位路径。
static func place_parent_anchor(
	node: CanvasItem,
	anchor_local: Vector2,
	size: Vector2,
	margin: float = DEFAULT_MARGIN,
	flip: bool = true,
	visual_offset_local: Vector2 = Vector2.ZERO
) -> void:
	if node == null or not is_instance_valid(node):
		return
	var parent := node.get_parent()
	var anchor_screen := anchor_local
	var offset_screen := visual_offset_local
	if parent is CanvasItem:
		var parent_transform := (parent as CanvasItem).get_global_transform()
		anchor_screen = parent_transform * anchor_local
		offset_screen = parent_transform * visual_offset_local - parent_transform.origin
	place_screen(node, anchor_screen, size, margin, flip, offset_screen)


## 使用鼠标当前屏幕坐标作为锚点。
static func place_at_mouse(
	node: CanvasItem,
	offset: Vector2,
	size: Vector2,
	margin: float = DEFAULT_MARGIN,
	flip: bool = true,
	visual_offset: Vector2 = Vector2.ZERO
) -> void:
	if node == null or not is_instance_valid(node):
		return
	var viewport := node.get_viewport()
	if viewport == null:
		return
	place_screen(node, viewport.get_mouse_position() + offset, size, margin, flip, visual_offset)


## 读取 Control 的当前尺寸；布局尚未完成时回退到最小尺寸或 fallback。
static func resolved_size(node: CanvasItem, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	if node is Control:
		var control := node as Control
		var result := control.size
		if result.x <= 0.0 or result.y <= 0.0:
			result = control.get_combined_minimum_size()
		if result.x > 0.0 and result.y > 0.0:
			return result
	return fallback

extends Camera2D

## Phase 12-2：1280×800 画布下将世界可视高度扩大到 667，换取更宽的战斗视野。
const DESIGN_ZOOM := Vector2(1.2, 1.2)
## Phase 12-1 的原版取景基线；用于把扩大后的视野向上展开，避免下方露出关卡外。
const SOURCE_ZOOM := Vector2(1.3559, 1.3559)

var max_right
var max_left
var max_top
var max_bottom
var _vertical_offset := 0.0
var _shake_offset := Vector2.ZERO


func _ready() -> void:
	zoom = DESIGN_ZOOM
	_update_vertical_offset()
	_apply_offset()


func _physics_process(_delta: float) -> void:
	_update_vertical_offset()
	_apply_offset()
	limit_right = max_right
	limit_left = max_left
	limit_top = max_top
	limit_bottom = max_bottom


func _update_vertical_offset() -> void:
	if not is_equal_approx(zoom.y, DESIGN_ZOOM.y):
		_vertical_offset = 0.0
		return
	var viewport_height: float = float(get_viewport().size.y)
	var source_height: float = viewport_height / SOURCE_ZOOM.y
	var design_height: float = viewport_height / zoom.y
	_vertical_offset = (source_height - design_height) * 0.5


func _apply_offset() -> void:
	offset = Vector2(_shake_offset.x, _vertical_offset + _shake_offset.y)


func disturb_offset(strength: float):
	_shake_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
	_apply_offset()


func shake(strength: float, times: int, interv: float):
	for i in range(times):
		if not is_inside_tree():
			return

		var tree = get_tree()
		if tree == null:
			return

		disturb_offset(strength)

		var timer = tree.create_timer(interv, false)
		await timer.timeout

		if not is_inside_tree():
			return

		reset_offset()

	if is_inside_tree():
		reset_offset()


func reset_offset():
	_shake_offset = Vector2.ZERO
	_apply_offset()

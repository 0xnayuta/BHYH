extends Camera2D

var max_right
var max_left
var max_top
var max_bottom


func _physics_process(_delta: float) -> void:
	limit_right = max_right
	limit_left = max_left
	limit_top = max_top
	limit_bottom = max_bottom


func disturb_offset(strength: float):
	offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))


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
	offset = Vector2.ZERO

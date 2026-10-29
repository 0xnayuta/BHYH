extends AnimatedSprite2D

var _recycled := true


func setup(scale_value: Vector2, direction: bool, speed_value: float) -> void:
	_recycled = false
	visible = true
	modulate = Color.WHITE
	self_modulate = Color.WHITE
	flip_h = direction
	scale = scale_value
	speed_scale = speed_value
	frame = 0
	play(&"RoleBeHit")


func prepare_for_pool() -> void:
	_recycled = true
	stop()
	visible = false


func recycle() -> void:
	if _recycled:
		return
	_recycled = true
	if Global != null and Global.has_method("recycle_role_be_hit"):
		Global.recycle_role_be_hit(self)
	else:
		queue_free()


func _on_animation_finished() -> void:
	recycle()

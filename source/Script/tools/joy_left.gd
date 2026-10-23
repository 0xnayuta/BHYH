extends Control

var is_set: bool = false
var touch_scale: float = 1.0
var _size: Vector2 = Vector2(200, 200)
var cur_size: float = 200.0


func _physics_process(_delta: float) -> void:
	var side: float = min(_size.x, _size.y)
	if side <= 0:
		side = cur_size
	scale = Vector2(side / max(cur_size, 1.0), side / max(cur_size, 1.0)) * touch_scale


func _release_dirs() -> void:
	var joy = get_node_or_null("joyBG/joy")
	if joy != null and joy.has_method("_release_dirs"):
		joy._release_dirs()


func _on_button_pressed() -> void:
	pass

extends Node2D
class_name Lsh

const FULLSCREEN_DESIGN_SIZE := Vector2(984.0, 508.0)
const FULLSCREEN_CONTENT_CENTER := Vector2(492.0, 254.0)

var target_map: String


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(
		1.0, min(viewport_size.x / FULLSCREEN_DESIGN_SIZE.x, viewport_size.y / FULLSCREEN_DESIGN_SIZE.y)
	)
	scale = Vector2(fit_scale, fit_scale)
	position = viewport_size * 0.5 - FULLSCREEN_CONTENT_CENTER * fit_scale


func _ready() -> void:
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)


func _on_return_xss_pressed() -> void:
	queue_free()
	Global.change_scene("res://Scene/level/level_xss.tscn")


func _on_return_xbj_pressed() -> void:
	queue_free()
	Global.change_scene("res://Scene/level/level_xbj.tscn")


func _on_return_xts_pressed() -> void:
	queue_free()
	Global.change_scene("res://Scene/level/level_xts.tscn")


func _on_return_xwk_pressed() -> void:
	queue_free()
	Global.change_scene("res://Scene/level/level_xwk.tscn")


func _on_return_xhy_pressed() -> void:
	queue_free()
	Global.change_scene("res://Scene/level/level_xhy.tscn")


func _on_return_xs_pressed() -> void:
	Global.add_message_show(get_parent(), "敬请期待！！！！", 1.5, Vector2(470, 300))


func _on_close_pressed() -> void:
	queue_free()

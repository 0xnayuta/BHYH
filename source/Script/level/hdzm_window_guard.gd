extends Node

var popup: CanvasItem
var initial_scene: Node


func setup(target_popup: CanvasItem) -> void:
	popup = target_popup
	initial_scene = get_tree().current_scene


func _process(_delta: float) -> void:
	if popup == null or not is_instance_valid(popup):
		queue_free()
		return
	var current_scene := get_tree().current_scene
	if initial_scene != null and current_scene != initial_scene:
		popup.visible = false
		var popup_parent := popup.get_parent()
		if popup_parent != null:
			popup_parent.remove_child(popup)
		popup.queue_free()
		queue_free()

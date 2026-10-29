extends Node2D
const FULLSCREEN_DESIGN_SIZE := Vector2(922.0, 564.0)
const FULLSCREEN_CONTENT_CENTER := Vector2(462.0, 254.0)


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


var _is_closing := false
var source_popup: Node = null


func _ensure_dsg_progress() -> void:
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()


func _dsg_stage_clear(stage_key: String) -> bool:
	_ensure_dsg_progress()
	return int(PlayerData.player_data.get(stage_key, 0)) == 1


func _close_popup_chain() -> void:
	if _is_closing:
		return
	_is_closing = true
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	if source_popup != null and is_instance_valid(source_popup) and not source_popup.is_queued_for_deletion():
		if source_popup is CanvasItem:
			(source_popup as CanvasItem).visible = false
		source_popup.queue_free()
	queue_free()


func _enter_dsg_level(path: String) -> void:
	if _is_closing:
		return
	var scene_tree := get_tree()
	if scene_tree == null:
		push_error("当前节点不在场景树中，无法进入兜率宫关卡：%s" % path)
		return
	_close_popup_chain()
	Global.call_deferred("change_scene", path)


func _on_dsgyc_pressed() -> void:
	_enter_dsg_level("res://Scene/level/level_dsg_1.tscn")


func _on_dsgyc_2_pressed() -> void:
	if _dsg_stage_clear("兜率宫1"):
		_enter_dsg_level("res://Scene/level/level_dsg_2.tscn")
	else:
		Global.add_message_show(Global.windows, "请先通过兜率宫一层", 1.5, Vector2(470, 300))


func _on_dsgyc_3_pressed() -> void:
	if _dsg_stage_clear("兜率宫2"):
		_enter_dsg_level("res://Scene/level/level_dsg_3.tscn")
	else:
		Global.add_message_show(Global.windows, "请先通过兜率宫地下一层", 1.5, Vector2(470, 300))


func _on_dsgyc_4_pressed() -> void:
	if _dsg_stage_clear("兜率宫3"):
		_enter_dsg_level("res://Scene/level/level_dsg_4.tscn")
	else:
		Global.add_message_show(Global.windows, "请先通过兜率宫地下二层", 1.5, Vector2(470, 300))


func _on_dsgyc_5_pressed() -> void:
	if _dsg_stage_clear("兜率宫4"):
		_enter_dsg_level("res://Scene/level/level_dsg_5.tscn")
	else:
		Global.add_message_show(Global.windows, "请先通过兜率宫地下三层", 1.5, Vector2(470, 300))


func _on_close_pressed() -> void:
	_close_popup_chain()

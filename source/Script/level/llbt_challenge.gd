extends Node2D
const FULLSCREEN_DESIGN_SIZE := Vector2(922.0, 564.0)
const FULLSCREEN_CONTENT_CENTER := Vector2(451.0, 273.0)
@onready var ceng_shu_text: Label = $BG/CengShuText
var max_num
var current_ceng_shu: int = 1
var source_popup: Node = null


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


func _ensure_llbt_progress() -> void:
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()


func _llbt_reached_level() -> int:
	_ensure_llbt_progress()
	return clampi(int(PlayerData.player_data.get("玲珑宝塔层数", 0)), 0, 25)


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


func _enter_llbt_level() -> void:
	if _is_closing:
		return
	var scene_tree := get_tree()
	if scene_tree == null:
		push_error("当前节点不在场景树中，无法进入玲珑宝塔")
		return
	_close_popup_chain()
	Global.cleanup_transient_ui()
	Global.call_deferred("change_scene", "res://Scene/level/level_llbt.tscn")


func _physics_process(delta: float) -> void:
	max_num = _llbt_reached_level()
	if max_num >= 24:
		max_num = 24
	if ceng_shu_text != null and is_instance_valid(ceng_shu_text):
		ceng_shu_text.text = str(current_ceng_shu) + "/" + str(max_num)


func _on_wxms_pressed() -> void:
	Global.llbtbossms = false
	Global.llbtcgms = false
	Global.llbtwxms = true

	_enter_llbt_level()


func _on_cgms_pressed() -> void:
	Global.llbtbossms = false
	Global.llbtcgms = true
	Global.llbtwxms = false
	_enter_llbt_level()


func _on_tztxs_pressed() -> void:
	if _llbt_reached_level() > 6:
		Global.llbt_level = 6
		Global.llbtbossms = true
		Global.llbtwxms = false
		Global.llbtcgms = false
		_enter_llbt_level()
	else:
		Global.add_message_show(Global.windows, "请先至少到达第7层！！", 1.5, Vector2(470, 300))


func _on_tslzz_pressed() -> void:
	if _llbt_reached_level() > 12:
		Global.llbt_level = 12
		Global.llbtbossms = true
		Global.llbtwxms = false
		Global.llbtcgms = false
		_enter_llbt_level()
	else:
		Global.add_message_show(Global.windows, "请先至少到达第13层！！", 1.5, Vector2(470, 300))


func _on_tznz_pressed() -> void:
	if _llbt_reached_level() > 18:
		Global.llbt_level = 18
		Global.llbtbossms = true
		Global.llbtwxms = false
		Global.llbtcgms = false
		_enter_llbt_level()
	else:
		Global.add_message_show(Global.windows, "请先至少到达第19层！！", 1.5, Vector2(470, 300))


func _on_tztttw_pressed() -> void:
	if _llbt_reached_level() >= 25:
		Global.llbt_level = 24
		Global.llbtbossms = true
		Global.llbtwxms = false
		Global.llbtcgms = false
		_enter_llbt_level()
	else:
		Global.add_message_show(Global.windows, "请先通关玲珑塔！！", 1.5, Vector2(470, 300))


func _on_close_pressed() -> void:
	_close_popup_chain()


func _on_help_pressed() -> void:
	Global.add_message_show(Global.windows, "玲珑塔帮助还没做！！", 1.5, Vector2(470, 300))
	pass


func _on_cure_pressed() -> void:
	if current_ceng_shu >= _llbt_reached_level() or current_ceng_shu >= 24:
		Global.add_message_show(Global.windows, "已达当前通关最高层数！！", 1.5, Vector2(470, 300))
		return
	current_ceng_shu += 1


func _on_reduce_pressed() -> void:
	if current_ceng_shu <= 1:
		Global.add_message_show(Global.windows, "最低传送至1层！！", 1.5, Vector2(470, 300))
		return
	current_ceng_shu -= 1


func _on_change_pressed() -> void:
	if current_ceng_shu > _llbt_reached_level():
		Global.add_message_show(Global.windows, "超出最高限制层数！！", 1.5, Vector2(470, 300))
		return
	if current_ceng_shu < 1:
		Global.add_message_show(Global.windows, "低于最低限制层数！！", 1.5, Vector2(470, 300))
		return
	Global.llbtcgms = true
	Global.llbt_level = current_ceng_shu
	_enter_llbt_level()

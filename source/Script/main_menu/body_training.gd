extends Node2D
class_name BodyTraining

const DESIGN_SIZE := Vector2(941.0, 591.0)
const DETAIL_SCENE_PATH := "res://Scene/main_menu/body_training_detail.tscn"
const BODY_IDS := BodyTrainingData.BODY_IDS
const TRAINING_KEY := "炼体"
@onready var main_panel: Sprite2D = $MainPanel
@onready var main_attribute: Label = get_node_or_null("MainAttribute") as Label

var body_data: Dictionary = {}
var detail_page: Node = null


func _ready() -> void:
	z_index = 4095
	z_as_relative = false
	_ensure_body_data()
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	for index in BODY_IDS.size():
		var button := get_node_or_null("Body%05d" % BODY_IDS[index]) as BaseButton
		if button != null:
			button.pressed.connect(_on_body_pressed.bind(index))
	_refresh_main_panel()


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.disconnect(_fit_to_fullscreen)


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	scale = Vector2.ONE
	position = viewport_size * 0.5


func _ensure_body_data() -> void:
	body_data = BodyTrainingData.normalize_state(PlayerData.player_data.get(TRAINING_KEY, {}))
	PlayerData.player_data[TRAINING_KEY] = body_data


func _current_profile() -> Dictionary:
	var profile: Variant = body_data.get("p1", {})
	return profile if profile is Dictionary else {}


func _refresh_main_panel() -> void:
	if main_attribute != null:
		var attributes: Dictionary = BodyTrainingData.get_attribute_totals(body_data)
		main_attribute.text = (
			"生命+%d\n魔法+%d\n攻击+%d\n物防+%d\n魔防+%d"
			% [
				attributes["hpMax"],
				attributes["mpMax"],
				attributes["atk"],
				attributes["phyDef"],
				attributes["magicDef"]
			]
		)
	for index in BODY_IDS.size():
		var level_label := get_node_or_null("BodyLevel%d" % index) as Label
		if level_label != null:
			var entry: Dictionary = _current_profile().get(str(BODY_IDS[index]), {})
			var level := int(entry.get("level", 0))
			level_label.text = "Lv.%d" % level
			level_label.z_index = 3
			var icon := get_node_or_null("AttributeIcon%d" % index) as Sprite2D
			if icon != null:
				icon.visible = true


func refresh_from_detail() -> void:
	_ensure_body_data()
	_refresh_main_panel()


func _on_body_pressed(index: int) -> void:
	if is_instance_valid(detail_page) and not detail_page.is_queued_for_deletion():
		if detail_page.has_method("setup"):
			detail_page.setup(self, index)
		return
	var detail_scene := Global.load_ui_scene(DETAIL_SCENE_PATH)
	if detail_scene == null:
		_show_message("体魄修炼页面加载失败")
		return
	detail_page = detail_scene.instantiate()
	Global.register_ui_runtime_instance(detail_page, DETAIL_SCENE_PATH)
	if detail_page.has_method("setup"):
		detail_page.setup(self, index)
	var parent := _ui_parent()
	parent.add_child(detail_page)
	detail_page.tree_exited.connect(_on_detail_exited, CONNECT_ONE_SHOT)


func _on_detail_exited() -> void:
	detail_page = null


func _on_main_close_pressed() -> void:
	if is_instance_valid(detail_page):
		detail_page.queue_free()
		detail_page = null
	var map_root := get_tree().current_scene
	if map_root != null and map_root.has_method("clear_body_training_page"):
		map_root.clear_body_training_page(self)
	queue_free()


func _ui_parent() -> Node:
	if Global.has_method("get_ui_popup_layer"):
		return Global.get_ui_popup_layer()
	if Global.windows != null:
		return Global.windows
	return get_parent() if get_parent() != null else self


func _show_message(message: String) -> void:
	Global.add_message_show(_ui_parent(), message, 1.2, Vector2.ZERO)

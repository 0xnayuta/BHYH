class_name CoopPanelHost
extends Node

## 协作面板宿主的 UI 生命周期：面板实例、图层/窗口栈、暂停、选择器、
## 场景按钮、关闭保存与临时 UI 清理。槽位、账本与输入会话仍由 LocalCoop 持有。

const PANEL_PATHS := {
	"背包": "res://Scene/back_pack/back_pack.tscn",
	"技能": "res://Scene/skill/learn_skill.tscn",
	"宠物": "res://Scene/pet/pet_interface.tscn",
	"法宝": "res://Scene/back_pack/magic_weapon_infor.tscn",
	"坐骑": "res://Scene/main_menu/mount_panel.tscn",
}

var _session: Node
var _panel_layer: CanvasLayer
var _panel: Node
var _panel_type := ""
var _panel_scene: PackedScene
var _switching_panel := false
var _panel_was_paused := false
var _has_open_panel := false
var _windows_pushed := false
var _session_buttons: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func setup(session: Node) -> void:
	_session = session
	process_mode = Node.PROCESS_MODE_ALWAYS


func has_panel() -> bool:
	return is_instance_valid(_panel)


func current_panel() -> Node:
	return _panel


func current_layer() -> CanvasLayer:
	return _panel_layer


func open_panel(slot: int, type: String) -> void:
	if is_instance_valid(_panel) or _switching_panel or _session == null or not _session.is_enabled():
		return
	if not PANEL_PATHS.has(type):
		return
	if MemoryClass != null and MemoryClass.has_method("is_save_snapshot_in_progress"):
		if bool(MemoryClass.is_save_snapshot_in_progress()):
			return
	var scene := get_tree().current_scene
	if scene == null:
		return
	var panel_scene := Global.load_ui_scene(str(PANEL_PATHS[type]))
	if panel_scene == null:
		push_warning("协作面板加载失败：%s" % str(PANEL_PATHS[type]))
		return
	_set_ui_slot(slot)
	_panel_was_paused = get_tree().paused
	_has_open_panel = true
	get_tree().paused = true
	_panel_type = type
	_panel_scene = panel_scene
	var layer := CanvasLayer.new()
	layer.layer = 30
	# 弹出层携带槽位，供当前 UI 宿主下的子面板与弹窗解析操作者。
	layer.set_meta("coop_slot", slot)
	scene.add_child(layer)
	_panel_layer = layer
	Global.get_ui_runtime().push_windows(layer)
	_windows_pushed = true
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.25)
	shade.size = get_viewport().get_visible_rect().size
	layer.add_child(shade)
	_create_panel(slot, type)


func close_panel() -> void:
	if is_instance_valid(_panel):
		_panel.queue_free()


func switch_panel(slot: int) -> void:
	_switch_panel(slot)


func on_scene_changed(scene: Node) -> void:
	clear()
	if _session == null or not _session.is_enabled() or scene == null:
		return
	if not scene.scene_file_path.begins_with("res://Scene/main_menu/map_") and not scene is BaseLevel:
		return
	_session_buttons = CanvasLayer.new()
	_session_buttons.layer = 12
	scene.add_child(_session_buttons)
	var row := HBoxContainer.new()
	row.position = Vector2(325, 4)
	_session_buttons.add_child(row)
	for slot in [1, 2]:
		for type: String in ["背包", "技能"]:
			var button := Button.new()
			button.text = "%dP%s" % [slot, type]
			button.pressed.connect(open_panel.bind(slot, type))
			row.add_child(button)
	if not scene is BaseLevel:
		(
			row
			. set_deferred(
				"position",
				Vector2(
					get_viewport().get_visible_rect().size.x - row.get_combined_minimum_size().x - 12,
					get_viewport().get_visible_rect().size.y - 42,
				)
			)
		)


## 会话重置/场景切换时立即释放 UI，不触发面板关闭保存。
func clear() -> void:
	_dispose_panel()
	if is_instance_valid(_session_buttons):
		_session_buttons.queue_free()
	_session_buttons = null


func _set_ui_slot(slot: int) -> void:
	if _session != null and is_instance_valid(_session):
		_session.ui_slot = clampi(slot, 1, 2)


func _dispose_panel() -> void:
	_switching_panel = false
	if is_instance_valid(_panel):
		if _panel.tree_exited.is_connected(_on_panel_closed):
			_panel.tree_exited.disconnect(_on_panel_closed)
		_panel.queue_free()
	_panel = null
	_panel_scene = null
	if is_instance_valid(_panel_layer):
		_panel_layer.queue_free()
	_panel_layer = null
	if _windows_pushed:
		Global.get_ui_runtime().pop_windows()
		_windows_pushed = false
	if _has_open_panel and is_inside_tree():
		get_tree().paused = _panel_was_paused
	_has_open_panel = false
	_set_ui_slot(1)


func _create_panel(slot: int, type: String) -> void:
	if _panel_scene == null or not is_instance_valid(_panel_layer):
		return
	var path: String = PANEL_PATHS[type]
	_panel = _panel_scene.instantiate()
	if type == "背包":
		_panel.set_script(load("res://Script/coop/coop_backpack.gd"))
	_panel.set_meta("coop_slot", slot)
	_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	if type == "背包":
		var props: Variant = _session.props_for_slot(slot)
		var player: Variant = props.source_player if is_instance_valid(props) else null
		if _has_property(_panel, "Player"):
			_panel.set("Player", player if is_instance_valid(player) else null)
		Global.configure_backpack_role_preview(_panel, player)
	Global.get_ui_runtime().register_ui_runtime_instance(_panel, path)
	_panel.tree_exited.connect(_on_panel_closed, CONNECT_ONE_SHOT)
	_panel_layer.add_child(_panel)
	get_tree().paused = true
	if type in ["背包", "法宝"]:
		_panel.position = get_viewport().get_visible_rect().size * 0.5
	elif type == "宠物":
		_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		_panel.size = Vector2(653, 513)
		_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	_panel.set_meta("coop_layer", _panel_layer)
	_add_player_selector(type)


func _add_player_selector(type: String) -> void:
	var tabs: BoxContainer
	if type in ["技能", "坐骑"]:
		tabs = HBoxContainer.new()
	else:
		tabs = VBoxContainer.new()
	tabs.name = "CoopPlayerSelector"
	tabs.add_theme_constant_override("separation", 6)
	match type:
		"背包":
			tabs.position = Vector2(-408, -195)
		"技能":
			tabs.position = Vector2(394, 6)
		"宠物":
			tabs.position = Vector2(-50, 40)
		"法宝":
			tabs.position = Vector2(-355, -177)
		"坐骑":
			tabs.position = Vector2(24, 15)
	var group := ButtonGroup.new()
	for slot in [1, 2]:
		var button := Button.new()
		button.name = "Player%d" % slot
		button.text = "%dP" % slot
		button.custom_minimum_size = Vector2(66 if type == "技能" else 46, 40)
		button.toggle_mode = true
		button.button_group = group
		button.set_pressed_no_signal(slot == _session.ui_slot)
		button.add_theme_font_size_override("font_size", UiFontSizes.FONT_SIZE_22)
		button.add_theme_color_override("font_color", UiColorTokens.TEXT_CREAM)
		button.add_theme_color_override("font_pressed_color", UiColorTokens.TEXT_GOLD_PALE_BRIGHT)
		for state: String in ["normal", "hover", "pressed", "focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = UiSurfaceTokens.COOP_TAB_BG_PRESSED if state == "pressed" else UiSurfaceTokens.COOP_TAB_BG
			style.border_color = (
				UiSurfaceTokens.COOP_TAB_BORDER_FOCUS
				if state in ["pressed", "focus"]
				else UiSurfaceTokens.COOP_TAB_BORDER
			)
			style.set_border_width_all(2)
			style.set_corner_radius_all(5)
			button.add_theme_stylebox_override(state, style)
		button.pressed.connect(_switch_panel.bind(slot))
		tabs.add_child(button)
	if type == "坐骑":
		_panel.panel_root.add_child(tabs)
	else:
		_panel.add_child(tabs)


func _switch_panel(slot: int) -> void:
	if _switching_panel or slot == _session.ui_slot or not is_instance_valid(_panel):
		return
	_switching_panel = true
	_replace_panel.call_deferred(slot)


func _replace_panel(slot: int) -> void:
	if not is_instance_valid(_panel) or not is_instance_valid(_panel_layer):
		_switching_panel = false
		return
	var old_panel := _panel
	old_panel.tree_exited.disconnect(_on_panel_closed)
	Global.get_ui_runtime().clear_hover_popup()
	old_panel.free()
	_session.link_bags()
	_set_ui_slot(slot)
	_panel_layer.set_meta("coop_slot", slot)
	_create_panel(slot, _panel_type)
	_switching_panel = false


func _on_panel_closed() -> void:
	if not is_inside_tree():
		return
	if is_instance_valid(_panel_layer):
		_panel_layer.queue_free()
	_panel_layer = null
	if _windows_pushed:
		Global.get_ui_runtime().pop_windows()
		_windows_pushed = false
	Global.get_ui_runtime().clear_hover_popup()
	_set_ui_slot(1)
	_panel = null
	_panel_scene = null
	if _session != null and is_instance_valid(_session):
		_session.link_bags()
		_session.refresh_passive_skills()
		var props: Variant = _session.secondary_props
		if is_instance_valid(props):
			props.get_equ_last_pro()
			props.get_last_prop()
	if _has_open_panel and is_inside_tree():
		get_tree().paused = _panel_was_paused
	_has_open_panel = false
	Global.request_save_with_feedback(
		"coop_panel_close",
		Global.get_ui_runtime().windows if is_instance_valid(Global.get_ui_runtime().windows) else self,
		"面板关闭保存失败："
	)


func _unhandled_key_input(event: InputEvent) -> void:
	if _session == null or not _session.is_enabled() or not event is InputEventKey or event.echo or not event.pressed:
		return
	if event.physical_keycode == KEY_KP_ADD:
		open_panel(2, "背包")
		get_viewport().set_input_as_handled()
	elif event.physical_keycode == KEY_INSERT:
		open_panel(2, "技能")
		get_viewport().set_input_as_handled()


func _has_property(node: Object, key: String) -> bool:
	if node == null:
		return false
	for property in node.get_property_list():
		if str(property.get("name", "")) == key:
			return true
	return false

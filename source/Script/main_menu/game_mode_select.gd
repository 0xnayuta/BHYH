extends CanvasLayer

signal mode_selected(player_count: int)

var _chosen := false


func _ready() -> void:
	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.color = Color(0, 0, 0, 0.48)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 300)
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("dab070")
	frame.border_color = Color("382714")
	frame.set_border_width_all(5)
	frame.set_corner_radius_all(12)
	frame.content_margin_left = 28
	frame.content_margin_right = 28
	frame.content_margin_top = 28
	frame.content_margin_bottom = 28
	frame.shadow_color = Color(0, 0, 0, 0.5)
	frame.shadow_size = 10
	panel.add_theme_stylebox_override("panel", frame)
	center.add_child(panel)
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	panel.add_child(row)
	var labels := ["单人游戏", "双人游戏", "取消"]
	for index in labels.size():
		var button := Button.new()
		button.name = ["SinglePlayer", "TwoPlayers", "Cancel"][index]
		button.text = labels[index]
		button.custom_minimum_size = Vector2(240, 64)
		button.add_theme_font_override("font", preload("res://Font/1_fonts_fzcy_fz_cu_yuan_m03.ttf"))
		button.add_theme_font_size_override("font_size", 30)
		button.add_theme_color_override("font_color", Color("291a08"))
		button.add_theme_color_override("font_hover_color", Color("291a08"))
		button.add_theme_color_override("font_pressed_color", Color("291a08"))
		for state in ["normal", "hover", "pressed", "focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = Color("ed9908") if state == "normal" else Color("ffc343")
			if state == "pressed":
				style.bg_color = Color("c57a06")
			style.border_color = Color("73501d")
			style.set_border_width_all(3)
			style.set_corner_radius_all(7)
			button.add_theme_stylebox_override(state, style)
		if index < 2:
			button.pressed.connect(_choose.bind(index + 1))
		else:
			button.pressed.connect(queue_free)
		row.add_child(button)
	row.get_child(0).grab_focus()


func _choose(player_count: int) -> void:
	if _chosen:
		return
	_chosen = true
	mode_selected.emit(player_count)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()

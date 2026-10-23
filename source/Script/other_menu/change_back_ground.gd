extends CanvasLayer

signal background_changed(index: int)

const BACKGROUND_LOCK_HINTS := {
	2: "到达二图解锁二图封面",
	3: "到达三图解锁三图封面",
	4: "到达四图解锁四图封面",
	5: "到达五图解锁五图封面",
	6: "到达六图解锁外传封面",
}


func _on_game_1_bg_pressed() -> void:
	_select_background(1)


func _on_game_2_bg_pressed() -> void:
	_select_background(2)


func _on_game_3_bg_pressed() -> void:
	_select_background(3)


func _on_game_4_bg_pressed() -> void:
	_select_background(4)


func _on_game_5_bg_pressed() -> void:
	_select_background(5)


func _on_game_5_bg_2_pressed() -> void:
	_select_background(6)


func _on_close_pressed() -> void:
	queue_free()


func _select_background(index: int) -> void:
	if MainSet.is_main_menu_background_unlocked(index):
		set_bg_image(index)
		return
	Global.add_message_show(
		Global.get_ui_popup_layer(), str(BACKGROUND_LOCK_HINTS.get(index, "该背景尚未解锁")), 1.5, Vector2(470, 300)
	)


func set_bg_image(index: int) -> void:
	MainSet.set_data["MainMenuBG"] = clampi(index, 1, 6)
	MemoryClass.main_bc()
	background_changed.emit(MainSet.set_data["MainMenuBG"])

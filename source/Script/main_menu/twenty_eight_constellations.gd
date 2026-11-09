extends Node2D

const BUTTON_SCENE := preload("res://Scene/other_scene/twenty_eight_constellations_button.tscn")
const NAMES := ["轸宿", "翼火蛇", "张月鹿", "星日马", "柳宿", "鬼宿", "井宿", "壁宿", "室宿", "危宿", "虚宿", "女宿", "牛宿", "斗宿"]

@onready var panel: Panel = $XingXiuBg
@onready var boss_button_list: GridContainer = $XingXiuBg/BossButtonCenter/BossButtonList
@onready var close_button: TextureButton = $XingXiuBg/Close


func _ready() -> void:
	if close_button != null:
		close_button.texture_normal = load("res://Art/constellations/ui/31.png")
		close_button.texture_pressed = close_button.texture_normal
		close_button.texture_hover = close_button.texture_normal
		close_button.ignore_texture_size = true
		close_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_build_boss_buttons()
	_center_panel()
	if not get_viewport().size_changed.is_connected(_center_panel):
		get_viewport().size_changed.connect(_center_panel)


func _center_panel() -> void:
	if panel == null:
		return
	var viewport_rect := get_viewport().get_visible_rect()
	var viewport_center := viewport_rect.position + viewport_rect.size * 0.5
	panel.position = to_local(viewport_center) - panel.size * 0.5


func _build_boss_buttons() -> void:
	for child in boss_button_list.get_children():
		child.queue_free()
	for level in range(1, 15):
		var button := BUTTON_SCENE.instantiate()
		button.configure(level, NAMES[level - 1], level >= 8)
		boss_button_list.add_child(button)


func _on_close_pressed() -> void:
	queue_free()

extends TextureButton

var level_index: int = 1
var constellation_name := ""


func configure(level: int, display_name: String, is_north: bool) -> void:
	level_index = clampi(level, 1, 14)
	constellation_name = display_name
	var icon := load("res://Art/constellations/icons/%d.png" % level_index) as Texture2D
	texture_normal = icon
	texture_pressed = icon
	texture_hover = icon
	texture_disabled = icon
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	custom_minimum_size = Vector2(120, 92)
	tooltip_text = "%d  %s" % [level_index, constellation_name]
	modulate = Color("9fc8ff") if is_north else Color("ffd19a")
	var label := Label.new()
	label.name = "Name"
	label.text = "%02d  %s" % [level_index, constellation_name]
	label.position = Vector2(0, 67)
	label.size = Vector2(120, 22)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	add_child(label)


func _on_pressed() -> void:
	Global.selected_constellation_level = level_index
	Global.change_scene("res://Scene/level/level_esbxx.tscn")

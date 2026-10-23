extends Label
var font: Font
var show_text: String
var font_color: Color
var out_line_size: int
var out_line_color: Color
var font_size: int


func _physics_process(delta: float) -> void:
	self.add_theme_color_override("font_color", font_color)
	self.add_theme_color_override("font_outline_color", out_line_color)
	self.add_theme_constant_override("outline_size", out_line_size)
	if font != null:
		self.add_theme_font_override("font", font)
	self.add_theme_font_size_override("font_size", font_size)
	self.text = show_text
	set_physics_process(false)

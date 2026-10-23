extends TextureRect

var combo_num: int


func _ready() -> void:
	refresh()


func setup(value) -> void:
	var next_digit := int(value)
	visible = true
	if combo_num == next_digit and texture != null:
		return
	combo_num = next_digit
	refresh()


func refresh() -> void:
	texture = Global.get_cached_texture("res://Art/all_number/lj/lj_" + str(combo_num) + ".png")

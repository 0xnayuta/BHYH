extends TextureRect
@onready var items: Button = $Items
@onready var _name: Label = $Name

var item_id
var num = 1


func _ready() -> void:
	items.hide_prop = true


func _physics_process(delta: float) -> void:
	items.set_button_icon(load_item_icon(item_id))
	items.total_number = num if num != null else 1
	_name.text = AE.all_equipment[item_id][DataKeys.NAME]
	var color = AE.all_equipment[item_id]["颜色"]
	_name.add_theme_color_override("font_color", color)
	_name.add_theme_color_override("font_outline_color", color)
	set_physics_process(false)


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc

extends Button
class_name PetBackpackSlot

signal slot_pressed(slot_index: int)

var slot_index: int = -1

@onready var item_icon: TextureRect = $ItemIcon
@onready var item_number: Label = $item_number


func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)


func set_item(texture: Texture2D, _item_tooltip: String, strengthen_level: int) -> void:
	item_icon.texture = texture
	item_icon.visible = texture != null
	tooltip_text = ""
	item_number.text = "+%d" % strengthen_level if strengthen_level > 0 else ""
	disabled = false


func clear_item() -> void:
	item_icon.texture = null
	item_icon.visible = false
	tooltip_text = ""
	item_number.text = ""
	disabled = false


func _on_pressed() -> void:
	slot_pressed.emit(slot_index)

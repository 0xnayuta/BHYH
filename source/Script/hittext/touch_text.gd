extends Control
@onready var bg = $MarginContainer/bg
@onready var st = $MarginContainer/MarginContainer/show_text
var tt: String


func _physics_process(_delta: float) -> void:
	st.text = tt

	pass

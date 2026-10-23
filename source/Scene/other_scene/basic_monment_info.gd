extends Control

## Global.add_basic_monment_info 注入的显示文本，与 message_info / message_show 等同族弹窗保持同一约定。
var show_text: String = ""

@onready var label: Label = $MarginContainer/ShowText


func _ready() -> void:
	self.z_index = 99


func _physics_process(_delta: float) -> void:
	label.text = str(show_text)

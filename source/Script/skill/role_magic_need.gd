extends Node2D
@onready var infor: Label = $PanelContainer/Infor

var skill_name: String
var current_need: int
var next_need: int


func _physics_process(delta: float) -> void:
	infor.text = "技能名：" + str(skill_name) + "，魔耗：" + str(current_need) + "  →  " + str(next_need)
	set_physics_process(false)

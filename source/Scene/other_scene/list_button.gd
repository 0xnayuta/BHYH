extends Button
var self_name: String
var father
var num: int


func _physics_process(delta: float) -> void:
	text = str(self_name)
	set_physics_process(false)


func _on_pressed() -> void:
	father.add_boss(self_name, num)

extends Button
var self_name: String
var father


func _physics_process(delta: float) -> void:
	text = str(self_name)
	set_physics_process(false)


func _on_pressed() -> void:
	father.target_boss = self_name
	father.show_prop()

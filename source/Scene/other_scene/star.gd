extends TextureRect
var type: int


func _physics_process(delta: float) -> void:
	texture = load("res://Art/main_game/choose_player/xx_" + str(type) + ".png")
	set_physics_process(false)

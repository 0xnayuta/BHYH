extends TouchScreenButton


func _ready() -> void:
	if not OS.has_feature("android"):
		queue_free()

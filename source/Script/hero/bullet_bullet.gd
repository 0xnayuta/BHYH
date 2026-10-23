extends RoleBullet


func _physics_process(_delta: float) -> void:
	if not is_set:
		bullet_players.play(_name)
		if direction:
			middle.scale.x = -1
		else:
			middle.scale.x = 1
		is_set = true

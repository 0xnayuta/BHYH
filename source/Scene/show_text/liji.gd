extends Label


func _ready() -> void:
	var combo_count := Global.get_combat_pool().get_combo_count()
	if combo_count > 1:
		self.text = str(combo_count) + "连击！！"
		$LjPlayer.play("LJ")
	else:
		queue_free()

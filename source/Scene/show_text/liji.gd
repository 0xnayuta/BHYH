extends Label


func _ready() -> void:
	if Global.lj_times > 1:
		self.text = str(Global.lj_times) + "连击！！"
		$LjPlayer.play("LJ")
	else:
		queue_free()

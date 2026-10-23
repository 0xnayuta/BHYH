extends AudioStreamPlayer

var target
var is_set = false


func _physics_process(_delta: float) -> void:
	set_volume_db(int(MainSet.set_data["MusicFB"]))
	if MainSet.set_data["BackGroundMusic"]:
		if not is_set:
			stream = Global.get_cached_audio(str(target))
			play()
			is_set = true
		self.stream_paused = false
	else:
		self.stream_paused = true


func _on_finished() -> void:
	queue_free()

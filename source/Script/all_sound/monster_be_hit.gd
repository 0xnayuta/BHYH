extends AudioStreamPlayer

var target
var is_set = false
var _last_volume_db := INF


func _apply_current_volume() -> void:
	var desired_volume := float(MainSet.set_data["MusicFB_2"]) if MainSet.set_data["RoleOrMonsterHit"] else -80.0
	if not is_equal_approx(_last_volume_db, desired_volume):
		_last_volume_db = desired_volume
		set_volume_db(desired_volume)


func setup(target_) -> void:
	target = target_
	is_set = false
	stream = Global.get_cached_audio(str(target))
	_last_volume_db = INF
	_apply_current_volume()
	set_physics_process(false)
	play()
	is_set = true


func _ready() -> void:
	set_physics_process(false)
	if not Global.sound_settings_changed.is_connected(_on_sound_settings_changed):
		Global.sound_settings_changed.connect(_on_sound_settings_changed)
	if target != null and not is_set:
		setup(target)


func _on_sound_settings_changed() -> void:
	if not is_set:
		return
	if not bool(MainSet.set_data.get("RoleOrMonsterHit", true)):
		_on_finished()
	else:
		_apply_current_volume()


func _on_finished() -> void:
	if not is_set:
		return
	stop()
	stream = null
	target = null
	is_set = false
	set_physics_process(false)
	if Global != null and Global.has_method("recycle_sound_player"):
		Global.recycle_sound_player(self)
	else:
		queue_free()

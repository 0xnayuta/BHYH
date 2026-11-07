extends "res://Script/hero/ne_zha_skill_effect.gd"
class_name FirstBatchAwakenArea

var freeze_seconds := 0.0
var _target_pulses: Dictionary = {}


func _ready() -> void:
	mirror_like_player = true
	super._ready()
	_enable_overlap_damage()


func _on_hit_box_area_entered(_area: Area2D) -> void:
	pass


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or bool(player.get("is_death")):
		queue_free()
		return
	_elapsed += delta
	if _elapsed >= life_seconds:
		queue_free()
		return
	var pulse := mini(max_hit_pulses - 1, floori(_elapsed / hit_interval)) if hit_interval > 0.0 else 0
	_apply_overlap_damage(pulse, _target_pulses, freeze_seconds)

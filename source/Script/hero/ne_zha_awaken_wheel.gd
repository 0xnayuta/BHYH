extends "res://Script/hero/ne_zha_skill_effect.gd"
class_name NeZhaAwakenWheel
var thrown := false
var _flight_age := 0.0
var _throw_direction := 1.0
var _target_pulses: Dictionary = {}


func _ready() -> void:
	super._ready()
	_enable_overlap_damage()


func _on_hit_box_area_entered(_area: Area2D) -> void:
	pass


func launch() -> void:
	if thrown:
		return
	thrown = true
	orbit_target = null
	_throw_direction = 1.0 if player.player_dir else -1.0
	direction = player.player_dir
	_elapsed = 0.0
	_pulse_elapsed = 0.0
	_pulse_count = 1
	_damage_exhausted = false
	_target_pulses.clear()
	max_hit_pulses = 4
	life_seconds = 3.0
	_refresh_collision_state()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or bool(player.get("is_death")):
		queue_free()
		return
	if not thrown and _elapsed + delta >= life_seconds:
		launch()
	if thrown:
		_flight_age += delta
		if _flight_age < 0.7:
			move_velocity = Vector2(_throw_direction * 650.0, 0)
		else:
			var hand := player.global_position + Vector2(0, -50)
			move_velocity = global_position.direction_to(hand) * 900.0
			if global_position.distance_to(hand) <= 900.0 * delta + 20.0:
				queue_free()
				return
	super._physics_process(delta)
	if not is_queued_for_deletion():
		_apply_overlap_damage(_pulse_count, _target_pulses)

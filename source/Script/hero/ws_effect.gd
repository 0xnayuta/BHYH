extends Node2D
@onready var death_timer: Timer = $DeathTimer
@export var live_time: float = 0.3
@export var alfa_factor: float = 1.0
@export var color: Color = Color(1, 1, 1)


func _process(_delta: float) -> void:
	if death_timer == null:
		return
	if death_timer.is_stopped():
		death_timer.start(live_time)
	var alfa: float = death_timer.time_left * alfa_factor / float(live_time)
	modulate = Color(color.r, color.g, color.b, alfa)


func _on_death_timer_timeout() -> void:
	queue_free()

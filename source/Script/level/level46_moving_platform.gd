extends AnimatableBody2D

@export var speed_x: float = 0.0
@export var speed_y: float = 5.0
@export var move_time_ms: float = 1000.0
@export var move_loop: bool = true

var _direction: float = 1.0
var _elapsed_ms: float = 0.0
var _moving: bool = true


func _ready() -> void:
	_direction = 1.0
	_elapsed_ms = 0.0
	_moving = true


func _physics_process(delta: float) -> void:
	if not _moving or move_time_ms <= 0.0:
		return

	var remaining_ms := maxf(delta * 1000.0, 0.0)
	while remaining_ms > 0.0 and _moving:
		var segment_ms := minf(remaining_ms, move_time_ms - _elapsed_ms)
		if segment_ms > 0.0:
			var velocity := Vector2(speed_x, speed_y) * _direction
			position += velocity * (segment_ms / 1000.0)
			_elapsed_ms += segment_ms
			remaining_ms -= segment_ms

		if _elapsed_ms >= move_time_ms:
			_elapsed_ms -= move_time_ms
			if move_loop:
				_direction *= -1.0
			else:
				_moving = false

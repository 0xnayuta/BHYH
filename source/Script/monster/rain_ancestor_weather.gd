extends Node2D
class_name RainAncestorWeather

const RAIN_COUNT := 50
const FIELD_SIZE := Vector2(1800.0, 900.0)
const SOURCE_FRAME_RATE := 30.0

var _center := Vector2.ZERO
var _direction := 1.0
var _duration := 10.0
var _elapsed := 0.0
var _drops: Array[Vector2] = []
var _velocity := Vector2.ZERO


func configure(center: Vector2, direction: float, duration: float) -> void:
	_center = center + Vector2(0.0, -300.0)
	_direction = signf(direction) if not is_zero_approx(direction) else 1.0
	_duration = maxf(duration, 0.1)


func _ready() -> void:
	top_level = true
	global_position = _center
	z_as_relative = false
	z_index = 120
	_velocity = Vector2(30.0 * SOURCE_FRAME_RATE * _direction, 45.0 * SOURCE_FRAME_RATE)
	var random := RandomNumberGenerator.new()
	random.seed = 3182
	for index in range(RAIN_COUNT):
		_drops.append(
			Vector2(
				random.randf_range(-FIELD_SIZE.x * 0.5, FIELD_SIZE.x * 0.5),
				random.randf_range(-FIELD_SIZE.y * 0.5, FIELD_SIZE.y * 0.5)
			)
		)
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		queue_free()
		return
	var half := FIELD_SIZE * 0.5
	for index in range(_drops.size()):
		var point := _drops[index] + _velocity * delta
		point.x = fposmod(point.x + half.x, FIELD_SIZE.x) - half.x
		point.y = fposmod(point.y + half.y, FIELD_SIZE.y) - half.y
		_drops[index] = point
	queue_redraw()


func _draw() -> void:
	var tail := _velocity.normalized() * 34.0
	for point: Vector2 in _drops:
		draw_line(point - tail, point, Color(0.58, 0.92, 0.84, 0.72), 2.0, true)

extends AnimatableBody2D

@export var speed_x: float = 10.0
@export var right_edge: float = 1200.0
@export var body_width: float = 400.0

var _role_on_ship := false
var _tracked_role: Node2D


func _ready() -> void:
	var sensor := get_node_or_null("BoardingSensor") as Area2D
	if sensor == null:
		return
	sensor.body_entered.connect(_on_boarding_sensor_body_entered)
	sensor.body_exited.connect(_on_boarding_sensor_body_exited)


func _physics_process(delta: float) -> void:
	if not _role_on_ship or not _can_move_in_current_screen():
		return
	var stop_x := right_edge - body_width * 0.5
	position.x = minf(position.x + speed_x * delta, stop_x)
	if is_equal_approx(position.x, stop_x):
		_role_on_ship = false


func _on_boarding_sensor_body_entered(body: Node2D) -> void:
	if not _is_level_role(body):
		return
	if body == _tracked_role:
		_role_on_ship = true
		return
	_tracked_role = body
	_role_on_ship = true


func _on_boarding_sensor_body_exited(body: Node2D) -> void:
	if body != _tracked_role:
		return
	_tracked_role = null
	_role_on_ship = false


func _is_level_role(body: Node2D) -> bool:
	var level := get_parent()
	return level != null and body == level.get("role_")


func _can_move_in_current_screen() -> bool:
	var level := get_parent()
	return level != null and int(level.get("current_stage")) == 1

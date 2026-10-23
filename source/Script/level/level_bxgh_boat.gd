extends AnimatableBody2D
class_name LevelBXGHBoat

const SOURCE_FPS := 24.0
const SOURCE_LEFT_X := 200.0
const SOURCE_RIGHT_X := 760.0

@export var source_speed := 3.0

var _direction := 1.0
var _is_static := false
var _source_frame_remainder := 0.0
var _left_edge_local := 0.0
var _right_edge_local := 0.0


func _ready() -> void:
	visible = true
	var boat_visual := get_node_or_null("Sprite2D") as Sprite2D
	if boat_visual != null:
		boat_visual.visible = true
		boat_visual.z_as_relative = false
		boat_visual.z_index = -1
	var parent_node := get_parent() as Node2D
	var parent_x := parent_node.global_position.x if parent_node != null else 0.0
	_left_edge_local = SOURCE_LEFT_X - parent_x
	_right_edge_local = SOURCE_RIGHT_X - parent_x
	position.x = clampf(position.x, _left_edge_local, _right_edge_local)


func _physics_process(delta: float) -> void:
	if _is_static:
		return
	_source_frame_remainder += maxf(delta, 0.0) * SOURCE_FPS
	while _source_frame_remainder >= 1.0:
		_source_frame_remainder -= 1.0
		var next_x := position.x + _direction * source_speed

		if next_x > _right_edge_local:
			_direction = -1.0
		elif next_x < _left_edge_local:
			_direction = 1.0
		else:
			position.x = next_x


func set_static() -> void:
	_is_static = true
	_source_frame_remainder = 0.0

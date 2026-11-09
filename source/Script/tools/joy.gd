extends TouchScreenButton

const DRAG_RADIUS := 64.0
const REST_POS := Vector2(-25, -25)

var finger_index: int = -1
var drag_offset: Vector2 = Vector2.ZERO
var is_set: bool = false
var _mouse_dragging: bool = false
@onready var rest_pos: Vector2 = REST_POS


func _ready() -> void:
	position = rest_pos


func _input(event: InputEvent) -> void:
	if is_set:
		return

	var mouse_button := event as InputEventMouseButton
	if mouse_button != null and mouse_button.button_index == MOUSE_BUTTON_LEFT:
		if (
			mouse_button.pressed
			and finger_index == -1
			and not _mouse_dragging
			and _contains_global_point(mouse_button.position)
		):
			_mouse_dragging = true
			drag_offset = _parent_local(mouse_button.position) - position
			get_viewport().set_input_as_handled()
		elif not mouse_button.pressed and _mouse_dragging:
			_mouse_dragging = false
			_release_dirs()
			position = rest_pos
			get_viewport().set_input_as_handled()
		return

	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion != null and _mouse_dragging:
		_drag_to(mouse_motion.position)
		get_viewport().set_input_as_handled()
		return

	var st := event as InputEventScreenTouch
	if st:
		if st.pressed and finger_index == -1:
			if _contains_global_point(st.position) or _contains_joy_base_point(st.position):
				finger_index = st.index
				var parent_local := _parent_local(st.position)
				if _contains_global_point(st.position):
					drag_offset = parent_local - position
				else:
					drag_offset = Vector2.ZERO
					_drag_to(st.position)
				get_viewport().set_input_as_handled()
		elif not st.pressed and st.index == finger_index:
			_release_dirs()
			finger_index = -1
			position = rest_pos
			get_viewport().set_input_as_handled()
		return

	var sd := event as InputEventScreenDrag
	if sd and sd.index == finger_index:
		_drag_to(sd.position)


func _parent_local(screen_pos: Vector2) -> Vector2:
	var parent_node := get_parent()
	if parent_node is Node2D:
		return parent_node.to_local(screen_pos)
	return screen_pos


func _contains_global_point(point: Vector2) -> bool:
	if texture_normal == null:
		return false
	return Rect2(Vector2.ZERO, texture_normal.get_size()).has_point(to_local(point))


func _contains_joy_base_point(point: Vector2) -> bool:
	var parent_node := get_parent()
	if parent_node == null:
		return false
	var base_tex = parent_node.get("texture")
	var base_size := Vector2(200, 200)
	if base_tex != null and base_tex.has_method("get_size"):
		base_size = base_tex.get_size()
	var local_pos := _parent_local(point)
	var rect := Rect2(-base_size * 0.5, base_size)
	return rect.has_point(local_pos)


func _drag_to(screen_pos: Vector2) -> void:
	var wish_pos := _parent_local(screen_pos) - drag_offset
	var movement := (wish_pos - rest_pos).limit_length(DRAG_RADIUS)
	position = rest_pos + movement
	movement /= DRAG_RADIUS
	_apply_dirs(movement)


func _apply_dirs(movement: Vector2) -> void:
	if movement.x > 0.15:
		_release_action("move_left")
		_press_action("move_right")
	elif movement.x < -0.15:
		_release_action("move_right")
		_press_action("move_left")
	else:
		_release_action("move_right")
		_release_action("move_left")

	if movement.y < -0.8:
		_release_action("down")
		_press_action("Exit", -movement.y)
	elif movement.y > 0.8:
		_release_action("Exit")
		_press_action("down", movement.y)
	else:
		_release_action("Exit")
		_release_action("down")


func _press_action(action_name: String, strength: float = 1.0) -> void:
	if InputMap.has_action(action_name):
		Input.action_press(action_name, strength)


func _release_action(action_name: String) -> void:
	if InputMap.has_action(action_name):
		Input.action_release(action_name)


func _release_dirs() -> void:
	_release_action("move_right")
	_release_action("move_left")
	_release_action("down")
	_release_action("Exit")


func _exit_tree() -> void:
	_release_dirs()

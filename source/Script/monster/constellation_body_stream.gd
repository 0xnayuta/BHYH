extends StreamedPngEffect
class_name ConstellationBodyStream

var _canvas_size := Vector2i(250, 250)
var _body_offset := Vector2.ZERO
var _face_right := false


func configure_canvas(canvas_size: Vector2i, body_offset: Vector2, face_right: bool) -> void:
	_canvas_size = canvas_size
	_body_offset = body_offset
	_face_right = face_right
	_update_registration()


func set_face_right(value: bool) -> void:
	if _face_right == value:
		return
	_face_right = value
	if _sprite != null:
		_sprite.flip_h = value
	_update_registration()


func _ready() -> void:
	flip_h = _face_right
	super._ready()
	if is_instance_valid(_sprite):
		_sprite.centered = false
		_update_registration()


func _update_registration() -> void:
	var direct_offset_x := _body_offset.x if _face_right else -_body_offset.x
	position = Vector2(-float(_canvas_size.x) * 0.5 + direct_offset_x, -float(_canvas_size.y) * 0.5 + _body_offset.y)

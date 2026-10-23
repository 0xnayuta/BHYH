extends StreamedPngEffect
class_name ConstellationBodyStream

var frame_textures: Array[Texture2D] = []
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
	_sprite = Sprite2D.new()
	_sprite.centered = false
	_sprite.flip_h = _face_right
	add_child(_sprite)
	_update_registration()
	_show_frame(0, true)


func _show_frame(frame_index: int, allow_sync_load: bool = false) -> void:
	if not frame_textures.is_empty():
		if frame_index == _last_frame or frame_index < 0 or frame_index >= frame_textures.size():
			return
		var texture := frame_textures[frame_index]
		if texture == null or _sprite == null:
			return
		_sprite.texture = texture
		_last_frame = frame_index
		_last_path = ""
		_has_displayed_frame = true
		return
	if frame_index == _last_frame or frame_index < 0 or frame_index >= frame_paths.size():
		return
	var path := frame_paths[frame_index]
	var uses_atlas_region := frame_regions.size() == frame_paths.size()
	if not uses_atlas_region and path == _last_path and _sprite != null and _sprite.texture != null:
		_last_frame = frame_index
		_has_displayed_frame = true
		_request_frame_window(frame_index + 1)
		return
	var source_texture: Texture2D = null
	if uses_atlas_region and path == _last_path and _sprite != null and _sprite.texture is AtlasTexture:
		source_texture = (_sprite.texture as AtlasTexture).atlas
	else:
		source_texture = _take_requested_texture(path, allow_sync_load)
	if source_texture == null or _sprite == null:
		return
	_last_frame = frame_index
	_last_path = path
	if uses_atlas_region:
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = source_texture
		atlas_texture.region = frame_regions[frame_index]
		if frame_margins.size() == frame_paths.size():
			atlas_texture.margin = frame_margins[frame_index]
		atlas_texture.filter_clip = true
		_sprite.texture = atlas_texture
	else:
		_sprite.texture = source_texture
	_has_displayed_frame = true
	_request_frame_window(frame_index + 1)


func _update_registration() -> void:
	var direct_offset_x := _body_offset.x if _face_right else -_body_offset.x
	position = Vector2(-float(_canvas_size.x) * 0.5 + direct_offset_x, -float(_canvas_size.y) * 0.5 + _body_offset.y)

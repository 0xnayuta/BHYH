extends Node2D
class_name StreamedPngEffect

signal finished
signal frame_ready
signal failed(message: String)

static var _matte_shader: Shader


static func _get_matte_shader() -> Shader:
	if _matte_shader == null:
		_matte_shader = Shader.new()
		_matte_shader.code = "shader_type canvas_item;\nrender_mode blend_add;\nuniform bool remove_black = false;\nuniform bool remove_blue = false;\nuniform vec2 black_edges = vec2(0.025, 0.065);\nuniform vec2 blue_edges = vec2(0.72, 0.88);\nvoid fragment() {\n    vec4 pixel = texture(TEXTURE, UV) * COLOR;\n    float black_mask = 1.0;\n    float blue_mask = 1.0;\n    if (remove_black) {\n        black_mask = smoothstep(black_edges.x, black_edges.y, max(max(pixel.r, pixel.g), pixel.b));\n    }\n    if (remove_blue) {\n        blue_mask = 1.0 - smoothstep(blue_edges.x, blue_edges.y, pixel.b) * (1.0 - smoothstep(0.02, 0.28, max(pixel.r, pixel.g)));\n    }\n    pixel.a *= black_mask * blue_mask;\n    if (pixel.a <= 0.001) { discard; }\n    COLOR = pixel;\n}\n"

	return _matte_shader


@export var sequence: FrameSequence
var auto_free: bool = true
var manual_frame_control: bool = false
var registration_offset: Vector2 = Vector2.ZERO:
	set(value):
		registration_offset = value
		_update_registration_position()
var remove_black_background: bool = false
var black_background_threshold: float = 0.045
var black_background_feather: float = 0.02
var remove_blue_background: bool = false
var blue_background_threshold: float = 0.8
var blue_background_feather: float = 0.08
var flip_h: bool = false:
	set(value):
		flip_h = value
		if _sprite != null:
			_sprite.flip_h = value

var _sprite: Sprite2D
var _atlas_texture: AtlasTexture
var _displayed_page: Texture2D
var _time := 0.0
var _last_frame := -1
var _manual_frame: int = 0
var _requested_paths: Dictionary[String, bool] = {}
var _finished := false
var _shutting_down := false
var _has_displayed_frame := false


func _ready() -> void:
	var errors: Array[String] = ["sequence is required"] if sequence == null else sequence.validate()
	if not errors.is_empty():
		_fail("Invalid FrameSequence: " + ", ".join(errors))
		return
	_sprite = Sprite2D.new()
	_sprite.centered = true
	_sprite.flip_h = flip_h
	_update_registration_position()
	if remove_black_background or remove_blue_background:
		var material := ShaderMaterial.new()
		material.shader = _get_matte_shader()
		material.set_shader_parameter("remove_black", remove_black_background)
		material.set_shader_parameter("remove_blue", remove_blue_background)
		material.set_shader_parameter(
			"black_edges",
			Vector2(
				maxf(black_background_threshold - black_background_feather, 0.0),
				black_background_threshold + black_background_feather
			)
		)
		material.set_shader_parameter(
			"blue_edges",
			Vector2(
				maxf(blue_background_threshold - blue_background_feather, 0.0),
				minf(blue_background_threshold + blue_background_feather, 1.0)
			)
		)
		_sprite.material = material
	add_child(_sprite)
	_request_frame_window(0)
	_show_frame(0)


func _update_registration_position() -> void:
	if is_instance_valid(_sprite):
		_sprite.position = Vector2(-registration_offset.x if flip_h else registration_offset.x, registration_offset.y)


func _process(delta: float) -> void:
	if _finished or _shutting_down:
		return
	# 首帧就绪前不消耗动画时间；避免一次性特效尚未显示就结束。
	if _last_frame < 0:
		_show_frame(_manual_frame if manual_frame_control else 0)
		return
	if manual_frame_control:
		_show_frame(_manual_frame)
		return
	_time += delta
	var frame_index := int(floor(_time * sequence.fps))
	if frame_index >= sequence.count():
		if sequence.loop:
			frame_index %= sequence.count()
		elif sequence.hold_last_frame:
			if _show_frame(sequence.count() - 1):
				_finish()
			return
		else:
			if _show_frame(sequence.count() - 1):
				_finish()
			return
	_show_frame(frame_index)


func clear_texture() -> void:
	if is_instance_valid(_sprite):
		_sprite.texture = null
	_displayed_page = null
	if _atlas_texture != null:
		_atlas_texture.atlas = null
	_has_displayed_frame = false


func has_displayed_frame() -> bool:
	return _has_displayed_frame and is_instance_valid(_sprite) and _sprite.texture != null


func displayed_frame() -> int:
	return _last_frame


func show_frame(frame_index: int) -> void:
	if not manual_frame_control or _shutting_down or sequence == null:
		return
	_manual_frame = clampi(frame_index, 0, sequence.count() - 1)
	_show_frame(_manual_frame)


func _request_frame_window(frame_index: int) -> void:
	if _shutting_down:
		return
	var retained: Dictionary[String, bool] = {}
	for offset in range(sequence.prefetch_frames + 1):
		var index := frame_index + offset
		if sequence.loop:
			index %= sequence.count()
		elif index >= sequence.count():
			break
		var path := sequence.frame_paths[index]
		retained[path] = true
		if not _requested_paths.has(path):
			_requested_paths[path] = true
			if not FrameTextureRequests.acquire(path):
				_fail("FrameSequence texture request failed: " + path)
				return
	for path: String in _requested_paths.keys():
		if not retained.has(path):
			FrameTextureRequests.release(path)
			_requested_paths.erase(path)


func _show_frame(frame_index: int) -> bool:
	if _shutting_down or frame_index < 0 or frame_index >= sequence.count():
		return false
	if frame_index == _last_frame and _has_displayed_frame:
		return true
	_request_frame_window(frame_index)
	if _shutting_down:
		return false
	var path := sequence.frame_paths[frame_index]
	if FrameTextureRequests.has_failed(path):
		_fail("FrameSequence texture load failed: " + path)
		return false
	var texture := FrameTextureRequests.get_texture(path)
	if texture == null:
		return false
	_last_frame = frame_index
	var visible_frame := sequence.frame_has_visual.is_empty() or sequence.frame_has_visual[frame_index]
	_displayed_page = texture
	if not visible_frame:
		_sprite.texture = null
	elif not sequence.frame_regions.is_empty():
		if _atlas_texture == null:
			_atlas_texture = AtlasTexture.new()
			_atlas_texture.filter_clip = true
		_atlas_texture.atlas = texture
		_atlas_texture.region = sequence.frame_regions[frame_index]
		_atlas_texture.margin = (
			sequence.frame_margins[frame_index] if not sequence.frame_margins.is_empty() else Rect2()
		)
		_sprite.texture = _atlas_texture
	else:
		_sprite.texture = texture
	var first_frame := not _has_displayed_frame
	_has_displayed_frame = _has_displayed_frame or visible_frame
	if first_frame and visible_frame:
		frame_ready.emit()
	return true


func _finish() -> void:
	if _finished:
		return
	_finished = true
	set_process(false)
	_shutdown_texture_loader()
	if not sequence.hold_last_frame and auto_free:
		clear_texture()
	finished.emit()
	if auto_free and not sequence.hold_last_frame:
		queue_free()


func _fail(message: String) -> void:
	if _finished:
		return
	_finished = true
	set_process(false)
	_shutdown_texture_loader()
	clear_texture()
	push_error(message)
	failed.emit(message)
	if auto_free:
		queue_free()


func _exit_tree() -> void:
	_shutdown_texture_loader()


func _shutdown_texture_loader() -> void:
	if _shutting_down:
		return
	_shutting_down = true
	for path: String in _requested_paths:
		FrameTextureRequests.release(path)
	_requested_paths.clear()

extends Node2D
class_name StreamedPngEffect

signal finished
signal frame_ready

static var _prewarmed_textures: Dictionary = {}
static var _prewarm_mutex := Mutex.new()
static var _prewarm_generation := 0
static var _matte_shader: Shader


static func _get_matte_shader() -> Shader:
	if _matte_shader == null:
		_matte_shader = Shader.new()
		_matte_shader.code = "shader_type canvas_item;\nrender_mode blend_add;\nuniform bool remove_black = false;\nuniform bool remove_blue = false;\nuniform vec2 black_edges = vec2(0.025, 0.065);\nuniform vec2 blue_edges = vec2(0.72, 0.88);\nvoid fragment() {\n    vec4 pixel = texture(TEXTURE, UV) * COLOR;\n    float black_mask = 1.0;\n    float blue_mask = 1.0;\n    if (remove_black) {\n        black_mask = smoothstep(black_edges.x, black_edges.y, max(max(pixel.r, pixel.g), pixel.b));\n    }\n    if (remove_blue) {\n        blue_mask = 1.0 - smoothstep(blue_edges.x, blue_edges.y, pixel.b) * (1.0 - smoothstep(0.02, 0.28, max(pixel.r, pixel.g)));\n    }\n    pixel.a *= black_mask * blue_mask;\n    if (pixel.a <= 0.001) { discard; }\n    COLOR = pixel;\n}\n"

	return _matte_shader


var frame_paths: Array[String] = []
var frame_regions: Array[Rect2] = []
var frame_margins: Array[Rect2] = []
var frame_has_visual: Array[bool] = []
var fps: float = 24.0
var loop_animation: bool = false
var auto_free: bool = true
var hold_last_frame: bool = false
var manual_frame_control: bool = false

var registration_offset: Vector2 = Vector2.ZERO:
	set(value):
		registration_offset = value
		_update_registration_position()

var allow_sync_first_frame: bool = true
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
var _last_path := ""
var _pending_paths: Dictionary = {}
var _ready_textures: Dictionary = {}
var _prefetch_count := 2
var _finished := false
var _shutting_down := false
var _has_displayed_frame := false


static func prewarm_effect_roots(root_paths: Array, frames_per_directory: int = 3) -> void:
	var pending_paths: Array[String] = []
	var seen_paths: Dictionary = {}
	var frame_limit := maxi(1, frames_per_directory)
	for root_path_value in root_paths:
		var root_path := str(root_path_value)
		if root_path == "":
			continue
		if not DirAccess.dir_exists_absolute(root_path):
			continue
		for directory_name in DirAccess.get_directories_at(root_path):
			var directory_path := root_path.path_join(directory_name)
			var file_names: Array[String] = []
			for file_name in DirAccess.get_files_at(directory_path):
				if file_name.get_extension().to_lower() == "png":
					file_names.append(file_name)
			if file_names.is_empty():
				_append_numbered_png_names(file_names, directory_path)
			file_names.sort_custom(func(a: String, b: String): return a.naturalnocasecmp_to(b) < 0)
			for index in range(mini(frame_limit, file_names.size())):
				var path := directory_path.path_join(file_names[index])
				if seen_paths.has(path) or _has_prewarmed_texture(path):
					continue
				seen_paths[path] = true
				pending_paths.append(path)
	if pending_paths.is_empty():
		return

	var mutex := _prewarm_mutex
	mutex.lock()
	var generation := _prewarm_generation
	mutex.unlock()
	var tree := Engine.get_main_loop() as SceneTree
	var batch_size := 2 if OS.has_feature("mobile") else 4
	var loaded_in_batch := 0
	for path in pending_paths:
		var texture: Texture2D
		if tree == null:
			texture = ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
		else:
			var request_error := ResourceLoader.load_threaded_request(path, "Texture2D")
			var status := ResourceLoader.load_threaded_get_status(path)
			if request_error != OK and status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				continue
			while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await tree.process_frame
				status = ResourceLoader.load_threaded_get_status(path)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				texture = ResourceLoader.load_threaded_get(path) as Texture2D
		mutex.lock()
		var generation_changed := generation != _prewarm_generation
		if not generation_changed and texture != null:
			_prewarmed_textures[path] = texture
		mutex.unlock()
		if generation_changed:
			return
		loaded_in_batch += 1
		if tree != null and loaded_in_batch >= batch_size:
			loaded_in_batch = 0
			await tree.process_frame


static func clear_prewarmed_images() -> void:
	var mutex := _prewarm_mutex
	mutex.lock()
	_prewarm_generation += 1
	_prewarmed_textures.clear()
	mutex.unlock()


static func _append_numbered_png_names(file_names: Array[String], directory_path: String) -> void:
	var missing_streak := 0
	for index in range(601):
		var file_name := str(index) + ".png"
		if ResourceLoader.exists(directory_path.path_join(file_name)):
			file_names.append(file_name)
			missing_streak = 0
		elif not file_names.is_empty():
			missing_streak += 1
			if missing_streak >= 30:
				break


static func _has_prewarmed_texture(path: String) -> bool:
	var mutex := _prewarm_mutex
	mutex.lock()
	var has_texture := _prewarmed_textures.has(path)
	mutex.unlock()
	return has_texture


static func _get_prewarmed_texture(path: String) -> Texture2D:
	var mutex := _prewarm_mutex
	mutex.lock()
	var texture := _prewarmed_textures.get(path) as Texture2D
	mutex.unlock()
	return texture


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.centered = true
	_sprite.flip_h = flip_h
	_update_registration_position()
	if remove_black_background or remove_blue_background:
		var black_threshold := clampf(black_background_threshold, 0.0, 1.0)
		var black_feather := clampf(black_background_feather, 0.0001, 0.5)
		var blue_threshold := clampf(blue_background_threshold, 0.0, 1.0)
		var blue_feather := clampf(blue_background_feather, 0.0001, 0.5)
		var material := ShaderMaterial.new()
		material.shader = _get_matte_shader()
		material.set_shader_parameter("remove_black", remove_black_background)
		material.set_shader_parameter("remove_blue", remove_blue_background)
		material.set_shader_parameter(
			"black_edges", Vector2(maxf(black_threshold - black_feather, 0.0), black_threshold + black_feather)
		)
		material.set_shader_parameter(
			"blue_edges", Vector2(maxf(blue_threshold - blue_feather, 0.0), minf(blue_threshold + blue_feather, 1.0))
		)
		_sprite.material = material
	add_child(_sprite)
	_show_frame(0, allow_sync_first_frame)
	if not _has_displayed_frame:
		_request_frame_window(0)
	else:
		_request_frame_window(1)


func _update_registration_position() -> void:
	if _sprite == null or not is_instance_valid(_sprite):
		return
	_sprite.position = Vector2(-registration_offset.x if flip_h else registration_offset.x, registration_offset.y)


func _process(delta: float) -> void:
	if frame_paths.is_empty():
		_finish()
		return
	_collect_ready_textures()
	if manual_frame_control:
		return
	_time += delta
	var frame_index := int(floor(_time * maxf(fps, 1.0)))
	if frame_index >= frame_paths.size():
		if loop_animation:
			frame_index %= frame_paths.size()
		elif hold_last_frame:
			_show_frame(frame_paths.size() - 1)
			return
		else:
			_finish()
			return
	_show_frame(frame_index)


func clear_texture() -> void:
	if _sprite != null and is_instance_valid(_sprite):
		_sprite.texture = null
	_displayed_page = null
	if _atlas_texture != null:
		_atlas_texture.atlas = null
	_has_displayed_frame = false


func has_displayed_frame() -> bool:
	return _has_displayed_frame and _sprite != null and is_instance_valid(_sprite) and _sprite.texture != null


func show_frame(frame_index: int) -> void:
	if not manual_frame_control or frame_paths.is_empty():
		return
	_collect_ready_textures()
	_show_frame(clampi(frame_index, 0, frame_paths.size() - 1))


func _request_frame_window(frame_index: int) -> void:
	if _shutting_down or frame_paths.is_empty():
		return
	var retained_paths: Dictionary = {}
	for offset in range(_prefetch_count + 1):
		var request_index := frame_index + offset
		if loop_animation:
			request_index %= frame_paths.size()
		elif request_index >= frame_paths.size():
			break
		var path := frame_paths[request_index]
		retained_paths[path] = true
		_request_texture(path)
	for ready_path in _ready_textures.keys():
		if not retained_paths.has(ready_path):
			_ready_textures.erase(ready_path)


func _request_texture(path: String) -> void:
	path = path
	if path == _last_path and _displayed_page != null:
		return
	if _shutting_down or _pending_paths.has(path) or _ready_textures.has(path):
		return
	var prewarmed_texture := _get_prewarmed_texture(path)
	if prewarmed_texture != null:
		_ready_textures[path] = prewarmed_texture
		return
	var request_error := ResourceLoader.load_threaded_request(path, "Texture2D", false, ResourceLoader.CACHE_MODE_REUSE)
	var status := ResourceLoader.load_threaded_get_status(path)
	if request_error == OK or status != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		_pending_paths[path] = true


func _collect_ready_textures() -> void:
	for path_value in _pending_paths.keys():
		var path := str(path_value)
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			continue
		if status != ResourceLoader.THREAD_LOAD_LOADED:
			_pending_paths.erase(path)
			continue
		var texture := ResourceLoader.load_threaded_get(path) as Texture2D
		_pending_paths.erase(path)
		if texture != null:
			_ready_textures[path] = texture


func _take_requested_texture(path: String, allow_sync_load: bool = false) -> Texture2D:
	path = path
	if path == _last_path and _displayed_page != null:
		return _displayed_page
	if allow_sync_load:
		var prewarmed_texture := _get_prewarmed_texture(path)
		if prewarmed_texture != null:
			return prewarmed_texture
		if _ready_textures.has(path):
			var ready_texture := _ready_textures[path] as Texture2D
			_ready_textures.erase(path)
			return ready_texture
		return ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	_request_texture(path)
	if _ready_textures.has(path):
		var ready_texture := _ready_textures[path] as Texture2D
		_ready_textures.erase(path)
		return ready_texture

	return null


func _show_frame(frame_index: int, allow_sync_load: bool = false) -> void:
	if (frame_index == _last_frame and _has_displayed_frame) or frame_index < 0 or frame_index >= frame_paths.size():
		return
	var path := frame_paths[frame_index]
	var uses_atlas_region := frame_regions.size() == frame_paths.size()
	if not uses_atlas_region and path == _last_path and _sprite != null and _sprite.texture != null:
		_last_frame = frame_index
		_request_frame_window(frame_index + 1)
		return
	var texture := _take_requested_texture(path, allow_sync_load)
	if texture == null or _sprite == null:
		return
	_last_frame = frame_index
	_last_path = path
	var first_frame := not _has_displayed_frame
	_displayed_page = texture
	if uses_atlas_region:
		if _atlas_texture == null:
			_atlas_texture = AtlasTexture.new()
			_atlas_texture.filter_clip = true
		if _atlas_texture.atlas != texture:
			_atlas_texture.atlas = texture
		_atlas_texture.region = frame_regions[frame_index]
		_atlas_texture.margin = frame_margins[frame_index] if frame_margins.size() == frame_paths.size() else Rect2()
		_sprite.texture = _atlas_texture
	else:
		_sprite.texture = texture
	var current_frame_has_visual := true
	if frame_has_visual.size() == frame_paths.size():
		current_frame_has_visual = frame_has_visual[frame_index]
	_has_displayed_frame = _has_displayed_frame or current_frame_has_visual
	if first_frame and current_frame_has_visual:
		frame_ready.emit()
	_request_frame_window(frame_index + 1)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	_shutdown_texture_loader()
	if not hold_last_frame and auto_free:
		clear_texture()
	finished.emit()
	if auto_free:
		queue_free()


func _exit_tree() -> void:
	_shutdown_texture_loader()


func _shutdown_texture_loader() -> void:
	if _shutting_down:
		return
	_shutting_down = true
	_pending_paths.clear()
	_ready_textures.clear()

## 7.4 魂卡闪卡预览；由 7.4 反编译参考按当前路径适配。
extends "res://Script/main_menu/soul_card_page.gd"

const DATA := preload("res://Script/data/soul_card_data.gd")
signal enlarged
var card_id := "qly"
var allow_drag := false
var card_star := 0
var compact := false
static var _alpha_rect_cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_motion_enabled = false
	_stage = TextureRect.new()
	_stage.name = "FoilCard"
	_stage.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stage.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_stage)
	_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stage.gui_input.connect(_preview_input)
	_stage.resized.connect(_update_render_resolution)
	_build_card()
	display_card(card_id, card_star)
	auto_rotate = true
	if compact:
		auto_rotate = false
		_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_angles = Vector2.ZERO
		_target = Vector2.ZERO
		_card.rotation = Vector3.ZERO
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		set_process(false)
	call_deferred("_update_render_resolution")


func display_card(id: String, star: int = 0) -> void:
	card_id = id
	card_star = star
	if _front == null:
		return
	var path := ART + "elite/" + id
	var portrait: Texture2D = load(DATA.portrait_art_path(id))
	_front.set_shader_parameter("background_texture", load(ART + "background.png"))
	_front.set_shader_parameter("background_region", Vector4(0.0, 0.0, 1.0, 1.0))
	_front.set_shader_parameter("background_depth", -0.25)
	_front.set_shader_parameter("subject_texture", portrait)
	var visible_rect: Rect2 = _alpha_rect_cache.get(id, Rect2())
	if visible_rect.size == Vector2.ZERO:
		visible_rect = _visible_alpha_rect(portrait)
		_alpha_rect_cache[id] = visible_rect
	var texture_size := portrait.get_size()
	var source_rect := Vector4(
		visible_rect.position.x / texture_size.x,
		1.0 - (visible_rect.position.y + visible_rect.size.y) / texture_size.y,
		visible_rect.size.x / texture_size.x,
		visible_rect.size.y / texture_size.y
	)
	var source_aspect := visible_rect.size.x / visible_rect.size.y
	var card_aspect := 2.0 / 3.0
	var subject_height := 0.54
	var subject_width := subject_height * source_aspect / card_aspect
	if subject_width > 0.84:
		subject_width = 0.84
		subject_height = subject_width * card_aspect / source_aspect
	var subject_fit := Vector2(subject_width, subject_height)
	_front.set_shader_parameter("subject_source_rect", source_rect)
	_front.set_shader_parameter("subject_fit", subject_fit)
	_front.set_shader_parameter("effects_texture", load(ART + "effects.png"))
	_front.set_shader_parameter("line_texture", portrait)
	_front.set_shader_parameter("has_line", false)
	_front.set_shader_parameter("typography_texture", load(path + "_title.png"))
	_front.set_shader_parameter("safe_scale", 1.0)
	_front.set_shader_parameter("safe_offset", Vector2.ZERO)
	_front.set_shader_parameter("subject_scale", 1.0)
	_front.set_shader_parameter("subject_depth", 0.4)
	_front.set_shader_parameter("foil", 1.0 if star >= 3 else 0.5 if star == 2 else 0.0)
	_target = Vector2.ZERO if compact else DEFAULT_TILT
	if compact:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _update_render_resolution() -> void:
	if compact:
		if _viewport != null:
			_viewport.size = Vector2i(128, 192)
			_viewport.msaa_3d = Viewport.MSAA_DISABLED
			_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		return
	super._update_render_resolution()


func _visible_alpha_rect(texture: Texture2D) -> Rect2:
	var image := texture.get_image()
	if image == null:
		return Rect2(Vector2.ZERO, texture.get_size())
	if texture is AtlasTexture:
		var atlas := texture as AtlasTexture
		var atlas_size := Vector2i(atlas.atlas.get_size())
		if image.get_size() == atlas_size and image.get_size() != Vector2i(texture.get_size()):
			image = image.get_region(Rect2i(atlas.region))
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < 0.12:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2(Vector2.ZERO, texture.get_size())
	return Rect2(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _preview_input(event: InputEvent) -> void:
	if allow_drag:
		_on_stage_input(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		enlarged.emit()
		accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		enlarged.emit()
		accept_event()


func _stop_auto() -> void:
	auto_rotate = false


func _calibrate_motion() -> void:
	pass


func _unhandled_input(_event: InputEvent) -> void:
	pass

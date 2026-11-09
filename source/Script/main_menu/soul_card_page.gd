## 7.4 魂卡闪卡展示页；由 7.4 反编译参考按当前 Theme 与 snake_case 路径适配。
extends Control

const PANEL_SIZE := Vector2(1040, 720)
const DEFAULT_CAMERA_SIZE := 4.8
const RENDER_SCALE := 2.0
const MAX_RENDER_EDGE := 2048.0
const CARD_SIZE := Vector2(2.8, 4.2)
const CARD_CORNER_RADIUS := 0.09
const CARD_CORNER_SEGMENTS := 12
const MAX_TILT := Vector2(0.36, 0.65)
const DEFAULT_TILT := Vector2(-0.035, -0.15)
const BASE_THEME: Theme = preload("res://Scene/theme/bhyh_theme.tres")
const CARD_SHADER_PATH := "res://Shader/soul_card.gdshader"
const ART := "res://Art/soul_card/"
const CARDS := [
	{"name": "烈焰龙魂", "subtitle": "闪卡工坊 · 原版示例", "subject": ART + "dragon_subject.png", "line": ART + "dragon_line.png"},
	{"name": "牛魔王·鬼", "subtitle": "人间 · 牛魔谷", "subject": ART + "24.png", "line": ART + "24_line.png"},
	{"name": "阎罗王", "subtitle": "地府 · 阎罗殿", "subject": ART + "43.png", "line": ART + "43_line.png"},
	{"name": "哪吒", "subtitle": "天庭 · 三太子", "subject": ART + "102.png", "line": ART + "102_line.png"},
]

var selected_card := 0
var auto_rotate := false
var _panel: PanelContainer
var _stage: TextureRect
var _viewport: SubViewport
var _card: Node3D
var _camera: Camera3D
var _front: ShaderMaterial
var _title: Label
var _subtitle: Label
var _finish: OptionButton
var _auto_button: Button
var _motion_button: Button
var _motion_hint: Label
var _motion_enabled := OS.has_feature("android")
var _motion_ready := false
var _motion_suspended := false
var _motion_attitude := Quaternion.IDENTITY
var _motion_neutral := Vector3.ZERO
var _motion_gravity := Vector3.ZERO
var _motion_anchor := DEFAULT_TILT
var _motion_wait := 0.0
var _sliders: Dictionary = {}
var _card_buttons: Array[Button] = []
var _target := DEFAULT_TILT
var _angles := DEFAULT_TILT
var _dragging := false
var _touch_index := -1
var _elapsed := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_build_card()
	_layout_panel()
	get_viewport().size_changed.connect(_layout_panel)
	select_card(0)


func _style(bg: Color, border: Color = UiSurfaceTokens.EARTH_BORDER_WARM) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _label(text: String, font_size := 20) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _button(parent: Node, text: String, callback: Callable, node_name: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size.y = 38
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _build_ui() -> void:
	theme = BASE_THEME
	var dim := ColorRect.new()
	dim.color = UiSurfaceTokens.OVERLAY_EARTH
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel = PanelContainer.new()
	_panel.name = "SoulCardPanel"
	_panel.size = PANEL_SIZE
	_panel.add_theme_stylebox_override(
		"panel", _style(UiSurfaceTokens.EARTH_PANEL, UiSurfaceTokens.EARTH_BORDER_BRIGHT)
	)
	add_child(_panel)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	_panel.add_child(outer)
	var header := HBoxContainer.new()
	outer.add_child(header)
	var heading := _label("魂卡", 32)
	heading.add_theme_color_override("font_color", UiColorTokens.TEXT_GOLD_EARTH)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	header.add_child(_label("全息流光 · 层叠景深", 18))
	_button(header, "关闭", queue_free, "CloseButton")
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	outer.add_child(body)
	var collection := VBoxContainer.new()
	collection.custom_minimum_size.x = 158
	collection.add_theme_constant_override("separation", 12)
	body.add_child(collection)
	collection.add_child(_label("魂卡图鉴", 24))
	for index in range(CARDS.size()):
		var button := _button(collection, str(CARDS[index]["name"]), select_card.bind(index), "Card%d" % index)
		button.custom_minimum_size.y = 54
		button.toggle_mode = true
		_card_buttons.append(button)
	var note := _label("展示卡面\n拖动查看流光\n滚轮缩放", 17)
	note.add_theme_color_override("font_color", UiColorTokens.TEXT_PARCHMENT_MUTED)
	collection.add_child(note)
	var preview := VBoxContainer.new()
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(preview)
	_title = _label("", 24)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.add_child(_title)
	_subtitle = _label("", 16)
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.add_child(_subtitle)

	_stage = TextureRect.new()
	_stage.name = "CardStage"
	_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stage.custom_minimum_size = Vector2(360, 350)
	_stage.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stage.stretch_mode = TextureRect.STRETCH_SCALE
	_stage.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_stage.resized.connect(_update_render_resolution, CONNECT_DEFERRED)
	_stage.mouse_filter = Control.MOUSE_FILTER_STOP
	_stage.gui_input.connect(_on_stage_input)
	preview.add_child(_stage)
	var tools := HBoxContainer.new()
	tools.alignment = BoxContainer.ALIGNMENT_CENTER
	preview.add_child(tools)
	_button(tools, "复位", reset_view, "ResetButton")
	_auto_button = _button(tools, "自动摆动", _toggle_auto, "AutoButton")
	_auto_button.toggle_mode = true
	_motion_button = _button(tools, "体感倾斜", _toggle_motion, "MotionButton")
	_motion_button.toggle_mode = true
	_motion_button.set_pressed_no_signal(_motion_enabled)
	_motion_button.visible = OS.has_feature("android")
	_motion_hint = _label("", 15)
	_motion_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_motion_hint.visible = _motion_button.visible
	preview.add_child(_motion_hint)
	var settings := VBoxContainer.new()
	settings.custom_minimum_size.x = 240
	settings.add_theme_constant_override("separation", 7)
	body.add_child(settings)
	settings.add_child(_label("卡面材质", 24))
	_finish = OptionButton.new()
	_finish.name = "FinishSelect"
	for finish_name in ["珠光镭射", "银箔", "原画", "烫金"]:
		_finish.add_item(finish_name)
	_finish.item_selected.connect(set_finish)
	settings.add_child(_finish)
	_add_slider(settings, "镭射强度", "foil", 0, 1, 0.52)
	_add_slider(settings, "画面比例", "subject_scale", 0.7, 1.4, 1.25)
	_add_slider(settings, "主体景深", "subject_depth", 0, 0.8, 0.4)
	_add_slider(settings, "特效景深", "effects_depth", -0.5, 0.8, 0.5)
	_add_slider(settings, "底纹景深", "background_depth", -0.6, 0, -0.25)
	var hint := _label("鼠标或手指拖动卡面\n正面倾斜欣赏 · Esc 关闭", 16)
	hint.add_theme_color_override("font_color", UiColorTokens.TEXT_PARCHMENT_MUTED)
	settings.add_child(hint)
	var credit := _label("闪卡工坊 × 造梦八荒   /   RuiC Card · MIT", 15)
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credit.add_theme_color_override("font_color", UiColorTokens.TEXT_PARCHMENT_MUTED)
	outer.add_child(credit)


func _add_slider(parent: Node, title: String, parameter: String, low: float, high: float, initial: float) -> void:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := _label(title, 18)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var value := _label("%.2f" % initial, 18)
	row.add_child(value)
	var slider := HSlider.new()
	slider.name = parameter
	slider.min_value = low
	slider.max_value = high
	slider.step = 0.01
	slider.value = initial
	slider.custom_minimum_size.y = 20
	slider.value_changed.connect(
		func(v: float):
			value.text = "%.2f" % v
			_set_parameter(parameter, v)
	)
	parent.add_child(slider)
	_sliders[parameter] = slider


func _build_card() -> void:
	_viewport = SubViewport.new()
	_viewport.name = "SoulCardViewport"
	_viewport.size = Vector2i(800, 800)
	_viewport.transparent_bg = true
	_viewport.own_world_3d = true
	_viewport.handle_input_locally = false
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.msaa_3d = Viewport.MSAA_2X
	_viewport.scaling_3d_scale = 1.0
	_stage.add_child(_viewport)
	_stage.texture = _viewport.get_texture()
	_camera = Camera3D.new()
	_camera.position = Vector3(0, 0, 8)
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = DEFAULT_CAMERA_SIZE
	_viewport.add_child(_camera)
	_card = Node3D.new()

	_card.rotation_order = EULER_ORDER_XYZ
	_viewport.add_child(_card)
	var core := MeshInstance3D.new()
	core.name = "RoundedCardEdge"
	core.mesh = _build_card_edge()
	var gold := StandardMaterial3D.new()
	gold.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gold.albedo_color = UiSurfaceTokens.EARTH_BORDER_BRIGHT
	gold.cull_mode = BaseMaterial3D.CULL_DISABLED
	core.material_override = gold
	_card.add_child(core)
	_front = ShaderMaterial.new()
	_front.shader = load(CARD_SHADER_PATH) as Shader
	_front.set_shader_parameter("background_texture", load(ART + "background.png"))
	_front.set_shader_parameter("effects_texture", load(ART + "effects.png"))
	var face := MeshInstance3D.new()
	face.name = "CardFront"
	face.mesh = _build_card_face()
	face.position.z = 0.024
	face.material_override = _front
	_card.add_child(face)


func _card_outline(inset := 0.0) -> PackedVector2Array:
	var outline := PackedVector2Array()
	var half_size := CARD_SIZE * 0.5 - Vector2.ONE * inset
	var radius := CARD_CORNER_RADIUS - inset
	for corner in range(4):
		var angle := float(corner) * PI * 0.5
		var center := Vector2(half_size.x - radius, half_size.y - radius)
		if corner in [1, 2]:
			center.x = -center.x
		if corner in [2, 3]:
			center.y = -center.y
		for step in range(CARD_CORNER_SEGMENTS + 1):
			var theta := angle + float(step) / CARD_CORNER_SEGMENTS * PI * 0.5
			outline.append(center + Vector2(cos(theta), sin(theta)) * radius)
	return outline


func _build_card_face() -> ArrayMesh:
	var outline := _card_outline(0.008)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(outline.size()):
		for point in [Vector2.ZERO, outline[(index + 1) % outline.size()], outline[index]]:
			surface.set_normal(Vector3.BACK)
			surface.set_uv(Vector2(point.x / CARD_SIZE.x + 0.5, 0.5 - point.y / CARD_SIZE.y))
			surface.add_vertex(Vector3(point.x, point.y, 0))
	return surface.commit()


func _build_card_edge() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings := [_card_outline(0.008), _card_outline(), _card_outline(), _card_outline(0.008)]
	var depths := [0.024, 0.016, -0.016, -0.024]
	for ring in range(rings.size() - 1):
		var current: PackedVector2Array = rings[ring]
		var next: PackedVector2Array = rings[ring + 1]
		for index in range(current.size()):
			var following := (index + 1) % current.size()
			var a := Vector3(current[index].x, current[index].y, depths[ring])
			var b := Vector3(current[following].x, current[following].y, depths[ring])
			var c := Vector3(next[index].x, next[index].y, depths[ring + 1])
			var d := Vector3(next[following].x, next[following].y, depths[ring + 1])
			for vertex in [a, b, c, b, d, c]:
				surface.add_vertex(vertex)
	surface.generate_normals()
	return surface.commit()


func select_card(index: int) -> void:
	if index < 0 or index >= CARDS.size():
		return
	selected_card = index
	_title.text = str(CARDS[index]["name"])
	_subtitle.text = str(CARDS[index]["subtitle"])
	var subject: Texture2D = load(str(CARDS[index]["subject"]))
	var line: Texture2D = load(str(CARDS[index]["line"]))
	_front.set_shader_parameter("subject_texture", subject)
	_front.set_shader_parameter("line_texture", line)
	_front.set_shader_parameter("safe_scale", 1.12 if index == 0 else 1.0)
	_front.set_shader_parameter("safe_offset", Vector2(-0.06, -0.035) if index == 0 else Vector2.ZERO)
	_front.set_shader_parameter("typography_texture", load(ART + "title_%d.png" % index))
	for button_index in range(_card_buttons.size()):
		_card_buttons[button_index].set_pressed_no_signal(button_index == index)
	reset_view()


func set_finish(index: int) -> void:
	_finish.select(index)
	_set_parameter("finish", index)
	(_sliders["foil"] as HSlider).editable = index != 2


func _set_parameter(parameter: String, value: Variant) -> void:
	if _front != null:
		_front.set_shader_parameter(parameter, value)


func reset_view() -> void:
	_target = DEFAULT_TILT
	_camera.size = DEFAULT_CAMERA_SIZE
	_stop_auto()
	_calibrate_motion()


func _toggle_auto() -> void:
	auto_rotate = _auto_button.button_pressed
	if auto_rotate:
		_motion_enabled = false
		_motion_button.set_pressed_no_signal(false)
		_motion_hint.text = "体感已关闭"


func _toggle_motion() -> void:
	_motion_enabled = _motion_button.button_pressed
	if _motion_enabled:
		_stop_auto()
		_calibrate_motion()
	else:
		_motion_hint.text = "体感已关闭，可手指拖动"


func _calibrate_motion() -> void:
	_motion_ready = false
	_motion_attitude = Quaternion.IDENTITY
	_motion_gravity = Vector3.ZERO
	_motion_anchor = _target
	_motion_wait = 0.0
	if _motion_enabled:
		_motion_hint.text = "以当前握姿校准 · 倾斜手机查看流光"


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_motion_suspended = true
		_dragging = false
		_touch_index = -1
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_motion_suspended = false
		if is_instance_valid(_motion_hint):
			_calibrate_motion()


func _update_motion(delta: float, gravity: Vector3, gyro: Vector3, acceleration: Vector3) -> void:
	if not _motion_enabled or _motion_suspended or _dragging or auto_rotate:
		return

	var measured := gravity
	if measured.length() < 1.0:
		measured = acceleration
	if not measured.is_finite() or measured.length() < 6.0 or measured.length() > 14.0:
		_motion_wait += delta
		if _motion_wait > 1.5 and not _motion_ready:
			_motion_hint.text = "未检测到体感数据，仍可手指拖动"
		return
	var step := clampf(delta, 0.0, 0.05)
	if not _motion_ready:
		_motion_gravity = measured.normalized()
		_motion_neutral = _motion_gravity
		_motion_attitude = Quaternion.IDENTITY
		_motion_anchor = _target
		_motion_ready = true
		_motion_hint.text = "体感已开启 · 复位可重新校准"
		return
	_motion_gravity = _motion_gravity.lerp(measured.normalized(), 1.0 - exp(-8.0 * step)).normalized()
	if gyro.is_finite() and gyro.length() > 0.015:
		var speed := gyro.length()
		_motion_attitude = (_motion_attitude * Quaternion(gyro / speed, minf(speed * step, 0.15))).normalized()

	var correction := Quaternion((_motion_attitude * _motion_gravity).normalized(), _motion_neutral)
	_motion_attitude = Quaternion.IDENTITY.slerp(correction, 1.0 - exp(-3.0 * step)) * _motion_attitude
	_motion_attitude = _motion_attitude.normalized()
	var tilt := Basis(_motion_attitude).get_euler(EULER_ORDER_XYZ)
	_target = (_motion_anchor + Vector2(tilt.x, tilt.y) * 0.8).clamp(-MAX_TILT, MAX_TILT)


func _stop_auto() -> void:
	auto_rotate = false
	_auto_button.set_pressed_no_signal(false)


func _on_stage_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.device != -1:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			if event.pressed:
				_stop_auto()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var step := -0.25 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.25
			_camera.size = clampf(_camera.size + step, 4.6, 7.5)
		accept_event()
	elif event is InputEventScreenTouch and event.pressed and _touch_index == -1:
		_touch_index = event.index
		_dragging = true
		_stop_auto()
		accept_event()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _dragging and _touch_index == -1 and event.device != -1:
		_drag(event.relative)
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_drag(event.relative)
	elif (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
		and _touch_index == -1
	):
		if _dragging:
			_calibrate_motion()
		_dragging = false
	elif event is InputEventScreenTouch and not event.pressed and event.index == _touch_index:
		_touch_index = -1
		_dragging = false
		_calibrate_motion()


func _drag(relative: Vector2) -> void:
	_target.x = clampf(_target.x + relative.y * 0.004, -MAX_TILT.x, MAX_TILT.x)
	_target.y = clampf(_target.y + relative.x * 0.006, -MAX_TILT.y, MAX_TILT.y)
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	_elapsed += delta
	if _motion_enabled and not _motion_suspended:
		_update_motion(delta, Input.get_gravity(), Input.get_gyroscope(), Input.get_accelerometer())
	var target := _target
	if auto_rotate and not _dragging:
		target = Vector2(sin(_elapsed * 0.53) * 0.055 - 0.018, sin(_elapsed * 0.42) * 0.23 - 0.055)
	target = target.clamp(-MAX_TILT, MAX_TILT)
	_angles = _angles.lerp(target, 1.0 - exp(-8.0 * delta))
	_card.rotation = Vector3(_angles.x, _angles.y, 0)
	var view := _card.basis.inverse() * Vector3.FORWARD * -1.0
	_set_parameter("card_view", view)


func _layout_panel() -> void:
	var viewport_size := get_viewport_rect().size
	var fit := maxf(0.01, minf((viewport_size.x - 24.0) / PANEL_SIZE.x, (viewport_size.y - 24.0) / PANEL_SIZE.y))
	_panel.scale = Vector2(fit, fit)
	_panel.position = (viewport_size - PANEL_SIZE * fit) * 0.5
	call_deferred("_update_render_resolution")


func _update_render_resolution() -> void:
	if _viewport == null or _stage.size.x <= 0.0 or _stage.size.y <= 0.0:
		return

	var pixel_size := _stage.size * _stage.get_screen_transform().get_scale().abs()
	var render_size := pixel_size * RENDER_SCALE
	render_size *= minf(1.0, MAX_RENDER_EDGE / maxf(render_size.x, render_size.y))
	var resolution := Vector2i(maxi(2, ceili(render_size.x)), maxi(2, ceili(render_size.y)))
	if _viewport.size != resolution:
		_viewport.size = resolution

extends Node2D
const FULLSCREEN_DESIGN_SIZE := Vector2(940, 590)
const SKILL_FORMULA_DATA = preload("res://Script/skill/skill_damage_formula_data.gd")
const FORMULA_FONT = preload("res://Font/aa_wen_zheng_ming_qin_fu_xiao_kai_mianfeiziti_com.ttf")
@onready var front_bg: ColorRect = $bg/lh_pic/front_bg
@onready var _title: Label = $bg/lh_pic/front_bg/Title
@onready var lh_value: Label = $bg/lh_pic/lh_value
@onready var damage_description_button: Button = $bg/lh_pic/front_bg/damage_description

var zd_sk
var bd_sk
var is_zd: bool = false
var is_bd: bool = false
var _last_coin_num: int = -1
var _formula_overlay: ColorRect
var _formula_panel: PanelContainer
var _formula_list: VBoxContainer


func _add_centered_bd_skill() -> void:
	bd_sk = Global.add_bd_skillscene(front_bg, Vector2.ZERO)
	var table_width: float = bd_sk.size.x
	bd_sk.position = Vector2((front_bg.size.x - table_width) * 0.5, 50.0)


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
	var fit_scale = min(viewport_size.x / FULLSCREEN_DESIGN_SIZE.x, viewport_size.y / FULLSCREEN_DESIGN_SIZE.y)
	var page_size = FULLSCREEN_DESIGN_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - page_size) * 0.5


func _ready() -> void:
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	is_zd = true
	zd_sk = Global.add_zd_skillscene(front_bg, Vector2(40, 50))
	is_bd = false
	_title.text = "主动技能"
	_update_coin_value()


func _process(_delta: float) -> void:
	_update_coin_value()


func _update_coin_value() -> void:
	var coin_num: int = PlayerData.get_soul()
	if coin_num == _last_coin_num:
		return
	_last_coin_num = coin_num
	lh_value.text = str(coin_num)


func _on_zd_skill_pressed() -> void:
	is_zd = true
	is_bd = false
	_title.text = "主动技能"
	damage_description_button.visible = true
	if zd_sk == null:
		zd_sk = Global.add_zd_skillscene(front_bg, Vector2(40, 50))
	if bd_sk != null:
		bd_sk.queue_free()
		bd_sk = null


func _on_bd_skill_pressed() -> void:
	is_zd = false
	is_bd = true
	_title.text = "被动技能"
	damage_description_button.visible = false
	_close_formula_overlay()
	if bd_sk == null:
		_add_centered_bd_skill()
	if zd_sk != null:
		zd_sk.queue_free()
		zd_sk = null


func _on_close_pressed() -> void:
	queue_free()


## ESC 分层关闭：先关闭技能伤害公式浮层；主技能窗口由 HUD 协调器继续处理。
func request_escape_close() -> bool:
	if is_instance_valid(_formula_overlay):
		_close_formula_overlay()
		return true
	return false


func _on_damage_description_pressed() -> void:
	if not is_zd or zd_sk == null or not is_instance_valid(zd_sk):
		return
	if is_instance_valid(_formula_overlay):
		_close_formula_overlay()
		return
	_create_formula_overlay()


func _create_formula_overlay() -> void:
	if is_instance_valid(zd_sk):
		zd_sk.visible = false
	if is_instance_valid(bd_sk):
		bd_sk.visible = false
	_formula_overlay = ColorRect.new()
	_formula_overlay.name = "SkillFormulaOverlay"
	_formula_overlay.color = Color(0.0, 0.0, 0.0, 0.72)
	_formula_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_formula_overlay.z_index = 100
	front_bg.add_child(_formula_overlay)
	_formula_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_formula_overlay.gui_input.connect(_on_formula_overlay_gui_input)

	_formula_panel = PanelContainer.new()
	_formula_panel.name = "FormulaPanel"
	_formula_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_formula_panel.add_theme_stylebox_override("panel", _make_panel_style())
	_formula_overlay.add_child(_formula_panel)
	_formula_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_formula_panel.offset_left = 24.0
	_formula_panel.offset_top = 18.0
	_formula_panel.offset_right = -24.0
	_formula_panel.offset_bottom = -18.0

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 7)
	_formula_panel.add_child(body)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 42.0
	body.add_child(header)

	var role_id := clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 6)
	var heading := Label.new()
	heading.text = SKILL_FORMULA_DATA.get_role_name(role_id) + "技能伤害公式"
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", FORMULA_FONT)
	heading.add_theme_font_size_override("font_size", 27)
	heading.add_theme_color_override("font_color", Color(1.0, 0.78, 0.27))
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(heading)

	var close_button := Button.new()
	close_button.text = "×"
	close_button.tooltip_text = "关闭"
	close_button.custom_minimum_size = Vector2(52.0, 40.0)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_button.add_theme_font_override("font", FORMULA_FONT)
	close_button.add_theme_font_size_override("font_size", 28)
	close_button.add_theme_color_override("font_hover_color", Color(1.0, 0.55, 0.18))
	close_button.pressed.connect(_close_formula_overlay)
	header.add_child(close_button)

	var divider := HSeparator.new()
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(divider)

	var scroll := ScrollContainer.new()
	scroll.name = "FormulaScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 12
	scroll.follow_focus = true
	body.add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_right", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(margin)

	_formula_list = VBoxContainer.new()
	_formula_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_formula_list.add_theme_constant_override("separation", 8)
	_formula_list.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(_formula_list)
	_populate_formula_cards(role_id)


func _populate_formula_cards(role_id: int) -> void:
	var role_key: String = zd_sk.get_role_key()
	var skill_ids: Array = zd_sk.skill_ids_by_role.get(role_key, [])
	var skill_names: Array = zd_sk.skill_name.get(role_key, [])
	var levels := {}
	for index in range(skill_ids.size()):
		levels[str(skill_ids[index])] = int(zd_sk.get_skill_level_by_index(index))

	for index in range(skill_ids.size()):
		var skill_id := str(skill_ids[index])
		var skill_name := str(skill_names[index]) if index < skill_names.size() else skill_id
		var stored_level := int(levels.get(skill_id, 0))
		var detail: Dictionary = SKILL_FORMULA_DATA.get_skill_detail(role_id, skill_id, stored_level, levels)
		_formula_list.add_child(_make_formula_card(skill_id, skill_name, stored_level, detail))


func _make_formula_card(skill_id: String, skill_name: String, stored_level: int, detail: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_theme_stylebox_override("panel", _make_card_style())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(row)

	var icon := TextureRect.new()
	icon.name = "SkillIcon"
	icon.custom_minimum_size = Vector2(64.0, 64.0)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	var icon_path := "res://Art/skill/skill_icon/" + YutuSkillData.icon_key(skill_id) + ".png"
	if ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path) as Texture2D
	row.add_child(icon)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 3)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(content)

	var title := Label.new()
	title.text = "%s  Lv.%d  ·  %s" % [skill_name, stored_level, str(detail.get("kind", "技能效果"))]
	title.add_theme_font_override("font", FORMULA_FONT)
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", Color(1.0, 0.74, 0.24))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(title)

	var lines: Array = detail.get("lines", [])
	for line_value in lines:
		var line := Label.new()
		line.text = str(line_value)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_theme_font_override("font", FORMULA_FONT)
		line.add_theme_font_size_override("font_size", 17)
		line.add_theme_color_override("font_color", Color(0.92, 0.92, 0.88))
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(line)
	return card


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.065, 0.98)
	style.border_color = Color(0.62, 0.43, 0.16, 1.0)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 16.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 10.0
	return style


func _make_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.075, 0.095, 0.105, 0.96)
	style.border_color = Color(0.26, 0.31, 0.31, 1.0)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 8.0
	return style


func _on_formula_overlay_gui_input(event: InputEvent) -> void:
	var pressed_outside := false
	if event is InputEventMouseButton:
		pressed_outside = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	elif event is InputEventScreenTouch:
		pressed_outside = event.pressed
	var global_position: Vector2 = _formula_overlay.get_global_transform_with_canvas() * event.position
	if (
		pressed_outside
		and is_instance_valid(_formula_panel)
		and not _formula_panel.get_global_rect().has_point(global_position)
	):
		_close_formula_overlay()
		get_viewport().set_input_as_handled()


func _close_formula_overlay() -> void:
	if is_instance_valid(_formula_overlay):
		_formula_overlay.queue_free()
	if is_instance_valid(zd_sk):
		zd_sk.visible = is_zd
	if is_instance_valid(bd_sk):
		bd_sk.visible = is_bd
	_formula_overlay = null
	_formula_panel = null
	_formula_list = null

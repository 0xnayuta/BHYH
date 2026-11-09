## 7.4 魂卡/精英 UI 面板基类；38-3 的页面在此之上扩展。
## 只使用当前 Theme 与 snake_case 素材路径，不建立平行 Theme。
extends Control

const DATA := preload("res://Script/data/soul_card_data.gd")
const BASE_THEME: Theme = preload("res://Scene/theme/bhyh_theme.tres")
const ITEM_SLOT := preload("res://Art/backpack/all_items/empty.png")
const SELECTED_SLOT := preload("res://Art/backpack/dywk.png")
const PANEL_SIZE := Vector2(1040, 620)
const DIM_COLOR := UiColorTokens.OUTLINE_NIGHT
var ink_frame: NinePatchRect
var panel: PanelContainer
var outer: VBoxContainer
var heading: HBoxContainer
var notice: Label
var dim: ColorRect
static var card_icon_cache: Dictionary = {}


func build_panel(title_text: String) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = BASE_THEME
	dim = ColorRect.new()
	dim.name = "ScreenDim"
	dim.color = DIM_COLOR
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	panel = PanelContainer.new()
	panel.name = "MainPanel"
	panel.size = PANEL_SIZE
	panel.add_theme_stylebox_override("panel", panel_style())
	add_child(panel)
	outer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	panel.add_child(outer)
	heading = HBoxContainer.new()
	outer.add_child(heading)
	var title := label(title_text, 30)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	var close := button(heading, "×", queue_free)
	close.name = "Close"
	close.custom_minimum_size = Vector2(41, 41)
	get_viewport().size_changed.connect(layout)
	panel.minimum_size_changed.connect(layout)
	call_deferred("layout")


func label(value: String, font_size: int = 19) -> Label:
	var result := Label.new()
	result.text = value
	result.add_theme_color_override("font_color", UiColorTokens.TEXT_GOLD_EARTH)
	result.add_theme_font_size_override("font_size", font_size)
	return result


func button(parent: Node, value: String, callback: Callable) -> Button:
	var result := Button.new()
	result.text = value
	result.custom_minimum_size = Vector2(70, 38)
	result.pressed.connect(callback)
	parent.add_child(result)
	return result


func detail_box(parent: Node) -> RichTextLabel:
	var result := RichTextLabel.new()
	result.bbcode_enabled = true
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result.add_theme_color_override("default_color", UiColorTokens.TEXT_PARCHMENT)
	parent.add_child(result)
	return result


func layout() -> void:
	if panel == null:
		return
	panel.size = PANEL_SIZE
	var viewport_size := get_viewport_rect().size
	position = Vector2.ZERO
	size = viewport_size
	dim.position = Vector2.ZERO
	dim.size = viewport_size
	var fit := minf(1.0, minf((viewport_size.x - 16.0) / PANEL_SIZE.x, (viewport_size.y - 16.0) / PANEL_SIZE.y))
	panel.scale = Vector2.ONE * maxf(0.1, fit)
	panel.position = (viewport_size - PANEL_SIZE * fit) * 0.5


func in_battle() -> bool:
	return get_tree().current_scene is BaseLevel


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()


static func texture_style(texture: Texture2D, margin: float = 6.0) -> StyleBoxTexture:
	var result := StyleBoxTexture.new()
	result.texture = texture
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		result.set_texture_margin(side, margin)
		result.set_content_margin(side, margin)
	return result


static func panel_style() -> StyleBox:
	var style := BASE_THEME.get_stylebox("panel", "PanelContainer")
	return style.duplicate() if style != null else StyleBoxEmpty.new()


static func slot_button(parent: Node, callback: Callable) -> Button:
	var result := Button.new()
	result.custom_minimum_size = Vector2(50, 50)
	result.size = Vector2(50, 50)
	result.expand_icon = true
	result.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.add_theme_constant_override("icon_max_width", 46)
	for state in ["normal", "pressed", "hover", "disabled", "focus"]:
		var box := texture_style(ITEM_SLOT, 0.0)
		result.add_theme_stylebox_override(state, box)
	var selected := NinePatchRect.new()
	selected.name = "Selected"
	selected.texture = SELECTED_SLOT
	selected.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selected.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selected.draw_center = false
	selected.patch_margin_left = 7
	selected.patch_margin_right = 7
	selected.patch_margin_top = 7
	selected.patch_margin_bottom = 7
	selected.visible = false
	result.add_child(selected)
	var badge := Label.new()
	badge.name = "Star"
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	badge.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	badge.add_theme_font_size_override("font_size", UiFontSizes.FONT_SIZE_12)
	badge.add_theme_color_override("font_color", UiColorTokens.TEXT_GOLD_EARTH)
	badge.add_theme_color_override("font_outline_color", UiColorTokens.INK)
	badge.add_theme_constant_override("outline_size", 3)
	result.add_child(badge)
	result.pressed.connect(callback)
	parent.add_child(result)
	return result


static func project_theme() -> Theme:
	return BASE_THEME


static func card_icon(id: String) -> Texture2D:
	if not card_icon_cache.has(id):
		card_icon_cache[id] = load(DATA.portrait_path(id))
	return card_icon_cache[id]

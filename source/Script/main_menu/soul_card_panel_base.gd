## 7.4 魂卡/精英 UI 面板基类；38-3 的页面在此之上扩展。
## 本批只提供布局、主题与数据读取骨架，视觉细化由 Theme 变体与 38-3 页面完成。
extends Control

const DATA := preload("res://Script/data/soul_card_data.gd")
const BASE_THEME: Theme = preload("res://Scene/theme/bhyh_theme.tres")
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
	add_child(panel)
	outer = VBoxContainer.new()
	panel.add_child(outer)
	heading = HBoxContainer.new()
	outer.add_child(heading)
	var title := label(title_text)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	var close := button(heading, "×", queue_free)
	close.custom_minimum_size = Vector2(41, 41)
	get_viewport().size_changed.connect(layout)
	panel.minimum_size_changed.connect(layout)
	call_deferred("layout")


func label(value: String) -> Label:
	var result := Label.new()
	result.text = value
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


static func project_theme() -> Theme:
	return BASE_THEME


static func panel_style() -> StyleBox:
	var style := BASE_THEME.get_stylebox("panel", "PanelContainer")
	return style if style != null else StyleBoxEmpty.new()


static func slot_button(parent: Node, callback: Callable) -> Button:
	var result := Button.new()
	result.custom_minimum_size = Vector2(50, 50)
	result.size = Vector2(50, 50)
	result.expand_icon = true
	result.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.pressed.connect(callback)
	parent.add_child(result)
	return result


static func card_icon(id: String) -> Texture2D:
	if not card_icon_cache.has(id):
		card_icon_cache[id] = load(DATA.portrait_path(id))
	return card_icon_cache[id]

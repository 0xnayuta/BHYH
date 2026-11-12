extends Control

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var title: Label = $MarginContainer/MarginContainer/VBoxContainer/title
@onready var color_rect: ColorRect = $ColorRect
@onready var margin_container: MarginContainer = $MarginContainer

@onready var _name: Label = $MarginContainer/MarginContainer/VBoxContainer/name
@onready var lx: Label = $MarginContainer/MarginContainer/VBoxContainer/lx
@onready var pz: Label = $MarginContainer/MarginContainer/VBoxContainer/pz
@onready var ms: Label = $MarginContainer/MarginContainer/VBoxContainer/VBoxContainer/ms
@onready var sl: Label = $MarginContainer/MarginContainer/VBoxContainer/sl
@onready var sj: Label = $MarginContainer/MarginContainer/VBoxContainer/VBoxContainer/sj
var my_name
var is_set = false
var _anchor := Vector2.ZERO
var _has_anchor := false

const TOOLTIP_MIN_WIDTH := 240.0
const TOOLTIP_MAX_WIDTH := 360.0
const TOOLTIP_SIDE_PADDING := 12.0
const TOOLTIP_TEXT_GAP := 12.0


func _get_display_name():
	var name1 = my_name
	return name1


func _ready() -> void:
	self.modulate = Color(1, 1, 1, 0)
	call_deferred("_capture_initial_anchor")


func _capture_initial_anchor() -> void:
	if _has_anchor:
		return
	_anchor = position
	_has_anchor = true
	_apply_layout()


func layout_at(anchor: Vector2) -> void:
	_anchor = anchor
	_has_anchor = true
	_apply_layout()


func _apply_layout() -> void:
	if not _has_anchor:
		return
	var rect := Rect2(color_rect.position, color_rect.size)
	if margin_container != null:
		rect = rect.merge(Rect2(margin_container.position, margin_container.size))
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	PopupLayout.place_parent_anchor(self, _anchor, rect.size, PopupLayout.DEFAULT_MARGIN, true, rect.position)


func _fit_content_width() -> void:
	if margin_container == null or ms == null:
		return
	var target_width := TOOLTIP_MIN_WIDTH
	if not ms.text.strip_edges().is_empty():
		var font := ms.get_theme_font(&"font")
		var font_size := ms.get_theme_font_size(&"font_size")
		if font != null:
			var text_width := font.get_string_size(ms.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			target_width = clampf(
				text_width + TOOLTIP_SIDE_PADDING * 2.0 + TOOLTIP_TEXT_GAP, TOOLTIP_MIN_WIDTH, TOOLTIP_MAX_WIDTH
			)
	margin_container.custom_minimum_size.x = target_width


func _physics_process(_delta: float) -> void:
	color_rect.size = margin_container.size
	if is_set == false:
		create_tween().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
		set_color()
		_name.text = "名称：" + str(EquipmentService.data(_get_display_name())[DataKeys.NAME])
		lx.text = "类型：" + str(EquipmentService.data(_get_display_name())[DataKeys.TYPE])
		pz.text = "品质：" + str(EquipmentService.data(_get_display_name())[DataKeys.QUALITY])
		if str(EquipmentService.data(_get_display_name())[DataKeys.TYPE]) == "消耗品":
			sl.text = "拥有：" + str(PlayerData.get_xhp_data(_get_display_name())) + " 个"
		else:
			sl.text = "拥有：" + str(PlayerData.get_item_data(_get_display_name())) + " 个"
		ms.text = UiTextFormat.description(str(EquipmentService.data(_get_display_name())["描述"]))
		sj.text = UiTextFormat.price(EquipmentService.data(_get_display_name())["售价"])
		_fit_content_width()
		is_set = true
	_apply_layout()


func set_color():
	if str(EquipmentService.data(_get_display_name()).get(DataKeys.QUALITY, "")) == "黑神话":
		_apply_black_myth_text_style(_name)
		_apply_black_myth_text_style(pz)
		return
	_name.add_theme_color_override("font_color", EquipmentService.data(_get_display_name())["颜色"])
	pz.add_theme_color_override("font_color", EquipmentService.data(_get_display_name())["颜色"])


func _apply_black_myth_text_style(label: Label) -> void:
	label.add_theme_color_override("font_color", UiColorTokens.TEXT_DANGER_DEEP)

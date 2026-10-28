extends Control
class_name ZhenYaoTower

const STAGE_SIZE := Vector2(941.0, 591.0)

@export var max_floor: int = 1
@export var current_points: int = 0

const TOWER_CURRENT_FLOOR_KEY := "镇妖塔当前层数"
const TOWER_MAX_FLOOR_KEY := "镇妖塔最高层数"
const TOWER_POINTS_KEY := "镇妖塔积分"
const TOWER_RUN_POINTS_KEY := "镇妖塔本次闯关积分"
const TOWER_ACHIEVEMENT_PURCHASE_KEY := "镇妖塔成就商店觉醒石已购次数"
const TOWER_LEVEL_SCENE_PATH := "res://Scene/level/level_zhen_yao_tower.tscn"
const TOWER_LEVEL_SCRIPT := preload("res://Script/level/level_zhen_yao_tower.gd")
const TOWER_FONT := preload("res://Font/aa_wen_zheng_ming_qin_fu_xiao_kai_mianfeiziti_com.ttf")
const TOWER_MATERIAL_IDS := [
	"105000012",
	"105000013",
	"105000014",
	"105000015",
	"105000016",
	"105000017",
	"105000018",
	"105000019",
	"105000020",
	"105000021",
	"105000022",
	"105000023",
]
const TOWER_MATERIAL_PRICES := [
	3000,
	3000,
	3000,
	3000,
	6000,
	6000,
	6000,
	6000,
	9000,
	9000,
	9000,
	9000,
]
const TOWER_AWAKENING_STONE_ID := "tjs"
const TOWER_AWAKENING_STONE_PRICE := 1
const TOWER_AWAKENING_STONE_LIMIT := 15
const TOWER_STRENGTH_STONE_IDS := ["qhs_1", "qhs_2", "qhs_3", "qhs_4"]
const TOWER_STRENGTH_STONE_PRICES := [100, 200, 300, 400]
const TOWER_STRENGTH_STONE_REQUIRED_FLOOR := 50
const TOWER_ACHIEVEMENT_AWAKENING_STONE_PRICE := 10000
const TOWER_ACHIEVEMENT_SKILL_BOOK_ID := "1_jns"
const TOWER_ACHIEVEMENT_SKILL_BOOK_PRICE := 10000

@onready var _stage: Control = $Stage
@onready var _max_floor_label: Label = $Stage/MaxFloorLabel
@onready var _points_label: Label = $Stage/PointsLabel
@onready var _floor_selector: Control = $Stage/FloorSelector
@onready var _floor_title: Label = $Stage/FloorSelector/Panel/Content/FloorTitle
@onready var _floor_input: LineEdit = $Stage/FloorSelector/Panel/Content/FloorPicker/FloorInput
@onready var _floor_selector_close: Button = $Stage/FloorSelector/Panel/Content/CloseSelector
@onready
var _tower_difficulty_button: Button = $Stage/FloorSelector/Panel/Content/TowerOptions/DifficultyRow/DifficultyButton
@onready var _tower_count_button: Button = $Stage/FloorSelector/Panel/Content/TowerOptions/CountRow/CountButton
@onready var _tower_speed_button: Button = $Stage/FloorSelector/Panel/Content/TowerOptions/SpeedRow/SpeedButton
@onready var _tower_auto_next_button: Button = $Stage/FloorSelector/Panel/Content/TowerOptions/AutoNextRow/AutoNextButton

var _updating_floor_input := false
var _shop_overlay: Control = null
var _shop_points_label: Label = null
var _shop_scroll: ScrollContainer = null
var _shop_touch_active := false
var _shop_touch_last_y := 0.0
var _shop_item_rows: Dictionary = {}
const TOWER_SPEED_VALUES := [1.2, 0.6, 0.3, 0.15, 0.075]
const TOWER_SPEED_LABELS := ["×1", "×2", "×4", "×8", "×16"]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 4095
	_layout_stage()
	if not get_viewport().size_changed.is_connected(_layout_stage):
		get_viewport().size_changed.connect(_layout_stage)
	_refresh_stats()


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_layout_stage):
		get_viewport().size_changed.disconnect(_layout_stage)


func _layout_stage() -> void:
	if _stage == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	_stage.scale = Vector2.ONE
	_stage.position = (viewport_size - STAGE_SIZE) * 0.5


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(_shop_overlay):
			_close_shop()
			return
		if _floor_selector != null and _floor_selector.visible:
			_on_floor_selector_close_pressed()
			return
		queue_free()


func _input(event: InputEvent) -> void:
	if is_instance_valid(_shop_overlay):
		if event.is_action_pressed("ui_cancel"):
			_close_shop()
			get_viewport().set_input_as_handled()
		_handle_shop_touch_input(event)
		return
	if _floor_selector == null or not _floor_selector.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_floor_selector_close_pressed()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _floor_selector_close != null and _floor_selector_close.get_global_rect().has_point(event.position):
			_on_floor_selector_close_pressed()
			get_viewport().set_input_as_handled()


func _on_close_pressed() -> void:
	queue_free()


func _refresh_stats() -> void:
	max_floor = maxi(1, int(PlayerData.player_data.get(TOWER_MAX_FLOOR_KEY, max_floor)))
	current_points = maxi(0, int(PlayerData.player_data.get(TOWER_POINTS_KEY, current_points)))
	if _max_floor_label != null:
		_max_floor_label.text = "最高层数 %d" % max_floor
	if _points_label != null:
		_points_label.text = "当前积分 %d" % current_points


func _show_unavailable(feature_name: String) -> void:
	if Global != null and Global.has_method("add_message_show"):
		Global.add_message_show(self, "%s暂未开放" % feature_name, 1.2, Vector2(470, 300))


func _on_achievement_shop_pressed() -> void:
	_show_shop("achievement")


func _on_challenge_pressed() -> void:
	_show_floor_selector()


func _show_floor_selector() -> void:
	if not PlayerData.player_data.has(TOWER_CURRENT_FLOOR_KEY):
		PlayerData.player_data[TOWER_CURRENT_FLOOR_KEY] = 1
	if not PlayerData.player_data.has(TOWER_MAX_FLOOR_KEY):
		PlayerData.player_data[TOWER_MAX_FLOOR_KEY] = 1
	if not PlayerData.player_data.has(TOWER_POINTS_KEY):
		PlayerData.player_data[TOWER_POINTS_KEY] = 0
	var highest_floor := _highest_unlocked_floor()
	_floor_title.text = "选择挑战层数（1 - %d）" % highest_floor
	var current_floor := clampi(int(PlayerData.player_data.get(TOWER_CURRENT_FLOOR_KEY, 1)), 1, highest_floor)
	_set_floor_input(current_floor)
	_floor_selector.visible = true
	_refresh_tower_options()
	_floor_input.grab_focus()
	_floor_input.select_all()


func _highest_unlocked_floor() -> int:
	return maxi(1, int(PlayerData.player_data.get(TOWER_MAX_FLOOR_KEY, max_floor)))


func _set_floor_input(floor_number: int) -> void:
	if _floor_input == null:
		return
	_updating_floor_input = true
	_floor_input.text = str(clampi(floor_number, 1, _highest_unlocked_floor()))
	_floor_input.caret_column = _floor_input.text.length()
	_updating_floor_input = false


func _read_floor_input() -> int:
	if _floor_input == null:
		return 1
	var floor_number := 1
	var input_text := _floor_input.text.strip_edges()
	if input_text.is_valid_int():
		floor_number = int(input_text)
	return clampi(floor_number, 1, _highest_unlocked_floor())


func _on_floor_input_text_changed(new_text: String) -> void:
	if _updating_floor_input or _floor_input == null:
		return
	var filtered_text := ""
	for character in new_text:
		if "0123456789".contains(character):
			filtered_text += character
	if not filtered_text.is_empty() and filtered_text.is_valid_int():
		filtered_text = str(mini(int(filtered_text), _highest_unlocked_floor()))
	if filtered_text != new_text:
		_updating_floor_input = true
		_floor_input.text = filtered_text
		_floor_input.caret_column = filtered_text.length()
		_updating_floor_input = false


func _on_floor_step_pressed(step: int) -> void:
	_set_floor_input(_read_floor_input() + step)
	_floor_input.grab_focus()


func _on_floor_input_submitted(_text: String) -> void:
	_on_start_floor_pressed()


func _on_start_floor_pressed() -> void:
	_on_floor_selected(_read_floor_input())


func _on_floor_selected(floor_number: int) -> void:
	PlayerData.player_data[TOWER_CURRENT_FLOOR_KEY] = clampi(floor_number, 1, _highest_unlocked_floor())
	PlayerData.player_data[TOWER_RUN_POINTS_KEY] = 0
	PlayerData.player_data["Map_num"] = 0
	TOWER_LEVEL_SCRIPT.prepare_floor_plan(int(PlayerData.player_data[TOWER_CURRENT_FLOOR_KEY]))
	MemoryClass.request_save("tower_floor_select")
	Global.change_scene(TOWER_LEVEL_SCENE_PATH)


func _on_floor_selector_close_pressed() -> void:
	if _floor_selector != null:
		_floor_selector.visible = false
	if _floor_input != null:
		_floor_input.release_focus()


func _on_floor_selector_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_floor_selector_close_pressed()


func _on_points_shop_pressed() -> void:
	_show_shop("points")


func _make_shop_style(background: Color, border: Color, border_width: int = 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 6.0
	style.content_margin_top = 4.0
	style.content_margin_right = 6.0
	style.content_margin_bottom = 4.0
	return style


func _style_shop_label(label: Label, font_size: int = 17) -> void:
	label.add_theme_font_override("font", TOWER_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(1.0, 0.933333, 0.713726, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.0901961, 0.0470588, 0.0235294, 1.0))
	label.add_theme_constant_override("outline_size", 2)


func _style_shop_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", TOWER_FONT)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color(1.0, 0.933333, 0.713726, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 0.901961, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.968627, 0.815686, 1.0))
	button.add_theme_color_override("font_outline_color", Color(0.0901961, 0.0470588, 0.0235294, 1.0))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_stylebox_override(
		"normal", _make_shop_style(Color(0.219608, 0.137255, 0.094118, 0.94), Color(0.752941, 0.611765, 0.337255, 1.0))
	)
	button.add_theme_stylebox_override(
		"pressed", _make_shop_style(Color(0.490196, 0.313725, 0.164706, 1.0), Color(1.0, 0.941176, 0.635294, 1.0))
	)
	button.add_theme_stylebox_override(
		"hover", _make_shop_style(Color(0.376471, 0.239216, 0.12549, 0.98), Color(1.0, 0.85098, 0.478431, 1.0))
	)


func _show_shop(mode: String) -> void:
	if _floor_selector != null:
		_floor_selector.visible = false
	_close_shop()

	_shop_overlay = Control.new()
	_shop_overlay.name = "TowerShopOverlay"
	_shop_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shop_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_shop_overlay.z_index = 30
	_stage.add_child(_shop_overlay)

	var dimmer := ColorRect.new()
	dimmer.name = "Dimmer"
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0352941, 0.0196078, 0.0117647, 0.52)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	dimmer.gui_input.connect(_on_shop_dimmer_gui_input)
	_shop_overlay.add_child(dimmer)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.position = Vector2(98.0, 34.0)
	panel.size = Vector2(745.0, 523.0)
	panel.add_theme_stylebox_override(
		"panel",
		_make_shop_style(Color(0.137255, 0.0862745, 0.054902, 0.98), Color(0.752941, 0.611765, 0.337255, 1.0), 3)
	)
	_shop_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 40)
	content.add_child(header)
	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.text = "积分商城" if mode == "points" else "成就商店"
	_style_shop_label(title, 22)
	header.add_child(title)
	_shop_points_label = Label.new()
	_shop_points_label.custom_minimum_size = Vector2(175, 0)
	_shop_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_shop_points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_shop_label(_shop_points_label, 17)
	header.add_child(_shop_points_label)
	var close_button := Button.new()
	close_button.custom_minimum_size = Vector2(72, 36)
	close_button.text = "关闭"
	_style_shop_button(close_button)
	close_button.pressed.connect(_close_shop)
	header.add_child(close_button)

	if mode == "points":
		var hint := Label.new()
		hint.custom_minimum_size = Vector2(0, 28)
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint.text = "炼体残卷：子丑寅卯3000，辰巳午未6000，申酉戌亥9000积分"
		_style_shop_label(hint, 16)
		content.add_child(hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 8
	scroll.follow_focus = false
	content.add_child(scroll)
	_shop_scroll = scroll
	var grid := GridContainer.new()
	grid.columns = 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)

	_shop_item_rows.clear()
	if mode == "points":
		for index in range(TOWER_MATERIAL_IDS.size()):
			var item_id: String = TOWER_MATERIAL_IDS[index]
			grid.add_child(_create_shop_item_row(item_id, int(TOWER_MATERIAL_PRICES[index]), -1, true))
	else:
		grid.add_child(
			_create_shop_item_row(TOWER_AWAKENING_STONE_ID, TOWER_ACHIEVEMENT_AWAKENING_STONE_PRICE, -1, true, 0)
		)
		grid.add_child(
			_create_shop_item_row(TOWER_ACHIEVEMENT_SKILL_BOOK_ID, TOWER_ACHIEVEMENT_SKILL_BOOK_PRICE, -1, true)
		)
		var strength_unlock_hint := Label.new()
		strength_unlock_hint.custom_minimum_size = Vector2(0, 28)
		strength_unlock_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		strength_unlock_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		strength_unlock_hint.text = "强化石通关50层解锁，可输入数量且不限购"
		_style_shop_label(strength_unlock_hint, 16)
		grid.add_child(strength_unlock_hint)
		for index in range(TOWER_STRENGTH_STONE_IDS.size()):
			var item_id: String = TOWER_STRENGTH_STONE_IDS[index]
			grid.add_child(
				_create_shop_item_row(
					item_id, int(TOWER_STRENGTH_STONE_PRICES[index]), -1, true, TOWER_STRENGTH_STONE_REQUIRED_FLOOR
				)
			)
	_refresh_shop()


func _create_shop_item_row(
	item_id: String,
	price: int,
	purchase_limit: int,
	show_quantity: bool = false,
	required_cleared_floor: int = 0,
	required_level_name: String = ""
) -> Control:
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(0.0, 60.0)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_stylebox_override(
		"panel", _make_shop_style(Color(0.219608, 0.137255, 0.094118, 0.7), Color(0.490196, 0.313725, 0.164706, 1.0))
	)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 4)
	row.add_child(line)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(42.0 if show_quantity else 46.0, 46.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var data: Dictionary = AE.all_equipment.get(item_id, {}) as Dictionary
	var icon_path := str(data.get("图标", "res://Art/backpack/all_items/%s.png" % item_id))
	icon.texture = load(icon_path) as Texture2D
	line.add_child(icon)

	var name_label := Label.new()
	name_label.custom_minimum_size = Vector2(66.0 if show_quantity else 92.0, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.text = str(data.get(DataKeys.NAME, item_id))
	name_label.tooltip_text = str(data.get("描述", name_label.text))
	_style_shop_label(name_label, 15)
	line.add_child(name_label)

	var price_label := Label.new()
	price_label.custom_minimum_size = Vector2(50.0 if show_quantity else 56.0, 0)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price_label.text = "%d积分" % price
	_style_shop_label(price_label, 14)
	line.add_child(price_label)

	var count_label := Label.new()
	count_label.custom_minimum_size = Vector2(34.0 if show_quantity else 44.0, 0)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_shop_label(count_label, 13)
	line.add_child(count_label)

	var quantity_input: LineEdit = null
	if show_quantity:
		var quantity_controls := HBoxContainer.new()
		quantity_controls.name = "QuantityControls"
		quantity_controls.add_theme_constant_override("separation", 2)

		var decrease_button := Button.new()
		decrease_button.custom_minimum_size = Vector2(28.0, 38.0)
		decrease_button.text = "-"
		decrease_button.tooltip_text = "减少购买数量"
		_style_shop_button(decrease_button)
		quantity_controls.add_child(decrease_button)

		quantity_input = LineEdit.new()
		quantity_input.name = "QuantityInput"
		quantity_input.custom_minimum_size = Vector2(58.0, 38.0)
		quantity_input.text = "1"
		quantity_input.max_length = 4
		quantity_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
		quantity_input.tooltip_text = "购买数量（1-9999）"
		quantity_input.add_theme_font_override("font", TOWER_FONT)
		quantity_input.add_theme_font_size_override("font_size", 14)
		quantity_input.add_theme_color_override("font_color", Color(1.0, 0.933333, 0.713726, 1.0))
		quantity_input.add_theme_color_override("caret_color", Color(1.0, 0.85098, 0.478431, 1.0))
		quantity_input.add_theme_stylebox_override(
			"normal",
			_make_shop_style(Color(0.0901961, 0.054902, 0.0313725, 0.94), Color(0.490196, 0.313725, 0.164706, 1.0))
		)
		quantity_controls.add_child(quantity_input)

		var increase_button := Button.new()
		increase_button.custom_minimum_size = Vector2(28.0, 38.0)
		increase_button.text = "+"
		increase_button.tooltip_text = "增加购买数量"
		_style_shop_button(increase_button)
		quantity_controls.add_child(increase_button)

		decrease_button.pressed.connect(_change_shop_quantity.bind(quantity_input, -1))
		increase_button.pressed.connect(_change_shop_quantity.bind(quantity_input, 1))
		line.add_child(quantity_controls)

	var buy_button := Button.new()
	buy_button.custom_minimum_size = Vector2(54.0 if show_quantity else 58.0, 38.0)
	buy_button.text = "购买"
	_style_shop_button(buy_button)
	buy_button.pressed.connect(
		_purchase_shop_item.bind(
			item_id, price, purchase_limit, quantity_input, required_cleared_floor, required_level_name
		)
	)
	line.add_child(buy_button)

	_shop_item_rows[item_id] = {
		"count": count_label,
		"button": buy_button,
		"limit": purchase_limit,
		"quantity": quantity_input,
		"required_cleared_floor": required_cleared_floor,
		"required_level_name": required_level_name,
	}
	return row


func _item_count(item_id: String) -> int:
	var total := 0
	var pages: Variant = PlayerData.player_data.get(DataKeys.ITEM_LIST, {})
	if not pages is Dictionary:
		return 0
	for page_value in (pages as Dictionary).values():
		if not page_value is Array:
			continue
		for item_value in page_value:
			if item_value is Dictionary and str(item_value.get(DataKeys.NAME, "")) == item_id:
				total += int(item_value.get(DataKeys.COUNT, 0))
	return total


func _read_shop_quantity(quantity_input: LineEdit) -> int:
	if quantity_input == null or not is_instance_valid(quantity_input):
		return 1
	var input_text: String = quantity_input.text.strip_edges()
	var quantity := 1
	if input_text.is_valid_int():
		quantity = int(input_text)
	quantity = clampi(quantity, 1, 9999)
	quantity_input.text = str(quantity)
	quantity_input.caret_column = quantity_input.text.length()
	return quantity


func _change_shop_quantity(quantity_input: LineEdit, amount: int) -> void:
	if quantity_input == null or not is_instance_valid(quantity_input):
		return
	var quantity := clampi(_read_shop_quantity(quantity_input) + amount, 1, 9999)
	quantity_input.text = str(quantity)
	quantity_input.caret_column = quantity_input.text.length()
	quantity_input.grab_focus()


func _has_cleared_tower_floor(floor_number: int) -> bool:
	return int(PlayerData.player_data.get(TOWER_MAX_FLOOR_KEY, 1)) > floor_number


func _has_cleared_level(level_name: String) -> bool:
	return int(PlayerData.player_data.get(level_name, 0)) > 0


func _handle_shop_touch_input(event: InputEvent) -> void:
	if _shop_scroll == null or not is_instance_valid(_shop_scroll):
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_shop_touch_active = _shop_scroll.get_global_rect().has_point(event.position)
			_shop_touch_last_y = event.position.y
		else:
			_shop_touch_active = false
	elif event is InputEventScreenDrag and _shop_touch_active:
		var delta_y: float = event.position.y - _shop_touch_last_y
		_shop_scroll.scroll_vertical = maxi(0, _shop_scroll.scroll_vertical - roundi(delta_y))
		_shop_touch_last_y = event.position.y
		get_viewport().set_input_as_handled()


func _refresh_shop() -> void:
	if not is_instance_valid(_shop_overlay):
		return
	var points := maxi(0, int(PlayerData.player_data.get(TOWER_POINTS_KEY, 0)))
	if _shop_points_label != null:
		_shop_points_label.text = "镇妖塔积分：%d" % points
	for item_id in _shop_item_rows.keys():
		var row: Dictionary = _shop_item_rows[item_id]
		var count_label: Label = row.get("count") as Label
		var buy_button: Button = row.get("button") as Button
		var purchase_limit := int(row.get("limit", -1))
		var required_cleared_floor := int(row.get("required_cleared_floor", 0))
		var required_level_name := str(row.get("required_level_name", ""))
		var is_unlocked := (
			(required_cleared_floor <= 0 or _has_cleared_tower_floor(required_cleared_floor))
			and (required_level_name == "" or _has_cleared_level(required_level_name))
		)
		var current_count := _item_count(str(item_id))
		if purchase_limit > 0:
			var bought := clampi(
				int(PlayerData.player_data.get(TOWER_ACHIEVEMENT_PURCHASE_KEY, 0)), 0, TOWER_AWAKENING_STONE_LIMIT
			)
			if count_label != null:
				count_label.text = "剩%d" % (TOWER_AWAKENING_STONE_LIMIT - bought)
			if buy_button != null:
				buy_button.disabled = not is_unlocked or bought >= purchase_limit
		else:
			if count_label != null:
				count_label.text = "有%d" % current_count if is_unlocked else "未解锁"
			if buy_button != null:
				buy_button.disabled = not is_unlocked


func _purchase_shop_item(
	item_id: String,
	price: int,
	purchase_limit: int,
	quantity_input: LineEdit = null,
	required_cleared_floor: int = 0,
	required_level_name: String = ""
) -> void:
	if not is_instance_valid(_shop_overlay) or not AE.all_equipment.has(item_id):
		return
	if required_cleared_floor > 0 and not _has_cleared_tower_floor(required_cleared_floor):
		_show_shop_message("需要通关镇妖塔%d层" % required_cleared_floor)
		return
	if required_level_name != "" and not _has_cleared_level(required_level_name):
		_show_shop_message("需要先通关%s" % required_level_name)
		return
	var quantity := 1
	if quantity_input != null and is_instance_valid(quantity_input):
		quantity = _read_shop_quantity(quantity_input)
	if purchase_limit > 0:
		var bought := int(PlayerData.player_data.get(TOWER_ACHIEVEMENT_PURCHASE_KEY, 0))
		if bought >= purchase_limit:
			_show_shop_message("该商品已达到限购次数")
			return
		var remaining := purchase_limit - bought
		if quantity > remaining:
			if quantity_input != null and is_instance_valid(quantity_input):
				quantity_input.text = str(remaining)
			_show_shop_message("最多还能购买%d个" % remaining)
			return
	var total_price := price * quantity
	var points := maxi(0, int(PlayerData.player_data.get(TOWER_POINTS_KEY, 0)))
	if points < total_price:
		_show_shop_message("镇妖塔积分不足")
		return
	if PlayerData.get_dj_page(item_id) == 0 and int(PlayerData.check_can_use_page("道具列表")) == 0:
		_show_shop_message("道具背包已满")
		return
	PlayerData.player_data[TOWER_POINTS_KEY] = points - total_price
	PlayerData.add_dj(item_id, quantity)
	if purchase_limit > 0:
		PlayerData.player_data[TOWER_ACHIEVEMENT_PURCHASE_KEY] = (
			int(PlayerData.player_data.get(TOWER_ACHIEVEMENT_PURCHASE_KEY, 0)) + quantity
		)
	_save_tower_data()
	_refresh_stats()
	_refresh_shop()
	_show_shop_message("购买成功：%d个" % quantity)


func _show_shop_message(message: String) -> void:
	if Global != null and Global.has_method("add_message_show"):
		Global.add_message_show(self, message, 1.2, Vector2.ZERO)


func _save_tower_data() -> void:
	var save_path := str(Global.cd_path)
	if save_path != "" and save_path.contains("Ar_"):
		MemoryClass.request_save("tower_data")


func _close_shop() -> void:
	if is_instance_valid(_shop_overlay):
		_shop_overlay.queue_free()
	_shop_overlay = null
	_shop_points_label = null
	_shop_scroll = null
	_shop_touch_active = false
	_shop_item_rows.clear()


func _on_shop_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_close_shop()


func _on_tower_difficulty_pressed() -> void:
	var difficulty := (int(MainSet.set_data.get("Difficult", 0)) + 1) % 3
	MainSet.set_data["Difficult"] = difficulty
	_refresh_tower_options()
	MemoryClass.main_bc()


func _on_tower_count_pressed() -> void:
	var count := clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	MainSet.set_data["CreateMonsterCount"] = 1 if count >= 5 else count + 1
	_refresh_tower_options()
	MemoryClass.main_bc()


func _on_tower_speed_pressed() -> void:
	var current_speed := float(MainSet.set_data.get("CreateMonsterSpeed", TOWER_SPEED_VALUES[0]))
	var speed_index := 0
	for index in range(TOWER_SPEED_VALUES.size()):
		if is_equal_approx(current_speed, float(TOWER_SPEED_VALUES[index])):
			speed_index = index
			break
	speed_index = (speed_index + 1) % TOWER_SPEED_VALUES.size()
	MainSet.set_data["CreateMonsterSpeed"] = TOWER_SPEED_VALUES[speed_index]
	_refresh_tower_options()
	MemoryClass.main_bc()


func _on_tower_auto_next_pressed() -> void:
	MainSet.set_data["镇妖塔自动下一层"] = not bool(MainSet.set_data.get("镇妖塔自动下一层", false))
	_refresh_tower_options()
	MemoryClass.main_bc()


func _refresh_tower_options() -> void:
	var difficulty := clampi(int(MainSet.set_data.get("Difficult", 0)), 0, 2)
	var count := clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	var current_speed := float(MainSet.set_data.get("CreateMonsterSpeed", TOWER_SPEED_VALUES[0]))
	var auto_next := bool(MainSet.set_data.get("镇妖塔自动下一层", false))
	var speed_index := 0
	for index in range(TOWER_SPEED_VALUES.size()):
		if is_equal_approx(current_speed, float(TOWER_SPEED_VALUES[index])):
			speed_index = index
			break
	MainSet.set_data["Difficult"] = difficulty
	MainSet.set_data["CreateMonsterCount"] = count
	MainSet.set_data["CreateMonsterSpeed"] = TOWER_SPEED_VALUES[speed_index]
	MainSet.set_data["镇妖塔自动下一层"] = auto_next
	if _tower_difficulty_button != null:
		_tower_difficulty_button.text = ["普通（积分×1）", "困难（积分×2）", "地狱（积分×3）"][difficulty]
	if _tower_count_button != null:
		_tower_count_button.text = "×%d" % count
	if _tower_speed_button != null:
		_tower_speed_button.text = TOWER_SPEED_LABELS[speed_index]
	if _tower_auto_next_button != null:
		_tower_auto_next_button.text = "已开启" if auto_next else "已关闭"

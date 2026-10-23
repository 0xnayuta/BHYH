extends Control

const CATALOG_DATA := preload("res://Script/main_menu/equipment_catalog_data.gd")
const CATEGORIES := ["悟空", "唐僧", "八戒", "沙僧", "白龙", "哪吒", "玉兔", "通用", "法宝"]
const PANEL_SIZE := Vector2(900.0, 540.0)
const GOLD := Color("e8c478")
const SLOT_BACKGROUND := preload("res://Art/backpack/all_items/empty.png")
const CATALOG_FONT := preload("res://Font/aa_wen_zheng_ming_qin_fu_xiao_kai_mianfeiziti_com.ttf")
const QUALITY_ORDER := ["普通", "优秀", "精良", "史诗", "邪灵", "魂器", "传说", "神器", "玄冥", "黑神话", "无敌"]

var catalog = CATALOG_DATA.new()
var category := "悟空"
var displayed_ids: Array[String] = []
var selected_id := ""
var _panel: PanelContainer
var _item_list: ItemList
var _detail: VBoxContainer
var _detail_scroll: ScrollContainer
var _search: LineEdit
var _type_filter: OptionButton
var _count: Label
var _category_buttons: Array[Button] = []
var _drag_bar: VScrollBar
var _touch_index := -1
var _drag_started := false
var _drag_origin := Vector2.ZERO
var _touch_position := Vector2.ZERO
var _icon_cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	catalog.initialize(AE.all_equipment)
	category = CATEGORIES[clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 7) - 1]
	_build_ui()
	_layout_panel()
	get_viewport().size_changed.connect(_layout_panel)
	refresh_items()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_begin_drag(event.position)
			if _drag_bar != null:
				_touch_index = event.index
		elif not event.pressed and event.index == _touch_index:
			_end_drag()
			_touch_index = -1
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_drag(event.position)
	elif (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.device != -1
		and _touch_index == -1
	):
		if event.pressed:
			_begin_drag(event.position)
		else:
			_end_drag()
	elif event is InputEventMouseMotion and event.device != -1 and _touch_index == -1:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_update_drag(event.position)


func _begin_drag(position: Vector2) -> void:
	_drag_bar = null
	for region in [_item_list, _detail_scroll]:
		var bar: VScrollBar = region.get_v_scroll_bar()
		if (
			region.get_global_rect().has_point(position)
			and not (bar.visible and bar.get_global_rect().has_point(position))
		):
			_drag_bar = bar
			break
	_drag_started = false
	_drag_origin = position
	_touch_position = position


func _update_drag(position: Vector2) -> void:
	if _drag_bar == null:
		return
	if not _drag_started and absf(position.y - _drag_origin.y) < 6.0 * _panel.scale.y:
		return
	_drag_started = true
	_drag_bar.value -= (position.y - _touch_position.y) / _panel.scale.y
	_touch_position = position
	get_viewport().set_input_as_handled()


func _end_drag() -> void:
	if _drag_started:
		get_viewport().set_input_as_handled()
	_drag_bar = null
	_drag_started = false


func _style(color: Color, border := Color("735933"), width := 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(5)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _build_ui() -> void:
	theme = Theme.new()
	theme.default_font = CATALOG_FONT
	theme.default_font_size = 22
	theme.set_color("font_color", "Label", Color("e5dbc9"))
	for control_type in ["Button", "OptionButton"]:
		theme.set_stylebox("normal", control_type, _style(Color("242621"), Color("64563e")))
		theme.set_stylebox("hover", control_type, _style(Color("37362b"), GOLD))
		theme.set_stylebox("pressed", control_type, _style(Color("49402c"), GOLD))
		theme.set_stylebox("focus", control_type, _style(Color.TRANSPARENT, Color("aa8b55")))
		theme.set_color("font_color", control_type, Color("cbbd9f"))
		theme.set_color("font_pressed_color", control_type, Color("ffdfa0"))
		theme.set_color("font_hover_color", control_type, Color("ffdfa0"))
	theme.set_stylebox("normal", "LineEdit", _style(Color("171b19"), Color("64563e")))
	theme.set_stylebox("focus", "LineEdit", _style(Color("20251f"), GOLD))
	theme.set_stylebox("panel", "ItemList", _style(Color("171b19"), Color("64563e")))
	theme.set_stylebox("selected", "ItemList", _style(Color("49402c"), Color("b59a60")))
	theme.set_stylebox("selected_focus", "ItemList", _style(Color("49402c"), GOLD))
	theme.set_color("font_color", "ItemList", Color("dcd0b8"))
	theme.set_color("font_selected_color", "ItemList", Color("ffdfa0"))
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.78)
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel = PanelContainer.new()
	_panel.name = "CatalogPanel"
	_panel.size = PANEL_SIZE
	var panel_style := _style(Color("20241f"), Color("b59a60"), 2)
	panel_style.content_margin_left = 18
	panel_style.content_margin_right = 18
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 12
	_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(_panel)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	_panel.add_child(outer)
	var header := HBoxContainer.new()
	outer.add_child(header)
	var title := Label.new()
	title.text = "装备图鉴"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", GOLD)
	header.add_child(title)
	var close := Button.new()
	close.name = "CloseButton"
	close.text = "关闭"
	close.custom_minimum_size = Vector2(64, 36)
	close.pressed.connect(queue_free)
	header.add_child(close)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	outer.add_child(tabs)
	for category_name in CATEGORIES:
		var button := Button.new()
		button.text = category_name
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 40
		button.pressed.connect(select_category.bind(category_name))
		tabs.add_child(button)
		_category_buttons.append(button)
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 10)
	outer.add_child(filters)
	_search = LineEdit.new()
	_search.placeholder_text = "搜索装备或法宝名称"
	_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search.text_changed.connect(func(_text): refresh_items())
	filters.add_child(_search)
	_type_filter = OptionButton.new()
	_type_filter.add_item("全部类型")
	for type_name in CATALOG_DATA.EQUIPMENT_TYPES:
		_type_filter.add_item(type_name)
	_type_filter.item_selected.connect(func(_index): refresh_items())
	filters.add_child(_type_filter)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	outer.add_child(body)
	_item_list = ItemList.new()
	_item_list.name = "EquipmentList"
	_item_list.custom_minimum_size = Vector2(258, 0)
	_item_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_list.fixed_icon_size = Vector2i(46, 46)
	_item_list.add_theme_constant_override("icon_margin", 10)
	_item_list.add_theme_constant_override("v_separation", 8)
	_item_list.item_selected.connect(func(index): select_item(displayed_ids[index]))
	body.add_child(_item_list)
	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.add_theme_stylebox_override("panel", _style(Color("171b19"), Color("64563e")))
	body.add_child(detail_panel)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.name = "DetailScroll"
	_detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_panel.add_child(_detail_scroll)
	_detail = VBoxContainer.new()
	_detail.name = "DetailContent"
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.add_theme_constant_override("separation", 10)
	_detail_scroll.add_child(_detail)
	_count = Label.new()
	_count.add_theme_font_size_override("font_size", 17)
	_count.add_theme_color_override("font_color", Color("a99d83"))
	outer.add_child(_count)


func _layout_panel() -> void:
	var viewport_size := get_viewport_rect().size
	var fit := minf(1.0, minf(viewport_size.x / PANEL_SIZE.x, viewport_size.y / PANEL_SIZE.y))
	_panel.scale = Vector2(fit, fit)
	_panel.position = (viewport_size - PANEL_SIZE * fit) * 0.5


func select_category(value: String) -> void:
	category = value
	_type_filter.select(0)
	refresh_items()


func refresh_items() -> void:
	displayed_ids.clear()
	_item_list.clear()
	for button in _category_buttons:
		button.set_pressed_no_signal(button.text == category)
	_type_filter.disabled = category == "法宝"
	var filter_type := _type_filter.get_item_text(_type_filter.selected)
	var query := _search.text.strip_edges()
	for key in catalog.equipment:
		var item_id := str(key)
		var data: Dictionary = catalog.equipment[key]
		var type_name := str(data.get(DataKeys.TYPE, ""))
		if item_id in CATALOG_DATA.HIDDEN_ITEM_IDS:
			continue
		if (
			PlayerData._is_removed_equipment_id(item_id)
			or item_id in PlayerData.RETIRED_WUDU_MAGIC_WEAPONS
			or item_id in PlayerData.RETIRED_XIANYU_EQUIPMENT_MAP
			or item_id in PlayerData.RETIRED_XIANYU_REMOVE_IDS
		):
			continue
		if category == "法宝":
			if type_name != "法宝":
				continue
		elif type_name not in CATALOG_DATA.EQUIPMENT_TYPES or str(data.get("所属", "")) != category:
			continue
		if category != "法宝" and filter_type != "全部类型" and type_name != filter_type:
			continue
		if query != "" and not catalog.item_name(item_id).containsn(query):
			continue
		displayed_ids.append(item_id)
	displayed_ids.sort_custom(
		func(a, b):
			var a_data: Dictionary = catalog.equipment[a]
			var b_data: Dictionary = catalog.equipment[b]
			var a_quality := QUALITY_ORDER.find(str(a_data.get(DataKeys.QUALITY, "")))
			var b_quality := QUALITY_ORDER.find(str(b_data.get(DataKeys.QUALITY, "")))
			if a_quality != b_quality:
				return a_quality < b_quality
			var a_type := str(a_data.get(DataKeys.TYPE, ""))
			var b_type := str(b_data.get(DataKeys.TYPE, ""))
			if a_type != b_type:
				return a_type < b_type
			return catalog.item_name(a) < catalog.item_name(b)
	)
	for item_id in displayed_ids:
		_item_list.add_item(catalog.item_name(item_id), _get_framed_icon(item_id))
	_count.text = "%s · 共 %d 件 · 品质升序  |  上下拖动浏览；属性以实际装备为准。" % [category, displayed_ids.size()]
	if not displayed_ids.is_empty():
		_item_list.select(0)
		select_item(displayed_ids[0])
	else:
		_clear_detail()
		_add_text("没有符合条件的装备", 20, GOLD)


func _clear_detail() -> void:
	selected_id = ""
	for child in _detail.get_children():
		_detail.remove_child(child)
		child.queue_free()
	_detail_scroll.scroll_vertical = 0


func select_item(item_id: String) -> void:
	_clear_detail()
	selected_id = item_id
	var list_index := displayed_ids.find(item_id)
	if list_index >= 0:
		_item_list.select(list_index)
		_item_list.ensure_current_is_visible()
	var data: Dictionary = catalog.equipment.get(item_id, {})
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	var banner := PanelContainer.new()
	banner.add_theme_stylebox_override("panel", _style(Color("2d3027"), Color("786443")))
	_detail.add_child(banner)
	banner.add_child(header)
	var icon := TextureRect.new()
	icon.name = "EquipmentIcon"
	icon.custom_minimum_size = Vector2(72, 72)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _get_framed_icon(item_id)
	header.add_child(icon)
	var identity := VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(identity)
	var name_label := Label.new()
	name_label.text = catalog.item_name(item_id)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_color_override("font_color", GOLD)
	name_label.add_theme_font_size_override("font_size", 28)
	identity.add_child(name_label)
	var metadata := Label.new()
	metadata.text = (
		"%s  /  %s  /  %s" % [data.get(DataKeys.QUALITY, ""), data.get(DataKeys.TYPE, ""), data.get("所属", "")]
	)
	metadata.add_theme_font_size_override("font_size", 19)
	metadata.add_theme_color_override("font_color", Color("bbae91"))
	identity.add_child(metadata)
	_add_text("基础属性", 23, GOLD)
	var attributes := GridContainer.new()
	attributes.columns = 3
	attributes.name = "AttributeCards"
	attributes.add_theme_constant_override("h_separation", 8)
	attributes.add_theme_constant_override("v_separation", 8)
	_detail.add_child(attributes)
	for value in catalog.get_attributes(item_id):
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", _style(Color("282d25"), Color("454b3a")))
		attributes.add_child(card)
		var row := HBoxContainer.new()
		card.add_child(row)
		var parts: PackedStringArray = value.split("  ", false, 1)
		var label := Label.new()
		label.text = parts[0]
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color("bbae91"))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		if parts.size() > 1:
			var number := Label.new()
			number.text = parts[1]
			number.add_theme_font_size_override("font_size", 24)
			number.add_theme_color_override("font_color", Color("f0d59b"))
			row.add_child(number)
	_add_section("装备描述", catalog.get_description(item_id), Color("e5dbc9"))
	_add_section("掉落位置与获取方式", catalog.get_sources(item_id), Color("bdd1b2"))


func _add_section(title: String, value: String, color: Color) -> void:
	_add_text(title, 23, GOLD)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(Color("232820"), Color("454b3a")))
	_detail.add_child(panel)
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 21)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("line_spacing", 5)
	panel.add_child(label)


func _get_framed_icon(item_id: String) -> Texture2D:
	if _icon_cache.has(item_id):
		return _icon_cache[item_id]
	var background := SLOT_BACKGROUND.get_image()
	if background.is_compressed():
		background.decompress()
	background.convert(Image.FORMAT_RGBA8)
	background.resize(64, 64, Image.INTERPOLATE_LANCZOS)
	var path: String = catalog.get_icon_path(item_id)
	if path != "":
		var texture := load(path) as Texture2D
		var foreground := texture.get_image()
		if foreground.is_compressed():
			foreground.decompress()
		foreground.convert(Image.FORMAT_RGBA8)
		var fit := 54.0 / maxf(foreground.get_width(), foreground.get_height())
		var icon_size := Vector2i(
			maxi(1, roundi(foreground.get_width() * fit)), maxi(1, roundi(foreground.get_height() * fit))
		)
		foreground.resize(icon_size.x, icon_size.y, Image.INTERPOLATE_LANCZOS)
		background.blend_rect(foreground, Rect2i(Vector2i.ZERO, icon_size), (Vector2i(64, 64) - icon_size) / 2)
	var result := ImageTexture.create_from_image(background)
	_icon_cache[item_id] = result
	return result


func _add_text(value: String, font_size := 16, color := Color("e2e8ed")) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	_detail.add_child(label)
	return label

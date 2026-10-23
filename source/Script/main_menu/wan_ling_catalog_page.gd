extends Control
class_name WanLingCatalogPage

const STAGE_SIZE := Vector2(940.0, 560.0)
const HUMAN_CATEGORY := "人间"
const UNDERWORLD_CATEGORY := "地府"
const HEAVEN_CATEGORY := "天庭"
const CATEGORY_NAMES := [
	"人间",
	"地府",
	"天庭",
	"截教天境",
	"碧游宫",
	"南瞻部洲",
	"东胜神洲",
	"北俱芦洲",
	"西牛贺州",
]
const HUMAN_MONSTERS := {
	1: "小猴子",
	2: "妖猴",
	3: "大猩猩",
	4: "猕猴王",
	5: "禺狨王",
	6: "龙王",
	7: "蝙蝠",
	8: "蝙蝠石像",
	9: "地鼠精",
	10: "妖狮",
	11: "狮驼王",
	12: "鹏魔王",
	13: "机甲鹰",
	14: "虾兵",
	15: "蟹将",
	16: "鱼将军",
	17: "龟丞相",
	18: "蛟魔王",
	20: "鲨魔王",
	21: "牛魔斗士",
	22: "牛魔王·兽",
	23: "牛魔王·人",
	24: "牛魔王·鬼",
}
const HUMAN_EFFECT_TEXT := {
	1: "每个+50生命",
	2: "每个+50生命",
	3: "每个+4魔防",
	4: "每个+100攻击",
	5: "每个+100攻击",
	6: "每个+20暴击",
	7: "每个+3破甲、破魔",
	8: "每个+100攻击",
	9: "每个+100生命",
	10: "每个+10攻击",
	11: "每个+0.2%伤害",
	12: "每个+0.2%伤害",
	13: "每个+0.2回血、回魔",
	14: "每个+5攻击",
	15: "每个+5攻击",
	16: "每个+5攻击",
	17: "每个+4物防",
	18: "每个+0.2%免伤",
	20: "每个+0.2%免伤",
	21: "每个+25魔法",
	22: "每个+0.2%伤害",
	23: "每个+0.2%免伤",
	24: "每个+0.01%吸血",
}
const UNDERWORLD_MONSTERS := {
	26: "鬼灯",
	27: "僵尸",
	28: "守夜人",
	29: "魔·红孩儿",
	30: "黑无常",
	31: "白无常",
	32: "白骨精·精",
	33: "傀儡王",
	37: "秦广王",
	39: "马面",
	40: "牛头",
	41: "判官",
	43: "阎罗王",
	48: "夜叉",
	49: "孟婆",
	51: "沙华",
	52: "河童",
	53: "曼珠",
	54: "青蛇",
	55: "转轮·圣帝",
	56: "转轮·真法",
	57: "转轮·圣王",
	58: "勾魂使者",
}
const UNDERWORLD_EFFECT_TEXT := {
	26: "每个+50生命",
	27: "每个+50生命",
	28: "每个+4魔防",
	29: "每个+100攻击",
	30: "每个+100攻击",
	31: "每个+20暴击",
	32: "每个+100破甲、破魔",
	33: "每个+100攻击、100生命",
	37: "每个+100攻击",
	39: "每个+5攻击",
	40: "每个+5攻击",
	41: "每个+100攻击",
	43: "每个+80物防",
	48: "每个+0.2%免伤",
	49: "每个+200魔法",
	51: "每个+0.01%伤害",
	52: "每个+0.01%免伤",
	53: "每个+100生命",
	54: "每个+50生命",
	55: "每个+0.2%伤害",
	56: "每个+0.2%免伤",
	57: "每个+0.2%伤害",
	58: "每个+0.2回血、回魔",
}
const HEAVEN_MONSTERS := {
	74: "黑龟",
	75: "黑虎",
	76: "巫鹰",
	77: "千里眼",
	78: "顺风耳",
	79: "巨灵神",
	80: "天兵·枪",
	81: "天兵·刀",
	82: "天兵·弓",
	83: "增长天王",
	84: "广目天王",
	85: "多闻天王",
	86: "狗妖",
	87: "羊妖",
	88: "牛妖",
	89: "朱子真",
	90: "蛇妖",
	91: "袁洪",
	92: "蜈蚣精",
	93: "二郎神",
	94: "天兵·斧",
	95: "天兵·锤",
	96: "猕猴王·通风",
	97: "巨盾护卫",
	98: "长刀护卫",
	99: "黑雕护卫",
	100: "土行孙",
	101: "雷震子",
	102: "哪吒",
	103: "托塔天王",
	104: "硫磺童子",
	105: "巫毒童子",
	106: "勾魂童子",
	107: "银角大王",
	108: "金角大王",
	109: "隐匿童子",
	110: "青牛精",
	111: "人参童子",
	112: "太白金星",
	113: "电魂童子",
	114: "太上老君",
	134: "马天君",
	135: "天王使者",
	136: "持国傀儡",
	137: "持国天王",
}
const HEAVEN_EFFECT_TEXT := {
	74: "每个+50生命",
	75: "每个+50生命",
	76: "每个+1魔防",
	77: "每个+100攻击",
	78: "每个+100攻击",
	79: "每个+20暴击",
	80: "每个+5攻击",
	81: "每个+2物防",
	82: "每个+3破甲、破魔",
	83: "每个+0.16%伤害",
	84: "每个+0.15%免伤",
	85: "每个+40物防",
	86: "每个+50生命",
	87: "每个+50生命",
	88: "每个+100生命",
	89: "每个+100攻击",
	90: "每个+1魔防",
	91: "每个+0.16%伤害",
	92: "每个+3破甲、破魔",
	93: "每个+0.15%免伤",
	94: "每个+5攻击",
	95: "每个+5攻击",
	96: "每个+0.01%吸血",
	97: "每个+2物防",
	98: "每个+5攻击",
	99: "每个+2魔防",
	100: "每个+100攻击",
	101: "每个+0.16%伤害",
	102: "每个+20暴击",
	103: "每个+0.15%免伤",
	104: "每个+50生命",
	105: "每个+2魔防",
	106: "每个+0.2回血、回魔",
	107: "每个+100攻击",
	108: "每个+200魔法",
	109: "每个+100生命",
	110: "每个+0.16%伤害",
	111: "每个+100生命",
	112: "每个+200魔法",
	113: "每个+0.01%免伤",
	114: "每个+0.16%伤害、0.15%免伤",
	134: "每个+100攻击",
	135: "每个+50生命",
	136: "每个+1000生命",
	137: "每个+20暴击",
}
const PORTRAIT_PATH := "res://Art/monster/creature_codex/%d.png"
const CRYSTAL_PATH := "res://Art/monster/soul_crystal/%d.png"
const UI_FONT := preload("res://Font/aa_wen_zheng_ming_qin_fu_xiao_kai_mianfeiziti_com.ttf")

@onready var _stage: Panel = $Stage
@onready var _category_list: VBoxContainer = $Stage/CategoryPanel/CategoryMargin/CategoryList
@onready var _section_title: Label = $Stage/ContentPanel/SectionTitle
@onready var _scroll: ScrollContainer = $Stage/ContentPanel/MonsterScroll
@onready var _grid: GridContainer = $Stage/ContentPanel/MonsterScroll/MonsterGrid
@onready var _empty_label: Label = $Stage/ContentPanel/EmptyLabel
@onready var _attribute_text: Label = $Stage/AttributePanel/AttributeMargin/AttributeContent/AttributeText

var _current_category := HUMAN_CATEGORY
var _category_buttons: Dictionary = {}
var _monster_widgets: Dictionary = {}
var _scroll_pointer_active := false
var _scroll_pointer_dragged := false
var _scroll_pointer_distance := 0.0


func _input(event: InputEvent) -> void:
	if not (
		event is InputEventScreenTouch
		or event is InputEventScreenDrag
		or event is InputEventMouseButton
		or event is InputEventMouseMotion
	):
		return
	if not _scroll.visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if not _scroll.get_global_rect().has_point(event.position):
				return
			_scroll_pointer_active = true
			_scroll_pointer_dragged = false
			_scroll_pointer_distance = 0.0
		elif _scroll_pointer_active:
			if _scroll_pointer_dragged:
				get_viewport().set_input_as_handled()
			_scroll_pointer_active = false
			_scroll_pointer_dragged = false
			_scroll_pointer_distance = 0.0
	elif event is InputEventScreenDrag and _scroll_pointer_active:
		_scroll_pointer_distance += absf(event.relative.y)
		if _scroll_pointer_distance >= 8.0:
			_scroll_pointer_dragged = true
		if _scroll_pointer_dragged:
			_scroll.scroll_vertical = maxi(0, _scroll.scroll_vertical - roundi(event.relative.y))
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not _scroll.get_global_rect().has_point(event.position):
				return
			_scroll_pointer_active = true
			_scroll_pointer_dragged = false
			_scroll_pointer_distance = 0.0
		elif _scroll_pointer_active:
			if _scroll_pointer_dragged:
				get_viewport().set_input_as_handled()
			_scroll_pointer_active = false
			_scroll_pointer_dragged = false
			_scroll_pointer_distance = 0.0
	elif event is InputEventMouseMotion and _scroll_pointer_active:
		_scroll_pointer_distance += absf(event.relative.y)
		if _scroll_pointer_distance >= 8.0:
			_scroll_pointer_dragged = true
		if _scroll_pointer_dragged:
			_scroll.scroll_vertical = maxi(0, _scroll.scroll_vertical - roundi(event.relative.y))
			get_viewport().set_input_as_handled()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	PlayerData.ensure_wanling_catalog_data()
	_build_category_buttons()
	_show_category(HUMAN_CATEGORY)
	_refresh_attribute_summary()
	_layout_stage()
	if not get_viewport().size_changed.is_connected(_layout_stage):
		get_viewport().size_changed.connect(_layout_stage)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()


func _layout_stage() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit := minf(1.0, minf(viewport_size.x / STAGE_SIZE.x, viewport_size.y / STAGE_SIZE.y))
	_stage.scale = Vector2(fit, fit)
	_stage.position = (viewport_size - STAGE_SIZE * fit) * 0.5


func _build_category_buttons() -> void:
	for category_name in CATEGORY_NAMES:
		var button := Button.new()
		button.custom_minimum_size = Vector2(130.0, 39.0)
		button.focus_mode = Control.FOCUS_NONE
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		button.text = category_name
		button.add_theme_font_override("font", UI_FONT)
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", Color("e9e6df"))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_disabled_color", Color("ffe39a"))
		button.add_theme_stylebox_override("normal", _make_button_style(Color("293138"), Color("5c6870")))
		button.add_theme_stylebox_override("hover", _make_button_style(Color("3a464d"), Color("89a69c")))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color("1d252a"), Color("b6c9bd")))
		button.add_theme_stylebox_override("disabled", _make_button_style(Color("7a2e32"), Color("e2b75c")))
		button.pressed.connect(_on_category_pressed.bind(str(category_name)))
		_category_list.add_child(button)
		_category_buttons[category_name] = button


func _show_category(category_name: String) -> void:
	_current_category = category_name
	_section_title.text = category_name
	for name_value in _category_buttons:
		var button: Button = _category_buttons[name_value]
		button.disabled = str(name_value) == category_name
	_clear_monster_cards()
	var is_supported := category_name in [HUMAN_CATEGORY, UNDERWORLD_CATEGORY, HEAVEN_CATEGORY]
	_scroll.visible = is_supported
	_empty_label.visible = not is_supported
	if category_name == HUMAN_CATEGORY:
		_build_cards(HUMAN_MONSTERS)
	elif category_name == UNDERWORLD_CATEGORY:
		_build_cards(UNDERWORLD_MONSTERS)
	elif category_name == HEAVEN_CATEGORY:
		_build_cards(HEAVEN_MONSTERS)
	else:
		_empty_label.text = "%s图录暂未开放" % category_name


func _clear_monster_cards() -> void:
	_monster_widgets.clear()
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()


func _build_cards(monsters: Dictionary) -> void:
	for monster_id_value in monsters:
		var monster_id := int(monster_id_value)
		_grid.add_child(_create_monster_card(monster_id, str(monsters[monster_id])))
	_scroll.scroll_vertical = 0


func _create_monster_card(monster_id: int, monster_name: String) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(158.0, 270.0)
	card.add_theme_stylebox_override("panel", _make_card_style())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 9)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 9)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)

	var name_label := Label.new()
	name_label.custom_minimum_size.y = 25.0
	name_label.text = monster_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_override("font", UI_FONT)
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color("f3dfaa"))
	column.add_child(name_label)

	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(140.0, 100.0)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = ResourceLoader.load(PORTRAIT_PATH % monster_id) as Texture2D
	column.add_child(portrait)

	var effect_label := Label.new()
	effect_label.custom_minimum_size.y = 31.0
	effect_label.text = _get_effect_text(monster_id)
	effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.add_theme_font_override("font", UI_FONT)
	effect_label.add_theme_font_size_override("font_size", 13)
	effect_label.add_theme_color_override("font_color", Color("d8cda9"))
	column.add_child(effect_label)

	var level_label := Label.new()
	level_label.custom_minimum_size.y = 22.0
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_override("font", UI_FONT)
	level_label.add_theme_font_size_override("font_size", 16)
	level_label.add_theme_color_override("font_color", Color("b9e3cc"))
	column.add_child(level_label)

	var material_row := HBoxContainer.new()
	material_row.alignment = BoxContainer.ALIGNMENT_CENTER
	material_row.add_theme_constant_override("separation", 5)
	column.add_child(material_row)

	var crystal_icon := TextureRect.new()
	crystal_icon.custom_minimum_size = Vector2(24.0, 24.0)
	crystal_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crystal_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	crystal_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	crystal_icon.texture = ResourceLoader.load(CRYSTAL_PATH % monster_id) as Texture2D
	material_row.add_child(crystal_icon)

	var material_label := Label.new()
	material_label.add_theme_font_override("font", UI_FONT)
	material_label.add_theme_font_size_override("font_size", 14)
	material_label.add_theme_color_override("font_color", Color("e5e7e8"))
	material_row.add_child(material_label)

	var upgrade_button := Button.new()
	upgrade_button.custom_minimum_size.y = 31.0
	upgrade_button.focus_mode = Control.FOCUS_NONE
	upgrade_button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	upgrade_button.text = "吞噬"
	upgrade_button.add_theme_font_override("font", UI_FONT)
	upgrade_button.add_theme_font_size_override("font_size", 16)
	upgrade_button.add_theme_color_override("font_color", Color.WHITE)
	upgrade_button.add_theme_color_override("font_disabled_color", Color("8e969b"))
	upgrade_button.add_theme_stylebox_override("normal", _make_button_style(Color("276149"), Color("72ae8e")))
	upgrade_button.add_theme_stylebox_override("hover", _make_button_style(Color("347a5e"), Color("a4d7bb")))
	upgrade_button.add_theme_stylebox_override("pressed", _make_button_style(Color("1d4937"), Color("d0eadb")))
	upgrade_button.add_theme_stylebox_override("disabled", _make_button_style(Color("343b3f"), Color("596166")))
	upgrade_button.pressed.connect(_on_consume_pressed.bind(monster_id))
	column.add_child(upgrade_button)

	_monster_widgets[monster_id] = {
		"level": level_label,
		"material": material_label,
		"button": upgrade_button,
	}
	_refresh_monster_card(monster_id)
	return card


func _refresh_monster_card(monster_id: int) -> void:
	if not _monster_widgets.has(monster_id):
		return
	var widgets: Dictionary = _monster_widgets[monster_id]
	var consumed := _get_consumed_count(monster_id)
	var consume_limit := _get_consume_limit(monster_id)
	var have := _get_soul_crystal_count(monster_id)
	var level_label: Label = widgets["level"]
	var material_label: Label = widgets["material"]
	var upgrade_button: Button = widgets["button"]
	level_label.text = "吞噬 %d / %d" % [consumed, consume_limit]
	material_label.text = "魂晶 %d" % have
	material_label.add_theme_color_override(
		"font_color", Color("b9e3cc") if have > 0 and consumed < consume_limit else Color("f0aaa5")
	)
	upgrade_button.disabled = have <= 0 or consumed >= consume_limit
	upgrade_button.text = "已达上限" if consumed >= consume_limit else "吞噬"


func _on_category_pressed(category_name: String) -> void:
	if category_name == _current_category:
		return
	_show_category(category_name)


func _on_consume_pressed(monster_id: int) -> void:
	var monster_name := _get_monster_name(monster_id)
	var consumed_count := _consume_all_crystals(monster_id)
	if consumed_count <= 0:
		if _get_consumed_count(monster_id) >= _get_consume_limit(monster_id):
			_show_message("%s已达到吞噬上限" % monster_name)
		else:
			_show_message("没有可吞噬的%s魂晶" % monster_name)
		_refresh_monster_card(monster_id)
		return
	if RoleProp != null and RoleProp.has_method("get_last_prop"):
		RoleProp.get_last_prop()
	_save_if_possible()
	_refresh_monster_card(monster_id)
	_refresh_attribute_summary()
	_show_message("吞噬%d个%s魂晶" % [consumed_count, monster_name])


func _get_monster_name(monster_id: int) -> String:
	var monsters := HUMAN_MONSTERS
	if _current_category == UNDERWORLD_CATEGORY:
		monsters = UNDERWORLD_MONSTERS
	elif _current_category == HEAVEN_CATEGORY:
		monsters = HEAVEN_MONSTERS
	return str(monsters.get(monster_id, "怪物"))


func _get_effect_text(monster_id: int) -> String:
	var effects := HUMAN_EFFECT_TEXT
	if _current_category == UNDERWORLD_CATEGORY:
		effects = UNDERWORLD_EFFECT_TEXT
	elif _current_category == HEAVEN_CATEGORY:
		effects = HEAVEN_EFFECT_TEXT
	return str(effects.get(monster_id, ""))


func _get_consumed_count(monster_id: int) -> int:
	if _current_category == UNDERWORLD_CATEGORY:
		return PlayerData.get_wanling_underworld_consumed_count(monster_id)
	if _current_category == HEAVEN_CATEGORY:
		return PlayerData.get_wanling_heaven_consumed_count(monster_id)
	return PlayerData.get_wanling_human_consumed_count(monster_id)


func _get_consume_limit(monster_id: int) -> int:
	if _current_category == UNDERWORLD_CATEGORY:
		return PlayerData.get_wanling_underworld_consume_limit(monster_id)
	if _current_category == HEAVEN_CATEGORY:
		return PlayerData.get_wanling_heaven_consume_limit(monster_id)
	return PlayerData.get_wanling_human_consume_limit(monster_id)


func _get_soul_crystal_count(monster_id: int) -> int:
	if _current_category == UNDERWORLD_CATEGORY:
		return PlayerData.get_wanling_underworld_soul_crystal_count(monster_id)
	if _current_category == HEAVEN_CATEGORY:
		return PlayerData.get_wanling_heaven_soul_crystal_count(monster_id)
	return PlayerData.get_wanling_soul_crystal_count(monster_id)


func _consume_all_crystals(monster_id: int) -> int:
	if _current_category == UNDERWORLD_CATEGORY:
		return PlayerData.consume_all_wanling_underworld_crystals(monster_id)
	if _current_category == HEAVEN_CATEGORY:
		return PlayerData.consume_all_wanling_heaven_crystals(monster_id)
	return PlayerData.consume_all_wanling_human_crystals(monster_id)


func _refresh_attribute_summary() -> void:
	var totals := PlayerData.get_wanling_attribute_totals()
	var rows := [
		["生命", "SHp", false],
		["魔法", "SMp", false],
		["攻击", "power", false],
		["物防", "Def", false],
		["魔防", "Mdef", false],
		["暴击", "Crit", false],
		["破甲", "ar", false],
		["破魔", "sp", false],
		["回血", "R_hp", false],
		["回魔", "R_mp", false],
		["伤害", "damage_bonus", true],
		["免伤", "damage_reduction", true],
		["吸血", "vampirism", true],
	]
	var lines: Array[String] = []
	for row in rows:
		var value := float(totals.get(str(row[1]), 0.0))
		var value_text := _format_number(value * 100.0) + "%" if bool(row[2]) else _format_number(value)
		lines.append("%s  +%s" % [str(row[0]), value_text])
	_attribute_text.text = "\n".join(lines)


func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")


func _on_close_pressed() -> void:
	queue_free()


func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		queue_free()
	elif event is InputEventScreenTouch and event.pressed:
		queue_free()


func _save_if_possible() -> void:
	var save_path := str(Global.cd_path)
	if save_path != "" and save_path.contains("Ar_") and FileAccess.file_exists(save_path):
		MemoryClass.save_game(save_path)


func _show_message(message: String) -> void:
	var parent_node: Node = Global.get_ui_popup_layer() if Global.has_method("get_ui_popup_layer") else get_parent()
	Global.add_message_show(parent_node, message, 1.5, Vector2.ZERO)


func _make_button_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	return style


func _make_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("20272b")
	style.border_color = Color("58666d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	return style

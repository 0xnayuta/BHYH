## 7.4 魂卡穿戴页；由 7.4 反编译参考按当前路径与 Theme 适配。
extends "res://Script/main_menu/soul_card_panel_base.gd"

const ROLE_PREVIEW := preload("res://Script/main_menu/soul_card_role_preview.gd")
const FOIL_PREVIEW := preload("res://Script/main_menu/soul_card_foil_preview.gd")
var foil_preview: Control
var selected_id := "qly"
var card_buttons: Dictionary = {}
var detail: RichTextLabel
var bond_detail: RichTextLabel
var slot_buttons: Array[Button] = []
var upgrade_button: Button
var equip_button: Button
var preview_page: Node
var role_preview: Node2D
var equipment_area: Control
var mini_cards: Dictionary = {}


func section(parent: Node, title: String, width: float = 0.0) -> VBoxContainer:
	var frame = PanelContainer.new()
	frame.name = "Section"
	frame.custom_minimum_size.x = width
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var style = panel_style()
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	frame.add_theme_stylebox_override("panel", style)
	parent.add_child(frame)
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	frame.add_child(content)
	if title != "":
		var heading_label = label(title, 22)
		heading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(heading_label)
	return content


func _ready() -> void:
	DATA.ensure(PlayerData.player_data)
	build_panel("魂卡")
	var old_close = heading.get_node("Close")
	heading.remove_child(old_close)
	old_close.queue_free()
	var close_button = button(heading, "关闭", queue_free)
	close_button.name = "Close"
	close_button.custom_minimum_size = Vector2(84, 38)
	var instruction = label("选择左侧魂卡，点击人物周围魂位穿戴；再次点击已装备魂位即可卸下。", 15)
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outer.add_child(instruction)
	var body = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	outer.add_child(body)
	var inventory = section(body, "魂卡图鉴", 272)
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inventory.add_child(scroll)
	var glow_margin = MarginContainer.new()
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		glow_margin.add_theme_constant_override(side, 12)
	scroll.add_child(glow_margin)
	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 10)
	glow_margin.add_child(grid)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for id in DATA.IDS:
		var cell = VBoxContainer.new()
		cell.custom_minimum_size.x = 56
		cell.add_theme_constant_override("separation", 2)
		grid.add_child(cell)
		var entry = slot_button(cell, select_card.bind(id))
		entry.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		entry.name = "Card_" + id
		entry.custom_minimum_size = Vector2(56, 84)
		entry.icon = null
		for state in ["normal", "pressed", "hover", "disabled", "focus"]:
			entry.add_theme_stylebox_override(state, _empty_style())
		var miniature = FOIL_PREVIEW.new()
		miniature.name = "MiniFoilCard"
		miniature.compact = true
		miniature.card_id = id
		miniature.card_star = int(DATA.record(PlayerData.player_data, id).star)
		miniature.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		entry.add_child(miniature)
		entry.move_child(miniature, 0)
		mini_cards[id] = miniature
		card_buttons[id] = entry
		cell.visible = id in DATA.AVAILABLE_IDS
		var glow = entry.get_node("Selected")
		glow.texture = null
		glow.set_script(preload("res://Script/main_menu/soul_card_selection_glow.gd"))
		var title = label(DATA.CARDS[id].name, 12)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.custom_minimum_size.x = 56
		cell.add_child(title)
	var middle = section(body, "", 312)
	var role_name: String = ["悟空", "唐僧", "八戒", "沙僧", "白龙", "哪吒", "玉兔", "小龙女"][
		clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 8) - 1
	]
	var role_title = label(role_name + " · 魂卡穿戴", 22)
	role_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	middle.add_child(role_title)
	equipment_area = Control.new()
	equipment_area.name = "EquipmentArea"
	equipment_area.custom_minimum_size = Vector2(292, 320)
	equipment_area.clip_contents = true
	middle.add_child(equipment_area)
	role_preview = ROLE_PREVIEW.new()
	role_preview.name = "RolePreview"
	role_preview.position = Vector2(146, 174)
	equipment_area.add_child(role_preview)
	for slot in range(6):
		var entry = slot_button(equipment_area, use_slot.bind(slot))
		entry.name = "SoulSlot%d" % slot
		var glow = entry.get_node("Selected")
		glow.texture = null
		glow.set_script(preload("res://Script/main_menu/soul_card_selection_glow.gd"))
		entry.custom_minimum_size = Vector2(56, 84)
		entry.size = Vector2(56, 84)
		entry.position = Vector2(4 if slot < 3 else 232, 4 + (slot % 3) * 104)
		var card_face = TextureRect.new()
		card_face.name = "EquippedFoilCard"
		card_face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		entry.add_child(card_face)
		entry.move_child(card_face, 0)
		var slot_name = label("魂位%d" % (slot + 1), 13)
		slot_name.name = "SlotName"
		slot_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_name.position = Vector2(-9, 85)
		slot_name.size = Vector2(74, 20)
		slot_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		entry.add_child(slot_name)
		slot_buttons.append(entry)
	middle.add_child(label("已激活羁绊", 20))
	bond_detail = detail_box(middle)
	bond_detail.custom_minimum_size.y = 70
	var right = section(body, "魂卡详情")
	right.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foil_preview = FOIL_PREVIEW.new()
	foil_preview.name = "SelectedFoilCard"
	foil_preview.custom_minimum_size = Vector2(0, 190)
	right.add_child(foil_preview)
	foil_preview.enlarged.connect(show_preview)
	var hint = label("点击闪卡放大查看", 14)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(hint)
	detail = detail_box(right)
	detail.name = "CardDetails"
	detail.add_theme_font_size_override("normal_font_size", UiFontSizes.FONT_SIZE_17)
	detail.add_theme_constant_override("line_separation", 4)
	var actions = HBoxContainer.new()
	right.add_child(actions)
	equip_button = button(actions, "装备到空位", equip_selected)
	upgrade_button = button(actions, "升星", upgrade_selected)
	equip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notice = label("首次通关必得对应魂卡；每次掉落5～12个碎片；25%概率掉落魂卡，已激活转换20碎片。", 16)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outer.add_child(notice)
	refresh()


func _empty_style() -> StyleBox:
	return StyleBoxEmpty.new()


func refresh() -> void:
	var data = DATA.ensure(PlayerData.player_data)
	var slots = DATA.equipped(PlayerData.player_data)
	for id in DATA.IDS:
		var star = int(data.cards[id].star)
		var entry: Button = card_buttons[id]
		entry.modulate = UiColorTokens.TEXT_PRIMARY if star > 0 else UiSurfaceTokens.PREVIEW_LOCKED_MODULATE
		mini_cards[id].display_card(id, star)
		entry.get_node("Star").text = "%d星" % star if star > 0 else "未获"
		entry.tooltip_text = DATA.CARDS[id].name + (" · 已装备" if slots.has(id) else "")
	for i in range(6):
		var id = str(slots[i])
		slot_buttons[i].icon = null
		var card_face: TextureRect = slot_buttons[i].get_node("EquippedFoilCard")
		card_face.texture = mini_cards[id]._stage.texture if id != "" else null
		for state in ["normal", "pressed", "hover", "disabled", "focus"]:
			var state_style: StyleBox
			if id != "":
				state_style = StyleBoxEmpty.new()
			else:
				state_style = texture_style(ITEM_SLOT, 0.0)
			slot_buttons[i].add_theme_stylebox_override(state, state_style)
		slot_buttons[i].get_node("Star").text = "%d星" % int(data.cards[id].star) if id != "" else ""
		slot_buttons[i].get_node("SlotName").text = DATA.CARDS[id].name if id != "" else "魂位%d" % (i + 1)
		slot_buttons[i].tooltip_text = "选择魂卡后点击此处穿戴；同卡再次点击卸下"
	var bonds: PackedStringArray = []
	for bond in DATA.active_bonds(slots):
		bonds.append("[color=#f1cf81]%s[/color]\n%s" % [bond.name, bond.text])
	bond_detail.text = "\n\n".join(bonds) if not bonds.is_empty() else "同时穿戴搭档魂卡，可激活对应羁绊。"
	select_card(selected_id)


func select_card(id: String) -> void:
	selected_id = id
	foil_preview.display_card(id, int(DATA.record(PlayerData.player_data, id).star))
	for key in card_buttons:
		card_buttons[key].get_node("Selected").visible = key == id
	var slots = DATA.equipped(PlayerData.player_data)
	for slot in range(6):
		slot_buttons[slot].get_node("Selected").visible = slots[slot] == id
	var card = DATA.record(PlayerData.player_data, id)
	var star = int(card.star)
	var lines: PackedStringArray = []
	lines.append(
		(
			"[font_size=26][color=#f1cf81]%s[/color][/font_size]  %s"
			% [DATA.CARDS[id].name, "★".repeat(star) if star > 0 else "未获得"]
		)
	)
	lines.append("碎片：%d　%s" % [card.fragments, "已装备" if slots.has(id) else "未装备"])
	lines.append("[color=#f1cf81]收藏属性（常驻）[/color]\n" + DATA.stats_text(DATA.card_stats(id, star, true)))
	lines.append("[color=#f1cf81]穿戴追加属性[/color]\n" + DATA.stats_text(DATA.card_stats(id, star, false)))
	lines.append("[color=#f1cf81]魂卡技能[/color]\n" + str(DATA.CARDS[id].skill))
	lines.append("以上为1星伤害，每次命中至少10倍攻击；1～5星伤害依次×1、×1.25、×1.5、×1.75、×2（含羁绊追加伤害）。5星增加25%范围，千里眼多1箭，火轮与水域多持续1秒。")
	for bond in DATA.PAIRS + DATA.SETS:
		if bond.cards.has(id):
			var available = true
			for member in bond.cards:
				if not member in DATA.AVAILABLE_IDS:
					available = false
			if not available:
				continue
			var names: PackedStringArray = []
			for member in bond.cards:
				names.append(DATA.CARDS[member].name)
			lines.append("[color=#f1cf81]%s[/color]（%s）\n%s" % [bond.name, "＋".join(names), bond.text])
	detail.text = "\n".join(lines)
	upgrade_button.text = "已满星" if star >= 5 else "升星（%d碎片）" % DATA.STAR_COSTS[star] if star > 0 else "未获得"
	upgrade_button.disabled = star < 1 or star >= 5 or int(card.fragments) < DATA.STAR_COSTS[star] or in_battle()
	equip_button.disabled = star < 1 or in_battle()


func use_slot(slot: int) -> void:
	var current = str(DATA.equipped(PlayerData.player_data)[slot])
	var id = "" if current == selected_id else selected_id
	if DATA.equip(PlayerData.player_data, id, slot, in_battle()):
		DATA.persist(self)
		refresh()
		notice.text = "已卸下魂卡" if id == "" else "已将%s装备到第%d魂位" % [DATA.CARDS[id].name, slot + 1]
	else:
		notice.text = "战斗中不能换卡。" if in_battle() else "请先挑战精英副本，获得这张魂卡。"


func equip_selected() -> void:
	var slots = DATA.equipped(PlayerData.player_data)
	if slots.has(selected_id):
		notice.text = "已经装备；点击对应魂位可卸下，或点击其他魂位移动。"
		return
	var empty = slots.find("")
	if empty < 0:
		notice.text = "六个魂位已满，请点击右侧要替换的魂位。"
		return
	use_slot(empty)


func upgrade_selected() -> void:
	if in_battle():
		return
	if DATA.upgrade(PlayerData.player_data, selected_id):
		DATA.persist(self)
		refresh()
		notice.text = "%s已升至%d星" % [DATA.CARDS[selected_id].name, DATA.record(PlayerData.player_data, selected_id).star]


func _popup_layer() -> Node:
	var layer := Global.get_ui_runtime().get_popup_layer()
	if layer != null:
		return layer
	var parent := get_parent()
	return parent if parent != null else self


func show_preview() -> void:
	if is_instance_valid(preview_page):
		preview_page.queue_free()
		return
	var popup = load("res://Script/main_menu/soul_card_panel_base.gd").new()
	preview_page = popup
	_popup_layer().add_child(popup)
	popup.build_panel(DATA.CARDS[selected_id].name + " · 闪卡")
	var enlarged_card = FOIL_PREVIEW.new()
	enlarged_card.card_id = selected_id
	enlarged_card.card_star = int(DATA.record(PlayerData.player_data, selected_id).star)
	enlarged_card.allow_drag = true
	enlarged_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	popup.outer.add_child(enlarged_card)
	popup.outer.add_child(popup.label("拖动卡面查看流光", 16))


func _exit_tree() -> void:
	if is_instance_valid(preview_page):
		preview_page.queue_free()

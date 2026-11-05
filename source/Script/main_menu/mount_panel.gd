extends Control

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

const MOUNT_CATALOG := preload("res://Script/mount/mount_catalog.gd")
const MOUNT_VISUAL := preload("res://Script/mount/mount_visual.gd")
const UI_FONT := preload("res://Font/aa_wen_zheng_ming_qin_fu_xiao_kai_mianfeiziti_com.ttf")
const PANEL_SIZE := Vector2(900.0, 590.0)
const TAB_NAMES := ["属性", "装备", "兽魂"]
const EQUIP_KEYS := ["头饰", "鞍具", "护甲", "缰绳", "饰品"]
const HIDDEN_MOUNT_IDS := ["1003900"]

var selected_mount_id := "1002200"
var selected_tab := 0
var panel_root: Control
var preview: Node2D
var preview_host: Panel
var name_label: Label
var state_label: Label
var message_label: Label
var action_button: Button
var train_button: Button
var train_all_button: Button
var list_button: Button
var content_root: Control
var tab_buttons: Array[Button] = []
var mount_list: Control
var mount_list_rows: Array[Button] = []
var mount_list_labels: Array[Label] = []
var skill_popup: Control
var message_timer := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	PlayerData.ensure_mount_data()
	var active_id := str(PlayerData.player_data.get(PlayerData.ACTIVE_MOUNT_KEY, ""))
	if HIDDEN_MOUNT_IDS.has(active_id):
		PlayerData.set_active_mount("")
		active_id = ""
	if active_id != "":
		selected_mount_id = active_id
	_build_ui()
	_refresh()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = UiSurfaceTokens.OVERLAY_MEDIUM
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	panel_root = Control.new()
	panel_root.name = "MountSelfDrawnPanel"
	panel_root.set_anchors_preset(Control.PRESET_CENTER)
	panel_root.position = -PANEL_SIZE * 0.5
	panel_root.size = PANEL_SIZE
	add_child(panel_root)
	var frame := Panel.new()
	frame.size = PANEL_SIZE
	frame.add_theme_stylebox_override("panel", _style(UiSurfaceTokens.COOL_FRAME, UiSurfaceTokens.COOL_ACCENT, 2, 6))
	panel_root.add_child(frame)
	var title := _label(
		"坐骑", Vector2(28, 15), Vector2(760, 40), 30, UiColorTokens.TEXT_GOLD, HORIZONTAL_ALIGNMENT_CENTER
	)
	title.name = "MountTitle"
	panel_root.add_child(title)
	var close := _button("×", Vector2(830, 15), Vector2(46, 40), 26)
	close.add_theme_stylebox_override(
		"normal", _style(UiSurfaceTokens.DANGER_DEEP, UiSurfaceTokens.DANGER_BORDER, 1, 4)
	)
	close.add_theme_stylebox_override(
		"hover", _style(UiSurfaceTokens.DANGER_HOVER, UiSurfaceTokens.DANGER_BORDER_HOVER, 1, 4)
	)
	close.add_theme_stylebox_override(
		"pressed", _style(UiSurfaceTokens.DANGER_PRESSED, UiSurfaceTokens.DANGER_BORDER_PRESSED, 1, 4)
	)
	panel_root.add_child(close)
	close.pressed.connect(queue_free)
	var header_line := ColorRect.new()
	header_line.position = Vector2(18, 61)
	header_line.size = Vector2(864, 2)
	header_line.color = UiSurfaceTokens.COOL_ACCENT_LINE
	header_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_root.add_child(header_line)
	list_button = _button("更换坐骑", Vector2(30, 65), Vector2(130, 34), 15)
	list_button.name = "MountChangeButton"
	list_button.pressed.connect(_toggle_mount_list)
	panel_root.add_child(list_button)
	name_label = _label(
		"坐骑", Vector2(30, 112), Vector2(290, 30), 21, UiColorTokens.TEXT_GOLD_LIGHT, HORIZONTAL_ALIGNMENT_CENTER
	)
	panel_root.add_child(name_label)
	state_label = _label(
		"休息", Vector2(30, 144), Vector2(290, 24), 16, UiColorTokens.TEXT_JADE, HORIZONTAL_ALIGNMENT_CENTER
	)
	panel_root.add_child(state_label)

	preview_host = Panel.new()
	preview_host.name = "MountPreviewViewport"
	preview_host.position = Vector2(25, 174)
	preview_host.size = Vector2(300, 300)
	preview_host.clip_contents = true
	preview_host.add_theme_stylebox_override(
		"panel", _style(UiSurfaceTokens.COOL_PANEL, UiSurfaceTokens.COOL_PREVIEW_BORDER, 1, 4)
	)
	panel_root.add_child(preview_host)
	preview = MOUNT_VISUAL.new()
	preview.name = "MountPreview"
	preview_host.add_child(preview)
	action_button = _button("出战", Vector2(30, 490), Vector2(88, 36), 14)
	action_button.name = "MountActionButton"
	action_button.pressed.connect(_toggle_active_mount)
	panel_root.add_child(action_button)
	train_button = _button("升级", Vector2(126, 490), Vector2(88, 36), 14)
	train_button.name = "MountTrainButton"
	train_button.pressed.connect(_train_mount)
	panel_root.add_child(train_button)
	train_all_button = _button("一键升级", Vector2(222, 490), Vector2(98, 36), 14)
	train_all_button.name = "MountTrainAllButton"
	train_all_button.pressed.connect(_train_mount_all)
	panel_root.add_child(train_all_button)
	message_label = _label(
		"", Vector2(25, 535), Vector2(305, 32), 13, UiColorTokens.TEXT_GOLD, HORIZONTAL_ALIGNMENT_CENTER
	)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel_root.add_child(message_label)
	_build_content()
	_build_mount_list()


func _build_content() -> void:
	content_root = Control.new()
	content_root.name = "MountContent"
	content_root.position = Vector2(360, 65)
	content_root.size = Vector2(515, 490)
	panel_root.add_child(content_root)
	for index in range(TAB_NAMES.size()):
		var tab := _button(TAB_NAMES[index], Vector2(index * 125, 0), Vector2(115, 36), 15)
		tab.name = "MountTab%d" % index
		tab.pressed.connect(_select_tab.bind(index))
		tab_buttons.append(tab)
		content_root.add_child(tab)


func _refresh() -> void:
	var mount := PlayerData.get_mount_by_id(selected_mount_id)
	if mount.is_empty():
		return
	var active_id := str(PlayerData.player_data.get(PlayerData.ACTIVE_MOUNT_KEY, ""))
	var active := active_id == selected_mount_id
	var unlocked := PlayerData.is_mount_unlocked(selected_mount_id)
	var level := int(mount.get(DataKeys.LEVEL, 1))
	var level_limit := PlayerData.get_mount_level_limit()
	name_label.text = str(mount.get(DataKeys.ALT_NAME, "坐骑"))
	state_label.text = "未解锁" if not unlocked else "出战中" if active else "休息中"
	state_label.add_theme_color_override(
		"font_color",
		UiColorTokens.TEXT_DIM if not unlocked else UiColorTokens.TEXT_GOLD if active else UiColorTokens.TEXT_INFO
	)
	action_button.text = "解锁" if not unlocked else "休息" if active else "出战"
	train_button.disabled = not unlocked or level >= level_limit
	train_all_button.disabled = not unlocked or level >= level_limit
	var preview_mount_id := "1003100" if selected_mount_id == "1002200" else selected_mount_id
	preview.setup(preview_mount_id, "idle")
	preview.modulate = UiSurfaceTokens.PREVIEW_LOCKED_MODULATE if not unlocked else Color.WHITE
	_fit_preview()
	_refresh_content(mount)
	_refresh_mount_list()


func _refresh_content(mount: Dictionary) -> void:
	for child in content_root.get_children():
		if child is Control and child.name.begins_with("Page_"):
			content_root.remove_child(child)
			child.queue_free()
	for index in range(tab_buttons.size()):
		var selected := index == selected_tab
		tab_buttons[index].add_theme_color_override(
			"font_color", UiColorTokens.TEXT_GOLD if selected else UiColorTokens.TEXT_SECONDARY
		)
		tab_buttons[index].add_theme_stylebox_override(
			"normal",
			_style(
				UiSurfaceTokens.DANGER_SELECTED if selected else UiSurfaceTokens.COOL_CONTROL,
				UiSurfaceTokens.COOL_ACCENT_SOFT if selected else UiSurfaceTokens.COOL_BORDER,
				1,
				4
			)
		)
	var page := VBoxContainer.new()
	page.name = "Page_%d" % selected_tab
	page.position = Vector2(0, 53)
	page.size = Vector2(500, 420)
	page.add_theme_constant_override("separation", 10)
	content_root.add_child(page)
	match selected_tab:
		0:
			_build_attribute_page(page, mount)
		1:
			_build_equipment_page(page, mount)
		2:
			_build_soul_page(page, mount)


func _build_attribute_page(page: VBoxContainer, mount: Dictionary) -> void:
	if not bool(mount.get(PlayerData.MOUNT_UNLOCKED_KEY, false)):
		var unlock_requirement := PlayerData.get_mount_unlock_requirement(str(mount.get("ID", "")))
		var item_id := str(unlock_requirement.get("物品", ""))
		var needed := maxi(1, int(unlock_requirement.get(DataKeys.COUNT, 1)))
		var item_data := EquipmentService.data_or_empty(StringName(item_id))
		var owned := PlayerData.get_inventory_item_count(item_id)
		var unlock_row := HBoxContainer.new()
		unlock_row.name = "MountUnlockRequirement"
		unlock_row.custom_minimum_size = Vector2(500, 62)
		unlock_row.add_theme_constant_override("separation", 12)
		var icon_path := str(item_data.get("图标", "res://Art/backpack/all_items/%s.png" % item_id))
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(54, 54)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path) as Texture2D
		unlock_row.add_child(icon)
		var info := VBoxContainer.new()
		info.add_theme_constant_override("separation", 2)
		info.add_child(
			_label(
				"解锁材料：%s  %d/%d" % [str(item_data.get(DataKeys.NAME, item_id)), owned, needed],
				Vector2.ZERO,
				Vector2(420, 26),
				15,
				UiColorTokens.TEXT_GOLD if owned >= needed else UiColorTokens.TEXT_WARNING_SOFT,
				HORIZONTAL_ALIGNMENT_LEFT
			)
		)
		info.add_child(
			_label(
				str(item_data.get("描述", "获得对应材料后可解锁坐骑")),
				Vector2.ZERO,
				Vector2(420, 24),
				13,
				UiColorTokens.TEXT_HINT,
				HORIZONTAL_ALIGNMENT_LEFT
			)
		)
		unlock_row.add_child(info)
		page.add_child(unlock_row)
		page.add_child(
			_label(
				"点击左侧“解锁”按钮消耗材料",
				Vector2.ZERO,
				Vector2(500, 28),
				14,
				UiColorTokens.TEXT_HINT,
				HORIZONTAL_ALIGNMENT_CENTER
			)
		)
		return
	var summary := HBoxContainer.new()
	summary.name = "MountAttributeSummary"
	summary.custom_minimum_size = Vector2(500, 34)
	summary.add_theme_constant_override("separation", 16)
	summary.add_child(
		_label("基础属性", Vector2.ZERO, Vector2(170, 34), 19, UiColorTokens.TEXT_GOLD, HORIZONTAL_ALIGNMENT_LEFT)
	)
	summary.add_child(
		_label(
			"等级  Lv.%d" % int(mount.get(DataKeys.LEVEL, 1)),
			Vector2.ZERO,
			Vector2(130, 34),
			15,
			UiColorTokens.TEXT_HINT,
			HORIZONTAL_ALIGNMENT_LEFT
		)
	)
	page.add_child(summary)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.custom_minimum_size = Vector2(500, 105)
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 5)
	var stats := {
		"生命": mount.get(DataKeys.HP, 0),
		"攻击": mount.get(DataKeys.ATTACK, 0),
		"物防": mount.get("物防", 0),
		"魔防": mount.get("魔防", 0),
		"回血": mount.get("回血", 0),
		"暴击": int(mount.get("暴击", 0)),
		"命中": int(mount.get("命中", 0)),
		"闪避": int(mount.get("闪避", 0)),
		"幸运": mount.get("幸运", 0),
		"破魔": mount.get("破魔", 0)
	}
	for key in stats.keys():
		grid.add_child(
			_label(
				"%s：%s" % [key, str(stats[key])],
				Vector2.ZERO,
				Vector2(230, 24),
				15,
				UiColorTokens.TEXT_HINT,
				HORIZONTAL_ALIGNMENT_LEFT
			)
		)
	page.add_child(grid)
	var qualification_header := HBoxContainer.new()
	qualification_header.name = "MountQualificationHeader"
	qualification_header.custom_minimum_size = Vector2(500, 30)
	qualification_header.add_theme_constant_override("separation", 8)
	var qualification_title := _label(
		"资质", Vector2.ZERO, Vector2(58, 28), 17, UiColorTokens.TEXT_GOLD, HORIZONTAL_ALIGNMENT_LEFT
	)
	qualification_title.custom_minimum_size = Vector2(58, 28)
	qualification_header.add_child(qualification_title)
	var requirement := PlayerData.get_mount_unlock_requirement(str(mount.get("ID", "")))
	var material_id := str(requirement.get("物品", ""))
	var material_data := EquipmentService.data_or_empty(StringName(material_id))
	var material_name := str(material_data.get(DataKeys.NAME, material_id))
	var material_count := PlayerData.get_inventory_item_count(material_id)
	var material_label := _label(
		"%s：%d" % [material_name, material_count],
		Vector2.ZERO,
		Vector2(270, 28),
		13,
		UiColorTokens.TEXT_HINT,
		HORIZONTAL_ALIGNMENT_RIGHT
	)
	material_label.custom_minimum_size = Vector2(270, 28)
	qualification_header.add_child(material_label)
	var qualification_button := _button("提升资质", Vector2.ZERO, Vector2(118, 28), 13)
	qualification_button.name = "MountQualificationButton"
	qualification_button.custom_minimum_size = Vector2(118, 28)
	qualification_button.tooltip_text = "消耗1个%s，随机一项资质增加100-150" % material_name
	qualification_button.disabled = PlayerData.MOUNT_QUALIFICATION_KEYS.all(
		func(key): return int(mount.get(key, 0)) >= PlayerData.MOUNT_QUALIFICATION_MAX
	)
	qualification_button.pressed.connect(_train_mount_qualification)
	qualification_header.add_child(qualification_button)
	page.add_child(qualification_header)
	var qual := VBoxContainer.new()
	qual.add_theme_constant_override("separation", 5)
	for key in ["生命资质", "攻击资质", "防御资质"]:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(500, 21)
		row.add_child(
			_label(key, Vector2.ZERO, Vector2(80, 24), 14, UiColorTokens.TEXT_HINT, HORIZONTAL_ALIGNMENT_LEFT)
		)
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(315, 18)
		bar.show_percentage = false
		bar.max_value = maxi(1, int(mount.get("%s上限" % key, 1)))
		bar.value = int(mount.get(key, 0))
		bar.add_theme_stylebox_override(
			"background", _style(UiSurfaceTokens.COOL_DEEP, UiSurfaceTokens.COOL_BORDER_DIM, 1, 4)
		)
		bar.add_theme_stylebox_override(
			"fill", _style(UiSurfaceTokens.COOL_PROGRESS, UiSurfaceTokens.COOL_BORDER_SOFT, 1, 4)
		)
		row.add_child(bar)
		row.add_child(
			_label(
				"%d/%d" % [int(bar.value), int(bar.max_value)],
				Vector2.ZERO,
				Vector2(85, 24),
				13,
				UiColorTokens.TEXT_HINT,
				HORIZONTAL_ALIGNMENT_RIGHT
			)
		)
		qual.add_child(row)
	page.add_child(qual)
	page.add_child(_label("技能", Vector2.ZERO, Vector2(500, 22), 17, UiColorTokens.TEXT_GOLD, HORIZONTAL_ALIGNMENT_LEFT))
	var skills_row := HBoxContainer.new()
	skills_row.add_theme_constant_override("separation", 10)
	var skills_value: Variant = mount.get("技能", [])
	var skills: Array = skills_value if skills_value is Array else []
	for skill_value in skills:
		var skill: Dictionary = skill_value if skill_value is Dictionary else {}
		var holder := VBoxContainer.new()
		holder.custom_minimum_size = Vector2(92, 100)
		holder.add_theme_constant_override("separation", 2)
		var icon_frame := PanelContainer.new()
		icon_frame.name = "MountSkillFrame_%s" % str(skill.get("id", ""))
		icon_frame.custom_minimum_size = Vector2(58, 58)
		icon_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon_frame.tooltip_text = "%s\n%s" % [str(skill.get("name", "技能")), str(skill.get("description", ""))]
		icon_frame.add_theme_stylebox_override(
			"panel", _style(UiSurfaceTokens.COOL_ICON_BG, UiSurfaceTokens.COOL_ACCENT, 2, 4)
		)
		var skill_button := Button.new()
		skill_button.name = "MountSkillButton_%s" % str(skill.get("id", ""))
		skill_button.custom_minimum_size = Vector2(54, 54)
		skill_button.focus_mode = Control.FOCUS_NONE
		skill_button.flat = true
		skill_button.expand_icon = true
		skill_button.tooltip_text = icon_frame.tooltip_text
		skill_button.pressed.connect(_open_skill_upgrade_popup.bind(skill.duplicate(true)))
		var path := MOUNT_CATALOG.get_icon_path(str(skill.get("id", "")))
		if path != "":
			skill_button.icon = load(path) as Texture2D
		else:
			skill_button.text = "缺图"
			skill_button.add_theme_font_override("font", UI_FONT)
			skill_button.add_theme_font_size_override("font_size", 12)
		icon_frame.add_child(skill_button)
		holder.add_child(icon_frame)
		holder.add_child(
			_label(
				str(skill.get("name", "技能")),
				Vector2.ZERO,
				Vector2(92, 20),
				11,
				UiColorTokens.TEXT_HINT,
				HORIZONTAL_ALIGNMENT_CENTER
			)
		)
		var skill_level := PlayerData.get_mount_skill_level(str(mount.get("ID", "")), str(skill.get("id", "")))
		holder.add_child(
			_label(
				"Lv.%d" % skill_level,
				Vector2.ZERO,
				Vector2(92, 18),
				11,
				UiColorTokens.TEXT_GOLD,
				HORIZONTAL_ALIGNMENT_CENTER
			)
		)
		skills_row.add_child(holder)
	page.add_child(skills_row)


func _open_skill_upgrade_popup(skill: Dictionary) -> void:
	if not PlayerData.is_mount_unlocked(selected_mount_id):
		_show_message("请先解锁坐骑")
		return
	var skill_id := str(skill.get("id", ""))
	var skill_level := PlayerData.get_mount_skill_level(selected_mount_id, skill_id)
	if skill_id == "" or skill_level <= 0:
		_show_message("坐骑技能数据无效")
		return
	_close_skill_upgrade_popup()
	if mount_list != null:
		mount_list.visible = false
	skill_popup = Control.new()
	skill_popup.name = "MountSkillUpgradePopup"
	skill_popup.position = Vector2.ZERO
	skill_popup.size = PANEL_SIZE
	skill_popup.z_index = 2000
	skill_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	panel_root.add_child(skill_popup)
	var shade := ColorRect.new()
	shade.color = UiSurfaceTokens.OVERLAY_STRONG
	shade.size = PANEL_SIZE
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	skill_popup.add_child(shade)
	var popup_frame := Panel.new()
	popup_frame.name = "MountSkillUpgradeFrame"
	popup_frame.position = Vector2(190, 82)
	popup_frame.size = Vector2(520, 426)
	popup_frame.add_theme_stylebox_override(
		"panel", _style(UiSurfaceTokens.COOL_DEEP, UiSurfaceTokens.COOL_ACCENT_BRIGHT, 2, 7)
	)
	skill_popup.add_child(popup_frame)
	popup_frame.add_child(
		_label("技能升级", Vector2(24, 12), Vector2(410, 38), 25, UiColorTokens.TEXT_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	)
	var close := _button("×", Vector2(454, 12), Vector2(44, 36), 23)
	close.name = "MountSkillPopupClose"
	close.pressed.connect(_close_skill_upgrade_popup)
	popup_frame.add_child(close)
	var icon_frame := PanelContainer.new()
	icon_frame.position = Vector2(28, 70)
	icon_frame.size = Vector2(84, 84)
	icon_frame.add_theme_stylebox_override(
		"panel", _style(UiSurfaceTokens.COOL_DEEPEST, UiSurfaceTokens.COOL_ACCENT, 2, 5)
	)
	popup_frame.add_child(icon_frame)
	var icon_path := MOUNT_CATALOG.get_icon_path(skill_id)
	if icon_path != "":
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(80, 80)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture = load(icon_path) as Texture2D
		icon_frame.add_child(icon)
	popup_frame.add_child(
		_label(
			str(skill.get("name", "技能")),
			Vector2(132, 67),
			Vector2(354, 34),
			21,
			UiColorTokens.TEXT_GOLD,
			HORIZONTAL_ALIGNMENT_LEFT
		)
	)
	var description := _label(
		str(skill.get("description", "")),
		Vector2(132, 101),
		Vector2(354, 60),
		14,
		UiColorTokens.TEXT_HINT,
		HORIZONTAL_ALIGNMENT_LEFT
	)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	popup_frame.add_child(description)
	popup_frame.add_child(
		_label(
			"当前等级：Lv.%d / %d" % [skill_level, PlayerData.MOUNT_SKILL_MAX_LEVEL],
			Vector2(132, 163),
			Vector2(354, 28),
			16,
			UiColorTokens.TEXT_GOLD,
			HORIZONTAL_ALIGNMENT_LEFT
		)
	)
	var damage_panel := Panel.new()
	damage_panel.position = Vector2(24, 201)
	damage_panel.size = Vector2(472, 126)
	damage_panel.add_theme_stylebox_override(
		"panel", _style(UiSurfaceTokens.COOL_PANEL_ALT, UiSurfaceTokens.COOL_DAMAGE_BORDER, 1, 4)
	)
	popup_frame.add_child(damage_panel)
	var combat := MOUNT_CATALOG.get_official_combat(skill_id)
	var is_buff := bool(combat.get("buff", false)) or str(skill.get("kind", "")) == "buff"
	var next_level := mini(PlayerData.MOUNT_SKILL_MAX_LEVEL, skill_level + 1)
	if is_buff:
		damage_panel.add_child(
			_label(
				"当前技能伤害：无直接伤害", Vector2(16, 7), Vector2(440, 28), 15, UiColorTokens.TEXT_HINT, HORIZONTAL_ALIGNMENT_LEFT
			)
		)
		damage_panel.add_child(
			_label(
				"升级后技能伤害：无直接伤害",
				Vector2(16, 38),
				Vector2(440, 28),
				15,
				UiColorTokens.TEXT_JADE,
				HORIZONTAL_ALIGNMENT_LEFT
			)
		)
		damage_panel.add_child(
			_label(
				"该技能为强化效果，数值按官方固定效果执行",
				Vector2(16, 74),
				Vector2(440, 38),
				13,
				UiColorTokens.TEXT_HINT_DIM,
				HORIZONTAL_ALIGNMENT_LEFT
			)
		)
	else:
		var current_multiplier := PlayerData.get_mount_skill_damage_multiplier(selected_mount_id, skill_id, skill_level)
		var next_multiplier := PlayerData.get_mount_skill_damage_multiplier(selected_mount_id, skill_id, next_level)
		var role_prop: Node = RoleProp
		var role_data_value: Variant = role_prop.get("roleprop") if role_prop != null else {}
		var role_data: Dictionary = role_data_value if role_data_value is Dictionary else {}
		var attack_value := maxi(0, int(role_data.get("power", 0)))
		var current_damage := int(round(float(attack_value) * current_multiplier))
		var next_damage := int(round(float(attack_value) * next_multiplier))
		damage_panel.add_child(
			_label(
				"当前技能伤害：攻击 × %.4f（约 %d/段）" % [current_multiplier, current_damage],
				Vector2(16, 7),
				Vector2(440, 28),
				15,
				UiColorTokens.TEXT_HINT,
				HORIZONTAL_ALIGNMENT_LEFT
			)
		)
		damage_panel.add_child(
			_label(
				"升级后技能伤害：攻击 × %.4f（约 %d/段）" % [next_multiplier, next_damage],
				Vector2(16, 38),
				Vector2(440, 28),
				15,
				UiColorTokens.TEXT_JADE,
				HORIZONTAL_ALIGNMENT_LEFT
			)
		)
		var hits := int(combat.get("hits", 1))
		var hit_text := "伤害段数：持续命中" if hits >= 999 else "伤害段数：%d段" % maxi(1, hits)
		damage_panel.add_child(
			_label(
				hit_text, Vector2(16, 69), Vector2(210, 28), 14, UiColorTokens.TEXT_HINT_DIM, HORIZONTAL_ALIGNMENT_LEFT
			)
		)
		if hits > 1 and hits < 999:
			damage_panel.add_child(
				_label(
					"理论总伤害：%d → %d" % [current_damage * hits, next_damage * hits],
					Vector2(220, 69),
					Vector2(236, 28),
					14,
					UiColorTokens.TEXT_HINT_DIM,
					HORIZONTAL_ALIGNMENT_RIGHT
				)
			)
	var cost := PlayerData.get_mount_skill_upgrade_cost(selected_mount_id, skill_id)
	var cost_text := (
		"已达到最高等级"
		if skill_level >= PlayerData.MOUNT_SKILL_MAX_LEVEL
		else "消耗灵魂：%d    当前灵魂：%d" % [cost, PlayerData.get_soul()]
	)
	popup_frame.add_child(
		_label(cost_text, Vector2(24, 334), Vector2(472, 28), 15, UiColorTokens.TEXT_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	)
	var upgrade := _button(
		"已满级" if skill_level >= PlayerData.MOUNT_SKILL_MAX_LEVEL else "升级", Vector2(190, 371), Vector2(140, 38), 16
	)
	upgrade.name = "MountSkillUpgradeButton"
	upgrade.disabled = skill_level >= PlayerData.MOUNT_SKILL_MAX_LEVEL
	upgrade.pressed.connect(_upgrade_mount_skill.bind(skill_id))
	popup_frame.add_child(upgrade)


func _close_skill_upgrade_popup() -> void:
	if skill_popup == null or not is_instance_valid(skill_popup):
		skill_popup = null
		return
	var parent := skill_popup.get_parent()
	if parent != null:
		parent.remove_child(skill_popup)
	skill_popup.queue_free()
	skill_popup = null


func _upgrade_mount_skill(skill_id: String) -> void:
	var skill_level := PlayerData.get_mount_skill_level(selected_mount_id, skill_id)
	if skill_level >= PlayerData.MOUNT_SKILL_MAX_LEVEL:
		_show_message("技能已达到20级")
		return
	var cost := PlayerData.get_mount_skill_upgrade_cost(selected_mount_id, skill_id)
	if PlayerData.get_soul() < cost:
		_show_message("灵魂不足，需要 %d" % cost)
		return
	if not PlayerData.upgrade_mount_skill(selected_mount_id, skill_id):
		_show_message("技能升级失败")
		return
	_show_message("技能升级成功")
	var mount := PlayerData.get_mount_by_id(selected_mount_id)
	var selected_skill := _find_mount_skill(mount, skill_id)
	_refresh_content(mount)
	if not selected_skill.is_empty():
		_open_skill_upgrade_popup(selected_skill)


func _find_mount_skill(mount: Dictionary, skill_id: String) -> Dictionary:
	var skills_value: Variant = mount.get("技能", [])
	if not (skills_value is Array):
		return {}
	for skill_value in skills_value:
		if skill_value is Dictionary and str((skill_value as Dictionary).get("id", "")) == skill_id:
			return (skill_value as Dictionary).duplicate(true)
	return {}


func _fit_preview() -> void:
	var bounds: Rect2 = preview.get_animation_visual_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		preview.position = preview_host.size * 0.5
		preview.scale = Vector2.ONE
		return
	var available := preview_host.size - Vector2(28, 28)
	var fit_scale := minf(available.x / bounds.size.x, available.y / bounds.size.y)
	fit_scale = clampf(fit_scale, 0.35, 1.15)
	preview.scale = Vector2(fit_scale, fit_scale)
	preview.position = preview_host.size * 0.5 - (bounds.position + bounds.size * 0.5) * fit_scale


func _build_equipment_page(_page: VBoxContainer, _mount: Dictionary) -> void:
	pass


func _build_soul_page(_page: VBoxContainer, _mount: Dictionary) -> void:
	pass


func _select_tab(index: int) -> void:
	_close_skill_upgrade_popup()
	selected_tab = clampi(index, 0, TAB_NAMES.size() - 1)
	var mount := PlayerData.get_mount_by_id(selected_mount_id)
	if not mount.is_empty():
		_refresh_content(mount)


func _build_mount_list() -> void:
	mount_list = Panel.new()
	mount_list.name = "MountChangeList"
	mount_list.position = Vector2(30, 100)
	mount_list.size = Vector2(205, 300)
	mount_list.z_index = 1000
	mount_list.mouse_filter = Control.MOUSE_FILTER_STOP
	mount_list.visible = false
	mount_list.add_theme_stylebox_override(
		"panel", _style(UiSurfaceTokens.COOL_PANEL, UiSurfaceTokens.COOL_ACCENT, 2, 4)
	)
	panel_root.add_child(mount_list)
	var mounts := _mounts_for_panel()
	for index in range(mounts.size()):
		var row := _button("", Vector2(8, 8 + index * 39), Vector2(189, 32), 13)
		row.name = "MountListRow%d" % index
		row.pressed.connect(_select_mount_row.bind(index))
		mount_list.add_child(row)
		mount_list_rows.append(row)
		var label := _label("", Vector2(8, 0), Vector2(173, 32), 13, UiColorTokens.TEXT_HINT, HORIZONTAL_ALIGNMENT_LEFT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(label)
		mount_list_labels.append(label)


func _toggle_mount_list() -> void:
	if not mount_list.visible:
		_close_skill_upgrade_popup()
	mount_list.visible = not mount_list.visible
	if mount_list.visible:
		mount_list.move_to_front()
		_refresh_mount_list()


func _refresh_mount_list() -> void:
	if mount_list == null:
		return
	var mounts := _mounts_for_panel()
	var active_id := str(PlayerData.player_data.get(PlayerData.ACTIVE_MOUNT_KEY, ""))
	for index in range(mount_list_rows.size()):
		var row := mount_list_rows[index]
		var has := index < mounts.size() and mounts[index] is Dictionary
		row.visible = has
		if not has:
			continue
		var mount: Dictionary = mounts[index]
		var id := str(mount.get("ID", ""))
		var suffix := (
			"  [出战]"
			if id == active_id
			else "  [未解锁]" if not bool(mount.get(PlayerData.MOUNT_UNLOCKED_KEY, false)) else ""
		)
		mount_list_labels[index].text = "%s%s" % [str(mount.get(DataKeys.ALT_NAME, "坐骑")), suffix]
		row.modulate = UiColorTokens.TEXT_GOLD if id == selected_mount_id else UiColorTokens.TEXT_PRIMARY


func _select_mount_row(index: int) -> void:
	var mounts := _mounts_for_panel()
	if index < 0 or index >= mounts.size() or not mounts[index] is Dictionary:
		return
	_close_skill_upgrade_popup()
	selected_mount_id = str((mounts[index] as Dictionary).get("ID", ""))
	mount_list.visible = false
	_refresh()


func _mounts_for_panel() -> Array:
	var result: Array = []
	for mount_value in PlayerData.ensure_mount_data():
		if not (mount_value is Dictionary):
			continue
		if HIDDEN_MOUNT_IDS.has(str((mount_value as Dictionary).get("ID", ""))):
			continue
		result.append(mount_value)
	return result


func _toggle_active_mount() -> void:
	var mount := PlayerData.get_mount_by_id(selected_mount_id)
	if mount.is_empty():
		return
	if not PlayerData.is_mount_unlocked(selected_mount_id):
		var requirement := PlayerData.get_mount_unlock_requirement(selected_mount_id)
		var item_id := str(requirement.get("物品", ""))
		var needed := maxi(1, int(requirement.get(DataKeys.COUNT, 1)))
		var item_data := EquipmentService.data_or_empty(StringName(item_id))
		var item_name := str(item_data.get(DataKeys.NAME, item_id))
		var owned := PlayerData.get_inventory_item_count(item_id)
		if item_id == "":
			_show_message("该坐骑暂未配置解锁材料")
			return
		if owned < needed:
			_show_message("缺少%s（%d/%d）" % [item_name, owned, needed])
			return
		if PlayerData.unlock_mount(selected_mount_id):
			_show_message("%s解锁成功" % str(mount.get(DataKeys.ALT_NAME, "坐骑")))
		else:
			_show_message("坐骑解锁失败")
		_refresh()
		return
	var active_id := str(PlayerData.player_data.get(PlayerData.ACTIVE_MOUNT_KEY, ""))
	PlayerData.set_active_mount("" if active_id == selected_mount_id else selected_mount_id)
	RoleProp.get_last_prop()
	RoleProp.check_hp()
	RoleProp.check_mp()
	_show_message("已休息" if active_id == selected_mount_id else "已出战")
	_refresh()


func _train_mount() -> void:
	var mount := PlayerData.get_mount_by_id(selected_mount_id)
	if mount.is_empty():
		return
	if not PlayerData.is_mount_unlocked(selected_mount_id):
		_show_message("请先解锁坐骑")
		return
	var level := int(mount.get(DataKeys.LEVEL, 1))
	var level_limit := PlayerData.get_mount_level_limit()
	if level >= level_limit:
		_show_message("坐骑等级不能超过人物当前等级")
		return
	var cost := maxi(500, level * 500)
	if PlayerData.get_soul() < cost:
		_show_message("灵魂不足，需要 %d" % cost)
		return
	PlayerData.set_soul(PlayerData.get_soul() - cost)
	PlayerData.add_mount_exp(
		selected_mount_id, maxi(1, PlayerData.mount_exp_for_level(level) - int(mount.get(DataKeys.EXP, 0)))
	)
	_show_message("升级成功，属性已更新")
	_refresh()


func _train_mount_all() -> void:
	var result := PlayerData.upgrade_mount_to_level_limit(selected_mount_id)
	if bool(result.get("success", false)):
		_show_message(
			(
				"一键升级 Lv.%d→Lv.%d，消耗%d灵魂"
				% [int(result.get("old_level", 1)), int(result.get("level", 1)), int(result.get("cost", 0))]
			)
		)
		_refresh()
		return
	var reason := str(result.get("reason", ""))
	if reason == "locked":
		_show_message("请先解锁坐骑")
	elif reason == "max":
		_show_message("坐骑等级已达到人物当前等级")
	else:
		_show_message("灵魂不足，下一等级需要%d" % int(result.get("need", 0)))


func _train_mount_qualification() -> void:
	var mount := PlayerData.get_mount_by_id(selected_mount_id)
	if mount.is_empty():
		return
	if not PlayerData.is_mount_unlocked(selected_mount_id):
		_show_message("请先解锁坐骑")
		return
	var result := PlayerData.upgrade_mount_random_qualification(selected_mount_id)
	if bool(result.get("success", false)):
		_show_message(
			(
				"%s +%d（%d/%d）"
				% [
					str(result.get("stat", "资质")),
					int(result.get("gain", 0)),
					int(result.get("value", 0)),
					PlayerData.MOUNT_QUALIFICATION_MAX
				]
			)
		)
		_refresh()
		return
	var reason := str(result.get("reason", ""))
	if reason == "max":
		_show_message("三项资质均已达到%d" % PlayerData.MOUNT_QUALIFICATION_MAX)
		return
	var requirement := PlayerData.get_mount_unlock_requirement(selected_mount_id)
	var material_id := str(requirement.get("物品", result.get("item_id", "")))
	var material_data := EquipmentService.data_or_empty(StringName(material_id))
	_show_message("缺少%s" % str(material_data.get(DataKeys.NAME, material_id)))


func _show_message(text_value: String) -> void:
	message_label.text = text_value
	message_timer = 3.0


func _process(delta: float) -> void:
	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0 and is_instance_valid(message_label):
			message_label.text = ""


func _label(
	text_value: String,
	position_value: Vector2,
	size_value: Vector2,
	font_size: int,
	color: Color,
	alignment: HorizontalAlignment
) -> Label:
	var label := Label.new()
	label.position = position_value
	label.size = size_value
	label.text = text_value
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", UI_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", UiColorTokens.OUTLINE_NIGHT)
	label.add_theme_constant_override("outline_size", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(text_value: String, position_value: Vector2, size_value: Vector2, font_size: int) -> Button:
	var button := Button.new()
	button.position = position_value
	button.size = size_value
	button.text = text_value
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", UI_FONT)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", UiColorTokens.TEXT_SECONDARY)
	button.add_theme_color_override("font_hover_color", UiColorTokens.TEXT_PRIMARY)
	button.add_theme_stylebox_override(
		"normal", _style(UiSurfaceTokens.COOL_CONTROL, UiSurfaceTokens.COOL_BORDER, 1, 4)
	)
	button.add_theme_stylebox_override(
		"hover", _style(UiSurfaceTokens.COOL_HOVER, UiSurfaceTokens.COOL_BORDER_BRIGHT, 1, 4)
	)
	button.add_theme_stylebox_override(
		"pressed", _style(UiSurfaceTokens.COOL_PRESSED, UiSurfaceTokens.COOL_BORDER_SOFT, 1, 4)
	)
	return button


func _style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	return style

extends Control

const STAGE_SIZE := Vector2(941, 591)
const ACTIVE_KEY := "主线剑阵出战"
const LEVEL_KEY := "主线剑阵等级"
const DEFAULT_ACTIVE_SWORD := ""
const SWORD_IDS := ["zhuxianjian", "xianxianjian", "sijianheyi", "luxianjian", "juexianjian"]
const SINGLE_SWORD_IDS := ["zhuxianjian", "xianxianjian", "luxianjian", "juexianjian"]
const SWORD_NAMES := ["诛仙剑", "陷仙剑", "四剑归一", "戮仙剑", "绝仙剑"]
const MAX_SWORD_LEVEL := 45
const CARD_WIDTH := 160.0
const MATERIAL_ICON_VISIBLE_LEFT := 14.0
const MATERIAL_ICON_VISIBLE_WIDTH := 22.0
const MATERIAL_ROW_GAP := 4.0
const SWORD_UPGRADE_MATERIALS := {
	"zhuxianjian":
	[
		{"code": "zxjp", "name": "诛仙剑魄", "count": 1},
		{"code": "zxjh", "name": "诛仙剑魂", "count": 1},
	],
	"xianxianjian":
	[
		{"code": "xxjp", "name": "陷仙剑魄", "count": 1},
		{"code": "zxjh", "name": "诛仙剑魂", "count": 1},
	],
	"luxianjian":
	[
		{"code": "lxjp", "name": "戮仙剑魄", "count": 1},
		{"code": "zxjh", "name": "诛仙剑魂", "count": 1},
	],
	"juexianjian":
	[
		{"code": "jxjp", "name": "绝仙剑魄", "count": 1},
		{"code": "zxjh", "name": "诛仙剑魂", "count": 1},
	],
	"sijianheyi":
	[
		{"code": "zxjp", "name": "诛仙剑魄", "count": 1},
		{"code": "xxjp", "name": "陷仙剑魄", "count": 1},
		{"code": "lxjp", "name": "戮仙剑魄", "count": 1},
		{"code": "jxjp", "name": "绝仙剑魄", "count": 1},
		{"code": "zxjh", "name": "诛仙剑魂", "count": 1},
	],
}
const BATTLE_TEXT := preload("res://Art/zhuxianjianzhen/zhu_xian_sword/images/76.png")
const REST_TEXT := preload("res://Art/zhuxianjianzhen/zhu_xian_sword/images/79.png")

@onready var _stage: Control = $Stage


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_bind_upgrade_buttons()
	_layout_stage()
	if not get_viewport().size_changed.is_connected(_layout_stage):
		get_viewport().size_changed.connect(_layout_stage)
	_ensure_state()
	_refresh_state()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()


func _layout_stage() -> void:
	if _stage == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	_stage.scale = Vector2.ONE
	_stage.position = (viewport_size - STAGE_SIZE) * 0.5


func _on_close_pressed() -> void:
	queue_free()


func _bind_upgrade_buttons() -> void:
	for i in range(SWORD_IDS.size()):
		var button := get_node_or_null("Stage/SwordCard" + str(i + 1) + "/UpgradeButton") as TextureButton
		if button == null:
			continue
		var old_callable := Callable(self, "_on_upgrade_pressed")
		if button.pressed.is_connected(old_callable):
			button.pressed.disconnect(old_callable)
		var new_callable := Callable(self, "_on_upgrade_pressed").bind(i)
		if not button.pressed.is_connected(new_callable):
			button.pressed.connect(new_callable)


func _on_upgrade_pressed(index: int = 0) -> void:
	_try_upgrade_sword(index)


func _on_action_1_pressed() -> void:
	_toggle_sword(0)


func _on_action_2_pressed() -> void:
	_toggle_sword(1)


func _on_action_3_pressed() -> void:
	_toggle_sword(2)


func _on_action_4_pressed() -> void:
	_toggle_sword(3)


func _on_action_5_pressed() -> void:
	_toggle_sword(4)


func _ensure_state() -> void:
	if PlayerData != null and PlayerData.has_method("ensure_main_sword_array"):
		PlayerData.ensure_main_sword_array()
	if not PlayerData.player_data.has(ACTIVE_KEY):
		PlayerData.player_data[ACTIVE_KEY] = DEFAULT_ACTIVE_SWORD
	var active := str(PlayerData.player_data.get(ACTIVE_KEY, ""))
	if active != "" and (not SWORD_IDS.has(active) or _get_level(active) < 1):
		PlayerData.player_data[ACTIVE_KEY] = DEFAULT_ACTIVE_SWORD


func _toggle_sword(index: int) -> void:
	if index < 0 or index >= SWORD_IDS.size():
		return
	_ensure_state()
	var sword_id: String = SWORD_IDS[index]
	var sword_name: String = SWORD_NAMES[index]
	if _get_level(sword_id) < 1:
		return
	var is_active: bool = str(PlayerData.player_data.get(ACTIVE_KEY, "")) == sword_id
	if is_active:
		PlayerData.player_data[ACTIVE_KEY] = ""
		_show_message(str(sword_name) + "已休战")
	else:
		PlayerData.player_data[ACTIVE_KEY] = sword_id
		_show_message(str(sword_name) + "已出战")
	_apply_role_prop()
	_save_if_possible()
	_refresh_state()


func _refresh_state() -> void:
	_ensure_state()
	var active := str(PlayerData.player_data.get(ACTIVE_KEY, ""))
	for i in range(SWORD_IDS.size()):
		var sword_id: String = SWORD_IDS[i]
		var card := get_node_or_null("Stage/SwordCard" + str(i + 1))
		if card == null:
			continue
		var level := _get_level(sword_id)
		var can_battle := level >= 1
		var can_upgrade := _can_upgrade_sword(sword_id, level)
		var selected: bool = active == sword_id and can_battle
		_set_card_level(card, level)
		_set_card_stats(card, sword_id, level)
		_set_card_material_text(card, sword_id, level)
		var stamp := card.get_node_or_null("BattleStamp") as CanvasItem
		if stamp != null:
			stamp.visible = selected
		var action_button := card.get_node_or_null("ActionButton") as TextureButton
		if action_button != null:
			action_button.disabled = not can_battle
			action_button.modulate = Color(1, 1, 1, 1) if can_battle else Color(0.62, 0.62, 0.62, 1)
		var text := card.get_node_or_null("ActionButton/text_str") as TextureRect
		if text != null:
			text.texture = REST_TEXT if selected else BATTLE_TEXT
		var upgrade_button := card.get_node_or_null("UpgradeButton") as TextureButton
		if upgrade_button != null:
			upgrade_button.disabled = not can_upgrade
			upgrade_button.modulate = Color(1, 1, 1, 1) if can_upgrade else Color(0.62, 0.62, 0.62, 1.0)


func _set_card_level(card: Node, level: int) -> void:
	var label := card.get_node_or_null("Level") as Label
	if label != null:
		label.text = "Lv." + str(level)


func _set_card_stats(card: Node, sword_id: String, level: int) -> void:
	for i in range(5):
		_set_stat(card, i, "")
	match sword_id:
		"zhuxianjian":
			_set_stat(card, 0, "攻击: " + str(level * 150))
		"xianxianjian":
			_set_stat(card, 0, "生命: " + str(level * 500))
		"sijianheyi":
			_set_stat(card, 0, "暴击: " + str(level * 10))
			_set_stat(card, 1, "命中: " + str(level * 10))
			_set_stat(card, 2, "闪避: " + str(level * 5))
			_set_stat(card, 3, "幸运: " + str(level * 5))
		"luxianjian":
			_set_stat(card, 0, "物防: " + str(level * 20))
			_set_stat(card, 1, "魔防: " + str(level * 20))
		"juexianjian":
			_set_stat(card, 0, "魔法: " + str(level * 400))


func _set_stat(card: Node, index: int, text: String) -> void:
	var label := card.get_node_or_null("Stat" + str(index)) as Label
	if label == null and index > 0:
		var base_label := card.get_node_or_null("Stat0") as Label
		if base_label != null:
			label = base_label.duplicate() as Label
			label.name = "Stat" + str(index)
			label.position = base_label.position + Vector2(0, 22 * index)
			card.add_child(label)
	if label != null:
		label.text = text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.position.x = (CARD_WIDTH - label.size.x) * 0.5


func _set_card_material_text(card: Node, sword_id: String, level: int) -> void:
	var materials: Array = _get_upgrade_materials(sword_id, level)
	_set_material_slot(card, 1, materials[0] if materials.size() > 0 else {})
	_set_material_slot(card, 2, materials[1] if materials.size() > 1 else {})


func _set_material_slot(card: Node, slot_index: int, material: Dictionary) -> void:
	var icon := card.get_node_or_null("MaterialIcon" + str(slot_index)) as TextureRect
	var label := card.get_node_or_null("MaterialText" + str(slot_index)) as Label
	var slot_y := 323.0 if slot_index == 1 else 348.0
	if icon != null:
		icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		icon.stretch_mode = TextureRect.STRETCH_SCALE
	if label != null:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var has_material := not material.is_empty()
	if icon != null:
		icon.visible = has_material
		if has_material:
			var texture := load(_get_material_icon_path(str(material.get("code", "")))) as Texture2D
			if texture != null:
				icon.texture = texture
	if label != null:
		label.visible = has_material
		if has_material:
			var code := str(material.get("code", ""))
			var need := int(material.get("count", 0))
			var have := _get_material_count(code)
			label.text = str(have) + "/" + str(need)
			label.add_theme_color_override("font_color", Color(0, 1, 0, 1) if have >= need else Color(1, 0, 0, 1))
			_center_material_row(card, icon, label, slot_y)


func _center_material_row(card: Node, icon: TextureRect, label: Label, slot_y: float) -> void:
	if icon == null or label == null:
		return
	var label_width := maxf(label.get_minimum_size().x, 1.0)
	label.size = Vector2(label_width, 24.0)
	var row_width := MATERIAL_ICON_VISIBLE_WIDTH + MATERIAL_ROW_GAP + label_width
	var row_left := (CARD_WIDTH - row_width) * 0.5
	icon.position = Vector2(row_left - MATERIAL_ICON_VISIBLE_LEFT, slot_y - 14.0)
	label.position = Vector2(row_left + MATERIAL_ICON_VISIBLE_WIDTH + MATERIAL_ROW_GAP, slot_y - 1.0)


func _format_material(material: Dictionary) -> String:
	return str(material.get("name", "")) + " x" + str(int(material.get("count", 0)))


func _format_materials(sword_id: String) -> String:
	var materials: Array = _get_upgrade_materials(sword_id, _get_level(sword_id))
	var parts: Array[String] = []
	for material in materials:
		if material is Dictionary:
			parts.append(_format_material(material))
	return "、".join(parts)


func _get_upgrade_materials(sword_id: String, level: int) -> Array:
	var base_materials: Array = SWORD_UPGRADE_MATERIALS.get(sword_id, [])
	var materials: Array = []
	var need_count := level + 2
	for material in base_materials:
		if material is Dictionary:
			var item := (material as Dictionary).duplicate()
			item["count"] = need_count
			materials.append(item)
	return materials


func _get_material_icon_path(code: String) -> String:
	return "res://Art/backpack/all_items/" + code + ".png"


func _get_material_count(code: String) -> int:
	if PlayerData != null and PlayerData.has_method("get_item_data"):
		return int(PlayerData.get_item_data(code))
	return 0


func _has_materials(sword_id: String) -> bool:
	var materials: Array = _get_upgrade_materials(sword_id, _get_level(sword_id))
	if materials.is_empty():
		return false
	for material in materials:
		if material is Dictionary:
			var code := str(material.get("code", ""))
			var need := int(material.get("count", 0))
			if _get_material_count(code) < need:
				return false
	return true


func _can_upgrade_sword(sword_id: String, level: int) -> bool:
	return SINGLE_SWORD_IDS.has(sword_id) and level < MAX_SWORD_LEVEL and _has_materials(sword_id)


func _try_upgrade_sword(index: int) -> void:
	if index < 0 or index >= SWORD_IDS.size():
		return
	_ensure_state()
	var sword_id: String = SWORD_IDS[index]
	var sword_name: String = SWORD_NAMES[index]
	var level := _get_level(sword_id)
	if not SINGLE_SWORD_IDS.has(sword_id):
		return
	if level >= MAX_SWORD_LEVEL:
		_show_message(str(sword_name) + "已满级")
		return
	if not _has_materials(sword_id):
		return
	var materials: Array = _get_upgrade_materials(sword_id, level)
	for material in materials:
		if material is Dictionary:
			var code := str(material.get("code", ""))
			var need := int(material.get("count", 0))
			if not PlayerData.remove_item(code, need):
				return
	PlayerData.player_data[LEVEL_KEY][sword_id] = level + 1
	_show_message(str(sword_name) + "升级成功")
	_apply_role_prop()
	_save_if_possible()
	_refresh_state()


func _get_level(sword_id: String) -> int:
	if PlayerData != null and PlayerData.has_method("get_main_sword_array_level"):
		return int(PlayerData.get_main_sword_array_level(sword_id))
	return 0


func _apply_role_prop() -> void:
	if LocalCoop.is_enabled():
		LocalCoop.refresh_main_sword_array()
		return
	if RoleProp != null:
		RoleProp.set_basic_prop()
		RoleProp.check_hp()
		RoleProp.check_mp()
		if RoleProp.source_player != null and RoleProp.source_player.has_method("jsfzsy"):
			RoleProp.source_player.jsfzsy()


func _save_if_possible() -> void:
	var save_path := str(Global.cd_path)
	if save_path != "" and save_path.contains("Ar_"):
		MemoryClass.request_save("zhu_xian_sword")
	else:
		MemoryClass.main_bc()


func _show_message(message: String) -> void:
	var parent: Node = self
	if Global.windows != null:
		parent = Global.windows
	Global.add_message_show(parent, message, 1.2, get_viewport().get_visible_rect().size * 0.5)

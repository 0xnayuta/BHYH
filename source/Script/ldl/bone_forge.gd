extends DivineForge
class_name BoneForge

const BONE_FIRE_IDS := ["shenhuo_1", "shenhuo_2", "shenhuo_3"]
const BONE_MAX_COUNT := 3


func _ready() -> void:
	super._ready()
	if has_node("Title"):
		$Title.text = "装备淬骨"
	if has_node("sz_"):
		$sz_.text = "淬骨"
	if has_node("need_lh"):
		$need_lh.visible = true


func _physics_process(_delta: float) -> void:
	n_q_1.is_in_ldl_gz = true
	n_q_2.is_in_ldl_gz = true
	old_zb.is_in_ldl_gz = true
	new_zb.is_in_ldl_gz = true
	var selected: Dictionary = _get_selected_slot()
	if selected.is_empty():
		_clear_display()
		return
	var equipment: Dictionary = selected.get("item", {})
	var item_name := str(equipment.get(DataKeys.NAME, ""))
	var data: Dictionary = equipment.get("data", {}) if equipment.get("data", {}) is Dictionary else {}
	var template: Dictionary = AE.all_equipment.get(item_name, {})
	var stage := int(data.get("淬骨次数", 0))
	var next_id := str(data.get("下一阶段", template.get("下一阶段", "")))
	var qh_level := int(equipment.get(DataKeys.ENHANCE_LEVEL, 0))
	old_zb_name = item_name

	var preview_id := item_name
	var preview_data: Dictionary = data.duplicate(true)
	_ensure_bone_strength_data(preview_data, item_name)
	_scale_bone_attributes(preview_data, 1.2)
	if stage + 1 >= BONE_MAX_COUNT:
		_bake_bone_strength_into_base(preview_data, qh_level, 2.0)
		_normalize_bone_attribute_signs(preview_data)
		preview_id = next_id
		new_zb_name = str(AE.all_equipment.get(next_id, {}).get(DataKeys.NAME, item_name))
		var preview_template: Dictionary = AE.all_equipment.get(next_id, {}).duplicate(true)
		for preview_key in preview_data:
			preview_template[preview_key] = preview_data[preview_key]
		preview_template[DataKeys.NAME] = str(AE.all_equipment.get(next_id, {}).get(DataKeys.NAME, item_name))
		preview_template["淬骨次数"] = BONE_MAX_COUNT
		preview_template.erase("下一阶段")
		preview_data = preview_template
	else:
		new_zb_name = item_name
	data = data
	old_zb.set_button_icon(load_item_icon(item_name))
	old_zb.get_item_name = item_name
	old_zb.eq_prop = data
	new_zb.set_button_icon(load_item_icon(preview_id))
	new_zb.get_item_name = preview_id
	new_zb.eq_prop = preview_data
	var selected_page := int(selected.get("page", 0))
	var selected_index := int(selected.get("index", -1))
	var selected_source := str(selected.get("source", "装备背包"))
	for slot in [old_zb, new_zb]:
		slot.qh_level = qh_level
		slot.current_page = selected_page
		slot.strength_source = selected_source
		slot.strength_index = selected_index
	if stage + 1 >= BONE_MAX_COUNT:
		new_zb.qh_level = 0
	var valid := (
		str(data.get(DataKeys.TYPE, template.get(DataKeys.TYPE, ""))) == "神骨"
		and next_id != ""
		and stage < BONE_MAX_COUNT
	)
	if not valid:
		n_q_1.set_button_icon(load_item_icon("empty"))
		n_q_1.get_item_name = "empty"
		n_q_1.eq_prop = {}
		n_q_2.set_button_icon(load_item_icon("empty"))
		n_q_2.get_item_name = "empty"
		n_q_2.eq_prop = {}
		num_b1.text = "已完成" if stage >= BONE_MAX_COUNT else "不可淬骨"
		num_b2.text = ""
		lh_text.text = ""
		return
	var fire_id: String = BONE_FIRE_IDS[stage]
	n_q_1.set_button_icon(load_item_icon(fire_id))
	n_q_1.get_item_name = fire_id
	n_q_1.eq_prop = AE.all_equipment.get(fire_id, {})
	n_q_1.total_number = 0
	var fire_count := _count_item_all_pages(fire_id)
	num_b1.text = str(fire_count) + "/3"
	_set_requirement_color(num_b1, fire_count >= 3)
	n_q_2.set_button_icon(load_item_icon("empty"))
	n_q_2.get_item_name = "empty"
	n_q_2.eq_prop = {}
	n_q_2.total_number = 0
	num_b2.text = ""
	lh_text.text = "成功率 50%"
	lh_text.position = Vector2(-170, -12)
	lh_text.size = Vector2(140, 26)
	lh_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lh_text.add_theme_color_override("font_color", Color("00FF00"))
	lh_text.add_theme_color_override("font_outline_color", Color("000000"))


func _on_sz_pressed() -> void:
	var selected: Dictionary = _get_selected_slot()
	if selected.is_empty():
		_show_message("请先选择一件神骨装备！")
		return
	var equipment: Dictionary = selected.get("item", {})
	var item_name := str(equipment.get(DataKeys.NAME, ""))
	var data: Dictionary = equipment.get("data", {}) if equipment.get("data", {}) is Dictionary else {}
	var template: Dictionary = AE.all_equipment.get(item_name, {})
	var next_id := str(data.get("下一阶段", template.get("下一阶段", "")))
	var stage := int(data.get("淬骨次数", 0))
	if str(data.get(DataKeys.TYPE, template.get(DataKeys.TYPE, ""))) != "神骨" or next_id == "":
		_show_message("只有设置了下一阶段的神骨装备才可以淬骨！")
		return
	if stage >= BONE_MAX_COUNT:
		_show_message("该装备已经完成三次淬骨！")
		return
	var fire_id: String = BONE_FIRE_IDS[stage]
	if _count_item_all_pages(fire_id) < 3:
		_show_message("淬骨神火不足，需要3个！")
		return
	var current := _read_selected_equipment(selected)
	if current.is_empty():
		_show_message("装备位置已变化，请重新选择装备！")
		return
	_consume_item_all_pages(fire_id, 3)
	var upgraded_data: Dictionary = current.get("data", {}).duplicate(true)
	_ensure_bone_strength_data(upgraded_data, item_name)
	if randf() < 0.5:
		upgraded_data["淬骨次数"] = stage + 1
		upgraded_data["下一阶段"] = next_id
		_scale_bone_attributes(upgraded_data, 1.2)
		if stage + 1 >= BONE_MAX_COUNT:
			upgraded_data = _promote_bone(
				upgraded_data, next_id, item_name, int(current.get(DataKeys.ENHANCE_LEVEL, 0))
			)
			_update_selected_equipment(selected, next_id, upgraded_data, 0)
			_show_message("淬骨成功，已进阶为完整的至尊骨！")
		else:
			_update_selected_equipment(selected, item_name, upgraded_data, int(current.get(DataKeys.ENHANCE_LEVEL, 0)))
			_show_message("淬骨成功！")
	else:
		_show_message("淬骨失败，材料已消耗。")
	_refresh_backpack()
	MemoryClass.save_game(Global.cd_path)


func _read_selected_equipment(selected: Dictionary) -> Dictionary:
	if str(selected.get("source", "装备背包")) == "人物穿戴":
		var slot_type := str(selected.get("穿戴栏", ""))
		var equipped: Variant = PlayerData.player_data.get(slot_type, [])
		if equipped is Array and not equipped.is_empty() and equipped[0] is Dictionary:
			return (equipped[0] as Dictionary).duplicate(true)
		return {}
	var pages: Dictionary = PlayerData.player_data.get(DataKeys.EQUIPMENT_LIST, {})
	var page_key := "页码" + str(int(selected.get("page", 0)))
	var page: Variant = pages.get(page_key, [])
	var index := int(selected.get("index", -1))
	if page is Array and index >= 0 and index < (page as Array).size() and (page as Array)[index] is Dictionary:
		return ((page as Array)[index] as Dictionary).duplicate(true)
	return {}


func _update_selected_equipment(selected: Dictionary, item_name: String, data: Dictionary, level: int) -> void:
	if str(selected.get("source", "装备背包")) == "人物穿戴":
		var slot_type := str(selected.get("穿戴栏", ""))
		var equipped: Variant = PlayerData.player_data.get(slot_type, [])
		if equipped is Array and not equipped.is_empty() and equipped[0] is Dictionary:
			var item: Dictionary = equipped[0]
			item[DataKeys.NAME] = item_name
			item[DataKeys.ENHANCE_LEVEL] = level
			item["data"] = data
			equipped[0] = item
			PlayerData.player_data[slot_type] = equipped
		RoleProp.get_equ_last_pro()
		RoleProp.get_last_prop()
		if is_instance_valid(RoleProp.source_player):
			RoleProp.source_player.on_eqchange()
		MLdl.qh_list[DataKeys.NAME] = item_name
		MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = level
		MLdl.qh_list["页码"] = int(selected.get("page", 0))
		MLdl.qh_list["位置"] = int(selected.get("index", -1))
		MLdl.qh_list["来源"] = str(selected.get("source", "装备背包"))
		MLdl.qh_list["穿戴栏"] = str(selected.get("穿戴栏", ""))
		MLdl.qh_list["data"] = data
		return
	var pages: Dictionary = PlayerData.player_data.get(DataKeys.EQUIPMENT_LIST, {})
	var page_key := "页码" + str(int(selected.get("page", 0)))
	var page: Variant = pages.get(page_key, [])
	var index := int(selected.get("index", -1))
	if page is Array and index >= 0 and index < (page as Array).size() and (page as Array)[index] is Dictionary:
		var item: Dictionary = (page as Array)[index]
		item[DataKeys.NAME] = item_name
		item[DataKeys.ENHANCE_LEVEL] = level
		item["data"] = data
		(page as Array)[index] = item
		MLdl.qh_list[DataKeys.NAME] = item_name
		MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = level
		MLdl.qh_list["页码"] = int(selected.get("page", 0))
		MLdl.qh_list["位置"] = index
		MLdl.qh_list["来源"] = "装备背包"
		MLdl.qh_list["穿戴栏"] = ""
		MLdl.qh_list["data"] = data


func _scale_bone_attributes(data: Dictionary, multiplier: float) -> void:
	const METADATA_KEYS := ["售价", "淬骨次数", "神铸阶段"]
	for key in data.keys():
		if str(key) in METADATA_KEYS or str(key) == "强化属性" or str(key) == "宝石":
			continue
		if data[key] is int or data[key] is float:
			data[key] = data[key] * multiplier
	var strength: Variant = data.get(DataKeys.ENHANCE_PROP, {})
	if strength is Dictionary:
		for key in (strength as Dictionary).keys():
			if strength[key] is int or strength[key] is float:
				(strength as Dictionary)[key] = strength[key] * multiplier


func _ensure_bone_strength_data(data: Dictionary, source_id: String) -> void:
	var strength: Variant = data.get(DataKeys.ENHANCE_PROP, null)
	if strength is Dictionary and not (strength as Dictionary).is_empty():
		return
	var source_template: Dictionary = AE.all_equipment.get(source_id, {})
	var template_strength: Variant = source_template.get(DataKeys.ENHANCE_PROP, {})
	if template_strength is Dictionary:
		data[DataKeys.ENHANCE_PROP] = (template_strength as Dictionary).duplicate(true)


func _bake_bone_strength_into_base(data: Dictionary, qh_level: int, multiplier: float) -> void:
	var strength: Variant = data.get(DataKeys.ENHANCE_PROP, {})
	var strength_data: Dictionary = strength if strength is Dictionary else {}
	const METADATA_KEYS := ["售价", "淬骨次数", "神铸阶段"]
	for key in data.keys():
		if str(key) in METADATA_KEYS or str(key) == "强化属性" or str(key) == "宝石":
			continue
		if data[key] is int or data[key] is float:
			var inherited_value := float(data[key])
			if strength_data.has(key) and (strength_data[key] is int or strength_data[key] is float):
				inherited_value += float(strength_data[key]) * float(qh_level)
			data[key] = inherited_value * multiplier
	for key in strength_data.keys():
		if strength_data[key] is int or strength_data[key] is float:
			strength_data[key] = strength_data[key] * multiplier
	data[DataKeys.ENHANCE_PROP] = strength_data


func _promote_bone(data: Dictionary, next_id: String, source_id: String = "", qh_level: int = 0) -> Dictionary:
	var promoted := data.duplicate(true)
	_ensure_bone_strength_data(promoted, source_id)
	_bake_bone_strength_into_base(promoted, qh_level, 2.0)
	_normalize_bone_attribute_signs(promoted)
	var template: Dictionary = AE.all_equipment.get(next_id, {})
	for key in ["品质", "类型", "颜色", "所属", "描述", "图标"]:
		if template.has(key):
			promoted[key] = template[key]
	promoted[DataKeys.NAME] = str(template.get(DataKeys.NAME, "完整的至尊骨"))
	promoted[DataKeys.GEM] = (
		data.get(DataKeys.GEM, []).duplicate(true)
		if data.get(DataKeys.GEM, []) is Array
		else data.get(DataKeys.GEM, {})
	)
	promoted["淬骨次数"] = 3
	promoted.erase("下一阶段")
	return promoted


func _normalize_bone_attribute_signs(data: Dictionary) -> void:
	const METADATA_KEYS := ["售价", "淬骨次数", "神铸阶段"]
	for key in data.keys():
		if str(key) in METADATA_KEYS or str(key) == "强化属性" or str(key) == "宝石":
			continue
		if data[key] is int or data[key] is float:
			data[key] = abs(float(data[key]))
	var strength: Variant = data.get(DataKeys.ENHANCE_PROP, {})
	if strength is Dictionary:
		for key in (strength as Dictionary).keys():
			if strength[key] is int or strength[key] is float:
				(strength as Dictionary)[key] = abs(float(strength[key]))

extends Strength
class_name DivineForge

const DIVINE_STONE_ID := "pgs"
const MAX_STAGE := 9
const STONES_PER_STAGE := 20


func _ready() -> void:
	n_q_1.is_in_ldl_gz = true
	n_q_2.is_in_ldl_gz = true
	old_zb.is_in_ldl_gz = true
	new_zb.is_in_ldl_gz = true
	get_node("n_q_2").visible = false
	if has_node("need_lh"):
		get_node("need_lh").visible = false
	_clear_display()


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
	var item_data: Dictionary = equipment.get("data", {})
	var selected_source := str(selected.get("source", MLdl.qh_list.get("来源", "装备背包")))
	var selected_page := int(selected.get("page", 0))
	var selected_index := int(selected.get("index", -1))
	var equipped_type := str(selected.get("穿戴栏", MLdl.qh_list.get("穿戴栏", "")))
	var current_stage := AE.get_divine_forge_stage(item_data)
	var target_stage: int = min(current_stage + 1, MAX_STAGE)
	var qh_level := int(equipment.get(DataKeys.ENHANCE_LEVEL, 0))
	var target_data: Dictionary = item_data.duplicate(true)
	target_data["神铸阶段"] = target_stage

	old_zb_name = item_name
	new_zb_name = item_name
	data = item_data
	self.qh_level = qh_level
	old_zb.set_button_icon(load_item_icon(item_name))
	old_zb.get_item_name = item_name
	old_zb.eq_prop = item_data
	old_zb.qh_level = qh_level
	old_zb.current_page = selected_page
	old_zb.strength_source = selected_source
	old_zb.strength_index = selected_index
	old_zb.set_meta("equipped_type", equipped_type)
	old_zb.set_meta("backpack_page", selected_page)
	old_zb.set_meta("backpack_index", selected_index)
	new_zb.set_button_icon(load_item_icon(item_name))
	new_zb.get_item_name = item_name
	new_zb.eq_prop = target_data
	new_zb.qh_level = qh_level
	new_zb.current_page = selected_page
	new_zb.strength_source = selected_source
	new_zb.strength_index = selected_index
	new_zb.set_meta("equipped_type", equipped_type)
	new_zb.set_meta("backpack_page", selected_page)
	new_zb.set_meta("backpack_index", selected_index)

	if current_stage >= MAX_STAGE:
		n_q_1.set_button_icon(load_item_icon("empty"))
		n_q_2.set_button_icon(load_item_icon("empty"))
		n_q_1.get_item_name = "empty"
		n_q_2.get_item_name = "empty"
		n_q_1.eq_prop = {}
		n_q_2.eq_prop = {}
		num_b1.text = "已满阶"
		num_b2.text = ""
		lh_text.text = ""
		return

	var required_stones: int = STONES_PER_STAGE
	var stone_id := _stone_id(target_stage)
	var stone_count := _count_item_all_pages(stone_id)
	n_q_1.set_button_icon(load_item_icon(stone_id))
	n_q_1.get_item_name = stone_id
	n_q_1.eq_prop = AE.all_equipment.get(stone_id, {})
	n_q_1.total_number = 0
	num_b1.text = str(stone_count) + "/" + str(required_stones)
	_set_requirement_color(num_b1, stone_count >= required_stones)

	num_b2.text = ""
	lh_text.text = ""


func _on_sz_pressed() -> void:
	var selected := _get_selected_slot()
	if selected.is_empty():
		_show_message("请先选择一件装备！")
		return
	var equipment: Dictionary = selected["item"]
	var item_name := str(equipment.get(DataKeys.NAME, ""))
	var item_data: Dictionary = equipment.get("data", {})
	if not AE.can_divine_forge(item_name, item_data):
		_show_message("只有神器及以上品质的武器、防具和饰品可以神铸！")
		return
	var current_stage := AE.get_divine_forge_stage(item_data)
	if current_stage >= MAX_STAGE:
		_show_message("该装备已经达到神铸最高九阶！")
		return
	var target_stage := current_stage + 1
	var stone_id := _stone_id(target_stage)
	if _count_item_all_pages(stone_id) < STONES_PER_STAGE:
		_show_message(str(AE.all_equipment[stone_id][DataKeys.NAME]) + "不足，需要20颗！")
		return
	_consume_item_all_pages(stone_id, STONES_PER_STAGE)
	var upgraded_data := item_data.duplicate(true)
	upgraded_data["神铸阶段"] = target_stage
	equipment["data"] = upgraded_data
	MLdl.qh_list["data"] = upgraded_data
	if str(selected["source"]) == "人物穿戴":
		RoleProp.get_equ_last_pro()
		RoleProp.get_last_prop()
		if is_instance_valid(RoleProp.source_player):
			RoleProp.source_player.on_eqchange()
	_show_message("神铸成功！")
	_refresh_backpack()
	MemoryClass.save_game(Global.cd_path)


func _get_selected_slot() -> Dictionary:
	var selected_name := str(MLdl.qh_list.get(DataKeys.NAME, ""))
	var source := str(MLdl.qh_list.get("来源", "装备背包"))
	var page_number := int(MLdl.qh_list.get("页码", 0))
	var index := int(MLdl.qh_list.get("位置", -1))
	if selected_name == "" or index < 0:
		return {}
	var items: Variant
	var slot_type := str(MLdl.qh_list.get("穿戴栏", ""))
	if source == "人物穿戴":
		items = PlayerData.player_data.get(slot_type, [])
		index = 0
		page_number = 0
	else:
		if page_number < 1:
			return {}
		items = PlayerData.player_data.get(DataKeys.EQUIPMENT_LIST, {}).get("页码%d" % page_number, [])
	if not items is Array or index >= items.size():
		return {}
	var item: Variant = items[index]
	if not item is Dictionary or str(item.get(DataKeys.NAME, "")) != selected_name:
		return {}
	return {"item": item, "source": source, "page": page_number, "index": index, "穿戴栏": slot_type}


func _stone_id(stage: int) -> String:
	return DIVINE_STONE_ID if stage == 1 else "pgs_%d" % stage


func _count_item_all_pages(item_name: String) -> int:
	var count := 0
	var pages: Dictionary = PlayerData.player_data.get(DataKeys.ITEM_LIST, {})
	for page_number in range(1, 21):
		var page: Variant = pages.get("页码%d" % page_number, [])
		if not page is Array:
			continue
		for item in page:
			if item is Dictionary and str(item.get(DataKeys.NAME, "")) == item_name:
				count += int(item.get(DataKeys.COUNT, 0))
	return count


func _consume_item_all_pages(item_name: String, count: int) -> void:
	var remaining := count
	var pages: Dictionary = PlayerData.player_data.get(DataKeys.ITEM_LIST, {})
	for page_number in range(1, 21):
		var page: Variant = pages.get("页码%d" % page_number, [])
		if not page is Array:
			continue
		for index in range(page.size() - 1, -1, -1):
			if remaining <= 0:
				return
			var item: Variant = page[index]
			if item is Dictionary and str(item.get(DataKeys.NAME, "")) == item_name:
				var taken := mini(int(item.get(DataKeys.COUNT, 0)), remaining)
				item[DataKeys.COUNT] -= taken
				remaining -= taken
				if int(item[DataKeys.COUNT]) <= 0:
					page.remove_at(index)


func _set_requirement_color(label: Label, enough: bool) -> void:
	label.add_theme_color_override("font_color", Color("00FF00") if enough else Color("FF0000"))


func _show_message(message: String) -> void:
	var parent_node: Node = Global.windows if is_instance_valid(Global.windows) else get_parent()
	Global.add_message_show(parent_node, message, 1.5, Vector2(470, 295))


func _refresh_backpack() -> void:
	var node: Node = get_parent()
	while node != null:
		var backpack := node.get_node_or_null("Main_Backpack")
		if backpack != null and backpack.has_method("set_box_data"):
			backpack.set_box_data()
			return
		node = node.get_parent()


func _clear_display() -> void:
	old_zb_name = "empty"
	new_zb_name = "empty"
	qh_level = -1
	data = {}
	for slot in [old_zb, new_zb, n_q_1, n_q_2]:
		slot.set_button_icon(load_item_icon("empty"))
		slot.get_item_name = "empty"
		slot.eq_prop = {}
	num_b1.text = ""
	num_b2.text = ""
	lh_text.text = ""


func remove_infomation() -> void:
	_clear_display()
	MLdl.qh_list[DataKeys.NAME] = ""
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = -1
	MLdl.qh_list["页码"] = 0
	MLdl.qh_list["位置"] = 0
	MLdl.qh_list["来源"] = "装备背包"
	MLdl.qh_list["穿戴栏"] = ""
	MLdl.qh_list["data"] = {}

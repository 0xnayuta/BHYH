extends Control
var _get_name
var page: int = 0
var number: int = 0
var eq_prop = {}
var jm

var pet_owner: Node = null
var pet_source: Variant = null
var pet_index: int = -1
var pet_slot_type: String = ""
var pet_action_label: String = "装备"
var is_pet_action: bool = false
var source_box: Node = null
var outside_click_enabled: bool = false

@onready var infor = $VBoxContainer/infor
@onready var lock_button: Button = $VBoxContainer/lock
@onready var lock_text: Label = $VBoxContainer/lock/Text


func _ready() -> void:
	infor.text = "第" + str(page) + "页" + "第" + str(number + 1) + "格"
	call_deferred("_refresh_lock_button")
	call_deferred("_enable_outside_click")
	await get_tree().create_timer(1.8).timeout
	if jm == null and not is_pet_action:
		queue_free()
		return
	_refresh_lock_button()


func _enable_outside_click() -> void:
	outside_click_enabled = true


func _input(event: InputEvent) -> void:
	if not outside_click_enabled or not is_visible_in_tree():
		return
	var click_position := Vector2.ZERO
	if event is InputEventMouseButton:
		if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
			return
		click_position = event.position
	elif event is InputEventScreenTouch:
		if not event.pressed:
			return
		click_position = event.position
	else:
		return
	if not _control_has_point($Panel, click_position) and not _control_has_point($VBoxContainer, click_position):
		queue_free()


func _control_has_point(control: Control, screen_position: Vector2) -> bool:
	var local_position := control.get_global_transform_with_canvas().affine_inverse() * screen_position
	return Rect2(Vector2.ZERO, control.size).has_point(local_position)


func _get_inventory_entry() -> Dictionary:
	if page <= 0 or number < 0:
		return {}
	var pages: Variant = PlayerData.player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if not pages is Dictionary:
		return {}
	var items: Variant = pages.get("页码" + str(page), [])
	if not items is Array or number >= (items as Array).size():
		return {}
	var item: Variant = (items as Array)[number]
	return item as Dictionary if item is Dictionary else {}


func _is_locked() -> bool:
	var item := _get_inventory_entry()
	var data: Variant = item.get("Data", {})
	return data is Dictionary and bool((data as Dictionary).get("锁定", false))


func _refresh_lock_button() -> void:
	if lock_button == null:
		return
	lock_button.visible = not is_pet_action
	if is_pet_action:
		return
	var locked := _is_locked()
	lock_text.text = "解 锁" if locked else "锁 定"
	lock_button.tooltip_text = "解锁后才能出售" if locked else "锁定物品，禁止出售"
	if source_box != null and is_instance_valid(source_box):
		source_box.item_locked = locked


func _on_lock_pressed() -> void:
	if is_pet_action:
		return
	var item := _get_inventory_entry()
	var data: Variant = item.get("Data", {})
	if not data is Dictionary:
		return
	(data as Dictionary)["锁定"] = not bool((data as Dictionary).get("锁定", false))
	eq_prop = data
	MemoryClass.save_game(Global.cd_path)
	_refresh_lock_button()


func setup_pet_action(owner: Node, source: Variant, index: int, slot_type: String, action_label: String = "装备") -> void:
	pet_owner = owner
	pet_source = source
	pet_index = index
	pet_slot_type = slot_type
	pet_action_label = action_label
	is_pet_action = owner != null
	_get_name = _pet_item_name(source)
	eq_prop = _pet_item_data(source)
	page = 1
	number = maxi(index, 0)
	set_meta("pet_action_label", action_label)

	show_behind_parent = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	if infor != null:
		infor.text = "第1页第%d格" % (number + 1) if index >= 0 else "已装备"
	var action_button := get_node_or_null("VBoxContainer/equ") as Button
	if action_button != null:
		var can_equip: bool = not owner.has_method("can_equip_pet_item") or owner.call("can_equip_pet_item") == true
		action_button.disabled = index >= 0 and not can_equip
		action_button.tooltip_text = "请先选择宠物" if action_button.disabled else action_label


func _pet_item_name(source: Variant) -> String:
	if source is Dictionary:
		var item := source as Dictionary
		return str(item.get(DataKeys.NAME, item.get(DataKeys.ALT_NAME, "宠物装备")))
	return str(source)


func _pet_item_data(source: Variant) -> Dictionary:
	if not (source is Dictionary):
		return {}
	var item := source as Dictionary
	var data: Variant = item.get("Data", {})
	if data is Dictionary and not (data as Dictionary).is_empty():
		return (data as Dictionary).duplicate(true)
	return item.duplicate(true)


func _call_pet_action(method_name: String) -> bool:
	if not is_pet_action or pet_owner == null or not is_instance_valid(pet_owner):
		return false
	if not pet_owner.has_method(method_name):
		return false
	var result = pet_owner.call(method_name, pet_source, pet_index, pet_slot_type, pet_action_label)

	return result == null or result == true


func _on_equ_pressed() -> void:
	if is_pet_action:
		if _call_pet_action("pet_equip_from_popup"):
			queue_free()
		return
	var new_list = PlayerData.get_zb_data(page, number)
	if not check_can_equipment(new_list[DataKeys.NAME]):
		return
	match AE.all_equipment[new_list[DataKeys.NAME]][DataKeys.TYPE]:
		"武器":
			PlayerData.remove_zb(page, number)
			if PlayerData.player_data[DataKeys.WEAPON].size() != 0:
				var mz = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.WEAPON][0]["Data"]
				PlayerData.player_data[DataKeys.WEAPON].clear()
				PlayerData.player_data[DataKeys.WEAPON].push_back(new_list)
				PlayerData.zl_zb()
				PlayerData.add_zb(mz, ql, eq_prop)
			else:
				PlayerData.player_data[DataKeys.WEAPON].clear()
				PlayerData.player_data[DataKeys.WEAPON].push_back(new_list)
				PlayerData.zl_zb()
		"防具":
			PlayerData.remove_zb(page, number)
			if PlayerData.player_data[DataKeys.ARMOR].size() != 0:
				var mz = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.ARMOR][0]["Data"]
				PlayerData.player_data[DataKeys.ARMOR].clear()
				PlayerData.player_data[DataKeys.ARMOR].push_back(new_list)
				PlayerData.zl_zb()
				PlayerData.add_zb(mz, ql, eq_prop)

			else:
				PlayerData.player_data[DataKeys.ARMOR].clear()
				PlayerData.player_data[DataKeys.ARMOR].push_back(new_list)
				PlayerData.zl_zb()
		"饰品":
			PlayerData.remove_zb(page, number)
			if PlayerData.player_data["饰品"].size() != 0:
				var mz = PlayerData.player_data["饰品"][0][DataKeys.NAME]
				var ql = PlayerData.player_data["饰品"][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data["饰品"][0]["Data"]
				PlayerData.player_data["饰品"].clear()
				PlayerData.player_data["饰品"].push_back(new_list)
				PlayerData.zl_zb()
				PlayerData.add_zb(mz, ql, eq_prop)
			else:
				PlayerData.player_data["饰品"].clear()
				PlayerData.player_data["饰品"].push_back(new_list)
				PlayerData.zl_zb()
		"神骨":
			PlayerData.remove_zb(page, number)
			var equipped_shengu: Array = PlayerData.ensure_shengu_slot()
			if not equipped_shengu.is_empty():
				var old_item: Dictionary = equipped_shengu[0]
				equipped_shengu.clear()
				equipped_shengu.push_back(new_list)
				PlayerData.zl_zb()
				PlayerData.add_zb(
					str(old_item.get(DataKeys.NAME, "")),
					int(old_item.get(DataKeys.ENHANCE_LEVEL, 0)),
					old_item.get("Data", {})
				)
			else:
				equipped_shengu.push_back(new_list)
				PlayerData.zl_zb()
		"头衔":
			PlayerData.remove_zb(page, number)
			if PlayerData.player_data[DataKeys.TITLE].size() != 0:
				var mz = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.TITLE][0]["Data"]
				PlayerData.player_data[DataKeys.TITLE].clear()
				PlayerData.player_data[DataKeys.TITLE].push_back(new_list)
				PlayerData.zl_zb()
				PlayerData.add_zb(mz, ql, eq_prop)
			else:
				PlayerData.player_data[DataKeys.TITLE].clear()
				PlayerData.player_data[DataKeys.TITLE].push_back(new_list)
				PlayerData.zl_zb()
		"头像框":
			PlayerData.remove_zb(page, number)
			var equipped_avatar_frames: Array = PlayerData.ensure_avatar_frame_slot()
			if not equipped_avatar_frames.is_empty() and equipped_avatar_frames[0] is Dictionary:
				var old_item: Dictionary = equipped_avatar_frames[0]
				equipped_avatar_frames.clear()
				equipped_avatar_frames.push_back(new_list)
				PlayerData.zl_zb()
				PlayerData.add_zb(
					str(old_item.get(DataKeys.NAME, "")),
					int(old_item.get(DataKeys.ENHANCE_LEVEL, 0)),
					old_item.get("Data", {})
				)
			else:
				equipped_avatar_frames.clear()
				equipped_avatar_frames.push_back(new_list)
				PlayerData.zl_zb()
		"时装":
			PlayerData.remove_zb(page, number)
			if PlayerData.player_data[DataKeys.FASHION].size() != 0:
				var mz = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.FASHION][0]["Data"]
				PlayerData.player_data[DataKeys.FASHION].clear()
				PlayerData.player_data[DataKeys.FASHION].push_back(new_list)
				PlayerData.zl_zb()
				PlayerData.add_zb(mz, ql, eq_prop)

			else:
				PlayerData.player_data[DataKeys.FASHION].clear()
				PlayerData.player_data[DataKeys.FASHION].push_back(new_list)
				PlayerData.zl_zb()
		"翅膀":
			PlayerData.remove_zb(page, number)
			if PlayerData.player_data[DataKeys.WINGS].size() != 0:
				var mz = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.WINGS][0]["Data"]
				PlayerData.player_data[DataKeys.WINGS].clear()
				PlayerData.player_data[DataKeys.WINGS].push_back(new_list)
				PlayerData.zl_zb()
				PlayerData.add_zb(mz, ql, eq_prop)
			else:
				PlayerData.player_data[DataKeys.WINGS].clear()
				PlayerData.player_data[DataKeys.WINGS].push_back(new_list)
				PlayerData.zl_zb()
		"法宝":
			PlayerData.remove_zb(page, number)
			if Global.fb_cd <= 0:
				if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
					var mz = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]
					var ql = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL]
					var wx = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS]
					eq_prop = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0]["Data"]
					PlayerData.player_data[DataKeys.MAGIC_WEAPON].clear()
					PlayerData.player_data[DataKeys.MAGIC_WEAPON].push_back(new_list)
					PlayerData.zl_zb()
					PlayerData.add_fb(mz, ql, wx, eq_prop)
				else:
					PlayerData.player_data[DataKeys.MAGIC_WEAPON].clear()
					PlayerData.player_data[DataKeys.MAGIC_WEAPON].push_back(new_list)
					PlayerData.zl_zb()
			else:
				var mz = new_list[DataKeys.NAME]
				var ql = new_list[DataKeys.ENHANCE_LEVEL]
				var wx = new_list[DataKeys.FIVE_ELEMENTS]
				eq_prop = new_list["Data"]
				PlayerData.add_fb(mz, ql, wx, eq_prop)
				var parent = Global.get_ancestor(self, 3)
				Global.add_message_show(parent, "当前法宝正在使用，无法更换！！", 1.5, Vector2(485, 240))
	RoleProp.get_equ_last_pro()
	RoleProp.get_last_prop()
	if is_instance_valid(RoleProp.source_player):
		RoleProp.source_player.on_eqchange()
	MemoryClass.save_game(Global.cd_path)
	queue_free()


func _on_sell_pressed() -> void:
	if is_pet_action:
		if _call_pet_action("pet_sell_from_popup"):
			queue_free()
		return
	if _is_locked():
		lock_button.grab_focus()
		Global.add_message_show(Global.get_ui_popup_layer(), "该物品已锁定，请先解锁后再出售！", 1.5, Vector2.ZERO)
		return
	if eq_prop == null:
		PlayerData.remove_zb(page, number)
		return
	if not eq_prop.has(DataKeys.TYPE):
		PlayerData.remove_zb(page, number)
		return
	var lx = eq_prop[DataKeys.TYPE]
	var pz = eq_prop[DataKeys.QUALITY]
	match lx:
		"武器", "防具", "饰品":
			if eq_prop[DataKeys.GEM].size() == 0:
				pass
			else:
				var parent = Global.get_ancestor(self, 3)
				Global.add_message_show(parent, "请先卸下该装备上的宝石！！", 1.5, Vector2(485, 240))
				return
	var abc = PlayerData.get_zb_data(page, number)

	var item_name = PlayerData.get_zb_data(page, number)["Data"][DataKeys.NAME]
	if pz == "传说" or pz == "玄冥" or pz == "魂器" or pz == "神器" or pz == "邪灵":
		_show_sell_confirm(
			"确定要卖出" + str(pz) + "品质的" + str(item_name) + "吗？（此装备已强化至+" + str(abc[DataKeys.ENHANCE_LEVEL]) + "。）"
		)
		return
	if lx == "法宝":
		_show_sell_confirm("确定要卖出" + str(lx) + str(item_name) + "吗？（此装备已强化至+" + str(abc[DataKeys.ENHANCE_LEVEL]) + "。）")
		return
	if abc[DataKeys.ENHANCE_LEVEL] > 0:
		_show_sell_confirm("确定要卖出" + str(lx) + str(item_name) + "吗？（此装备已强化至+" + str(abc[DataKeys.ENHANCE_LEVEL]) + "。）")
		return

	var get_value = AE.all_equipment[_get_name]["售价"]
	PlayerData.add_soul(get_value)
	MemoryClass.save_game(Global.cd_path)
	PlayerData.remove_zb(page, number)
	PlayerData.zl_zb()
	queue_free()


func _show_sell_confirm(confirm_text: String) -> void:
	self.visible = false
	Signals.connect_choose_box_signal(self, "sell")
	jm = Global.add_choose_text(Global.get_ui_popup_layer(), Vector2.ZERO, confirm_text, 0)
	if jm == null:
		return
	var popup := jm as Control
	if popup == null:
		return
	popup.process_mode = Node.PROCESS_MODE_ALWAYS
	var overlay := popup.get_node_or_null("TextureRect") as ColorRect
	if overlay == null:
		return
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color.TRANSPARENT
	call_deferred("_center_sell_confirm_popup", popup)


func _center_sell_confirm_popup(popup: Control) -> void:
	if popup == null or not is_instance_valid(popup):
		return
	await get_tree().process_frame
	var overlay := popup.get_node_or_null("TextureRect") as ColorRect
	if overlay == null:
		return
	var dialog := overlay.get_node_or_null("bg") as Control
	if dialog == null:
		return
	var dialog_size := dialog.size
	dialog.anchor_left = 0.0
	dialog.anchor_top = 0.0
	dialog.anchor_right = 0.0
	dialog.anchor_bottom = 0.0
	dialog.offset_left = (overlay.size.x - dialog_size.x) * 0.5
	dialog.offset_top = (overlay.size.y - dialog_size.y) * 0.5
	dialog.offset_right = dialog.offset_left + dialog_size.x
	dialog.offset_bottom = dialog.offset_top + dialog_size.y


func sell():
	if _is_locked():
		visible = true
		_refresh_lock_button()
		return
	var get_value = AE.all_equipment[_get_name]["售价"]
	PlayerData.add_soul(get_value)
	MemoryClass.save_game(Global.cd_path)
	PlayerData.remove_zb(page, number)
	PlayerData.zl_zb()


func get_number():
	var _number = int(str(get_parent().name).split("_")[1]) - 1
	return _number


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func _on_mouse_exited() -> void:
	pass


func _on_v_box_container_mouse_exited() -> void:
	pass


func _on_panel_mouse_exited() -> void:
	pass


func check_can_equipment(EquipmentName):
	var role_id: int = PlayerData.player_data["Myself"]
	var parent = Global.get_ancestor(self, 3)
	var eq_base = AE.all_equipment[EquipmentName]["所属"]
	var name_str = AE.all_equipment[EquipmentName][DataKeys.NAME] as String
	var role_base: String
	if eq_base == "通用":
		return true
	match role_id:
		1:
			role_base = "悟空"
			if eq_base == "悟空":
				return true
		2:
			role_base = "唐僧"
			if eq_base == "唐僧":
				return true
		3:
			role_base = "八戒"
			if eq_base == "八戒":
				return true
		4:
			role_base = "沙僧"
			if eq_base == "沙僧·铲" or eq_base == "沙僧·弓" or eq_base == "沙僧":
				return true
		5:
			role_base = "白龙"
			if eq_base == "白龙":
				return true
		6:
			role_base = "哪吒"
			if eq_base == "哪吒":
				return true
		7:
			role_base = "玉兔"
			if eq_base == "玉兔":
				return true
	Global.add_message_show(parent, name_str + "属于" + eq_base + "，" + role_base + "无法穿戴！！", 1.5, Vector2(485, 240))
	return false

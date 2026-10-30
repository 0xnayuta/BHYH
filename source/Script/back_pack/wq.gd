extends Button

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

var add_equ_box
var get_item_name
var qh_level: int
var pp
var wx = []
var eq_prop = {}
var _slot_background_ready := false
var _slot_background_item_visible := false
var _avatar_frame_signature := ""
var _shengu_signature := ""


func _ready() -> void:
	_sync_avatar_frame_equipment(true)
	_sync_shengu_equipment(true)
	_ensure_slot_background()


func _ensure_slot_background() -> void:
	if _slot_background_ready:
		return
	_sync_slot_background_style(true)
	_slot_background_ready = true


func _sync_slot_background_style(force := false) -> void:
	var item_visible := _has_item_icon()
	if not force and _slot_background_item_visible == item_visible and _slot_background_ready:
		return
	_slot_background_item_visible = item_visible
	var slot_name := str(self.name)
	var bg_path := (
		"res://Art/backpack/all_items/empty.png"
		if item_visible
		else "res://Art/backpack/all_items/" + slot_name + ".png"
	)
	var bg_texture = load(bg_path) if ResourceLoader.exists(bg_path) else load("res://Art/backpack/all_items/empty.png")
	for style_name in ["normal", "pressed", "hover", "disabled", "focus"]:
		var style := StyleBoxTexture.new()
		style.texture = bg_texture
		add_theme_stylebox_override(style_name, style)


func _icon_name() -> String:
	if icon == null or icon.resource_path == "":
		return ""
	return icon.resource_path.get_file().get_basename()


func _has_item_icon() -> bool:
	var icon_name := _icon_name()
	return icon_name != "" and not ["empty", "wq", "fj", "sp", "fb", "sz", "cb", "tx", "txk", "shengu"].has(icon_name)


func _item_id() -> String:
	var item_name := str(get_item_name)
	if AE.all_equipment.has(item_name):
		return item_name
	return _icon_name()


func _sync_avatar_frame_equipment(force := false) -> void:
	if str(name) != "txk":
		return
	var equipped: Array = PlayerData.ensure_avatar_frame_slot()
	var signature := "empty"
	var item: Dictionary = {}
	if not equipped.is_empty() and equipped[0] is Dictionary:
		item = equipped[0]
		signature = (
			"%s:%d:%s"
			% [
				str(item.get(DataKeys.NAME, "")),
				int(item.get(DataKeys.ENHANCE_LEVEL, 0)),
				str(item.get("Data", {})),
			]
		)
	if not force and signature == _avatar_frame_signature:
		return
	_avatar_frame_signature = signature
	if item.is_empty():
		get_item_name = ""
		qh_level = 0
		eq_prop = {}
		set_button_icon(load("res://Art/backpack/all_items/empty.png"))
		return
	get_item_name = str(item.get(DataKeys.NAME, ""))
	qh_level = int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	eq_prop = item.get("Data", {})
	var item_icon_path: String = "res://Art/backpack/all_items/" + str(get_item_name) + ".png"
	var item_icon = (
		load(item_icon_path)
		if ResourceLoader.exists(item_icon_path)
		else load("res://Art/backpack/all_items/empty.png")
	)
	set_button_icon(item_icon)


func _sync_shengu_equipment(force := false) -> void:
	if str(name) != "shengu":
		return
	var equipped: Array = PlayerData.ensure_shengu_slot()
	var signature := "empty"
	if not equipped.is_empty() and equipped[0] is Dictionary:
		signature = str(equipped[0])
	if not force and signature == _shengu_signature:
		return
	_shengu_signature = signature
	if equipped.is_empty() or not (equipped[0] is Dictionary):
		get_item_name = ""
		qh_level = 0
		eq_prop = {}
		set_button_icon(load("res://Art/backpack/all_items/empty.png"))
		return
	var item: Dictionary = equipped[0]
	get_item_name = str(item.get(DataKeys.NAME, ""))
	qh_level = int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	eq_prop = item.get("Data", {})
	var item_icon_path: String = "res://Art/backpack/all_items/" + str(get_item_name) + ".png"
	set_button_icon(
		(
			load(item_icon_path)
			if ResourceLoader.exists(item_icon_path)
			else load("res://Art/backpack/all_items/empty.png")
		)
	)


func _mouse_position_for_popup(parent_node: Node, offset := Vector2(25, 20)) -> Vector2:
	var mouse_pos := get_tree().get_root().get_mouse_position() + offset
	if parent_node is CanvasItem:
		return (parent_node as CanvasItem).get_global_transform().affine_inverse() * mouse_pos
	return mouse_pos


func _physics_process(_delta: float) -> void:
	_sync_avatar_frame_equipment()
	_sync_shengu_equipment()
	_sync_slot_background_style()
	if add_equ_box != null:
		var popup_parent = add_equ_box.get_parent()
		if popup_parent != null:
			pp = _mouse_position_for_popup(popup_parent)
			add_equ_box.position = pp


func _on_pressed() -> void:
	if PlayerData.check_can_use_page("装备列表") == 0:
		Global.add_message_show(NodeUtils.ancestor(self, 5), "背包已满，无法卸下！！", 1.5, Vector2(80, 0))
		return
	match str(self.name):
		"wq":
			if PlayerData.player_data[DataKeys.WEAPON].size() != 0:
				var _name = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.WEAPON][0]["Data"]
				PlayerData.add_zb(_name, ql, eq_prop)
			else:
				set_button_icon(load("res://Art/backpack/wq.png"))
			PlayerData.player_data[DataKeys.WEAPON].clear()
		"fj":
			if PlayerData.player_data[DataKeys.ARMOR].size() != 0:
				var _name = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.ARMOR][0]["Data"]
				PlayerData.add_zb(_name, ql, eq_prop)
			else:
				set_button_icon(load("res://Art/backpack/fj.png"))
			PlayerData.player_data[DataKeys.ARMOR].clear()
		"sp":
			if PlayerData.player_data["饰品"].size() != 0:
				var _name = PlayerData.player_data["饰品"][0][DataKeys.NAME]
				var ql = PlayerData.player_data["饰品"][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data["饰品"][0]["Data"]
				PlayerData.add_zb(_name, ql, eq_prop)
			else:
				set_button_icon(load("res://Art/backpack/sp.png"))
			PlayerData.player_data["饰品"].clear()
		"shengu":
			var equipped: Array = PlayerData.ensure_shengu_slot()
			if not equipped.is_empty() and equipped[0] is Dictionary:
				var item: Dictionary = equipped[0]
				PlayerData.add_zb(
					str(item.get(DataKeys.NAME, "")), int(item.get(DataKeys.ENHANCE_LEVEL, 0)), item.get("Data", {})
				)
			equipped.clear()
			_shengu_signature = ""
			_sync_shengu_equipment(true)
		"tx":
			if PlayerData.player_data[DataKeys.TITLE].size() != 0:
				var _name = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.TITLE][0]["Data"]
				PlayerData.add_zb(_name, ql, eq_prop)
			else:
				set_button_icon(load("res://Art/backpack/all_items/tx.png"))
			PlayerData.player_data[DataKeys.TITLE].clear()
		"txk":
			var equipped: Array = PlayerData.ensure_avatar_frame_slot()
			if not equipped.is_empty() and equipped[0] is Dictionary:
				var item: Dictionary = equipped[0]
				PlayerData.add_zb(
					str(item.get(DataKeys.NAME, "")), int(item.get(DataKeys.ENHANCE_LEVEL, 0)), item.get("Data", {})
				)
			equipped.clear()
			_avatar_frame_signature = ""
			_sync_avatar_frame_equipment(true)
		"sz":
			if PlayerData.player_data[DataKeys.FASHION].size() != 0:
				var _name = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.FASHION][0]["Data"]
				PlayerData.add_zb(_name, ql, eq_prop)
			else:
				set_button_icon(load("res://Art/backpack/sz.png"))
			PlayerData.player_data[DataKeys.FASHION].clear()
		"cb":
			if PlayerData.player_data[DataKeys.WINGS].size() != 0:
				var _name = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.ENHANCE_LEVEL]
				eq_prop = PlayerData.player_data[DataKeys.WINGS][0]["Data"]
				PlayerData.add_zb(_name, ql, eq_prop)
			else:
				set_button_icon(load("res://Art/backpack/cb.png"))
			PlayerData.player_data[DataKeys.WINGS].clear()
		"fb":
			if Global.fb_cd <= 0:
				if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
					var _name = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]
					var ql = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL]
					var wx = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS]
					eq_prop = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0]["Data"]
					PlayerData.add_fb(_name, ql, wx, eq_prop)
				else:
					set_button_icon(load("res://Art/backpack/fb.png"))
				PlayerData.player_data[DataKeys.MAGIC_WEAPON].clear()
			else:
				Global.add_message_show(NodeUtils.ancestor(self, 5), "当前法宝正在使用，无法更换！！", 1.5, Vector2(80, 0))
	qh_level = 0
	RoleProp.get_equ_last_pro()
	RoleProp.get_last_prop()
	if is_instance_valid(RoleProp.source_player):
		RoleProp.source_player.on_eqchange()
	MemoryClass.request_save("back_pack_magic_change")


func _on_mouse_entered() -> void:
	if add_equ_box != null or not _has_item_icon():
		return
	var item_id := _item_id()
	if item_id == "":
		return
	var ancestor_level := 3 if str(self.name) in ["cb", "sz", "tx", "txk", "shengu"] else 5
	var popup_parent = NodeUtils.ancestor(self, ancestor_level)
	pp = _mouse_position_for_popup(popup_parent)
	add_equ_box = Global.add_equ_propeties_box(popup_parent, pp, item_id, qh_level, wx, eq_prop)


func _on_mouse_exited() -> void:
	if add_equ_box != null:
		add_equ_box.queue_free()

extends TextureRect
@onready var show_box: Button = $ShowBox
@onready var eq_name: Label = $Eq_name
@onready var have_or_not: Label = $HaveOrNot
@onready var cdorxx: Label = $change/cdorxx
@onready var cdinfor: TextureRect = $cdinfor
var self_name: String
var transmogrified: Transmogrified


func _physics_process(_delta: float) -> void:
	eq_name.text = str(AE.all_equipment[self_name][DataKeys.NAME])
	show_box.is_in_ldl_gz = true
	show_box.is_in_hhgz = true
	show_box.set_button_icon(load_item_icon(self_name))
	show_box.qh_level = 0
	show_box.wx = []
	show_box.eq_prop = AE.all_equipment[self_name]
	var list = PlayerData.player_data[DataKeys.TRANSMOG_LIST]
	if (
		list[DataKeys.WEAPON] == self_name
		or list[DataKeys.ARMOR] == self_name
		or list[DataKeys.WINGS] == self_name
		or list[DataKeys.TITLE] == self_name
	):
		cdinfor.visible = true
		cdorxx.text = str("卸下")
	else:
		cdinfor.visible = false
		cdorxx.text = str("穿戴")
	if already_have(self_name):
		have_or_not.text = "已解锁"
		have_or_not.add_theme_color_override("font_color", "00ff00")
		have_or_not.add_theme_color_override("font_outline_color", "00ff00")
	else:
		have_or_not.add_theme_color_override("font_color", "ff0000")
		have_or_not.add_theme_color_override("font_outline_color", "ff0000")
		have_or_not.text = "未解锁"

	set_physics_process(false)


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func already_have(Name):
	return PlayerData.has_acquired_equipment(str(Name))


func _on_change_pressed() -> void:
	var lx = AE.all_equipment[self_name][DataKeys.TYPE]
	if lx == "时装":
		lx = "防具"
	var item_name = AE.all_equipment[self_name][DataKeys.NAME]
	if cdorxx.text == "穿戴":
		if not already_have(self_name):
			Global.add_message_show(Global.windows, "您还未获得过" + str(item_name) + "！！", 1.5, Vector2(470, 295))
			return
		if not PlayerData.change_transmog(lx, self_name):
			Global.add_message_show(
				Global.windows, "存档保存失败，本次幻化已撤销：%s" % MemoryClass.describe_save_error(), 2.0, Vector2(470, 295)
			)
			return
		Global.add_message_show(Global.windows, str(lx) + "幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
	elif cdorxx.text == "卸下":
		if not PlayerData.change_transmog(lx, ""):
			Global.add_message_show(
				Global.windows, "存档保存失败，本次幻化已撤销：%s" % MemoryClass.describe_save_error(), 2.0, Vector2(470, 295)
			)
			return
		Global.add_message_show(Global.windows, "取消" + str(lx) + ":" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
	else:
		return
	transmogrified.on_eqchange()
	if is_instance_valid(RoleProp.source_player) and RoleProp.source_player.has_method("on_eqchange"):
		RoleProp.source_player.on_eqchange()
	for i in transmogrified.box_list.get_children():
		if i != null:
			i.set_physics_process(true)
	set_physics_process(true)

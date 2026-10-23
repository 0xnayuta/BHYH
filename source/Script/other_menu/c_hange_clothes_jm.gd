extends Node2D

@onready var have_or_not: Label = $BG/HaveOrNot
@onready var cdorxx: Label = $BG/change/cdorxx
@onready var cdinfor: Sprite2D = $cdinfor
@onready var show_box: Button = $BG/ShowBox
@onready var eq_name: Label = $BG/Eq_name

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
	if list[DataKeys.WEAPON] == self_name or list[DataKeys.ARMOR] == self_name or list[DataKeys.WINGS] == self_name:
		cdinfor.visible = true
		cdorxx.text = str("卸下")
	else:
		cdinfor.visible = false
		cdorxx.text = str("穿戴")
	if PlayerData.has_acquired_equipment(self_name):
		have_or_not.text = "已解锁"
		have_or_not.add_theme_color_override("font_color", "00ff00")
	else:
		have_or_not.add_theme_color_override("font_color", "ff0000")
		have_or_not.text = "未解锁"

	set_physics_process(false)


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func _on_change_pressed() -> void:
	var lx = AE.all_equipment[self_name][DataKeys.TYPE]
	var item_name = AE.all_equipment[self_name][DataKeys.NAME]

	if cdorxx.text == "穿戴":
		if PlayerData.has_acquired_equipment(self_name):
			if lx == "武器":
				PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] = self_name
				Global.add_message_show(Global.windows, "武器幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
			elif lx == "防具":
				PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] = self_name
				Global.add_message_show(Global.windows, "防具幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
			elif lx == "时装":
				PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] = self_name
				Global.add_message_show(Global.windows, "时装幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
			elif lx == "翅膀":
				PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] = self_name
				Global.add_message_show(Global.windows, "翅膀幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
		else:
			Global.add_message_show(Global.windows, "您还未获得过" + str(item_name) + "！！", 1.5, Vector2(470, 295))
	elif cdorxx.text == "卸下":
		if lx == "武器":
			PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] = ""
			Global.add_message_show(Global.windows, "取消武器：" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
		elif lx == "防具":
			PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] = ""
			Global.add_message_show(Global.windows, "取消防具：" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
		elif lx == "时装":
			PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] = ""
			Global.add_message_show(Global.windows, "取消时装：" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
		elif lx == "翅膀":
			PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] = ""
			Global.add_message_show(Global.windows, "取消翅膀：" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
	transmogrified.on_eqchange()
	if is_instance_valid(RoleProp.source_player) and RoleProp.source_player.has_method("on_eqchange"):
		RoleProp.source_player.on_eqchange()
	for i in transmogrified.list:
		if i != null:
			i.set_physics_process(true)
	MemoryClass.save_game(Global.cd_path)
	set_physics_process(true)

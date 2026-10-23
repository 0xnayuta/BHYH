extends Node2D
@onready var up_button: TextureRect = $UpButton
@onready var down_button: TextureRect = $DownButton
@onready var level_info_old: Label = $PropInfoBg/OldPropList/LevelInfo_old
@onready var prop_info_old: Label = $PropInfoBg/OldPropList/PropInfo_old
@onready var level_info_new: Label = $PropInfoBg/NewPropList/LevelInfo_new
@onready var prop_info_new: Label = $PropInfoBg/NewPropList/PropInfo_new
@onready var need_num: Label = $DownButton/Title/NeedNum
@onready var needlh: Label = $lh/needlh

var zhen_fa_type
var real_name
var father


func _physics_process(delta: float) -> void:
	if father != null:
		set_box_info()
		set_level_info()
		set_need_and_lh_info()


func set_level_info():
	zhen_fa_type = father.current_zhen_fa_name
	match zhen_fa_type:
		"slz":
			real_name = "森罗阵"
		"lpz":
			real_name = "落魄阵"
		"tsz":
			real_name = "腾蛇阵"
		"tqz":
			real_name = "太清阵"
	var cur_level = int(PlayerData.player_data[real_name][str(father.current_num)]["Level"])
	var prop_type = RoleProp.zhen_fa_props[real_name][str(father.current_num)]["Type"]
	if int(cur_level) <= 50:
		level_info_old.text = "Lv." + str(cur_level)
		prop_info_old.text = str(prop_type) + "+" + str(RoleProp.get_zf_loc_prop(real_name, father.current_num))
	else:
		level_info_old.text = "已满级"
		prop_info_old.text = "已满级"
	if int(cur_level) + 1 <= 50:
		level_info_new.text = "Lv." + str(cur_level + 1)
		prop_info_new.text = str(prop_type) + "+" + str(RoleProp.get_next_level_prop(real_name, father.current_num))
	else:
		prop_info_new.text = "已满级"
		level_info_new.text = "已满级"


func set_need_and_lh_info():
	var cur_level = int(PlayerData.player_data[real_name][str(father.current_num)]["Level"])
	var item_name = PlayerData.player_data[real_name][str(father.current_num)]["InName"]
	var material_need_value = int(cur_level / 5) + 1
	var need_lh = int(cur_level / 5) * 1000 + 1000
	var current_num = int(PlayerData.get_item_data(item_name))
	need_num.text = str(PlayerData.get_item_data(item_name)) + "/" + str(material_need_value)
	if current_num >= material_need_value:
		need_num.add_theme_color_override("font_color", "00ff00")
	else:
		need_num.add_theme_color_override("font_color", "ff0000")
	needlh.text = "灵魂：" + str(need_lh)


func set_box_info():
	up_button.father = father
	up_button.not_show = true
	up_button.loc_num = father.current_num
	down_button.father = father
	down_button.loc_num = father.current_num
	down_button.not_show = true


func _on_cure_level_pressed() -> void:
	var cur_level = int(PlayerData.player_data[real_name][str(father.current_num)]["Level"])
	var item_name = PlayerData.player_data[real_name][str(father.current_num)]["InName"]
	var material_need_value = int(cur_level / 5) + 1
	var need_lh = int(cur_level / 5) * 1000 + 1000
	var current_num := int(PlayerData.get_item_data(item_name))
	if cur_level >= 50:
		Global.add_message_show(Global.windows, "已满级！！", 1.5, Vector2(500, 305))
		return
	if current_num < material_need_value:
		Global.add_message_show(Global.windows, "材料不足！！", 1.5, Vector2(500, 305))
		return
	if PlayerData.get_soul() < need_lh:
		Global.add_message_show(Global.windows, "灵魂不足！！", 1.5, Vector2(500, 305))
		return
	PlayerData.spend_soul(need_lh)
	PlayerData.remove_dj(item_name, PlayerData.get_dj_page(item_name), material_need_value)
	PlayerData.player_data[real_name][str(father.current_num)]["Level"] += 1
	Global.add_message_show(Global.windows, "升级成功！！", 1.5, Vector2(500, 305))

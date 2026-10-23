extends Node2D
@onready var old_text: Label = $OldList/oldpic/sjq/OldText
@onready var new_text: Label = $NewList/newpic/sjq/NewText
@onready var add_prop_old: Label = $OldList/AddPropOld
@onready var skill_info_old: Label = $OldList/SkillInfoOld
@onready var add_prop_new: Label = $NewList/AddPropNew
@onready var skill_info_new: Label = $NewList/SkillInfoNew
@onready var item: Button = $TextureRect/Item
@onready var need: Label = $TextureRect/Need
@onready var needlh: Label = $lh/needlh
var zhen_fa_type
var father
var real_name


func _physics_process(delta: float) -> void:
	if father != null:
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
		set_item_pic()
		set_need_and_lh_info()
		set_skill_info()
		set_add_prop_text()


func set_item_pic():
	var item_name = "zftps"
	item.is_in_hhgz = true
	item.set_button_icon(load_item_icon(item_name))
	item.qh_level = 0
	item.wx = []
	item.eq_prop = AE.all_equipment[item_name]


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func set_add_prop_text():
	var cur_level = PlayerData.player_data[real_name]["Level"]
	old_text.text = "阵法等级：Lv." + str(cur_level)
	if cur_level + 1 < 10:
		new_text.text = "阵法等级：Lv." + str(cur_level + 1)
	else:
		new_text.text = "已满级"
	match real_name:
		"森罗阵":
			add_prop_old.text = "附加属性：最终伤害减少" + str(cur_level) + "%"
			if cur_level < 10:
				add_prop_new.text = "附加属性：最终伤害减少" + str(cur_level + 1) + "%"
			else:
				add_prop_new.text = ""
		"落魄阵":
			add_prop_old.text = "附加属性：最终伤害增加" + str(cur_level) + "%"
			if cur_level < 10:
				add_prop_new.text = "附加属性：最终伤害增加" + str(cur_level + 1) + "%"
			else:
				add_prop_new.text = ""
		"腾蛇阵":
			add_prop_old.text = "附加属性：受到爆伤伤害减少" + str(cur_level) + "%"
			if cur_level < 10:
				add_prop_new.text = "附加属性：受到爆伤伤害减少" + str(cur_level + 1) + "%"
			else:
				add_prop_new.text = ""
		"太清阵":
			add_prop_old.text = "附加属性：造成爆伤增加" + str(cur_level) + "%"
			if cur_level < 10:
				add_prop_new.text = "附加属性：造成爆伤增加" + str(cur_level + 1) + "%"
			else:
				add_prop_new.text = ""


func set_skill_info():
	var cur_level = PlayerData.player_data[real_name]["Level"]
	match real_name:
		"森罗阵":
			skill_info_old.text = "森罗阵Lv." + str(cur_level) + "：使用后立刻获得森罗加护（自身受伤减少" + str(cur_level * 2) + "%，持续10秒。）"
			if cur_level < 10:
				skill_info_new.text = (
					"森罗阵Lv." + str(cur_level + 1) + "：使用后立刻获得森罗加护（自身受伤减少" + str((cur_level + 1) * 2) + "%，持续10秒。）"
				)
			else:
				skill_info_new.text = ""
		"落魄阵":
			skill_info_old.text = (
				"落魄阵Lv."
				+ str(cur_level)
				+ "：对进入法阵的敌人有"
				+ str(cur_level * 10)
				+ "%概率对其施加虚弱效果（造成伤害降低"
				+ str(cur_level * 2)
				+ "%），阵法存在8秒，持续10秒。"
			)
			if cur_level < 10:
				skill_info_new.text = (
					"落魄阵Lv."
					+ str(cur_level + 1)
					+ "：对进入法阵的敌人有"
					+ str((cur_level + 1) * 10)
					+ "%概率对其施加虚弱效果（造成伤害降低"
					+ str((cur_level + 1) * 2)
					+ "%），阵法存在8秒，效果持续10秒。"
				)
			else:
				skill_info_new.text = ""
		"腾蛇阵":
			skill_info_old.text = "腾蛇阵Lv." + str(cur_level) + "：自身伤害增加" + str(cur_level * 1.5) + "%，持续10秒。"
			if cur_level < 10:
				skill_info_new.text = (
					"腾蛇阵Lv." + str(cur_level + 1) + "：自身伤害增加" + str((cur_level + 1) * 1.5) + "%，持续10秒。"
				)
			else:
				skill_info_new.text = ""
		"太清阵":
			skill_info_old.text = "太清阵Lv." + str(cur_level + 1) + "：每过1秒，清除处于法阵内玩家的低级负面，并恢复一定量的生命，令其1秒内不会被击退，法阵持续10秒。"
			if cur_level < 10:
				skill_info_new.text = (
					"太清阵Lv." + str(cur_level + 1) + "：每过1秒，清除处于法阵内玩家的低级负面，并恢复一定量的生命，令其1秒内不会被击退，法阵持续10秒。"
				)
			else:
				skill_info_new.text = ""


func set_need_and_lh_info():
	var cur_level = PlayerData.player_data[real_name]["Level"]
	var item_name = "zftps"
	var material_need_value = int(cur_level) * 10 + 10
	var need_lh = int(cur_level) * 10000 + 1000
	var current_num = int(PlayerData.get_item_data(item_name))
	need.text = str(PlayerData.get_item_data(item_name)) + "/" + str(material_need_value)
	if current_num >= material_need_value:
		need.add_theme_color_override("font_color", "00ff00")
	else:
		need.add_theme_color_override("font_color", "ff0000")
	needlh.text = "灵魂：" + str(need_lh)


func check_full_level():
	var list = PlayerData.player_data[real_name]
	var cur_level = PlayerData.player_data[real_name]["Level"]
	var need_level = 5 + cur_level * 5
	for i in list:
		if typeof(list[i]) == TYPE_DICTIONARY:
			if list[i]["Level"] < need_level:
				return false
	return true


func _on_tupo_pressed() -> void:
	var cur_level = PlayerData.player_data[real_name]["Level"]
	var item_name = "zftps"
	var material_need_value = int(cur_level) * 10 + 10
	var need_lh = int(cur_level) * 10000 + 1000
	var current_num := int(PlayerData.get_item_data(item_name))
	if cur_level >= 10:
		Global.add_message_show(Global.windows, "阵法已满级！！", 1.5, Vector2(500, 305))
		return
	if current_num < material_need_value:
		Global.add_message_show(Global.windows, "材料不足！！", 1.5, Vector2(500, 305))
		return
	if PlayerData.get_soul() < need_lh:
		Global.add_message_show(Global.windows, "灵魂不足！！", 1.5, Vector2(500, 305))
		return
	if not check_full_level():
		Global.add_message_show(Global.windows, "还有阵法未达到指定要求！！", 1.5, Vector2(500, 305))
		return
	PlayerData.spend_soul(need_lh)
	PlayerData.remove_dj(item_name, PlayerData.get_dj_page(item_name), material_need_value)
	PlayerData.player_data[real_name]["Level"] += 1
	Global.add_message_show(Global.windows, "阵法突破成功！！", 1.5, Vector2(500, 305))

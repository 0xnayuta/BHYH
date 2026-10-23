extends Node2D
@onready var text_1: Label = $PropText/text_1
@onready var text_2: Label = $PropText/text_2
@onready var text_3: Label = $PropText/text_3
@onready var text_4: Label = $PropText/text_4
@onready var zhen_fa_level: Label = $BG/ZhenFaLevel
@onready var add_prop: Label = $VBoxContainer2/AddProp
@onready var skill_info: Label = $VBoxContainer2/SkillInfo
var father
var zhen_fa_type: String
var real_name: String


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
		zhen_fa_level.text = "阵法等级：Lv." + str(PlayerData.player_data[real_name]["Level"])
		set_prop_text()
		set_add_prop_text()
		set_skill_info()
		set_physics_process(false)


func set_add_prop_text():
	var cur_level = PlayerData.player_data[real_name]["Level"]
	match real_name:
		"森罗阵":
			add_prop.text = "附加属性：最终伤害减少" + str(cur_level) + "%"
		"落魄阵":
			add_prop.text = "附加属性：最终伤害增加" + str(cur_level) + "%"
		"腾蛇阵":
			add_prop.text = "附加属性：受到爆伤伤害减少" + str(cur_level) + "%"
		"太清阵":
			add_prop.text = "附加属性：造成爆伤增加" + str(cur_level) + "%"


func set_skill_info():
	var cur_level = PlayerData.player_data[real_name]["Level"]
	match real_name:
		"森罗阵":
			skill_info.text = "森罗阵Lv." + str(cur_level) + "：使用后立刻获得森罗加护（自身受伤减少" + str(cur_level * 2) + "%，效果持续10秒）。"
		"落魄阵":
			skill_info.text = (
				"落魄阵Lv."
				+ str(cur_level)
				+ "：对进入法阵的敌人有"
				+ str(cur_level * 10)
				+ "%概率对其施加虚弱效果（造成伤害降低"
				+ str(cur_level * 2)
				+ "%），阵法存在8秒，持续10秒。"
			)
		"腾蛇阵":
			skill_info.text = "腾蛇阵Lv." + str(cur_level) + "：自身伤害增加" + str(cur_level * 1.5) + "%，持续10秒。"
		"太清阵":
			skill_info.text = "太清阵Lv." + str(cur_level) + "：每过1秒，清除处于法阵内玩家的低级负面，并恢复一定量的生命，令其1秒内不会被击退，法阵持续10秒。"


func set_prop_text():
	var list = PlayerData.player_data[real_name]
	for i in list:
		if typeof(list[i]) == TYPE_DICTIONARY:
			var prop = int(list[i]["Level"] * RoleProp.zhen_fa_props[real_name][i]["Value"])
			var prop_type = RoleProp.zhen_fa_props[real_name][i]["Type"]
			var target_text = get_node("PropText/text_" + str(i))
			if prop > 0:
				target_text.visible = true
				target_text.text = i + "号位Lv." + str(list[i]["Level"]) + "：" + str(prop_type) + "+" + str(prop)
			else:
				target_text.visible = false

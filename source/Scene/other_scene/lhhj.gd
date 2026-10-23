extends Node2D

const FULLSCREEN_DESIGN_SIZE := Vector2(922.0, 564.0)
const FULLSCREEN_CONTENT_CENTER := Vector2(461.0, 282.0)
var target_boss: String
@onready var boss_list: VBoxContainer = $BG/ColorRect/Text2/TotalList/BossList
@onready var text_3: Label = $BG/ColorRect/Text3
@onready var boss_list_1: VBoxContainer = $BG/ColorRect/Text/TotalList/BossList1
var boss_data = [
	{"Name": "白骨精·改", "Num": 3201},
	{"Name": "草木皆兵", "Num": 139},
	{"Name": "猕猴王", "Num": 4},
	{"Name": "禺狨王", "Num": 5},
	{"Name": "蝙蝠石像", "Num": 8},
	{"Name": "狮驼王", "Num": 11},
	{"Name": "鹏魔王", "Num": 12},
	{"Name": "蛟魔王", "Num": 18},
	{"Name": "鲨魔王", "Num": 20},
	{"Name": "牛魔王一", "Num": 22},
	{"Name": "牛魔王二", "Num": 23},
	{"Name": "牛魔王三", "Num": 24},
	{"Name": "龙王", "Num": 6},
	{"Name": "魔盾虎兵", "Num": 3001},
	{"Name": "猛虎射手", "Num": 3002},
	{"Name": "牛铁枪", "Num": 3003},
	{"Name": "投石车", "Num": 3004},
	{"Name": "寅将军", "Num": 3005},
	{"Name": "特处士", "Num": 3006},
	{"Name": "金之祖巫", "Num": 3007},
	{"Name": "蘑菇精", "Num": 3008},
	{"Name": "金钱松", "Num": 3009},
	{"Name": "人形藤蔓", "Num": 3010},
	{"Name": "苍耳妖", "Num": 3011},
	{"Name": "旋转斧头", "Num": 3012},
	{"Name": "闵老护法", "Num": 3019},
	{"Name": "道明妖僧", "Num": 3020},
	{"Name": "木之祖巫", "Num": 3021},
	{"Name": "贝壳", "Num": 3028},
	{"Name": "虎鲨", "Num": 3049},
	{"Name": "蚌女", "Num": 3030},
	{"Name": "虾兵", "Num": 3031},
	{"Name": "夜叉", "Num": 3032},
	{"Name": "灵感大王", "Num": 3033},
	{"Name": "四头虫", "Num": 3034},
	{"Name": "水之祖巫", "Num": 3035},
	{"Name": "火焰鸟", "Num": 3036},
	{"Name": "蝎子精", "Num": 3037},
	{"Name": "忍猴", "Num": 3038},
	{"Name": "百足蜈蚣", "Num": 3039},
	{"Name": "赤炎金刚", "Num": 3040},
	{"Name": "噬火毒蝎", "Num": 3041},
	{"Name": "火之祖巫", "Num": 3042},
	{"Name": "岩石怪", "Num": 3047},
	{"Name": "祖巫火球", "Num": 3056},
	{"Name": "鸟身女妖", "Num": 3065},
	{"Name": "泥偶精", "Num": 3066},
	{"Name": "花妖", "Num": 3067},
	{"Name": "核桃精", "Num": 3068},
	{"Name": "金光孔雀", "Num": 3069},
	{"Name": "芙蓉仙子", "Num": 3070},
	{"Name": "土之祖巫", "Num": 3071},
	{"Name": "守卫", "Num": 3076},
	{"Name": "土之祖巫", "Num": 3077},
	{"Name": "土之祖巫", "Num": 3078},
	{"Name": "后土小风", "Num": 3080},
	{"Name": "后土大风", "Num": 3081},
	{"Name": "石墙", "Num": 3082},
	{"Name": "通天教主(穷奇版)", "Num": 3117}
]
var ghost_list = [
	{"Name": "红孩儿", "Num": 29},
	{"Name": "白骨精", "Num": 32},
	{"Name": "傀儡", "Num": 34},
	{"Name": "傀儡王", "Num": 33},
	{"Name": "秦广王", "Num": 37},
	{"Name": "判官", "Num": 41},
	{"Name": "阎罗王", "Num": 43},
	{"Name": "宋帝王", "Num": 59},
	{"Name": "夜叉", "Num": 48},
	{"Name": "孟婆", "Num": 50},
	{"Name": "转轮王一", "Num": 57},
	{"Name": "转轮王二", "Num": 55},
	{"Name": "转轮王三", "Num": 56},
	{"Name": "五毒·五官王", "Num": 61},
	{"Name": "五毒·卞城王", "Num": 63},
	{"Name": "五毒·泰山王", "Num": 64},
	{"Name": "五毒·都市王", "Num": 65},
	{"Name": "五毒·平等王", "Num": 6601}
]
var sky_list = [
	{"Name": "千里眼", "Num": 77},
	{"Name": "顺风耳", "Num": 78},
	{"Name": "猕猴王·通风", "Num": 96},
	{"Name": "巨灵神", "Num": 79},
	{"Name": "增长天王", "Num": 83},
	{"Name": "广目天王", "Num": 84},
	{"Name": "多闻天王", "Num": 85},
	{"Name": "马天君", "Num": 134},
	{"Name": "持国天王", "Num": 137},
	{"Name": "朱子真", "Num": 89},
	{"Name": "袁洪", "Num": 91},
	{"Name": "二郎神", "Num": 93},
	{"Name": "土行孙", "Num": 100},
	{"Name": "雷震子", "Num": 101},
	{"Name": "哪吒", "Num": 102},
	{"Name": "托塔天王", "Num": 103},
	{"Name": "银角大王", "Num": 107},
	{"Name": "金角大王", "Num": 108},
	{"Name": "青牛精", "Num": 110},
	{"Name": "太白金星", "Num": 112},
	{"Name": "太上老君", "Num": 114},
	{"Name": "天庭战神", "Num": 132},
	{"Name": "牛魔王四", "Num": 141},
	{"Name": "转轮王四", "Num": 142},
	{"Name": "焰中仙", "Num": 140},
	{"Name": "花豹圣者·高友乾", "Num": 1401},
	{"Name": "狻猊圣者·杨森", "Num": 1402},
	{"Name": "狴犴圣者·王魔", "Num": 1403},
	{"Name": "碧宵娘娘", "Num": 1404},
	{"Name": "琼宵娘娘", "Num": 1406},
	{"Name": "云霄娘娘", "Num": 1407},
	{"Name": "千年妖蚊", "Num": 1408},
	{"Name": "千年蜈蚣", "Num": 1409},
	{"Name": "千年蝉妖", "Num": 1410},
	{"Name": "赤月神君", "Num": 146},
	{"Name": "紫眸鹫王", "Num": 147},
	{"Name": "白水神君", "Num": 148},
	{"Name": "紫睛鹏王", "Num": 149},
	{"Name": "青阳神君", "Num": 212}
]


func _physics_process(delta: float) -> void:
	if target_boss != null and target_boss != "":
		text_3.text = "设置" + str(target_boss) + "部分属性"
	else:
		text_3.text = "请选择Boss进行属性设置"


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(
		1.0, min(viewport_size.x / FULLSCREEN_DESIGN_SIZE.x, viewport_size.y / FULLSCREEN_DESIGN_SIZE.y)
	)
	scale = Vector2(fit_scale, fit_scale)
	position = viewport_size * 0.5 - FULLSCREEN_CONTENT_CENTER * fit_scale


func _ready() -> void:
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	Global.lhhj_boss_list.clear()
	add_total_list()


func add_total_list():
	if PlayerData.player_data["地府"]:
		for i in ghost_list:
			boss_data.push_back(i)
	if PlayerData.player_data["天庭"]:
		for i in sky_list:
			boss_data.push_back(i)
	for i in boss_data:
		Global.addlistbutton(boss_list_1, i["Name"], self, i["Num"])


func _on_challenge_pressed() -> void:
	if Global.lhhj_boss_list.size() <= 0:
		Global.add_message_show(get_parent(), "请至少添加一个boss！！", 1.5, Vector2(470, 300))
		return
	var scene_tree := get_tree()
	if scene_tree == null:
		push_error("当前节点不在场景树中，无法进入轮回幻境")
		return
	Global.cleanup_transient_ui()
	Global.call_deferred("change_scene", "res://Scene/level/level_lhhj.tscn")


func add_boss(Name, Num):
	if Global.lhhj_boss_list.has(Name):
		Global.add_message_show(get_parent(), "重复添加", 1.5, Vector2(470, 300))
		return
	Global.lhhj_boss_list[Name] = {
		"Num": Num,
		"Name": "",
		"Level": 0,
		"SHp": 0,
		"def": 0,
		"mdef": 0,
		"crit": 0,
		"miss": 0,
		"toughness": 0,
		"crit_reduce": 0,
		"htarget": 0,
		"lucky": 0,
		"ar": 0,
		"sp": 0,
		"speed": 0,
		"power": 0,
		"ebol": 0,
		"self_rhp": 0
	}
	Global.addlhhjbutton(boss_list, Name, self)


func show_prop() -> void:
	if target_boss == null or target_boss == "":
		return
	if not Global.lhhj_boss_list.has(target_boss):
		return

	var props_in_first = ["Name", "Level", "SHp", "def", "mdef", "crit", "miss", "power"]
	var props_in_second = [
		{"prop": "ebol", "node": "ebol"},
		{"prop": "lucky", "node": "lucky"},
		{"prop": "crit_reduce", "node": "Critreduce"},
		{"prop": "toughness", "node": "Toughness"},
		{"prop": "ar", "node": "ar"},
		{"prop": "sp", "node": "sp"},
		{"prop": "speed", "node": "speed"},
		{"prop": "self_rhp", "node": "self_rhp"},
	]

	for prop in props_in_first:
		var node_path = "BG/ColorRect/Text3/TotalList/BossList/" + prop
		var target_node = get_node_or_null(node_path)
		if target_node:
			target_node.text = str(Global.lhhj_boss_list[target_boss][prop])

	for item in props_in_second:
		var node_path = "BG/ColorRect/Text3/TotalList2/BossList/" + str(item["node"])
		var target_node = get_node_or_null(node_path)
		if target_node:
			target_node.text = str(Global.lhhj_boss_list[target_boss][item["prop"]])


func _on_remove_boss_pressed() -> void:
	if target_boss != null:
		if target_boss != "":
			Global.lhhj_boss_list.erase(target_boss)
			Global.add_message_show(get_parent(), "取消召唤" + str(target_boss) + "！！", 1.5, Vector2(470, 300))
		else:
			Global.add_message_show(get_parent(), "请选择要清除的boss！", 1.5, Vector2(470, 300))
			return
	else:
		Global.add_message_show(get_parent(), "请选择要清除的boss！", 1.5, Vector2(470, 300))
		return
	for i in boss_list.get_children():
		if i != null:
			if i.self_name == target_boss:
				boss_list.remove_child(i)
				i.queue_free()
	target_boss = ""


func _on_close_pressed() -> void:
	queue_free()


func _on_remove_all_pressed() -> void:
	Global.lhhj_boss_list.clear()
	for i in boss_list.get_children():
		if i != null:
			boss_list.remove_child(i)
			i.queue_free()
	target_boss = ""
	Global.add_message_show(get_parent(), "目标召唤列表已全部清除！！", 1.5, Vector2(470, 300))


func _on_remove_prop_pressed() -> void:
	if target_boss == null:
		Global.add_message_show(get_parent(), "请选择要清除属性的boss！", 1.5, Vector2(470, 300))
		return
	if target_boss == "":
		Global.add_message_show(get_parent(), "请选择要清除属性的boss！", 1.5, Vector2(470, 300))
		return

	for i in Global.lhhj_boss_list[target_boss]:
		if i != "Num":
			Global.lhhj_boss_list[target_boss][i] = 0
	Global.add_message_show(get_parent(), str(target_boss) + "属性已重置为基础属性！！", 1.5, Vector2(470, 300))


func set_prop(TargetProp: String, prop):
	if target_boss == null:
		Global.add_message_show(get_parent(), "请选择要设置属性的boss！", 1.5, Vector2(470, 300))
		return
	if target_boss == "":
		Global.add_message_show(get_parent(), "请选择要设置属性的boss！", 1.5, Vector2(470, 300))
		return
	if TargetProp != "Name" and TargetProp != "ebol":
		if not typeof(prop) == TYPE_INT:
			Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
			return
		if prop < 0:
			Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
			return
	elif TargetProp == "ebol":
		if not typeof(prop) == TYPE_FLOAT and not typeof(prop) == TYPE_INT:
			Global.add_message_show(get_parent(), "请输入整数或小数！", 1.5, Vector2(470, 300))
			return
		if prop < 0:
			Global.add_message_show(get_parent(), "请输入大于或等于0的整数或小数！", 1.5, Vector2(470, 300))
			return
	Global.lhhj_boss_list[target_boss][TargetProp] = prop


func _on_dj_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("Level", int(new_text))


func _on_hp_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("SHp", int(new_text))


func _on_def_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("def", int(new_text))


func _on_mdef_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("mdef", int(new_text))


func _on_crit_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("crit", int(new_text))


func _on_miss_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("miss", int(new_text))


func _on_power_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("power", int(new_text))


func _on_lucky_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("lucky", int(new_text))


func _on_critreduce_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("crit_reduce", int(new_text))


func _on_toughness_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("toughness", int(new_text))


func _on_ar_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("ar", int(new_text))


func _on_sp_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("sp", int(new_text))


func _on_speed_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("speed", int(new_text))


func _on_self_rhp_text_changed(new_text: String) -> void:
	var prop = int(new_text)
	if not typeof(prop) == TYPE_INT:
		Global.add_message_show(get_parent(), "请输入整数！", 1.5, Vector2(470, 300))
		return
	if prop < 0:
		Global.add_message_show(get_parent(), "请输入大于或等于0的整数！", 1.5, Vector2(470, 300))
		return
	set_prop("self_rhp", int(new_text))


func _on_help_pressed() -> void:
	Global.addlhhjhelp(self, Vector2(0, 0))


func _on_add_all_pressed() -> void:
	for i in boss_data:
		add_boss(i["Name"], i["Num"])


func _on_name_text_changed(new_text: String) -> void:
	set_prop("Name", str(new_text))


func _on_ebol_text_changed(new_text: String) -> void:
	set_prop("ebol", float(new_text))

extends Node2D
class_name BasicTask
@onready var text: Label = $BG/ms/ScrollContainer/Text
@onready var task_list: VBoxContainer = $BG/ScrollContainer/TaskList
@onready var reward_list: GridContainer = $BG/jl/ScrollContainer/RewardList
@onready var lqjl: TextureButton = $BG/lqjl
@onready var title: Label = $BG/ColorRect/Title
@onready var num: Label = $BG/ColorRect/Title/Num
var activity_finish_num: int = 0
var daily_finish_num: int = 0
var task_is_finish: bool
var current_task_name: String
var current_task_type: int = 1
var all_daily_list = {
	"关注八荒湮隳":
	{
		"task_name": "关注八荒湮隳",
		"task_type": "DailyTask",
		"task_info": "关注八荒湮隳",
		"task_reward": [{"Name": "bhyh", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0}],
		"UnlimitedClaim": true,
	},
	"至尊骨养成一":
	{
		"task_name": "至尊骨养成一",
		"task_type": "DailyTask",
		"task_info": "玩家等级达到1级就可以领取\n（" + str(PlayerData.player_data[DataKeys.PLAYER_LEVEL]) + "/1）",
		"task_reward": [{"Name": "psdzzg", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0}],
		"UnlimitedClaim": true,
	},
}
var all_activity_list = {
	"新的旅途":
	{
		"task_name": "新的旅途",
		"task_type": "ActivityTask",
		"task_info": "玩家等级达10级\n" + "（" + str(PlayerData.player_data[DataKeys.PLAYER_LEVEL]) + "/1）",
		"TaskTarget": {"玩家等级": 1},
		"FinishType": 2,
		"task_reward":
		[
			{
				"Name": "zcld",
				"Value": 1,
				"Prop": {},
				"WX":
				[
					"金",
					"木",
				],
				"strength_value": 0
			},
		],
	},
	"七魔尽伏":
	{
		"task_name": "七魔尽伏",
		"task_type": "ActivityTask",
		"task_info": "通关所有图一副本（花果山、水帘洞、桃花源、蝙蝠窟、七星洞、迦楼罗之穴、浅岸、东海、鲨之涡流、牛魔谷）",
		"TaskTarget":
		{"花果山": 1, "水帘洞": 1, "桃花源": 1, "蝙蝠窟": 1, "七星洞": 1, "迦楼罗之穴": 1, "浅岸": 1, "东海": 1, "鲨之涡流": 1, "牛魔谷": 1},
		"FinishType": 6,
		"task_reward":
		[
			{"Name": "fmxz", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "jsbx_1", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
		]
	},
	"十殿肃清":
	{
		"task_name": "十殿肃清",
		"task_type": "ActivityTask",
		"task_info": "通关所有图二副本（鬼城、无常巷、鬼门关、接引院、判官府、阎罗殿、忘川河、奈何桥、望乡台、转轮殿）",
		"TaskTarget":
		{"鬼城": 1, "无常巷": 1, "鬼门关": 1, "接引院": 1, "判官府": 1, "阎罗殿": 1, "忘川河": 1, "奈何桥": 1, "望乡台": 1, "转轮殿": 1},
		"FinishType": 6,
		"task_reward":
		[
			{"Name": "zmxz", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "jsbx_1", "Value": 3, "Prop": {}, "WX": [], "strength_value": 0},
		]
	},
	"成长礼包1":
	{
		"task_name": "成长礼包1",
		"task_type": "ActivityTask",
		"task_info": "玩家等级达10级\n" + "（" + str(PlayerData.player_data[DataKeys.PLAYER_LEVEL]) + "/10）",
		"TaskTarget": {"玩家等级": 10},
		"FinishType": 2,
		"task_reward":
		[
			{"Name": "xydxq", "Value": 2, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "mpyj", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 10, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "bsd_1", "Value": 3, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"成长礼包2":
	{
		"task_name": "成长礼包2",
		"task_type": "ActivityTask",
		"task_info": "玩家等级达20级\n" + "（" + str(PlayerData.player_data[DataKeys.PLAYER_LEVEL]) + "/20）",
		"TaskTarget": {"玩家等级": 20},
		"FinishType": 2,
		"task_reward":
		[
			{"Name": "xydxq", "Value": 2, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 18, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "szbx_1", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "bsd_2", "Value": 3, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "xlhys", "Value": 2, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "czlxls", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "wxxls", "Value": 30, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"成长礼包3":
	{
		"task_name": "成长礼包3",
		"task_type": "ActivityTask",
		"task_info": "玩家等级达30级\n" + "（" + str(PlayerData.player_data[DataKeys.PLAYER_LEVEL]) + "/30）",
		"TaskTarget": {"玩家等级": 30},
		"FinishType": 2,
		"task_reward":
		[
			{"Name": "xydxq", "Value": 2, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 25, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "szbx_2", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "renshen", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "liuhuang", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "shougong", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "lingli", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "xianmao", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "leizong", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "smlp", "Value": 50, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "xlhys", "Value": 5, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "czlxls", "Value": 30, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "wxxls", "Value": 60, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "ziyanyujin", "Value": 200, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"成长礼包4":
	{
		"task_name": "成长礼包4",
		"task_type": "ActivityTask",
		"task_info": "玩家等级达40级\n" + "（" + str(PlayerData.player_data[DataKeys.PLAYER_LEVEL]) + "/40）",
		"TaskTarget": {"玩家等级": 40},
		"FinishType": 2,
		"task_reward":
		[
			{"Name": "xydxq", "Value": 3, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 28, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "bsd_3", "Value": 3, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "renshen", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "liuhuang", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "shougong", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "lingli", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "xianmao", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "leizong", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "dudan", "Value": 30, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "smlp", "Value": 100, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "dlhys", "Value": 3, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "czlxls", "Value": 60, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "wxxls", "Value": 90, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "ziyanyujin", "Value": 300, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"决战平天大圣":
	{
		"task_name": "决战平天大圣",
		"task_type": "ActivityTask",
		"TaskTarget": {"牛魔王·鬼": 5},
		"FinishType": 1,
		"task_info": "击败牛魔王·鬼5次\n" + "（" + str(PlayerData.player_data["牛魔王·鬼"]) + "/5）",
		"task_reward":
		[
			{"Name": "bsd_4", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"浩瀚星河":
	{
		"task_name": "浩瀚星河",
		"task_type": "ActivityTask",
		"TaskTarget": {"转轮·真法": 5},
		"FinishType": 1,
		"task_info": "击败转轮·真法5次\n" + "（" + str(PlayerData.player_data["转轮·真法"]) + "/5）",
		"task_reward":
		[
			{"Name": "bsd_5", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"无首神":
	{
		"task_name": "无首神",
		"task_type": "ActivityTask",
		"TaskTarget": {"战神刑天": 10, "玩家等级": 50},
		"FinishType": 6,
		"task_info":
		(
			"击败战神刑天10次"
			+ "（"
			+ str(PlayerData.player_data["战神刑天"])
			+ "/10）玩家等级达50级"
			+ "（"
			+ str(PlayerData.player_data[DataKeys.PLAYER_LEVEL])
			+ "/50）"
		),
		"task_reward":
		[
			{"Name": "xmzy", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"小有所藏":
	{
		"task_name": "小有所藏",
		"task_type": "ActivityTask",
		"task_info": "幻化功能中，收集进度达5" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/5），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 5},
		"FinishType": 4,
		"task_reward":
		[
			{"Name": "xysc", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"业余收藏家":
	{
		"task_name": "业余收藏家",
		"task_type": "ActivityTask",
		"task_info": "幻化功能中，收集进度达10" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/10），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 10},
		"FinishType": 4,
		"task_reward":
		[
			{"Name": "yyscj", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 2, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"专业收藏家":
	{
		"task_name": "专业收藏家",
		"task_type": "ActivityTask",
		"task_info": "幻化功能中，收集进度达15" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/15），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 15},
		"FinishType": 4,
		"task_reward":
		[
			{"Name": "zyscj", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 3, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"痴迷收藏家":
	{
		"task_name": "痴迷收藏家",
		"task_type": "ActivityTask",
		"task_info": "幻化功能中，收集进度达20" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/20），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 20},
		"FinishType": 4,
		"task_reward":
		[
			{"Name": "cmscj", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 5, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"强迫症收藏家":
	{
		"task_name": "强迫症收藏家",
		"task_type": "ActivityTask",
		"task_info": "幻化功能中，收集进度达25" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/25），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 25},
		"FinishType": 4,
		"task_reward":
		[
			{"Name": "qpzscj", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 8, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"骨灰级收藏家":
	{
		"task_name": "骨灰级收藏家",
		"task_type": "ActivityTask",
		"task_info": "幻化功能中，收集进度达30" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/30），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 30},
		"FinishType": 4,
		"task_reward":
		[
			{"Name": "ghjscj", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 10, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"行走博物馆":
	{
		"task_name": "行走博物馆",
		"task_type": "ActivityTask",
		"task_info": "幻化功能中，收集进度达35" + "（" + str(PlayerData.player_data["幻化拥有列表"].size()) + "/35），若显示不准确，请先进去幻化界面再过来。",
		"TaskTarget": {"收集进度": 35},
		"FinishType": 4,
		"task_reward":
		[
			{"Name": "xzbwg", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "qhsbx", "Value": 15, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
	"勇闯八荒":
	{
		"task_name": "勇闯八荒",
		"task_type": "ActivityTask",
		"task_info": "未拥有过”修成正果头衔“，并且通过天庭",
		"TaskTarget": {"未持有": true, "天庭": true},
		"FinishType": 5,
		"task_reward":
		[
			{"Name": "hhyx", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0},
			{"Name": "jsbx_2", "Value": 2, "Prop": {}, "WX": [], "strength_value": 0},
		],
	},
}


func _remove_black_transparent_frames(root: Node = self) -> void:
	if root is ColorRect:
		(root as ColorRect).color = Color(0, 0, 0, 0)
	elif root is Label:
		var label := root as Label
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0))
		label.add_theme_constant_override("outline_size", 0)
		label.add_theme_constant_override("shadow_outline_size", 0)
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 0)
	for child in root.get_children():
		_remove_black_transparent_frames(child)


func _ready() -> void:
	_remove_black_transparent_frames()
	_clear_current_task_selection()
	add_task_list()


func _physics_process(delta: float) -> void:
	match current_task_type:
		1:
			title.text = "活动任务完成："
			num.text = "（" + str(activity_finish_num) + "/" + str(all_activity_list.size()) + "）"
			if current_task_name == null or current_task_name == "" or not all_activity_list.has(current_task_name):
				_disable_claim_button()
				return

			if current_task_name == "七魔尽伏":
				var target = all_activity_list["七魔尽伏"]["TaskTarget"]
				var completed = 0
				var total = target.size()
				for key in target.keys():
					if PlayerData.player_data.get(key, 0) >= target[key]:
						completed += 1
				text.text = "通关所有图一副本（已完成 {completed}/{total}）".format({"completed": completed, "total": total})

			elif current_task_name == "十殿肃清":
				var target = all_activity_list["十殿肃清"]["TaskTarget"]
				var completed = 0
				var total = target.size()
				for key in target.keys():
					if PlayerData.player_data.get(key, 0) >= target[key]:
						completed += 1
				text.text = "通关所有图二副本（已完成 {completed}/{total}）".format({"completed": completed, "total": total})
			else:
				text.text = str(all_activity_list[current_task_name]["task_info"])

			if task_is_finish:
				if not PlayerData.player_data.get(current_task_name, false):
					lqjl.disabled = false
				else:
					lqjl.disabled = true
			else:
				lqjl.disabled = true
		2:
			title.text = "日常任务完成："
			num.text = "（" + str(daily_finish_num) + "/" + str(all_daily_list.size()) + "）"
			if current_task_name == null or current_task_name == "" or not all_daily_list.has(current_task_name):
				_disable_claim_button()
				return
			text.text = str(all_daily_list[current_task_name]["task_info"])
			lqjl.disabled = not task_is_finish


func add_task_list():
	match current_task_type:
		1:
			remove_list()
			for i in all_activity_list:
				Global.add_task_title(
					task_list, all_activity_list[i]["task_type"], all_activity_list[i]["task_name"], self
				)
		2:
			remove_list()
			for i in all_daily_list:
				Global.add_task_title(task_list, all_daily_list[i]["task_type"], all_daily_list[i]["task_name"], self)


func add_reward():
	remove_reward()
	var task_data = _get_current_task_data()
	if task_data.is_empty():
		_disable_claim_button()
		return
	for i in task_data["task_reward"]:
		var item_name = i["Name"]
		var total_num = i["Value"]
		Global.add_task_reward(reward_list, item_name, total_num)


func _clear_current_task_selection() -> void:
	current_task_name = ""
	task_is_finish = false
	text.text = ""
	remove_reward()
	_disable_claim_button()


func _disable_claim_button() -> void:
	if lqjl != null:
		lqjl.disabled = true


func remove_reward():
	for i in reward_list.get_children():
		i.queue_free()


func remove_list():
	activity_finish_num = 0
	daily_finish_num = 0
	for i in task_list.get_children():
		i.queue_free()


func _on_lqjl_pressed() -> void:
	var task_data = _get_current_task_data()
	if task_data.is_empty():
		_disable_claim_button()
		return
	if not task_is_finish:
		_disable_claim_button()
		return
	if current_task_type == 1 and PlayerData.player_data.get(current_task_name, false):
		_disable_claim_button()
		return
	if not task_data.get("UnlimitedClaim", false):
		PlayerData.player_data[current_task_name] = true
	var list = task_data["task_reward"]
	Global.add_reward_info(Global.get_ancestor(self, 1), Vector2(0, 0), list, null, null)
	MemoryClass.save_game(Global.cd_path)


func _get_current_task_data() -> Dictionary:
	match current_task_type:
		1:
			if all_activity_list.has(current_task_name):
				return all_activity_list[current_task_name]
		2:
			if all_daily_list.has(current_task_name):
				return all_daily_list[current_task_name]
	return {}


func _on_close_pressed() -> void:
	queue_free()


func _on_hd_task_pressed() -> void:
	current_task_type = 1
	_clear_current_task_selection()
	add_task_list()


func _on_rc_task_pressed() -> void:
	current_task_type = 2
	_clear_current_task_selection()
	add_task_list()

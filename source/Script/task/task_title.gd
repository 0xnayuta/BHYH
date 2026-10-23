extends TextureButton
var task_name: String
var task_type: String
var my_father: BasicTask

@onready var tilte: Label = $Tilte
@onready var label: Label = $Label

var task_info: String
var reward_list = []
var nb_name: String
var finish: bool


func _physics_process(delta: float) -> void:
	tilte.text = task_name
	if task_type != "DailyTask" and PlayerData.player_data.get(task_name, false):
		label.text = "已领取"
		my_father.activity_finish_num += 1
		label.add_theme_color_override("font_color", "00ffff")
		label.add_theme_color_override("font_outline_color", "00ffff")
		set_physics_process(false)
		return
	if check_task_finish():
		finish = true
		if task_type == "DailyTask":
			my_father.daily_finish_num += 1
		label.text = "已完成"
		label.add_theme_color_override("font_color", "00ff00")
		label.add_theme_color_override("font_outline_color", "00ff00")
	else:
		finish = false
		label.text = "未完成"
		label.add_theme_color_override("font_color", "ff0000")
		label.add_theme_color_override("font_outline_color", "ff0000")
	set_physics_process(false)


func check_task_finish():
	match task_type:
		"ActivityTask":
			match my_father.all_activity_list[task_name]["FinishType"]:
				1:
					var target = my_father.all_activity_list[task_name]["TaskTarget"]
					for i in target:
						if PlayerData.player_data[i] < target[i]:
							return false
					return true
				2:
					var target = my_father.all_activity_list[task_name]["TaskTarget"]
					for i in target:
						if PlayerData.player_data[DataKeys.PLAYER_LEVEL] < target[i]:
							return false
					return true
				3:
					var target = my_father.all_activity_list[task_name]["TaskTarget"]
					match int(PlayerData.player_data["Myself"]):
						1:
							if PlayerData.check_have_zb("wkttzssz")[0]:
								return true
						2:
							if PlayerData.check_have_zb("tsttzssz")[0]:
								return true
						3:
							if PlayerData.check_have_zb("bjttzssz")[0]:
								return true
						4:
							if PlayerData.check_have_zb("ssttzssz")[0]:
								return true
					return false
				4:
					var target = my_father.all_activity_list[task_name]["TaskTarget"]
					if PlayerData.player_data["幻化拥有列表"].size() >= int(target["收集进度"]):
						return true
					return false
				5:
					var target = my_father.all_activity_list[task_name]["TaskTarget"]
					if not PlayerData.player_data["ieho"] and PlayerData.player_data["截教天镜"]:
						return true
					return false
				6:
					var target = my_father.all_activity_list[task_name]["TaskTarget"]
					for key in target.keys():
						if PlayerData.player_data.get(key, -1) < target[key]:
							return false
					return true
					return true

		"DailyTask":
			if task_name == DataKeys.Daily.EIGHT_IMMORTAL_TASK:
				return PlayerData.is_eight_immortal_daily_complete()
			return true
	return true


func _on_pressed() -> void:
	my_father.task_is_finish = finish
	my_father.current_task_type = 2 if task_type == "DailyTask" else 1
	my_father.current_task_name = task_name
	my_father.add_reward()

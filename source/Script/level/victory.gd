extends LevelSettlement
@onready var grades_s_how: AnimationPlayer = $GradesSHow
@onready var begin_time: Label = $GameUseTime/BeginTime
@onready var end_time: Label = $GameUseTime2/EndTime
@onready var use_time: Label = $GameUseTime3/UseTIME
@onready var hp_text: Label = $PlayerLastHp/Hp_text
@onready var most_lj_text: Label = $MostLj/MostLj_text
var last_time
const VICTORY_DESIGN_SIZE := Vector2(940.0, 590.0)
const PING_JIA_TEXTURE_SIZE := Vector2(93.0, 75.0)
const PING_JIA_FINAL_SCALE := 2.5


func _fit_to_window() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / VICTORY_DESIGN_SIZE.x, viewport_size.y / VICTORY_DESIGN_SIZE.y)
	var content_size = VICTORY_DESIGN_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - content_size) * 0.5


func _ready() -> void:
	_fit_to_window()
	if not get_viewport().size_changed.is_connected(_fit_to_window):
		get_viewport().size_changed.connect(_fit_to_window)
	Global.remove_all_buff()
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/13_game_victory.mp3")
	get_tree().paused = false
	Global.level_end_time = ""
	Global.level_end_time = Time.get_datetime_string_from_system(false, true) as String
	var num_1 = int(Global.level_end_time.split(" ")[1].split(":")[0]) * 3600
	var num_2 = int(Global.level_end_time.split(" ")[1].split(":")[1]) * 60
	var num_3 = int(Global.level_end_time.split(" ")[1].split(":")[2])
	var num_4 = int(Global.level_begin_time.split(" ")[1].split(":")[0]) * 3600
	var num_5 = int(Global.level_begin_time.split(" ")[1].split(":")[1]) * 60
	var num_6 = int(Global.level_begin_time.split(" ")[1].split(":")[2])
	var last_num = (num_1 + num_2 + num_3) - (num_4 + num_5 + num_6)

	last_time = get_lasttime(last_num)
	if Global.current_level == "火焰山":
		if not MainSet.set_data["LevelHYS"]:
			MainSet.set_data["LevelHYS"] = true
			MemoryClass.main_bc()
			Global.add_message_show(Global.get_ui_runtime().windows, "恭喜通关火焰山，解锁角色“猪八戒”！！", 1.5, Vector2(470, 300))
	begin_time.text = "开始时间：" + Global.level_begin_time
	end_time.text = "结束时间：" + Global.level_end_time
	use_time.text = (
		"过关用时：" + str(last_time["小时"]) + " 小时 " + str(last_time["分钟"]) + " 分钟 " + str(last_time["秒"]) + " 秒 "
	)
	hp_text.text = "剩余状态：" + str(snapped(float(RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp) * 100, 0.01)) + "%"
	most_lj_text.text = "最高连击：" + str(Global.most_lianji)
	if not MainSet.set_data["Music4"]:
		if randf_range(0, 1) <= 0.05:
			if p_dpj() >= 4:
				MainSet.set_data["Music4"] = true
				MemoryClass.main_bc()
				Global.add_message_show(Global.get_ui_runtime().windows, "触发彩蛋，恭喜开启图四音乐！！！", 1.5, Vector2(470, 300))
	if Global.current_level != "":
		var pj = p_dpj()
		if PlayerData.player_data["关卡评价"].has(Global.current_level):
			if pj >= PlayerData.player_data["关卡评价"][Global.current_level]:
				PlayerData.player_data["关卡评价"][Global.current_level] = pj
	_commit_settlement("level_victory")
	grades_s_how.play("Show")
	if MainSet.is_auto_battle_enabled() and bool(MainSet.set_data.get("AutoBattleRetry", false)):
		call_deferred("_auto_rechallenge")


func _return_map_path() -> String:
	if Global.current_level == "镇妖塔":
		return "res://Scene/main_menu/map_0.tscn"
	match int(PlayerData.player_data["Map_num"]):
		1:
			return "res://Scene/main_menu/map_1.tscn"
		2:
			if PlayerData.player_data["地府"]:
				return "res://Scene/main_menu/map_2.tscn"
			return "res://Scene/main_menu/map_1.tscn"
		3:
			if PlayerData.player_data["天庭"]:
				return "res://Scene/main_menu/map_3.tscn"
			return "res://Scene/main_menu/map_1.tscn"
		4:
			if PlayerData.player_data["截教天镜"]:
				return "res://Scene/main_menu/map_4.tscn"
			return "res://Scene/main_menu/map_1.tscn"
		5:
			if PlayerData.player_data.has("碧游宫") and PlayerData.player_data["碧游宫"]:
				return "res://Scene/main_menu/map_5.tscn"
			return "res://Scene/main_menu/map_1.tscn"
		6:
			if int(PlayerData.player_data.get("通天教主", 0)) == 1:
				return "res://Scene/main_menu/map_6.tscn"
			return "res://Scene/main_menu/map_1.tscn"
		7:
			return "res://Scene/main_menu/map_7.tscn"
		8:
			if PlayerData.player_data.get("Map_variant", "") == "Map_8_1":
				return "res://Scene/main_menu/map_8_1.tscn"
			return "res://Scene/main_menu/map_8.tscn"
		9:
			if PlayerData.player_data.get("Map_variant", "") == "Map_9_1":
				return "res://Scene/main_menu/map_9_1.tscn"
			return "res://Scene/main_menu/map_9.tscn"
		_:
			return "res://Scene/main_menu/map_1.tscn"


func _on_return_map_pressed() -> void:
	if not _begin_leave():
		return
	if not _flush_pending_settlement():
		_abort_leave()
		return
	RoleProp.ws_value = 0
	if not _request_scene_change(_return_map_path()):
		_abort_leave()


func get_lasttime(Num):
	var hour = floor(Num / 3600)
	var minute = floor(Num % 3600 / 60)
	var second = Num - hour * 3600 - minute * 60
	return {
		"小时": hour,
		"分钟": minute,
		"秒": second,
	}


func _on_more_informaition_pressed() -> void:
	Global.add_after_level_end(self, Vector2(0, 0))


func _on_rechallenge_pressed() -> void:
	if Global.last_level_path == "":
		Global.add_message_show(Global.get_ui_runtime().windows, "获取关卡信息时出现错误，请手动更换关卡！！", 1.5, Vector2(470, 300))
		return
	if not _begin_rechallenge():
		return
	if not _flush_pending_settlement():
		_abort_rechallenge()
		return
	_reset_role_state_for_rechallenge()
	if not _request_scene_change(Global.last_level_path):
		_abort_rechallenge()


func _auto_rechallenge() -> void:
	await get_tree().create_timer(1.0).timeout
	if is_inside_tree() and not _is_rechallenging:
		_on_rechallenge_pressed()


func p_dpj():
	var current_zt = int(snapped(float(RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp) * 100, 0.01))
	if last_time["分钟"] <= 2 and Global.total_hurt_count == 0 and current_zt >= 95:
		return 5
	else:
		match int(last_time["分钟"]):
			0:
				if current_zt <= 100 and current_zt >= 85:
					return 4
				elif current_zt < 85 and current_zt >= 75:
					return 3
				elif current_zt < 75 and current_zt >= 65:
					return 2
				else:
					return 1
			1:
				if current_zt <= 100 and current_zt >= 85:
					return 4
				elif current_zt < 85 and current_zt >= 75:
					return 3
				elif current_zt < 75 and current_zt >= 65:
					return 2
				else:
					return 1
			2:
				if current_zt <= 100 and current_zt >= 85:
					return 4
				elif current_zt < 85 and current_zt >= 75:
					return 3
				elif current_zt < 75 and current_zt >= 65:
					return 2
				else:
					return 1
			3:
				if current_zt <= 100 and current_zt >= 85:
					return 4
				elif current_zt < 85 and current_zt >= 75:
					return 3
				elif current_zt < 75 and current_zt >= 65:
					return 2
				else:
					return 1
			4:
				if current_zt <= 100 and current_zt >= 85:
					return 3
				elif current_zt < 85 and current_zt >= 75:
					return 2
				elif current_zt < 75 and current_zt >= 65:
					return 2
				else:
					return 1
			5:
				if current_zt <= 100 and current_zt >= 85:
					return 2
				elif current_zt < 85 and current_zt >= 75:
					return 2
				elif current_zt < 75 and current_zt >= 65:
					return 1
				else:
					return 1
			6:
				if current_zt <= 100 and current_zt >= 85:
					return 2
				elif current_zt < 85 and current_zt >= 75:
					return 1
				elif current_zt < 75 and current_zt >= 65:
					return 1
				else:
					return 1
	return 1


func add_pj():
	var ping_jia_size := PING_JIA_TEXTURE_SIZE * PING_JIA_FINAL_SCALE

	Global.add_pj(self, Vector2(65, 65), p_dpj())


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_fit_to_window):
		get_viewport().size_changed.disconnect(_fit_to_window)

extends Node2D
class_name GameSet
const GAME_SET_DESIGN_SIZE := Vector2(942.0, 589.0)
@onready var gm_open_or_close: Button = $Bg/BGColor/VBoxContainer/GameMusicTitle/GMOpenOrClose
@onready var gm_2_open_or_close: Button = $Bg/BGColor/VBoxContainer/GameMusicTitle2/GM2OpenOrClose
@onready var h_slider: HSlider = $Bg/BGColor/VBoxContainer/GameMusicFB/HSlider
@onready var gm_2_slider: HSlider = $Bg/BGColor/VBoxContainer/GameMusicFB2/GM2Slider
@onready var mbt_open_or_close: Button = $Bg/BGColor/VBoxContainer/MonsterBloodText/MBTOpenOrClose
@onready var mbs_open_or_close: Button = $Bg/BGColor/VBoxContainer/MonsterBloodShow/MBSOpenOrClose
@onready var mbs2_open_or_close: Button = $Bg/BGColor/VBoxContainer/MonsterBloodShow2/MBS2OpenOrClose
@onready var damage_show: Button = $Bg/BGColor/VBoxContainer/DamageTextShow/DamageShow
@onready var yes_or_no: Button = $Bg/BGColor/VBoxContainer2/BodyShow/YesOrNo
@onready var yes_or_not: Button = $Bg/BGColor/VBoxContainer2/HpBloodDelay/YesORNot
@onready var yes_or_nots: Button = $Bg/BGColor/VBoxContainer2/AutomaticallyPickUpItems/YesOrNots
@onready var ornot: Button = $Bg/BGColor/VBoxContainer2/AutomaticallyPickUpItems2/Ornot
@onready var open_close: Button = $Bg/BGColor/VBoxContainer2/LevelInfo/openClose
@onready var show_close_2: Button = $Bg/BGColor/VBoxContainer/RoleEQ/ShowClose2
@onready var show_close: Button = $Bg/BGColor/VBoxContainer2/RoleBody/ShowClose
@onready var frame_rate_option: OptionButton = $Bg/BGColor/VBoxContainer2/FrameRate/FrameRateOption

var is_set = false
var music_is_change = false
var _last_setting_state_mask := -1


func _fit_to_viewport() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / GAME_SET_DESIGN_SIZE.x, viewport_size.y / GAME_SET_DESIGN_SIZE.y)
	var panel_size = GAME_SET_DESIGN_SIZE * fit_scale
	global_scale = Vector2(fit_scale, fit_scale)
	global_position = (viewport_size - panel_size) * 0.5


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_fit_to_viewport()


func _ready() -> void:
	if not get_viewport().size_changed.is_connected(_fit_to_viewport):
		get_viewport().size_changed.connect(_fit_to_viewport)
	_fit_to_viewport()
	_fix_setting_layout_rows()
	_setup_frame_rate_option()


func _fix_setting_layout_rows() -> void:
	var rows := [
		[$Bg/BGColor/VBoxContainer/GameMusicTitle, Vector2(290, 38)],
		[$Bg/BGColor/VBoxContainer/GameMusicTitle2, Vector2(290, 38)],
		[$Bg/BGColor/VBoxContainer/GameMusicFB, Vector2(290, 38)],
		[$Bg/BGColor/VBoxContainer/GameMusicFB2, Vector2(290, 38)],
		[$Bg/BGColor/VBoxContainer/MonsterBloodText, Vector2(300, 38)],
		[$Bg/BGColor/VBoxContainer/MonsterBloodShow, Vector2(300, 38)],
		[$Bg/BGColor/VBoxContainer/MonsterBloodShow2, Vector2(300, 38)],
		[$Bg/BGColor/VBoxContainer/RoleEQ, Vector2(290, 31)],
		[$Bg/BGColor/VBoxContainer/DamageTextShow, Vector2(290, 31)],
		[$Bg/BGColor/VBoxContainer2/GameMusicTitle, Vector2(390, 38)],
		[$Bg/BGColor/VBoxContainer2/GameMusicTitle2, Vector2(330, 38)],
		[$Bg/BGColor/VBoxContainer2/FrameRate, Vector2(330, 36)],
		[$Bg/BGColor/VBoxContainer2/BodyShow, Vector2(360, 31)],
		[$Bg/BGColor/VBoxContainer2/HpBloodDelay, Vector2(290, 35)],
		[$Bg/BGColor/VBoxContainer2/AutomaticallyPickUpItems, Vector2(290, 30)],
		[$Bg/BGColor/VBoxContainer2/AutomaticallyPickUpItems2, Vector2(290, 31)],
		[$Bg/BGColor/VBoxContainer2/LevelInfo, Vector2(330, 31)],
		[$Bg/BGColor/VBoxContainer2/RoleBody, Vector2(290, 31)],
	]
	for row in rows:
		var label := row[0] as Label
		if label == null:
			continue
		label.custom_minimum_size = row[1]
		label.clip_text = false
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT


func _setup_frame_rate_option() -> void:
	frame_rate_option.clear()
	var selected_index := 0
	var saved_frame_rate := MainSet.get_frame_rate()
	for frame_rate in MainSet.FRAME_RATE_OPTIONS:
		frame_rate_option.add_item("%d FPS" % frame_rate, frame_rate)
		if frame_rate == saved_frame_rate:
			selected_index = frame_rate_option.item_count - 1
	frame_rate_option.select(selected_index)


func _get_setting_state_mask() -> int:
	var state_mask := 0
	if bool(MainSet.set_data["NotShowRoleBody"]):
		state_mask |= 1 << 0
	if bool(MainSet.set_data["NotShowRoleEQ"]):
		state_mask |= 1 << 1
	if bool(MainSet.set_data["BackGroundMusic"]):
		state_mask |= 1 << 2
	if bool(MainSet.set_data["RoleOrMonsterHit"]):
		state_mask |= 1 << 3
	if bool(MainSet.set_data["MonsterBloodTextSHow"]):
		state_mask |= 1 << 4
	if bool(MainSet.set_data["MonsterBloodSHow"]):
		state_mask |= 1 << 5
	if bool(MainSet.set_data["MonsterLittleBlood"]):
		state_mask |= 1 << 6
	if bool(MainSet.set_data["NoShowMonsterBody"]):
		state_mask |= 1 << 7
	if bool(MainSet.set_data["HpBarDelay"]):
		state_mask |= 1 << 8
	if bool(MainSet.set_data["automatically_pick_up_items"]):
		state_mask |= 1 << 9
	if bool(MainSet.set_data["PickUpItemsMusic"]):
		state_mask |= 1 << 10
	if bool(MainSet.set_data["LevelInfo"]):
		state_mask |= 1 << 11
	if bool(MainSet.set_data.get("ShowDamageText", true)):
		state_mask |= 1 << 12
	return state_mask


func _physics_process(_delta: float) -> void:
	var setting_state_mask := _get_setting_state_mask()
	if is_set and setting_state_mask == _last_setting_state_mask:
		return
	_last_setting_state_mask = setting_state_mask
	if MainSet.set_data["NotShowRoleBody"]:
		show_close.text = "不显示"
	else:
		show_close.text = "显示中"
	if MainSet.set_data["NotShowRoleEQ"]:
		show_close_2.text = "不显示"
	else:
		show_close_2.text = "显示中"

	if MainSet.set_data["BackGroundMusic"] == true:
		gm_open_or_close.text = "开启中"
	else:
		gm_open_or_close.text = "关闭中"
	if MainSet.set_data["RoleOrMonsterHit"] == true:
		gm_2_open_or_close.text = "开启中"
	else:
		gm_2_open_or_close.text = "关闭中"
	if MainSet.set_data["MonsterBloodTextSHow"]:
		mbt_open_or_close.text = "开启中"
	else:
		mbt_open_or_close.text = "关闭中"

	if MainSet.set_data["MonsterBloodSHow"]:
		mbs_open_or_close.text = "开启中"
	else:
		mbs_open_or_close.text = "关闭中"
	if MainSet.set_data["MonsterLittleBlood"]:
		mbs2_open_or_close.text = "开启中"
	else:
		mbs2_open_or_close.text = "关闭中"
	if bool(MainSet.set_data.get("ShowDamageText", true)):
		damage_show.text = "显示中"
	else:
		damage_show.text = "不显示"
	if MainSet.set_data["NoShowMonsterBody"]:
		yes_or_no.text = "当前显示"
	else:
		yes_or_no.text = "当前不显示"
	if MainSet.set_data["HpBarDelay"]:
		yes_or_not.text = "开启中"
	else:
		yes_or_not.text = "关闭中"
	if MainSet.set_data["automatically_pick_up_items"]:
		yes_or_nots.text = "开启中"
	else:
		yes_or_nots.text = "关闭中"
	if MainSet.set_data["PickUpItemsMusic"]:
		ornot.text = "开启中"
	else:
		ornot.text = "关闭中"
	if MainSet.set_data["LevelInfo"]:
		open_close.text = "开启中"
	else:
		open_close.text = "关闭中"
	if not is_set:
		h_slider.set_value_no_signal(MainSet.set_data["MusicFB"])
		gm_2_slider.set_value_no_signal(MainSet.set_data["MusicFB_2"])
		is_set = true


func _on_frame_rate_option_item_selected(index: int) -> void:
	var frame_rate := frame_rate_option.get_item_id(index)
	if frame_rate not in MainSet.FRAME_RATE_OPTIONS:
		return
	MainSet.set_data["FrameRate"] = frame_rate
	MainSet.apply_frame_rate()
	MemoryClass.main_bc()


func _on_gm_open_or_close_pressed() -> void:
	if MainSet.set_data["BackGroundMusic"] == true:
		MainSet.set_data["BackGroundMusic"] = false
	else:
		MainSet.set_data["BackGroundMusic"] = true
	MemoryClass.main_bc()


func _on_gm_2_open_or_close_pressed() -> void:
	if MainSet.set_data["RoleOrMonsterHit"] == true:
		MainSet.set_data["RoleOrMonsterHit"] = false
	else:
		MainSet.set_data["RoleOrMonsterHit"] = true
	MemoryClass.main_bc()


func _on_h_slider_value_changed(value: float) -> void:
	MainSet.set_data["MusicFB"] = value
	MemoryClass.main_bc()


func _on_return_pressed() -> void:
	queue_free()


func _on_gm_2_slider_value_changed(value: float) -> void:
	MainSet.set_data["MusicFB_2"] = value
	MemoryClass.main_bc()


func _on_mbt_open_or_close_pressed() -> void:
	if MainSet.set_data["MonsterBloodTextSHow"]:
		MainSet.set_data["MonsterBloodTextSHow"] = false
	else:
		MainSet.set_data["MonsterBloodTextSHow"] = true
	MemoryClass.main_bc()


func _on_mbs_open_or_close_pressed() -> void:
	if MainSet.set_data["MonsterBloodSHow"]:
		MainSet.set_data["MonsterBloodSHow"] = false
	else:
		MainSet.set_data["MonsterBloodSHow"] = true
	MemoryClass.main_bc()


func _on_mbs_2_open_or_close_pressed() -> void:
	if MainSet.set_data["MonsterLittleBlood"]:
		MainSet.set_data["MonsterLittleBlood"] = false
	else:
		MainSet.set_data["MonsterLittleBlood"] = true
	MemoryClass.main_bc()


func _on_damage_show_pressed() -> void:
	var show_damage := not bool(MainSet.set_data.get("ShowDamageText", true))
	Global.set_damage_text_enabled(show_damage)
	MemoryClass.main_bc()


func _on_g_mzm_1_pressed() -> void:
	MainSet.set_data["music"] = 1
	MemoryClass.main_bc()
	music_is_change = true


func _on_g_mzm_2_pressed() -> void:
	if MainSet.set_data["CurrentLevelPage"] >= 2:
		MainSet.set_data["music"] = 2
		MemoryClass.main_bc()
		music_is_change = true
	else:
		Global.add_message_show(Global.windows, "到达二图解锁二图背景音乐", 1.5, Vector2(470, 300))


func _on_g_mzm_3_pressed() -> void:
	if MainSet.set_data["CurrentLevelPage"] >= 3:
		MainSet.set_data["music"] = 3
		MemoryClass.main_bc()
		music_is_change = true
	else:
		Global.add_message_show(Global.windows, "到达三图解锁三图背景音乐", 1.5, Vector2(470, 300))


func _on_gm_2_zm_1_pressed() -> void:
	MainSet.set_data["MainMenuBG"] = 1
	MemoryClass.main_bc()


func _on_gm_2_zm_2_pressed() -> void:
	if MainSet.is_main_menu_background_unlocked(2):
		MainSet.set_data["MainMenuBG"] = 2
		MemoryClass.main_bc()
	else:
		Global.add_message_show(Global.windows, "到达二图解锁二图封面", 1.5, Vector2(470, 300))


func _on_gm_2_zm_3_pressed() -> void:
	if MainSet.is_main_menu_background_unlocked(3):
		MainSet.set_data["MainMenuBG"] = 3
		MemoryClass.main_bc()
	else:
		Global.add_message_show(Global.windows, "到达三图解锁三图封面", 1.5, Vector2(470, 300))


func _on_yes_or_no_pressed() -> void:
	if MainSet.set_data["NoShowMonsterBody"]:
		MainSet.set_data["NoShowMonsterBody"] = false
	else:
		MainSet.set_data["NoShowMonsterBody"] = true
	MemoryClass.main_bc()


func _on_yes_or_not_pressed() -> void:
	if MainSet.set_data["HpBarDelay"]:
		MainSet.set_data["HpBarDelay"] = false
	else:
		MainSet.set_data["HpBarDelay"] = true
	MemoryClass.main_bc()


func _on_yes_or_nots_pressed() -> void:
	if MainSet.set_data["automatically_pick_up_items"]:
		MainSet.set_data["automatically_pick_up_items"] = false
	else:
		MainSet.set_data["automatically_pick_up_items"] = true
	MemoryClass.main_bc()


func _on_g_mzm_4_pressed() -> void:
	if MainSet.set_data["Music4"]:
		MainSet.set_data["music"] = 4
		MemoryClass.main_bc()
		music_is_change = true
	else:
		Global.add_message_show(Global.windows, "还未开启四图音乐哦，快去游戏中寻找一下吧~", 1.5, Vector2(470, 300))


func _on_ornot_pressed() -> void:
	if MainSet.set_data["PickUpItemsMusic"]:
		MainSet.set_data["PickUpItemsMusic"] = false
	else:
		MainSet.set_data["PickUpItemsMusic"] = true
	MemoryClass.main_bc()


func _on_open_close_pressed() -> void:
	if MainSet.set_data["LevelInfo"]:
		MainSet.set_data["LevelInfo"] = false
	else:
		MainSet.set_data["LevelInfo"] = true
	MemoryClass.main_bc()


func _on_show_close_2_pressed() -> void:
	if MainSet.set_data["NotShowRoleEQ"]:
		MainSet.set_data["NotShowRoleEQ"] = false
	else:
		MainSet.set_data["NotShowRoleEQ"] = true
	MemoryClass.main_bc()


func _on_show_close_pressed() -> void:
	if MainSet.set_data["NotShowRoleBody"]:
		MainSet.set_data["NotShowRoleBody"] = false
	else:
		MainSet.set_data["NotShowRoleBody"] = true
	MemoryClass.main_bc()

extends Node2D
const MAIN_MENU_DESIGN_SIZE := Vector2(940.0, 590.0)
# C3 资产迁移后的规范文件名；使用显式数组保持静态引用，避免动态拼接再次漏迁移。
const MAIN_MENU_BACKGROUND_PATHS := [
	"res://Art/main_game/bei_jing_1_runtime.jpg",
	"res://Art/main_game/bei_jing_2_runtime.jpg",
	"res://Art/main_game/bei_jing_3_runtime.jpg",
	"res://Art/main_game/bei_jing_4_runtime.jpg",
	"res://Art/main_game/bei_jing_5_runtime.jpg",
	"res://Art/main_game/bei_jing_6_runtime.jpg",
]
var abx: TextureButton
@onready var ar_infer: Node2D = $ar_infer
@onready var b_gset: Node2D = $BGset

@onready var begin_game: TextureButton = $Begin_game

@onready var music_set = $Music_set

@onready var music: TextureButton = $music

@onready var tiaoguo: TextureButton = $tiaoguo
@onready var tiaoguo_label: Label = $tiaoguo/tiaoguo_label

@onready var back_ground = $background

@onready var name_2: Label = $name/name2
@onready var http_request: HTTPRequest = $HTTPRequest
var times: int = 0
var my_music
var is_playing = false
var cd_jm
var message_box
var music_jm
var game_set: GameSet
var _last_plot_skip: Variant = null
var _last_main_menu_bg := -1
var _active_main_menu_background_path := ""


func _fit_main_menu_to_viewport() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / MAIN_MENU_DESIGN_SIZE.x, viewport_size.y / MAIN_MENU_DESIGN_SIZE.y)
	var menu_size = MAIN_MENU_DESIGN_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - menu_size) * 0.5


func _menu_content_parent() -> Node:
	return self


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_fit_main_menu_to_viewport()


func _ready() -> void:
	if not get_viewport().size_changed.is_connected(_fit_main_menu_to_viewport):
		get_viewport().size_changed.connect(_fit_main_menu_to_viewport)
	_fit_main_menu_to_viewport()
	_apply_main_menu_background(_resolve_main_menu_background())
	if Global == null:
		print("错误：Global 未加载")
		return
	if MainSet.set_data.has("FileValue"):
		if float(MainSet.set_data["FileValue"]) < float(Global.file_num):
			MainSet.set_data["FileValue"] = Global.file_num
	Global.set_cd_path("")
	Global.collect_num = 0
	Global.llbt_level = 1
	Global.llbtbossms = false
	Global.llbtcgms = false
	Global.llbtwxms = false
	Global.get_ui_runtime().windows = get_parent()
	Global.fb_cd = 0
	Global.is_eye_fix = false
	Global.is_dead_link = false
	MemoryClass.remove_play_data()
	RoleProp.ws_value = 0
	MemoryClass.main_dq()
	if not Global.get_audio_runtime().has_main_menu_music():
		Global.get_audio_runtime().add_main_menu_music()
	if MainSet.set_data["FristGame"]:
		Global.add_game_need_know(_menu_content_parent(), Vector2(0, 0))
		pass


func _exit_tree() -> void:
	if is_instance_valid(http_request):
		http_request.cancel_request()
	back_ground.texture = null
	Global.release_cached_texture(_active_main_menu_background_path)
	_active_main_menu_background_path = ""


func _apply_main_menu_background(index: int) -> void:
	var clamped_index := clampi(index, 1, 6)
	var next_background_path: String = MAIN_MENU_BACKGROUND_PATHS[clamped_index - 1]
	if _active_main_menu_background_path != "" and _active_main_menu_background_path != next_background_path:
		back_ground.texture = null
		Global.release_cached_texture(_active_main_menu_background_path)
	_active_main_menu_background_path = next_background_path
	_last_main_menu_bg = clamped_index
	match clamped_index:
		1:
			name_2.text = "《八荒湮隳篇·力战七大魔王》"
		2:
			name_2.text = "《八荒湮隳篇·勇斗十殿阎罗》"
		3:
			name_2.text = "《八荒湮隳篇·智取十万天兵》"
		4, 5, 6:
			name_2.text = ""
	back_ground.texture = (
		ResourceLoader.load(next_background_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
	)


func _resolve_main_menu_background() -> int:
	var saved_background := int(MainSet.set_data.get("MainMenuBG", 1))
	var resolved_background := MainSet.normalize_main_menu_background(saved_background)
	if resolved_background != saved_background:
		MainSet.set_data["MainMenuBG"] = resolved_background
		MemoryClass.main_bc()
	return resolved_background


func _physics_process(_delta: float) -> void:
	var plot_skip := bool(MainSet.set_data["剧情跳过"])
	if plot_skip != _last_plot_skip:
		_last_plot_skip = plot_skip
		tiaoguo_label.text = "显示剧情" if plot_skip else "跳过剧情"
	var main_menu_bg := _resolve_main_menu_background()
	if main_menu_bg != _last_main_menu_bg:
		_apply_main_menu_background(main_menu_bg)
	RoleProp.ws_value = 0
	var music_menu_open := music_set.get_child_count() != 0
	if music.disabled != music_menu_open:
		music.disabled = music_menu_open
	if music_menu_open:
		if music_jm != null:
			if music_jm.is_change:
				Global.get_audio_runtime().add_main_menu_music()
				music_jm.is_change = false
	if game_set != null:
		if game_set.music_is_change:
			Global.get_audio_runtime().add_main_menu_music()
			game_set.music_is_change = false


func _on_begin_game_pressed() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/2_sd_xz.mp3")

	if ar_infer.get_child_count() == 0:
		cd_jm = Global.add_cd_jm(ar_infer, Vector2(0, 0))


func _on_music_pressed() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/2_sd_xz.mp3")
	music_jm = Global.add_music_set(music_set, Vector2(0, 0))


func _on_gmae_help_pressed() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/2_sd_xz.mp3")
	Global.add_gm_infor(_menu_content_parent(), Vector2(0, 0))


func _on_tiaoguo_pressed() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/2_sd_xz.mp3")
	if MainSet.set_data["剧情跳过"]:
		MainSet.set_data["剧情跳过"] = false
		Global.add_message_show(get_parent(), "将不会跳过结束剧情！！", 1.5, Vector2(470, 340))
	else:
		MainSet.set_data["剧情跳过"] = true
		Global.add_message_show(get_parent(), "将会跳过结束剧情！！", 1.5, Vector2(470, 340))
	MemoryClass.main_bc()


func _on_change_bg_pressed() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/2_sd_xz.mp3")
	Global.add_change_bg(b_gset, Vector2(0, 0))


func _on_game_set_pressed() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/2_sd_xz.mp3")
	game_set = Global.add_game_set(_menu_content_parent(), Vector2(0, 0))


func _on_game_warn_pressed() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/2_sd_xz.mp3")
	Global.add_game_need_know(_menu_content_parent(), Vector2(0, 0))


func check_time():
	var error = http_request.request("http://quan.suning.com/getSysTime.do")
	if error != OK:
		push_error("在HTTP请求中发生了一个错误。")
	times += 1
	if times >= 15:
		Global.add_message_show(get_parent(), "获取时间信息失败，网络连接可能存在问题，部分功能将无法使用！！", 1.5, Vector2(470, 340))


func _on_body_received(request, body):
	var time_str = body.get_string_from_utf8()
	if time_str == "":
		print("无法获取时间1！！")
		check_time()
		Global.add_message_show(get_parent(), "获取时间信息失败，网络连接可能存在问题，部分功能将无法使用！！", 1.5, Vector2(470, 340))
		return null
	var utc_time = JSON.parse_string(time_str)
	if utc_time == null:
		print("无法获取时间2！！")
		check_time()
		Global.add_message_show(get_parent(), "获取时间信息失败，网络连接可能存在问题，部分功能将无法使用！！", 1.5, Vector2(470, 340))
		return null
	var t_ime_unix = int(utc_time["sysTime2"])
	if t_ime_unix == null or str(t_ime_unix) == "":
		print("无法获取时间3！！")
		check_time()
		Global.add_message_show(get_parent(), "获取时间信息失败，网络连接可能存在问题，部分功能将无法使用！！", 1.5, Vector2(470, 340))
		return null
	return t_ime_unix


func _on_http_request_request_completed(
	result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray
) -> void:
	if not is_inside_tree():
		return
	if _on_body_received(result, body) != null:
		var abc = str(_on_body_received(result, body)).split()
		var data_list = {
			"year": str(abc[0] + abc[1] + abc[2] + abc[3]),
			"month": str(abc[4] + abc[5]),
			"day": str(abc[6] + abc[7]),
			"hour": str(abc[8] + abc[9]),
			"minute": str(abc[10] + abc[11]),
			"second": str(abc[12] + abc[13]),
		}
		refresh_time(data_list)


func refresh_time(data_list):
	var dic = data_list
	var my_dic = MainSet.set_data["MyTime"]

	if my_dic.size() <= 0:
		return
	if int(dic["year"]) < int(my_dic["year"]):
		return
	elif int(dic["year"]) > int(my_dic["year"]):
		print("更新年")
		MainSet.set_data["MyTime"] = data_list
	else:
		if int(dic["month"]) < int(my_dic["month"]):
			return
		elif int(dic["month"]) > int(my_dic["month"]):
			print("更新月")
			MainSet.set_data["MyTime"] = data_list
		else:
			if int(dic["day"]) < int(my_dic["day"]):
				return
			elif int(dic["day"]) > int(my_dic["day"]):
				print("更新日")
				MainSet.set_data["MyTime"] = data_list
			else:
				return
	MemoryClass.main_bc()


func _on_letter_pressed() -> void:
	Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/2_sd_xz.mp3")
	Global.add_letter_for_player(_menu_content_parent(), Vector2(0, 0))

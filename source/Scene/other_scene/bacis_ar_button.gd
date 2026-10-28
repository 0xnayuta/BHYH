extends TextureButton

@onready var my_num: Label = $MyNum
@onready var name_label: Label = $InfoBox/Name
@onready var level_and_role: Label = $InfoBox/LevelAndRole
@onready var time: Label = $InfoBox/Time

var archive_num: int
var _mode_picker: CanvasLayer


func _physics_process(_delta: float) -> void:
	set_normal_info()
	set_physics_process(false)


func set_normal_info() -> void:
	my_num.text = str(archive_num)
	var archive_data: Dictionary = MemoryClass.peek_archive_data(_archive_path(archive_num))
	var role_id: int = int(archive_data.get("Myself", 0))
	if role_id < 1 or role_id > 7:
		name_label.text = ""
		time.text = ""
		level_and_role.text = "空存档"
		return

	var metadata: Dictionary = _archive_metadata(archive_num)
	var archive_time: String = str(metadata.get("time", ""))
	if archive_time.strip_edges() == "":
		archive_time = MemoryClass.read_archive_time(_archive_path(archive_num))
		if archive_time != "":
			MemoryClass.repair_archive_time(archive_num, archive_time)
	var archive_name: String = str(metadata.get("name", ""))
	time.text = archive_time
	name_label.text = "名字：" + archive_name if archive_name != "" else ""
	var coop_value: Variant = archive_data.get(LocalCoop.SAVE_KEY, {})
	if coop_value is Dictionary and bool((coop_value as Dictionary).get("启用", false)):
		var p2_value: Variant = (coop_value as Dictionary).get("2P", {})
		if p2_value is Dictionary:
			var p1_level := int(archive_data.get(DataKeys.PLAYER_LEVEL, 1))
			var p2_level := int((p2_value as Dictionary).get(DataKeys.PLAYER_LEVEL, 1))
			level_and_role.text = (
				"1P  Lv：%d  %s\n2P  Lv：%d  %s"
				% [p1_level, _role_name(role_id), p2_level, _role_name(int((p2_value as Dictionary).get("Myself", 0)))]
			)
			return
	level_and_role.text = (
		"Lv：" + str(MemoryClass.get_archive_level(_archive_path(archive_num))) + "    " + _role_name(role_id)
	)


func _archive_path(archive_number: int) -> String:
	return "user://MyAr_" + str(archive_number) + ".json"


func _archive_metadata(archive_number: int) -> Dictionary:
	if archive_number <= 6:
		return {
			"name": MainSet.set_data.get("name" + str(archive_number), ""),
			"time": MainSet.set_data.get("time" + str(archive_number), ""),
		}
	var other_archives_value: Variant = MainSet.set_data.get("其他存档", {})
	if not other_archives_value is Dictionary:
		return {}
	var other_archives: Dictionary = other_archives_value as Dictionary
	var metadata_value: Variant = other_archives.get(str(archive_number), {})
	return metadata_value as Dictionary if metadata_value is Dictionary else {}


func _role_name(role_id: int) -> String:
	match role_id:
		1:
			return "悟空"
		2:
			return "唐僧"
		3:
			return "八戒"
		4:
			return "沙僧"
		5:
			return "白龙"
		6:
			return "哪吒"
		7:
			return "玉兔"
	return "空存档"


func _on_pressed() -> void:
	Global.set_cd_path("user://MyAr_" + str(archive_num) + ".json")
	if not MemoryClass.load_game(Global.get_cd_path()):
		return
	if PlayerData.player_data.has("FileValue"):
		if float(PlayerData.player_data["FileValue"]) <= float(Global.file_num):
			PlayerData.player_data["FileValue"] = Global.file_num
		else:
			Global.add_message_show(get_parent(), "当前游戏不是最新版本，请使用最新版本游戏！！！", 1.5, Vector2(470, 340))
			return
	if level_and_role.text == "空存档":
		_open_creation_mode()
	else:
		await Global.begin_archive_session()
		change_to_map()


func _open_creation_mode() -> void:
	if OS.has_feature("mobile"):
		_on_creation_mode_selected(1)
		return
	if is_instance_valid(_mode_picker):
		return
	_mode_picker = load("res://Scene/main_menu/game_mode_select.tscn").instantiate()
	_mode_picker.mode_selected.connect(_on_creation_mode_selected)
	add_child(_mode_picker)


func _on_creation_mode_selected(player_count: int) -> void:
	LocalCoop.creation_player_count = player_count
	if is_instance_valid(_mode_picker):
		_mode_picker.queue_free()
	Global.change_scene("res://Scene/main_menu/choose_player.tscn")


func change_to_map():
	Global.change_scene("res://Scene/main_menu/map_0.tscn")


func get_time():
	var date = Time.get_date_string_from_system()
	var _time = Time.get_time_string_from_system()
	var last_time = date + " " + _time
	return last_time

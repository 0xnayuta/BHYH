extends Node
var player_data = PlayerData.player_data
var _player:
	get:
		return player_data
	set(v):
		player_data = v
var initialized_data = {}
var get_sj = {}
var limit_time = {
	"year": 2024,
	"month": 5,
	"day": 9,
	"hour": 13,
	"minute": 35,
	"second": 0,
}
var level
const ARCHIVE_BACKUP_SUFFIX: String = ".bak"
const ARCHIVE_TEMP_SUFFIX: String = ".tmp"
const SAVE_KEY_PATH: String = "user://.save_key"
const MAIN_SETTINGS_PATH: String = "user://MainGame.json"
const ARCHIVE_CONTAINER_KEYS := ["装备列表", "道具列表", "消耗品列表"]
const ARCHIVE_TIME_KEY: String = "存档时间"

signal background_save_finished(path: String, success: bool)
var _save_thread: Thread
var _active_save_job: Dictionary = {}
var _pending_background_saves: Dictionary = {}
var _failed_background_saves: Dictionary = {}
var _save_flush_in_progress := false


func request_background_save(path: String) -> bool:
	if _archive_number_from_path(path) <= 0:
		return false
	var snapshot := _prepare_player_save_data()
	if snapshot.is_empty():
		return false
	var password := _ensure_stable_key()
	if password.is_empty():
		return false
	var job := {"path": path, "data": snapshot, "password": password}
	_failed_background_saves.erase(path)

	_pending_background_saves[path] = job
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	_start_next_background_save()
	return true


static func _write_background_save(job: Dictionary) -> bool:
	return _atomic_write_encrypted_dictionary(str(job["path"]), job["data"], str(job["password"]))


func _start_next_background_save() -> void:
	if _save_thread != null or _pending_background_saves.is_empty() or _save_flush_in_progress:
		return
	var path := str(_pending_background_saves.keys()[0])
	_active_save_job = _pending_background_saves[path]
	_pending_background_saves.erase(path)
	_save_thread = Thread.new()
	var error := _save_thread.start(_write_background_save.bind(_active_save_job))
	if error != OK:
		_save_thread = null
		var failed_job := _active_save_job
		_active_save_job = {}
		_complete_background_save(failed_job, false)


func _complete_background_save(job: Dictionary, success: bool) -> void:
	var path := str(job["path"])
	if success:
		_failed_background_saves.erase(path)
		if is_instance_valid(MainSet):
			_set_archive_time(_archive_number_from_path(path), str(job["data"][ARCHIVE_TIME_KEY]))

	elif not _pending_background_saves.has(path):
		_failed_background_saves[path] = job
		push_error("后台存档写入失败，已保留快照，退出/下次同步保存时重试：" + path)
	background_save_finished.emit(path, success)


func _collect_background_save() -> void:
	if _save_thread == null:
		return
	var success := bool(_save_thread.wait_to_finish())
	var job := _active_save_job
	_save_thread = null
	_active_save_job = {}
	_complete_background_save(job, success)


func _process(_delta: float) -> void:
	if _save_thread != null and not _save_thread.is_alive():
		_collect_background_save()
	_start_next_background_save()
	if _save_thread == null and _pending_background_saves.is_empty():
		set_process(false)


func flush_pending_saves() -> bool:
	if _save_flush_in_progress:
		return false
	_save_flush_in_progress = true
	_collect_background_save()
	while not _pending_background_saves.is_empty():
		var path := str(_pending_background_saves.keys()[0])
		var job: Dictionary = _pending_background_saves[path]
		_pending_background_saves.erase(path)
		_complete_background_save(job, _write_background_save(job))

	for path in _failed_background_saves.keys():
		var job: Dictionary = _failed_background_saves[path]
		_complete_background_save(job, _write_background_save(job))
	_save_flush_in_progress = false
	return _failed_background_saves.is_empty()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		flush_pending_saves()


func _exit_tree() -> void:
	flush_pending_saves()


var _stable_key: String = ""
var _stable_key_loaded: bool = false
var _main_settings_loaded: bool = false


func check_out_time():
	var dic = limit_time
	var my_dic = MainSet.set_data["MyTime"]
	if my_dic == {}:
		return
	if int(dic["year"]) < int(my_dic["year"]):
		return true
	elif int(dic["year"]) > int(my_dic["year"]):
		return false
	else:
		if int(dic["month"]) < int(my_dic["month"]):
			return true
		elif int(dic["month"]) > int(my_dic["month"]):
			return false
		else:
			if int(dic["day"]) < int(my_dic["day"]):
				return true
			elif int(dic["day"]) > int(my_dic["day"]):
				return false
			else:
				if int(dic["hour"]) < int(my_dic["hour"]):
					return true
				elif int(dic["hour"]) > int(my_dic["hour"]):
					return false
				else:
					if int(dic["minute"]) < int(my_dic["minute"]):
						return true
					elif int(dic["minute"]) > int(my_dic["minute"]):
						return false
					else:
						return true


func load_game(路径) -> bool:
	var path: String = str(路径)
	var read_result: Dictionary = _read_encrypted_dictionary_compatible(path, keys)
	if not bool(read_result.get("ok", false)):
		return false
	var archive_data_value: Variant = read_result.get("data", {})
	if archive_data_value is Dictionary:
		var archive_data: Dictionary = archive_data_value.duplicate(true)
		if not archive_data.is_empty():
			archive_data.erase(ARCHIVE_TIME_KEY)
			player_data["已获取装备列表"] = []
			LocalCoop.clear_runtime()
			player_data.erase(LocalCoop.SAVE_KEY)
			_player.merge(archive_data, true)
	PlayerData.normalize_soul()
	PlayerData.migrate_consumables_from_dj_to_xhp()
	PlayerData.ensure_shengu_slot()
	PlayerData.ensure_acquired_equipment_data()
	PlayerData.ensure_player_passive_skills()
	PlayerData._remove_retired_wudu_magic_weapons()
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()
	if PlayerData.has_method("ensure_mount_data"):
		PlayerData.ensure_mount_data()
	PlayerData.enforce_level_caps()
	PlayerData.ensure_pet_tiger()
	PlayerData.ensure_pet_dragon()
	PlayerData.ensure_pet_phoenix()
	PlayerData.ensure_pet_turtle()
	PlayerData.ensure_pet_rabbit()
	if PlayerData.has_method("ensure_pet_neat"):
		PlayerData.ensure_pet_neat()
	if PlayerData.has_method("ensure_pet_yin_tiger"):
		PlayerData.ensure_pet_yin_tiger()
	if PlayerData.has_method("ensure_shared_pet_backpack"):
		PlayerData.ensure_shared_pet_backpack()
	LocalCoop.load_profile()
	return true


func peek_archive_data(路径) -> Dictionary:
	var read_result: Dictionary = _read_encrypted_dictionary_compatible(str(路径), keys)
	var data_value: Variant = read_result.get("data", {})
	return data_value if data_value is Dictionary else {}


func get_archive_level(路径) -> int:
	var archive_data: Dictionary = peek_archive_data(路径)
	if not archive_data.has(DataKeys.PLAYER_LEVEL):
		return 1
	return clampi(int(archive_data[DataKeys.PLAYER_LEVEL]), 1, int(PlayerData.PLAYER_MAX_LEVEL))


func read_archive_time(路径) -> String:
	var archive_path: String = str(路径)
	var read_result: Dictionary = _read_encrypted_dictionary_compatible(archive_path, keys)
	var archive_data_value: Variant = read_result.get("data", {})
	var recovered_from_backup: bool = bool(read_result.get("recovered_from_backup", false))
	var has_archive_data: bool = archive_data_value is Dictionary and not (archive_data_value as Dictionary).is_empty()
	if has_archive_data and not recovered_from_backup and FileAccess.file_exists(archive_path):
		var modified_time: int = int(FileAccess.get_modified_time(archive_path))
		if modified_time > 0:
			return Time.get_datetime_string_from_unix_time(modified_time, true)

	var archive_data: Dictionary = archive_data_value if archive_data_value is Dictionary else {}
	var archive_time_value: Variant = archive_data.get(ARCHIVE_TIME_KEY, "")
	var archive_time: String = str(archive_time_value).strip_edges()
	if archive_time != "":
		return archive_time
	var backup_path: String = archive_path + ARCHIVE_BACKUP_SUFFIX
	if FileAccess.file_exists(backup_path):
		var backup_modified_time: int = int(FileAccess.get_modified_time(backup_path))
		if backup_modified_time > 0:
			return Time.get_datetime_string_from_unix_time(backup_modified_time, true)
	return ""


var keys = "zmxybhyh" + OS.get_unique_id() + "v1.1"


func save_game(path: String) -> bool:
	flush_pending_saves()
	var archive_path: String = str(path)
	var archive_number: int = _archive_number_from_path(archive_path)
	if archive_number <= 0:
		return false
	var save_data := _prepare_player_save_data()
	if save_data.is_empty():
		return false
	if not safe_write_archive(archive_path, save_data):
		return false
	_failed_background_saves.erase(archive_path)
	_set_archive_time(archive_number, str(save_data[ARCHIVE_TIME_KEY]))
	if not main_bc():
		push_warning("存档列表元数据写入失败，将从玩家存档时间恢复")
	return true


func _prepare_player_save_data() -> Dictionary:
	var swapped := LocalCoop.suspend_player_view()
	var snapshot := _prepare_primary_player_save_data()
	if not snapshot.is_empty():
		LocalCoop.save_profile(snapshot)
		LocalCoop.link_bags()
	if swapped:
		LocalCoop.resume_player_view()
	return snapshot


func _prepare_primary_player_save_data() -> Dictionary:
	if not _is_valid_player_archive_data(PlayerData.player_data):
		push_error("拒绝保存无效的玩家存档数据")
		return {}
	PlayerData.normalize_soul()
	PlayerData.ensure_acquired_equipment_data()
	PlayerData.migrate_consumables_from_dj_to_xhp()
	PlayerData.ensure_player_passive_skills()
	PlayerData._remove_retired_wudu_magic_weapons()
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()
	if PlayerData.has_method("ensure_main_sword_array"):
		PlayerData.ensure_main_sword_array()
	if PlayerData.has_method("ensure_wanling_catalog_data"):
		PlayerData.ensure_wanling_catalog_data()
	if PlayerData.has_method("ensure_mount_data"):
		PlayerData.ensure_mount_data()
	PlayerData.enforce_level_caps()
	PlayerData.ensure_pet_tiger()
	PlayerData.ensure_pet_dragon()
	PlayerData.ensure_pet_phoenix()
	PlayerData.ensure_pet_turtle()
	PlayerData.ensure_pet_rabbit()
	if PlayerData.has_method("ensure_pet_neat"):
		PlayerData.ensure_pet_neat()
	if PlayerData.has_method("ensure_pet_yin_tiger"):
		PlayerData.ensure_pet_yin_tiger()
	if PlayerData.has_method("ensure_shared_pet_backpack"):
		PlayerData.ensure_shared_pet_backpack()

	var save_data: Dictionary = PlayerData.player_data.duplicate(true)
	if not _is_valid_player_archive_data(save_data):
		push_error("拒绝保存不完整的玩家存档数据")
		return {}
	save_data[ARCHIVE_TIME_KEY] = get_time()
	return save_data


func main_dq():
	if not _main_settings_loaded:
		_load_main_settings(MAIN_SETTINGS_PATH)

		_main_settings_loaded = true

	if MainSet.has_method("apply_frame_rate"):
		MainSet.apply_frame_rate()


func _load_main_settings(path: String) -> void:
	var read_result: Dictionary = _read_encrypted_dictionary_compatible(path, keys2)
	if not bool(read_result.get("ok", false)):
		return
	var settings_value: Variant = read_result.get("data", {})
	if settings_value is Dictionary:
		MainSet.set_data.merge(settings_value, true)


var keys2 = "zmxybhyh" + OS.get_unique_id() + "v1.1"


func main_bc() -> bool:
	var persisted_settings: Dictionary = MainSet.set_data.duplicate(true)
	persisted_settings.erase("AutoBattleEnabled")
	return _atomic_write_encrypted_dictionary(MAIN_SETTINGS_PATH, persisted_settings, _ensure_stable_key())


func safe_write_archive(path: String, data: Dictionary) -> bool:
	flush_pending_saves()
	var success := _atomic_write_encrypted_dictionary(path, data, _ensure_stable_key())
	if success:
		_failed_background_saves.erase(path)
	return success


func _is_valid_player_archive_data(data: Dictionary) -> bool:
	if data.is_empty() or not data.has(DataKeys.PLAYER_LEVEL) or not data.has("Myself"):
		return false
	for key in ARCHIVE_CONTAINER_KEYS:
		var container_value: Variant = data.get(key, null)
		if not container_value is Dictionary:
			return false
		var container: Dictionary = container_value
		var first_page_value: Variant = container.get("页码1", null)
		if not first_page_value is Array:
			return false
	return true


static func _read_encrypted_dictionary(path: String, password: String) -> Dictionary:
	var result: Dictionary = {"ok": false, "missing": false, "data": {}}
	if not FileAccess.file_exists(path):
		result["ok"] = true
		result["missing"] = true
		return result

	var plain_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if plain_file == null:
		return result
	var plain_length: int = plain_file.get_length()
	plain_file.close()
	if plain_length <= 0:
		result["ok"] = true
		return result

	var reader: FileAccess = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
	if reader == null:
		return result
	var data: Dictionary = {}
	var found_json: bool = false
	while reader.get_position() < reader.get_length():
		var line: String = reader.get_line()
		if line.strip_edges().is_empty():
			continue
		found_json = true
		var parsed: Variant = JSON.parse_string(line)
		if not parsed is Dictionary:
			reader.close()
			return result
		var parsed_dictionary: Dictionary = parsed as Dictionary
		data.merge(parsed_dictionary, true)
	reader.close()
	result["ok"] = true
	result["data"] = data if found_json else {}
	return result


func _read_encrypted_dictionary_with_backup(path: String, password: String) -> Dictionary:
	var primary: Dictionary = _read_encrypted_dictionary(path, password)
	var primary_data_value: Variant = primary.get("data", {})
	var primary_has_data: bool = primary_data_value is Dictionary and not (primary_data_value as Dictionary).is_empty()
	if bool(primary.get("ok", false)) and not bool(primary.get("missing", false)) and primary_has_data:
		return primary

	var backup: Dictionary = _read_encrypted_dictionary(path + ARCHIVE_BACKUP_SUFFIX, password)
	if bool(backup.get("ok", false)) and not bool(backup.get("missing", false)):
		var backup_data_value: Variant = backup.get("data", {})
		var backup_has_data: bool = backup_data_value is Dictionary and not (backup_data_value as Dictionary).is_empty()
		if backup_has_data or not bool(primary.get("ok", false)) or bool(primary.get("missing", false)):
			backup["recovered_from_backup"] = true
			return backup

	if bool(primary.get("ok", false)):
		return primary
	return primary if bool(backup.get("missing", false)) else backup


func _read_encrypted_dictionary_compatible(path: String, primary_password: String) -> Dictionary:
	flush_pending_saves()
	var fallback: Dictionary = {"ok": false, "missing": false, "data": {}}
	var passwords: Array = []
	var stable_key: String = _load_stable_key()
	if stable_key != "":
		passwords.append(stable_key)
	if primary_password != stable_key:
		passwords.append(primary_password)

	for password_value in passwords:
		var password: String = str(password_value)
		var attempt: Dictionary = _read_encrypted_dictionary_with_backup(path, password)
		if bool(attempt.get("ok", false)) and not bool(attempt.get("missing", false)):
			return attempt
		if not bool(fallback.get("ok", false)) or not bool(attempt.get("missing", false)):
			fallback = attempt
	return fallback


static func _atomic_write_encrypted_dictionary(path: String, data: Dictionary, password: String) -> bool:
	if path.strip_edges() == "" or password == "":
		return false
	var temp_path: String = path + ARCHIVE_TEMP_SUFFIX
	var backup_path: String = path + ARCHIVE_BACKUP_SUFFIX
	if not _remove_file_if_exists(temp_path):
		return false

	var payload: String = JSON.stringify(data)
	if payload == "" or payload == "null":
		return false
	var writer: FileAccess = FileAccess.open_encrypted_with_pass(temp_path, FileAccess.WRITE, password)
	if writer == null:
		return false
	writer.store_line(payload)
	writer.flush()
	var write_error: Error = writer.get_error()
	writer.close()
	if write_error != OK:
		_remove_file_if_exists(temp_path)
		return false

	var verified: Dictionary = _read_encrypted_dictionary(temp_path, password)
	if not bool(verified.get("ok", false)):
		_remove_file_if_exists(temp_path)
		return false

	if not _remove_file_if_exists(backup_path):
		_remove_file_if_exists(temp_path)
		return false
	var had_target: bool = FileAccess.file_exists(path)
	if had_target and not _rename_file(path, backup_path):
		_remove_file_if_exists(temp_path)
		return false
	if not _rename_file(temp_path, path):
		if had_target and not FileAccess.file_exists(path) and FileAccess.file_exists(backup_path):
			_rename_file(backup_path, path)
		_remove_file_if_exists(temp_path)
		return false
	return true


static func _remove_file_if_exists(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	return error == OK or not FileAccess.file_exists(path)


static func _rename_file(from_path: String, to_path: String) -> bool:
	var error: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(from_path), ProjectSettings.globalize_path(to_path)
	)
	return error == OK


func _load_stable_key() -> String:
	if _stable_key_loaded:
		return _stable_key
	_stable_key_loaded = true
	if not FileAccess.file_exists(SAVE_KEY_PATH):
		return ""
	var key_file: FileAccess = FileAccess.open(SAVE_KEY_PATH, FileAccess.READ)
	if key_file == null:
		return ""
	var saved_key: String = key_file.get_as_text().strip_edges()
	key_file.close()
	if saved_key != "":
		_stable_key = saved_key
	return _stable_key


func _ensure_stable_key() -> String:
	var existing_key: String = _load_stable_key()
	if existing_key != "":
		return existing_key
	_stable_key = str(keys)
	var key_file: FileAccess = FileAccess.open(SAVE_KEY_PATH, FileAccess.WRITE)
	if key_file != null:
		key_file.store_string(_stable_key)
		key_file.flush()
		key_file.close()
	return _stable_key


func _archive_number_from_path(path: String) -> int:
	var prefix: String = "user://MyAr_"
	if not path.begins_with(prefix) or not path.ends_with(".json"):
		return 0
	var number_text: String = path.substr(prefix.length(), path.length() - prefix.length() - 5)
	if not number_text.is_valid_int():
		return 0
	var number: int = int(number_text)
	return number if number > 0 else 0


func _set_archive_time(archive_number: int, time_text: String) -> void:
	if archive_number <= 6:
		MainSet.set_data["time" + str(archive_number)] = time_text
		return
	var other_archives_value: Variant = MainSet.set_data.get("其他存档", {})
	var other_archives: Dictionary = other_archives_value as Dictionary if other_archives_value is Dictionary else {}
	var archive_key: String = str(archive_number)
	if not other_archives.has(archive_key) or not (other_archives[archive_key] is Dictionary):
		other_archives[archive_key] = {"name": "", "time": ""}
	var archive_meta: Dictionary = other_archives[archive_key] as Dictionary
	archive_meta["time"] = time_text
	MainSet.set_data["其他存档"] = other_archives


func repair_archive_time(archive_number: int, time_text: String) -> bool:
	if archive_number <= 0 or time_text.strip_edges() == "":
		return false
	_set_archive_time(archive_number, time_text)
	return main_bc()


func get_time():
	var date = Time.get_date_string_from_system()
	var _time = Time.get_time_string_from_system()
	var last_time = date + " " + _time
	return last_time


func get_cd_number():
	if Global.cd_path == null:
		return "1"
	var number: int = _archive_number_from_path(str(Global.cd_path))
	return str(number) if number > 0 else "1"


func remove_data():
	initialized_data = PlayerData.initialized_data.duplicate(true)
	remove_main_data(get_cd_number())

	MemoryClass.main_bc()


func remove_play_data():
	initialized_data = PlayerData.initialized_data.duplicate(true)

	_player.clear()
	_player.merge(initialized_data.duplicate(true))
	pass


func remove():
	Global.add_message_show(Global.windows, "数据不正常哦，拜拜啦~", 4, Vector2(485, 295))
	remove_data()
	MainSet.set_data["xg"] = true
	safe_write_archive(str(Global.cd_path), initialized_data)
	MemoryClass.save_game(Global.cd_path)


func remove_main_data(Num: int):
	if Num <= 6:
		MainSet.set_data["name" + str(Num)] = ""
		MainSet.set_data["time" + str(Num)] = ""
	else:
		MainSet.set_data["其他存档"][str(Num)]["name"] = ""
		MainSet.set_data["其他存档"][str(Num)]["time"] = ""

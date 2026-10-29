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

signal background_save_finished(path: String, success: bool, serial: int)
## 同步保存失败信号：即使调用方丢弃 bool，Global 也能记录并给出反馈。
signal save_failed(reason: String, error: String, message: String, notify: bool)
## 最近一次保存失败的程序化原因（"" 表示最近一次成功或尚未保存）。
## 取值：invalid_archive_path / stale_archive_identity / normalize_failed:<键> / invalid_archive_data / write_failed
var last_save_error: String = ""
var _save_thread: Thread
var _active_save_job: Dictionary = {}
var _pending_background_saves: Dictionary = {}
var _failed_background_saves: Dictionary = {}
var _save_flush_in_progress := false
var _save_snapshot_in_progress := false
## 最近一次同步保存结果；入口可观察，不依赖调用方是否判读 bool。
var last_save_outcome: Dictionary = {}
## 后台写任务序号：每次入队递增；完成信号携带同一序号，消费方可判定信号顺序。
var _background_save_serial: int = 0
var _last_background_save_serial: int = 0


## 后台保存：路径缺省取当前会话档案；调用方不能借路径参数越过会话身份。
func request_background_save(path: String = "") -> bool:
	if not Global.is_archive_session_active():
		last_save_error = "no_archive_session"
		return false
	var session_path: String = Global.get_archive_session_path().strip_edges()
	var archive_path: String = session_path if str(path).strip_edges() == "" else str(path).strip_edges()
	if archive_path != session_path:
		last_save_error = "stale_archive_identity"
		return false
	if archive_number_from_path(archive_path) <= 0:
		last_save_error = "invalid_archive_path"
		return false
	if not is_archive_identity_current(archive_path, Global.get_archive_identity_epoch()):
		last_save_error = "stale_archive_identity"
		return false
	var snapshot := _prepare_player_save_data()
	if snapshot.is_empty():
		return false
	var password := _ensure_stable_key()
	if password.is_empty():
		return false
	_background_save_serial += 1
	var job := {
		"path": archive_path,
		"data": snapshot,
		"password": password,
		"generation": Global.get_archive_identity_epoch(),
		"serial": _background_save_serial,
	}
	_failed_background_saves.erase(archive_path)

	_pending_background_saves[archive_path] = job
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	_start_next_background_save()
	return true


static func _write_background_save(job: Dictionary) -> bool:
	return _atomic_write_encrypted_dictionary(str(job["path"]), job["data"], str(job["password"]))


func _start_next_background_save() -> void:
	if _save_thread != null or _pending_background_saves.is_empty() or _save_flush_in_progress:
		return
	var job := _take_current_background_job()
	if job.is_empty():
		return
	_active_save_job = job
	_save_thread = Thread.new()
	var error := _save_thread.start(_write_background_save.bind(_active_save_job))
	if error != OK:
		_save_thread = null
		var failed_job := _active_save_job
		_active_save_job = {}
		_complete_background_save(failed_job, false)


## 取出第一个仍属于当前档案身份的任务；过期任务直接丢弃，不回写旧档案。
func _take_current_background_job() -> Dictionary:
	while not _pending_background_saves.is_empty():
		var path := str(_pending_background_saves.keys()[0])
		var job: Dictionary = _pending_background_saves[path]
		_pending_background_saves.erase(path)
		if is_archive_identity_current(path, int(job.get("generation", -1))):
			return job
	return {}


func _complete_background_save(job: Dictionary, success: bool) -> void:
	var path := str(job["path"])
	var serial := int(job.get("serial", 0))
	_last_background_save_serial = maxi(_last_background_save_serial, serial)
	var identity_current := is_archive_identity_current(path, int(job.get("generation", -1)))
	if not identity_current:
		# 切档后旧任务到达：拒绝回写元数据，也不进入失败重试队列。
		last_save_error = "stale_archive_identity"
		background_save_finished.emit(path, false, serial)
		return
	if success:
		last_save_error = ""
		_failed_background_saves.erase(path)
		if is_instance_valid(MainSet):
			_set_archive_time(archive_number_from_path(path), str(job["data"][ARCHIVE_TIME_KEY]))

	elif not _pending_background_saves.has(path):
		last_save_error = "write_failed"
		_failed_background_saves[path] = job
		push_error("后台存档写入失败，已保留快照，退出/下次同步保存时重试：" + path)
	background_save_finished.emit(path, success, serial)


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


## 当前是否有后台写任务或待写任务；path 为空时查询全部。
func has_pending_background_save(path: String = "") -> bool:
	var target := str(path).strip_edges()
	if target == "":
		return _save_thread != null or not _pending_background_saves.is_empty()
	if _save_thread != null and str(_active_save_job.get("path", "")) == target:
		return true
	return _pending_background_saves.has(target)


func has_failed_background_save(path: String = "") -> bool:
	var target := str(path).strip_edges()
	if target == "":
		return not _failed_background_saves.is_empty()
	return _failed_background_saves.has(target)


func get_last_background_save_serial() -> int:
	return _last_background_save_serial


func flush_pending_saves() -> bool:
	if _save_flush_in_progress:
		return false
	_save_flush_in_progress = true
	_collect_background_save()
	while not _pending_background_saves.is_empty():
		var job := _take_current_background_job()
		if job.is_empty():
			break
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


## 读档入口：返回显式结果，调用方不再用 bool 推断“空档/损坏/成功”。
## status: loaded / missing / empty / unreadable / invalid / invalid_path
func load_game(路径) -> Dictionary:
	var path: String = str(路径)
	var archive_number := archive_number_from_path(path)
	if archive_number <= 0:
		return _archive_load_result(false, "invalid_path", archive_number)
	var read_result: Dictionary = _read_encrypted_dictionary_compatible(path, keys)
	if not bool(read_result.get("ok", false)):
		return _archive_load_result(false, "unreadable", archive_number)
	var archive_data_value: Variant = read_result.get("data", {})
	var archive_data: Dictionary = archive_data_value if archive_data_value is Dictionary else {}
	if archive_data.is_empty():
		var empty_status := "missing" if bool(read_result.get("missing", false)) else "empty"
		return _archive_load_result(false, empty_status, archive_number)
	if not _is_valid_player_archive_data(archive_data):
		push_error("拒绝读取无效的玩家存档数据：%s" % path)
		return _archive_load_result(false, "invalid", archive_number)
	var clean_data: Dictionary = archive_data.duplicate(true)
	clean_data.erase(ARCHIVE_TIME_KEY)
	# 读档前重置内存档，避免同一进程连续读两档时残留上一档的键。
	remove_play_data()
	player_data["已获取装备列表"] = []
	LocalCoop.clear_runtime()
	player_data.erase(LocalCoop.SAVE_KEY)
	_player.merge(clean_data, true)
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
	var result := _archive_load_result(true, "loaded", archive_number)
	if bool(read_result.get("recovered_from_backup", false)):
		result["recovered_from_backup"] = true
	return result


func _archive_load_result(ok: bool, status: String, archive_number: int) -> Dictionary:
	var message := ""
	match status:
		"missing":
			message = "存档不存在，请新建存档。"
		"empty":
			message = "存档内容为空，请新建存档。"
		"unreadable":
			message = "存档读取失败，文件可能已损坏。"
		"invalid":
			message = "存档数据不完整或版本不兼容，无法读取。"
		"invalid_path":
			message = "存档路径无效。"
	return {"ok": ok, "status": status, "archive_number": archive_number, "message": message}


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


## 统一保存入口：业务只提交保存意图，路径与失败结果由持久化边界处理。
## reason 仅用于失败诊断，不参与路径解析或档案内容。
## notify=false 供已自行展示失败文案的命令/面板使用，避免重复提示。
func request_save(reason: String = "", notify: bool = true) -> bool:
	return bool(request_save_result(reason, notify).get("ok", false))


## 同步保存的结构化结果：ok/reason/error/message/path/notify。
## 失败时更新 last_save_outcome 并发出 save_failed；调用方丢弃 bool 也不会静默。
func request_save_result(reason: String = "", notify: bool = true) -> Dictionary:
	last_save_error = ""
	if not Global.is_archive_session_active():
		last_save_error = "no_archive_session"
		return _finish_save_result(reason, false, notify, "")
	var archive_path: String = Global.get_archive_session_path().strip_edges()
	if archive_number_from_path(archive_path) <= 0:
		last_save_error = "invalid_archive_path"
		return _finish_save_result(reason, false, notify, archive_path)
	if archive_path != Global.get_cd_path().strip_edges():
		last_save_error = "stale_archive_identity"
		return _finish_save_result(reason, false, notify, archive_path)
	if save_game(archive_path):
		return _finish_save_result(reason, true, notify, archive_path)
	push_warning("存档保存失败（%s）：%s" % [reason, archive_path])
	return _finish_save_result(reason, false, notify, archive_path)


func _finish_save_result(reason: String, ok: bool, notify: bool, archive_path: String) -> Dictionary:
	var result := {
		"ok": ok,
		"reason": reason,
		"error": last_save_error,
		"message": describe_save_error(),
		"path": archive_path,
		"notify": notify,
	}
	last_save_outcome = result
	if not ok:
		save_failed.emit(reason, last_save_error, str(result["message"]), notify)
	return result


## 最近一次同步保存结果快照；未保存过时为空字典。
func get_last_save_outcome() -> Dictionary:
	return last_save_outcome.duplicate(true)


## 会话身份是否仍然有效：路径与身份纪元必须同时匹配。
func is_archive_identity_current(path: String, generation: int) -> bool:
	if generation < 0 or generation != Global.get_archive_identity_epoch():
		return false
	return Global.get_cd_path().strip_edges() == str(path).strip_edges()


func save_game(path: String) -> bool:
	flush_pending_saves()
	var archive_path: String = str(path)
	var archive_number: int = archive_number_from_path(archive_path)
	if archive_number <= 0:
		last_save_error = "invalid_archive_path"
		return false
	var generation: int = Global.get_archive_identity_epoch()
	if not is_archive_identity_current(archive_path, generation):
		# 调用方持有的路径已不是当前档案：拒绝回写，避免切档后覆盖新档。
		last_save_error = "stale_archive_identity"
		push_warning("拒绝保存过期档案身份：%s" % archive_path)
		return false
	var save_data := _prepare_player_save_data()
	if save_data.is_empty():
		if last_save_error == "":
			last_save_error = "invalid_archive_data"
		return false
	if not is_archive_identity_current(archive_path, generation):
		last_save_error = "stale_archive_identity"
		push_warning("快照生成期间档案身份变化，放弃写入：%s" % archive_path)
		return false
	if not safe_write_archive(archive_path, save_data):
		last_save_error = "write_failed"
		return false
	last_save_error = ""
	_failed_background_saves.erase(archive_path)
	_set_archive_time(archive_number, str(save_data[ARCHIVE_TIME_KEY]))
	if not main_bc():
		push_warning("存档列表元数据写入失败，将从玩家存档时间恢复")
	return true


## 保存失败的可读描述：供 UI 直接展示，不需要解析日志。
func describe_save_error() -> String:
	match last_save_error:
		"":
			return ""
		"invalid_archive_path":
			return "当前没有可写入的档案，请先进入存档。"
		"no_archive_session":
			return "尚未进入档案会话，本次保存已取消。"
		"stale_archive_identity":
			return "档案已切换，本次保存已取消。"
		"invalid_archive_data":
			return "当前数据不完整，已拒绝保存。"
		"write_failed":
			return "写入存档失败，请检查磁盘空间后重试。"
		_:
			if last_save_error.begins_with("normalize_failed:"):
				return "数据补全失败（%s），已拒绝保存。" % last_save_error.trim_prefix("normalize_failed:")
			return "保存失败：%s" % last_save_error


func _prepare_player_save_data() -> Dictionary:
	last_save_error = ""
	# 快照期间禁止打开/切换协作面板，保证共享账本与个体数据同批读取。
	_save_snapshot_in_progress = true
	var snapshot := _prepare_primary_player_save_data()
	if not snapshot.is_empty():
		LocalCoop.save_profile(snapshot)
		LocalCoop.link_bags()
	_save_snapshot_in_progress = false
	return snapshot


## 快照互斥入口：面板打开/切换在快照生成期间必须拒绝。
func is_save_snapshot_in_progress() -> bool:
	return _save_snapshot_in_progress


## 规范化补全步骤：名字 -> 可调用对象。补全必须幂等；任一步抛错或返回
## 显式失败时阻止保存，避免"补全失败但写入成功"。
func _normalization_steps() -> Array:
	return [
		["normalize_soul", PlayerData],
		["ensure_acquired_equipment_data", PlayerData],
		["migrate_consumables_from_dj_to_xhp", PlayerData],
		["ensure_player_passive_skills", PlayerData],
		["_remove_retired_wudu_magic_weapons", PlayerData],
		["ensure_special_dungeon_progress", PlayerData],
		["ensure_main_sword_array", PlayerData],
		["ensure_wanling_catalog_data", PlayerData],
		["ensure_mount_data", PlayerData],
		["ensure_pet_tiger", PlayerData],
		["ensure_pet_dragon", PlayerData],
		["ensure_pet_phoenix", PlayerData],
		["ensure_pet_turtle", PlayerData],
		["ensure_pet_rabbit", PlayerData],
		["ensure_pet_neat", PlayerData],
		["ensure_pet_yin_tiger", PlayerData],
		["ensure_shared_pet_backpack", PlayerData],
		# 等级上限必须最后执行：ensure_pet_* 会补出新宠物，
		# 先钳制会让这些宠物在第一次保存时保留未钳制的等级/经验，破坏幂等。
		["enforce_level_caps", PlayerData],
	]


## 补全是否可用只由返回值之外的**后置条件**判定：补全入口多为 void 或
## "是否新增"语义（`ensure_pet_*` 返回 false 表示已存在），返回值无法表达失败。
## 因此这里只检查方法存在性，正确性交给 `_normalization_postcondition_error()`。
func _run_normalization_step(step_name: String, target: Object) -> bool:
	if target == null or not target.has_method(step_name):
		last_save_error = "normalize_failed:" + step_name
		push_error("保存前补全缺少入口：%s" % step_name)
		return false
	target.call(step_name)
	return true


## 补全后的结构后置条件。任一项不满足即视为补全失败，保存必须被阻止。
func _normalization_postcondition_error() -> String:
	var data: Dictionary = PlayerData.player_data
	for key in ARCHIVE_CONTAINER_KEYS:
		var container = data.get(key, null)
		if not (container is Dictionary) or not ((container as Dictionary).get("页码1", null) is Array):
			return "containers"
	var pets = data.get(PlayerData.PET_LIST_KEY, null)
	if not (pets is Array):
		return "pets"
	var player_level := int(data.get(DataKeys.PLAYER_LEVEL, 1))
	for pet in pets:
		if not (pet is Dictionary):
			return "pets"
		if int((pet as Dictionary).get(DataKeys.LEVEL, 1)) > player_level:
			return "pets"
	var pet_backpack = data.get(PlayerData.PET_BACKPACK_KEY, null)
	if not (pet_backpack is Array):
		return "pet_backpack"
	var mounts = data.get(PlayerData.MOUNT_LIST_KEY, null)
	if not (mounts is Array) or (mounts as Array).is_empty():
		return "mounts"
	var passives = data.get(DataKeys.Skill.PASSIVE, null)
	if not (passives is Dictionary):
		return "passives"
	for skill_name in PlayerData.PLAYER_PASSIVE_SKILL_KEYS:
		if not (passives as Dictionary).has(skill_name):
			return "passives"
	var sword_levels = data.get(PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY, null)
	if not (sword_levels is Dictionary):
		return "main_sword_array"
	var catalog = data.get(PlayerData.WANLING_CATALOG_LEVELS_KEY, null)
	if not (catalog is Dictionary) or (catalog as Dictionary).is_empty():
		return "wanling_catalog"
	if not (data.get("已获取装备列表", null) is Array):
		return "acquired_equipment"
	if int(data.get(DataKeys.PLAYER_LEVEL, -1)) < 1:
		return "player_level"
	return ""


func _prepare_primary_player_save_data() -> Dictionary:
	if not _is_valid_player_archive_data(PlayerData.player_data):
		push_error("拒绝保存无效的玩家存档数据")
		last_save_error = "invalid_archive_data"
		return {}
	for step in _normalization_steps():
		if not _run_normalization_step(str(step[0]), step[1]):
			push_error("保存前补全失败，已阻止写入：%s" % step[0])
			return {}
	var postcondition_error := _normalization_postcondition_error()
	if postcondition_error != "":
		last_save_error = "normalize_failed:" + postcondition_error
		push_error("保存前补全后置条件不满足，已阻止写入：%s" % postcondition_error)
		return {}

	var save_data: Dictionary = PlayerData.player_data.duplicate(true)
	if not _is_valid_player_archive_data(save_data):
		push_error("拒绝保存不完整的玩家存档数据")
		last_save_error = "invalid_archive_data"
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


func is_valid_role_id(value: Variant) -> bool:
	if not (value is int or value is float):
		return false
	var role_id: int = int(value)
	return role_id >= 1 and role_id <= 7


func _is_valid_player_archive_data(data: Dictionary) -> bool:
	if data.is_empty() or not data.has(DataKeys.PLAYER_LEVEL) or not data.has("Myself"):
		return false
	if not is_valid_role_id(data.get("Myself")):
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


## 档案路径的唯一权威解析：user://MyAr_<正整数>.json 之外一律返回 0。
func archive_number_from_path(path: String) -> int:
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


## 当前会话档案号；未进入会话时为 0（消费者必须显式处理）。
func get_cd_number() -> int:
	return Global.get_archive_session_archive_number()


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
	safe_write_archive(Global.get_archive_session_path(), initialized_data)


func remove_main_data(Num: int):
	if Num <= 0:
		return
	if Num <= 6:
		MainSet.set_data["name" + str(Num)] = ""
		MainSet.set_data["time" + str(Num)] = ""
		return
	var other: Dictionary = MainSet.set_data.get("其他存档", {})
	if other is Dictionary and other.has(str(Num)):
		other[str(Num)]["name"] = ""
		other[str(Num)]["time"] = ""

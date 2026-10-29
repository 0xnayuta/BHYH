extends Node

## 档案持久化定向探针：缺失档、空档、损坏档、备份恢复、原子写、
## Myself 范围、云存档收集与 request_save 行为。
## 由 scripts/archive_probe_runner.py 以独立 user:// 目录运行。

const RESULT_PREFIX := "ARCHIVE_PERSISTENCE_PROBE_RESULT="
const TEST_ARCHIVE_PREFIX := "user://MyAr_9"
const PANEL_ARCHIVE_PATH := "user://MyAr_1.json"
const OLD_ARCHIVE_TIME := "2000-01-01 00:00:00"

var failures: Array[String] = []
var checks: Dictionary = {}


func _ready() -> void:
	print("USER_DIR=", OS.get_data_dir())
	await _run()
	var ok := failures.is_empty()
	print(RESULT_PREFIX, JSON.stringify({"ok": ok, "failures": failures, "checks": checks}))
	get_tree().quit(0 if ok else 1)


func _check(name: String, condition: bool, detail: String = "") -> void:
	checks[name] = {"ok": condition, "detail": detail}
	if not condition:
		failures.append("%s: %s" % [name, detail])


func _reset_profile(role_id: int = 1, level: int = 1) -> void:
	PlayerData.player_data.clear()
	PlayerData.player_data.merge(PlayerData.initialized_data.duplicate(true))
	PlayerData.player_data["Myself"] = role_id
	PlayerData.player_data["玩家等级"] = level
	Global.set_cd_path("")


## 建立会话并把指定路径登记为当前档案；等价于业务侧“点开存档”之后的状态。
func _open_session(path: String) -> void:
	Global.set_cd_path(path)
	Global.bind_archive_session()


func _archive_data(role_id: int, level: int) -> Dictionary:
	var data: Dictionary = PlayerData.initialized_data.duplicate(true)
	data["Myself"] = role_id
	data["玩家等级"] = level
	return data


func _write_plain(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
		file.close()


func _run() -> void:
	_test_missing_and_empty()
	_test_corrupt_archive()
	_test_backup_recovery()
	_test_role_range()
	_test_cloud_validation()
	_test_request_save()
	_test_archive_session()
	await _test_settlement_ownership()
	await _test_panel_saves()


func _test_missing_and_empty() -> void:
	var missing_path := TEST_ARCHIVE_PREFIX + "001.json"
	_reset_profile(1, 3)
	var missing_result: Dictionary = MemoryClass.load_game(missing_path)
	_check("missing_archive_reported", missing_result.get("status") == "missing", "status=%s" % missing_result.get("status"))
	_check("missing_archive_not_loaded", not bool(missing_result.get("ok", true)))
	_check("missing_archive_not_created", not FileAccess.file_exists(missing_path))

	var empty_path := TEST_ARCHIVE_PREFIX + "002.json"
	_write_plain(empty_path, "")
	_reset_profile(1, 4)
	var empty_result: Dictionary = MemoryClass.load_game(empty_path)
	_check("empty_archive_reported", empty_result.get("status") == "empty", "status=%s" % empty_result.get("status"))
	_check("empty_archive_not_loaded", not bool(empty_result.get("ok", true)))


func _test_corrupt_archive() -> void:
	var path := TEST_ARCHIVE_PREFIX + "003.json"
	_write_plain(path, "not-a-valid-archive")
	_reset_profile(1, 1)
	var result: Dictionary = MemoryClass.load_game(path)
	_check("corrupt_archive_rejected", result.get("status") == "unreadable", "status=%s" % result.get("status"))
	_check("corrupt_archive_not_loaded", not bool(result.get("ok", true)))


func _test_backup_recovery() -> void:
	var path := TEST_ARCHIVE_PREFIX + "004.json"
	var first := _archive_data(1, 10)
	var second := _archive_data(1, 11)
	var wrote_first := MemoryClass.safe_write_archive(path, first)
	var wrote_second := MemoryClass.safe_write_archive(path, second)
	_check("atomic_write_ok", wrote_first and wrote_second and FileAccess.file_exists(path))
	_check("atomic_temp_removed", not FileAccess.file_exists(path + ".tmp"))
	_check("atomic_backup_created", FileAccess.file_exists(path + ".bak"))

	_write_plain(path, "corrupted-primary")
	var result: Dictionary = MemoryClass._read_encrypted_dictionary_compatible(path, MemoryClass.keys)
	var recovered := bool(result.get("recovered_from_backup", false))
	var recovered_level := int((result.get("data", {}) as Dictionary).get("玩家等级", 0))
	_check("backup_recovered", bool(result.get("ok", false)) and recovered, "ok/recovered=%s/%s" % [result.get("ok"), recovered])
	_check("backup_content_previous", recovered_level == 10, "level=%s" % recovered_level)


func _test_role_range() -> void:
	_check("local_role_1_valid", MemoryClass._is_valid_player_archive_data(_archive_data(1, 1)))
	_check("local_role_7_valid", MemoryClass._is_valid_player_archive_data(_archive_data(7, 1)))
	_check("local_role_0_invalid", not MemoryClass._is_valid_player_archive_data(_archive_data(0, 1)))
	_check("local_role_8_invalid", not MemoryClass._is_valid_player_archive_data(_archive_data(8, 1)))

	var invalid_path := TEST_ARCHIVE_PREFIX + "005.json"
	MemoryClass.safe_write_archive(invalid_path, _archive_data(8, 1))
	_reset_profile(1, 1)
	var invalid_loaded: Dictionary = MemoryClass.load_game(invalid_path)
	_check("invalid_role_load_rejected", invalid_loaded.get("status") == "invalid", "status=%s" % invalid_loaded.get("status"))

	var valid_path := TEST_ARCHIVE_PREFIX + "006.json"
	MemoryClass.safe_write_archive(valid_path, _archive_data(7, 5))
	_reset_profile(1, 1)
	var valid_loaded: Dictionary = MemoryClass.load_game(valid_path)
	_check("role_7_load_accepted", bool(valid_loaded.get("ok", false)), "status=%s" % valid_loaded.get("status"))


func _test_cloud_validation() -> void:
	_check("cloud_role_7_valid", MemoryClass.is_valid_role_id(7))
	_check("cloud_role_0_invalid", not MemoryClass.is_valid_role_id(0))
	_check("cloud_role_8_invalid", not MemoryClass.is_valid_role_id(8))
	_check("cloud_role_text_invalid", not MemoryClass.is_valid_role_id("7"))


func _test_request_save() -> void:
	_reset_profile(1, 1)
	Global.set_cd_path("")
	_check("request_save_without_session", not MemoryClass.request_save("probe_empty"))

	_reset_profile(7, 12)
	_open_session(TEST_ARCHIVE_PREFIX + "009.json")
	var saved := MemoryClass.request_save("probe_save")
	_check("request_save_writes", saved and FileAccess.file_exists(Global.get_cd_path()), "saved=%s" % saved)
	_check("request_save_no_temp", not FileAccess.file_exists(Global.get_cd_path() + ".tmp"))
	_check("request_save_level", MemoryClass.get_archive_level(Global.get_cd_path()) == 12)

	var saved_path := Global.get_cd_path()
	_reset_profile(1, 1)
	var reloaded: Dictionary = MemoryClass.load_game(saved_path)
	_check(
		"request_save_reloads",
		bool(reloaded.get("ok", false)) and int(PlayerData.player_data.get("Myself", 0)) == 7 and int(PlayerData.player_data.get("玩家等级", 0)) == 12,
		"status=%s role=%s level=%s" % [reloaded.get("status"), PlayerData.player_data.get("Myself"), PlayerData.player_data.get("玩家等级")]
	)

	_reset_profile(8, 1)
	_open_session(TEST_ARCHIVE_PREFIX + "010.json")
	var rejected := MemoryClass.request_save("probe_invalid")
	_check("request_save_rejects_invalid_role", not rejected, "saved=%s" % rejected)
	_check("request_save_invalid_not_written", not FileAccess.file_exists(Global.get_cd_path()))

	_reset_profile(1, 9)
	_open_session(TEST_ARCHIVE_PREFIX + "011.json")
	var seeded := MemoryClass.request_save("probe_seed")
	var seeded_level := MemoryClass.get_archive_level(Global.get_cd_path())
	var seeded_path := Global.get_cd_path()
	PlayerData.player_data.clear()
	var empty_blocked := MemoryClass.request_save("probe_empty_profile")
	_reset_profile(1, 1)
	var after_level := MemoryClass.get_archive_level(seeded_path)
	_check(
		"empty_profile_not_overwrite",
		seeded and not empty_blocked and seeded_level == 9 and after_level == 9,
		"seed=%s blocked=%s before=%s after=%s" % [seeded, empty_blocked, seeded_level, after_level]
	)


func _test_settlement_ownership() -> void:
	_reset_profile(1, 1)
	_open_session(TEST_ARCHIVE_PREFIX + "041.json")
	Global.current_level = "花果山"
	Global.level_begin_time = "2026-10-29 00:00:00"
	Global.last_level_path = "res://Scene/level/level_1.tscn"
	RoleProp.roleprop.Hp = 100
	RoleProp.roleprop.SHp = 100
	RoleProp.roleprop.Mp = 100
	RoleProp.roleprop.SMp = 100
	PlayerData.player_data["Map_num"] = 1
	PlayerData.player_data["zyforever"] = false
	PlayerData.player_data["ieho"] = false

	var victory_saves: Array = []
	var victory_scenes: Array = []
	var victory: Node = load("res://Scene/level/victory.tscn").instantiate()
	victory.save_request_override = func(reason: String) -> bool:
		victory_saves.append(reason)
		return true
	victory.scene_change_override = func(path: String) -> bool:
		victory_scenes.append(path)
		return true
	add_child(victory)
	await get_tree().process_frame
	_check("victory_ready_saves_once", victory_saves == ["level_victory"], str(victory_saves))
	victory._on_return_map_pressed()
	victory._on_return_map_pressed()
	_check("victory_return_scene_once", victory_scenes.size() == 1, str(victory_scenes))
	_check("victory_return_no_extra_save", victory_saves.size() == 1, str(victory_saves))
	victory.queue_free()
	await get_tree().process_frame

	var rechallenge_saves: Array = []
	var rechallenge_scenes: Array = []
	var rechallenge: Node = load("res://Scene/level/victory.tscn").instantiate()
	rechallenge.save_request_override = func(reason: String) -> bool:
		rechallenge_saves.append(reason)
		return true
	rechallenge.scene_change_override = func(path: String) -> bool:
		rechallenge_scenes.append(path)
		return true
	add_child(rechallenge)
	await get_tree().process_frame
	rechallenge._on_rechallenge_pressed()
	rechallenge._on_rechallenge_pressed()
	_check("victory_rechallenge_scene_once", rechallenge_scenes.size() == 1, str(rechallenge_scenes))
	_check("victory_rechallenge_no_extra_save", rechallenge_saves.size() == 1, str(rechallenge_saves))
	rechallenge.queue_free()
	await get_tree().process_frame

	var retry_attempts: Array = []
	var retry_scenes: Array = []
	var retry_victory: Node = load("res://Scene/level/victory.tscn").instantiate()
	retry_victory.save_request_override = func(reason: String) -> bool:
		retry_attempts.append(reason)
		return retry_attempts.size() > 1
	retry_victory.scene_change_override = func(path: String) -> bool:
		retry_scenes.append(path)
		return true
	add_child(retry_victory)
	await get_tree().process_frame
	retry_victory._on_return_map_pressed()
	_check("victory_retry_save_after_failure", retry_attempts.size() == 2 and retry_scenes.size() == 1, "%s/%s" % [retry_attempts, retry_scenes])
	retry_victory.queue_free()
	await get_tree().process_frame

	var items_before_batch: Dictionary = PlayerData.player_data[DataKeys.ITEM_LIST].duplicate(true)
	var invalid_batch := PlayerData.add_dj_batch([{"name": "__missing_reward__", "number": 1}])
	_check("defeat_batch_rejects_invalid_atomically", not invalid_batch and PlayerData.player_data[DataKeys.ITEM_LIST] == items_before_batch)

	PlayerData.player_data[DataKeys.DEFEAT_REWARD_CLAIMED] = false
	var defeat_saves: Array = []
	var defeat_scenes: Array = []
	var defeat: Node = load("res://Scene/level/defeat.tscn").instantiate()
	defeat.save_request_override = func(reason: String) -> bool:
		defeat_saves.append(reason)
		return true
	defeat.scene_change_override = func(path: String) -> bool:
		defeat_scenes.append(path)
		return true
	add_child(defeat)
	await get_tree().process_frame
	var bsd_before := _item_count("bsd_5")
	defeat._on_lqjl_pressed()
	defeat._on_lqjl_pressed()
	_check("defeat_items_once", defeat_saves == ["level_defeat_reward"], str(defeat_saves))
	_check("defeat_items_granted", _item_count("bsd_5") == bsd_before + 1 and _item_count("qhs_1") == 8, "bsd=%d qhs1=%d" % [_item_count("bsd_5"), _item_count("qhs_1")])
	_check("defeat_items_claim_persisted", bool(PlayerData.player_data.get(DataKeys.DEFEAT_REWARD_CLAIMED, false)))
	defeat._on_return_map_pressed()
	defeat._on_return_map_pressed()
	_check("defeat_return_scene_once", defeat_scenes.size() == 1, str(defeat_scenes))
	_check("defeat_return_no_extra_save", defeat_saves.size() == 1, str(defeat_saves))
	defeat.queue_free()
	await get_tree().process_frame

	var reentry_saves: Array = []
	var reentry: Node = load("res://Scene/level/defeat.tscn").instantiate()
	reentry.save_request_override = func(reason: String) -> bool:
		reentry_saves.append(reason)
		return true
	add_child(reentry)
	await get_tree().process_frame
	var reentry_qhs := _item_count("qhs_1")
	reentry._on_lqjl_pressed()
	_check("defeat_reentry_no_regrant", _item_count("qhs_1") == reentry_qhs and reentry_saves.is_empty(), "qhs=%d saves=%s" % [_item_count("qhs_1"), str(reentry_saves)])
	reentry.queue_free()
	await get_tree().process_frame

	PlayerData.player_data[DataKeys.DEFEAT_REWARD_CLAIMED] = false
	var failed_saves: Array = []
	var failed: Node = load("res://Scene/level/defeat.tscn").instantiate()
	failed.save_request_override = func(reason: String) -> bool:
		failed_saves.append(reason)
		return false
	add_child(failed)
	await get_tree().process_frame
	var qhs_before := _item_count("qhs_1")
	failed._on_lqjl_pressed()
	_check("defeat_items_save_failure_rolls_back", _item_count("qhs_1") == qhs_before and not bool(PlayerData.player_data.get(DataKeys.DEFEAT_REWARD_CLAIMED, false)), "qhs=%d" % _item_count("qhs_1"))
	_check("defeat_items_failure_attempted", failed_saves == ["level_defeat_reward"], str(failed_saves))
	failed.queue_free()
	await get_tree().process_frame

	var equipment_saves: Array = []
	var equipment_failed: Node = load("res://Scene/level/defeat.tscn").instantiate()
	equipment_failed.save_request_override = func(reason: String) -> bool:
		equipment_saves.append(reason)
		return false
	add_child(equipment_failed)
	await get_tree().process_frame
	equipment_failed._on_js_pressed()
	_check("defeat_equipment_save_failure_rolls_back", not PlayerData.has_acquired_equipment("xczg"), str(PlayerData.player_data.get(DataKeys.ACQUIRED_EQUIPMENT_LIST, [])))
	_check("defeat_equipment_failure_attempted", equipment_saves == ["level_defeat_reward"], str(equipment_saves))
	equipment_failed.queue_free()
	await get_tree().process_frame


func _item_count(item_name: String) -> int:
	var total := 0
	for page in PlayerData.player_data[DataKeys.ITEM_LIST].values():
		if not page is Array:
			continue
		for item in page:
			if item is Dictionary and str((item as Dictionary).get(DataKeys.NAME, "")) == item_name:
				total += int((item as Dictionary).get(DataKeys.COUNT, 0))
	return total


## 16-3：档案会话上下文。会话是保存与关卡入口的唯一权威表示。
func _test_archive_session() -> void:
	_reset_profile(1, 4)
	_check("session_initially_inactive", not Global.is_archive_session_active())
	_check("session_bind_requires_path", not Global.bind_archive_session())
	_check("session_active_blocks_nothing_when_inactive", Global.get_archive_session_path() == "")

	Global.set_cd_path(TEST_ARCHIVE_PREFIX + "031.json")
	var bound := Global.bind_archive_session()
	_check("session_bind_ok", bound)
	_check("session_active_after_bind", Global.is_archive_session_active())
	_check("session_archive_number", Global.get_archive_session_archive_number() == 9031, "%d" % Global.get_archive_session_archive_number())
	_check("session_role_id", Global.get_archive_session_role_id() == 1, "%d" % Global.get_archive_session_role_id())
	_check("session_path_matches_cd_path", Global.get_archive_session_path() == Global.get_cd_path())
	var generation := Global.get_archive_session_generation()
	_check("session_rebind_is_idempotent", Global.bind_archive_session() and Global.get_archive_session_generation() == generation)

	# 会话未建立时保存与后台保存都必须拒绝。
	Global.set_cd_path("")
	_check("session_ended_by_path_switch", not Global.is_archive_session_active())
	var no_session_save := MemoryClass.request_save("probe_no_session")
	_check("session_absent_blocks_save", not no_session_save)
	_check("session_absent_save_reason", MemoryClass.last_save_error == "no_archive_session", MemoryClass.last_save_error)
	var no_session_background := MemoryClass.request_background_save()
	_check("session_absent_blocks_background_save", not no_session_background)

	# 会话结束必须使 save/后台保存同时失效，且不残留上一档的编号。
	_open_session(TEST_ARCHIVE_PREFIX + "032.json")
	var session_generation := Global.get_archive_session_generation()
	Global.end_archive_session()
	_check("session_end_advances_generation", Global.get_archive_session_generation() > session_generation)
	_check("session_end_clears_number", Global.get_archive_session_archive_number() == 0)
	Global.end_archive_session()
	_check("session_end_idempotent", not Global.is_archive_session_active())

	# 角色变化：同一路径下切换 My 字号必须重建会话并保留当前档案编号。
	_open_session(TEST_ARCHIVE_PREFIX + "033.json")
	var role_change_generation := Global.get_archive_session_generation()
	PlayerData.player_data["Myself"] = 3
	_check("session_role_change_rebinds", Global.bind_archive_session())
	_check("session_role_change_generation", Global.get_archive_session_generation() > role_change_generation)
	_check("session_role_change_role_id", Global.get_archive_session_role_id() == 3, "%d" % Global.get_archive_session_role_id())
	_check(
		"session_role_change_number_kept",
		Global.get_archive_session_archive_number() == 9033,
		"%d" % Global.get_archive_session_archive_number()
	)
	Global.end_archive_session()

	# 冷启动 -> 读档 -> 建立会话 -> 退出会话 -> 再进同一档案：内容保持一致，代次递增。
	var reentry_path := TEST_ARCHIVE_PREFIX + "034.json"
	_reset_profile(1, 6)
	MemoryClass.safe_write_archive(reentry_path, _archive_data(1, 6))
	_reset_profile(1, 1)
	Global.set_cd_path(reentry_path)
	var first_load: Dictionary = MemoryClass.load_game(reentry_path)
	var first_bound := Global.bind_archive_session()
	var first_generation := Global.get_archive_session_generation()
	_check("session_reentry_first_load", bool(first_load.get("ok", false)) and first_bound)
	Global.end_archive_session()
	Global.set_cd_path(reentry_path)
	var second_load: Dictionary = MemoryClass.load_game(reentry_path)
	var second_bound := Global.bind_archive_session()
	_check("session_reentry_second_load", bool(second_load.get("ok", false)) and second_bound)
	_check(
		"session_reentry_generation_advances",
		Global.get_archive_session_generation() > first_generation,
		"%d -> %d" % [first_generation, Global.get_archive_session_generation()]
	)
	_check(
		"session_reentry_level_kept",
		int(PlayerData.player_data.get("玩家等级", 0)) == 6,
		"level=%s" % PlayerData.player_data.get("玩家等级")
	)

	# 关卡入口守卫：无会话时拒绝进入关卡，且不改变目标场景。
	Global.set_cd_path("")
	Global.end_archive_session()
	var blocked_level := Global.change_scene("res://Scene/level/level_1.tscn")
	_check("session_level_entry_blocked", not blocked_level)
	_check("session_level_entry_no_target", Global.target_scene != "res://Scene/level/level_1.tscn")
	_open_session(reentry_path)
	_check("session_level_entry_allowed", Global._is_valid_scene_change_target("res://Scene/level/level_1.tscn"))
	Global.end_archive_session()
	_reset_profile(1, 1)


## 直接调用背包/技能/炼体面板的真实保存处理器，验证界面路径确实经 request_save 落盘。
func _test_panel_saves() -> void:
	_reset_profile(1, 5)
	_open_session(PANEL_ARCHIVE_PATH)
	PlayerData.player_data["翅膀显示"] = true
	PlayerData.player_data["头衔显示"] = true
	PlayerData.player_data[DataKeys.SKILL_LEARNED][DataKeys.Skill.KEYMAP]["Y"] = "old"
	var seeded := MemoryClass.request_save("probe_panel_seed")
	_check("panel_seed_saved", seeded)

	var bag: Node = (load("res://Scene/back_pack/back_pack.tscn") as PackedScene).instantiate()
	bag.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(bag)
	await get_tree().process_frame
	bag.call("_on_wings_show_pressed")
	bag.call("_on_head_show_pressed")
	var bag_data := MemoryClass.peek_archive_data(PANEL_ARCHIVE_PATH)
	_check(
		"panel_backpack_wings_saved",
		bag_data.get("翅膀显示") == false,
		"wings=%s" % bag_data.get("翅膀显示")
	)
	_check(
		"panel_backpack_head_saved",
		bag_data.get("头衔显示") == false,
		"head=%s" % bag_data.get("头衔显示")
	)
	bag.queue_free()
	await get_tree().process_frame

	var keys: Node = (load("res://Scene/skill/skill_key_set.tscn") as PackedScene).instantiate()
	keys.process_mode = Node.PROCESS_MODE_DISABLED
	keys.set("need_name", "slz")
	add_child(keys)
	keys.call("_on_y_pressed")
	await get_tree().process_frame
	var key_data := MemoryClass.peek_archive_data(PANEL_ARCHIVE_PATH)
	var learned: Dictionary = key_data.get(DataKeys.SKILL_LEARNED, {})
	var keymap: Dictionary = learned.get(DataKeys.Skill.KEYMAP, {})
	var bound_key := str(keymap.get("Y", ""))
	_check("panel_skill_key_saved", bound_key == "slz", "Y=%s" % bound_key)

	_mark_archive_time_old(PANEL_ARCHIVE_PATH)
	var strength: Node = (load("res://Scene/ldl/strength.tscn") as PackedScene).instantiate()
	strength.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(strength)
	await get_tree().process_frame
	strength.call("remove_infomation")
	await get_tree().process_frame
	_check(
		"panel_strength_saved",
		_archive_time(PANEL_ARCHIVE_PATH) != OLD_ARCHIVE_TIME,
		"time=%s" % _archive_time(PANEL_ARCHIVE_PATH)
	)
	strength.queue_free()
	await get_tree().process_frame

	_mark_archive_time_old(PANEL_ARCHIVE_PATH)
	var ldl: Node = (load("res://Scene/ldl/ldl.tscn") as PackedScene).instantiate()
	ldl.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(ldl)
	await get_tree().process_frame
	_check(
		"panel_ldl_saved",
		_archive_time(PANEL_ARCHIVE_PATH) != OLD_ARCHIVE_TIME,
		"time=%s" % _archive_time(PANEL_ARCHIVE_PATH)
	)
	ldl.queue_free()
	await get_tree().process_frame

	_mark_archive_time_old(PANEL_ARCHIVE_PATH)
	var synthesis: Node = (load("res://Scene/ldl/synthesis.tscn") as PackedScene).instantiate()
	synthesis.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(synthesis)
	await get_tree().process_frame
	synthesis.call("remove_infomation")
	await get_tree().process_frame
	_check(
		"panel_synthesis_saved",
		_archive_time(PANEL_ARCHIVE_PATH) != OLD_ARCHIVE_TIME,
		"time=%s" % _archive_time(PANEL_ARCHIVE_PATH)
	)
	synthesis.queue_free()
	await get_tree().process_frame

	await _check_main_menu_saves()
	await _check_save_identity_and_normalization()
	await _check_reward_and_menu_saves()


## 主菜单批次：直接调用地图页与各功能页的真实保存处理器，回读加密档案确认已落盘。
func _check_main_menu_saves() -> void:
	_reset_profile(1, 5)
	_open_session(PANEL_ARCHIVE_PATH)
	MemoryClass.request_save("probe_main_seed")
	var popup_layer := CanvasLayer.new()
	add_child(popup_layer)
	Global.windows = popup_layer
	var global_popup := Global.get_ui_popup_layer()
	await get_tree().process_frame
	var cases := [
		["map_0", "res://Scene/main_menu/map_0.tscn", "_save_if_possible"],
		["map_1", "res://Scene/main_menu/map_1.tscn", "_on_bc_game_pressed"],
		["map_2", "res://Scene/main_menu/map_2.tscn", "_on_memory_game_pressed"],
		["map_3", "res://Scene/main_menu/map_3.tscn", "_on_memory_game_pressed"],
		["map_3_special", "res://Scene/main_menu/map_3.tscn", "_sync_special_button_layer"],
		["map_4", "res://Scene/main_menu/map_4.tscn", "_on_memory_class_pressed"],
		["map_5", "res://Scene/main_menu/map_5.tscn", "_on_memory_class_pressed"],
		["map_6", "res://Scene/main_menu/map_6.tscn", "_on_memory_class_pressed"],
		["map_7", "res://Scene/main_menu/map_7.tscn", "_on_memory_class_pressed"],
		["map_8", "res://Scene/main_menu/map_8.tscn", "_on_memory_class_pressed"],
		["map_8_1", "res://Scene/main_menu/map_8_1.tscn", "_on_memory_class_pressed"],
		["map_9", "res://Scene/main_menu/map_9.tscn", "_on_memory_class_pressed"],
		["map_9_1", "res://Scene/main_menu/map_9_1.tscn", "_on_memory_class_pressed"],
		["tower_data", "res://Scene/main_menu/zhen_yao_tower.tscn", "_save_tower_data"],
		["sword", "res://Scene/main_menu/zhu_xian_sword_page.tscn", "_save_if_possible"],
		["wanling", "res://Scene/main_menu/wan_ling_catalog_page.tscn", "_save_if_possible"],
		["announcement", "res://Scene/main_menu/game_announcement.tscn", "_save_secret_progress"],
		["training", "res://Scene/main_menu/body_training_detail.tscn", "_save_if_possible"],
	]
	for entry in cases:
		var label := str(entry[0])
		var scene_path := str(entry[1])
		var handler := str(entry[2])
		var page: Node = (load(scene_path) as PackedScene).instantiate()
		page.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(page)
		await get_tree().process_frame
		_mark_archive_time_old(PANEL_ARCHIVE_PATH)
		page.call(handler)
		await get_tree().process_frame
		_check(
			"panel_main_%s_saved" % label,
			_archive_time(PANEL_ARCHIVE_PATH) != OLD_ARCHIVE_TIME,
			"time=%s" % _archive_time(PANEL_ARCHIVE_PATH)
		)
		page.queue_free()
		await get_tree().process_frame
	global_popup.queue_free()
	popup_layer.queue_free()
	Global.windows = null
	await get_tree().process_frame
	await get_tree().process_frame


## 16-2B：保存身份纪元、切档前 flush 与过期回写拒绝。
## 16-2D：规范化补全幂等，后置条件不满足时阻止写入。
func _check_save_identity_and_normalization() -> void:
	var path_a := TEST_ARCHIVE_PREFIX + "021.json"
	var path_b := TEST_ARCHIVE_PREFIX + "022.json"
	_reset_profile(1, 7)
	_open_session(path_a)
	_check("identity_save_a", MemoryClass.request_save("probe_identity_a"))
	var epoch_a := Global.get_archive_identity_epoch()
	Global.set_cd_path(path_b)
	Global.bind_archive_session()
	var epoch_b := Global.get_archive_identity_epoch()
	_check("identity_epoch_advances", epoch_b > epoch_a, "%d -> %d" % [epoch_a, epoch_b])
	_check("identity_current_for_b", MemoryClass.is_archive_identity_current(path_b, epoch_b))
	_check("identity_stale_for_a", not MemoryClass.is_archive_identity_current(path_a, epoch_b))
	var stale_written := MemoryClass.save_game(path_a)
	_check("identity_stale_write_rejected", not stale_written, "written=%s" % stale_written)
	_check("identity_error_reason", MemoryClass.last_save_error == "stale_archive_identity", MemoryClass.last_save_error)
	_check("identity_error_readable", MemoryClass.describe_save_error() != "")

	# 切档前 flush：旧档案的待写任务在身份切换前落盘。
	_reset_profile(1, 8)
	_open_session(path_a)
	_check("identity_flush_queue_enqueued", MemoryClass.request_background_save())
	Global.set_cd_path(path_b)
	_check(
		"identity_switch_flushed_old_archive",
		MemoryClass.get_archive_level(path_a) == 8,
		"level=%s" % MemoryClass.get_archive_level(path_a)
	)

	# 16-2D 幂等：连续两次准备快照，除时间外内容一致。
	_reset_profile(1, 5)
	_open_session(path_b)
	var first := MemoryClass._prepare_player_save_data()
	var second := MemoryClass._prepare_player_save_data()
	first.erase(MemoryClass.ARCHIVE_TIME_KEY)
	second.erase(MemoryClass.ARCHIVE_TIME_KEY)
	var diff_keys := []
	for key in first.keys():
		if JSON.stringify(first[key]) != JSON.stringify(second.get(key)):
			diff_keys.append(str(key))
	for key in second.keys():
		if not first.has(key):
			diff_keys.append(str(key))
	var pet_diff := ""
	if not diff_keys.is_empty():
		var pets_a: Array = first.get("宠物列表", [])
		var pets_b: Array = second.get("宠物列表", [])
		pet_diff += "size=%d/%d " % [pets_a.size(), pets_b.size()]
		for index in mini(pets_a.size(), pets_b.size()):
			var pet_a: Dictionary = pets_a[index]
			var pet_b: Dictionary = pets_b[index]
			for key in pet_a.keys():
				if JSON.stringify(pet_a[key]) != JSON.stringify(pet_b.get(key)):
					pet_diff += "[%d].%s(%s/%s) " % [index, key, str(pet_a[key]), str(pet_b.get(key))]
			for key in pet_b.keys():
				if not pet_a.has(key):
					pet_diff += "[%d].+%s " % [index, key]
	_check("normalize_idempotent", diff_keys.is_empty(), "diff=%s %s" % [str(diff_keys), pet_diff])
	_check("normalize_ok_no_error", MemoryClass.last_save_error == "", MemoryClass.last_save_error)

	# 16-2D 后置条件：宠物列表混入非字典元素时补全无法修复，保存必须被阻止。
	_reset_profile(1, 5)
	_open_session(path_b)
	_check("normalize_baseline_saved", MemoryClass.request_save("probe_normalize_baseline"))
	PlayerData.player_data[PlayerData.PET_LIST_KEY].append("garbage")
	var blocked := MemoryClass.request_save("probe_normalize_fail")
	_check("normalize_failure_blocks_save", not blocked)
	_check(
		"normalize_failure_reason",
		MemoryClass.last_save_error.begins_with("normalize_failed:"),
		MemoryClass.last_save_error
	)
	_check("normalize_failure_not_written", MemoryClass.get_archive_level(path_b) == 5)
	_reset_profile(1, 5)


## 关卡与收尾批次：验证结算界面与其余业务保存处理器确实经 request_save 落盘。
func _check_reward_and_menu_saves() -> void:
	_reset_profile(1, 5)
	_open_session(PANEL_ARCHIVE_PATH)
	MemoryClass.request_save("probe_reward_seed")
	_set_archive_time_value(PANEL_ARCHIVE_PATH, "2000-01-01 00:00:00")
	var reward: Node = (load("res://Scene/other_scene/reward_interface.tscn") as PackedScene).instantiate()
	reward.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(reward)
	await get_tree().process_frame
	reward.set("reward_items", [{"Name": "qhs_1", "Value": 1, "Prop": {}, "WX": [], "strength_value": 0}])
	reward.call("_process", 0.016)
	await get_tree().process_frame
	_check(
		"batch_reward_interface_saved",
		_archive_time(PANEL_ARCHIVE_PATH) != OLD_ARCHIVE_TIME,
		"time=%s" % _archive_time(PANEL_ARCHIVE_PATH)
	)
	_check(
		"batch_reward_item_granted_once",
		int(PlayerData.get_item_data("qhs_1")) == 1,
		"count=%s" % PlayerData.get_item_data("qhs_1")
	)
	reward.queue_free()
	await get_tree().process_frame

	_set_archive_time_value(PANEL_ARCHIVE_PATH, "2000-01-01 00:00:00")
	RoleProp.baseroleprop.Level = 1
	RoleProp.baseroleprop.exp = 0
	RoleProp.cure_level()
	await get_tree().process_frame
	_check(
		"batch_level_up_saved",
		_archive_time(PANEL_ARCHIVE_PATH) != OLD_ARCHIVE_TIME,
		"time=%s" % _archive_time(PANEL_ARCHIVE_PATH)
	)
	_check(
		"batch_level_up_persisted_level",
		int(MemoryClass.peek_archive_data(PANEL_ARCHIVE_PATH).get(DataKeys.PLAYER_LEVEL, 0)) == 2,
		"level=%s" % MemoryClass.peek_archive_data(PANEL_ARCHIVE_PATH).get(DataKeys.PLAYER_LEVEL)
	)


func _set_archive_time_value(path: String, value: String) -> void:
	var data := MemoryClass.peek_archive_data(path)
	data[MemoryClass.ARCHIVE_TIME_KEY] = value
	MemoryClass.safe_write_archive(path, data)


func _mark_archive_time_old(path: String) -> void:
	var data := MemoryClass.peek_archive_data(path)
	data[MemoryClass.ARCHIVE_TIME_KEY] = OLD_ARCHIVE_TIME
	MemoryClass.safe_write_archive(path, data)


func _archive_time(path: String) -> String:
	return str(MemoryClass.peek_archive_data(path).get(MemoryClass.ARCHIVE_TIME_KEY, ""))

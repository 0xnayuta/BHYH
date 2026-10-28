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
	Global.cd_path = ""


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
	await _test_panel_saves()


func _test_missing_and_empty() -> void:
	var missing_path := TEST_ARCHIVE_PREFIX + "001.json"
	_reset_profile(1, 3)
	var missing_ok := MemoryClass.load_game(missing_path)
	_check("missing_archive_loads", missing_ok, "load_game=%s" % missing_ok)
	_check("missing_archive_not_created", not FileAccess.file_exists(missing_path))

	var empty_path := TEST_ARCHIVE_PREFIX + "002.json"
	_write_plain(empty_path, "")
	_reset_profile(1, 4)
	var empty_ok := MemoryClass.load_game(empty_path)
	_check("empty_archive_loads", empty_ok, "load_game=%s" % empty_ok)


func _test_corrupt_archive() -> void:
	var path := TEST_ARCHIVE_PREFIX + "003.json"
	_write_plain(path, "not-a-valid-archive")
	_reset_profile(1, 1)
	var ok := MemoryClass.load_game(path)
	_check("corrupt_archive_rejected", not ok, "load_game=%s" % ok)


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
	var invalid_loaded := MemoryClass.load_game(invalid_path)
	_check("invalid_role_load_rejected", not invalid_loaded, "load_game=%s" % invalid_loaded)

	var valid_path := TEST_ARCHIVE_PREFIX + "006.json"
	MemoryClass.safe_write_archive(valid_path, _archive_data(7, 5))
	_reset_profile(1, 1)
	var valid_loaded := MemoryClass.load_game(valid_path)
	_check("role_7_load_accepted", valid_loaded, "load_game=%s" % valid_loaded)


func _test_cloud_validation() -> void:
	_check("cloud_role_7_valid", MemoryClass.is_valid_role_id(7))
	_check("cloud_role_0_invalid", not MemoryClass.is_valid_role_id(0))
	_check("cloud_role_8_invalid", not MemoryClass.is_valid_role_id(8))
	_check("cloud_role_text_invalid", not MemoryClass.is_valid_role_id("7"))


func _test_request_save() -> void:
	_reset_profile(1, 1)
	Global.cd_path = ""
	_check("request_save_without_session", not MemoryClass.request_save("probe_empty"))

	_reset_profile(7, 12)
	Global.cd_path = TEST_ARCHIVE_PREFIX + "009.json"
	var saved := MemoryClass.request_save("probe_save")
	_check("request_save_writes", saved and FileAccess.file_exists(Global.cd_path), "saved=%s" % saved)
	_check("request_save_no_temp", not FileAccess.file_exists(Global.cd_path + ".tmp"))
	_check("request_save_level", MemoryClass.get_archive_level(Global.cd_path) == 12)

	var saved_path := Global.cd_path
	_reset_profile(1, 1)
	var reloaded := MemoryClass.load_game(saved_path)
	_check(
		"request_save_reloads",
		reloaded and int(PlayerData.player_data.get("Myself", 0)) == 7 and int(PlayerData.player_data.get("玩家等级", 0)) == 12,
		"loaded=%s role=%s level=%s" % [reloaded, PlayerData.player_data.get("Myself"), PlayerData.player_data.get("玩家等级")]
	)

	_reset_profile(8, 1)
	Global.cd_path = TEST_ARCHIVE_PREFIX + "010.json"
	var rejected := MemoryClass.request_save("probe_invalid")
	_check("request_save_rejects_invalid_role", not rejected, "saved=%s" % rejected)
	_check("request_save_invalid_not_written", not FileAccess.file_exists(Global.cd_path))

	_reset_profile(1, 9)
	Global.cd_path = TEST_ARCHIVE_PREFIX + "011.json"
	var seeded := MemoryClass.request_save("probe_seed")
	var seeded_level := MemoryClass.get_archive_level(Global.cd_path)
	var seeded_path := Global.cd_path
	PlayerData.player_data.clear()
	var empty_blocked := MemoryClass.request_save("probe_empty_profile")
	_reset_profile(1, 1)
	var after_level := MemoryClass.get_archive_level(seeded_path)
	_check(
		"empty_profile_not_overwrite",
		seeded and not empty_blocked and seeded_level == 9 and after_level == 9,
		"seed=%s blocked=%s before=%s after=%s" % [seeded, empty_blocked, seeded_level, after_level]
	)


## 直接调用背包/技能/炼体面板的真实保存处理器，验证界面路径确实经 request_save 落盘。
func _test_panel_saves() -> void:
	_reset_profile(1, 5)
	Global.cd_path = PANEL_ARCHIVE_PATH
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


## 主菜单批次：直接调用地图页与各功能页的真实保存处理器，回读加密档案确认已落盘。
func _check_main_menu_saves() -> void:
	_reset_profile(1, 5)
	Global.cd_path = PANEL_ARCHIVE_PATH
	MemoryClass.request_save("probe_main_seed")
	await _check_reward_and_menu_saves()
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


## 关卡与收尾批次：验证结算界面与其余业务保存处理器确实经 request_save 落盘。
func _check_reward_and_menu_saves() -> void:
	_reset_profile(1, 5)
	Global.cd_path = PANEL_ARCHIVE_PATH
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

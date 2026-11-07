extends Node

## 7.2 剩余脚本与场景运行时探针。
## 覆盖：Global 年兽预载、V7.2 公告、喜鹊双倍掉率叠加、幻化翅膀/头衔聚合、
## 小龙女昵称偏移。探针只在 scripts/ 中维护，由 scene_probe_runner 复制执行。

const RESULT_PREFIX := "MENU_UI_72_PROBE_RESULT="
const TEARDOWN_MARKER := "MENU_UI_72_PROBE_TEARDOWN"
const ANNOUNCEMENT_SCENE := preload("res://Scene/main_menu/game_announcement.tscn")
const DJ_SELL_SCENE := preload("res://Scene/back_pack/dj_sell.tscn")
const ROLE8_SCENE := preload("res://Scene/hero/role_8/role_8.tscn")
const TRANSMOGRIFIED_SCRIPT := preload("res://Script/other_menu/transmogrified.gd")
const PET_NIAN_FAMILY := preload("res://Script/pet/pet_nian_family.gd")

var _failures: Array[String] = []
var _saved_myself: Variant = null
var _saved_pets: Variant = null
var _saved_active_pet: Variant = null
var _saved_consumables: Variant = null
var _saved_initial_buffs: Variant = null


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	_save_player_data()
	await _check_pet_nian(checks)
	await _check_announcement(checks)
	await _check_magpie(checks)
	_check_transmogrified(checks)
	_check_role8(checks)
	_restore_player_data()
	checks["teardown"] = true
	for check_name in checks:
		if not checks[check_name]:
			_failures.append(str(check_name))
	print(
		(
			RESULT_PREFIX
			+ JSON.stringify({"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks})
		)
	)
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _save_player_data() -> void:
	_saved_myself = PlayerData.player_data.get("Myself")
	_saved_pets = PlayerData.player_data.get(PlayerData.PET_LIST_KEY)
	_saved_active_pet = PlayerData.player_data.get(PlayerData.ACTIVE_PET_KEY)
	_saved_consumables = PlayerData.player_data.get(DataKeys.CONSUMABLE_LIST)
	_saved_initial_buffs = PlayerData.player_data.get("初始Buff")


func _restore_player_data() -> void:
	if _saved_myself != null:
		PlayerData.player_data["Myself"] = _saved_myself
	if _saved_pets == null:
		PlayerData.player_data.erase(PlayerData.PET_LIST_KEY)
	else:
		PlayerData.player_data[PlayerData.PET_LIST_KEY] = _saved_pets
	if _saved_active_pet == null:
		PlayerData.player_data.erase(PlayerData.ACTIVE_PET_KEY)
	else:
		PlayerData.player_data[PlayerData.ACTIVE_PET_KEY] = _saved_active_pet
	if _saved_consumables == null:
		PlayerData.player_data.erase(DataKeys.CONSUMABLE_LIST)
	else:
		PlayerData.player_data[DataKeys.CONSUMABLE_LIST] = _saved_consumables
	if _saved_initial_buffs == null:
		PlayerData.player_data.erase("初始Buff")
	else:
		PlayerData.player_data["初始Buff"] = _saved_initial_buffs


func _check_pet_nian(checks: Dictionary) -> void:
	var pet: Dictionary = PlayerData.PET_NIAN_PET.duplicate(true)
	pet[DataKeys.DEPLOYED] = true
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [pet]
	PlayerData.player_data[PlayerData.ACTIVE_PET_KEY] = "PetNian"
	var info := Global.get_active_pet_preload_data(1)
	checks["global_pet_nian_type"] = str(info.get("type", "")) == "PetNian"
	checks["global_pet_nian_stage"] = int(info.get("stage", 0)) == 1
	var paths := Global.get_active_pet_preload_paths(1)
	checks["global_pet_nian_paths"] = (
		paths.size() == 3
		and str(paths[0]).ends_with("pet_nian_summon_1.tscn")
		and str(paths[1]).ends_with("pet_nian_stage1_frames.tres")
		and str(paths[2]).ends_with("head1.png")
	)
	Global.prewarm_active_pet_runtime_resources(1)
	checks["global_pet_nian_prewarm"] = Global.get_prewarmed_pet_signature(1) == "PetNian:1"
	checks["global_pet_nian_family_match"] = PET_NIAN_FAMILY.matches(pet)
	await get_tree().process_frame


func _check_announcement(checks: Dictionary) -> void:
	var announcement := ANNOUNCEMENT_SCENE.instantiate()
	add_child(announcement)
	await get_tree().process_frame
	checks["announcement_has_v72"] = (announcement.get("text_data") as Dictionary).has("V7_2")
	checks["announcement_button"] = (
		announcement.get_node_or_null("BG/PanelContainer/HBoxContainer/BBBg/ScrollContainer/bblist/V0_53") != null
	)
	announcement.call("_on_v_0_53_pressed")
	checks["announcement_version"] = (
		str(announcement.get("verisions_name")) == "V7_2" and str(announcement.get("verisions")) == "V7.2"
	)
	checks["announcement_text_rendered"] = announcement.text_list.get_child_count() > 0
	announcement.queue_free()
	await get_tree().process_frame


func _check_magpie(checks: Dictionary) -> void:
	PlayerData.player_data["Myself"] = 1
	PlayerData.player_data[DataKeys.CONSUMABLE_LIST] = {
		"页码1": [{"名字": "xydxq", "数量": 4, "五行": []}],
	}
	PlayerData.player_data["初始Buff"] = []
	var panel := DJ_SELL_SCENE.instantiate()
	panel.set("my_page", 1)
	panel.set("my_name", "xydxq")
	add_child(panel)
	await get_tree().process_frame
	checks["magpie_first_use"] = bool(panel.call("_use_lucky_magpie"))
	checks["magpie_first_duration"] = _magpie_duration() == 7200.0
	checks["magpie_first_count"] = PlayerData.get_xhp_data("xydxq") == 3
	checks["magpie_second_use"] = bool(panel.call("_use_lucky_magpie"))
	checks["magpie_second_duration"] = _magpie_duration() == 14400.0
	checks["magpie_second_count"] = PlayerData.get_xhp_data("xydxq") == 2
	var buffs: Array = PlayerData.player_data["初始Buff"]
	if not buffs.is_empty():
		buffs[0]["AddTime"] = 79200.0
		checks["magpie_near_cap"] = bool(panel.call("_use_lucky_magpie"))
		checks["magpie_near_cap_duration"] = _magpie_duration() == 86400.0
		checks["magpie_near_cap_count"] = PlayerData.get_xhp_data("xydxq") == 1
		checks["magpie_over_cap"] = not bool(panel.call("_use_lucky_magpie"))
		checks["magpie_over_cap_kept"] = _magpie_duration() == 86400.0
		checks["magpie_over_cap_count"] = PlayerData.get_xhp_data("xydxq") == 1
	else:
		checks["magpie_near_cap"] = false
		checks["magpie_near_cap_duration"] = false
		checks["magpie_near_cap_count"] = false
		checks["magpie_over_cap"] = false
		checks["magpie_over_cap_kept"] = false
	panel.queue_free()
	await get_tree().process_frame


func _magpie_duration() -> float:
	var buffs: Array = PlayerData.player_data.get("初始Buff", [])
	for entry in buffs:
		if entry is Dictionary and str(entry.get("Name", "")) == "DoubleFallPro":
			return float(entry.get("AddTime", 0.0))
	return 0.0


func _check_transmogrified(checks: Dictionary) -> void:
	PlayerData.player_data["Myself"] = 4
	var view := TRANSMOGRIFIED_SCRIPT.new()
	var role_label := Label.new()
	view.set("role", role_label)
	var list: Array = view.call("get_current_role_list")
	checks["transmog_sha_items"] = list.has("slxjc") and list.has("slys")
	checks["transmog_sha_items_defined"] = (
		EquipmentService.definition(&"slxjc") != null and EquipmentService.definition(&"slys") != null
	)
	checks["transmog_wings_appended"] = list.has("xqzy")
	checks["transmog_titles_appended"] = list.has("bhyh")
	role_label.free()
	view.free()


func _check_role8(checks: Dictionary) -> void:
	var role8 := ROLE8_SCENE.instantiate()
	var name_label := role8.get_node_or_null("Name_") as Control
	checks["role8_nickname_offset"] = (
		name_label != null
		and is_equal_approx(name_label.offset_top, -134.0)
		and is_equal_approx(name_label.offset_bottom, -112.0)
	)
	role8.free()

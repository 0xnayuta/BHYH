extends Node

## ldl 同帧页面切换、背包 grid 增量刷新与强化保存失败回滚探针。
## 由 scripts/scene_probe_runner.py 在一次性 user:// 目录中执行：只建立并清理
## 本探针独占的 MyAr_ 临时档案，不读取任何真实用户存档、.save_key 或 MainGame.json。
##
## 覆盖：
## - 真实档案会话 + `Global.add_ldl` 打开生产 ldl 场景；
## - 同帧 强化→合成→强化→镶嵌→返回：每一步 active 页面唯一、旧实例只排队不复用、
##   返回后 ldl 释放且模式标志复位；
## - 背包 grid 增量刷新：条目字段原地修改、同值 Data 引用替换、替换后 Data 原地修改
##   都必须触发重填，刷新后快照与引用同步；
## - 强化保存失败（结束会话，复用 archive probe 的注入方式）时装备等级、灵魂与
##   强化石完整回滚，失败原因可观察。

const RESULT_PREFIX := "LDL_RUNTIME_PROBE_RESULT="
const TEARDOWN_MARKER := "LDL_RUNTIME_PROBE_TEARDOWN"
const DataKeys := preload("res://Script/base/data_keys.gd")

const BACKPACK_SCENE_PATH := "res://Scene/back_pack/main_backpack.tscn"
const STRENGTH_SCENE_PATH := "res://Scene/ldl/strength.tscn"
const TEST_ITEM_NAME := "ptxzg"

const SESSION_ROLE_ID := 1
const SESSION_LEVEL := 30
const SESSION_SOUL := 100000
const ROLLBACK_SOUL := 1000
const ROLLBACK_STONES := 10
const AWAIT_FRAME_LIMIT := 240

var _failures: Array[String] = []
var _checks: Dictionary = {}
var _archive_path := ""


func _ready() -> void:
	# 探针主动触发保存失败；关闭兜底提示，只验证信号/状态与回滚。
	Global.set_save_failure_feedback_enabled(false)
	_run.call_deferred()


func _run() -> void:
	_reset_profile(SESSION_ROLE_ID, SESSION_LEVEL)
	PlayerData.player_data["南天王殿"] = 1
	PlayerData.set_soul(SESSION_SOUL)
	_seed_equipment_entry()
	if not _bind_session():
		_finish()
		return
	await _check_backpack_grid_refresh()
	await _check_ldl_same_frame_switch()
	await _check_strength_save_failure_rollback()
	_teardown_session()
	_finish()


## 真实会话但只使用本进程独占的临时档案；路径与真实存档同目录结构，便于走完整校验。
func _bind_session() -> bool:
	_archive_path = "user://MyAr_9%s.json" % str(Time.get_ticks_usec())
	_remove_archive(_archive_path)
	Global.set_cd_path(_archive_path)
	var bound: bool = Global.bind_archive_session()
	_check("session_bound", bound, _archive_path)
	return bound


func _teardown_session() -> void:
	Global.end_archive_session()
	Global.set_cd_path("")
	_remove_archive(_archive_path)
	Global.get_ui_runtime().set_ldl_mode_active(false)


func _remove_archive(path: String) -> void:
	for candidate in [path, path + ".bak"]:
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))


func _reset_profile(role_id: int, level: int) -> void:
	PlayerData.player_data.clear()
	PlayerData.player_data.merge(PlayerData.initialized_data.duplicate(true))
	PlayerData.player_data["Myself"] = role_id
	PlayerData.player_data[DataKeys.PLAYER_LEVEL] = level


func _seed_equipment_entry() -> Dictionary:
	var pages: Dictionary = PlayerData.player_data[DataKeys.EQUIPMENT_LIST]
	var page_items: Array = pages.get("页码1", [])
	page_items.clear()
	var data: Dictionary = EquipmentService.data(TEST_ITEM_NAME).duplicate(true)
	var entry := {DataKeys.NAME: TEST_ITEM_NAME, DataKeys.ENHANCE_LEVEL: 1, "Data": data}
	page_items.push_back(entry)
	pages["页码1"] = page_items
	return entry


## 背包 grid 增量刷新：变更必须触发重填，刷新后快照/引用同步。
## 场景单独实例化，使用普通装备页投影（非 ldl 窗口），直接观察 box 内容是否跟随数据。
func _check_backpack_grid_refresh() -> void:
	Global.get_ui_runtime().set_ldl_mode_active(false)
	var backpack: Node = load(BACKPACK_SCENE_PATH).instantiate()
	add_child(backpack)
	await _await_frames(1)
	var timer: Timer = backpack.get("timer") as Timer
	if timer != null:
		timer.stop()
	backpack.set("current_fl", 0)
	backpack.set("current_page", 1)
	backpack.call("set_box_data")

	var entry: Dictionary = PlayerData.player_data[DataKeys.EQUIPMENT_LIST]["页码1"][0]
	var box: Node = _find_equipment_box(backpack, TEST_ITEM_NAME)
	_check("grid_box_found", box != null, TEST_ITEM_NAME)
	if box == null:
		backpack.queue_free()
		await _await_frames(1)
		return

	_check("grid_initial_level", int(box.get("qh_level")) == 1, str(box.get("qh_level")))
	_check("grid_initial_data_ref", is_same(box.get("eq_prop"), entry.get("Data")), "box 未持有条目 Data 引用")

	# 1) 条目字段原地修改：显示投影变化必须触发重填。
	entry[DataKeys.ENHANCE_LEVEL] = 2
	_check("grid_inplace_detected", not bool(backpack.call("_grid_state_matches")), "原地修改未被识别")
	backpack.call("_on_timer_timeout")
	_check("grid_inplace_refreshed", int(box.get("qh_level")) == 2, str(box.get("qh_level")))

	# 2) 同值但换引用的 Data：值比较命中，必须靠引用身份触发重填。
	var replaced_from: Dictionary = entry["Data"]
	var replacement: Dictionary = replaced_from.duplicate(true)
	entry["Data"] = replacement
	var current_state: Array = backpack.call("_current_grid_state") as Array
	var snapshot: Array = backpack.get("_grid_snapshot") as Array
	_check("grid_ref_swap_value_equal", current_state[0] == snapshot, "替换后投影值应相等")
	_check("grid_ref_swap_detected", not bool(backpack.call("_grid_state_matches")), "同值新引用未被识别")
	backpack.call("_on_timer_timeout")
	_check("grid_ref_swap_refreshed", is_same(box.get("eq_prop"), replacement), "box 仍持有旧 Data 引用")
	_check("grid_ref_swap_synced", bool(backpack.call("_grid_state_matches")), "刷新后引用快照未同步")

	# 3) 替换后的 Data 原地修改：子字典值变化也必须触发重填。
	replacement["锁定"] = true
	_check("grid_inplace_data_detected", not bool(backpack.call("_grid_state_matches")), "Data 原地修改未被识别")
	backpack.call("_on_timer_timeout")
	_check("grid_inplace_data_refreshed", bool(box.get("item_locked")), "锁定状态未刷新")
	_check("grid_inplace_data_synced", bool(backpack.call("_grid_state_matches")), "刷新后投影快照未同步")

	backpack.queue_free()
	await _await_frames(1)


## 同帧切换：所有 handler 同步调用，不插入 await，复现 UI 同帧多事件。
func _check_ldl_same_frame_switch() -> void:
	var ldl: Node = Global.add_ldl(self, Vector2.ZERO)
	var opened: bool = await _await_ldl_ready(ldl)
	_check("ldl_opened", opened and Global.get_ui_runtime().is_ldl_mode_active(), str(opened))
	if not opened:
		return
	var bg: Node = ldl.get("bg_2") as Node
	var initial_strength: Node = ldl.get("strength") as Node
	_check("ldl_initial_mode", MLdl.current_mode == "强化", str(MLdl.current_mode))
	_check("ldl_initial_panel", _panel_live(initial_strength) and _count_panels(bg, "strength") == 1, "初始强化页缺失或重复")

	ldl.call("_on_hc_pressed")
	var synthesis: Node = ldl.get("synthesis") as Node
	_check("switch_hc_mode", MLdl.current_mode == "合成", str(MLdl.current_mode))
	_check("switch_hc_panel", _panel_live(synthesis) and _count_panels(bg, "synthesis") == 1, "合成页缺失或重复")
	_check("switch_hc_strength_gone", _count_panels(bg, "strength") == 0, "强化页残留")
	_check(
		"switch_hc_old_queued",
		is_instance_valid(initial_strength) and initial_strength.is_queued_for_deletion(),
		"旧强化页未排队释放"
	)

	ldl.call("_on_qh_pressed")
	var second_strength: Node = ldl.get("strength") as Node
	_check("switch_qh_mode", MLdl.current_mode == "强化", str(MLdl.current_mode))
	_check("switch_qh_panel", _panel_live(second_strength) and _count_panels(bg, "strength") == 1, "强化页缺失或重复")
	_check("switch_qh_synthesis_gone", _count_panels(bg, "synthesis") == 0, "合成页残留")
	_check(
		"switch_qh_new_instance",
		is_instance_valid(second_strength) and second_strength != initial_strength,
		"同帧重开复用了旧实例"
	)
	_check(
		"switch_qh_old_queued",
		is_instance_valid(initial_strength) and initial_strength.is_queued_for_deletion(),
		"旧强化页未排队释放"
	)

	ldl.call("_on_xq_pressed")
	var mosaic: Node = ldl.get("mosaic") as Node
	_check("switch_xq_mode", MLdl.current_mode == "镶嵌", str(MLdl.current_mode))
	_check("switch_xq_panel", _panel_live(mosaic) and _count_panels(bg, "mosaic") == 1, "镶嵌页缺失或重复")
	_check("switch_xq_strength_gone", _count_panels(bg, "strength") == 0, "强化页残留")
	_check(
		"switch_xq_old_queued",
		is_instance_valid(second_strength) and second_strength.is_queued_for_deletion(),
		"强化页未排队释放"
	)

	ldl.call("_on_return_pressed")
	_check("return_mode", MLdl.current_mode == "强化", str(MLdl.current_mode))
	_check("return_inactive", not Global.get_ui_runtime().is_ldl_mode_active(), "ldl 模式标志未复位")
	_check("return_queued", not is_instance_valid(ldl) or ldl.is_queued_for_deletion(), "ldl 未排队释放")
	await _await_frames(2)
	_check("return_freed", not is_instance_valid(ldl), "ldl 未释放")


## 保存失败回滚：沿用 archive probe 的 no_archive_session 注入，避免写坏外部文件。
func _check_strength_save_failure_rollback() -> void:
	Global.get_ui_runtime().set_ldl_mode_active(true)
	_reset_profile(SESSION_ROLE_ID, 1)
	PlayerData.set_soul(ROLLBACK_SOUL)
	PlayerData.add_dj("qhs_1", ROLLBACK_STONES)
	PlayerData.add_dj("qhs_2", ROLLBACK_STONES)
	var entry: Dictionary = _seed_equipment_entry()
	var data: Dictionary = entry["Data"]
	MLdl.qh_list[DataKeys.NAME] = TEST_ITEM_NAME
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = 1
	MLdl.qh_list["页码"] = 1
	MLdl.qh_list["位置"] = 0
	MLdl.qh_list["来源"] = "装备背包"
	MLdl.qh_list["穿戴栏"] = ""
	MLdl.qh_list["Data"] = data

	var strength: Node = load(STRENGTH_SCENE_PATH).instantiate()
	add_child(strength)
	await _await_frames(1)
	strength.set("qh_level", 1)
	strength.set("old_zb_name", TEST_ITEM_NAME)
	strength.set("new_zb_name", TEST_ITEM_NAME)
	strength.call("get_qhs_name")
	strength.call("set_str_info")
	Global.end_archive_session()
	_check("rollback_session_ended", not Global.is_archive_session_active(), "会话未结束，无法注入保存失败")
	strength.call("_on_qh_pressed")

	var failed_entry: Dictionary = PlayerData.player_data[DataKeys.EQUIPMENT_LIST]["页码1"][0]
	var failed_level := int(failed_entry.get(DataKeys.ENHANCE_LEVEL, 0))
	var failed_soul := PlayerData.get_soul()
	var failed_qhs_1 := int(PlayerData.get_item_data("qhs_1"))
	var failed_qhs_2 := int(PlayerData.get_item_data("qhs_2"))
	_check("rollback_level", failed_level == 1, str(failed_level))
	_check("rollback_soul", failed_soul == ROLLBACK_SOUL, str(failed_soul))
	_check(
		"rollback_stones",
		failed_qhs_1 == ROLLBACK_STONES and failed_qhs_2 == ROLLBACK_STONES,
		"%d/%d" % [failed_qhs_1, failed_qhs_2]
	)
	_check(
		"rollback_error_observable", MemoryClass.last_save_error == "no_archive_session", MemoryClass.last_save_error
	)

	strength.queue_free()
	await _await_frames(1)
	Global.get_ui_runtime().set_ldl_mode_active(false)


func _find_equipment_box(backpack: Node, item_name: String) -> Node:
	for box_index in range(1, 26):
		var box: Node = backpack.call("target_box", box_index) as Node
		if box != null and str(box.get("get_item_name")) == item_name:
			return box
	return null


func _count_panels(parent: Node, kind: String) -> int:
	var count := 0
	for child in parent.get_children():
		if not is_instance_valid(child) or child.is_queued_for_deletion():
			continue
		if kind == "strength" and child is Strength:
			count += 1
		elif kind == "synthesis" and child is Synthesis:
			count += 1
		elif kind == "mosaic" and child is Mosaic:
			count += 1
	return count


func _panel_live(panel: Node) -> bool:
	return is_instance_valid(panel) and panel.is_inside_tree() and not panel.is_queued_for_deletion()


func _await_ldl_ready(ldl: Node) -> bool:
	for _frame in range(AWAIT_FRAME_LIMIT):
		await get_tree().process_frame
		if not is_instance_valid(ldl):
			return false
		if ldl.is_inside_tree() and ldl.is_node_ready():
			return true
	return false


func _await_frames(count: int) -> void:
	for _frame in range(count):
		await get_tree().process_frame


func _check(name: String, condition: bool, detail: String = "") -> void:
	_checks[name] = {"ok": condition, "detail": detail}
	if not condition:
		_failures.append("%s: %s" % [name, detail])


func _finish() -> void:
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

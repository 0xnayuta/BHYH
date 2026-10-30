extends Node

## 关卡进入与怪物生成运行时探针（由 scripts/scene_probe_runner.py 复制到工程根目录并执行）。
## 验证 LevelEntryRuntime 的拒绝语义、强制信息面板、掉落概率表与模式复位，
## 以及 MonsterSpawnRuntime 的路径解析与生成结果；结束恢复等级设置、档案路径与运行上下文。

const RESULT_PREFIX := "LEVEL_ENTRY_PROBE_RESULT="
const TEARDOWN_MARKER := "LEVEL_ENTRY_PROBE_TEARDOWN"
const NORMAL_LEVEL := "res://Scene/level/level_1.tscn"
const FORCED_INFO_LEVEL := "res://Scene/level/level_stz.tscn"
const DROP_LEVEL_NAME := "花果山"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	var host := Node2D.new()
	add_child(host)
	var previous_cd_path := Global.get_cd_path()
	var previous_level_info_flag = MainSet.set_data.get("LevelInfo", true)
	var previous_level_name := Global.get_current_level_name()

	# 无档案会话：拒绝进入并返回 null，不实例化面板。
	Global.set_cd_path("")
	checks["reject_without_session"] = (
		Global.add_level_info(host, "花果山", Vector2.ZERO, NORMAL_LEVEL) == null
	)
	checks["reject_without_session_name"] = Global.get_current_level_name() == ""
	checks["enter_guard_without_session"] = (
		Global.get_level_entry_runtime().enter_level_without_info(host, NORMAL_LEVEL) == null
	)

	# 建立会话后：信息面板显示分支返回已登记的面板。
	PlayerData.player_data["Myself"] = 1
	Global.set_cd_path("user://MyAr_1.json")
	Global.bind_archive_session()
	MainSet.set_data["LevelInfo"] = true
	var panel = Global.add_level_info(host, DROP_LEVEL_NAME, Vector2.ZERO, NORMAL_LEVEL)
	checks["panel_created"] = panel != null and is_instance_valid(panel)
	checks["panel_level_name"] = panel != null and str(panel.level_name) == DROP_LEVEL_NAME
	checks["panel_target_path"] = panel != null and str(panel.target_stage_path) == NORMAL_LEVEL
	checks["panel_registered"] = (
		panel != null and Global.get_ui_runtime().is_transient_ui_registered(panel)
	)
	checks["context_name_set"] = Global.get_current_level_name() == DROP_LEVEL_NAME
	if panel != null and is_instance_valid(panel):
		panel.queue_free()

	# 设置关闭信息面板时走直进分支：非 res:// 目标落到兜率宫选择面板，并记录关卡名。
	MainSet.set_data["LevelInfo"] = false
	Global.set_current_level_name("")
	var direct = Global.add_level_info(host, "兜率宫", Vector2.ZERO, "probe_dsg_choose")
	checks["direct_enter_dsg_panel"] = direct != null and is_instance_valid(direct)
	checks["direct_enter_sets_name"] = Global.get_current_level_name() == "兜率宫"
	if direct != null and is_instance_valid(direct):
		direct.queue_free()

	# 强制信息面板关卡不受设置影响。
	var forced = Global.add_level_info(host, "挑战三太子", Vector2.ZERO, FORCED_INFO_LEVEL)
	checks["forced_info_panel"] = forced != null and is_instance_valid(forced)
	if forced != null and is_instance_valid(forced):
		forced.queue_free()

	# 掉落概率表：同步后按关卡名取基础概率，再乘以难度系数。
	Global.sync_level_drop_pro_data({DROP_LEVEL_NAME: {"fall_pro": 50}})
	Global.set_current_level_name(DROP_LEVEL_NAME)
	checks["fall_pro_from_table"] = is_equal_approx(Global.get_current_level_fall_pro(0.1), 0.5)
	Global.set_current_level_name("未登记关卡")
	checks["fall_pro_default"] = is_equal_approx(Global.get_current_level_fall_pro(0.1), 0.1)

	# 模式复位：四个无尽标志与八仙选择由单一入口清除。
	Global.four_swords_endless_mode = true
	Global.three_prince_endless_mode = true
	Global.sss_lendless_mode = true
	Global.constellation_endless_mode = true
	Global.selected_eight_immortal_id = 8
	Global.apply_level_entry_mode_reset("res://Scene/level/level_tzsijian.tscn")
	checks["reset_four_swords"] = not Global.four_swords_endless_mode
	Global.apply_level_entry_mode_reset("res://Scene/level/level_stz.tscn")
	checks["reset_three_prince"] = not Global.three_prince_endless_mode
	Global.apply_level_entry_mode_reset("res://Scene/level/level_sssl.tscn")
	checks["reset_sssl"] = not Global.sss_lendless_mode
	Global.apply_level_entry_mode_reset("res://Scene/level/level_esbxx.tscn")
	checks["reset_constellation"] = not Global.constellation_endless_mode
	Global.apply_level_entry_mode_reset("res://Scene/level/level_bxgh.tscn")
	checks["reset_eight_immortal"] = Global.selected_eight_immortal_id == 0
	Global.four_swords_endless_mode = false
	Global.three_prince_endless_mode = false
	Global.sss_lendless_mode = false
	Global.constellation_endless_mode = false
	Global.selected_eight_immortal_id = 0

	# 怪物生成：默认命名路径不改名，别名路径写 source_monster_id。
	var spawn := Global.get_monster_spawn_runtime()
	var default_path := spawn.monster_scene_path(1)
	checks["spawn_default_path"] = default_path == "res://Scene/monster/monster_1.tscn"
	var monster_parent := Node2D.new()
	add_child(monster_parent)
	var monster = Global.create_monster(1, monster_parent, Vector2(12, 34))
	checks["spawn_monster_created"] = monster != null and is_instance_valid(monster)
	checks["spawn_monster_position"] = monster != null and monster.position == Vector2(12, 34)
	checks["spawn_default_no_meta"] = monster != null and not monster.has_meta("source_monster_id")
	if monster != null and is_instance_valid(monster):
		monster.queue_free()

	# 别名覆盖表里的 ID 走别名场景，并带来源 ID 元数据；无别名时不判失败。
	var alias_checked := false
	var alias_id := 0
	for candidate in range(1, 4000):
		var candidate_path := spawn.monster_scene_path(candidate)
		if candidate_path == "" or candidate_path == "res://Scene/monster/monster_%d.tscn" % candidate:
			continue
		if not ResourceLoader.exists(candidate_path):
			continue
		alias_id = candidate
		break
	if alias_id > 0:
		var alias_monster = Global.create_monster(alias_id, monster_parent, Vector2.ZERO)
		if alias_monster != null:
			checks["spawn_alias_name"] = alias_monster.name == "Monster_%d" % alias_id
			checks["spawn_alias_meta"] = int(alias_monster.get_meta("source_monster_id", -1)) == alias_id
			alias_monster.queue_free()
			alias_checked = true

	Global.set_cd_path(previous_cd_path)
	MainSet.set_data["LevelInfo"] = previous_level_info_flag
	Global.set_current_level_name(previous_level_name)
	if is_instance_valid(host):
		host.queue_free()

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {
		"ok": _failures.is_empty(),
		"failures": _failures.duplicate(),
		"checks": checks,
		"alias_checked": alias_checked,
	}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

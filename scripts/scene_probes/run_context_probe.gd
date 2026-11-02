extends Node

## 运行上下文运行时探针（由 scripts/scene_probe_runner.py 复制到工程根目录并执行）。
## 验证 RunContext 的统计口径（总量与分类型互不串桶）、宝塔层数、关卡显示名，
## 以及结算面板 after_level_end 读取同一上下文；结束后恢复原值，不污染后续用例。

const RESULT_PREFIX := "RUN_CONTEXT_PROBE_RESULT="
const TEARDOWN_MARKER := "RUN_CONTEXT_PROBE_TEARDOWN"
const SETTLEMENT_SCENE := "res://Scene/other_scene/after_level_end.tscn"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	var context := Global.get_run_context()
	context.reset_combat_stats()
	checks["reset_zeroes"] = (
		context.damage_dealt == 0
		and context.physical_dealt == 0
		and context.magic_dealt == 0
		and context.real_dealt == 0
		and context.damage_taken == 0
		and context.physical_taken == 0
		and context.magic_taken == 0
		and context.real_taken == 0
		and context.healing == 0
		and context.hit_count == 0
		and context.hurt_count == 0
		and context.crit_count == 0
		and context.miss_count == 0
	)

	context.add_damage_dealt(100)
	context.add_damage_dealt_by_type("physics", 40)
	context.add_damage_dealt_by_type("magic", 30)
	context.add_damage_dealt_by_type("real", 20)
	context.add_damage_taken(70)
	context.add_damage_taken_by_type("physics", 50)
	context.add_damage_taken_by_type("magic", 15)
	context.add_damage_taken_by_type("real", 5)
	context.add_healing(25)
	context.count_hit()
	context.count_hit()
	context.count_hurt()
	context.count_crit()
	context.count_miss()

	checks["dealt_total"] = context.damage_dealt == 100
	checks["dealt_buckets"] = (
		context.physical_dealt == 40 and context.magic_dealt == 30 and context.real_dealt == 20
	)
	checks["taken_total"] = context.damage_taken == 70
	checks["taken_buckets"] = (
		context.physical_taken == 50 and context.magic_taken == 15 and context.real_taken == 5
	)
	checks["type_isolation"] = (
		context.physical_dealt == 40
		and context.physical_taken == 50
		and context.damage_dealt == 100
		and context.damage_taken == 70
	)
	checks["healing"] = context.healing == 25
	checks["counters"] = (
		context.hit_count == 2
		and context.hurt_count == 1
		and context.crit_count == 1
		and context.miss_count == 1
	)

	# 未知伤害类型不写入任何分桶，也不改总量（与迁移前的 if/elif 链一致）。
	context.add_damage_taken_by_type("fire", 999)
	context.add_damage_dealt_by_type("fire", 999)
	checks["unknown_type_ignored"] = context.damage_taken == 70 and context.damage_dealt == 100

	var previous_floor := context.get_tower_floor()
	context.set_tower_floor(7)
	var floor_after_set := Global.get_tower_floor()
	Global.advance_tower_floor()
	checks["tower_floor_set"] = floor_after_set == 7
	checks["tower_floor_advance"] = Global.get_tower_floor() == 8
	checks["tower_floor_shared"] = context.get_tower_floor() == 8

	var previous_name := Global.get_current_level_name()
	Global.set_current_level_name("运行上下文探针")
	checks["level_name_roundtrip"] = Global.get_current_level_name() == "运行上下文探针"

	# 结算面板读取同一上下文：数值来自 RunContext，而不是面板自身状态。
	var settlement := (load(SETTLEMENT_SCENE) as PackedScene).instantiate()
	add_child(settlement)
	var settlement_hit: Label = settlement.get_node("HBoxContainer/VBoxContainer/TotalHit")
	var settlement_cure: Label = settlement.get_node("HBoxContainer/VBoxContainer3/TotalCure")
	checks["settlement_dealt_label"] = settlement_hit.text == "累计造成伤害：100"
	checks["settlement_cure_label"] = settlement_cure.text == "累计治疗数值：25"

	context.reset_combat_stats()
	checks["reset_after_use"] = context.damage_dealt == 0 and context.healing == 0

	var previous_path := context.get_last_level_path()
	context.set_last_level_path("res://Scene/level/level_1.tscn")
	checks["last_level_path_roundtrip"] = context.get_last_level_path() == "res://Scene/level/level_1.tscn"
	context.clear_last_level_path()
	checks["last_level_path_clear"] = context.get_last_level_path() == ""
	context.set_last_level_path(previous_path)

	context.begin_level_timing()
	var begin_text := context.get_level_begin_time()
	var elapsed := context.finish_level_timing()
	checks["level_timing_end"] = begin_text != "" and context.get_level_end_time() != ""
	checks["level_timing_elapsed"] = elapsed >= 0

	context.record_combo(3)
	context.record_combo(2)
	context.record_combo(5)
	checks["max_combo"] = context.get_max_combo() == 5
	context.reset_player_hit_count()
	context.add_player_hit()
	checks["player_hit_count"] = context.get_player_hit_count() == 1
	context.reset_player_hit_count()

	var previous_game_over := context.get_game_over_variant()
	context.set_game_over_variant(2)
	checks["game_over_variant"] = context.get_game_over_variant() == 2
	context.set_game_over_variant(previous_game_over)

	var previous_prince := context.get_selected_three_prince_id()
	var previous_constellation := context.get_selected_constellation_level()
	context.set_selected_three_prince_id(4402)
	context.set_selected_constellation_level(7)
	checks["selected_ids"] = (
		context.get_selected_three_prince_id() == 4402
		and context.get_selected_constellation_level() == 7
	)
	context.set_selected_three_prince_id(previous_prince)
	context.set_selected_constellation_level(previous_constellation)

	var previous_endless := context.is_llbt_endless_mode()
	var previous_continue := context.is_llbt_continue_mode()
	var previous_boss := context.is_llbt_boss_mode()
	context.set_llbt_challenge_modes(true, false, true)
	checks["llbt_modes_set"] = (
		context.is_llbt_endless_mode() and not context.is_llbt_continue_mode() and context.is_llbt_boss_mode()
	)
	context.clear_llbt_challenge_modes()
	checks["llbt_modes_clear"] = (
		not context.is_llbt_endless_mode()
		and not context.is_llbt_continue_mode()
		and not context.is_llbt_boss_mode()
	)
	context.set_llbt_challenge_modes(previous_endless, previous_continue, previous_boss)
	context.reset_level_progress()

	Global.set_tower_floor(previous_floor)
	Global.set_current_level_name(previous_name)
	checks["restored_floor"] = Global.get_tower_floor() == previous_floor
	checks["restored_name"] = Global.get_current_level_name() == previous_name
	if is_instance_valid(settlement):
		settlement.queue_free()

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

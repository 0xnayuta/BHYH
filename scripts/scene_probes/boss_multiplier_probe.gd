extends Node

## 6.6 BOSS 刷怪倍率探针：上游删除了 Level_65/68 BOSS 出生点的
## ignore_count_multiplier，本探针固定“普通点复制、BOSS 点同样复制”的语义。
## 只构造脚本实例，不进入关卡场景；实际关卡冒烟由 level_test_runner 负责。

const RESULT_PREFIX := "BOSS_MULTIPLIER_PROBE_RESULT="
const TEARDOWN_MARKER := "BOSS_MULTIPLIER_PROBE_TEARDOWN"
const CASES := [
	{
		"name": "level_65",
		"script": "res://Script/level/level_65.gd",
		"boss_id": 3136,
		"boss_stage": 5,
		"normal_id": 3144,
		"normal_stage": 1,
	},
	{
		"name": "level_68",
		"script": "res://Script/level/level_68.gd",
		"boss_id": 3182,
		"boss_stage": 4,
		"normal_id": 3181,
		"normal_stage": 1,
	},
]

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	var previous_multiplier: Variant = MainSet.set_data.get("CreateMonsterCount", 1)
	for case: Dictionary in CASES:
		var case_name := str(case["name"])
		var level = _new_level(str(case["script"]))
		if level == null:
			checks["%s_script_load" % case_name] = false
			_failures.append("%s_script_load" % case_name)
			continue
		var points: Array = level.call("_birth_points")
		var boss_point: Dictionary = _point_for(
			points, int(case["boss_stage"]), int(case["boss_id"])
		)
		checks["%s_boss_point_present" % case_name] = not boss_point.is_empty()
		checks["%s_boss_ignores_multiplier_removed" % case_name] = (
			not boss_point.is_empty() and not bool(boss_point.get("ignore_count_multiplier", false))
		)

		var boss_base := _point_total(points, int(case["boss_stage"]), int(case["boss_id"]))
		var normal_base := _point_total(points, int(case["normal_stage"]), int(case["normal_id"]))
		for multiplier: int in [1, 5]:
			MainSet.set_data["CreateMonsterCount"] = multiplier
			level.call("_configure_level_monsters")
			level.call("_apply_monster_count_multiplier")
			var groups: Dictionary = level.get("monster_group")
			var boss_group: Array = groups.get("stage_%d" % int(case["boss_stage"]), [])
			var normal_group: Array = groups.get("stage_%d" % int(case["normal_stage"]), [])
			var point_states: Dictionary = level.get("_point_states")
			var target := int((point_states.get(50, {}) as Dictionary).get("target", -1))
			var suffix := "%s_x%d" % [case_name, multiplier]
			checks["%s_boss_count" % suffix] = (
				_count_id(boss_group, int(case["boss_id"])) == boss_base * multiplier
			)
			checks["%s_normal_count" % suffix] = (
				_count_id(normal_group, int(case["normal_id"])) == normal_base * multiplier
			)
			checks["%s_point_target" % suffix] = target == boss_base * multiplier
		level.free()

	if previous_multiplier == null:
		MainSet.set_data.erase("CreateMonsterCount")
	else:
		MainSet.set_data["CreateMonsterCount"] = int(previous_multiplier)

	for key: String in checks:
		if not bool(checks[key]):
			_failures.append(key)
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _new_level(script_path: String):
	var script := load(script_path) as Script
	if script == null:
		return null
	return script.new()


func _point_for(points: Array, stage: int, monster_id: int) -> Dictionary:
	for point: Dictionary in points:
		if int(point.get("stage", 0)) == stage and int(point.get("monster", 0)) == monster_id:
			return point
	return {}


func _point_total(points: Array, stage: int, monster_id: int) -> int:
	var total := 0
	for point: Dictionary in points:
		if int(point.get("stage", 0)) == stage and int(point.get("monster", 0)) == monster_id:
			total += int(point.get("total", 0))
	return total


func _count_id(items: Array, monster_id: int) -> int:
	var count := 0
	for item: Variant in items:
		if int(item) == monster_id:
			count += 1
	return count

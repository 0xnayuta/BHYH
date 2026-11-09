extends Node

## 38-6a 回归：非 qly 精英 signature 必须把方向写入 EliteAttack.move_direction。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "PHASE_38_6A_PROBE_RESULT="
const TEARDOWN_MARKER := "PHASE_38_6A_PROBE_TEARDOWN"
const LEVEL_ELITE := preload("res://Scene/level/level_elite.tscn")
const ATTACK_SCRIPT := preload("res://Script/level/elite_attack.gd")

var _checks: Dictionary = {}
var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var saved_selection: Dictionary = Global.get_run_context().get_elite_challenge_selection()
	var saved_level: String = Global.get_current_level_name()
	var saved_game_over: int = Global.get_run_context().get_game_over_variant()
	Global.get_run_context().set_elite_challenge_selection({"card": "sfe", "tier": 0})
	var level := LEVEL_ELITE.instantiate()
	add_child(level)
	var mechanics: Node = null
	for _index in range(120):
		mechanics = level.get_node_or_null("EliteMechanics")
		if mechanics != null and is_instance_valid(level.get("elite_boss")):
			break
		await get_tree().process_frame
	_checks["sfe_elite_spawned"] = mechanics != null and is_instance_valid(level.get("elite_boss"))
	if mechanics == null:
		_checks["sfe_attack_created"] = false
		_checks["sfe_attack_direction"] = false
	else:
		level.set_physics_process(false)
		mechanics.call("_emit", Vector2(500, 300), "sound", 125.0, 0.8, Vector2.RIGHT, false)
		var attack: Node = null
		for child in level.get_children():
			if child.get_script() == ATTACK_SCRIPT:
				attack = child
				break
		_checks["sfe_attack_created"] = attack != null
		_checks["sfe_attack_direction"] = (
			attack != null
			and attack.get("move_direction") is Vector2
			and (attack.get("move_direction") as Vector2).is_equal_approx(Vector2.RIGHT)
		)
		_checks["sfe_attack_visual"] = attack != null and str(attack.get("visual")) == "sound"
		if attack != null:
			attack.set_physics_process(false)
			attack.queue_free()
	level.queue_free()
	await get_tree().process_frame
	Global.get_run_context().set_elite_challenge_selection(saved_selection)
	Global.set_current_level_name(saved_level)
	Global.get_run_context().set_game_over_variant(saved_game_over)
	_report()


func _report() -> void:
	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

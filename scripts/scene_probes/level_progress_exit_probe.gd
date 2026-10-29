extends Node

## 18-3C：关卡退出分支保存次数探针。
## 直接加载特殊关卡，注入保存/转场替身，断言非胜利分支只保存一次。

const RESULT_PREFIX := "LEVEL_PROGRESS_EXIT_PROBE_RESULT="
const TEARDOWN_MARKER := "LEVEL_PROGRESS_EXIT_PROBE_TEARDOWN"
const LOAD_MAX_FRAMES := 900

var _failures: Array[String] = []
var _is_worker := false


func _ready() -> void:
	if not _is_worker:
		var worker: Node = duplicate()
		worker.set("_is_worker", true)
		worker.name = "LevelProgressExitProbeWorker"
		get_tree().root.add_child.call_deferred(worker)
		return
	_run.call_deferred()


func _run() -> void:
	PlayerData.player_data["Myself"] = 1
	PlayerData.player_data["玩家等级"] = 30
	Global.set_cd_path("user://MyAr_9098.json")
	Global.bind_archive_session()
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["剧情跳过"] = false
	var checks: Dictionary = {}
	await _check_branch("res://Scene/level/level_17.tscn", "res://Scene/level/level_sdwfb.tscn", checks)
	await _check_branch("res://Scene/level/level_22.tscn", "res://Scene/level/level_xtqfb.tscn", checks)
	await _check_branch("res://Scene/level/level_19.tscn", "res://Scene/level/level_20.tscn", checks, true)
	await _check_branch("res://Scene/level/level_20.tscn", "res://Scene/level/level_20.tscn", checks)
	await _check_branch("res://Scene/level/level_10.tscn", "res://Scene/main_menu/game_over_1.tscn", checks)
	await _check_branch("res://Scene/level/level_21.tscn", "res://Scene/main_menu/game_over_1.tscn", checks)
	Global.end_archive_session()
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_branch(scene_path: String, expected_target: String, checks: Dictionary, force_no_throw := false) -> void:
	var label := scene_path.get_file()
	Global.change_scene(scene_path, false, false)
	var level: Node = await _await_scene(scene_path)
	if level == null:
		_fail(label + ": 关卡加载超时")
		checks[label] = false
		return
	if force_no_throw:
		level.set("canthro", false)
	var saves: Array[String] = []
	var target_box := {"target": ""}
	level.set(
		"progress_save_override",
		func(reason: String) -> bool:
			saves.append(reason)
			return true
	)
	level.set(
		"exit_scene_change_override",
		func(path: String) -> void:
			target_box["target"] = path
	)
	await level.call("_leave_level_from_exit")
	await get_tree().process_frame
	var target := str(target_box["target"])
	var ok := saves.size() == 1 and saves[0] == "level_progress_transition" and target == expected_target
	if not ok:
		_fail("%s: saves=%s target=%s expected=%s" % [label, str(saves), target, expected_target])
	checks[label] = ok
	await _release_current_level()


func _await_scene(scene_path: String) -> Node:
	for _frame in range(LOAD_MAX_FRAMES):
		await get_tree().process_frame
		var current := get_tree().current_scene
		if current != null and current.scene_file_path == scene_path:
			return current
	return null


func _release_current_level() -> void:
	var current := get_tree().current_scene
	if current != null and is_instance_valid(current):
		get_tree().current_scene = null
		current.queue_free()
		await get_tree().process_frame


func _fail(message: String) -> void:
	_failures.append(message)

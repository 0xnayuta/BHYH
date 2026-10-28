extends Node

## 加载页失败/取消/超时探针（由 scripts/scene_probe_runner.py 复制到工程根目录并执行）。
## 验证：预载单槽失败/显式清理、重复切换旧加载页不提交、超时后保留加载页，
## 以及失败/取消不会进入目标可玩场景。

const RESULT_PREFIX := "LOAD_GUARD_PROBE_RESULT="
const TEARDOWN_MARKER := "LOAD_GUARD_PROBE_TEARDOWN"
const LOAD_SCENE := "res://Scene/other_scene/load_scene.tscn"
const LEVEL_1 := "res://Scene/level/level_1.tscn"
const LEVEL_2 := "res://Scene/level/level_2.tscn"
const LEVEL_3 := "res://Scene/level/level_3.tscn"
const MISSING_SCENE := "res://Scene/level/__load_guard_missing.tscn"
const WAIT_FRAMES := 1800

var _failures: Array[String] = []
var _is_worker := false


func _ready() -> void:
	if not _is_worker:
		var worker: Node = duplicate()
		worker.set("_is_worker", true)
		worker.name = "LoadGuardProbeWorker"
		get_tree().root.add_child.call_deferred(worker)
		return
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	Global.preload_next(MISSING_SCENE)
	await get_tree().process_frame
	var missing_slot := Global.get_preloaded_scene_slot_snapshot()
	checks["slot_missing_cleared"] = (
		str(missing_slot.get("path", "")) == "" and not bool(missing_slot.get("ready", true))
	)

	Global.preload_next(LEVEL_1)
	await get_tree().process_frame
	Global.clear_preloaded_scene_slot()
	var cleared_slot := Global.get_preloaded_scene_slot_snapshot()
	checks["slot_explicit_clear"] = (
		str(cleared_slot.get("path", "")) == ""
		and str(cleared_slot.get("ready_path", "")) == ""
		and not bool(cleared_slot.get("ready", true))
	)

	Global.change_scene(LEVEL_1)
	var first_page: Node = await _await_scene(LOAD_SCENE, 120)
	checks["cancel_page_started"] = first_page != null
	Global.change_scene(LEVEL_2)
	var level_two: Node = await _await_scene(LEVEL_2, WAIT_FRAMES)
	checks["cancel_latest_wins"] = level_two != null
	var current_after_cancel := get_tree().current_scene
	checks["cancel_stale_not_current"] = (
		current_after_cancel != null and current_after_cancel.scene_file_path == LEVEL_2
	)

	ProjectSettings.set_setting("application/run/load_timeout_msec", 0)
	Global.change_scene(LEVEL_3, true)
	var timeout_page: Node = await _await_scene(LOAD_SCENE, 120)
	var timeout_failed := false
	for _frame in range(120):
		await get_tree().process_frame
		if (
			is_instance_valid(timeout_page)
			and timeout_page.has_method("is_load_failed")
			and bool(timeout_page.call("is_load_failed"))
		):
			timeout_failed = true
			break
	checks["timeout_failed"] = timeout_failed
	var current_after_timeout := get_tree().current_scene
	checks["timeout_stays_loading"] = (
		current_after_timeout != null and current_after_timeout.scene_file_path == LOAD_SCENE
	)
	ProjectSettings.set_setting("application/run/load_timeout_msec", 120000)

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _await_scene(scene_path: String, max_frames: int) -> Node:
	for _frame in range(max_frames):
		await get_tree().process_frame
		var current := get_tree().current_scene
		if current != null and is_instance_valid(current) and current.scene_file_path == scene_path:
			return current
	return null

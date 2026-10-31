extends Node

## DragonBones 骨骼运行时探针（由 scripts/scene_probe_runner.py 复制到工程根目录执行）。
## 验证 ZMWS 批量导出的 .dbfactory 能被 DragonBonesArmatureView 实例化、播放 appear_1、
## 推进时间轴与 seek，并记录首次/热实例化开销与多实例稳态帧时间。
## 覆盖 KNOWN_LIMITATIONS §8 的 1×1 拆件：插件按骨骼缩放绘制，渲染区域与整套角色一致。

const RESULT_PREFIX := "DRAGONBONES_ARMATURE_PROBE_RESULT="
const TEARDOWN_MARKER := "DRAGONBONES_ARMATURE_PROBE_TEARDOWN"

const CASES: Array[Dictionary] = [
	{
		"key": "wukong",
		"factory": "res://Art/monster/01_wukong_shengti/01_wukong_shengti.dbfactory",
		"data": "01-wukong_shengti",
		"animations": 85,
		"bones": 60,
		"slots": 50,
		"rect": Vector2(112.27, 184.45),
		"animation": "appear_1",
	},
	{
		"key": "shaseng",
		"factory": "res://Art/monster/04_shaseng/04_shaseng.dbfactory",
		"data": "04-shaseng",
		"animations": 117,
		"bones": 49,
		"slots": 47,
		"rect": Vector2(201.83, 135.16),
		"animation": "idle",
	},
]
const RECT_TOLERANCE := 0.5
const FIRST_INSTANCE_BUDGET_MS := 4000.0
const WARM_INSTANCE_BUDGET_MS := 400.0
const MULTI_INSTANCE := 8
const STEADY_FRAME_BUDGET_MS := 20.0

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	var metrics: Dictionary = {}
	# 首帧固定开销（headless 初始化）不属于被测逻辑，先吞掉一帧。
	await get_tree().process_frame

	for case in CASES:
		await _check_case(case, checks, metrics)
	await _check_multi_instance(checks, metrics)

	checks["teardown"] = _teardown()
	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {
		"ok": _failures.is_empty(),
		"failures": _failures.duplicate(),
		"checks": checks,
		"metrics": metrics,
	}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)


func _check_case(case: Dictionary, checks: Dictionary, metrics: Dictionary) -> void:
	var key: String = case["key"]
	var factory := load(case["factory"]) as Resource
	checks["%s_factory" % key] = factory != null
	if factory == null:
		return

	var names: Array = factory.call("get_loaded_dragon_bones_data_name_list")
	checks["%s_data_name" % key] = names.has(case["data"])
	var armature_names: Array = factory.call("get_loaded_dragon_bones_armature_name_list", case["data"])
	checks["%s_armature_name" % key] = armature_names.has(case["data"])

	var view = _spawn(factory, case["data"])
	var t_start := Time.get_ticks_msec()
	await get_tree().process_frame
	var first_ms := float(Time.get_ticks_msec() - t_start)
	metrics["%s_first_instance_ms" % key] = first_ms
	checks["%s_first_instance_budget" % key] = first_ms < FIRST_INSTANCE_BUDGET_MS

	var animations: Array = view.call("get_animations")
	checks["%s_animation_count" % key] = animations.size() == int(case["animations"])
	var animation: String = case["animation"]
	checks["%s_has_animation" % key] = view.call("has_animation", animation)

	var armature = view.call("get_armature")
	checks["%s_armature" % key] = armature != null
	if armature != null:
		checks["%s_bones" % key] = armature.call("get_bones").size() == int(case["bones"])
		checks["%s_slots" % key] = armature.call("get_slots").size() == int(case["slots"])

	view.call("play", animation, 1)
	checks["%s_playing" % key] = bool(view.call("is_playing"))
	checks["%s_current_animation" % key] = str(view.call("get_current_animation")) == animation

	for _i in 8:
		await get_tree().process_frame
	var progress := float(view.call("get_animation_progress"))
	metrics["%s_progress_after_8_frames" % key] = progress
	checks["%s_progress_advances" % key] = progress > 0.0 and progress < 1.0

	view.call("seek_animation", animation, 0.5)
	var told := float(view.call("tell_animation", animation))
	metrics["%s_tell_at_half" % key] = told
	checks["%s_seek" % key] = absf(told - 0.5) < 0.05

	var rect: Rect2 = view.call("get_rect")
	metrics["%s_rect" % key] = [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
	var expected: Vector2 = case["rect"]
	checks["%s_rect" % key] = rect.size.distance_to(expected) <= RECT_TOLERANCE

	view.call("stop_all_animations", true, true)
	checks["%s_stopped" % key] = not bool(view.call("is_playing"))

	# 热实例化：同一 factory 再次实例化，仅 measure 首帧构建开销。
	var t_warm := Time.get_ticks_msec()
	var warm = _spawn(factory, case["data"])
	await get_tree().process_frame
	var warm_ms := float(Time.get_ticks_msec() - t_warm)
	metrics["%s_warm_instance_ms" % key] = warm_ms
	checks["%s_warm_instance_budget" % key] = warm_ms < WARM_INSTANCE_BUDGET_MS
	warm.free()

	view.free()


func _check_multi_instance(checks: Dictionary, metrics: Dictionary) -> void:
	var case: Dictionary = CASES[0]
	var factory := load(case["factory"]) as Resource
	if factory == null:
		checks["multi_factory"] = false
		return
	var views: Array = []
	var t_build := Time.get_ticks_msec()
	for _i in MULTI_INSTANCE:
		views.append(_spawn(factory, case["data"]))
	await get_tree().process_frame
	metrics["multi_build_ms"] = float(Time.get_ticks_msec() - t_build)
	for view in views:
		view.call("play", case["animation"], 0)

	var t_steady := Time.get_ticks_msec()
	for _i in 30:
		await get_tree().process_frame
	var steady := float(Time.get_ticks_msec() - t_steady) / 30.0
	metrics["multi_steady_frame_ms"] = steady
	metrics["multi_instance_count"] = views.size()
	checks["multi_steady_budget"] = steady < STEADY_FRAME_BUDGET_MS
	for view in views:
		view.call("stop_all_animations", true, true)
		view.free()


func _spawn(factory: Resource, data_name: String):
	var view = ClassDB.instantiate("DragonBonesArmatureView")
	view.set("factory", factory)
	view.set("instantiate_dragon_bones_data_name", data_name)
	view.set("instantiate_armature_name", data_name)
	add_child(view)
	return view


func _teardown() -> bool:
	for child in get_children():
		child.free()
	return true

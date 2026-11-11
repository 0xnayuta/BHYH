extends Node

## UI 作用域缓存切换与过期请求运行时探针（由 scripts/scene_probe_runner.py 复制到
## 工程根目录并执行）。所有断言都只走 ResourceRuntime 公开入口，不访问私有字段。
##
## 覆盖：
## - 真实进入 main menu archive / map / battle 三个作用域，begin 后先读到可见的
##   pending/queued 与 missing_paths，再等待 ready；
## - 读档、炼丹炉/强化/合成、任务、level info 与暂停目标从作用域缓存实例化；
## - 跨作用域释放旧作用域，同时保留无关共享场景与共享纹理；
## - 同作用域重复 begin 在 ready 与在途两种状态都不换 token、不丢请求；
## - map 请求在途时切到 battle：过期等待者返回 false，最终 battle ready 且 scope
##   队列清空，旧 scope 路径不进入当前缓存；
## - begin scope 后立即 begin_ui_preload_pause：idle 期间不启动新请求
##   （pending 为 0、queued 保留），恢复后 ready；
## - 隔离 ResourceRuntime 注入一条真实缺失路径：wait 返回 false、error/failed_paths
##   含路径且未缓存；随后空作用域清理旧 token/失败状态，主 runtime 不受影响；
## - 暂停 UI（set_menu.tscn）登记/关闭后作用域缓存保留；
## - clear_ui_scope 推进 token 并清空作用域缓存；victory 空作用域与
##   clear_runtime_state 主动丢弃缓存；
## - clear_runtime_state 后再次 begin archive/map：engine cache 可能直接命中，
##   只断言 ready、路径可实例化且无旧请求/失败残留；
## - Global._preload_paths_threaded 真实在途（大场景、engine cache 冷）时
##   clear_runtime_state：同步收尾 token、无残留运行时缓存，随后 archive 可重用。
##
## 固定作用域路径来自 `const Array`，GDScript 会自动只读，无法临时 append；
## 因此缺失路径注入由探针内 ResourceRuntime 子类只覆盖 `_collect_ui_scope_paths`，
## 请求调度、线程失败、错误记录与清理仍全部复用真实实现。

const RESULT_PREFIX := "UI_SCOPE_PROBE_RESULT="
const TEARDOWN_MARKER := "UI_SCOPE_PROBE_TEARDOWN"

const ARCHIVE_TARGET := "res://Scene/main_menu/main_menu.tscn"
const MAP_TARGET := "res://Scene/main_menu/map_1.tscn"
const BATTLE_TARGET := "res://Scene/level/level_1.tscn"
const EMPTY_TARGET := "res://Scene/level/victory.tscn"

const ARCHIVE_PATHS := [
	"res://Scene/archive_interface/read_archive_interface.tscn",
	"res://Scene/archive_interface/bacis_ar_button.tscn",
]
const MAP_PATHS := [
	"res://Scene/level/level_info.tscn",
	"res://Scene/task/basic_task.tscn",
	"res://Scene/task/task_title.tscn",
	"res://Scene/ldl/ldl.tscn",
	"res://Scene/ldl/strength.tscn",
	"res://Scene/ldl/synthesis.tscn",
]
const SET_MENU_PATH := "res://Scene/level/set_menu.tscn"
const BATTLE_PATHS := ["res://Scene/level/set_menu.tscn"]

const SHARED_SCENE := "res://Scene/level/victory.tscn"
const SHARED_TEXTURE := "res://Art/backpack/49.png"
const MISSING_SCOPE_PATH := "res://Scene/level/__ui_scope_probe_missing.tscn"
## 大体积真实场景池：仅选 engine cache 未命中的候选，确保能观察到 LOADING。
const LEGACY_PRELOAD_POOL := [
	"res://Scene/level/level_74.tscn",
	"res://Scene/level/level_73.tscn",
	"res://Scene/level/level_85.tscn",
	"res://Scene/level/level_76.tscn",
	"res://Scene/hero/role_1/role1.tscn",
	"res://Scene/hero/role_bullet.tscn",
]
const WAIT_FRAME_LIMIT := 2400


class ScopeWaiter:
	extends Node

	var done := false
	var result := true

	func start(runtime: ResourceRuntime) -> void:
		result = await runtime.wait_ui_scope_ready()
		done = true


## 隔离实例只额外注入一条不存在的必需路径；调度、线程失败、错误记录与清理
## 全部复用真实 ResourceRuntime 实现，不替换加载器。
class MissingScopeRuntime:
	extends ResourceRuntime

	var injected_path := ""

	func _collect_ui_scope_paths(scope_name: String) -> Array[String]:
		var paths: Array[String] = super._collect_ui_scope_paths(scope_name)
		if injected_path != "":
			paths.append(injected_path)
		return paths


var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var runtime := Global.get_resource_runtime()
	var checks: Dictionary = {}

	# 起始作用域为空；共享场景/纹理不属于任何固定 UI 作用域，跨作用域不得被清理。
	var initial := runtime.get_ui_scope_snapshot()
	checks["initial_scope_none"] = str(initial.get("scope", "missing")) == ""
	checks["initial_paths_empty"] = _array_size(initial.get("paths", [])) == 0
	checks["initial_not_pending"] = not runtime.has_ui_scope_pending()
	var shared_scene := runtime.load_scene(SHARED_SCENE)
	var shared_texture := runtime.get_cached_texture(SHARED_TEXTURE)
	checks["shared_scene_cached"] = shared_scene != null and Global.is_resource_cached(SHARED_SCENE)
	checks["shared_texture_cached"] = shared_texture != null and Global.is_resource_cached(SHARED_TEXTURE)

	# archive：main menu 读档作用域。
	runtime.begin_ui_scope(ARCHIVE_TARGET)
	_check_loading_snapshot(runtime.get_ui_scope_snapshot(), "archive", "archive", ARCHIVE_PATHS, checks)
	var archive_ready: bool = await runtime.wait_ui_scope_ready()
	checks["archive_ready"] = archive_ready
	_check_ready_snapshot(runtime, "archive", "archive", ARCHIVE_PATHS, checks)
	_check_instances(runtime, ARCHIVE_PATHS, "archive", checks)

	# battle 首次进入（engine cache 冷）：先上锁再等 idle，暂停期只保留排队。
	runtime.begin_ui_scope(BATTLE_TARGET)
	runtime.begin_ui_preload_pause()
	await runtime.wait_ui_preload_idle()
	await _await_frames(3)
	var paused := runtime.get_ui_scope_snapshot()
	checks["pause_scope_battle"] = str(paused.get("scope", "")) == "battle"
	checks["pause_state_loading"] = str(paused.get("state", "")) == "loading"
	checks["pause_missing_visible"] = _array_size(paused.get("missing_paths", [])) > 0
	checks["pause_no_new_start"] = int(paused.get("pending_count", -1)) == 0
	checks["pause_queued_visible"] = int(paused.get("queued_count", 0)) > 0
	checks["pause_not_started_set_menu"] = runtime.get_cached_packed_scene(SET_MENU_PATH) == null
	runtime.end_ui_preload_pause()
	var pause_resume_ready: bool = await runtime.wait_ui_scope_ready()
	checks["pause_resume_ready"] = pause_resume_ready
	_check_ready_snapshot(runtime, "battle_pause", "battle", BATTLE_PATHS, checks)
	_check_instances(runtime, BATTLE_PATHS, "battle_pause", checks)

	# 暂停 UI：按生产入口登记实例，关闭后作用域缓存仍保留。
	var pause_scene := runtime.get_cached_packed_scene(SET_MENU_PATH)
	var pause_instance: Node = null
	if pause_scene != null:
		pause_instance = pause_scene.instantiate()
	checks["pause_instance_created"] = pause_instance != null
	if pause_instance != null:
		get_tree().root.add_child(pause_instance)
		var ui_runtime := Global.get_ui_runtime()
		ui_runtime.register_ui_runtime_instance(pause_instance, SET_MENU_PATH)
		await get_tree().process_frame
		checks["pause_registered"] = _ui_runtime_count(ui_runtime, SET_MENU_PATH) >= 1
		pause_instance.queue_free()
		await _await_frames(3)
		checks["pause_instance_freed"] = not is_instance_valid(pause_instance)
		checks["pause_unregistered"] = _ui_runtime_count(ui_runtime, SET_MENU_PATH) == 0
		checks["pause_cache_preserved"] = (
			runtime.get_cached_packed_scene(SET_MENU_PATH) != null and runtime.is_ui_scope_scene_path(SET_MENU_PATH)
		)

	# clear_ui_scope：推进旧 token 并清空作用域缓存/状态，共享资源不受影响。
	var battle_token := int(runtime.get_ui_scope_snapshot().get("token", -1))
	runtime.clear_ui_scope()
	var cleared_api := runtime.get_ui_scope_snapshot()
	checks["scope_clear_api_scope_none"] = str(cleared_api.get("scope", "missing")) == ""
	checks["scope_clear_api_token_advanced"] = int(cleared_api.get("token", -1)) > battle_token
	checks["scope_clear_api_paths_empty"] = _array_size(cleared_api.get("paths", [])) == 0
	checks["scope_clear_api_state_none"] = str(cleared_api.get("state", "")) == "none"
	checks["scope_clear_api_error_empty"] = str(cleared_api.get("error", "missing")) == ""
	checks["scope_clear_api_requests_zero"] = (
		int(cleared_api.get("pending_count", -1)) == 0
		and int(cleared_api.get("queued_count", -1)) == 0
		and int(cleared_api.get("cancelled_request_count", -1)) == 0
	)
	checks["scope_clear_api_not_pending"] = not runtime.has_ui_scope_pending()
	checks["scope_clear_api_set_menu_released"] = (
		runtime.get_cached_packed_scene(SET_MENU_PATH) == null and not runtime.is_ui_scope_scene_path(SET_MENU_PATH)
	)
	checks["scope_clear_api_shared_preserved"] = (
		Global.is_resource_cached(SHARED_SCENE) and Global.is_resource_cached(SHARED_TEXTURE)
	)
	var clear_api_wait: bool = await runtime.wait_ui_scope_ready()
	checks["scope_clear_api_wait_true"] = clear_api_wait

	# map 首次进入（engine cache 冷）：请求真实排队/在途时立即切 battle，
	# 验证可见待决状态、过期等待者、最终队列清空与旧 scope 结果丢弃。
	runtime.begin_ui_scope(MAP_TARGET)
	var inflight: Dictionary = await _await_inflight_scope(runtime)
	checks["inflight_scope_map"] = str(inflight.get("scope", "")) == "map"
	checks["inflight_paths"] = _same_path_set(inflight.get("paths", []), MAP_PATHS)
	checks["inflight_state_loading"] = str(inflight.get("state", "")) == "loading"
	checks["inflight_missing_visible"] = _array_size(inflight.get("missing_paths", [])) > 0
	checks["inflight_pending_visible"] = int(inflight.get("pending_count", 0)) > 0
	checks["inflight_queued_visible"] = int(inflight.get("queued_count", 0)) > 0
	checks["inflight_error_empty"] = str(inflight.get("error", "missing")) == ""
	checks["inflight_archive_released"] = _all_not_cached(runtime, ARCHIVE_PATHS)
	checks["inflight_archive_not_scope"] = _none_are_scope_paths(runtime, ARCHIVE_PATHS)
	checks["inflight_battle_released"] = runtime.get_cached_packed_scene(SET_MENU_PATH) == null
	checks["inflight_shared_preserved"] = (
		Global.is_resource_cached(SHARED_SCENE) and Global.is_resource_cached(SHARED_TEXTURE)
	)

	# 在途状态重复 begin 仍幂等：token、请求数与缺失集都不重置。
	var inflight_token := int(inflight.get("token", -1))
	var inflight_requests := int(inflight.get("pending_count", 0)) + int(inflight.get("queued_count", 0))
	var inflight_missing := _array_size(inflight.get("missing_paths", []))
	runtime.begin_ui_scope(MAP_TARGET)
	var inflight_after := runtime.get_ui_scope_snapshot()
	checks["inflight_idempotent_token"] = int(inflight_after.get("token", -2)) == inflight_token
	checks["inflight_idempotent_requests"] = (
		int(inflight_after.get("pending_count", 0)) + int(inflight_after.get("queued_count", 0)) == inflight_requests
	)
	checks["inflight_idempotent_missing"] = (_array_size(inflight_after.get("missing_paths", [])) == inflight_missing)
	checks["inflight_idempotent_state"] = str(inflight_after.get("state", "")) == "loading"

	var waiter := ScopeWaiter.new()
	waiter.name = "UiScopeStaleWaiter"
	add_child(waiter)
	waiter.start(runtime)
	checks["stale_waiter_started"] = not waiter.done
	runtime.begin_ui_scope(BATTLE_TARGET)
	var switched := runtime.get_ui_scope_snapshot()
	checks["switch_scope_battle"] = str(switched.get("scope", "")) == "battle"
	checks["switch_cancelled_visible"] = int(switched.get("cancelled_request_count", 0)) > 0

	# 过期等待者必须返回 false；battle 可能从 engine cache 直接接管，只等待 ready。
	var switch_ready: bool = await runtime.wait_ui_scope_ready()
	checks["battle_ready"] = switch_ready
	for _frame in range(WAIT_FRAME_LIMIT):
		if waiter.done:
			break
		await get_tree().process_frame
	checks["stale_waiter_completed"] = waiter.done
	checks["stale_waiter_false"] = waiter.done and not waiter.result

	var drained: Dictionary = await _drain_scope_requests(runtime)
	checks["final_scope_battle"] = str(drained.get("scope", "")) == "battle"
	checks["final_state_ready"] = str(drained.get("state", "")) == "ready"
	checks["final_pending_zero"] = int(drained.get("pending_count", -1)) == 0
	checks["final_queued_zero"] = int(drained.get("queued_count", -1)) == 0
	checks["final_cancelled_zero"] = int(drained.get("cancelled_request_count", -1)) == 0
	checks["final_not_pending"] = not runtime.has_ui_scope_pending()
	checks["final_battle_cached_all"] = _same_path_set(drained.get("cached_paths", []), BATTLE_PATHS)
	checks["final_map_not_cached"] = _all_not_cached(runtime, MAP_PATHS)
	checks["final_map_not_scope"] = _none_are_scope_paths(runtime, MAP_PATHS)
	checks["final_set_menu_cached"] = runtime.get_cached_packed_scene(SET_MENU_PATH) != null
	var final_wait: bool = await runtime.wait_ui_scope_ready()
	checks["final_wait_ready"] = final_wait
	checks["shared_preserved_after_switch"] = (
		Global.is_resource_cached(SHARED_SCENE) and Global.is_resource_cached(SHARED_TEXTURE)
	)
	_check_ready_snapshot(runtime, "battle", "battle", BATTLE_PATHS, checks)
	_check_instances(runtime, BATTLE_PATHS, "battle", checks)

	# map 热缓存再入：engine cache 已有的路径被直接接管，其余路径真实加载；
	# 旧 battle 缓存释放，无关共享资源保留。
	runtime.begin_ui_scope(MAP_TARGET)
	_check_loading_snapshot(runtime.get_ui_scope_snapshot(), "map_warm", "map", MAP_PATHS, checks)
	var map_ready: bool = await runtime.wait_ui_scope_ready()
	checks["map_ready"] = map_ready
	_check_ready_snapshot(runtime, "map", "map", MAP_PATHS, checks)
	_check_instances(runtime, MAP_PATHS, "map", checks)
	checks["battle_released_by_map"] = _all_not_cached(runtime, BATTLE_PATHS)
	checks["battle_not_scope_by_map"] = _none_are_scope_paths(runtime, BATTLE_PATHS)
	checks["archive_released_by_map"] = _all_not_cached(runtime, ARCHIVE_PATHS)
	checks["archive_not_scope_by_map"] = _none_are_scope_paths(runtime, ARCHIVE_PATHS)
	checks["shared_preserved_by_map"] = (
		Global.is_resource_cached(SHARED_SCENE) and Global.is_resource_cached(SHARED_TEXTURE)
	)

	# 同作用域 ready 状态重复 begin：keep token 与缓存。
	var map_snapshot_before := runtime.get_ui_scope_snapshot()
	var map_token_before := int(map_snapshot_before.get("token", -1))
	runtime.begin_ui_scope(MAP_TARGET)
	var map_snapshot_after := runtime.get_ui_scope_snapshot()
	checks["idempotent_ready_token"] = int(map_snapshot_after.get("token", -2)) == map_token_before
	checks["idempotent_ready_scope"] = str(map_snapshot_after.get("scope", "")) == "map"
	checks["idempotent_ready_cached"] = _same_path_set(map_snapshot_after.get("cached_paths", []), MAP_PATHS)
	checks["idempotent_ready_state"] = str(map_snapshot_after.get("state", "")) == "ready"
	var idempotent_wait: bool = await runtime.wait_ui_scope_ready()
	checks["idempotent_ready_wait"] = idempotent_wait

	# battle 热缓存再入：set_menu 由 engine cache 接管，旧 map 缓存释放。
	runtime.begin_ui_scope(BATTLE_TARGET)
	var battle_again_ready: bool = await runtime.wait_ui_scope_ready()
	checks["battle_reentry_ready"] = battle_again_ready
	_check_ready_snapshot(runtime, "battle_reentry", "battle", BATTLE_PATHS, checks)
	checks["map_released_by_battle_reentry"] = _all_not_cached(runtime, MAP_PATHS)
	checks["map_not_scope_by_battle_reentry"] = _none_are_scope_paths(runtime, MAP_PATHS)
	checks["shared_preserved_by_battle_reentry"] = (
		Global.is_resource_cached(SHARED_SCENE) and Global.is_resource_cached(SHARED_TEXTURE)
	)

	# victory/defeat 目标进入空作用域（生产清空路径），旧 battle 缓存释放但共享资源保留。
	runtime.begin_ui_scope(EMPTY_TARGET)
	var empty_snapshot := runtime.get_ui_scope_snapshot()
	checks["empty_scope_none"] = str(empty_snapshot.get("scope", "missing")) == ""
	checks["empty_paths_empty"] = _array_size(empty_snapshot.get("paths", [])) == 0
	checks["empty_state_none"] = str(empty_snapshot.get("state", "")) == "none"
	checks["empty_error_empty"] = str(empty_snapshot.get("error", "missing")) == ""
	checks["empty_requests_zero"] = (
		int(empty_snapshot.get("pending_count", -1)) == 0
		and int(empty_snapshot.get("queued_count", -1)) == 0
		and int(empty_snapshot.get("cancelled_request_count", -1)) == 0
	)
	checks["empty_not_pending"] = not runtime.has_ui_scope_pending()
	var empty_wait: bool = await runtime.wait_ui_scope_ready()
	checks["empty_wait_true"] = empty_wait
	checks["empty_releases_battle"] = (
		runtime.get_cached_packed_scene(SET_MENU_PATH) == null and not runtime.is_ui_scope_scene_path(SET_MENU_PATH)
	)
	checks["empty_preserves_shared"] = (
		Global.is_resource_cached(SHARED_SCENE) and Global.is_resource_cached(SHARED_TEXTURE)
	)

	# clear_runtime_state：主动丢弃全部运行时缓存。
	runtime.clear_runtime_state()
	var discarded := runtime.get_ui_scope_snapshot()
	checks["discard_scope_none"] = str(discarded.get("scope", "missing")) == ""
	checks["discard_paths_empty"] = _array_size(discarded.get("paths", [])) == 0
	checks["discard_state_none"] = str(discarded.get("state", "")) == "none"
	checks["discard_error_empty"] = str(discarded.get("error", "missing")) == ""
	checks["discard_requests_zero"] = (
		int(discarded.get("pending_count", -1)) == 0
		and int(discarded.get("queued_count", -1)) == 0
		and int(discarded.get("cancelled_request_count", -1)) == 0
	)
	checks["discard_not_pending"] = not runtime.has_ui_scope_pending()
	var discard_wait: bool = await runtime.wait_ui_scope_ready()
	checks["discard_wait_true"] = discard_wait
	checks["discard_shared_cleared"] = (
		runtime.get_cached_packed_scene(SHARED_SCENE) == null and not Global.is_resource_cached(SHARED_TEXTURE)
	)

	# clear_runtime_state 后重用：engine cache 可能直接命中，因此不断言初始 loading；
	# 只要求再次 begin archive/map 后 ready、路径可实例化且无旧请求/失败残留。
	runtime.begin_ui_scope(ARCHIVE_TARGET)
	var reuse_archive_ready: bool = await runtime.wait_ui_scope_ready()
	checks["reuse_archive_ready"] = reuse_archive_ready
	_check_ready_snapshot(runtime, "archive_reuse", "archive", ARCHIVE_PATHS, checks)
	_check_instances(runtime, ARCHIVE_PATHS, "archive_reuse", checks)
	_check_scope_queue_drained(runtime, "archive_reuse", checks)

	runtime.begin_ui_scope(MAP_TARGET)
	var reuse_map_ready: bool = await runtime.wait_ui_scope_ready()
	checks["reuse_map_ready"] = reuse_map_ready
	_check_ready_snapshot(runtime, "map_reuse", "map", MAP_PATHS, checks)
	_check_instances(runtime, MAP_PATHS, "map_reuse", checks)
	_check_scope_queue_drained(runtime, "map_reuse", checks)
	checks["reuse_map_releases_archive"] = _all_not_cached(runtime, ARCHIVE_PATHS)
	checks["reuse_map_archive_not_scope"] = _none_are_scope_paths(runtime, ARCHIVE_PATHS)
	checks["reuse_map_no_battle_cache"] = _all_not_cached(runtime, BATTLE_PATHS)
	checks["reuse_map_battle_not_scope"] = _none_are_scope_paths(runtime, BATTLE_PATHS)

	# 失败传播/清理：GDScript 的 const Array 自动只读，无法 temporary append；
	# 改用独立 ResourceRuntime 子类只在收集路径时注入一条真实缺失路径，
	# 其余调度、线程失败、错误记录与清理全部复用真实实现。
	checks["map_paths_const_readonly"] = ResourceRuntime.UI_SCOPE_MAP_SCENE_PATHS.is_read_only()
	var global_runtime := Global.get_resource_runtime()
	var global_before := global_runtime.get_ui_scope_snapshot()
	var failing_runtime := MissingScopeRuntime.new()
	failing_runtime.name = "UiScopeFailureProbeRuntime"
	failing_runtime.injected_path = MISSING_SCOPE_PATH
	failing_runtime.setup(Global)
	add_child(failing_runtime)
	failing_runtime.begin_ui_scope(MAP_TARGET)
	var failure_wait: bool = await failing_runtime.wait_ui_scope_ready()
	checks["isolated_failure_wait_false"] = not failure_wait
	var failure_snapshot := failing_runtime.get_ui_scope_snapshot()
	checks["isolated_failure_scope_map"] = str(failure_snapshot.get("scope", "")) == "map"
	checks["isolated_failure_state_failed"] = str(failure_snapshot.get("state", "")) == "failed"
	checks["isolated_failure_error_has_path"] = str(failure_snapshot.get("error", "")).contains(MISSING_SCOPE_PATH)
	checks["isolated_failure_failed_path"] = ((failure_snapshot.get("failed_paths", []) as Array).has(
		MISSING_SCOPE_PATH
	))
	checks["isolated_failure_missing_not_cached"] = (
		failing_runtime.get_cached_packed_scene(MISSING_SCOPE_PATH) == null
	)
	checks["isolated_failure_missing_is_scope_path"] = (failing_runtime.is_ui_scope_scene_path(MISSING_SCOPE_PATH))
	var failure_token := int(failure_snapshot.get("token", -1))

	failing_runtime.injected_path = ""
	failing_runtime.begin_ui_scope(EMPTY_TARGET)
	await failing_runtime.wait_ui_preload_idle()
	var failure_cleanup := failing_runtime.get_ui_scope_snapshot()
	checks["isolated_cleanup_scope_none"] = str(failure_cleanup.get("scope", "")) == ""
	checks["isolated_cleanup_token_advanced"] = (int(failure_cleanup.get("token", -1)) > failure_token)
	checks["isolated_cleanup_paths_empty"] = _array_size(failure_cleanup.get("paths", [])) == 0
	checks["isolated_cleanup_failed_empty"] = (_array_size(failure_cleanup.get("failed_paths", [])) == 0)
	checks["isolated_cleanup_error_empty"] = (str(failure_cleanup.get("error", "missing")) == "")
	checks["isolated_cleanup_state_none"] = str(failure_cleanup.get("state", "")) == "none"
	checks["isolated_cleanup_requests_zero"] = (
		int(failure_cleanup.get("pending_count", -1)) == 0
		and int(failure_cleanup.get("queued_count", -1)) == 0
		and int(failure_cleanup.get("cancelled_request_count", -1)) == 0
	)
	checks["isolated_cleanup_not_pending"] = not failing_runtime.has_ui_scope_pending()
	checks["isolated_cleanup_missing_not_cached"] = (
		failing_runtime.get_cached_packed_scene(MISSING_SCOPE_PATH) == null
	)
	checks["isolated_cleanup_missing_not_scope"] = (not failing_runtime.is_ui_scope_scene_path(MISSING_SCOPE_PATH))
	var isolated_wait: bool = await failing_runtime.wait_ui_scope_ready()
	checks["isolated_cleanup_wait_true"] = isolated_wait
	var global_after := global_runtime.get_ui_scope_snapshot()
	checks["isolated_global_scope_unchanged"] = (
		str(global_after.get("scope", "missing")) == str(global_before.get("scope", "missing"))
	)
	checks["isolated_global_token_unchanged"] = (
		int(global_after.get("token", -1)) == int(global_before.get("token", -2))
	)
	checks["isolated_global_paths_unchanged"] = _same_path_set(
		global_after.get("paths", []), global_before.get("paths", [])
	)
	checks["isolated_global_missing_not_cached"] = (global_runtime.get_cached_packed_scene(MISSING_SCOPE_PATH) == null)
	failing_runtime.clear_runtime_state()
	failing_runtime.queue_free()
	await _await_frames(2)
	checks["isolated_runtime_freed"] = not is_instance_valid(failing_runtime)

	# legacy 线程预载在途时 clear_runtime_state：转移 orphan 后同步收尾 token。
	# 先清空运行时缓存，再从 engine cache 未命中的大场景中选择候选。
	runtime.clear_runtime_state()
	var legacy_paths := _select_legacy_preload_paths()
	checks["legacy_candidates_available"] = not legacy_paths.is_empty()
	var legacy_in_progress := ""
	if not legacy_paths.is_empty():
		Global._preload_paths_threaded(legacy_paths)
		legacy_in_progress = _first_in_progress_threaded_request(legacy_paths)
		# 有界等待请求进入 LOADING；不同步等待其完成，避免错过 IN_PROGRESS。
		for _frame in range(240):
			if legacy_in_progress != "":
				break
			await get_tree().process_frame
			legacy_in_progress = _first_in_progress_threaded_request(legacy_paths)
	checks["legacy_preload_in_progress"] = legacy_in_progress != ""
	# 立即清理；若同步 drain 阻塞，只会等待真实加载完成，不做循环重试。
	runtime.clear_runtime_state()
	checks["legacy_detected_token_settled"] = (
		legacy_in_progress != ""
		and ResourceLoader.load_threaded_get_status(legacy_in_progress) != ResourceLoader.THREAD_LOAD_IN_PROGRESS
	)
	var legacy_tokens_settled := true
	for path_value in legacy_paths:
		if ResourceLoader.load_threaded_get_status(str(path_value)) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			legacy_tokens_settled = false
	checks["legacy_tokens_settled"] = legacy_tokens_settled
	checks["legacy_threaded_idle"] = runtime.is_threaded_preload_idle()
	checks["legacy_no_stale_cache"] = _none_cached(runtime, legacy_paths)
	checks["legacy_resource_cache_empty"] = runtime.get_resource_cache_size() == 0
	var legacy_cleared := runtime.get_ui_scope_snapshot()
	checks["legacy_clear_scope_none"] = str(legacy_cleared.get("scope", "missing")) == ""
	checks["legacy_clear_state_none"] = str(legacy_cleared.get("state", "")) == "none"
	checks["legacy_clear_requests_zero"] = (
		int(legacy_cleared.get("pending_count", -1)) == 0
		and int(legacy_cleared.get("queued_count", -1)) == 0
		and int(legacy_cleared.get("cancelled_request_count", -1)) == 0
	)

	# 清理后立即重用：engine cache 可能命中，只要求 ready 与可实例化。
	runtime.begin_ui_scope(ARCHIVE_TARGET)
	var legacy_reuse_ready: bool = await runtime.wait_ui_scope_ready()
	checks["legacy_reuse_ready"] = legacy_reuse_ready
	_check_ready_snapshot(runtime, "archive_reuse_legacy", "archive", ARCHIVE_PATHS, checks)
	_check_instances(runtime, ARCHIVE_PATHS, "archive_reuse_legacy", checks)
	_check_scope_queue_drained(runtime, "archive_reuse_legacy", checks)
	checks["legacy_no_stale_cache_after_reuse"] = _none_cached(runtime, legacy_paths)

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_loading_snapshot(
	snapshot: Dictionary, prefix: String, scope: String, expected: Array, checks: Dictionary
) -> void:
	checks["%s_scope_begin" % prefix] = str(snapshot.get("scope", "missing")) == scope
	checks["%s_paths_begin" % prefix] = _same_path_set(snapshot.get("paths", []), expected)
	checks["%s_state_begin_loading" % prefix] = str(snapshot.get("state", "")) == "loading"
	checks["%s_missing_begin_visible" % prefix] = (_array_size(snapshot.get("missing_paths", [])) > 0)
	checks["%s_requests_begin_visible" % prefix] = (
		int(snapshot.get("pending_count", 0)) + int(snapshot.get("queued_count", 0)) > 0
	)
	checks["%s_error_begin_empty" % prefix] = str(snapshot.get("error", "missing")) == ""


func _check_ready_snapshot(
	runtime: ResourceRuntime, prefix: String, scope: String, expected: Array, checks: Dictionary
) -> void:
	var snapshot := runtime.get_ui_scope_snapshot()
	checks["%s_scope_ready" % prefix] = str(snapshot.get("scope", "missing")) == scope
	checks["%s_paths_ready" % prefix] = _same_path_set(snapshot.get("paths", []), expected)
	checks["%s_cached_ready" % prefix] = _same_path_set(snapshot.get("cached_paths", []), expected)
	checks["%s_missing_ready_empty" % prefix] = (_array_size(snapshot.get("missing_paths", [])) == 0)
	checks["%s_state_ready" % prefix] = str(snapshot.get("state", "")) == "ready"
	checks["%s_pending_ready_zero" % prefix] = (
		int(snapshot.get("pending_count", -1)) == 0 and int(snapshot.get("queued_count", -1)) == 0
	)
	checks["%s_not_pending" % prefix] = not runtime.has_ui_scope_pending()
	checks["%s_error_ready_empty" % prefix] = str(snapshot.get("error", "missing")) == ""


func _check_instances(runtime: ResourceRuntime, paths: Array, prefix: String, checks: Dictionary) -> void:
	for path_value in paths:
		var path := str(path_value)
		var label := "%s_%s" % [prefix, path.get_file().get_basename()]
		var packed := runtime.get_cached_packed_scene(path)
		checks["%s_cached" % label] = packed != null
		var instance: Node = null
		if packed != null:
			instance = packed.instantiate()
		checks["%s_instantiated" % label] = instance != null
		if instance != null:
			instance.free()


## ready 之后确认没有残留的取消/失败请求；pending/queued 由 ready 快照覆盖。
func _check_scope_queue_drained(runtime: ResourceRuntime, prefix: String, checks: Dictionary) -> void:
	var snapshot := runtime.get_ui_scope_snapshot()
	checks["%s_cancelled_zero" % prefix] = (int(snapshot.get("cancelled_request_count", -1)) == 0)
	checks["%s_failed_empty" % prefix] = _array_size(snapshot.get("failed_paths", [])) == 0
	checks["%s_not_pending" % prefix] = not runtime.has_ui_scope_pending()


func _ui_runtime_count(ui_runtime: UiRuntime, scene_path: String) -> int:
	var snapshot := ui_runtime.get_scope_snapshot()
	var counts_value: Variant = snapshot.get("runtime_scene_counts", {})
	if not counts_value is Dictionary:
		return -1
	return int((counts_value as Dictionary).get(scene_path, 0))


func _drain_scope_requests(runtime: ResourceRuntime) -> Dictionary:
	var snapshot := runtime.get_ui_scope_snapshot()
	for _frame in range(WAIT_FRAME_LIMIT):
		if (
			int(snapshot.get("pending_count", -1)) == 0
			and int(snapshot.get("queued_count", -1)) == 0
			and int(snapshot.get("cancelled_request_count", -1)) == 0
		):
			return snapshot
		await get_tree().process_frame
		snapshot = runtime.get_ui_scope_snapshot()
	return snapshot


## process_frame 在 Node._process 之前发出：等到同一帧快照里同时出现 LOADING 与
## QUEUED，即可确定请求管理器已填槽且尚未取回，避免把“已 ready”误当在途。
func _await_inflight_scope(runtime: ResourceRuntime) -> Dictionary:
	var snapshot := runtime.get_ui_scope_snapshot()
	for _frame in range(WAIT_FRAME_LIMIT):
		if (
			int(snapshot.get("pending_count", 0)) > 0
			and int(snapshot.get("queued_count", 0)) > 0
			and _array_size(snapshot.get("missing_paths", [])) > 0
		):
			return snapshot
		await get_tree().process_frame
		snapshot = runtime.get_ui_scope_snapshot()
	return snapshot


func _all_not_cached(runtime: ResourceRuntime, paths: Array) -> bool:
	for path_value in paths:
		if runtime.get_cached_packed_scene(str(path_value)) != null:
			return false
	return true


func _none_cached(runtime: ResourceRuntime, paths: Array) -> bool:
	for path_value in paths:
		if runtime.is_resource_cached(str(path_value)):
			return false
	return true


func _first_in_progress_threaded_request(paths: Array) -> String:
	for path_value in paths:
		var path := str(path_value)
		if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return path
	return ""


func _select_legacy_preload_paths() -> Array:
	var selected: Array = []
	for path_value in LEGACY_PRELOAD_POOL:
		var path := str(path_value)
		if ResourceLoader.has_cached(path):
			continue
		selected.append(path)
		if selected.size() >= 2:
			break
	return selected


func _none_are_scope_paths(runtime: ResourceRuntime, paths: Array) -> bool:
	for path_value in paths:
		if runtime.is_ui_scope_scene_path(str(path_value)):
			return false
	return true


func _same_path_set(value: Variant, expected: Array) -> bool:
	var actual: Dictionary = {}
	if value is Array:
		for item in value as Array:
			actual[str(item)] = true
	if actual.size() != expected.size():
		return false
	for item in expected:
		if not actual.has(str(item)):
			return false
	return true


func _array_size(value: Variant) -> int:
	if value is Array:
		return (value as Array).size()
	return -1


func _await_frames(count: int) -> void:
	for _frame in range(count):
		await get_tree().process_frame

class_name ResourceRuntime
extends Node

## 场景/资源缓存、单次关卡租约、单槽预载与线程预热。
## 另持有固定 UI 作用域强引用，并用统一线程请求队列按作用域/永久 UI 分阶段预热。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码通过 Global 窄入口访问，生命周期由本运行时统一管理。

const PERMANENT_SMALL_UI_SCENE_PATHS := [
	"res://Scene/back_pack/back_pack.tscn",
	"res://Scene/skill/learn_skill.tscn",
	"res://Scene/pet/pet_interface.tscn",
	"res://Scene/back_pack/magic_weapon_infor.tscn",
]

## 固定 UI 作用域：每个切换目标绑定一组常用场景，整组异步预热、整组精确释放。
## 空作用域（胜利/失败等）不持有任何场景。
const UI_SCOPE_NONE := ""
const UI_SCOPE_ARCHIVE := "archive"
const UI_SCOPE_MAP := "map"
const UI_SCOPE_BATTLE := "battle"

const UI_SCOPE_MAIN_MENU_SCENE_PATH := "res://Scene/main_menu/main_menu.tscn"
const UI_SCOPE_MAP_SCENE_PREFIX := "res://Scene/main_menu/map_"
const UI_SCOPE_BATTLE_SCENE_PREFIX := "res://Scene/level/"
const UI_SCOPE_BATTLE_EXCLUDED_SCENE_PATHS := [
	"res://Scene/level/victory.tscn",
	"res://Scene/level/defeat.tscn",
]

const UI_SCOPE_ARCHIVE_SCENE_PATHS := [
	"res://Scene/archive_interface/read_archive_interface.tscn",
	"res://Scene/archive_interface/bacis_ar_button.tscn",
]
const UI_SCOPE_MAP_SCENE_PATHS := [
	"res://Scene/level/level_info.tscn",
	"res://Scene/task/basic_task.tscn",
	"res://Scene/task/task_title.tscn",
	"res://Scene/ldl/ldl.tscn",
	"res://Scene/ldl/strength.tscn",
	"res://Scene/ldl/synthesis.tscn",
]
const UI_SCOPE_BATTLE_SCENE_PATHS := [
	"res://Scene/level/set_menu.tscn",
]

## UI 场景可能通过脚本 preload 相互依赖，按队列串行预热避免并发循环等待。
const UI_SCENE_REQUEST_KIND_SCOPE := "scope"
const UI_SCENE_REQUEST_KIND_PERMANENT := "permanent"
const UI_SCENE_REQUEST_STATE_QUEUED := 0
const UI_SCENE_REQUEST_STATE_LOADING := 1
const UI_SCOPE_READY_TIMEOUT_MSEC := 60_000

var _host
var _resource_cache: Dictionary = {}
var _sprite_frames_cache: Dictionary = {}
var _audio_cache: Dictionary = {}
var _texture_cache: Dictionary = {}
var _monster_scene_cache: Dictionary = {}
var _permanent_small_ui_scene_cache: Dictionary = {}

var _permanent_ui_prewarm_in_progress := false
var _permanent_ui_prewarmed := false
var _permanent_ui_prewarm_generation: int = 0
var _permanent_ui_prewarm_token: int = 0
var _permanent_ui_prewarm_error: String = ""

## 当前 UI 作用域：强引用独立于 _resource_cache，切换时精确整体释放。
var _ui_scope_name: String = UI_SCOPE_NONE
var _ui_scope_target_scene: String = ""
var _ui_scope_token: int = 0
var _ui_scope_generation: int = 0
var _ui_scope_paths: Array[String] = []
var _ui_scope_scene_cache: Dictionary = {}
var _ui_scope_failed_paths: Dictionary = {}
var _ui_scope_error: String = ""

## 统一线程请求经理：scope 与永久 UI 共用队列与固定并发槽位。
var _ui_scene_requests: Dictionary = {}
var _ui_scene_request_queue: Array[String] = []
## 外部线程阶段暂停：>0 时只轮询在途请求，不再启动新请求。
var _ui_preload_pause_count: int = 0
## legacy preload 异步互斥：generation 感知，过期 waiter 不阻塞新请求。
var _legacy_preload_epoch: int = 0
var _legacy_preload_lock_owner_id: int = 0
var _legacy_preload_waiter_next_id: int = 0
var _legacy_preload_waiters: Array[Dictionary] = []
var _legacy_active_requests: Array = []
## 普通 Thread 加载作业：4.7.2 的 load_threaded_request 在嵌套 preload 时
## 泄漏 LoadToken（godot#120661）。一次只运行一个普通 Thread 加载，避免两个
## 线程互相等待对方依赖而死锁；排队项由主线程逐帧推进。
var _thread_load_jobs: Dictionary = {}
var _thread_load_queue: Array = []
var _active_thread_load_job: ThreadLoadJob = null
var _thread_load_job_next_id: int = 0
var _thread_load_jobs_shutting_down := false

## 关卡资源租约
var _level_resource_lease: Dictionary = {}
var _level_resource_lease_id: int = 0

## 单槽预载
var _preloaded_scene: PackedScene = null
var _preloaded_scene_path: String = ""
var _preloading_path: String = ""
var _preloading_job_id: int = 0


func setup(host: Node) -> void:
	_host = host
	# 线程请求经理必须在暂停树中继续轮询；实际处理由 set_process 按需开启。
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	_poll_thread_load_jobs()
	_poll_ui_scene_requests()
	_fill_ui_scene_request_slots()
	_refresh_permanent_ui_prewarm_state()
	if _ui_scene_requests.is_empty() and not _has_unsettled_thread_loads():
		set_process(false)
	elif (
		_ui_preload_pause_count > 0
		and _count_ui_scene_requests_in_state(UI_SCENE_REQUEST_STATE_LOADING) == 0
		and not _has_unsettled_thread_loads()
	):
		# 暂停期无在途请求：只保留排队状态，等 end_ui_preload_pause 再恢复。
		set_process(false)


## 是否存在仍需主线程推进的作业：排队、运行中或已放弃但未 join。
func _has_unsettled_thread_loads() -> bool:
	if _active_thread_load_job != null or not _thread_load_queue.is_empty():
		return true
	for job_value in _thread_load_jobs.values():
		if (job_value as ThreadLoadJob).state == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return true
	return false


## 单个线程加载作业：工作线程只执行 ResourceLoader.load，结果由主线程取回。
## `joined` 保证每个 Thread 只 wait_to_finish 一次。
class ThreadLoadJob:
	extends RefCounted
	var job_id: int = 0
	var thread: Thread
	var path: String
	var type_hint: String
	var cache_mode: int = ResourceLoader.CACHE_MODE_REUSE
	var resource: Resource
	var state: int = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	var abandoned := false
	var joined := false


## 登记一个普通 Thread 加载并返回作业 id；实际执行由主线程逐个启动。
func start_thread_load(path: String, type_hint: String = "", cache_mode: int = ResourceLoader.CACHE_MODE_REUSE) -> int:
	if path.is_empty():
		return 0
	_thread_load_job_next_id += 1
	var job := ThreadLoadJob.new()
	job.job_id = _thread_load_job_next_id
	job.path = path
	job.type_hint = type_hint
	job.cache_mode = cache_mode
	_thread_load_jobs[job.job_id] = job
	_thread_load_queue.append(job.job_id)
	_ensure_ui_request_processing()
	return job.job_id


func get_thread_load_state(job_id: int) -> int:
	var job_value: Variant = _thread_load_jobs.get(job_id)
	if job_value == null:
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	return (job_value as ThreadLoadJob).state


## 取回已完成作业的结果并释放句柄；仍在进行中时返回 null 并保留作业。
func take_thread_load_resource(job_id: int) -> Resource:
	var job_value: Variant = _thread_load_jobs.get(job_id)
	if job_value == null:
		return null
	var job: ThreadLoadJob = job_value
	if job.state == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return null
	_thread_load_jobs.erase(job_id)
	_thread_load_queue.erase(job_id)
	_join_thread_load_job(job)
	return job.resource


## 放弃作业结果：运行中的作业标记为 abandoned，结束后由主线程 join 丢弃；
## 排队项直接移除，不创建线程。
func retire_thread_load(job_id: int) -> void:
	if job_id <= 0:
		return
	var job_value: Variant = _thread_load_jobs.get(job_id)
	if job_value == null:
		return
	var job: ThreadLoadJob = job_value
	_thread_load_jobs.erase(job_id)
	_thread_load_queue.erase(job_id)
	if job == _active_thread_load_job:
		job.abandoned = true
	else:
		_join_thread_load_job(job)
	_ensure_ui_request_processing()


## 工作线程入口：不能触碰场景树或节点，只做资源加载。
static func _load_resource_on_thread(path: String, type_hint: String, cache_mode: int) -> Resource:
	return ResourceLoader.load(path, type_hint, cache_mode)


func _poll_thread_load_jobs() -> void:
	var active := _active_thread_load_job
	if active != null:
		if active.thread != null and active.thread.is_alive():
			return
		_join_thread_load_job(active)
		if not active.abandoned:
			active.state = (
				ResourceLoader.THREAD_LOAD_LOADED if active.resource != null else ResourceLoader.THREAD_LOAD_FAILED
			)
		_active_thread_load_job = null
	_start_next_thread_load_job()


func _start_next_thread_load_job() -> void:
	while _active_thread_load_job == null and not _thread_load_queue.is_empty():
		var job_id := int(_thread_load_queue.pop_front())
		var job_value: Variant = _thread_load_jobs.get(job_id)
		if job_value == null:
			continue
		var job: ThreadLoadJob = job_value
		var thread := Thread.new()
		var err := thread.start(ResourceRuntime._load_resource_on_thread.bind(job.path, job.type_hint, job.cache_mode))
		if err != OK:
			job.state = ResourceLoader.THREAD_LOAD_FAILED
			_thread_load_jobs.erase(job_id)
			continue
		job.thread = thread
		_active_thread_load_job = job


func _join_thread_load_job(job: ThreadLoadJob) -> void:
	if job.joined:
		return
	job.joined = true
	if job.thread == null:
		return
	job.resource = job.thread.wait_to_finish() as Resource
	job.thread = null


## 退出或清空：只 join 已结束的线程。运行中的工作线程需要主循环刷新主线程
## MessageQueue 上的回调才能结束，退出阶段无法再推进帧；放弃它并交由进程退出
## 回收，绝不阻塞主线程导致窗口无法关闭。
func _join_all_thread_load_jobs() -> void:
	var active := _active_thread_load_job
	if active != null and not active.joined:
		if active.thread == null or not active.thread.is_alive():
			_join_thread_load_job(active)
	_active_thread_load_job = null
	_thread_load_jobs.clear()
	_thread_load_queue.clear()


func _retire_thread_load_ids(job_ids: Array) -> void:
	for job_id in job_ids:
		retire_thread_load(int(job_id))
	job_ids.clear()


func _erase_thread_load_id(job_ids: Array, job_id: int) -> void:
	var index := job_ids.find(job_id)
	if index >= 0:
		job_ids.remove_at(index)


func is_generation_current(generation: int) -> bool:
	if _host == null:
		return false
	return _host.is_runtime_generation_current(generation)


func get_runtime_generation() -> int:
	if _host == null:
		return 0
	return int(_host._runtime_generation)


# -----------------------------------------------------------------------------
# 缓存大小与诊断快照
# -----------------------------------------------------------------------------


func get_resource_cache_size() -> int:
	return _resource_cache.size()


func get_sprite_frames_cache_size() -> int:
	return _sprite_frames_cache.size()


func get_audio_cache_size() -> int:
	return _audio_cache.size()


func get_texture_cache_size() -> int:
	return _texture_cache.size()


func get_monster_scene_cache_size() -> int:
	return _monster_scene_cache.size()


func get_permanent_small_ui_scene_count() -> int:
	return _permanent_small_ui_scene_cache.size()


func is_permanent_ui_prewarm_in_progress() -> bool:
	return _permanent_ui_prewarm_in_progress


func is_permanent_ui_prewarmed() -> bool:
	return _permanent_ui_prewarmed


func get_permanent_ui_prewarm_error() -> String:
	return _permanent_ui_prewarm_error


## 清空运行期状态后允许重新建立作用域。
func clear_runtime_state() -> void:
	_clear_runtime_state_internal(false)


## 真正进程退出：旧协程只能同步收尾，不允许再进入新运行期或重新开启 process。
func shutdown_runtime_state() -> void:
	_clear_runtime_state_internal(true)


func _clear_runtime_state_internal(shutting_down: bool) -> void:
	# 旧协程可能停在 await；清理前把已发起的 legacy 作业转交主线程继续收尾。
	_retire_thread_load_ids(_legacy_active_requests)
	_abort_ui_scene_requests(shutting_down)
	_ui_preload_pause_count = 0
	_legacy_preload_epoch += 1
	_legacy_preload_lock_owner_id = 0
	_legacy_preload_waiters.clear()
	_ui_scope_token += 1
	_ui_scope_name = UI_SCOPE_NONE
	_ui_scope_target_scene = ""
	_ui_scope_generation = 0
	_ui_scope_paths.clear()
	_ui_scope_scene_cache.clear()
	_ui_scope_failed_paths.clear()
	_ui_scope_error = ""
	_permanent_ui_prewarm_generation = 0
	_permanent_ui_prewarm_token += 1
	_permanent_ui_prewarm_error = ""
	clear_preloaded_scene_slot()
	_resource_cache.clear()
	_sprite_frames_cache.clear()
	_audio_cache.clear()
	_texture_cache.clear()
	_monster_scene_cache.clear()
	_permanent_small_ui_scene_cache.clear()
	_level_resource_lease.clear()
	_level_resource_lease_id = 0
	_permanent_ui_prewarm_in_progress = false
	_permanent_ui_prewarmed = false
	# 可重用 clear 恢复正常调度；真正 shutdown 保持禁止，晚到回调只能同步收尾。
	_thread_load_jobs_shutting_down = shutting_down
	if not shutting_down:
		_ensure_ui_request_processing()


# -----------------------------------------------------------------------------
# 场景与基础资源加载
# -----------------------------------------------------------------------------


func is_scene_resource_path(path: String) -> bool:
	return path.ends_with(".tscn") or path.ends_with(".scn")


func is_valid_packed_scene(value: Variant) -> bool:
	if not is_instance_valid(value):
		return false
	return value is PackedScene


func load_scene(path: String) -> PackedScene:
	if not is_scene_resource_path(path):
		return null
	if _permanent_small_ui_scene_cache.has(path):
		var permanent_scene: Variant = _permanent_small_ui_scene_cache[path]
		if is_valid_packed_scene(permanent_scene):
			return permanent_scene
		_permanent_small_ui_scene_cache.erase(path)
	if _belongs_to_any_ui_scope(path):
		if is_ui_scope_scene_path(path):
			return _load_current_ui_scope_scene_synchronously(path)
		var engine_scene := _get_engine_cached_packed_scene(path)
		if engine_scene != null:
			return engine_scene
		# 非当前作用域的固定 UI 只做主线程 REUSE 读取，不进入 _resource_cache，
		# 避免与作用域强引用形成双持有。
		return _load_scene_synchronously(path)
	if _resource_cache.has(path) and not is_valid_packed_scene(_resource_cache[path]):
		_resource_cache.erase(path)
	if not _resource_cache.has(path):
		var loaded_scene := _load_scene_synchronously(path)
		if loaded_scene == null:
			return null
		_resource_cache[path] = loaded_scene
	var cached_scene: Variant = _resource_cache.get(path)
	if not is_valid_packed_scene(cached_scene):
		return null
	if path in PERMANENT_SMALL_UI_SCENE_PATHS:
		_permanent_small_ui_scene_cache[path] = cached_scene
	return cached_scene as PackedScene


## 同步 API 的唯一读入口：REUSE 在未命中缓存时可能等待同路径已开始的普通线程加载，
## 因此本函数只保证不重复制造加载任务，不承诺零阻塞；正常入口会在加载页等待 UI
## 作用域就绪后再发布目标场景。
func _load_scene_synchronously(path: String) -> PackedScene:
	return ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene


func _load_current_ui_scope_scene_synchronously(path: String) -> PackedScene:
	if _ui_scope_scene_cache.has(path):
		var scoped_scene: Variant = _ui_scope_scene_cache[path]
		if is_valid_packed_scene(scoped_scene):
			_resource_cache.erase(path)
			return scoped_scene as PackedScene
		_ui_scope_scene_cache.erase(path)
	# 兼容早期同步加载/handoff 写入 _resource_cache 的作用域路径：迁入独立字典。
	if _resource_cache.has(path):
		var legacy_scene: Variant = _resource_cache[path]
		_resource_cache.erase(path)
		if is_valid_packed_scene(legacy_scene):
			_ui_scope_scene_cache[path] = legacy_scene
			return legacy_scene as PackedScene
	var engine_scene := _get_engine_cached_packed_scene(path)
	if engine_scene != null:
		_ui_scope_scene_cache[path] = engine_scene
		return engine_scene
	var loaded_scene := _load_scene_synchronously(path)
	if loaded_scene != null:
		_ui_scope_scene_cache[path] = loaded_scene
	return loaded_scene


func load_scene_uncached(path: String) -> PackedScene:
	if path == "":
		return null
	if _belongs_to_any_ui_scope(path):
		# 固定 UI 只允许当前作用域持有；非当前作用域同步读取但不落任何缓存。
		if is_ui_scope_scene_path(path):
			return _load_current_ui_scope_scene_synchronously(path)
		return _load_scene_synchronously(path)
	if _resource_cache.has(path):
		return _resource_cache[path] as PackedScene
	var scene := _load_scene_synchronously(path)
	if scene != null:
		_resource_cache[path] = scene
		track_level_resource(path)
	return scene


func load_level_monster_scene(path: String) -> PackedScene:
	if path == "":
		return null
	if _monster_scene_cache.has(path):
		return _monster_scene_cache[path] as PackedScene
	var scene := load_scene(path)
	if scene != null:
		_monster_scene_cache[path] = scene
		track_level_resource(path)
	return scene


func cache_monster_scene(path: String, scene: PackedScene) -> void:
	if path != "" and scene != null:
		_monster_scene_cache[path] = scene


func prewarm_permanent_small_ui_scenes(generation: int = -1) -> bool:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return false
	if _permanent_ui_prewarmed and _are_permanent_small_ui_scenes_cached():
		return true
	_permanent_ui_prewarmed = false
	_permanent_ui_prewarm_error = ""
	_permanent_ui_prewarm_generation = request_generation
	var prewarm_token := _permanent_ui_prewarm_token
	_permanent_ui_prewarm_in_progress = true
	_ensure_permanent_ui_scene_requests(request_generation)
	var deadline_msec := Time.get_ticks_msec() + UI_SCOPE_READY_TIMEOUT_MSEC
	var tree := get_tree()
	while true:
		if not is_generation_current(request_generation):
			break
		if prewarm_token != _permanent_ui_prewarm_token:
			break
		if _are_permanent_small_ui_scenes_cached():
			break
		if not _has_pending_ui_scene_requests(UI_SCENE_REQUEST_KIND_PERMANENT):
			break
		if Time.get_ticks_msec() > deadline_msec:
			_permanent_ui_prewarm_error = "永久 UI 预热超时（%d ms）。" % UI_SCOPE_READY_TIMEOUT_MSEC
			break
		if tree == null:
			break
		await tree.process_frame
	_refresh_permanent_ui_prewarm_state()
	if prewarm_token != _permanent_ui_prewarm_token:
		return false
	if not is_generation_current(request_generation):
		return false
	if not _permanent_ui_prewarm_error.is_empty():
		return false
	return _are_permanent_small_ui_scenes_cached()


# -----------------------------------------------------------------------------
# UI 作用域与统一线程请求经理
# -----------------------------------------------------------------------------


## 场景切换入口：定位作用域，切掉旧作用域强引用，再异步预热当前作用域与永久小 UI。
## 同 scope、同运行时代次、同路径的重复调用幂等：不丢弃、不重置已有任务与缓存。
func begin_ui_scope(target_path: String) -> void:
	if target_path.is_empty():
		# 空目标不是合法场景请求；保持当前作用域，避免误清空已预热缓存。
		return
	var next_scope_name := _resolve_ui_scope_name(target_path)
	var next_paths := _collect_ui_scope_paths(next_scope_name)
	var next_generation := get_runtime_generation()
	if (
		next_scope_name == _ui_scope_name
		and next_generation == _ui_scope_generation
		and _same_ui_scope_paths(next_paths, _ui_scope_paths)
	):
		_ui_scope_target_scene = target_path
		_ensure_permanent_ui_scene_requests(next_generation)
		_ensure_ui_scope_scene_requests()
		_prioritize_ui_scope_requests()
		return
	var same_scope := next_scope_name != UI_SCOPE_NONE and next_scope_name == _ui_scope_name
	_ui_scope_token += 1
	var scope_token := _ui_scope_token
	_retarget_ui_scope_requests(next_paths, scope_token, next_generation)
	_ui_scope_target_scene = target_path
	_ui_scope_name = next_scope_name
	_ui_scope_paths = next_paths
	_ui_scope_generation = next_generation
	_ui_scope_error = ""
	_ui_scope_failed_paths.clear()
	if not same_scope:
		_ui_scope_scene_cache.clear()
	# 固定 UI 场景只能由当前作用域持有；清掉历史残留，避免跨作用域串缓存。
	_purge_ui_scope_paths_from_resource_cache()
	# 永久小 UI 独立于场景作用域，切换作用域时不释放。
	_permanent_ui_prewarm_generation = next_generation
	_ensure_permanent_ui_scene_requests(next_generation)
	_ensure_ui_scope_scene_requests()
	_prioritize_ui_scope_requests()
	_ensure_ui_request_processing()


## 等待当前作用域全部必需路径缓存完成；失败或令牌/代次改变返回 false。
func wait_ui_scope_ready() -> bool:
	if _ui_scope_paths.is_empty():
		return true
	var scope_token := _ui_scope_token
	var runtime_generation := get_runtime_generation()
	var deadline_msec := Time.get_ticks_msec() + UI_SCOPE_READY_TIMEOUT_MSEC
	var tree := get_tree()
	if tree == null:
		_set_ui_scope_error_if_empty("UI 作用域等待失败：ResourceRuntime 不在场景树中。")
		return false
	while is_instance_valid(self):
		if scope_token != _ui_scope_token:
			return false
		if not is_generation_current(runtime_generation):
			return false
		if not _ui_scope_error.is_empty() or not _ui_scope_failed_paths.is_empty():
			return false
		if _are_ui_scope_scenes_cached():
			return true
		if Time.get_ticks_msec() > deadline_msec:
			_set_ui_scope_error_if_empty("UI 作用域预热超时（%d ms）。" % UI_SCOPE_READY_TIMEOUT_MSEC)
			return false
		_ensure_ui_scope_scene_requests()
		_prioritize_ui_scope_requests()
		if not _has_pending_ui_scope_requests():
			# 无在途/排队请求却仍缺路径：明确失败，绝不把缺失当通过。
			_set_ui_scope_error_if_empty("UI 作用域等待结束但仍有场景未缓存。")
			return false
		await tree.process_frame
	return false


## 外部线程阶段立即上锁：先禁止新开请求，再由调用方 await idle，避免等待窗口内的竞态。
func begin_ui_preload_pause() -> void:
	_ui_preload_pause_count += 1


## 结束一层暂停；嵌套计数归零后才安全恢复请求经理的启动能力。
func end_ui_preload_pause() -> void:
	if _ui_preload_pause_count <= 0:
		return
	_ui_preload_pause_count -= 1
	if _ui_preload_pause_count > 0:
		return
	_ensure_ui_request_processing()


## 仅等待已启动（LOADING）的 UI 请求收尾，含被 scope/generation 取消的孤儿请求；
## 不等待排队项，避免与外部 UI waiter 互等。节点离开树/无树时直接返回，不阻塞退出。
func wait_ui_preload_idle() -> void:
	while is_inside_tree():
		if is_threaded_preload_idle():
			return
		var tree := get_tree()
		if tree == null:
			return
		await tree.process_frame


## 已启动请求（UI manager/legacy 预载）是否全部收尾；不含排队项，保持迁移前语义。
func is_threaded_preload_idle() -> bool:
	return (
		_count_ui_scene_requests_in_state(UI_SCENE_REQUEST_STATE_LOADING) == 0
		and _active_thread_load_job == null
		and _thread_load_queue.is_empty()
	)


## 只读诊断：未收尾的线程加载作业数（含排队与运行中）。
func get_in_progress_thread_load_count() -> int:
	var count := 0
	for job_value in _thread_load_jobs.values():
		if (job_value as ThreadLoadJob).state == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			count += 1
	if _active_thread_load_job != null and _active_thread_load_job.abandoned:
		count += 1
	return count


func _wait_ui_preload_idle_for_generation(generation: int, epoch: int) -> bool:
	while is_inside_tree():
		if epoch != _legacy_preload_epoch:
			return false
		if not is_generation_current(generation):
			return false
		if is_threaded_preload_idle():
			return true
		var tree := get_tree()
		if tree == null:
			return false
		await tree.process_frame
	return false


func _is_legacy_preload_current(generation: int, epoch: int) -> bool:
	return epoch == _legacy_preload_epoch and is_generation_current(generation)


func _enqueue_legacy_preload_waiter(generation: int) -> Dictionary:
	_legacy_preload_waiter_next_id += 1
	var waiter := {
		"id": _legacy_preload_waiter_next_id,
		"generation": generation,
		"epoch": _legacy_preload_epoch,
	}
	_legacy_preload_waiters.append(waiter)
	return waiter


func _is_legacy_preload_waiter_current(waiter: Dictionary) -> bool:
	if int(waiter.get("epoch", -1)) != _legacy_preload_epoch:
		return false
	return is_generation_current(int(waiter.get("generation", -1)))


func _remove_legacy_preload_waiter(waiter_id: int) -> void:
	for index in range(_legacy_preload_waiters.size() - 1, -1, -1):
		var queued: Dictionary = _legacy_preload_waiters[index]
		if int(queued.get("id", 0)) == waiter_id:
			_legacy_preload_waiters.remove_at(index)


## 从队首取当前代次 waiter；过期/清态 waiter 直接剔除，避免阻塞新请求。
func _take_next_current_legacy_preload_waiter() -> Dictionary:
	while not _legacy_preload_waiters.is_empty():
		var queued: Dictionary = _legacy_preload_waiters[0]
		if _is_legacy_preload_waiter_current(queued):
			return queued
		_legacy_preload_waiters.pop_front()
	return {}


## 非阻塞排队：逐帧 await，持有者代次过期时由 impl/代次检查尽快释放，新代次不会被永久阻塞。
func _wait_legacy_preload_turn(waiter: Dictionary) -> bool:
	var waiter_id := int(waiter.get("id", 0))
	while is_inside_tree():
		if not _is_legacy_preload_waiter_current(waiter):
			_remove_legacy_preload_waiter(waiter_id)
			return false
		if _legacy_preload_lock_owner_id == waiter_id:
			return true
		if _legacy_preload_lock_owner_id == 0:
			var next_waiter := _take_next_current_legacy_preload_waiter()
			if int(next_waiter.get("id", 0)) == waiter_id:
				_legacy_preload_lock_owner_id = waiter_id
				return true
		var tree := get_tree()
		if tree == null:
			_remove_legacy_preload_waiter(waiter_id)
			return false
		await tree.process_frame
	_remove_legacy_preload_waiter(waiter_id)
	return false


func _release_legacy_preload_turn(waiter_id: int) -> void:
	if _legacy_preload_lock_owner_id == waiter_id:
		_legacy_preload_lock_owner_id = 0
	_remove_legacy_preload_waiter(waiter_id)


## 非阻塞取消当前 UI 作用域：清空 scope 强引用、切到空作用域并推进 token。
## 已启动的 scope 线程请求转孤儿继续轮询到完成并丢弃；永久 UI 与其他缓存不受影响。
func clear_ui_scope() -> void:
	var next_generation := get_runtime_generation()
	_ui_scope_token += 1
	var empty_paths: Array[String] = []
	_retarget_ui_scope_requests(empty_paths, _ui_scope_token, next_generation)
	_ui_scope_name = UI_SCOPE_NONE
	_ui_scope_target_scene = ""
	_ui_scope_generation = next_generation
	_ui_scope_paths.clear()
	_ui_scope_scene_cache.clear()
	_ui_scope_failed_paths.clear()
	_ui_scope_error = ""
	_purge_ui_scope_paths_from_resource_cache()
	if not _ui_scene_requests.is_empty():
		_ensure_ui_request_processing()


## 当前作用域存在未完成、失败或尚未启动的路径时为 true；空作用域返回 false。
func has_ui_scope_pending() -> bool:
	if _ui_scope_paths.is_empty():
		return false
	if not _ui_scope_error.is_empty() or not _ui_scope_failed_paths.is_empty():
		return true
	return not _are_ui_scope_scenes_cached()


## 仅当前作用域拥有的固定 UI 路径返回 true；永久小 UI 不在此列。
func is_ui_scope_scene_path(path: String) -> bool:
	if path.is_empty() or _ui_scope_paths.is_empty():
		return false
	return path in _ui_scope_paths


## 只读快照：返回副本，不暴露内部字典/数组引用。
func get_ui_scope_snapshot() -> Dictionary:
	var paths: Array[String] = []
	var cached_paths: Array[String] = []
	var missing_paths: Array[String] = []
	for path in _ui_scope_paths:
		paths.append(path)
		if _has_valid_ui_scope_scene(path):
			cached_paths.append(path)
		else:
			missing_paths.append(path)
	var failed_paths: Array[String] = []
	for path_value in _ui_scope_failed_paths.keys():
		failed_paths.append(str(path_value))
	failed_paths.sort()
	var state := _get_ui_scope_state()
	return {
		"scope": _ui_scope_name,
		"target_scene": _ui_scope_target_scene,
		"token": _ui_scope_token,
		"generation": _ui_scope_generation,
		"runtime_generation": get_runtime_generation(),
		"paths": paths,
		"cached_paths": cached_paths,
		"missing_paths": missing_paths,
		"failed_paths": failed_paths,
		"failed_reasons": _ui_scope_failed_paths.duplicate(true),
		"pending_count": _count_ui_scope_requests(_ui_scope_token, UI_SCENE_REQUEST_STATE_LOADING),
		"queued_count": _count_ui_scope_requests(_ui_scope_token, UI_SCENE_REQUEST_STATE_QUEUED),
		"cancelled_request_count": _count_ui_scope_requests(0, UI_SCENE_REQUEST_STATE_LOADING),
		"state": state,
		"ready": state == "ready",
		"error": _ui_scope_error,
		"permanent_prewarm_in_progress": _permanent_ui_prewarm_in_progress,
		"permanent_prewarmed": _permanent_ui_prewarmed,
		"permanent_prewarm_error": _permanent_ui_prewarm_error,
		"permanent_pending_count":
		_count_ui_scene_requests(UI_SCENE_REQUEST_KIND_PERMANENT, UI_SCENE_REQUEST_STATE_LOADING),
		"permanent_queued_count":
		_count_ui_scene_requests(UI_SCENE_REQUEST_KIND_PERMANENT, UI_SCENE_REQUEST_STATE_QUEUED),
	}


func _resolve_ui_scope_name(target_path: String) -> String:
	if target_path.is_empty():
		return UI_SCOPE_NONE
	if target_path.begins_with(UI_SCOPE_MAP_SCENE_PREFIX):
		return UI_SCOPE_MAP
	if target_path == UI_SCOPE_MAIN_MENU_SCENE_PATH:
		return UI_SCOPE_ARCHIVE
	if (
		target_path.begins_with(UI_SCOPE_BATTLE_SCENE_PREFIX)
		and not (target_path in UI_SCOPE_BATTLE_EXCLUDED_SCENE_PATHS)
	):
		return UI_SCOPE_BATTLE
	return UI_SCOPE_NONE


func _collect_ui_scope_paths(scope_name: String) -> Array[String]:
	var source: Array = []
	if scope_name == UI_SCOPE_ARCHIVE:
		source = UI_SCOPE_ARCHIVE_SCENE_PATHS
	elif scope_name == UI_SCOPE_MAP:
		source = UI_SCOPE_MAP_SCENE_PATHS
	elif scope_name == UI_SCOPE_BATTLE:
		source = UI_SCOPE_BATTLE_SCENE_PATHS
	var paths: Array[String] = []
	for path_value in source:
		paths.append(str(path_value))
	return paths


func _same_ui_scope_paths(left: Array[String], right: Array[String]) -> bool:
	if left.size() != right.size():
		return false
	for index in range(left.size()):
		if left[index] != right[index]:
			return false
	return true


func _belongs_to_any_ui_scope(path: String) -> bool:
	if path.is_empty():
		return false
	if path in UI_SCOPE_ARCHIVE_SCENE_PATHS:
		return true
	if path in UI_SCOPE_MAP_SCENE_PATHS:
		return true
	return path in UI_SCOPE_BATTLE_SCENE_PATHS


func _get_ui_scope_state() -> String:
	if _ui_scope_paths.is_empty():
		return "none"
	if not _ui_scope_error.is_empty() or not _ui_scope_failed_paths.is_empty():
		return "failed"
	if _are_ui_scope_scenes_cached():
		return "ready"
	return "loading"


func _are_ui_scope_scenes_cached() -> bool:
	for path in _ui_scope_paths:
		if not _has_valid_ui_scope_scene(path):
			return false
	return true


func _has_valid_ui_scope_scene(path: String) -> bool:
	var value: Variant = _ui_scope_scene_cache.get(path)
	if is_valid_packed_scene(value):
		return true
	if _ui_scope_scene_cache.has(path):
		_ui_scope_scene_cache.erase(path)
	return false


func _has_valid_permanent_scene(path: String) -> bool:
	var value: Variant = _permanent_small_ui_scene_cache.get(path)
	if is_valid_packed_scene(value):
		return true
	if _permanent_small_ui_scene_cache.has(path):
		_permanent_small_ui_scene_cache.erase(path)
	# 兼容旧 load_scene 路径：永久 UI 也允许从 _resource_cache 认领。
	var cached_scene: Variant = _resource_cache.get(path)
	if is_valid_packed_scene(cached_scene):
		_permanent_small_ui_scene_cache[path] = cached_scene
		return true
	return false


func _are_permanent_small_ui_scenes_cached() -> bool:
	for path_value in PERMANENT_SMALL_UI_SCENE_PATHS:
		if not _has_valid_permanent_scene(str(path_value)):
			return false
	return true


func _ensure_ui_scope_scene_requests() -> void:
	if _ui_scope_paths.is_empty():
		return
	for path in _ui_scope_paths:
		if _ui_scope_failed_paths.has(path):
			continue
		if _has_valid_ui_scope_scene(path):
			continue
		_schedule_ui_scene_request(path, UI_SCENE_REQUEST_KIND_SCOPE, _ui_scope_token, _ui_scope_generation)


## 让当前永久请求代次失效：排队项直接丢弃；已启动项只摘除回写资格并继续轮询收尾。
func _cancel_pending_permanent_ui_requests() -> void:
	var queued_to_drop: Array[String] = []
	for path_value in _ui_scene_requests.keys():
		var path := str(path_value)
		var record: Dictionary = _ui_scene_requests[path]
		if str(record.get("kind", "")) != UI_SCENE_REQUEST_KIND_PERMANENT:
			continue
		if int(record.get("state", UI_SCENE_REQUEST_STATE_QUEUED)) == UI_SCENE_REQUEST_STATE_QUEUED:
			queued_to_drop.append(path)
		else:
			record["permanent_token"] = -1
	for path in queued_to_drop:
		_ui_scene_requests.erase(path)
		_ui_scene_request_queue.erase(path)
	if not _ui_scene_requests.is_empty():
		_ensure_ui_request_processing()


## 固定 UI 场景只允许由作用域字典持有；清掉 _resource_cache 中的历史残留 key。
## 只按固定 scope 表精确删除，不触碰永久 UI 与其他资源类型。
func _purge_ui_scope_paths_from_resource_cache() -> void:
	for path_value in UI_SCOPE_ARCHIVE_SCENE_PATHS:
		_resource_cache.erase(str(path_value))
	for path_value in UI_SCOPE_MAP_SCENE_PATHS:
		_resource_cache.erase(str(path_value))
	for path_value in UI_SCOPE_BATTLE_SCENE_PATHS:
		_resource_cache.erase(str(path_value))


## 把当前作用域待启动请求稳定排到队列最前；已在途请求不受影响。
func _prioritize_ui_scope_requests() -> void:
	if _ui_scene_request_queue.size() < 2:
		return
	var priority_paths: Array[String] = []
	var deferred_paths: Array[String] = []
	for path in _ui_scene_request_queue:
		var record: Variant = _ui_scene_requests.get(path)
		var is_current_scope := false
		if record is Dictionary:
			var record_dict: Dictionary = record
			is_current_scope = (
				str(record_dict.get("kind", "")) == UI_SCENE_REQUEST_KIND_SCOPE
				and int(record_dict.get("token", 0)) == _ui_scope_token
			)
		if is_current_scope:
			priority_paths.append(path)
		else:
			deferred_paths.append(path)
	if priority_paths.is_empty():
		return
	var reordered: Array[String] = []
	reordered.append_array(priority_paths)
	reordered.append_array(deferred_paths)
	_ui_scene_request_queue = reordered


func _ensure_permanent_ui_scene_requests(generation: int) -> void:
	# 永久 UI 失败已上报 owner；场景切换不逐帧重试，显式 prewarm 调用才重试。
	if not _permanent_ui_prewarm_error.is_empty():
		return
	for path_value in PERMANENT_SMALL_UI_SCENE_PATHS:
		var path := str(path_value)
		if _has_valid_permanent_scene(path):
			continue
		_schedule_ui_scene_request(path, UI_SCENE_REQUEST_KIND_PERMANENT, 0, generation)


func _refresh_permanent_ui_prewarm_state() -> void:
	var pending := _has_pending_ui_scene_requests(UI_SCENE_REQUEST_KIND_PERMANENT)
	_permanent_ui_prewarm_in_progress = pending
	if pending:
		return
	if not _are_permanent_small_ui_scenes_cached():
		return
	# 代次已过期时只保留已加载资源，不把过期协程记成预热成功。
	if not is_generation_current(_permanent_ui_prewarm_generation):
		return
	_permanent_ui_prewarm_error = ""
	_permanent_ui_prewarmed = true


## 旧作用域已开始的请求继续轮询到完成并取回丢弃；新作用域需要的同路径请求
## 明确转让给新 token/generation 后交接，避免重复发起。
func _retarget_ui_scope_requests(next_paths: Array[String], scope_token: int, generation: int) -> void:
	var queued_to_drop: Array[String] = []
	for path_value in _ui_scene_requests.keys():
		var path := str(path_value)
		var record: Dictionary = _ui_scene_requests[path]
		if str(record.get("kind", "")) != UI_SCENE_REQUEST_KIND_SCOPE:
			continue
		if path in next_paths:
			record["token"] = scope_token
			record["generation"] = generation
			continue
		if int(record.get("state", UI_SCENE_REQUEST_STATE_QUEUED)) == UI_SCENE_REQUEST_STATE_QUEUED:
			queued_to_drop.append(path)
		else:
			record["token"] = 0
	for path in queued_to_drop:
		_ui_scene_requests.erase(path)
		_ui_scene_request_queue.erase(path)


func _schedule_ui_scene_request(path: String, kind: String, scope_token: int, generation: int) -> void:
	if path.is_empty():
		return
	if _ui_scene_requests.has(path):
		var existing: Dictionary = _ui_scene_requests[path]
		if str(existing.get("kind", "")) != kind:
			return
		if kind == UI_SCENE_REQUEST_KIND_PERMANENT:
			if is_generation_current(generation):
				existing["generation"] = generation
			if int(existing.get("permanent_token", -1)) != _permanent_ui_prewarm_token:
				existing["permanent_token"] = _permanent_ui_prewarm_token
		elif scope_token != 0 and int(existing.get("token", 0)) == 0:
			existing["token"] = scope_token
			existing["generation"] = generation
		return
	if _try_adopt_cached_ui_scene(path, kind, scope_token):
		return
	_ui_scene_requests[path] = {
		"state": UI_SCENE_REQUEST_STATE_QUEUED,
		"kind": kind,
		"token": scope_token,
		"permanent_token": _permanent_ui_prewarm_token if kind == UI_SCENE_REQUEST_KIND_PERMANENT else -1,
		"generation": generation,
		"error": "",
	}
	_ui_scene_request_queue.append(path)
	if kind == UI_SCENE_REQUEST_KIND_PERMANENT:
		_permanent_ui_prewarm_in_progress = true
		_permanent_ui_prewarmed = false
	_ensure_ui_request_processing()


func _try_adopt_cached_ui_scene(path: String, kind: String, scope_token: int) -> bool:
	if kind == UI_SCENE_REQUEST_KIND_PERMANENT:
		if _has_valid_permanent_scene(path):
			return true
		var engine_permanent := _get_engine_cached_packed_scene(path)
		if engine_permanent != null:
			_permanent_small_ui_scene_cache[path] = engine_permanent
			_resource_cache[path] = engine_permanent
			return true
		return false
	if _has_valid_ui_scope_scene(path):
		return true
	if scope_token != _ui_scope_token:
		return false
	if not is_generation_current(_ui_scope_generation):
		return false
	var cached_scene: Variant = _resource_cache.get(path)
	if not is_valid_packed_scene(cached_scene):
		if _resource_cache.has(path):
			_resource_cache.erase(path)
		cached_scene = null
	var engine_scene := _get_engine_cached_packed_scene(path)
	if engine_scene != null:
		cached_scene = engine_scene
	if not is_valid_packed_scene(cached_scene):
		return false
	_ui_scope_scene_cache[path] = cached_scene
	_resource_cache.erase(path)
	return true


func _get_engine_cached_packed_scene(path: String) -> PackedScene:
	if not ResourceLoader.has_cached(path):
		return null
	var cached_scene: Variant = ResourceLoader.get_cached_ref(path)
	if not is_valid_packed_scene(cached_scene):
		return null
	return cached_scene as PackedScene


func _poll_ui_scene_requests() -> void:
	if _ui_scene_requests.is_empty():
		return
	var request_paths: Array = _ui_scene_requests.keys()
	for path_value in request_paths:
		var path := str(path_value)
		if not _ui_scene_requests.has(path):
			continue
		var record: Dictionary = _ui_scene_requests[path]
		if int(record.get("state", UI_SCENE_REQUEST_STATE_QUEUED)) != UI_SCENE_REQUEST_STATE_LOADING:
			continue
		var status := get_thread_load_state(int(record.get("job_id", 0)))
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			_resolve_loaded_ui_scene(path, record)
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			_fail_ui_scene_request(path, record, "线程加载失败")
		elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_resolve_invalid_ui_scene(path, record)


func _resolve_loaded_ui_scene(path: String, record: Dictionary) -> void:
	var resource := take_thread_load_resource(int(record.get("job_id", 0)))
	_complete_ui_scene_request(path, record, resource)


func _resolve_invalid_ui_scene(path: String, record: Dictionary) -> void:
	_fail_ui_scene_request(path, record, "线程加载状态无效（请求未成功建立）")


func _fill_ui_scene_request_slots() -> void:
	if _ui_preload_pause_count > 0:
		return
	var limit := 1
	var loading := _count_ui_scene_requests_in_state(UI_SCENE_REQUEST_STATE_LOADING)
	while loading < limit and not _ui_scene_request_queue.is_empty():
		var path := str(_ui_scene_request_queue.pop_front())
		if not _ui_scene_requests.has(path):
			continue
		var record: Dictionary = _ui_scene_requests[path]
		if int(record.get("state", UI_SCENE_REQUEST_STATE_QUEUED)) != UI_SCENE_REQUEST_STATE_QUEUED:
			continue
		var kind := str(record.get("kind", ""))
		if _try_adopt_cached_ui_scene(path, kind, int(record.get("token", 0))):
			_ui_scene_requests.erase(path)
			continue
		var job_id := start_thread_load(path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
		if job_id > 0:
			record["job_id"] = job_id
			record["state"] = UI_SCENE_REQUEST_STATE_LOADING
			loading += 1
		else:
			_fail_ui_scene_request(path, record, "线程加载请求被拒绝")


func _complete_ui_scene_request(path: String, record: Dictionary, resource: Variant) -> void:
	_ui_scene_requests.erase(path)
	_ui_scene_request_queue.erase(path)
	var kind := str(record.get("kind", ""))
	if kind == UI_SCENE_REQUEST_KIND_PERMANENT:
		if int(record.get("permanent_token", -1)) != _permanent_ui_prewarm_token:
			return
		if not is_generation_current(int(record.get("generation", -1))):
			return
		if is_valid_packed_scene(resource):
			_permanent_small_ui_scene_cache[path] = resource
			_resource_cache[path] = resource
		else:
			_permanent_ui_prewarm_error = "永久 UI 场景线程结果类型无效：%s" % path
		return
	if not _is_ui_scope_record_current(record):
		return
	if not is_valid_packed_scene(resource):
		_record_ui_scope_failure(path, "线程加载结果不是有效的 PackedScene")
		return
	_ui_scope_scene_cache[path] = resource
	_ui_scope_failed_paths.erase(path)


func _fail_ui_scene_request(path: String, record: Dictionary, message: String) -> void:
	take_thread_load_resource(int(record.get("job_id", 0)))
	_ui_scene_requests.erase(path)
	_ui_scene_request_queue.erase(path)
	var kind := str(record.get("kind", ""))
	if kind == UI_SCENE_REQUEST_KIND_PERMANENT:
		if int(record.get("permanent_token", -1)) != _permanent_ui_prewarm_token:
			return
		if is_generation_current(int(record.get("generation", -1))):
			_permanent_ui_prewarm_error = "%s：%s" % [path, message]
		return
	if _is_ui_scope_record_current(record):
		_record_ui_scope_failure(path, message)


func _record_ui_scope_failure(path: String, message: String) -> void:
	_ui_scope_failed_paths[path] = message
	_set_ui_scope_error_if_empty("UI 作用域场景加载失败：%s（%s）" % [path, message])


func _set_ui_scope_error_if_empty(message: String) -> void:
	if _ui_scope_error.is_empty():
		_ui_scope_error = message


func _is_ui_scope_record_current(record: Dictionary) -> bool:
	var scope_token := int(record.get("token", 0))
	if scope_token == 0 or scope_token != _ui_scope_token:
		return false
	var record_generation := int(record.get("generation", -1))
	if record_generation != _ui_scope_generation:
		return false
	return is_generation_current(record_generation)


func _has_pending_ui_scene_requests(kind: String) -> bool:
	for record in _ui_scene_requests.values():
		if str(record.get("kind", "")) != kind:
			continue
		if (
			kind == UI_SCENE_REQUEST_KIND_PERMANENT
			and int(record.get("permanent_token", -1)) != _permanent_ui_prewarm_token
		):
			continue
		return true
	return false


func _has_pending_ui_scope_requests() -> bool:
	for record in _ui_scene_requests.values():
		if str(record.get("kind", "")) != UI_SCENE_REQUEST_KIND_SCOPE:
			continue
		if int(record.get("token", 0)) != _ui_scope_token:
			continue
		return true
	return false


func _count_ui_scene_requests(kind: String, state: int) -> int:
	var count := 0
	for record in _ui_scene_requests.values():
		if str(record.get("kind", "")) != kind:
			continue
		if (
			kind == UI_SCENE_REQUEST_KIND_PERMANENT
			and int(record.get("permanent_token", -1)) != _permanent_ui_prewarm_token
		):
			continue
		if int(record.get("state", -1)) != state:
			continue
		count += 1
	return count


func _count_ui_scope_requests(scope_token: int, state: int) -> int:
	var count := 0
	for record in _ui_scene_requests.values():
		if str(record.get("kind", "")) != UI_SCENE_REQUEST_KIND_SCOPE:
			continue
		if int(record.get("token", -1)) != scope_token:
			continue
		if int(record.get("state", -1)) != state:
			continue
		count += 1
	return count


func _count_ui_scene_requests_in_state(state: int) -> int:
	var count := 0
	for record in _ui_scene_requests.values():
		if int(record.get("state", -1)) == state:
			count += 1
	return count


func _ensure_ui_request_processing() -> void:
	if _thread_load_jobs_shutting_down:
		return
	if not _ui_scene_requests.is_empty() or _has_unsettled_thread_loads():
		set_process(true)


## 清空请求：在途作业转交主线程收尾；真正退出时同步 join 全部线程。
func _abort_ui_scene_requests(shutting_down: bool) -> void:
	_thread_load_jobs_shutting_down = shutting_down
	for record_value in _ui_scene_requests.values():
		retire_thread_load(int((record_value as Dictionary).get("job_id", 0)))
	_ui_scene_requests.clear()
	_ui_scene_request_queue.clear()
	if shutting_down:
		_join_all_thread_load_jobs()
	else:
		_ensure_ui_request_processing()


# -----------------------------------------------------------------------------
# 缓存查询与交接
# -----------------------------------------------------------------------------


func is_resource_cached(path: String) -> bool:
	if path.is_empty():
		return false
	return (
		_permanent_small_ui_scene_cache.has(path)
		or _ui_scope_scene_cache.has(path)
		or _resource_cache.has(path)
		or _sprite_frames_cache.has(path)
		or _audio_cache.has(path)
		or _texture_cache.has(path)
	)


func get_cached_packed_scene(path: String) -> PackedScene:
	if path.is_empty():
		return null
	var permanent_value: Variant = _permanent_small_ui_scene_cache.get(path)
	if is_valid_packed_scene(permanent_value):
		return permanent_value as PackedScene
	var scoped_value: Variant = _ui_scope_scene_cache.get(path)
	if is_valid_packed_scene(scoped_value):
		return scoped_value as PackedScene
	var value: Variant = _resource_cache.get(path)
	if not is_valid_packed_scene(value):
		return null
	return value as PackedScene


func get_cached_sprite_frames(path: String) -> SpriteFrames:
	if path.is_empty():
		return null
	var value: Variant = _sprite_frames_cache.get(path)
	if value is SpriteFrames:
		return value as SpriteFrames
	var res_val: Variant = _resource_cache.get(path)
	if res_val is SpriteFrames:
		return res_val as SpriteFrames
	return null


func handoff_loaded_resource(path: String, resource: Resource, track_level: bool = false) -> bool:
	if path.is_empty() or resource == null:
		return false
	cache_threaded_resource(path, resource)
	if track_level:
		track_level_resource(path)
	return true


func get_cached_audio(path: String) -> AudioStream:
	var resolved_path := path
	if path.ends_with("/effect4.mp3") and not path.begins_with("res://Music/hero/role_7/"):
		resolved_path = path.replace("effect4.mp3", "effect3.mp3")
	if path == "":
		return null
	if not _audio_cache.has(path):
		_audio_cache[path] = load(resolved_path)
	return _audio_cache[path] as AudioStream


func get_cached_texture(path: String) -> Texture2D:
	var resolved_path := path
	if path.ends_with("/mp_poision.png"):
		resolved_path = path.replace("mp_poision.png", "poision.png")
	if path == "":
		return null
	if not _texture_cache.has(path) or _texture_cache[path] == null:
		var texture := load(resolved_path) as Texture2D
		if texture != null:
			_texture_cache[path] = texture
		else:
			_texture_cache.erase(path)
		return texture
	return _texture_cache[path] as Texture2D


func release_cached_texture(path: String) -> void:
	if path == "":
		return
	_texture_cache.erase(path)
	var resolved_path := path
	if resolved_path != path:
		_texture_cache.erase(resolved_path)


func cache_threaded_resource(path: String, resource: Resource) -> void:
	if resource == null:
		return
	if resource is PackedScene or path.ends_with(".tscn") or path.ends_with(".scn"):
		if _belongs_to_any_ui_scope(path):
			# 固定 UI 场景只允许当前作用域持有；非当前作用域不写任何缓存，避免跨作用域残留。
			if is_ui_scope_scene_path(path) and is_valid_packed_scene(resource):
				_ui_scope_scene_cache[path] = resource
			return
		_resource_cache[path] = resource
	elif resource is SpriteFrames:
		_sprite_frames_cache[path] = resource
	elif resource is AudioStream:
		_audio_cache[path] = resource
	elif resource is Texture2D:
		_texture_cache[path] = resource
	else:
		_resource_cache[path] = resource


func release_role_cached_resources() -> void:
	_erase_cached_paths_by_prefix(_resource_cache, ["res://Art/hero_picture/", "res://Scene/hero/"])
	_erase_cached_paths_by_prefix(_sprite_frames_cache, ["res://Art/hero_picture/"])
	_erase_cached_paths_by_prefix(_texture_cache, ["res://Art/hero_picture/"])
	_erase_cached_paths_by_prefix(_audio_cache, ["res://Music/hero/"])


func is_permanent_small_ui_scene_path(path: String) -> bool:
	return path in PERMANENT_SMALL_UI_SCENE_PATHS


func get_cached_scene_paths() -> Array[String]:
	var result: Array[String] = []
	for path_value in _resource_cache.keys():
		result.append(str(path_value))
	return result


func erase_cached_scene(path: String) -> void:
	if path != "":
		_resource_cache.erase(path)


func erase_cached_texture_paths_by_prefix(prefixes: Array) -> void:
	_erase_cached_paths_by_prefix(_texture_cache, prefixes)


func clear_permanent_small_ui_scene_cache() -> void:
	# 永久 UI 双持有于专用字典与 _resource_cache：只移除本所有者登记的 4 个精确 key，
	# 不触碰作用域字典、贴图/音频/SpriteFrames 缓存或其他场景路径。
	_permanent_ui_prewarm_token += 1
	for path_value in PERMANENT_SMALL_UI_SCENE_PATHS:
		_resource_cache.erase(str(path_value))
	_permanent_small_ui_scene_cache.clear()
	_cancel_pending_permanent_ui_requests()
	_permanent_ui_prewarmed = false
	_permanent_ui_prewarm_in_progress = false
	_permanent_ui_prewarm_error = ""


func _erase_cached_paths_by_prefix(cache: Dictionary, prefixes: Array) -> void:
	for path_value in cache.keys():
		var path := str(path_value)
		for prefix in prefixes:
			if path.begins_with(str(prefix)):
				cache.erase(path)
				break


# -----------------------------------------------------------------------------
# 关卡资源租约
# -----------------------------------------------------------------------------


func begin_level_resource_lease(target_scene: String) -> int:
	release_level_resource_lease()
	_level_resource_lease_id += 1
	_level_resource_lease = {
		"id": _level_resource_lease_id,
		"target_scene": target_scene,
		"paths": {},
		"scene_paths": {},
		"monster_scene_paths": {},
		"bullet_scene_paths": {},
		"texture_paths": {},
		"audio_paths": {},
		"warmed_scene_paths": {},
		"prewarmed_monster_ids": {},
	}
	return _level_resource_lease_id


func release_level_resource_lease(lease_id: int = -1) -> int:
	if _level_resource_lease.is_empty():
		return 0
	if lease_id >= 0 and int(_level_resource_lease.get("id", 0)) != lease_id:
		return 0
	var target_scene := str(_level_resource_lease.get("target_scene", ""))
	var paths: Dictionary = _level_resource_lease.get("paths", {})
	var released := 0
	for path_value in paths.keys():
		var path := str(path_value)
		if path.is_empty() or path == target_scene:
			continue
		if path in PERMANENT_SMALL_UI_SCENE_PATHS or _permanent_small_ui_scene_cache.has(path):
			continue
		_resource_cache.erase(path)
		_sprite_frames_cache.erase(path)
		_texture_cache.erase(path)
		_audio_cache.erase(path)
		_monster_scene_cache.erase(path)
		released += 1
	_level_resource_lease = {}
	return released


func is_level_scene_warmed(path: String) -> bool:
	if _level_resource_lease.is_empty():
		return false
	var warmed: Dictionary = _level_resource_lease.get("warmed_scene_paths", {})
	return warmed.has(path)


func mark_level_scene_warmed(path: String) -> void:
	if _level_resource_lease.is_empty():
		return
	var warmed: Dictionary = _level_resource_lease.get("warmed_scene_paths", {})
	warmed[path] = true


func is_level_monster_prewarmed(monster_id: int) -> bool:
	if _level_resource_lease.is_empty():
		return false
	var prewarmed: Dictionary = _level_resource_lease.get("prewarmed_monster_ids", {})
	return prewarmed.has(monster_id)


func mark_level_monster_prewarmed(monster_id: int) -> void:
	if _level_resource_lease.is_empty():
		return
	var prewarmed: Dictionary = _level_resource_lease.get("prewarmed_monster_ids", {})
	prewarmed[monster_id] = true


func track_level_resource(path: String) -> void:
	if path.is_empty() or _level_resource_lease.is_empty():
		return
	var target_scene := str(_level_resource_lease.get("target_scene", ""))
	if path == target_scene:
		return
	var paths: Dictionary = _level_resource_lease.get("paths", {})
	paths[path] = true
	var extension := path.get_extension().to_lower()
	if extension in ["tscn", "scn"]:
		var scene_paths: Dictionary = _level_resource_lease.get("scene_paths", {})
		scene_paths[path] = true
		if path.begins_with("res://Scene/monster/") or path.begins_with("res://Scene/bullet/"):
			var monster_scene_paths: Dictionary = _level_resource_lease.get("monster_scene_paths", {})
			monster_scene_paths[path] = true
			if (
				path.begins_with("res://Scene/bullet/")
				or path.contains("/monster_bullet")
				or path.get_file().to_lower().contains("bullet")
			):
				var bullet_scene_paths: Dictionary = _level_resource_lease.get("bullet_scene_paths", {})
				bullet_scene_paths[path] = true
	elif extension in ["png", "jpg", "jpeg", "webp", "svg"]:
		var texture_paths: Dictionary = _level_resource_lease.get("texture_paths", {})
		texture_paths[path] = true
	elif extension in ["mp3", "ogg", "wav"]:
		var audio_paths: Dictionary = _level_resource_lease.get("audio_paths", {})
		audio_paths[path] = true


func get_dependency_resource_path(dependency: String) -> String:
	var resource_path_start := dependency.find("res://")
	if resource_path_start >= 0:
		return dependency.substr(resource_path_start)
	return dependency


func track_level_scene_dependencies(scene_paths: Array) -> void:
	for scene_path_value in scene_paths:
		var scene_path := str(scene_path_value)
		track_level_resource(scene_path)
		for dependency in ResourceLoader.get_dependencies(scene_path):
			var dependency_path := get_dependency_resource_path(str(dependency))
			track_level_resource(dependency_path)


func get_lease_snapshot() -> Dictionary:
	if _level_resource_lease.is_empty():
		return {
			"active": false,
			"id": 0,
			"target_scene": "",
			"owned_path_count": 0,
			"owned_paths": [],
			"scene_paths": [],
			"monster_scene_paths": [],
			"bullet_scene_paths": [],
			"texture_paths": [],
			"audio_paths": [],
			"warmed_scene_paths": [],
			"prewarmed_monster_ids": [],
		}
	return {
		"active": true,
		"id": int(_level_resource_lease.get("id", 0)),
		"target_scene": str(_level_resource_lease.get("target_scene", "")),
		"owned_path_count": (_level_resource_lease.get("paths", {}) as Dictionary).size(),
		"owned_paths": _lease_path_list(_level_resource_lease.get("paths", {})),
		"scene_paths": _lease_path_list(_level_resource_lease.get("scene_paths", {})),
		"monster_scene_paths": _lease_path_list(_level_resource_lease.get("monster_scene_paths", {})),
		"bullet_scene_paths": _lease_path_list(_level_resource_lease.get("bullet_scene_paths", {})),
		"texture_paths": _lease_path_list(_level_resource_lease.get("texture_paths", {})),
		"audio_paths": _lease_path_list(_level_resource_lease.get("audio_paths", {})),
		"warmed_scene_paths": _lease_path_list(_level_resource_lease.get("warmed_scene_paths", {})),
		"prewarmed_monster_ids": _lease_int_list(_level_resource_lease.get("prewarmed_monster_ids", {})),
	}


func _lease_path_list(value: Variant) -> Array:
	var result: Array = []
	if value is Dictionary:
		for path_value in (value as Dictionary).keys():
			result.append(str(path_value))
	result.sort()
	return result


func _lease_int_list(value: Variant) -> Array:
	var result: Array = []
	if value is Dictionary:
		for int_value in (value as Dictionary).keys():
			result.append(int(int_value))
	result.sort()
	return result


# -----------------------------------------------------------------------------
# 单槽预载
# -----------------------------------------------------------------------------


func preload_next(path: String) -> void:
	if path == "" or (_preloaded_scene != null and _preloaded_scene_path == path):
		return
	if _preloading_path == path:
		var existing_status := get_thread_load_state(_preloading_job_id)
		if (
			existing_status == ResourceLoader.THREAD_LOAD_FAILED
			or existing_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
		):
			clear_preloaded_scene_slot()
		else:
			return
	clear_preloaded_scene_slot()
	if not ResourceLoader.exists(path):
		return
	if _resource_cache.has(path):
		var cached: Variant = _resource_cache[path]
		if cached is PackedScene:
			_preloaded_scene = cached as PackedScene
			_preloaded_scene_path = path
			return
	_preloading_path = path
	_preloading_job_id = start_thread_load(path)
	if _preloading_job_id <= 0:
		_preloading_path = ""


func clear_preloaded_scene_slot() -> void:
	retire_thread_load(_preloading_job_id)
	_preloading_job_id = 0
	_preloaded_scene = null
	_preloaded_scene_path = ""
	_preloading_path = ""


func take_preloaded_scene(path: String) -> PackedScene:
	if _preloaded_scene != null:
		if _preloaded_scene_path == path:
			var ps = _preloaded_scene
			clear_preloaded_scene_slot()
			return ps
		_preloaded_scene = null
		_preloaded_scene_path = ""
	if _preloading_path == path:
		var status := get_thread_load_state(_preloading_job_id)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var ps := take_thread_load_resource(_preloading_job_id) as PackedScene
			_preloading_job_id = 0
			clear_preloaded_scene_slot()
			return ps
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			clear_preloaded_scene_slot()
	return null


func get_preloaded_slot_snapshot() -> Dictionary:
	var state: int = ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	if _preloaded_scene != null:
		state = ResourceLoader.THREAD_LOAD_LOADED
	elif _preloading_job_id > 0:
		state = get_thread_load_state(_preloading_job_id)
	return {
		"path": _preloading_path,
		"ready_path": _preloaded_scene_path,
		"ready": _preloaded_scene != null,
		"state": state,
	}


# -----------------------------------------------------------------------------
# 线程预载与分帧预热
# -----------------------------------------------------------------------------


func preload_paths_threaded(paths: Array, generation: int = -1) -> void:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
	# 先上锁再排队/等 idle，避免等待窗口内启动新请求；所有返回路径统一释放锁与 pause。
	begin_ui_preload_pause()
	var waiter := _enqueue_legacy_preload_waiter(request_generation)
	var waiter_id := int(waiter.get("id", 0))
	var waiter_epoch := int(waiter.get("epoch", -1))
	var acquired: bool = await _wait_legacy_preload_turn(waiter)
	if not acquired:
		end_ui_preload_pause()
		return
	var idle: bool = await _wait_ui_preload_idle_for_generation(request_generation, waiter_epoch)
	if not idle:
		_release_legacy_preload_turn(waiter_id)
		end_ui_preload_pause()
		return
	if _is_legacy_preload_current(request_generation, waiter_epoch):
		_legacy_active_requests.clear()
		await _preload_paths_threaded_impl(paths, request_generation, waiter_epoch)
	_release_legacy_preload_turn(waiter_id)
	end_ui_preload_pause()


func _preload_paths_threaded_impl(paths: Array, request_generation: int, request_epoch: int) -> void:
	var owned_jobs: Array = _legacy_active_requests
	if not _is_legacy_preload_current(request_generation, request_epoch):
		_retire_thread_load_ids(owned_jobs)
		return
	var request_paths: Array[String] = []
	var seen_paths: Dictionary = {}
	for path_value in paths:
		var path := str(path_value)
		if path == "":
			continue
		if (
			_resource_cache.has(path)
			or _sprite_frames_cache.has(path)
			or _audio_cache.has(path)
			or _texture_cache.has(path)
		):
			continue
		if seen_paths.has(path):
			continue
		seen_paths[path] = true
		request_paths.append(path)

	var batch_size := get_threaded_preload_batch_size(request_paths.size())
	var batch_start := 0
	while batch_start < request_paths.size():
		if not _is_legacy_preload_current(request_generation, request_epoch):
			_retire_thread_load_ids(owned_jobs)
			return
		var pending: Array[int] = []
		var pending_paths: Dictionary = {}
		var batch_end := mini(batch_start + batch_size, request_paths.size())
		for index in range(batch_start, batch_end):
			if not _is_legacy_preload_current(request_generation, request_epoch):
				_retire_thread_load_ids(owned_jobs)
				return
			var path := request_paths[index]
			var job_id := start_thread_load(path)
			if job_id > 0:
				owned_jobs.append(job_id)
				pending.append(job_id)
				pending_paths[job_id] = path
			else:
				# 线程无法启动时保持原同步回退路径。
				cache_threaded_resource(path, load(path))
		while not pending.is_empty():
			if not _is_legacy_preload_current(request_generation, request_epoch):
				_retire_thread_load_ids(owned_jobs)
				return
			var i := pending.size() - 1
			while i >= 0:
				var job_id := pending[i]
				var path := str(pending_paths.get(job_id, ""))
				var status := get_thread_load_state(job_id)
				if status == ResourceLoader.THREAD_LOAD_LOADED:
					var resource := take_thread_load_resource(job_id)
					_erase_thread_load_id(owned_jobs, job_id)
					cache_threaded_resource(path, resource)
					pending.remove_at(i)
					pending_paths.erase(job_id)
				elif (
					status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
				):
					take_thread_load_resource(job_id)
					_erase_thread_load_id(owned_jobs, job_id)
					pending.remove_at(i)
					pending_paths.erase(job_id)
				i -= 1
			if not pending.is_empty():
				var tree := get_tree()
				if tree == null:
					_retire_thread_load_ids(owned_jobs)
					return
				await tree.process_frame
				if not _is_legacy_preload_current(request_generation, request_epoch):
					_retire_thread_load_ids(owned_jobs)
					return
		batch_start = batch_end
	# 正常完成时不应残留作业；防御性转交，避免任何早退遗留线程。
	_retire_thread_load_ids(owned_jobs)


func get_threaded_preload_batch_size(request_count: int) -> int:
	if request_count <= 0:
		return 1
	return mini(request_count, 2 if OS.has_feature("mobile") else 4)


func warm_scene_paths_over_frames(paths: Array, per_frame: int = 2, generation: int = -1) -> void:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
	var warmed_this_frame := 0
	for path in paths:
		if not is_generation_current(request_generation):
			return
		var scene_path := str(path)
		if not is_scene_resource_path(scene_path):
			continue
		var scene = load_scene(scene_path)
		if scene != null:
			warm_scene_instance(scene)
			warmed_this_frame += 1
			if warmed_this_frame >= per_frame:
				warmed_this_frame = 0
				var tree := get_tree()
				if tree == null:
					return
				await tree.process_frame
				if not is_generation_current(request_generation):
					return


func warm_scene_instance(scene: PackedScene) -> void:
	if scene == null:
		return
	var node := scene.instantiate()
	if node != null:
		node.free()


func _release_warm_audio_players(players: Array[AudioStreamPlayer]) -> void:
	for player in players:
		if player == null or not is_instance_valid(player):
			continue
		player.stop()
		player.stream = null
		player.free()
	players.clear()


func warm_audio_streams_over_frames(paths: Array, per_frame: int = 2, generation: int = -1) -> void:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
	var players: Array[AudioStreamPlayer] = []
	var batch_size := maxi(1, per_frame)
	for path_value in paths:
		if not is_generation_current(request_generation):
			_release_warm_audio_players(players)
			return
		var stream := get_cached_audio(str(path_value))
		if stream == null:
			continue
		var player := AudioStreamPlayer.new()
		player.volume_db = -80.0
		player.stream = stream
		add_child(player)
		player.play()
		players.append(player)
		if players.size() >= batch_size:
			var tree := get_tree()
			if tree == null:
				_release_warm_audio_players(players)
				return
			await tree.process_frame
			_release_warm_audio_players(players)
			if not is_generation_current(request_generation):
				return
	if not players.is_empty():
		var tree := get_tree()
		if tree == null:
			_release_warm_audio_players(players)
			return
		await tree.process_frame
		_release_warm_audio_players(players)


func warm_texture_rids_over_frames(paths: Array, per_frame: int = 6, generation: int = -1) -> void:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
	var warmed_this_frame := 0
	for path in paths:
		if not is_generation_current(request_generation):
			return
		var texture := get_cached_texture(str(path))
		if texture == null:
			continue
		texture.get_rid()
		warmed_this_frame += 1
		if warmed_this_frame >= per_frame:
			warmed_this_frame = 0
			if DisplayServer.get_name() == "headless":
				var tree := get_tree()
				if tree == null:
					return
				await tree.process_frame
			else:
				await RenderingServer.frame_post_draw
			if not is_generation_current(request_generation):
				return

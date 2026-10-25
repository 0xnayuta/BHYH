class_name FrameTextureRequests
extends RefCounted


## 只持有活跃窗口和未收尾请求；不建立永久纹理缓存。
class Request:
	extends RefCounted
	var owners: int = 1
	var pending: bool = true
	var failed: bool = false
	var texture: Texture2D


static var _requests: Dictionary[String, Request] = {}
static var _poll_scheduled: bool = false
static var _closing: bool = false


static func acquire(path: String) -> bool:
	if _closing:
		push_error("FrameSequence texture requests are closing")
		return false
	if _requests.has(path):
		_requests[path].owners += 1
		return not _requests[path].failed
	var request := Request.new()
	_requests[path] = request
	request.texture = ResourceLoader.get_cached_ref(path) as Texture2D
	if request.texture != null:
		request.pending = false
		return true
	var error := ResourceLoader.load_threaded_request(path, "Texture2D", false, ResourceLoader.CACHE_MODE_REUSE)
	if error != OK:
		request.pending = false
		request.failed = true
		push_error("FrameSequence texture request failed: " + path)
		return false
	_schedule_poll()
	return true


static func get_texture(path: String) -> Texture2D:
	var request: Request = _requests.get(path)
	return request.texture if request != null else null


static func has_failed(path: String) -> bool:
	var request: Request = _requests.get(path)
	return request == null or request.failed


static func release(path: String) -> void:
	var request: Request = _requests.get(path)
	if request == null:
		return
	request.owners -= 1
	if request.owners == 0 and not request.pending:
		_requests.erase(path)
	elif request.pending:
		_schedule_poll()


static func pending_count() -> int:
	var count := 0
	for request: Request in _requests.values():
		if request.pending:
			count += 1
	return count


static func retained_count() -> int:
	return _requests.size()


static func _schedule_poll() -> void:
	if _poll_scheduled:
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		push_error("FrameSequence texture requests require SceneTree")
		return
	_poll_scheduled = true
	tree.process_frame.connect(_poll, CONNECT_ONE_SHOT)


static func _poll() -> void:
	_poll_scheduled = false
	var still_pending := false
	for path: String in _requests.keys():
		var request: Request = _requests[path]
		if not request.pending:
			continue
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			still_pending = true
			continue
		request.pending = false
		if status in [ResourceLoader.THREAD_LOAD_LOADED, ResourceLoader.THREAD_LOAD_FAILED]:
			request.texture = ResourceLoader.load_threaded_get(path) as Texture2D
		request.failed = request.texture == null
		if request.failed:
			push_error("FrameSequence texture load failed: " + path)
		if request.owners == 0:
			_requests.erase(path)
	if still_pending:
		_schedule_poll()


static func shutdown_process() -> void:
	# 仅进程关闭收尾允许等待；关卡退出始终跨帧归还租约。
	_closing = true
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null and tree.process_frame.is_connected(_poll):
		tree.process_frame.disconnect(_poll)
	_poll_scheduled = false
	for path: String in _requests.keys():
		var request: Request = _requests[path]
		if request.pending:
			var status := ResourceLoader.load_threaded_get_status(path)
			if (
				status
				in [
					ResourceLoader.THREAD_LOAD_IN_PROGRESS,
					ResourceLoader.THREAD_LOAD_LOADED,
					ResourceLoader.THREAD_LOAD_FAILED
				]
			):
				ResourceLoader.load_threaded_get(path)
	_requests.clear()

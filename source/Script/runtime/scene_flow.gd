class_name SceneFlow
extends Node

## 场景切换流、目标场景状态与请求代次守卫。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码通过 Global.change_scene() 正式入口发起场景切换。

var _host
var target_scene: String = ""
var _scene_request_generation: int = 0


func setup(host: Node) -> void:
	_host = host


func get_scene_request_generation() -> int:
	return _scene_request_generation


func is_scene_request_current(generation: int) -> bool:
	return generation == _scene_request_generation


func is_valid_scene_change_target(target_path: String) -> bool:
	if target_path.is_empty():
		return false
	if not (target_path.ends_with(".tscn") or target_path.ends_with(".scn")):
		return false
	return ResourceLoader.exists(target_path)


func clear_runtime_state() -> void:
	_scene_request_generation += 1
	target_scene = ""


func change_scene(target, force_loading_screen: bool = false, require_archive_session: bool = true) -> bool:
	var target_path := str(target)
	if not is_valid_scene_change_target(target_path):
		push_warning("change_scene rejected invalid target: %s" % target_path)
		return false
	if (
		require_archive_session
		and target_path.begins_with("res://Scene/level/")
		and not _host.is_archive_session_active()
	):
		push_warning("change_scene rejected level target without archive session: %s" % target_path)
		return false

	var tree := get_tree()
	if tree == null:
		return false

	_scene_request_generation += 1
	_host._advance_runtime_generation()
	var exiting_archive: bool = _host.is_archive_exit_scene(target_path)
	# 先让面板关闭保存走完，再撤销会话上下文；end 之后的保存请求一律拒绝。
	_host.get_ui_runtime().cleanup_transient_ui()
	if exiting_archive:
		_host.end_archive_session()
	_host.get_ui_runtime().release_ui_runtime_cache(exiting_archive)

	_host.clear_level_resource_cache()
	_host.get_resource_runtime().begin_level_resource_lease(target_path)

	var cached = _host.get_resource_runtime().take_preloaded_scene(target_path)
	if cached == null:
		_host.get_resource_runtime().clear_preloaded_scene_slot()
	target_scene = target_path

	if (
		not force_loading_screen
		and cached != null
		and target_path.begins_with("res://Scene/level/")
		and target_path != "res://Scene/level/level_hdzm.tscn"
	):
		var fast_err := tree.change_scene_to_packed(cached)
		return fast_err == OK

	var load_err := tree.change_scene_to_file("res://Scene/other_scene/load_scene.tscn")
	return load_err == OK

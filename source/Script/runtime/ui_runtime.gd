class_name UiRuntime
extends Node

## UI 宿主、弹出层、临时 UI 登记与 UI 实例缓存。
## 由 Global 作为普通子节点持有，不是 Autoload；add_* 工厂仍留在 Global，
## 但工厂必须通过 Global.get_ui_runtime() 使用本服务的生命周期 API。

var _host
var windows: Node = null
var _windows_stack: Array[Node] = []

var _ui_popup_layer: CanvasLayer = null
var _active_hover_popup: Node = null
var _cleanup_transient_ui_active := false
var _ui_runtime_instance_paths: Dictionary = {}
var _ui_runtime_instance_counts: Dictionary = {}
var _transient_ui_instances: Dictionary = {}


func setup(host: Node) -> void:
	_host = host


func push_windows(host: Node) -> void:
	_windows_stack.append(windows)
	windows = host


func pop_windows() -> void:
	if _windows_stack.is_empty():
		windows = null
		return
	windows = _windows_stack.pop_back()


func get_popup_layer() -> CanvasLayer:
	if _ui_popup_layer != null and is_instance_valid(_ui_popup_layer):
		return _ui_popup_layer
	if get_tree() == null:
		return null
	_ui_popup_layer = CanvasLayer.new()
	_ui_popup_layer.name = "GlobalUiPopupLayer"
	_ui_popup_layer.layer = 4096
	get_tree().root.add_child(_ui_popup_layer)
	return _ui_popup_layer


func clear_hover_popup() -> void:
	if _active_hover_popup != null and is_instance_valid(_active_hover_popup):
		_active_hover_popup.queue_free()
	_active_hover_popup = null


func register_hover_popup(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		clear_hover_popup()
		return
	if _active_hover_popup == node:
		return
	clear_hover_popup()
	_active_hover_popup = node


## 清理已登记的临时 UI 与弹出层。地图/商店阴影、地图 Shop 按钮等场景自有节点
## 不登记，由所属场景释放；message_show 由父节点/自身计时释放，也不进入登记表。
func cleanup_transient_ui() -> void:
	if _cleanup_transient_ui_active:
		return
	_cleanup_transient_ui_active = true
	clear_hover_popup()
	_close_registered_transient_ui()
	if _ui_popup_layer != null and is_instance_valid(_ui_popup_layer):
		for child in _ui_popup_layer.get_children():
			if child != null and is_instance_valid(child) and not child.is_queued_for_deletion():
				child.queue_free()
	_cleanup_transient_ui_active = false


func register_transient_ui(node: Node, close_method: StringName = &"", scene_path: String = "") -> void:
	if node == null or not is_instance_valid(node) or node.is_queued_for_deletion():
		return
	var resolved_path := scene_path
	if resolved_path == "":
		resolved_path = str(node.scene_file_path)
	if _is_permanent_ui_path(resolved_path):
		return
	var instance_id := node.get_instance_id()
	if _transient_ui_instances.has(instance_id):
		return
	_transient_ui_instances[instance_id] = {"node": node, "close_method": close_method}
	node.tree_exited.connect(_on_transient_ui_exited.bind(instance_id), CONNECT_ONE_SHOT)


func is_transient_ui_registered(node: Node) -> bool:
	if node == null or not is_instance_valid(node):
		return false
	return _transient_ui_instances.has(node.get_instance_id())


func _on_transient_ui_exited(instance_id: int) -> void:
	_transient_ui_instances.erase(instance_id)


func _close_registered_transient_ui() -> void:
	for instance_id in _transient_ui_instances.keys():
		var entry: Dictionary = _transient_ui_instances[instance_id]
		var node: Variant = entry.get("node")
		if node == null or not is_instance_valid(node) or node.is_queued_for_deletion():
			_transient_ui_instances.erase(instance_id)
			continue
		var close_method: StringName = entry.get("close_method", &"")
		if close_method != &"" and node.has_method(close_method):
			node.call(close_method)
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			node.queue_free()
		_transient_ui_instances.erase(instance_id)


func register_ui_runtime_instance(node: Node, scene_path: String) -> void:
	if node == null or not is_instance_valid(node) or not is_runtime_ui_scene_path(scene_path):
		return
	var instance_id := node.get_instance_id()
	if _ui_runtime_instance_paths.has(instance_id):
		return
	_ui_runtime_instance_paths[instance_id] = scene_path
	_ui_runtime_instance_counts[scene_path] = int(_ui_runtime_instance_counts.get(scene_path, 0)) + 1
	node.tree_exited.connect(_on_ui_runtime_instance_exited.bind(instance_id), CONNECT_ONE_SHOT)


func _on_ui_runtime_instance_exited(instance_id: int) -> void:
	if not _ui_runtime_instance_paths.has(instance_id):
		return
	var scene_path := str(_ui_runtime_instance_paths[instance_id])
	_ui_runtime_instance_paths.erase(instance_id)
	var remaining := maxi(0, int(_ui_runtime_instance_counts.get(scene_path, 1)) - 1)
	if remaining > 0:
		_ui_runtime_instance_counts[scene_path] = remaining
		return
	_ui_runtime_instance_counts.erase(scene_path)
	call_deferred("_release_ui_scene_cache_if_unused", scene_path)


func _release_ui_scene_cache_if_unused(scene_path: String) -> void:
	if int(_ui_runtime_instance_counts.get(scene_path, 0)) > 0:
		return
	if _host.get_resource_runtime().is_permanent_small_ui_scene_path(scene_path):
		return
	_host.get_resource_runtime().erase_cached_scene(scene_path)
	_clear_packed_scene_members_for_path(scene_path)
	_host.get_resource_runtime().erase_cached_texture_paths_by_prefix(_ui_art_prefixes_for_scene(scene_path))


func release_ui_runtime_cache(release_permanent: bool = false) -> void:
	_ui_runtime_instance_paths.clear()
	_ui_runtime_instance_counts.clear()
	for scene_path in _host.get_resource_runtime().get_cached_scene_paths():
		if (
			is_runtime_ui_scene_path(scene_path)
			and (release_permanent or not _host.get_resource_runtime().is_permanent_small_ui_scene_path(scene_path))
		):
			_host.get_resource_runtime().erase_cached_scene(scene_path)
	for property_info in _host.get_property_list():
		var property_name := StringName(property_info.get("name", ""))
		var value: Variant = _host.get(property_name)
		if (
			_host.get_resource_runtime().is_valid_packed_scene(value)
			and is_runtime_ui_scene_path((value as PackedScene).resource_path)
			and (
				release_permanent
				or not _host.get_resource_runtime().is_permanent_small_ui_scene_path(
					(value as PackedScene).resource_path
				)
			)
		):
			_host.set(property_name, null)
	if release_permanent or not _host.is_archive_session_active():
		(
			_host
			. get_resource_runtime()
			. erase_cached_texture_paths_by_prefix(
				[
					"res://Art/backpack/",
					"res://Art/skill/",
					"res://Art/shop/",
					"res://Art/ldl/",
					"res://Art/pet/pet_page_resources/",
					"res://Art/main_menu/BodyTraining/",
					"res://Art/lianti/",
					"res://Art/zhenyaota/",
				]
			)
		)
	if release_permanent:
		_host.get_resource_runtime().clear_permanent_small_ui_scene_cache()


func clear_runtime_state() -> void:
	_ui_runtime_instance_paths.clear()
	_ui_runtime_instance_counts.clear()
	_transient_ui_instances.clear()
	_cleanup_transient_ui_active = false
	_active_hover_popup = null
	_windows_stack.clear()
	windows = null


func get_scope_snapshot() -> Dictionary:
	return {
		"owner": "UiRuntime",
		"capacity": "按运行时实例登记；无固定上限",
		"cleanup": "UiRuntime.release_ui_runtime_cache / _release_ui_scene_cache_if_unused",
		"runtime_instance_count": _ui_runtime_instance_paths.size(),
		"runtime_scene_count": _ui_runtime_instance_counts.size(),
		"runtime_scene_counts": _ui_runtime_instance_counts.duplicate(true),
		"transient_instance_count": _transient_ui_instances.size(),
		"permanent_scene_count": _host.get_resource_runtime().get_permanent_small_ui_scene_count(),
	}


func _is_permanent_ui_path(scene_path: String) -> bool:
	return _host.get_resource_runtime().is_permanent_small_ui_scene_path(scene_path)


func _clear_packed_scene_members_for_path(scene_path: String) -> void:
	for property_info in _host.get_property_list():
		var property_name := StringName(property_info.get("name", ""))
		var value: Variant = _host.get(property_name)
		if (
			_host.get_resource_runtime().is_valid_packed_scene(value)
			and (value as PackedScene).resource_path == scene_path
		):
			_host.set(property_name, null)


func is_runtime_ui_scene_path(scene_path: String) -> bool:
	if scene_path == "res://Scene/set_menu.tscn" or scene_path == "res://Scene/pet/pet_interface.tscn":
		return true
	for prefix in [
		"res://Scene/back_pack/",
		"res://Scene/skill/",
		"res://Scene/shop/",
		"res://Scene/ldl/",
		"res://Scene/task/",
		"res://Scene/pellet/",
		"res://Scene/archive_interface/",
	]:
		if scene_path.begins_with(prefix):
			return true
	return (
		scene_path
		in [
			"res://Scene/main_menu/body_training.tscn",
			"res://Scene/main_menu/body_training_detail.tscn",
			"res://Scene/main_menu/zhu_xian_sword_page.tscn",
			"res://Scene/main_menu/zhen_yao_tower.tscn",
			"res://Scene/main_menu/game_set.tscn",
			"res://Scene/main_menu/game_announcement.tscn",
			"res://Scene/main_menu/game_information.tscn",
			"res://Scene/other_scene/choose_music.tscn",
			"res://Scene/other_scene/twenty_eight_constellations.tscn",
			"res://Scene/other_scene/zhen_fa_ui.tscn",
			"res://Scene/other_scene/transmogtified_box.tscn",
			"res://Scene/other_scene/transmogrified.tscn",
			"res://Scene/other_scene/change_back_ground.tscn",
			"res://Scene/magic_weapon/magic_help.tscn",
		]
	)


func _ui_art_prefixes_for_scene(scene_path: String) -> Array:
	if scene_path.begins_with("res://Scene/skill/"):
		return ["res://Art/skill/"]
	if scene_path.begins_with("res://Scene/back_pack/"):
		return ["res://Art/backpack/"]
	if scene_path == "res://Scene/pet/pet_interface.tscn":
		return ["res://Art/pet/pet_page_resources/"]
	if scene_path.begins_with("res://Scene/ldl/"):
		return ["res://Art/ldl/"]
	if (
		scene_path == "res://Scene/main_menu/body_training.tscn"
		or scene_path == "res://Scene/main_menu/body_training_detail.tscn"
	):
		return ["res://Art/lianti/"]
	if scene_path == "res://Scene/main_menu/zhen_yao_tower.tscn":
		return ["res://Art/zhenyaota/"]
	return []

class_name RuntimeDiagnostics
extends Node

## 只读运行时诊断：调试性能浮层与缓存/租约/保存状态快照。
## 由 Global 作为普通子节点持有，不是 Autoload；业务状态仍归 Global 所有。

const SHOW_DEBUG_PERF_OVERLAY := true
const COOP_DEBUG_TOP_MARGIN := 164.0

var _host
var _debug_perf_layer: CanvasLayer = null
var _debug_perf_label: Label = null
var _debug_perf_elapsed := 0.0


func setup(host: Node) -> void:
	_host = host


func _ready() -> void:
	if SHOW_DEBUG_PERF_OVERLAY:
		_create_debug_perf_overlay()


func _physics_process(delta: float) -> void:
	if _debug_perf_label == null or not is_instance_valid(_debug_perf_label):
		return
	_debug_perf_elapsed += delta
	if _debug_perf_elapsed < 1.0:
		return
	_debug_perf_elapsed = 0.0
	_update_debug_perf_overlay()


func get_runtime_generation() -> int:
	return int(_host._runtime_generation)


func get_background_save_status() -> Dictionary:
	return {
		"serial": _host._background_save_last_serial,
		"success": _host._background_save_last_success,
		"path": _host._background_save_last_path,
		"failure_count": _host._background_save_failure_count,
		"last_error": MemoryClass.last_save_error if MemoryClass != null else "",
	}


func get_save_failure_status() -> Dictionary:
	return {
		"count": _host._save_failure_count,
		"last": (_host._save_failure_last as Dictionary).duplicate(true),
		"last_outcome": MemoryClass.get_last_save_outcome() if MemoryClass != null else {},
		"feedback_enabled": _host._save_failure_feedback_enabled,
	}


## 只读快照；数组为副本，调用方不能借此修改租约。
func get_level_resource_lease_snapshot() -> Dictionary:
	var lease: Dictionary = _host._level_resource_lease
	if lease.is_empty():
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
		"id": int(lease.get("id", 0)),
		"target_scene": str(lease.get("target_scene", "")),
		"owned_path_count": (lease.get("paths", {}) as Dictionary).size(),
		"owned_paths": _lease_path_list(lease.get("paths", {})),
		"scene_paths": _lease_path_list(lease.get("scene_paths", {})),
		"monster_scene_paths": _lease_path_list(lease.get("monster_scene_paths", {})),
		"bullet_scene_paths": _lease_path_list(lease.get("bullet_scene_paths", {})),
		"texture_paths": _lease_path_list(lease.get("texture_paths", {})),
		"audio_paths": _lease_path_list(lease.get("audio_paths", {})),
		"warmed_scene_paths": _lease_path_list(lease.get("warmed_scene_paths", {})),
		"prewarmed_monster_ids": _lease_int_list(lease.get("prewarmed_monster_ids", {})),
	}


func get_cache_scope_snapshot() -> Dictionary:
	var pool_limits := {
		"damage_text": _host.DAMAGE_TEXT_POOL_LIMIT,
		"mr_hurt": _host.MR_HURT_POOL_LIMIT,
		"role_be_hit": _host.ROLE_BE_HIT_POOL_LIMIT,
		"sound_player": _host.SOUND_PLAYER_POOL_LIMIT,
	}
	var pool_sizes: Dictionary = {}
	for pool_name in pool_limits:
		var pool_value: Variant = _host._pool_data.get(pool_name, [])
		pool_sizes[pool_name] = (pool_value as Array).size() if pool_value is Array else 0
	return {
		"build_read_only":
		{
			"owner": "scripts/convert_level_preload_catalog.py + LevelPreloadStore",
			"capacity": "构建期生成；运行时只读，无运行时增长",
			"cleanup": "none",
			"catalog_path": LevelPreloadStore.CATALOG_PATH,
			"catalog_loaded": LevelPreloadStore.is_catalog_loaded(),
		},
		"shared_runtime":
		{
			"owner": "Global",
			"capacity": "按租约/UI/永久所有权驻留；无固定上限",
			"cleanup":
			"release_level_resource_lease / UiRuntime.release_ui_runtime_cache / release_role_runtime_resources",
			"resource_entries": _host._resource_cache.size(),
			"sprite_frames_entries": _host._sprite_frames_cache.size(),
			"audio_entries": _host._audio_cache.size(),
			"texture_entries": _host._texture_cache.size(),
		},
		"permanent":
		{
			"owner": "Global",
			"capacity": "永久小 UI 4 条；角色/宠物预热标记各 1",
			"cleanup": "UiRuntime.release_ui_runtime_cache(release_permanent=true) / end_archive_session",
			"small_ui_scene_count": _host._permanent_small_ui_scene_cache.size(),
			"small_ui_prewarm_in_progress": _host._permanent_ui_prewarm_in_progress,
			"small_ui_prewarmed": _host._permanent_ui_prewarmed,
			"role_prewarmed_id": _host._prewarmed_role_id,
			"pet_signature": _host._prewarmed_pet_signature,
		},
		"level":
		{
			"owner": "Global._level_resource_lease",
			"capacity": "按当前关卡加载路径；无固定上限",
			"cleanup": "change_scene / clear_level_resource_cache",
			"lease": get_level_resource_lease_snapshot(),
			"monster_scene_count": _host._monster_scene_cache.size(),
			"preloaded_slot": get_preloaded_scene_slot_snapshot(),
		},
		"combat":
		{
			"owner": "Global",
			"capacity": "池上限 80/32/24/32；静态帧缓存随模块",
			"cleanup": "end_archive_session -> clear_combat_runtime_cache",
			"pool_sizes": pool_sizes,
			"pool_limits": pool_limits,
			"pool_root_valid": _host._pool_data.get("root") != null and is_instance_valid(_host._pool_data.get("root")),
			"active_damage_texts": _host._active_damage_texts.size(),
			"active_sound_players": int(_host.get_audio_runtime().get_snapshot().get("active_sound_players", 0)),
			"all_hero_skill_resources_preloaded": _host._all_hero_skill_resources_preloaded,
		},
		"ui": _host.get_ui_runtime().get_scope_snapshot(),
	}


func get_preloaded_scene_slot_snapshot() -> Dictionary:
	return {
		"path": _host._preloading_path,
		"ready_path": _host._preloaded_scene_path,
		"ready": _host._preloaded_scene != null,
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


func _create_debug_perf_overlay() -> void:
	if _debug_perf_layer != null and is_instance_valid(_debug_perf_layer):
		return
	_debug_perf_layer = CanvasLayer.new()
	_debug_perf_layer.name = "DebugPerfOverlay"
	_debug_perf_layer.layer = 4096
	add_child(_debug_perf_layer)
	_debug_perf_label = Label.new()
	_debug_perf_label.name = "DebugPerfLabel"
	_debug_perf_label.z_index = 4096
	_debug_perf_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_debug_perf_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_debug_perf_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_debug_perf_label.add_theme_font_size_override("font_size", 12)
	_debug_perf_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.25, 1.0))
	_debug_perf_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_debug_perf_label.add_theme_constant_override("outline_size", 1)
	_debug_perf_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	_debug_perf_label.add_theme_constant_override("shadow_offset_x", 0)
	_debug_perf_label.add_theme_constant_override("shadow_offset_y", 0)
	_debug_perf_layer.add_child(_debug_perf_label)
	_debug_perf_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_debug_perf_label.offset_left = -244.0
	_debug_perf_label.offset_top = 6.0
	_debug_perf_label.offset_right = -24.0
	_debug_perf_label.offset_bottom = 54.0
	_update_debug_perf_overlay()


func _format_debug_memory(bytes_value: int) -> String:
	var mb := float(bytes_value) / 1024.0 / 1024.0
	return str(snapped(mb, 0.1)) + " MB"


func _update_debug_perf_overlay() -> void:
	if _debug_perf_label == null or not is_instance_valid(_debug_perf_label):
		return
	var coop_node = get_node_or_null("/root/LocalCoop")
	var top_margin := 6.0
	if coop_node != null and coop_node.has_method("is_enabled") and coop_node.is_enabled():
		top_margin = COOP_DEBUG_TOP_MARGIN
	_debug_perf_label.offset_top = top_margin
	_debug_perf_label.offset_bottom = top_margin + 48.0
	var fps := Engine.get_frames_per_second()
	var render_total_mem := int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	_debug_perf_label.text = "FPS: " + str(fps) + "\n显存: " + _format_debug_memory(render_total_mem)

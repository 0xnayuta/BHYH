class_name LevelLayoutStore
extends RefCounted

## 构建期布局索引的只读入口。运行时只按场景路径懒加载单关卡布局，
## 不扫描目录、不解析脚本源文本。

const CATALOG_PATH := "res://Script/data/level_layout_catalog.tres"

static var _catalog: LevelLayoutCatalog
static var _layouts: Dictionary = {}
static var _spawn_dicts: Dictionary = {}
static var _stage_trigger_x: Dictionary = {}
static var _screen_starts: Dictionary = {}
static var _screen_rights: Dictionary = {}


static func is_catalog_loaded() -> bool:
	return _catalog != null


static func _ensure_catalog() -> bool:
	if _catalog != null:
		return true
	_catalog = (ResourceLoader.load(CATALOG_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE) as LevelLayoutCatalog)
	if _catalog == null:
		push_error("缺少构建期关卡布局 Catalog: " + CATALOG_PATH)
		return false
	return true


static func layout(scene_path: String) -> LevelLayoutEntry:
	if scene_path.is_empty() or not _ensure_catalog():
		return null
	var layout_path := _catalog.layout_path(scene_path)
	if layout_path == &"":
		return null
	if _layouts.has(layout_path):
		return _layouts[layout_path] as LevelLayoutEntry
	var entry := ResourceLoader.load(str(layout_path), "Resource", ResourceLoader.CACHE_MODE_REUSE) as LevelLayoutEntry
	if entry == null:
		push_error("关卡布局资源无法加载: " + str(layout_path))
		return null
	_layouts[layout_path] = entry
	return entry


static func player_birth_points(scene_path: String) -> PackedVector2Array:
	var entry := layout(scene_path)
	if entry == null:
		return PackedVector2Array()
	return entry.player_birth_points.duplicate()


static func stage_specs(scene_path: String) -> Array[LevelStageSpec]:
	var entry := layout(scene_path)
	if entry == null:
		return []
	return entry.stages.duplicate()


static func stage_count(scene_path: String) -> int:
	var entry := layout(scene_path)
	return entry.stage_count() if entry != null else 0


static func stage_trigger_x(scene_path: String) -> Array:
	if scene_path.is_empty():
		return []
	if _stage_trigger_x.has(scene_path):
		return _stage_trigger_x[scene_path]
	var entry := layout(scene_path)
	if entry == null:
		return []
	var result: Array = []
	for stage in entry.stages:
		if stage != null:
			result.append(stage.trigger_rect.position.x)
	_stage_trigger_x[scene_path] = result
	return result


static func screen_starts(scene_path: String) -> Array:
	if scene_path.is_empty():
		return []
	if _screen_starts.has(scene_path):
		return _screen_starts[scene_path]
	var entry := layout(scene_path)
	if entry == null:
		return []
	var result: Array = []
	for stage in entry.stages:
		if stage != null:
			result.append(stage.screen_rect.position.x)
	_screen_starts[scene_path] = result
	return result


static func screen_rights(scene_path: String) -> Array:
	if scene_path.is_empty():
		return []
	if _screen_rights.has(scene_path):
		return _screen_rights[scene_path]
	var entry := layout(scene_path)
	if entry == null:
		return []
	var result: Array = []
	for stage in entry.stages:
		if stage != null:
			result.append(stage.screen_rect.end.x)
	_screen_rights[scene_path] = result
	return result


static func spawn_point_dicts(scene_path: String) -> Array:
	if scene_path.is_empty():
		return []
	if _spawn_dicts.has(scene_path):
		return _spawn_dicts[scene_path]
	var entry := layout(scene_path)
	if entry == null:
		return []
	var result := entry.spawn_dicts()
	_spawn_dicts[scene_path] = result
	return result


static func clear_cache() -> void:
	_catalog = null
	_layouts.clear()
	_spawn_dicts.clear()
	_stage_trigger_x.clear()
	_screen_starts.clear()
	_screen_rights.clear()

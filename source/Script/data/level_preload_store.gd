class_name LevelPreloadStore
extends RefCounted

## 构建期关卡预载索引的只读入口；运行时不解析 .gd / .tscn 源文本。
const CATALOG_PATH := "res://Script/data/level_preload_catalog.tres"

static var _catalog: LevelPreloadCatalog


static func _ensure_catalog() -> bool:
	if _catalog != null:
		return true
	_catalog = (ResourceLoader.load(CATALOG_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE) as LevelPreloadCatalog)
	if _catalog == null:
		push_error("缺少构建期关卡预载 Catalog: " + CATALOG_PATH)
		return false
	return true


static func level(scene_path: String) -> LevelPreloadEntry:
	if scene_path.is_empty() or not _ensure_catalog():
		return null
	return _catalog.level(scene_path)


static func stage_group(scene_path: String) -> Dictionary:
	var entry := level(scene_path)
	if entry == null:
		return {"stage_1": [], "stage_2": [], "stage_3": [], "stage_4": []}
	return entry.stage_group()


static func monster_ids(scene_path: String) -> Array[int]:
	var entry := level(scene_path)
	if entry == null:
		return []
	return Array(entry.monster_ids)


static func bullet_scenes(monster_scene_path: String) -> PackedStringArray:
	if monster_scene_path.is_empty() or not _ensure_catalog():
		return PackedStringArray()
	return _catalog.bullet_scenes(monster_scene_path)

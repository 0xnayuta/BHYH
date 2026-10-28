class_name LevelPreloadStore
extends RefCounted

## 构建期关卡预载索引的只读入口；运行时不解析 .gd / .tscn 源文本。
## 数组查询返回副本，内部 Catalog 与 Entry 不对外暴露写入入口。
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


static func _level(scene_path: String) -> LevelPreloadEntry:
	if scene_path.is_empty() or not _ensure_catalog():
		return null
	return _catalog.level(scene_path)


static func first_wave_ids(scene_path: String) -> PackedInt32Array:
	var entry := _level(scene_path)
	if entry == null:
		return PackedInt32Array()
	return entry.first_wave_ids.duplicate()


static func monster_ids(scene_path: String) -> Array[int]:
	var result: Array[int] = []
	var entry := _level(scene_path)
	if entry != null:
		result.assign(entry.monster_ids)
	return result


static func bullet_scenes(monster_scene_path: String) -> PackedStringArray:
	if monster_scene_path.is_empty() or not _ensure_catalog():
		return PackedStringArray()
	return _catalog.bullet_scenes(monster_scene_path)


static func monster_scene_path(monster_id: int) -> String:
	if monster_id <= 0 or not _ensure_catalog():
		return ""
	return _catalog.scene_path_for(monster_id)


static func dynamic_monster_textures(monster_id: int) -> PackedStringArray:
	if monster_id <= 0 or not _ensure_catalog():
		return PackedStringArray()
	return _catalog.texture_paths_for(monster_id)


static func dynamic_monster_scenes(monster_id: int) -> PackedStringArray:
	if monster_id <= 0 or not _ensure_catalog():
		return PackedStringArray()
	return _catalog.extra_scene_paths_for(monster_id)

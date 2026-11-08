class_name ExternalMonsterStore
extends RefCounted

## 外部怪物映射的只读入口。返回内置类型副本，不暴露 Catalog 写入入口。

const CATALOG_PATH := "res://Script/data/external_monster_catalog.tres"

static var _catalog: ExternalMonsterCatalog


static func is_catalog_loaded() -> bool:
	return _catalog != null


static func _ensure_catalog() -> bool:
	if _catalog != null:
		return true
	_catalog = (
		ResourceLoader.load(CATALOG_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE) as ExternalMonsterCatalog
	)
	if _catalog == null:
		push_error("缺少外部怪物映射 Catalog: " + CATALOG_PATH)
		return false
	return true


static func monster_id(external_id: int) -> int:
	if external_id <= 0 or not _ensure_catalog():
		return 0
	return _catalog.monster_id(external_id)


static func scene_path(external_id: int) -> String:
	if external_id <= 0 or not _ensure_catalog():
		return ""
	return str(_catalog.scene_path(external_id))


static func source_name(external_id: int) -> String:
	if external_id <= 0 or not _ensure_catalog():
		return ""
	return str(_catalog.source_name(external_id))


static func clear_cache() -> void:
	_catalog = null

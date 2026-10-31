extends Node

## ZMWS 数值配置表查询入口（Autoload: ZmwsConfig）。
## 表文件来自素材仓 Data/zmws_config/，按需加载并缓存，不做全量预载。
## 不使用 class_name：干净克隆首次 --headless 运行时全局类名缓存不存在。

const TABLE_SCRIPT := preload("res://Script/config/config_table.gd")
const ROOT := "res://Data/zmws_config"

var _cache: Dictionary = {}
var _index: Dictionary = {}
var _index_loaded := false


func _ensure_index() -> void:
	if _index_loaded:
		return
	_index_loaded = true
	var path := ROOT.path_join("index.json")
	if not FileAccess.file_exists(path):
		push_warning("ZmwsConfig: 缺少索引 %s" % path)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		_index = parsed
	else:
		push_warning("ZmwsConfig: 索引解析失败 %s" % path)


func is_available() -> bool:
	_ensure_index()
	return not _index.is_empty()


func table_count() -> int:
	_ensure_index()
	return int(_index.get("table_count", 0))


func total_rows() -> int:
	_ensure_index()
	return int(_index.get("total_rows", 0))


func has_table(name: String) -> bool:
	_ensure_index()
	var tables: Dictionary = _index.get("tables", {})
	return tables.has(name)


func table_names() -> PackedStringArray:
	_ensure_index()
	var out := PackedStringArray()
	var tables: Dictionary = _index.get("tables", {})
	for key in tables.keys():
		out.append(str(key))
	out.sort()
	return out


func table(name: String):
	if _cache.has(name):
		return _cache[name]
	var path := ROOT.path_join(name + ".json")
	if not FileAccess.file_exists(path):
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return null
	var instance = TABLE_SCRIPT.new(name, parsed)
	_cache[name] = instance
	return instance


func find(name: String, id: Variant) -> Array:
	var t = table(name)
	if t == null:
		return []
	return t.find_by_id(id)


func value(name: String, id: Variant, column_name: String) -> Variant:
	var t = table(name)
	if t == null:
		return null
	var row: Array = t.find_by_id(id)
	if row.is_empty():
		return null
	var index: int = t.column_index(column_name)
	if index < 0 or index >= row.size():
		return null
	return row[index]


func cached_table_count() -> int:
	return _cache.size()


func clear_cache() -> void:
	_cache.clear()

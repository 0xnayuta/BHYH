extends RefCounted

## ZMWS 数值表：列式存储 + id 索引。
## 由 ZmwsConfig 按需创建；不注册 class_name，避免干净克隆首次 headless 时
## 全局类名缓存缺失导致解析失败。

var table_name := ""
var header: Array = []
var rows: Array = []

var _column_index: Dictionary = {}
var _by_id: Dictionary = {}


func _init(name: String, raw: Dictionary) -> void:
	table_name = name
	header = raw.get("header", [])
	rows = raw.get("rows", [])
	for i in range(header.size()):
		_column_index[str(header[i])] = i
	_by_id.clear()
	var id_col: int = int(_column_index.get("id", -1))
	if id_col < 0:
		return
	for row in rows:
		if row is Array and row.size() > id_col:
			var key: Variant = row[id_col]
			if not _by_id.has(key):
				_by_id[key] = row


func size() -> int:
	return rows.size()


func has_column(name: String) -> bool:
	return _column_index.has(name)


func column_index(name: String) -> int:
	return int(_column_index.get(name, -1))


func row_at(index: int) -> Array:
	if index < 0 or index >= rows.size():
		return []
	return rows[index]


func row_dict(index: int) -> Dictionary:
	var out := {}
	var row: Array = row_at(index)
	for i in range(mini(header.size(), row.size())):
		out[str(header[i])] = row[i]
	return out


func value(index: int, column_name: String) -> Variant:
	var i := column_index(column_name)
	if i < 0:
		return null
	var row: Array = row_at(index)
	return row[i] if i < row.size() else null


func has_id(id: Variant) -> bool:
	return _by_id.has(id)


func find_by_id(id: Variant) -> Array:
	if _by_id.has(id):
		return _by_id[id]
	return []

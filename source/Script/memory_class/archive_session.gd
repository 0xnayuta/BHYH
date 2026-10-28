class_name ArchiveSession
extends RefCounted

## 当前档案会话的只读快照。只由 Global 创建与替换，业务侧仅读取。
## generation 为 0 表示会话未建立；建立后单调递增，供保存与异步回调校验。

var _generation: int = 0
var _archive_number: int = 0
var _role_id: int = 0
var _archive_path: String = ""


func _init(generation: int = 0, archive_number: int = 0, role_id: int = 0, archive_path: String = "") -> void:
	_generation = generation
	_archive_number = archive_number
	_role_id = role_id
	_archive_path = archive_path


func is_active() -> bool:
	return _generation > 0 and _archive_number > 0 and _archive_path != ""


func get_generation() -> int:
	return _generation


func get_archive_number() -> int:
	return _archive_number


func get_role_id() -> int:
	return _role_id


func get_archive_path() -> String:
	return _archive_path


func matches(path: String, role_id: int) -> bool:
	return is_active() and _archive_path == path and _role_id == role_id

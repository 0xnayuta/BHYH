extends RefCounted

## 6.8 纹理别名表（B-03）已于 2026-10-27 清空。
## 2,313 条旧路径映射已按目标存在性、静态引用与全量/UI 命中统计收敛；
## 当前 ALIASES 为空，resolve 为恒等映射。
## 新增别名必须有明确消费者，并通过 classify_texture_aliases.py --check。

const ALIASES: Dictionary = {}

static var _hit_counts: Dictionary = {}
static var _hit_dir: String = ""
static var _hit_dir_checked: bool = false


static func _hit_capture_dir() -> String:
	if not _hit_dir_checked:
		_hit_dir_checked = true
		if OS.is_debug_build():
			_hit_dir = OS.get_environment("BHYH_TEXTURE_ALIAS_HITS_DIR").strip_edges()
	return _hit_dir


static func _record_hit(key: String) -> void:
	if _hit_capture_dir().is_empty():
		return
	_hit_counts[key] = int(_hit_counts.get(key, 0)) + 1


## 每个进程退出时由 Global._exit_tree 调用；按 PID 写独立 JSON，避免并发追加冲突。
static func flush_hit_stats() -> void:
	var directory := _hit_capture_dir()
	if directory.is_empty() or _hit_counts.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(directory)
	var path := directory.path_join("alias_hits_%d.json" % OS.get_process_id())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(_hit_counts))
	file.close()
	_hit_counts.clear()


static func resolve(path: String) -> String:
	var key := path.trim_prefix("res://")
	var resolved: Variant = ALIASES.get(key)
	if resolved == null:
		return "res://" + key
	_record_hit(key)
	return "res://" + str(resolved)

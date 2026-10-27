extends RefCounted
class_name AtlasMetadataStore

## 统一读取构建期生成的 AtlasMetadata 资源，替代运行时 manifest JSON 解析。
## 只接受 metadata.tres 路径，不再兼容 manifest.json 逻辑路径。
## 路径为空、文件缺失与 schema 失败均通过 push_error 明确记录，不再静默返回空字典。

static var _cache: Dictionary = {}
static var _view_cache: Dictionary = {}
static var _view_failures: Dictionary = {}
static var _missing_paths: Dictionary = {}


static func data_for(path: String) -> Dictionary:
	if path.is_empty():
		return {}
	if _cache.has(path):
		return _cache[path]
	var metadata := _load_metadata(path)
	if metadata == null:
		return {}
	_cache[path] = metadata.data
	return metadata.data


static func view_for(path: String) -> AtlasMetadataView:
	if path.is_empty():
		push_error("AtlasMetadata path is empty")
		return null
	if _view_cache.has(path):
		return _view_cache[path] as AtlasMetadataView
	if _view_failures.has(path):
		return null
	var metadata := _load_metadata(path)
	if metadata == null:
		_view_failures[path] = true
		return null
	var view := AtlasMetadataView.new(metadata, path)
	if not view.is_valid():
		_report_missing(path, "AtlasMetadata runtime schema invalid: " + view.error_message())
		_view_failures[path] = true
		return null
	_view_cache[path] = view
	return view


static func validate_path(path: String) -> Array[String]:
	var errors: Array[String] = []
	if path.is_empty():
		errors.append("metadata path is empty")
		return errors
	if not ResourceLoader.exists(path):
		errors.append("metadata file not found: " + path)
		return errors
	var resource := ResourceLoader.load(path, "Resource", ResourceLoader.CACHE_MODE_REUSE)
	if not resource is AtlasMetadata:
		errors.append("resource is not AtlasMetadata: " + path)
		return errors
	errors.append_array((resource as AtlasMetadata).validate())
	return errors


static func clear_cache() -> void:
	_cache.clear()
	_view_cache.clear()
	_view_failures.clear()
	_missing_paths.clear()


static func _load_metadata(path: String) -> AtlasMetadata:
	if not ResourceLoader.exists(path):
		_report_missing(path, "AtlasMetadata 文件不存在")
		return null
	var resource := ResourceLoader.load(path, "Resource", ResourceLoader.CACHE_MODE_REUSE)
	if not resource is AtlasMetadata:
		_report_missing(path, "AtlasMetadata 类型不匹配")
		return null
	var metadata := resource as AtlasMetadata
	var errors := metadata.validate()
	if not errors.is_empty():
		_report_missing(path, "AtlasMetadata schema 无效: " + ", ".join(errors))
		return null
	return metadata


static func _report_missing(path: String, detail: String) -> void:
	# 同一路径只报一次，避免逐帧调用刷屏；清理缓存后重新可报。
	if _missing_paths.has(path):
		return
	_missing_paths[path] = true
	push_error("%s: %s" % [detail, path])

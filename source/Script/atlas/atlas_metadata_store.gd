extends RefCounted
class_name AtlasMetadataStore

## 统一读取构建期生成的 AtlasMetadata 资源，替代运行时 manifest JSON 解析。
## 只接受 metadata.tres 路径，不再兼容 manifest.json 逻辑路径。
## 路径为空、文件缺失与 schema 失败均通过 push_error 明确记录，不再静默返回空字典。
static var _cache: Dictionary = {}
static var _missing_paths: Dictionary = {}


static func data_for(path: String) -> Dictionary:
	if path.is_empty():
		return {}
	if _cache.has(path):
		return _cache[path]
	if not ResourceLoader.exists(path):
		_report_missing(path, "AtlasMetadata 文件不存在")
		return {}
	var resource := ResourceLoader.load(path, "Resource", ResourceLoader.CACHE_MODE_REUSE)
	if not resource is AtlasMetadata:
		_report_missing(path, "AtlasMetadata 类型不匹配")
		return {}
	var metadata := resource as AtlasMetadata
	var errors := metadata.validate()
	if not errors.is_empty():
		_report_missing(path, "AtlasMetadata schema 无效: " + ", ".join(errors))
		return {}
	_cache[path] = metadata.data
	return metadata.data


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
	_missing_paths.clear()


static func _report_missing(path: String, detail: String) -> void:
	# 同一路径只报一次，避免逐帧调用刷屏；清理缓存后重新可报。
	if _missing_paths.has(path):
		return
	_missing_paths[path] = true
	push_error("%s: %s" % [detail, path])

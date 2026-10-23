extends RefCounted
class_name AtlasMetadataStore

## 统一读取构建期生成的 AtlasMetadata 资源，替代运行时 manifest JSON 解析。
## 只接受 metadata.tres 路径，不再兼容 manifest.json 逻辑路径。
static var _cache: Dictionary = {}


static func data_for(path: String) -> Dictionary:
	if path.is_empty():
		return {}
	if _cache.has(path):
		return _cache[path]
	if not ResourceLoader.exists(path):
		return {}
	var resource := ResourceLoader.load(path, "Resource", ResourceLoader.CACHE_MODE_REUSE)
	if resource is AtlasMetadata:
		var metadata := resource as AtlasMetadata
		var errors := metadata.validate()
		if not errors.is_empty():
			push_error("Invalid AtlasMetadata %s: %s" % [path, ", ".join(errors)])
			return {}
		_cache[path] = metadata.data
		return metadata.data
	return {}


static func clear_cache() -> void:
	_cache.clear()

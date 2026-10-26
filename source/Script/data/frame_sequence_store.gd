class_name FrameSequenceStore
extends RefCounted

## Catalog 只驻留元数据；纹理预热租约按关卡显式释放。
## 资产身份只用 asset_id；fps/loop/hold/prefetch 属于实例播放策略。
const CATALOG_PATH := "res://Art/frame_sequences/frame_sequence_catalog.tres"

static var _catalog: FrameSequenceCatalog
static var _validated: Dictionary[int, bool] = {}
static var _prewarmed_paths: Dictionary[String, bool] = {}
static var _prewarm_generation: int = 0


static func _ensure_catalog() -> bool:
	if _catalog != null:
		return true
	_catalog = ResourceLoader.load(CATALOG_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE) as FrameSequenceCatalog
	if _catalog == null:
		push_error("缺少构建期帧序列 Catalog: " + CATALOG_PATH)
		return false
	return true


static func directory_asset_id(directory: String) -> StringName:
	## 批量目录资产的登记规则：构建期与运行时使用同一确定性映射。
	if not directory.begins_with("res://Art/"):
		push_error("目录资产必须位于 res://Art/ 下: " + directory)
		return &""
	return StringName("dir/" + directory.trim_prefix("res://Art/"))


static func has_sequence(asset_id: StringName) -> bool:
	if not _ensure_catalog():
		return false
	return _catalog.sequences.has(asset_id)


static func get_sequence(asset_id: StringName) -> FrameSequence:
	if not _ensure_catalog():
		return null
	var sequence: FrameSequence = _catalog.sequences.get(asset_id)
	if sequence == null:
		push_error("缺少构建期帧序列: " + str(asset_id))
		return null
	var instance_id := sequence.get_instance_id()
	if not _validated.has(instance_id):
		var errors := sequence.validate()
		if not errors.is_empty():
			push_error("无效构建期帧序列 %s: %s" % [asset_id, ", ".join(errors)])
			return null
		_validated[instance_id] = true
	return sequence


static func prewarm_sequence(sequence: FrameSequence, frame_limit: int = 3) -> bool:
	if sequence == null or not sequence.validate().is_empty() or frame_limit <= 0:
		push_error("无法预热无效 FrameSequence 或非正 frame_limit")
		return false
	var generation := _prewarm_generation
	var paths: Dictionary[String, bool] = {}
	for index in range(mini(frame_limit, sequence.count())):
		var path := sequence.frame_paths[index]
		paths[path] = true
		if not _prewarmed_paths.has(path):
			_prewarmed_paths[path] = true
			FrameTextureRequests.acquire(path)
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		push_error("FrameSequence 预热需要 SceneTree")
		clear_prewarmed_textures()
		return false
	for path: String in paths:
		while FrameTextureRequests.get_texture(path) == null and not FrameTextureRequests.has_failed(path):
			await tree.process_frame
			if generation != _prewarm_generation:
				return false
		if FrameTextureRequests.has_failed(path):
			FrameTextureRequests.release(path)
			_prewarmed_paths.erase(path)
			return false
	return generation == _prewarm_generation


static func clear_prewarmed_textures() -> void:
	_prewarm_generation += 1
	for path: String in _prewarmed_paths:
		FrameTextureRequests.release(path)
	_prewarmed_paths.clear()


static func clear_cache() -> void:
	clear_prewarmed_textures()
	_validated.clear()
	_catalog = null

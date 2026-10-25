class_name FrameSequenceStore
extends RefCounted

## 运行时只读入口：从构建期 Catalog 取得 FrameSequence，不扫描目录。
const CATALOG_PATH := "res://Art/frame_sequences/frame_sequence_catalog.tres"

static var _catalog: FrameSequenceCatalog


static func key_for(directory: String, fps: float, loop: bool, hold_last_frame: bool, prefetch: int = 2) -> StringName:
	return StringName("%s|%.1f|%s|%s|%d" % [directory, fps, str(loop), str(hold_last_frame), prefetch])


static func _ensure_catalog() -> void:
	if _catalog == null:
		_catalog = (
			ResourceLoader.load(CATALOG_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE) as FrameSequenceCatalog
		)
		assert(_catalog != null, "缺少构建期帧序列 Catalog: " + CATALOG_PATH)


static func has_sequence(directory: String, fps: float, loop: bool, hold_last_frame: bool, prefetch: int = 2) -> bool:
	var key := key_for(directory, fps, loop, hold_last_frame, prefetch)
	_ensure_catalog()
	return _catalog.sequences.has(key)


static func get_sequence(
	directory: String, fps: float, loop: bool, hold_last_frame: bool, prefetch: int = 2
) -> FrameSequence:
	var key := key_for(directory, fps, loop, hold_last_frame, prefetch)
	_ensure_catalog()
	var sequence: FrameSequence = _catalog.sequences.get(key)
	assert(sequence != null, "缺少构建期帧序列: " + str(key))
	return sequence


static func clear_cache() -> void:
	_catalog = null

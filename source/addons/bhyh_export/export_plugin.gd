@tool
extends EditorExportPlugin

## 将运行时通过 FileAccess 读取的 JSON/BIN 原始数据加入实际导出包。
## 清单由 scripts/export_raw_manifest.py 生成，插件不在导出时扫描目录，
## 避免导出配置、插件与探针各自维护路径。

const MANIFEST_PATH := "res://Script/data/export_raw_dependencies.json"

var _included_paths: Dictionary = {}


func _get_name() -> String:
	return "BHYH Raw Data Export"


func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	_included_paths.clear()
	var text := FileAccess.get_file_as_string(MANIFEST_PATH)
	if text.is_empty():
		push_error("BHYH raw export manifest missing or unreadable: " + MANIFEST_PATH)
		return
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("BHYH raw export manifest is not a JSON object: " + MANIFEST_PATH)
		return
	var files: Variant = parsed.get("files", [])
	if not files is Array:
		push_error("BHYH raw export manifest files is not an array: " + MANIFEST_PATH)
		return

	var total_bytes := 0
	var missing := 0
	for item: Variant in files:
		if not item is Dictionary:
			missing += 1
			continue
		var path := str(item.get("path", ""))
		if path.is_empty() or not path.begins_with("res://"):
			push_error("BHYH raw export path is invalid: " + path)
			missing += 1
			continue
		var normalized := path.simplify_path()
		if _included_paths.has(normalized):
			push_error("BHYH raw export duplicate path: " + normalized)
			missing += 1
			continue
		if not FileAccess.file_exists(normalized):
			push_error("BHYH raw export file missing: " + normalized)
			missing += 1
			continue
		var bytes := FileAccess.get_file_as_bytes(normalized)
		add_file(normalized, bytes, false)
		_included_paths[normalized] = true
		total_bytes += bytes.size()

	print(
		(
			"BHYH_RAW_EXPORT files=%d expected=%d missing=%d bytes=%d"
			% [_included_paths.size(), files.size(), missing, total_bytes]
		)
	)


func _export_file(path: String, _type: String, _features: PackedStringArray) -> void:
	if _included_paths.has(path.simplify_path()):
		skip()

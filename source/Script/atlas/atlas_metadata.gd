extends Resource
class_name AtlasMetadata

## 构建期由 scripts/convert_atlas_metadata.py 生成。
## 运行时只读，禁止在游戏进程中回写。
const SCHEMA_ID := "atlas_metadata"
const SCHEMA_VERSION := 1

@export var schema_id: String = SCHEMA_ID
@export var schema_version: int = SCHEMA_VERSION
@export var data: Dictionary = {}


func validate() -> Array[String]:
	var errors: Array[String] = []
	if schema_id != SCHEMA_ID:
		errors.append("schema_id=%s, expected=%s" % [schema_id, SCHEMA_ID])
	if schema_version != SCHEMA_VERSION:
		errors.append("schema_version=%d, expected=%d" % [schema_version, SCHEMA_VERSION])
	if typeof(data) != TYPE_DICTIONARY:
		errors.append("data must be a Dictionary")
		return errors
	if data.get("__top_level", "") == "array":
		if typeof(data.get("items", null)) != TYPE_ARRAY:
			errors.append("data.items must be an Array for __top_level=array")
		return errors
	if data.has("animation") and data.has("frames"):
		if typeof(data["frames"]) != TYPE_ARRAY:
			errors.append("data.frames must be an Array for animation metadata")
		if data.has("back_atlases") and typeof(data["back_atlases"]) != TYPE_ARRAY:
			errors.append("data.back_atlases must be an Array")
		if data.has("front_atlases") and typeof(data["front_atlases"]) != TYPE_ARRAY:
			errors.append("data.front_atlases must be an Array")
		return errors
	if data.has("pages") and typeof(data["pages"]) != TYPE_ARRAY:
		errors.append("data.pages must be an Array")
	if data.has("sequences") and typeof(data["sequences"]) != TYPE_DICTIONARY:
		errors.append("data.sequences must be a Dictionary")
	if data.has("files") and typeof(data["files"]) != TYPE_DICTIONARY:
		errors.append("data.files must be a Dictionary")
	if not data.has("pages") and not data.has("sequences") and not data.has("files"):
		errors.append("data must contain pages, sequences or files")
	return errors

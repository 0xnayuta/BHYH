class_name ExternalMonsterCatalog
extends Resource

## 外部 ZMWS 怪物 ID → BHYH 怪物场景。当前按中文名精确匹配生成，
## 同一名称有多个 BHYH 场景时固定取最小 ID，保证生成结果确定。
## `source_names` 只用于诊断与人工复核，不参与运行时选择。

@export var monster_ids: Dictionary[int, int] = {}
@export var scene_paths: Dictionary[int, StringName] = {}
@export var source_names: Dictionary[int, StringName] = {}


func monster_id(external_id: int) -> int:
	return int(monster_ids.get(external_id, 0))


func scene_path(external_id: int) -> StringName:
	return scene_paths.get(external_id, &"")


func source_name(external_id: int) -> StringName:
	return source_names.get(external_id, &"")

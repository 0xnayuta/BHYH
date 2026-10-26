class_name LevelPreloadEntry
extends Resource

## 构建期生成的单关卡预载数据。
## `first_wave_ids` 只用于首波优先级；`monster_ids` 是完整覆盖集合，
## 包含所有阶段（含 stage_5 及以后）与动态出生点怪物。
@export var first_wave_ids: PackedInt32Array = PackedInt32Array()
@export var monster_ids: PackedInt32Array = PackedInt32Array()

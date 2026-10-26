class_name LevelPreloadEntry
extends Resource

## 构建期生成的单关卡预载数据；阶段与怪物 ID 均为已解析值。
@export var stage_1: PackedInt32Array = PackedInt32Array()
@export var stage_2: PackedInt32Array = PackedInt32Array()
@export var stage_3: PackedInt32Array = PackedInt32Array()
@export var stage_4: PackedInt32Array = PackedInt32Array()
@export var monster_ids: PackedInt32Array = PackedInt32Array()


func stage_group() -> Dictionary:
	return {
		"stage_1": Array(stage_1),
		"stage_2": Array(stage_2),
		"stage_3": Array(stage_3),
		"stage_4": Array(stage_4),
	}

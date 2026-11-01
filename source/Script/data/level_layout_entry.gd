class_name LevelLayoutEntry
extends Resource

## 单关卡布局资源。玩家出生点与刷怪点分开存储：
## - player_birth_points 供玩家生成；
## - stages[].spawn_points 供关卡刷怪，兼容 BaseLevel._birth_points() 的字典形状。

@export var level_id: StringName = &""
@export var layout_size: Vector2 = Vector2.ZERO
@export var player_birth_points: PackedVector2Array = PackedVector2Array()
@export var stages: Array[LevelStageSpec] = []
@export var exit_rect: Rect2 = Rect2()
@export var exit_open_when: StringName = &"stage_clear"


func stage_count() -> int:
	return stages.size()


func stage_at(index: int) -> LevelStageSpec:
	if index < 1 or index > stages.size():
		return null
	return stages[index - 1]


func spawn_dicts() -> Array:
	var result: Array = []
	for stage in stages:
		if stage == null:
			continue
		for point in stage.spawn_points:
			if point != null:
				result.append(point.as_spawn_dict(stage.index))
	return result

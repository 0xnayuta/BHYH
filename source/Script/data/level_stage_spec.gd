class_name LevelStageSpec
extends Resource

## 单个战斗阶段：分屏矩形、触发区与刷怪点。
## 当前运行时只消费 screen_rect / trigger_rect / spawn_points；其余字段保留给后续接线。

@export var index: int = 1
@export var screen_rect: Rect2 = Rect2()
@export var trigger_rect: Rect2 = Rect2()
@export var spawn_trigger_rect: Rect2 = Rect2()
@export var close_walls: PackedStringArray = PackedStringArray()
@export var open_walls: PackedStringArray = PackedStringArray()
@export var spawn_points: Array[LevelSpawnPoint] = []

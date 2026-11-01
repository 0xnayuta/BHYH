class_name LevelSpawnPoint
extends Resource

## 单个刷怪点。字段与 BaseLevel 现有出生点字典保持一一对应；
## `monster_ids` 的第一项供旧字典消费者使用，完整集合供后续调度扩展。

@export var point_id: int = 0
@export var monster_ids: PackedInt32Array = PackedInt32Array()
@export var position: Vector2 = Vector2.ZERO
@export var count: int = 1
@export var delay: float = 0.0
@export var interval: float = 0.0
## -1 左、1 右、0 保持原朝向。
@export var direction: int = 0
## 依赖点：前置点完成刷怪 / 全部死亡后才启动；0 表示无依赖。
@export var after_spawn: int = 0
@export var after_dead: int = 0
@export var ignore_count_multiplier: bool = false


func primary_monster_id() -> int:
	return monster_ids[0] if not monster_ids.is_empty() else 0


func as_spawn_dict(stage_index: int) -> Dictionary:
	return {
		"point": point_id,
		"stage": stage_index,
		"monster": primary_monster_id(),
		"position": position,
		"total": count,
		"delay": delay,
		"interval": interval,
		"face": float(direction),
		"after_spawn": after_spawn,
		"after_dead": after_dead,
		"ignore_count_multiplier": ignore_count_multiplier,
	}

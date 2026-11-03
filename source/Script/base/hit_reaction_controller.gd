class_name HitReactionController
extends RefCounted
## 受击反应状态与来源快照：代次、活动标志、显式来源上下文。
## 只管理通用状态；特殊怪物仍保留自己的 state_hurt 分支与动画时序。


class Snapshot:
	extends RefCounted

	var target: Variant
	var player: BaseHero
	var hit_data: Dictionary


var _active: bool = false
var _generation: int = 0
var _snapshot: Snapshot = null


func begin(snapshot: Snapshot = null) -> int:
	_generation += 1
	_active = true
	_snapshot = snapshot
	return _generation


func finish(generation: int) -> bool:
	if generation != _generation:
		return false
	_active = false
	_snapshot = null
	return true


func cancel() -> void:
	_generation += 1
	_active = false
	_snapshot = null


func is_active() -> bool:
	return _active


func get_generation() -> int:
	return _generation


func matches(generation: int) -> bool:
	return generation == _generation


func get_snapshot() -> Snapshot:
	return _snapshot


func get_source_player() -> BaseHero:
	return _snapshot.player if _snapshot != null else null

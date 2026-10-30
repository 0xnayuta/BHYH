class_name NodeUtils
extends RefCounted

## 无状态节点与向量工具。调用方直接用 `NodeUtils.xxx()`，不再经 `Global` 转发。
## 返回值保持动态类型（不标注具体节点类），调用方可继续按业务节点访问成员。


## 向上取第 count 层父节点；层级不足或中途为空时返回 null。
static func ancestor(node, count: int):
	var current = node
	var remaining := count
	while remaining > 0:
		if current == null:
			return null
		current = current.get_parent()
		remaining -= 1
	return current


## 两点之间的单位方向向量；任一分量为 0 或任一对象为空时返回零向量（历史语义）。
static func position_between(from_object, to_object) -> Vector2:
	if from_object == null or to_object == null:
		return Vector2(0, 0)
	var delta_x: float = to_object.position.x - from_object.position.x
	var delta_y: float = to_object.position.y - from_object.position.y
	if delta_x == 0.0 or delta_y == 0.0:
		return Vector2(0, 0)
	var length: float = sqrt(delta_x * delta_x + delta_y * delta_y)
	return Vector2(delta_x / length, delta_y / length)


## 两点之间的直线距离；任一对象为空时返回 0。
static func distance_between(from_object, to_object) -> float:
	if from_object == null or to_object == null:
		return 0.0
	var delta_x: float = to_object.position.x - from_object.position.x
	var delta_y: float = to_object.position.y - from_object.position.y
	return sqrt(delta_x * delta_x + delta_y * delta_y)

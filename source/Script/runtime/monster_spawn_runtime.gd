class_name MonsterSpawnRuntime
extends Node

## 怪物生成：怪物 ID 到场景路径的解析与生成入口。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 业务侧仍经 Global.create_monster 正式入口访问，路径解析供关卡预载复用。

const DEFAULT_MONSTER_SCENE_FORMAT := "res://Scene/monster/monster_%d.tscn"

var _host = null


func setup(host: Node) -> void:
	_host = host


## 关卡预载覆盖表优先；未登记 ID 回落默认命名。
func monster_scene_path(monster_id: int) -> String:
	var override := LevelPreloadStore.monster_scene_path(monster_id)
	if not override.is_empty():
		return override
	return DEFAULT_MONSTER_SCENE_FORMAT % monster_id


func create_monster(monster_id: int, parent, position: Vector2) -> BaseMonster:
	var path := monster_scene_path(monster_id)
	var scene: PackedScene = _host.load_level_monster_scene(path)
	if scene == null:
		return null
	var target := _host.instance_scene(scene, parent) as BaseMonster
	if target == null:
		return null
	# 动态别名场景保留源怪物 ID，供结算与掉落按 ID 归类。
	if path != DEFAULT_MONSTER_SCENE_FORMAT % monster_id:
		target.name = "Monster_%d" % monster_id
		target.set_meta("source_monster_id", monster_id)
	target.position = position
	return target

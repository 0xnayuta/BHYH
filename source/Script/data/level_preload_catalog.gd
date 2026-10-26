class_name LevelPreloadCatalog
extends Resource

## 构建期生成的关卡预载索引；键为关卡场景路径或怪物场景路径。
@export var levels: Dictionary[StringName, LevelPreloadEntry] = {}
@export var monster_bullets: Dictionary[StringName, PackedStringArray] = {}


func level(scene_path: String) -> LevelPreloadEntry:
	return levels.get(StringName(scene_path))


func bullet_scenes(monster_scene_path: String) -> PackedStringArray:
	return monster_bullets.get(StringName(monster_scene_path), PackedStringArray())

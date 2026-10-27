class_name LevelPreloadCatalog
extends Resource

## 构建期生成的关卡预载索引；键为关卡场景路径或怪物场景路径。
@export var levels: Dictionary[StringName, LevelPreloadEntry] = {}
@export var monster_bullets: Dictionary[StringName, PackedStringArray] = {}
## 别名怪物的主场景覆盖（生成期展开）；未登记的 ID 仍按 monster_<id>.tscn 构造。
@export var monster_scene_paths: Dictionary[int, StringName] = {}
## 怪物 ID → 构建期展开后的动态纹理文件（目录已在生成期展开）。
@export var monster_texture_paths: Dictionary[int, PackedStringArray] = {}
## 怪物 ID → 额外预载场景（弹体等）。
@export var monster_extra_scene_paths: Dictionary[int, PackedStringArray] = {}


func level(scene_path: String) -> LevelPreloadEntry:
	return levels.get(StringName(scene_path))


func bullet_scenes(monster_scene_path: String) -> PackedStringArray:
	return monster_bullets.get(StringName(monster_scene_path), PackedStringArray())


func scene_path_for(monster_id: int) -> String:
	return str(monster_scene_paths.get(monster_id, &""))


func texture_paths_for(monster_id: int) -> PackedStringArray:
	return monster_texture_paths.get(monster_id, PackedStringArray())


func extra_scene_paths_for(monster_id: int) -> PackedStringArray:
	return monster_extra_scene_paths.get(monster_id, PackedStringArray())

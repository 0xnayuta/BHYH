class_name RoleRuntimeResourceManifest
extends Resource

## 角色运行时预热清单：按资源类型拆分，避免场景、SpriteFrames、纹理与音频混用。
@export var scene_paths := PackedStringArray()
@export var sprite_frames_paths := PackedStringArray()
@export var texture_paths := PackedStringArray()
@export var audio_paths := PackedStringArray()

## 技能键位 → 额外资源路径；仅在该技能已装备时预热。
@export var conditional_scene_paths: Dictionary = {}
@export var conditional_texture_paths: Dictionary = {}

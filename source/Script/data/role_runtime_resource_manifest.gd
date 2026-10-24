class_name RoleRuntimeResourceManifest
extends Resource

## 角色运行时预热清单：按资源类型拆分，避免场景、SpriteFrames、纹理与音频混用。
@export var scene_paths := PackedStringArray()
@export var sprite_frames_paths := PackedStringArray()
@export var texture_paths := PackedStringArray()
@export var audio_paths := PackedStringArray()


func collect_paths() -> PackedStringArray:
	var paths := PackedStringArray()
	paths.append_array(scene_paths)
	paths.append_array(sprite_frames_paths)
	paths.append_array(texture_paths)
	paths.append_array(audio_paths)
	return paths

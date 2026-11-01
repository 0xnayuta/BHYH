class_name LevelLayoutCatalog
extends Resource

## 构建期生成的布局索引：关卡场景路径 -> 单关卡布局资源路径。
## 未登记的场景表示尚未迁移，运行时沿用关卡现有逻辑。

@export var layout_paths: Dictionary[StringName, StringName] = {}


func layout_path(scene_path: String) -> StringName:
	if scene_path.is_empty():
		return &""
	return layout_paths.get(StringName(scene_path), &"")

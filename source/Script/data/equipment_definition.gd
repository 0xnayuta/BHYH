class_name EquipmentDefinition
extends Resource

## 单条装备/物品静态定义。定义只读；强化、宝石、五行与随机结果不属于定义本身。
## `defined_fields` 保留旧字典的字段存在性；`randomized_fields` 标记必须由规则层生成的字段。

@export var id: StringName = &""
@export var display_name: String = ""
@export var origin: String = ""
@export var quality: String = ""
@export var color_hex: String = ""
@export var category: String = ""
@export var description: String = ""
@export var price: int = 0
@export var icon_path: String = ""
@export var equipment_type: String = ""
@export var fb_type: String = ""
@export var next_stage: String = ""
@export var growth_rate: float = 0.0
@export var element: PackedStringArray = PackedStringArray()
@export var forge_forbidden: bool = false

## 16 个属性只保存定义中存在的键；int/float 原类型不被统一转换。
@export var stats: Dictionary[StringName, Variant] = {}
## 旧 `强化属性`；保留 `target` 等历史键。
@export var enhancement: Dictionary[StringName, Variant] = {}
## 定义期宝石槽；宝石实例仍属于玩家档案。
@export var gem_slots: PackedStringArray = PackedStringArray()

## 旧字典中出现过的顶层字段，用于区分“缺失”与“空值”。
@export var defined_fields: PackedStringArray = PackedStringArray()
## 由旧运行时代码生成、构建源不保存采样值的字段。
@export var randomized_fields: PackedStringArray = PackedStringArray()


func has_defined_field(field: StringName) -> bool:
	return defined_fields.has(String(field))


func is_randomized(field: StringName) -> bool:
	return randomized_fields.has(String(field))

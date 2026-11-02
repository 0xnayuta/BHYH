class_name EquipmentStatRoll
extends Resource

## 单个随机属性/成长率的生成规格。规格只描述范围与变换，不保存采样值。
## sampler: randi_range / randf_range；kind 是采样后的数值类型。
## step > 0 时用 snapped/snappedf；整数 step 保持旧 snapped 的 int 返回类型。
## rounding: none / int_if_integral / ceil，对应旧数据生成函数的取整语义。

@export var sampler: StringName = &"randi"
@export var kind: StringName = &"int"
@export var minimum: float = 0.0
@export var maximum: float = 0.0
@export var step: float = 0.0
@export var scale: float = 1.0
@export var rounding: StringName = &"none"

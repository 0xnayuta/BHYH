class_name EquipmentCatalog
extends Resource

## 构建期生成的装备定义 Catalog。运行时只读，不承载玩家实例状态。

const SCHEMA_VERSION := 1

@export var schema_version: int = SCHEMA_VERSION
@export var source_sha256: String = ""
@export var definition_count: int = 0
@export var definitions: Array[EquipmentDefinition] = []


func create_store() -> EquipmentStore:
	if schema_version != SCHEMA_VERSION:
		push_error("EquipmentCatalog schema 版本不匹配: %d" % schema_version)
	if definition_count != definitions.size():
		push_error("EquipmentCatalog 定义数不一致: %d != %d" % [definition_count, definitions.size()])
	return EquipmentStore.new(self)

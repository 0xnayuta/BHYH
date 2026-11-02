class_name EquipmentStore
extends RefCounted

## Catalog 的只读查询面。索引在构造时一次建立；不提供可写 all_equipment 字典。

var _catalog: EquipmentCatalog
var _definitions: Dictionary[StringName, EquipmentDefinition] = {}
var _categories: Dictionary[StringName, Array] = {}
var _ids: PackedStringArray = PackedStringArray()


func _init(catalog: EquipmentCatalog) -> void:
	_catalog = catalog
	if _catalog == null:
		push_error("EquipmentStore 需要 EquipmentCatalog")
		return
	for definition in _catalog.definitions:
		if definition == null:
			push_error("EquipmentCatalog 含空定义")
			continue
		if definition.id.is_empty():
			push_error("EquipmentCatalog 含空 ID 定义")
			continue
		if _definitions.has(definition.id):
			push_error("EquipmentCatalog 含重复 ID: " + str(definition.id))
			continue
		_definitions[definition.id] = definition
		if not _categories.has(definition.category):
			_categories[definition.category] = []
		_categories[definition.category].append(definition)
	_ids = PackedStringArray(_definitions.keys())
	_ids.sort()


func catalog() -> EquipmentCatalog:
	return _catalog


func size() -> int:
	return _ids.size()


func has(definition_id: StringName) -> bool:
	return _definitions.has(definition_id)


func definition(definition_id: StringName) -> EquipmentDefinition:
	var result: EquipmentDefinition = _definitions.get(definition_id)
	if result == null:
		push_error("未知装备定义: " + str(definition_id))
	return result


func ids() -> PackedStringArray:
	return _ids.duplicate()


func categories() -> PackedStringArray:
	var result := PackedStringArray(_categories.keys())
	result.sort()
	return result


func by_category(category: StringName) -> Array[EquipmentDefinition]:
	var result: Array[EquipmentDefinition] = []
	var entries: Array = _categories.get(category, [])
	result.assign(entries)
	return result

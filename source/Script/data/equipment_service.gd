class_name EquipmentService
extends RefCounted

## 装备定义与规则的静态服务入口；不新增 Autoload。
## 33-3 用它替换 UI/背包中的旧 AE 字典访问，33-4 再收口 AE。

const CATALOG_PATH := "res://Script/data/equipment_catalog.tres"

static var _store: EquipmentStore
static var _roller: EquipmentRoller
static var _rules: EquipmentRules


static func store() -> EquipmentStore:
	if _store != null:
		return _store
	var catalog := load(CATALOG_PATH) as EquipmentCatalog
	if catalog == null:
		push_error("缺少装备 Catalog: " + CATALOG_PATH)
		return null
	_store = catalog.create_store()
	return _store


static func roller() -> EquipmentRoller:
	if _roller != null:
		return _roller
	var current_store := store()
	if current_store == null:
		return null
	_roller = EquipmentRoller.new(current_store)
	return _roller


static func rules() -> EquipmentRules:
	if _rules != null:
		return _rules
	var current_store := store()
	var current_roller := roller()
	if current_store == null or current_roller == null:
		return null
	_rules = EquipmentRules.new(current_store, current_roller)
	return _rules


static func has(definition_id: StringName) -> bool:
	var current_store := store()
	return current_store != null and current_store.has(definition_id)


static func definition(definition_id: StringName) -> EquipmentDefinition:
	var current_store := store()
	if current_store == null or not current_store.has(definition_id):
		return null
	return current_store.definition(definition_id)


static func ids() -> PackedStringArray:
	var current_store := store()
	return PackedStringArray() if current_store == null else current_store.ids()


static func data(definition_id: StringName) -> Dictionary:
	var current_roller := roller()
	if current_roller == null:
		return {}
	return current_roller.materialize(definition_id)


static func data_or_empty(definition_id: StringName) -> Dictionary:
	if not has(definition_id):
		return {}
	return data(definition_id)


static func find(definition_id: StringName) -> Variant:
	if not has(definition_id):
		return null
	return data(definition_id)


static func reset() -> void:
	_store = null
	_roller = null
	_rules = null

class_name EquipmentRoller
extends RefCounted

## 将 EquipmentDefinition 的随机字段物化为旧字典形状的运行时快照。
## 规格只来自 Resource；不解析旧 all_equipment_data.gd，也不修改 Catalog 定义。

var _store: EquipmentStore
var _cache: Dictionary[StringName, Dictionary] = {}


func _init(store: EquipmentStore) -> void:
	_store = store
	if _store == null:
		push_error("EquipmentRoller 需要 EquipmentStore")


func clear_cache() -> void:
	_cache.clear()


func roll_stats(definition: EquipmentDefinition) -> Dictionary[StringName, Variant]:
	var result: Dictionary[StringName, Variant] = {}
	if definition == null:
		push_error("EquipmentRoller 收到空定义")
		return result
	for field in definition.randomized_fields:
		var field_name := StringName(field)
		var roll: EquipmentStatRoll = definition.random_rolls.get(field_name)
		if roll == null:
			push_error("缺少随机规格: %s.%s" % [definition.id, field])
			continue
		result[field_name] = roll_value(roll)
	return result


func roll_value(roll: EquipmentStatRoll) -> Variant:
	if roll == null:
		push_error("EquipmentRoller 收到空随机规格")
		return 0
	var value: Variant
	match str(roll.sampler):
		"randi":
			value = randi_range(int(round(roll.minimum)), int(round(roll.maximum)))
		"randf":
			value = randf_range(roll.minimum, roll.maximum)
			if roll.step > 0.0:
				if roll.kind == &"int":
					value = snapped(value, int(round(roll.step)))
				else:
					value = snappedf(value, roll.step)
		_:
			push_error("未知随机采样器: " + str(roll.sampler))
			return 0
	if not is_equal_approx(roll.scale, 1.0):
		value = float(value) * roll.scale
	match str(roll.rounding):
		"none":
			pass
		"int_if_integral":
			if is_equal_approx(value, round(value)):
				value = int(round(value))
			else:
				value = snappedf(value, 0.0001)
		"ceil":
			value = int(ceil(float(value)))
		_:
			push_error("未知随机取整规则: " + str(roll.rounding))
			return 0
	return value


func materialize(definition_id: StringName) -> Dictionary:
	if _cache.has(definition_id):
		return _cache[definition_id].duplicate(true)
	if _store == null or not _store.has(definition_id):
		push_error("无法物化未知装备定义: " + str(definition_id))
		return {}
	var definition := _store.definition(definition_id)
	var data := _definition_to_dictionary(definition)
	var rolls := roll_stats(definition)
	for field in rolls:
		data[String(field)] = rolls[field]
	_cache[definition_id] = data
	return data.duplicate(true)


func _definition_to_dictionary(definition: EquipmentDefinition) -> Dictionary:
	var data: Dictionary = {}
	for field in definition.defined_fields:
		match field:
			"名字":
				data[field] = definition.display_name
			"所属":
				data[field] = definition.origin
			"品质":
				data[field] = definition.quality
			"颜色":
				data[field] = definition.color_hex
			"类型":
				data[field] = definition.category
			"描述":
				data[field] = definition.description
			"售价":
				data[field] = definition.price
			"图标":
				data[field] = definition.icon_path
			"装备类型":
				data[field] = definition.equipment_type
			"FBTYPE":
				data[field] = definition.fb_type
			"下一阶段":
				data[field] = definition.next_stage
			"不可神铸":
				data[field] = definition.forge_forbidden
			"强化属性":
				var enhancement: Dictionary = {}
				for key in definition.enhancement:
					enhancement[String(key)] = definition.enhancement[key]
				data[field] = enhancement
			"宝石":
				data[field] = Array(definition.gem_slots)
			"五行":
				data[field] = Array(definition.element)
			"成长率":
				if not definition.is_randomized(&"成长率"):
					data[field] = definition.growth_rate
			_:
				if definition.stats.has(StringName(field)):
					data[field] = definition.stats[StringName(field)]
				elif not definition.is_randomized(StringName(field)):
					push_error("定义字段未映射: %s.%s" % [definition.id, field])
	return data

class_name EquipmentRules
extends RefCounted

## 旧装备规则的服务化出口。输入输出仍使用旧字典形状，供 33-3 分批迁移；
## 定义与随机值从 EquipmentCatalog/EquipmentRoller 读取，不写回 Resource。

const PROP_LIST_NAME = [
	"SHp",
	"SMp",
	"power",
	"Def",
	"Mdef",
	"Crit",
	"Miss",
	"R_hp",
	"R_mp",
	"vampirism",
	"Lucky",
	"toughness",
	"htarget",
	"CritReduce",
	"ar",
	"sp",
]
const DIVINE_FORGE_MAX_STAGE := 9
const DIVINE_FORGE_STAGE_BONUS := 0.3
const DIVINE_FORGE_TYPES := ["武器", "防具", "饰品"]
const DIVINE_FORGE_QUALITY_RANK := {
	"普通": 0,
	"优秀": 1,
	"精良": 2,
	"史诗": 3,
	"邪灵": 4,
	"魂器": 5,
	"传说": 6,
	"神器": 7,
	"玄冥": 8,
	"黑神话": 9,
	"无敌": 10,
}
const DIVINE_FORGE_STAGE_PREFIXES := ["", "一阶·", "二阶·", "三阶·", "四阶·", "五阶·", "六阶·", "七阶·", "八阶·", "九阶·"]
const GEM_RESONANCE_SOCKETS := 8
const GEM_RESONANCE_LEVEL_BONUS := 0.15

var _store: EquipmentStore
var _roller: EquipmentRoller


func _init(store: EquipmentStore, roller: EquipmentRoller = null) -> void:
	_store = store
	_roller = roller if roller != null else EquipmentRoller.new(store)


func clear_cache() -> void:
	if _roller != null:
		_roller.clear_cache()


func _template(definition_id: StringName) -> Dictionary:
	if _store == null or not _store.has(definition_id):
		return {}
	return _roller.materialize(definition_id)


func get_last_equ_pro(definition_id: StringName, qh_level: int, data: Dictionary) -> Dictionary:
	var result: Dictionary = data.duplicate(true)
	var template := _template(definition_id)
	if str(template.get("类型", "")) == "道具":
		return result
	var enhancement: Variant = result.get("强化属性", {})
	if not enhancement is Dictionary:
		enhancement = {}
	for key in result.keys():
		if enhancement.has(key):
			result[key] = enhancement[key] * qh_level + data[key]
	return result


func get_fb_last_equ_pro(_definition_id: StringName, qh_level: int, wxlist: Array, data: Dictionary) -> Dictionary:
	var czl: Variant = data["成长率"]
	var hhp: Variant = czl
	var smp: Variant = czl
	var jpow: Variant = czl
	var tdef: Variant = czl
	if wxlist.has("火"):
		hhp = czl + 1
	if wxlist.has("水"):
		smp = czl + 1
	if wxlist.has("金"):
		jpow = czl + 1
	if wxlist.has("土"):
		tdef = czl + 1
	var result: Dictionary = data.duplicate(true)
	var enhancement: Variant = result.get("强化属性", {})
	if not enhancement is Dictionary:
		enhancement = {}
	for key in result.keys():
		if not enhancement.has(key):
			continue
		match key:
			"SHp":
				result[key] = hhp * enhancement[key] * qh_level + data[key]
			"SMp":
				result[key] = smp * enhancement[key] * qh_level + data[key]
			"power":
				result[key] = jpow * enhancement[key] * qh_level + data[key]
			"Def", "Mdef":
				result[key] = tdef * enhancement[key] * qh_level + data[key]
	return result


func get_divine_forge_stage(data: Dictionary) -> int:
	return clampi(int(data.get("神铸阶段", 0)), 0, DIVINE_FORGE_MAX_STAGE)


func can_divine_forge(definition_id: StringName, data: Dictionary = {}) -> bool:
	var template := _template(definition_id)
	if (
		definition_id not in [&"cjxianjie", &"cdxianjie", &"zhxianjie"]
		and bool(data.get("不可神铸", template.get("不可神铸", false)))
	):
		return false
	var item_type := str(data.get("类型", template.get("类型", "")))
	var quality := str(data.get("品质", template.get("品质", "")))
	var quality_rank := int(DIVINE_FORGE_QUALITY_RANK.get(quality, -1))
	var artifact_rank := int(DIVINE_FORGE_QUALITY_RANK.get("神器", 7))
	return DIVINE_FORGE_TYPES.has(item_type) and quality_rank >= artifact_rank


func get_divine_forge_multiplier(definition_id: StringName, data: Dictionary) -> float:
	if not can_divine_forge(definition_id, data):
		return 1.0
	return 1.0 + float(get_divine_forge_stage(data)) * DIVINE_FORGE_STAGE_BONUS


func scale_divine_forge_value(value: Variant, definition_id: StringName, data: Dictionary) -> Variant:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return value
	var scaled_value: float = float(value) * get_divine_forge_multiplier(definition_id, data)
	if is_equal_approx(scaled_value, round(scaled_value)):
		return int(round(scaled_value))
	return snappedf(scaled_value, 0.0001)


func get_divine_forge_stage_prefix(data: Dictionary) -> String:
	return DIVINE_FORGE_STAGE_PREFIXES[get_divine_forge_stage(data)]


func get_divine_forge_display_name(definition_id: StringName, data: Dictionary) -> String:
	var template := _template(definition_id)
	var base_name := str(data.get("名字", template.get("名字", str(definition_id))))
	if not can_divine_forge(definition_id, data):
		return base_name
	return get_divine_forge_stage_prefix(data) + base_name


func _get_divine_forge_item_data(definition_id: StringName, data: Dictionary) -> Dictionary:
	var item_data := _template(definition_id)
	for key in data:
		item_data[key] = data[key]
	return item_data


func _get_divine_forge_strength_data(definition_id: StringName, data: Dictionary) -> Dictionary:
	var template := _template(definition_id)
	var strength_data: Dictionary = {}
	if template.get("强化属性", {}) is Dictionary:
		strength_data = template.get("强化属性", {}).duplicate(true)
	if data.get("强化属性", {}) is Dictionary:
		for key in data.get("强化属性", {}):
			strength_data[key] = data["强化属性"][key]
	return strength_data


func _get_raw_divine_forge_gem_properties(definition_id: StringName, data: Dictionary) -> Dictionary:
	var gem_properties: Dictionary = {}
	for property_name in PROP_LIST_NAME:
		gem_properties[property_name] = 0
	var item_data := _get_divine_forge_item_data(definition_id, data)
	var gems: Variant = item_data.get("宝石", [])
	if not gems is Array:
		return gem_properties
	for gem_name in gems:
		var gem_data := _template(StringName(str(gem_name)))
		for property_name in PROP_LIST_NAME:
			if gem_data.has(property_name):
				gem_properties[property_name] += gem_data[property_name]
	return gem_properties


func get_gem_resonance_level(data: Dictionary) -> int:
	if str(data.get("类型", "")) == "法宝":
		return 0
	var gems: Variant = data.get("宝石", [])
	if not gems is Array or gems.size() != GEM_RESONANCE_SOCKETS:
		return 0
	var minimum_level := 0
	for gem_id in gems:
		var gem_name := str(gem_id)
		var gem_data := _template(StringName(gem_name))
		var level_text := gem_name.get_slice("_", 1)
		if str(gem_data.get("所属", "")) != "宝石" or not level_text.is_valid_int():
			return 0
		var level := int(level_text)
		if level <= 0:
			return 0
		minimum_level = level if minimum_level == 0 else mini(minimum_level, level)
	return minimum_level


func scale_gem_resonance_value(value: Variant, data: Dictionary) -> Variant:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return value
	var scaled_value := float(value) * (1.0 + get_gem_resonance_level(data) * GEM_RESONANCE_LEVEL_BONUS)
	if is_equal_approx(scaled_value, round(scaled_value)):
		return int(round(scaled_value))
	return snappedf(scaled_value, 0.0001)


func get_divine_forge_gem_properties(definition_id: StringName, data: Dictionary) -> Dictionary:
	var gem_properties := _get_raw_divine_forge_gem_properties(definition_id, data)
	var item_data := _get_divine_forge_item_data(definition_id, data)
	for property_name in PROP_LIST_NAME:
		gem_properties[property_name] = scale_gem_resonance_value(gem_properties[property_name], item_data)
	return gem_properties


func get_divine_forge_properties(
	definition_id: StringName, qh_level: int, data: Dictionary, include_gems := false
) -> Dictionary:
	var item_data := _get_divine_forge_item_data(definition_id, data)
	var strength_data := _get_divine_forge_strength_data(definition_id, item_data)
	var raw_gem_properties: Dictionary = {}
	if include_gems:
		raw_gem_properties = get_divine_forge_gem_properties(definition_id, item_data)
	var result: Dictionary = item_data.duplicate(true)
	result["强化属性"] = strength_data
	for property_name in PROP_LIST_NAME:
		var base_value: float = float(item_data.get(property_name, 0.0))
		var strength_value: float = float(strength_data.get(property_name, 0.0)) * float(qh_level)
		var raw_total: float = base_value + strength_value
		result[property_name] = scale_divine_forge_value(raw_total, definition_id, item_data)
		if include_gems:
			result[property_name] += raw_gem_properties.get(property_name, 0)
	return result


func get_wx() -> Array:
	randomize()
	var wx := {"金": false, "木": false, "水": false, "火": false, "土": false}
	var rr := randi_range(0, 100)
	if rr <= 10:
		var wx_lst := ["金", "木", "水", "火", "土"]
		var aa := randi_range(0, 4)
		var wx_1: String = wx_lst[aa]
		wx_lst.erase(wx_1)
		var bb := randi_range(0, 3)
		var wx_2: String = wx_lst[bb]
		wx_lst.erase(wx_2)
		var cc := randi_range(0, 2)
		var wx_3: String = wx_lst[cc]
		wx[wx_1] = true
		wx[wx_2] = true
		wx[wx_3] = true
		var new_list: Array = []
		for key in wx:
			if wx[key]:
				new_list.push_back(key)
		return new_list
	elif rr > 10 and rr < 30:
		var wx_lst := ["金", "木", "水", "火", "土"]
		var aa := randi_range(0, 4)
		var wx_1: String = wx_lst[aa]
		wx_lst.erase(wx_1)
		var bb := randi_range(0, 3)
		var wx_2: String = wx_lst[bb]
		wx[wx_1] = true
		wx[wx_2] = true
		var new_list: Array = []
		for key in wx:
			if wx[key]:
				new_list.push_back(key)
		return new_list
	else:
		var new_list: Array = []
		var wx_lst := ["金", "木", "水", "火", "土"]
		var aa := randi_range(0, 4)
		new_list.push_back(wx_lst[aa])
		return new_list

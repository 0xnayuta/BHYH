extends Node2D

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var eq_name: Label = $pro_wk/information/inf/VBoxContainer2/eq_name
@onready var eq_pz: Label = $pro_wk/information/inf/VBoxContainer2/eq_pz
@onready var eq_lx: Label = $pro_wk/information/inf/VBoxContainer2/eq_lx
@onready var eq_czl: Label = $pro_wk/information/inf/VBoxContainer3/eq_czl
@onready var eq_star_level: Label = $pro_wk/information/inf/VBoxContainer3/eq_star_level
@onready var eq_hp: Label = $pro_wk/information/inf/VBoxContainer3/eq_hp
@onready var eq_mp: Label = $pro_wk/information/inf/VBoxContainer3/eq_mp
@onready var eq_power: Label = $pro_wk/information/inf/VBoxContainer3/eq_power
@onready var eq_def: Label = $pro_wk/information/inf/VBoxContainer3/eq_def
@onready var eq_mdef: Label = $pro_wk/information/inf/VBoxContainer3/eq_mdef
@onready var eq_crit: Label = $pro_wk/information/inf/VBoxContainer3/eq_crit
@onready var eq_miss: Label = $pro_wk/information/inf/VBoxContainer3/eq_miss
@onready var eq_ehp: Label = $pro_wk/information/inf/VBoxContainer3/eq_ehp
@onready var eq_emp: Label = $pro_wk/information/inf/VBoxContainer3/eq_emp
@onready var eq_mz: Label = $pro_wk/information/inf/VBoxContainer3/eq_mz
@onready var eq_lucky: Label = $pro_wk/information/inf/VBoxContainer3/eq_lucky
@onready var eq_rx: Label = $pro_wk/information/inf/VBoxContainer3/eq_rx
@onready var eq_pj: Label = $pro_wk/information/inf/VBoxContainer3/eq_pj
@onready var eq_pm: Label = $pro_wk/information/inf/VBoxContainer3/eq_pm
@onready var eq_xx: Label = $pro_wk/information/inf/VBoxContainer3/eq_xx
@onready var eq_bm: Label = $pro_wk/information/inf/VBoxContainer3/eq_bm
@onready var eq_ms: Label = $pro_wk/information/inf/VBoxContainer/eq_ms
@onready var eq_sj: Label = $pro_wk/information/inf/VBoxContainer/eq_sj
@onready var color_rect: ColorRect = $ColorRect
@onready var bs_pro_list = $pro_wk/information/inf/BsProp
@onready var have: Label = $pro_wk/information/inf/VBoxContainer2/have
@onready var v_box_container_3: VBoxContainer = $pro_wk/information/inf/VBoxContainer3

@onready var bs_eq_hp: Label = $pro_wk/information/inf/BsProp/eq_hp
@onready var bs_eq_mp: Label = $pro_wk/information/inf/BsProp/eq_mp
@onready var bs_eq_power: Label = $pro_wk/information/inf/BsProp/eq_power
@onready var bs_eq_def: Label = $pro_wk/information/inf/BsProp/eq_def
@onready var bs_eq_mdef: Label = $pro_wk/information/inf/BsProp/eq_mdef
@onready var bs_eq_crit: Label = $pro_wk/information/inf/BsProp/eq_crit
@onready var bs_eq_miss: Label = $pro_wk/information/inf/BsProp/eq_miss
@onready var bs_eq_ehp: Label = $pro_wk/information/inf/BsProp/eq_ehp
@onready var bs_eq_emp: Label = $pro_wk/information/inf/BsProp/eq_emp
@onready var bs_eq_mz: Label = $pro_wk/information/inf/BsProp/eq_mz
@onready var bs_eq_lucky: Label = $pro_wk/information/inf/BsProp/eq_lucky
@onready var bs_eq_rx: Label = $pro_wk/information/inf/BsProp/eq_rx
@onready var bs_eq_pj: Label = $pro_wk/information/inf/BsProp/eq_pj
@onready var bs_eq_pm: Label = $pro_wk/information/inf/BsProp/eq_pm
@onready var bs_eq_xx: Label = $pro_wk/information/inf/BsProp/eq_xx
@onready var bs_eq_bm: Label = $pro_wk/information/inf/BsProp/eq_bm

var bs_prop = {
	"SHp": 0,
	"SMp": 0,
	"power": 0,
	"Def": 0,
	"Mdef": 0,
	"Crit": 0,
	"Miss": 0,
	"R_hp": 0,
	"R_mp": 0,
	"vampirism": 0,
	"Lucky": 0,
	"toughness": 0,
	"htarget": 0,
	"CritReduce": 0,
	"ar": 0,
	"sp": 0
}

var eq_prop = {}
var qh_level: int
var wx = []
var nam: String
var is_set = false
var is_in_ldl_gz = false
var is_in_shop = false
var is_pet_equipment: bool = false
var pet_item: Dictionary = {}
var pet_sale_price: int = 0
var pet_random_labels: Array = []

const DIVINE_PROPERTY_NAMES := [
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
	"sp"
]
const PET_RANDOM_STAT_NAMES := {
	"SHp": "生命",
	"SMp": "魔法",
	"power": "攻击",
	"Def": "物防",
	"Mdef": "魔防",
	"Crit": "暴击",
	"Miss": "闪避",
	"R_hp": "回血",
	"R_mp": "回魔",
	"htarget": "命中",
	"Lucky": "幸运",
	"toughness": "韧性",
	"ar": "破甲",
	"sp": "破魔",
	"vampirism": "吸血",
	"CritReduce": "暴免"
}


func setup_pet_equipment(item: Dictionary, sale_price: int = 0) -> void:
	is_pet_equipment = true
	pet_item = item.duplicate(true)
	pet_sale_price = maxi(0, sale_price)
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	eq_prop = data
	nam = str(
		item.get(
			DataKeys.NAME, item.get(DataKeys.ALT_NAME, data.get(DataKeys.NAME, data.get(DataKeys.ALT_NAME, "宠物装备")))
		)
	)
	qh_level = int(item.get(DataKeys.ENHANCE_LEVEL, data.get(DataKeys.ENHANCE_LEVEL, 0)))


func _pet_merged_data() -> Dictionary:
	var result: Dictionary = {}
	var nested: Variant = pet_item.get("Data", {})
	if nested is Dictionary:
		result.merge((nested as Dictionary).duplicate(true), true)
	result.merge(pet_item, true)
	return result


func _pet_number(source: Dictionary, keys: Array) -> float:
	for key in keys:
		if not source.has(key):
			continue
		var value: Variant = source.get(key, 0)
		if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
			return float(value)
	return 0.0


func _pet_number_text(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(snappedf(value, 0.01))


func _pet_quality_color(quality: String) -> Color:
	return (
		{
			"普通": Color(1, 1, 1),
			"优秀": Color(0.35, 1, 0.35),
			"精良": Color(0.35, 0.7, 1),
			"史诗": Color(0.78, 0.42, 1),
			"邪灵": Color(0.9, 0.3, 0.82),
			"魂器": Color(1, 0.55, 0.18),
			"传说": Color(1, 0.78, 0.18),
			"神器": Color(1, 0.3, 0.2),
			"玄冥": Color(0.3, 0.9, 1),
			"黑神话": Color(0.6, 0, 0),
			"无敌": Color(1, 0.2, 0.2)
		}
		. get(quality, Color(1, 1, 1))
	)


func _set_pet_information() -> void:
	var data := _pet_merged_data()
	var item_name := str(data.get(DataKeys.NAME, data.get(DataKeys.ALT_NAME, nam))).strip_edges()
	if item_name == "":
		item_name = "宠物装备"
	var quality := str(data.get(DataKeys.QUALITY, "普通"))
	eq_name.text = "%s(+%d)" % [item_name, qh_level] if qh_level > 0 else item_name
	eq_pz.text = "品质：%s" % quality
	var raw_type := str(data.get(DataKeys.TYPE, data.get("装备类型", ""))).strip_edges()
	var slot_name := str(
		(
			{
				"zbst": "技能",
				"zbmz": "衣服",
				"zbxz": "鞋子",
				"zbyf": "手套",
				"zbjn": "帽子",
				"技能": "技能",
				"衣服": "衣服",
				"鞋子": "鞋子",
				"手套": "手套",
				"帽子": "帽子"
			}
			. get(raw_type.to_lower(), raw_type)
		)
	)
	eq_lx.text = "类型：宠物装备%s" % ("·" + slot_name if slot_name != "" else "")
	var display_color := _pet_quality_color(quality)
	var item_color: Variant = data.get("颜色", display_color)
	if item_color is Color:
		display_color = item_color
	for title_label in [eq_name, eq_pz]:
		title_label.add_theme_color_override("font_color", display_color)
		title_label.add_theme_color_override("font_outline_color", display_color)

	have.visible = false
	eq_czl.visible = false
	eq_star_level.visible = false
	bs_pro_list.visible = data.get(DataKeys.GEM, []) is Array and not (data.get(DataKeys.GEM, []) as Array).is_empty()
	if bs_pro_list.visible:
		set_bs_infor()
	else:
		_set_gem_resonance_information(data)
	var strengthen_value: Variant = data.get(DataKeys.ENHANCE_PROP, {})
	var strengthen: Dictionary = strengthen_value if strengthen_value is Dictionary else {}
	var rows := [
		[eq_hp, "生命", ["生命", "生命上限", "SHp"]],
		[eq_mp, "魔法", ["魔法", "魔力", "魔法上限", "SMp"]],
		[eq_power, "攻击", ["攻击", "power"]],
		[eq_def, "物防", ["物防", "防御", "Def"]],
		[eq_mdef, "魔防", ["魔防", "Mdef"]],
		[eq_crit, "暴击", ["暴击", "Crit"]],
		[eq_miss, "闪避", ["闪避", "Miss"]],
		[eq_ehp, "回血", ["回血", "R_hp"]],
		[eq_emp, "回魔", ["回魔", "R_mp"]],
		[eq_mz, "命中", ["命中", "htarget"]],
		[eq_lucky, "幸运", ["幸运", "Lucky"]],
		[eq_rx, "韧性", ["韧性", "toughness"]],
		[eq_pj, "破甲", ["破甲", "ar"]],
		[eq_pm, "破魔", ["破魔", "sp"]],
		[eq_xx, "吸血", ["吸血", "vampirism"]],
		[eq_bm, "暴免", ["暴免", "CritReduce"]]
	]
	for row in rows:
		var label := row[0] as Label
		var base_value := _pet_number(data, row[2])
		var strengthen_total := _pet_number(strengthen, row[2]) * float(qh_level)
		label.visible = not is_zero_approx(base_value) or not is_zero_approx(strengthen_total)
		if label.visible:
			label.text = "%s:%s" % [str(row[1]), _pet_number_text(base_value)]
			if not is_zero_approx(strengthen_total):
				var sign := "+" if strengthen_total > 0.0 else ""
				label.text += "(%s%s)" % [sign, _pet_number_text(strengthen_total)]

	_clear_pet_random_labels()
	var random_value: Variant = data.get("随机属性", [])
	var random_stats: Array = random_value if random_value is Array else []
	if random_stats.is_empty():
		_add_pet_random_label("随机属性：拾取时生成4条（属性可重复）", true)
	else:
		_add_pet_random_label("随机属性：", true)
		for random_entry in random_stats:
			if not (random_entry is Dictionary):
				continue
			var random_stat: Dictionary = random_entry
			var stat_key := str(
				random_stat.get("属性", random_stat.get("属性名", random_stat.get("stat", random_stat.get("key", ""))))
			)
			var stat_name := str(PET_RANDOM_STAT_NAMES.get(stat_key, stat_key))
			var base_value := _pet_value(random_stat.get("数值", random_stat.get("基础值", random_stat.get("value", 0))))
			var strengthen_per_level := _pet_value(
				random_stat.get(DataKeys.ENHANCE_PROP, random_stat.get("强化值", random_stat.get("strength", 0)))
			)
			var line := "  %s+%s" % [stat_name, _pet_number_text(base_value)]
			if not is_zero_approx(strengthen_per_level):
				line += "（强化+%s/级" % _pet_number_text(strengthen_per_level)
				if qh_level > 0:
					line += "，当前+%s" % _pet_number_text(strengthen_per_level * float(qh_level))
				line += "）"
			_add_pet_random_label(line)

	var description := str(data.get("描述", "")).strip_edges()
	eq_ms.visible = description != ""
	if eq_ms.visible:
		eq_ms.text = "描述:%s" % description
	eq_sj.visible = pet_sale_price > 0
	if eq_sj.visible:
		eq_sj.text = "售价:%d灵魂。" % pet_sale_price
	call_deferred("_update_pet_popup_background")


func _clear_pet_random_labels() -> void:
	for label_value in pet_random_labels:
		if label_value is Label and is_instance_valid(label_value):
			(label_value as Label).queue_free()
	pet_random_labels.clear()


func _add_pet_random_label(text_value: String, is_header := false) -> void:
	if v_box_container_3 == null:
		return
	var label := Label.new()
	label.text = text_value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 16 if not is_header else 15)
	label.add_theme_color_override("font_color", Color(1, 0.6, 0.2, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 1)
	v_box_container_3.add_child(label)
	pet_random_labels.append(label)


func _pet_value(value: Variant) -> float:
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return float(value)
	if value is String and (value as String).strip_edges().is_valid_float():
		return float(value)
	return 0.0


func _update_pet_popup_background() -> void:
	if is_pet_equipment and is_instance_valid(color_rect):
		color_rect.size = $pro_wk/information.size


func _call_divine_helper(method_names: Array, args: Array):
	for method_name in method_names:
		if AE.has_method(method_name):
			return AE.callv(method_name, args)

	if AE.has_method("_get_data"):
		var data_node = AE.call("_get_data")
		if data_node != null:
			for method_name in method_names:
				if data_node.has_method(method_name):
					return data_node.callv(method_name, args)
	return null


func _is_divine_eligible(_name: String, data: Dictionary) -> bool:
	var template: Dictionary = AE.all_equipment.get(_name, {})
	var item_type := str(data.get(DataKeys.TYPE, template.get(DataKeys.TYPE, "")))
	var quality := str(data.get(DataKeys.QUALITY, template.get(DataKeys.QUALITY, "")))
	var quality_rank := {
		"普通": 0, "优秀": 1, "精良": 2, "史诗": 3, "邪灵": 4, "魂器": 5, "传说": 6, "神器": 7, "玄冥": 8, "黑神话": 9, "无敌": 10
	}
	return ["武器", "防具", "饰品"].has(item_type) and int(quality_rank.get(quality, -1)) >= 7


func _get_divine_stage(data: Dictionary) -> int:
	var stage = _call_divine_helper(["get_divine_forge_stage"], [data])
	if stage == null:
		stage = data.get("神铸阶段", 0)
	return clampi(int(stage), 0, 9)


func _get_divine_multiplier(_name: String, data: Dictionary) -> float:
	var multiplier = _call_divine_helper(["get_divine_forge_multiplier"], [_name, data])
	if multiplier == null:
		return 1.0 + float(_get_divine_stage(data)) * 0.3 if _is_divine_eligible(_name, data) else 1.0
	return float(multiplier)


func _scale_divine_value(value, _name: String, data: Dictionary):
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return value
	var scaled = _call_divine_helper(["scale_divine_forge_value"], [value, _name, data])
	if scaled != null:
		return scaled
	return float(value) * _get_divine_multiplier(_name, data)


func _get_divine_display_name(_name: String) -> String:
	var display_name = _call_divine_helper(
		["get_divine_forge_display_name", "get_equipment_display_name"], [_name, eq_prop]
	)
	if display_name != null:
		return str(display_name)
	var base_name := str(eq_prop.get(DataKeys.NAME, AE.all_equipment.get(_name, {}).get(DataKeys.NAME, _name)))
	var prefixes := ["", "一阶·", "二阶·", "三阶·", "四阶·", "五阶·", "六阶·", "七阶·", "八阶·", "九阶·"]
	return prefixes[_get_divine_stage(eq_prop)] + base_name if _is_divine_eligible(_name, eq_prop) else base_name


func _get_divine_properties(_name: String, level: int, data: Dictionary, include_gems := false) -> Dictionary:
	var properties = _call_divine_helper(
		["get_divine_forge_properties", "get_divine_forge_props"], [_name, level, data, include_gems]
	)
	if properties is Dictionary:
		return properties
	return {}


func _get_divine_gem_properties(_name: String, data: Dictionary) -> Dictionary:
	var properties = _call_divine_helper(
		["get_divine_forge_gem_properties", "get_divine_forge_gem_props"], [_name, data]
	)
	if properties is Dictionary:
		return properties
	var result := {}
	for property_name in DIVINE_PROPERTY_NAMES:
		result[property_name] = 0
	if not data.has(DataKeys.GEM) or not data[DataKeys.GEM] is Array:
		return result
	for gem_name in data[DataKeys.GEM]:
		var gem_data: Dictionary = AE.all_equipment.get(str(gem_name), {})
		for property_name in DIVINE_PROPERTY_NAMES:
			if gem_data.has(property_name):
				result[property_name] += AE.scale_gem_resonance_value(gem_data[property_name], data)
	return result


func _ready() -> void:
	self.modulate = Color(1, 1, 1, 0)


func _physics_process(_delta: float) -> void:
	if get_parent().get_script() != null and get_parent().get_script().resource_path.ends_with("BackPack.gdc"):
		if self.position.y + color_rect.size.y >= 320:
			self.position.y = 320 - color_rect.size.y
		if self.position.x + color_rect.size.x >= 495:
			self.position.x = 270 - color_rect.size.x
	elif get_parent() == Global.get_ui_runtime().windows:
		var viewport_size := get_viewport().get_visible_rect().size
		if self.position.y + color_rect.size.y >= viewport_size.y:
			self.position.y = viewport_size.y - color_rect.size.y - 8.0
		if self.position.x + color_rect.size.x >= viewport_size.x:
			self.position.x = get_tree().get_root().get_mouse_position().x - color_rect.size.x - 25.0
		if self.position.x < 8.0:
			self.position.x = 8.0
		if self.position.y < 8.0:
			self.position.y = 8.0
	if is_pet_equipment:
		color_rect.size = $pro_wk/information.size
		if not is_set:
			create_tween().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
			_set_pet_information()
			is_set = true
		return
	if nam == "empty":
		return
	color_rect.size = $pro_wk/information.size
	if bs_pro_list != null:
		if eq_prop != {}:
			if eq_prop.has(DataKeys.GEM):
				if eq_prop[DataKeys.GEM].size() == 0:
					bs_pro_list.queue_free()
	if not is_set:
		create_tween().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
		set_some_pro_color(nam)
		_set_equipment_info(nam)
		if AE.all_equipment[nam][DataKeys.TYPE] != "道具" and AE.all_equipment[nam][DataKeys.TYPE] != "消耗品":
			have.queue_free()
			set_bs_infor()
		else:
			if v_box_container_3 != null:
				v_box_container_3.queue_free()
			if bs_pro_list != null:
				bs_pro_list.queue_free()
		is_set = true


func set_some_pro_color(_name):
	if str(AE.all_equipment[_name].get(DataKeys.QUALITY, "")) == "黑神话":
		_apply_black_myth_text_style(eq_name)
		_apply_black_myth_text_style(eq_pz)
		return
	eq_name.add_theme_color_override("font_color", AE.all_equipment[_name]["颜色"])
	eq_name.add_theme_color_override("font_outline_color", AE.all_equipment[_name]["颜色"])
	eq_pz.add_theme_color_override("font_color", AE.all_equipment[_name]["颜色"])
	eq_pz.add_theme_color_override("font_outline_color", AE.all_equipment[_name]["颜色"])


func _apply_black_myth_text_style(label: Label) -> void:
	label.add_theme_color_override("font_color", Color(0.6, 0.0, 0.0, 1.0))


func _set_equipment_info(_name: String):
	if AE.all_equipment[_name][DataKeys.TYPE] == "道具" or AE.all_equipment[_name][DataKeys.TYPE] == "消耗品":
		eq_name.text = str(AE.all_equipment[_name][DataKeys.NAME])
		eq_pz.text = "品质：" + str(AE.all_equipment[_name][DataKeys.QUALITY])
		if AE.all_equipment[_name].has("所属"):
			if AE.all_equipment[_name]["所属"] != "" and AE.all_equipment[_name]["所属"] != "无":
				eq_lx.text = (
					"类型：" + str(AE.all_equipment[_name][DataKeys.TYPE]) + "·" + str(AE.all_equipment[_name]["所属"])
				)
			else:
				eq_lx.text = "类型：" + str(AE.all_equipment[_name][DataKeys.TYPE])
		else:
			eq_lx.text = "类型：" + str(AE.all_equipment[_name][DataKeys.TYPE])
		if str(AE.all_equipment[_name][DataKeys.TYPE]) == "消耗品":
			have.text = "拥有：" + str(PlayerData.get_xhp_data(_name)) + " 个"
		else:
			have.text = "拥有：" + str(PlayerData.get_item_data(_name)) + " 个"
		if AE.all_equipment[_name]["描述"] == "" and eq_ms != null:
			eq_ms.queue_free()
		else:
			eq_ms.text = "描述:" + str(AE.all_equipment[_name]["描述"])
		eq_sj.text = "售价:" + str(AE.all_equipment[_name]["售价"]) + "灵魂。"
		return

	var equipment_data_source: Node = AE._get_data()
	var display_name: String = equipment_data_source.get_divine_forge_display_name(_name, eq_prop)
	if qh_level != 0:
		eq_name.text = display_name + "(+" + str(qh_level) + ")"
	else:
		eq_name.text = display_name
	eq_pz.text = "品质：" + str(get_properies(_name, "品质")[0])
	eq_lx.text = "类型：" + str(get_properies(_name, "类型")[0]) + "·" + str(get_properies(_name, "所属")[0])
	match get_properies(_name, "类型")[0]:
		"法宝":
			if not AE.all_equipment[_name].has(DataKeys.FIVE_ELEMENTS) and eq_star_level != null:
				eq_star_level.queue_free()
			else:
				if get_wx() == "":
					eq_star_level.text = "五行：随机"
				else:
					eq_star_level.text = "五行：" + str(get_wx())
			if get_fb_pro(_name, "成长率") == 0 and eq_czl != null:
				eq_czl.queue_free()
			else:
				eq_czl.text = "成长率: " + str(get_fb_pro(_name, "成长率"))
			if get_fb_pro(_name, "SHp") == 0 and eq_hp != null:
				eq_hp.queue_free()
			else:
				eq_hp.text = "生命:" + str(get_fb_pro(_name, "SHp"))

			if get_fb_pro(_name, "SMp") == 0 and eq_mp != null:
				eq_mp.queue_free()
			else:
				eq_mp.text = "魔法:" + str(get_fb_pro(_name, "SMp"))

			if get_fb_pro(_name, "power") == 0 and eq_power != null:
				eq_power.queue_free()
			else:
				eq_power.text = "攻击:" + str(get_fb_pro(_name, "power"))

			if get_fb_pro(_name, "Def") == 0 and eq_def != null:
				eq_def.queue_free()
			else:
				eq_def.text = "物防:" + str(get_fb_pro(_name, "Def"))

			if get_fb_pro(_name, "Mdef") == 0 and eq_mdef != null:
				eq_mdef.queue_free()
			else:
				eq_mdef.text = "魔防:" + str(get_fb_pro(_name, "Mdef"))

			if get_properies(_name, "Crit")[0] == 0 and eq_crit != null:
				eq_crit.queue_free()
			else:
				eq_crit.text = "暴击:" + str(get_properies(_name, "Crit")[0])

			if get_properies(_name, "Miss")[0] == 0 and eq_miss != null:
				eq_miss.queue_free()
			else:
				eq_miss.text = "闪避:" + str(get_properies(_name, "Miss")[0])

			if get_properies(_name, "R_hp")[0] == 0 and eq_ehp != null:
				eq_ehp.queue_free()
			else:
				eq_ehp.text = "回血:" + str(get_properies(_name, "R_hp")[0])

			if get_properies(_name, "R_mp")[0] == 0 and eq_emp != null:
				eq_emp.queue_free()
			else:
				eq_emp.text = "回魔:" + str(get_properies(_name, "R_mp")[0])

			if get_properies(_name, "htarget")[0] == 0 and eq_mz != null:
				eq_mz.queue_free()
			else:
				eq_mz.text = "命中:" + str(get_properies(_name, "htarget")[0])

			if get_properies(_name, "Lucky")[0] == 0 and eq_lucky != null:
				eq_lucky.queue_free()
			else:
				eq_lucky.text = "幸运:" + str(get_properies(_name, "Lucky")[0])

			if get_properies(_name, "toughness")[0] == 0 and eq_rx != null:
				eq_rx.queue_free()
			else:
				eq_rx.text = "韧性:" + str(get_properies(_name, "toughness")[0])

			if get_properies(_name, "ar")[0] == 0 and eq_pj != null:
				eq_pj.queue_free()
			else:
				eq_pj.text = "破甲:" + str(get_properies(_name, "ar")[0])

			if get_properies(_name, "sp")[0] == 0 and eq_pm != null:
				eq_pm.queue_free()
			else:
				eq_pm.text = "破魔:" + str(get_properies(_name, "sp")[0])

			if get_properies(_name, "vampirism")[0] == 0 and eq_xx != null:
				eq_xx.queue_free()
			else:
				eq_xx.text = "吸血:" + str(get_properies(_name, "vampirism")[0])

			if get_properies(_name, "CritReduce")[0] == 0 and eq_bm != null:
				eq_bm.queue_free()
			else:
				eq_bm.text = "暴免:" + str(get_properies(_name, "CritReduce")[0])

			if AE.all_equipment[_name]["描述"] == "" and eq_ms != null:
				eq_ms.queue_free()
			else:
				eq_ms.text = "描述:" + str(AE.all_equipment[_name]["描述"])
		"武器", "防具", "饰品", "神骨", "头衔", "时装", "翅膀":
			if not AE.all_equipment[_name].has(DataKeys.FIVE_ELEMENTS) and eq_star_level != null:
				eq_star_level.queue_free()
			else:
				eq_star_level.text = "五行：" + str(get_wx())
			if eq_czl != null:
				eq_czl.queue_free()
			if get_properies(_name, "SHp")[0] == 0 and eq_hp != null:
				eq_hp.queue_free()
			else:
				eq_hp.text = "生命:" + str(get_properies(_name, "SHp")[1])

			if get_properies(_name, "SMp")[0] == 0 and eq_mp != null:
				eq_mp.queue_free()
			else:
				eq_mp.text = "魔法:" + str(get_properies(_name, "SMp")[1])

			if get_properies(_name, "power")[0] == 0 and eq_power != null:
				eq_power.queue_free()
			else:
				eq_power.text = "攻击:" + str(get_properies(_name, "power")[1])

			if get_properies(_name, "Def")[0] == 0 and eq_def != null:
				eq_def.queue_free()
			else:
				eq_def.text = "物防:" + str(get_properies(_name, "Def")[1])

			if get_properies(_name, "Mdef")[0] == 0 and eq_mdef != null:
				eq_mdef.queue_free()
			else:
				eq_mdef.text = "魔防:" + str(get_properies(_name, "Mdef")[1])

			if get_properies(_name, "Crit")[0] == 0 and eq_crit != null:
				eq_crit.queue_free()
			else:
				eq_crit.text = "暴击:" + str(get_properies(_name, "Crit")[1])

			if get_properies(_name, "Miss")[0] == 0 and eq_miss != null:
				eq_miss.queue_free()
			else:
				eq_miss.text = "闪避:" + str(get_properies(_name, "Miss")[1])

			if get_properies(_name, "R_hp")[0] == 0 and eq_ehp != null:
				eq_ehp.queue_free()
			else:
				eq_ehp.text = "回血:" + str(get_properies(_name, "R_hp")[1])

			if get_properies(_name, "R_mp")[0] == 0 and eq_emp != null:
				eq_emp.queue_free()
			else:
				eq_emp.text = "回魔:" + str(get_properies(_name, "R_mp")[1])

			if get_properies(_name, "htarget")[0] == 0 and eq_mz != null:
				eq_mz.queue_free()
			else:
				eq_mz.text = "命中:" + str(get_properies(_name, "htarget")[1])

			if get_properies(_name, "Lucky")[0] == 0 and eq_lucky != null:
				eq_lucky.queue_free()
			else:
				eq_lucky.text = "幸运:" + str(get_properies(_name, "Lucky")[1])

			if get_properies(_name, "toughness")[0] == 0 and eq_rx != null:
				eq_rx.queue_free()
			else:
				eq_rx.text = "韧性:" + str(get_properies(_name, "toughness")[1])

			if get_properies(_name, "ar")[0] == 0 and eq_pj != null:
				eq_pj.queue_free()
			else:
				eq_pj.text = "破甲:" + str(get_properies(_name, "ar")[1])

			if get_properies(_name, "sp")[0] == 0 and eq_pm != null:
				eq_pm.queue_free()
			else:
				eq_pm.text = "破魔:" + str(get_properies(_name, "sp")[1])

			if get_properies(_name, "vampirism")[0] == 0 and eq_xx != null:
				eq_xx.queue_free()
			else:
				eq_xx.text = "吸血:" + str(get_properies(_name, "vampirism")[1])

			if get_properies(_name, "CritReduce")[0] == 0 and eq_bm != null:
				eq_bm.queue_free()


func set_bs_infor():
	if not is_pet_equipment and str(AE.all_equipment.get(nam, {}).get(DataKeys.TYPE, "")) == "法宝":
		bs_pro_list.hide()
		return
	if not eq_prop.has(DataKeys.GEM):
		self.queue_free()
		return
	_set_gem_resonance_information(eq_prop)
	for child in bs_pro_list.get_children():
		child.queue_free()
	if eq_prop[DataKeys.GEM].size() == 0:
		return

	var prop_names = {
		"SHp": "生命",
		"SMp": "魔力",
		"power": "攻击",
		"Def": "防御",
		"Mdef": "魔防",
		"Crit": "暴击",
		"Miss": "闪避",
		"R_hp": "回血",
		"R_mp": "回魔",
		"htarget": "命中",
		"Lucky": "幸运",
		"toughness": "韧性",
		"ar": "破甲",
		"sp": "破魔",
		"vampirism": "吸血",
		"CritReduce": "暴免"
	}

	var equipment_data_source: Node = AE._get_data()
	for i in eq_prop[DataKeys.GEM]:
		var gem_data = AE.all_equipment.get(i)
		if gem_data == null:
			continue

		var gem_name = gem_data.get(DataKeys.NAME, str(i))

		var props_text = ""
		for u in [
			"SHp",
			"SMp",
			"power",
			"Def",
			"Mdef",
			"Crit",
			"Miss",
			"R_hp",
			"R_mp",
			"htarget",
			"Lucky",
			"toughness",
			"ar",
			"sp",
			"vampirism",
			"CritReduce"
		]:
			if gem_data.has(u) and gem_data[u] != 0:
				var display_name = prop_names.get(u, u)
				var scaled_value = equipment_data_source.scale_gem_resonance_value(gem_data[u], eq_prop)
				props_text += " " + display_name + "+" + str(scaled_value)

		var hbox = HBoxContainer.new()
		hbox.alignment = 0
		bs_pro_list.add_child(hbox)

		var icon_path = "res://Art/backpack/all_items/" + str(i) + ".png"
		var tex = load(icon_path)
		if tex != null:
			var icon = TextureRect.new()
			icon.texture = tex
			icon.custom_minimum_size = Vector2(15, 15)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			hbox.add_child(icon)

		var label = Label.new()
		label.text = gem_name + " " + props_text
		hbox.add_child(label)


func _set_gem_resonance_information(data: Dictionary) -> void:
	var gems: Variant = data.get(DataKeys.GEM, null)
	if not gems is Array:
		return
	var resonance := AE.get_gem_resonance_level(data)
	var container := bs_pro_list.get_parent()
	var label := container.get_node_or_null("GemResonance") as Label
	if label == null:
		label = Label.new()
		label.name = "GemResonance"
		var font_override = eq_lx.get_theme_font("font")
		if font_override != null:
			label.add_theme_font_override("font", font_override)
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color("e8c478"))
		container.add_child(label)
		container.move_child(label, bs_pro_list.get_index())
	if resonance > 0:
		label.text = "宝石共鸣：%d级\n宝石属性加成：+%d%%" % [resonance, resonance * 15]
	else:
		label.text = "宝石共鸣：未开启（%d/8）" % gems.size()


func get_bs_prop(need):
	if set_bs_prop() == {}:
		return 0
	else:
		var information = set_bs_prop()[need]
		return information


func set_bs_prop():
	if eq_prop == null or not eq_prop.has(DataKeys.GEM):
		return {}
	var equipment_data_source: Node = AE._get_data()
	var divine_gem_properties: Dictionary = equipment_data_source.get_divine_forge_gem_properties(nam, eq_prop)
	for property_name in bs_prop:
		bs_prop[property_name] = divine_gem_properties.get(property_name, 0)
	if eq_prop[DataKeys.GEM].is_empty():
		return {}
	return bs_prop


func get_properies(_name, need):
	var target_count
	var infomation
	infomation = get_last_equ_pro(_name, qh_level)
	if infomation == null:
		self.queue_free()
		return [null, null]
	if not infomation.has(need):
		self.queue_free()
		return [null, null]
	infomation = infomation[need]
	if typeof(infomation) == TYPE_STRING:
		return [infomation]
	else:
		target_count = infomation

		var strengthen_val = 0
		if eq_prop.has(DataKeys.ENHANCE_PROP) and eq_prop[DataKeys.ENHANCE_PROP].has(need):
			strengthen_val = eq_prop[DataKeys.ENHANCE_PROP][need]
		elif (
			AE.all_equipment[_name].has(DataKeys.ENHANCE_PROP)
			and AE.all_equipment[_name][DataKeys.ENHANCE_PROP].has(need)
		):
			strengthen_val = AE.all_equipment[_name][DataKeys.ENHANCE_PROP][need]

		var equipment_data_source: Node = AE._get_data()
		var base_value = eq_prop.get(need, AE.all_equipment[_name].get(need, 0))
		var scaled_base = equipment_data_source.scale_divine_forge_value(base_value, _name, eq_prop)
		var scaled_strength = equipment_data_source.scale_divine_forge_value(
			float(strengthen_val) * float(qh_level), _name, eq_prop
		)
		infomation = str(scaled_base)
		if qh_level > 0 and strengthen_val != 0:
			var sign := "+" if float(scaled_strength) >= 0.0 else ""
			infomation += "(" + sign + str(scaled_strength) + ")"
	return [target_count, infomation]


func get_last_equ_pro(_name_, qh_level_):
	if eq_prop == null:
		return
	return AE._get_data().get_divine_forge_properties(_name_, qh_level_, eq_prop)


func _get_display_name():
	var _name = str(self.get_parent().get_item_name)
	return _name


func get_wx():
	var a = ""
	for i in wx:
		a = a + str(i)
	return a


func get_fb_pro(_name, need):
	var infomation = AE.get_fb_last_equ_pro(_name, qh_level, wx, eq_prop)[need]
	return infomation


## ESC 分层关闭：只关闭装备属性浮层。
func request_escape_close() -> bool:
	queue_free()
	return true

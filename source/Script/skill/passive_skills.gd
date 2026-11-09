extends Node

var PlayerData: PlayerDataStore:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		if coop != null:
			return coop.data_for(self) as PlayerDataStore
		return get_tree().root.get_node_or_null("PlayerData") as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		if coop != null:
			return coop.props_for(self) as BaseRoleProperties
		return get_tree().root.get_node_or_null("RoleProp") as BaseRoleProperties

var need_lh_list = [
	5000,
	10000,
	15000,
	20000,
	25000,
	30000,
	35000,
	40000,
	45000,
	50000,
	55000,
	60000,
	65000,
	70000,
	75000,
	80000,
	85000,
	90000,
	95000,
	100000,
	105000
]
var rx_value = [
	0, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100
]
var mq_value = [0, 100, 130, 160, 200, 240, 280, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000]
var kb_value = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
var yh_value = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
var hh_value = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
var mr_value = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]

var _last_passive_levels := PackedInt32Array([-1, -1, -1, -1, -1, -1, -1])
var _last_props_id: int = 0


func _ready() -> void:
	PlayerData.passive_skills_changed.connect(get_passive_skill_properties)
	get_passive_skill_properties()


func get_unlocked_level(source_level: int) -> int:
	return int(max(0, source_level) / 3)


func _extend_linear(values: Array, level: int) -> int:
	if level <= 0:
		return int(values[0])
	if level < values.size():
		return int(values[level])
	var last_index = values.size() - 1
	var step = int(values[last_index]) - int(values[last_index - 1])
	return int(values[last_index]) + step * (level - last_index)


func get_value(_name: String, level: int) -> int:
	match _name:
		DataKeys.Skill.PASSIVE_HP:
			return _extend_linear(rx_value, level)
		DataKeys.Skill.PASSIVE_MP:
			return _extend_linear(mq_value, level)
		DataKeys.Skill.PASSIVE_CRIT:
			return _extend_linear(kb_value, level)
		DataKeys.Skill.PASSIVE_HP_REGEN:
			return _extend_linear(yh_value, level)
		DataKeys.Skill.PASSIVE_MP_REGEN:
			return _extend_linear(hh_value, level)
		DataKeys.Skill.PASSIVE_HIT:
			return _extend_linear(mr_value, level)
		DataKeys.Skill.PASSIVE_SOUL_GAIN:
			return max(0, level) * 5
	return 0


func get_soul_gain_bonus_percent() -> int:
	var passive_value: Variant = PlayerData.player_data.get(DataKeys.Skill.PASSIVE, {})
	if not (passive_value is Dictionary):
		return 0
	var passive_levels: Dictionary = passive_value
	return get_value(DataKeys.Skill.PASSIVE_SOUL_GAIN, int(passive_levels.get(DataKeys.Skill.PASSIVE_SOUL_GAIN, 0)))


func apply_soul_gain_bonus(base_value: int) -> int:
	if base_value <= 0:
		return base_value
	return int(float(base_value) * float(100 + get_soul_gain_bonus_percent()) / 100.0)


func get_passive_skill_properties() -> void:
	var passive_value: Variant = PlayerData.player_data.get(DataKeys.Skill.PASSIVE, {})
	if not (passive_value is Dictionary):
		return
	var target: Dictionary = passive_value
	var props := RoleProp
	var props_id := props.get_instance_id()
	var levels := PackedInt32Array(
		[
			int(target.get(DataKeys.Skill.PASSIVE_HP, 0)),
			int(target.get(DataKeys.Skill.PASSIVE_MP, 0)),
			int(target.get(DataKeys.Skill.PASSIVE_CRIT, 0)),
			int(target.get(DataKeys.Skill.PASSIVE_HP_REGEN, 0)),
			int(target.get(DataKeys.Skill.PASSIVE_MP_REGEN, 0)),
			int(target.get(DataKeys.Skill.PASSIVE_HIT, 0)),
			int(target.get(DataKeys.Skill.PASSIVE_SOUL_GAIN, 0)),
		]
	)
	if props_id == _last_props_id and levels == _last_passive_levels:
		return
	_last_props_id = props_id
	_last_passive_levels = levels
	props.pasl_prop.SHp = get_value(DataKeys.Skill.PASSIVE_HP, levels[0])
	props.pasl_prop.SMp = get_value(DataKeys.Skill.PASSIVE_MP, levels[1])
	props.pasl_prop.Crit = get_value(DataKeys.Skill.PASSIVE_CRIT, levels[2])
	props.pasl_prop.R_hp = get_value(DataKeys.Skill.PASSIVE_HP_REGEN, levels[3])
	props.pasl_prop.R_mp = get_value(DataKeys.Skill.PASSIVE_MP_REGEN, levels[4])
	props.pasl_prop.htarget = get_value(DataKeys.Skill.PASSIVE_HIT, levels[5])


func get_lh(_name):
	return get_lh_for_level(_name, int(PlayerData.player_data[DataKeys.Skill.PASSIVE].get(_name, 0)))


func get_lh_for_level(_name: String, level: int) -> int:
	var get_level := maxi(0, level)
	if get_level < need_lh_list.size():
		return need_lh_list[get_level]
	return 5000 * (get_level + 1)

extends Node

## 玩家被动技能单例：持有玩家槽位的 pasl_prop 快照。
## 数值规则由 PassiveSkillTable 提供；本类不轮询，刷新由 PlayerData.passive_skills_changed 驱动。

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

var _last_passive_levels := PackedInt32Array([-1, -1, -1, -1, -1, -1, -1])
var _last_props_id: int = 0


func _ready() -> void:
	PlayerData.passive_skills_changed.connect(get_passive_skill_properties)
	get_passive_skill_properties()


func get_unlocked_level(source_level: int) -> int:
	return PassiveSkillTable.get_unlocked_level(source_level)


func get_value(_name: String, level: int) -> int:
	return PassiveSkillTable.get_value(_name, level)


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
	return PassiveSkillTable.get_cost_for_level(level)

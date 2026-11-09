class_name PassiveSkillTable
extends RefCounted

## 玩家与宠物被动技能共用的只读等级→数值表。
## 无状态，不读写档案；调用方不得在此写入快照或灵魂。

const NEED_LH_LIST := [
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
	105000,
]
const RX_VALUE := [
	0, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100
]
const MQ_VALUE := [
	0, 100, 130, 160, 200, 240, 280, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000
]
const KB_VALUE := [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
const YH_VALUE := [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
const HH_VALUE := [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
const MR_VALUE := [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]


static func get_unlocked_level(source_level: int) -> int:
	return int(max(0, source_level) / 3)


static func _extend_linear(values: Array, level: int) -> int:
	if level <= 0:
		return int(values[0])
	if level < values.size():
		return int(values[level])
	var last_index := values.size() - 1
	var step := int(values[last_index]) - int(values[last_index - 1])
	return int(values[last_index]) + step * (level - last_index)


static func get_value(skill_name: String, level: int) -> int:
	match skill_name:
		DataKeys.Skill.PASSIVE_HP:
			return _extend_linear(RX_VALUE, level)
		DataKeys.Skill.PASSIVE_MP:
			return _extend_linear(MQ_VALUE, level)
		DataKeys.Skill.PASSIVE_CRIT:
			return _extend_linear(KB_VALUE, level)
		DataKeys.Skill.PASSIVE_HP_REGEN:
			return _extend_linear(YH_VALUE, level)
		DataKeys.Skill.PASSIVE_MP_REGEN:
			return _extend_linear(HH_VALUE, level)
		DataKeys.Skill.PASSIVE_HIT:
			return _extend_linear(MR_VALUE, level)
		DataKeys.Skill.PASSIVE_SOUL_GAIN:
			return max(0, level) * 5
	return 0


static func get_cost_for_level(level: int) -> int:
	var get_level := maxi(0, level)
	if get_level < NEED_LH_LIST.size():
		return NEED_LH_LIST[get_level]
	return 5000 * (get_level + 1)

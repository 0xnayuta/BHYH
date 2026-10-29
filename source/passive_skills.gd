extends Node

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
var ps_value = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]


func _physics_process(_delta: float) -> void:
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
		"热血":
			return _extend_linear(rx_value, level)
		"魔泉":
			return _extend_linear(mq_value, level)
		"狂暴":
			return _extend_linear(kb_value, level)
		"永恒":
			return _extend_linear(yh_value, level)
		"辉煌":
			return _extend_linear(hh_value, level)
		"敏锐":
			return _extend_linear(mr_value, level)
		"收益":
			return max(0, level) * 5
	return 0


func get_soul_gain_bonus_percent() -> int:
	var passive_value: Variant = PlayerData.player_data.get("被动技能", {})
	if not (passive_value is Dictionary):
		return 0
	var passive_levels: Dictionary = passive_value
	return get_value("收益", int(passive_levels.get("收益", 0)))


func apply_soul_gain_bonus(base_value: int) -> int:
	if base_value <= 0:
		return base_value
	return int(float(base_value) * float(100 + get_soul_gain_bonus_percent()) / 100.0)


func get_passive_skill_properties():
	var target = PlayerData.player_data["被动技能"]
	RoleProp.pasl_prop.SHp = get_value("热血", int(target["热血"]))
	RoleProp.pasl_prop.SMp = get_value("魔泉", int(target["魔泉"]))
	RoleProp.pasl_prop.Crit = get_value("狂暴", int(target["狂暴"]))
	RoleProp.pasl_prop.R_hp = get_value("永恒", int(target["永恒"]))
	RoleProp.pasl_prop.R_mp = get_value("辉煌", int(target["辉煌"]))
	RoleProp.pasl_prop.htarget = get_value("敏锐", int(target["敏锐"]))


func get_lh(_name):
	return get_lh_for_level(_name, int(PlayerData.player_data["被动技能"].get(_name, 0)))


func get_lh_for_level(_name: String, level: int) -> int:
	var get_level := maxi(0, level)
	if get_level < need_lh_list.size():
		return need_lh_list[get_level]
	return 5000 * (get_level + 1)

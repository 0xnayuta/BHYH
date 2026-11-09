## 7.4 魂卡/精英系统；由 7.4 反编译参考按当前 API、命名与路径适配。
extends RefCounted

const DATA = preload("res://Script/data/soul_card_data.gd")


static func snapshot(enemy: BaseMonster) -> Dictionary:
	return {
		"hp": enemy.get_health_without_coop(),
		"level": enemy.level,
		"def": enemy.def,
		"mdef": enemy.mdef,
		"ar": enemy.ar,
		"sp": enemy.sp,
		"hit": enemy.htarget,
		"crit": enemy.crit,
		"miss": enemy.miss,
		"attacks": enemy.obj_attack_dict.duplicate(true)
	}


static func calculate(base: Dictionary, id: String, tier: int, coop: bool = false) -> Dictionary:
	var result = base.duplicate(true)
	var group = int(DATA.CARDS[id].group)
	var heaven = group in [0, 3]
	var underworld = group == 1
	var hp_bonus = (
		BaseMonster.HEAVEN_NIGHTMARE_HEALTH_BONUS
		if heaven
		else BaseMonster.UNDERWORLD_NIGHTMARE_HEALTH_BONUS if underworld else BaseMonster.NIGHTMARE_HEALTH_BONUS
	)
	var atk_bonus = (
		BaseMonster.HEAVEN_NIGHTMARE_ATTACK_BONUS
		if heaven
		else BaseMonster.UNDERWORLD_NIGHTMARE_ATTACK_BONUS if underworld else BaseMonster.NIGHTMARE_ATTACK_BONUS
	)
	var def_bonus = (
		BaseMonster.HEAVEN_NIGHTMARE_DEFENSE_BONUS
		if heaven
		else BaseMonster.UNDERWORLD_NIGHTMARE_DEFENSE_BONUS if underworld else BaseMonster.NIGHTMARE_DEFENSE_BONUS
	)
	var penetration = BaseMonster.HEAVEN_NIGHTMARE_PENETRATION_BONUS if heaven else def_bonus
	result.hp = int((float(base.hp) * 3.0 + hp_bonus) * DATA.HP_MULT[tier]) * (2 if coop else 1)
	result.def = int((int(base.def) * 3 + def_bonus) * DATA.DEF_MULT[tier])
	result.mdef = int((int(base.mdef) * 3 + def_bonus) * DATA.DEF_MULT[tier])
	result.ar = int(base.ar) * 3 + penetration
	result.sp = int(base.sp) * 3 + penetration
	result.level = int(base.level) + BaseMonster.NIGHTMARE_LEVEL_BONUS
	result.hit = int(base.hit) * 3 + BaseMonster.NIGHTMARE_HIT_BONUS
	result.damage_bonus = (
		BaseMonster.HEAVEN_NIGHTMARE_DAMAGE_BONUS
		if heaven
		else BaseMonster.UNDERWORLD_NIGHTMARE_DAMAGE_BONUS if underworld else BaseMonster.NIGHTMARE_DAMAGE_BONUS
	)
	result.damage_reduction = result.damage_bonus + (0.25 if coop else 0.0)
	for attack in result.attacks.values():
		if attack is Dictionary and attack.has("power"):
			attack.power = int((float(attack.power) * 3.0 + atk_bonus) * DATA.ATK_MULT[tier])
			if coop:
				attack.power = int(float(attack.power) * 1.3)
	if id in DATA.AVAILABLE_IDS:
		result.hp = 3000000000 * (2 if coop else 1)
		result.def = 35000
		result.mdef = 35000
		result.ar = 65000
		result.sp = 65000
		result.hit = 5000
		result.crit = 8000
		result.damage_bonus = 1.25
		result.damage_reduction = 1.25 + (0.25 if coop else 0.0)
		for attack in result.attacks.values():
			if attack is Dictionary and attack.has("power"):
				attack.power = 351000 if coop else 270000
	return result


static func apply(enemy: BaseMonster, id: String, tier: int, coop: bool = false) -> void:
	var values = calculate(snapshot(enemy), id, tier, coop)
	enemy.set_health_without_coop(int(values.hp / (2 if coop else 1)))
	enemy.level = values.level
	enemy.def = values.def
	enemy.mdef = values.mdef
	enemy.ar = values.ar
	enemy.sp = values.sp
	enemy.htarget = values.hit
	enemy.crit = values.crit
	enemy.attack_range = 99999
	enemy.mysee = 99999
	enemy.super_armor_active = true
	enemy.damage_bonus = values.damage_bonus
	# BaseMonster 的 getter 在双人下统一追加 0.25；这里写入 raw 值避免 UI 预览与实际重复叠加。
	enemy.damage_reduction = float(values.damage_reduction) - (0.25 if coop else 0.0)
	enemy.obj_attack_dict = values.attacks


static func preview(context: Node, id: String, tier: int) -> Dictionary:
	var data_node = CharacterBody2D.new()
	context.add_child(data_node)
	var monster: int = DATA.CARDS[id].monster
	data_node.set_script(load("res://Script/monster/monster_%d.gd" % monster))
	data_node.set_process(false)
	data_node.set_physics_process(false)
	if monster in [30, 31]:
		data_node.call("monster_%d" % monster, false)
	else:
		data_node.call("monster_%d" % (101 if monster == 102 else monster))
	var result = calculate(
		snapshot(data_node as BaseMonster), id, tier, context.get_node("/root/LocalCoop").is_enabled()
	)
	data_node.free()
	return result

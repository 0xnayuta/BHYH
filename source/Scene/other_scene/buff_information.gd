extends MarginContainer
var buff_name: String
@onready var buff_infor: Label = $MarginContainer/BuffInfor
var data_list = {}
var total_times: int = 1
var last_hurt: float
var mm_time: int = 99999
var parent_node
var other_text: String


func _physics_process(delta: float) -> void:
	if data_list.has("CanRemove"):
		if data_list["CanRemove"]:
			other_text = "(低级负面)"
		else:
			other_text = "(高级负面)"
	else:
		other_text = "(低级负面)"
	if parent_node == null:
		return
	buff_name = parent_node.data_list["Name"]
	var last_time = parent_node.buff_time
	var value = parent_node.data_list["value"]
	var reduce_interval = parent_node.data_list.get("reduce_interval", parent_node.data_list.get("ReduceInterval", 0.0))
	var atk_kind = parent_node.data_list["AttackKind"]
	var get_damage_type: String
	match atk_kind:
		"physics":
			get_damage_type = "物理"
		"magic":
			get_damage_type = "魔法"
		"real":
			get_damage_type = "真实"
	match buff_name:
		"YutuWeakPoison", "YutuStrongPoison", "YutuWeakExtraPoison", "YutuStrongExtraPoison":
			buff_infor.text = (
				"%s：%d层\n每秒基础魔法伤害：%s\n剩余%s秒。"
				% [
					str(parent_node.data_list.get("DisplayName", "中毒")),
					int(parent_node.data_list.get("HaveCount", 0)),
					str(snapped(float(value), 0.1)),
					str(snapped(float(parent_node.data_list.get("TimeLeft", last_time)), 0.1)),
				]
			)
		"PetLifeBonus":
			buff_infor.text = "生命加成：生命上限增加%d，剩余%s秒。" % [int(value), str(snapped(last_time, 0.1))]
		"PetAttackBonus":
			buff_infor.text = "攻击加成：攻击增加%d，剩余%s秒。" % [int(value), str(snapped(last_time, 0.1))]
		"PetDefenseBonus":
			buff_infor.text = (
				"防御加成：物防增加%d，魔防增加%d，剩余%s秒。"
				% [int(value), int(data_list.get("magic_value", value)), str(snapped(last_time, 0.1))]
			)
		"PetManaBonus":
			buff_infor.text = "魔法加成：魔法上限增加%d，剩余%s秒。" % [int(value), str(snapped(last_time, 0.1))]
		"Ice":
			if last_time < mm_time:
				buff_infor.text = "该单位处于冰冻状态，" + str(snapped(last_time, 0.1)) + "秒内无法行动。" + other_text
			else:
				buff_infor.text = "该单位处于被永久冰冻无法行动。" + other_text
		"Bleed":
			if last_time < mm_time:
				buff_infor.text = (
					"该单位处于持续"
					+ str(snapped(last_time, 0.1))
					+ "秒的流血状态，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "受到"
					+ str(last_hurt)
					+ str(get_damage_type)
					+ "伤害。"
					+ other_text
				)
			else:
				buff_infor.text = (
					"该单位被添加永久流血，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "受到"
					+ str(last_hurt)
					+ str(get_damage_type)
					+ "伤害。"
					+ other_text
				)
		"poision":
			if last_time < mm_time:
				buff_infor.text = (
					"该单位处于持续"
					+ str(snapped(last_time, 0.1))
					+ "秒的中毒状态，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "受到"
					+ str(last_hurt)
					+ str(get_damage_type)
					+ "伤害。"
					+ other_text
				)
			else:
				buff_infor.text = (
					"该单位被添加永久中毒，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "受到"
					+ str(last_hurt)
					+ str(get_damage_type)
					+ "伤害。"
					+ other_text
				)
		"Fire":
			if last_time < mm_time:
				buff_infor.text = (
					"该单位处于持续"
					+ str(snapped(last_time, 0.1))
					+ "秒的灼烧状态，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "受到"
					+ str(last_hurt)
					+ str(get_damage_type)
					+ "伤害。"
					+ other_text
				)
			else:
				buff_infor.text = (
					"该单位被添加永久灼烧，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "受到"
					+ str(last_hurt)
					+ str(get_damage_type)
					+ "伤害。"
					+ other_text
				)
		"stun":
			if last_time < mm_time:
				buff_infor.text = "该单位处于眩晕状态，" + str(snapped(last_time, 0.1)) + "秒内无法行动。" + other_text
			else:
				buff_infor.text = "该单位被永久眩晕无法行动。" + other_text
		"EyeFix":
			if last_time < mm_time:
				buff_infor.text = "该单位处于眩目状态，" + str(snapped(last_time, 0.1)) + "秒内无法行动。" + other_text
			else:
				buff_infor.text = "该单位被永久眩目无法行动。" + other_text
		"DeadLink":
			if last_time < mm_time:
				buff_infor.text = "该单位被施加" + str(snapped(last_time, 0.1)) + "秒的死亡连接，在此期间攻击施加者，自身也会受到同等伤害。" + other_text
			else:
				buff_infor.text = "该单位永久施加死亡连接，在此期间攻击施加者，自身也会受到同等伤害。" + other_text
		"nlls":
			if last_time < mm_time:
				buff_infor.text = str(snapped(last_time, 0.1)) + "秒内，玩家移动的越快，法力和生命流失的越快。" + other_text
			else:
				buff_infor.text = "玩家移动的越快，法力和生命流失的越快。" + other_text
		"speed_down":
			if last_time < mm_time:
				buff_infor.text = str(snapped(last_time, 0.1)) + "秒内，移动速度降低" + str(last_hurt * 100) + "%" + other_text
			else:
				buff_infor.text = "移动速度永久降低" + str(snapped(last_hurt, 0.1) * 100) + "%" + other_text
		"Boundground":
			if last_time < mm_time:
				buff_infor.text = "该单位处于缚地状态，" + str(snapped(last_time, 0.1)) + "秒内无法跳跃。" + other_text
			else:
				buff_infor.text = "该单位被永久缚地无法跳跃。" + other_text
		"silent":
			if last_time < mm_time:
				buff_infor.text = "该单位处于沉默状态，" + str(snapped(last_time, 0.1)) + "秒内无法使用技能。" + other_text
			else:
				buff_infor.text = "该单位被永久沉默无法使用技能。" + other_text
		"Immobilize":
			if last_time < mm_time:
				buff_infor.text = "该单位处于定身状态，" + str(snapped(last_time, 0.1)) + "秒内无法行动。" + other_text
			else:
				buff_infor.text = "该单位被永久定身无法行动。" + other_text
		"blood_fix":
			if last_time < mm_time:
				buff_infor.text = "该单位处于封疗状态，" + str(snapped(last_time, 0.1)) + "秒内无法回复生命值。" + other_text
			else:
				buff_infor.text = "该单位被永久封疗无法回复生命值。" + other_text
		"Scary":
			if last_time < mm_time:
				buff_infor.text = "该单位被恐惧，" + str(snapped(last_time, 0.1)) + "秒无法自由行动。" + other_text
			else:
				buff_infor.text = "该单位被永久恐惧，无法自由行动。" + other_text
		"defe_reduce":
			if last_time < mm_time:
				buff_infor.text = (
					"该单位处于破甲状态，"
					+ str(snapped(last_time, 0.1))
					+ "秒内双抗被无视"
					+ str(snapped(last_hurt, 0.01) * 100)
					+ "% 。"
					+ other_text
				)
			else:
				buff_infor.text = "该单位被永久破甲，双抗被无视" + str(snapped(last_hurt, 0.01) * 100) + "% 。" + other_text
		"SuperArmor":
			if bool(parent_node.data_list.get("ImmuneAllControl", false)):
				var remaining := float(parent_node.data_list.get("TimeLeft", last_time))
				if remaining < mm_time:
					buff_infor.text = "该单位处于霸体状态，剩余%s秒，免疫所有控制效果。" % str(snapped(remaining, 0.1))
				else:
					buff_infor.text = "该单位永久处于霸体状态，免疫所有控制效果。"
			elif last_time < mm_time:
				buff_infor.text = "该单位处于霸体状态，" + str(snapped(last_time, 0.1)) + "秒内免疫击退。"
			else:
				buff_infor.text = "该单位永久处于霸体状态。"
		"Indestructible":
			if last_time < mm_time:
				buff_infor.text = "该单位处于不灭灵体状态，" + str(snapped(last_time, 0.1)) + "秒内免疫高于自身当前生命的伤害。"
		"Indestructible1":
			if last_time < mm_time:
				buff_infor.text = "该单位处于伏妖护盾状态，" + str(snapped(last_time, 0.1)) + "秒内免疫高于自身当前生命的伤害。"
			else:
				buff_infor.text = "该单位永久免疫高于自身当前生命的伤害。"
		"DoubleFallPro":
			buff_infor.text = "幸运的喜鹊：" + str(snapped(last_time, 0.1)) + "秒内怪物掉率翻倍，地狱强化石随机宝箱也受到加成。"
		"Voodoo":
			if last_time < mm_time:
				buff_infor.text = (
					"该单位处于持续"
					+ str(snapped(last_time, 0.1))
					+ "秒的巫毒状态，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "受到"
					+ str(last_hurt)
					+ str(get_damage_type)
					+ "伤害。"
					+ other_text
				)
			else:
				buff_infor.text = (
					"该单位被添加永久巫毒，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "受到"
					+ str(last_hurt)
					+ str(get_damage_type)
					+ "伤害。"
					+ other_text
				)
		"slzbuff":
			var levelslz = PlayerData.player_data["森罗阵"]["Level"]
			if last_time < mm_time:
				buff_infor.text = (
					"该单位获得森罗阵的加护，" + str(snapped(last_time, 0.1)) + "秒内，受伤降低" + str(levelslz * 0.02 * 100) + "%"
				)
			else:
				buff_infor.text = "该单位获得森罗阵的加护，受伤永久降低" + str(snapped(levelslz * 0.02, 0.01) * 100) + "%"
		"lpzbuff":
			var levelslz = PlayerData.player_data["落魄阵"]["Level"]
			if last_time < mm_time:
				buff_infor.text = "该单位被施加虚弱，" + str(snapped(last_time, 0.1)) + "秒内，伤害降低" + str(last_hurt * 100) + "%"
			else:
				buff_infor.text = "该单位被施加虚弱，伤害永久降低" + str(snapped(last_hurt, 0.01) * 100) + "%"
		"tszbuff":
			var levelslz = PlayerData.player_data["落魄阵"]["Level"]
			if last_time < mm_time:
				buff_infor.text = (
					"该单位获得腾蛇加护，" + str(snapped(last_time, 0.1)) + "秒内，伤害增加" + str(levelslz * 0.015 * 100) + "%"
				)
			else:
				buff_infor.text = "该单位获得腾蛇加护，伤害永久增加" + str(snapped(levelslz * 0.015, 0.001) * 100) + "%"
		"PoisionBody":
			buff_infor.text = "该单位获得万毒加护，受伤减少，免疫部分击退，并对攻击者施加”巫毒“。"
		"lljybuff":
			buff_infor.text = "该单位被点穴，" + str(snapped(last_time, 0.1)) + "秒内，无法行动"
		"jgz":
			var jgz_level = int(data_list["value"])
			var hurt_bonus = 20 + (jgz_level - 1) * 8

			if last_time < mm_time:
				buff_infor.text = "该单位被紧箍咒束缚，" + str(snapped(last_time, 0.1)) + "秒内受到的伤害提升" + str(hurt_bonus) + "%！"
			else:
				buff_infor.text = "该单位被永久紧箍咒束缚，受到的伤害提升" + str(hurt_bonus) + "%！"

		"zznh":
			var zznh_level = int(data_list["value"])
			var hurt_bonus = 10 + (zznh_level - 1) * 10
			var defense_text := "，并降低50%物理防御和魔法防御" if float(data_list.get("defense_reduction", 0.0)) > 0.0 else ""
			if last_time < mm_time:
				buff_infor.text = (
					"该单位被战争怒吼震慑，"
					+ str(snapped(last_time, 0.1))
					+ "秒内受到的伤害提升"
					+ str(hurt_bonus)
					+ "%"
					+ defense_text
					+ "！"
				)
			else:
				buff_infor.text = "该单位被永久战争怒吼震慑，受到的伤害提升" + str(hurt_bonus) + "%" + defense_text + "！"

		"no_debuff":
			if last_time < mm_time:
				buff_infor.text = "该单位" + str(snapped(last_time, 0.1)) + "秒内，免疫所有负面状态。"
			else:
				buff_infor.text = "该单位永久免疫所有负面状态。"
		"flls":
			if last_time < mm_time:
				buff_infor.text = (
					"该单位处于持续"
					+ str(snapped(last_time, 0.1))
					+ "秒的法力流失状态，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "扣除"
					+ str(last_hurt)
					+ "魔法"
					+ other_text
				)
			else:
				buff_infor.text = (
					"该单位被添加永久法力流失，每过" + str(reduce_interval) + "秒" + "扣除" + str(last_hurt) + "魔法。" + other_text
				)
		"yxbuff":
			buff_infor.text = "提升攻击力、暴击率、幸运。"
		"HealOverTime":
			if last_time < mm_time:
				buff_infor.text = (
					"该单位获得持续"
					+ str(snapped(last_time, 0.1))
					+ "秒的治疗效果，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "恢复"
					+ str(snapped(last_hurt * 100, 0.1))
					+ "%最大生命值。"
				)
			else:
				buff_infor.text = (
					"该单位获得永久治疗效果，每过"
					+ str(reduce_interval)
					+ "秒"
					+ "恢复"
					+ str(snapped(last_hurt * 100, 0.1))
					+ "%最大生命值。"
				)
		"life_mana_lock":
			if last_time < mm_time:
				buff_infor.text = "该单位处于生命法力封锁状态，" + str(snapped(last_time, 0.1)) + "秒内无法回复生命值和法力值。" + other_text
			else:
				buff_infor.text = "该单位被永久生命法力封锁，无法回复生命值和法力值。" + other_text

		"SMSRSZ_CD":
			if last_time < mm_time:
				buff_infor.text = "弹道类技能消除效果进入" + str(snapped(last_time, 0.1)) + "冷却。"

	await get_tree().create_timer(3, false).timeout
	queue_free()

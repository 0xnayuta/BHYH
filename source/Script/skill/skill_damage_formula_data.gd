extends RefCounted

const ROLE_NAMES := {
	1: "悟空",
	2: "唐僧",
	3: "八戒",
	4: "沙僧",
	5: "白龙",
	6: "哪吒",
	7: "玉兔",
}


static func get_role_name(role_id: int) -> String:
	return str(ROLE_NAMES.get(role_id, "悟空"))


static func get_skill_detail(role_id: int, skill_id: String, stored_level: int, all_levels: Dictionary) -> Dictionary:
	if role_id == 7:
		if skill_id == YutuSkillData.PASSIVE_KEY:
			if stored_level <= 0:
				return _detail("被动技能", ["未学习时不叠加月印。", YutuSkillData.PASSIVE_DESCRIPTION])
			return _detail(
				"被动物理伤害",
				[
					"每次有效的非毒素伤害叠加1层月印，满8层消耗并追击该目标；毒素伤害与追击本身不叠印。",
					_attack_formula_panel(
						"追击伤害", YutuSkillData.PASSIVE_BASE, YutuSkillData.PASSIVE_GROWTH, stored_level
					),
					"学习后自动生效，不可设置按键，无魔法消耗；升11～20级使用一阶技能书，升21～30级使用二阶技能书。",
				]
			)
		var row := YutuSkillData.skill(skill_id)
		if skill_id in ["yt_hyl", "yt_ygj"]:
			return _detail("辅助技能", [str(row.get("description", "")).replace("\\n", "\n")])
		var level := clampi(stored_level, 1, 30)
		var formula := _attack_formula_clamped_offset(
			"每次命中",
			float(row.get("skillDefault", "0")),
			float(row.get("skillAdd", "0")),
			level,
			YutuSkillData.number_at(str(row.get("skillCountAdd", "0")), level)
		)
		if stored_level <= 0:
			return _detail("未学习", ["学习后Lv.1效果：", formula])
		var lines: Array = [formula]
		if skill_id in ["yt_mds", "yt_tyy", "yt_xdz", "yt_ldmw"]:
			var poison_row := YutuSkillData.row("1111052") if skill_id == "yt_ldmw" else row
			var ratio := YutuSkillData.POISON_DAMAGE_RATIO
			lines.append(
				_attack_formula_clamped_offset(
					"每次叠毒增加的每秒伤害",
					float(poison_row.get("skillDefault", "0")) * ratio,
					float(poison_row.get("skillAdd", "0")) * ratio,
					level,
					YutuSkillData.number_at(str(poison_row.get("skillCountAdd", "0")), level) * ratio
				)
			)
			lines.append(
				(
					"每次命中叠毒增加该次技能基础伤害的25%，后续命中继续累计并刷新持续时间；初始毒层数不额外倍乘伤害。"
					if skill_id != "yt_ldmw"
					else "已有蔓毒或玄毒时，每次命中追加爆炸基础伤害25%的毒伤，可继续累计；两种毒同时存在时分摊这一份伤害。"
				)
			)
		if skill_id == "yt_ymw":
			lines.append("同一目标每次释放最多受到%d段伤害，需处于攻击范围内。" % YutuSkillData.MOON_DANCE_HITS)
		elif skill_id == "yt_yl":
			lines.append("旋转阶段持续5秒，每%s秒可再次造成伤害。" % _number(YutuSkillData.MOON_WHEEL_INTERVAL_MS / 1000.0))
			lines.append("觉醒：牵引全屏怪物（包括空中目标），每次伤害叠加2层月印。")
		elif skill_id == "yt_xdz":
			lines.append("觉醒：" + YutuSkillData.NEEDLE_AWAKEN_DESCRIPTION)
		elif skill_id == "yt_mds":
			lines.append("觉醒：" + YutuSkillData.POWDER_AWAKEN_DESCRIPTION)
		elif skill_id == "yt_ldmw":
			lines.append("觉醒：" + YutuSkillData.JAR_AWAKEN_DESCRIPTION)
		return _detail("物理伤害" if YutuSkillData.KEYS.find(skill_id) >= 5 else "魔法伤害", lines)
	match role_id:
		1:
			return _role_1(skill_id, stored_level)
		2:
			return _role_2(skill_id, stored_level, all_levels)
		3:
			return _role_3(skill_id, stored_level, all_levels)
		4:
			return _role_4(skill_id, stored_level, all_levels)
		5:
			return _role_5(skill_id, stored_level)
		6:
			return _role_6(skill_id, stored_level)
	return _detail("技能效果", ["暂无可显示的伤害公式。"])


static func _role_1(skill_id: String, stored_level: int) -> Dictionary:
	var level := _legacy_level(stored_level)
	match skill_id:
		"slz":
			return _detail("魔法伤害", [_attack_formula("伤害", 2.5, 0.12, level)])
		"hytj":
			return _detail("魔法伤害", [_attack_formula("每次命中", 0.25, 0.02, level), "每个伤害时点会结算2次；同一目标不限制重复命中。"])
		"lys":
			return _detail("魔法伤害", [_attack_formula("每次命中", 0.16, 0.02, level, 35.0)])
		"lyfb":
			return _detail(
				"魔法伤害", [_attack_formula("每次命中", 0.7, 0.2, level), _attack_formula("觉醒刀刃每段", 1.8, 0.25, level)]
			)
		"hmz", "hmz_ws":
			return _detail(
				"物理 / 魔法伤害",
				[
					_attack_range_formula("腾空首段（物理）", 1.02, 1.1, 0.15, level, 0.65),
					_attack_range_formula("腾空连斩（物理）", 1.08, 1.16, 0.18, level),
					_attack_range_formula("下落冲击（魔法）", 1.02, 1.1, 0.15, level),
					_attack_range_formula("落地爆发（魔法）", 3.5, 3.8, 0.5, level),
					"火魔斩无双及其觉醒均使用火魔斩无双自己的等级。" if skill_id == "hmz_ws" else "随机倍率会在每次生成伤害数据时重新取值。",
				]
			)
		"zz":
			return _detail("物理伤害", [_attack_formula("伤害", 4.0, 0.5, level)])
		"qsez":
			return _detail(
				"物理伤害", [_attack_formula("每段", 0.07, 0.02, level), "残影伤害继承：本次技能伤害 × %s。" % _percent(0.7 + level * 0.03)]
			)
		"jdy":
			return _detail("魔法伤害", [_attack_formula("冲撞 / 上升命中", 0.4, 0.07, level)])
		"hyjj":
			return _detail("魔法伤害", [_attack_formula("每段六丁神火", 0.5, 0.15, level)])
		"sx":
			if stored_level <= 0:
				return _detail("被动效果", ["未学习时不提供暴击和吸血。"])
			return _detail(
				"被动效果",
				[
					"暴击增加：4 + (Lv - 1) × 1.6 = %s。" % _number(4.0 + (stored_level - 1) * 1.6),
					"吸血增加：3%% + (Lv - 1) × 0.3%% = %s。" % _percent(0.03 + (stored_level - 1) * 0.003),
				]
			)
		"gsrs":
			return _detail(
				"物理伤害",
				[
					_attack_formula("伤害", 4.0, 0.5, level),
					"命中降低防御 %s，持续8秒。" % _percent(minf(1.0, 0.3 + level * 0.064)),
				]
			)
		"hyjj_ws":
			return _detail("魔法伤害", [_attack_formula("光束每段", 0.6, 0.12, level)])
	return _unknown()


static func _role_2(skill_id: String, stored_level: int, all_levels: Dictionary) -> Dictionary:
	var level := _legacy_level(stored_level)
	var mastery := maxi(0, int(all_levels.get("sjt", 0)))
	match skill_id:
		"blb":
			return _detail("魔法伤害", [_attack_formula("伤害", 1.0, 0.05, level)])
		"xbz":
			return _detail(
				"魔法伤害",
				[
					_attack_formula("每段冰刺（共3段）", 0.75, 0.075, level),
					"水精通触发冰冻：%s，持续%s秒。" % [_percent((3.0 + mastery * 0.5) / 100.0), _number(1.0 + mastery * 0.1)],
					"目标处于紧箍咒中时，冰冻概率再增加：紧箍咒Lv × 3.5%。",
				]
			)
		"shy":
			return _detail("辅助技能", ["无直接伤害。生成可继承玄冰阵、天降甘露和九环圣经的幻影。"])
		"tjgl":
			return _detail(
				"治疗",
				[
					"治疗公式：最大生命 × 20% × [1 + 0.6 × 已损生命比例]。",
					"技能等级不参与治疗量计算。",
					"当前Lv.%d：最大生命 × 20%% × [1 + 0.6 × 已损生命比例]。" % stored_level,
					"过量治疗转为护盾，最多等于最大生命，持续15秒。",
					"觉醒后护盾不被击破就不会消失，且护盾存在期间免疫击退。",
				]
			)
		"smb":
			return _detail(
				"魔法伤害",
				[
					_dual_formula("光柱伤害", 6.0, 2.2, 0.4, 0.3, level),
					"水精通触发冰冻：%s，持续%s秒。" % [_percent((2.0 + mastery) / 100.0), _number(2.0 + mastery * 0.1)],
					"觉醒额外光柱：50%追加1次，20%追加2次。每次使用相同公式。",
				]
			)
		"sgq":
			return _detail("魔法伤害", [_attack_formula("法球每段冰刺", 0.15, 0.02, level)])
		"myhc":
			return _detail(
				"持续治疗",
				[
					"每秒恢复公式：最大生命 × 随机[4%%～5%%]。",
					"技能等级不参与恢复量计算。",
					"当前Lv.%d：最大生命 × 随机[4%%～5%%]。" % stored_level,
				]
			)
		"jgz":
			return _detail(
				"辅助技能",
				[
					"无直接伤害。聚怪并提高目标承受的伤害。",
					"目标承受伤害倍率：1.2 + (技能等级 - 1) × 0.1。",
					"当前Lv.%d：目标承受伤害 × %s。" % [stored_level, _number(1.2 + (stored_level - 1) * 0.1)],
					"持续时间：5 + (Lv - 1) × 0.5 = %s秒。" % _number(5.0 + maxi(stored_level - 1, 0) * 0.5),
					"玄冰阵 / 水魔爆的冰冻概率额外增加：Lv × 3.5%。",
				]
			)
		"jhsj":
			return _detail(
				"魔法伤害",
				[_attack_formula("佛光每段", 0.8, 0.1, level), _attack_formula_panel("觉醒每段", 15.0, 0.45, stored_level)]
			)
		"sjt":
			return _detail(
				"被动效果",
				[
					"玄冰阵冰冻概率：3%% + Lv × 0.5%% = %s。" % _percent((3.0 + stored_level * 0.5) / 100.0),
					"水魔爆冰冻概率：2%% + Lv × 1%% = %s。" % _percent((2.0 + stored_level) / 100.0),
					(
						"玄冰阵 / 水魔爆冰冻时间分别为 %s秒 / %s秒。"
						% [_number(1.0 + stored_level * 0.1), _number(2.0 + stored_level * 0.1)]
					),
				]
			)
		"by":
			return _detail(
				"魔法伤害",
				[
					"每个雨滴节点会结算落雨与落地两次范围伤害。",
					(
						"每次技能公式：0.32 × [攻击 × (2 + 1.6 × 技能等级) + 最大魔法 × (0.13 + 0.1 × 技能等级)]。\n每次当前Lv.%d：0.32 × [攻击 × %s + 最大魔法 × %s]。"
						% [stored_level, _number(2.0 + stored_level * 1.6), _number(0.13 + stored_level * 0.1)]
					),
					"每次命中有25%概率冰冻1.5秒。",
				]
			)
		"zfjg":
			return _detail(
				"召唤伤害",
				[
					"金刚第1 / 2 / 3式：攻击 × 2 / 攻击 × 4 / 攻击 × 6，均为魔法伤害。",
					"第3式降低目标30%防御，持续20秒。",
					"召唤持续：20 + Lv × 2 = %s秒。" % _number(20.0 + stored_level * 2.0),
				]
			)
	return _unknown()


static func _role_3(skill_id: String, stored_level: int, all_levels: Dictionary) -> Dictionary:
	var level := _legacy_level(stored_level)
	var armor := maxi(0, int(all_levels.get("rj", 0)))
	match skill_id:
		"ssp":
			return _detail("物理伤害", [_hp_attack_formula("每段突刺", 0.03, 0.05, 0.47, 0.05, level)])
		"dj":
			return _detail(
				"物理伤害",
				[
					_attack_formula("伤害", 3.0, 0.3, level),
					"刃甲触发眩晕：%s，持续%s秒。" % [_percent((10.0 + armor) / 100.0), _number(3.0 + armor * 0.1)]
				]
			)
		"dgq":
			return _detail("物理伤害", [_attack_formula("每次命中", 1.1, 0.1, level)])
		"zznh":
			return _detail(
				"辅助技能",
				[
					(
						"无直接伤害。被怒吼命中的目标，下次承受伤害倍率：1.1 + (Lv - 1) × 0.1 = %s。"
						% _number(1.1 + maxi(stored_level - 1, 0) * 0.1)
					),
					"觉醒后，被吸取的敌人在震慑期间额外降低50%物理防御和魔法防御。",
				]
			)
		"tmc":
			return _detail(
				"魔法伤害", [_hp_attack_formula("尖刺 / 反弹每次", 0.06, 0.09, 0.04, 0.05, level), "魔球期间物理防御和魔法防御提高50%。"]
			)
		"sd":
			return _detail(
				"持续治疗 / 防御",
				[
					"无直接伤害。每秒治疗公式：6 + 最大生命 × [0.4% + 0.1% × (技能等级 + 1)]。",
					"当前Lv.%d：每秒治疗 = 6 + 最大生命 × %s。" % [stored_level, _percent(0.004 + level * 0.001)],
					"持续约10.3秒；持续期间不会被击退。持续时间和免击退效果不随等级成长。",
				]
			)
		"jsp":
			return _detail(
				"物理伤害",
				[
					_attack_formula("每段", 1.4, 0.1, level),
					"刃甲触发眩晕：%s，持续%s秒。" % [_percent((armor * 0.4) / 100.0), _number(0.5 + armor * 0.05)]
				]
			)
		"xgq":
			return _detail("物理伤害", [_attack_formula("每次命中", 1.1, 0.1, level)])
		"syzq":
			return _detail(
				"物理伤害",
				[
					_attack_formula("每次命中", 2.0, 0.2, level),
					"刃甲触发眩晕：%s，持续%s秒。" % [_percent((8.0 + armor * 0.5) / 100.0), _number(2.0 + armor * 0.1)]
				]
			)
		"rj":
			return _detail(
				"被动效果",
				[
					"受击回血概率公式：2% + 技能等级 × 0.5%。",
					(
						"当前Lv.%d：受击回血概率 = %s；回血量 = 攻击 × [%s + 0.03 × 技能等级] = 攻击 × %s。"
						% [
							stored_level,
							_percent((2.0 + stored_level * 0.5) / 100.0),
							_number(0.5),
							_number(0.5 + stored_level * 0.03)
						]
					),
					(
						"盾击眩晕概率公式：10% + 技能等级 × 1%；当前Lv."
						+ str(stored_level)
						+ "："
						+ _percent((10.0 + stored_level) / 100.0)
						+ "，持续时间 = 3 + 技能等级 × 0.1 = "
						+ _number(3.0 + stored_level * 0.1)
						+ "秒。"
					),
					(
						"巨石破眩晕概率公式：技能等级 × 0.4%；当前Lv."
						+ str(stored_level)
						+ "："
						+ _percent(stored_level * 0.004)
						+ "，持续时间 = 0.5 + 技能等级 × 0.05 = "
						+ _number(0.5 + stored_level * 0.05)
						+ "秒。"
					),
					(
						"圣域之墙眩晕概率公式：8% + 技能等级 × 0.5%；当前Lv."
						+ str(stored_level)
						+ "："
						+ _percent((8.0 + stored_level * 0.5) / 100.0)
						+ "，持续时间 = 2 + 技能等级 × 0.1 = "
						+ _number(2.0 + stored_level * 0.1)
						+ "秒。"
					),
				]
			)
		"bdqk":
			return _detail("物理伤害", [_hp_attack_formula("每段震波", 0.16, 0.04, 0.7, 0.14, level)])
	return _unknown()


static func _role_4(skill_id: String, stored_level: int, all_levels: Dictionary) -> Dictionary:
	var level := _legacy_level(stored_level)
	var poison := maxi(0, int(all_levels.get("mds", 0)))
	match skill_id:
		"qlj":
			return _detail("物理伤害", [_attack_formula("伤害", 2.5, 0.4, level)])
		"dcj":
			return _detail("魔法伤害", [_attack_formula("每段", 0.6, 0.3, level)])
		"wdzt":
			return _detail(
				"防御效果",
				[
					"无直接伤害。受到伤害倍率：70%% - Lv × 2%% = %s。" % _percent(maxf(0.0, 0.7 - stored_level * 0.02)),
					"20%%概率恢复本次减免的伤害；普通效果持续6秒。"
				]
			)
		"tkj":
			return _detail("物理伤害", [_attack_formula("伤害", 3.0, 0.5, level, 35.0)])
		"mmw":
			return _detail("魔法伤害", [_attack_formula("每段", 2.0, 0.2, level), "觉醒且已学习猛毒素时，命中附加5秒巫毒。"])
		"jdz":
			return _detail(
				"魔法伤害", [_attack_formula("毒阵每段", 1.5 if poison > 0 else 1.0, 0.1, level), "已学习猛毒素时附加5秒巫毒；毒阵同时造成减速。"]
			)
		"lhsq":
			return _detail(
				"魔法伤害 / 治疗",
				[
					_attack_formula("伤害", 1.35, 0.1, level),
					"命中治疗：本次基础伤害 × [20% + Lv × 3%] × [1 + 0.3 × 已损生命比例]。",
					"觉醒后每次命中增加20%最大生命值和20%攻击，最多叠加五次，持续10秒。"
				]
			)
		"zq":
			return _detail(
				"魔法伤害",
				[_attack_formula("每段", 0.7 if poison > 0 else 1.0, 0.2 if poison > 0 else 0.1, level), "已学习猛毒素时附加5秒巫毒。"]
			)
		"wdww":
			return _detail(
				"传递伤害",
				[
					"娃娃无主动伤害。娃娃生命：目标最大生命 × [25%% + Lv × 2%%] = 目标最大生命 × %s。" % _percent(0.25 + stored_level * 0.02),
					"攻击娃娃时，绑定目标受到相同伤害。",
					"觉醒后可同时连接四个敌人。"
				]
			)
		"mds":
			return _detail("真实伤害", ["巫毒每秒：攻击 × 10%，持续5秒，可叠加至7层。", "7层引爆：层数 × 攻击 × [0.5 + 0.05 × Lv]。"])
		"bylt":
			return _detail(
				"魔法伤害", [_attack_formula_clamped_offset("每段（共6段）", 1.8, 0.25, stored_level), "已学习猛毒素时，每次命中附加5秒巫毒。"]
			)
		"cmly":
			return _detail(
				"魔法伤害", [_attack_formula_clamped_offset("木龙每段", 1.8, 0.25, stored_level), "已学习猛毒素时，每次命中附加5秒巫毒。"]
			)
	return _unknown()


static func _role_5(skill_id: String, stored_level: int) -> Dictionary:
	var level := _legacy_level(stored_level)
	match skill_id:
		"xyq":
			return _detail(
				"物理伤害", [_attack_formula("普通挥击每段", 0.3, 0.2, level), _attack_formula("终结击", 1.5, 0.2, level)]
			)
		"slq":
			return _detail("物理伤害", [_attack_formula("伤害", 2.0, 0.12, level)])
		"blq":
			return _detail("魔法伤害", [_attack_formula("每次命中", 0.5, 0.2, level)])
		"fhf":
			return _detail("物理伤害", [_attack_formula("伤害", 3.0, 0.2, level), "觉醒后，技能前摇、后摇和冷却均缩短为原来的三分之一。"])
		"cxq":
			return _detail(
				"物理伤害", [_attack_formula("普通刺击每段", 0.5, 0.02, level), _attack_formula("终结击", 1.5, 0.02, level, 35.0)]
			)
		"llrd":
			return _detail("魔法伤害", [_attack_formula("落地雷击", 3.0, 0.2, level), "命中使目标5秒内承受伤害提高30%。"])
		"lljy":
			return _detail("魔法伤害", [_attack_formula("残影每段", 0.1, 0.01, level), "冲刺点穴使目标僵直1.2秒。"])
		"ygth":
			return _detail(
				"物理伤害", [_attack_formula("每段", 0.7, 0.01, level), "觉醒后跳过前段挥枪，连续释放三次巨型银钩；每次银钩伤害为未觉醒的三倍，冷却缩短至0.8秒。"]
			)
		"tllz":
			return _detail(
				"魔法伤害",
				[
					_attack_formula("雷阵每段", 2.5, 0.01, level),
					"雷阵持续10秒并减速目标。",
					"觉醒后，命中敌人降低50%物理防御和魔法防御，并在目标位置额外释放一个相同伤害的雷阵。"
				]
			)
		"yyb":
			return _detail(
				"被动真实伤害", ["每次有效攻击有15%概率触发天雷。", "天雷伤害：本次伤害 × 30% + Lv × 0.02。", "恢复生命：天雷伤害 × [1 + Lv × 0.2]。"]
			)
		"ltjz":
			return _detail(
				"魔法伤害",
				[
					_attack_formula_panel("每段雷电", 2.3, 0.25, stored_level),
					"觉醒后，在距离最远的有效目标位置额外释放一个相同伤害的雷霆劫阵。",
				]
			)
	return _unknown()


static func _role_6(skill_id: String, stored_level: int) -> Dictionary:
	match skill_id:
		"nz_jlsh":
			return _detail("物理伤害", [_attack_formula_clamped("每段九龙神火", 0.6706, 0.2, stored_level)])
		"nz_fhcc":
			return _detail("物理伤害", [_attack_formula_clamped("每段（共3段）", 0.8504, 0.26, stored_level)])
		"nz_hlqg":
			return _detail("物理伤害", [_attack_formula_clamped("切割及环绕火轮每段", 0.8504, 0.22, stored_level)])
		"nz_hlhs":
			return _detail("治疗 / 强化", ["无直接伤害。每层充能治疗：8 + 攻击 × 2% × Lv。", "觉醒时每层充能提高攻击：Lv × 1%，最多5层。"])
		"nz_lblc":
			return _detail(
				"物理伤害",
				[
					_attack_formula_clamped("普通突刺每段", 1.0465, 0.35, stored_level),
					_attack_formula_clamped("砸地段", 3.0368, 0.431, stored_level),
					_attack_formula_clamped("强化追踪每段", 0.522, 0.32, stored_level),
					"强化追踪命中降低50%防御，持续8秒。",
				]
			)
		"nz_yysj":
			return _detail(
				"物理伤害",
				[_attack_formula_clamped("每把阴剑 / 阳剑", 0.8504, 0.2, stored_level), "每轮发射阴剑、阳剑各1把；普通间隔0.267秒，觉醒间隔0.12秒。"]
			)
	return _unknown()


static func _detail(kind: String, lines: Array) -> Dictionary:
	return {"kind": kind, "lines": lines}


static func _unknown() -> Dictionary:
	return _detail("技能效果", ["暂无可显示的伤害公式。"])


static func _legacy_level(stored_level: int) -> int:
	return maxi(1, stored_level + 1)


static func _attack_formula(label: String, base: float, growth: float, level: int, flat: float = 0.0) -> String:
	var formula := "攻击 × [%s + %s × (技能等级 + 1)]" % [_number(base), _number(growth)]
	var current := "攻击 × %s" % _number(base + growth * level)
	if flat != 0.0:
		formula = _number(flat) + " + " + formula
		current = _number(flat) + " + " + current
	return "%s技能公式：%s。\n%s当前Lv.%d：%s。" % [label, formula, label, level - 1, current]


static func _attack_formula_panel(label: String, base: float, growth: float, stored_level: int) -> String:
	return (
		"%s技能公式：攻击 × [%s + %s × 技能等级]。\n%s当前Lv.%d：攻击 × %s。"
		% [label, _number(base), _number(growth), label, stored_level, _number(base + growth * stored_level)]
	)


static func _attack_formula_clamped(label: String, base: float, growth: float, stored_level: int) -> String:
	return (
		"%s技能公式：攻击 × [%s + %s × 技能等级]。\n%s当前Lv.%d：攻击 × %s。"
		% [label, _number(base), _number(growth), label, stored_level, _number(base + growth * stored_level)]
	)


static func _attack_formula_clamped_offset(
	label: String, base: float, growth: float, stored_level: int, flat: float = 0.0
) -> String:
	var growth_level := stored_level - 1
	var formula := "攻击 × [%s + %s × (技能等级 - 1)]" % [_number(base), _number(growth)]
	var current := "攻击 × %s" % _number(base + growth * growth_level)
	if flat != 0.0:
		formula = _number(flat) + " + " + formula
		current = _number(flat) + " + " + current
	return "%s技能公式：%s。\n%s当前Lv.%d：%s。" % [label, formula, label, stored_level, current]


static func _attack_range_formula(
	label: String, low: float, high: float, growth: float, level: int, scale: float = 1.0
) -> String:
	var low_value := (low + growth * level) * scale
	var high_value := (high + growth * level) * scale
	var formula_low := "(%s + %s × (技能等级 + 1))" % [_number(low), _number(growth)]
	var formula_high := "(%s + %s × (技能等级 + 1))" % [_number(high), _number(growth)]
	if not is_equal_approx(scale, 1.0):
		formula_low += " × " + _number(scale)
		formula_high += " × " + _number(scale)
	return (
		"%s技能公式：攻击 × 随机[%s～%s]。\n%s当前Lv.%d：攻击 × 随机[%s～%s]。"
		% [label, formula_low, formula_high, label, level - 1, _number(low_value), _number(high_value)]
	)


static func _dual_formula(
	label: String, attack_base: float, attack_growth: float, mp_base: float, mp_growth: float, level: int
) -> String:
	return (
		"%s技能公式：攻击 × [%s + %s × (技能等级 + 1)] + 最大魔法 × [%s + %s × (技能等级 + 1)]。\n%s当前Lv.%d：攻击 × %s + 最大魔法 × %s。"
		% [
			label,
			_number(attack_base),
			_number(attack_growth),
			_number(mp_base),
			_number(mp_growth),
			label,
			level - 1,
			_number(attack_base + attack_growth * level),
			_number(mp_base + mp_growth * level)
		]
	)


static func _hp_attack_formula(
	label: String, hp_base: float, hp_growth: float, attack_base: float, attack_growth: float, level: int
) -> String:
	return (
		"%s技能公式：最大生命 × [%s + %s × (技能等级 + 1)] + 攻击 × [%s + %s × (技能等级 + 1)]。\n%s当前Lv.%d：最大生命 × %s + 攻击 × %s。"
		% [
			label,
			_number(hp_base),
			_number(hp_growth),
			_number(attack_base),
			_number(attack_growth),
			label,
			level - 1,
			_number(hp_base + hp_growth * level),
			_number(attack_base + attack_growth * level)
		]
	)


static func _percent(value: float) -> String:
	return _number(value * 100.0) + "%"


static func _number(value: float) -> String:
	var result := "%.3f" % value
	while result.contains(".") and result.ends_with("0"):
		result = result.left(result.length() - 1)
	if result.ends_with("."):
		result = result.left(result.length() - 1)
	return result

extends RefCounted
class_name LongnvSkillData

## 小龙女（Role8）技能静态数据；技能等级、MP 与冷却均由运行时角色属性承担。

const KEYS := [
	"xln_lz",
	"xln_tk",
	"xln_ay",
	"xln_xr",
	"xln_ly",
	"xln_qlx",
	"xln_slj",
	"xln_lzs",
	"xln_lzw",
	"xln_lzn",
	"xln_rw",
	"xln_yr",
	"xln_fr",
	"xln_yrz",
	"xln_jyc",
	"xln_fxr",
	"xln_hylz",
	"xln_lrmt",
	"xln_llft",
	"xln_llmt",
]
const NAMES := [
	"飞旋龙",
	"龙影刃",
	"落龙刺",
	"回龙击",
	"魔龙绞",
	"潜龙行",
	"瞬龙击",
	"龙之锁",
	"龙之舞",
	"龙之怒",
	"刃舞",
	"圆刃",
	"飞刃",
	"圆刃斩",
	"疾影刺",
	"飞旋刃",
	"幻影连斩",
	"雷刃漫天",
	"雷龙附体",
	"玲珑漫天",
]
const ACTIONS := [
	"effect1",
	"effect2_1",
	"effect3_1",
	"effect4_1",
	"effect10",
	"effect5",
	"effect6_1",
	"effect7_1",
	"effect8",
	"effect9",
	"effect1",
	"effect2",
	"effect3",
	"effect4_1",
	# 7.1 数据表写 effect5，但当前 ring/default 仅提供 effect5_1，保留当前可用动画名。
	"effect5_1",
	"effect6_1",
	"effect7_1",
	"effect8",
	"effect9",
	"effect10",
]
const EFFECTS := [
	"effect1",
	"effect2",
	"effect3_1",
	"effect4_1",
	"effect10",
	"effect5",
	"effect6_2",
	"effect7_1",
	"effect8",
	"effect9",
	"ring_effect1",
	"ring_effect2",
	"ring_effect3",
	"ring_effect4_2",
	"ring_effect6",
	"ring_effect6",
	"",
	"ring_effect8_1",
	"ring_effect9",
	"ring_effect10",
]
const EXTRA_EFFECTS := {
	1: ["effect2_2"],
	2: ["effect3_2"],
	7: ["effect7_2"],
	9: ["effect9_buff"],
	11: ["ring_effect2_2"],
}
const RATIOS := [
	0.6,
	1.41,
	1.2,
	2.06,
	3.0,
	0.0,
	1.56,
	1.8,
	1.0,
	2.83,
	0.65,
	1.03,
	1.23,
	1.32,
	3.07,
	3.06,
	1.6,
	4.46,
	3.46,
	4.82,
]
const DAMAGE_GROWTH := [
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.0,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
	0.21,
]
const BLEED_RATIO := 0.02
const BLEED_INTERVAL := 1.1
const BLEED_DURATION := 4.5
const ULTIMATE_SLASH_WEIGHT := 0.2
const DESCENT_WEIGHT := 1.36 / 1.2
const COOLDOWNS := [
	4.0, 5.5, 4.0, 9.0, 7.0, 10.8, 4.8, 7.8, 8.4, 13.8, 2.7, 2.4, 2.4, 4.8, 5.4, 7.8, 7.8, 7.2, 9.0, 10.8
]
const DURATIONS := [
	0.5, 0.48, 1.0, 0.57, 1.15, 0.64, 1.2, 1.0, 2.0, 0.9, 0.7, 0.54, 1.3, 1.05, 0.78, 0.74, 1.3, 1.1, 0.8, 1.8
]
const HIT_TIMES := [
	[0.05, 0.24, 0.43],
	[],
	[0.05, 0.55],
	[0.33],
	[0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.95],
	[],
	[0.12, 0.48],
	[0.3, 0.66],
	[0.05, 0.45, 0.85, 1.25, 1.65],
	[0.32],
	[0.2, 0.4, 0.6],
	[0.35],
	[],
	[0.18, 0.48, 0.78],
	[0.18],
	[],
	[0.25, 0.55, 0.85, 1.15],
	[0.7],
	[0.2],
	[0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7],
]
const DESCRIPTIONS := [
	"原地快速旋转双刃，对周围敌人造成三次物理伤害，同时召唤旋转双刃向前飞行攻击并击退敌人。",
	"向前投掷飞刃攻击路径上的敌人；飞刃存在时再次按键，瞬移至飞刃位置并发动斩击。",
	"快速跃起挑击前方敌人，再向斜下方刺落，对范围内敌人造成物理伤害。",
	"挥动双刃攻击前方敌人，附加每跳以目标当前生命值2%为基础的魔法流血伤害；再次按键可向后翻身回避。",
	"屏幕中央浮现龙首，刀光攻击屏幕内敌人六次，随后发动终结一击。",
	"双刃：隐身10秒，移动速度提高30%；施放攻击或受到伤害后显形，显形后短暂无敌。10秒内获得攻击增幅与20%减伤。",
	"双刃：高速穿刺前方敌人并追加斩击，冲刺移动期间无敌，命中附加3次持续伤害和1秒麻痹。",
	"双刃：向两侧挥出锁链飞刃，再收拢将敌人拉至身边，造成两段伤害并眩晕2秒。",
	"双刃：持续2秒旋转攻击周围敌人，共5段伤害；期间可左右移动并吸附附近敌人。",
	"双刃：爆发升龙，眩晕周围敌人1.5秒；10秒内伤害提高30%、移速提高40%、减伤30%，免疫击退。",
	"圆刃：原地旋转攻击周围敌人3次，2秒内额外获得50%闪避概率。施放时切换圆刃形态。",
	"圆刃：劈砍前方并挥出斩击，命中使敌人物理与魔法防御降低30%，持续2秒。",
	"圆刃：依次发射三个飞行环刃，攻击路径上的敌人并击退。",
	"圆刃：化身旋转圆刃向前滚动，移动期间无敌，连续攻击并携带敌人，命中降低敌人双防30%，持续4秒。",
	"圆刃：向前冲刺穿过敌人，冲刺移动期间无敌，对路径上的敌人造成伤害并麻痹1秒。觉醒后原地旋转飞刃，范围和特效扩大2倍，伤害与命中频率提高3倍，冷却缩短至0.5秒。",
	"圆刃：向前投掷旋转圆刃，携带沿途敌人并附加持续3秒的流血，每跳以目标当前生命值2%为基础造成魔法伤害。",
	"圆刃：化身残影连续攻击4次，施放期间免疫击退和部分控制，命中眩晕2秒。",
	"圆刃：跃起投刃，落地释放电蛇造成范围魔法伤害，恐惧3秒并减速5秒。",
	"圆刃：雷龙从天而降，造成范围魔法伤害并眩晕2秒；获得8秒龙魂，提高伤害、移速并降低受到的伤害。",
	"圆刃：召唤雷龙及月牙刀光连续攻击屏幕内敌人，造成7段魔法伤害并眩晕3秒。",
]


static func mp(key: String, level: int) -> int:
	var index := KEYS.find(key)
	if index < 0:
		return 0
	if index >= 5:
		if index == 19:
			return 60 + maxi(0, level - 1) * 3
		var bases := [25.3, 23.0, 32.0, 32.0, 33.0, 24.83, 26.7, 26.7, 50.12, 47.79, 53.86, 101.55, 108.68, 110.08]
		var rates := [2.38, 2.38, 3.64, 3.64, 3.64, 5.22, 5.22, 5.42, 10.44, 10.44, 10.44, 15.66, 16.66, 15.66]
		return floori(float(bases[index - 5]) + float(rates[index - 5]) * maxi(1, level))
	if index == 4:
		return 35 + maxi(0, level - 1) * 3
	var base := 22.0 if index == 3 else (16.7 if index == 1 else 15.3)
	var growth := 2.38 if index == 3 else 1.12
	var capped := mini(40, maxi(1, level))
	var cost := floori(growth * capped + base)
	for current in range(41, level + 1):
		cost = floori(pow(float(current), 0.3) * growth * 3.0 + cost)
	return cost


static func damage(index: int, level: int, power: float) -> float:
	return power * (float(RATIOS[index]) + maxi(0, level - 1) * float(DAMAGE_GROWTH[index]))


static func effect_banks(index: int) -> Array[String]:
	var banks: Array[String] = []
	if not str(EFFECTS[index]).is_empty():
		banks.append(str(EFFECTS[index]))
	for bank: String in EXTRA_EFFECTS.get(index, []):
		if bank not in banks:
			banks.append(bank)
	return banks


static func _coop() -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		return (loop as SceneTree).root.get_node_or_null("LocalCoop")
	return null


static func bleed_damage(enemy: BaseMonster, caster: BaseHero, ratio: float = BLEED_RATIO) -> int:
	var coop := _coop()
	var caster_props := coop.props_for(caster) as BaseRoleProperties if coop != null else null
	var source_props: BaseRoleProperties = caster_props if caster_props != null else RoleProp
	var defense := maxf(0.0, float(enemy.mdef) - float(source_props.roleprop.get("sp", 0)))
	if enemy.is_defe_reduce:
		defense *= 1.0 - enemy.get_effective_defense_reduction()
	var reduction := snappedf(defense / (defense + 100.0), 0.001)
	return maxi(1, int(float(enemy.hp) * ratio * (1.0 - reduction)))

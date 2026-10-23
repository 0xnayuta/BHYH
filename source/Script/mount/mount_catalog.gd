extends RefCounted

const SLOT_KEYS := ["Y", "U", "I", "O", "L"]
static var _official_data: Dictionary = {}


static func official_skill(skill_id: String) -> Dictionary:
	_ensure_official_data()
	return _official_data.get("skills", {}).get(skill_id, {})


static func official_buff(group: String, level: int = 1) -> Dictionary:
	_ensure_official_data()
	var buffs: Dictionary = _official_data.get("buffs", {})
	return buffs.get(
		group, buffs.get(str(int(group) * 100 + clampi(level, 1, 20)), buffs.get(str(int(group) * 100 + 1), {}))
	)


static func _ensure_official_data() -> void:
	if _official_data.is_empty():
		var parsed: Variant = JSON.parse_string(
			FileAccess.get_file_as_string("res://Art/mount/official_parts/skill_data.json")
		)
		if parsed is Dictionary:
			_official_data = parsed


const MONSTER_HURT_SPEED_X_SCALE := 30.0
const MONSTER_HURT_SPEED_Y_SCALE := 15.0
const SKILL_DAMAGE_RATE_SCALE := 2.0

const OFFICIAL_MOVEMENT := {
	"3104200": {"mode": "forward", "start": 21.0 / 30.0, "duration": 0.867, "speed": 300.0},
	"3106000": {"mode": "forward", "start": 1.0 / 30.0, "duration": 27.0 / 30.0, "speed": 300.0},
	"3106900": {"mode": "forward", "start": 11.0 / 30.0, "duration": 0.6, "speed": 240.0},
	"3107300": {"mode": "speed_buff", "start": 0.0, "duration": 8.0, "multiplier": 1.8},
	"3110800":
	{
		"mode": "target_leap",
		"duration": 20.0 / 30.0,
		"max_distance": 400.0,
		"jump_start": 9.0 / 30.0,
		"jump_duration": 0.2,
		"jump_speed_x": 300.0,
		"jump_speed_y": -200.0,
		"land_start": 14.0 / 30.0,
		"land_duration": 0.2,
	},
	"3110900":
	{
		"mode": "forward",
		"start": 11.0 / 30.0,
		"duration": 0.2,
		"speed": 800.0,
		"speed_y": -50.0,
	},
}

const OFFICIAL_COMBAT := {
	"3104200":
	{
		"first": 21.0 / 30.0,
		"hits": 6,
		"interval": 0.134,
		"life": 0.867,
		"power": 1.5073,
		"add": 0.044,
		"back": 240,
		"up": -42,
		"attack": "physics",
		"body": true
	},
	"3104300":
	{
		"first": 0.0,
		"hits": 1,
		"interval": 0.0,
		"life": 1.667,
		"power": 7.98,
		"add": 0.133,
		"back": 32,
		"up": -42,
		"attack": "magic",
		"body": true
	},
	"3104400":
	{
		"first": 0.5,
		"hits": 1,
		"interval": 0.0,
		"life": 1.5,
		"power": 1.957,
		"add": 0.076,
		"back": 32,
		"up": -42,
		"attack": "magic",
		"alone": true
	},
	"3104500": {"buff": true},
	"3105100":
	{
		"first": 16.0 / 30.0,
		"hits": 2,
		"interval": 0.234,
		"life": 2.0,
		"power": 4.788,
		"add": 0.133,
		"back": 32,
		"up": -42,
		"attack": "magic"
	},
	"3105200":
	{
		"first": 25.0 / 30.0,
		"hits": 1,
		"interval": 0.0,
		"life": 0.6,
		"power": 3.7683,
		"add": 0.0885,
		"back": 32,
		"up": -42,
		"attack": "magic",
		"alone": true
	},
	"3105300":
	{
		"first": 0.0,
		"hits": 3,
		"interval": 0.334,
		"life": 0.867,
		"power": 3.2806,
		"add": 0.133,
		"back": 32,
		"up": -42,
		"attack": "magic",
		"body": true
	},
	"3105400":
	{
		"first": 0.66,
		"hits": 12,
		"interval": 0.234,
		"life": 10.0,
		"power": 3.1587,
		"add": 0.083,
		"back": 32,
		"up": -42,
		"attack": "magic"
	},
	"3105900":
	{
		"first": 10.0 / 30.0,
		"hits": 1,
		"interval": 0.0,
		"life": 2.0,
		"power": 5.453,
		"add": 0.266,
		"back": 32,
		"up": -42,
		"attack": "magic"
	},
	"3106000":
	{
		"first": 1.0 / 30.0,
		"hits": 8,
		"interval": 0.234,
		"life": 10.0,
		"power": 2.0836,
		"add": 0.0885,
		"back": 32,
		"up": -42,
		"attack": "magic",
		"body": true,
		"alone": true
	},
	"3106100":
	{
		"first": 13.0 / 30.0,
		"hits": 8,
		"interval": 0.234,
		"life": 10.0,
		"power": 1.995,
		"add": 0.0995,
		"back": 120,
		"up": -80,
		"attack": "magic"
	},
	"3106200": {"buff": true},
	"3106700":
	{
		"first": 0.231,
		"hits": 1,
		"interval": 0.0,
		"life": 0.434,
		"power": 0.9975,
		"add": 0.0885,
		"back": 20,
		"up": -60,
		"attack": "physics",
		"alone": true
	},
	"3106800":
	{
		"first": 0.0,
		"hits": 3,
		"interval": 0.267,
		"life": 1.834,
		"power": 4.2116,
		"add": 0.053,
		"back": 100,
		"up": -60,
		"attack": "physics",
		"body": true
	},
	"3106900":
	{
		"first": 11.0 / 30.0,
		"hits": 3,
		"interval": 0.2,
		"life": 0.6,
		"power": 2.527,
		"add": 0.0885,
		"back": 180,
		"up": -60,
		"attack": "physics",
		"body": true
	},
	"3107000":
	{
		"first": 0.0,
		"hits": 5,
		"interval": 0.367,
		"life": 2.1,
		"power": 2.2078,
		"add": 0.053,
		"back": 21,
		"up": -42,
		"attack": "physics",
		"body": true
	},
	"3107100":
	{
		"first": 22.0 / 30.0,
		"hits": 3,
		"interval": 0.2,
		"life": 1.1,
		"power": 3.5023,
		"add": 0.0885,
		"back": 50,
		"up": -60,
		"attack": "physics"
	},
	"3107200":
	{
		"first": 27.0 / 30.0,
		"hits": 1,
		"interval": 0.0,
		"life": 0.5,
		"power": 2.2876,
		"add": 0.053,
		"back": 21,
		"up": -42,
		"attack": "physics",
		"alone": true
	},
	"3107300":
	{
		"first": 1.0 / 30.0,
		"hits": 999,
		"interval": 0.334,
		"life": 8.0,
		"power": 0.2819,
		"add": 0.0155,
		"back": 20,
		"up": -60,
		"attack": "physics",
		"body": true,
		"alone": true
	},
	"3107400":
	{
		"first": 0.66,
		"hits": 12,
		"interval": 0.234,
		"life": 10.0,
		"power": 1.7622,
		"add": 0.0665,
		"back": 100,
		"up": -60,
		"attack": "physics"
	},
	"3107500":
	{
		"first": 0.0,
		"hits": 1,
		"interval": 0.0,
		"life": 0.9,
		"power": 7.98,
		"add": 0.266,
		"back": 120,
		"up": -120,
		"attack": "physics",
		"body": true
	},
	"3107600": {"buff": true},
	"3107700":
	{
		"first": 13.0 / 30.0,
		"hits": 3,
		"interval": 0.234,
		"life": 1.0,
		"power": 3.99,
		"add": 0.133,
		"back": 20,
		"up": -60,
		"attack": "physics"
	},
	"3107800":
	{
		"first": 16.0 / 30.0,
		"hits": 1,
		"interval": 0.0,
		"life": 8.0,
		"power": 5.0983,
		"add": 0.177,
		"back": 100,
		"up": -60,
		"attack": "physics",
		"alone": true
	},
	"3108000":
	{
		"first": 0.0,
		"hits": 50,
		"interval": 0.5,
		"life": 5.5,
		"power": 2.3341,
		"add": 0.069,
		"back": 0,
		"up": -42,
		"attack": "magic"
	},
	"3108100":
	{
		"first": 0.0,
		"hits": 6,
		"interval": 0.234,
		"life": 2.467,
		"power": 3.2851,
		"add": 0.115,
		"back": 33,
		"up": -20,
		"attack": "magic"
	},
	"3108300":
	{
		"first": 25.0 / 30.0,
		"hits": 999,
		"interval": 0.3,
		"life": 2.667,
		"power": 2.0315,
		"add": 0.086,
		"back": 100,
		"up": -60,
		"attack": "physics"
	},
	"3109100":
	{
		"first": 8.0 / 30.0,
		"hits": 3,
		"interval": 0.3,
		"life": 1.167,
		"power": 1.2888,
		"add": 0.0625,
		"back": 130,
		"up": -42,
		"attack": "physics"
	},
	"3109200":
	{
		"first": 14.0 / 30.0,
		"hits": 3,
		"interval": 0.3,
		"life": 1.934,
		"power": 4.4954,
		"add": 0.115,
		"back": 32,
		"up": -42,
		"attack": "magic"
	},
	"3109600":
	{
		"first": 17.0 / 30.0,
		"hits": 999,
		"interval": 0.3,
		"life": 10.0,
		"power": 0.5253,
		"add": 0.0265,
		"back": 50,
		"up": -30,
		"attack": "physics"
	},
	"3110800":
	{
		"first": 20.0 / 30.0,
		"hits": 2,
		"interval": 0.4,
		"life": 0.4,
		"power": 8.113,
		"add": 0.4655,
		"back": 10,
		"up": -50,
		"attack": "physics"
	},
	"3110900":
	{
		"first": 14.0 / 30.0,
		"hits": 1,
		"interval": 0.8,
		"life": 0.4,
		"power": 11.97,
		"add": 0.7445,
		"back": 100,
		"up": -50,
		"attack": "physics"
	},
	"3111000":
	{
		"first": 14.0 / 30.0,
		"hits": 8,
		"interval": 0.5,
		"life": 4.0,
		"power": 1.9019,
		"add": 0.121,
		"back": 30,
		"up": -50,
		"attack": "physics",
		"alone": true
	},
	"3111100": {"buff": true},
	"3111101":
	{
		"first": 9.0 / 30.0,
		"hits": 10,
		"interval": 0.7,
		"life": 0.6,
		"power": 2.3514,
		"add": 0.138,
		"back": 20,
		"up": -30,
		"attack": "physics"
	},
	"3111200":
	{
		"first": 6.0 / 30.0,
		"hits": 1,
		"interval": 0.2,
		"life": 0.9,
		"power": 1.0,
		"add": 0.0,
		"back": 50,
		"up": -50,
		"attack": "physics"
	},
}

const OFFICIAL_NORMAL_COMBAT := {
	"1002200":
	{
		"first": 0.0,
		"hits": 1,
		"interval": 0.0,
		"life": 0.933,
		"power": 3.724,
		"add": 0.0,
		"back": 21,
		"up": -42,
		"attack": "physics",
		"body": true
	},
	"1002700":
	{
		"first": 1.0 / 30.0,
		"hits": 5,
		"interval": 0.2,
		"life": 0.6,
		"power": 0.532,
		"add": 0.0,
		"back": 21,
		"up": -42,
		"attack": "physics",
		"body": true
	},
	"1002800":
	{
		"first": 19.0 / 30.0,
		"hits": 1,
		"interval": 0.0,
		"life": 0.4,
		"power": 5.32,
		"add": 0.0,
		"back": 21,
		"up": -42,
		"attack": "physics",
		"body": true
	},
	"1003500":
	{
		"first": 0.0,
		"hits": 1,
		"interval": 0.0,
		"life": 0.7,
		"power": 2.527,
		"add": 0.0,
		"back": 21,
		"up": -42,
		"attack": "physics",
		"body": true
	},
	"1003600":
	{
		"first": 0.0,
		"hits": 1,
		"interval": 0.0,
		"life": 1.733,
		"power": 1.596,
		"add": 0.0,
		"back": 33,
		"up": -66,
		"attack": "physics",
		"body": true
	},
	"1003900":
	{
		"first": 0.0,
		"hits": 2,
		"interval": 0.4,
		"life": 1.667,
		"power": 2.926,
		"add": 0.0,
		"back": 21,
		"up": -42,
		"attack": "physics",
		"body": true
	},
	"1004700":
	{
		"first": 0.0,
		"hits": 1,
		"interval": 0.2,
		"life": 1.733,
		"power": 2.128,
		"add": 0.0,
		"back": 21,
		"up": -42,
		"attack": "physics",
		"body": true
	},
}

const SKILLS := {
	"1002200":
	[
		{"id": "3106900", "name": "横扫千军", "description": "向前快速冲刺", "cooldown": 10.0, "power": 1.8, "kind": "dash"},
		{
			"id": "3107000",
			"name": "噬血虎爪",
			"description": "用爪子对前方怪物进行多段攻击",
			"cooldown": 10.0,
			"power": 2.2,
			"kind": "claw"
		},
		{
			"id": "3106700",
			"name": "战神之爪",
			"description": "多次召唤战神虎爪从天降落并造成破甲",
			"cooldown": 15.0,
			"power": 2.8,
			"kind": "rain"
		},
		{
			"id": "3106800",
			"name": "虎啸风生",
			"description": "朝前方怒吼出一个巨型声波",
			"cooldown": 20.0,
			"power": 3.6,
			"kind": "wave"
		},
		{
			"id": "3108300",
			"name": "灵能聚变",
			"description": "在头顶聚集灵能，随后朝前方发射，落地后牵引敌人并造成伤害",
			"cooldown": 20.0,
			"power": 5.0,
			"kind": "ultimate"
		},
	],
	"1002700":
	[
		{
			"id": "3107500",
			"name": "神鹿撞击",
			"description": "用头上的角将敌人顶飞，造成晕眩",
			"cooldown": 10.0,
			"power": 1.9,
			"kind": "dash"
		},
		{
			"id": "3107600",
			"name": "鹿飞九天",
			"description": "神域之雪漫舞周身，提升伤害和速度",
			"cooldown": 15.0,
			"power": 1.25,
			"kind": "buff"
		},
		{
			"id": "3107700",
			"name": "雪舞霜冻",
			"description": "从头顶降下雪花雨并冻结敌人",
			"cooldown": 15.0,
			"power": 2.7,
			"kind": "rain"
		},
		{
			"id": "3107800",
			"name": "破空飞雪",
			"description": "从鹿角连续发射雪花子弹",
			"cooldown": 20.0,
			"power": 3.3,
			"kind": "projectile"
		},
		{
			"id": "3108000",
			"name": "凛冽风暴",
			"description": "召唤极寒风暴席卷全场",
			"cooldown": 20.0,
			"power": 5.0,
			"kind": "ultimate"
		},
	],
	"1002800":
	[
		{"id": "3107100", "name": "沧浪之水", "description": "向前发射一道冲击浪", "cooldown": 10.0, "power": 1.8, "kind": "wave"},
		{
			"id": "3107200",
			"name": "爆破魔珠",
			"description": "水弹命中后炸裂并分化旋转",
			"cooldown": 10.0,
			"power": 2.3,
			"kind": "projectile"
		},
		{"id": "3107300", "name": "流光飞舞", "description": "加速前进并眩晕沿途敌人", "cooldown": 15.0, "power": 2.8, "kind": "dash"},
		{"id": "3107400", "name": "漫天飞星", "description": "全屏召唤流星划落", "cooldown": 20.0, "power": 3.7, "kind": "rain"},
		{
			"id": "3108100",
			"name": "惊涛骇浪",
			"description": "召唤滚滚巨浪覆盖全场",
			"cooldown": 20.0,
			"power": 5.0,
			"kind": "ultimate"
		},
	],
	"1003500":
	[
		{
			"id": "3105900",
			"name": "龙鱼吐珠",
			"description": "向前吐出水珠并使目标减速",
			"cooldown": 10.0,
			"power": 1.8,
			"kind": "projectile"
		},
		{
			"id": "3106000",
			"name": "鱼龙九变",
			"description": "快速向前游动并伤害路径敌人",
			"cooldown": 10.0,
			"power": 2.2,
			"kind": "dash"
		},
		{
			"id": "3106100",
			"name": "鱼龙幻形",
			"description": "凝聚鲲鱼向前冲击并击飞敌人",
			"cooldown": 15.0,
			"power": 2.9,
			"kind": "wave"
		},
		{
			"id": "3106200",
			"name": "梦幻泡泡",
			"description": "彩色泡泡环绕周身并强化攻击",
			"cooldown": 20.0,
			"power": 1.3,
			"kind": "buff"
		},
		{
			"id": "3109100",
			"name": "汇元凝珠",
			"description": "水凝珠爆炸并发射大量水弹",
			"cooldown": 20.0,
			"power": 5.0,
			"kind": "ultimate"
		},
	],
	"1003600":
	[
		{"id": "3105100", "name": "天降寒冰", "description": "召唤寒冰砸向敌人并爆炸", "cooldown": 10.0, "power": 1.9, "kind": "rain"},
		{
			"id": "3105200",
			"name": "神龙吐晶",
			"description": "从口中射出三枚寒冰弹",
			"cooldown": 10.0,
			"power": 2.3,
			"kind": "projectile"
		},
		{
			"id": "3105300",
			"name": "飞龙在天",
			"description": "全屏翱翔并眩晕碰到的怪物",
			"cooldown": 15.0,
			"power": 3.0,
			"kind": "dash"
		},
		{"id": "3105400", "name": "漫天风霜", "description": "召唤全屏冰晶坠落", "cooldown": 25.0, "power": 3.9, "kind": "rain"},
		{
			"id": "3109200",
			"name": "绝对冰封",
			"description": "创造冰之幻境冰封并破碎全场",
			"cooldown": 20.0,
			"power": 5.2,
			"kind": "ultimate"
		},
	],
	"1003900":
	[
		{"id": "3104200", "name": "屠戮之角", "description": "低头向前发起冲锋", "cooldown": 10.0, "power": 1.9, "kind": "dash"},
		{
			"id": "3104300",
			"name": "八荒俱灭",
			"description": "怒吼震地，眩晕周围怪物",
			"cooldown": 10.0,
			"power": 2.4,
			"kind": "burst"
		},
		{
			"id": "3104400",
			"name": "凶星陨落",
			"description": "连续落下七颗陨石攻击附近怪物",
			"cooldown": 20.0,
			"power": 3.1,
			"kind": "rain"
		},
		{
			"id": "3104500",
			"name": "古藤兽甲",
			"description": "强化攻击并减少受到的伤害",
			"cooldown": 20.0,
			"power": 1.35,
			"kind": "buff"
		},
		{
			"id": "3109600",
			"name": "狂沙走石",
			"description": "飞石狂沙持续伤害周围敌人",
			"cooldown": 20.0,
			"power": 5.0,
			"kind": "ultimate"
		},
	],
	"1004700":
	[
		{
			"id": "3110800",
			"name": "腾龙重跃",
			"description": "跳向最近敌人并造成两次重击",
			"cooldown": 20.0,
			"power": 2.1,
			"kind": "leap"
		},
		{
			"id": "3110900",
			"name": "汲魄龙威",
			"description": "幻化龙形猛突并强化攻击与命中",
			"cooldown": 20.0,
			"power": 2.5,
			"kind": "dash"
		},
		{"id": "3111000", "name": "霜飓冻狱", "description": "三团霜寒飓风围绕自身", "cooldown": 20.0, "power": 3.0, "kind": "aura"},
		{
			"id": "3111100",
			"name": "爪电天罚",
			"description": "爪附雷电，普攻额外触发雷击",
			"cooldown": 10.0,
			"power": 1.4,
			"kind": "buff"
		},
		{
			"id": "3111200",
			"name": "腾龙转生",
			"description": "切换飞行形态并强化攻击和暴击",
			"cooldown": 20.0,
			"power": 5.2,
			"kind": "ultimate"
		},
	],
}


static func get_skills(mount_id: String) -> Array:
	var value: Variant = SKILLS.get(mount_id, [])
	return value.duplicate(true) if value is Array else []


static func get_official_combat(skill_id: String) -> Dictionary:
	var value: Variant = OFFICIAL_COMBAT.get(skill_id, {})
	if (
		(value as Dictionary).is_empty()
		and skill_id in ["3003800", "3111300", "3111400", "3111500", "3111600", "3111601", "3111700"]
	):
		var raw := official_skill(skill_id)
		var moves := str(raw.get("targetMove", "0,0")).split(",")
		value = {
			"first": 0.0,
			"hits": int(raw.get("attMax", 1)),
			"interval": float(raw.get("attInterval", 0)) / 1000.0,
			"life": 4.0 if skill_id == "3111500" else 1.0,
			"power": float(raw.get("skillDefault", 1.0)),
			"add": float(raw.get("skillAdd", 0.0)) + float(raw.get("horseSkillAdd", 0.0)),
			"back": int(moves[0]),
			"up": -int(moves[1]),
			"attack": "physics",
		}
		if skill_id == "3111600":
			value = {"buff": true}
	if not (value is Dictionary):
		return {}
	var result: Dictionary = (value as Dictionary).duplicate(true)
	if not bool(result.get("buff", false)):
		if result.has("power"):
			result["power"] = float(result["power"]) * SKILL_DAMAGE_RATE_SCALE
		if result.has("add"):
			result["add"] = float(result["add"]) * SKILL_DAMAGE_RATE_SCALE
	return result


static func get_official_normal_combat(mount_id: String) -> Dictionary:
	var value: Variant = OFFICIAL_NORMAL_COMBAT.get(mount_id, {})
	return value.duplicate(true) if value is Dictionary else {}


static func get_official_movement(skill_id: String) -> Dictionary:
	var value: Variant = OFFICIAL_MOVEMENT.get(skill_id, {})
	return value.duplicate(true) if value is Dictionary else {}


static func to_runtime_knockback_x(value: Variant) -> float:
	return float(value) / MONSTER_HURT_SPEED_X_SCALE


static func to_runtime_knockback_y(value: Variant) -> float:
	return float(value) / MONSTER_HURT_SPEED_Y_SCALE


static func get_icon_path(skill_id: String) -> String:
	var path := "res://Art/mount/skills/%s.png" % skill_id
	return path if ResourceLoader.exists(path) else ""

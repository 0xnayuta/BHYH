## 7.4 魂卡/精英系统；由 7.4 反编译参考按当前 API、命名与路径适配。
extends RefCounted

const KEY: String = DataKeys.SOUL_CARD
const AVAILABLE_IDS := ["qly", "sfe"]
const IDS := [
	"qly", "sfe", "jls", "nz", "hwc", "bwc", "pg", "ylw", "lw", "jmw", "stw", "pmw", "zztw", "gmtw", "dwtw", "cgtw"
]
const CARDS := {
	"qly":
	{
		"name": "千里眼",
		"monster": 77,
		"group": 0,
		"type": "attack",
		"skill": "攻击命中25%概率从目标上方落下3支追踪箭，每支10倍攻击物伤。冷却3秒。",
		"elite": "箭雨追猎：扇形箭矢后，目标脚下追加延迟落箭。"
	},
	"sfe":
	{
		"name": "顺风耳",
		"monster": 78,
		"group": 0,
		"type": "magic",
		"skill": "攻击命中25%概率释放10倍攻击魔法声波，附加4秒回响。冷却4秒。",
		"elite": "回声震荡：声波命中后在原地留下回响区。"
	},
	"jls":
	{
		"name": "巨灵神",
		"monster": 79,
		"group": 0,
		"type": "attack",
		"skill": "有效命中累计8次，落下16倍攻击物理巨斧，击退普通怪。冷却5秒。",
		"elite": "裂地巨斧：连续落斧，低血量追加两侧裂地。"
	},
	"nz":
	{
		"name": "哪吒",
		"monster": 102,
		"group": 0,
		"type": "magic",
		"skill": "释放技能后投出火轮，持续3秒，每0.5秒造成10倍攻击魔伤。冷却6秒。",
		"elite": "烈焰封锁：火轮沿地面推进，半血后夹击。"
	},
	"hwc":
	{
		"name": "黑无常",
		"monster": 30,
		"group": 1,
		"type": "magic",
		"skill": "攻击命中25%概率附加索命，4秒内每秒10倍攻击魔伤。冷却4秒。",
		"elite": "索命印：追踪锁定后引爆，并留下幽冥伤害区。"
	},
	"bwc":
	{
		"name": "白无常",
		"monster": 31,
		"group": 1,
		"type": "hybrid",
		"skill": "技能命中释放摄魂锁链，造成10倍攻击魔伤并牵引普通怪。冷却5秒。",
		"elite": "摄魂锁阵：多条锁链封锁目标附近区域。"
	},
	"pg":
	{
		"name": "判官",
		"monster": 41,
		"group": 1,
		"type": "magic",
		"skill": "每6次有效命中追加判印，每秒最多1层；3层引爆20倍攻击魔伤。",
		"elite": "生死判印：连续判印预警，最后引爆中心区域。"
	},
	"ylw":
	{
		"name": "阎罗王",
		"monster": 43,
		"group": 1,
		"type": "tank",
		"skill": "命中生命低于35%的目标触发24倍攻击魔法审判，并获得10%最大生命护盾，持续6秒。冷却10秒。",
		"elite": "幽冥审判：大范围延迟爆发，低血量追加冥火。"
	},
	"lw":
	{
		"name": "龙王",
		"monster": 6,
		"group": 2,
		"type": "magic",
		"skill": "释放技能后在目标处留下4秒水域，每秒10倍攻击魔伤并浸水。冷却6秒。",
		"elite": "覆海水柱：水柱连发，落点留下短暂水域。"
	},
	"jmw":
	{
		"name": "蛟魔王",
		"monster": 18,
		"group": 2,
		"type": "magic",
		"skill": "攻击命中25%概率放出贯穿水龙，造成12倍攻击魔伤。冷却4秒。",
		"elite": "双龙冲击：两条水龙交错冲锋，附加落点爆发。"
	},
	"stw":
	{
		"name": "狮驼王",
		"monster": 11,
		"group": 2,
		"type": "attack",
		"skill": "累计5次有效暴击触发14倍攻击物理狮吼，普通怪眩晕1秒。冷却5秒。",
		"elite": "狮吼破阵：蓄力冲击，半血后追加环形震波。"
	},
	"pmw":
	{
		"name": "鹏魔王",
		"monster": 12,
		"group": 2,
		"type": "attack",
		"skill": "攻击命中25%概率发出贯穿风刃，造成10倍攻击物伤。冷却3秒。",
		"elite": "裂空风刃：多路风刃，延迟二次横扫。"
	},
	"zztw":
	{
		"name": "增长天王",
		"monster": 83,
		"group": 3,
		"type": "attack",
		"skill": "每释放3次角色技能，巨剑斩下18倍攻击物理范围伤害。冷却6秒。",
		"elite": "巨剑连裁：目标处落剑后追加两侧剑阵。"
	},
	"gmtw":
	{
		"name": "广目天王",
		"monster": 84,
		"group": 3,
		"type": "magic",
		"skill": "攻击命中25%概率召出灵蛇，造成10倍攻击魔伤并附加4秒蛇印。冷却4秒。",
		"elite": "灵蛇封路：灵蛇穿行后留下蛇毒区域。"
	},
	"dwtw":
	{
		"name": "多闻天王",
		"monster": 85,
		"group": 3,
		"type": "tank",
		"skill": "每10秒获得15%最大生命护盾，持续6秒；受击时向攻击者反射10倍攻击魔法光矢，每秒最多1次。",
		"elite": "宝伞光阵：定点光柱爆发，低血量增加光柱数量。"
	},
	"cgtw":
	{
		"name": "持国天王",
		"monster": 137,
		"group": 3,
		"type": "hybrid",
		"skill": "释放技能产生10倍攻击魔法音波；下一次技能命中追加10倍攻击音波。冷却5秒。",
		"elite": "梵音回响：音波连奏，残留区域持续伤害。"
	},
}
const PAIRS := [
	{"id": "ears", "name": "耳目通天", "cards": ["qly", "sfe"], "text": "追踪箭增至5支，齐射命中回响目标追加一次10倍攻击音爆。"},
	{"id": "army", "name": "天将破阵", "cards": ["jls", "nz"], "text": "巨斧命中火轮覆盖目标追加10倍攻击火爆，并延长该火轮1秒（每轮一次）。"},
	{"id": "reaper", "name": "勾魂索命", "cards": ["hwc", "bwc"], "text": "锁链结算目标剩余索命伤害，并重新附加索命。组合冷却6秒。"},
	{"id": "judgment", "name": "生死判决", "cards": ["pg", "ylw"], "text": "判印爆炸留下6秒死判，使阎罗审判不受目标生命门槛限制。"},
	{"id": "dragons", "name": "双龙覆海", "cards": ["lw", "jmw"], "text": "水龙经过水域时分出两道10倍攻击侧浪，命中浸水目标追加10倍攻击水柱。"},
	{"id": "beasts", "name": "狮鹏裂空", "cards": ["stw", "pmw"], "text": "狮吼施加4秒裂空；风刃命中后分裂两道10倍攻击风刃，优先追击其他敌人。"},
	{"id": "swords", "name": "剑蛇合击", "cards": ["zztw", "gmtw"], "text": "巨剑命中蛇印目标追加两柄10倍攻击小剑。"},
	{"id": "guard", "name": "宝伞梵音", "cards": ["dwtw", "cgtw"], "text": "护盾存在时琵琶音波伤害+50%；护盾被击破产生10倍攻击音波，4秒内双防+20%。"},
	{"id": "hunt", "name": "穿云追猎", "cards": ["qly", "pmw"], "text": "追踪箭标记优先猎物，下一次风刃优先追击该目标并增加30%伤害。"},
	{"id": "echo", "name": "余音不绝", "cards": ["sfe", "cgtw"], "text": "琵琶命中回响目标，0.5秒后追加一次10倍攻击回声。"},
	{"id": "water_snake", "name": "水府灵蛇", "cards": ["lw", "gmtw"], "text": "灵蛇命中浸水目标时，向附近敌人扩散蛇印，并各造成10倍攻击魔伤。"},
	{"id": "fortress", "name": "攻守兼备", "cards": ["jls", "dwtw"], "text": "巨斧命中时回复最大生命5%的魂卡护盾，最多回复至宝伞护盾上限。"},
]
const SETS := [
	{"id": "heaven", "name": "天庭征伐", "cards": ["qly", "sfe", "jls", "nz"], "text": "四种技能各触发一次，发动30倍攻击范围合击，冷却15秒。"},
	{
		"id": "underworld",
		"name": "幽冥审判",
		"cards": ["hwc", "bwc", "pg", "ylw"],
		"text": "魂卡有效命中累计12次形成4秒幽冥领域，每秒10倍攻击魔伤，判印累计需求减半并获得10%生命护盾，冷却15秒。"
	},
	{
		"id": "kings",
		"name": "妖王会盟",
		"cards": ["lw", "jmw", "stw", "pmw"],
		"text": "狮吼或风刃命中浸水目标，引发12倍攻击风水爆发并聚拢普通怪，冷却4秒。"
	},
	{
		"id": "guardians",
		"name": "四大天王",
		"cards": ["zztw", "gmtw", "dwtw", "cgtw"],
		"text": "四种技能各触发一次，获得6秒加护：魂卡伤害+50%，现有护盾强化50%，冷却18秒。"
	},
]
const STAR_COSTS := [0, 20, 40, 80, 160]
const STAR_STATS := [0.0, 1.0, 1.35, 1.75, 2.25, 3.0]
const ATTRIBUTES := {
	"attack": {"power": 4500.0, "Crit": 15.0, "ar": 250.0},
	"magic": {"power": 4000.0, "SMp": 1000.0, "sp": 250.0},
	"tank": {"SHp": 60000.0, "Def": 500.0, "Mdef": 500.0},
	"hybrid": {"SHp": 30000.0, "power": 2500.0, "R_mp": 3.0},
}
const STAT_NAMES := {
	"power": "攻击",
	"SHp": "生命",
	"SMp": "魔法",
	"Def": "物防",
	"Mdef": "魔防",
	"Crit": "暴击",
	"ar": "破甲",
	"sp": "破魔",
	"R_mp": "回魔"
}
const TIERS := ["精英", "炼狱", "极限"]
const HP_MULT := [3.0, 6.0, 12.0]
const ATK_MULT := [1.3, 1.6, 2.0]
const DEF_MULT := [1.15, 1.3, 1.5]
const FRAGMENTS := [3, 8, 18]
const FULL_CHANCE := [0.1, 0.15, 0.2]


static func ensure(profile: Dictionary) -> Dictionary:
	var value: Variant = profile.get(KEY, {})
	var data: Dictionary = value if value is Dictionary else {}
	for field in ["cards", "loadouts", "clears", "first_clears"]:
		if not data.get(field) is Dictionary:
			data[field] = {}
	for id in IDS:
		var record: Variant = data.cards.get(id, {})
		if not record is Dictionary:
			record = {}
		record["star"] = clampi(int(record.get("star", 0)), 0, 5)
		record["fragments"] = maxi(0, int(record.get("fragments", 0)))
		data.cards[id] = record
	for role in range(1, 9):
		var slots: Variant = data.loadouts.get(str(role), [])
		if not slots is Array:
			slots = []
		var clean: Array[String] = []
		for index in range(6):
			var id = str(slots[index]) if index < slots.size() else ""
			if not CARDS.has(id) or clean.has(id) or int(data.cards.get(id, {}).get("star", 0)) < 1:
				id = ""
			clean.append(id)
		data.loadouts[str(role)] = clean
	profile[KEY] = data
	return data


static func record(profile: Dictionary, id: String) -> Dictionary:
	return ensure(profile).cards.get(id, {})


static func equipped(profile: Dictionary, role: int = -1) -> Array:
	var selected_role = int(profile.get("Myself", 1)) if role < 0 else role
	return ensure(profile).loadouts[str(clampi(selected_role, 1, 8))].duplicate()


static func equip(profile: Dictionary, id: String, slot: int, in_battle: bool = false) -> bool:
	if in_battle or slot < 0 or slot >= 6 or (id != "" and not CARDS.has(id)):
		return false
	var data = ensure(profile)
	if id != "" and int(data.cards[id].star) < 1:
		return false
	var slots: Array = data.loadouts[str(clampi(int(profile.get("Myself", 1)), 1, 8))]
	if id != "" and slots.has(id):
		slots[slots.find(id)] = ""
	slots[slot] = id
	return true


static func upgrade(profile: Dictionary, id: String) -> bool:
	if not CARDS.has(id):
		return false
	var card = record(profile, id)
	var star = int(card.star)
	if star < 1 or star >= 5 or int(card.fragments) < STAR_COSTS[star]:
		return false
	card.fragments -= STAR_COSTS[star]
	card.star += 1
	return true


static func skill_multiplier(star: int) -> float:
	return 1.0 + float(clampi(star, 1, 5) - 1) * 0.25


static func card_stats(id: String, star: int, collection: bool) -> Dictionary:
	var result: Dictionary = {}
	if not CARDS.has(id) or star < 1:
		return result
	var factor: float = STAR_STATS[clampi(star, 1, 5)] * (0.2 if collection else 1.0)
	for key in ATTRIBUTES[CARDS[id].type]:
		result[key] = snappedf(float(ATTRIBUTES[CARDS[id].type][key]) * factor, 0.1)
	return result


static func attribute_totals(profile: Dictionary) -> Dictionary:
	var data = ensure(profile)
	var slots: Array = data.loadouts[str(clampi(int(profile.get("Myself", 1)), 1, 8))]
	var total: Dictionary = {}
	for id in IDS:
		var star = int(data.cards[id].star)
		var values = card_stats(id, star, true)
		if slots.has(id):
			var extra = card_stats(id, star, false)
			for key in extra:
				values[key] = float(values.get(key, 0.0)) + float(extra[key])
		for key in values:
			total[key] = float(total.get(key, 0.0)) + float(values[key])
	return total


static func active_bonds(slots: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for bond in PAIRS + SETS:
		var active = true
		for id in bond.cards:
			if not slots.has(id):
				active = false
		if active:
			result.append(bond)
	return result


static func stats_text(values: Dictionary) -> String:
	var result: PackedStringArray = []
	for key in values:
		result.append("%s +%s" % [STAT_NAMES.get(key, key), str(snappedf(float(values[key]), 0.1))])
	return "　".join(result) if not result.is_empty() else "尚未获得"


static func portrait_path(id: String) -> String:
	return "res://Art/monster/creature_codex/%d.png" % int(CARDS[id].monster)


static func portrait_art_path(id: String) -> String:
	return "res://Art/soul_card/elite/%s_portrait.tres" % id


static func claim(profile: Dictionary, id: String, tier: int, roll: float = -1.0) -> Dictionary:
	if not CARDS.has(id) or tier < 0 or tier > 2:
		return {}
	var data = ensure(profile)
	var card: Dictionary = data.cards[id]
	var amount: int = randi_range(5, 12) if roll < 0.0 else clampi(5 + int(roll * 8.0), 5, 12)
	var first_bonus = 0
	var full = int(data.clears.get(id, -1)) < 0 or (randf() if roll < 0.0 else roll) < 0.25
	data.first_clears["%s_%d" % [id, tier]] = true
	var acquired = full and int(card.star) == 0
	if acquired:
		card.star = 1
	elif full:
		amount += 20
	card.fragments += amount
	data.clears[id] = maxi(int(data.clears.get(id, -1)), tier)
	return {"name": CARDS[id].name, "acquired": acquired, "fragments": amount, "first_bonus": first_bonus, "full": full}


static func persist(context: Node) -> void:
	var memory = context.get_node_or_null("/root/MemoryClass")
	if memory != null:
		memory.request_save("soul_card")

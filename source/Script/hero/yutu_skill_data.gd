extends RefCounted
class_name YutuSkillData

const KEYS := ["yt_mds", "yt_tyy", "yt_xdz", "yt_hyl", "yt_ldmw", "yt_fyz", "yt_xyyy", "yt_yl", "yt_ygj", "yt_ymw"]
const IDS := [
	"1111010", "1111020", "1111030", "1111040", "1111050", "1112010", "1112020", "1112030", "1112040", "1112050"
]
const NAMES := ["蔓毒散", "兔影跃", "玄毒针", "回元露", "炼毒魔瓮", "飞月斩", "星移月影", "月轮", "月光诀", "月魔舞"]

const ACTIONS := ["skill3", "skill2", "skill3", "skill4", "skill3", "skill1", "skill2", "skill3", "skill4", "skill5"]

const DAMAGE_GROWTH := {
	"111101": 0.2,
	"111102": 0.26,
	"111103": 0.2,
	"111105": 0.43,
	"111201": 0.15,
	"111202": 0.26,
	"111203": 0.15,
	"111205": 0.25,
}
const MOON_DANCE_HITS := 8
const MOON_WHEEL_INTERVAL_MS := 500
const POISON_DAMAGE_RATIO := 0.25
const NEEDLE_AWAKEN_RANGE_MULTIPLIER := 2.0
const NEEDLE_AWAKEN_SPREAD_DEGREES := 15.0
const NEEDLE_AWAKEN_DESCRIPTION := "射程更远，造成的毒素层数翻倍，并向上、下各额外发射一道毒针。"
const POWDER_AWAKEN_SCALE := 2.0
const POWDER_AWAKEN_DESCRIPTION := "药粉范围扩大至2倍，造成的毒素层数翻倍。"
const JAR_AWAKEN_EXTRA_EXPLOSIONS := 3
const JAR_AWAKEN_INTERVAL := 0.2
const JAR_AWAKEN_DESCRIPTION := "爆炸后在原位置每隔0.2秒额外爆炸，共追加3次，造成的毒素层数翻倍。"
const PASSIVE_KEY := "yt_yyzh"
const PASSIVE_NAME := "月影追魂"
const PASSIVE_SLOT := 11
const PASSIVE_MARKS := 8
const PASSIVE_BASE := 1.5
const PASSIVE_GROWTH := 0.3
const PASSIVE_DESCRIPTION := "被动：每次对敌人造成有效的非毒素伤害时，为该敌人叠加1层月印；达到8层时消耗全部月印，从屏幕上方召唤月影追击该目标。"
static var _data: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		var parsed: Variant = JSON.parse_string(
			FileAccess.get_file_as_string("res://Art/hero_picture/role_7/skills.json")
		)
		if parsed is Dictionary:
			_data = parsed
			var skills: Dictionary = _data.get("skills", {})
			for id: String in skills:
				var family := id.left(6)
				if DAMAGE_GROWTH.has(family):
					skills[id]["skillAdd"] = DAMAGE_GROWTH[family]
			if skills.has("1112031"):
				skills["1112031"]["attInterval"] = MOON_WHEEL_INTERVAL_MS
	return _data


static func row(id: String) -> Dictionary:
	return data().get("skills", {}).get(id, {})


static func skill(key: String) -> Dictionary:
	if key == PASSIVE_KEY:
		return {"name": PASSIVE_NAME, "description": PASSIVE_DESCRIPTION, "consumeMP": "0"}
	var index := KEYS.find(key)
	return row(IDS[index]) if index >= 0 else {}


static func buff_row(id: String, level: int) -> Dictionary:
	return data().get("buffs", {}).get(id + "%02d" % clampi(level, 1, 30), {})


static func number_at(value: String, level: int) -> float:
	if value.is_empty():
		return 0.0
	var values := value.split(",")
	return float(values[clampi(level - 1, 0, values.size() - 1)])


static func mp(key: String, level: int) -> int:
	return int(number_at(str(skill(key).get("consumeMP", "0")), level))


static func passive_damage(level: int, power: float) -> float:
	return power * (PASSIVE_BASE + level * PASSIVE_GROWTH) if level > 0 else 0.0


static func icon_key(key: String) -> String:
	return key


static func damage(id: String, level: int, power: float) -> float:
	var entry := row(id)
	level = clampi(level, 1, 30)
	return (
		power * (float(entry.get("skillDefault", "0")) + float(entry.get("skillAdd", "0")) * (level - 1))
		+ number_at(str(entry.get("skillCountAdd", "0")), level)
	)


static func descriptions() -> Array:
	var result: Array = []
	for id: String in IDS:
		var description := str(row(id).get("description", "")).replace("\\n", "\n")
		if id == "1112030":
			description += "\n觉醒：牵引全屏怪物（包括空中目标），每次伤害叠加2层月印。"
		elif id == "1111030":
			description += "\n觉醒：" + NEEDLE_AWAKEN_DESCRIPTION
		elif id == "1111010":
			description += "\n觉醒：" + POWDER_AWAKEN_DESCRIPTION
		elif id == "1111050":
			description += "\n觉醒：" + JAR_AWAKEN_DESCRIPTION
		result.append(description)
	return result

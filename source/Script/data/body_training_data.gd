extends RefCounted
class_name BodyTrainingData

const BODY_IDS := [10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009, 10010, 10011, 10012]
const BODY_NAMES := ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
const BODY_CONFIG := {
	10001:
	{
		"levelMax": 25,
		"propId": "105000012",
		"attributeT": "hpMax",
		"initialValue": 200,
		"levelBase": 200,
		"levelGrowth": 20,
		"expPos": 0,
		"pointTicket": 100
	},
	10002:
	{
		"levelMax": 25,
		"propId": "105000013",
		"attributeT": "mpMax",
		"initialValue": 150,
		"levelBase": 150,
		"levelGrowth": 15,
		"expPos": 0,
		"pointTicket": 100
	},
	10003:
	{
		"levelMax": 25,
		"propId": "105000014",
		"attributeT": "def",
		"initialValue": 10,
		"levelBase": 15,
		"levelGrowth": 3,
		"expPos": 0,
		"pointTicket": 100
	},
	10004:
	{
		"levelMax": 25,
		"propId": "105000015",
		"attributeT": "atk",
		"initialValue": 25,
		"levelBase": 25,
		"levelGrowth": 5,
		"expPos": 0,
		"pointTicket": 100
	},
	10005:
	{
		"levelMax": 25,
		"propId": "105000016",
		"attributeT": "hpMax",
		"initialValue": 400,
		"levelBase": 400,
		"levelGrowth": 40,
		"expPos": 1,
		"pointTicket": 100
	},
	10006:
	{
		"levelMax": 25,
		"propId": "105000017",
		"attributeT": "mpMax",
		"initialValue": 300,
		"levelBase": 300,
		"levelGrowth": 30,
		"expPos": 1,
		"pointTicket": 100
	},
	10007:
	{
		"levelMax": 25,
		"propId": "105000018",
		"attributeT": "def",
		"initialValue": 20,
		"levelBase": 30,
		"levelGrowth": 6,
		"expPos": 1,
		"pointTicket": 100
	},
	10008:
	{
		"levelMax": 25,
		"propId": "105000019",
		"attributeT": "atk",
		"initialValue": 50,
		"levelBase": 50,
		"levelGrowth": 10,
		"expPos": 1,
		"pointTicket": 100
	},
	10009:
	{
		"levelMax": 25,
		"propId": "105000020",
		"attributeT": "hpMax",
		"initialValue": 600,
		"levelBase": 600,
		"levelGrowth": 60,
		"expPos": 2,
		"pointTicket": 100
	},
	10010:
	{
		"levelMax": 25,
		"propId": "105000021",
		"attributeT": "mpMax",
		"initialValue": 450,
		"levelBase": 450,
		"levelGrowth": 45,
		"expPos": 2,
		"pointTicket": 100
	},
	10011:
	{
		"levelMax": 25,
		"propId": "105000022",
		"attributeT": "def",
		"initialValue": 30,
		"levelBase": 45,
		"levelGrowth": 9,
		"expPos": 2,
		"pointTicket": 100
	},
	10012:
	{
		"levelMax": 25,
		"propId": "105000023",
		"attributeT": "atk",
		"initialValue": 75,
		"levelBase": 75,
		"levelGrowth": 15,
		"expPos": 2,
		"pointTicket": 100
	},
}


static func get_config(body_id: int) -> Dictionary:
	return (BODY_CONFIG.get(body_id, {}) as Dictionary).duplicate(true)


static func get_level_value(body_id: int, level: int) -> int:
	var config := get_config(body_id)
	var count := clampi(level, 0, int(config.get("levelMax", 25)))
	if count <= 0:
		return 0
	var total := int(config.get("initialValue", 0))
	var level_base := int(config.get("levelBase", 0))
	var level_growth := int(config.get("levelGrowth", 0))
	for current_level in range(1, count):
		total += level_base + current_level * level_growth
	return total


static func get_next_value(body_id: int, level: int) -> int:
	return get_level_value(body_id, level + 1)


static func get_train_requirement(_exp_pos: int, level: int) -> int:
	return 25 + maxi(0, level) * 5


static func normalize_state(stored: Variant) -> Dictionary:
	var result := {"p1": {}, "p2": {}}
	if stored is Dictionary:
		var source: Dictionary = stored
		for profile in ["p1", "p2"]:
			if source.get(profile, {}) is Dictionary:
				result[profile] = (source[profile] as Dictionary).duplicate(true)
		var legacy_found := false
		for body_id in BODY_IDS:
			var key := str(body_id)
			if source.get(key, null) is Dictionary:
				result["p1"][key] = (source[key] as Dictionary).duplicate(true)
				legacy_found = true
		if not legacy_found and source.has("p1") == false and source.has("p2") == false:
			result["p1"] = source.duplicate(true)
	for profile in ["p1", "p2"]:
		var profile_data: Dictionary = result[profile]
		for body_id in BODY_IDS:
			var key := str(body_id)
			var entry: Dictionary = profile_data.get(key, {}) if profile_data.get(key, {}) is Dictionary else {}
			entry["level"] = clampi(int(entry.get("level", 0)), 0, int(get_config(body_id).get("levelMax", 25)))
			entry["val"] = get_level_value(body_id, int(entry["level"]))
			entry["type"] = str(get_config(body_id).get("attributeT", ""))
			profile_data[key] = entry
		result[profile] = profile_data
	return result


static func get_attribute_totals(state: Variant, profile := "p1") -> Dictionary:
	var totals := {"hpMax": 0, "mpMax": 0, "atk": 0, "phyDef": 0, "magicDef": 0}
	var normalized := normalize_state(state)
	var profile_data: Dictionary = normalized.get(profile, {})
	for body_id in BODY_IDS:
		var entry: Dictionary = profile_data.get(str(body_id), {})
		var attribute := str(get_config(body_id).get("attributeT", ""))
		if attribute == "def":
			var defense_value := get_level_value(body_id, int(entry.get("level", 0)))
			totals["phyDef"] += defense_value
			totals["magicDef"] += defense_value
		elif totals.has(attribute):
			totals[attribute] += get_level_value(body_id, int(entry.get("level", 0)))
	return totals

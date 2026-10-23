extends RefCounted
class_name NorthOriginalData

const ROOT := "res://Art/level/game_4_level/north_original/"
static var _monsters: Dictionary = {}
static var _skills: Dictionary = {}
static var _sky: Dictionary = {}
static var _buffs: Dictionary = {}


static func monster_record(id: int) -> Dictionary:
	if _monsters.is_empty():
		_monsters = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "monsters.json"))
	return _monsters.get(str(id), {})


static func skill(id: Variant) -> Dictionary:
	if _skills.is_empty():
		_skills = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "skills.json"))
	return _skills.get(str(id), {})


static func metadata(id: int) -> String:
	var record := monster_record(id)
	return "res://Art/monster/north_original/%d/metadata.tres" % int(record["model"]) if not record.is_empty() else ""


static func level_data(number: int, hidden: bool = false) -> Dictionary:
	return JSON.parse_string(
		FileAccess.get_file_as_string(ROOT + "level_%d%s.json" % [number, "_hidden" if hidden else ""])
	)


static func sky_path() -> Array:
	if _sky.is_empty():
		_sky = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "sky_paths.json"))
	return _sky["p1"]


static func buff_record(id: String) -> Dictionary:
	if _buffs.is_empty():
		_buffs = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "buffs.json"))
	return _buffs.get(id, {})


static func numbers(value: String) -> Array:
	var result: Array = []
	for part in value.replace(";", ",").split(",", false):
		result.append(float(part))
	return result


static func monster_config(id: int) -> Dictionary:
	var raw := monster_record(id)
	if raw.is_empty():
		return {}
	var resistance := float(raw["magRes"])
	return {
		"name": raw["name"],
		"level": int(raw["level"]),
		"hp": int(raw["hpMax"]),
		"attack": int(raw["atk"]),
		"def": int(raw["phyDef"]),
		"mdef": roundi(100.0 * resistance / maxf(1.0 - resistance, 0.01)),
		"crit": roundi(float(raw["critical"]) * 1000),
		"miss": roundi(float(raw["dodge"]) * 1000),
		"hit": roundi(float(raw["hit"]) * 1000),
		"toughness": float(raw["toughness"]),
		"armor_break": 0,
		"magic_break": 0,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"speed": float(raw["walkSpeed"]) / 5.0,
		"range": 0,
		"sight": 1200,
		"is_boss": raw["boss"] == "1",
		"is_flying": raw["type"] == "2",
		"max_protect": float(raw["protectPoint"]),
		"coin": 0,
		"exp": 0,
		"drop_rate": 0.0,
		"drop_list": []
	}


static func preview(number: int) -> Dictionary:
	var data := level_data(number)
	var entries: Array = []
	for text_id in str(data["dungeon"]["monsterID"]).split(";", false):
		var id := int(text_id)
		var record := monster_record(id)
		entries.append(
			{
				"Name": record["name"],
				"is_boss": record["boss"] == "1",
				"ScenePath": "res://Scene/monster/monster_%d.tscn" % id,
				"ConfigId": id
			}
		)
	return {
		"level_name": data["name"],
		"monster_list": entries,
		"fall_pro": 0,
		"LevelFall": [],
		"NeedZDL": {},
		"SelfBg": "hgs",
		"Level": 1
	}

extends RefCounted

## 截教天境万灵图录与魂晶数据。运行时只读，不承载玩家实例状态。

const CATEGORY := "截教天境"
const LEVEL_MONSTERS := {
	"res://Scene/level/level_31.tscn": [115, 140, 116, 117],
	"res://Scene/level/level_32.tscn": [119, 120, 1401],
	"res://Scene/level/level_33.tscn": [120, 122, 1402],
	"res://Scene/level/level_34.tscn": [118, 122, 1403],
	"res://Scene/level/level_35.tscn": [123, 1404],
	"res://Scene/level/level_36.tscn": [124, 1406, 1404],
	"res://Scene/level/level_37.tscn": [123, 124, 1407],
	"res://Scene/level/level_38.tscn": [118, 119, 120, 122, 1408],
	"res://Scene/level/level_39.tscn": [118, 119, 120, 122, 1410],
	"res://Scene/level/level_34_1.tscn": [1405],
	"res://Scene/level/level_38_1.tscn": [1409],
}
const IDS := [
	115, 116, 117, 118, 119, 120, 122, 123, 124, 140, 1401, 1402, 1403, 1404, 1405, 1406, 1407, 1408, 1409, 1410
]
const BOSS_IDS := [116, 117, 140, 1401, 1402, 1403, 1404, 1405, 1406, 1407, 1408, 1409, 1410]
const NAMES := {
	115: "火龙护卫",
	116: "五龙轮",
	117: "飞烟剑",
	118: "地狱练气师",
	119: "噩梦炼气师",
	120: "黑烟炼气师",
	122: "妖风炼气师",
	123: "凤翎",
	124: "雷钻怪",
	140: "焰中仙",
	1401: "花豹圣者·高友乾",
	1402: "狻猊圣者·杨森",
	1403: "狴犴圣者·王魔",
	1404: "碧霄",
	1405: "魔王吕岳",
	1406: "琼霄",
	1407: "琼霄娘娘",
	1408: "千年妖蚊",
	1409: "千年蜈蚣",
	1410: "千年妖蝉",
}
const EFFECTS := {
	115: {"SHp": 50.0},
	116: {"power": 100.0},
	117: {"Crit": 20.0},
	118: {"power": 5.0},
	119: {"Mdef": 2.0},
	120: {"Def": 2.0},
	122: {"ar": 4.0, "sp": 4.0},
	123: {"SHp": 100.0},
	124: {"R_hp": 0.2, "R_mp": 0.2},
	140: {"power": 100.0},
	1401: {"power": 100.0},
	1402: {"Crit": 20.0},
	1403: {"Def": 20.0},
	1404: {"SMp": 200.0},
	1405: {"damage_bonus": 0.002},
	1406: {"power": 100.0},
	1407: {"damage_reduction": 0.002},
	1408: {"Mdef": 20.0},
	1409: {"SHp": 1000.0},
	1410: {"damage_bonus": 0.002, "damage_reduction": 0.002},
}
const EFFECT_TEXT := {
	115: "每个+50生命",
	116: "每个+100攻击",
	117: "每个+20暴击",
	118: "每个+5攻击",
	119: "每个+2魔防",
	120: "每个+2物防",
	122: "每个+4破甲、破魔",
	123: "每个+100生命",
	124: "每个+0.2回血、回魔",
	140: "每个+100攻击",
	1401: "每个+100攻击",
	1402: "每个+20暴击",
	1403: "每个+20物防",
	1404: "每个+200魔法",
	1405: "每个+0.2%伤害",
	1406: "每个+100攻击",
	1407: "每个+0.2%免伤",
	1408: "每个+20魔防",
	1409: "每个+1000生命",
	1410: "每个+0.2%伤害、0.2%免伤",
}


static func crystal_icon(monster_id: int) -> String:
	var path := "res://Art/monster/soul_crystal/%d.png" % monster_id
	if ResourceLoader.exists(path):
		return path
	return "res://Art/monster/creature_codex/%d.png" % monster_id

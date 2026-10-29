class_name LevelProgressCommand
extends RefCounted

## 关卡进度唯一命令与数据表：按关卡号、当前关卡名或导入关卡段解析要写的键。
## add_tg 只调用本类，不再散落 48 个 match 分支；值类型与旧存档保持一致。

const IMPORTED_LEVEL_MIN: int = 63
const IMPORTED_LEVEL_MAX: int = 75
const NIGHTMARE_LEVEL: int = 20

const LEVEL_PROGRESS := {
	1: {"水帘洞": 1},
	2: {"桃花源": 1},
	3: {"蝙蝠窟": 1},
	4: {"七星洞": 1},
	5: {"迦楼罗之穴": 1},
	6: {"浅岸": 1},
	7: {"东海": 1},
	8: {"鲨之涡流": 1},
	9: {"牛魔谷": 1},
	10: {"地府": true},
	11: {"无常巷": 1},
	12: {"鬼门关": 1},
	13: {"接引院": 1},
	14: {"判官府": 1},
	15: {"阎罗殿": 1},
	16: {"忘川河": 1},
	17: {"奈何桥": 1},
	18: {"望乡台": 1},
	19: {"转轮殿": 1},
	20: {"天庭": true},
	21: {"天宫道": 1},
	22: {"南天门": 1},
	23: {"南天王殿": 1},
	24: {"西天王殿": 1},
	25: {"北天王殿": 1},
	26: {"彩虹楼": 1},
	27: {"朝会殿": 1},
	28: {"凌霄宝殿": 1},
	29: {"玲珑宝塔": 1},
	30: {"兜率宫": 1},
	31: {"兜率宫1": 1},
	32: {"兜率宫2": 1},
	33: {"兜率宫3": 1},
	34: {"兜率宫4": 1},
	35: {"截教天镜": true},
	36: {"火龙岛": 1},
	37: {"九龙岛": 1},
	38: {"龙脊山": 1},
	39: {"尾妖林": 1},
	40: {"仙音岛": 1},
	41: {"仙幻岛": 1},
	42: {"仙树岛": 1},
	43: {"蓬莱岛": 1},
	44: {"蓬莱仙境": 1},
	45: {"碧游宫": true},
	46: {"陷仙门": 1},
	47: {"绝境宫": 1},
	48: {"通天教主": 1},
}

const NIGHTMARE_PROGRESS := {"地府噩梦": true}

const REGION_PROGRESS_KEYS := [
	"绝仙门",
	"紫晶门",
	"戮仙门",
	"指景宫",
	"陷仙门",
	"绝境宫",
	"通天教主",
	"玄武门",
	"朱雀街",
	"未央宫",
	"九华山麓",
	"双溪寺",
	"神光金岭",
	"普陀山脚",
	"九龙宝殿",
	"法华灵洞",
	"峨眉山道",
	"清音阁",
	"金顶云海",
	"五台山口",
	"锦绣峰",
	"万佛朝阁",
	"冥海",
]


## 解析本次通关应写的键值；导入关卡优先，其次区域关卡名，最后按关卡号查表。
static func resolve_entries(level: int, current_level: String, is_imported: bool, nightmare: bool) -> Dictionary:
	if is_imported and level >= IMPORTED_LEVEL_MIN and level <= IMPORTED_LEVEL_MAX:
		var imported_entries := {"东胜神州通关_%d" % level: 1}
		if level == IMPORTED_LEVEL_MAX:
			imported_entries["云川"] = 1
		return imported_entries
	if current_level in REGION_PROGRESS_KEYS:
		return {current_level: 1}
	var entries_value: Variant = LEVEL_PROGRESS.get(level, {})
	var entries: Dictionary = (entries_value as Dictionary).duplicate() if entries_value is Dictionary else {}
	if level == NIGHTMARE_LEVEL and nightmare:
		entries.merge(NIGHTMARE_PROGRESS)
	return entries


## 只写档案字典，不保存；保存由关卡分支唯一提交。
static func apply(
	target: Dictionary, level: int, current_level: String, is_imported: bool, nightmare: bool
) -> Dictionary:
	var entries := resolve_entries(level, current_level, is_imported, nightmare)
	for key in entries.keys():
		target[key] = entries[key]
	return entries


## 北俱芦洲覆盖 add_tg：动态关卡完成键 + 原始房名。
static func apply_north_continent(target: Dictionary, stage_number: int, display_name: String) -> Dictionary:
	var entries := {"北俱芦洲通关_%d" % stage_number: 1, display_name: 1}
	for key in entries.keys():
		target[key] = entries[key]
	return entries

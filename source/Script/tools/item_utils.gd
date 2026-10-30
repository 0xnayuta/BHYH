class_name ItemUtils
extends RefCounted

## 无状态物品工具：品质前缀清理与随机物品条目生成。调用方直接用 `ItemUtils.xxx()`。

const QUALITY_PREFIXES := ["shishi", "youxiu", "jingliang", "putong", "xieling", "hunqi", "chuanshuo", "shenqi"]
const XIANYU_BODY_NAME_MAP := {
	"xyfjwk": "wkxysz",
	"xyfjts": "tsxysz",
	"xyfjbj": "bjxysz",
	"xyfjss": "ssxysz",
	"xyfjbl": "blxyfj",
}


## 去掉品质前缀并归一化仙羽身体名；无匹配时原样返回。
static func clean_fashion_name(item_name: String) -> String:
	if XIANYU_BODY_NAME_MAP.has(item_name):
		return str(XIANYU_BODY_NAME_MAP[item_name])
	for prefix in QUALITY_PREFIXES:
		if item_name.get_slice(prefix, 1) != item_name:
			return item_name.get_slice(prefix, 1)
	return item_name


## 从候选表随机抽取 rolls 次，每次累加 value_range；返回 [{Name, Value, Prop, WX, strength_value}]，未抽中的条目被剔除。
static func random_item_entries(item_ids, rolls: int, value_range: int) -> Array:
	randomize()
	var counts := {}
	for item_id in item_ids:
		counts[item_id] = {"Name": item_id, "Num": 0}
	for _i in range(rolls):
		var picked = item_ids[randi_range(0, item_ids.size() - 1)]
		counts[picked]["Num"] += value_range
	for item_id in counts.keys():
		if int(counts[item_id]["Num"]) == 0:
			counts.erase(item_id)
	var entries: Array = []
	for item_id in counts:
		(
			entries
			. push_back(
				{
					"Name": item_id,
					"Value": counts[item_id]["Num"],
					"Prop": {},
					"WX": [],
					"strength_value": 0,
				}
			)
		)
	return entries

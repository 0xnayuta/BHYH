class_name ItemUtils
extends RefCounted

## 无状态物品工具：品质前缀清理、随机物品条目生成与物品图标解析。
## 调用方直接用 `ItemUtils.xxx()`。

const ITEM_ICON_DIR := "res://Art/backpack/all_items/"
const FALLBACK_ICON_DIR := "res://Art/backpack/"
const BUFF_ICON_DIR := "res://Art/add_effect/buff_icon/"
const EMPTY_ICON_PATH := ITEM_ICON_DIR + "empty.png"

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


const FIVE_ELEMENTS := ["金", "木", "水", "火", "土"]


## 法宝五行组合：0 按权重抽 1~3 个，1~3 抽固定个数，4 抽四行（缺一），5 全五行，其它返回空。
static func random_element_set(mode: int) -> Array:
	match mode:
		0:
			var roll := randi_range(0, 100)
			if roll <= 4:
				return _pick_distinct(3, FIVE_ELEMENTS)
			if roll > 4 and roll < 10:
				return _pick_distinct(2, FIVE_ELEMENTS)
			return _pick_distinct(1, FIVE_ELEMENTS)
		1:
			return _pick_distinct(1, FIVE_ELEMENTS)
		2:
			return _pick_distinct(2, FIVE_ELEMENTS)
		3:
			return _pick_distinct(3, FIVE_ELEMENTS)
		4:
			var remaining: Array = FIVE_ELEMENTS.duplicate()
			remaining.remove_at(randi_range(0, remaining.size() - 1))
			return remaining
		5:
			return FIVE_ELEMENTS.duplicate()
		_:
			return []


## 不放回抽 count 个；候选不足时按剩余数量返回。
static func _pick_distinct(count: int, source: Array) -> Array:
	var result: Array = []
	var pool: Array = source.duplicate()
	for _i in range(count):
		if pool.is_empty():
			break
		var index := randi_range(0, pool.size() - 1)
		result.append(pool[index])
		pool.remove_at(index)
	return result


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


## 物品图标：`all_items/<id>.png`，缺失返回 null（不抛错、不占位）。
static func item_icon(item_id) -> Texture2D:
	var path := ITEM_ICON_DIR + str(item_id) + ".png"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


## 物品图标带旧目录兜底：先 `all_items/`，再 `Art/backpack/<id>.png`，都缺失返回 null。
static func item_icon_with_legacy_fallback(item_id) -> Texture2D:
	var primary := item_icon(item_id)
	if primary != null:
		return primary
	var fallback_path := FALLBACK_ICON_DIR + str(item_id) + ".png"
	if not ResourceLoader.exists(fallback_path):
		return null
	return load(fallback_path) as Texture2D


## 物品图标带空图标兜底：装备数据 `图标` 优先，其次 `all_items/<id>.png`，最后 `empty.png`。
static func item_icon_with_empty_fallback(item_id) -> Texture2D:
	var item_data: Dictionary = AE.all_equipment.get(str(item_id), {})
	var data_icon_path := str(item_data.get("图标", ""))
	if data_icon_path != "" and ResourceLoader.exists(data_icon_path):
		return load(data_icon_path) as Texture2D
	var icon := item_icon(item_id)
	if icon != null:
		return icon
	return load(EMPTY_ICON_PATH) as Texture2D


## 装备数据图标优先：`图标` 命中即返回，否则回落 `all_items/<id>.png`（无空图标兜底）。
static func equipment_icon_or_item_icon(item_id) -> Texture2D:
	var item_data: Dictionary = AE.all_equipment.get(str(item_id), {})
	var icon_path := str(item_data.get("图标", ""))
	if icon_path != "" and ResourceLoader.exists(icon_path):
		return load(icon_path) as Texture2D
	return load(ITEM_ICON_DIR + str(item_id) + ".png") as Texture2D


## buff 图标：统一走 `Global.get_cached_texture`，沿用其 `mp_poision -> poision` 别名与缓存。
static func buff_icon(buff_id) -> Texture2D:
	var resolved := str(buff_id)
	if resolved == "mp_poision":
		resolved = "poision"
	return Global.get_cached_texture(BUFF_ICON_DIR + resolved.to_lower() + ".png")

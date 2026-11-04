extends Node

## 6.9 玉兔掉落展开探针：验证 expand_drop_entries 的纯函数语义、4 条
## 6.6 制作书掉落与 LevelInfo 预览，不依赖随机掉落。
## 运行期掉落消费方在 base_monster.gd；本探针固定数据契约，避免 RNG 造成假阴性。

const RESULT_PREFIX := "YUTU_DROP_PROBE_RESULT="
const TEARDOWN_MARKER := "YUTU_DROP_PROBE_TEARDOWN"
const YUTU := preload("res://Script/data/yutu_equipment_data.gd")
const LEVEL_INFO := preload("res://Scene/other_scene/level_info.gd")
const BOOK_CASES := [
	{
		"level_name": "清音阁",
		"level_path": "res://Scene/level/level_57.tscn",
		"script_path": "res://Script/level/level_57.gd",
		"boss_id": 3041,
		"book_id": "zqfjytzzs",
	},
	{
		"level_name": "五台山口",
		"level_path": "res://Scene/level/level_59.tscn",
		"script_path": "res://Script/level/level_59.gd",
		"boss_id": 3069,
		"book_id": "zqwqytzzs",
	},
	{
		"level_name": "桃花谷",
		"level_path": "res://Scene/level/level_68.tscn",
		"script_path": "res://Script/level/level_68.gd",
		"boss_id": 3182,
		"book_id": "ygfjytzzs",
	},
	{
		"level_name": "万妖穴",
		"level_path": "res://Scene/level/level_71.tscn",
		"script_path": "res://Script/level/level_71.gd",
		"boss_id": 3277,
		"book_id": "ygwqytzzs",
	},
]

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	var source: Array = [
		{"name": "nzhjq", "value": 1, "chance": 0.25},
		{"name": "qhs_1", "value": 2, "chance": 1.0},
	]
	var before: Array = source.duplicate(true)
	var expanded: Array = YUTU.expand_drop_entries(source)
	checks["source_table_unchanged"] = source == before
	checks["regular_source_and_yutu_present"] = (
		_has_name(expanded, "nzhjq") and _has_name(expanded, "ytwqpt")
	)
	checks["source_entries_preserved"] = _has_name(expanded, "qhs_1")
	checks["expansion_idempotent"] = YUTU.expand_drop_entries(expanded).size() == expanded.size()

	for entry: Dictionary in YUTU.definitions():
		for suffix: String in ["", "zzs"] if bool(entry.get("book", false)) else [""]:
			var source_id := str(entry.get("source_base", entry.get("base", ""))) + suffix
			var target_id := str(entry.get("id", "")) + suffix
			if source_id == target_id:
				continue
			var mapped: Array = YUTU.expand_drop_entries(
				[{"name": source_id, "value": 1, "chance": 0.25}]
			)
			var ok := (
				mapped.size() == 2
				and str(mapped[0].get("name", "")) == source_id
				and str(mapped[1].get("name", "")) == target_id
				and is_equal_approx(float(mapped[1].get("chance", -1.0)), 0.25)
			)
			checks["mapping_%s" % target_id] = ok

	for case: Dictionary in BOOK_CASES:
		var book_id := str(case["book_id"])
		var script := load(str(case["script_path"])) as Script
		var level = script.new() if script != null else null
		var drops: Array = []
		if level != null:
			var config: Variant = level.call("get_level_monster_config", int(case["boss_id"]))
			if config is Dictionary:
				drops = (config as Dictionary).get("independent_drop_list", []).duplicate(true)
			level.free()
		var source_before: Array = drops.duplicate(true)
		var source_count := _count_name(drops, book_id)
		var expanded_drops: Array = YUTU.expand_drop_entries(drops)
		var prefix := str(case["level_name"])
		checks["%s_source_book_once" % prefix] = source_count == 1
		checks["%s_source_table_immutable" % prefix] = drops == source_before
		checks["%s_expanded_book_once" % prefix] = _count_name(expanded_drops, book_id) == 1
		checks["%s_expansion_preserves_source" % prefix] = _has_name(expanded_drops, book_id)

		var info = LEVEL_INFO.new()
		info.set("target_stage_path", str(case["level_path"]))
		info.set("level_name", prefix)
		var preview: Variant = info.call("_get_level_info")
		var preview_ok := false
		if preview is Dictionary:
			var level_fall: Variant = (preview as Dictionary).get("LevelFall", [])
			var probabilities: Variant = (preview as Dictionary).get("LevelFallProbability", {})
			preview_ok = (
				level_fall is Array
				and (level_fall as Array).has(book_id)
				and probabilities is Dictionary
				and int((probabilities as Dictionary).get(book_id, 0)) == 10
			)
		info.free()
		checks["%s_preview_book" % prefix] = preview_ok

	for key: String in checks:
		if not bool(checks[key]):
			_failures.append(key)
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _has_name(entries: Array, name: String) -> bool:
	return _count_name(entries, name) > 0


func _count_name(entries: Array, name: String) -> int:
	var count := 0
	for entry: Variant in entries:
		if entry is Dictionary and str((entry as Dictionary).get("name", "")) == name:
			count += 1
	return count

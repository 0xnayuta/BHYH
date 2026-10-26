extends Node

## 关卡选择态运行时探针（由 scripts/scene_probe_runner.py 复制到工程根目录并执行）。
## 验证“选择 ID 只在运行期确定”的关卡：八仙过海与挑战三太子。
## Catalog 对这两关只登记静态可解析条目，实际怪物由关卡脚本按 Global 选择值
## 自行预载；探针逐个选择项断言刷怪表与预载登记，防止边界回退成静默漏预载。

const RESULT_PREFIX := "LEVEL_SELECTION_PROBE_RESULT="
const TEARDOWN_MARKER := "LEVEL_SELECTION_PROBE_TEARDOWN"
const BXGH_SCENE := "res://Scene/level/level_bxgh.tscn"
const STZ_SCENE := "res://Scene/level/level_stz.tscn"
const BXGH_IDS: Array[int] = [163, 175, 165, 166, 168, 169, 174, 164]
const BXGH_FALLBACK_ID := 163
const PRINCE_IDS: Array[int] = [4401, 4402, 4403]
const PRINCE_FALLBACK_ID := 4401
const PRINCE_BACKGROUNDS: Dictionary[int, String] = {
	4401: "BackgroundNezha",
	4402: "BackgroundMuzha",
	4403: "BackgroundJinzha",
}
const LOAD_MAX_FRAMES := 900
const PREWARM_MAX_FRAMES := 900

var _failures: Array[String] = []
var _is_worker := false


func _ready() -> void:
	# 切关会释放主场景自身；复制常驻 worker 承担测试逻辑。
	if not _is_worker:
		var worker: Node = duplicate()
		worker.set("_is_worker", true)
		worker.name = "LevelSelectionProbeWorker"
		get_tree().root.add_child.call_deferred(worker)
		return
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	PlayerData.player_data["Myself"] = 1
	RoleProp.baseroleprop.Level = 1
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Hp = 999999999
	RoleProp.current_hp = 999999999
	Global.cd_path = ""
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, true)
	await _check_bxgh(checks)
	await _check_stz(checks)
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	# 结果输出后进入引擎退出阶段；退出期 RID 清理噪声不计入 0/0 门禁。
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_bxgh(checks: Dictionary) -> void:
	for boss_id: int in BXGH_IDS:
		Global.selected_eight_immortal_id = boss_id
		checks["bxgh_%d" % boss_id] = await _check_selection(BXGH_SCENE, boss_id)
	Global.selected_eight_immortal_id = 0
	checks["bxgh_invalid_fallback"] = await _check_selection(BXGH_SCENE, BXGH_FALLBACK_ID)


func _check_stz(checks: Dictionary) -> void:
	for prince_id: int in PRINCE_IDS:
		Global.selected_three_prince_id = prince_id
		checks["stz_%d" % prince_id] = await _check_selection(
			STZ_SCENE, prince_id, PRINCE_BACKGROUNDS[prince_id]
		)
	Global.selected_three_prince_id = 0
	checks["stz_invalid_fallback"] = await _check_selection(
		STZ_SCENE, PRINCE_FALLBACK_ID, PRINCE_BACKGROUNDS[PRINCE_FALLBACK_ID]
	)


func _check_selection(scene_path: String, expected_id: int, background_name: String = "") -> bool:
	var label := "%s/%d" % [scene_path.get_file(), expected_id]
	Global.change_scene(scene_path)
	var level: Node = await _await_level(scene_path)
	if level == null:
		_fail(label + ": 关卡加载超时")
		return false
	var ok := true
	var stage_one := _stage_one_ids(level)
	if stage_one != [expected_id]:
		_fail("%s: 刷怪表 stage_1=%s，期望 [%d]" % [label, str(stage_one), expected_id])
		ok = false
	if not await _await_monster_scene_cached(expected_id):
		_fail("%s: 关卡自身预载未缓存怪物场景 %d" % [label, expected_id])
		ok = false
	if background_name != "" and not _background_matches(level, background_name):
		_fail("%s: 背景可见性未切换到 %s" % [label, background_name])
		ok = false
	await _release_current_level()
	return ok


func _release_current_level() -> void:
	# 连续切关时先释放旧关卡，避免旧主角在新关卡预载期间继续物理帧。
	var current := get_tree().current_scene
	if current != null and is_instance_valid(current):
		get_tree().current_scene = null
		current.queue_free()
	await get_tree().process_frame


func _await_level(scene_path: String) -> Node:
	for _frame in range(LOAD_MAX_FRAMES):
		await get_tree().process_frame
		var current := get_tree().current_scene
		if current != null and current.scene_file_path == scene_path:
			return current
	return null


func _await_monster_scene_cached(expected_id: int) -> bool:
	var scene_path := "res://Scene/monster/monster_%d.tscn" % expected_id
	for _frame in range(PREWARM_MAX_FRAMES):
		if ResourceLoader.has_cached(scene_path):
			return true
		await get_tree().process_frame
	return false


func _stage_one_ids(level: Node) -> Array:
	var group_value: Variant = level.get("monster_group")
	if not group_value is Dictionary:
		return []
	var stage_value: Variant = (group_value as Dictionary).get("stage_1", [])
	return Array(stage_value) if stage_value is Array else []


func _background_matches(level: Node, expected_name: String) -> bool:
	var background_root := level.get_node_or_null("BackGround/front")
	if background_root == null:
		return false
	for child in background_root.get_children():
		if child.name == expected_name:
			if not (child as CanvasItem).visible:
				return false
		elif child.name in ["BackgroundNezha", "BackgroundMuzha", "BackgroundJinzha"]:
			if (child as CanvasItem).visible:
				return false
	return true


func _fail(message: String) -> void:
	_failures.append(message)

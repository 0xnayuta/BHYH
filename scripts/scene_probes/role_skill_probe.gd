extends Node

## 角色 2 / 4 技能入口探针（由 scripts/scene_probe_runner.py 复制到工程根目录执行）。
## 验证：技能入口调用、BingYu/CangMu 效果实例化、5 个角色特效 Spine 预加载。

const RESULT_PREFIX := "ROLE_SKILL_PROBE_RESULT="
const TEARDOWN_MARKER := "ROLE_SKILL_PROBE_TEARDOWN"
const ROLE2_SCENE := "res://Scene/hero/role_2/role_2.tscn"
const ROLE4_SCENE := "res://Scene/hero/role_4/role_4.tscn"

var _failures: Array[String] = []
var _checks: Dictionary = {}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var level := Node2D.new()
	level.name = "RoleSkillProbeLevel"
	add_child(level)
	var role2 := (load(ROLE2_SCENE) as PackedScene).instantiate()
	var role4 := (load(ROLE4_SCENE) as PackedScene).instantiate()
	level.add_child(role2)
	level.add_child(role4)
	await get_tree().process_frame
	await get_tree().process_frame

	PlayerData.player_data["Myself"] = 2
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Mp = 999999
	RoleProp.current_hp = 999999
	for hero in [role2, role4]:
		var cooldowns: Dictionary = hero.get("role1_skill_inter")
		cooldowns["by"] = 0
		cooldowns["cmly"] = 0
		hero.set("player_dir", true)

	role2.call("get_skill", "by")
	role4.call("get_skill", "cmly")
	await get_tree().process_frame
	await get_tree().process_frame

	_checks["bingyu_effect_spawned"] = _count_effect("BingYuEffect") > 0
	_checks["cangmu_effect_spawned"] = _count_effect("CangMuLongYunEffect") > 0
	_checks["bingyu_preload"] = bool(
		load("res://Script/hero/bing_yu_effect.gd").call("preload_effect_data")
	)
	_checks["cangmu_preload"] = bool(
		load("res://Script/hero/cang_mu_long_yun_effect.gd").call("preload_effect_data")
	)
	_checks["lyfb_preload"] = bool(
		load("res://Script/hero/lyfb_awaken_effect.gd").call("preload_effect_data")
	)
	_checks["hmz_preload"] = bool(
		load("res://Script/hero/hmz_awaken_effect.gd").call("preload_effect_data")
	)
	_checks["jhsj_preload"] = bool(
		load("res://Script/hero/jhsj_awaken_effect.gd").call("preload_effect_data")
	)
	for key in _checks:
		if not bool(_checks[key]):
			_failures.append(str(key))

	print(RESULT_PREFIX + JSON.stringify({"ok": _failures.is_empty(), "failures": _failures, "checks": _checks}))
	print(TEARDOWN_MARKER)

	for child in get_children():
		child.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit(0 if _failures.is_empty() else 1)


func _count_effect(class_name_value: String) -> int:
	return _count_script_class(self, class_name_value)


func _count_script_class(node: Node, class_name_value: String) -> int:
	var count := 0
	for child in node.get_children():
		var script: Script = child.get_script() as Script
		if script != null and script.get_global_name() == class_name_value:
			count += 1
		count += _count_script_class(child, class_name_value)
	return count

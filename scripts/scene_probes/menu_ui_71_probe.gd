extends Node

## 7.1 菜单/UI 与剩余脚本规格探针：技能透明度、公告、自动战斗、觉醒浮层与玉兔冲刺无敌。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "MENU_UI_71_PROBE_RESULT="
const TEARDOWN_MARKER := "MENU_UI_71_PROBE_TEARDOWN"

var _checks: Dictionary = {}
var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var saved_data: Dictionary = PlayerData.player_data.duplicate(true)
	var saved_settings: Dictionary = MainSet.set_data.duplicate(true)
	var saved_cd_path: String = Global.get_cd_path()
	Global.set_cd_path("")
	MainSet.set_auto_battle_enabled(false)
	PlayerData.player_data = PlayerData.initialized_data.duplicate(true)
	PlayerData.player_data["Myself"] = 7
	PlayerData.ensure_skill_data()
	RoleProp.set_physics_process(false)

	await _check_game_set()
	await _check_announcement()
	await _check_zd_skill()
	_check_auto_battle()
	await _check_awaken_popup()
	await _check_yutu_dash()

	RoleProp.source_player = null
	PlayerData.player_data = saved_data
	MainSet.set_data = saved_settings
	Global.set_cd_path(saved_cd_path)
	_report()


func _check_game_set() -> void:
	var scene := (load("res://Scene/main_menu/game_set.tscn") as PackedScene).instantiate()
	add_child(scene)
	await get_tree().process_frame
	var slider := scene.get_node_or_null("Bg/BGColor/VBoxContainer/SkillOpacity/Slider") as HSlider
	var value_label := scene.get_node_or_null("Bg/BGColor/VBoxContainer/SkillOpacity/Value") as Label
	_checks["game_set_slider"] = slider != null
	_checks["game_set_value_label"] = value_label != null
	if slider != null and value_label != null:
		scene.call("_on_skill_opacity_changed", 35.0)
		_checks["game_set_opacity"] = is_equal_approx(MainSet.get_skill_effect_opacity(), 0.35)
		_checks["game_set_label"] = value_label.text == "35%"
	scene.queue_free()
	await get_tree().process_frame


func _check_announcement() -> void:
	var scene := (load("res://Scene/main_menu/game_announcement.tscn") as PackedScene).instantiate()
	add_child(scene)
	await get_tree().process_frame
	var button := scene.get_node_or_null("BG/PanelContainer/HBoxContainer/BBBg/ScrollContainer/bblist/V0_52") as Button
	_checks["announcement_button"] = button != null and button.text == "V7.1"
	if button != null:
		button.pressed.emit()
		_checks["announcement_version"] = str(scene.get("verisions_name")) == "V7_1"
		_checks["announcement_text"] = str(scene.get("verisions")) == "V7.1"
		var data: Dictionary = scene.get("text_data")
		_checks["announcement_data"] = data.has("V7_1") and data["V7_1"].size() >= 19
	scene.queue_free()
	await get_tree().process_frame


func _check_zd_skill() -> void:
	PlayerData.player_data["Myself"] = 8
	var scene := (load("res://Scene/skill/zd_skill.tscn") as PackedScene).instantiate()
	add_child(scene)
	await get_tree().process_frame
	_checks["zd_role8_awaken_buttons"] = _count_named(scene, "AwakenButton") > 0
	scene.queue_free()
	await get_tree().process_frame
	PlayerData.player_data["Myself"] = 7


func _count_named(root: Node, target: String) -> int:
	var count := 1 if str(root.name) == target else 0
	for child in root.get_children():
		count += _count_named(child, target)
	return count


func _check_auto_battle() -> void:
	var script := load("res://Script/runtime/auto_battle_config.gd") as Script
	var auto: Node = script.new() as Node
	_checks["auto_battle_role8"] = str(auto.call("_skill_name", "xln_lz")) == "飞旋龙"
	var constants: Dictionary = auto.get_script().get_script_constant_map()
	var role_skills: Dictionary = constants.get("ROLE_SKILLS", {})
	_checks["auto_battle_role8_count"] = (role_skills.get("角色8", []) as Array).size() == 20
	auto.free()


func _check_awaken_popup() -> void:
	var scene := (load("res://Scene/skill/skill_awaken_popup.tscn") as PackedScene).instantiate()
	add_child(scene)
	await get_tree().process_frame
	scene.call("configure", "飞旋龙", null, "xln_lz")
	var xln_text := str(scene.get_node("EffectDescription").text)
	_checks["awaken_xln"] = "2倍" in xln_text
	scene.call("configure", "阴阳双生", null, "yyb")
	var yyb_text := str(scene.get_node("EffectDescription").text)
	_checks["awaken_yyb"] = "5倍" in yyb_text
	scene.call("configure", "玲珑漫天", null, "xln_llmt")
	_checks["awaken_llmt"] = "伤害段数翻倍" in str(scene.get_node("EffectDescription").text)
	scene.queue_free()
	await get_tree().process_frame


func _check_yutu_dash() -> void:
	var host := Node2D.new()
	host.name = "MenuUi71ProbeHost"
	add_child(host)
	var hero: Node = Global.call_hero("role_7", host, Vector2(620, 450), false) as Node
	hero.set_physics_process(false)
	await get_tree().process_frame
	hero.set("_active_id", "1112020")
	hero.set("_motion_until", float(hero.get("_clock")) + 1.0)
	_checks["yutu_dash_state"] = bool(hero.call("is_dashing"))
	var hp_before := float(RoleProp.roleprop.Hp)
	hero.call("effect_reducehp", 100, "physics")
	_checks["yutu_dash_invincible"] = is_equal_approx(float(RoleProp.roleprop.Hp), hp_before)
	_checks["yutu_dash_last_hurt"] = int(hero.call("get_monster_last_hurt", null, null)) == 0
	hero.set("_motion_until", 0.0)
	_checks["yutu_dash_end"] = not bool(hero.call("is_dashing"))
	hero.queue_free()
	host.queue_free()


func _report() -> void:
	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

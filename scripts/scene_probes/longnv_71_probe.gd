extends Node

## 小龙女 7.1 技能规格探针：数据表、觉醒状态、冲刺窗口、分刃与技能透明度。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "LONGNV_71_PROBE_RESULT="
const TEARDOWN_MARKER := "LONGNV_71_PROBE_TEARDOWN"

var _checks: Dictionary = {}
var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var saved_data: Dictionary = PlayerData.player_data.duplicate(true)
	var saved_settings: Dictionary = MainSet.set_data.duplicate(true)
	var host := Node2D.new()
	host.name = "Longnv71ProbeHost"
	add_child(host)

	PlayerData.player_data["Myself"] = 8
	PlayerData.ensure_skill_data()
	for index in range(1, 21):
		var skill: Dictionary = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能" + str(index)]
		skill[DataKeys.LEVEL] = 1
		skill["学习"] = 1
	_set_awakened("xln_jyc", true)
	_set_awakened("xln_tk", true)
	_set_awakened("xln_lz", true)
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Mp = 999999
	RoleProp.roleprop.SMp = 999999
	RoleProp.roleprop.Hp = 100000
	RoleProp.roleprop.SHp = 100000

	var hero = Global.call_hero("role_8", host, Vector2.ZERO, false)
	await get_tree().process_frame
	await get_tree().process_frame
	_checks["hero_spawned"] = hero is LongnvHero
	if not is_instance_valid(hero):
		_report()
		return

	_checks["data_jyc_duration"] = is_equal_approx(float(LongnvSkillData.DURATIONS[13]), 1.05)
	_checks["data_jyc_hit_times"] = LongnvSkillData.HIT_TIMES[13] == [0.18, 0.48, 0.78]
	_checks["data_jyc_effect"] = str(LongnvSkillData.EFFECTS[14]) == "ring_effect6"
	_checks["data_dash_duration"] = is_equal_approx(float(LongnvSkillData.DURATIONS[6]), 1.2)
	_checks["data_dash_hit_times"] = LongnvSkillData.HIT_TIMES[6] == [0.12, 0.48]
	_checks["data_lz_duration"] = is_equal_approx(float(LongnvSkillData.DURATIONS[14]), 0.78)
	_checks["data_lz_hit_times"] = LongnvSkillData.HIT_TIMES[14] == [0.18]
	_checks["data_ring_action"] = str(LongnvSkillData.ACTIONS[14]) == "effect5_1"

	_checks["awakened_enabled"] = bool(hero.call("is_skill_awakened", "xln_jyc"))
	_set_awakened_enabled("xln_jyc", false)
	_checks["awakened_disabled"] = not bool(hero.call("is_skill_awakened", "xln_jyc"))
	_set_awakened_enabled("xln_jyc", true)

	hero.call("_finish_action")
	hero.role1_skill_inter["xln_jyc"] = 0.0
	var hp_before: float = float(RoleProp.roleprop.Hp)
	hero.call("_begin_action", LongnvSkillData.ACTIONS[6], 100.0, 6)
	hero.set("_elapsed", 0.2)
	hero.extra_skills.start(6, 1)
	_checks["dash_window"] = bool(hero.extra_skills.is_dashing())
	hero.call("effect_reducehp", 500, "physics")
	_checks["dash_invincible"] = is_equal_approx(float(RoleProp.roleprop.Hp), hp_before)
	hero.call("_finish_action")
	_checks["dash_window_closed"] = not bool(hero.extra_skills.is_dashing())

	hero.call("_finish_action")
	hero.role1_skill_inter["xln_jyc"] = 0.0
	var hero_props: BaseRoleProperties = hero.call("_props")
	hero_props.roleprop.Mp = 999999
	hero_props.roleprop.SMp = 999999
	hero.call("get_skill", "xln_jyc")
	_checks["jyc_cooldown"] = is_equal_approx(float(hero.role1_skill_inter["xln_jyc"]), 0.5)
	hero.call("_finish_action")
	hero.role1_skill_inter["xln_jyc"] = 0.0

	hero.call("_finish_action")
	hero.set("_cast_damage", 100.0)
	hero.call("_launch_blade")
	_checks["split_blades"] = hero._extra_blades.size() == 2
	hero.call("_finish_action")

	hero.extra_skills.fury_left = 0.0
	hero.extra_skills.soul_left = 0.0
	hero.extra_skills.stealth_bonus_left = 0.0
	hero.set("_skill_index", 0)
	_checks["awakened_spin_multiplier"] = is_equal_approx(float(hero.extra_skills.damage_multiplier()), 2.0)

	var screen_layer: CanvasLayer = hero.get("_screen_layer")
	hero.call("_notification", Node.NOTIFICATION_PAUSED)
	_checks["pause_hides_screen_layer"] = not screen_layer.visible
	hero.call("_notification", Node.NOTIFICATION_UNPAUSED)
	_checks["unpause_shows_screen_layer"] = screen_layer.visible

	var opacity_controller: Node = null
	for child in MainSet.get_children():
		var script := child.get_script() as Script
		if script != null and script.resource_path.ends_with("role_skill_opacity.gd"):
			opacity_controller = child
			break
	_checks["opacity_controller"] = opacity_controller != null
	if opacity_controller != null:
		MainSet.set_skill_effect_opacity(50.0)
		var visual := Control.new()
		visual.name = "SpecialEffectProbe"
		host.add_child(visual)
		await get_tree().process_frame
		opacity_controller.call("_apply_opacity")
		_checks["opacity_visual"] = is_equal_approx(visual.self_modulate.a, 0.5)
		opacity_controller.call("_restore_native_opacity")
		_checks["opacity_restored"] = is_equal_approx(visual.self_modulate.a, 1.0)
		visual.queue_free()
	MainSet.set_skill_effect_opacity(100.0)

	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)

	hero.queue_free()
	host.queue_free()
	PlayerData.player_data = saved_data
	MainSet.set_data = saved_settings
	get_tree().quit(0 if _failures.is_empty() else 1)


func _set_awakened(skill_id: String, value: bool) -> void:
	if not PlayerData.player_data.has(DataKeys.Skill.AWAKENED):
		PlayerData.player_data[DataKeys.Skill.AWAKENED] = {}
	if not PlayerData.player_data.has(DataKeys.Skill.AWAKENED_ENABLED):
		PlayerData.player_data[DataKeys.Skill.AWAKENED_ENABLED] = {}
	PlayerData.player_data[DataKeys.Skill.AWAKENED][skill_id] = value
	PlayerData.player_data[DataKeys.Skill.AWAKENED_ENABLED][skill_id] = true


func _set_awakened_enabled(skill_id: String, value: bool) -> void:
	PlayerData.player_data[DataKeys.Skill.AWAKENED_ENABLED][skill_id] = value


func _report() -> void:
	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": false, "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(1)

extends Node

## 7.2 首批觉醒运行时探针。
## 覆盖：重斩三道地裂、玄冰阵五段冰刺与冰域、哪吒双火轮、月魔舞三月影，
## 以及觉醒弹窗、技能面板按钮与一阶觉醒石材料。
## 探针只在 scripts/ 中维护，由 scene_probe_runner 复制到工程根目录执行。

const RESULT_PREFIX := "AWAKEN_72_PROBE_RESULT="
const TEARDOWN_MARKER := "AWAKEN_72_PROBE_TEARDOWN"
const ROLE1_SCENE := preload("res://Scene/hero/role_1/role1.tscn")
const ROLE2_SCENE := preload("res://Scene/hero/role_2/role_2.tscn")
const ROLE6_SCENE := preload("res://Scene/hero/role_6/role_6.tscn")
const ROLE7_SCENE := preload("res://Scene/hero/role_7/role_7.tscn")
const POPUP_SCENE := preload("res://Scene/skill/skill_awaken_popup.tscn")
const ZD_SKILL_SCENE := preload("res://Scene/skill/zd_skill.tscn")
const AWAKEN_AREA := preload("res://Script/hero/first_batch_awaken_area.gd")
const NEZHA_AWAKEN_WHEEL := preload("res://Script/hero/ne_zha_awaken_wheel.gd")
const EQUIPMENT_CATALOG := preload("res://Script/data/equipment_catalog.tres")

var _failures: Array[String] = []
var _saved_awaken: Variant = null
var _saved_enabled: Variant = null
var _saved_myself: Variant = null
var _role1_waves: Array[Dictionary] = []
var _role2_spikes: Array[Dictionary] = []
var _role2_fields: Array[Dictionary] = []
var _yutu_effects: Array[Dictionary] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	_save_player_data()
	var level := Node2D.new()
	level.name = "Awaken72ProbeLevel"
	add_child(level)

	await _check_equipment(checks)
	await _check_popup(checks)
	await _check_role1(level, checks)
	await _check_role2(level, checks)
	await _check_nezha(level, checks)
	await _check_yutu(level, checks)
	await _check_zd_skill(checks)

	_restore_player_data()
	checks["teardown"] = true
	for check_name in checks:
		if not checks[check_name]:
			_failures.append(str(check_name))
	print(
		(
			RESULT_PREFIX
			+ JSON.stringify({"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks})
		)
	)
	print(TEARDOWN_MARKER)
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit(0 if _failures.is_empty() else 1)


func _save_player_data() -> void:
	_saved_awaken = PlayerData.player_data.get(DataKeys.Skill.AWAKENED)
	_saved_enabled = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED)
	_saved_myself = PlayerData.player_data.get("Myself")
	PlayerData.player_data[DataKeys.Skill.AWAKENED] = {}
	PlayerData.player_data[DataKeys.Skill.AWAKENED_ENABLED] = {}
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Mp = 999999
	RoleProp.roleprop.Hp = 999999
	RoleProp.current_hp = 999999


func _restore_player_data() -> void:
	if _saved_awaken == null:
		PlayerData.player_data.erase(DataKeys.Skill.AWAKENED)
	else:
		PlayerData.player_data[DataKeys.Skill.AWAKENED] = _saved_awaken
	if _saved_enabled == null:
		PlayerData.player_data.erase(DataKeys.Skill.AWAKENED_ENABLED)
	else:
		PlayerData.player_data[DataKeys.Skill.AWAKENED_ENABLED] = _saved_enabled
	if _saved_myself != null:
		PlayerData.player_data["Myself"] = _saved_myself


func _unlock(skill_id: String) -> void:
	var awaken: Dictionary = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	awaken[skill_id] = true
	PlayerData.player_data[DataKeys.Skill.AWAKENED] = awaken
	var enabled: Dictionary = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	enabled[skill_id] = true
	PlayerData.player_data[DataKeys.Skill.AWAKENED_ENABLED] = enabled


func _check_equipment(checks: Dictionary) -> void:
	var store := EQUIPMENT_CATALOG.create_store()
	checks["equipment_tjs_exists"] = store.has(&"tjs")
	if store.has(&"tjs"):
		var tjs := store.definition(&"tjs")
		checks["equipment_tjs_name"] = tjs.display_name == "一阶觉醒石"
		checks["equipment_tjs_origin"] = tjs.origin == "技能觉醒材料"
		checks["equipment_tjs_category"] = tjs.category == "道具"
		checks["equipment_tjs_cost_text"] = "15" in tjs.description
	checks["equipment_ptjs_exists"] = store.has(&"ptjs")
	await get_tree().process_frame


func _check_popup(checks: Dictionary) -> void:
	var popup := POPUP_SCENE.instantiate()
	add_child(popup)
	await get_tree().process_frame
	var icon := PlaceholderTexture2D.new()
	var expected := {"zz": "重斩", "xbz": "玄冰阵", "nz_hlqg": "火轮切割", "yt_ymw": "月魔舞"}
	for skill_id: String in expected:
		popup.configure(str(expected[skill_id]), icon, skill_id)
		checks["popup_supported_" + skill_id] = popup._is_supported_awaken_skill(skill_id)
		checks["popup_name_" + skill_id] = popup.skill_name_label.text == str(expected[skill_id])
		checks["popup_desc_" + skill_id] = not popup.get_node("EffectDescription").text.is_empty()
		checks["popup_visible_" + skill_id] = popup.get_node("ConfirmButton").visible
	checks["popup_rejects_unknown"] = not popup._is_supported_awaken_skill("__unknown__")
	popup.queue_free()
	await get_tree().process_frame


func _spawn_role(level: Node2D, scene: PackedScene, role_id: int) -> Node:
	PlayerData.player_data["Myself"] = role_id
	var hero := scene.instantiate()
	level.add_child(hero)
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Mp = 999999
	RoleProp.roleprop.Hp = 999999
	RoleProp.current_hp = 999999
	hero.set("is_death", false)
	await get_tree().process_frame
	await get_tree().process_frame
	hero.set("is_death", false)
	hero.set_physics_process(false)
	return hero


func _check_role1(level: Node2D, checks: Dictionary) -> void:
	_unlock("zz")
	var hero := await _spawn_role(level, ROLE1_SCENE, 1)
	hero.hit_dic = {"power": 100.0, "hurtBack": [1, 0], "attackKind": "physics", "WSValue": 4}
	checks["role1_zz_action_ready"] = hero._prepare_zz_awaken_action()
	checks["role1_zz_action_registered"] = hero.role_action_player.has_animation("zz_awaken")
	hero.get_action = "zz"
	hero.is_using_skills = true
	checks["role1_zz_super_armor"] = hero._skill_super_armor_active()
	hero.is_using_skills = false
	checks["role1_inside_tree"] = hero.is_inside_tree()
	checks["role1_bullet_inside"] = hero.bullet.is_inside_tree()
	checks["role1_hit_dic_power"] = float(hero.hit_dic.get("power", 0.0)) == 100.0

	_role1_waves.clear()
	hero._spawn_zz_awaken_waves()
	await _poll_capture(hero, "role1", 0.6)
	var powers: Array[float] = []
	var scales: Array[float] = []
	for wave in _role1_waves:
		powers.append(float(wave.get("power", 0.0)))
		scales.append(float(wave.get("scale", 0.0)))
	checks["role1_zz_wave_count"] = _role1_waves.size() == 3
	checks["role1_zz_wave_powers"] = powers == [200.0, 400.0, 800.0]
	checks["role1_zz_wave_scales"] = (
		scales.size() == 3
		and is_equal_approx(scales[0], 1.0)
		and is_equal_approx(scales[1], 1.3)
		and is_equal_approx(scales[2], 1.6)
	)
	checks["role1_zz_wave_scales_actual"] = scales
	checks["role1_zz_wave_script"] = (_role1_waves.size() == 3 and _role1_waves[0].get("script") == AWAKEN_AREA)
	hero.queue_free()
	await get_tree().process_frame


func _check_role2(level: Node2D, checks: Dictionary) -> void:
	_unlock("xbz")
	var hero := await _spawn_role(level, ROLE2_SCENE, 2)
	hero.obj_attack_dict["xbz"] = {"power": 100.0, "hurtBack": [1, 0], "attackKind": "magic", "WSValue": 4}
	checks["role2_inside_tree"] = hero.is_inside_tree()
	checks["role2_bullet_inside"] = hero.bullet.is_inside_tree()
	checks["role2_xbz_hit_power"] = float(hero.obj_attack_dict.get("xbz", {}).get("power", 0.0)) == 100.0

	_role2_spikes.clear()
	_role2_fields.clear()
	hero.add_xbz()
	await _poll_capture(hero, "role2", 1.0)
	checks["role2_xbz_spike_count"] = _role2_spikes.size() == 5
	var child_names: Array[String] = []
	for child in hero.bullet.get_children():
		child_names.append(str(child.name))
	checks["role2_children_after"] = child_names
	checks["role2_xbz_spike_power"] = (
		_role2_spikes.size() == 5 and _role2_spikes.all(func(entry: Dictionary) -> bool: return entry.power == 200.0)
	)
	checks["role2_xbz_spike_freeze_last"] = (
		_role2_spikes.size() == 5 and _role2_spikes[0].freeze == 0.0 and _role2_spikes[4].freeze == 2.0
	)
	checks["role2_xbz_spike_script"] = (_role2_spikes.size() == 5 and _role2_spikes[0].script == AWAKEN_AREA)
	checks["role2_xbz_field_count"] = _role2_fields.size() == 5
	var field_config_ok := _role2_fields.size() == 5
	if field_config_ok:
		for entry in _role2_fields:
			if not (
				entry.life == 3.0
				and entry.interval == 0.5
				and entry.pulses == 6
				and entry.power == 100.0
				and entry.freeze == 0.0
			):
				field_config_ok = false
				break
	checks["role2_xbz_field_config"] = field_config_ok
	var field_anchor_ok := _role2_fields.size() == 5
	if field_anchor_ok:
		for entry in _role2_fields:
			if float(entry.spike_bottom) <= 0.0:
				field_anchor_ok = false
				break
	checks["role2_xbz_field_anchor"] = field_anchor_ok
	hero.queue_free()
	await get_tree().process_frame


func _check_nezha(level: Node2D, checks: Dictionary) -> void:
	_unlock("nz_hlqg")
	var hero := await _spawn_role(level, ROLE6_SCENE, 6)
	var base_power := float(hero.obj_attack_dict["nz_hlqg"].get("power", 0.0))
	hero._use_fire_wheel()
	await get_tree().create_timer(0.5, false).timeout
	var wheels: Array = hero._awaken_wheels
	checks["nezha_wheel_count"] = wheels.size() == 2
	checks["nezha_wheel_script"] = (
		wheels.size() == 2 and wheels.all(func(wheel: Node) -> bool: return wheel.get_script() == NEZHA_AWAKEN_WHEEL)
	)
	checks["nezha_wheel_config"] = wheels.size() == 2
	if wheels.size() == 2:
		for wheel in wheels:
			if not (
				is_equal_approx(float(wheel.life_seconds), 8.0)
				and is_equal_approx(float(wheel.hit_interval), 1.0)
				and int(wheel.max_hit_pulses) == 8
				and is_equal_approx(float(wheel.hit_dic.get("power", 0.0)), base_power * 2.0)
				and wheel.use_visual_collision == true
			):
				checks["nezha_wheel_config"] = false
				break
	checks["nezha_wheel_angles"] = (
		wheels.size() == 2 and is_equal_approx(absf(float(wheels[1].orbit_angle) - float(wheels[0].orbit_angle)), PI)
	)
	checks["nezha_wheel_orbits_player"] = (
		wheels.size() == 2 and wheels.all(func(wheel: Node) -> bool: return wheel.orbit_target == hero)
	)
	hero.queue_free()
	await get_tree().process_frame


func _check_yutu(level: Node2D, checks: Dictionary) -> void:
	_unlock("yt_ymw")
	var hero := await _spawn_role(level, ROLE7_SCENE, 7)
	checks["yutu_dance_awake_active"] = hero.is_dance_awaken_active()
	hero._begin_dance_shadows()
	await get_tree().process_frame
	checks["yutu_shadow_count"] = hero._dance_shadows.size() == 2
	checks["yutu_shadow_offsets"] = (
		hero._dance_shadows.size() == 2
		and is_equal_approx(float(hero._dance_shadows[1].position.x - hero._dance_shadows[0].position.x), 360.0)
	)
	checks["yutu_shadow_alpha"] = (
		hero._dance_shadows.size() == 2 and is_equal_approx(float(hero._dance_shadows[0].modulate.a), 0.65)
	)

	var params: Variant = JSON.parse_string(str(YutuSkillData.row("1112050").get("param", "[]")))
	var event: Dictionary = {}
	if params is Array:
		for entry in params:
			if entry is Dictionary and entry.get("type") == "bulletFollwSelf":
				event = entry
				break
	_yutu_effects.clear()
	hero._spawn_event(event, "1112050", 1, hero.global_position, {})
	await _poll_capture(hero, "yutu", 0.15)
	checks["yutu_dance_effect_count"] = _yutu_effects.size() == 3
	var sides: Array[int] = []
	for entry in _yutu_effects:
		sides.append(int(entry.get("side", 99)))
	sides.sort()
	checks["yutu_dance_sides"] = sides == [-1, 0, 1]
	checks["yutu_dance_flags"] = (
		_yutu_effects.size() == 3
		and _yutu_effects.all(func(entry: Dictionary) -> bool: return entry.awakened == true)
		and _yutu_effects.filter(func(entry: Dictionary) -> bool: return entry.shadow == true).size() == 2
	)
	var main_power := 0.0
	var shadow_power := 0.0
	for entry in _yutu_effects:
		if int(entry.get("side", 0)) == 0:
			main_power = float(entry.get("power", 0.0))
		elif float(entry.get("power", 0.0)) > 0.0:
			shadow_power = float(entry.get("power", 0.0))
	checks["yutu_dance_power_ratio"] = (
		main_power > 0.0 and shadow_power > 0.0 and is_equal_approx(shadow_power / main_power, 0.7)
	)
	hero._finish_action()
	await get_tree().process_frame
	checks["yutu_shadow_cleanup"] = hero._dance_shadows.is_empty()
	hero.queue_free()
	await get_tree().process_frame


func _check_zd_skill(checks: Dictionary) -> void:
	PlayerData.player_data["Myself"] = 7
	var panel := ZD_SKILL_SCENE.instantiate()
	add_child(panel)
	await get_tree().process_frame
	panel._setup_skill_awaken_buttons()
	await get_tree().process_frame
	var moon_dance_button := panel.get_node_or_null("ScrollContainer/HBoxContainer/sk_pi/ski_10/AwakenButton")
	var non_awaken_button := panel.get_node_or_null("ScrollContainer/HBoxContainer/sk_pi/ski_9/AwakenButton")
	checks["zd_skill_moon_dance_button"] = moon_dance_button != null
	checks["zd_skill_non_awaken_skipped"] = non_awaken_button == null
	panel.queue_free()
	await get_tree().process_frame


func _poll_capture(hero: Node, phase: String, duration: float) -> void:
	var seen: Dictionary = {}
	var elapsed := 0.0
	while elapsed < duration:
		for child in hero.bullet.get_children():
			var instance_id := int(child.get_instance_id())
			if seen.has(instance_id):
				continue
			seen[instance_id] = true
			if phase == "role1" and child.get_script() == AWAKEN_AREA:
				(
					_role1_waves
					. append(
						{
							"power": float(child.get("hit_dic").get("power", 0.0)),
							"scale": child.scale.x,
							"script": child.get_script(),
						}
					)
				)
			elif phase == "role2" and child.get_script() == AWAKEN_AREA:
				if is_equal_approx(float(child.get("hit_interval")), 0.5):
					(
						_role2_fields
						. append(
							{
								"life": float(child.get("life_seconds")),
								"interval": float(child.get("hit_interval")),
								"pulses": int(child.get("max_hit_pulses")),
								"power": float(child.get("hit_dic").get("power", 0.0)),
								"freeze": float(child.get("freeze_seconds")),
								"spike_bottom": child.get_meta("xbz_spike_bottom", -1.0),
							}
						)
					)
				else:
					(
						_role2_spikes
						. append(
							{
								"power": float(child.get("hit_dic").get("power", 0.0)),
								"freeze": float(child.get("freeze_seconds")),
								"script": child.get_script(),
							}
						)
					)
			elif phase == "yutu" and child is YutuSkillEffect and child.skill_id == "1112050":
				(
					_yutu_effects
					. append(
						{
							"side": int(child.dance_side),
							"power": float(child.hit_dic.get("power", 0.0)),
							"awakened": child.hit_dic.get("yutu_dance_awakened", false) == true,
							"shadow": child.hit_dic.get("yutu_dance_shadow", false) == true,
						}
					)
				)
		await get_tree().create_timer(0.03, false).timeout
		elapsed += 0.03

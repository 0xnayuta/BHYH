extends Node

## 38-6 缺口回归：非 qly 精英 signature 方向、72/73 魂晶图标、
## 2P 魂卡属性隔离与双人精英实际属性。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "PHASE_38_6_PROBE_RESULT="
const TEARDOWN_MARKER := "PHASE_38_6_PROBE_TEARDOWN"
const LEVEL_ELITE := preload("res://Scene/level/level_elite.tscn")
const ATTACK_SCRIPT := preload("res://Script/level/elite_attack.gd")
const BOSS_STATS := preload("res://Script/level/elite_boss_stats.gd")
const SOUL_CARD := preload("res://Script/data/soul_card_data.gd")

var _checks: Dictionary = {}
var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var saved_selection: Dictionary = Global.get_run_context().get_elite_challenge_selection()
	var saved_level: String = Global.get_current_level_name()
	var saved_game_over: int = Global.get_run_context().get_game_over_variant()
	var saved_data: Dictionary = PlayerData.player_data.duplicate(true)
	await _check_elite_direction()
	_check_soul_crystal_icons()
	await _check_coop_soul_card_stats()
	await _check_coop_elite_stats()
	await _check_74_ui()
	Global.get_run_context().set_elite_challenge_selection(saved_selection)
	Global.set_current_level_name(saved_level)
	Global.get_run_context().set_game_over_variant(saved_game_over)
	PlayerData.player_data = saved_data
	LocalCoop.clear_runtime()
	_report()


func _check_elite_direction() -> void:
	Global.get_run_context().set_elite_challenge_selection({"card": "sfe", "tier": 0})
	var level := LEVEL_ELITE.instantiate()
	add_child(level)
	var mechanics: Node = null
	for _index in range(120):
		mechanics = level.get_node_or_null("EliteMechanics")
		if mechanics != null and is_instance_valid(level.get("elite_boss")):
			break
		await get_tree().process_frame
	_checks["sfe_elite_spawned"] = mechanics != null and is_instance_valid(level.get("elite_boss"))
	if mechanics == null:
		_checks["sfe_attack_created"] = false
		_checks["sfe_attack_direction"] = false
		level.queue_free()
		await get_tree().process_frame
		return
	level.set_physics_process(false)
	mechanics.call("_emit", Vector2(500, 300), "sound", 125.0, 0.8, Vector2.RIGHT, false)
	var attack: Node = null
	for child in level.get_children():
		if child.get_script() == ATTACK_SCRIPT:
			attack = child
			break
	_checks["sfe_attack_created"] = attack != null
	_checks["sfe_attack_direction"] = (
		attack != null
		and attack.get("move_direction") is Vector2
		and (attack.get("move_direction") as Vector2).is_equal_approx(Vector2.RIGHT)
	)
	_checks["sfe_attack_visual"] = attack != null and str(attack.get("visual")) == "sound"
	if attack != null:
		attack.set_physics_process(false)
		attack.queue_free()
	level.queue_free()
	await get_tree().process_frame


func _check_soul_crystal_icons() -> void:
	var icon_72 := EquipmentService.definition(&"heaven_soul_crystal_72")
	var icon_73 := EquipmentService.definition(&"heaven_soul_crystal_73")
	_checks["soul_crystal_72_icon"] = (
		icon_72 != null and icon_72.icon_path == "res://Art/monster/soul_crystal/72.png"
	)
	_checks["soul_crystal_73_icon"] = (
		icon_73 != null and icon_73.icon_path == "res://Art/monster/soul_crystal/73.png"
	)


func _check_coop_soul_card_stats() -> void:
	LocalCoop.create_secondary(2)
	await get_tree().process_frame
	_set_soul_card(PlayerData.player_data, 1, "qly")
	_set_soul_card(LocalCoop.secondary_data.player_data, 2, "sfe")
	var primary_props: Node = get_node("/root/RoleProp")
	var secondary_props: Node = LocalCoop.secondary_props
	primary_props.call("_refresh_static_prop_cache")
	secondary_props.call("_refresh_static_prop_cache")
	var primary_values: Dictionary = primary_props.get("_cached_wanling_props")
	var secondary_values: Dictionary = secondary_props.get("_cached_wanling_props")
	_checks["coop_soul_primary_power"] = float(primary_values.get("power", 0.0)) >= 5400.0
	_checks["coop_soul_secondary_power"] = float(secondary_values.get("power", 0.0)) >= 4800.0
	_checks["coop_soul_secondary_magic"] = float(secondary_values.get("SMp", 0.0)) >= 1200.0
	_checks["coop_soul_isolated"] = (
		float(secondary_values.get("power", 0.0)) < float(primary_values.get("power", 0.0))
		and float(secondary_values.get("SMp", 0.0)) > float(primary_values.get("SMp", 0.0))
	)
	await get_tree().process_frame


func _check_coop_elite_stats() -> void:
	Global.get_run_context().set_elite_challenge_selection({"card": "sfe", "tier": 0})
	var level := LEVEL_ELITE.instantiate()
	add_child(level)
	var enemy: BaseMonster = null
	for _index in range(120):
		enemy = level.get("elite_boss") as BaseMonster
		if enemy != null:
			break
		await get_tree().process_frame
	var max_attack := 0
	if enemy != null:
		for attack in enemy.obj_attack_dict.values():
			if attack is Dictionary:
				max_attack = maxi(max_attack, int(attack.get("power", 0)))
	_checks["coop_elite_spawned"] = enemy != null
	_checks["coop_elite_attack"] = max_attack == 351000
	_checks["coop_elite_damage_reduction"] = enemy != null and is_equal_approx(float(enemy.damage_reduction), 1.5)
	_checks["coop_elite_health"] = enemy != null and int(enemy.max_hp) == 6000000000
	level.queue_free()
	await get_tree().process_frame


func _check_74_ui() -> void:
	var announcement := (load("res://Scene/main_menu/game_announcement.tscn") as PackedScene).instantiate()
	add_child(announcement)
	await get_tree().process_frame
	_checks["announcement_v74_text"] = (announcement.get("text_data") as Dictionary).has("V7_4")
	_checks["announcement_v74_button"] = (
		announcement.get_node_or_null(
			"BG/PanelContainer/HBoxContainer/BBBg/ScrollContainer/bblist/V0_55"
		)
		!= null
	)
	announcement.queue_free()
	await get_tree().process_frame
	var map := (load("res://Scene/main_menu/map_0.tscn") as PackedScene).instantiate()
	add_child(map)
	await get_tree().process_frame
	_checks["map_soul_card_entry"] = map.get_node_or_null("TopButtons/SoulCard") != null
	_checks["map_elite_challenge_entry"] = map.get_node_or_null("TopButtons/EliteChallenge") != null
	map.queue_free()
	await get_tree().process_frame


func _set_soul_card(profile: Dictionary, role: int, id: String) -> void:
	var data := SOUL_CARD.ensure(profile)
	data.cards[id].star = 1
	data.loadouts[str(role)][0] = id


func _report() -> void:
	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

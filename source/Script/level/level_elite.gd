## 7.4 精英副本关卡脚本；由 7.4 反编译参考按当前 API、命名与路径适配。
extends BaseLevel

const DATA := preload("res://Script/data/soul_card_data.gd")
const PANEL_UI_PATH := "res://Script/main_menu/soul_card_panel_base.gd"
const BOSS_STATS := preload("res://Script/level/elite_boss_stats.gd")
const MECHANICS := preload("res://Script/level/elite_boss_mechanics.gd")
var card_id = "qly"
var tier = 0
var elite_boss: BaseMonster
var reward: Dictionary = {}
var ready_to_finish = false
var status: Label
var result_panel: PanelContainer
var elite_ui: CanvasLayer
var _panel_ui_script: Script


func _panel_ui() -> Script:
	if _panel_ui_script == null:
		_panel_ui_script = load(PANEL_UI_PATH) as Script
	return _panel_ui_script


func _panel_theme() -> Theme:
	var script: Script = _panel_ui()
	return script.call("project_theme") as Theme if script != null else Theme.new()


func _ready() -> void:
	var selection: Dictionary = Global.get_run_context().get_elite_challenge_selection()
	card_id = str(selection.get("card", "qly"))
	if not DATA.AVAILABLE_IDS.has(card_id):
		card_id = "qly"
	tier = clampi(int(selection.get("tier", 0)), 0, 2)
	Global.set_current_level_name("精英副本 · " + str(DATA.CARDS[card_id].name))
	Global.get_run_context().set_game_over_variant(1)
	level_stage = 0
	super._ready()
	$BackGround/front/BackgroundMuzha.hide()
	$BackGround/front/BackgroundJinzha.hide()
	$wall/stop1.disabled = true
	exit.hide()
	exit_2.set_deferred("disabled", true)
	_build_hud()
	call_deferred("_spawn_boss")


func _spawn_boss() -> void:
	var scene = load("res://Scene/monster/monster_%d.tscn" % int(DATA.CARDS[card_id].monster)) as PackedScene
	if scene == null:
		show_elite_notice("Boss资源加载失败，请返回地图")
		return
	elite_boss = scene.instantiate() as BaseMonster
	elite_boss.set_meta("elite_card", card_id)
	monster.add_child(elite_boss)
	elite_boss.position = Vector2(820, 340)
	configure_boss(elite_boss)
	var mechanics = MECHANICS.new()
	mechanics.name = "EliteMechanics"
	add_child(mechanics)
	mechanics.setup(elite_boss, self, card_id, tier)
	ready_to_finish = true


func configure_boss(enemy: BaseMonster) -> void:
	BOSS_STATS.apply(enemy, card_id, tier)
	enemy.fall_pro = 0
	enemy.fall_coin = 0
	enemy.fall_stone_pro = 0
	enemy.add_exp = 0
	enemy.start_spawn_damage_protection(1.0)


func _build_hud() -> void:
	elite_ui = CanvasLayer.new()
	elite_ui.name = "EliteUI"
	elite_ui.layer = 4
	add_child(elite_ui)
	status = Label.new()
	status.name = "EliteStatus"
	status.position = Vector2(280, 90)
	elite_ui.add_child(status)
	show_elite_notice("%s · %s：原招特效显现后发动强化攻击，注意走位" % [DATA.TIERS[tier], DATA.CARDS[card_id].name])
	var leave = Button.new()
	leave.name = "LeaveTrial"
	leave.theme = _panel_theme()
	leave.text = "退出试炼"
	leave.position = Vector2(1050, 100)
	leave.size = Vector2(120, 38)
	leave.pressed.connect(return_to_map)
	elite_ui.add_child(leave)


func show_elite_notice(value: String) -> void:
	if is_instance_valid(status):
		status.text = value


func on_elite_monster_defeated(enemy: BaseMonster) -> void:
	if not reward.is_empty() or enemy != elite_boss or not enemy.death():
		return
	var player = get_progression_player()
	if player == null or player.is_death:
		return
	reward = DATA.claim(PlayerData.player_data, card_id, tier)
	if LocalCoop.is_enabled():
		DATA.claim(LocalCoop.secondary_data.player_data, card_id, tier)
	DATA.persist(self)
	call_deferred("_show_result")


func _show_result() -> void:
	show_elite_notice("试炼成功，魂卡奖励已发放")
	result_panel = PanelContainer.new()
	result_panel.name = "EliteResult"
	result_panel.position = Vector2(380, 160)
	result_panel.size = Vector2(440, 210)
	result_panel.theme = _panel_theme()
	elite_ui.add_child(result_panel)
	var rows = VBoxContainer.new()
	result_panel.add_child(rows)
	var text = Label.new()
	text.text = (
		"%s · %s 通关\n%s\n魂卡碎片 +%d"
		% [
			DATA.CARDS[card_id].name,
			DATA.TIERS[tier],
			"获得1星魂卡：" + str(reward.name) if reward.acquired else "重复魂卡转换为20碎片" if reward.full else "本次获得魂卡碎片",
			reward.fragments
		]
	)
	rows.add_child(text)
	var retry = Button.new()
	retry.name = "Retry"
	retry.text = "再次挑战"
	retry.pressed.connect(retry_trial)
	rows.add_child(retry)
	var leave = Button.new()
	leave.name = "ReturnToMap"
	leave.text = "返回地图 · 装备魂卡"
	leave.pressed.connect(return_to_map)
	rows.add_child(leave)


func retry_trial() -> void:
	Global.call_deferred("change_scene", "res://Scene/level/level_elite.tscn")


func return_to_map() -> void:
	Global.call_deferred("change_scene", "res://Scene/main_menu/map_0.tscn")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = false


func set_through() -> void:
	if my_camera != null:
		my_camera.max_left = 0
		my_camera.max_right = 1200


func one_check_can_exit() -> bool:
	return false


func check_can_exit() -> bool:
	return false


func _is_auto_battle_enabled() -> bool:
	return false


func _leave_level_from_exit() -> void:
	if not reward.is_empty():
		return_to_map()


func add_tg(_level) -> void:
	pass

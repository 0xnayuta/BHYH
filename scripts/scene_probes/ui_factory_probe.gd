extends Node

## 场景工厂族探针（由 scripts/scene_probe_runner.py 复制到工程根目录并执行）。
## 验证 W6 S5 拆出的 5 个工厂族：Global.add_* 正式入口仍可用、实例挂在正确的父节点、
## 场景缓存由工厂族持有并在 Global 侧释放语义不变。

const RESULT_PREFIX := "UI_FACTORY_PROBE_RESULT="
const TEARDOWN_MARKER := "UI_FACTORY_PROBE_TEARDOWN"

const MESSAGE_SHOW_PATH := "res://Scene/show_text/message_show.tscn"
const SHOP_PATH := "res://Scene/shop/shop.tscn"
const BACK_PACK_PATH := "res://Scene/back_pack/back_pack.tscn"
const REWARD_BOX_PATH := "res://Scene/other_scene/reward_box_2.tscn"
const BASE_BUFF_PATH := "res://Scene/base/base_buff.tscn"
const HIT_TEXT_PATH := "res://Scene/hittext/hit_text.tscn"
const MONSTER_HEAD_INFO_PATH := "res://Scene/other_scene/monster_head_info.tscn"
const BOSS_INFO_PATH := "res://Scene/monster/boss_info.tscn"
const BASIC_MOMENT_INFO_PATH := "res://Scene/other_scene/basic_monment_info.tscn"
const BOX_SCENE_PATH := "res://Scene/back_pack/box_1.tscn"
const GAME_NEED_KNOW_PATH := "res://Scene/other_scene/game_need_know.tscn"
const HC_HELP_PATH := "res://Scene/other_scene/hc_help.tscn"
const HELP_THING_PATH := "res://Scene/other_scene/help_things.tscn"
const ZHEN_FA_HELP_PATH := "res://Scene/other_scene/zhen_fa_help.tscn"
const ZHEN_FA_TU_PO_PATH := "res://Scene/other_scene/zhen_fa_tu_po.tscn"
const ZHEN_YAN_CURE_LEVEL_PATH := "res://Scene/other_scene/zhen_yan_cure_level.tscn"
const ZHEN_FA_INFO_PATH := "res://Scene/other_scene/zhenfainfo.tscn"
const ZHENFA_LX_BUTTON_PATH := "res://Scene/other_scene/zhenfalxbutton.tscn"
const ZHENYAN_BUTTON_PATH := "res://Scene/other_scene/zhenyanbutton.tscn"
const FORGE_HELP_PATH := "res://Scene/ldl/forge_help.tscn"
const FORGES_PATH := "res://Scene/ldl/forge.tscn"
const DECOMPOSE_HELP_PATH := "res://Scene/ldl/decompose_help.tscn"
const DECOMPOSE_PATH := "res://Scene/ldl/decompose.tscn"
const ROLE4_BULLET_PATH := "res://Scene/hero/role_4/role4_bullet.tscn"
const NEW_BULLET_PATH := "res://Scene/hero/bullet_bullet.tscn"
const ROLE_BULLET_1_PATH := "res://Scene/hero/role_bullet_1.tscn"
const MONSTER65_BULLET_PATH := "res://Scene/monster/monster65bullet.tscn"
const MONSTER141_AURA_PATH := "res://Scene/other_scene/nmw_aura.tscn"
const AURA_PATH := "res://Scene/other_scene/auras.tscn"
const SMB_EFFECT_PATH := "res://Scene/hero/role_2/smb_effect.tscn"
const ROLE_SPECIAL_EFFECT_PATH := "res://Scene/hero/role_special_effect.tscn"
const WS_EFFECT_PATH := "res://Scene/hero/role_1/ws_effect.tscn"
const LINE_EFFECT_PATH := "res://Scene/level/line_effect.tscn"
const GAME_SET_PATH := "res://Scene/main_menu/game_set.tscn"
const SKILL_KEY_SET_PATH := "res://Scene/skill/skill_key_set.tscn"
const MUSIC_SET_PATH := "res://Scene/other_scene/choose_music.tscn"
const LDL_PATH := "res://Scene/ldl/ldl.tscn"
const GAME_INFORMATION_PATH := "res://Scene/main_menu/game_information.tscn"
const LEARN_SKILL_PATH := "res://Scene/skill/learn_skill.tscn"
const BUFF_INFORMATION_PATH := "res://Scene/other_scene/buff_information.tscn"
const BUFF_ICON_PATH := "res://Scene/other_scene/buff_icon.tscn"
const STAGE_PATH := "res://Scene/level/jctfloor_1.tscn"
const FLY_STAGE_PATH := "res://Scene/level/zlw_fly_floor.tscn"
const ZZ_TW_TRAP_PATH := "res://Scene/level/zztw_trap.tscn"
const DSG_CHOOSE_PATH := "res://Scene/level/dsg_choose.tscn"
const TASK_TITLE_PATH := "res://Scene/task/task_title.tscn"
const PING_JIA_PATH := "res://Scene/other_scene/ping_jia.tscn"
const MESSAGE_INFO_PATH := "res://Scene/show_text/message_info.tscn"
const ZD_SKILL_PATH := "res://Scene/skill/zd_skill.tscn"
const BD_SKILL_PATH := "res://Scene/skill/bd_skill.tscn"
const MAGIC_HELP_PATH := "res://Scene/magic_weapon/magic_help.tscn"
const SOME_MONSTER_HELP_PATH := "res://Scene/monster/some_monster_help.tscn"
const LETTER_FOR_PLAYER_PATH := "res://Scene/other_scene/a_letter_for_all_players.tscn"
const CURE_TIMES_BOX_PATH := "res://Scene/shop/cure_times_box.tscn"
const TRANS_BOX_PATH := "res://Scene/other_scene/transmogtified_box.tscn"
const MOSAIC_HELP_PATH := "res://Scene/ldl/mosaic_help.tscn"
const MOSAIC_PATH := "res://Scene/ldl/mosaic.tscn"
const HDZM_PATH := "res://Scene/level/hdzm.tscn"
const LSH_PATH := "res://Scene/other_scene/lsh.tscn"
const LXDY_PATH := "res://Scene/other_scene/lxdy.tscn"
const BASIC_AR_BUTTON_PATH := "res://Scene/other_scene/bacis_ar_button.tscn"
const ROLE_INFORMATION_PATH := "res://Scene/level/role_information.tscn"
const CHANGE_BG_PATH := "res://Scene/other_scene/change_back_ground.tscn"
const H_HJM_PATH := "res://Scene/other_scene/transmogrified.tscn"
const CD_JM_PATH := "res://Scene/archive_interface/read_archive_interface.tscn"
const BASIC_PELLET_PATH := "res://Scene/pellet/basic_pellet.tscn"
const GAME_ANNOUNCEMENT_PATH := "res://Scene/main_menu/game_announcement.tscn"
const ROLE1_SHALLOW_PATH := "res://Scene/hero/role1_s_hallow.tscn"
const ROLE2_SHALLOW_PATH := "res://Scene/base/role2shallow.tscn"
const CAMERA_PATH := "res://Scene/level/camera.tscn"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	# 工厂用例会实例化带 _physics_process 的业务场景；暂停场景树避免用夹具数据驱动
	# 真实逻辑产生日志噪声，探针自身仍按帧推进。
	get_tree().paused = true
	var checks: Dictionary = {}
	await _check_factory_wiring(checks)
	await _check_popup_family(checks)
	await _check_popup_announcement(checks)
	await _check_shop_family(checks)
	await _check_backpack_family(checks)
	await _check_reward_family(checks)
	await _check_combat_family(checks)
	await _check_combat_cache_release(checks)
	await _check_combat_pool(checks)
	await _check_monster_display_family(checks)
	await _check_level_hint_family(checks)
	await _check_zhen_fa_family(checks)
	await _check_forge_family(checks)
	await _check_projectile_family(checks)
	await _check_basic_pellet(checks)
	await _check_effect_family(checks)
	await _check_menu_panel_family(checks)
	await _check_level_scene_family(checks)
	await _check_show_text_family(checks)
	await _check_skill_panel_family(checks)
	await _check_map_overlay_family(checks)
	await _check_magic_weapon(checks)

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	get_tree().paused = false
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_factory_wiring(checks: Dictionary) -> void:
	checks["popup_factory_node"] = _has_child_node("PopupFactory")
	checks["shop_factory_node"] = _has_child_node("ShopFactory")
	checks["backpack_factory_node"] = _has_child_node("BackpackFactory")
	checks["reward_factory_node"] = _has_child_node("RewardFactory")
	checks["combat_factory_node"] = _has_child_node("CombatPresentationFactory")
	checks["monster_display_factory_node"] = _has_child_node("MonsterDisplayFactory")
	checks["level_hint_factory_node"] = _has_child_node("LevelHintFactory")
	checks["zhen_fa_factory_node"] = _has_child_node("ZhenFaFactory")
	checks["forge_factory_node"] = _has_child_node("ForgeFactory")
	checks["projectile_factory_node"] = _has_child_node("ProjectileFactory")
	checks["effect_factory_node"] = _has_child_node("EffectFactory")
	checks["menu_panel_factory_node"] = _has_child_node("MenuPanelFactory")
	checks["level_scene_factory_node"] = _has_child_node("LevelSceneFactory")
	checks["show_text_factory_node"] = _has_child_node("ShowTextFactory")
	checks["skill_panel_factory_node"] = _has_child_node("SkillPanelFactory")
	checks["map_overlay_factory_node"] = _has_child_node("MapOverlayFactory")
	checks["factories_are_not_autoloads"] = (
		Global.get_popup_factory().get_parent() == Global
		and Global.get_shop_factory().get_parent() == Global
		and Global.get_backpack_factory().get_parent() == Global
		and Global.get_reward_factory().get_parent() == Global
		and Global.get_combat_factory().get_parent() == Global
		and Global.get_monster_display_factory().get_parent() == Global
		and Global.get_level_hint_factory().get_parent() == Global
		and Global.get_zhen_fa_factory().get_parent() == Global
		and Global.get_forge_factory().get_parent() == Global
		and Global.get_projectile_factory().get_parent() == Global
		and Global.get_effect_factory().get_parent() == Global
		and Global.get_menu_panel_factory().get_parent() == Global
		and Global.get_level_scene_factory().get_parent() == Global
		and Global.get_show_text_factory().get_parent() == Global
		and Global.get_skill_panel_factory().get_parent() == Global
		and Global.get_map_overlay_factory().get_parent() == Global
	)
	checks["factories_are_plain_nodes"] = (
		Global.get_popup_factory() is Node and Global.get_popup_factory().get_script() != null
	)
	checks["dead_role_entries_removed"] = (
		not Global.has_method("add_role_button")
		and not Global.has_method("add_choose_player")
		and not Global.has_method("add_change_clothes_jm")
	)


func _check_popup_family(checks: Dictionary) -> void:
	var host := _make_host("PopupProbeHost")
	var created: Array[Node] = []
	var message: Node = Global.add_message_show(host, "探针消息", 1.5, Vector2.ZERO)
	await _settle()
	checks["popup_message_created"] = message != null and message.get_parent() == host
	checks["popup_message_text"] = message != null and str(message.show_text) == "探针消息"
	checks["popup_message_z"] = message != null and int(message.z_index) == 999
	if message != null:
		created.append(message)
	var buff_info: Node = Global.add_buff_info(host, Vector2(120, 120), "buff 提示")
	await _settle()
	checks["popup_buff_info_delegates"] = (
		buff_info != null and buff_info.get_parent() == host and str(buff_info.show_text) == "buff 提示"
	)
	if buff_info != null:
		created.append(buff_info)
	var buff_data := {"Name": "probe_buff", "Level": 2}
	var buff_infor: Node = Global.add_buffinfor(host, Vector2(300, 200), buff_data)
	await _settle()
	checks["popup_buff_infor_created"] = buff_infor != null and buff_infor.get_parent() == host
	checks["popup_buff_infor_data"] = buff_infor != null and buff_infor.data_list == buff_data
	checks["popup_buff_infor_hover_layer"] = buff_infor != null and buff_infor.z_index == 4095
	checks["popup_buff_infor_cached"] = Global.is_resource_cached(BUFF_INFORMATION_PATH)
	if buff_infor != null:
		created.append(buff_infor)
	var touch: Node = Global.add_touch_text(host, Vector2(40, 40), "触摸")
	await _settle()
	checks["popup_touch_created"] = touch != null and str(touch.tt) == "触摸"
	if touch != null:
		created.append(touch)
	var moment: Node = Global.add_moment_text(host, Vector2(60, 60), "时刻", 1.0)
	await _settle()
	checks["popup_moment_created"] = moment != null and str(moment.show_text) == "时刻"
	if moment != null:
		created.append(moment)
	var liji: Node = Global.add_lj(host, Vector2(80, 80))
	# liji 是自动播完即释放的飘字，只在构建当帧断言，不跨越 settle。
	checks["popup_liji_created"] = liji != null
	if liji != null:
		created.append(liji)
	var combo: Node = Global.add_combo(host, 7, Vector2(100, 100))
	await _settle()
	checks["popup_combo_created"] = combo != null and combo.get_parent() == host
	if combo != null:
		created.append(combo)
	var combo_again: Node = Global.add_combo(host, 9, Vector2(110, 110))
	checks["popup_combo_reused"] = combo_again != null and combo_again == combo
	var combo_num: Node = Global.add_combo_num(host, 5)
	await _settle()
	checks["popup_combo_num_created"] = combo_num != null and int(combo_num.combo_num) == 5
	if combo_num != null:
		created.append(combo_num)
	var scene_cached := Global.is_resource_cached(MESSAGE_SHOW_PATH)
	checks["popup_scene_cached"] = scene_cached
	_cleanup(created, host)


func _check_popup_announcement(checks: Dictionary) -> void:
	var host := _make_host("AnnouncementProbeHost")
	var announcement: Node = Global.add_game_announcement(host, Vector2(37, 38))
	await _settle()
	checks["popup_announcement_created"] = announcement != null and announcement.get_parent() == host
	checks["popup_announcement_canvaslayer"] = announcement != null and announcement is CanvasLayer
	checks["popup_announcement_offset"] = announcement != null and announcement.offset == Vector2(37, 38)
	checks["popup_announcement_registered"] = (
		announcement != null and Global.get_ui_runtime().is_transient_ui_registered(announcement)
	)
	_cleanup([announcement] as Array[Node], host)


func _check_shop_family(checks: Dictionary) -> void:
	var host := _make_host("ShopProbeHost")
	var created: Array[Node] = []
	var shop: Node = Global.add_shop(host, Vector2(300, 200))
	await _settle()
	checks["shop_created"] = shop != null and shop.get_parent() == host
	checks["shop_transient_registered"] = (
		shop != null and bool(Global.get_ui_runtime().is_transient_ui_registered(shop))
	)
	if shop != null:
		created.append(shop)
	var item: Node = Global.add_shop_items(host, Vector2(320, 220), "probe_item", 5)
	await _settle()
	checks["shop_item_created"] = (item != null and str(item._item_name) == "probe_item" and int(item.need_lh) == 5)
	if item != null:
		created.append(item)
	var mystery: Node = Global.add_mystery_shop(host, Vector2.ZERO)
	await _settle()
	checks["shop_mystery_created"] = mystery != null and mystery.get_parent() == host
	if mystery != null:
		created.append(mystery)
	var choose: Node = Global.add_choose_item(host, Vector2.ZERO, [], "probe_choose", 1)
	await _settle()
	checks["shop_choose_created"] = choose != null and choose.get_parent() == host
	if choose != null:
		created.append(choose)
	var synthesis: Node = Global.add_synthesis(host, Vector2(90, 90))
	await _settle()
	checks["shop_synthesis_created"] = synthesis != null
	if synthesis != null:
		created.append(synthesis)
	var strength: Node = Global.add_strength(host, Vector2(70, 70))
	await _settle()
	checks["shop_strength_created"] = strength != null
	if strength != null:
		created.append(strength)
	var yes_no: Node = Global.add_s_y_n_help(host, Vector2(50, 50))
	await _settle()
	checks["shop_yes_no_created"] = yes_no != null
	if yes_no != null:
		created.append(yes_no)
	var cure: Node = Global.add_cure_times_box(host, Vector2(60, 70))
	await _settle()
	checks["shop_cure_box_created"] = cure != null and cure.get_parent() == host
	checks["shop_cure_box_position"] = cure != null and cure.position == Vector2(60, 70)
	if cure != null:
		created.append(cure)
	var trans: Node = Global.add_trans_box(host, "probe_trans", null)
	await _settle()
	checks["shop_trans_box_created"] = trans != null and trans.get_parent() == host
	checks["shop_trans_box_fields"] = (
		trans != null and str(trans.self_name) == "probe_trans" and trans.transmogrified == null
	)
	if trans != null:
		created.append(trans)
	checks["shop_scene_cached"] = Global.is_resource_cached(SHOP_PATH)
	_cleanup(created, host)


func _check_backpack_family(checks: Dictionary) -> void:
	var host := _make_host("BackpackProbeHost")
	var created: Array[Node] = []
	var main_backpack: Node = Global.add_main_backpack(host, Vector2(10, 10))
	await _settle()
	checks["backpack_main_created"] = main_backpack != null and main_backpack.get_parent() == host
	if main_backpack != null:
		created.append(main_backpack)
	var back_pack: Node = Global.add_back_pack(host, Vector2.ZERO)
	await _settle()
	checks["backpack_backpack_created"] = back_pack != null and back_pack.get_parent() == host
	if back_pack != null:
		created.append(back_pack)
	# 使用真实装备 ID，避免面板 _physics_process 在探针多帧存活期间访问不存在的数据。
	var probe_item := _first_equipment_id()
	var dj_infor: Node = Global.add_dj_infor(host, Vector2(20, 20), probe_item)
	await _settle()
	checks["backpack_dj_infor_created"] = (
		dj_infor != null and probe_item != "" and str(dj_infor.my_name) == probe_item
	)
	if dj_infor != null:
		created.append(dj_infor)
	var pl_sell: Node = Global.add_pl_sell(host, Vector2(30, 30))
	await _settle()
	checks["backpack_pl_sell_created"] = pl_sell != null
	if pl_sell != null:
		created.append(pl_sell)
	var magp: Node = Global.add_magp_infor(host, Vector2(40, 40))
	await _settle()
	checks["backpack_magp_created"] = magp != null
	if magp != null:
		created.append(magp)
	var buff_text: Node = Global.add_buff_icon_text(host, "poision")
	await _settle()
	checks["backpack_buff_text_created"] = buff_text != null and str(buff_text._texture) == "poision"
	if buff_text != null:
		created.append(buff_text)
	var skill_select: Node = Global.add_skill_select(host, Vector2(50, 50), "probe_weapon")
	await _settle()
	checks["backpack_skill_select_created"] = skill_select != null and str(skill_select.weapon_name) == "probe_weapon"
	if skill_select != null:
		created.append(skill_select)
	var use_weapon: Node = Global.add_use_magic_weapon(host, Vector2(60, 60))
	await _settle()
	checks["backpack_use_weapon_created"] = use_weapon != null
	if use_weapon != null:
		created.append(use_weapon)
	var role_info: Node = Global.add_role_information(host, Vector2(70, 71))
	checks["backpack_role_info_created"] = role_info != null and role_info.get_parent() == host
	checks["backpack_role_info_fields"] = (
		role_info != null and role_info.z_index == 99 and role_info.position == Vector2(70, 71)
	)
	checks["backpack_role_info_buff_box"] = (role_info != null and Global.buff_box == role_info.buff_box)
	if role_info != null:
		created.append(role_info)
	var h_hjm: Node = Global.add_h_hjm(host, Vector2(72, 73))
	await _settle()
	checks["backpack_h_hjm_created"] = h_hjm != null and h_hjm.get_parent() == host
	checks["backpack_h_hjm_position"] = h_hjm != null and h_hjm.position == Vector2(72, 73)
	if h_hjm != null:
		created.append(h_hjm)
	checks["backpack_scene_cached"] = Global.is_resource_cached(BACK_PACK_PATH)
	_cleanup(created, host)
	Global.buff_box = null


func _check_reward_family(checks: Dictionary) -> void:
	var host := _make_host("RewardProbeHost")
	var created: Array[Node] = []
	var reward_info: Node = Global.add_reward_info(host, Vector2.ZERO, [], "", 0)
	await _settle()
	checks["reward_info_created"] = reward_info != null and reward_info.get_parent() == host
	if reward_info != null:
		created.append(reward_info)
	var probe_item_id := _first_equipment_id()
	checks["reward_item_id_available"] = probe_item_id != ""
	var reward_box: Node = Global.add_reward_box(host, probe_item_id, 3)
	await _settle()
	checks["reward_box_created"] = (
		reward_box != null and str(reward_box.item_id) == probe_item_id and int(reward_box.num) == 3
	)
	if reward_box != null:
		created.append(reward_box)
	var task_reward: Node = Global.add_task_reward(host, probe_item_id, 2)
	await _settle()
	checks["reward_task_created"] = task_reward != null and int(task_reward.total_num) == 2
	if task_reward != null:
		created.append(task_reward)
	var basic_task: Node = Global.add_basic_task(host, Vector2.ZERO)
	await _settle()
	checks["reward_basic_task_created"] = basic_task != null
	if basic_task != null:
		created.append(basic_task)
	var after_end: Node = Global.add_after_level_end(host, Vector2.ZERO)
	await _settle()
	checks["reward_after_end_created"] = after_end != null
	if after_end != null:
		created.append(after_end)
	checks["reward_scene_cached"] = Global.is_resource_cached(REWARD_BOX_PATH)
	_cleanup(created, host)


func _check_combat_family(checks: Dictionary) -> void:
	var host := _make_host("CombatProbeHost")
	var created: Array[Node] = []
	# BaseBuff 要求父级挂在 BaseHero/BaseMonster 下；归属用例由协作探针覆盖真实怪物，
	# 本探针只验证工厂入口的拒绝语义与返回形状。
	checks["combat_buff_rejects_null"] = Global.add_buff(null, {"Name": "Voodoo"}) == null
	checks["combat_buff_rejects_empty_name"] = Global.add_buff(host, {"Name": ""}) == null
	checks["combat_buff_rejects_non_dictionary"] = Global.add_buff(host, "bad") == null
	var icon_data := {"Name": "probe_icon", "Level": 1}
	var buff_icon: Node = Global.add_buff_icon(host, icon_data)
	await _settle()
	checks["combat_buff_icon_created"] = buff_icon != null and buff_icon.get_parent() == host
	checks["combat_buff_icon_fields"] = (
		buff_icon != null
		and str(buff_icon.buff_name) == "probe_icon"
		and str(buff_icon.name) == "probe_icon"
		and buff_icon.data_list == icon_data
	)
	checks["combat_buff_icon_cached"] = Global.is_resource_cached(BUFF_ICON_PATH)
	# 负向断言：无效父节点返回 null，不创建节点。
	checks["combat_buff_icon_rejects_null_parent"] = Global.add_buff_icon(null, icon_data) == null
	if buff_icon != null:
		created.append(buff_icon)
	var trap: Node = Global.add_trap(host, Vector2(11, 11), "probe_trap")
	await _settle()
	checks["combat_trap_created"] = trap != null and str(trap._get_name) == "probe_trap"
	if trap != null:
		created.append(trap)
	var hit: Node = Global.add_hit_text(host, Vector2(12, 12), "1234", "physics", false, false)
	await _settle()
	checks["combat_hit_text_created"] = hit != null and str(hit.show_text) == "1234"
	if hit != null:
		created.append(hit)
	var monster_blood: Node = Global.add_monster_blood(host, Vector2(13, 13), 0.5, 50)
	await _settle()
	checks["combat_monster_blood_created"] = (
		monster_blood != null
		and int(monster_blood.bar_text) == 50
		and is_equal_approx(float(monster_blood.bar_value), 0.5)
	)
	if monster_blood != null:
		created.append(monster_blood)
	var miss: Node = Global.add_miss_effect(host, Vector2(14, 14))
	await _settle()
	checks["combat_miss_created"] = miss != null and miss.get_parent() == host
	if miss != null:
		created.append(miss)
	var damage_number: Node = Global.add_damage_number(host, 999, "physics", true, null)
	await _settle()
	checks["combat_damage_number_created"] = damage_number != null and int(damage_number.need_number) == 999
	if damage_number != null:
		created.append(damage_number)
	var boss_blood: Node = Global.add_boss_blood_instance(host, null)
	await _settle()
	checks["combat_boss_blood_created"] = boss_blood != null
	if boss_blood != null:
		created.append(boss_blood)
	var bullet: Node = Global.add_bullet("knife", host, true, 5.0, Vector2(15, 15), "", [])
	checks["combat_bullet_created"] = bullet != null
	if bullet != null:
		created.append(bullet)
	var safe_bullet: Node = Global.add_bullet_safe("knife", host, true, 5.0, Vector2(16, 16), "", [])
	checks["combat_bullet_safe_created"] = safe_bullet != null
	if safe_bullet != null:
		created.append(safe_bullet)
	var effect_bullet: Node = Global.add_special_effect_bullet(host, Vector2(17, 17), Vector2.ONE, "hmz", false)
	checks["combat_effect_bullet_created"] = effect_bullet != null
	if effect_bullet != null:
		created.append(effect_bullet)
	checks["combat_scene_cached"] = Global.is_resource_cached(HIT_TEXT_PATH)
	_cleanup(created, host)


func _check_combat_pool(checks: Dictionary) -> void:
	var pool := Global.get_combat_pool()
	checks["combat_pool_node"] = pool != null and pool.get_parent() == Global
	checks["combat_pool_limits"] = (
		int(pool.get_pool_limits().get("damage_text", 0)) == 80
		and int(pool.get_pool_limits().get("mr_hurt", 0)) == 32
		and int(pool.get_pool_limits().get("role_be_hit", 0)) == 24
		and int(pool.get_pool_limits().get("sound_player", 0)) == 32
	)
	var host := _make_host("CombatPoolProbeHost")
	pool.clear_runtime_pools()
	var first: Node = Global.add_damage_text(host, Vector2(1, 1), 111, "physics", false, null)
	var second: Node = Global.add_damage_text(host, Vector2(2, 2), 222, "magic", true, null)
	await _settle()
	checks["damage_text_created"] = first != null and second != null
	checks["damage_text_counted"] = pool.get_active_damage_text_count() == 2
	Global.recycle_damage_text(first)
	checks["damage_text_recycled"] = pool.get_active_damage_text_count() == 1
	checks["damage_text_pooled"] = pool.get_pool_size("damage_text") >= 1
	var mr_first: Node = Global.add_mr_hurt(host, Vector2(3, 3))
	var mr_second: Node = Global.add_mr_hurt(host, Vector2(4, 4))
	await _settle()
	checks["mr_hurt_created"] = mr_first != null
	checks["mr_hurt_throttled"] = mr_second == null
	var role_hit: Node = Global.add_special_effect(host, Vector2(5, 5), "RoleBeHit", Vector2.ONE, false, 1.0)
	await _settle()
	checks["role_be_hit_created"] = role_hit != null
	Global.recycle_role_be_hit(role_hit)
	checks["role_be_hit_pooled"] = pool.get_pool_size("role_be_hit") >= 1
	var slim: Node = Global.add_special_effect(host, Vector2(6, 6), "blood_reduce", Vector2.ONE, false, 1.0)
	await _settle()
	checks["special_effect_slim_created"] = slim != null and str(slim.effect_name) == "blood_reduce"
	checks["sword_damage_text_throttle"] = bool(Global.can_show_sword_damage_text())
	checks["sword_hit_effect_throttle"] = bool(Global.can_show_sword_hit_effect())
	pool.clear_runtime_pools()
	_cleanup([slim], host)


func _check_monster_display_family(checks: Dictionary) -> void:
	# 怪物展示族：三个场景槽位常驻，重复调用共用同一 PackedScene 但实例彼此独立。
	var host := _make_host("MonsterDisplayProbeHost")
	var created: Array[Node] = []
	var head: Node = Global.add_monster_head(host, "ProbeBoss", true, "res://Scene/level/level_1.tscn")
	await _settle()
	checks["monster_head_created"] = head != null and head.get_parent() == host
	checks["monster_head_name"] = head != null and str(head.monster_name) == "ProbeBoss"
	checks["monster_head_is_boss"] = head != null and bool(head.is_boss)
	checks["monster_head_scene_path"] = (
		head != null and str(head.monster_scene_path) == "res://Scene/level/level_1.tscn"
	)
	if head != null:
		created.append(head)
	var second_head: Node = Global.add_monster_head(host, "ProbeBoss2", false)
	await _settle()
	checks["monster_head_second_instance"] = second_head != null and second_head != head
	if second_head != null:
		created.append(second_head)
	var info: Node = Global.add_monster_info(host, "ProbeBoss", Vector2(31, 32))
	await _settle()
	checks["monster_info_created"] = info != null and info.get_parent() == host
	checks["monster_info_name"] = info != null and str(info.monster_name) == "ProbeBoss"
	checks["monster_info_position"] = info != null and info.position == Vector2(31, 32)
	if info != null:
		created.append(info)
	var moment: Node = Global.add_basic_monment_info(host, "探针提示", Vector2(41, 42))
	await _settle()
	checks["basic_moment_created"] = moment != null and moment.get_parent() == host
	checks["basic_moment_text"] = moment != null and str(moment.show_text) == "探针提示"
	checks["basic_moment_position"] = moment != null and moment.position == Vector2(41, 42)
	if moment != null:
		created.append(moment)
	checks["monster_display_scenes_cached"] = (
		Global.is_resource_cached(MONSTER_HEAD_INFO_PATH)
		and Global.is_resource_cached(BOSS_INFO_PATH)
		and Global.is_resource_cached(BASIC_MOMENT_INFO_PATH)
	)
	_cleanup(created, host)


func _check_level_hint_family(checks: Dictionary) -> void:
	# 关卡提示族：掉落箱与道具箱共用同一场景槽位，但元数据与字段不同。
	var host := _make_host("LevelHintProbeHost")
	var created: Array[Node] = []
	var fall_box: Node = Global.add_level_fall_box(host, true, false, "probe_drop", 2, ["金"], {"Def": 1})
	await _settle()
	checks["level_fall_box_created"] = fall_box != null and fall_box.get_parent() == host
	checks["level_fall_box_flags"] = (
		fall_box != null and bool(fall_box.is_in_ldl_gz) and not bool(fall_box.is_in_hhgz)
	)
	checks["level_fall_box_quality"] = fall_box != null and int(fall_box.qh_level) == 2
	checks["level_fall_box_name"] = (
		fall_box != null
		and str(fall_box.get_item_name) == "probe_drop"
		and str(fall_box.get_meta("item_name", "")) == "probe_drop"
	)
	checks["level_fall_box_meta"] = fall_box != null and bool(fall_box.get_meta("level_fall_box", false))
	if fall_box != null:
		created.append(fall_box)
	var item_box: Node = Global.add_item_box(host, false, true, "probe_item", 3, 5, ["木"], {})
	await _settle()
	checks["item_box_created"] = item_box != null and item_box.get_parent() == host
	checks["item_box_total_number"] = item_box != null and int(item_box.total_number) == 5
	checks["item_box_no_fall_meta"] = item_box != null and not item_box.has_meta("level_fall_box")
	if item_box != null:
		created.append(item_box)
	var know: Node = Global.add_game_need_know(host, Vector2(21, 22))
	await _settle()
	checks["game_need_know_created"] = know != null and know.get_parent() == host
	checks["game_need_know_position"] = know != null and know.position == Vector2(21, 22)
	if know != null:
		created.append(know)
	var hc_help: Node = Global.add_hc_help(host, Vector2(31, 32))
	await _settle()
	checks["hc_help_created"] = hc_help != null and hc_help.get_parent() == host
	checks["hc_help_position"] = hc_help != null and hc_help.position == Vector2(31, 32)
	if hc_help != null:
		created.append(hc_help)
	var help_thing: Node = Global.add_help_thing(host, Vector2(41, 42), {"Name": "probe"})
	await _settle()
	checks["help_thing_created"] = help_thing != null and help_thing.get_parent() == host
	checks["help_thing_info"] = (help_thing != null and str(help_thing.item_info.get("Name", "")) == "probe")
	checks["help_thing_position"] = help_thing != null and help_thing.position == Vector2(41, 42)
	if help_thing != null:
		created.append(help_thing)
	checks["level_hint_scenes_cached"] = (
		Global.is_resource_cached(BOX_SCENE_PATH)
		and Global.is_resource_cached(GAME_NEED_KNOW_PATH)
		and Global.is_resource_cached(HC_HELP_PATH)
		and Global.is_resource_cached(HELP_THING_PATH)
	)
	_cleanup(created, host)


func _check_zhen_fa_family(checks: Dictionary) -> void:
	# 阵法面板族：六个入口共用父节点与父面板引用，返回形状各自独立。
	var host := _make_host("ZhenFaProbeHost")
	var created: Array[Node] = []
	var help: Node = Global.add_zhen_fa_help(host, Vector2(11, 12))
	await _settle()
	checks["zhen_fa_help_created"] = help != null and help.get_parent() == host
	checks["zhen_fa_help_position"] = help != null and help.position == Vector2(11, 12)
	if help != null:
		created.append(help)
	var father := Node2D.new()
	father.name = "ZhenFaProbeFather"
	add_child(father)
	var tu_po: Node = Global.add_zhen_fa_tu_po(host, Vector2(21, 22), father)
	await _settle()
	checks["zhen_fa_tu_po_created"] = tu_po != null and tu_po.get_parent() == host
	checks["zhen_fa_tu_po_father"] = tu_po != null and tu_po.father == father
	if tu_po != null:
		created.append(tu_po)
	var cure: Node = Global.add_zhen_yan_cure_level(host, Vector2(31, 32), father)
	await _settle()
	checks["zhen_yan_cure_created"] = cure != null and cure.get_parent() == host
	checks["zhen_yan_cure_father"] = cure != null and cure.father == father
	if cure != null:
		created.append(cure)
	var info: Node = Global.add_zhen_fa_info(host, Vector2(41, 42), father)
	await _settle()
	checks["zhen_fa_info_created"] = info != null and info.get_parent() == host
	checks["zhen_fa_info_father"] = info != null and info.father == father
	if info != null:
		created.append(info)
	var lx_button: Node = Global.add_zhenfalxbutton(host, "probe_zhenfa", father)
	await _settle()
	checks["zhen_fa_lx_created"] = lx_button != null and lx_button.get_parent() == host
	checks["zhen_fa_lx_name"] = lx_button != null and str(lx_button.zhenfa_name) == "probe_zhenfa"
	checks["zhen_fa_lx_father"] = lx_button != null and lx_button.father == father
	if lx_button != null:
		created.append(lx_button)
	var eye: Node = Global.addzhenyanbutton(host, Vector2(51, 52), 3, father)
	await _settle()
	checks["zhen_yan_button_created"] = eye != null and eye.get_parent() == host
	checks["zhen_yan_button_loc"] = eye != null and int(eye.loc_num) == 3
	checks["zhen_yan_button_father"] = eye != null and eye.father == father
	if eye != null:
		created.append(eye)
	checks["zhen_fa_scenes_cached"] = (
		Global.is_resource_cached(ZHEN_FA_HELP_PATH)
		and Global.is_resource_cached(ZHEN_FA_TU_PO_PATH)
		and Global.is_resource_cached(ZHEN_YAN_CURE_LEVEL_PATH)
		and Global.is_resource_cached(ZHEN_FA_INFO_PATH)
		and Global.is_resource_cached(ZHENFA_LX_BUTTON_PATH)
		and Global.is_resource_cached(ZHENYAN_BUTTON_PATH)
	)
	_cleanup(created, host)
	if is_instance_valid(father):
		father.queue_free()


func _check_forge_family(checks: Dictionary) -> void:
	# 锻造/分解族：四个入口共用父节点，锻造说明/主面板与分解说明/主面板各自持有坐标。
	var host := _make_host("ForgeProbeHost")
	var created: Array[Node] = []
	var forge_help: Node = Global.add_forge_help(host, Vector2(13, 14))
	await _settle()
	checks["forge_help_created"] = forge_help != null and forge_help.get_parent() == host
	checks["forge_help_position"] = forge_help != null and forge_help.position == Vector2(13, 14)
	if forge_help != null:
		created.append(forge_help)
	var forges: Node = Global.add_forges(host, Vector2(23, 24))
	await _settle()
	checks["forges_created"] = forges != null and forges.get_parent() == host
	checks["forges_position"] = forges != null and forges.position == Vector2(23, 24)
	if forges != null:
		created.append(forges)
	var decompose_help: Node = Global.add_decompose_help(host, Vector2(33, 34))
	await _settle()
	checks["decompose_help_created"] = decompose_help != null and decompose_help.get_parent() == host
	checks["decompose_help_position"] = decompose_help != null and decompose_help.position == Vector2(33, 34)
	if decompose_help != null:
		created.append(decompose_help)
	var decompose: Node = Global.add_decompose_instance(host, Vector2(43, 44))
	await _settle()
	checks["decompose_created"] = decompose != null and decompose.get_parent() == host
	checks["decompose_position"] = decompose != null and decompose.position == Vector2(43, 44)
	if decompose != null:
		created.append(decompose)
	checks["forge_factory_node"] = _has_child_node("ForgeFactory")
	checks["forge_factory_parent"] = Global.get_forge_factory().get_parent() == Global
	checks["forge_scenes_cached"] = (
		Global.is_resource_cached(FORGE_HELP_PATH)
		and Global.is_resource_cached(FORGES_PATH)
		and Global.is_resource_cached(DECOMPOSE_HELP_PATH)
		and Global.is_resource_cached(DECOMPOSE_PATH)
	)
	# 负向断言：已删除的死入口不得复活。
	checks["forge_box_entry_removed"] = not Global.has_method("add_forge_box")
	_cleanup(created, host)


func _check_basic_pellet(checks: Dictionary) -> void:
	var host := _make_host("PelletProbeHost")
	var pellet: Node = Global.add_basic_pellet(host, Vector2(19, 20))
	await _settle()
	checks["basic_pellet_created"] = pellet != null and pellet.get_parent() == host
	# 场景在 _ready 中按视口重排；只断言可见缩放，不锁定传入坐标。
	checks["basic_pellet_scaled"] = pellet != null and pellet.scale.x > 0.0
	checks["basic_pellet_cached"] = Global.is_resource_cached(BASIC_PELLET_PATH)
	_cleanup([pellet] as Array[Node], host)


func _check_projectile_family(checks: Dictionary) -> void:
	# 弹体族：七个入口共用父节点，缓存槽位与返回字段各自独立。
	var host := _make_host("ProjectileProbeHost")
	var created: Array[Node] = []
	var role4: Node = Global.add_role4_bullet(host, null, Vector2(1, 2))
	await _settle()
	checks["role4_bullet_created"] = role4 != null and role4.get_parent() == host
	checks["role4_bullet_position"] = role4 != null and role4.position == Vector2(1, 2)
	checks["role4_bullet_player_null"] = role4 != null and role4.player == null
	if role4 != null:
		created.append(role4)
	var hit_dic := {"probe": 1}
	var new_bullet: Node = Global.add_new_bullet(host, Vector2(3, 4), 1, "ProbeBullet", hit_dic)
	await _settle()
	checks["new_bullet_created"] = new_bullet != null and new_bullet.get_parent() == host
	checks["new_bullet_fields"] = (
		new_bullet != null
		and str(new_bullet._name) == "ProbeBullet"
		and new_bullet.hit_dic == hit_dic
		and int(new_bullet.direction) == 1
	)
	if new_bullet != null:
		created.append(new_bullet)
	var slim: Node = Global.add_role_bullet(host, Vector2(5, 6), 1, "Role2Bullet1", hit_dic, null)
	await _settle()
	checks["role_bullet_slim_created"] = slim != null and slim.get_parent() == host
	checks["role_bullet_slim_fields"] = (
		slim != null and str(slim._name) == "Role2Bullet1" and int(slim.direction) == 1
	)
	if slim != null:
		created.append(slim)
	var streaming: Node = Global.add_role_bullet(host, Vector2(7, 8), 1, "Role3Bullet2", hit_dic, null)
	await _settle()
	checks["role_bullet_streaming_created"] = streaming != null and streaming.get_parent() == host
	if streaming != null:
		created.append(streaming)
	var bullet_1: Node = Global.add_role_bullet_1(host, Vector2(9, 10), "Role2Bullet2", hit_dic, null)
	await _settle()
	checks["role_bullet_1_created"] = bullet_1 != null and bullet_1.get_parent() == host
	checks["role_bullet_1_fields"] = (
		bullet_1 != null and str(bullet_1._name) == "Role2Bullet2" and bullet_1.hit_dic == hit_dic
	)
	if bullet_1 != null:
		created.append(bullet_1)
	var safe_bullet: Node = Global.add_role_bullet_1_safe(host, Vector2(11, 12), "Role2Bullet3", hit_dic, null)
	await _settle()
	checks["role_bullet_1_safe_created"] = safe_bullet != null and safe_bullet.get_parent() == host
	if safe_bullet != null:
		created.append(safe_bullet)
	var monster_bullet: Node = Global.add_monster65_bullet(host, Vector2(13, 14))
	await _settle()
	checks["monster65_bullet_created"] = monster_bullet != null and monster_bullet.get_parent() == host
	checks["monster65_bullet_position"] = monster_bullet != null and monster_bullet.position == Vector2(13, 14)
	if monster_bullet != null:
		created.append(monster_bullet)
	var weapon_bullet: Node = Global.add_weapon_bullet(host, Vector2(15, 16), "SwordBullet", hit_dic, 1, 50)
	await _settle()
	checks["weapon_bullet_created"] = weapon_bullet != null and weapon_bullet.get_parent() == host
	checks["weapon_bullet_fields"] = (
		weapon_bullet != null
		and weapon_bullet.obj_attack_dict == hit_dic
		and int(weapon_bullet.rnd) == 50
		and int(weapon_bullet.dir) == 1
	)
	if weapon_bullet != null:
		created.append(weapon_bullet)
	checks["projectile_scenes_cached"] = (
		Global.is_resource_cached(ROLE4_BULLET_PATH)
		and Global.is_resource_cached(NEW_BULLET_PATH)
		and Global.is_resource_cached(ROLE_BULLET_1_PATH)
		and Global.is_resource_cached(MONSTER65_BULLET_PATH)
	)
	# 负向断言：清缓存必须真正释放四个槽位，且重新取用仍可加载。
	var projectile_factory := Global.get_projectile_factory()
	projectile_factory.clear_scene_caches()
	checks["projectile_cache_cleared"] = (
		projectile_factory._role4_bullet_scene == null
		and projectile_factory._new_bullet_scene == null
		and projectile_factory._role_bullet_1_scene == null
		and projectile_factory._monster65_bullet_scene == null
		and projectile_factory._basic_pellet_scene == null
	)
	checks["projectile_cache_reloads"] = projectile_factory.get_role4_bullet_scene() != null
	_cleanup(created, host)


func _check_effect_family(checks: Dictionary) -> void:
	# 效果族：六个入口共用父节点，灵魄数值经 PaSkill 加成，字段与返回形状独立。
	var host := _make_host("EffectProbeHost")
	var created: Array[Node] = []
	var boss_aura: Node = Global.add_monster141_aura(host, Vector2(1, 2), null)
	await _settle()
	checks["monster141_aura_created"] = boss_aura != null and boss_aura.get_parent() == host
	checks["monster141_aura_target"] = boss_aura != null and boss_aura.target_monster == null
	checks["monster141_aura_position"] = boss_aura != null and boss_aura.position == Vector2(1, 2)
	if boss_aura != null:
		created.append(boss_aura)
	var soul: Node = Global.add_aura(host, Vector2(3, 4), 10, 2)
	await _settle()
	checks["aura_created"] = soul != null and soul.get_parent() == host
	checks["aura_value_bonus"] = (
		soul != null
		and int(soul.value) == PaSkill.apply_soul_gain_bonus(10)
		and int(soul.get_meta("base_soul_value", -1)) == 10
	)
	checks["aura_color_type"] = soul != null and int(soul.color_type) == 2
	if soul != null:
		created.append(soul)
	var smb: Node = Global.add_smb_effect(host, Vector2(5, 6), 1)
	await _settle()
	checks["smb_effect_created"] = smb != null and smb.get_parent() == host
	checks["smb_effect_dir"] = smb != null and int(smb.dir) == 1
	if smb != null:
		created.append(smb)
	var special: Node = Global.add_role_special_effect(host, Vector2(7, 8), 1, "sd")
	await _settle()
	checks["role_special_effect_created"] = special != null and special.get_parent() == host
	checks["role_special_effect_name"] = special != null and str(special.special_effect_name) == "sd"
	if special != null:
		created.append(special)
	# 未知特效名回落到基础特效场景，仍写入原始名称。
	var fallback_effect: Node = Global.add_role_special_effect(host, Vector2(9, 10), 1, "__missing_effect__")
	await _settle()
	checks["role_special_effect_fallback"] = (
		fallback_effect != null and str(fallback_effect.special_effect_name) == "__missing_effect__"
	)
	if fallback_effect != null:
		created.append(fallback_effect)
	var ws: Node = Global.add_ws_effect(host)
	await _settle()
	checks["ws_effect_created"] = ws != null and ws.get_parent() == host
	if ws != null:
		created.append(ws)
	var line: Node = Global.add_line(host, null, "probe_line")
	await _settle()
	checks["line_effect_created"] = line != null and line.get_parent() == host
	checks["line_effect_fields"] = line != null and str(line.type) == "probe_line" and line.position == Vector2.ZERO
	if line != null:
		created.append(line)
	var role1_shallow: Node = Global.add_role1_shallow(host, Vector2(11, 12), -1, 7, null)
	await _settle()
	checks["role1_shallow_created"] = role1_shallow != null and role1_shallow.get_parent() == host
	checks["role1_shallow_fields"] = (
		role1_shallow != null
		and role1_shallow.position == Vector2(11, 12)
		and int(role1_shallow.iniaction) == 7
		and int(role1_shallow.direction) == -1
		and role1_shallow.player == null
	)
	if role1_shallow != null:
		created.append(role1_shallow)
	var role2_shallow: Node = Global.add_role2_shallow(host, Vector2(13, 14), true)
	await _settle()
	checks["role2_shallow_created"] = role2_shallow != null and role2_shallow.get_parent() == host
	checks["role2_shallow_fields"] = (
		role2_shallow != null and role2_shallow.position == Vector2(13, 14) and bool(role2_shallow.dir)
	)
	if role2_shallow != null:
		created.append(role2_shallow)
	checks["effect_scenes_cached"] = (
		Global.is_resource_cached(MONSTER141_AURA_PATH)
		and Global.is_resource_cached(SMB_EFFECT_PATH)
		and Global.is_resource_cached(ROLE_SPECIAL_EFFECT_PATH)
		and Global.is_resource_cached(WS_EFFECT_PATH)
		and Global.is_resource_cached(LINE_EFFECT_PATH)
		and Global.is_resource_cached(ROLE1_SHALLOW_PATH)
		and Global.is_resource_cached(ROLE2_SHALLOW_PATH)
	)
	_cleanup(created, host)


func _check_menu_panel_family(checks: Dictionary) -> void:
	# 菜单/设置族：六个入口共用父节点；设置/炼丹炉/学习技能登记为临时 UI。
	var host := _make_host("MenuPanelProbeHost")
	var created: Array[Node] = []
	var ui_runtime := Global.get_ui_runtime()
	var game_set: Node = Global.add_game_set(host, Vector2.ZERO)
	await _settle()
	checks["game_set_created"] = game_set != null and game_set.get_parent() == host
	checks["game_set_scaled"] = game_set != null and game_set.scale.x > 0.0 and game_set.scale.x == game_set.scale.y
	checks["game_set_registered"] = (game_set != null and ui_runtime.is_transient_ui_registered(game_set))
	if game_set != null:
		created.append(game_set)
	var key_set: Node = Global.add_skill_key_set(host, Vector2(3, 4), "probe_key")
	await _settle()
	checks["skill_key_set_created"] = key_set != null and key_set.get_parent() == host
	checks["skill_key_set_fields"] = (
		key_set != null and key_set.position == Vector2(3, 4) and str(key_set.need_name) == "probe_key"
	)
	if key_set != null:
		created.append(key_set)
	var music_set: Node = Global.add_music_set(host, Vector2(5, 6))
	await _settle()
	checks["music_set_created"] = music_set != null and music_set.get_parent() == host
	checks["music_set_position"] = music_set != null and music_set.position == Vector2(5, 6)
	if music_set != null:
		created.append(music_set)
	var ldl: Node = Global.add_ldl(host, Vector2(7, 8))
	await _settle()
	checks["ldl_created"] = ldl != null and ldl.get_parent() == host
	# ldl/learn_skill 在 _ready 中按视口自行居中，传入坐标会被覆盖；只断言层级与登记。
	checks["ldl_fields"] = ldl != null and ldl.z_index == 99
	checks["ldl_registered"] = ldl != null and ui_runtime.is_transient_ui_registered(ldl)
	if ldl != null:
		created.append(ldl)
	var gm_infor: Node = Global.add_gm_infor(host, Vector2(9, 10))
	await _settle()
	checks["gm_infor_created"] = gm_infor != null and gm_infor.get_parent() == host
	# 根节点为 CanvasLayer：position/z_index 无对应属性，赋值保持迁移前的无效语义。
	checks["gm_infor_canvaslayer_root"] = gm_infor != null and gm_infor is CanvasLayer
	checks["gm_infor_position_noop"] = gm_infor != null and gm_infor.get("position") == null
	if gm_infor != null:
		created.append(gm_infor)
	var learn_skill: Node = Global.add_learn_skill(host, Vector2(11, 12))
	await _settle()
	checks["learn_skill_created"] = learn_skill != null and learn_skill.get_parent() == host
	checks["learn_skill_fields"] = learn_skill != null and learn_skill.z_index == 99
	# learn_skill 属常驻小 UI 路径，register_transient_ui 按设计跳过登记。
	checks["learn_skill_permanent_not_registered"] = (
		learn_skill != null and not ui_runtime.is_transient_ui_registered(learn_skill)
	)
	if learn_skill != null:
		created.append(learn_skill)
	var mosaic_help: Node = Global.add_mosaic_help(host, Vector2(21, 22))
	await _settle()
	checks["menu_mosaic_help_created"] = mosaic_help != null and mosaic_help.get_parent() == host
	checks["menu_mosaic_help_position"] = mosaic_help != null and mosaic_help.position == Vector2(21, 22)
	if mosaic_help != null:
		created.append(mosaic_help)
	var mosaic: Node = Global.add_mosaic_instance(host, Vector2(23, 24))
	await _settle()
	checks["menu_mosaic_created"] = mosaic != null and mosaic.get_parent() == host
	checks["menu_mosaic_position"] = mosaic != null and mosaic.position == Vector2(23, 24)
	if mosaic != null:
		created.append(mosaic)
	var ar_button: Node = Global.add_basic_ar_button(host, 7)
	await _settle()
	checks["menu_ar_button_created"] = ar_button != null and ar_button.get_parent() == host
	checks["menu_ar_button_fields"] = ar_button != null and int(ar_button.archive_num) == 7
	if ar_button != null:
		created.append(ar_button)
	var change_bg: Node = Global.add_change_bg(host, Vector2(31, 32))
	await _settle()
	checks["menu_change_bg_created"] = change_bg != null and change_bg.get_parent() == host
	checks["menu_change_bg_canvaslayer"] = change_bg != null and change_bg is CanvasLayer
	checks["menu_change_bg_offset"] = change_bg != null and change_bg.offset == Vector2(31, 32)
	if change_bg != null:
		created.append(change_bg)
	var cd_jm: Node = Global.add_cd_jm(host, Vector2(33, 34))
	await _settle()
	checks["menu_cd_jm_created"] = cd_jm != null and cd_jm.get_parent() == host
	checks["menu_cd_jm_position"] = cd_jm != null and cd_jm.position == Vector2(33, 34)
	if cd_jm != null:
		created.append(cd_jm)
	checks["menu_panel_scenes_cached"] = (
		Global.is_resource_cached(GAME_SET_PATH)
		and Global.is_resource_cached(SKILL_KEY_SET_PATH)
		and Global.is_resource_cached(MUSIC_SET_PATH)
		and Global.is_resource_cached(LDL_PATH)
		and Global.is_resource_cached(GAME_INFORMATION_PATH)
		and Global.is_resource_cached(LEARN_SKILL_PATH)
		and Global.is_resource_cached(MOSAIC_HELP_PATH)
		and Global.is_resource_cached(MOSAIC_PATH)
		and Global.is_resource_cached(BASIC_AR_BUTTON_PATH)
		and Global.is_resource_cached(CHANGE_BG_PATH)
		and Global.is_resource_cached(CD_JM_PATH)
	)
	# 负向断言：已删除的死入口不得复活。
	checks["set_menu_entry_removed"] = not Global.has_method("add_set_menu")
	_cleanup(created, host)


func _check_level_scene_family(checks: Dictionary) -> void:
	# 关卡场景族：地板/飞行地板/陷阱/选择面板的字段与坐标各自独立。
	var host := _make_host("LevelSceneProbeHost")
	var created: Array[Node] = []
	var stage: Node = Global.add_stage(host, "probe_stage", Vector2(1, 2))
	await _settle()
	checks["stage_created"] = stage != null and stage.get_parent() == host
	checks["stage_fields"] = stage != null and str(stage.type) == "probe_stage" and stage.position == Vector2(1, 2)
	if stage != null:
		created.append(stage)
	var fly_stage: Node = Global.add_z_lw_stage(host, Vector2(3, 4), 5, 1, 30, true)
	await _settle()
	checks["fly_stage_created"] = fly_stage != null and fly_stage.get_parent() == host
	checks["fly_stage_fields"] = (
		fly_stage != null
		and fly_stage.position == Vector2(3, 4)
		and int(fly_stage.direction) == 1
		and int(fly_stage.speed) == 5
		and int(fly_stage.max_position_x) == 30
		and bool(fly_stage.pd)
	)
	if fly_stage != null:
		created.append(fly_stage)
	var trap: Node = Global.add_zztw_trap(host, "probe_zztw", Vector2(5, 6))
	await _settle()
	checks["zztw_trap_created"] = trap != null and trap.get_parent() == host
	checks["zztw_trap_fields"] = trap != null and str(trap.my_name) == "probe_zztw" and trap.position == Vector2(5, 6)
	if trap != null:
		created.append(trap)
	var dsg: Node = Global.add_dsg_choose(host)
	await _settle()
	checks["dsg_choose_created"] = dsg != null and dsg.get_parent() == host
	# 选择面板在 _ready 中按视口自行居中，传入坐标不是最终位置。
	if dsg != null:
		created.append(dsg)
	var camera: Node = Global.add_camera(host, Vector2(25, 26), 1200)
	await _settle()
	checks["camera_created"] = camera != null and camera.get_parent() == host
	checks["camera_fields"] = (camera != null and camera.position == Vector2(25, 26) and int(camera.max_right) == 1200)
	if camera != null:
		created.append(camera)
	checks["level_scene_scenes_cached"] = (
		Global.is_resource_cached(STAGE_PATH)
		and Global.is_resource_cached(FLY_STAGE_PATH)
		and Global.is_resource_cached(ZZ_TW_TRAP_PATH)
		and Global.is_resource_cached(DSG_CHOOSE_PATH)
		and Global.is_resource_cached(CAMERA_PATH)
	)
	_cleanup(created, host)


func _check_show_text_family(checks: Dictionary) -> void:
	# 展示文本族：字体文本、任务标题与评分文字；已删除的死入口不得复活。
	var host := _make_host("ShowTextProbeHost")
	var created: Array[Node] = []
	var text: Node = Global.add_font_instance(host, "探针文本", null, 18, Color(1, 0, 0), 2, Color(0, 0, 0))
	await _settle()
	checks["show_text_font_created"] = text != null and text.get_parent() == host
	checks["show_text_font_fields"] = (
		text != null
		and str(text.show_text) == "探针文本"
		and text.font == null
		and int(text.font_size) == 18
		and int(text.out_line_size) == 2
		and text.font_color == Color(1, 0, 0)
	)
	if text != null:
		created.append(text)
	var title: Node = Global.add_task_title(host, "probe_type", "probe_task", null)
	await _settle()
	checks["show_text_task_title_created"] = title != null and title.get_parent() == host
	checks["show_text_task_title_fields"] = (
		title != null
		and str(title.task_type) == "probe_type"
		and str(title.task_name) == "probe_task"
		and title.my_father == null
		and int(title.z_index) == 99
	)
	if title != null:
		created.append(title)
	var ping_jia: Node = Global.add_pj(host, Vector2(7, 8), 3)
	await _settle()
	checks["show_text_ping_jia_created"] = ping_jia != null and ping_jia.get_parent() == host
	checks["show_text_ping_jia_fields"] = (
		ping_jia != null and int(ping_jia.num) == 3 and ping_jia.position == Vector2(7, 8)
	)
	if ping_jia != null:
		created.append(ping_jia)
	var monster_help: Node = Global.add_some_monster_help(host, Vector2(15, 16))
	await _settle()
	checks["show_text_monster_help_created"] = monster_help != null and monster_help.get_parent() == host
	checks["show_text_monster_help_position"] = monster_help != null and monster_help.position == Vector2(15, 16)
	if monster_help != null:
		created.append(monster_help)
	var letter: Node = Global.add_letter_for_player(host, Vector2(17, 18))
	await _settle()
	checks["show_text_letter_created"] = letter != null and letter.get_parent() == host
	checks["show_text_letter_position"] = letter != null and letter.position == Vector2(17, 18)
	if letter != null:
		created.append(letter)
	# 这些场景属于运行期 UI 路径：最后一个实例退出后 UiRuntime 会释放场景缓存，
	# 工厂槽位仍持有强引用，因此断言取用可用而不是 is_resource_cached。
	var show_text_factory := Global.get_show_text_factory()
	checks["show_text_scenes_reusable"] = (
		show_text_factory.get_task_title_scene() != null
		and show_text_factory.get_ping_jia_scene() != null
		and show_text_factory.get_message_info_scene() != null
		and show_text_factory.get_some_monster_help_scene() != null
		and show_text_factory.get_letter_for_player_scene() != null
	)
	checks["show_text_dead_entries_removed"] = (
		not Global.has_method("add_star") and not Global.has_method("add_role_magic_need")
	)
	_cleanup(created, host)


func _check_skill_panel_family(checks: Dictionary) -> void:
	# 技能面板族：角色/变身技能面板与法宝说明，层级固定为 99。
	var host := _make_host("SkillPanelProbeHost")
	var created: Array[Node] = []
	var zd: Node = Global.add_zd_skillscene(host, Vector2(9, 10))
	await _settle()
	checks["skill_panel_zd_created"] = zd != null and zd.get_parent() == host
	checks["skill_panel_zd_fields"] = zd != null and zd.z_index == 99 and zd.position == Vector2(9, 10)
	if zd != null:
		created.append(zd)
	var bd: Node = Global.add_bd_skillscene(host, Vector2(11, 12))
	await _settle()
	checks["skill_panel_bd_created"] = bd != null and bd.get_parent() == host
	checks["skill_panel_bd_fields"] = bd != null and bd.z_index == 99 and bd.position == Vector2(11, 12)
	if bd != null:
		created.append(bd)
	var magic_help: Node = Global.add_magic_help(host, Vector2(13, 14))
	await _settle()
	checks["skill_panel_magic_help_created"] = magic_help != null and magic_help.get_parent() == host
	checks["skill_panel_magic_help_fields"] = (
		magic_help != null and magic_help.z_index == 99 and magic_help.position == Vector2(13, 14)
	)
	if magic_help != null:
		created.append(magic_help)
	var skill_panel_factory := Global.get_skill_panel_factory()
	checks["skill_panel_scenes_reusable"] = (
		skill_panel_factory.get_zd_skill_scene() != null
		and skill_panel_factory.get_bd_skill_scene() != null
		and skill_panel_factory.get_magic_help_scene() != null
	)
	_cleanup(created, host)


func _check_map_overlay_family(checks: Dictionary) -> void:
	# 地图浮层族：三个入口均登记为临时 UI；lsh/lxdy 在 _ready 中按视口重排。
	var host := _make_host("MapOverlayProbeHost")
	var created: Array[Node] = []
	var ui_runtime := Global.get_ui_runtime()
	var hdzm: Node = Global.add_hdzm(host, host)
	await _settle()
	checks["map_overlay_hdzm_created"] = hdzm != null and hdzm.get_parent() == host
	checks["map_overlay_hdzm_fields"] = (
		hdzm != null
		and hdzm.parent_node == host
		and hdzm.scale == Vector2.ONE
		and hdzm.position == Global.viewport_center_for_parent(host) - Vector2(493, 260)
	)
	checks["map_overlay_hdzm_registered"] = (hdzm != null and ui_runtime.is_transient_ui_registered(hdzm))
	if hdzm != null:
		created.append(hdzm)
	var lsh: Node = Global.add_lsh(host, host)
	await _settle()
	checks["map_overlay_lsh_created"] = lsh != null and lsh.get_parent() == host
	checks["map_overlay_lsh_scaled"] = lsh != null and lsh.scale.x > 0.0
	checks["map_overlay_lsh_registered"] = (lsh != null and ui_runtime.is_transient_ui_registered(lsh))
	if lsh != null:
		created.append(lsh)
	var lxdy: Node = Global.add_lxdy(host, host)
	await _settle()
	checks["map_overlay_lxdy_created"] = lxdy != null and lxdy.get_parent() == host
	checks["map_overlay_lxdy_scaled"] = lxdy != null and lxdy.scale.x > 0.0
	checks["map_overlay_lxdy_registered"] = (lxdy != null and ui_runtime.is_transient_ui_registered(lxdy))
	if lxdy != null:
		created.append(lxdy)
	var map_overlay_factory := Global.get_map_overlay_factory()
	checks["map_overlay_scenes_reusable"] = (
		map_overlay_factory.get_hdzm_scene() != null
		and map_overlay_factory.get_lsh_scene() != null
		and map_overlay_factory.get_lxdy_scene() != null
	)
	_cleanup(created, host)


func _check_magic_weapon(checks: Dictionary) -> void:
	var runtime := Global.get_magic_weapon_runtime()
	checks["magic_runtime_node"] = runtime != null and runtime.get_parent() == Global
	checks["magic_scene_path_known"] = Global.get_magic_weapon_scene_path("qlsword") != ""
	checks["magic_scene_path_unknown"] = Global.get_magic_weapon_scene_path("__missing_weapon") == ""
	var host := _make_host("MagicWeaponProbeHost")
	runtime.clear_runtime_state()
	var weapon: Node = Global.add_magic_weapon(host, "qlsword", Vector2(10, 10), null)
	await _settle()
	checks["magic_weapon_created"] = weapon != null and weapon.get_parent() == host
	checks["magic_summon_bound"] = Global.get_magic_summon_for(null) == weapon
	var replacement: Node = Global.add_magic_weapon(host, "qlsword", Vector2(20, 20), null)
	await _settle()
	checks["magic_weapon_replaced"] = (
		replacement != null and replacement != weapon and Global.get_magic_summon_for(null) == replacement
	)
	runtime.clear_runtime_state()
	checks["magic_summon_cleared"] = Global.get_magic_summon_for(null) == null
	_cleanup([replacement], host)


func _check_combat_cache_release(checks: Dictionary) -> void:
	Global.get_combat_factory().clear_scene_caches()
	var host := _make_host("CombatReloadHost")
	var reloaded: Node = Global.add_miss_effect(host, Vector2(1, 1))
	await _settle()
	checks["combat_reload_after_clear"] = reloaded != null and reloaded.get_parent() == host
	_cleanup([reloaded] as Array[Node], host)


func _first_equipment_id() -> String:
	# 取一个有图标资源的装备，避免探针把缺失素材算作真实错误。
	for key in AE.all_equipment.keys():
		var item_id := str(key)
		if ResourceLoader.exists("res://Art/backpack/all_items/%s.png" % item_id):
			return item_id
	return ""


func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func _has_child_node(node_name: String) -> bool:
	var child := Global.get_node_or_null(NodePath(node_name))
	return child != null and child.get_script() != null


func _make_host(node_name: String) -> Node2D:
	var host := Node2D.new()
	host.name = node_name
	# 业务场景可能在 _physics_process 中改变 SceneTree.paused 或读取未构造的夹具数据；
	# 探针宿主禁用处理，只保留 _ready 与显式断言。
	host.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().root.add_child(host)
	return host


func _cleanup(nodes: Array, host: Node) -> void:
	for node in nodes:
		if node != null and is_instance_valid(node):
			node.queue_free()
	if host != null and is_instance_valid(host):
		host.queue_free()

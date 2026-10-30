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
	await _check_shop_family(checks)
	await _check_backpack_family(checks)
	await _check_reward_family(checks)
	await _check_combat_family(checks)
	await _check_combat_cache_release(checks)
	await _check_combat_pool(checks)
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
	checks["factories_are_not_autoloads"] = (
		Global.get_popup_factory().get_parent() == Global
		and Global.get_shop_factory().get_parent() == Global
		and Global.get_backpack_factory().get_parent() == Global
		and Global.get_reward_factory().get_parent() == Global
		and Global.get_combat_factory().get_parent() == Global
	)
	checks["factories_are_plain_nodes"] = (
		Global.get_popup_factory() is Node and Global.get_popup_factory().get_script() != null
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
	checks["shop_item_created"] = (
		item != null and str(item._item_name) == "probe_item" and int(item.need_lh) == 5
	)
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
	var dj_infor: Node = Global.add_dj_infor(host, Vector2(20, 20), "probe_dj")
	await _settle()
	checks["backpack_dj_infor_created"] = dj_infor != null and str(dj_infor.my_name) == "probe_dj"
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
	checks["backpack_scene_cached"] = Global.is_resource_cached(BACK_PACK_PATH)
	_cleanup(created, host)


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
		monster_blood != null and int(monster_blood.bar_text) == 50 and is_equal_approx(float(monster_blood.bar_value), 0.5)
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
	get_tree().root.add_child(host)
	return host


func _cleanup(nodes: Array, host: Node) -> void:
	for node in nodes:
		if node != null and is_instance_valid(node):
			node.queue_free()
	if host != null and is_instance_valid(host):
		host.queue_free()

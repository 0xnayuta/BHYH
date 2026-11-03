extends SceneTree

const DataKeys := preload("res://Script/base/data_keys.gd")

var data: Node
var coop: Node
var memory: Node
var global: Node
var stage: Node
var failures: Array[String] = []
var status := "PASS"
var skip_reason := ""
var case_name := ""


class PetSlotProbeLevel:
	extends Node2D

	var spawned_slots: Array[int] = []

	func _spawn_active_pet(slot: int = 1) -> void:
		spawned_slots.append(slot)


class BossProtectionProbeLevel:
	extends Node2D

	var tower_defeated_count: int = 0

	func on_tower_monster_defeated(_monster: Node) -> void:
		tower_defeated_count += 1


func _initialize() -> void:
	call_deferred("_run")


func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		status = "FAIL"


func _skip(reason: String) -> void:
	if status != "FAIL":
		status = "SKIP"
		skip_reason = reason


func _reset_state() -> void:
	if is_instance_valid(stage):
		stage.queue_free()
		await process_frame
	stage = null
	current_scene = null
	coop.clear_runtime()
	data.player_data.clear()
	data.player_data.merge(data.initialized_data.duplicate(true))
	data.player_data["Myself"] = 1
	global.set_cd_path("")


func _make_stage() -> void:
	stage = Node2D.new()
	root.add_child(stage)
	current_scene = stage
	await process_frame


func _make_hero(role_id: int, slot: int, parent: Node = null) -> Node:
	var host: Node = parent if parent != null else stage
	return global.call_hero("role_" + str(role_id), host, Vector2(100 + slot * 50, 340), false, slot)


func _run() -> void:
	data = root.get_node("PlayerData")
	coop = root.get_node("LocalCoop")
	memory = root.get_node("MemoryClass")
	global = root.get_node("Global")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="):
			case_name = arg.trim_prefix("--case=")
	if case_name == "":
		status = "FAIL"
		failures.append("missing --case")
	await _reset_state()
	match case_name:
		"LocalCoopProbe":
			await _case_core()
		"LocalCoopGameplayProbe":
			await _case_gameplay()
		"LocalCoopMagicSwitchProbe":
			await _case_magic_switch()
		"LocalCoopMagicPresentationProbe":
			await _case_magic_presentation()
		"LocalCoopBossProtectionProbe":
			await _case_boss_protection()
		"LocalCoopMonsterBalanceProbe":
			await _case_monster_balance()
		"LocalCoopMonsterInfoProbe":
			await _case_monster_info()
		"LocalCoopNicknameProbe":
			await _case_nickname()
		"LocalCoopPanelProbe":
			await _case_panel()
		"LocalCoopPerformanceProbe":
			await _case_performance()
		"LocalCoopPetBuffProbe":
			await _case_pet_buff()
		"LocalCoopPetExperienceProbe":
			await _case_pet_experience()
		"LocalCoopPetSlotProbe":
			await _case_pet_slot()
		"LocalCoopPetDragonProbe":
			await _case_pet_dragon()
		"LocalCoopPetPhoenixProbe":
			await _case_pet_phoenix()
		"LocalCoopPetRabbitProbe":
			await _case_pet_rabbit()
		"LocalCoopPetMouseProbe":
			await _case_pet_mouse()
		"LocalCoopPetNeatProbe":
			await _case_pet_neat()
		"LocalCoopPetYinTigerProbe":
			await _case_pet_yin_tiger()
		"LocalCoopSharedSoulProbe":
			await _case_shared_soul()
		"LocalCoopSlotLedgerProbe":
			await _case_slot_ledger()
		"LocalCoopPanelOperatorProbe":
			await _case_panel_operator()
		"LocalCoopSkillKeysProbe":
			await _case_skill_keys()
		"LocalCoopSwitchPassiveProbe":
			await _case_switch_passive()
		"LocalCoopSwordMountProbe":
			await _case_sword_mount()
		"LocalCoopCreationUIProbe":
			await _case_creation_ui()
		"LocalCoopAttributionSourcesProbe":
			await _case_attribution_sources()
		"LocalCoopPoolReuseProbe":
			await _case_pool_reuse()
		"LocalCoopDamageStatsProbe":
			await _case_damage_stats()
		"LocalCoopWushuangAttributionProbe":
			await _case_wushuang_attribution()
		"LocalCoopRole4PoisonProbe":
			await _case_role4_poison()
		"LocalCoopAllDeadProbe":
			await _case_all_dead()
		"LocalCoopInputIsolationProbe":
			await _case_input_isolation()
		"LocalCoopKeyConfigProbe":
			await _case_key_config()
		"LocalCoopHudReadOnlyProbe":
			await _case_hud_read_only()
		"LocalCoopAutoBattleProbe":
			await _case_auto_battle()
		_:
			status = "FAIL"
			failures.append("unknown case: " + case_name)
	if is_instance_valid(stage):
		stage.queue_free()
		await process_frame
	coop.clear_runtime()
	var result := {
		"case": case_name,
		"status": status,
		"failures": failures,
		"skip_reason": skip_reason,
	}
	print("COOP_MATRIX_RESULT=", JSON.stringify(result))
	quit(0 if status != "FAIL" else 1)


func _case_core() -> void:
	coop.create_secondary(7)
	_check(coop.is_enabled(), "second profile enabled")
	_check(int(coop.secondary_data.player_data.get("Myself", 0)) == 7, "2P role selected")
	var primary_level := int(data.player_data.get("玩家等级", 0))
	coop.secondary_data.player_data["玩家等级"] = primary_level + 11
	_check(int(data.player_data.get("玩家等级", 0)) == primary_level, "independent levels")
	coop.secondary_data.player_data["道具列表"]["页码1"].append(["coop_probe", 1])
	_check(data.player_data["道具列表"]["页码1"].size() == 1, "bag is shared")
	var snapshot: Dictionary = memory._prepare_player_save_data()
	_check(int(snapshot.get("Myself", 0)) == 1, "save keeps primary profile")
	_check(
		int(snapshot.get(coop.SAVE_KEY, {}).get("2P", {}).get("玩家等级", 0)) == primary_level + 11, "save keeps 2P profile"
	)
	await _make_stage()
	var first: Node = _make_hero(1, 1)
	var second: Node = _make_hero(7, 2)
	_check(first != null and second != null, "both heroes instantiated")
	if first != null and second != null:
		_check(first.PlayerData == data and second.PlayerData == coop.secondary_data, "hero profiles isolated")
		_check(
			first.RoleProp == root.get_node("RoleProp") and second.RoleProp == coop.secondary_props,
			"hero props isolated"
		)
		_check(first.PlayerInput != second.PlayerInput, "input views isolated")
	coop.clear_runtime()


func _case_gameplay() -> void:
	coop.create_secondary(7)
	var level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	stage = level
	coop._on_scene_changed()
	await create_timer(1.2).timeout
	level.can_create = false
	if level.get("create_control") != null:
		level.create_control.stop()
	_check(level.get("role_p2") != null, "level spawns role_p2")
	var p2 = level.get("role_p2")
	if p2 != null:
		_check(int(p2.get_meta("coop_slot", 0)) == 2, "P2 hero slot meta")
	if level.get("role_information") != null:
		level.role_information.reveal_after_scene_loaded()
		_check(level.role_information.role_p2 != null, "role information has P2 HUD")
	level.queue_free()
	await process_frame
	stage = null


func _case_magic_switch() -> void:
	coop.create_secondary(7)
	var weapon_script: Script = load("res://Script/magic_weapon/qlsword.gd")
	var first: Node = weapon_script.new()
	var second: Node = weapon_script.new()
	first.set_meta("coop_slot", 1)
	second.set_meta("coop_slot", 2)
	first.fb_cd = 1.0
	second.fb_cd = 3.0
	_check(first.fb_cd == 1.0 and second.fb_cd == 3.0, "cooldowns isolated")
	var summon1 := Node2D.new()
	var summon2 := Node2D.new()
	first.current_player_magic_summon = summon1
	second.current_player_magic_summon = summon2
	_check(first.current_player_magic_summon == summon1, "P1 summon owner")
	_check(second.current_player_magic_summon == summon2, "P2 summon owner")
	first.current_player_magic_summon = null
	second.current_player_magic_summon = null
	first.free()
	second.free()
	summon1.free()
	summon2.free()


func _magic_weapon_entry(weapon_name: String) -> Dictionary:
	return {
		DataKeys.NAME: weapon_name,
		DataKeys.ENHANCE_LEVEL: 0,
		DataKeys.FIVE_ELEMENTS: [],
		"Data": {"成长率": 0.0},
	}


func _wait_magic_weapon(hero: Node, frames: int = 40) -> Node:
	for _index in frames:
		if hero.get_magic_weapon_target() != null:
			return hero.get_magic_weapon_target()
		await physics_frame
	return hero.get_magic_weapon_target()


## 25-2：装备法宝展示实例的双人创建、切换、默认回退、冷却与移除。
func _case_magic_presentation() -> void:
	coop.create_secondary(7)
	data.player_data[DataKeys.MAGIC_WEAPON] = [_magic_weapon_entry("qlsword")]
	data.player_data["实战法宝"] = "qlsword"
	coop.secondary_data.player_data[DataKeys.MAGIC_WEAPON] = [_magic_weapon_entry("qlsword")]
	coop.secondary_data.player_data["实战法宝"] = "qlsword"
	await _make_stage()
	var holder := Node2D.new()
	stage.add_child(holder)
	var p1: Node = _make_hero(1, 1, holder)
	var p2: Node = _make_hero(7, 2, holder)
	_check(p1 != null and p2 != null, "magic presentation owners instantiated")
	if p1 != null:
		var cd1: Node = load("res://Scene/magic_weapon/magic_weapon_skill_cd.tscn").instantiate()
		stage.add_child(cd1)
		p1.set_meta("magic_cd_icon", cd1)
	if p2 != null:
		var cd2: Node = load("res://Scene/magic_weapon/magic_weapon_skill_cd.tscn").instantiate()
		stage.add_child(cd2)
		p2.set_meta("magic_cd_icon", cd2)
	if p1 == null or p2 == null:
		return
	var p1_target: Node = await _wait_magic_weapon(p1)
	var p2_target: Node = await _wait_magic_weapon(p2)
	_check(p1_target != null and p2_target != null, "both equipped magic weapons instantiated")
	if p1_target == null or p2_target == null:
		return
	_check(p1_target != p2_target, "P1/P2 magic weapon instances isolated")
	_check(int(p1_target.get_meta("coop_slot", 0)) == 1, "P1 magic weapon slot")
	_check(int(p2_target.get_meta("coop_slot", 0)) == 2, "P2 magic weapon slot")
	_check(p1_target.player == p1 and p2_target.player == p2, "magic weapon owner follows hero slot")
	_check(p1.get_active_magic_weapon_name() == "qlsword", "P1 active magic weapon name")
	_check(p1_target.scene_file_path.contains("qlsword"), "P1 initial weapon scene")

	data.player_data[DataKeys.MAGIC_WEAPON] = [
		_magic_weapon_entry("qlsword"),
		_magic_weapon_entry("dshl"),
	]
	data.player_data["实战法宝"] = "dshl"
	for _index in 40:
		await physics_frame
		if p1.get_magic_weapon_target() != null and p1.get_magic_weapon_target() != p1_target:
			break
	var switched: Node = p1.get_magic_weapon_target()
	_check(switched != null and switched != p1_target, "P1 weapon instance replaced on switch")
	_check(switched != null and switched.scene_file_path.contains("cucurbit"), "P1 switched to dshl scene")
	_check(p2.get_magic_weapon_target() == p2_target, "P2 weapon instance survives P1 switch")
	_check(p1.get_active_magic_weapon_name() == "dshl", "P1 active name follows switch")

	data.player_data["实战法宝"] = ""
	for _index in 40:
		await physics_frame
		if p1.get_magic_weapon_target() != null and p1.get_active_magic_weapon_name() == "qlsword":
			break
	_check(p1.get_active_magic_weapon_name() == "qlsword", "empty selection falls back to first weapon")
	_check((data.player_data[DataKeys.MAGIC_WEAPON] as Array).size() == 2, "fallback keeps owned weapon list")

	var current: Node = p1.get_magic_weapon_target()
	_check(current != null, "fallback weapon instantiated")
	if current != null:
		p1.RoleProp.roleprop.Mp = p1.RoleProp.roleprop.SMp
		p1.use_fb()
		for _index in 5:
			await physics_frame
		_check(float(current.get("usecd")) > 0.0, "use_fb starts weapon cooldown")
		var timer: Node = current.get_node_or_null("SkillCD")
		_check(timer is Timer and not timer.is_stopped(), "weapon cooldown timer running")
		var p2_timer: Node = p2_target.get_node_or_null("SkillCD")
		_check(p2_timer is Timer and p2_timer.is_stopped(), "P2 cooldown unaffected by P1 use")

	data.player_data["实战法宝"] = "wdsf"
	for _index in 20:
		await physics_frame
		if p1.get_active_magic_weapon_name() == "qlsword":
			break
	_check(p1.get_active_magic_weapon_name() == "qlsword", "retired weapon falls back to first weapon")

	data.player_data[DataKeys.MAGIC_WEAPON] = []
	for _index in 20:
		await physics_frame
		if p1.get_magic_weapon_target() == null:
			break
	_check(p1.get_magic_weapon_target() == null, "empty weapon list clears instance")
	_check(p2.get_magic_weapon_target() == p2_target, "P2 weapon survives P1 removal")

	coop.secondary_data.player_data[DataKeys.MAGIC_WEAPON] = []
	for _index in 20:
		await physics_frame
		if p2.get_magic_weapon_target() == null:
			break
	_check(p2.get_magic_weapon_target() == null, "P2 empty weapon list clears instance")

	data.player_data[DataKeys.MAGIC_WEAPON] = [_magic_weapon_entry("qlsword")]
	data.player_data["实战法宝"] = "qlsword"
	var exit_target: Node = await _wait_magic_weapon(p1)
	_check(exit_target != null, "hero exit cleanup fixture target")
	if exit_target != null:
		p1.queue_free()
		await process_frame
		await process_frame
		_check(not is_instance_valid(exit_target), "hero exit clears magic weapon instance")

	global.get_magic_weapon_runtime().clear_runtime_state()
	await process_frame
	await process_frame


## 25-3：Boss 保护/白条、控制免疫、技能重置与掉落唯一结算。
func _case_boss_protection() -> void:
	stage = BossProtectionProbeLevel.new()
	root.add_child(stage)
	current_scene = stage
	await process_frame
	var monster: Node = load("res://Scene/monster/monster_139.tscn").instantiate()
	monster.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster.is_boss = true
	monster.hp = 100000
	monster.max_hp = 100000
	monster.set_meta("tower_floor", 1)
	monster.is_stun = true
	monster.set("skill_1_cd", 5.0)
	monster.set_meta("death_drops_settled", false)

	for _index in 225:
		monster._add_boss_protect_from_hit(null)
	_check(monster.is_boss_protecting(), "boss protection activates at max")
	_check(monster.get_boss_current_protect() > 0.0, "boss protection current value")
	_check(monster.get_white_bar_armor_time_left() > 0.0, "white bar starts")
	_check(not monster.is_stun, "boss protection clears control")
	_check(float(monster.get("skill_1_cd")) == 0.0, "boss protection resets skill cooldown")
	_check(monster.is_control_immune(), "boss protection implies control immunity")

	monster._process_boss_protect(4.1)
	_check(not monster.is_boss_protecting(), "boss protection expires")
	_check(monster.is_white_bar_control_immune(), "white bar outlives protection")
	_check(monster.is_control_immune(), "white bar implies control immunity")
	monster._process_boss_protect(4.0)
	_check(not monster.is_white_bar_control_immune(), "white bar expires")
	_check(not monster.is_control_immune(), "control immunity ends with white bar")

	monster.settle_death_drops()
	_check(bool(monster.get_meta("death_drops_settled", false)), "death drops marked settled")
	_check(stage.tower_defeated_count == 1, "tower settlement called once")
	monster.settle_death_drops()
	_check(stage.tower_defeated_count == 1, "duplicate death settlement ignored")
	monster.queue_free()
	await process_frame


func _case_monster_balance() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var settings: Node = root.get_node("MainSet")
	var show_blood: Variant = settings.set_data.get("MonsterBloodSHow", true)
	settings.set_data["MonsterBloodSHow"] = false
	var monster: Node = load("res://Scene/monster/monster_139.tscn").instantiate()
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	_check(monster.max_hp == monster.get_health_without_coop() * 2, "monster max HP doubled")
	_check(monster.get_coop_attack_power(100) == 130, "monster attack scaled")
	_check(is_equal_approx(monster.damage_reduction, 0.25), "monster extra 25% reduction")
	monster.queue_free()
	await process_frame
	settings.set_data["MonsterBloodSHow"] = show_blood


func _labels(node: Node) -> String:
	var result := str(node.text) + "\n" if node is Label else ""
	for child in node.get_children():
		result += _labels(child)
	return result


func _case_monster_info() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var head: Node = load("res://Scene/other_scene/monster_head_info.tscn").instantiate()
	stage.add_child(head)
	await process_frame
	head.monster_name = "dxx"
	head.is_boss = true
	var panel: Control = head._create_monster_attr_panel()
	var text := _labels(panel)
	_check("生命" in text and "攻击" in text, "monster info base attributes")
	panel.free()
	head.monster_name = "验证怪"
	head.level_monster_config = {"name": "验证怪", "hp": 1000, "attack": 100, "damage_reduction": 0.2}
	panel = head._create_monster_attr_panel()
	text = _labels(panel)
	_check("生命：2000" in text, "coop monster info HP scale")
	_check("攻击：130" in text, "coop monster info attack scale")
	_check("免伤：45%" in text, "coop monster info reduction scale")
	panel.free()
	head.queue_free()
	await process_frame


func _case_nickname() -> void:
	coop.create_secondary(7)
	data.player_data["角色昵称"] = "P1"
	coop.secondary_data.player_data["角色昵称"] = "P2"
	var snapshot: Dictionary = memory._prepare_player_save_data()
	_check(snapshot.get("角色昵称", "") == "P1", "1P nickname preserved")
	_check(snapshot.get(coop.SAVE_KEY, {}).get("2P", {}).get("角色昵称", "") == "P2", "2P nickname preserved")


func _case_panel() -> void:
	coop.create_secondary(7)
	await _make_stage()
	_check(coop.panel_host != null and coop.panel_host.get_parent() == coop, "panel host is child node")
	_check(not coop.has_method("open_panel") and not coop.has_method("has_panel"), "panel API moved off LocalCoop")
	coop.panel_host.open_panel(1, "背包")
	await process_frame
	await process_frame
	_check(coop.panel_host.has_panel(), "bag panel opens")
	coop.panel_host.switch_panel(2)
	await process_frame
	await process_frame
	_check(coop.ui_slot == 2, "panel switches to P2")
	if coop.panel_host.has_panel():
		coop.panel_host.current_panel().queue_free()
		await process_frame
		await process_frame
	_check(not coop.panel_host.has_panel(), "panel closes")


func _case_performance() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var monster := Node2D.new()
	stage.add_child(monster)
	var start := Time.get_ticks_usec()
	for _index in 1000:
		coop.props_for(monster)
	var elapsed := Time.get_ticks_usec() - start
	_check(elapsed < 50000, "1000 owner lookups under 50ms")
	_check(coop.owner_hero(stage) == null, "level container is not a hero owner")
	monster.free()


func _pet_probe_data(pet_type: String, pet_name: String, max_hp: int, exp_value: int = 0) -> Dictionary:
	return {
		"名称": pet_name,
		"类型": pet_type,
		"阶段": 1,
		"等级": 1,
		"经验": exp_value,
		"下级经验": 84,
		"生命": max_hp,
		"生命上限": max_hp,
		"魔法": 100,
		"魔法上限": 100,
		"攻击": 10,
		"防御": 10,
		"魔防": 10,
		"暴击": 1,
		"闪避": 1,
		"幸运": 1,
		"回血": 0,
		"回魔": 0,
		"根骨": 0,
		"技能": ["水疗盾"],
		"出战": true,
	}


func _make_pet_buff_unit(slot: int, max_hp: int) -> Node:
	var pet_script: Script = load("res://Script/base/base_object.gd")
	var pet: Node = pet_script.new()
	if not pet.has_method("get") or not pet.has_method("set"):
		_check(false, "pet buff fixture instantiated")
		pet.free()
		return null
	pet.set_meta("coop_slot", slot)
	stage.add_child(pet)
	pet.set_process(false)
	pet.set_physics_process(false)
	pet.set("max_hp", max_hp)
	pet.set("hp", max_hp)
	var pet_data := _pet_probe_data("PetTurtle", "龟布", max_hp)
	pet_data["已学习技能"] = ["生命加成"]
	pet_data["技能等级"] = {"生命加成": 5}
	var runtime_script: Script = load("res://Script/pet/pet_life_bonus_runtime.gd")
	var runtime: Node = runtime_script.new()
	runtime.name = "PetLifeBonusRuntime"
	runtime.setup(pet_data)
	pet.add_child(runtime)
	return pet


func _find_pet_buff(hero: Node, buff_name: String) -> Node:
	if not is_instance_valid(hero) or not is_instance_valid(hero.buff):
		return null
	for child in hero.buff.get_children():
		var info: Variant = child.get("buff_info")
		if info is Dictionary and str(info.get("Name", "")) == buff_name:
			return child
	return null


func _wait_for_pet_buff(hero: Node, buff_name: String, frames: int = 20) -> Node:
	for _index in frames:
		var buff: Node = _find_pet_buff(hero, buff_name)
		if buff != null:
			return buff
		await process_frame
	return _find_pet_buff(hero, buff_name)


func _count_pet_buff(hero: Node, buff_name: String) -> int:
	if not is_instance_valid(hero) or not is_instance_valid(hero.buff):
		return 0
	var count := 0
	for child in hero.buff.get_children():
		var info: Variant = child.get("buff_info")
		if info is Dictionary and str(info.get("Name", "")) == buff_name:
			count += 1
	return count


func _case_pet_buff() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "pet buff owners instantiated")
	if p1 == null or p2 == null:
		return
	var pet1: Node = await _make_pet_buff_unit(1, 1000)
	var pet2: Node = await _make_pet_buff_unit(2, 2000)
	_check(pet1 != null and pet2 != null, "pet owner fixtures instantiated")
	if pet1 == null or pet2 == null:
		return
	var buff1: Node = await _wait_for_pet_buff(p1, "PetLifeBonus")
	var buff2: Node = await _wait_for_pet_buff(p2, "PetLifeBonus")
	_check(buff1 != null, "P1 pet owner buff created")
	_check(buff2 != null, "P2 pet owner buff created")
	if buff1 != null:
		_check(int(buff1.buff_info.get("value", 0)) == 100, "P1 pet buff uses P1 pet HP")
		_check(buff1.get_parent() == p1.buff, "P1 pet buff attached to P1")
	if buff2 != null:
		_check(int(buff2.buff_info.get("value", 0)) == 200, "P2 pet buff uses P2 pet HP")
		_check(buff2.get_parent() == p2.buff, "P2 pet buff attached to P2")
	_check(buff1 != buff2, "pet owner buffs are distinct nodes")
	_check(_count_pet_buff(p1, "PetLifeBonus") == 1, "P1 has only its own pet buff")
	_check(_count_pet_buff(p2, "PetLifeBonus") == 1, "P2 has only its own pet buff")
	_check(int(p1.get_meta("coop_slot", 1)) == 1, "P1 owner slot")
	_check(int(p2.get_meta("coop_slot", 1)) == 2, "P2 owner slot")
	pet1.queue_free()
	pet2.queue_free()
	await process_frame
	await process_frame


func _case_pet_experience() -> void:
	coop.create_secondary(7)
	await _make_stage()
	data.player_data["玩家等级"] = 50
	data.player_data["玩家当前经验"] = 0
	coop.secondary_data.player_data["玩家等级"] = 50
	coop.secondary_data.player_data["玩家当前经验"] = 0
	var props: Node = root.get_node("RoleProp")
	props.baseroleprop.Level = 50
	props.baseroleprop.exp = 0
	coop.secondary_props.baseroleprop.Level = 50
	coop.secondary_props.baseroleprop.exp = 0
	var pet1 := _pet_probe_data("PetTurtle", "龟布", 1000, 5)
	var pet2 := _pet_probe_data("PetTurtle", "龟布", 1000, 7)
	data.player_data["宠物列表"] = [pet1]
	coop.secondary_data.player_data["宠物列表"] = [pet2]
	data.player_data["出战宠物"] = "龟布"
	coop.secondary_data.player_data["出战宠物"] = "龟布"
	var monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster.add_exp = 20
	monster.set_exp()
	_check(int(props.baseroleprop.exp) == 20, "P1 player experience gained")
	_check(int(coop.secondary_props.baseroleprop.exp) == 20, "P2 player experience gained")
	_check(int(pet1.get("经验", 0)) == 25, "P1 pet experience gained")
	_check(int(pet2.get("经验", 0)) == 27, "P2 pet experience gained")
	_check(coop.pet_profile_for(pet1) == data, "P1 pet owner profile")
	_check(coop.pet_profile_for(pet2) == coop.secondary_data, "P2 pet owner profile")
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "pet HUD owners instantiated")
	if p1 == null or p2 == null:
		return
	var hud1: Node = load("res://Scene/base/base_role.tscn").instantiate()
	hud1.player = p1
	hud1.set_meta("coop_slot", 1)
	hud1.set("_cached_level", stage)
	stage.add_child(hud1)
	stage.set_meta(coop.pet_meta_key("active_pet_dead_this_level", 2), true)
	stage.set_meta(coop.pet_meta_key("active_pet_dead_keys", 2), ["PetTurtle", "龟布"])
	var hud_scene: PackedScene = load("res://Scene/base/base_role.tscn")
	var hud2: Node = hud_scene.instantiate()
	hud2.player = p2
	hud2.set_meta("coop_slot", 2)
	hud2.set("_cached_level", stage)
	stage.add_child(hud2)
	await process_frame
	await process_frame
	_check(hud1.pet_panel != null and hud1.pet_panel.visible, "P1 pet HUD visible")
	_check(hud2.pet_panel != null and hud2.pet_panel.visible, "P2 pet HUD visible")
	if hud1.pet_exp_text != null and hud2.pet_exp_text != null:
		_check(hud1.pet_exp_text.text == "25/84", "P1 pet HUD experience")
		_check(hud2.pet_exp_text.text == "27/84", "P2 pet HUD experience")
	if hud1.pet_hp_text != null and hud2.pet_hp_text != null:
		_check(hud1.pet_hp_text.text == "1000/1000", "P1 pet HUD alive")
		_check(hud2.pet_hp_text.text == "0/1000", "P2 pet HUD dead state")
	hud1.queue_free()
	hud2.queue_free()
	monster.queue_free()
	await process_frame
	await process_frame
	# 23-1：P2 龟族升级只写 P2 档案，不得把 1P 出战宠物改成 PetTurtle。
	data.player_data["宠物列表"] = [_pet_probe_data("PetTiger", "虎丸", 1000, 0)]
	data.player_data["出战宠物"] = "PetTiger"
	coop.secondary_data.player_data["宠物列表"] = [_pet_probe_data("PetTurtle", "龟布", 1000, 0)]
	coop.secondary_data.player_data["出战宠物"] = "PetTurtle"
	var evolution_monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	stage.add_child(evolution_monster)
	await process_frame
	evolution_monster.set_physics_process(false)
	evolution_monster._cure_active_pet_exp(200, 2)
	_check(str(data.player_data.get("出战宠物", "")) != "PetTurtle", "P2 turtle evolution keeps P1 active")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetTurtle", "P2 turtle evolution updates P2 active")
	evolution_monster.queue_free()
	await process_frame


## 23-2 共享槽位边界：预热、装备加成、法宝复活必须按槽位解析。
func _case_pet_slot() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var p1_pet := _pet_probe_data("PetTiger", "白灵虎", 1000)
	p1_pet["阶段"] = 2
	var p2_pet := _pet_probe_data("PetTurtle", "玄武将军", 1000)
	p2_pet["阶段"] = 3
	p2_pet["等级"] = 30
	data.player_data["宠物列表"] = [p1_pet]
	coop.secondary_data.player_data["宠物列表"] = [p2_pet]
	data.player_data["出战宠物"] = "PetTiger"
	coop.secondary_data.player_data["出战宠物"] = "PetTurtle"

	var info1: Dictionary = global.get_active_pet_preload_data(1)
	var info2: Dictionary = global.get_active_pet_preload_data(2)
	_check(str(info1.get("type", "")) == "PetTiger" and int(info1.get("stage", 0)) == 2, "P1 preload selects P1 pet")
	_check(
		str(info2.get("type", "")) == "PetTurtle" and int(info2.get("stage", 0)) == 3,
		"P2 preload selects P2 pet actual=" + str(info2)
	)
	var paths1: Array[String] = global.get_active_pet_preload_paths(1)
	var paths2: Array[String] = global.get_active_pet_preload_paths(2)
	_check(paths1.has("res://Scene/pet/pet_tiger_summon_2.tscn"), "P1 preload path is tiger stage 2")
	_check(
		paths2.has("res://Scene/pet/pet_turtle_summon_3.tscn"),
		"P2 preload path is turtle stage 3 actual=" + str(paths2)
	)
	await global.prewarm_active_pet_runtime_resources(1)
	await global.prewarm_active_pet_runtime_resources(2)
	_check(global.get_prewarmed_pet_signature(1) == "PetTiger:2", "P1 prewarm signature")
	_check(
		global.get_prewarmed_pet_signature(2) == "PetTurtle:3",
		"P2 prewarm signature actual=" + global.get_prewarmed_pet_signature(2)
	)

	# 装备加成：阵法等级按槽位读取，P2 不得拿 P1 的加成。
	data.player_data["宠物阵法等级"] = {"生命": 0}
	coop.secondary_data.player_data["宠物阵法等级"] = {"生命": 1}
	var pet_scene: PackedScene = load("res://Scene/pet/pet_turtle_summon_1.tscn")
	var unit1: Node = pet_scene.instantiate()
	var unit2: Node = pet_scene.instantiate()
	unit1.set_meta("coop_slot", 1)
	unit2.set_meta("coop_slot", 2)
	stage.add_child(unit1)
	stage.add_child(unit2)
	await process_frame
	unit1.set_physics_process(false)
	unit1.set_process(false)
	unit2.set_physics_process(false)
	unit2.set_process(false)
	var unit_data := _pet_probe_data("PetTurtle", "龟布", 1000)
	unit1.apply_pet_data(unit_data.duplicate(true))
	unit2.apply_pet_data(unit_data.duplicate(true))
	_check(unit1.PlayerData == data, "P1 pet unit equipment owner")
	_check(unit2.PlayerData == coop.secondary_data, "P2 pet unit equipment owner")
	_check(int(unit2.get("max_hp")) - int(unit1.get("max_hp")) == 400, "P2 pet equipment bonus uses P2 formation")
	unit1.queue_free()
	unit2.queue_free()
	await process_frame

	# 慈心妙莲：只清 P2 死亡态、只恢复 P2 宠物、只重建 P2。
	var probe_level := PetSlotProbeLevel.new()
	stage.add_child(probe_level)
	var player_parent := Node2D.new()
	probe_level.add_child(player_parent)
	var weapon_player: Node = global.call_hero("role_7", player_parent, Vector2(100, 340), false, 2)
	var p1_dead := _pet_probe_data("PetTurtle", "龟布", 1000)
	p1_dead["生命"] = 0
	var p2_dead := _pet_probe_data("PetTurtle", "龟布", 1000)
	p2_dead["生命"] = 0
	data.player_data["宠物列表"] = [p1_dead]
	data.player_data["出战宠物"] = "龟布"
	coop.secondary_data.player_data["宠物列表"] = [p2_dead]
	coop.secondary_data.player_data["出战宠物"] = "龟布"
	for slot in [1, 2]:
		probe_level.set_meta(coop.pet_meta_key("active_pet_dead_this_level", slot), true)
		probe_level.set_meta(coop.pet_meta_key("active_pet_dead_keys", slot), ["PetTurtle", "龟布"])
		probe_level.set_meta(coop.pet_meta_key("active_pet_dead_name", slot), "PetTurtle")
		probe_level.set_meta(coop.pet_meta_key("active_pet_dead_type", slot), "PetTurtle")
		probe_level.set_meta(coop.pet_meta_key("active_pet_dead_display_name", slot), "龟布")
	var weapon: Node = load("res://Script/magic_weapon/eight_immortal_magic_weapon.gd").new()
	weapon.player = weapon_player
	weapon.weapon_id = "hehua"
	weapon.fb_level = 1
	weapon.set_meta("coop_slot", 2)
	weapon._use_miaolian()
	await process_frame
	await process_frame
	_check(int(p2_dead.get("生命", 0)) > 0, "P2 pet revived")
	_check(int(p1_dead.get("生命", 0)) == 0, "P1 pet untouched by P2 revive")
	_check(
		not bool(probe_level.get_meta(coop.pet_meta_key("active_pet_dead_this_level", 2), true)),
		"P2 death meta cleared"
	)
	_check(
		bool(probe_level.get_meta(coop.pet_meta_key("active_pet_dead_this_level", 1), false)), "P1 death meta preserved"
	)
	_check(probe_level.spawned_slots == [2], "P2 revive respawns only P2")
	weapon.free()
	probe_level.queue_free()
	await process_frame


func _find_pet_unit(monster: Node, slot: int, meta_key: String) -> Node:
	if monster == null:
		return null
	for child in monster.get_children():
		if child.has_meta(meta_key) and int(child.get_meta("coop_slot", 1)) == slot:
			return child
	return null


## 23-2 青龙族：族规则、BaseMonster 升级与槽位写回。
func _case_pet_dragon() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var family = load("res://Script/pet/pet_dragon_family.gd").new()
	var family_pet := _pet_probe_data("PetDragon", "龙仔", 1000)
	family_pet["等级"] = 15
	family_pet["阶段"] = 1
	_check(family.matches(family_pet), "dragon family matches type")
	_check(not family.matches({"名称": "朱雀女皇"}), "dragon family rejects phoenix name")
	family.normalize_spawn(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 1, "dragon normalize keeps stored stage")
	family.evolve(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 2, "dragon evolve uses level threshold")
	_check(str(family_pet.get("名称", "")) == "绿英龙", "dragon evolve updates display name")
	_check((family_pet.get("技能", []) as Array).has("闪电冲刺"), "dragon evolve updates skills")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetDragon", "dragon evolve writes P2 active")
	_check(family.scene_path(3) == "res://Scene/pet/pet_dragon_summon_3.tscn", "dragon scene path")

	data.player_data["玩家等级"] = 15
	coop.secondary_data.player_data["玩家等级"] = 15
	data.player_data["玩家当前经验"] = 0
	coop.secondary_data.player_data["玩家当前经验"] = 0
	var props: Node = root.get_node("RoleProp")
	props.baseroleprop.Level = 15
	props.baseroleprop.exp = 0
	coop.secondary_props.baseroleprop.Level = 15
	coop.secondary_props.baseroleprop.exp = 0
	var p1_pet := _pet_probe_data("PetDragon", "龙仔", 1000)
	p1_pet["等级"] = 1
	var p2_pet := _pet_probe_data("PetDragon", "龙仔", 1000)
	p2_pet["等级"] = 14
	data.player_data["宠物列表"] = [p1_pet]
	coop.secondary_data.player_data["宠物列表"] = [p2_pet]
	data.player_data["出战宠物"] = "PetDragon"
	coop.secondary_data.player_data["出战宠物"] = "PetDragon"
	var monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster._cure_active_pet_exp(1000, 2)
	_check(int(p2_pet.get("等级", 0)) == 15, "P2 dragon reaches player level")
	_check(int(p2_pet.get("阶段", 0)) == 2, "P2 dragon evolves to stage 2")
	_check(str(p2_pet.get("名称", "")) == "绿英龙", "P2 dragon evolution name")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetDragon", "P2 dragon active stays type")
	_check(int(p1_pet.get("阶段", 1)) == 1, "P1 dragon untouched by P2 evolution")
	monster.queue_free()
	await process_frame

	# 控制器/BaseLevel 实际生成：P1/P2 青龙单位都必须带槽位元数据。
	p1_pet["等级"] = 15
	p2_pet["等级"] = 15
	stage.queue_free()
	stage = null
	await process_frame
	var level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	stage = level
	coop._on_scene_changed()
	await create_timer(2.0).timeout
	level.can_create = false
	if level.get("create_control") != null:
		level.create_control.stop()
	var p1_unit: Node = _find_pet_unit(level.get("monster"), 1, "pet_dragon_unit")
	var p2_unit: Node = _find_pet_unit(level.get("monster"), 2, "pet_dragon_unit")
	_check(p1_unit != null, "P1 dragon spawned by controller")
	_check(p2_unit != null, "P2 dragon spawned by controller")
	if p1_unit != null:
		_check(int(p1_unit.get("dragon_stage")) == 2, "P1 dragon stage 2")
	if p2_unit != null:
		_check(int(p2_unit.get("dragon_stage")) == 2, "P2 dragon stage 2")
	level.queue_free()
	stage = null
	await process_frame


## 23-2 凤凰族：族规则、升级写回、死亡别名与双槽生成。
func _case_pet_phoenix() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var family = load("res://Script/pet/pet_phoenix_family.gd").new()
	var family_pet := _pet_probe_data("PetPhoenix", "雀蛋", 1000)
	family_pet["等级"] = 15
	family_pet["阶段"] = 3
	_check(family.matches(family_pet), "phoenix family matches type")
	_check(family.is_name("朱雀幼灵"), "phoenix family matches extra name")
	family.normalize_spawn(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 3, "phoenix normalize keeps stored stage")
	family.evolve(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 2, "phoenix evolve uses level threshold")
	_check(str(family_pet.get("名称", "")) == "炎皇雀", "phoenix evolve updates display name")
	_check((family_pet.get("技能", []) as Array).has("不死火鸟"), "phoenix evolve updates skills")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetPhoenix", "phoenix evolve writes P2 active")
	_check(family.scene_path(3) == "res://Scene/pet/pet_phoenix_summon_3.tscn", "phoenix scene path")
	var aliases: Array[String] = ["雀蛋"]
	family.append_death_aliases(aliases, "雀蛋")
	_check(aliases.has("PetPhoenix") and aliases.has("朱雀女皇") and aliases.has("朱雀幼灵"), "phoenix death aliases")

	var alias_level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	var level_aliases: Array[String] = alias_level._active_pet_dead_aliases("雀蛋")
	_check(level_aliases.has("PetPhoenix") and level_aliases.has("朱雀女皇"), "BaseLevel phoenix death aliases")
	alias_level.free()
	var panel: Node = load("res://Scene/pet/pet_interface.tscn").instantiate()
	var panel_aliases: Array[String] = panel._pet_dead_aliases("朱雀幼灵")
	_check(panel_aliases.has("PetPhoenix") and panel_aliases.has("朱雀女皇"), "PetInterface phoenix death aliases")
	panel.free()

	data.player_data["玩家等级"] = 15
	coop.secondary_data.player_data["玩家等级"] = 15
	data.player_data["玩家当前经验"] = 0
	coop.secondary_data.player_data["玩家当前经验"] = 0
	var props: Node = root.get_node("RoleProp")
	props.baseroleprop.Level = 15
	props.baseroleprop.exp = 0
	coop.secondary_props.baseroleprop.Level = 15
	coop.secondary_props.baseroleprop.exp = 0
	var p1_pet := _pet_probe_data("PetPhoenix", "雀蛋", 1000)
	p1_pet["等级"] = 1
	var p2_pet := _pet_probe_data("PetPhoenix", "雀蛋", 1000)
	p2_pet["等级"] = 14
	data.player_data["宠物列表"] = [p1_pet]
	coop.secondary_data.player_data["宠物列表"] = [p2_pet]
	data.player_data["出战宠物"] = "PetPhoenix"
	coop.secondary_data.player_data["出战宠物"] = "PetPhoenix"
	var monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster._cure_active_pet_exp(1000, 2)
	_check(int(p2_pet.get("等级", 0)) == 15, "P2 phoenix reaches player level")
	_check(int(p2_pet.get("阶段", 0)) == 2, "P2 phoenix evolves to stage 2")
	_check(str(p2_pet.get("名称", "")) == "炎皇雀", "P2 phoenix evolution name")
	_check(int(p1_pet.get("阶段", 1)) == 1, "P1 phoenix untouched by P2 evolution")
	monster.queue_free()
	await process_frame

	p1_pet["等级"] = 15
	p2_pet["等级"] = 15
	stage.queue_free()
	stage = null
	await process_frame
	var level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	stage = level
	coop._on_scene_changed()
	await create_timer(2.0).timeout
	level.can_create = false
	if level.get("create_control") != null:
		level.create_control.stop()
	var p1_unit: Node = _find_pet_unit(level.get("monster"), 1, "pet_phoenix_unit")
	var p2_unit: Node = _find_pet_unit(level.get("monster"), 2, "pet_phoenix_unit")
	_check(p1_unit != null, "P1 phoenix spawned by controller")
	_check(p2_unit != null, "P2 phoenix spawned by controller")
	if p1_unit != null:
		_check(int(p1_unit.get("phoenix_stage")) == 2, "P1 phoenix stage 2")
	if p2_unit != null:
		_check(int(p2_unit.get("phoenix_stage")) == 2, "P2 phoenix stage 2")
	level.queue_free()
	stage = null
	await process_frame


## 23-2 月兔族：族规则、升级写回、死亡别名与双槽生成。
func _case_pet_rabbit() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var family = load("res://Script/pet/pet_rabbit_family.gd").new()
	var family_pet := _pet_probe_data("PetRabbit", "月兔", 1000)
	family_pet["等级"] = 15
	family_pet["阶段"] = 4
	_check(family.matches(family_pet), "rabbit family matches type")
	_check(family.matches({"名称": "疾风兔"}), "rabbit family matches display name")
	_check(not family.matches({"名称": "朱雀女皇"}), "rabbit family rejects phoenix name")
	family.normalize_spawn(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 2, "rabbit normalize uses level threshold")
	_check(str(family_pet.get("名称", "")) == "疾风兔", "rabbit normalize updates display name")
	_check((family_pet.get("技能", []) as Array).has("疾风"), "rabbit normalize updates skills")
	_check(int(family_pet.get("生命资质基础上限", 0)) == 2500, "rabbit normalize sets base stat limits")
	family_pet["等级"] = 30
	family.evolve(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 3, "rabbit evolve uses level threshold")
	_check(str(family_pet.get("名称", "")) == "寒冰玉兔", "rabbit evolve updates display name")
	_check((family_pet.get("技能", []) as Array).has("冰陨"), "rabbit evolve updates skills")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetRabbit", "rabbit evolve writes P2 active")
	_check(family.scene_path(4) == "res://Scene/pet/pet_rabbit_summon_4.tscn", "rabbit scene path")
	var aliases: Array[String] = ["月兔"]
	family.append_death_aliases(aliases, "月兔")
	_check(aliases.has("PetRabbit") and aliases.has("冰霜月神"), "rabbit death aliases")

	var alias_level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	var level_aliases: Array[String] = alias_level._active_pet_dead_aliases("月兔")
	_check(level_aliases.has("PetRabbit") and level_aliases.has("冰霜月神"), "BaseLevel rabbit death aliases")
	alias_level.free()
	var panel: Node = load("res://Scene/pet/pet_interface.tscn").instantiate()
	var panel_aliases: Array[String] = panel._pet_dead_aliases("疾风兔")
	_check(panel_aliases.has("PetRabbit") and panel_aliases.has("寒冰玉兔"), "PetInterface rabbit death aliases")
	panel.free()

	data.player_data["玩家等级"] = 15
	coop.secondary_data.player_data["玩家等级"] = 15
	data.player_data["玩家当前经验"] = 0
	coop.secondary_data.player_data["玩家当前经验"] = 0
	var props: Node = root.get_node("RoleProp")
	props.baseroleprop.Level = 15
	props.baseroleprop.exp = 0
	coop.secondary_props.baseroleprop.Level = 15
	coop.secondary_props.baseroleprop.exp = 0
	var p1_pet := _pet_probe_data("PetRabbit", "月兔", 1000)
	p1_pet["等级"] = 1
	var p2_pet := _pet_probe_data("PetRabbit", "月兔", 1000)
	p2_pet["等级"] = 14
	data.player_data["宠物列表"] = [p1_pet]
	coop.secondary_data.player_data["宠物列表"] = [p2_pet]
	data.player_data["出战宠物"] = "PetRabbit"
	coop.secondary_data.player_data["出战宠物"] = "PetRabbit"
	var monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster._cure_active_pet_exp(1000, 2)
	_check(int(p2_pet.get("等级", 0)) == 15, "P2 rabbit reaches player level")
	_check(int(p2_pet.get("阶段", 0)) == 2, "P2 rabbit evolves to stage 2")
	_check(str(p2_pet.get("名称", "")) == "疾风兔", "P2 rabbit evolution name")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetRabbit", "P2 rabbit active stays type")
	_check(int(p1_pet.get("阶段", 1)) == 1, "P1 rabbit untouched by P2 evolution")
	monster.queue_free()
	await process_frame

	p1_pet["等级"] = 15
	p2_pet["等级"] = 15
	stage.queue_free()
	stage = null
	await process_frame
	var level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	stage = level
	coop._on_scene_changed()
	await create_timer(2.0).timeout
	level.can_create = false
	if level.get("create_control") != null:
		level.create_control.stop()
	var p1_unit: Node = _find_pet_unit(level.get("monster"), 1, "pet_rabbit_unit")
	var p2_unit: Node = _find_pet_unit(level.get("monster"), 2, "pet_rabbit_unit")
	_check(p1_unit != null, "P1 rabbit spawned by controller")
	_check(p2_unit != null, "P2 rabbit spawned by controller")
	if p1_unit != null:
		_check(int(p1_unit.get("turtle_stage")) == 2, "P1 rabbit stage 2")
	if p2_unit != null:
		_check(int(p2_unit.get("turtle_stage")) == 2, "P2 rabbit stage 2")
	level.queue_free()
	stage = null
	await process_frame


## 23-2 子鼠族：两阶、等级技能、升级写回、死亡别名与双槽生成。
func _case_pet_mouse() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var family = load("res://Script/pet/pet_mouse_family.gd").new()
	var family_pet := _pet_probe_data("PetMouse", "子鼠元帅", 1000)
	family_pet["等级"] = 30
	family_pet["阶段"] = 2
	_check(family.matches(family_pet), "mouse family matches type")
	_check(family.matches({"名称": "子鼠大元帅"}), "mouse family matches display name")
	_check(not family.matches({"名称": "月兔"}), "mouse family rejects rabbit name")
	family.normalize_spawn(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 1, "mouse normalize uses level stage")
	_check(str(family_pet.get("名称", "")) == "子鼠元帅", "mouse normalize updates display name")
	_check((family_pet.get("技能", []) as Array).size() == 2, "mouse normalize applies level 30 skills")
	_check(int(family_pet.get("生命资质基础上限", 0)) == 2500, "mouse normalize sets base stat limits")
	family_pet["等级"] = 50
	family.evolve(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 2, "mouse evolve reaches stage 2")
	_check(str(family_pet.get("名称", "")) == "子鼠大元帅", "mouse evolve updates display name")
	_check((family_pet.get("技能", []) as Array).has("子鼠奥义"), "mouse evolve applies level 50 skills")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetMouse", "mouse evolve writes P2 active")
	_check(family.scene_path(2) == "res://Scene/pet/pet_mouse_summon_2.tscn", "mouse scene path")
	var aliases: Array[String] = ["子鼠元帅"]
	family.append_death_aliases(aliases, "子鼠元帅")
	_check(aliases.has("PetMouse") and aliases.has("子鼠大元帅"), "mouse death aliases")

	var alias_level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	var level_aliases: Array[String] = alias_level._active_pet_dead_aliases("子鼠元帅")
	_check(level_aliases.has("PetMouse") and level_aliases.has("子鼠大元帅"), "BaseLevel mouse death aliases")
	alias_level.free()
	var panel: Node = load("res://Scene/pet/pet_interface.tscn").instantiate()
	var panel_aliases: Array[String] = panel._pet_dead_aliases("子鼠大元帅")
	_check(panel_aliases.has("PetMouse") and panel_aliases.has("子鼠元帅"), "PetInterface mouse death aliases")
	panel.free()

	data.player_data["玩家等级"] = 50
	coop.secondary_data.player_data["玩家等级"] = 50
	data.player_data["玩家当前经验"] = 0
	coop.secondary_data.player_data["玩家当前经验"] = 0
	var props: Node = root.get_node("RoleProp")
	props.baseroleprop.Level = 50
	props.baseroleprop.exp = 0
	coop.secondary_props.baseroleprop.Level = 50
	coop.secondary_props.baseroleprop.exp = 0
	var p1_pet := _pet_probe_data("PetMouse", "子鼠元帅", 1000)
	p1_pet["等级"] = 1
	var p2_pet := _pet_probe_data("PetMouse", "子鼠元帅", 1000)
	p2_pet["等级"] = 49
	data.player_data["宠物列表"] = [p1_pet]
	coop.secondary_data.player_data["宠物列表"] = [p2_pet]
	data.player_data["出战宠物"] = "PetMouse"
	coop.secondary_data.player_data["出战宠物"] = "PetMouse"
	var monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster._cure_active_pet_exp(200000, 2)
	_check(int(p2_pet.get("等级", 0)) == 50, "P2 mouse reaches player level")
	_check(int(p2_pet.get("阶段", 0)) == 2, "P2 mouse evolves to stage 2")
	_check(str(p2_pet.get("名称", "")) == "子鼠大元帅", "P2 mouse evolution name")
	_check((p2_pet.get("技能", []) as Array).has("子鼠奥义"), "P2 mouse evolution skills")
	_check(int(p1_pet.get("阶段", 1)) == 1, "P1 mouse untouched by P2 evolution")
	monster.queue_free()
	await process_frame

	p1_pet["等级"] = 50
	p2_pet["等级"] = 50
	stage.queue_free()
	stage = null
	await process_frame
	var level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	stage = level
	coop._on_scene_changed()
	await create_timer(2.0).timeout
	level.can_create = false
	if level.get("create_control") != null:
		level.create_control.stop()
	var p1_unit: Node = _find_pet_unit(level.get("monster"), 1, "pet_mouse_unit")
	var p2_unit: Node = _find_pet_unit(level.get("monster"), 2, "pet_mouse_unit")
	_check(p1_unit != null, "P1 mouse spawned by controller")
	_check(p2_unit != null, "P2 mouse spawned by controller")
	if p1_unit != null:
		_check(int(p1_unit.get("turtle_stage")) == 2, "P1 mouse stage 2")
	if p2_unit != null:
		_check(int(p2_unit.get("turtle_stage")) == 2, "P2 mouse stage 2")
	level.queue_free()
	stage = null
	await process_frame


## 23-2 丑牛族：四阶、阶段技能、升级写回、死亡别名与双槽生成。
func _case_pet_neat() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var family = load("res://Script/pet/pet_neat_family.gd").new()
	var family_pet := _pet_probe_data("PetNeat", "丑牛元帅", 1000)
	family_pet["等级"] = 30
	family_pet["阶段"] = 1
	_check(family.matches(family_pet), "neat family matches type")
	_check(family.matches({"名称": "丑牛大元帅"}), "neat family matches display name")
	_check(not family.matches({"名称": "子鼠元帅"}), "neat family rejects mouse name")
	family.normalize_spawn(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 3, "neat normalize uses level stage")
	_check(str(family_pet.get("名称", "")) == "丑牛元帅", "neat normalize updates display name")
	_check((family_pet.get("技能", []) as Array).has("蛮力践踏"), "neat normalize applies stage 3 skills")
	family_pet["等级"] = 50
	family.evolve(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 4, "neat evolve reaches stage 4")
	_check(str(family_pet.get("名称", "")) == "丑牛大元帅", "neat evolve updates display name")
	_check((family_pet.get("技能", []) as Array).has("丑牛奥义"), "neat evolve applies stage 4 skills")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetNeat", "neat evolve writes P2 active")
	_check(family.scene_path(4) == "res://Scene/pet/pet_neat_summon_4.tscn", "neat scene path")
	var aliases: Array[String] = ["丑牛元帅"]
	family.append_death_aliases(aliases, "丑牛元帅")
	_check(aliases.has("PetNeat") and aliases.has("丑牛大元帅"), "neat death aliases")

	var alias_level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	var level_aliases: Array[String] = alias_level._active_pet_dead_aliases("丑牛元帅")
	_check(level_aliases.has("PetNeat") and level_aliases.has("丑牛大元帅"), "BaseLevel neat death aliases")
	alias_level.free()
	var panel: Node = load("res://Scene/pet/pet_interface.tscn").instantiate()
	var panel_aliases: Array[String] = panel._pet_dead_aliases("丑牛大元帅")
	_check(panel_aliases.has("PetNeat") and panel_aliases.has("丑牛元帅"), "PetInterface neat death aliases")
	panel.free()

	data.player_data["玩家等级"] = 50
	coop.secondary_data.player_data["玩家等级"] = 50
	data.player_data["玩家当前经验"] = 0
	coop.secondary_data.player_data["玩家当前经验"] = 0
	var props: Node = root.get_node("RoleProp")
	props.baseroleprop.Level = 50
	props.baseroleprop.exp = 0
	coop.secondary_props.baseroleprop.Level = 50
	coop.secondary_props.baseroleprop.exp = 0
	var p1_pet := _pet_probe_data("PetNeat", "丑牛元帅", 1000)
	p1_pet["等级"] = 1
	var p2_pet := _pet_probe_data("PetNeat", "丑牛元帅", 1000)
	p2_pet["等级"] = 49
	data.player_data["宠物列表"] = [p1_pet]
	coop.secondary_data.player_data["宠物列表"] = [p2_pet]
	data.player_data["出战宠物"] = "PetNeat"
	coop.secondary_data.player_data["出战宠物"] = "PetNeat"
	var monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster._cure_active_pet_exp(200000, 2)
	_check(int(p2_pet.get("等级", 0)) == 50, "P2 neat reaches player level")
	_check(int(p2_pet.get("阶段", 0)) == 4, "P2 neat evolves to stage 4")
	_check(str(p2_pet.get("名称", "")) == "丑牛大元帅", "P2 neat evolution name")
	_check((p2_pet.get("技能", []) as Array).has("丑牛奥义"), "P2 neat evolution skills")
	_check(int(p1_pet.get("阶段", 1)) == 1, "P1 neat untouched by P2 evolution")
	monster.queue_free()
	await process_frame

	p1_pet["等级"] = 50
	p2_pet["等级"] = 50
	stage.queue_free()
	stage = null
	await process_frame
	var level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	stage = level
	coop._on_scene_changed()
	await create_timer(2.0).timeout
	level.can_create = false
	if level.get("create_control") != null:
		level.create_control.stop()
	var p1_unit: Node = _find_pet_unit(level.get("monster"), 1, "pet_neat_unit")
	var p2_unit: Node = _find_pet_unit(level.get("monster"), 2, "pet_neat_unit")
	_check(p1_unit != null, "P1 neat spawned by controller")
	_check(p2_unit != null, "P2 neat spawned by controller")
	if p1_unit != null:
		_check(int(p1_unit.get("turtle_stage")) == 4, "P1 neat stage 4")
	if p2_unit != null:
		_check(int(p2_unit.get("turtle_stage")) == 4, "P2 neat stage 4")
	level.queue_free()
	stage = null
	await process_frame


## 23-2 寅虎族：四阶、阶段技能、Global 预热、升级写回、死亡别名与双槽生成。
func _case_pet_yin_tiger() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var family = load("res://Script/pet/pet_yin_tiger_family.gd").new()
	var family_pet := _pet_probe_data("PetYinTiger", "寅虎元帅", 1000)
	family_pet["等级"] = 30
	family_pet["阶段"] = 1
	_check(family.matches(family_pet), "yin tiger family matches type")
	_check(family.matches({"名称": "寅虎大元帅"}), "yin tiger family matches display name")
	_check(not family.matches({"名称": "丑牛元帅"}), "yin tiger family rejects neat name")
	family.normalize_spawn(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 3, "yin tiger normalize uses level stage")
	_check(str(family_pet.get("名称", "")) == "寅虎元帅", "yin tiger normalize updates display name")
	_check(not (family_pet.get("技能", []) as Array).has("猛虎下山"), "yin tiger stage 3 keeps base skills")
	_check(int(family_pet.get("生命资质基础上限", 0)) == 2800, "yin tiger normalize sets base stat limits")
	family_pet["等级"] = 50
	family.evolve(family_pet, coop.secondary_data)
	_check(int(family_pet.get("阶段", 0)) == 4, "yin tiger evolve reaches stage 4")
	_check(str(family_pet.get("名称", "")) == "寅虎大元帅", "yin tiger evolve updates display name")
	_check((family_pet.get("技能", []) as Array).has("寅虎奥义"), "yin tiger evolve applies stage 4 skills")
	_check(str(coop.secondary_data.player_data.get("出战宠物", "")) == "PetYinTiger", "yin tiger evolve writes P2 active")
	_check(family.scene_path(4) == "res://Scene/pet/pet_yin_tiger_summon_4.tscn", "yin tiger scene path")
	var aliases: Array[String] = ["寅虎元帅"]
	family.append_death_aliases(aliases, "寅虎元帅")
	_check(aliases.has("PetYinTiger") and aliases.has("寅虎大元帅"), "yin tiger death aliases")

	var alias_level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	var level_aliases: Array[String] = alias_level._active_pet_dead_aliases("寅虎元帅")
	_check(level_aliases.has("PetYinTiger") and level_aliases.has("寅虎大元帅"), "BaseLevel yin tiger death aliases")
	alias_level.free()
	var panel: Node = load("res://Scene/pet/pet_interface.tscn").instantiate()
	var panel_aliases: Array[String] = panel._pet_dead_aliases("寅虎大元帅")
	_check(panel_aliases.has("PetYinTiger") and panel_aliases.has("寅虎元帅"), "PetInterface yin tiger death aliases")
	panel.free()

	data.player_data["玩家等级"] = 50
	coop.secondary_data.player_data["玩家等级"] = 50
	data.player_data["玩家当前经验"] = 0
	coop.secondary_data.player_data["玩家当前经验"] = 0
	var props: Node = root.get_node("RoleProp")
	props.baseroleprop.Level = 50
	props.baseroleprop.exp = 0
	coop.secondary_props.baseroleprop.Level = 50
	coop.secondary_props.baseroleprop.exp = 0
	var p1_pet := _pet_probe_data("PetYinTiger", "寅虎元帅", 1000)
	p1_pet["等级"] = 1
	var p2_pet := _pet_probe_data("PetYinTiger", "寅虎元帅", 1000)
	p2_pet["等级"] = 49
	data.player_data["宠物列表"] = [p1_pet]
	coop.secondary_data.player_data["宠物列表"] = [p2_pet]
	data.player_data["出战宠物"] = "PetYinTiger"
	coop.secondary_data.player_data["出战宠物"] = "PetYinTiger"
	var monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster._cure_active_pet_exp(200000, 2)
	_check(int(p2_pet.get("等级", 0)) == 50, "P2 yin tiger reaches player level")
	_check(int(p2_pet.get("阶段", 0)) == 4, "P2 yin tiger evolves to stage 4")
	_check(str(p2_pet.get("名称", "")) == "寅虎大元帅", "P2 yin tiger evolution name")
	_check((p2_pet.get("技能", []) as Array).has("寅虎奥义"), "P2 yin tiger evolution skills")
	_check(int(p1_pet.get("阶段", 1)) == 1, "P1 yin tiger untouched by P2 evolution")
	monster.queue_free()
	await process_frame

	p1_pet["等级"] = 50
	p2_pet["等级"] = 50
	family.normalize_spawn(p1_pet, data)
	var preload_info: Dictionary = global.get_active_pet_preload_data(1)
	_check(str(preload_info.get("type", "")) == "PetYinTiger", "yin tiger preload type")
	_check(int(preload_info.get("stage", 0)) == 4, "yin tiger preload stage")
	var preload_paths: Array[String] = global.get_active_pet_preload_paths(1)
	_check(preload_paths.has("res://Scene/pet/pet_yin_tiger_summon_4.tscn"), "yin tiger preload scene")
	_check(
		preload_paths.has("res://Art/pet/pet_yin_tiger/model/actions/stage2/yin_tiger_stage2_frames.tres"),
		"yin tiger preload stage 2 frames"
	)
	_check(preload_paths.has("res://Scene/pet/pet_yin_tiger_bullet.tscn"), "yin tiger preload bullet")
	_check(preload_paths.has("res://Art/pet/skillicon/yhaoyi.png"), "yin tiger preload aoyi icon")
	await global.prewarm_active_pet_runtime_resources(1)
	_check(global.get_prewarmed_pet_signature(1) == "PetYinTiger:4", "yin tiger prewarm signature")

	stage.queue_free()
	stage = null
	await process_frame
	var level: Node = load("res://Scene/level/level_1.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	stage = level
	coop._on_scene_changed()
	await create_timer(2.0).timeout
	level.can_create = false
	if level.get("create_control") != null:
		level.create_control.stop()
	var p1_unit: Node = _find_pet_unit(level.get("monster"), 1, "pet_yin_tiger_unit")
	var p2_unit: Node = _find_pet_unit(level.get("monster"), 2, "pet_yin_tiger_unit")
	_check(p1_unit != null, "P1 yin tiger spawned by controller")
	_check(p2_unit != null, "P2 yin tiger spawned by controller")
	if p1_unit != null:
		_check(int(p1_unit.get("turtle_stage")) == 4, "P1 yin tiger stage 4")
	if p2_unit != null:
		_check(int(p2_unit.get("turtle_stage")) == 4, "P2 yin tiger stage 4")
	level.queue_free()
	stage = null
	await process_frame


func _case_shared_soul() -> void:
	coop.create_secondary(7)
	data.set_soul(100)
	coop.secondary_data.add_soul(50)
	_check(data.get_soul() == 150 and coop.secondary_data.get_soul() == 150, "shared soul gain")
	_check(data.spend_soul(100) and coop.secondary_data.get_soul() == 50, "shared soul spend")
	_check(not coop.secondary_data.spend_soul(51), "shared soul insufficient")


## 16-4：槽位查询可枚举、共享账本单写入者、个体状态按槽位归属。
func _case_slot_ledger() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "slot ledger heroes instantiated")
	if p1 == null or p2 == null:
		return

	# 16-4A：槽位查询可枚举且指向唯一所有者。
	var slots: Dictionary = coop.slot_snapshot()
	_check(int(slots.get(1, {}).get("role_id", 0)) == 1, "slot 1 role id")
	_check(int(slots.get(2, {}).get("role_id", 0)) == 7, "slot 2 role id")
	_check(bool(slots.get(1, {}).get("active", false)), "slot 1 active")
	_check(bool(slots.get(2, {}).get("active", false)), "slot 2 active")
	_check(not bool(slots.get(1, {}).get("data_is_secondary", true)), "slot 1 data is primary")
	_check(bool(slots.get(2, {}).get("data_is_secondary", false)), "slot 2 data is secondary")
	_check(bool(slots.get(2, {}).get("props_is_secondary", false)), "slot 2 props is secondary")
	_check(coop.slot_for(p1) == 1 and coop.slot_for(p2) == 2, "hero slot resolution")
	_check(coop.data_for(p2) == coop.secondary_data, "data_for hero slot")
	_check(coop.props_for(p1) == root.get_node("RoleProp"), "props_for 1P hero")
	_check(coop.props_for(p2) == coop.secondary_props, "props_for 2P hero")
	_check(coop.data_for_slot(1) == data and coop.data_for_slot(2) == coop.secondary_data, "slot data owners")

	# 16-4B：共享账本同一容器，写入只发生一次。
	var report: Dictionary = coop.shared_ledger_report()
	for key in coop.shared_keys():
		var entry: Dictionary = report.get(key, {})
		_check(bool(entry.get("same_container", false)), "shared container " + key)
		_check(bool(entry.get("equal", false)), "shared value " + key)
	data.player_data["道具列表"]["页码1"].append({"Name": "shared_probe"})
	_check(coop.secondary_data.player_data["道具列表"]["页码1"].size() == 1, "bag write visible to 2P")
	coop.secondary_data.player_data["装备列表"]["页码1"].append({"Name": "shared_probe_2"})
	_check(data.player_data["装备列表"]["页码1"].size() == 1, "equipment write visible to 1P")
	data.set_soul(200)
	coop.secondary_data.spend_soul(50)
	_check(data.get_soul() == 150 and coop.secondary_data.get_soul() == 150, "shared soul single ledger")
	coop.increment_pellet_count("培元丹1")
	_check(int(data.player_data.get("培元丹1", 0)) == 1, "pellet counted once for 1P")
	_check(int(coop.secondary_data.player_data.get("培元丹1", 0)) == 1, "pellet counted once for 2P")
	data.player_data["被动技能"]["热血"] = 3
	coop.link_passive_skills()
	_check(int(coop.secondary_data.player_data["被动技能"]["热血"]) == 3, "passive shared")
	var training: Dictionary = coop.BODY_TRAINING_DATA.normalize_state(data.player_data.get("炼体", {}))
	training["p1"]["10001"]["level"] = 4
	data.player_data["炼体"] = training
	coop.link_bags()
	_check(int(coop.secondary_data.player_data["炼体"]["p2"]["10001"]["level"]) == 4, "body training shared")
	_check(int(coop.secondary_data.player_data["炼体"]["p1"]["10001"]["level"]) == 4, "body training copy kept in sync")
	# 合并规则：两侧按 max 归并，再同步到 p1/p2 两个视图。
	var secondary_training: Dictionary = coop.BODY_TRAINING_DATA.normalize_state(
		coop.secondary_data.player_data.get("炼体", {})
	)
	secondary_training["p2"]["10001"]["level"] = 7
	coop.secondary_data.player_data["炼体"] = secondary_training
	coop.link_bags()
	var merged_training: Dictionary = data.player_data["炼体"]
	_check(int(merged_training["p1"]["10001"]["level"]) == 7, "body training merges by max")
	_check(int(merged_training["p2"]["10001"]["level"]) == 7, "body training p2 view synced")
	_check(is_same(data.player_data["炼体"], coop.secondary_data.player_data["炼体"]), "body training single container")
	# 重复链接不得重复追加共享容器内容。
	var pack_size: int = data.player_data["宠物背包"].size()
	coop.link_bags()
	coop.link_bags()
	_check(data.player_data["宠物背包"].size() == pack_size, "shared pet backpack stable on relink")

	# 16-4C：个体状态按槽位归属，且 2P 档案不携带共享副本。
	data.player_data["玩家等级"] = 30
	coop.secondary_data.player_data["玩家等级"] = 12
	_check(int(coop.data_for_slot(1).player_data.get("玩家等级", 0)) == 30, "1P level independent")
	_check(int(coop.data_for_slot(2).player_data.get("玩家等级", 0)) == 12, "2P level independent")
	coop.secondary_props.baseroleprop.Level = 12
	coop.secondary_props.cure_exp(10)
	_check(int(data.player_data.get("玩家当前经验", -1)) == 0, "2P exp does not leak to 1P")
	_check(int(coop.secondary_data.player_data.get("玩家当前经验", -1)) == 10, "2P exp written to 2P")
	# 个体项：装备穿戴、出战宠物、技能键位互不串槽。
	_check(
		not is_same(data.player_data["武器"], coop.secondary_data.player_data["武器"]),
		"weapon slots are distinct containers"
	)
	_check(
		not is_same(data.player_data[DataKeys.SKILL_LEARNED], coop.secondary_data.player_data[DataKeys.SKILL_LEARNED]),
		"skill learned slots are distinct containers"
	)
	data.player_data["出战宠物"] = "PetTiger"
	coop.secondary_data.player_data["出战宠物"] = "PetTurtle"
	_check(
		(
			str(coop.data_for_slot(1).player_data.get("出战宠物", "")) == "PetTiger"
			and str(coop.data_for_slot(2).player_data.get("出战宠物", "")) == "PetTurtle"
		),
		"active pet individually owned"
	)
	data.player_data[DataKeys.SKILL_LEARNED][DataKeys.Skill.KEYMAP]["Y"] = "p1_bind"
	coop.secondary_data.player_data[DataKeys.SKILL_LEARNED][DataKeys.Skill.KEYMAP]["Y"] = "p2_bind"
	_check(
		str(coop.data_for_slot(1).player_data[DataKeys.SKILL_LEARNED][DataKeys.Skill.KEYMAP]["Y"]) == "p1_bind",
		"1P skill keybind individually owned"
	)
	_check(
		str(coop.data_for_slot(2).player_data[DataKeys.SKILL_LEARNED][DataKeys.Skill.KEYMAP]["Y"]) == "p2_bind",
		"2P skill keybind individually owned"
	)
	var snapshot: Dictionary = memory._prepare_player_save_data()
	var saved_2p: Dictionary = snapshot.get(coop.SAVE_KEY, {}).get("2P", {})
	for key in coop.shared_keys():
		_check(not saved_2p.has(key), "2P archive strips shared key " + key)
	_check(int(saved_2p.get("玩家等级", 0)) == 12, "2P archive keeps individual level")

	# 16-4D：清空运行期后不残留上一会话槽位。
	coop.clear_runtime()
	_check(coop.data_for_slot(2) == data, "cleared slot 2 falls back to slot 1")
	var cleared: Dictionary = coop.slot_snapshot()
	_check(not bool(cleared.get(2, {}).get("active", true)), "cleared slot 2 inactive")
	_check(coop.shared_ledger_report().is_empty(), "cleared ledger report empty")
	p1.queue_free()
	p2.queue_free()
	await process_frame


## 16-5：面板显式操作者、快照互斥与关闭/暂停恢复。
func _case_panel_operator() -> void:
	coop.create_secondary(7)
	await _make_stage()
	_check(not coop.has_method("suspend_player_view"), "view swap entry removed")
	_check(not coop.has_method("resume_player_view"), "view swap restore removed")

	coop.panel_host.open_panel(2, "背包")
	await process_frame
	await process_frame
	_check(coop.panel_host.has_panel(), "2P panel opens")
	if not coop.panel_host.has_panel():
		return
	var panel: Node = coop.panel_host.current_panel()
	_check(coop.ui_slot == 2, "panel slot is 2P")
	_check(panel.PlayerData == coop.secondary_data, "panel operator is 2P")
	_check(panel.RoleProp == coop.secondary_props, "panel props operator is 2P")
	_check(not is_same(data.player_data, coop.secondary_data.player_data), "global alias not swapped during 2P panel")
	panel.PlayerData.player_data["角色昵称"] = "P2_PANEL"
	_check(str(coop.secondary_data.player_data.get("角色昵称", "")) == "P2_PANEL", "panel write hits 2P")
	_check(str(data.player_data.get("角色昵称", "")) != "P2_PANEL", "panel write does not hit 1P")
	_check(int(coop.panel_host.current_layer().get_meta("coop_slot", 0)) == 2, "panel layer carries slot")
	var selector: Node = panel.get_node_or_null("CoopPlayerSelector")
	_check(
		(
			selector != null
			and selector.get_node_or_null("Player1") != null
			and selector.get_node_or_null("Player2") != null
		),
		"panel builds 1P/2P selector"
	)

	coop.panel_host.switch_panel(1)
	await process_frame
	await process_frame
	_check(coop.ui_slot == 1, "panel switches to 1P")
	_check(
		coop.panel_host.has_panel() and coop.panel_host.current_panel().PlayerData == data, "1P panel operator is 1P"
	)

	# 快照互斥：快照生成期间拒绝打开/切换面板。
	memory._save_snapshot_in_progress = true
	coop.panel_host.close_panel()
	await process_frame
	await process_frame
	coop.panel_host.open_panel(1, "背包")
	await process_frame
	_check(not coop.panel_host.has_panel(), "panel open blocked during snapshot")
	memory._save_snapshot_in_progress = false
	_check(not memory.is_save_snapshot_in_progress(), "snapshot flag cleared")

	coop.panel_host.open_panel(1, "背包")
	await process_frame
	await process_frame
	_check(coop.panel_host.has_panel(), "panel reopens after snapshot")
	_check(paused, "panel pauses tree")
	var layer: Node = coop.panel_host.current_layer()
	_check(global.get_ui_runtime().windows == layer, "windows points to panel layer")
	coop.panel_host.close_panel()
	await process_frame
	await process_frame
	_check(not coop.panel_host.has_panel(), "panel closed")
	_check(not paused, "tree unpaused after close")
	_check(
		global.get_ui_runtime().windows == null,
		"windows restored after close [" + str(global.get_ui_runtime().windows) + "]"
	)
	_check(coop.ui_slot == 1, "ui slot reset after close")

	# 24-1：宠物属性页子控制器与 P2 操作者。
	coop.panel_host.open_panel(2, "宠物")
	await process_frame
	await process_frame
	_check(coop.panel_host.has_panel(), "pet panel opens")
	if coop.panel_host.has_panel():
		var pet_panel: Node = coop.panel_host.current_panel()
		_check(pet_panel.PlayerData == coop.secondary_data, "pet panel operator is 2P")
		var attribute_pages: Node = pet_panel.get_node_or_null("PetAttributePages")
		_check(
			attribute_pages != null and attribute_pages.has_method("select_page"),
			"pet attribute pages controller present"
		)
		if attribute_pages != null:
			attribute_pages.call("select_page", 1)
			await process_frame
			_check(int(attribute_pages.get("page_index")) == 1, "pet attribute page switches")
			var row6: CanvasItem = pet_panel.get_node_or_null("PetAttributePages/StatRow6") as CanvasItem
			var row7: CanvasItem = pet_panel.get_node_or_null("PetAttributePages/StatRow7") as CanvasItem
			_check(row6 != null and row6.visible, "page 2 shows row 6")
			_check(row7 != null and not row7.visible, "page 2 hides row 7")
		coop.panel_host.close_panel()
		await process_frame
		await process_frame
		_check(not coop.panel_host.has_panel(), "pet panel closed")

	# 24-2：会话清理必须关闭面板、恢复暂停与窗口栈。
	coop.panel_host.open_panel(1, "背包")
	await process_frame
	await process_frame
	_check(coop.panel_host.has_panel() and paused, "clear fixture panel open")
	coop.clear_runtime()
	await process_frame
	await process_frame
	_check(not coop.panel_host.has_panel(), "clear closes panel")
	_check(not paused, "clear restores pause")
	_check(global.get_ui_runtime().windows == null, "clear restores windows")
	_check(coop.ui_slot == 1, "clear resets ui slot")


func _case_skill_keys() -> void:
	coop.create_secondary(7)
	_check(InputMap.has_action("p2_slz"), "P2 normal attack mapping")
	_check(InputMap.has_action("p2_技能"), "P2 skill mapping")
	_check(InputMap.has_action("p2_MagicWeapon"), "P2 magic mapping")
	var input: Object = coop.input_for(coop.secondary_data)
	Input.action_press("p2_move_right")
	_check(input.is_action_pressed("move_right"), "P2 input view responds")
	Input.action_release("p2_move_right")


func _case_switch_passive() -> void:
	coop.create_secondary(7)
	coop.refresh_passive_skills()
	_check(is_instance_valid(coop.secondary_passives), "secondary passive runtime exists")
	_check(coop.props_for(coop.secondary_data) == coop.secondary_props, "secondary passive props owner")


func _case_sword_mount() -> void:
	coop.create_secondary(7)
	data.player_data["通天教主"] = 1
	coop.secondary_data.player_data["通天教主"] = 0
	_check(coop.secondary_data.is_mount_system_unlocked(), "P2 uses host mount unlock")
	coop.refresh_main_sword_array()
	_check(coop.secondary_data.has_method("get_main_sword_array_level"), "P2 sword profile available")


func _case_creation_ui() -> void:
	coop.creation_player_count = 2
	var selection: Node = load("res://Scene/main_menu/choose_player.tscn").instantiate()
	root.add_child(selection)
	current_scene = selection
	stage = selection
	await process_frame
	var role7: Control = selection.role_cards.get_node_or_null("Role7")
	_check(role7 != null, "role7 exists")
	if role7 != null:
		_check(role7.get_index() == 5, "role7 official display order")
		_check(role7.custom_minimum_size.is_equal_approx(Vector2(130, 530)), "role7 official card size")
	selection.set_role(1)
	selection.set_role(7)
	_check(selection.selected_roles == [1, 7], "coop role selection")
	_check(not selection.start_button.disabled, "coop start enabled")
	selection.queue_free()
	await process_frame
	stage = null
	coop.creation_player_count = 1


func _case_attribution_sources() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "attribution owners instantiated")
	if p1 == null or p2 == null:
		return
	var monster: Node = load("res://Scene/monster/monster_139.tscn").instantiate()
	monster.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster.hp = 1000000
	monster.max_hp = 1000000
	monster.get_player = p1
	monster.get_target = p1
	var role_prop: Node = root.get_node("RoleProp")
	role_prop.source_player = p1
	var orphan := Area2D.new()
	_check(monster._get_damage_source_player(orphan) == null, "source-less hit does not fall back to global P1")
	orphan.free()

	data.player_data["腾蛇阵"]["Level"] = 1
	coop.secondary_data.player_data["腾蛇阵"]["Level"] = 4
	data.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] = 1
	coop.secondary_data.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] = 6
	p1.RoleProp.roleprop["vampirism"] = 0.1
	p2.RoleProp.roleprop["vampirism"] = 0.5
	_check(is_equal_approx(monster._get_vampirism_rate(p2), 0.5), "vampirism reads P2 props")
	_check(monster._get_tszz_level(p2) == 4, "tsz reads P2 profile")
	_check(monster._get_role5_skill_level(p2) == 6, "role5 skill reads P2 profile")

	var hit := {"WSValue": 7, "power": 0, "hurtBack": [0, 0], "attackKind": "real"}
	p1.RoleProp.ws_value = 0
	p2.RoleProp.ws_value = 0
	var melee_hitbox: Area2D = p2.get_node("base_damagebox/HitBox")
	var old_get_player: Node = monster.get_player
	var old_damage_slot := int(monster.get_meta("coop_damage_slot", 0))
	var old_props_source: Variant = p2.RoleProp.source_player
	monster._on_hurt_box_area_entered(melee_hitbox)
	_check(p1.RoleProp.ws_value == 0, "P2 melee leaves P1 WS unchanged")
	_check(p2.RoleProp.ws_value > 0, "P2 melee credits P2 WS")
	_check(monster.get_player == old_get_player, "hit restores monster get_player")
	_check(int(monster.get_meta("coop_damage_slot", 0)) == old_damage_slot, "hit restores damage slot")
	_check(p2.RoleProp.source_player == old_props_source, "hit restores source props")

	var settings: Node = root.get_node("MainSet")
	settings.set_data["ShowDamageText"] = true
	var old_text: Node = global.add_damage_text(stage, Vector2.ZERO, 111, "physics", false, p1)
	_check(old_text != null, "damage text pooled node created")
	if old_text != null:
		old_text.recycle()
		var new_text: Node = global.add_damage_text(stage, Vector2.ZERO, 222, "magic", true, p2)
		_check(new_text != null, "damage text reused from pool")
		if new_text != null:
			_check(new_text.damage_value == 222, "pooled text resets value")
			_check(new_text.type == "magic", "pooled text resets type")
			_check(new_text.is_crit, "pooled text resets crit flag")
			_check(new_text.target == p2, "pooled text resets target")
			new_text.recycle()

	p1.RoleProp.ws_value = 0
	p2.RoleProp.ws_value = 0
	var skill_bullet: Node = global.add_role_bullet_1(p2.bullet, Vector2.ZERO, "probe_skill", hit.duplicate(true))
	_check(skill_bullet != null and skill_bullet.player == p2, "skill bullet carries P2 source")
	if skill_bullet != null:
		skill_bullet.is_set = true
		skill_bullet.set_physics_process(false)
		await process_frame
		monster._on_hurt_box_area_entered(skill_bullet)
		_check(p1.RoleProp.ws_value == 0, "P2 skill leaves P1 WS unchanged")
		_check(p2.RoleProp.ws_value > 0, "P2 skill credits P2 WS")

	var buff_area := Area2D.new()
	monster.add_child(buff_area)
	var buff_bullet: Node = (
		global
		. add_role_bullet(
			stage,
			Vector2(180, 340),
			false,
			"SMSRBullet",
			{
				"power": 0,
				"hurtBack": [0, 0],
				"attackKind": "real",
				"addeffect": {"Name": "probe_coop_buff", "AddTime": 5.0, "reduce_interval": 0, "value": 0.0},
			},
			p2
		)
	)
	_check(buff_bullet != null and buff_bullet.player == p2, "buff bullet carries P2 source")
	if buff_bullet != null:
		await process_frame
		buff_bullet._on_hit_box_area_entered(buff_area)
		await process_frame
		var has_buff := false
		for buff_child in monster.buff.get_children():
			var info: Variant = buff_child.get("buff_info")
			if info is Dictionary and str(info.get("Name", "")) == "probe_coop_buff":
				has_buff = true
				break
		_check(has_buff, "P2 bullet addeffect lands on target")
	buff_area.queue_free()

	p1.RoleProp.ws_value = 0
	p2.RoleProp.ws_value = 0
	var root_bullet: Node = global.add_role_bullet(
		stage, Vector2(200, 340), false, "Role2Bullet1", hit.duplicate(true), p2
	)
	_check(root_bullet != null, "root bullet created with explicit source")
	if root_bullet != null:
		_check(root_bullet.player == p2, "root bullet carries P2 source")
		_check(int(root_bullet.get_meta("coop_slot", 0)) == 2, "root bullet carries P2 slot")
		await process_frame
		var root_hit_area: Area2D = root_bullet.get_node("Middle/HitBox")
		monster._on_hurt_box_area_entered(root_hit_area)
		_check(p1.RoleProp.ws_value == 0, "root bullet leaves P1 WS unchanged")
		_check(p2.RoleProp.ws_value > 0, "root bullet credits P2 WS")

	var summon: Node = load("res://Scene/monster/monster_zhw/monster_143_zhw.tscn").instantiate()
	summon.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(summon)
	await process_frame
	summon.set_physics_process(false)
	summon.set_summon_properties(p2, 0.0)
	_check(coop.owner_hero(summon) == p2, "summon owner resolves to P2")
	_check(coop.slot_for(summon) == 2, "summon slot resolves to P2")
	_check(int(summon.get_meta("coop_slot", 0)) == 2, "summon carries P2 slot")
	_check(monster._get_damage_source_player(summon) == p2, "summon damage source resolves to P2")

	var ownerless_host := Node2D.new()
	stage.add_child(ownerless_host)
	var ownerless_summon: Node = load("res://Scene/monster/monster_zhw/monster_143_zhw.tscn").instantiate()
	ownerless_summon.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(ownerless_summon)
	await process_frame
	ownerless_summon.set_physics_process(false)
	ownerless_summon.set_summon_properties(ownerless_host, 0.0)
	_check(ownerless_summon.player_reference == null, "ownerless summon does not borrow 1P")
	ownerless_summon.queue_free()
	ownerless_host.queue_free()

	var weapon: Node = global.add_magic_weapon(stage, "qlsword", Vector2(300, 340), p2)
	_check(weapon != null, "magic weapon created with explicit source")
	if weapon != null:
		_check(weapon.player == p2, "magic weapon carries P2 source")
		_check(int(weapon.get_meta("coop_slot", 0)) == 2, "magic weapon carries P2 slot")
		_check(monster._get_damage_source_player(weapon) == p2, "magic weapon damage source resolves to P2")
		p1.RoleProp.ws_value = 0
		p2.RoleProp.ws_value = 0
		weapon.hit_dic = {"power": 10, "hurtBack": [0, 0], "attackKind": "real", "WSValue": 3}
		monster.apply_role_hit(weapon)
		_check(p1.RoleProp.ws_value == 0, "P2 magic weapon leaves P1 WS unchanged")
		_check(p2.RoleProp.ws_value > 0, "P2 magic weapon credits P2 WS")
		var weapon_summon: Node = load("res://Scene/monster/monster_zhw/monster_143_zhw.tscn").instantiate()
		weapon_summon.process_mode = Node.PROCESS_MODE_DISABLED
		stage.add_child(weapon_summon)
		await process_frame
		weapon_summon.set_physics_process(false)
		weapon_summon.set_summon_properties(weapon, 0.0)
		_check(weapon_summon.player_reference == p2, "non-hero summon follows weapon owner P2")
		weapon_summon.queue_free()

	var shallow: Node = global.add_role1_shallow(stage, Vector2(220, 340), 1, 1, p2)
	_check(shallow != null and shallow.player == p2, "shallow carries P2 source")
	if shallow != null:
		_check(monster._get_damage_source_player(shallow) == p2, "shallow damage source resolves to P2")

	p1.RoleProp.ws_value = 0
	p2.RoleProp.ws_value = 0
	var p1_hitbox: Area2D = p1.get_node("base_damagebox/HitBox")
	monster._on_hurt_box_area_entered(p1_hitbox)
	_check(p1.RoleProp.ws_value > 0, "P1 melee credits P1 WS")
	_check(p2.RoleProp.ws_value == 0, "P1 melee leaves P2 WS unchanged")

	root_bullet = null
	summon.queue_free()
	monster.queue_free()
	await process_frame


func _set_probe_attack(hero: Node, crit: int, ar: int, level: int, attack_kind: String) -> void:
	hero.RoleProp.roleprop["htarget"] = 0
	hero.RoleProp.roleprop["Crit"] = crit
	hero.RoleProp.roleprop["ar"] = ar
	hero.RoleProp.roleprop["sp"] = 0
	hero.RoleProp.roleprop["Lucky"] = 0
	hero.RoleProp.baseroleprop.Level = level
	hero.hit_dic = {"power": 100, "hurtBack": [0, 0], "attackKind": attack_kind}


func _case_damage_stats() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "damage stats owners instantiated")
	if p1 == null or p2 == null:
		return
	var monster: Node = load("res://Scene/monster/monster_139.tscn").instantiate()
	monster.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster.level = 1
	monster.def = 100
	monster.mdef = 100
	monster.crit_reduce = 0
	monster.toughness = 0
	monster.is_defe_reduce = false
	monster.hp = 1000000
	monster.max_hp = 1000000

	_set_probe_attack(p1, 0, 0, 1, "real")
	monster.get_player = p1
	var p1_real: int = monster.get_role_last_hurt(p1)
	_check(p1_real == 100 and not monster.is_crit, "P1 real damage baseline")
	_set_probe_attack(p2, 1000000000, 0, 1, "real")
	monster.get_player = p2
	var p2_crit: int = monster.get_role_last_hurt(p2)
	_check(monster.is_crit, "P2 crit uses P2 Crit")
	_check(p2_crit >= 190, "P2 crit damage separated")

	_set_probe_attack(p1, 0, 0, 1, "physics")
	monster.get_player = p1
	var p1_armor: int = monster.get_role_last_hurt(p1)
	_set_probe_attack(p2, 0, 100, 1, "physics")
	monster.get_player = p2
	var p2_armor: int = monster.get_role_last_hurt(p2)
	_check(p1_armor == 50 and p2_armor == 100, "P2 armor penetration uses P2 ar")

	_set_probe_attack(p1, 0, 0, 1, "real")
	monster.get_player = p1
	var p1_level: int = monster.get_role_last_hurt(p1)
	_set_probe_attack(p2, 0, 0, 100, "real")
	monster.get_player = p2
	var p2_level: int = monster.get_role_last_hurt(p2)
	_check(p1_level == 100 and p2_level == 110, "P2 level suppression uses P2 level")

	p1.RoleProp.roleprop.damage_bonus = 0.0
	p2.RoleProp.roleprop.damage_bonus = 0.5
	monster.hp = 1000000
	monster.hd = 0
	monster.ws_hd = true
	monster.damage_reduction = 0.0
	var p1_damage: int = monster.hurt_reduce_hp(100, p1)
	var p2_damage: int = monster.hurt_reduce_hp(100, p2)
	_check(p1_damage == 75 and p2_damage == 125, "damage_bonus reads actual attacker")

	monster.queue_free()
	await process_frame


func _case_pool_reuse() -> void:
	await _make_stage()
	var settings: Node = root.get_node("MainSet")
	settings.set_data["ShowDamageText"] = true
	settings.set_data["RoleOrMonsterHit"] = true
	var monster: Node = load("res://Scene/monster/monster_139.tscn").instantiate()
	monster.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)

	var mr: Node = global.add_mr_hurt(monster, Vector2.ZERO)
	_check(mr != null, "mr_hurt taken from pool")
	if mr != null:
		_check(not mr._recycled and mr.visible, "mr_hurt active")
		mr.recycle()
		_check(mr._recycled and not mr.visible and not mr.animation_player.is_playing(), "mr_hurt cleaned on return")
		await create_timer(0.06).timeout
		var mr2: Node = global.add_mr_hurt(monster, Vector2.ZERO)
		_check(mr2 == mr, "mr_hurt reused from pool")
		if mr2 != null:
			_check(
				not mr2._recycled and mr2.visible and mr2.animation_player.is_playing(), "mr_hurt replayed after reuse"
			)
			mr2.recycle()

	var rh: Node = global.add_special_effect(monster, Vector2.ZERO, "RoleBeHit", Vector2.ONE, false, 1.0)
	_check(rh != null, "role_be_hit taken from pool")
	if rh != null:
		_check(not rh._recycled and rh.visible and rh.is_playing(), "role_be_hit active")
		rh.recycle()
		_check(rh._recycled and not rh.visible and not rh.is_playing(), "role_be_hit cleaned on return")
		var rh2: Node = global.add_special_effect(monster, Vector2.ZERO, "RoleBeHit", Vector2.ONE, false, 1.0)
		_check(rh2 == rh, "role_be_hit reused from pool")
		if rh2 != null:
			_check(not rh2._recycled and rh2.visible and rh2.is_playing(), "role_be_hit replayed after reuse")
			rh2.recycle()

	var path_one := "res://Music/monster_hurt/6_beattack_by_role1.mp3"
	var path_two := "res://Music/hero/9_beattack_by_role2.mp3"
	var sound_one: Node = global.get_audio_runtime().add_sound(monster, path_one)
	_check(sound_one != null, "sound_player taken from pool")
	if sound_one != null:
		_check(sound_one.is_set and sound_one.stream != null and sound_one.playing, "sound_player active")
		sound_one._on_finished()
		_check(
			not sound_one.is_set and sound_one.stream == null and sound_one.target == null,
			"sound_player cleaned on finish"
		)
		var sound_two: Node = global.get_audio_runtime().add_sound(monster, path_two)
		_check(sound_two == sound_one, "sound_player reused from pool")
		if sound_two != null:
			_check(
				sound_two.is_set and sound_two.target == path_two and sound_two.stream != null,
				"sound_player setup with new target"
			)
			sound_two._on_finished()

	monster.queue_free()
	await process_frame


func _case_wushuang_attribution() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "WS attribution owners instantiated")
	if p1 == null or p2 == null:
		return
	var monster: Node = load("res://Scene/monster/monster_139.tscn").instantiate()
	monster.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(monster)
	await process_frame
	var hit := {"WSValue": 7, "power": 0, "hurtBack": [0, 0], "attackKind": "real"}
	p1.RoleProp.ws_value = 0
	p2.RoleProp.ws_value = 0
	var melee_hitbox: Area2D = p2.get_node("base_damagebox/HitBox")
	monster.get_player = p1
	monster._on_hurt_box_area_entered(melee_hitbox)
	_check(p1.RoleProp.ws_value == 0, "P2 melee does not credit P1 WS")
	_check(p2.RoleProp.ws_value > 0, "P2 melee credits P2 WS")

	var bullet: Node = load("res://Script/hero/role_bullet_1.gd").new()
	bullet._name = "probe"
	bullet.hit_dic = hit
	bullet.player = p2
	bullet.is_set = true
	var bullet_an := AnimatedSprite2D.new()
	bullet_an.name = "BulletAN"
	bullet.add_child(bullet_an)
	var bullet_player := AnimationPlayer.new()
	bullet_player.name = "BulletPlayer"
	bullet.add_child(bullet_player)
	bullet.set_physics_process(false)
	p2.bullet.add_child(bullet)
	await process_frame
	p1.RoleProp.ws_value = 0
	p2.RoleProp.ws_value = 0
	monster.remove_meta("coop_damage_slot")
	monster.get_player = p1
	monster.get_target = p1
	monster._on_hurt_box_area_entered(bullet)
	_check(p1.RoleProp.ws_value == 0, "P2 projectile does not credit P1 WS")
	_check(p2.RoleProp.ws_value == 7, "P2 projectile credits P2 WS")

	p1.RoleProp.ws_value = 0
	p2.RoleProp.ws_value = 0
	monster.get_player = p2
	monster.get_target = p2
	monster.cure_ws_value(p2)
	_check(p1.RoleProp.ws_value == 0, "explicit P2 WS owner leaves P1 unchanged")
	_check(p2.RoleProp.ws_value > 0, "explicit P2 WS owner credits P2")

	p1.RoleProp.ws_value = 0
	p2.RoleProp.ws_value = 0
	monster.get_player = p1
	monster.get_target = p1
	var damage_source_state: Dictionary = monster.bind_role_damage_source(p2)
	monster.cure_ws_value()
	monster.unbind_role_damage_source(damage_source_state)
	_check(p1.RoleProp.ws_value == 0, "bound P2 source leaves P1 WS unchanged")
	_check(p2.RoleProp.ws_value > 0, "bound P2 source credits P2 WS")
	monster.queue_free()
	await process_frame


func _case_role4_poison() -> void:
	coop.create_secondary(4)
	await _make_stage()
	var p1: Node = _make_hero(4, 1)
	var p2: Node = _make_hero(4, 2)
	await process_frame
	_check(p1 != null and p2 != null, "role4 poison owners instantiated")
	if p1 == null or p2 == null:
		return
	_set_role4_poison_stats(p1, 100, 1)
	_set_role4_poison_stats(p2, 300, 1)
	if not p1.PlayerData.player_data.has(DataKeys.Skill.AWAKENED):
		p1.PlayerData.player_data[DataKeys.Skill.AWAKENED] = {}
	if not p2.PlayerData.player_data.has(DataKeys.Skill.AWAKENED):
		p2.PlayerData.player_data[DataKeys.Skill.AWAKENED] = {}
	var p1_awaken: Dictionary = p1.PlayerData.player_data[DataKeys.Skill.AWAKENED]
	var p2_awaken: Dictionary = p2.PlayerData.player_data[DataKeys.Skill.AWAKENED]
	p1_awaken["mds"] = false
	p2_awaken["mds"] = true

	var monster: Node = load("res://Scene/monster/monster_139.tscn").instantiate()
	monster.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster.hp = 100000
	monster.max_hp = 100000
	monster.hd = 0
	monster.ws_hd = true
	monster.damage_reduction = 0
	monster.def = 0
	monster.mdef = 0
	monster.is_boss = false
	_check(not monster._is_mds_awaken_active(p1), "P1 MDS awakening is source-local")
	_check(monster._is_mds_awaken_active(p2), "P2 MDS awakening is source-local")

	await _add_voodoo_stacks(monster, p1, 6)
	await _add_voodoo_stacks(monster, p2, 1)
	monster.wd_hurt()
	_check(monster.hp == 100000, "mixed stacks below seven do not burst")
	await _add_voodoo_stacks(monster, p1, 1)
	p1.RoleProp.roleprop.power = 100
	p2.RoleProp.roleprop.power = 300
	monster.wd_hurt()
	var reduction: float = 1.0 - float(monster.damage_reduction)
	var p1_expected := int(int(7 * (int(p1.RoleProp.roleprop.power) * 0.55)) * reduction)
	_check(monster.hp == 100000 - p1_expected, "P1 poison burst uses P1 power")
	_check(_probe_check_wd(monster, p1) == 0, "P1 burst removes only P1 stacks")
	_check(_probe_check_wd(monster, p2) == 1, "P2 stack survives P1 burst")

	await _add_voodoo_stacks(monster, p2, 6)
	p1.RoleProp.roleprop.power = 100
	p2.RoleProp.roleprop.power = 300
	monster.wd_hurt()
	var p2_expected := int(int(7 * (int(p2.RoleProp.roleprop.power) * 0.55)) * reduction)
	_check(monster.hp == 100000 - p1_expected - p2_expected, "P2 poison burst uses P2 power")
	_check(_probe_check_wd(monster, p2) == 0, "P2 burst removes only P2 stacks")

	monster.queue_free()
	await process_frame


func _set_role4_poison_stats(hero: Node, power: int, skill_level: int) -> void:
	hero.PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] = skill_level
	hero.RoleProp.roleprop.power = power
	hero.RoleProp.roleprop.damage_bonus = 0


func _add_voodoo_stacks(monster: Node, source_player: Node, count: int) -> void:
	for _index in range(count):
		var added: Variant = global.add_buff(
			monster.buff,
			{
				"Name": "Voodoo",
				"AddTime": 5,
				"reduce_interval": 1,
				"value": 0,
				"CanAdd": true,
				"AttackKind": "real",
				"DeBuff": true,
				"source_player": source_player
			}
		)
		_check(added != null, "voodoo buff created")
	await process_frame


func _probe_check_wd(monster: Node, source_player: Node) -> int:
	return int(global.call("check_wd", monster, source_player))


func _case_all_dead() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "all-dead owners instantiated")
	if p1 == null or p2 == null:
		return
	var paths: Array[String] = []
	p1.is_death = true
	coop.scene_change_override = func(path: String) -> bool:
		paths.append(path)
		return true
	_check(not coop.request_defeat_if_all_players_dead(), "one death does not request defeat")
	p2.is_death = true
	_check(coop.request_defeat_if_all_players_dead(), "both deaths request defeat")
	_check(not coop.request_defeat_if_all_players_dead(), "duplicate all-dead request is ignored")
	_check(paths.size() == 1 and paths[0] == "res://Scene/level/defeat.tscn", "defeat scene requested once")

	coop.clear_runtime()
	await _make_stage()
	p1 = _make_hero(1, 1)
	p2 = _make_hero(7, 2)
	paths.clear()
	p1.is_death = true
	p2.is_death = true
	coop.scene_change_override = func(_path: String) -> bool: return false
	_check(not coop.request_defeat_if_all_players_dead(), "failed scene change is not committed")
	coop.scene_change_override = func(path: String) -> bool:
		paths.append(path)
		return true
	_check(coop.request_defeat_if_all_players_dead(), "failed request can retry")
	_check(paths.size() == 1, "retry requests scene once")
	coop.scene_change_override = Callable()


func _action_has_physical_key(action: StringName, key: int) -> bool:
	if not InputMap.has_action(action):
		return false
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and int(event.physical_keycode) == key:
			return true
	return false


func _probe_has_property(node: Object, property_name: String) -> bool:
	for property: Dictionary in node.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false


func _auto_battle_context_for(hero: Node) -> Object:
	if _probe_has_property(hero, "auto_battle_context"):
		var existing: Variant = hero.get("auto_battle_context")
		if existing != null:
			return existing
	var context_script: Script = load("res://Script/base/auto_battle_context.gd")
	return context_script.new(hero)


func _auto_battle_controller_for(hero: Node) -> Object:
	if _probe_has_property(hero, "auto_battle_controller"):
		var existing: Variant = hero.get("auto_battle_controller")
		if existing != null:
			return existing
	var controller_script: Script = load("res://Script/base/auto_battle_controller.gd")
	return controller_script.new(_auto_battle_context_for(hero))


## 25-1：目标缓存/移动、配置槽位隔离、关闭清理与游标计数。
func _case_auto_battle() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var settings: Node = root.get_node("MainSet")
	var old_enabled: bool = settings.is_auto_battle_enabled()
	var old_skill_only: Variant = settings.set_data.get("AutoBattleSkillOnly", false)
	var old_by_slot: Variant = settings.set_data.get("AutoBattleSkillsBySlot", {})
	var old_magic: Variant = settings.set_data.get("AutoBattleMagicWeapon", false)
	var old_sword: Variant = settings.set_data.get("AutoBattleSwordArray", false)
	var old_wushuang: Variant = settings.set_data.get("AutoBattleWushuang", false)
	settings.set_auto_battle_enabled(false)
	settings.set_data["AutoBattleSkillOnly"] = false
	settings.set_data["AutoBattleMagicWeapon"] = false
	settings.set_data["AutoBattleSwordArray"] = false
	settings.set_data["AutoBattleWushuang"] = false
	settings.set_data["AutoBattleSkillsBySlot"] = {
		"1": {"角色1": [{"id": "slz", "count": 2}, {"id": "zz", "count": 1}]},
		"2": {"角色7": [{"id": "yt_ldmw", "count": 3}]},
	}
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "auto battle owners instantiated")
	if p1 == null or p2 == null:
		return
	p1.set_physics_process(false)
	p2.set_physics_process(false)
	p1.set_process(false)
	p2.set_process(false)
	var context1: Object = _auto_battle_context_for(p1)
	var context2: Object = _auto_battle_context_for(p2)
	var entries1: Array = context1.get_skill_entries()
	var entries2: Array = context2.get_skill_entries()
	_check(entries1.size() == 2 and str(entries1[0].get("id", "")) == "slz", "P1 slot skills isolated")
	_check(entries2.size() == 1 and str(entries2[0].get("id", "")) == "yt_ldmw", "P2 slot skills isolated")
	_check(int(entries1[0].get("count", 0)) == 2, "P1 skill count retained")

	var controller: Object = _auto_battle_controller_for(p1)
	if _probe_has_property(p1, "auto_battle_controller"):
		var production_controller: Variant = p1.get("auto_battle_controller")
		_check(production_controller == controller, "BaseHero owns controller")

	settings.set_data["AutoBattleSkillsBySlot"] = {
		"1": {"角色1": []},
		"2": {"角色7": [{"id": "yt_ldmw", "count": 3}]},
	}
	var monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	monster.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(monster)
	await process_frame
	monster.set_physics_process(false)
	monster.hp = 1000000
	monster.max_hp = 1000000
	monster.global_position = Vector2(700, 340)
	if not monster.is_in_group("monsters"):
		monster.add_to_group("monsters")

	settings.set_auto_battle_enabled(true)
	controller.reset()
	controller.advance_timers(1.0)
	controller.tick(0.22)
	_check(controller.get_target() == monster, "auto target cached")
	controller.process_movement()
	_check(p1.velocity.x > 0.0, "auto moves toward distant target")
	_check(bool(p1.player_dir), "auto faces target direction")

	monster.global_position = Vector2(180, 340)
	controller.tick(0.22)
	controller.process_movement()
	_check(controller.get_target() == monster, "in-range target retained")
	_check(is_zero_approx(p1.velocity.x), "auto stops inside attack range")

	monster.queue_free()
	await process_frame
	controller.tick(0.22)
	_check(controller.get_target() == null, "dead target cleared")

	settings.set_auto_battle_enabled(false)
	controller.tick(0.22)
	_check(controller.get_target() == null, "disable clears target")
	_check(controller.get_skill_cursor() == 0, "disable clears cursor")
	_check(controller.get_skill_cast_counts().is_empty(), "disable clears cast counts")
	_check(is_zero_approx(controller.get_elapsed()), "disable clears cadence")

	var skill_hero: Node = _make_hero(1, 1)
	_check(skill_hero != null, "auto battle skill owner instantiated")
	if skill_hero == null:
		return
	skill_hero.set_physics_process(false)
	skill_hero.set_process(false)
	settings.set_data["AutoBattleSkillOnly"] = true
	settings.set_data["AutoBattleSkillsBySlot"] = {
		"1": {"角色1": [{"id": "slz", "count": 2}]},
	}
	data.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["Y"] = "slz"
	skill_hero.RoleProp.roleprop.Mp = skill_hero.RoleProp.roleprop.SMp
	var skill_controller: Object = _auto_battle_controller_for(skill_hero)
	settings.set_auto_battle_enabled(true)
	skill_controller.reset()
	skill_controller.tick(0.22)
	_check(
		float(skill_hero.role1_skill_inter.get("slz", 0.0)) > 0.0, "real skill starts through controller"
	)
	_check(
		int(skill_controller.get_skill_cast_counts().get("slz", 0)) == 1, "skill cast count tracks start"
	)
	skill_hero.is_using_skills = false
	skill_hero.is_attacking = false
	skill_hero.get_action = "wait"
	skill_hero.role1_skill_inter["slz"] = 0.0
	skill_hero.RoleProp.roleprop.Mp = skill_hero.RoleProp.roleprop.SMp
	skill_hero.role_action_player.stop()
	skill_controller.tick(0.22)
	_check(
		skill_controller.get_skill_cast_counts().is_empty(), "skill count clears after required casts"
	)
	_check(skill_controller.get_skill_cursor() == 0, "skill cursor wraps after count")
	skill_controller.reset()
	_check(skill_controller.get_target() == null and skill_controller.get_skill_cursor() == 0, "reset clears state")

	settings.set_data["AutoBattleWushuang"] = true
	settings.set_data["AutoBattleSkillOnly"] = true
	skill_hero.RoleProp.is_ws_state = false
	skill_hero.RoleProp.ws_value = skill_hero.RoleProp.max_ws_value
	skill_hero.role1_skill_inter["slz"] = 0.0
	skill_controller.reset()
	skill_controller.tick(0.22)
	_check(skill_hero.RoleProp.is_ws_state, "auto wushuang triggers before skill")
	_check(is_zero_approx(float(skill_hero.role1_skill_inter.get("slz", 0.0))), "wushuang short-circuits skill")
	settings.set_data["AutoBattleWushuang"] = false
	skill_hero.RoleProp.is_ws_state = false

	var live_hero: Node = _make_hero(1, 1)
	_check(live_hero != null, "live auto battle owner instantiated")
	if live_hero == null:
		return
	var live_monster: Node = load("res://Scene/monster/monster_1.tscn").instantiate()
	live_monster.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(live_monster)
	await process_frame
	live_monster.set_physics_process(false)
	live_monster.hp = 1000000
	live_monster.max_hp = 1000000
	live_monster.global_position = Vector2(700, 340)
	if not live_monster.is_in_group("monsters"):
		live_monster.add_to_group("monsters")
	settings.set_data["AutoBattleSkillOnly"] = false
	settings.set_data["AutoBattleSkillsBySlot"] = {"1": {"角色1": []}, "2": {"角色7": []}}
	settings.set_auto_battle_enabled(true)
	var live_controller: Object = live_hero.auto_battle_controller
	_check(live_controller != null, "live BaseHero auto controller")
	for _frame in 30:
		await physics_frame
		if live_controller.get_target() == live_monster and live_hero.velocity.x > 0.0:
			break
	_check(live_controller.get_target() == live_monster, "live physics selects target")
	_check(live_hero.velocity.x > 0.0, "live physics auto-moves")

	p2.set_physics_process(true)
	p2.set_process(true)
	for _frame in 30:
		await physics_frame
		if p2.auto_battle_controller.get_target() == live_monster and p2.velocity.x > 0.0:
			break
	_check(p2.auto_battle_controller.get_target() == live_monster, "P2 physics selects target")
	_check(p2.velocity.x > 0.0, "P2 physics auto-moves")

	settings.set_auto_battle_enabled(false)
	await physics_frame
	await physics_frame
	_check(absf(live_hero.velocity.x) < 1.0, "live physics stops after disable")
	_check(absf(p2.velocity.x) < 1.0, "P2 physics stops after disable")

	settings.set_auto_battle_enabled(true)
	for _frame in 20:
		await physics_frame
		if live_controller.get_target() == live_monster:
			break
	var paused_target: Variant = live_controller.get_target()
	_check(paused_target == live_monster, "pause fixture target")
	live_hero.process_mode = Node.PROCESS_MODE_DISABLED
	await physics_frame
	await physics_frame
	_check(live_controller.get_target() == paused_target, "pause freezes auto target")
	live_hero.process_mode = Node.PROCESS_MODE_INHERIT
	live_hero.is_death = true
	live_hero.velocity.x = 100.0
	live_controller.process_movement()
	_check(absf(live_hero.velocity.x) < 1.0, "death stops auto movement")
	live_hero.is_death = false
	_check(live_controller.get_target() == live_monster, "death retains auto target")
	var scene_target: Variant = live_controller.get_target()
	var had_scene_target := scene_target != null
	stage.queue_free()
	stage = null
	await process_frame
	_check(live_controller.get_target() == null, "scene exit clears auto target")
	_check(had_scene_target, "scene exit fixture had target")

	settings.set_auto_battle_enabled(old_enabled)
	settings.set_data["AutoBattleSkillOnly"] = old_skill_only
	settings.set_data["AutoBattleSkillsBySlot"] = old_by_slot
	settings.set_data["AutoBattleMagicWeapon"] = old_magic
	settings.set_data["AutoBattleSwordArray"] = old_sword
	settings.set_data["AutoBattleWushuang"] = old_wushuang
	monster = null


func _case_input_isolation() -> void:
	coop.create_secondary(7)
	var p2_keys: Dictionary = coop.P2_KEYS
	for action: String in p2_keys.keys():
		var action_name := "p2_" + action
		_check(InputMap.has_action(action_name), "P2 action exists: " + action_name)
		_check(
			_action_has_physical_key(StringName(action_name), int(p2_keys[action])), "P2 key matches: " + action_name
		)
	_check(_action_has_physical_key(&"move_right", KEY_D), "P1 move_right remains D")
	_check(_action_has_physical_key(&"normalhit", KEY_J), "P1 normalhit remains J")
	_check(_action_has_physical_key(&"jump", KEY_K), "P1 jump remains K")

	var p1_input: Object = coop.input_for(data)
	var p2_input: Object = coop.input_for(coop.secondary_data)
	_check(p1_input.action_name(&"move_right") == &"move_right", "P1 view uses base mapping")
	_check(p2_input.action_name(&"move_right") == &"p2_move_right", "P2 view uses p2 mapping")

	Input.action_press("p2_move_right")
	_check(p2_input.is_action_pressed("move_right"), "P2 move action reaches P2 view")
	_check(not p1_input.is_action_pressed("move_right"), "P2 move action does not reach P1 view")
	Input.action_release("p2_move_right")

	Input.action_press("move_right")
	_check(p1_input.is_action_pressed("move_right"), "P1 move action reaches P1 view")
	_check(not p2_input.is_action_pressed("move_right"), "P1 move action does not reach P2 view")
	Input.action_release("move_right")

	Input.action_press("p2_normalhit")
	_check(p2_input.is_action_pressed("normalhit"), "P2 attack action reaches P2 view")
	_check(not p1_input.is_action_pressed("normalhit"), "P2 attack action does not reach P1 view")
	Input.action_release("p2_normalhit")

	var enabled_value: Variant = data.player_data["本地双人"].get("启用", true)
	data.player_data["本地双人"]["启用"] = false
	_check(not coop.is_enabled(), "coop disabled for fallback check")
	_check(p2_input.action_name(&"move_right") == &"move_right", "disabled P2 view falls back to base")
	_check(p2_input.action_name(&"normalhit") == &"normalhit", "disabled P2 attack falls back to base")
	data.player_data["本地双人"]["启用"] = enabled_value
	_check(coop.is_enabled(), "coop re-enabled")
	_check(p2_input.action_name(&"move_right") == &"p2_move_right", "re-enabled P2 view restores p2 mapping")


func _case_key_config() -> void:
	var config_path := "user://KeyConfig.json"
	var had_config := FileAccess.file_exists(config_path)
	var backup := FileAccess.get_file_as_string(config_path) if had_config else ""
	await _make_stage()
	var packed: PackedScene = load("res://Scene/tools/set_com.tscn")
	var config: Node = packed.instantiate()
	config.set("is_set", true)
	stage.add_child(config)
	await process_frame
	await process_frame

	var keys: Array = config.get("keys")
	var defaults: Array = config.get("default_keys")
	var key_nodes: Array = config.get("key_list")
	_check(keys.size() == 12 and defaults.size() == 12 and key_nodes.size() == 11, "key config nodes initialized")
	if keys.size() > 0 and key_nodes.size() > 0:
		var first_key: Dictionary = keys[0]
		var first_node: Node = key_nodes[0]
		var original_x := float(first_key["position"]["x"])
		first_key["key"] = "Z"
		first_key["position"]["x"] = original_x + 10.0
		config.call("_apply_keys_to_nodes")
		_check(first_node.get("text_key").text == "Z", "key label applies immediately")
		_check(is_equal_approx(first_node.position.x, original_x + 10.0), "key position applies immediately")
		config.call("_save_keys_config")
		_check(FileAccess.file_exists(config_path), "key config saved")
		config.call("_on_reset_layout_pressed")
		var reset_keys: Array = config.get("keys")
		_check(str(reset_keys[0]["key"]) == str(defaults[0]["key"]), "reset restores default key label")
		_check(first_node.get("text_key").text == str(defaults[0]["key"]), "reset applies default label immediately")
		_check(
			is_equal_approx(first_node.position.x, float(defaults[0]["position"]["x"])),
			"reset restores default position"
		)

	config.queue_free()
	await process_frame
	if had_config:
		var out := FileAccess.open(config_path, FileAccess.WRITE)
		if out != null:
			out.store_string(backup)
			out.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(config_path))


func _set_hud_stats(
	hero: Node,
	hp: int,
	max_hp: int,
	mp: int,
	max_mp: int,
	exp_value: int,
	max_exp: int,
	ws: int,
	protect: int,
	max_protect: int
) -> void:
	hero.RoleProp.baseroleprop.SHp = max_hp
	hero.RoleProp.baseroleprop.SMp = max_mp
	hero.RoleProp.roleprop.Hp = hp
	hero.RoleProp.roleprop.Mp = mp
	hero.RoleProp.roleprop.R_hp = 0
	hero.RoleProp.roleprop.R_mp = 0
	hero.RoleProp.baseroleprop.exp = exp_value
	hero.RoleProp.baseroleprop.max_exp = max_exp
	hero.RoleProp.ws_value = ws
	hero.RoleProp.max_ws_value = 100
	hero.current_protect = protect
	hero.max_protect = max_protect
	hero.cure_value = 0
	hero.RoleProp.get_last_prop()


func _hud_snapshot(profile: Node) -> String:
	return JSON.stringify(profile.player_data)


func _hud_diff(before: String, after: String) -> String:
	var before_data: Variant = JSON.parse_string(before)
	var after_data: Variant = JSON.parse_string(after)
	if not before_data is Dictionary or not after_data is Dictionary:
		return "snapshot parse failed"
	var changed: Array[String] = []
	for key: Variant in before_data.keys():
		if not after_data.has(key) or JSON.stringify(before_data[key]) != JSON.stringify(after_data[key]):
			changed.append(str(key))
	for key: Variant in after_data.keys():
		if not before_data.has(key):
			changed.append("+" + str(key))
	return ",".join(changed)


func _case_hud_read_only() -> void:
	coop.create_secondary(7)
	await _make_stage()
	var p1: Node = _make_hero(1, 1)
	var p2: Node = _make_hero(7, 2)
	_check(p1 != null and p2 != null, "HUD owners instantiated")
	if p1 == null or p2 == null:
		return
	await process_frame
	await process_frame
	await process_frame
	p1.set_physics_process(false)
	p2.set_physics_process(false)
	p1.set_process(false)
	p2.set_process(false)
	_set_hud_stats(p1, 111, 222, 33, 44, 55, 66, 25, 10, 20)
	_set_hud_stats(p2, 333, 444, 55, 66, 77, 88, 50, 5, 10)
	_check(
		int(p1.RoleProp.roleprop.Hp) == 111 and int(p1.RoleProp.roleprop.SHp) == 222,
		"P1 stats set immediately actual=" + str(p1.RoleProp.roleprop.Hp) + "/" + str(p1.RoleProp.roleprop.SHp)
	)
	_check(
		int(p2.RoleProp.roleprop.Hp) == 333 and int(p2.RoleProp.roleprop.SHp) == 444,
		"P2 stats set immediately actual=" + str(p2.RoleProp.roleprop.Hp) + "/" + str(p2.RoleProp.roleprop.SHp)
	)
	p1.RoleProp.baseroleprop.Level = 11
	p2.RoleProp.baseroleprop.Level = 22
	data.player_data["宠物列表"] = [_pet_probe_data("PetTurtle", "龟布", 1000, 5)]
	coop.secondary_data.player_data["宠物列表"] = [_pet_probe_data("PetTurtle", "龟布", 1000, 7)]
	data.player_data["出战宠物"] = "龟布"
	coop.secondary_data.player_data["出战宠物"] = "龟布"
	data.player_data["角色昵称"] = "HUD_P1"
	coop.secondary_data.player_data["角色昵称"] = "HUD_P2"
	var p1_before := _hud_snapshot(data)
	var p2_before := _hud_snapshot(coop.secondary_data)

	var hud1: Node = load("res://Scene/base/base_role.tscn").instantiate()
	hud1.player = p1
	hud1.set_meta("coop_slot", 1)
	hud1.set("_cached_level", stage)
	stage.add_child(hud1)
	var hud2: Node = load("res://Scene/base/base_role_p2.tscn").instantiate()
	hud2.player = p2
	hud2.set_meta("coop_slot", 2)
	hud2.set("_cached_level", stage)
	stage.add_child(hud2)
	await process_frame
	await process_frame
	await process_frame

	_check(
		hud1.hp_text.text == "111/222",
		(
			"P1 HUD HP from slot actual="
			+ hud1.hp_text.text
			+ " prop="
			+ str(p1.RoleProp.roleprop.Hp)
			+ "/"
			+ str(p1.RoleProp.roleprop.SHp)
		)
	)
	_check(
		hud2.hp_text.text == "333/444",
		(
			"P2 HUD HP from slot actual="
			+ hud2.hp_text.text
			+ " prop="
			+ str(p2.RoleProp.roleprop.Hp)
			+ "/"
			+ str(p2.RoleProp.roleprop.SHp)
		)
	)
	_check(
		hud1.mp_text.text == "33/44",
		(
			"P1 HUD MP from slot actual="
			+ hud1.mp_text.text
			+ " prop="
			+ str(p1.RoleProp.roleprop.Mp)
			+ "/"
			+ str(p1.RoleProp.roleprop.SMp)
		)
	)
	_check(
		hud2.mp_text.text == "55/66",
		(
			"P2 HUD MP from slot actual="
			+ hud2.mp_text.text
			+ " prop="
			+ str(p2.RoleProp.roleprop.Mp)
			+ "/"
			+ str(p2.RoleProp.roleprop.SMp)
		)
	)
	_check(hud1.exp_text.text == "55/66", "P1 HUD experience from slot")
	_check(hud2.exp_text.text == "77/88", "P2 HUD experience from slot")
	_check(hud1.role_level.text == "11", "P1 HUD level from slot")
	_check(hud2.role_level.text == "22", "P2 HUD level from slot")
	_check(is_equal_approx(hud1.ws_effect.value, 0.25), "P1 HUD wushuang from slot")
	_check(is_equal_approx(hud2.ws_effect.value, 0.5), "P2 HUD wushuang from slot")
	_check(is_equal_approx(hud1.role_protect.value, 0.5), "P1 HUD protect from slot")
	_check(is_equal_approx(hud2.role_protect.value, 0.5), "P2 HUD protect from slot")
	_check(hud1.pet_panel != null and hud1.pet_panel.visible, "P1 pet HUD visible")
	_check(hud2.pet_panel != null and hud2.pet_panel.visible, "P2 pet HUD visible")
	_check(hud1.pet_exp_text != null and hud1.pet_exp_text.text == "5/84", "P1 pet HUD experience")
	_check(hud2.pet_exp_text != null and hud2.pet_exp_text.text == "7/84", "P2 pet HUD experience")
	_check(hud1.pet_hp_text != null and hud1.pet_hp_text.text == "1000/1000", "P1 pet HUD HP")
	_check(hud2.pet_hp_text != null and hud2.pet_hp_text.text == "1000/1000", "P2 pet HUD HP")
	_check(_hud_snapshot(data) == p1_before, "P1 HUD frame is read-only")
	_check(_hud_snapshot(coop.secondary_data) == p2_before, "P2 HUD frame is read-only")

	coop.panel_host.open_panel(2, "背包")
	await process_frame
	await process_frame
	_check(coop.panel_host.has_panel(), "HUD panel opens")
	_check(
		_hud_snapshot(data) == p1_before,
		"P1 data unchanged while panel open diff=" + _hud_diff(p1_before, _hud_snapshot(data))
	)
	_check(
		_hud_snapshot(coop.secondary_data) == p2_before,
		"P2 data unchanged while panel open diff=" + _hud_diff(p2_before, _hud_snapshot(coop.secondary_data))
	)
	_check(hud1.hp_text.text == "111/222" and hud2.hp_text.text == "333/444", "HUD values survive pause/panel")
	coop.panel_host.close_panel()
	await process_frame
	await process_frame
	_check(not coop.panel_host.has_panel(), "HUD panel closes")
	_check(_hud_snapshot(data) == p1_before, "P1 data unchanged after panel close")
	_check(_hud_snapshot(coop.secondary_data) == p2_before, "P2 data unchanged after panel close")

	hud1.queue_free()
	hud2.queue_free()
	await process_frame
	coop.clear_runtime()
	await process_frame
	_check(coop.secondary_data == null, "HUD teardown clears secondary profile")
	_check(_hud_snapshot(data) == p1_before, "HUD teardown does not write P1 data")

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


func _make_hero(role_id: int, slot: int) -> Node:
	return global.call_hero("role_" + str(role_id), stage, Vector2(100 + slot * 50, 340), false, slot)


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
		"LocalCoopSharedSoulProbe":
			await _case_shared_soul()
		"LocalCoopSlotLedgerProbe":
			await _case_slot_ledger()
		"LocalCoopSkillKeysProbe":
			await _case_skill_keys()
		"LocalCoopSwitchPassiveProbe":
			await _case_switch_passive()
		"LocalCoopSwordMountProbe":
			await _case_sword_mount()
		"LocalCoopCreationUIProbe":
			await _case_creation_ui()
		"LocalCoopWushuangAttributionProbe":
			await _case_wushuang_attribution()
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
	_check(int(snapshot.get(coop.SAVE_KEY, {}).get("2P", {}).get("玩家等级", 0)) == primary_level + 11, "save keeps 2P profile")
	await _make_stage()
	var first: Node = _make_hero(1, 1)
	var second: Node = _make_hero(7, 2)
	_check(first != null and second != null, "both heroes instantiated")
	if first != null and second != null:
		_check(first.PlayerData == data and second.PlayerData == coop.secondary_data, "hero profiles isolated")
		_check(first.RoleProp == root.get_node("RoleProp") and second.RoleProp == coop.secondary_props, "hero props isolated")
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
	coop.open_panel(1, "背包")
	await process_frame
	await process_frame
	_check(coop.has_panel(), "bag panel opens")
	coop._switch_panel(2)
	await process_frame
	await process_frame
	_check(coop.ui_slot == 2, "panel switches to P2")
	if coop.has_panel():
		coop._panel.queue_free()
		await process_frame
		await process_frame
	_check(not coop.has_panel(), "panel closes")


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
	_check(
		coop.secondary_data.player_data["道具列表"]["页码1"].size() == 1,
		"bag write visible to 2P"
	)
	coop.secondary_data.player_data["装备列表"]["页码1"].append({"Name": "shared_probe_2"})
	_check(
		data.player_data["装备列表"]["页码1"].size() == 1,
		"equipment write visible to 1P"
	)
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
	_check(
		int(coop.secondary_data.player_data["炼体"]["p2"]["10001"]["level"]) == 4,
		"body training shared"
	)
	_check(
		int(coop.secondary_data.player_data["炼体"]["p1"]["10001"]["level"]) == 4,
		"body training copy kept in sync"
	)
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
	_check(
		is_same(data.player_data["炼体"], coop.secondary_data.player_data["炼体"]),
		"body training single container"
	)
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
		str(coop.data_for_slot(1).player_data.get("出战宠物", "")) == "PetTiger"
		and str(coop.data_for_slot(2).player_data.get("出战宠物", "")) == "PetTurtle",
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

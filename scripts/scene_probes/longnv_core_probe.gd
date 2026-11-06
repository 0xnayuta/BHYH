extends Node

## 小龙女 1P 核心探针：实例化 Role_8，验证 20 个技能入口与普通攻击动作可启动。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "LONGNV_CORE_PROBE_RESULT="
const TEARDOWN_MARKER := "LONGNV_CORE_PROBE_TEARDOWN"
const ROLE_SCENE := "res://Scene/hero/role_8/role_8.tscn"

var _failures: Array[String] = []
var _checks: Dictionary = {}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var host := Node2D.new()
	host.name = "LongnvCoreProbeHost"
	add_child(host)

	PlayerData.player_data["Myself"] = 8
	PlayerData.player_data[DataKeys.PLAYER_LEVEL] = 1
	PlayerData.ensure_skill_data()
	for index in range(1, 21):
		var skill: Dictionary = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能" + str(index)]
		skill[DataKeys.LEVEL] = 1
		skill["学习"] = 1
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Mp = 999999
	RoleProp.roleprop.SMp = 999999
	RoleProp.roleprop.Hp = 999999
	RoleProp.roleprop.SHp = 999999

	var hero = Global.call_hero("role_8", host, Vector2.ZERO, false)
	await get_tree().process_frame
	await get_tree().process_frame
	_checks["role_scene_registered"] = ResourceLoader.exists(ROLE_SCENE)
	_checks["hero_spawned"] = hero != null and is_instance_valid(hero)
	_checks["hero_class"] = hero is LongnvHero
	_checks["skill_count"] = LongnvSkillData.KEYS.size() == 20
	if not is_instance_valid(hero):
		_report()
		return

	_checks["body_loaded"] = str(hero.role_body.get("source_set")) == "default"
	_checks["animations_loaded"] = hero.role_action_player.has_animation("effect1")
	var choose = load("res://Scene/main_menu/choose_player.tscn").instantiate()
	add_child(choose)
	await get_tree().process_frame
	choose.call("set_role", 8)
	await get_tree().process_frame
	_checks["choose_player_card8"] = choose.role_cards.get_node_or_null("Role8") != null
	_checks["choose_player_role8"] = int(choose.get("selected_roles")[0]) == 8
	choose.queue_free()
	var skill_page = load("res://Scene/skill/zd_skill.tscn").instantiate()
	add_child(skill_page)
	await get_tree().process_frame
	_checks["skill_page_role8"] = str(skill_page.call("get_role_key")) == "角色8"
	_checks["skill_page_20_rows"] = (
		skill_page.get_node_or_null("ScrollContainer/HBoxContainer/sk_pi/ski_20") != null
	)
	_checks["skill_page_20_icons"] = (
		skill_page.get_node_or_null("ScrollContainer/HBoxContainer/Sk_na/skill_20") != null
	)
	skill_page.queue_free()
	var auto_page = load("res://Scene/auto_battle_config.tscn").instantiate()
	add_child(auto_page)
	await get_tree().process_frame
	_checks["auto_battle_role8"] = str(auto_page.get("role_key")) == "角色8"
	_checks["auto_battle_20_skills"] = auto_page.get("available_skills").size() == 20
	auto_page.queue_free()
	var preview_page := Node.new()
	var preview_bg := Node2D.new()
	preview_bg.name = "background"
	preview_page.add_child(preview_bg)
	var preview_body := Sprite2D.new()
	preview_body.name = "RoleBody"
	preview_bg.add_child(preview_body)
	var preview_equipment := Sprite2D.new()
	preview_equipment.name = "RoleEquipment"
	preview_bg.add_child(preview_equipment)
	var preview_front := Sprite2D.new()
	preview_front.name = "RoleBodyFront"
	preview_bg.add_child(preview_front)
	Global.configure_backpack_role_preview(preview_page)
	_checks["backpack_preview_script"] = (
		preview_body.get_script() != null
		and preview_body.get_script().resource_path == "res://Script/hero/longnv_official_parts.gd"
	)
	_checks["backpack_preview_visible"] = preview_body.visible and not preview_equipment.visible
	preview_page.free()
	PlayerData.player_data[DataKeys.TRANSMOG_LIST] = {
		DataKeys.WEAPON: "4820101",
		DataKeys.ARMOR: "4820103",
		DataKeys.WINGS: "hhyq",
		DataKeys.TITLE: "",
	}
	var transmog = load("res://Scene/other_scene/transmogrified.tscn").instantiate()
	add_child(transmog)
	await get_tree().process_frame
	await get_tree().physics_frame
	var role8_items: Array = transmog.call("get_current_role_list")
	_checks["transmog_role8_items"] = role8_items.has("4820101") and role8_items.has("4820103")
	_checks["transmog_role8_body"] = (
		str(transmog.role_body.get("body_equipment")) == "4820103"
		and transmog.role_body.get_script() != null
		and transmog.role_body.get_script().resource_path == "res://Script/hero/longnv_official_parts.gd"
	)
	_checks["transmog_wings_hhyq"] = (
		transmog.wings.sprite_frames != null
		and transmog.wings.sprite_frames.has_animation("hhyq")
		and transmog.wings.visible
	)
	transmog.queue_free()
	var mount_visual = load("res://Script/mount/mount_visual.gd").new()
	add_child(mount_visual)
	await get_tree().process_frame
	mount_visual.call("set_longnv_rider", "4820103", "4820101", "ride")
	var longnv_rider = mount_visual.get("_longnv_rider")
	_checks["mount_longnv_rider"] = (
		longnv_rider != null
		and str(longnv_rider.get("body_equipment")) == "4820103"
		and str(longnv_rider.get("weapon_equipment")) == "4820101"
	)
	mount_visual.queue_free()
	var hero_props = hero.call("_props")
	hero_props.roleprop.Mp = 999999
	hero_props.roleprop.SMp = 999999
	for index in range(LongnvSkillData.KEYS.size()):
		var key: String = LongnvSkillData.KEYS[index]
		hero_props.roleprop.Mp = 999999
		if hero.role1_skill_inter.has(key):
			hero.role1_skill_inter[key] = 0.0
		hero.set("_active", false)
		hero.set("is_using_skills", false)
		hero.set("is_attacking", false)
		hero.call("get_skill", key)
		for _frame in range(24):
			await get_tree().physics_frame
		_checks["skill_%02d_%s" % [index + 1, key]] = bool(hero.get("_active"))
		hero.call("_finish_action")
		await get_tree().process_frame

	hero.set("is_using_skills", false)
	hero.set("is_attacking", false)
	hero.call("_start_melee", "hit1")
	await get_tree().physics_frame
	_checks["melee_started"] = bool(hero.get("_active"))
	hero.call("_finish_action")

	LocalCoop.create_secondary(8)
	var p2 = Global.call_hero("role_8", host, Vector2(150, 0), false, 2)
	await get_tree().process_frame
	await get_tree().process_frame
	_checks["p2_spawned"] = p2 is LongnvHero
	_checks["p2_slot"] = int(LocalCoop.slot_for(p2)) == 2
	_checks["p2_props"] = p2.call("_props") == LocalCoop.secondary_props
	if is_instance_valid(p2):
		var p2_data = LocalCoop.data_for(p2)
		for skill_index in range(1, 21):
			var skill_entry: Dictionary = p2_data.player_data[DataKeys.SKILL_LEARNED]["技能" + str(skill_index)]
			skill_entry[DataKeys.LEVEL] = 1
			skill_entry["学习"] = 1
		var p2_props = p2.call("_props")
		p2_props.roleprop.Mp = 999999
		p2.role1_skill_inter["xln_lz"] = 0.0
		p2.call("get_skill", "xln_lz")
		await get_tree().physics_frame
		_checks["p2_skill_started"] = bool(p2.get("_active"))
		if not bool(p2.get("_active")):
			print(
				"LONGNV_P2_BLOCK active=%s using=%s be=%s death=%s silent=%s limit=%s mp=%s level=%s cd=%s"
				% [
					p2.get("_active"),
					p2.get("is_using_skills"),
					p2.get("is_be_attacking"),
					p2.get("is_death"),
					p2.get("is_silent"),
					p2.call("no_limit_buff"),
					p2_props.roleprop.Mp,
					p2.call("get_skill_level", 1),
					p2.get("role1_skill_inter").get("xln_lz"),
				]
			)
		p2.call("_finish_action")
		p2.queue_free()
	LocalCoop.clear_runtime()

	hero.queue_free()
	await get_tree().process_frame
	LocalCoop.create_secondary(8)
	var p2_data = LocalCoop.data_for_slot(2)
	p2_data.ensure_skill_data()
	for skill_index in range(1, 21):
		var p2_entry: Dictionary = p2_data.player_data[DataKeys.SKILL_LEARNED]["技能" + str(skill_index)]
		p2_entry[DataKeys.LEVEL] = 1
		p2_entry["学习"] = 1
	var previous_scene: Node = get_tree().current_scene
	var level = load("res://Scene/level/level_1.tscn").instantiate()
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	LocalCoop._on_scene_changed()
	await get_tree().create_timer(1.2).timeout
	level.can_create = false
	if level.get("create_control") != null:
		level.create_control.stop()
	var level_p1 = level.get("_role")
	var level_p2 = level.get("role_p2")
	_checks["level_p1_role8"] = level_p1 is LongnvHero
	_checks["level_p2_role8"] = level_p2 is LongnvHero
	if level_p1 != null and level_p2 != null:
		_checks["level_profiles_isolated"] = level_p1.PlayerData != level_p2.PlayerData
		_checks["level_props_isolated"] = level_p1.RoleProp != level_p2.RoleProp
		_checks["level_p2_slot"] = int(level_p2.get_meta("coop_slot", 0)) == 2
		var p1_props = level_p1.RoleProp
		var p2_props = level_p2.RoleProp
		p1_props.roleprop.Mp = 999999
		p2_props.roleprop.Mp = 999999
		level_p1.role1_skill_inter["xln_lz"] = 0.0
		level_p2.role1_skill_inter["xln_lz"] = 0.0
		level_p1.call("get_skill", "xln_lz")
		await get_tree().physics_frame
		_checks["level_p1_skill"] = bool(level_p1.get("_active"))
		level_p1.call("_finish_action")
		level_p2.call("get_skill", "xln_lz")
		await get_tree().physics_frame
		_checks["level_p2_skill"] = bool(level_p2.get("_active"))
		_checks["level_cooldowns_isolated"] = (
			float(level_p1.role1_skill_inter.get("xln_lz", 0.0)) > 0.0
			and float(level_p2.role1_skill_inter.get("xln_lz", 0.0)) > 0.0
		)
		level_p2.call("_finish_action")
		level_p2.set("is_using_skills", false)
		level_p2.set("is_attacking", false)
		level_p2.call("_start_melee", "hit1")
		await get_tree().physics_frame
		_checks["level_p2_melee"] = bool(level_p2.get("_active"))
		level_p2.call("_finish_action")
		level_p1.RoleProp.roleprop.Hp = 0
		level_p2.RoleProp.roleprop.Hp = maxf(1.0, level_p2.RoleProp.roleprop.Hp)
		_checks["level_progression_uses_p2"] = level.call("get_progression_player") == level_p2
	var level_camera = level.get("my_camera")
	if level_camera != null and level_p1 != null and level_p2 != null:
		level_camera.call("_center_on_living_players")
		var expected_center: Vector2 = (level_p1.global_position + level_p2.global_position) * 0.5
		_checks["level_camera_centers"] = (
			level_camera.global_position.distance_to(expected_center) < 4.0
		)
	else:
		_checks["level_camera_centers"] = false
	var level_information = level.get("role_information")
	if level_information != null:
		level_information.reveal_after_scene_loaded()
		_checks["level_p2_hud"] = level_information.role_p2 != null
		if level_information.role_p2 != null:
			_checks["level_p2_hud_binding"] = level_information.role_p2.player == level_p2
	else:
		_checks["level_p2_hud"] = false
	level.queue_free()
	await get_tree().process_frame
	get_tree().current_scene = previous_scene
	LocalCoop.clear_runtime()

	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	_report()
	if is_instance_valid(hero):
		hero.queue_free()


func _report() -> void:
	print(RESULT_PREFIX + JSON.stringify({"ok": _failures.is_empty(), "failures": _failures, "checks": _checks}))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)

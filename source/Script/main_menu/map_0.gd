extends Node2D

const MAP_DESIGN_SIZE := Vector2(940.0, 590.0)
const PET_PANEL_SIZE := Vector2(653.0, 513.0)
const PLAYER_HEAD_BASE_POSITION := Vector2(15.0, 2.0)
const PLAYER_PANEL_BASE_POSITION := Vector2(8.0, 8.0)
const PLAYER_LEVEL_BASE_POSITION := Vector2(10.0, 84.0)
const BACKPACK_SCENE_PATH := "res://Scene/back_pack/back_pack.tscn"
const PET_SCENE_PATH := "res://Scene/pet/pet_interface.tscn"
const MOUNT_SCENE_PATH := "res://Scene/main_menu/mount_panel.tscn"
const ZHUXIAN_SWORD_PAGE_PATH := "res://Scene/main_menu/zhu_xian_sword_page.tscn"
const WANLING_CATALOG_PAGE_PATH := "res://Scene/main_menu/wan_ling_catalog_page.tscn"
const EQUIPMENT_CATALOG_PAGE_PATH := "res://Scene/main_menu/equipment_catalog_page.tscn"
const BODY_TRAINING_SCENE_PATH := "res://Scene/main_menu/body_training.tscn"
const ZHENYAO_TOWER_SCENE_PATH := "res://Scene/main_menu/zhen_yao_tower.tscn"
const SOUTH_CONTINENT_PATH := "res://Scene/main_menu/map_6.tscn"
const EAST_CONTINENT_PATH := "res://Scene/main_menu/map_7.tscn"
const NORTH_CONTINENT_PATH := "res://Scene/main_menu/map_8.tscn"
const WEST_CONTINENT_PATH := "res://Scene/main_menu/map_9.tscn"
const HUMAN_WORLD_PATH := "res://Scene/main_menu/map_1.tscn"
const UNDERWORLD_PATH := "res://Scene/main_menu/map_2.tscn"
const HEAVEN_PATH := "res://Scene/main_menu/map_3.tscn"
const HEAVEN_JIEJIAO_PATH := "res://Scene/main_menu/map_4.tscn"
const HEAVEN_BIYOU_PATH := "res://Scene/main_menu/map_5.tscn"
const ROLE_HEAD_PATHS := {
	1: "res://Art/hero_picture/role_properies_box/hud_swk.png",
	2: "res://Art/hero_picture/role_properies_box/hud_tsz.png",
	3: "res://Art/hero_picture/role_properies_box/hud_zbj.png",
	4: "res://Art/hero_picture/role_properies_box/hud_shs.png",
	5: "res://Art/hero_picture/role_properies_box/hud_blm.png",
	6: "res://Art/hero_picture/role_properies_box/hud_nz.png",
}

var backpack_page: Node = null
var magic_weapon_page: Node = null
var pet_page: Node = null
var mount_page: Node = null
var skill_page: Node = null
var zhuxian_sword_page: Node = null
var wanling_catalog_page: Node = null
var equipment_catalog_page: Node = null
var body_training_page: Node = null
var zhenyao_tower_page: Node = null


func _ready() -> void:
	Global.get_ui_runtime().windows = _ui_parent()
	_update_player_head()
	_update_player_level()
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	_save_if_possible()
	Global.call_deferred("prewarm_permanent_small_ui_scenes")


func _exit_tree() -> void:
	_save_if_possible()
	Global.release_map_visual_resources(self)


func _save_if_possible() -> void:
	if Global.is_archive_session_active() and FileAccess.file_exists(Global.get_archive_session_path()):
		MemoryClass.request_save("map_0_save")


func _update_player_head() -> void:
	var role_id := clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 6)
	$PlayerHead.texture = load(str(ROLE_HEAD_PATHS[role_id])) as Texture2D


func _update_player_level() -> void:
	var level_label := get_node_or_null("PlayerLevel") as Label
	if level_label != null:
		level_label.text = str(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, 1))


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale: float = minf(viewport_size.x / MAP_DESIGN_SIZE.x, viewport_size.y / MAP_DESIGN_SIZE.y)
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - MAP_DESIGN_SIZE * fit_scale) * 0.5
	var left_compensation := Vector2(-position.x / fit_scale, 0.0)
	$PlayerHead.position = PLAYER_HEAD_BASE_POSITION + left_compensation
	$PlayerPanel.position = PLAYER_PANEL_BASE_POSITION + left_compensation
	var level_label := get_node_or_null("PlayerLevel") as Label
	if level_label != null:
		level_label.position = PLAYER_LEVEL_BASE_POSITION + left_compensation
	$TopButtons.position = left_compensation
	$EquipmentCatalog.position.x = 834.0 + position.x / fit_scale
	$BottomButtons.position = left_compensation
	_center_pet_page()


func _center_pet_page() -> void:
	if pet_page is Control and is_instance_valid(pet_page):
		(pet_page as Control).position = _viewport_center() - PET_PANEL_SIZE * 0.5


func _ui_parent() -> Node:
	if Global.has_method("get_ui_popup_layer"):
		return Global.get_ui_runtime().get_popup_layer()
	var parent := get_parent()
	return parent if parent != null else self


func _viewport_center() -> Vector2:
	return get_viewport().get_visible_rect().size * 0.5


func _set_if_has_property(target: Object, property_name: StringName, value: Variant) -> void:
	for property in target.get_property_list():
		if StringName(property.name) == property_name:
			target.set(property_name, value)
			return


func _current_preview_player() -> Variant:
	var player: Variant = RoleProp.source_player
	return player if is_instance_valid(player) else null


func _toggle_scene(current_page: Variant, scene_path: String, setup_backpack := false) -> Node:
	if is_instance_valid(current_page):
		(current_page as Node).queue_free()
		return null
	var page_scene := Global.load_ui_scene(scene_path)
	if page_scene == null:
		Global.add_message_show(_ui_parent(), "页面加载失败", 1.5, Vector2(470, 300))
		return null
	var page := page_scene.instantiate()
	Global.get_ui_runtime().register_ui_runtime_instance(page, scene_path)
	if setup_backpack:
		var player: Variant = _current_preview_player()
		_set_if_has_property(page, &"Player", player)
		_set_if_has_property(page, &"boxObj", self)
		Global.configure_backpack_role_preview(page, player)
	_ui_parent().add_child(page)
	if page is Node2D:
		(page as Node2D).position = _viewport_center()
	return page


func _show_unavailable(feature_name: String) -> void:
	Global.add_message_show(_ui_parent(), "%s暂未开放" % feature_name, 1.5, Vector2(470, 300))


func _change_map(scene_path: String) -> void:
	_save_if_possible()
	Global.change_scene(scene_path)


func _require_map_clear(level_name: String, message: String) -> bool:
	if bool(PlayerData.player_data.get(level_name, false)):
		return true
	Global.add_message_show(_ui_parent(), message, 1.5, Vector2(470, 300))
	return false


func _on_south_continent_pressed() -> void:
	if not _require_map_clear("通天教主", "需要先通关碧游宫！"):
		return
	_change_map(SOUTH_CONTINENT_PATH)


func _on_east_continent_pressed() -> void:
	if not _require_map_clear("冥海", "需要先通关南瞻部洲！"):
		return
	_change_map(EAST_CONTINENT_PATH)


func _on_north_continent_pressed() -> void:
	if not _require_map_clear("云川", "需要先通关东胜神洲！"):
		return
	_change_map(NORTH_CONTINENT_PATH)


func _on_west_continent_pressed() -> void:
	if not _require_map_clear("星域", "需要先通关北俱芦洲！"):
		return
	_change_map(WEST_CONTINENT_PATH)


func _on_demon_tower_pressed() -> void:
	zhenyao_tower_page = _toggle_scene(zhenyao_tower_page, ZHENYAO_TOWER_SCENE_PATH)


func _on_human_world_pressed() -> void:
	_change_map(HUMAN_WORLD_PATH)


func _on_underworld_pressed() -> void:
	if not _require_map_clear("牛魔谷", "需要先通关人间！"):
		return
	_change_map(UNDERWORLD_PATH)


func _on_heaven_pressed() -> void:
	if not _require_map_clear("转轮殿", "需要先通关地府！"):
		return
	var target_path := HEAVEN_PATH
	match int(PlayerData.player_data.get("HeavenMap_num", 3)):
		4:
			target_path = HEAVEN_JIEJIAO_PATH
		5:
			target_path = HEAVEN_BIYOU_PATH
	_change_map(target_path)


func _on_bag_pressed() -> void:
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(1, "背包")
		return
	backpack_page = _toggle_scene(backpack_page, BACKPACK_SCENE_PATH, true)


func _on_magic_weapon_pressed() -> void:
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(1, "法宝")
		return
	if magic_weapon_page != null and is_instance_valid(magic_weapon_page):
		magic_weapon_page.queue_free()
		magic_weapon_page = null
		return
	magic_weapon_page = Global.add_magp_infor(_ui_parent(), _viewport_center())


func _on_mount_pressed() -> void:
	if not PlayerData.is_mount_system_unlocked():
		Global.add_message_show(_ui_parent(), "通关碧游宫开放坐骑", 1.5, Vector2(470, 300))
		return
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(1, "坐骑")
		return
	mount_page = _toggle_scene(mount_page, MOUNT_SCENE_PATH)


func _on_pet_pressed() -> void:
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(1, "宠物")
		return
	pet_page = _toggle_scene(pet_page, PET_SCENE_PATH)
	_center_pet_page()


func _on_wing_pressed() -> void:
	_show_unavailable("翅膀")


func _on_body_training_pressed() -> void:
	if is_instance_valid(body_training_page) and not body_training_page.is_queued_for_deletion():
		return
	body_training_page = _toggle_scene(body_training_page, BODY_TRAINING_SCENE_PATH)


func clear_body_training_page(page: Node) -> void:
	if body_training_page == page:
		body_training_page = null


func _on_zhuxian_pressed() -> void:
	zhuxian_sword_page = _toggle_scene(zhuxian_sword_page, ZHUXIAN_SWORD_PAGE_PATH)


func _on_wanling_catalog_pressed() -> void:
	wanling_catalog_page = _toggle_scene(wanling_catalog_page, WANLING_CATALOG_PAGE_PATH)


func _on_equipment_catalog_pressed() -> void:
	equipment_catalog_page = _toggle_scene(equipment_catalog_page, EQUIPMENT_CATALOG_PAGE_PATH)


func _on_shop_pressed() -> void:
	Global.add_shop(_ui_parent(), Vector2.ZERO)


func _on_alchemy_pressed() -> void:
	Global.add_ldl(_ui_parent(), Vector2.ZERO)


func _on_skill_pressed() -> void:
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(1, "技能")
		return
	if skill_page != null and is_instance_valid(skill_page):
		skill_page.queue_free()
		skill_page = null
		return
	skill_page = Global.add_learn_skill(_ui_parent(), Vector2.ZERO)


func _on_activity_pressed() -> void:
	Global.add_game_announcement(_ui_parent(), Vector2.ZERO)


func _on_task_pressed() -> void:
	Global.add_basic_task(_ui_parent(), Vector2.ZERO)


func _on_group_pressed() -> void:
	_show_unavailable("群组")


func _on_return_pressed() -> void:
	_save_if_possible()
	Global.change_scene("res://Scene/main_menu/main_menu.tscn")

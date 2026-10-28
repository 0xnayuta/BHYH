extends Node2D

const MAP_DESIGN_SIZE := Vector2(940.0, 590.0)
const LEVEL_HIGHLIGHT_SHADER := preload("res://Shader/ws_effect.gdshader")
const LEFT_ALIGNED_BUTTON_NAMES := [
	"MemoryClass",
	"Shop",
	"LDL2",
	"Skill",
	"Activity",
	"Task",
	"Return",
	"GameSet",
	"GameAn",
	"next",
	"Pellet",
]
const RIGHT_ALIGNED_BUTTON_NAMES := [
	"NorthContinent",
	"WorldMapButton",
]
const MAP_LEVEL_NAMES := {
	63: "金沙村",
	64: "百仙园",
	65: "傲来国",
	66: "花果山",
	67: "水帘洞",
	68: "桃花谷",
	69: "蝙蝠窟",
	70: "七星洞",
	71: "万妖穴",
	72: "琉璃宫",
	73: "金玉宫",
	74: "浮天台",
	75: "云川",
}
const LAST_OPEN_LEVEL := 74

var max_page: int = 7
var skill_target
var _left_aligned_button_positions := {}
var _right_aligned_button_right_edges := {}
var _level_highlight_tween: Tween


func _ui_parent() -> Node:
	var parent := get_parent()
	if parent != null:
		return parent
	return self


func _fit_to_fullscreen() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale: float = minf(viewport_size.x / MAP_DESIGN_SIZE.x, viewport_size.y / MAP_DESIGN_SIZE.y)
	var map_size: Vector2 = MAP_DESIGN_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - map_size) * 0.5
	_align_left_side_buttons(fit_scale)
	_align_right_side_buttons(fit_scale)
	_cleanup_map_shadow_rects()


func _align_left_side_buttons(fit_scale: float) -> void:
	if fit_scale <= 0.0:
		return
	for button_name in LEFT_ALIGNED_BUTTON_NAMES:
		var button := get_node_or_null(button_name) as Control
		if button == null:
			continue
		if not _left_aligned_button_positions.has(button_name):
			_left_aligned_button_positions[button_name] = button.position
		var original_position: Vector2 = _left_aligned_button_positions[button_name]
		button.position = Vector2(original_position.x - position.x / fit_scale, original_position.y)


func _align_right_side_buttons(fit_scale: float) -> void:
	if fit_scale <= 0.0:
		return
	for button_name in RIGHT_ALIGNED_BUTTON_NAMES:
		var button := get_node_or_null(button_name) as Control
		if button == null:
			continue
		if not _right_aligned_button_right_edges.has(button_name):
			_right_aligned_button_right_edges[button_name] = button.position.x + button.size.x
		var original_right_edge: float = _right_aligned_button_right_edges[button_name]
		var right_margin: float = MAP_DESIGN_SIZE.x - original_right_edge
		button.position = Vector2(
			MAP_DESIGN_SIZE.x - button.size.x - right_margin + position.x / fit_scale, button.position.y
		)


func _exit_tree() -> void:
	_cleanup_map_shadow_rects()
	Global.release_map_visual_resources(self)


func _cleanup_map_shadow_rects() -> void:
	var parent := get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		if child != null and child.name in ["MapShadowTop", "MapShadowBottom", "MapShadowLeft", "MapShadowRight"]:
			child.queue_free()


func _ready() -> void:
	LazyTextureButtonStates.setup(self)
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)

	Global.windows = _ui_parent()
	Global.llbt_level = 1
	Global.llbtbossms = false
	Global.llbtcgms = false
	Global.llbtwxms = false
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = RoleProp.roleprop.Hp
	RoleProp.current_mp = RoleProp.roleprop.Mp

	if int(MainSet.set_data.get("CurrentLevelPage", 0)) < max_page:
		MainSet.set_data["CurrentLevelPage"] = max_page
		MemoryClass.main_bc()

	if MainMusic.my_main_music == null:
		MainMusic.add_music()
	Global.current_level = ""
	if not Global.is_frist:
		Global.add_message_show(Global.windows, "欢迎进入游戏！作品完全免费！！", 1.5, Vector2(470, 300))
		Global.is_frist = true
	Global.player_be_hit_count = 0
	Global.last_level_path = ""
	Global.fb_cd = 0
	get_tree().paused = false
	PlayerData.player_data["Map_num"] = max_page

	Global.is_mpo = false
	Global.is_ice = false
	Global.is_poision = false
	Global.is_fire = false
	Global.is_speed_down = false
	Global.is_stun = false
	Global.is_bleed = false
	Global.is_eye_fix = false
	Global.is_dead_link = false
	RoleProp.ws_value = 0

	if not Global.cd_path.is_empty():
		MemoryClass.request_save("map_enter")
	MemoryClass.main_dq()
	_update_level_progression()


func _is_map7_level_cleared(level_number: int) -> bool:
	return bool(PlayerData.player_data.get("东胜神州通关_%d" % level_number, false))


func _has_map7_prerequisite(level_number: int) -> bool:
	if level_number <= 63:
		return true
	return _is_map7_level_cleared(level_number - 1)


func _update_level_progression() -> void:
	if _level_highlight_tween != null:
		_level_highlight_tween.kill()
		_level_highlight_tween = null

	for level_number in range(63, 76):
		var level_button := get_node_or_null("Level_%d" % level_number) as TextureButton
		if level_button == null:
			continue
		level_button.material = null
		if level_number > LAST_OPEN_LEVEL:
			level_button.disabled = true
		else:
			level_button.disabled = not _has_map7_prerequisite(level_number)

	for level_number in range(63, LAST_OPEN_LEVEL + 1):
		if _is_map7_level_cleared(level_number) or not _has_map7_prerequisite(level_number):
			continue
		var next_level_button := get_node_or_null("Level_%d" % level_number) as TextureButton
		if next_level_button != null:
			_start_level_highlight(next_level_button)
		break


func _start_level_highlight(level_button: TextureButton) -> void:
	var highlight_material := ShaderMaterial.new()
	highlight_material.shader = LEVEL_HIGHLIGHT_SHADER
	highlight_material.set_shader_parameter("outline_width", 1.0)
	highlight_material.set_shader_parameter("outline_color", Color(1.0, 0.941176, 0.0, 1.0))
	level_button.material = highlight_material
	_level_highlight_tween = create_tween().set_loops()
	_level_highlight_tween.tween_method(_set_level_highlight_width.bind(highlight_material), 1.0, 4.0, 0.5)
	_level_highlight_tween.tween_method(_set_level_highlight_width.bind(highlight_material), 4.0, 1.0, 0.5)


func _set_level_highlight_width(width: float, highlight_material: ShaderMaterial) -> void:
	if is_instance_valid(highlight_material):
		highlight_material.set_shader_parameter("outline_width", width)


func _on_map_level_pressed(level_number: int) -> void:
	var level_name: String = MAP_LEVEL_NAMES.get(level_number, "东胜神州关卡")
	if level_number > LAST_OPEN_LEVEL:
		Global.add_message_show(_ui_parent(), "%s暂未开放" % level_name, 1.5, Vector2(470, 300))
		return
	if not _has_map7_prerequisite(level_number):
		var prerequisite_name: String = MAP_LEVEL_NAMES.get(level_number - 1, "前置关卡")
		Global.add_message_show(_ui_parent(), "需要先通关%s！" % prerequisite_name, 1.5, Vector2(470, 300))
		return
	var level_path := "res://Scene/level/level_%d.tscn" % level_number
	if ResourceLoader.exists(level_path):
		Global.add_level_info(_ui_parent(), level_name, Vector2.ZERO, level_path)
		return
	Global.add_message_show(_ui_parent(), "%s 尚未接入，敬请期待！" % level_name, 1.5, Vector2(470, 300))


func _on_memory_class_pressed() -> void:
	if not Global.cd_path.is_empty():
		MemoryClass.save_game(Global.cd_path)
	Global.add_message_show(_ui_parent(), "保存成功！本作品完全免费，谨防受骗上当！", 1.5, Vector2(470, 300))


func _on_shop_pressed() -> void:
	Global.add_shop(_ui_parent(), Vector2.ZERO)


func _on_ldl_2_pressed() -> void:
	Global.add_ldl(_ui_parent(), Vector2.ZERO)


func _on_skill_pressed() -> void:
	if skill_target == null:
		skill_target = Global.add_learn_skill(_ui_parent(), Vector2.ZERO)
	else:
		skill_target.queue_free()


func _on_activity_pressed() -> void:
	Global.add_message_show(_ui_parent(), "敬请期待！！！", 1.5, Vector2(470, 300))


func _on_task_pressed() -> void:
	Global.add_basic_task(_ui_parent(), Vector2.ZERO)


func _on_return_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_0.tscn")


func _on_game_set_pressed() -> void:
	Global.add_game_set(_ui_parent(), Vector2.ZERO)


func _on_game_an_pressed() -> void:
	Global.add_game_announcement(_ui_parent(), Vector2.ZERO)


func _on_pellet_pressed() -> void:
	Global.add_basic_pellet(_ui_parent(), Vector2.ZERO)


func _on_jjtj_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_6.tscn")


func _on_north_continent_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_8.tscn")

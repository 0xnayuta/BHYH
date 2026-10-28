extends Node2D
class_name Map4

const MAP_DESIGN_SIZE := Vector2(940.0, 590.0)
const MAP_SHADOW_FADE := 55.0
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
	"Pellet",
]
const RIGHT_ALIGNED_BUTTON_NAMES := [
	"level_lhhj",
	"WorldMapButton",
]
@onready var level: AnimationPlayer = $Level
@onready var level_31: TextureButton = $Level_31
@onready var level_32: TextureButton = $Level_32
@onready var level_33: TextureButton = $Level_33
@onready var level_34: TextureButton = $Level_34
@onready var level_35: TextureButton = $Level_35
@onready var level_36: TextureButton = $Level_36
@onready var level_37: TextureButton = $Level_37
@onready var level_38: TextureButton = $Level_38
@onready var level_39: TextureButton = $Level_39
@onready var level_byg: TextureButton = $Level_byg
@onready var level_esbxx: TextureButton = $Level_esbxx
@onready var level_znyy: TextureButton = $Level_znyy

var max_page: int = 4
var skill_target
var my_music
var _map_shadow_rects := []
var _map_shadow_shader: Shader
var _left_aligned_button_positions := {}
var _right_aligned_button_right_edges := {}


func _get_map_shadow_shader() -> Shader:
	if _map_shadow_shader != null:
		return _map_shadow_shader
	_map_shadow_shader = Shader.new()
	_map_shadow_shader.code = "\nshader_type canvas_item;\nuniform int side = 0;\nuniform vec2 rect_size = vec2(1.0, 1.0);\nuniform float solid_px = 0.0;\nuniform float fade_px = 55.0;\nuniform float noise_strength_px = 10.0;\nuniform float noise_scale_px = 85.0;\nuniform float alpha_power = 1.45;\n\nfloat hash(vec2 p) {\n    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);\n}\n\nfloat noise(vec2 p) {\n    vec2 i = floor(p);\n    vec2 f = fract(p);\n    vec2 u = f * f * (3.0 - 2.0 * f);\n    float a = hash(i);\n    float b = hash(i + vec2(1.0, 0.0));\n    float c = hash(i + vec2(0.0, 1.0));\n    float d = hash(i + vec2(1.0, 1.0));\n    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);\n}\n\nvoid fragment() {\n    vec2 px = UV * rect_size;\n    float inward_px = px.y;\n    float edge_axis_px = px.x;\n    if (side == 1) {\n        inward_px = rect_size.y - px.y;\n        edge_axis_px = px.x;\n    } else if (side == 2) {\n        inward_px = px.x;\n        edge_axis_px = px.y;\n    } else if (side == 3) {\n        inward_px = rect_size.x - px.x;\n        edge_axis_px = px.y;\n    }\n    float n1 = noise(vec2(edge_axis_px / noise_scale_px, 0.37));\n    float n2 = noise(vec2(edge_axis_px / (noise_scale_px * 0.43), 8.91));\n    float wobble_px = ((n1 * 0.72 + n2 * 0.28) - 0.5) * noise_strength_px;\n    float fade_t = clamp((inward_px - solid_px + wobble_px) / max(fade_px, 1.0), 0.0, 1.0);\n    fade_t = smoothstep(0.0, 1.0, fade_t);\n    float alpha = pow(1.0 - fade_t, alpha_power) * 0.68;\n    COLOR = vec4(0.0, 0.0, 0.0, alpha);\n}\n"

	return _map_shadow_shader


func _cleanup_map_shadow_rects() -> void:
	var names = ["MapShadowTop", "MapShadowBottom", "MapShadowLeft", "MapShadowRight"]
	var p = get_parent()
	if p != null:
		for child in p.get_children():
			if child != null and child.name in names:
				child.queue_free()
	for rect in _map_shadow_rects:
		if rect != null and is_instance_valid(rect):
			rect.queue_free()
	_map_shadow_rects.clear()


func _exit_tree() -> void:
	_cleanup_map_shadow_rects()
	Global.release_map_visual_resources(self)


func _ensure_map_shadow_rects() -> void:
	if _map_shadow_rects.size() > 0:
		return
	_cleanup_map_shadow_rects()
	for i in range(4):
		var rect := ColorRect.new()
		rect.name = ["MapShadowTop", "MapShadowBottom", "MapShadowLeft", "MapShadowRight"][i]
		rect.color = Color.WHITE
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.z_index = 1000
		var material := ShaderMaterial.new()
		material.shader = _get_map_shadow_shader()
		material.set_shader_parameter("side", i)
		rect.material = material
		get_parent().add_child(rect)
		_map_shadow_rects.append(rect)


func _set_shadow_rect(index: int, _pos: Vector2, _size: Vector2, solid_px_: float, fade_px_: float) -> void:
	var rect: ColorRect = _map_shadow_rects[index]
	rect.position = _pos
	rect.size = Vector2(max(_size.x, 0.0), max(_size.y, 0.0))
	rect.visible = rect.size.x > 0.5 and rect.size.y > 0.5
	if rect.material is ShaderMaterial:
		(rect.material as ShaderMaterial).set_shader_parameter("rect_size", rect.size)
		(rect.material as ShaderMaterial).set_shader_parameter("solid_px", max(solid_px_, 0.0))
		(rect.material as ShaderMaterial).set_shader_parameter("fade_px", max(fade_px_, 1.0))


func _ui_parent() -> Node:
	var p = get_parent()
	if p != null:
		return p
	return self


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / MAP_DESIGN_SIZE.x, viewport_size.y / MAP_DESIGN_SIZE.y)
	var map_size = MAP_DESIGN_SIZE * fit_scale
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
		var right_margin := MAP_DESIGN_SIZE.x - original_right_edge
		button.position = Vector2(
			MAP_DESIGN_SIZE.x - button.size.x - right_margin + position.x / fit_scale, button.position.y
		)


func _ready() -> void:
	LazyTextureButtonStates.setup(self)
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	if not MainSet.set_data["LevelTT"]:
		MainSet.set_data["LevelTT"] = true
		Global.add_message_show(Global.windows, "恭喜通到达天庭，解锁角色“沙悟净”！！", 1.5, Vector2(470, 300))
		MemoryClass.main_bc()
	Global.llbt_level = 1
	Global.llbtbossms = false
	Global.llbtcgms = false
	Global.llbtwxms = false
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = RoleProp.roleprop.Hp
	RoleProp.current_mp = RoleProp.roleprop.Mp

	for i in range(1, 11):
		play_an(i)

	if MainSet.set_data["CurrentLevelPage"] <= max_page:
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
	PlayerData.player_data["Map_num"] = 4
	PlayerData.player_data["HeavenMap_num"] = 4
	MemoryClass.request_save("map_enter")
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
	MemoryClass.main_dq()
	check_pass_level()


func _on_level_31_pressed() -> void:
	Global.add_level_info(_ui_parent(), "火龙岛", Vector2(0, 0), "res://Scene/level/level_31.tscn")


func _on_level_32_pressed() -> void:
	Global.add_level_info(_ui_parent(), "九龙岛", Vector2(0, 0), "res://Scene/level/level_32.tscn")


func _on_level_33_pressed() -> void:
	Global.add_level_info(_ui_parent(), "龙脊山", Vector2(0, 0), "res://Scene/level/level_33.tscn")


func _on_level_34_pressed() -> void:
	Global.add_level_info(_ui_parent(), "尾妖林", Vector2(0, 0), "res://Scene/level/level_34.tscn")


func _on_level_35_pressed() -> void:
	Global.add_level_info(_ui_parent(), "仙音岛", Vector2(0, 0), "res://Scene/level/level_35.tscn")


func _on_level_36_pressed() -> void:
	Global.add_level_info(_ui_parent(), "仙幻岛", Vector2(0, 0), "res://Scene/level/level_36.tscn")


func _on_level_37_pressed() -> void:
	Global.add_level_info(_ui_parent(), "仙树岛", Vector2(0, 0), "res://Scene/level/level_37.tscn")


func _on_level_38_pressed() -> void:
	Global.add_level_info(_ui_parent(), "蓬莱岛", Vector2(0, 0), "res://Scene/level/level_38.tscn")


func _on_level_39_pressed() -> void:
	Global.add_level_info(_ui_parent(), "蓬莱仙境", Vector2(0, 0), "res://Scene/level/level_39.tscn")


func _on_level_byg_pressed() -> void:
	if PlayerData.check_pass("碧游宫"):
		Global.cleanup_transient_ui()
		Global.change_scene("res://Scene/main_menu/map_5.tscn")
	else:
		if PlayerData.player_data["蓬莱仙境"] != 1:
			Global.add_message_show(get_parent(), "需要通关蓬莱仙境！！", 1.5, Vector2(470, 300))
		elif PlayerData.player_data[DataKeys.PLAYER_LEVEL] < 60:
			Global.add_message_show(get_parent(), "需要等级达到60级！！", 1.5, Vector2(470, 300))
		elif PlayerData.get_item_data("ttsl") == 0:
			Global.add_message_show(get_parent(), "需要通天赦令！！", 1.5, Vector2(470, 300))
		else:
			PlayerData.player_data["碧游宫"] = true
			Global.cleanup_transient_ui()
			Global.change_scene("res://Scene/main_menu/map_5.tscn")


func _on_level_esbxx_pressed() -> void:
	if PlayerData.player_data[DataKeys.PLAYER_LEVEL] < 60:
		Global.add_message_show(get_parent(), "玩家等级达60级开启！！", 1.5, Vector2(470, 300))
		return
	if PlayerData.player_data["尾妖林"] == 0:
		Global.add_message_show(get_parent(), "需通关尾妖林！！", 1.5, Vector2(470, 300))
		return
	Global.selected_constellation_level = 0
	Global.add_level_info(_ui_parent(), "挑战28星宿", Vector2.ZERO, "res://Scene/level/level_esbxx.tscn")


func _on_level_znyy_pressed() -> void:
	Global.add_message_show(get_parent(), "敬请期待！！！！", 1.5, Vector2(470, 300))
	return


func _on_hdzm_pressed() -> void:
	Global.add_hdzm(_ui_parent(), self)


func _on_memory_class_pressed() -> void:
	MemoryClass.save_game(Global.cd_path)
	Global.add_message_show(get_parent(), "保存成功！本作品完全免费，谨防受骗上当！", 1.5, Vector2(470, 300))


func _on_shop_pressed() -> void:
	Global.add_shop(_ui_parent(), Vector2(0, 0))


func _on_ldl_2_pressed() -> void:
	Global.add_ldl(_ui_parent(), Vector2(0, 0))


func _on_skill_pressed() -> void:
	if skill_target == null:
		skill_target = Global.add_learn_skill(_ui_parent(), Vector2(0, 0))
	else:
		skill_target.queue_free()


func _on_activity_pressed() -> void:
	Global.add_message_show(get_parent(), "敬请期待！！！！", 1.5, Vector2(470, 300))


func _on_task_pressed() -> void:
	Global.add_basic_task(_ui_parent(), Vector2(0, 0))


func _on_return_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_0.tscn")


func _on_game_set_pressed() -> void:
	Global.add_game_set(_ui_parent(), Vector2(0, 0))


func _on_game_an_pressed() -> void:
	Global.add_game_announcement(_ui_parent(), Vector2(0, 0))


func _on_pellet_pressed() -> void:
	Global.add_basic_pellet(_ui_parent(), Vector2(0, 0))


func check_pass_level():
	var can_enter_huolongdao = (
		PlayerData.player_data["截教天镜"] and PlayerData.player_data.玲珑宝塔 == 1 and PlayerData.get_item_data("ttlp") != 0
	)
	level_31.disabled = not can_enter_huolongdao

	level_32.disabled = not (PlayerData.player_data["火龙岛"] == 1)
	level_33.disabled = not (PlayerData.player_data["九龙岛"] == 1)
	level_34.disabled = not (PlayerData.player_data["龙脊山"] == 1)
	level_35.disabled = not (PlayerData.player_data["尾妖林"] == 1)
	level_36.disabled = not (PlayerData.player_data["仙音岛"] == 1)
	level_37.disabled = not (PlayerData.player_data["仙幻岛"] == 1)
	level_38.disabled = not (PlayerData.player_data["仙树岛"] == 1)
	level_39.disabled = not (PlayerData.player_data["蓬莱岛"] == 1)

	level_byg.disabled = not (PlayerData.player_data["蓬莱仙境"] == 1)

	level_esbxx.disabled = not (
		bool(PlayerData.player_data.get("隐藏地图全开", false))
		or (PlayerData.player_data[DataKeys.PLAYER_LEVEL] >= 60 and PlayerData.player_data["尾妖林"] == 1)
	)
	level_znyy.disabled = true

	for i in range(1, 11):
		play_an(i)


func play_an(Level):
	match int(Level):
		1:
			if PlayerData.get_item_data("ttlp") and PlayerData.player_data.玲珑宝塔 == 1:
				if PlayerData.player_data.九龙岛 == 0:
					level.play("Level_31")
				else:
					level_31.material = null
			else:
				level_31.material = null
		2:
			if PlayerData.player_data.九龙岛 == 0 and PlayerData.player_data.火龙岛 == 1:
				level.play("Level_32")
			else:
				level_32.material = null
		3:
			if PlayerData.player_data.龙脊山 == 0 and PlayerData.player_data.九龙岛 == 1:
				level.play("Level_33")
			else:
				level_33.material = null
		4:
			if PlayerData.player_data.尾妖林 == 0 and PlayerData.player_data.龙脊山 == 1:
				level.play("Level_34")
			else:
				level_34.material = null
		5:
			if PlayerData.player_data.仙音岛 == 0 and PlayerData.player_data.尾妖林 == 1:
				level.play("Level_35")
			else:
				level_35.material = null
		6:
			if PlayerData.player_data.仙幻岛 == 0 and PlayerData.player_data.仙音岛 == 1:
				level.play("Level_36")
			else:
				level_36.material = null
		7:
			if PlayerData.player_data.仙树岛 == 0 and PlayerData.player_data.仙幻岛 == 1:
				level.play("Level_37")
			else:
				level_37.material = null
		8:
			if PlayerData.player_data.蓬莱岛 == 0 and PlayerData.player_data.仙树岛 == 1:
				level.play("Level_38")
			else:
				level_38.material = null
		9:
			if PlayerData.player_data.蓬莱仙境 == 0 and PlayerData.player_data.蓬莱岛 == 1:
				level.play("Level_39")
			else:
				level_39.material = null
		10:
			if PlayerData.player_data["蓬莱仙境"] == 1 and not PlayerData.check_pass("碧游宫"):
				level.play("Level_byg")
			else:
				level_byg.material = null


func _on_level_lhhj_pressed() -> void:
	Global.addlhhj(_ui_parent(), Vector2(0, 0))

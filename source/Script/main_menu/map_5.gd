extends Node2D

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
	"next",
	"Pellet",
]
const RIGHT_ALIGNED_BUTTON_NAMES := [
	"SouthContinent",
	"WorldMapButton",
]
@onready var level: AnimationPlayer = $Level
@onready var level_40: TextureButton = $Level_40
@onready var level_41: TextureButton = $Level_41
@onready var level_42: TextureButton = $Level_42
@onready var level_43: TextureButton = $Level_43
@onready var level_44: TextureButton = $Level_44
@onready var level_45: TextureButton = $Level_45
@onready var level_46: TextureButton = $Level_46
@onready var south_continent := get_node_or_null("SouthContinent") as Button

var max_page: int = 5
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
	_map_shadow_shader.code = "\r\nshader_type canvas_item;\r\nuniform int side = 0;\r\nuniform vec2 rect_size = vec2(1.0, 1.0);\r\nuniform float solid_px = 0.0;\r\nuniform float fade_px = 55.0;\r\nuniform float noise_strength_px = 10.0;\r\nuniform float noise_scale_px = 85.0;\r\nuniform float alpha_power = 1.45;\r\n\r\nfloat hash(vec2 p) {\r\n    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);\r\n}\r\n\r\nfloat noise(vec2 p) {\r\n    vec2 i = floor(p);\r\n    vec2 f = fract(p);\r\n    vec2 u = f * f * (3.0 - 2.0 * f);\r\n    float a = hash(i);\r\n    float b = hash(i + vec2(1.0, 0.0));\r\n    float c = hash(i + vec2(0.0, 1.0));\r\n    float d = hash(i + vec2(1.0, 1.0));\r\n    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);\r\n}\r\n\r\nvoid fragment() {\r\n    vec2 px = UV * rect_size;\r\n    float inward_px = px.y;\r\n    float edge_axis_px = px.x;\r\n    if (side == 1) {\r\n        inward_px = rect_size.y - px.y;\r\n        edge_axis_px = px.x;\r\n    } else if (side == 2) {\r\n        inward_px = px.x;\r\n        edge_axis_px = px.y;\r\n    } else if (side == 3) {\r\n        inward_px = rect_size.x - px.x;\r\n        edge_axis_px = px.y;\r\n    }\r\n    float n1 = noise(vec2(edge_axis_px / noise_scale_px, 0.37));\r\n    float n2 = noise(vec2(edge_axis_px / (noise_scale_px * 0.43), 8.91));\r\n    float wobble_px = ((n1 * 0.72 + n2 * 0.28) - 0.5) * noise_strength_px;\r\n    float fade_t = clamp((inward_px - solid_px + wobble_px) / max(fade_px, 1.0), 0.0, 1.0);\r\n    fade_t = smoothstep(0.0, 1.0, fade_t);\r\n    float alpha = pow(1.0 - fade_t, alpha_power) * 0.68;\r\n    COLOR = vec4(0.0, 0.0, 0.0, alpha);\r\n}\r\n"

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
		var right_margin: float = MAP_DESIGN_SIZE.x - original_right_edge
		button.position = Vector2(
			MAP_DESIGN_SIZE.x - button.size.x - right_margin + position.x / fit_scale, button.position.y
		)


func _ready() -> void:
	LazyTextureButtonStates.setup(self)
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	Global.windows = _ui_parent()
	if not MainSet.set_data.get("LevelTT2", false):
		MainSet.set_data["LevelTT2"] = true
		MemoryClass.main_bc()

	Global.llbt_level = 1
	Global.llbtbossms = false
	Global.llbtcgms = false
	Global.llbtwxms = false
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = RoleProp.roleprop.Hp
	RoleProp.current_mp = RoleProp.roleprop.Mp

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
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()
	PlayerData.player_data["Map_num"] = 5
	PlayerData.player_data["HeavenMap_num"] = 5
	if not Global.cd_path.is_empty():
		MemoryClass.save_game(Global.cd_path)

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


func _is_map5_level_cleared(level_name: String) -> bool:
	return bool(PlayerData.player_data.get(level_name, false))


func _require_map5_prerequisite(level_name: String, message: String = "") -> bool:
	if _is_map5_level_cleared(level_name):
		return true
	var prompt := message if message != "" else "需要先通关" + level_name + "！"
	Global.add_message_show(_ui_parent(), prompt, 1.5, Vector2(470, 300))
	return false


func check_pass_level() -> void:
	level_40.disabled = false
	level_41.disabled = not _is_map5_level_cleared("绝仙门")
	level_42.disabled = not _is_map5_level_cleared("紫晶门")
	level_43.disabled = not _is_map5_level_cleared("戮仙门")
	level_44.disabled = not _is_map5_level_cleared("指景宫")
	level_45.disabled = not _is_map5_level_cleared("陷仙门")
	level_46.disabled = not _is_map5_level_cleared("绝境宫")
	if south_continent != null:
		south_continent.disabled = not _is_map5_level_cleared("通天教主")

	level.stop()
	for level_button in [level_40, level_41, level_42, level_43, level_44, level_45, level_46]:
		level_button.material = null

	var progression := [
		{"name": "绝仙门", "animation": "Level_40"},
		{"name": "紫晶门", "animation": "Level_41"},
		{"name": "戮仙门", "animation": "Level_42"},
		{"name": "指景宫", "animation": "Level_43"},
		{"name": "陷仙门", "animation": "Level_44"},
		{"name": "绝境宫", "animation": "Level_45"},
		{"name": "通天教主", "animation": "Level_46"},
	]
	for stage in progression:
		if not _is_map5_level_cleared(str(stage["name"])):
			level.play(str(stage["animation"]))
			break


func _on_level_40_pressed() -> void:
	Global.add_level_info(_ui_parent(), "绝仙门", Vector2(0, 0), "res://Scene/level/level_40.tscn")


func _on_level_41_pressed() -> void:
	if not _require_map5_prerequisite("绝仙门"):
		return
	Global.add_level_info(_ui_parent(), "紫晶门", Vector2(0, 0), "res://Scene/level/level_41.tscn")


func _on_level_42_pressed() -> void:
	if not _require_map5_prerequisite("紫晶门"):
		return
	Global.add_level_info(_ui_parent(), "戮仙门", Vector2(0, 0), "res://Scene/level/level_42.tscn")


func _on_level_43_pressed() -> void:
	if not _require_map5_prerequisite("戮仙门"):
		return
	Global.add_level_info(_ui_parent(), "指景宫", Vector2(0, 0), "res://Scene/level/level_43.tscn")


func _on_level_44_pressed() -> void:
	if not _require_map5_prerequisite("指景宫"):
		return
	Global.add_level_info(_ui_parent(), "陷仙门", Vector2(0, 0), "res://Scene/level/level_44.tscn")


func _on_level_45_pressed() -> void:
	if not _require_map5_prerequisite("陷仙门"):
		return
	Global.add_level_info(_ui_parent(), "绝境宫", Vector2(0, 0), "res://Scene/level/level_45.tscn")


func _on_level_46_pressed() -> void:
	if not _require_map5_prerequisite("绝境宫"):
		return
	Global.add_level_info(_ui_parent(), "通天教主", Vector2(0, 0), "res://Scene/level/level_46.tscn")


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


func _on_jjtj_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_4.tscn")


func _on_south_continent_pressed() -> void:
	if not _require_map5_prerequisite("通天教主", "通关通天教主后开启南瞻部洲！"):
		return
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_6.tscn")

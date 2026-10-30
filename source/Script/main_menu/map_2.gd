extends Node2D

const MAP_DESIGN_SIZE := Vector2(940.0, 590.0)
const MAP_SHADOW_FADE := 55.0
const RIGHT_ALIGNED_BUTTON_NAMES := [
	"changetomain",
	"Activity",
	"Learn_skill",
	"LdL",
	"MemoryGame",
	"shop",
	"GameAn",
	"BossTreasureCheckBox",
	"next",
	"WorldMapButton",
]
@onready var level_11: TextureButton = $Level_11
@onready var level_12: TextureButton = $Level_12
@onready var level_13: TextureButton = $Level_13
@onready var level_14: TextureButton = $Level_14
@onready var level_15: TextureButton = $Level_15
@onready var level_16: TextureButton = $Level_16
@onready var level_17: TextureButton = $Level_17
@onready var level_18: TextureButton = $Level_18
@onready var level_19: TextureButton = $Level_19
@onready var level_20: TextureButton = $Level_20
@onready var level_lxdy: TextureButton = $Level_lxdy
@onready var level: AnimationPlayer = $level
@onready var level_nmg: TextureButton = $Level_nmg

@onready var boss_treasure_checkbox: TextureButton = $BossTreasureCheckBox
var is_chest_mode: bool = false

var max_page: int = 2
var skill_target
var my_music
var _map_shadow_rects := []
var _map_shadow_shader: Shader
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
	_align_right_side_buttons(fit_scale)
	_cleanup_map_shadow_rects()


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


func _ready():
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)

	if MainSet.set_data.has("BossTreasureBoxMode"):
		is_chest_mode = MainSet.set_data["BossTreasureBoxMode"]
	else:
		is_chest_mode = false
		MainSet.set_data["BossTreasureBoxMode"] = false
		MemoryClass.main_bc()

	update_button_texture()

	Global.llbt_level = 1
	Global.llbtbossms = false
	Global.llbtcgms = false
	Global.llbtwxms = false
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = RoleProp.roleprop.Hp
	RoleProp.current_mp = RoleProp.roleprop.Mp
	for i in range(11):
		play_an(i)
	if MainSet.set_data["CurrentLevelPage"] <= max_page:
		MainSet.set_data["CurrentLevelPage"] = max_page
		MemoryClass.main_bc()
	Global.current_level = ""
	if not Global.is_frist:
		Global.add_message_show(Global.get_ui_runtime().windows, "欢迎进入游戏！作品完全免费！！", 1.5, Vector2(470, 300))
		Global.is_frist = true
	Global.player_be_hit_count = 0
	Global.last_level_path = ""
	Global.fb_cd = 0

	get_tree().paused = false
	PlayerData.player_data["Map_num"] = 2
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
	if not Global.get_audio_runtime().has_main_menu_music():
		Global.get_audio_runtime().add_main_menu_music()
	check_pass_level()


func update_button_texture():
	var tex_path = (
		"res://Art/game_3/other_map_button/bxdl.png" if is_chest_mode else "res://Art/game_3/other_map_button/sjdl.png"
	)
	var texture = load(tex_path)
	if texture:
		boss_treasure_checkbox.texture_normal = texture

		boss_treasure_checkbox.texture_hover = texture
		boss_treasure_checkbox.texture_pressed = texture
	else:
		print("错误：找不到纹理 ", tex_path)


func _on_boss_treasure_toggled():
	is_chest_mode = !is_chest_mode

	update_button_texture()

	MainSet.set_data["BossTreasureBoxMode"] = is_chest_mode
	MemoryClass.main_bc()

	var mode_text = "普通掉落模式" if not is_chest_mode else "宝箱掉落模式（Boss 将掉落自选宝箱）"
	Global.add_message_show(Global.get_ui_runtime().windows, mode_text, 1.5, Vector2(470, 300))


func _on_changetomain_pressed() -> void:
	Global.change_scene("res://Scene/main_menu/map_0.tscn")


func _on_ld_l_pressed() -> void:
	Global.add_ldl(_ui_parent(), Vector2(0, 0))


func _on_memory_game_pressed() -> void:
	MemoryClass.request_save("map_save")
	Global.add_message_show(get_parent(), "保存成功！本作品完全免费，谨防受骗上当！", 1.5, Vector2(470, 300))


func check_music():
	if MainSet.set_data["music"] == 1:
		if my_music != null:
			my_music.queue_free()

		my_music = Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/zmxy_1_bgm.mp3")
	elif MainSet.set_data["music"] == 2:
		if my_music != null:
			my_music.queue_free()
		my_music = Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/zmxy_2_bgm.mp3")
	elif MainSet.set_data["music"] == 3:
		if my_music != null:
			my_music.queue_free()
		my_music = Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/44_begin.mp3")
	elif MainSet.set_data["music"] == 4:
		if my_music != null:
			my_music.queue_free()
		my_music = Global.get_audio_runtime().add_bgm(self, "res://Music/main_scene_music/zmxy4bg.mp3")


func check_pass_level():
	if PlayerData.get_dj_page("mjlp") != 0 and PlayerData.player_data["地府"]:
		if PlayerData.player_data.牛魔谷 == 1 and PlayerData.get_dj_page("mjlp") != 0 and PlayerData.player_data["地府"]:
			level_11.disabled = false
		else:
			level_11.disabled = true
		if PlayerData.player_data.无常巷 == 1:
			level_12.disabled = false
		else:
			level_12.disabled = true
		if PlayerData.player_data.鬼门关 == 1:
			level_13.disabled = false
		else:
			level_13.disabled = true
		if PlayerData.player_data.接引院 == 1:
			level_14.disabled = false
		else:
			level_14.disabled = true
		if PlayerData.player_data.判官府 == 1:
			level_15.disabled = false
		else:
			level_15.disabled = true
		if PlayerData.player_data.阎罗殿 == 1:
			level_16.disabled = false
		else:
			level_16.disabled = true
		if PlayerData.player_data.忘川河 == 1:
			level_17.disabled = false
		else:
			level_17.disabled = true
		if PlayerData.player_data.奈何桥 == 1:
			level_18.disabled = false
		else:
			level_18.disabled = true
		if PlayerData.player_data.望乡台 == 1:
			level_19.disabled = false
		else:
			level_19.disabled = true
		if PlayerData.player_data.转轮殿 == 1:
			level_20.disabled = false
		else:
			level_20.disabled = true
	else:
		level_11.disabled = true
		level_12.disabled = true
		level_13.disabled = true
		level_14.disabled = true
		level_15.disabled = true
		level_16.disabled = true
		level_17.disabled = true
		level_18.disabled = true
		level_19.disabled = true
		level_20.disabled = true
		level_lxdy.disabled = true


func _on_button_pressed() -> void:
	Global.change_scene("res://Scene/main_menu/map_1.tscn")


func _on_level_11_pressed() -> void:
	Global.add_level_info(_ui_parent(), "鬼城", Vector2(0, 0), "res://Scene/level/level_11.tscn")


func _on_level_12_pressed() -> void:
	Global.add_level_info(_ui_parent(), "无常巷", Vector2(0, 0), "res://Scene/level/level_12.tscn")


func _on_level_13_pressed() -> void:
	Global.add_level_info(_ui_parent(), "鬼门关", Vector2(0, 0), "res://Scene/level/level_13.tscn")


func _on_level_14_pressed() -> void:
	Global.add_level_info(_ui_parent(), "接引院", Vector2(0, 0), "res://Scene/level/level_14.tscn")


func _on_level_15_pressed() -> void:
	Global.add_level_info(_ui_parent(), "判官府", Vector2(0, 0), "res://Scene/level/level_15.tscn")


func _on_level_16_pressed() -> void:
	Global.add_level_info(_ui_parent(), "阎罗殿", Vector2(0, 0), "res://Scene/level/level_16.tscn")


func _on_level_17_pressed() -> void:
	Global.add_level_info(_ui_parent(), "忘川河", Vector2(0, 0), "res://Scene/level/level_17.tscn")


func _on_level_18_pressed() -> void:
	Global.add_level_info(_ui_parent(), "奈何桥", Vector2(0, 0), "res://Scene/level/level_18.tscn")


func _on_level_19_pressed() -> void:
	Global.add_level_info(_ui_parent(), "望乡台", Vector2(0, 0), "res://Scene/level/level_19.tscn")


func _on_level_20_pressed() -> void:
	Global.add_level_info(_ui_parent(), "转轮殿", Vector2(0, 0), "res://Scene/level/level_21.tscn")


func _on_level_nmg_pressed() -> void:
	Global.add_level_info(_ui_parent(), "火焰山", Vector2(0, 0), "res://Scene/level/level_nmg.tscn")


func _on_level_lxdy_pressed() -> void:
	Global.add_lxdy(_ui_parent(), _ui_parent())


func _on_shop_pressed() -> void:
	Global.add_shop(_ui_parent(), Vector2(0, 0))


func _on_activity_pressed() -> void:
	Global.add_basic_task(_ui_parent(), Vector2(0, 0))


func _on_learn_skill_pressed() -> void:
	if skill_target == null:
		skill_target = Global.add_learn_skill(_ui_parent(), Vector2(0, 0))
	else:
		skill_target.queue_free()


func play_an(Level):
	match int(Level):
		1:
			if PlayerData.get_dj_page("mjlp"):
				level_nmg.material = null
				if not PlayerData.player_data.无常巷 == 1:
					level.play("level11")
				else:
					level_11.material = null
			else:
				level_11.material = null
				level.play("levelnmg")

		2:
			if PlayerData.player_data.鬼门关 == 0 and PlayerData.player_data.无常巷 == 1:
				level.play("level12")
			else:
				level_12.material = null
		3:
			if PlayerData.player_data.接引院 == 0 and PlayerData.player_data.鬼门关 == 1:
				level.play("level13")
			else:
				level_13.material = null
		4:
			if PlayerData.player_data.判官府 == 0 and PlayerData.player_data.接引院 == 1:
				level.play("level14")
			else:
				level_14.material = null
		5:
			if PlayerData.player_data.阎罗殿 == 0 and PlayerData.player_data.判官府 == 1:
				level.play("level15")
			else:
				level_15.material = null
		6:
			if PlayerData.player_data.忘川河 == 0 and PlayerData.player_data.阎罗殿 == 1:
				level.play("level16")
			else:
				level_16.material = null
		7:
			if PlayerData.player_data.奈何桥 == 0 and PlayerData.player_data.忘川河 == 1:
				level.play("level17")
			else:
				level_17.material = null
		8:
			if PlayerData.player_data.望乡台 == 0 and PlayerData.player_data.奈何桥 == 1:
				level.play("level18")
			else:
				level_18.material = null
		9:
			if PlayerData.player_data.转轮殿 == 0 and PlayerData.player_data.望乡台 == 1:
				level.play("level19")
			else:
				level_18.material = null
		10:
			if not PlayerData.player_data["天庭"] and PlayerData.player_data.转轮殿 == 1:
				level.play("level20")
			else:
				level_19.material = null


func _on_changetott_pressed() -> void:
	if PlayerData.check_pass("天庭"):
		Global.change_scene("res://Scene/main_menu/map_3.tscn")
	else:
		if PlayerData.player_data.转轮殿 != 1:
			Global.add_message_show(get_parent(), "需要通关转轮殿！！", 1.5, Vector2(470, 300))
		elif PlayerData.get_item_data("ttlp") == 0:
			Global.add_message_show(get_parent(), "需要通天令牌！！", 1.5, Vector2(470, 300))


func _on_game_an_pressed() -> void:
	Global.add_game_announcement(_ui_parent(), Vector2(0, 0))


func _on_level_lhhj_pressed() -> void:
	Global.addlhhj(_ui_parent(), Vector2(0, 0))

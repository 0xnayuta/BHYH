extends Node2D

const MAP_DESIGN_SIZE := Vector2(940.0, 590.0)
const MAP_SHADOW_FADE := 55.0
const LEFT_ALIGNED_BUTTON_NAMES := [
	"Shop",
	"bc_game",
	"Skill_learn",
	"GameAn",
	"BossTreasureCheckBox",
	"turn_mainmenu",
	"next",
]
const RIGHT_ALIGNED_BUTTON_NAMES := [
	"Task",
	"WorldMapButton",
]
@onready var level_1: TextureButton = $level_1
@onready var level_2: TextureButton = $level_2
@onready var level_3: TextureButton = $level_3
@onready var level_4: TextureButton = $level_4
@onready var level_5: TextureButton = $level_5
@onready var level_6: TextureButton = $level_6
@onready var level_7: TextureButton = $level_7
@onready var level_8: TextureButton = $level_8
@onready var level_9: TextureButton = $Node2D2/Node2D/level_9
@onready var level_10: TextureButton = $level_10
@onready var level: AnimationPlayer = $Level
@onready var level2: AnimationPlayer = $Level2

@onready var boss_treasure_checkbox: TextureButton = $BossTreasureCheckBox
var is_chest_mode: bool = false

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


var message
var skill_target
var is_playing = false
var max_page: int = 1


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
	PlayerData.player_data["Map_num"] = 1
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
	if MainMusic.my_main_music == null:
		MainMusic.add_music()
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


func _on_level_1_pressed() -> void:
	Global.add_level_info(_ui_parent(), "花果山", Vector2(0, 0), "res://Scene/level/level_1.tscn")


func _on_level_2_pressed() -> void:
	Global.add_level_info(_ui_parent(), "水帘洞", Vector2(0, 0), "res://Scene/level/level_2.tscn")


func _on_level_3_pressed() -> void:
	Global.add_level_info(_ui_parent(), "桃花源", Vector2(0, 0), "res://Scene/level/level_3.tscn")


func _on_level_4_pressed() -> void:
	Global.add_level_info(_ui_parent(), "蝙蝠窟", Vector2(0, 0), "res://Scene/level/level_4.tscn")


func _on_level_5_pressed() -> void:
	Global.add_level_info(_ui_parent(), "七星洞", Vector2(0, 0), "res://Scene/level/level_5.tscn")


func _on_level_6_pressed() -> void:
	Global.add_level_info(_ui_parent(), "迦楼罗之穴", Vector2(0, 0), "res://Scene/level/level_6.tscn")


func _on_level_7_pressed() -> void:
	Global.add_level_info(_ui_parent(), "浅岸", Vector2(0, 0), "res://Scene/level/level_7.tscn")


func _on_level_8_pressed() -> void:
	Global.add_level_info(_ui_parent(), "东海", Vector2(0, 0), "res://Scene/level/level_8.tscn")


func _on_level_9_pressed() -> void:
	Global.add_level_info(_ui_parent(), "鲨之涡流", Vector2(0, 0), "res://Scene/level/level_9.tscn")


func _on_level_10_pressed() -> void:
	Global.add_level_info(_ui_parent(), "牛魔谷", Vector2(0, 0), "res://Scene/level/level_10.tscn")


func check_music():
	if MainSet.set_data["music"] == 1:
		if my_music != null:
			my_music.queue_free()
		my_music = Global.add_bgm(self, "res://Music/main_scene_music/zmxy_1_bgm.mp3")
	elif MainSet.set_data["music"] == 2:
		if my_music != null:
			my_music.queue_free()
		my_music = Global.add_bgm(self, "res://Music/main_scene_music/zmxy_2_bgm.mp3")
	elif MainSet.set_data["music"] == 3:
		if my_music != null:
			my_music.queue_free()
		my_music = Global.add_bgm(self, "res://Music/main_scene_music/44_begin.mp3")
	elif MainSet.set_data["music"] == 4:
		if my_music != null:
			my_music.queue_free()
		my_music = Global.add_bgm(self, "res://Music/main_scene_music/zmxy4bg.mp3")


func _on_bc_game_pressed() -> void:
	MemoryClass.request_save("map_save")
	Global.add_message_show(get_parent(), "保存成功！本作品完全免费，谨防受骗上当！", 1.5, Vector2(470, 300))


func _on_skill_learn_pressed() -> void:
	if skill_target == null:
		skill_target = Global.add_learn_skill(_ui_parent(), Vector2(0, 0))
	else:
		skill_target.queue_free()


func check_pass_level():
	if PlayerData.player_data.水帘洞 == 1:
		level_2.disabled = false
	else:
		level_2.disabled = true
	if PlayerData.player_data.桃花源 == 1:
		level_3.disabled = false
	else:
		level_3.disabled = true
	if PlayerData.player_data.蝙蝠窟 == 1:
		level_4.disabled = false
	else:
		level_4.disabled = true
	if PlayerData.player_data.七星洞 == 1:
		level_5.disabled = false
	else:
		level_5.disabled = true
	if PlayerData.player_data.迦楼罗之穴 == 1:
		level_6.disabled = false
	else:
		level_6.disabled = true
	if PlayerData.player_data.浅岸 == 1:
		level_7.disabled = false
	else:
		level_7.disabled = true
	if PlayerData.player_data.东海 == 1:
		level_8.disabled = false
	else:
		level_8.disabled = true
	if PlayerData.player_data.鲨之涡流 == 1:
		level_9.disabled = false
	else:
		level_9.disabled = true
	if PlayerData.player_data.牛魔谷 == 1:
		level_10.disabled = false
	else:
		level_10.disabled = true


func _on_ldl_pressed() -> void:
	Global.add_ldl(_ui_parent(), Vector2(0, 0))


func _on_next_pressed() -> void:
	Global.change_scene("res://Scene/main_menu/map_2.tscn")


func _on_turn_mainmenu_pressed() -> void:
	Global.change_scene("res://Scene/main_menu/map_0.tscn")


func _on_shop_pressed() -> void:
	Global.add_shop(_ui_parent(), Vector2(0, 0))


func add_text(text, parent):
	if message == null:
		message = Global.add_touch_text(parent, Vector2(80, 0), text)


func remove_text():
	if message != null:
		message.queue_free()


func play_an(Level):
	match int(Level):
		1:
			if PlayerData.player_data.水帘洞 == 0:
				level.play("Level1")
			else:
				level_1.material = null
		2:
			if PlayerData.player_data.桃花源 == 0 and PlayerData.player_data.水帘洞 == 1:
				level.play("level2")
			else:
				level_2.material = null
		3:
			if PlayerData.player_data.蝙蝠窟 == 0 and PlayerData.player_data.桃花源 == 1:
				level.play("level3")
			else:
				level_3.material = null
		4:
			if PlayerData.player_data.七星洞 == 0 and PlayerData.player_data.蝙蝠窟 == 1:
				level.play("level4")
			else:
				level_4.material = null
		5:
			if PlayerData.player_data.迦楼罗之穴 == 0 and PlayerData.player_data.七星洞 == 1:
				level.play("level5")
			else:
				level_5.material = null
		6:
			if PlayerData.player_data.浅岸 == 0 and PlayerData.player_data.迦楼罗之穴 == 1:
				level.play("level6")
			else:
				level_6.material = null
		7:
			if PlayerData.player_data.东海 == 0 and PlayerData.player_data.浅岸 == 1:
				level.play("level7")
			else:
				level_7.material = null
		8:
			if PlayerData.player_data.鲨之涡流 == 0 and PlayerData.player_data.东海 == 1:
				level.play("level8")
			else:
				level_8.material = null
		9:
			if PlayerData.player_data.鲨之涡流 == 1:
				level2.play("szwl")

		10:
			if not PlayerData.player_data["地府"] and PlayerData.player_data.牛魔谷 == 1:
				level.play("level10")
			else:
				level_10.material = null


func _on_level_1_mouse_entered() -> void:
	pass


func _on_level_1_mouse_exited() -> void:
	if not level_1.disabled:
		play_an(1)


func _on_level_2_mouse_entered() -> void:
	pass


func _on_level_2_mouse_exited() -> void:
	if not level_2.disabled:
		play_an(2)


func _on_level_3_mouse_entered() -> void:
	pass


func _on_level_3_mouse_exited() -> void:
	if not level_3.disabled:
		play_an(3)


func _on_level_4_mouse_entered() -> void:
	pass


func _on_level_4_mouse_exited() -> void:
	if not level_4.disabled:
		play_an(4)


func _on_level_5_mouse_entered() -> void:
	pass


func _on_level_5_mouse_exited() -> void:
	if not level_5.disabled:
		play_an(5)


func _on_level_6_mouse_entered() -> void:
	pass


func _on_level_6_mouse_exited() -> void:
	if not level_6.disabled:
		play_an(6)


func _on_level_7_mouse_entered() -> void:
	pass


func _on_level_7_mouse_exited() -> void:
	if not level_7.disabled:
		play_an(7)


func _on_level_8_mouse_entered() -> void:
	pass


func _on_level_8_mouse_exited() -> void:
	if not level_8.disabled:
		play_an(8)


func _on_level_9_mouse_entered() -> void:
	if not level_9.disabled:
		level2.play("szwl2")


func _on_level_9_mouse_exited() -> void:
	if not level_9.disabled:
		level2.play("szwl")


func _on_level_10_mouse_entered() -> void:
	pass


func _on_level_10_mouse_exited() -> void:
	if not level_8.disabled:
		play_an(10)


func _on_task_pressed() -> void:
	Global.add_basic_task(_ui_parent(), Vector2(0, 0))


func _on_game_an_pressed() -> void:
	Global.add_game_announcement(_ui_parent(), Vector2(0, 0))


func _on_level_lhhj_pressed() -> void:
	Global.addlhhj(_ui_parent(), Vector2(0, 0))

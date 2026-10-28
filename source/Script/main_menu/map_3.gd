extends Node2D
class_name Map3

const MAP_DESIGN_SIZE := Vector2(940.0, 590.0)
const MAP_SHADOW_FADE := 55.0
const ZHUXIAN_SWORD_PAGE_PATH := "res://Scene/main_menu/zhu_xian_sword_page.tscn"
const RIGHT_ALIGNED_BUTTON_NAMES := [
	"level_lhhj",
	"bxgh",
	"next",
	"Button",
	"ZhuXianSwordButton",
	"ChallengeFourSwordsButton",
	"WorldMapButton",
]
const LEFT_ALIGNED_BUTTON_NAMES := [
	"MemoryGame",
	"Shop",
	"ldl",
	"LearnSkill",
	"Actity",
	"Task",
	"ReturnToMainMenu",
	"GameSet",
	"GameAn",
	"BossTreasureCheckBox",
	"Pellet",
]
@onready var level: AnimationPlayer = $Level

@onready var level_21: TextureButton = $Level_21
@onready var level_22: TextureButton = $Level_22
@onready var level_23: TextureButton = $Level_23
@onready var level_24: TextureButton = $Level_24
@onready var level_25: TextureButton = $Level_25
@onready var level_26: TextureButton = $Level_26
@onready var level_27: TextureButton = $Level_27
@onready var level_28: TextureButton = $Level_28
@onready var level_29: TextureButton = $Level_29
@onready var level_30: TextureButton = $Level_30
@onready var level_stz: TextureButton = $Level_stz
@onready var level_dsg: TextureButton = $Level_dsg
@onready var level_hdzm: TextureButton = $Level_hdzm
@onready var level_sssl: TextureButton = $Level_sssl
@onready var smdp: TextureButton = $smdp
@onready var lsh: TextureButton = $lsh
@onready var kls: TextureButton = $kls
@onready var ghg: TextureButton = $ghg
@onready var bxgh: TextureButton = $bxgh
@onready var tzhy: TextureButton = $tzhy
@onready var memory_game: TextureButton = $MemoryGame
@onready var shop: TextureButton = $Shop
@onready var ldl: TextureButton = $ldl
@onready var learn_skill: TextureButton = $LearnSkill
@onready var actity: TextureButton = $Actity
@onready var task: TextureButton = $Task
@onready var return_to_main_menu: TextureButton = $ReturnToMainMenu
@onready var game_set: TextureButton = $GameSet

@onready var boss_treasure_checkbox: TextureButton = $BossTreasureCheckBox
@onready var challenge_four_swords_panel: Control = get_node_or_null("ChallengeFourSwordsPanel")
var is_chest_mode: bool = false

var max_page: int = 3
var skill_target
var my_music
var zhuxian_sword_page: Node = null
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
		get_parent().add_child.call_deferred(rect)
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


func _ready():
	_sync_special_button_layer()
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

	MainSet.set_data["LevelTT"] = true
	MemoryClass.main_bc()
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()
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
	if MainMusic.my_main_music == null:
		MainMusic.add_music()
	Global.current_level = ""
	if Global.windows == null:
		Global.windows = _ui_parent()
	if not Global.is_frist:
		Global.add_message_show(Global.windows, "欢迎进入游戏！作品完全免费！！", 1.5, Vector2(470, 300))
		Global.is_frist = true
	Global.player_be_hit_count = 0
	Global.last_level_path = ""
	Global.fb_cd = 0

	get_tree().paused = false
	PlayerData.player_data["Map_num"] = 3
	PlayerData.player_data["HeavenMap_num"] = 3
	if not Global.cd_path.is_empty():
		MemoryClass.request_save("map_enter")


func _sync_special_button_layer() -> void:
	for node_path in ["ZhuXianSwordButton", "ChallengeFourSwordsButton"]:
		var node := get_node_or_null(node_path) as CanvasItem
		if node != null:
			node.z_index = 0
	if not Global.cd_path.is_empty() and Global.cd_path.contains("Ar_"):
		MemoryClass.request_save("map_3_special")
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
	Global.add_message_show(Global.windows, mode_text, 1.5, Vector2(470, 300))


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


func check_pass_level():
	var heaven_unlocked := (
		bool(PlayerData.player_data.get("天庭", false)) or int(PlayerData.player_data.get("转轮殿", 0)) == 1
	)
	if heaven_unlocked:
		PlayerData.player_data["九重天"] = 1
		level_21.disabled = false
		if PlayerData.player_data["天宫道"] == 1:
			level_22.disabled = false
		else:
			level_22.disabled = true
		if PlayerData.player_data["南天门"] == 1:
			level_23.disabled = false
		else:
			level_23.disabled = true
		if PlayerData.player_data["南天王殿"] == 1:
			level_24.disabled = false
		else:
			level_24.disabled = true
		if PlayerData.player_data["西天王殿"] == 1:
			level_25.disabled = false
		else:
			level_25.disabled = true
		if PlayerData.player_data["北天王殿"] == 1:
			level_26.disabled = false
		else:
			level_26.disabled = true
		if PlayerData.player_data["彩虹楼"] == 1:
			level_27.disabled = false
		else:
			level_27.disabled = true
		if PlayerData.player_data["朝会殿"] == 1:
			level_28.disabled = false
		else:
			level_28.disabled = true
		if PlayerData.player_data["凌霄宝殿"] == 1:
			level_29.disabled = false
		else:
			level_29.disabled = true
		if int(PlayerData.player_data.get("玲珑宝塔", 0)) == 1:
			level_30.disabled = false
		else:
			level_30.disabled = true
		if int(PlayerData.player_data.get("兜率宫", 0)) == 1:
			level_dsg.disabled = false
		else:
			level_dsg.disabled = true
		if PlayerData.player_data["截教天镜"]:
			level_hdzm.disabled = false
		else:
			level_hdzm.disabled = true
		level_stz.disabled = false

		level_hdzm.disabled = false
		level_sssl.disabled = false
		lsh.disabled = false
		kls.disabled = false
		ghg.disabled = false
		tzhy.disabled = false
	else:
		level_21.disabled = true
		level_22.disabled = true
		level_23.disabled = true
		level_24.disabled = true
		level_25.disabled = true
		level_26.disabled = true
		level_27.disabled = true
		level_28.disabled = true
		level_29.disabled = true
		level_30.disabled = true
		level_stz.disabled = true
		level_dsg.disabled = true
		level_hdzm.disabled = true
		level_sssl.disabled = true
		lsh.disabled = true
		ghg.disabled = true
		tzhy.disabled = true

	kls.disabled = false


func _on_level_21_pressed() -> void:
	Global.add_level_info(_ui_parent(), "九重天", Vector2(0, 0), "res://Scene/level/level_22.tscn")


func _on_level_22_pressed() -> void:
	Global.add_level_info(_ui_parent(), "天宫道", Vector2(0, 0), "res://Scene/level/level_23.tscn")


func _on_level_23_pressed() -> void:
	Global.add_level_info(_ui_parent(), "南天门", Vector2(0, 0), "res://Scene/level/level_24.tscn")


func _on_level_24_pressed() -> void:
	Global.add_level_info(_ui_parent(), "南天王殿", Vector2(0, 0), "res://Scene/level/level_25.tscn")


func _on_level_25_pressed() -> void:
	Global.add_level_info(_ui_parent(), "西天王殿", Vector2(0, 0), "res://Scene/level/level_26.tscn")


func _on_level_26_pressed() -> void:
	Global.add_level_info(_ui_parent(), "北天王殿", Vector2(0, 0), "res://Scene/level/level_27.tscn")


func _on_level_27_pressed() -> void:
	Global.add_level_info(_ui_parent(), "彩虹楼", Vector2(0, 0), "res://Scene/level/level_28.tscn")


func _on_level_28_pressed() -> void:
	Global.add_level_info(_ui_parent(), "朝会殿", Vector2(0, 0), "res://Scene/level/level_29.tscn")


func _on_level_29_pressed() -> void:
	Global.add_level_info(_ui_parent(), "凌霄宝殿", Vector2(0, 0), "res://Scene/level/level_30.tscn")


func _on_level_30_pressed() -> void:
	Global.add_level_info(_ui_parent(), "玲珑宝塔", Vector2(0, 0), "res://Scene/level/level_llbt.tscn")


func _on_level_stz_pressed() -> void:
	Global.selected_three_prince_id = 0
	Global.add_level_info(_ui_parent(), "挑战三太子", Vector2(0, 0), "res://Scene/level/level_stz.tscn")


func _on_level_dsg_pressed() -> void:
	if int(PlayerData.player_data.get("兜率宫", 0)) == 0:
		Global.add_message_show(get_parent(), "需通关玲珑宝塔！", 1.5, Vector2(470, 300))
	else:
		Global.add_level_info(_ui_parent(), "兜率宫", Vector2(0, 0), "兜率宫")


func _on_level_hdzm_pressed() -> void:
	if PlayerData.player_data.截教天镜 == false:
		Global.add_message_show(get_parent(), "需通关兜率宫！", 1.5, Vector2(470, 300))
	else:
		Global.add_hdzm(_ui_parent(), self)


func _on_level_sssl_pressed() -> void:
	Global.add_level_info(_ui_parent(), "神兽森林", Vector2(0, 0), "res://Scene/level/level_sssl.tscn")


func _on_smdp_pressed() -> void:
	Global.add_mystery_shop(_ui_parent(), Vector2(0, 0))


func _on_lsh_pressed() -> void:
	Global.add_lsh(_ui_parent(), _ui_parent())


func _on_kls_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/level/level_kls.tscn")


func _on_ghg_pressed() -> void:
	Global.add_level_info(_ui_parent(), "广寒宫", Vector2(0, 0), "res://Scene/level/level_ghg.tscn")


func _on_bxgh_pressed() -> void:
	Global.selected_eight_immortal_id = 0
	Global.add_level_info(_ui_parent(), "八仙过海", Vector2(0, 0), "res://Scene/level/level_bxgh.tscn")


func _on_tzhy_pressed() -> void:
	if PlayerData.player_data[DataKeys.PLAYER_LEVEL] < 40:
		Global.add_message_show(get_parent(), "需要角色等级大于等于40级！", 1.5, Vector2(470, 300))
		return
	Global.change_scene("res://Scene/level/level_tzhy.tscn")


func _on_memory_game_pressed() -> void:
	MemoryClass.request_save("map_save")
	Global.add_message_show(get_parent(), "保存成功！本作品完全免费，谨防受骗上当！", 1.5, Vector2(470, 300))


func _on_shop_pressed() -> void:
	Global.add_shop(_ui_parent(), Vector2(0, 0))


func _on_ldl_pressed() -> void:
	Global.add_ldl(_ui_parent(), Vector2(0, 0))


func _on_learn_skill_pressed() -> void:
	if skill_target == null:
		skill_target = Global.add_learn_skill(_ui_parent(), Vector2(0, 0))
	else:
		skill_target.queue_free()


func _on_actity_pressed() -> void:
	Global.add_message_show(get_parent(), "敬请期待！！！！", 1.5, Vector2(470, 300))


func _on_task_pressed() -> void:
	Global.add_basic_task(_ui_parent(), Vector2(0, 0))


func _on_return_to_main_menu_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_0.tscn")


func _on_game_set_pressed() -> void:
	Global.add_game_set(_ui_parent(), Vector2(0, 0))


func _on_next_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_1.tscn")


func _on_button_cs() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/level/level_39.tscn")


func _on_button_pressed() -> void:
	Global.cleanup_transient_ui()
	Global.change_scene("res://Scene/main_menu/map_2.tscn")


func _on_game_an_pressed() -> void:
	Global.add_game_announcement(_ui_parent(), Vector2(0, 0))


func _on_pellet_pressed() -> void:
	Global.add_basic_pellet(_ui_parent(), Vector2(0, 0))


func _on_zhu_xian_sword_pressed() -> void:
	if zhuxian_sword_page != null and is_instance_valid(zhuxian_sword_page):
		zhuxian_sword_page.queue_free()
		zhuxian_sword_page = null
		return
	var page_scene := load(ZHUXIAN_SWORD_PAGE_PATH) as PackedScene
	if page_scene == null:
		Global.add_message_show(_ui_parent(), "诛仙剑阵页面加载失败", 1.5, Vector2(470, 300))
		return
	zhuxian_sword_page = page_scene.instantiate()
	var popup_parent := Global.get_ui_popup_layer() if Global.has_method("get_ui_popup_layer") else _ui_parent()
	popup_parent.add_child(zhuxian_sword_page)


func _on_challenge_four_swords_pressed() -> void:
	_hide_challenge_four_swords_panel()
	Global.add_level_info(_ui_parent(), "挑战四剑", Vector2(0, 0), "res://Scene/level/level_tzsijian.tscn")


func _on_challenge_four_swords_close_pressed() -> void:
	_hide_challenge_four_swords_panel()


func _enter_challenge_four_swords(level_name: String, level_path: String) -> void:
	var prerequisites := {
		"紫晶门": "绝仙门",
		"戮仙门": "紫晶门",
		"指景宫": "戮仙门",
	}
	var prerequisite := str(prerequisites.get(level_name, ""))
	if prerequisite != "" and not bool(PlayerData.player_data.get(prerequisite, false)):
		Global.add_message_show(_ui_parent(), "需要先通关" + prerequisite + "！", 1.5, Vector2(470, 300))
		return
	_hide_challenge_four_swords_panel()
	Global.add_level_info(_ui_parent(), level_name, Vector2(0, 0), level_path)


func _hide_challenge_four_swords_panel() -> void:
	if challenge_four_swords_panel != null and is_instance_valid(challenge_four_swords_panel):
		challenge_four_swords_panel.visible = false


func _on_challenge_jxm_pressed() -> void:
	_enter_challenge_four_swords("绝仙门", "res://Scene/level/level_40.tscn")


func _on_challenge_zjm_pressed() -> void:
	_enter_challenge_four_swords("紫晶门", "res://Scene/level/level_41.tscn")


func _on_challenge_lxm_pressed() -> void:
	_enter_challenge_four_swords("戮仙门", "res://Scene/level/level_42.tscn")


func _on_challenge_zjg_pressed() -> void:
	_enter_challenge_four_swords("指景宫", "res://Scene/level/level_43.tscn")


func play_an(Level):
	match int(Level):
		1:
			if PlayerData.get_item_data("ttlp"):
				if not PlayerData.player_data.天宫道 == 1:
					level.play("Level_21")
				else:
					level_21.material = null
			else:
				level_21.material = null
		2:
			if PlayerData.player_data.南天门 == 0 and PlayerData.player_data.天宫道 == 1:
				level.play("Level_22")
			else:
				level_22.material = null
		3:
			if PlayerData.player_data.南天王殿 == 0 and PlayerData.player_data.南天门 == 1:
				level.play("Level_23")
			else:
				level_23.material = null
		4:
			if PlayerData.player_data.西天王殿 == 0 and PlayerData.player_data.南天王殿 == 1:
				level.play("Level_24")
			else:
				level_24.material = null
		5:
			if PlayerData.player_data.北天王殿 == 0 and PlayerData.player_data.西天王殿 == 1:
				level.play("Level_25")
			else:
				level_25.material = null
		6:
			if PlayerData.player_data.彩虹楼 == 0 and PlayerData.player_data.北天王殿 == 1:
				level.play("Level_26")
			else:
				level_26.material = null
		7:
			if PlayerData.player_data.朝会殿 == 0 and PlayerData.player_data.彩虹楼 == 1:
				level.play("Level_27")
			else:
				level_27.material = null
		8:
			if PlayerData.player_data.凌霄宝殿 == 0 and PlayerData.player_data.朝会殿 == 1:
				level.play("Level_28")
			else:
				level_28.material = null
		9:
			if int(PlayerData.player_data.get("玲珑宝塔", 0)) == 0 and int(PlayerData.player_data.get("凌霄宝殿", 0)) == 1:
				level.play("Level_29")
			else:
				level_28.material = null
		10:
			if (
				not bool(PlayerData.player_data.get("截教天镜", false))
				and int(PlayerData.player_data.get("玲珑宝塔", 0)) == 1
				and int(PlayerData.player_data.get("兜率宫", 0)) != 1
			):
				level.play("Level_30")
			else:
				level_29.material = null


func _on_level_lhhj_pressed() -> void:
	Global.addlhhj(_ui_parent(), Vector2(0, 0))

extends CanvasLayer

@onready var role_cards: HBoxContainer = $FitRoot/RoleCards
@onready var shengcun: HBoxContainer = $FitRoot/InfoPanel/Stats/shengcun
@onready var gongji: HBoxContainer = $FitRoot/InfoPanel/Stats/gongji
@onready var minjie: HBoxContainer = $FitRoot/InfoPanel/Stats/minjie
@onready var caozuo: HBoxContainer = $FitRoot/InfoPanel/Stats/caozuo
@onready var role_name: Label = $FitRoot/InfoPanel/RoleName
@onready var prop: Label = $FitRoot/InfoPanel/Prop
@onready var info: Label = $FitRoot/InfoPanel/Info
@onready var start_button: TextureButton = $FitRoot/qued

var role_name_list := ["孙悟空", "唐三藏", "猪八戒", "沙悟净", "小白龙", "哪吒", "玉兔"]
var property_list := ["火", "水", "土", "木", "金", "火", "木"]
var color_list := ["ff4c30", "02ffff", "d27c21", "27d957", "ffff55", "ff6a32", "bda0ff"]
var role_info := [
	"齐天大圣孙悟空，机敏聪慧，胆识过人。善用棍法，灵活多变，上手简单。",
	"金蝉转世唐三藏，佛法无边，普渡众生。擅长爆发与回复，适合稳扎稳打。",
	"天蓬元帅猪八戒，力大无穷，坚韧不拔。生存能力强，上手简单。",
	"卷帘大将沙悟净，为人谨慎，朴实无华。擅用猛毒，成长上限高。",
	"玉龙三太子小白龙，智勇双全，刚正不阿。手持长枪，机制多样，操作灵活。",
	"灵珠转世哪吒，脚踏风火轮，手持火尖枪。攻势迅捷，擅长持续追击与多段攻击。",
	"广寒玉兔，双刀映月。药毒与月刃十式兼修，灵巧迅捷。",
]
var role_id_to_index := {"swk": 1, "tsz": 2, "zbj": 3, "swj": 4, "xbl": 5, "nz": 6, "yt": 7}
var shengcun_star := [0, 4, 3, 4, 4, 3, 3, 3]
var gongji_star := [0, 3, 5, 2, 4, 3, 5, 4]
var minjie_star := [0, 5, 3, 4, 3, 4, 5, 5]
var caozuo_star := [0, 3, 4, 3, 4, 5, 4, 4]
var current_choose: int = 0
var selected_roles: Array[int] = [0, 0]
var selecting_slot := 1
var coop_enabled := false
var p2_marker: TextureRect
var reset_button: TextureButton
var role_card_normal := [
	preload("res://Art/main_game/choose_player_zm4/19.png"),
	preload("res://Art/main_game/choose_player_zm4/30.png"),
	preload("res://Art/main_game/choose_player_zm4/40.png"),
	preload("res://Art/main_game/choose_player_zm4/50.png"),
	preload("res://Art/main_game/choose_player_zm4/60.png"),
	preload("res://Art/main_game/choose_player_zm4/nezha_normal.png"),
	preload("res://Art/main_game/choose_player_zm4/yutu_normal.png"),
]
var role_card_hover := [
	preload("res://Art/main_game/choose_player_zm4/25.png"),
	preload("res://Art/main_game/choose_player_zm4/35.png"),
	preload("res://Art/main_game/choose_player_zm4/45.png"),
	preload("res://Art/main_game/choose_player_zm4/55.png"),
	preload("res://Art/main_game/choose_player_zm4/65.png"),
	preload("res://Art/main_game/choose_player_zm4/nezha_hover.png"),
	preload("res://Art/main_game/choose_player_zm4/yutu_hover.png"),
]
var role_card_selected := [
	preload("res://Art/main_game/choose_player_zm4/27.png"),
	preload("res://Art/main_game/choose_player_zm4/37.png"),
	preload("res://Art/main_game/choose_player_zm4/47.png"),
	preload("res://Art/main_game/choose_player_zm4/57.png"),
	preload("res://Art/main_game/choose_player_zm4/67.png"),
	preload("res://Art/main_game/choose_player_zm4/nezha_selected.png"),
	preload("res://Art/main_game/choose_player_zm4/yutu_selected.png"),
]
var start_button_normal := preload("res://Art/main_game/choose_player_zm4/90.png")
var start_button_hover := preload("res://Art/main_game/choose_player_zm4/92.png")
var start_button_pressed := preload("res://Art/main_game/choose_player_zm4/93.png")
var player_one_icon := preload("res://Art/main_game/choose_player_zm4/2_1_p.png")
var selected_player_icon := TextureRect.new()


func _fit_choose_player_to_viewport() -> void:
	var design_size := Vector2(940, 590)
	var viewport_size = get_viewport().get_visible_rect().size
	var fit_scale = min(viewport_size.x / design_size.x, viewport_size.y / design_size.y)
	var fit_root := $FitRoot as Control
	fit_root.scale = Vector2(fit_scale, fit_scale)
	fit_root.position = (viewport_size - design_size * fit_scale) * 0.5


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_fit_choose_player_to_viewport()


func _ready() -> void:
	coop_enabled = not OS.has_feature("mobile") and LocalCoop.creation_player_count == 2
	LocalCoop.creation_player_count = 1
	var yutu := TextureButton.new()
	yutu.name = "Role7"
	yutu.ignore_texture_size = true
	yutu.stretch_mode = TextureButton.STRETCH_KEEP
	yutu.pressed.connect(_on_role_card_pressed.bind(7))
	yutu.mouse_entered.connect(_on_role_card_mouse_entered.bind(7))
	yutu.mouse_exited.connect(_on_role_card_mouse_exited.bind(7))
	role_cards.add_child(yutu)
	role_cards.move_child(yutu, 5)
	var yutu_text := TextureRect.new()
	yutu_text.name = "Hover7"
	yutu_text.texture = preload("res://Art/main_game/choose_player_zm4/yutu_hover_text.png")
	yutu_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	yutu_text.hide()
	$FitRoot/HoverIcons.add_child(yutu_text)
	role_cards.add_theme_constant_override("separation", 0)
	for card: Control in role_cards.get_children():
		card.custom_minimum_size = Vector2(130, 530)
		if card is TextureButton:
			card.ignore_texture_size = true
			card.stretch_mode = TextureButton.STRETCH_KEEP
	_fit_choose_player_to_viewport()
	selected_player_icon.texture = player_one_icon
	selected_player_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selected_player_icon.size = player_one_icon.get_size()
	selected_player_icon.z_index = 10
	selected_player_icon.visible = false
	_refresh_role_cards()
	_clear_role_info()
	_create_coop_controls()


func _clear_role_info() -> void:
	role_name.text = ""
	prop.text = ""
	info.text = "请选择角色"
	start_button.disabled = true


func _refresh_role_cards() -> void:
	for i in range(1, 8):
		var button := role_cards.get_node_or_null("Role" + str(i)) as TextureButton
		if button == null:
			continue
		var selected := i == selected_roles[0] or (coop_enabled and i == selected_roles[1])
		button.texture_normal = role_card_selected[i - 1] if selected else role_card_normal[i - 1]
		button.texture_hover = role_card_selected[i - 1] if selected else role_card_hover[i - 1]
		button.texture_pressed = role_card_selected[i - 1]
		button.texture_disabled = role_card_normal[i - 1]
		button.disabled = coop_enabled and selected_roles[1] > 0
		button.modulate = Color.WHITE
		button.scale = Vector2.ONE
		button.z_index = 0
	start_button.texture_normal = start_button_normal
	start_button.texture_hover = start_button_hover
	start_button.texture_pressed = start_button_pressed
	start_button.disabled = selected_roles[0] == 0 or (coop_enabled and selected_roles[1] == 0)
	if selected_roles[0] >= 1 and selected_roles[0] <= 7:
		var selected_button := role_cards.get_node_or_null("Role" + str(selected_roles[0])) as TextureButton
		if selected_button != null:
			if selected_player_icon.get_parent() == null:
				selected_button.add_child(selected_player_icon)
			elif selected_player_icon.get_parent() != selected_button:
				selected_player_icon.reparent(selected_button, false)
			selected_player_icon.position = Vector2(1, 18)
			selected_player_icon.visible = true
	else:
		selected_player_icon.visible = false


func set_role(role_id: int) -> void:
	if role_id <= 0 or role_id > role_name_list.size():
		return
	current_choose = role_id
	selected_roles[selecting_slot - 1] = role_id
	if coop_enabled and selecting_slot < 2:
		selecting_slot += 1
	role_name.text = role_name_list[current_choose - 1]
	info.text = role_info[current_choose - 1]
	prop.text = "属性：" + property_list[current_choose - 1]
	prop.add_theme_color_override("font_color", Color.html(color_list[current_choose - 1]))
	_hide_all_hover_icons()
	_refresh_stars()
	_refresh_selected_card()


func _refresh_selected_card() -> void:
	_refresh_role_cards()
	_refresh_p2_marker()
	call_deferred("_refresh_p2_marker")


func _refresh_stars() -> void:
	_clear_children(shengcun)
	_clear_children(gongji)
	_clear_children(minjie)
	_clear_children(caozuo)
	_add_stars(shengcun, shengcun_star[current_choose])
	_add_stars(gongji, gongji_star[current_choose])
	_add_stars(minjie, minjie_star[current_choose])
	_add_stars(caozuo, caozuo_star[current_choose])


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


func _add_stars(parent: Node, filled: int) -> void:
	for index in range(5):
		var star := Label.new()
		star.text = "★" if index < filled else "☆"
		star.add_theme_color_override("font_color", Color(1.0, 0.78, 0.25))
		parent.add_child(star)


func _on_role_card_pressed(role_id: int) -> void:
	set_role(role_id)


func _set_hover_icon(role_id: int, show_icon: bool) -> void:
	var icon := get_node_or_null("FitRoot/HoverIcons/Hover" + str(role_id)) as TextureRect
	if icon == null:
		return
	var card := role_cards.get_node("Role" + str(role_id)) as Control
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size = Vector2(138, 66) * role_cards.scale
	icon.position = (
		role_cards.position
		+ card.position * role_cards.scale
		+ Vector2((card.size.x * role_cards.scale.x - icon.size.x) * 0.5, 271)
	)
	icon.visible = show_icon


func _hide_all_hover_icons() -> void:
	for i in range(1, 8):
		_set_hover_icon(i, false)


func _on_role_card_mouse_entered(role_id: int) -> void:
	if role_id >= 1 and role_id <= 7 and role_id != current_choose:
		_set_hover_icon(role_id, true)


func _on_role_card_mouse_exited(role_id: int) -> void:
	_set_hover_icon(role_id, false)


func _on_return_main_menu_pressed() -> void:
	Global.cd_path = ""
	Global.change_scene("res://Scene/main_menu/main_menu.tscn")


func _on_qued_pressed() -> void:
	if selected_roles[0] < 1 or selected_roles[0] > 7:
		return
	if coop_enabled and (selected_roles[1] < 1 or selected_roles[1] > 7):
		return

	PlayerData.player_data["Myself"] = selected_roles[0]
	if coop_enabled:
		LocalCoop.create_secondary(selected_roles[1])
	else:
		LocalCoop.clear_runtime()
		PlayerData.player_data.erase(LocalCoop.SAVE_KEY)
	if not MemoryClass.request_save("choose_player"):
		Global.add_message_show(self, "存档保存失败，请重试", 1.5, Vector2(470, 340))
		return
	await Global.begin_archive_session()
	Global.change_scene("res://Scene/main_menu/map_0.tscn")


func _create_coop_controls() -> void:
	if not coop_enabled:
		return
	reset_button = TextureButton.new()
	reset_button.name = "ResetSelection"
	reset_button.position = Vector2(717.5, 523.45)
	reset_button.texture_normal = preload("res://Art/main_game/choose_player_zm4/12.png")
	reset_button.texture_hover = preload("res://Art/main_game/choose_player_zm4/14.png")
	reset_button.texture_pressed = preload("res://Art/main_game/choose_player_zm4/16.png")
	reset_button.pressed.connect(_reset_selection)
	$FitRoot.add_child(reset_button)
	p2_marker = TextureRect.new()
	p2_marker.texture = preload("res://Art/main_game/choose_player_zm4/1_2_p.png")
	p2_marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p2_marker.size = player_one_icon.get_size()
	p2_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p2_marker.z_index = 11
	$FitRoot.add_child(p2_marker)
	p2_marker.hide()


func _refresh_p2_marker() -> void:
	if not is_instance_valid(p2_marker):
		return
	p2_marker.visible = coop_enabled and selected_roles[1] > 0
	if p2_marker.visible:
		var card := role_cards.get_node("Role" + str(selected_roles[1])) as Control
		if p2_marker.get_parent() != card:
			p2_marker.reparent(card, false)
		p2_marker.position = Vector2(55 if selected_roles[0] == selected_roles[1] else 1, 18)


func _reset_selection() -> void:
	selected_roles = [0, 0]
	selecting_slot = 1
	current_choose = 0
	_clear_role_info()
	_refresh_selected_card()


func _update_archive_time() -> void:
	var num := _archive_num()
	var time_text: String = MemoryClass.get_time()
	if num <= 0:
		return
	if num <= 6:
		MainSet.set_data["time" + str(num)] = time_text
	else:
		var key := str(num)
		if not MainSet.set_data["其他存档"].has(key):
			MainSet.set_data["其他存档"][key] = {"name": "", "time": ""}
		MainSet.set_data["其他存档"][key]["time"] = time_text
	MemoryClass.main_bc()


func _archive_num() -> int:
	if Global.cd_path.find("Ar_") == -1:
		return 0
	return int(Global.cd_path.split("Ar_")[1].split(".")[0])

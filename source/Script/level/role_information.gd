extends Node2D

var _gogo: AnimatedSprite2D
var gogo: AnimatedSprite2D:
	get:
		if _gogo == null:
			_gogo = get_node_or_null("roleLayer/Control/Control/Gogo") as AnimatedSprite2D
		return _gogo
@onready var role_layer: Control = $roleLayer/Control
@onready var control_2: Control = $roleLayer/Control2
@onready var set_menu_con: GridContainer = $roleLayer/ButtonGroup

var set_key_tscn: PackedScene = preload("res://Scene/tools/set_com.tscn")
var head_tscn: PackedScene = preload("res://Scene/base/base_role.tscn")
var head_p2_tscn: PackedScene = preload("res://Scene/base/base_role_p2.tscn")

var set_com_node
var player
var player_p2
var role_p1
var role_p2
var buff_box: HBoxContainer
var is_stop: bool = false
var cur_prop: bool = false
const OLD_WUSHUANG_POSITION := Vector2(735, 505)
const DESKTOP_BUTTON_ORDER := ["pet", "skill", "magic_weapon", "backpack", "set", "menu"]


func _ready() -> void:
	add_to_group("RoleInformation")
	Global.call_deferred("prewarm_permanent_small_ui_scenes")
	player = _main_role()
	if player == null:
		player = RoleProp.source_player
	_order_hud_buttons()
	gogo.visible = false

	role_p1 = head_tscn.instantiate()
	role_p1.player = player
	role_p1.set_meta("coop_slot", 1)
	role_layer.add_child(role_p1)
	buff_box = role_p1.buff_box
	Global.buff_box = buff_box

	if _is_mobile():
		set_com_node = set_key_tscn.instantiate()
		control_2.add_child(set_com_node)

	player_p2 = _second_role()
	if player_p2 != null:
		role_p2 = head_p2_tscn.instantiate()
		role_p2.player = player_p2
		role_p2.set_meta("coop_slot", 2)
		role_layer.add_child(role_p2)

	if _is_mobile():
		_layout_mobile()

	_hide_role_hud(role_p1)
	_hide_role_hud(role_p2)
	set_menu_con.visible = false


func _main_role():
	var level = get_parent()
	if level != null:
		if level.get("role_") != null:
			return level.get("role_")
		if level.get("_role") != null:
			return level.get("_role")
	return null


func _second_role():
	var level = get_parent()
	if level != null and level.get("role_p2") != null:
		return level.get("role_p2")
	return null


func _is_mobile() -> bool:
	return OS.has_feature("android")


func _show_role_hud(role_node: Node) -> void:
	if role_node == null:
		return
	role_node.visible = true
	if role_node is CanvasItem:
		role_node.modulate = Color(1, 1, 1, 1)
	var head_node = role_node.get("head")
	if head_node is CanvasItem:
		head_node.visible = true
		head_node.modulate = Color(1, 1, 1, 1)
	var menu_node = role_node.get("menu")
	if menu_node is CanvasItem:
		menu_node.visible = true
		menu_node.modulate = Color(1, 1, 1, 1)
	var grey_node = role_node.get("grey")
	if grey_node is CanvasItem:
		grey_node.visible = true
		grey_node.modulate = Color(1, 1, 1, 1)


func _hide_role_hud(role_node: Node) -> void:
	if role_node == null:
		return
	role_node.visible = false


func reveal_after_scene_loaded() -> void:
	_show_role_hud(role_p1)
	_show_role_hud(role_p2)
	set_menu_con.visible = true
	if LocalCoop.is_enabled():
		set_menu_con.columns = 6
		set_menu_con.custom_minimum_size = Vector2(350, 72)
		set_menu_con.add_theme_constant_override("h_separation", 5)
		set_menu_con.add_theme_constant_override("v_separation", 5)
		for button in set_menu_con.get_children():
			if button is TextureButton:
				button.custom_minimum_size = Vector2(54, 54)
				button.visible = true
		set_menu_con.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
		set_menu_con.size = Vector2(350, 72)
		set_menu_con.position = Vector2(
			(get_viewport_rect().size.x - set_menu_con.size.x) * 0.5,
			get_viewport_rect().size.y - set_menu_con.size.y - 8
		)
		_layout_coop_skill_menu(role_p1, false)
		_layout_coop_skill_menu(role_p2, true)
	else:
		_layout_desktop()


func _layout_coop_skill_menu(hud: Control, second: bool) -> void:
	if hud == null:
		return
	var menu: Control = hud.menu
	menu.anchor_left = 1.0 if second else 0.0
	menu.anchor_right = menu.anchor_left
	menu.anchor_top = 1.0
	menu.anchor_bottom = 1.0
	menu.pivot_offset = Vector2.ZERO
	menu.scale = Vector2(0.85 if second else -0.85, 0.85)
	menu.position = Vector2(hud.size.x - 320 if second else 320, hud.size.y - 120)
	hud.grey.position = Vector2(82, 86)


func _order_hud_buttons() -> void:
	for index in DESKTOP_BUTTON_ORDER.size():
		var button := set_menu_con.get_node_or_null(DESKTOP_BUTTON_ORDER[index])
		if button != null:
			set_menu_con.move_child(button, index)


func _layout_desktop() -> void:
	set_menu_con.visible = true
	set_menu_con.columns = 1
	set_menu_con.custom_minimum_size = Vector2(56, 304)
	set_menu_con.add_theme_constant_override("h_separation", 0)
	set_menu_con.add_theme_constant_override("v_separation", 6)
	for button in set_menu_con.get_children():
		if button is TextureButton:
			button.custom_minimum_size = Vector2(56, 56)
			button.visible = true
	var menu_button := set_menu_con.get_node_or_null("menu") as TextureButton
	if menu_button != null:
		menu_button.visible = false
	set_menu_con.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	set_menu_con.offset_left = 24.0
	set_menu_con.offset_right = 80.0
	set_menu_con.offset_top = -328.0
	set_menu_con.offset_bottom = -24.0


func _layout_mobile() -> void:
	set_menu_con.visible = false
	set_menu_con.columns = 2
	set_menu_con.custom_minimum_size = Vector2(118, 180)
	for button in set_menu_con.get_children():
		if button is TextureButton:
			button.custom_minimum_size = Vector2(56, 56)
			button.visible = true
	set_menu_con.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	set_menu_con.offset_left = -134.0
	set_menu_con.offset_right = -16.0
	set_menu_con.offset_top = 16.0
	set_menu_con.offset_bottom = 196.0
	set_menu_con.visible = true

	_show_role_hud(role_p1)

	if role_p2 != null:
		_show_role_hud(role_p2)
		role_p2.grey.position = role_p1.grey.position


func switch_role() -> void:
	if not _is_mobile() or role_p2 == null:
		return
	if cur_prop:
		role_p1.grey.modulate.a = 1
		role_p2.grey.modulate.a = 1
	else:
		role_p1.grey.modulate.a = 1
		role_p2.grey.modulate.a = 1
	cur_prop = not cur_prop


func is_full_ws() -> bool:
	return role_p1 != null and role_p1.is_full_ws()

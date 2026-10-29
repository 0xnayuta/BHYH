class_name BaseRole
extends Control

var PlayerData: PlayerDataStore:
	get:
		var target: Node = player if is_instance_valid(player) else self
		return LocalCoop.data_for(target)
var RoleProp: BaseRoleProperties:
	get:
		var target: Node = player if is_instance_valid(player) else self
		return LocalCoop.props_for(target)

@onready var menu: TextureRect = $role_menu
@onready var head: TextureRect = $role_hp_mp_exp
@onready var ws_effect: TextureProgressBar = $role_menu/ws_wk/ws_effect
@onready var max_ws: AnimatedSprite2D = $role_menu/grey/max_ws
@onready var skill_box: HBoxContainer = $role_menu/SkillBox
@onready var role_skill_slots: Array[TextureRect] = [
	$role_menu/skil_1,
	$role_menu/skil_2,
	$role_menu/skil_3,
	$role_menu/skil_4,
	$role_menu/skil_5,
]
@onready var grey: Sprite2D = $role_menu/grey
@onready var role_protect: TextureProgressBar = $role_menu/RoleProtect
@onready var role_level: Label = $role_hp_mp_exp/TextureRect/role_level
@onready var hp_bar: TextureProgressBar = $role_hp_mp_exp/hp_bar
@onready var hp_text: Label = $role_hp_mp_exp/hp_bar/hp_text
@onready var mp_bar: TextureProgressBar = $role_hp_mp_exp/mp_bar
@onready var mp_text: Label = $role_hp_mp_exp/mp_bar/mp_text
@onready var exp_bar: TextureProgressBar = $role_hp_mp_exp/exp_bar
@onready var exp_text: Label = $role_hp_mp_exp/exp_bar/exp_text
@onready var nature_recovery_mp: Label = $role_hp_mp_exp/mp_bar/nature_recovery_mp
@onready var nature_recovery_hp: Label = $role_hp_mp_exp/hp_bar/nature_recovery_hp
@onready var buff_box: HBoxContainer = $role_hp_mp_exp/Buff_box
@onready var role_head: TextureRect = $role_hp_mp_exp/PanelContainer/Control/role_head
var pet_panel: TextureRect
var pet_head: TextureRect
var pet_level: Label
var pet_hp_bar: TextureProgressBar
var pet_hp_text: Label
var pet_hp_recovery: Label
var pet_mp_bar: TextureProgressBar
var pet_mp_text: Label
var pet_mp_recovery: Label
var pet_exp_bar: TextureProgressBar
var pet_exp_text: Label
var pet_protect_bar: TextureProgressBar
var pet_skill_box: HBoxContainer
@onready var magic_icon: HBoxContainer = $role_menu/magicIcon

var skill_tscn: PackedScene = preload("res://Scene/other_scene/skill_icon.tscn")
var magic_tscn: PackedScene = preload("res://Scene/magic_weapon/magic_weapon_skill_cd.tscn")
var buff_tscn: PackedScene = preload("res://Scene/other_scene/buff_icon.tscn")
const STATUS_ICON_SIZE := Vector2(32, 32)
const PET_LEARNED_SKILL_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const PET_LEARNED_ACTIVE_SKILL_ICONS := {"嗜血狂爆": "sxkb", "法术能量": "fsnl"}

var player
var magic_cd
var buff_icons: Dictionary = {}
var _last_skill_bindings: Dictionary = {}
var _last_skill_levels: Dictionary = {}
var _last_mount_skill_signature := ""
var _last_magic_name := ""
var _last_pet_head_key := ""
var _last_pet_skill_names: Array[String] = []
var _role_skill_icons: Array[TextureRect] = []
var _uses_role_skill_slots := false
var _skill_bindings_initialized := false
var _magic_name_initialized := false
var _cached_level: Node = null
var _cached_pet_unit: Node = null
var _pet_lookup_cooldown := 0.0


func _ready() -> void:
	if player == null:
		player = RoleProp.source_player
	_set_role_head()
	_load_skill_icons()
	_load_buff_icons()
	if magic_cd != null:
		if is_instance_valid(player):
			player.set_meta("magic_cd_icon", magic_cd)
		if LocalCoop.slot_for(self) == 1:
			Global.mg_cd_pic = magic_cd
	_bind_pet_panel_nodes()
	_set_pet_values()


func _physics_process(_delta: float) -> void:
	_pet_lookup_cooldown = maxf(0.0, _pet_lookup_cooldown - _delta)
	if player == null:
		player = RoleProp.source_player
	if player == null:
		_set_pet_values()
		return

	_set_buff_icon_info()
	_set_skill_pic()
	_set_magic_weapon_pic()
	_set_values()
	_set_pet_values()


func _set_role_head() -> void:
	match int(PlayerData.player_data.get("Myself", 1)):
		1:
			role_head.texture = load("res://Art/hero_picture/role_properies_box/hud_swk.png")
		2:
			role_head.texture = load("res://Art/hero_picture/role_properies_box/hud_tsz.png")
		3:
			role_head.texture = load("res://Art/hero_picture/role_properies_box/hud_zbj.png")
		4:
			role_head.texture = load("res://Art/hero_picture/role_properies_box/hud_shs.png")
		5:
			role_head.texture = load("res://Art/hero_picture/role_properies_box/hud_blm.png")
		6:
			role_head.texture = load("res://Art/hero_picture/role_properies_box/hud_nz.png")
		7:
			role_head.texture = load("res://Art/hero_picture/role_properies_box/hud_yt.png")
			role_head.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _load_skill_icons() -> void:
	for key_name in ["Y", "U", "I", "O", "L"]:
		var icon = skill_tscn.instantiate()
		icon.name = key_name
		skill_box.add_child(icon)

	_role_skill_icons.clear()
	if role_skill_slots.size() == 5:
		_uses_role_skill_slots = true
		skill_box.visible = false
		for slot in role_skill_slots:
			slot.texture = null
			slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			slot.clip_contents = true

	magic_cd = magic_tscn.instantiate()
	magic_cd.name = "H"
	magic_icon.add_child(magic_cd)


func _load_buff_icons() -> void:
	for buff_name in Global.all_buff_list:
		_ensure_buff_icon(str(buff_name))


func _ensure_buff_icon(buff_name: String):
	if buff_icons.has(buff_name):
		var cached_icon = buff_icons[buff_name]
		if is_instance_valid(cached_icon) and not cached_icon.is_queued_for_deletion():
			cached_icon.custom_minimum_size = STATUS_ICON_SIZE
			cached_icon.size = STATUS_ICON_SIZE
			cached_icon.scale = Vector2.ONE
			cached_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cached_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			return cached_icon
		buff_icons.erase(buff_name)
	var buff_icon = null
	for existing_icon in buff_box.get_children():
		if str(existing_icon.name) == buff_name or str(existing_icon.get("buff_name")) == buff_name:
			buff_icon = existing_icon
			break
	if buff_icon == null:
		buff_icon = buff_tscn.instantiate()
		buff_icon.name = buff_name
		buff_box.add_child(buff_icon)
	buff_icon.parent_node = player
	buff_icon.custom_minimum_size = STATUS_ICON_SIZE
	buff_icon.size = STATUS_ICON_SIZE
	buff_icon.scale = Vector2.ONE
	buff_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	buff_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	buff_icons[buff_name] = buff_icon
	buff_icon.visible = false
	return buff_icon


func _update_buff_icon(icon, buff, buff_obj: Dictionary, stack_count: int = 1) -> void:
	if not is_instance_valid(icon) or icon.is_queued_for_deletion():
		return
	var buff_info: Dictionary = _make_buff_info(buff_obj)
	buff_info["HaveCount"] = stack_count
	icon.parent_node = player
	icon.data_list = buff_info
	if not icon.visible:
		icon.visible = true
	if not bool(buff.get("is_check")):
		var add_time: float = float(buff_info.get("AddTime", 0.0))
		if add_time > 0.0:
			icon.buff_icon_remove.start(add_time)
		buff.set("is_check", true)


func _set_values() -> void:
	var shp: float = max(float(RoleProp.roleprop.SHp), 1.0)
	var smp: float = max(float(RoleProp.roleprop.SMp), 1.0)
	var max_exp: float = max(float(RoleProp.baseroleprop.max_exp), 1.0)
	var max_ws_value: float = max(float(RoleProp.max_ws_value), 1.0)
	var max_protect: float = max(float(player.max_protect), 1.0)

	nature_recovery_hp.text = (
		"+" + str(float(RoleProp.roleprop.R_hp)) + "/s * " + str(player.cure_value)
		if RoleProp.roleprop.Hp < RoleProp.roleprop.SHp and RoleProp.roleprop.R_hp > 0
		else ""
	)
	nature_recovery_mp.text = (
		"+" + str(float(RoleProp.roleprop.R_mp)) + "/s"
		if RoleProp.roleprop.Mp < RoleProp.roleprop.SMp and RoleProp.roleprop.R_mp > 0
		else ""
	)

	role_level.text = str(RoleProp.baseroleprop.Level)
	hp_bar.value = float(RoleProp.roleprop.Hp) / shp
	hp_text.text = str(int(RoleProp.roleprop.Hp)) + "/" + str(int(RoleProp.roleprop.SHp))
	mp_bar.value = float(RoleProp.roleprop.Mp) / smp
	mp_text.text = str(int(RoleProp.roleprop.Mp)) + "/" + str(int(RoleProp.roleprop.SMp))
	exp_bar.value = float(RoleProp.baseroleprop.exp) / max_exp
	exp_text.text = str(RoleProp.baseroleprop.exp) + "/" + str(RoleProp.baseroleprop.max_exp)
	if ws_effect != null:
		ws_effect.value = float(RoleProp.ws_value) / max_ws_value
	if max_ws != null:
		var ws_percent := ws_effect.value if ws_effect != null else float(RoleProp.ws_value) / max_ws_value
		max_ws.visible = ws_percent >= 1.0 and not RoleProp.is_ws_state
	role_protect.value = float(player.current_protect) / max_protect


func _bind_pet_panel_nodes() -> void:
	pet_panel = _find_pet_panel()
	if pet_panel == null:
		return
	pet_level = pet_panel.get_node_or_null("TextureRect/role_level") as Label
	pet_hp_bar = pet_panel.get_node_or_null("hp_bar") as TextureProgressBar
	pet_hp_text = pet_panel.get_node_or_null("hp_bar/hp_text") as Label
	pet_hp_recovery = pet_panel.get_node_or_null("hp_bar/nature_recovery_hp") as Label
	pet_mp_bar = pet_panel.get_node_or_null("mp_bar") as TextureProgressBar
	pet_mp_text = pet_panel.get_node_or_null("mp_bar/mp_text") as Label
	pet_mp_recovery = pet_panel.get_node_or_null("mp_bar/nature_recovery_mp") as Label
	pet_exp_bar = pet_panel.get_node_or_null("exp_bar") as TextureProgressBar
	pet_protect_bar = pet_panel.get_node_or_null("RoleProtect") as TextureProgressBar
	pet_exp_text = pet_panel.get_node_or_null("exp_bar/exp_text") as Label
	pet_skill_box = pet_panel.get_node_or_null("SkillBox") as HBoxContainer
	var pet_head_panel := pet_panel.get_node_or_null("PanelContainer") as Control
	var pet_head_control := pet_panel.get_node_or_null("PanelContainer/Control") as Control
	if pet_head_panel != null:
		pet_head_panel.clip_contents = true
	if pet_head_control != null:
		pet_head_control.clip_contents = true
		pet_head_control.custom_minimum_size = Vector2(80, 80)
	pet_head = pet_panel.get_node_or_null("PanelContainer/Control/role_head") as TextureRect
	if pet_head != null:
		pet_head.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pet_head.stretch_mode = TextureRect.STRETCH_SCALE
		pet_head.flip_h = true
		pet_head.anchor_left = 0.0
		pet_head.anchor_top = 0.0
		pet_head.anchor_right = 1.0
		pet_head.anchor_bottom = 1.0
		pet_head.offset_left = 0.0
		pet_head.offset_top = 0.0
		pet_head.offset_right = 0.0
		pet_head.offset_bottom = 0.0


func _find_pet_panel() -> TextureRect:
	for child in get_children():
		if child is TextureRect and str(child.name).ends_with("_hp_mp_exp") and str(child.name) != "role_hp_mp_exp":
			return child
	return null


func _set_pet_values() -> void:
	if pet_panel == null:
		_bind_pet_panel_nodes()
	if pet_panel == null:
		return
	var pet: Dictionary = _active_pet_data()
	if pet.is_empty() or (is_instance_valid(player) and bool(player.get("is_death"))):
		pet_panel.visible = false
		_clear_pet_skill_icons()
		_last_pet_head_key = ""
		_last_pet_skill_names.clear()
		_update_pet_head({}, null)
		return
	pet_panel.visible = true
	var pet_unit: Node = _get_cached_active_pet_unit()
	var max_hp: int = max(1, int(pet.get("生命上限", pet.get(DataKeys.HP, 1))))
	var hp: int = int(pet.get(DataKeys.HP, max_hp))
	if pet_unit != null:
		var unit_max_hp = pet_unit.get("max_hp")
		var unit_hp = pet_unit.get("hp")
		if unit_max_hp != null:
			max_hp = max(1, int(unit_max_hp))
		if unit_hp != null:
			hp = clampi(int(unit_hp), 0, max_hp)
	elif _is_pet_dead_in_current_level(str(pet.get(DataKeys.ALT_NAME, ""))):
		hp = 0
	var max_mp: int = max(1, int(pet.get("魔法上限", pet.get(DataKeys.MP, 1))))
	var mp: int = clampi(int(pet.get(DataKeys.MP, max_mp)), 0, max_mp)
	var max_protect: int = max(1, int(pet.get("max_protect", 100)))
	var current_protect: int = clampi(int(pet.get("current_protect", 0)), 0, max_protect)
	var hp_recover: int = int(pet.get("回血", 0))
	var mp_recover: int = int(pet.get("回魔", 0))
	if pet_unit != null:
		var unit_max_mp = pet_unit.get("max_mp")
		var unit_mp = pet_unit.get("mp")
		if unit_max_mp != null:
			max_mp = max(1, int(unit_max_mp))
		if unit_mp != null:
			mp = clampi(int(unit_mp), 0, max_mp)
	if pet_unit != null:
		var unit_max_protect = pet_unit.get("max_protect")
		var unit_current_protect = pet_unit.get("current_protect")
		if unit_max_protect != null:
			max_protect = max(1, int(unit_max_protect))
		if unit_current_protect != null:
			current_protect = clampi(int(unit_current_protect), 0, max_protect)
	var max_exp: int = max(1, int(pet.get("下级经验", 100)))
	var exp_value: int = clampi(int(pet.get(DataKeys.EXP, 0)), 0, max_exp)
	if pet_level != null:
		pet_level.text = str(int(pet.get(DataKeys.LEVEL, 1)))
	if pet_hp_bar != null:
		pet_hp_bar.value = float(hp) / float(max_hp)
	if pet_hp_text != null:
		pet_hp_text.text = "%d/%d" % [hp, max_hp]
	if pet_hp_recovery != null:
		pet_hp_recovery.text = "+" + str(hp_recover) + "/s" if hp < max_hp and hp_recover > 0 else ""
	if pet_mp_bar != null:
		pet_mp_bar.value = float(mp) / float(max_mp)
	if pet_mp_text != null:
		pet_mp_text.text = "%d/%d" % [mp, max_mp]
	if pet_mp_recovery != null:
		pet_mp_recovery.text = "+" + str(mp_recover) + "/s" if mp < max_mp and mp_recover > 0 else ""
	if pet_exp_bar != null:
		pet_exp_bar.value = float(exp_value) / float(max_exp)
	if pet_exp_text != null:
		pet_exp_text.text = "%d/%d" % [exp_value, max_exp]
	if pet_protect_bar != null:
		pet_protect_bar.max_value = float(max_protect)
		pet_protect_bar.value = float(current_protect)
	_update_pet_head(pet, pet_unit)
	_update_pet_skill_icons(pet, pet_unit)


func _active_pet_data() -> Dictionary:
	var data: Dictionary = PlayerData.player_data
	var active_name := str(data.get("出战宠物", ""))
	var pets: Variant = data.get("宠物列表", [])
	if not (pets is Array):
		return {}
	var first_active_pet: Dictionary = {}
	for pet in pets:
		if not (pet is Dictionary) or not bool(pet.get(DataKeys.DEPLOYED, false)):
			continue
		if first_active_pet.is_empty():
			first_active_pet = pet
		if active_name != "" and str(pet.get(DataKeys.ALT_NAME, "")) == active_name:
			return pet
		if active_name == "PetDragon" and _is_pet_dragon_hud_data(pet, null):
			return pet
		if active_name == "PetPhoenix" and _is_pet_phoenix_hud_data(pet, null):
			return pet
		if active_name == "PetTurtle" and _is_pet_turtle_hud_data(pet, null):
			return pet
		if active_name == "PetRabbit" and _is_pet_rabbit_hud_data(pet, null):
			return pet
		if active_name == "PetMouse" and _is_pet_mouse_hud_data(pet, null):
			return pet
		if active_name == "PetNeat" and _is_pet_neat_hud_data(pet, null):
			return pet
		if active_name == "PetYinTiger" and _is_pet_yin_tiger_hud_data(pet, null):
			return pet
	return first_active_pet


func _is_pet_dead_in_current_level(pet_name: String) -> bool:
	var level := _get_current_level()
	var slot := LocalCoop.slot_for(self)
	if level == null or not bool(level.get_meta(LocalCoop.pet_meta_key("active_pet_dead_this_level", slot), false)):
		return false
	var aliases := _pet_dead_aliases(pet_name)
	var dead_pet_keys_value: Variant = level.get_meta(LocalCoop.pet_meta_key("active_pet_dead_keys", slot), [])
	if dead_pet_keys_value is Array:
		for alias in aliases:
			if dead_pet_keys_value.has(alias):
				return true
	var dead_type := str(level.get_meta(LocalCoop.pet_meta_key("active_pet_dead_type", slot), ""))
	if dead_type != "" and aliases.has(dead_type):
		return true
	var dead_name := str(level.get_meta(LocalCoop.pet_meta_key("active_pet_dead_name", slot), ""))
	var dead_display_name := str(level.get_meta(LocalCoop.pet_meta_key("active_pet_dead_display_name", slot), ""))
	return dead_name == "" or aliases.has(dead_name) or aliases.has(dead_display_name)


func _find_pet_dead_level(node: Node, pet_name: String) -> bool:
	if node == null:
		return false
	var slot := LocalCoop.slot_for(self)
	if bool(node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_this_level", slot), false)):
		var aliases := _pet_dead_aliases(pet_name)
		var dead_pet_keys_value: Variant = node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_keys", slot), [])
		if dead_pet_keys_value is Array:
			for alias in aliases:
				if dead_pet_keys_value.has(alias):
					return true
		var dead_type := str(node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_type", slot), ""))
		if dead_type != "" and aliases.has(dead_type):
			return true
		var dead_name := str(node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_name", slot), ""))
		var dead_display_name := str(node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_display_name", slot), ""))
		if dead_name == "" or aliases.has(dead_name) or aliases.has(dead_display_name):
			return true
	for child in node.get_children():
		if _find_pet_dead_level(child, pet_name):
			return true
	return false


func _pet_dead_aliases(pet_name: String) -> Array[String]:
	var aliases: Array[String] = [pet_name]
	if pet_name == "PetNeat" or pet_name in ["丑牛", "丑牛元帅", "丑牛大元帅"]:
		aliases.append("PetNeat")
		aliases.append("丑牛元帅")
		aliases.append("丑牛大元帅")
	if pet_name == "PetYinTiger" or pet_name in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"]:
		aliases.append("PetYinTiger")
		aliases.append("寅虎元帅")
		aliases.append("寅虎大元帅")
	if pet_name == "PetMouse" or pet_name.begins_with("子鼠") or pet_name in ["子鼠元帅", "子鼠大元帅"]:
		aliases.append("PetMouse")
		for name in ["子鼠元帅", "子鼠大元帅"]:
			if not aliases.has(name):
				aliases.append(name)
	if pet_name == "PetTurtle" or pet_name.begins_with("玄武") or pet_name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]:
		aliases.append("PetTurtle")
		for name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]:
			if not aliases.has(name):
				aliases.append(name)
	if pet_name == "PetDragon" or pet_name.begins_with("辰龙") or pet_name in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]:
		aliases.append("PetDragon")
		for name in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]:
			if not aliases.has(name):
				aliases.append(name)
	if pet_name == "PetTiger" or pet_name in ["虎丸", "白灵虎", "白虎将军", "白虎战神", "白虎"]:
		aliases.append("PetTiger")
		for name in ["虎丸", "白灵虎", "白虎将军", "白虎战神", "白虎"]:
			if not aliases.has(name):
				aliases.append(name)
	if (
		pet_name == "PetPhoenix"
		or pet_name.begins_with("朱雀")
		or pet_name in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]
	):
		aliases.append("PetPhoenix")
		for name in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]:
			if not aliases.has(name):
				aliases.append(name)
	if pet_name == "PetRabbit" or pet_name in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]:
		aliases.append("PetRabbit")
		for name in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]:
			if not aliases.has(name):
				aliases.append(name)
	return aliases


func _get_current_level() -> Node:
	if is_instance_valid(_cached_level) and _cached_level.is_inside_tree():
		return _cached_level
	var ancestor: Node = self
	while ancestor != null:
		if ancestor is BaseLevel or ancestor.get("monster") is Node:
			_cached_level = ancestor
			return ancestor
		ancestor = ancestor.get_parent()
	var current_scene := get_tree().current_scene
	if current_scene != null and (current_scene is BaseLevel or current_scene.get("monster") is Node):
		_cached_level = current_scene
		return current_scene
	var levels := get_tree().get_nodes_in_group("BaseLevel")
	_cached_level = levels[0] if not levels.is_empty() else null
	return _cached_level


func _get_cached_active_pet_unit() -> Node:
	if (
		is_instance_valid(_cached_pet_unit)
		and _cached_pet_unit.is_inside_tree()
		and not _cached_pet_unit.is_queued_for_deletion()
	):
		return _cached_pet_unit
	_cached_pet_unit = null
	if _pet_lookup_cooldown > 0.0:
		return null
	_pet_lookup_cooldown = 0.25
	var level := _get_current_level()
	if level == null:
		return null
	var registered_pet = level.get_meta(LocalCoop.pet_meta_key("active_pet_unit", LocalCoop.slot_for(self)), false)
	if is_instance_valid(registered_pet):
		var registered_pet_node := registered_pet as Node
		if registered_pet_node != null and _is_hud_active_pet_unit(registered_pet_node):
			_cached_pet_unit = registered_pet_node
			return registered_pet_node
	elif level.has_meta(LocalCoop.pet_meta_key("active_pet_unit", LocalCoop.slot_for(self))):
		level.remove_meta(LocalCoop.pet_meta_key("active_pet_unit", LocalCoop.slot_for(self)))
	var monster_container := level.get("monster") as Node
	if monster_container == null:
		return null
	for child in monster_container.get_children():
		if _is_hud_active_pet_unit(child):
			_cached_pet_unit = child
			return child
	return null


func _is_hud_active_pet_unit(node: Node) -> bool:
	if not is_instance_valid(node) or not node.is_inside_tree() or node.is_queued_for_deletion():
		return false
	if int(node.get_meta("coop_slot", 1)) != LocalCoop.slot_for(self):
		return false
	if (
		bool(node.get_meta("pet_tiger_unit", false))
		or bool(node.get_meta("pet_phoenix_unit", false))
		or bool(node.get_meta("pet_turtle_unit", false))
		or bool(node.get_meta("pet_rabbit_unit", false))
		or bool(node.get_meta("pet_mouse_unit", false))
		or bool(node.get_meta("pet_neat_unit", false))
		or bool(node.get_meta("pet_yin_tiger_unit", false))
	):
		return true
	return bool(node.get_meta("pet_dragon_unit", false)) and not bool(node.get("is_dragon_clone"))


func _update_pet_head(pet: Dictionary, pet_unit: Node) -> void:
	if pet_head == null:
		return
	if pet.is_empty():
		if pet_head.texture != null:
			pet_head.texture = null
		return
	var stage := _active_pet_skill_stage(pet, pet_unit)
	var pet_type := (
		"yin_tiger"
		if _is_pet_yin_tiger_hud_data(pet, pet_unit)
		else (
			"neat"
			if _is_pet_neat_hud_data(pet, pet_unit)
			else (
				"mouse"
				if _is_pet_mouse_hud_data(pet, pet_unit)
				else (
					"rabbit"
					if _is_pet_rabbit_hud_data(pet, pet_unit)
					else (
						"turtle"
						if _is_pet_turtle_hud_data(pet, pet_unit)
						else (
							"phoenix"
							if _is_pet_phoenix_hud_data(pet, pet_unit)
							else ("dragon" if _is_pet_dragon_hud_data(pet, pet_unit) else "tiger")
						)
					)
				)
			)
		)
	)
	var head_key := "%s:%d" % [pet_type, stage]
	if head_key == _last_pet_head_key:
		return
	_last_pet_head_key = head_key
	if pet_type == "yin_tiger":
		pet_head.texture = _pet_yin_tiger_head_texture(stage)
	elif pet_type == "neat":
		pet_head.texture = _pet_neat_head_texture(stage)
	elif pet_type == "mouse":
		pet_head.texture = _pet_mouse_head_texture(stage)
	elif pet_type == "rabbit":
		pet_head.texture = _pet_rabbit_head_texture(stage)
	elif pet_type == "turtle":
		pet_head.texture = _pet_turtle_head_texture(stage)
	elif pet_type == "phoenix":
		pet_head.texture = _pet_phoenix_head_texture(stage)
	else:
		pet_head.texture = _pet_dragon_head_texture(stage) if pet_type == "dragon" else _pet_tiger_head_texture(stage)


func _pet_tiger_head_texture(stage: int) -> Texture2D:
	return Global.get_cached_texture(
		"res://Art/pet/pet_tiger/model/actions/stage%d/wait/icon.png" % clampi(stage, 1, 4)
	)


func _pet_dragon_head_texture(stage: int) -> Texture2D:
	return Global.get_cached_texture("res://Art/pet/pet_dragon/model/actions/stage%d/wait/头像.png" % clampi(stage, 1, 4))


func _pet_phoenix_head_texture(stage: int) -> Texture2D:
	return Global.get_cached_texture(
		"res://Art/pet/pet_phoenix/model/actions/stage%d/wait/头像.png" % clampi(stage, 1, 4)
	)


func _pet_turtle_head_texture(stage: int) -> Texture2D:
	return load("res://Art/pet/pet_turtle/model/actions/stage%d/wait/tou_xiang.png" % clampi(stage, 1, 4)) as Texture2D


func _pet_rabbit_head_texture(stage: int) -> Texture2D:
	return load("res://Art/pet/pet_rabbit/model/actions/stage%d/wait/tou_xiang.png" % clampi(stage, 1, 4)) as Texture2D


func _pet_mouse_head_texture(stage: int) -> Texture2D:
	return load("res://Art/pet/pet_mouse/model/actions/stage%d/wait/head.png" % clampi(stage, 1, 2)) as Texture2D


func _pet_neat_head_texture(stage: int) -> Texture2D:
	return load("res://Art/pet/pet_neat/model/actions/stage%d/wait/tou_xiang.png" % clampi(stage, 1, 4)) as Texture2D


func _pet_yin_tiger_head_texture(stage: int) -> Texture2D:
	var source_stage := 2 if stage >= 4 else 1
	var path := "res://Art/pet/pet_yin_tiger/model/actions/stage%d/wait/1.png" % source_stage
	return load(path) as Texture2D


func _clear_pet_skill_icons() -> void:
	if pet_skill_box == null:
		return
	for child in pet_skill_box.get_children():
		child.queue_free()
	_last_pet_skill_names.clear()


func _update_pet_skill_icons(pet: Dictionary, pet_unit: Node) -> void:
	if pet_skill_box == null:
		return
	var stage := _active_pet_skill_stage(pet, pet_unit)
	var skill_names := _pet_visible_skill_icon_names(pet, pet_unit, stage)
	var skill_names_changed := skill_names != _last_pet_skill_names
	if skill_names_changed:
		_last_pet_skill_names = skill_names.duplicate()
	while pet_skill_box.get_child_count() > skill_names.size():
		var extra := pet_skill_box.get_child(pet_skill_box.get_child_count() - 1)
		pet_skill_box.remove_child(extra)
		extra.queue_free()
	for i in range(skill_names.size()):
		var icon := _ensure_pet_skill_icon(i)
		var skill_name := str(skill_names[i])
		if skill_names_changed or str(icon.name) != skill_name:
			icon.name = skill_name
			var icon_file := "aoyi" if skill_name in ["xwaoyi", "ysaoyi", "zsaoyi"] else skill_name
			icon.texture = load("res://Art/pet/skillicon/%s.png" % icon_file)
			icon.visible = icon.texture != null
		_set_pet_skill_cooldown(icon, skill_name, pet_unit)


func _ensure_pet_skill_icon(index: int) -> TextureRect:
	var icon: TextureRect = null
	if index < pet_skill_box.get_child_count():
		icon = pet_skill_box.get_child(index) as TextureRect
	if icon == null:
		icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pet_skill_box.add_child(icon)
	icon.size = Vector2(32, 32)
	_ensure_pet_skill_cooldown_nodes(icon)
	return icon


func _ensure_pet_skill_cooldown_nodes(icon: TextureRect) -> void:
	var mask := icon.get_node_or_null("PicBox") as TextureProgressBar
	if mask == null:
		mask = TextureProgressBar.new()
		mask.name = "PicBox"
		mask.modulate = Color(0.329412, 0.329412, 0.329412, 1)
		mask.max_value = 1.0
		mask.step = 0.0
		mask.fill_mode = 5
		mask.nine_patch_stretch = true
		icon.add_child(mask)
	mask.position = Vector2.ZERO
	mask.size = Vector2(32, 32)
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mask.z_index = 1
	var time_text := icon.get_node_or_null("TimeText") as Label
	if time_text == null:
		time_text = Label.new()
		time_text.name = "TimeText"
		time_text.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		time_text.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		time_text.add_theme_constant_override("outline_size", 5)
		time_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		time_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon.add_child(time_text)
	time_text.position = Vector2.ZERO
	time_text.size = Vector2(32, 32)
	time_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	time_text.z_index = 2


func _set_pet_skill_cooldown(icon: TextureRect, skill_name: String, pet_unit: Node) -> void:
	var mask := icon.get_node_or_null("PicBox") as TextureProgressBar
	var time_text := icon.get_node_or_null("TimeText") as Label
	if mask == null or time_text == null:
		return
	var cd := _pet_skill_cooldown_left(skill_name, pet_unit)
	var max_cd := _pet_skill_cooldown_max(skill_name, pet_unit)
	mask.texture_progress = icon.texture
	if cd <= 0.0 or max_cd <= 0.0:
		mask.visible = false
		mask.value = 0.0
		time_text.visible = false
		return
	mask.visible = true
	mask.value = clampf(cd / max_cd, 0.0, 1.0)
	time_text.visible = true
	if cd > 1.0:
		time_text.text = str(snapped(cd, 1.0))
	else:
		time_text.text = str(snapped(cd, 0.1))


func _pet_skill_cooldown_left(skill_name: String, pet_unit: Node) -> float:
	if pet_unit == null:
		return 0.0
	if skill_name in PET_LEARNED_ACTIVE_SKILL_ICONS.values():
		var runtime := pet_unit.get_node_or_null("PetLearnedSkillRuntime")
		if runtime != null and runtime.has_method("cooldown_left"):
			return maxf(0.0, float(runtime.cooldown_left()))
		return 0.0
	var key := _pet_skill_cooldown_key(skill_name)
	if key == "":
		return 0.0
	return maxf(0.0, float(pet_unit.get(key)))


func _pet_skill_cooldown_key(skill_name: String) -> String:
	match skill_name:
		"hy", "hx", "fs", "np", "sld", "yg", "sc", "mncz":
			return "skill_1_cd"
		"sxhz", "sdcc", "bshn", "txlj", "jf", "hxfb", "mljt", "mhxs":
			return "skill_2_cd"
		"hsqj", "ltwj", "dhly", "sybh", "bs", "zsaoyi", "cnaoyi", "yhaoyi":
			return "skill_3_cd"
		"aoyi", "qlaoyi", "xwaoyi", "ysaoyi":
			return "skill_4_cd"
	return ""


func _pet_skill_cooldown_max(skill_name: String, pet_unit: Node) -> float:
	if skill_name in PET_LEARNED_ACTIVE_SKILL_ICONS.values():
		if pet_unit != null:
			var runtime := pet_unit.get_node_or_null("PetLearnedSkillRuntime")
			if runtime != null and runtime.has_method("cooldown_max"):
				return maxf(0.0, float(runtime.cooldown_max()))
		return PET_LEARNED_SKILL_RUNTIME.COOLDOWN_SECONDS
	var base_cooldown := 1.0
	match skill_name:
		"hy":
			base_cooldown = 7.0
		"hx":
			base_cooldown = 7.0
		"fs":
			base_cooldown = 20.0
		"sxhz":
			base_cooldown = 11.0
		"sdcc":
			base_cooldown = 10.0
		"hsqj":
			base_cooldown = 13.0
		"ltwj":
			base_cooldown = 16.0
		"aoyi":
			if pet_unit != null and bool(pet_unit.get_meta("pet_dragon_unit", false)):
				base_cooldown = 60.0
			elif pet_unit != null and bool(pet_unit.get_meta("pet_phoenix_unit", false)):
				base_cooldown = 45.0
			else:
				base_cooldown = 26.0
		"qlaoyi":
			base_cooldown = 60.0
		"np":
			base_cooldown = 30.0
		"bshn":
			base_cooldown = 12.0
		"dhly":
			base_cooldown = 15.0
		"sld":
			base_cooldown = 10.0
		"txlj":
			base_cooldown = 45.0
		"sybh":
			base_cooldown = 12.0
		"xwaoyi":
			base_cooldown = 60.0
		"yg":
			base_cooldown = 0.0
		"jf":
			base_cooldown = 20.0
		"bs":
			base_cooldown = 15.0
		"ysaoyi":
			base_cooldown = 60.0
		"sc":
			base_cooldown = 10.0
		"hxfb":
			base_cooldown = 10.0
		"zsaoyi":
			base_cooldown = 9.0
		"mncz":
			base_cooldown = 10.0
		"mljt":
			base_cooldown = 12.0
		"cnaoyi":
			base_cooldown = 45.0
		"mhxs":
			base_cooldown = 10.0
		"yhaoyi":
			base_cooldown = 45.0
		"mncz":
			base_cooldown = 10.0
		"mljt":
			base_cooldown = 12.0
		"cnaoyi":
			base_cooldown = 45.0
	var cooldown_multiplier := 1.0
	if pet_unit != null:
		var unit_multiplier = pet_unit.get("pet_skill_cooldown_multiplier")
		if unit_multiplier != null:
			cooldown_multiplier = maxf(0.01, float(unit_multiplier))
	return base_cooldown * cooldown_multiplier


func _active_pet_skill_stage(pet: Dictionary, pet_unit: Node) -> int:
	if _is_pet_neat_hud_data(pet, pet_unit):
		if pet_unit != null:
			var neat_unit_stage = pet_unit.get("turtle_stage")
			if neat_unit_stage != null:
				return clampi(int(neat_unit_stage), 1, 4)
		return clampi(int(pet.get("阶段", 1)), 1, 4)
	if _is_pet_mouse_hud_data(pet, pet_unit):
		if pet_unit != null:
			var mouse_unit_stage = pet_unit.get("turtle_stage")
			if mouse_unit_stage != null:
				return clampi(int(mouse_unit_stage), 1, 2)
		if pet.has("阶段"):
			return clampi(int(pet.get("阶段", 1)), 1, 2)
		return 2 if int(pet.get(DataKeys.LEVEL, 1)) >= 50 else 1
	if pet_unit != null:
		var turtle_unit_stage = pet_unit.get("turtle_stage")
		if turtle_unit_stage != null:
			return clampi(int(turtle_unit_stage), 1, 4)
		var dragon_unit_stage = pet_unit.get("dragon_stage")
		if dragon_unit_stage != null:
			return clampi(int(dragon_unit_stage), 1, 4)
		var phoenix_unit_stage = pet_unit.get("phoenix_stage")
		if phoenix_unit_stage != null:
			return clampi(int(phoenix_unit_stage), 1, 4)
		var unit_stage = pet_unit.get("tiger_stage")
		if unit_stage != null:
			return clampi(int(unit_stage), 1, 4)
	if pet.has("阶段"):
		return clampi(int(pet.get("阶段", 1)), 1, 4)
	var skill_stage := _pet_tiger_stage_from_skill_data(pet)
	if skill_stage > 0:
		return skill_stage
	var level := int(pet.get(DataKeys.LEVEL, pet.get("Level", pet.get("level", 1))))
	if level >= 50:
		return 4
	if level >= 30:
		return 3
	if level >= 15:
		return 2
	return 1


func _pet_tiger_stage_from_skill_data(pet: Dictionary) -> int:
	var stage := 0
	for value in pet.values():
		if value is Array:
			stage = max(stage, _pet_tiger_stage_from_skill_array(value))
	return stage


func _pet_tiger_stage_from_skill_array(skills: Array) -> int:
	var stage := 0
	for skill in skills:
		var skill_name := ""
		if skill is Dictionary:
			for value in skill.values():
				var text := str(value)
				if text in ["hy", "sxhz", "hsqj", "aoyi"]:
					skill_name = text
					break
		else:
			skill_name = str(skill)
		match skill_name:
			"aoyi":
				stage = max(stage, 4)
			"hsqj":
				stage = max(stage, 3)
			"sxhz":
				stage = max(stage, 2)
			"hy":
				stage = max(stage, 1)
	return stage


func _pet_tiger_skill_names_for_stage(stage: int) -> Array[String]:
	match clampi(stage, 1, 4):
		1:
			return ["hy"]
		2:
			return ["hy", "sxhz"]
		3:
			return ["hy", "sxhz", "hsqj"]
		_:
			return ["hy", "sxhz", "hsqj", "aoyi"]


func _pet_visible_skill_icon_names(pet: Dictionary, pet_unit: Node, stage: int) -> Array[String]:
	var result: Array[String] = []
	for skill_id in _pet_skill_icon_names_for_pet(pet, pet_unit, stage):
		var native_skill_id := str(skill_id)
		if native_skill_id == "yg" or _pet_skill_cooldown_max(native_skill_id, pet_unit) > 0.0:
			result.append(native_skill_id)
	for skill_name in PET_LEARNED_SKILL_RUNTIME.learned_skill_names(pet):
		var learned_skill_id := str(PET_LEARNED_ACTIVE_SKILL_ICONS.get(str(skill_name), ""))
		if not learned_skill_id.is_empty() and not result.has(learned_skill_id):
			result.append(learned_skill_id)
	return result


func _pet_skill_icon_names_for_pet(pet: Dictionary, pet_unit: Node, stage: int) -> Array[String]:
	if _is_pet_yin_tiger_hud_data(pet, pet_unit):
		return ["hx"] if clampi(stage, 1, 4) < 4 else ["hx", "mhxs", "yhaoyi"]
	if _is_pet_neat_hud_data(pet, pet_unit):
		match clampi(stage, 1, 4):
			3:
				return ["mncz", "mljt"]
			4:
				return ["mncz", "mljt", "cnaoyi"]
			_:
				return ["mncz"]
	if _is_pet_mouse_hud_data(pet, pet_unit):
		var mouse_skill_names: Array[String] = ["sc"]
		var pet_level := int(pet.get(DataKeys.LEVEL, 1))
		if pet_level >= 30:
			mouse_skill_names.append("hxfb")
		if pet_level >= 50:
			mouse_skill_names.append("zsaoyi")
		return mouse_skill_names
	if _is_pet_rabbit_hud_data(pet, pet_unit):
		match clampi(stage, 1, 4):
			1:
				return ["yg"]
			2:
				return ["yg", "jf"]
			3:
				return ["yg", "jf", "bs"]
			_:
				return ["yg", "jf", "bs", "ysaoyi"]
	if _is_pet_turtle_hud_data(pet, pet_unit):
		match clampi(stage, 1, 4):
			1:
				return ["sld"]
			2:
				return ["sld", "txlj"]
			3:
				return ["sld", "txlj", "sybh"]
			_:
				return ["sld", "txlj", "sybh", "xwaoyi"]
	if _is_pet_phoenix_hud_data(pet, pet_unit):
		match clampi(stage, 1, 4):
			1:
				return ["np"]
			2:
				return ["np", "bshn"]
			3:
				return ["np", "bshn", "dhly"]
			_:
				return ["np", "bshn", "dhly", "aoyi"]
	if not _is_pet_dragon_hud_data(pet, pet_unit):
		return _pet_tiger_skill_names_for_stage(stage)
	match clampi(stage, 1, 4):
		1:
			return ["fs"]
		2:
			return ["fs", "sdcc"]
		3:
			return ["fs", "sdcc", "ltwj"]
		_:
			return ["fs", "sdcc", "ltwj", "aoyi"]


func _is_pet_dragon_hud_data(pet: Dictionary, pet_unit: Node) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	var is_dragon := (
		str(pet.get(DataKeys.TYPE, "")) == "PetDragon"
		or pet_name.begins_with("辰龙")
		or pet_name in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]
	)
	if pet_unit != null and bool(pet_unit.get_meta("pet_dragon_unit", false)):
		is_dragon = true
	return is_dragon


func _is_pet_phoenix_hud_data(pet: Dictionary, pet_unit: Node) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	var is_phoenix := (
		str(pet.get(DataKeys.TYPE, "")) == "PetPhoenix"
		or pet_name.begins_with("朱雀")
		or pet_name in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]
	)
	if pet_unit != null and bool(pet_unit.get_meta("pet_phoenix_unit", false)):
		is_phoenix = true
	return is_phoenix


func _is_pet_turtle_hud_data(pet: Dictionary, pet_unit: Node) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	var is_turtle := (
		str(pet.get(DataKeys.TYPE, "")) == "PetTurtle"
		or pet_name.begins_with("玄武")
		or pet_name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]
	)
	if pet_unit != null and bool(pet_unit.get_meta("pet_turtle_unit", false)):
		is_turtle = true
	return is_turtle


func _is_pet_rabbit_hud_data(pet: Dictionary, pet_unit: Node) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	var is_rabbit := str(pet.get(DataKeys.TYPE, "")) == "PetRabbit" or pet_name in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]
	if pet_unit != null and bool(pet_unit.get_meta("pet_rabbit_unit", false)):
		is_rabbit = true
	return is_rabbit


func _is_pet_mouse_hud_data(pet: Dictionary, pet_unit: Node) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	var is_mouse := (
		str(pet.get(DataKeys.TYPE, "")) == "PetMouse" or pet_name.begins_with("子鼠") or pet_name in ["子鼠元帅", "子鼠大元帅"]
	)
	if pet_unit != null and bool(pet_unit.get_meta("pet_mouse_unit", false)):
		is_mouse = true
	return is_mouse


func _is_pet_neat_hud_data(pet: Dictionary, pet_unit: Node) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	var is_neat := str(pet.get(DataKeys.TYPE, "")) == "PetNeat" or pet_name in ["丑牛", "丑牛元帅", "丑牛大元帅"]
	if pet_unit != null and bool(pet_unit.get_meta("pet_neat_unit", false)):
		is_neat = true
	return is_neat


func _is_pet_yin_tiger_hud_data(pet: Dictionary, pet_unit: Node) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	var is_yin_tiger := str(pet.get(DataKeys.TYPE, "")) == "PetYinTiger" or pet_name in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"]
	if pet_unit != null and bool(pet_unit.get_meta("pet_yin_tiger_unit", false)):
		is_yin_tiger = true
	return is_yin_tiger


func _is_mobile_touch_hud() -> bool:
	return (
		OS.has_feature("android")
		or get_tree().root.has_node("TouchControls")
		or get_parent() != null and get_parent().name == "Control"
	)


func is_full_ws() -> bool:
	return RoleProp.ws_value >= RoleProp.max_ws_value and not RoleProp.is_ws_state


func _set_skill_pic() -> void:
	var skill_data = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {})
	var skill_keys = skill_data.get("技能键位", {}) if skill_data is Dictionary else {}
	var skill_levels := _get_skill_level_snapshot(skill_data)
	var mount_runtime := _current_mount_runtime()
	var display_skill_keys: Variant = skill_keys
	var mount_skill_signature := ""
	if (
		mount_runtime != null
		and mount_runtime.has_method("is_riding_mount")
		and bool(mount_runtime.call("is_riding_mount"))
	):
		display_skill_keys = {}
		var mount_skill_ids: Array[String] = []
		for slot in range(5):
			var mount_skill: Dictionary = mount_runtime.call("get_mount_skill_for_slot", slot)
			var mount_skill_id := str(mount_skill.get("id", ""))
			mount_skill_ids.append(mount_skill_id)
			if mount_skill_id != "":
				display_skill_keys[["Y", "U", "I", "O", "L"][slot]] = mount_skill_id
		mount_skill_signature = "|".join(mount_skill_ids)
	if (
		_skill_bindings_initialized
		and skill_keys is Dictionary
		and skill_keys == _last_skill_bindings
		and skill_levels == _last_skill_levels
		and mount_skill_signature == _last_mount_skill_signature
	):
		return
	_skill_bindings_initialized = true
	_last_skill_bindings = skill_keys.duplicate() if skill_keys is Dictionary else {}
	_last_skill_levels = skill_levels
	_last_mount_skill_signature = mount_skill_signature
	_set_skill_pic_for_icons(
		skill_box.get_children(), display_skill_keys, mount_runtime if mount_skill_signature != "" else null
	)
	_sync_role_skill_slot_icons(display_skill_keys)
	_set_skill_pic_for_icons(
		_role_skill_icons, display_skill_keys, mount_runtime if mount_skill_signature != "" else null
	)


func _sync_role_skill_slot_icons(skill_keys: Variant) -> void:
	_role_skill_icons.clear()
	if not _uses_role_skill_slots or role_skill_slots.size() != 5:
		return
	var key_names := ["Y", "U", "I", "O", "L"]
	for index in range(role_skill_slots.size()):
		var slot := role_skill_slots[index]
		var key_name: String = key_names[index]
		var skill_name := str(skill_keys.get(key_name, "")) if skill_keys is Dictionary else ""
		var icon := slot.get_node_or_null(key_name) as TextureRect
		if skill_name == "" or skill_name == "Empty":
			if icon != null:
				slot.remove_child(icon)
				icon.queue_free()
			continue
		if icon == null:
			icon = skill_tscn.instantiate() as TextureRect
			icon.name = key_name
			slot.add_child(icon)
			icon.size = Vector2(45, 45)
			var icon_scale := Vector2(slot.size.x / 45.0, slot.size.y / 45.0)
			var mirrored := menu.scale.x < 0.0
			icon.position = Vector2(slot.size.x if mirrored else 0.0, 0)
			icon.scale = Vector2(-icon_scale.x if mirrored else icon_scale.x, icon_scale.y)
		_role_skill_icons.append(icon)


func _get_skill_level_snapshot(skill_data: Variant) -> Dictionary:
	var levels: Dictionary = {}
	if not skill_data is Dictionary:
		return levels
	for key in skill_data:
		var entry: Variant = skill_data[key]
		if entry is Dictionary and entry.has(DataKeys.LEVEL):
			levels[str(key)] = int(entry[DataKeys.LEVEL])
	return levels


func _set_skill_pic_for_icons(icons: Array, skill_keys: Variant, mount_runtime: Node = null) -> void:
	var key_names := ["Y", "U", "I", "O", "L"]
	for icon in icons:
		var key_name: String = str(icon.name)
		var skill_name: String = str(skill_keys.get(key_name, "")) if skill_keys is Dictionary else ""
		icon.skill_name = skill_name if skill_name != "" else "Empty"
		icon.mount_skill_slot = key_names.find(key_name) if mount_runtime != null and skill_name != "" else -1
		if icon.has_method("set_mp_display"):
			icon.set_mp_display(0 if mount_runtime != null else _get_skill_mp(skill_name))


func _current_mount_runtime() -> Node:
	if player == null or not is_instance_valid(player):
		return null
	return player.get_node_or_null("MountRuntime")


func _get_skill_mp(skill_name: String) -> int:
	if skill_name == "" or skill_name == "Empty":
		return 0
	if skill_name in ["sx", "sjt", "rj", "mds", "yyb"]:
		return 0
	if player != null and player.has_method("get_skill_display_mp"):
		return int(player.get_skill_display_mp(skill_name))
	if player != null and player.has_method("get_need_mp"):
		return int(player.get_need_mp(skill_name, false))
	return 0


func _set_magic_weapon_pic() -> void:
	if magic_cd == null:
		return
	var magic_name: String = str(PlayerData.player_data.get("实战法宝", ""))
	if _magic_name_initialized and magic_name == _last_magic_name:
		return
	_magic_name_initialized = true
	_last_magic_name = magic_name
	magic_cd.visible = magic_name != ""
	magic_cd.skill_name = magic_name


func _set_buff_icon_info() -> void:
	var active_buff_names: Array[String] = []
	var buff_counts: Dictionary = {}
	var first_buff_by_name: Dictionary = {}
	if player == null or player.buff == null:
		for icon in buff_icons.values():
			if is_instance_valid(icon) and not icon.is_queued_for_deletion():
				icon.visible = false
		return

	for buff in player.buff.get_children():
		var buff_obj = buff.get("buff_info")
		if not buff_obj is Dictionary or not buff_obj.has("Name"):
			continue
		var buff_name: String = str(buff_obj["Name"])
		if not buff_counts.has(buff_name):
			buff_counts[buff_name] = 0
			first_buff_by_name[buff_name] = buff
		buff_counts[buff_name] += 1

	for buff_name in buff_counts.keys():
		active_buff_names.append(str(buff_name))
		var buff = first_buff_by_name[buff_name]
		var buff_obj: Dictionary = buff.get("buff_info")
		var icon = _ensure_buff_icon(str(buff_name))
		_update_buff_icon(icon, buff, buff_obj, int(buff_counts[buff_name]))

	for buff_name in buff_icons.keys():
		if not active_buff_names.has(str(buff_name)):
			var inactive_icon = buff_icons[buff_name]
			if is_instance_valid(inactive_icon) and not inactive_icon.is_queued_for_deletion():
				inactive_icon.visible = false


func _make_buff_info(buff_obj: Dictionary) -> Dictionary:
	var info: Dictionary = {
		"Name": str(buff_obj.get("Name", "")),
		"value": 0.0,
		"AddTime": float(buff_obj.get("AddTime", 0.0)),
		"reduce_interval": float(buff_obj.get("reduce_interval", 0.0)),
		"AttackKind": str(buff_obj.get("AttackKind", "")),
		"HaveCount": 1,
	}
	for key in buff_obj.keys():
		if not info.has(key):
			info[key] = buff_obj[key]
	info["value"] = float(buff_obj.get("value", 0.0))
	return info

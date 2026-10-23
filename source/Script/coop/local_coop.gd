extends Node

const SAVE_KEY := "本地双人"
const SAVE_VERSION := 2
const BAG_KEYS := ["装备列表", "道具列表", "消耗品列表"]
const PLAYER_DATA_SCRIPT := preload("res://Script/memory_class/player_data.gd")
const PROPS_SCRIPT := preload("res://Script/base/base_role_properies.gd")
const PASSIVE_SCRIPT := preload("res://passive_skills.gd")
const INPUT_VIEW := preload("res://Script/coop/coop_input.gd")
const PANEL_PATHS := {
	"背包": "res://Scene/back_pack/back_pack.tscn",
	"技能": "res://Scene/skill/learn_skill.tscn",
	"宠物": "res://Scene/pet/pet_interface.tscn",
	"法宝": "res://Scene/back_pack/magic_weapon_infor.tscn",
	"坐骑": "res://Scene/main_menu/mount_panel.tscn",
}
const P2_KEYS := {
	"move_left": KEY_LEFT,
	"move_right": KEY_RIGHT,
	"Exit": KEY_UP,
	"down": KEY_DOWN,
	"normalhit": KEY_KP_1,
	"jump": KEY_KP_2,
	"slz": KEY_KP_3,
	"lys": KEY_KP_4,
	"lyfb": KEY_KP_5,
	"hmz": KEY_KP_6,
	"hytj": KEY_KP_8,
	"无双": KEY_KP_0,
	"MagicWeapon": KEY_KP_9,
	"MountToggle": KEY_KP_DIVIDE,
	"阵法": KEY_KP_MULTIPLY,
	"MDS": KEY_KP_SUBTRACT,
	"backpack": KEY_KP_ADD,
	"技能": KEY_INSERT,
}

var secondary_data: Node
var secondary_props: Node
var secondary_passives: Node
var inputs: Array[CoopInput] = []
var ui_slot := 1
var creation_player_count := 1
var _property_cache: Dictionary = {}
var _owner_fields_cache: Dictionary = {}
var _target_elapsed := 0.0
var _panel_layer: CanvasLayer
var _previous_windows: Node
var _panel: Node
var _panel_type := ""
var _panel_scene: PackedScene
var _switching_panel := false
var _panel_was_paused := false
var _session_buttons: CanvasLayer
var _primary_runtime_data: Node
var _primary_runtime_props: Node
var _primary_hero: Node
var _primary_data: Dictionary = {}
var _primary_properties: Dictionary = {}
var _view_swapped := false
var _shared_soul := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for slot in [1, 2]:
		var view: CoopInput = INPUT_VIEW.new()
		view.slot = slot
		view.session = self
		inputs.append(view)
	for action: String in P2_KEYS:
		var name := "p2_" + action
		if not InputMap.has_action(name):
			InputMap.add_action(name)
			var key := InputEventKey.new()
			key.physical_keycode = P2_KEYS[action]
			InputMap.action_add_event(name, key)
	get_tree().scene_changed.connect(_on_scene_changed)


func is_enabled() -> bool:
	var primary: Dictionary = _primary_data if _view_swapped else PlayerData.player_data
	return (
		not OS.has_feature("mobile")
		and is_instance_valid(secondary_data)
		and bool(primary.get(SAVE_KEY, {}).get("启用", false))
	)


func _default_profile() -> Dictionary:
	var seed := PLAYER_DATA_SCRIPT.new()
	var profile: Dictionary = seed.player_data.duplicate(true)
	seed.free()
	return profile


func create_secondary(role_id: int) -> void:
	clear_runtime()
	var profile := _default_profile()
	profile["Myself"] = clampi(role_id, 1, 7)
	profile["存档名称"] = "2P"
	PlayerData.player_data[SAVE_KEY] = {"版本": SAVE_VERSION, "启用": true, "2P": profile}
	load_profile()


func load_profile() -> void:
	clear_runtime()
	var saved: Variant = PlayerData.player_data.get(SAVE_KEY, {})
	if not saved is Dictionary or not saved.get("2P", {}) is Dictionary:
		return
	var profile: Dictionary = saved.get("2P", {})
	if not bool(saved.get("启用", false)) or OS.has_feature("mobile") or int(profile.get("Myself", 0)) not in range(1, 8):
		return
	PlayerData.ensure_main_sword_array()
	PlayerData.ensure_player_passive_skills()
	secondary_data = PLAYER_DATA_SCRIPT.new()
	secondary_data.name = "SecondPlayerData"
	secondary_data.set_meta("coop_slot", 2)
	secondary_data.player_data = _default_profile()
	secondary_data.player_data.merge(profile.duplicate(true), true)
	var shared_passives: Dictionary = PlayerData.player_data["被动技能"]
	var old_passives: Variant = profile.get("被动技能", {})
	if old_passives is Dictionary:
		for skill_name: String in PlayerData.PLAYER_PASSIVE_SKILL_KEYS:
			shared_passives[skill_name] = maxi(int(shared_passives[skill_name]), int(old_passives.get(skill_name, 0)))
	link_passive_skills()
	var levels: Dictionary = PlayerData.player_data[PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY]
	var old_levels: Variant = profile.get(PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY, {})
	if old_levels is Dictionary:
		for sword_id: String in PlayerData.MAIN_SWORD_ARRAY_LEVEL_DEFAULT:
			levels[sword_id] = maxi(int(levels[sword_id]), int(old_levels.get(sword_id, 0)))
	if str(PlayerData.player_data[PlayerData.MAIN_SWORD_ARRAY_KEY]).is_empty():
		PlayerData.player_data[PlayerData.MAIN_SWORD_ARRAY_KEY] = str(profile.get(PlayerData.MAIN_SWORD_ARRAY_KEY, ""))
	link_main_sword_array()
	PlayerData.ensure_main_sword_array()
	var initial_soul := clampi(int(PlayerData.player_data.get("coin_num", 0)), PlayerData.SOUL_MIN, PlayerData.SOUL_MAX)
	if int(saved.get("版本", 1)) < SAVE_VERSION:
		initial_soul += clampi(int(profile.get("coin_num", 0)), PlayerData.SOUL_MIN, PlayerData.SOUL_MAX)
	set_shared_soul(initial_soul)
	saved["版本"] = SAVE_VERSION
	secondary_props = PROPS_SCRIPT.new()
	secondary_props.name = "SecondRoleProperties"
	secondary_props.set_meta("coop_slot", 2)
	secondary_props.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(secondary_props)
	add_child(secondary_data)
	secondary_passives = PASSIVE_SCRIPT.new()
	secondary_passives.name = "SecondPassiveSkills"
	secondary_passives.set_meta("coop_slot", 2)
	secondary_passives.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(secondary_passives)
	secondary_passives.get_passive_skill_properties()
	secondary_props.baseroleprop.Level = int(secondary_data.player_data.get("玩家等级", 1))
	secondary_props.baseroleprop.exp = int(secondary_data.player_data.get("玩家当前经验", 0))
	secondary_props.set_basic_prop()
	link_bags()


func link_bags() -> void:
	if not is_instance_valid(secondary_data):
		return
	for key: String in BAG_KEYS:
		secondary_data.player_data[key] = (_primary_data if _view_swapped else PlayerData.player_data)[key]
	link_main_sword_array()


func link_passive_skills() -> void:
	if not is_enabled():
		return
	secondary_data.player_data["被动技能"] = data_for_slot(1).player_data["被动技能"]


func refresh_passive_skills() -> void:
	if not is_enabled():
		return
	link_passive_skills()
	PaSkill.get_passive_skill_properties()
	secondary_passives.get_passive_skill_properties()
	for slot in [1, 2]:
		var props: Node = props_for(data_for_slot(slot))
		props.get_last_prop()
		props.check_hp()
		props.check_mp()


func link_main_sword_array() -> void:
	if not is_enabled():
		return
	var primary: Dictionary = _primary_data if _view_swapped else PlayerData.player_data
	secondary_data.player_data[PlayerData.MAIN_SWORD_ARRAY_KEY] = primary.get(PlayerData.MAIN_SWORD_ARRAY_KEY, "")
	secondary_data.player_data[PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY] = primary[PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY]


func refresh_main_sword_array() -> void:
	link_main_sword_array()
	for props: Node in [
		_primary_runtime_props if _view_swapped else RoleProp, RoleProp if _view_swapped else secondary_props
	]:
		if not is_instance_valid(props):
			continue
		props.set_basic_prop()
		props.check_hp()
		props.check_mp()
		if is_instance_valid(props.source_player):
			props.source_player._sync_main_sword_array_weapon()
			props.source_player.jsfzsy()


func save_profile(snapshot: Dictionary) -> void:
	if not is_instance_valid(secondary_data):
		return
	var profile: Dictionary = secondary_data.player_data.duplicate(true)
	for key: String in BAG_KEYS:
		profile.erase(key)
	profile.erase(PlayerData.MAIN_SWORD_ARRAY_KEY)
	profile.erase(PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY)
	profile.erase("被动技能")
	profile.erase(SAVE_KEY)
	snapshot["coin_num"] = normalize_shared_soul()
	profile.erase("coin_num")
	snapshot[SAVE_KEY] = {
		"版本": SAVE_VERSION,
		"启用": bool(PlayerData.player_data.get(SAVE_KEY, {}).get("启用", false)),
		"2P": profile,
	}


func shares_soul_with(profile: Node) -> bool:
	return is_enabled() and (profile == PlayerData or profile == secondary_data or profile == _primary_runtime_data)


func normalize_shared_soul() -> int:
	var primary: Dictionary = _primary_data if _view_swapped else PlayerData.player_data
	var value := int(primary.get("coin_num", _shared_soul))
	value += int(secondary_data.player_data.get("coin_num", _shared_soul)) - _shared_soul
	return set_shared_soul(value)


func set_shared_soul(value: int) -> int:
	_shared_soul = clampi(value, PlayerData.SOUL_MIN, PlayerData.SOUL_MAX)
	var primary: Dictionary = _primary_data if _view_swapped else PlayerData.player_data
	primary["coin_num"] = _shared_soul
	secondary_data.player_data["coin_num"] = _shared_soul
	return _shared_soul


func clear_runtime() -> void:
	suspend_player_view()
	ui_slot = 1
	for node in [secondary_passives, secondary_props, secondary_data, _primary_runtime_data, _primary_runtime_props]:
		if is_instance_valid(node):
			node.free()
	secondary_passives = null
	secondary_props = null
	secondary_data = null
	_primary_runtime_data = null
	_primary_runtime_props = null
	_shared_soul = 0


func _has_property(node: Object, key: String) -> bool:
	var script: Variant = node.get_script()
	var cache_key: Variant = script if script != null else node.get_class()
	if not _property_cache.has(cache_key):
		var names: Dictionary = {}
		for item: Dictionary in node.get_property_list():
			names[str(item.name)] = true
		_property_cache[cache_key] = names
	return _property_cache[cache_key].has(key)


func owner_hero(node: Node, depth := 0) -> Node:
	if not is_instance_valid(node) or depth > 4:
		return null
	var parent := node
	while parent != null:
		if parent is BaseHero:
			return parent
		if parent is BaseLevel or parent == self or parent == get_tree().root:
			return null
		var script: Variant = parent.get_script()
		var cache_key: Variant = script if script != null else parent.get_class()
		if not _owner_fields_cache.has(cache_key):
			var fields: Array[String] = []
			for key: String in [
				"Player",
				"owner_player",
				"hero",
				"GetObj",
				"Parent",
				"source",
				"source_weapon",
				"summoner",
				"player_reference"
			]:
				if _has_property(parent, key):
					fields.append(key)
			_owner_fields_cache[cache_key] = fields
		for key: String in _owner_fields_cache[cache_key]:
			var value: Variant = parent.get(key)
			if is_instance_valid(value) and value is Node and value != parent:
				var found := owner_hero(value, depth + 1)
				if found != null:
					return found
		parent = parent.get_parent()
	return null


func slot_for(node: Node) -> int:
	if not is_instance_valid(node) or not is_enabled():
		return 1
	if node == PlayerData or node == RoleProp:
		return 2 if _view_swapped else 1
	if node.has_meta("coop_damage_slot"):
		return int(node.get_meta("coop_damage_slot"))
	if node is BaseMonster:
		return int(node.get_player.get_meta("coop_slot", 1)) if is_instance_valid(node.get_player) else 1
	var parent := node
	while parent != null:
		if parent.has_meta("coop_slot"):
			return int(parent.get_meta("coop_slot"))
		parent = parent.get_parent()
	var owner := owner_hero(node)
	if owner != null:
		return int(owner.get_meta("coop_slot", 1))
	for key: String in ["MyFather", "owner_monster", "source_monster"]:
		if _has_property(node, key):
			var source: Variant = node.get(key)
			if is_instance_valid(source) and source is BaseMonster and is_instance_valid(source.get_player):
				return int(source.get_player.get_meta("coop_slot", 1))
	var path := str(node.get_script().resource_path) if node.get_script() != null else ""
	if (
		path.begins_with("res://Script/back_pack/")
		or path.begins_with("res://Script/skill/")
		or path.begins_with("res://Script/other_scene/")
		or path.begins_with("res://Script/magic_weapon/")
	):
		return ui_slot
	return 1


func data_for(node: Node) -> Node:
	return data_for_slot(slot_for(node))


func data_for_slot(slot: int) -> Node:
	if slot == 2 and is_instance_valid(secondary_data):
		return secondary_data
	return _primary_runtime_data if _view_swapped else PlayerData


func pet_profile_for(pet: Dictionary) -> Node:
	if is_enabled():
		for slot in [1, 2]:
			var profile := data_for_slot(slot)
			for entry in profile.player_data.get("宠物列表", []):
				if is_same(entry, pet):
					return profile
	return PlayerData


func pet_meta_key(key: String, slot: int) -> String:
	return key + "_p2" if slot == 2 else key


func props_for(node: Node) -> Node:
	if slot_for(node) == 2:
		return RoleProp if _view_swapped else secondary_props
	return _primary_runtime_props if _view_swapped else RoleProp


func props_for_slot(slot: int) -> Node:
	if slot == 2:
		return RoleProp if _view_swapped else secondary_props
	return _primary_runtime_props if _view_swapped else RoleProp


func input_for(node: Node) -> CoopInput:
	return inputs[slot_for(node) - 1]


func living_players() -> Array[BaseHero]:
	var result: Array[BaseHero] = []
	for props in [
		_primary_runtime_props if _view_swapped else RoleProp, RoleProp if _view_swapped else secondary_props
	]:
		if is_instance_valid(props) and is_instance_valid(props.source_player) and not props.source_player.is_death:
			result.append(props.source_player)
	return result


func all_players_dead() -> bool:
	return is_enabled() and living_players().is_empty()


func _physics_process(delta: float) -> void:
	if not is_enabled() or get_tree().paused:
		return
	var level := get_tree().current_scene
	if not level is BaseLevel:
		return
	_target_elapsed += delta
	if _target_elapsed < 0.15:
		return
	_target_elapsed = 0.0
	var players := living_players()
	if players.is_empty():
		return
	for monster: BaseMonster in level.get_active_monsters():
		var nearest: BaseHero = players[0]
		for player: BaseHero in players:
			if (
				monster.global_position.distance_squared_to(player.global_position)
				< monster.global_position.distance_squared_to(nearest.global_position)
			):
				nearest = player
		monster.get_player = nearest


func _on_scene_changed() -> void:
	if is_instance_valid(_session_buttons):
		_session_buttons.queue_free()
	ui_slot = 1
	var scene := get_tree().current_scene
	if not is_enabled() or scene == null:
		return
	if not scene.scene_file_path.begins_with("res://Scene/main_menu/map_") and not scene is BaseLevel:
		return
	_session_buttons = CanvasLayer.new()
	_session_buttons.layer = 12
	scene.add_child(_session_buttons)
	var row := HBoxContainer.new()
	row.position = Vector2(325, 4)
	_session_buttons.add_child(row)
	for slot in [1, 2]:
		for type: String in ["背包", "技能"]:
			var button := Button.new()
			button.text = "%dP%s" % [slot, type]
			button.add_theme_font_override("font", load("res://Font/1_fonts_fzcy_fz_cu_yuan_m03.ttf"))
			button.pressed.connect(open_panel.bind(slot, type))
			row.add_child(button)
	if not scene is BaseLevel:
		(
			row
			. set_deferred(
				"position",
				Vector2(
					get_viewport().get_visible_rect().size.x - row.get_combined_minimum_size().x - 12,
					get_viewport().get_visible_rect().size.y - 42,
				)
			)
		)


func open_panel(slot: int, type: String) -> void:
	if is_instance_valid(_panel) or _switching_panel or not is_enabled() or not PANEL_PATHS.has(type):
		return
	ui_slot = slot
	_panel_was_paused = get_tree().paused
	get_tree().paused = true
	if slot == 2:
		resume_player_view()
	_panel_type = type
	_panel_scene = load(PANEL_PATHS[type]) as PackedScene
	var layer := CanvasLayer.new()
	layer.layer = 30
	get_tree().current_scene.add_child(layer)
	_panel_layer = layer
	_previous_windows = Global.windows
	Global.windows = layer
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.25)
	shade.size = get_viewport().get_visible_rect().size
	layer.add_child(shade)
	_create_panel(slot, type)


func _create_panel(slot: int, type: String) -> void:
	var path: String = PANEL_PATHS[type]
	_panel = _panel_scene.instantiate()
	if type == "背包":
		_panel.set_script(load("res://Script/coop/coop_backpack.gd"))
	_panel.set_meta("coop_slot", slot)
	_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	if type == "背包":
		var player: Variant = RoleProp.source_player
		if _has_property(_panel, "Player"):
			_panel.set("Player", player if is_instance_valid(player) else null)
		Global.configure_backpack_role_preview(_panel, player)
	Global.register_ui_runtime_instance(_panel, path)
	_panel.tree_exited.connect(_on_panel_closed, CONNECT_ONE_SHOT)
	_panel_layer.add_child(_panel)
	get_tree().paused = true
	if type in ["背包", "法宝"]:
		_panel.position = get_viewport().get_visible_rect().size * 0.5
	elif type == "宠物":
		_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		_panel.size = Vector2(653, 513)
		_panel.position = (get_viewport().get_visible_rect().size - _panel.size) * 0.5
	if type == "法宝" and PlayerData.player_data.get("法宝", []).is_empty():
		for child in _panel.get_node("BG").get_children():
			if child is CanvasItem and child.name != "Close":
				child.hide()
		var empty := Label.new()
		empty.name = "EmptyMagicWeapon"
		empty.text = "当前角色未装备法宝"
		empty.position = Vector2(-200, -40)
		empty.size = Vector2(400, 80)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.add_theme_font_override("font", load("res://Font/1_fonts_fzcy_fz_cu_yuan_m03.ttf"))
		empty.add_theme_font_size_override("font_size", 24)
		_panel.add_child(empty)
	_panel.set_meta("coop_layer", _panel_layer)
	_add_player_selector(type)


func _add_player_selector(type: String) -> void:
	var tabs: BoxContainer = HBoxContainer.new() if type in ["技能", "坐骑"] else VBoxContainer.new()
	tabs.name = "CoopPlayerSelector"
	tabs.add_theme_constant_override("separation", 6)
	match type:
		"背包":
			tabs.position = Vector2(-408, -195)
		"技能":
			tabs.position = Vector2(394, 6)
		"宠物":
			tabs.position = Vector2(-50, 40)
		"法宝":
			tabs.position = Vector2(-355, -177)
		"坐骑":
			tabs.position = Vector2(24, 15)
	var group := ButtonGroup.new()
	for slot in [1, 2]:
		var button := Button.new()
		button.name = "Player%d" % slot
		button.text = "%dP" % slot
		button.custom_minimum_size = Vector2(66 if type == "技能" else 46, 40)
		button.toggle_mode = true
		button.button_group = group
		button.set_pressed_no_signal(slot == ui_slot)
		button.add_theme_font_override("font", load("res://Font/1_fonts_fzcy_fz_cu_yuan_m03.ttf"))
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_color_override("font_color", Color("e9d6ae"))
		button.add_theme_color_override("font_pressed_color", Color("fff2b4"))
		for state: String in ["normal", "hover", "pressed", "focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = Color("85511c") if state == "pressed" else Color("36200f")
			style.border_color = Color("ffd473") if state in ["pressed", "focus"] else Color("a47738")
			style.set_border_width_all(2)
			style.set_corner_radius_all(5)
			button.add_theme_stylebox_override(state, style)
		button.pressed.connect(_switch_panel.bind(slot))
		tabs.add_child(button)
	if type == "坐骑":
		_panel.panel_root.add_child(tabs)
	else:
		_panel.add_child(tabs)


func _switch_panel(slot: int) -> void:
	if _switching_panel or slot == ui_slot or not is_instance_valid(_panel):
		return
	_switching_panel = true
	_replace_panel.call_deferred(slot)


func _replace_panel(slot: int) -> void:
	if not is_instance_valid(_panel) or not is_instance_valid(_panel_layer):
		_switching_panel = false
		return
	var old_panel := _panel
	old_panel.tree_exited.disconnect(_on_panel_closed)
	Global.clear_hover_popup()
	old_panel.free()
	suspend_player_view()
	link_bags()
	ui_slot = slot
	if slot == 2:
		resume_player_view()
	_create_panel(slot, _panel_type)
	_switching_panel = false


func _on_panel_closed() -> void:
	if not is_inside_tree():
		return
	if is_instance_valid(_panel_layer):
		_panel_layer.queue_free()
	Global.windows = _previous_windows if is_instance_valid(_previous_windows) else null
	suspend_player_view()
	ui_slot = 1
	_panel = null
	_panel_scene = null
	link_bags()
	refresh_passive_skills()
	if is_instance_valid(secondary_props):
		secondary_props.get_equ_last_pro()
		secondary_props.get_last_prop()
	get_tree().paused = _panel_was_paused
	if Global.cd_path != "":
		MemoryClass.save_game(Global.cd_path)


func suspend_player_view() -> bool:
	if not _view_swapped:
		return false
	normalize_shared_soul()
	secondary_data.player_data = PlayerData.player_data
	for key: String in _primary_properties:
		secondary_props.set(key, RoleProp.get(key))
		RoleProp.set(key, _primary_runtime_props.get(key))
	PlayerData.player_data = _primary_data
	Global.get_player = _primary_hero if is_instance_valid(_primary_hero) else null
	_view_swapped = false
	return true


func resume_player_view() -> void:
	if _view_swapped or not is_instance_valid(secondary_data):
		return
	normalize_shared_soul()
	_primary_data = PlayerData.player_data
	if not is_instance_valid(_primary_runtime_data):
		_primary_runtime_data = PLAYER_DATA_SCRIPT.new()
		_primary_runtime_data.set_meta("coop_slot", 1)
		_primary_runtime_data.player_data = _primary_data
		_primary_runtime_data.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(_primary_runtime_data)
		_primary_runtime_props = PROPS_SCRIPT.new()
		_primary_runtime_props.set_meta("coop_slot", 1)
		_primary_runtime_props.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(_primary_runtime_props)
	_primary_runtime_data.player_data = _primary_data
	_primary_hero = Global.get_player if is_instance_valid(Global.get_player) else null
	Global.get_player = secondary_props.source_player if is_instance_valid(secondary_props.source_player) else null
	_primary_properties.clear()
	for info: Dictionary in RoleProp.get_property_list():
		if (int(info.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0 and str(info.name) not in ["PlayerData", "RoleProp"]:
			_primary_properties[str(info.name)] = true
			_primary_runtime_props.set(info.name, RoleProp.get(info.name))
			RoleProp.set(info.name, secondary_props.get(info.name))
	PlayerData.player_data = secondary_data.player_data
	_view_swapped = true


func _unhandled_key_input(event: InputEvent) -> void:
	if not is_enabled() or not event is InputEventKey or event.echo or not event.pressed:
		return
	if event.physical_keycode == KEY_KP_ADD:
		open_panel(2, "背包")
		get_viewport().set_input_as_handled()
	elif event.physical_keycode == KEY_INSERT:
		open_panel(2, "技能")
		get_viewport().set_input_as_handled()


func clear_player_buffs(player: BaseHero) -> void:
	if not is_instance_valid(player.buff):
		return
	for item in player.buff.get_children():
		if str(item.buff_info.get("Name", "")) != "DoubleFallPro":
			item.queue_free()


func has_panel() -> bool:
	return is_instance_valid(_panel)


func nearest_player(point: Vector2) -> BaseHero:
	var nearest: BaseHero
	var distance := INF
	for player: BaseHero in living_players():
		var current := point.distance_squared_to(player.global_position)
		if current < distance:
			distance = current
			nearest = player
	return nearest

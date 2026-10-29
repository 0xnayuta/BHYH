extends Node

const SAVE_KEY := "本地双人"
## 档案形状版本：3 起 2P 档案不再携带共享键副本；旧档在读档时按最大值合并，不丢数据。
const SAVE_VERSION := 3
## 灵魂共享引入版本：早于该版本的 2P 档内 coin_num 仍计入共享账本。
const SHARED_SOUL_VERSION := 2
const BAG_KEYS := ["装备列表", "道具列表", "消耗品列表", "宠物背包"]
const PLAYER_DATA_SCRIPT := preload("res://Script/memory_class/player_data.gd")
const PROPS_SCRIPT := preload("res://Script/base/base_role_properies.gd")
const BODY_TRAINING_DATA := preload("res://Script/data/body_training_data.gd")
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
## 双人死亡只提交一次；由场景切换或 clear_runtime 重置。
var _defeat_requested := false
## 测试可注入场景切换；生产走 Global.change_scene。
var scene_change_override: Callable
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
	return (
		not OS.has_feature("mobile")
		and is_instance_valid(secondary_data)
		and bool(PlayerData.player_data.get(SAVE_KEY, {}).get("启用", false))
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
	if int(saved.get("版本", 1)) < SHARED_SOUL_VERSION:
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
		if key != "宠物背包":
			secondary_data.player_data[key] = PlayerData.player_data[key]
	_link_shared_pet_backpack(PlayerData)
	_link_shared_attribute_progression()
	link_main_sword_array()


func _link_shared_pet_backpack(primary_data: Node) -> void:
	if not is_instance_valid(primary_data) or not is_instance_valid(secondary_data):
		return
	if primary_data.has_method("ensure_shared_pet_backpack"):
		primary_data.ensure_shared_pet_backpack()
	if secondary_data.has_method("ensure_shared_pet_backpack"):
		secondary_data.ensure_shared_pet_backpack()
	var primary_pack: Variant = primary_data.player_data.get("宠物背包", [])
	var secondary_pack: Variant = secondary_data.player_data.get("宠物背包", [])
	if not (primary_pack is Array) or not (secondary_pack is Array):
		return
	if primary_pack != secondary_pack:
		var merged: Array = (primary_pack as Array).duplicate(true)
		for item in secondary_pack:
			if item is Dictionary:
				merged.append((item as Dictionary).duplicate(true))
		primary_pack = merged
		primary_data.player_data["宠物背包"] = primary_pack
	secondary_data.player_data["宠物背包"] = primary_pack


func _merge_progression_dict(primary: Dictionary, secondary: Dictionary) -> Dictionary:
	var merged: Dictionary = primary.duplicate(true)
	for key: Variant in secondary:
		var secondary_value: Variant = secondary[key]
		var primary_value: Variant = merged.get(key, null)
		if primary_value is Dictionary and secondary_value is Dictionary:
			merged[key] = _merge_progression_dict(primary_value, secondary_value)
		elif secondary_value is int or secondary_value is float:
			if primary_value is int or primary_value is float:
				merged[key] = maxi(int(primary_value), int(secondary_value))
			elif not merged.has(key):
				merged[key] = secondary_value
		elif not merged.has(key):
			merged[key] = secondary_value
	return merged


func _link_shared_attribute_progression() -> void:
	if not is_instance_valid(secondary_data):
		return
	var training := BODY_TRAINING_DATA.normalize_state(PlayerData.player_data.get("炼体", {}))
	var secondary_training := BODY_TRAINING_DATA.normalize_state(secondary_data.player_data.get("炼体", {}))
	var combined_training := _merge_progression_dict(training, secondary_training)
	var all_training: Dictionary = _merge_progression_dict(
		combined_training.get("p1", {}), combined_training.get("p2", {})
	)
	combined_training["p1"] = all_training.duplicate(true)
	combined_training["p2"] = all_training.duplicate(true)
	PlayerData.player_data["炼体"] = combined_training
	secondary_data.player_data["炼体"] = combined_training
	var catalog := _merge_progression_dict(
		PlayerData.player_data.get(PlayerData.WANLING_CATALOG_LEVELS_KEY, {}),
		secondary_data.player_data.get(PlayerData.WANLING_CATALOG_LEVELS_KEY, {})
	)
	PlayerData.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY] = catalog
	secondary_data.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY] = catalog


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
	secondary_data.player_data[PlayerData.MAIN_SWORD_ARRAY_KEY] = PlayerData.player_data.get(
		PlayerData.MAIN_SWORD_ARRAY_KEY, ""
	)
	secondary_data.player_data[PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY] = PlayerData.player_data[
		PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY
	]


func refresh_main_sword_array() -> void:
	link_main_sword_array()
	for slot in [1, 2]:
		var props: Node = props_for_slot(slot)
		if not is_instance_valid(props):
			continue
		props.set_basic_prop()
		props.check_hp()
		props.check_mp()
		if is_instance_valid(props.source_player):
			props.source_player._sync_main_sword_array_weapon()
			props.source_player.jsfzsy()


## 共享账本键：由 1P 档案唯一持有，2P 仅在运行期引用同一容器。
## 新增共享项必须在此登记，否则会重新出现两套可写真源。
func shared_keys() -> Array[String]:
	var keys: Array[String] = []
	keys.append_array(BAG_KEYS)
	keys.append("被动技能")
	keys.append(PlayerData.MAIN_SWORD_ARRAY_KEY)
	keys.append(PlayerData.MAIN_SWORD_ARRAY_LEVEL_KEY)
	keys.append("炼体")
	keys.append(PlayerData.WANLING_CATALOG_LEVELS_KEY)
	keys.append("coin_num")
	return keys


## 共享账本一致性：逐键报告 1P/2P 是否同一容器且值相等，供探针与调试验证。
func shared_ledger_report() -> Dictionary:
	var report: Dictionary = {}
	if not is_instance_valid(secondary_data):
		return report
	var primary := canonical_profile_for_slot(1)
	for key: String in shared_keys():
		var primary_value: Variant = primary.player_data.get(key, null)
		var secondary_value: Variant = secondary_data.player_data.get(key, null)
		report[key] = {
			"same_container": is_same(primary_value, secondary_value),
			"equal": JSON.stringify(primary_value) == JSON.stringify(secondary_value),
		}
	return report


## 槽位查询的可枚举快照：确认每个槽位的数据/属性所有者与角色。
func slot_snapshot() -> Dictionary:
	var result: Dictionary = {}
	for slot in [1, 2]:
		var profile := data_for_slot(slot)
		var props := props_for_slot(slot)
		var active: bool = slot == 1 or is_instance_valid(secondary_data)
		result[slot] = {
			"slot": slot,
			"active": active,
			"data_is_secondary": is_instance_valid(secondary_data) and profile == secondary_data,
			"props_is_secondary": is_instance_valid(secondary_props) and props == secondary_props,
			"role_id": int(profile.player_data.get("Myself", 1)) if profile != null and active else 0,
		}
	return result


func save_profile(snapshot: Dictionary) -> void:
	if not is_instance_valid(secondary_data):
		return
	var profile: Dictionary = secondary_data.player_data.duplicate(true)
	# 共享项只由 1P 档案持有：2P 档案不写任何共享副本。
	for key: String in shared_keys():
		profile.erase(key)
	profile.erase(SAVE_KEY)
	snapshot["coin_num"] = normalize_shared_soul()
	snapshot[SAVE_KEY] = {
		"版本": SAVE_VERSION,
		"启用": bool(PlayerData.player_data.get(SAVE_KEY, {}).get("启用", false)),
		"2P": profile,
	}


func shares_soul_with(profile: Node) -> bool:
	return is_enabled() and (profile == PlayerData or profile == secondary_data)


func normalize_shared_soul() -> int:
	var value := int(PlayerData.player_data.get("coin_num", _shared_soul))
	value += int(secondary_data.player_data.get("coin_num", _shared_soul)) - _shared_soul
	return set_shared_soul(value)


func set_shared_soul(value: int) -> int:
	_shared_soul = clampi(value, PlayerData.SOUL_MIN, PlayerData.SOUL_MAX)
	PlayerData.player_data["coin_num"] = _shared_soul
	secondary_data.player_data["coin_num"] = _shared_soul
	return _shared_soul


func clear_runtime() -> void:
	ui_slot = 1
	_defeat_requested = false
	for node in [secondary_passives, secondary_props, secondary_data]:
		if is_instance_valid(node):
			node.free()
	secondary_passives = null
	secondary_props = null
	secondary_data = null
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
				"player",
				"owner_player",
				"source_player",
				"hero",
				"my_owner",
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


## 槽位解析顺序（遗留边界，新增代码不得依赖后两项）：
## 1. 全局别名（`PlayerData`/`RoleProp`，随视图交换切换）→ 当前视图槽位；
## 2. 节点 meta `coop_damage_slot`（伤害归属快照）；
## 3. 怪物 → `get_player` 的 `coop_slot`；
## 4. 祖先链 meta `coop_slot`；
## 5. `owner_hero()` 沿持有者字段回溯到 BaseHero 的 `coop_slot`；
## 6. 弹体/召唤物经 `MyFather`/`owner_monster`/`source_monster` 回溯；
## 7. 脚本路径前缀（`back_pack`/`skill`/`other_scene`/`magic_weapon`）→ `ui_slot`；
## 8. 默认 1。
func slot_for(node: Node) -> int:
	if not is_instance_valid(node) or not is_enabled():
		return 1
	if node == PlayerData or node == RoleProp:
		return 1
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
	return canonical_profile_for_slot(slot)


## 槽位权威档案：1P 恒为 Autoload，2P 仅在会话内有效；与视图状态无关。
func canonical_profile_for_slot(slot: int) -> Node:
	if slot == 2 and is_instance_valid(secondary_data):
		return secondary_data
	return PlayerData


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
	return props_for_slot(slot_for(node))


func props_for_slot(slot: int) -> Node:
	if slot == 2 and is_instance_valid(secondary_props):
		return secondary_props
	return RoleProp


func refresh_pellet_props() -> void:
	if not is_enabled():
		return
	for slot in [1, 2]:
		var props := props_for_slot(slot)
		if not is_instance_valid(props):
			continue
		props.get_last_prop()
		props.check_hp()
		props.check_mp()


func increment_pellet_count(key: String) -> void:
	if not is_enabled():
		return
	PlayerData.player_data[key] = mini(5, int(PlayerData.player_data.get(key, 0)) + 1)
	secondary_data.player_data[key] = mini(5, int(secondary_data.player_data.get(key, 0)) + 1)
	refresh_pellet_props()


func input_for(node: Node) -> CoopInput:
	return inputs[slot_for(node) - 1]


func living_players() -> Array[BaseHero]:
	var result: Array[BaseHero] = []
	for slot in [1, 2]:
		var props: Node = props_for_slot(slot)
		if is_instance_valid(props) and is_instance_valid(props.source_player) and not props.source_player.is_death:
			result.append(props.source_player)
	return result


func all_players_dead() -> bool:
	return is_enabled() and living_players().is_empty()


## 单人或双人均死亡后请求一次败北场景；未全灭或已请求时返回 false。
func request_defeat_if_all_players_dead() -> bool:
	if is_enabled() and not all_players_dead():
		return false
	if _defeat_requested:
		return false
	_defeat_requested = true
	var target := "res://Scene/level/defeat.tscn"
	var changed := false
	if scene_change_override.is_valid():
		changed = bool(scene_change_override.call(target))
	else:
		changed = Global.change_scene(target)
	if not changed:
		_defeat_requested = false
	return changed


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
		var nearest := nearest_player(monster.global_position)
		if nearest != null:
			monster.get_player = nearest


func _on_scene_changed() -> void:
	_defeat_requested = false
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
	if MemoryClass != null and MemoryClass.has_method("is_save_snapshot_in_progress"):
		if bool(MemoryClass.is_save_snapshot_in_progress()):
			return
	ui_slot = slot
	_panel_was_paused = get_tree().paused
	get_tree().paused = true
	_panel_type = type
	_panel_scene = load(PANEL_PATHS[type]) as PackedScene
	var layer := CanvasLayer.new()
	layer.layer = 30
	# 弹出层携带槽位，供 Global.windows 下的子面板与弹窗解析操作者。
	layer.set_meta("coop_slot", slot)
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
		var player: Variant = props_for_slot(slot).source_player
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
	_panel.set_meta("coop_layer", _panel_layer)
	_add_player_selector(type)


func _add_player_selector(type: String) -> void:
	var tabs: BoxContainer
	if type in ["技能", "坐骑"]:
		tabs = HBoxContainer.new()
	else:
		tabs = VBoxContainer.new()
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
	link_bags()
	ui_slot = slot
	_panel_layer.set_meta("coop_slot", slot)
	_create_panel(slot, _panel_type)
	_switching_panel = false


func _on_panel_closed() -> void:
	if not is_inside_tree():
		return
	if is_instance_valid(_panel_layer):
		_panel_layer.queue_free()
	Global.windows = _previous_windows if is_instance_valid(_previous_windows) else null
	ui_slot = 1
	_panel = null
	_panel_scene = null
	link_bags()
	refresh_passive_skills()
	if is_instance_valid(secondary_props):
		secondary_props.get_equ_last_pro()
		secondary_props.get_last_prop()
	get_tree().paused = _panel_was_paused
	Global.request_save_with_feedback(
		"coop_panel_close", Global.windows if is_instance_valid(Global.windows) else self, "面板关闭保存失败："
	)


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


## 关闭当前协作面板；生命周期收口仍由 _on_panel_closed 统一处理。
func close_panel() -> void:
	if is_instance_valid(_panel):
		_panel.queue_free()


func nearest_player(point: Vector2) -> BaseHero:
	var nearest: BaseHero
	var distance := INF
	for player: BaseHero in living_players():
		var current := point.distance_squared_to(player.global_position)
		if current < distance:
			distance = current
			nearest = player
	return nearest

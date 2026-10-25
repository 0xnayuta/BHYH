extends Node2D

var back_target
var set_target
var skill_target
var magic_weapon_target
var pet_target
var cur_level
var bp_c: int = 0
var _backpack_scene: PackedScene

const BACKPACK_SCENE := "res://Scene/back_pack/back_pack.tscn"
const SET_MENU_SCENE := "res://Scene/set_menu.tscn"
const PET_INTERFACE_SCENE := "res://Scene/pet/pet_interface.tscn"
const ESCAPE_CLOSE_METHOD := &"request_escape_close"


func _viewport_center() -> Vector2:
	return get_viewport().get_visible_rect().size * 0.5


func _ready() -> void:
	_refresh_level()
	if not is_instance_valid(cur_level):
		call_deferred("_refresh_level")


func _refresh_level() -> void:
	cur_level = _resolve_level()


func _active_level():
	if not is_instance_valid(cur_level):
		_refresh_level()
	return cur_level


func _get_backpack_scene() -> PackedScene:
	if _backpack_scene != null:
		return _backpack_scene
	_backpack_scene = Global.load_ui_scene(BACKPACK_SCENE)
	return _backpack_scene


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_B or event.keycode == KEY_B:
			_toggle_pet()
			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("菜单"):
		# ESC 在暂停树中仍需生效：本节点为 PROCESS_MODE_ALWAYS。
		if not _close_topmost_window():
			_on_set_pressed()
		_refresh_pause_state()
		get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	_cleanup_targets()
	bp_c = get_child_count()
	if Input.is_action_just_pressed("backpack") and _main_role() != null:
		_toggle_backpack(_main_role())
	if InputMap.has_action("backpack1") and Input.is_action_just_pressed("backpack1") and _second_role() != null:
		_toggle_backpack(_second_role())
	if Input.is_action_just_pressed("技能") and _main_role() != null:
		_toggle_skill(_main_role())
	if Input.is_action_just_pressed("法宝") and _main_role() != null:
		_toggle_magic(_main_role())
	if InputMap.has_action("技能1") and Input.is_action_just_pressed("技能1") and _second_role() != null:
		_toggle_skill(_second_role())
	if InputMap.has_action("法宝1") and Input.is_action_just_pressed("法宝1") and _second_role() != null:
		_toggle_magic(_second_role())

	_refresh_pause_state()


func _main_role():
	var level = _active_level()
	if is_instance_valid(level):
		var level_role: Variant = level.get("role_")
		if is_instance_valid(level_role):
			return level_role
	var source_player: Variant = RoleProp.source_player
	return source_player if is_instance_valid(source_player) else null


func _second_role():
	var level = _active_level()
	if is_instance_valid(level):
		var second_role: Variant = level.get("role_p2")
		if is_instance_valid(second_role):
			return second_role
	return null


## ESC 统一入口：协作面板优先，其次关闭当前 HUD 窗口的最上层子层。
## 返回 true 表示已消费本次 ESC；false 表示没有可关闭的 UI，交由设置菜单处理。
func _close_topmost_window() -> bool:
	if LocalCoop.has_panel():
		LocalCoop.close_panel()
		return true
	_cleanup_targets()
	var window := _find_active_window()
	if window == null:
		return false
	if _dispatch_escape_close(window):
		return true
	if window.has_method(ESCAPE_CLOSE_METHOD) and bool(window.call(ESCAPE_CLOSE_METHOD)):
		return true
	_close_active_window(window)
	return true


func _find_active_window() -> Node:
	for window in [set_target, skill_target, magic_weapon_target, back_target, pet_target]:
		if _is_alive(window):
			return window
	return null


## 按子节点逆序递归，先处理更深的可视层，再处理当前节点；近似 Godot 的绘制顺序。
func _dispatch_escape_close(node: Node) -> bool:
	var children := node.get_children()
	for index in range(children.size() - 1, -1, -1):
		var child: Node = children[index]
		if not _is_alive(child) or not _is_ui_layer_visible(child):
			continue
		if _dispatch_escape_close(child):
			return true
		if child.has_method(ESCAPE_CLOSE_METHOD) and bool(child.call(ESCAPE_CLOSE_METHOD)):
			return true
	return false


func _is_ui_layer_visible(node: Node) -> bool:
	if node is CanvasItem:
		return (node as CanvasItem).is_visible_in_tree()
	if node is CanvasLayer:
		return (node as CanvasLayer).visible
	return node.is_inside_tree()


func _close_active_window(window: Node) -> void:
	if window == back_target:
		back_target = null
	elif window == set_target:
		set_target = null
	elif window == skill_target:
		skill_target = null
	elif window == magic_weapon_target:
		magic_weapon_target = null
	elif window == pet_target:
		pet_target = null
	_queue_target(window)


func _on_backpack_pressed() -> void:
	if _main_role() != null:
		_toggle_backpack(_main_role())


func _on_set_pressed() -> void:
	_cleanup_targets()
	if _is_alive(set_target):
		_queue_target(set_target)
		set_target = null
		return
	if _has_open_child():
		return
	var scene: PackedScene = Global.load_ui_scene(SET_MENU_SCENE)
	if scene == null:
		return
	set_target = scene.instantiate()
	Global.register_ui_runtime_instance(set_target, SET_MENU_SCENE)
	if set_target is CanvasLayer:
		set_target.layer = 4
	_track_target(set_target, "set")
	add_child(set_target)


func _on_skill_pressed() -> void:
	if _main_role() != null:
		_toggle_skill(_main_role())


func _on_magic_weapon_pressed() -> void:
	if _main_role() != null:
		_toggle_magic(_main_role())


func _on_pet_pressed() -> void:
	_toggle_pet()


func _toggle_backpack(_role) -> void:
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(LocalCoop.slot_for(_role), "背包")
		return
	_cleanup_targets()
	if _is_alive(back_target):
		_queue_target(back_target)
		back_target = null
		return
	if _has_open_child():
		return
	var scene: PackedScene = _get_backpack_scene()
	if scene == null:
		return
	back_target = scene.instantiate()
	Global.register_ui_runtime_instance(back_target, BACKPACK_SCENE)
	_set_if_has_property(back_target, "Player", _role)
	_set_if_has_property(back_target, "boxObj", self)
	Global.configure_backpack_role_preview(back_target, _role)
	_track_target(back_target, "backpack")
	add_child(back_target)
	back_target.position = _viewport_center()


func _toggle_skill(_role) -> void:
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(LocalCoop.slot_for(_role), "技能")
		return
	_cleanup_targets()
	if _is_alive(skill_target):
		_queue_target(skill_target)
		skill_target = null
		return
	if _has_open_child():
		return
	skill_target = Global.add_learn_skill(self, Vector2.ZERO)
	if skill_target != null:
		_set_if_has_property(skill_target, "Player", _role)
		_track_target(skill_target, "skill")


func _toggle_pet() -> void:
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(LocalCoop.slot_for(_main_role()), "宠物")
		return
	_cleanup_targets()
	if _is_alive(pet_target):
		_queue_target(pet_target)
		pet_target = null
		return
	if _has_open_child():
		return
	var scene: PackedScene = Global.load_ui_scene(PET_INTERFACE_SCENE)
	if scene == null:
		return
	pet_target = scene.instantiate()
	Global.register_ui_runtime_instance(pet_target, PET_INTERFACE_SCENE)
	_track_target(pet_target, "pet")
	add_child(pet_target)
	pet_target.position = _viewport_center() - Vector2(326.5, 256.5)


func _toggle_magic(_role) -> void:
	if LocalCoop.is_enabled():
		LocalCoop.open_panel(LocalCoop.slot_for(_role), "法宝")
		return
	_cleanup_targets()
	if _is_alive(magic_weapon_target):
		_queue_target(magic_weapon_target)
		magic_weapon_target = null
		return
	if _has_open_child():
		return
	magic_weapon_target = Global.add_magp_infor(self, _viewport_center())
	if magic_weapon_target != null:
		_track_target(magic_weapon_target, "magic")


func _resolve_level():
	var p := get_parent()
	while p != null:
		if p.get("role_") != null or p.get("role_information") != null:
			return p
		p = p.get_parent()
	return null


func _can_resume_level() -> bool:
	var level = _active_level()
	if level == null:
		return true
	var role_info = level.get("role_information")
	return role_info == null or not role_info.is_stop


func _refresh_pause_state() -> void:
	if _has_open_child():
		if not get_tree().paused:
			get_tree().paused = true
	elif get_tree().paused and _can_resume_level():
		get_tree().paused = false


func _has_open_child() -> bool:
	if LocalCoop.has_panel():
		return true
	_cleanup_targets()
	for child in get_children():
		if _is_alive(child):
			return true
	return (
		_is_alive(back_target)
		or _is_alive(set_target)
		or _is_alive(skill_target)
		or _is_alive(magic_weapon_target)
		or _is_alive(pet_target)
	)


func _cleanup_targets() -> void:
	if not _is_alive(back_target):
		back_target = null
	if not _is_alive(set_target):
		set_target = null
	if not _is_alive(skill_target):
		skill_target = null
	if not _is_alive(magic_weapon_target):
		magic_weapon_target = null
	if not _is_alive(pet_target):
		pet_target = null


func _is_alive(node) -> bool:
	return node != null and is_instance_valid(node) and not node.is_queued_for_deletion()


func _queue_target(node) -> void:
	if _is_alive(node):
		node.queue_free()


func _track_target(node, slot: String) -> void:
	if node == null:
		return
	if not node.tree_exited.is_connected(_on_target_exited):
		node.tree_exited.connect(_on_target_exited.bind(slot), CONNECT_ONE_SHOT)


func _on_target_exited(slot: String) -> void:
	match slot:
		"backpack":
			back_target = null
			_backpack_scene = null
		"set":
			set_target = null
		"skill":
			skill_target = null
		"magic":
			magic_weapon_target = null
		"pet":
			pet_target = null
	_refresh_pause_state()


func _set_if_has_property(obj: Object, prop_name: String, value) -> void:
	if obj == null:
		return
	for prop in obj.get_property_list():
		if str(prop.get("name", "")) == prop_name:
			obj.set(prop_name, value)
			return

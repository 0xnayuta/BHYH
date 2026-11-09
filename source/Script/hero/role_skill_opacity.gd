extends Node

## 按 MainSet.SkillEffectOpacity 调整角色技能表现层的透明度。
## 只处理技能/特效视觉，不改变角色本体与装备的默认透明度。

var _visuals: Dictionary = {}
var _previous_opacity := 1.0


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	RenderingServer.frame_pre_draw.connect(_apply_opacity)
	RenderingServer.frame_post_draw.connect(_restore_native_opacity)


func _on_node_added(node: Node) -> void:
	if node is CanvasItem and _is_role_skill_visual(node):
		_register_visual(node)


func _is_role_skill_visual(node: CanvasItem) -> bool:
	var current: Node = node
	var parts_effect := false
	while current != null:
		if current.is_in_group("role_skill_visual"):
			return true
		if current is BaseHero:
			return parts_effect
		var node_name := str(current.name)
		if node_name.begins_with("SpecialEffect") or node_name == "OriginalAttackEffect":
			return true
		var script := current.get_script() as Script
		if script != null and script.resource_path.begins_with("res://Script/hero/"):
			var file := script.resource_path.get_file()
			if file.ends_with("_official_parts.gd"):
				if current == node and node_name not in ["RoleBody", "RoleBodyFront", "RoleEquipment"]:
					parts_effect = true
			elif not file.ends_with("_data.gd"):
				return true
		current = current.get_parent()
	return false


func _register_visual(node: Variant) -> void:
	if not is_instance_valid(node) or not node is CanvasItem or not node.is_inside_tree():
		return
	var visual := node as CanvasItem
	var id: int = visual.get_instance_id()
	if _visuals.has(id):
		return
	_visuals[id] = {
		"node": weakref(visual),
		"base": visual.self_modulate.a,
		"last": visual.self_modulate.a,
		"restore": false,
	}
	visual.tree_exiting.connect(func() -> void: _visuals.erase(id), CONNECT_ONE_SHOT)


func _apply_opacity() -> void:
	var opacity: float = get_parent().get_skill_effect_opacity()
	if is_equal_approx(opacity, 1.0) and is_equal_approx(_previous_opacity, 1.0):
		return
	_previous_opacity = opacity
	for id: int in _visuals:
		var record: Dictionary = _visuals[id]
		var node := record["node"].get_ref() as CanvasItem
		if not is_instance_valid(node):
			continue
		var tint := node.self_modulate
		record["base"] = tint.a
		var alpha := float(record["base"]) * opacity
		record["restore"] = not is_equal_approx(tint.a, alpha)
		if not is_equal_approx(tint.a, alpha):
			tint.a = alpha
			node.self_modulate = tint
		record["last"] = alpha


func _restore_native_opacity() -> void:
	if is_equal_approx(_previous_opacity, 1.0):
		return
	for id: int in _visuals:
		var record: Dictionary = _visuals[id]
		if not record["restore"]:
			continue
		var node := record["node"].get_ref() as CanvasItem
		if is_instance_valid(node):
			var tint := node.self_modulate
			tint.a = float(record["base"])
			node.self_modulate = tint
		record["restore"] = false

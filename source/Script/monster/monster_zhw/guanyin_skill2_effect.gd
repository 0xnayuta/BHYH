extends Node2D
class_name GuanyinSkill2Effect

const ATLAS_1 := "res://Art/monster/guanyin_spine/skill_2_cropped/600020_skill1.atlas"
const SKELETON_1 := "res://Art/monster/guanyin_spine/skill_2_cropped/600020_skill1.spine-json"
const VISUAL_SCALE := 1.0
const EFFECT_DURATION := 3.45
const DAMAGE_RANGE_SCALE := 1.5
const ARMOR_BREAK_RATIO := 0.4
const ARMOR_BREAK_DURATION := 20.0
const STUN_CHANCE := 0.3
const STUN_DURATION := 2.0

const DAMAGE_NODES: Array[Dictionary] = [
	{"time": 0.633, "position": Vector2(156.25, 82.49), "size": Vector2(940.0, 746.0)},
	{"time": 0.667, "position": Vector2(160.15, 68.16), "size": Vector2(822.0, 710.0)},
	{"time": 1.97, "position": Vector2(54.36, 50.42), "size": Vector2(397.5, 270.0)},
	{"time": 1.97, "position": Vector2(50.81, 61.33), "size": Vector2(356.0, 346.0)},
	{"time": 1.97, "position": Vector2(57.21, 75.23), "size": Vector2(437.0, 322.0)},
	{"time": 1.97, "position": Vector2(56.21, 27.57), "size": Vector2(653.0, 372.0)},
	{"time": 1.97, "position": Vector2(73.24, 60.31), "size": Vector2(623.0, 208.0)},
	{"time": 2.0, "position": Vector2(41.51, 62.75), "size": Vector2(522.0, 234.0)},
	{"time": 2.6, "position": Vector2(-105.8, 178.68), "size": Vector2(250.0, 204.0)}
]

static var _data_1: Variant = null
static var _load_failed := false
static var _active_visuals := 0

@onready var layer_1: Variant = $Layer1
var source: Node = null
var damage_per_node: int = 1
var face_right := true
var show_visual := true
var _reserved_visual := false
var _debuffed_target_ids: Dictionary = {}


static func preload_effect_data() -> bool:
	if _load_failed:
		return false
	_data_1 = _load_data(ATLAS_1, SKELETON_1, _data_1)
	_load_failed = _data_1 == null
	return not _load_failed


static func clear_cached_data() -> void:
	_data_1 = null
	_load_failed = false
	_active_visuals = 0


static func reserve_visual_slot() -> bool:
	if _active_visuals > 0:
		return false
	_active_visuals += 1
	return true


static func _load_data(atlas_path: String, skeleton_path: String, cached: Variant) -> Variant:
	if cached != null:
		return cached
	if not ClassDB.class_exists("SpineSkeletonDataResource"):
		push_error("GuanyinSkill2Effect: Spine GDExtension is not loaded")
		return null
	var atlas := load(atlas_path)
	if atlas == null:
		push_error("GuanyinSkill2Effect: 无法加载 Spine atlas: " + atlas_path)
		return null
	var skeleton_file := load(skeleton_path)
	if skeleton_file == null:
		push_error("GuanyinSkill2Effect: 无法加载 Spine skeleton: " + skeleton_path)
		return null
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	skeleton_data.set_atlas_res(atlas)
	skeleton_data.set_skeleton_file_res(skeleton_file)
	skeleton_data.update_skeleton_data()
	if not skeleton_data.is_skeleton_data_loaded():
		push_error("GuanyinSkill2Effect: Spine 骨骼数据解析失败: " + skeleton_path)
		return null
	return skeleton_data


func setup(owner_node: Node, attack_power: int, is_facing_right: bool, use_visual := true) -> void:
	source = owner_node
	damage_per_node = maxi(1, attack_power * 5)
	face_right = is_facing_right
	_reserved_visual = reserve_visual_slot() if use_visual else false
	show_visual = _reserved_visual
	scale.x = 1.0 if face_right else -1.0


func _ready() -> void:
	if not show_visual:
		if layer_1 != null:
			layer_1.visible = false
		_run_original_timeline()
		return
	if not preload_effect_data() or layer_1 == null or not layer_1.has_method("set_skeleton_data_res"):
		queue_free()
		return

	layer_1.set_skeleton_data_res(_data_1)
	_setup_spine_blend_materials()
	_play_spine_animation(layer_1)
	_run_original_timeline()


func _play_spine_animation(target: Variant) -> void:
	if target == null or not is_instance_valid(target) or not target.has_method("get_animation_state"):
		return
	var animation_state: Variant = target.get_animation_state()
	if animation_state == null:
		await get_tree().process_frame
		if target == null or not is_instance_valid(target) or not target.has_method("get_animation_state"):
			return
		animation_state = target.get_animation_state()
	if animation_state != null:
		animation_state.set_animation("play", false, 0)


func _setup_spine_blend_materials() -> void:
	var normal_material := CanvasItemMaterial.new()
	normal_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	var additive_material := CanvasItemMaterial.new()
	additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	var multiply_material := CanvasItemMaterial.new()
	multiply_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	layer_1.set_normal_material(normal_material)
	layer_1.set_additive_material(additive_material)
	layer_1.set_screen_material(additive_material)
	layer_1.set_multiply_material(multiply_material)


func _run_original_timeline() -> void:
	var elapsed := 0.0
	for damage_node in DAMAGE_NODES:
		var hit_time := float(damage_node["time"])
		var wait_time := hit_time - elapsed
		if wait_time > 0.0:
			await get_tree().create_timer(wait_time).timeout
		if not is_inside_tree():
			return
		_damage_node(damage_node)
		elapsed = hit_time
	var remaining := EFFECT_DURATION - elapsed
	if remaining > 0.0:
		await get_tree().create_timer(remaining).timeout
	if layer_1 != null and layer_1.has_method("set_skeleton_data_res"):
		layer_1.set_skeleton_data_res(null)
	queue_free()


func _exit_tree() -> void:
	if layer_1 != null and layer_1.has_method("set_skeleton_data_res"):
		layer_1.set_skeleton_data_res(null)
	if _reserved_visual:
		_reserved_visual = false
		_active_visuals = maxi(0, _active_visuals - 1)


func _damage_node(damage_node: Dictionary) -> void:
	var node_position: Vector2 = damage_node["position"]
	var node_size: Vector2 = damage_node["size"]

	var center_offset := Vector2(node_position.x, -node_position.y) * VISUAL_SCALE
	if not face_right:
		center_offset.x = -center_offset.x
	var hit_center := global_position + center_offset
	var hit_half_size := node_size * VISUAL_SCALE * 0.5 * DAMAGE_RANGE_SCALE
	for monster in _get_enemy_targets():
		if not is_instance_valid(monster) or monster.hp <= 0:
			continue
		var delta := monster.global_position - hit_center
		if absf(delta.x) <= hit_half_size.x and absf(delta.y) <= hit_half_size.y:
			monster.receive_friendly_damage(damage_per_node, "magic", source if is_instance_valid(source) else null)
			Global.add_sound(self, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
			_apply_skill_debuffs_once(monster)


func _apply_skill_debuffs_once(target: BaseMonster) -> void:
	if not is_instance_valid(target) or target.hp <= 0:
		return
	var target_id := target.get_instance_id()
	if _debuffed_target_ids.has(target_id):
		return
	_debuffed_target_ids[target_id] = true
	if is_instance_valid(source):
		source.apply_defense_reduce_to_target(target, ARMOR_BREAK_DURATION, ARMOR_BREAK_RATIO)
		if randf() < STUN_CHANCE:
			source.apply_stun_to_target(target, STUN_DURATION)


func _get_enemy_targets() -> Array[BaseMonster]:
	var result: Array[BaseMonster] = []
	if is_instance_valid(source) and source.has_method("search_for_targets"):
		source.search_for_targets()
		var source_targets = source.get("all_monsters")
		if source_targets is Array:
			for candidate in source_targets:
				_append_enemy(result, candidate)
		_append_enemy(result, source.get("current_target"))
	if result.is_empty():
		var tree := get_tree()
		if tree != null:
			for candidate in tree.get_nodes_in_group("monsters"):
				_append_enemy(result, candidate)
			if result.is_empty() and tree.current_scene != null:
				_collect_enemies_recursive(tree.current_scene, result)
	return result


func _collect_enemies_recursive(node: Node, result: Array[BaseMonster]) -> void:
	_append_enemy(result, node)
	for child in node.get_children():
		_collect_enemies_recursive(child, result)


func _append_enemy(result: Array[BaseMonster], candidate: Variant) -> void:
	if candidate is BaseMonster and candidate != source and candidate.hp > 0:
		if candidate.get("is_summon") != true and not result.has(candidate):
			result.append(candidate)

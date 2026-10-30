extends Node2D
class_name GuanyinSkillAEffect

const ATLAS_PATH := "res://Art/monster/guanyin_spine/skill_a/600020_attack_hit1.atlas"
const SKELETON_PATH := "res://Art/monster/guanyin_spine/skill_a/600020_attack_hit1.spine-json"
const EFFECT_DURATION := 1.2
const HIT_TIME := 0.4
const HIT_POSITION := Vector2(-23.45, 211.77)
const HIT_SIZE := Vector2(733.0, 628.0)

static var _shared_data: Variant = null
static var _load_failed := false

@onready var spine_sprite: Variant = $SpineSprite
var source: Node = null
var damage: int = 1
var face_right := true


static func preload_effect_data() -> bool:
	if _shared_data != null:
		return true
	if _load_failed:
		return false
	if not ClassDB.class_exists("SpineSkeletonDataResource"):
		_load_failed = true
		push_error("GuanyinSkillAEffect: Spine GDExtension is not loaded")
		return false
	var atlas := load(ATLAS_PATH)
	if atlas == null:
		_load_failed = true
		push_error("GuanyinSkillAEffect: 无法加载 Spine atlas: " + ATLAS_PATH)
		return false
	var skeleton_file := load(SKELETON_PATH)
	if skeleton_file == null:
		_load_failed = true
		push_error("GuanyinSkillAEffect: 无法加载 Spine skeleton: " + SKELETON_PATH)
		return false
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	skeleton_data.set_atlas_res(atlas)
	skeleton_data.set_skeleton_file_res(skeleton_file)
	skeleton_data.update_skeleton_data()
	if not skeleton_data.is_skeleton_data_loaded():
		_load_failed = true
		push_error("GuanyinSkillAEffect: Spine 骨骼数据解析失败")
		return false
	_shared_data = skeleton_data
	return true


static func clear_cached_data() -> void:
	_shared_data = null
	_load_failed = false


func setup(owner_node: Node, attack_power: int, is_facing_right: bool) -> void:
	source = owner_node
	damage = maxi(1, attack_power * 7)
	face_right = is_facing_right
	scale.x = 1.0 if face_right else -1.0


func _ready() -> void:
	if not preload_effect_data() or spine_sprite == null or not spine_sprite.has_method("set_skeleton_data_res"):
		queue_free()
		return
	spine_sprite.set_skeleton_data_res(_shared_data)
	_setup_spine_blend_materials()
	_play_spine_animation(spine_sprite)
	_run_timeline()


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
	spine_sprite.set_normal_material(normal_material)
	spine_sprite.set_additive_material(additive_material)
	spine_sprite.set_screen_material(additive_material)
	spine_sprite.set_multiply_material(multiply_material)


func _run_timeline() -> void:
	await get_tree().create_timer(HIT_TIME).timeout
	if not is_inside_tree():
		return
	_apply_area_damage()
	await get_tree().create_timer(EFFECT_DURATION - HIT_TIME).timeout
	if spine_sprite != null and spine_sprite.has_method("set_skeleton_data_res"):
		spine_sprite.set_skeleton_data_res(null)
	queue_free()


func _apply_area_damage() -> void:
	var center_offset := Vector2(HIT_POSITION.x, -HIT_POSITION.y)
	if not face_right:
		center_offset.x = -center_offset.x
	var hit_center := global_position + center_offset

	var hit_half_size := HIT_SIZE * 0.5
	for monster in _get_enemy_targets():
		if not is_instance_valid(monster) or monster.hp <= 0:
			continue
		var delta := monster.global_position - hit_center
		if absf(delta.x) <= hit_half_size.x and absf(delta.y) <= hit_half_size.y:
			monster.receive_friendly_damage(damage, "magic", source if is_instance_valid(source) else null)
			Global.get_audio_runtime().add_sound(self, "res://Music/monster_hurt/6_beattack_by_role1.mp3")


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

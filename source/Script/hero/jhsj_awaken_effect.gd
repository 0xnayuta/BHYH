extends Node2D
class_name JHSJAwakenEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const FALLBACK_EFFECT_SCENE_PATH := "res://Scene/hero/role_special_effect_slim/jhsj.tscn"
const ATLAS_PATH := "res://Art/hero_picture/role_2/jhsj_awaken/runtime/HeroF_6030_skill.atlas"
const SKELETON_PATH := "res://Art/hero_picture/role_2/jhsj_awaken/runtime/HeroF_6030_skill08_1.spine-json"
const SPINE_SCALE := Vector2(0.2, 0.2)
const SPINE_DURATION := 2.5
const HIT_TIMES := [0.25, 1.1]
const MULTI_HIT_INTERVAL := 0.12
const HIT_HALF_SIZE := Vector2(620.0, 520.0)

var owner_player: Node = null
var hit_data: Dictionary = {}
var face_right := true
var _spine: Variant = null
var _fallback_effect: Node = null
var _cached_targets: Array[BaseMonster] = []
static var _shared_data: Variant = null
static var _normal_material: CanvasItemMaterial
static var _additive_material: CanvasItemMaterial
static var _multiply_material: CanvasItemMaterial
static var _load_failed := false


func setup(player: Node, data: Dictionary, is_facing_right: bool) -> void:
	owner_player = player
	hit_data = data.duplicate(true)
	face_right = is_facing_right


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	_cache_targets()
	if not preload_effect_data():
		_spawn_fallback_visual()
		_run_hits()
		return
	_spine = ClassDB.instantiate("SpineSprite")
	if _spine == null or not _spine.has_method("set_skeleton_data_res"):
		_spawn_fallback_visual()
		_run_hits()
		return
	_spine.scale = SPINE_SCALE
	scale.x = 1.0 if face_right else -1.0
	_spine.z_index = 24
	add_child(_spine as Node)
	_spine.set_skeleton_data_res(_shared_data)
	_spine.set_normal_material(_normal_material)
	_spine.set_additive_material(_additive_material)
	_spine.set_screen_material(_additive_material)
	_spine.set_multiply_material(_multiply_material)
	var state: Variant = _spine.get_animation_state()
	if state == null:
		await get_tree().process_frame
		if _spine != null and is_instance_valid(_spine):
			state = _spine.get_animation_state()
	if state != null:
		state.set_animation("skill08_1", false, 0)
	_run_hits()


func _spawn_fallback_visual() -> void:
	var fallback_effect_scene := load(FALLBACK_EFFECT_SCENE_PATH) as PackedScene
	if fallback_effect_scene == null:
		return
	_fallback_effect = fallback_effect_scene.instantiate()
	if _fallback_effect == null:
		return
	_fallback_effect.position = Vector2(0, -15)
	_fallback_effect.scale = Vector2(1.35, 1.35)
	_fallback_effect.z_index = 24
	add_child(_fallback_effect)


func _process(_delta: float) -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position


func _run_hits() -> void:
	var previous_time := 0.0
	for hit_time in HIT_TIMES:
		await get_tree().create_timer(hit_time - previous_time, false).timeout
		if owner_player == null or not is_instance_valid(owner_player):
			return
		_apply_area_damage()
		previous_time = hit_time
	await get_tree().create_timer(maxf(0.0, SPINE_DURATION - HIT_TIMES[-1]), false).timeout
	queue_free()


static func preload_effect_data() -> bool:
	if _shared_data != null:
		return true
	if not ClassDB.class_exists("SpineSkeletonDataResource") or not ClassDB.class_exists("SpineSprite"):
		return false
	var atlas := load(ATLAS_PATH)
	var skeleton_file := load(SKELETON_PATH)
	if atlas == null or skeleton_file == null:
		return false
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	skeleton_data.set_atlas_res(atlas)
	skeleton_data.set_skeleton_file_res(skeleton_file)
	skeleton_data.update_skeleton_data()
	if not skeleton_data.is_skeleton_data_loaded():
		return false
	_shared_data = skeleton_data
	_normal_material = CanvasItemMaterial.new()
	_normal_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	_additive_material = CanvasItemMaterial.new()
	_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_multiply_material = CanvasItemMaterial.new()
	_multiply_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	return true


static func clear_cached_data() -> void:
	_shared_data = null
	_normal_material = null
	_additive_material = null
	_multiply_material = null
	_load_failed = false


func _apply_area_damage() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		return
	var direction := 1.0 if face_right else -1.0
	var center: Vector2 = owner_player.global_position + Vector2(120.0 * direction, -120.0)
	for hit_index in range(3):
		_damage_area_after_delay(center, float(hit_index) * MULTI_HIT_INTERVAL)


func _damage_area_after_delay(center: Vector2, delay: float) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay, false).timeout
	if owner_player == null or not is_instance_valid(owner_player):
		return
	var hit_half_size := HIT_HALF_SIZE
	for target in _cached_targets:
		if target == null or not is_instance_valid(target):
			continue
		if target.hp <= 0 or target.no_target or target.is_boss_protecting():
			continue
		var offset: Vector2 = target.global_position + Vector2(0.0, -70.0) - center
		if absf(offset.x) <= hit_half_size.x and absf(offset.y) <= hit_half_size.y:
			_apply_target_damage(target)


func _cache_targets() -> void:
	var scene := get_tree().current_scene
	if scene != null:
		_collect_targets(scene)


func _collect_targets(node: Node) -> void:
	if node is BaseMonster:
		_cached_targets.append(node as BaseMonster)
	for child in node.get_children():
		_collect_targets(child)


func _apply_target_damage(node: BaseMonster) -> void:
	var damage_source_state := node.bind_role_damage_source(owner_player as BaseHero)
	var old_hit_data: Dictionary = owner_player.hit_dic
	var old_miss: int = node.miss
	owner_player.hit_dic = hit_data

	node.miss = 0
	var damage := int(
		(
			float(node.get_role_last_hurt(owner_player))
			* role_props.ws_up_power
			* node.jgz_bl
			* node.zznh_bl
			* node.hurt_bl
			* (1.0 + node.lpzzs)
			* (1.0 + owner_player.tszzs)
			* node.llrdzs
		)
	)
	if damage > 0:
		node.hurt_received = damage
		node.hurt_reduce_hp(damage, owner_player)
		node.add_lj(damage)
		Global.get_run_context().add_damage_dealt(damage)
		Global.get_run_context().add_damage_dealt_by_type("magic", damage)
		Global.get_audio_runtime().add_sound(node, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not node.is_miss and not node.is_boss_protecting():
			node.hurt_special_effect = Global.add_mr_hurt(node.pz, Vector2.ZERO)
		if not node.is_control_immune():
			_apply_hit_stun(node)
		node.role5_bullet(damage, owner_player)
	node.miss = old_miss
	owner_player.hit_dic = old_hit_data
	node.unbind_role_damage_source(damage_source_state)


func _apply_hit_stun(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.is_control_immune():
		return
	target.set_meta("jhsj_awaken_hit_stun_token", Time.get_ticks_msec())
	target.is_be_attacking = true
	target.interrupt_movement_for_control()
	if target.mr_player != null and target.mr_player.has_animation("hurt"):
		target.mr_player.play("hurt")
	call_deferred("_release_hit_stun", target, int(target.get_meta("jhsj_awaken_hit_stun_token")))


func _release_hit_stun(target: BaseMonster, token: int) -> void:
	await get_tree().create_timer(0.2, false).timeout
	if target == null or not is_instance_valid(target):
		return
	if int(target.get_meta("jhsj_awaken_hit_stun_token", 0)) != token:
		return
	target.is_be_attacking = false

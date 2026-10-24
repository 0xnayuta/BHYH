extends Node2D
class_name BingYuEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const DROP_COUNT := 9
const WAVE_COUNT := 3
const DROP_INTERVAL := 0.03
const WAVE_INTERVAL := 0.08
const SCREEN_HALF_WIDTH := 700.0

const LANDING_EFFECT_Y := 50

const ATLAS_PATH := "res://Art/hero_picture/role_2/bing_yu/runtime/510040_attack_hit1.atlas"
const SKELETON_PATH := "res://Art/hero_picture/role_2/bing_yu/runtime/510040_attack_hit1.spine-json"
const SPINE_FPS := 30.0
const SPINE_DURATION := 1.8
const SPINE_SCALE := Vector2(0.5, 0.5)
const NODE_SOURCE_SIZE := Vector2(480.0, 442.0)
const NODE_RANGE_SCALE := 2.0
const RAIN_DAMAGE_DELAY := 1.0 / SPINE_FPS
const LANDING_DAMAGE_DELAY := 0.1
const NODE_DAMAGE_HALF_SIZE := NODE_SOURCE_SIZE * SPINE_SCALE * NODE_RANGE_SCALE * 0.5

const RAIN_NODE_HALF_SIZE := Vector2(66.0, 387.0) * SPINE_SCALE * NODE_RANGE_SCALE * 0.5
const RAIN_NODE_OFFSET := Vector2(-91.48, -645.94) * SPINE_SCALE

const FREEZE_CHANCE := 0.25
const FREEZE_DURATION := 1.5

var owner_player: Node
var hit_data: Dictionary = {}
var _anchor_position := Vector2.ZERO
var _active_effects: Array = []
var _targets: Array[BaseMonster] = []
static var _shared_data: Variant = null
static var _normal_material: CanvasItemMaterial = null
static var _additive_material: CanvasItemMaterial = null
static var _multiply_material: CanvasItemMaterial = null
static var _load_failed := false


func setup(player: Node, data: Dictionary) -> void:
	owner_player = player
	hit_data = data.duplicate(true)


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	_anchor_position = owner_player.global_position
	global_position = _anchor_position
	if not preload_effect_data():
		queue_free()
		return
	_cache_targets()
	_run_rain()


func _run_rain() -> void:
	for wave_index in range(WAVE_COUNT):
		for index in range(DROP_COUNT):
			_spawn_complete_spine_effect()
			if index < DROP_COUNT - 1:
				await get_tree().create_timer(DROP_INTERVAL, false).timeout
		if wave_index < WAVE_COUNT - 1:
			await get_tree().create_timer(WAVE_INTERVAL, false).timeout
	await get_tree().create_timer(SPINE_DURATION + 0.15, false).timeout
	queue_free()


func _spawn_complete_spine_effect() -> void:
	var landing_x := randf_range(-SCREEN_HALF_WIDTH, SCREEN_HALF_WIDTH)
	var effect: Variant = ClassDB.instantiate("SpineSprite")
	if effect == null:
		return
	var node_position := Vector2(landing_x, LANDING_EFFECT_Y)
	effect.position = node_position
	effect.scale = SPINE_SCALE
	effect.z_index = 18
	add_child(effect as Node)
	effect.set_skeleton_data_res(_shared_data)
	effect.set_normal_material(_normal_material)
	effect.set_additive_material(_additive_material)
	effect.set_screen_material(_additive_material)
	effect.set_multiply_material(_multiply_material)
	_active_effects.append(effect)
	_play_spine_effect(effect)
	_free_effect_after_duration(effect)
	var landing_global_position := global_position + node_position
	_damage_node_after_delay(landing_global_position + RAIN_NODE_OFFSET, RAIN_NODE_HALF_SIZE, RAIN_DAMAGE_DELAY)
	_damage_node_after_delay(landing_global_position, NODE_DAMAGE_HALF_SIZE, LANDING_DAMAGE_DELAY)


func _play_spine_effect(effect: Variant) -> void:
	if effect == null or not is_instance_valid(effect) or not effect.has_method("get_animation_state"):
		return
	var animation_state: Variant = effect.get_animation_state()
	if animation_state == null:
		await get_tree().process_frame
		if effect == null or not is_instance_valid(effect) or not effect.has_method("get_animation_state"):
			return
		animation_state = effect.get_animation_state()
	if animation_state != null:
		animation_state.set_animation("play", false, 0)


func _free_effect_after_duration(effect: Variant) -> void:
	await get_tree().create_timer(SPINE_DURATION, false).timeout
	_active_effects.erase(effect)
	if effect != null and is_instance_valid(effect):
		effect.queue_free()


static func prewarm_frames() -> void:
	preload_effect_data()


static func clear_cached_data() -> void:
	_shared_data = null


static func preload_effect_data() -> bool:
	if _shared_data != null:
		return true
	if _load_failed:
		return false
	if not ClassDB.class_exists("SpineSkeletonDataResource") or not ClassDB.class_exists("SpineSprite"):
		_load_failed = true
		push_error("BingYuEffect: Spine GDExtension is not loaded")
		return false
	var atlas := load(ATLAS_PATH)
	if atlas == null:
		_load_failed = true
		push_error("BingYuEffect: 无法加载 Spine atlas: " + ATLAS_PATH)
		return false
	var skeleton_file := load(SKELETON_PATH)
	if skeleton_file == null:
		_load_failed = true
		push_error("BingYuEffect: 无法加载 Spine skeleton: " + SKELETON_PATH)
		return false
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	skeleton_data.set_atlas_res(atlas)
	skeleton_data.set_skeleton_file_res(skeleton_file)
	skeleton_data.update_skeleton_data()
	if not skeleton_data.is_skeleton_data_loaded():
		_load_failed = true
		push_error("BingYuEffect: Spine 骨骼数据解析失败")
		return false
	_shared_data = skeleton_data
	_normal_material = CanvasItemMaterial.new()
	_normal_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	_additive_material = CanvasItemMaterial.new()
	_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_multiply_material = CanvasItemMaterial.new()
	_multiply_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	return true


func _damage_node_after_delay(node_global_position: Vector2, half_size: Vector2, delay: float) -> void:
	await get_tree().create_timer(delay, false).timeout
	if owner_player == null or not is_instance_valid(owner_player):
		return
	_damage_targets_at_node(node_global_position, half_size)


func _damage_targets_at_node(node_global_position: Vector2, half_size: Vector2) -> void:
	_cache_targets()
	for target in _targets:
		if _is_valid_target(target):
			var target_center := target.global_position + Vector2(0.0, -70.0)
			var offset := target_center - node_global_position
			if absf(offset.x) <= half_size.x and absf(offset.y) <= half_size.y:
				_apply_hit(target)


func _cache_targets() -> void:
	_targets.clear()
	var level := _find_level_node()
	if level != null and ("monster" in level) and level.monster != null:
		_collect_targets(level.monster)


func _collect_targets(node: Node) -> void:
	if node == null:
		return
	if _is_valid_target(node):
		_targets.append(node as BaseMonster)
	for child in node.get_children():
		_collect_targets(child)


func _find_level_node() -> Node:
	var node := owner_player.get_parent()
	while node != null:
		if node is BaseLevel:
			return node
		node = node.get_parent()
	return get_tree().current_scene


func _is_valid_target(target: Variant) -> bool:
	if target == null or not is_instance_valid(target) or not (target is BaseMonster):
		return false
	if target.hp <= 0 or target.no_target:
		return false
	if target.is_boss_protecting():
		return false
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return false
	return true


func _apply_hit(target: BaseMonster) -> void:
	var damage_source_state := target.bind_role_damage_source(owner_player as BaseHero)
	var old_hit_data: Dictionary = owner_player.hit_dic
	owner_player.hit_dic = hit_data
	if role_props.source_player.istsz:
		var tsz_level := int(player_data.player_data["腾蛇阵"]["Level"])
		role_props.source_player.tszzs = tsz_level * 0.015
	else:
		role_props.source_player.tszzs = 0.0
	var base_damage := float(target.get_role_last_hurt(owner_player))
	var damage := int(
		(
			base_damage
			* role_props.ws_up_power
			* target.jgz_bl
			* target.zznh_bl
			* target.hurt_bl
			* (1.0 + target.lpzzs)
			* (1.0 + owner_player.tszzs)
			* target.llrdzs
		)
	)
	if damage > 0:
		target.hurt_received = damage
		target.hurt_reduce_hp(damage, owner_player)
		if MainSet.set_data["MonsterLittleBlood"]:
			if target.monster_blood_bar == null:
				target.monster_blood_bar = Global.add_monster_blood(
					target, Vector2(-30, -90), target.hp / float(target.max_hp), target.hp
				)
		target.add_lj(damage)
		Global.total_role_hit += damage
		Global.total_mag_hit += damage
		Global.add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not target.is_miss and not target.is_boss_protecting():
			target.hurt_special_effect = Global.add_mr_hurt(target.pz, Vector2(0, 0))
		if not target.is_control_immune():
			_apply_hit_stun(target)
		target.role5_bullet(damage, owner_player)
		if not target.is_control_immune() and randf() < FREEZE_CHANCE:
			Global.add_buff(
				target.buff,
				{
					"Name": "Ice",
					"AddTime": FREEZE_DURATION,
					"reduce_interval": 0,
					"value": 0,
					"AttackKind": "",
					"DeBuff": true
				}
			)
		if not role_props.is_ws_state:
			role_props.ws_value += int(hit_data.get("WSValue", 8))
	owner_player.hit_dic = old_hit_data
	target.unbind_role_damage_source(damage_source_state)


func _apply_hit_stun(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.is_control_immune():
		return
	target.set_meta("bingyu_hit_stun_token", Time.get_ticks_msec())
	target.is_be_attacking = true
	target.interrupt_movement_for_control()
	if target.mr_player != null and target.mr_player.has_animation("hurt"):
		target.mr_player.play("hurt")
	call_deferred("_release_hit_stun", target, int(target.get_meta("bingyu_hit_stun_token")))


func _release_hit_stun(target: BaseMonster, token: int) -> void:
	await get_tree().create_timer(0.2, false).timeout
	if target == null or not is_instance_valid(target):
		return
	if int(target.get_meta("bingyu_hit_stun_token", 0)) != token:
		return
	target.is_be_attacking = false

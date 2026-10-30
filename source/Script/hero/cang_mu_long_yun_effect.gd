extends Node2D
class_name CangMuLongYunEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const ATLAS_PATH := "res://Art/hero_picture/role_4/cang_mu_long_yun/runtime/HeroF_6009_skill.atlas"
const SKELETON_PATH := "res://Art/hero_picture/role_4/cang_mu_long_yun/runtime/HeroF_6009_skill01_2.spine-json"
const FALLBACK_FRAME_META := "res://Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_frames.json"
const FALLBACK_FRAME_DIR := "res://Art/hero_picture/role_4/cang_mu_long_yun/frames/"
const SPINE_SCALE := Vector2(0.2, 0.2)
const SPINE_DURATION := 1.8
const HIT_INTERVAL := 0.12
const MAX_HITS_PER_FRAME := 6

const COLLISION_INTERVAL := HIT_INTERVAL

const HEAD_SLOT_NAMES := [
	"FX-st01",
	"FX-st1",
	"FX-st2",
	"FX-st3",
	"FX-st4",
	"FX-st5",
	"FX-st6",
	"FX-st7",
	"FX-st8",
	"FX-st9",
	"FX-st10",
	"FX-st11",
	"FX-shitou-st1_14",
	"FX-shitou-st1_15",
	"FX-shitou-st1_16",
	"FX-shitou-st1_17",
	"FX-shitou-st1_18",
	"FX-shitou-st1_19",
	"FX-shitou-st1_20",
	"FX-shitou-st1_21",
	"FX-shitou-st1_22",
	"FX-shitou-st1_23",
	"FX-shitou-st1_24",
	"FX-shitou-st1_25",
	"FX-shitou-st1_26",
	"FX-shitou-st1_27",
	"FX-shitou-st1_28",
	"FX-shitou-st1_29",
	"FX-shitou-st1_30",
	"FX-shitou-st1_31",
	"FX-shitou-st1_32",
	"FX-shitou-st1_33",
	"FX-shitou-st1_34",
	"FX-shitou-st1_35",
	"FX-shitou-st1_36",
	"FX-shitou-st1_37"
]
const HEAD_FORWARD_PADDING := 120.0
const HEAD_BACKWARD_PADDING := 80.0
const HEAD_VERTICAL_HALF := 280.0

const HEAD_HIT_HALF_SIZE := Vector2(140.0, 280.0)
const NODE_BONE_GROUPS := [
	[
		"mulong5",
		"mulong5b",
		"mulong5c",
		"mulong5d",
		"mulong5e",
		"mulong5f",
		"mulong5g",
		"mulong5h",
		"mulong5i",
		"mulong5j",
		"mulong5k",
		"mulong5l",
		"mulong5m",
		"mulong5n",
		"mulong5o",
		"mulong5p",
		"mulong5q",
		"mulong5r",
		"mulong5s",
		"mulong5t",
		"tou_zong",
		"tou1",
		"mulong3",
		"mulong4",
		"tou2",
		"mulong6",
		"mulong7",
		"tou3",
		"mulong8",
		"mulong9",
		"tou4",
		"mulong10",
		"mulong11"
	],
	[
		"mulong14",
		"mulong5b2",
		"mulong5c2",
		"mulong5d2",
		"mulong5e2",
		"mulong5f2",
		"mulong5g2",
		"mulong5h2",
		"mulong5i2",
		"mulong5j2",
		"mulong5k2",
		"mulong5l2",
		"mulong5m2",
		"mulong5n2",
		"mulong5o2",
		"mulong5p2",
		"mulong5q2",
		"mulong5r2",
		"mulong5s2",
		"mulong5t2",
		"tou_zong2",
		"tou5",
		"mulong15",
		"mulong16",
		"tou6",
		"mulong17",
		"mulong18",
		"tou7",
		"mulong19",
		"mulong20",
		"tou8",
		"mulong21",
		"mulong22"
	],
	[
		"mulong25",
		"mulong5b3",
		"mulong5c3",
		"mulong5d3",
		"mulong5e3",
		"mulong5f3",
		"mulong5g3",
		"mulong5h3",
		"mulong5i3",
		"mulong5j3",
		"mulong5k3",
		"mulong5l3",
		"mulong5m3",
		"mulong5n3",
		"mulong5o3",
		"mulong5p3",
		"mulong5q3",
		"mulong5r3",
		"mulong5s3",
		"mulong5t3",
		"tou_zong3",
		"tou9",
		"mulong26",
		"mulong27",
		"tou10",
		"mulong28",
		"mulong29",
		"tou11",
		"mulong30",
		"mulong31",
		"tou12",
		"mulong32",
		"mulong33"
	],
	[
		"mulong36",
		"mulong5b4",
		"mulong5c4",
		"mulong5d4",
		"mulong5e4",
		"mulong5f4",
		"mulong5g4",
		"mulong5h4",
		"mulong5i4",
		"mulong5j4",
		"mulong5k4",
		"mulong5l4",
		"mulong5m4",
		"mulong5n4",
		"mulong5o4",
		"mulong5p4",
		"mulong5q4",
		"mulong5r4",
		"mulong5s4",
		"mulong5t4",
		"tou_zong4",
		"tou13",
		"mulong37",
		"mulong38",
		"tou14",
		"mulong39",
		"mulong40",
		"tou15",
		"mulong41",
		"mulong42",
		"tou16",
		"mulong43",
		"mulong44"
	],
	[
		"mulong47",
		"mulong5b5",
		"mulong5c5",
		"mulong5d5",
		"mulong5e5",
		"mulong5f5",
		"mulong5g5",
		"mulong5h5",
		"mulong5i5",
		"mulong5j5",
		"mulong5k5",
		"mulong5l5",
		"mulong5m5",
		"mulong5n5",
		"mulong5o5",
		"mulong5p5",
		"mulong5q5",
		"mulong5r5",
		"mulong5s5",
		"mulong5t5",
		"tou_zong5",
		"tou17",
		"mulong48",
		"mulong49",
		"tou18",
		"mulong50",
		"mulong51",
		"tou19",
		"mulong52",
		"mulong53",
		"tou20",
		"mulong54",
		"mulong55"
	],
	[
		"mulong58",
		"mulong5b6",
		"mulong5c6",
		"mulong5d6",
		"mulong5e6",
		"mulong5f6",
		"mulong5g6",
		"mulong5h6",
		"mulong5i6",
		"mulong5j6",
		"mulong5k6",
		"mulong5l6",
		"mulong5m6",
		"mulong5n6",
		"mulong5o6",
		"mulong5p6",
		"mulong5q6",
		"mulong5r6",
		"mulong5s6",
		"mulong5t6",
		"tou_zong6",
		"tou21",
		"mulong59",
		"mulong60",
		"tou22",
		"mulong61",
		"mulong62",
		"tou23",
		"mulong63",
		"mulong64",
		"tou24",
		"mulong65",
		"mulong66"
	]
]

var owner_player: Node = null
var hit_data: Dictionary = {}
var face_right := true
var _spine: Variant = null
var _fallback_sprite: Sprite2D = null
var _cached_targets: Array[BaseMonster] = []
var _cached_target_ids: Dictionary = {}
var _target_snapshot_version := -2
var _fallback_target_container: Node = null
var _fallback_targets_dirty := true
var _target_next_hit_msec: Dictionary = {}
var _pending_hits: Array[BaseMonster] = []
var _pending_hit_ids: Dictionary = {}
var _head_slots: Array = []
var _active_head_positions: Array[Vector2] = []
var _active_head_bounds := Rect2()
var _has_active_head_bounds := false
var _collision_elapsed := 0.0
var _collision_accumulator := 0.0
var _collision_running := false
var _head_sweep_direction := 1.0
var _head_has_appeared := false
var _max_head_forward_reach := -INF
static var _shared_data: Variant = null
static var _normal_material: CanvasItemMaterial
static var _additive_material: CanvasItemMaterial
static var _multiply_material: CanvasItemMaterial


func setup(player: Node, is_facing_right: bool, data: Dictionary) -> void:
	owner_player = player
	face_right = is_facing_right
	hit_data = data.duplicate(true)
	_head_sweep_direction = 1.0 if face_right else -1.0
	_head_has_appeared = false
	_max_head_forward_reach = -INF
	_cached_targets.clear()
	_cached_target_ids.clear()
	_target_snapshot_version = -2
	_fallback_target_container = null
	_fallback_targets_dirty = true
	_target_next_hit_msec.clear()
	_pending_hits.clear()
	_pending_hit_ids.clear()
	_head_slots.clear()
	_active_head_positions.clear()
	_active_head_bounds = Rect2()
	_has_active_head_bounds = false
	_collision_elapsed = 0.0
	_collision_accumulator = 0.0
	_collision_running = false


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	_cache_targets()
	if not _preload_effect_data():
		_spawn_fallback_visual()
		_collision_running = true
		_finish_after(SPINE_DURATION + 0.5)
		return
	_spine = ClassDB.instantiate("SpineSprite")
	if _spine == null or not _spine.has_method("set_skeleton_data_res"):
		_spawn_fallback_visual()
		_collision_running = true
		_finish_after(SPINE_DURATION + 0.5)
		return
	_spine.scale = SPINE_SCALE
	scale.x = 1.0 if face_right else -1.0
	z_index = 99
	_spine.z_index = 24
	add_child(_spine as Node)
	_spine.set_skeleton_data_res(_shared_data)
	_spine.set_normal_material(_normal_material)
	_spine.set_additive_material(_additive_material)
	_spine.set_screen_material(_additive_material)
	_spine.set_multiply_material(_multiply_material)
	var skeleton: Variant = _spine.get_skeleton()
	if skeleton != null:
		if skeleton.has_method("set_skin_by_name"):
			skeleton.set_skin_by_name("default")
		if skeleton.has_method("set_slots_to_setup_pose"):
			skeleton.set_slots_to_setup_pose()
		_cache_head_slots(skeleton)
	var state: Variant = _spine.get_animation_state()
	if state == null:
		await get_tree().process_frame
		if _spine != null and is_instance_valid(_spine):
			state = _spine.get_animation_state()
	if state == null:
		_spawn_fallback_visual()
		_collision_running = true
		_finish_after(SPINE_DURATION + 0.5)
		return
	if state.has_method("set_animation"):
		state.set_animation("skill01_2", false, 0)
	_collision_running = true
	_finish_after(SPINE_DURATION + 0.5)


func _process(delta: float) -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	_flush_pending_hits()
	if not _collision_running:
		return
	_collision_elapsed += delta
	_collision_accumulator += delta
	if _collision_elapsed >= SPINE_DURATION:
		_collision_running = false
		return
	if _collision_accumulator >= COLLISION_INTERVAL:
		_collision_accumulator = fmod(_collision_accumulator, COLLISION_INTERVAL)
		_apply_node_damage()


func _flush_pending_hits() -> void:
	var processed := 0
	while processed < MAX_HITS_PER_FRAME and not _pending_hits.is_empty():
		var target: BaseMonster = _pending_hits.pop_back()
		if target != null and is_instance_valid(target):
			_pending_hit_ids.erase(target.get_instance_id())
			if _is_valid_target(target):
				_apply_hit(target)
		processed += 1


func _apply_node_damage() -> void:
	if hit_data.is_empty() or owner_player == null or not is_instance_valid(owner_player):
		return
	_cache_targets()
	if _cached_targets.is_empty():
		return
	var skeleton: Variant = _spine.get_skeleton() if _spine != null and is_instance_valid(_spine) else null
	if skeleton == null:
		_apply_fallback_visual_damage()
		return

	if skeleton.has_method("update_world_transform"):
		skeleton.update_world_transform(0)
	var head_positions := _get_active_head_positions(skeleton)
	if head_positions.is_empty():
		return

	var now_msec := Time.get_ticks_msec()
	var next_hit_delay_msec := int(HIT_INTERVAL * 1000.0)
	var bounds_min := _active_head_bounds.position - HEAD_HIT_HALF_SIZE
	var bounds_max := _active_head_bounds.end + HEAD_HIT_HALF_SIZE
	for target in _cached_targets:
		if not _is_valid_target(target):
			continue
		var target_id := target.get_instance_id()
		if now_msec < int(_target_next_hit_msec.get(target_id, 0)):
			continue
		var target_center := target.global_position + Vector2(0.0, -70.0)
		if (
			target_center.x < bounds_min.x
			or target_center.x > bounds_max.x
			or target_center.y < bounds_min.y
			or target_center.y > bounds_max.y
		):
			continue
		var hit_node := false

		for head_position in head_positions:
			var offset := target_center - head_position
			if absf(offset.x) <= HEAD_HIT_HALF_SIZE.x and absf(offset.y) <= HEAD_HIT_HALF_SIZE.y:
				hit_node = true
				break
		if hit_node:
			if not _pending_hit_ids.has(target_id):
				_pending_hits.push_back(target)
				_pending_hit_ids[target_id] = true
				_target_next_hit_msec[target_id] = now_msec + next_hit_delay_msec


func _get_active_head_positions(skeleton: Variant) -> Array[Vector2]:
	_active_head_positions.clear()
	_active_head_bounds = Rect2()
	_has_active_head_bounds = false
	if skeleton == null:
		return _active_head_positions
	if _head_slots.is_empty():
		_cache_head_slots(skeleton)
	for slot in _head_slots:
		if slot == null:
			continue
		var pose: Variant = slot.get_pose() if slot.has_method("get_pose") else null
		var attachment: Variant = pose.get_attachment() if pose != null and pose.has_method("get_attachment") else null
		if attachment == null:
			continue
		if slot.has_method("get_color"):
			var slot_color: Variant = slot.get_color()
			if slot_color is Color and (slot_color as Color).a <= 0.01:
				continue
		var bone: Variant = slot.get_bone() if slot.has_method("get_bone") else null
		if bone == null or not bone.has_method("get_global_transform"):
			continue
		var head_position: Vector2 = bone.get_global_transform().origin
		_active_head_positions.append(head_position)
		if _has_active_head_bounds:
			_active_head_bounds = _active_head_bounds.expand(head_position)
		else:
			_active_head_bounds = Rect2(head_position, Vector2.ZERO)
			_has_active_head_bounds = true
	return _active_head_positions


func _cache_head_slots(skeleton: Variant) -> void:
	_head_slots.clear()
	if skeleton == null or not skeleton.has_method("find_slot"):
		return
	for slot_name in HEAD_SLOT_NAMES:
		var slot: Variant = skeleton.find_slot(slot_name)
		if slot != null:
			_head_slots.append(slot)


func _get_head_forward_reach(skeleton: Variant) -> float:
	if skeleton == null or not skeleton.has_method("find_slot"):
		return 0.0

	_head_sweep_direction = 1.0 if face_right else -1.0
	var furthest := -INF
	for head_position in _get_active_head_positions(skeleton):
		var offset_x := (head_position.x - global_position.x) * _head_sweep_direction
		furthest = maxf(furthest, offset_x)

	if is_inf(furthest):
		return 0.0

	_head_has_appeared = true
	_max_head_forward_reach = maxf(_max_head_forward_reach, furthest)
	return _max_head_forward_reach + HEAD_FORWARD_PADDING


func _apply_fallback_visual_damage() -> void:
	if _fallback_sprite == null or not is_instance_valid(_fallback_sprite) or _fallback_sprite.texture == null:
		return
	var texture_size := Vector2(_fallback_sprite.texture.get_size())
	var half_size := texture_size * _fallback_sprite.global_scale.abs() * 0.5
	var visual_center := _fallback_sprite.global_position
	for target in _cached_targets:
		if not _is_valid_target(target):
			continue
		var target_id := target.get_instance_id()
		var now_msec := Time.get_ticks_msec()
		if now_msec < int(_target_next_hit_msec.get(target_id, 0)):
			continue
		var target_center := target.global_position + Vector2(0.0, -70.0)
		var offset := target_center - visual_center
		if absf(offset.x) <= half_size.x and absf(offset.y) <= half_size.y:
			if not _pending_hit_ids.has(target_id):
				_pending_hits.push_back(target)
				_pending_hit_ids[target_id] = true
				_target_next_hit_msec[target_id] = now_msec + int(HIT_INTERVAL * 1000.0)


func _is_valid_target(target: Node) -> bool:
	if target == null or not is_instance_valid(target) or not (target is BaseMonster):
		return false

	if target.is_queued_for_deletion() or target.is_death:
		return false
	if target.hp <= 0 or target.no_target or target.is_boss_protecting():
		return false
	return true


func _apply_hit(target: BaseMonster) -> void:
	if not _is_valid_target(target) or owner_player == null or not is_instance_valid(owner_player):
		return
	var source_player := owner_player as BaseHero
	if source_player == null:
		return

	var damage_source_state := target.bind_role_damage_source(source_player)
	var old_hit_data: Dictionary = source_player.hit_dic
	var old_target: Variant = target.get_target
	var old_source_player: Variant = role_props.source_player
	var old_tszzs: float = source_player.tszzs
	source_player.hit_dic = hit_data
	target.get_target = source_player
	target.has_target = true

	role_props.source_player = source_player
	if source_player.istsz:
		var tsz_level := int(player_data.player_data["腾蛇阵"]["Level"])
		source_player.tszzs = tsz_level * 0.015
	else:
		source_player.tszzs = 0.0

	var base_damage := float(target.get_role_last_hurt(source_player))

	var damage_scale := float(target.llrdzs)
	if is_nan(damage_scale) or is_inf(damage_scale) or damage_scale <= 0.0:
		damage_scale = 1.0
	var damage := int(
		(
			base_damage
			* role_props.ws_up_power
			* target.jgz_bl
			* target.zznh_bl
			* target.hurt_bl
			* (1.0 + target.lpzzs)
			* (1.0 + source_player.tszzs)
			* damage_scale
		)
	)
	target.hurt_received = damage
	target.cure_ws_value(source_player)
	if damage > 0:
		target.hurt_reduce_hp(damage, owner_player)
		if target is Monster138:
			target.transfer_linked_damage(damage)
		target.add_lj(damage)
		Global.total_role_hit += damage
		if str(hit_data.get("attackKind", "")) == "magic":
			Global.total_mag_hit += damage
		Global.get_audio_runtime().add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not target.is_miss and not target.is_boss_protecting():
			target.hurt_special_effect = Global.add_mr_hurt(target.pz, Vector2(0, 0))
		if not target.is_control_immune():
			_apply_hit_stun(target)
		if not target.is_boss_protecting():
			_apply_voodoo_if_learned(target)
		target.role5_bullet(damage, owner_player)
	target.get_target = old_target
	source_player.hit_dic = old_hit_data
	source_player.tszzs = old_tszzs
	role_props.source_player = old_source_player
	target.unbind_role_damage_source(damage_source_state)


func _apply_hit_stun(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.is_control_immune():
		return
	if target.mr_player != null and target.mr_player.has_animation("hurt"):
		if String(target.mr_player.current_animation) != "hurt":
			target.mr_player.play("hurt")
	target.extend_timed_hit_stun("cmly_hit_stun", 0.2)


func _apply_voodoo_if_learned(target: Node) -> void:
	var skill_level := int(player_data.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL])
	var source_player := owner_player as BaseHero
	if skill_level <= 0 or Global.check_wd(target, source_player) >= 7:
		return
	Global.add_buff(
		target.buff,
		{
			"Name": "Voodoo",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": int(role_props.roleprop.power * 0.1),
			"CanAdd": true,
			"AttackKind": "real",
			"DeBuff": true,
			"source_player": source_player
		}
	)


func _cache_targets() -> void:
	var level := _find_level_node()
	var version := (
		int(level.get_active_monster_version())
		if level != null and level.has_method("get_active_monster_version")
		else -1
	)
	if version >= 0 and version == _target_snapshot_version:
		return
	var monster_container: Variant = level.get("monster") if level != null else null
	if version < 0 and not monster_container is Node:
		monster_container = get_tree().current_scene
	if version < 0 and monster_container is Node:
		var container := monster_container as Node
		if _fallback_target_container == container and not _fallback_targets_dirty:
			return
		if _fallback_target_container != container:
			_fallback_target_container = container
			_fallback_targets_dirty = true
			if not container.child_entered_tree.is_connected(_on_fallback_target_tree_changed):
				container.child_entered_tree.connect(_on_fallback_target_tree_changed)
			if not container.child_exiting_tree.is_connected(_on_fallback_target_tree_changed):
				container.child_exiting_tree.connect(_on_fallback_target_tree_changed)
		_fallback_targets_dirty = false
	_target_snapshot_version = version
	_cached_targets.clear()
	_cached_target_ids.clear()
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		for target in level.get_active_monsters():
			_append_cached_target(target)
		return

	if monster_container is Node:
		_collect_targets(monster_container as Node)
	else:
		var scene := get_tree().current_scene
		if scene != null:
			_collect_targets(scene)


func _on_fallback_target_tree_changed(_node: Node) -> void:
	_fallback_targets_dirty = true


func _find_level_node() -> Node:
	var node := owner_player.get_parent()
	while node != null:
		if node is BaseLevel:
			return node
		node = node.get_parent()
	return get_tree().current_scene


func _collect_targets(node: Node) -> void:
	if node is BaseMonster:
		_append_cached_target(node as BaseMonster)
	for child in node.get_children():
		_collect_targets(child)


func _append_cached_target(target: Node) -> void:
	if target == null or not is_instance_valid(target) or not (target is BaseMonster):
		return

	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return
	if target.has_method("get") and target.get("is_summon") == true:
		return
	var target_id := target.get_instance_id()
	if _cached_target_ids.has(target_id):
		return
	_cached_target_ids[target_id] = true
	_cached_targets.append(target as BaseMonster)


func _finish_after(duration: float) -> void:
	await get_tree().create_timer(duration, false).timeout
	if is_inside_tree():
		queue_free()


static func preload_effect_data() -> bool:
	return _preload_effect_data()


static func _preload_effect_data() -> bool:
	if _shared_data != null:
		return true
	if not ClassDB.class_exists("SpineSkeletonDataResource") or not ClassDB.class_exists("SpineSprite"):
		return false
	var atlas: Variant = ResourceLoader.load(ATLAS_PATH, "", ResourceLoader.CACHE_MODE_REUSE)
	var skeleton_file := ResourceLoader.load(SKELETON_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE)
	if atlas == null or skeleton_file == null:
		push_error("苍木龙陨 Spine 资源加载失败")
		return false
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	if skeleton_data == null:
		push_error("苍木龙陨 SpineSkeletonDataResource 创建失败")
		return false
	skeleton_data.set_atlas_res(atlas)
	skeleton_data.set_skeleton_file_res(skeleton_file)
	skeleton_data.update_skeleton_data()
	if not skeleton_data.is_skeleton_data_loaded():
		push_error("苍木龙陨 skeleton 数据加载失败")
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


func _spawn_fallback_visual() -> void:
	var metadata_file := FileAccess.open(FALLBACK_FRAME_META, FileAccess.READ)
	if metadata_file == null:
		push_error("苍木龙陨兼容帧索引缺失")
		return
	var parsed: Variant = JSON.parse_string(metadata_file.get_as_text())
	if not (parsed is Dictionary) or not (parsed.get("frames", []) is Array):
		push_error("苍木龙陨兼容帧索引无效")
		return
	var sprite := Sprite2D.new()
	sprite.z_index = 24
	sprite.centered = true
	add_child(sprite)
	_fallback_sprite = sprite
	_play_fallback_frames(sprite, parsed["frames"])


func _play_fallback_frames(sprite: Sprite2D, frame_meta: Array) -> void:
	for frame_data in frame_meta:
		if not is_inside_tree() or sprite == null or not is_instance_valid(sprite):
			return
		if not (frame_data is Dictionary):
			continue
		var frame_name := str(frame_data.get("file", ""))
		var texture := load(FALLBACK_FRAME_DIR + frame_name) as Texture2D
		if texture == null:
			continue
		var frame_width := float(frame_data.get("width", texture.get_width()))
		var frame_height := float(frame_data.get("height", texture.get_height()))
		var frame_left := float(frame_data.get("left", 0.0))
		var frame_top := float(frame_data.get("top", 0.0))
		sprite.texture = texture
		sprite.position = Vector2(frame_left + frame_width * 0.5 - 800.0, frame_top + frame_height * 0.5 - 900.0)
		sprite.scale = Vector2(-1.0 if not face_right else 1.0, 1.0)
		await get_tree().create_timer(1.0 / 30.0, false).timeout

extends Node2D
class_name HmzAwakenEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const ATLAS_PATH := "res://Art/hero_picture/role_2/jhsj_awaken/runtime/HeroF_6030_skill.atlas"
const SKELETON_PATH := "res://Art/hero_picture/role_2/jhsj_awaken/runtime/HeroF_6030_skill01_2_1.spine-json"
const SPINE_SCALE := Vector2(0.2, 0.2)
const SPINE_DURATION := 1.35

const NODE_HITS: Array[Dictionary] = [
	{"time": 0.1, "bone": "FX/xialuohuo/luohuo0"},
	{"time": 0.2, "bone": "shandian"},
	{"time": 0.2, "bone": "jiantou"},
	{"time": 0.2, "bone": "huoquan00001"},
	{"time": 0.2, "bone": "huoquan6"},
	{"time": 0.2, "bone": "js001"},
	{"time": 0.2, "bone": "js1"},
	{"time": 0.2, "bone": "FX/yancheng2/yan2_24"},
	{"time": 0.2, "bone": "FX/yuanquan_9"},
	{"time": 0.2, "bone": "FX72"},
	{"time": 0.2667, "bone": "jianshe001"},
	{"time": 0.2667, "bone": "huozhu"},
	{"time": 0.2667, "bone": "FX/qizhao/hero_1023_huobao_00018"},
	{"time": 0.2667, "bone": "FX/yancheng2/yan2_25"},
	{"time": 0.3, "bone": "huoquan11"},
	{"time": 0.3, "bone": "huoquan14"},
	{"time": 0.3, "bone": "FX/kuosan4/kuosan4_17"},
	{"time": 0.3, "bone": "suishi01"},
	{"time": 0.3333, "bone": "FX/baodian4/hero_1023_huoxing_00001"},
	{"time": 0.3333, "bone": "huoquan10"},
	{"time": 0.3333, "bone": "huoquan12"},
	{"time": 0.3333, "bone": "FX/kuosan4/kuosan4_18"},
	{"time": 0.3333, "bone": "FX/shitoubao/shitoubao_00000"},
	{"time": 0.4333, "bone": "huoquan8"},
	{"time": 0.4333, "bone": "FX/kuosan4/kuosan4_22"},
	{"time": 0.4333, "bone": "FX/kuosan4/kuosan4_23"},
	{"time": 0.4333, "bone": "suishi1"},
	{"time": 0.4333, "bone": "suishi2"},
	{"time": 0.4333, "bone": "suishi3"},
	{"time": 0.4333, "bone": "suishi4"},
	{"time": 0.4667, "bone": "FX/kuosan4/kuosan4_19"},
	{"time": 0.4667, "bone": "suishi5"},
	{"time": 0.5333, "bone": "huoquan9"},
	{"time": 0.5333, "bone": "huoquan13"},
	{"time": 0.5333, "bone": "huoquan15"},
	{"time": 0.5667, "bone": "suishi6"},
	{"time": 0.6333, "bone": "FX/kuosan4/kuosan4_21"},
	{"time": 0.6667, "bone": "FX/kuosan4/kuosan4_20"}
]
const ORIGINAL_HITBOX_HALF_SIZE := Vector2(74.5, 62.0)
const NODE_HIT_ENVELOPE_HALF_SIZE := Vector2(620.0, 520.0)

var owner_player: Node2D
var hit_data: Dictionary = {}
var face_right := true
var has_visual := false
var _spine: Variant = null
var _cached_targets: Array[BaseMonster] = []
var _target_snapshot_version := -2
var _hit_bones: Dictionary = {}
static var _shared_data: Variant = null
static var _normal_material: CanvasItemMaterial
static var _additive_material: CanvasItemMaterial
static var _multiply_material: CanvasItemMaterial


func setup(player: Node2D, is_facing_right: bool, data: Dictionary = {}) -> void:
	owner_player = player
	face_right = is_facing_right
	hit_data = data.duplicate(true)
	if player != null and player.has_method("get_hmz_ws_hit_data"):
		var ws_hit_data: Variant = player.call("get_hmz_ws_hit_data", "hmz_3")
		if ws_hit_data is Dictionary and not ws_hit_data.is_empty():
			hit_data = ws_hit_data
	_target_snapshot_version = -2
	_cached_targets.clear()
	_hit_bones.clear()


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	_cache_targets()
	var visual_loaded: bool = await _spawn_spine_visual()
	if not visual_loaded:
		queue_free()
		return
	has_visual = true
	_run_hits()
	_finish_after(SPINE_DURATION)


func _process(_delta: float) -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position


func _spawn_spine_visual() -> bool:
	if not ClassDB.class_exists("SpineSkeletonDataResource") or not ClassDB.class_exists("SpineSprite"):
		push_error("HmzAwakenEffect: Spine GDExtension is not loaded")
		return false
	if not preload_effect_data():
		return false
	_spine = ClassDB.instantiate("SpineSprite")
	if _spine == null or not _spine.has_method("set_skeleton_data_res"):
		_spine = null
		return false
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
	var state: Variant = _spine.get_animation_state()
	if state == null:
		await get_tree().process_frame
		if _spine != null and is_instance_valid(_spine):
			state = _spine.get_animation_state()
	if state == null:
		_spine.queue_free()
		_spine = null
		return false
	state.set_animation("skill01_2_1", false, 0)
	_cache_hit_bones(_spine.get_skeleton())
	return true


func _finish_after(duration: float) -> void:
	await get_tree().create_timer(duration, false).timeout
	if is_inside_tree():
		queue_free()


func _run_hits() -> void:
	var previous_time := 0.0
	for node_hit in NODE_HITS:
		var hit_time := float(node_hit["time"])
		var wait_time := hit_time - previous_time
		if wait_time > 0.0:
			await get_tree().create_timer(wait_time, false).timeout
		if owner_player == null or not is_instance_valid(owner_player):
			return
		_apply_node_damage(str(node_hit["bone"]))
		previous_time = hit_time


func _apply_node_damage(bone_name: String) -> void:
	if hit_data.is_empty() or owner_player == null or not is_instance_valid(owner_player):
		return

	_cache_targets()
	var hit_center := _get_node_global_position(bone_name)
	var hit_half_size := _get_node_hit_half_size()
	for target in _cached_targets:
		if target == null or not is_instance_valid(target):
			continue
		if target.hp <= 0 or target.no_target or target.is_boss_protecting():
			continue
		var offset: Vector2 = target.global_position + Vector2(0.0, -70.0) - hit_center
		if absf(offset.x) <= hit_half_size.x and absf(offset.y) <= hit_half_size.y:
			_apply_hit(target)


func _get_node_hit_half_size() -> Vector2:
	var hit_scale := Vector2(2.2, 3.2) if role_props.is_ws_state else Vector2(1.5, 2.2)
	var original_half_size := ORIGINAL_HITBOX_HALF_SIZE * hit_scale
	return Vector2(
		maxf(original_half_size.x, NODE_HIT_ENVELOPE_HALF_SIZE.x),
		maxf(original_half_size.y, NODE_HIT_ENVELOPE_HALF_SIZE.y)
	)


func _get_node_global_position(bone_name: String) -> Vector2:
	var node_position := global_position
	if _spine != null and is_instance_valid(_spine) and _spine.has_method("get_skeleton"):
		var skeleton: Variant = _spine.get_skeleton()
		if skeleton != null:
			var bone: Variant = _hit_bones.get(bone_name)
			if bone == null and skeleton.has_method("find_bone"):
				bone = skeleton.find_bone(bone_name)
				if bone != null:
					_hit_bones[bone_name] = bone
			if bone != null and bone.has_method("get_global_transform"):
				if skeleton.has_method("update_world_transform"):
					skeleton.update_world_transform(0)
				node_position = bone.get_global_transform().origin
	return node_position


func _cache_hit_bones(skeleton: Variant) -> void:
	_hit_bones.clear()
	if skeleton == null or not skeleton.has_method("find_bone"):
		return
	for node_hit in NODE_HITS:
		var bone_name := str(node_hit["bone"])
		var bone: Variant = skeleton.find_bone(bone_name)
		if bone != null:
			_hit_bones[bone_name] = bone


func _cache_targets() -> void:
	var level := _find_level_node()
	var version := (
		int(level.get_active_monster_version())
		if level != null and level.has_method("get_active_monster_version")
		else -1
	)
	if version >= 0 and version == _target_snapshot_version:
		return
	_target_snapshot_version = version
	_cached_targets.clear()
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		for target in level.get_active_monsters():
			if target is BaseMonster and not _cached_targets.has(target):
				_cached_targets.append(target as BaseMonster)
		return
	var monster_container: Variant = level.get("monster") if level != null else null
	if monster_container is Node:
		_collect_targets(monster_container as Node)
	else:
		var scene := get_tree().current_scene
		if scene != null:
			_collect_targets(scene)


func _find_level_node() -> Node:
	var node: Node = owner_player.get_parent() if owner_player != null else null
	while node != null:
		if node is BaseLevel or node.get("monster") is Node:
			return node
		node = node.get_parent()
	return get_tree().current_scene


func _collect_targets(node: Node) -> void:
	if node is BaseMonster:
		_cached_targets.append(node as BaseMonster)
	for child in node.get_children():
		_collect_targets(child)


func _apply_hit(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.hp <= 0:
		return
	var damage_source_state := target.bind_role_damage_source(owner_player as BaseHero)
	var old_hit_data: Dictionary = owner_player.hit_dic
	var old_target: Variant = target.get_target
	var old_miss: int = target.miss
	var old_source_player: Variant = role_props.source_player
	var old_tszzs: float = owner_player.tszzs
	owner_player.hit_dic = hit_data
	target.get_target = owner_player
	target.has_target = true

	role_props.source_player = owner_player
	target.miss = 0
	if owner_player.istsz:
		var tsz_level := int(player_data.player_data["腾蛇阵"]["Level"])
		owner_player.tszzs = tsz_level * 0.015
	else:
		owner_player.tszzs = 0.0
	var damage_scale := float(target.llrdzs)
	if is_nan(damage_scale) or is_inf(damage_scale) or damage_scale <= 0.0:
		damage_scale = 1.0
	var damage := int(
		(
			float(target.get_role_last_hurt(owner_player))
			* role_props.ws_up_power
			* target.jgz_bl
			* target.zznh_bl
			* target.hurt_bl
			* (1.0 + target.lpzzs)
			* (1.0 + owner_player.tszzs)
			* damage_scale
		)
	)
	target.hurt_received = damage
	target.cure_ws_value(owner_player as BaseHero)
	target.hurt_reduce_hp(damage, owner_player)
	if damage > 0:
		target.add_lj(damage)
		Global.get_run_context().add_damage_dealt(damage)
		if str(hit_data.get("attackKind", "")) == "magic":
			Global.get_run_context().add_damage_dealt_by_type("magic", damage)
		Global.get_audio_runtime().add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not target.is_miss and not target.is_boss_protecting():
			target.hurt_special_effect = Global.add_mr_hurt(target.pz, Vector2.ZERO)
		if not target.is_control_immune():
			_apply_hit_stun(target)
		target.role5_bullet(damage, owner_player)
	target.get_target = old_target
	target.miss = old_miss
	owner_player.hit_dic = old_hit_data
	owner_player.tszzs = old_tszzs
	target.unbind_role_damage_source(damage_source_state)
	role_props.source_player = old_source_player


func _apply_hit_stun(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.is_control_immune():
		return
	if target.mr_player != null and target.mr_player.has_animation("hurt"):
		target.mr_player.play("hurt")
	target.extend_timed_hit_stun("hmz_awaken_hit_stun", 0.2)


static func preload_effect_data() -> bool:
	if _shared_data != null:
		return true
	if not ClassDB.class_exists("SpineSkeletonDataResource") or not ClassDB.class_exists("SpineSprite"):
		return false
	var atlas: Variant = ResourceLoader.load(ATLAS_PATH, "", ResourceLoader.CACHE_MODE_REUSE)
	var skeleton_file := ResourceLoader.load(SKELETON_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE)
	if atlas == null:
		push_error("HmzAwakenEffect: 无法加载 Spine atlas: " + ATLAS_PATH)
		return false
	if skeleton_file == null:
		push_error("HmzAwakenEffect: 无法加载 Spine skeleton: " + SKELETON_PATH)
		return false
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	if skeleton_data == null:
		return false
	skeleton_data.set_atlas_res(atlas)
	skeleton_data.set_skeleton_file_res(skeleton_file)
	skeleton_data.update_skeleton_data()
	if not skeleton_data.is_skeleton_data_loaded():
		push_error("HmzAwakenEffect: Spine 骨骼数据解析失败: " + SKELETON_PATH)
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

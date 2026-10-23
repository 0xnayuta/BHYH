extends Node2D
class_name Role4PoisonArrayAwakenEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const ATLAS_PATH := "res://Art/hero_picture/role_4/cang_mu_long_yun/runtime/HeroF_6009_skill.atlas"
const SKELETON_PATH := "res://Art/hero_picture/role_4/cang_mu_long_yun/runtime/HeroF_6009_skill.spine-json"
const SPINE_SCALE := Vector2(0.2, 0.2)
const HIT_INTERVAL := 0.2
const WHIRLWIND_HIT_HALF_SIZE := Vector2(180.0, 220.0)
const WHIRLWIND_SLOT_NAMES := [
	"FX-longjuanfeng-ljf0_0", "FX-longjuanfeng-ljf0_1", "FX-longjuanfeng-ljf0_2", "FX-longjuanfeng-ljf0_3"
]

var owner_player: BaseHero = null
var array_node: Node = null
var hit_data: Dictionary = {}
var face_right := true
var _spine: Variant = null
var _elapsed := 0.0
var _hit_elapsed := 0.0
var _cached_targets: Array[BaseMonster] = []
var _whirlwind_slots: Array = []
static var _shared_data: Variant = null
static var _normal_material: CanvasItemMaterial
static var _additive_material: CanvasItemMaterial
static var _multiply_material: CanvasItemMaterial


static func clear_cached_data() -> void:
	_shared_data = null
	_normal_material = null
	_additive_material = null
	_multiply_material = null


func setup(player: BaseHero, is_facing_right: bool, data: Dictionary, field: Node = null) -> void:
	owner_player = player
	face_right = is_facing_right
	hit_data = data.duplicate(true)
	array_node = field


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	_cache_targets()
	if not _spawn_spine_visual():
		queue_free()


func _process(delta: float) -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	_elapsed += delta
	_hit_elapsed += delta
	if _hit_elapsed >= HIT_INTERVAL:
		_hit_elapsed = fmod(_hit_elapsed, HIT_INTERVAL)
		_apply_area_damage()
	if array_node == null or not is_instance_valid(array_node) or array_node.is_queued_for_deletion():
		queue_free()


func _spawn_spine_visual() -> bool:
	if not ClassDB.class_exists("SpineSkeletonDataResource") or not ClassDB.class_exists("SpineSprite"):
		return false
	if not _preload_spine_data():
		return false
	_spine = ClassDB.instantiate("SpineSprite")
	if _spine == null or not _spine.has_method("set_skeleton_data_res"):
		_spine = null
		return false
	_spine.scale = SPINE_SCALE
	scale.x = 1.0 if face_right else -1.0
	z_index = 98
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
		_cache_whirlwind_slots(skeleton)
	var state: Variant = _spine.get_animation_state()
	if state == null:
		return false
	state.set_animation("skill03_3", true, 0)
	return true


func _cache_whirlwind_slots(skeleton: Variant) -> void:
	_whirlwind_slots.clear()
	if skeleton == null or not skeleton.has_method("find_slot"):
		return
	for slot_name in WHIRLWIND_SLOT_NAMES:
		var slot: Variant = skeleton.find_slot(slot_name)
		if slot != null:
			_whirlwind_slots.append(slot)


static func _preload_spine_data() -> bool:
	if _shared_data != null:
		return true
	var atlas := load(ATLAS_PATH)
	var skeleton_file := load(SKELETON_PATH)
	if atlas == null or skeleton_file == null:
		return false
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	if skeleton_data == null:
		return false
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


func _cache_targets() -> void:
	_cached_targets.clear()
	var level := owner_player.get_parent().get_parent() if owner_player != null else null
	var monsters: Node = level.get("monster") if level != null else null
	if monsters == null:
		return
	for child in monsters.get_children():
		if child is BaseMonster:
			_cached_targets.append(child as BaseMonster)


func _apply_area_damage() -> void:
	if hit_data.is_empty() or owner_player == null or not is_instance_valid(owner_player):
		return
	_cache_targets()
	var skeleton: Variant = _spine.get_skeleton() if _spine != null and is_instance_valid(_spine) else null
	if skeleton == null:
		return
	if skeleton.has_method("update_world_transform"):
		skeleton.update_world_transform(0)
	var whirlwind_positions := _get_active_whirlwind_positions()
	if whirlwind_positions.is_empty():
		return
	for target in _cached_targets:
		if not _is_valid_target(target):
			continue
		var target_center := target.global_position + Vector2(0.0, -70.0)
		for whirlwind_position in whirlwind_positions:
			var offset := target_center - whirlwind_position
			if absf(offset.x) <= WHIRLWIND_HIT_HALF_SIZE.x and absf(offset.y) <= WHIRLWIND_HIT_HALF_SIZE.y:
				_apply_hit(target)
				break


func _get_active_whirlwind_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for slot in _whirlwind_slots:
		if slot == null:
			continue
		var pose: Variant = slot.get_pose() if slot.has_method("get_pose") else null
		var attachment: Variant = pose.get_attachment() if pose != null and pose.has_method("get_attachment") else null
		if attachment == null:
			continue
		if slot.has_method("get_color"):
			var color: Variant = slot.get_color()
			if color is Color and (color as Color).a <= 0.01:
				continue
		var bone: Variant = slot.get_bone() if slot.has_method("get_bone") else null
		if bone != null and bone.has_method("get_global_transform"):
			positions.append(bone.get_global_transform().origin)
	return positions


func _is_valid_target(target: BaseMonster) -> bool:
	return (
		target != null
		and is_instance_valid(target)
		and target.hp > 0
		and not target.is_death
		and not target.no_target
		and not target.is_boss_protecting()
		and not target.get_meta("pet_tiger_unit", false)
		and not target.get_meta("is_summon", false)
	)


func _apply_hit(target: BaseMonster) -> void:
	var old_hit_data: Dictionary = owner_player.hit_dic
	var old_target: Variant = target.get_target
	var old_source_player: Variant = role_props.source_player
	owner_player.hit_dic = hit_data
	target.get_target = owner_player
	target.has_target = true
	role_props.source_player = owner_player
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
			* damage_scale
		)
	)
	if damage > 0:
		target.hurt_received = damage
		target.hurt_reduce_hp(damage, owner_player)
		if target is Monster138:
			target.transfer_linked_damage(damage)
		target.add_lj(damage)
		Global.total_role_hit += damage
		if str(hit_data.get("attackKind", "")) == "magic":
			Global.total_mag_hit += damage
		_apply_voodoo_if_learned(target)
		target.role5_bullet(damage, owner_player)
	target.get_target = old_target
	owner_player.hit_dic = old_hit_data
	role_props.source_player = old_source_player


func _apply_voodoo_if_learned(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.is_boss_protecting():
		return
	if (
		int(player_data.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL]) <= 0
		or Global.check_wd(target) >= 7
	):
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
			"DeBuff": true
		}
	)

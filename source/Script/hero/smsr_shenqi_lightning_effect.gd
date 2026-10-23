extends Node2D
class_name SMSRShenqiLightningEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const EFFECT_OFFSET := Vector2(0.0, -8.0)
const EFFECT_SCALE := Vector2(0.65, 0.65)
const LIGHTNING_POSITION := Vector2(0.0, -200.0)
const HIT_POSITION := Vector2(0.0, -1.0)
const STRIKES_PER_ROUND := 3
const STRIKE_INTERVAL := 0.18
const TARGET_HALF_WIDTH := 720.0
const TARGET_HALF_HEIGHT := 380.0
const DAMAGE_RADIUS_X := 230.0
const DAMAGE_RADIUS_Y := 170.0
const STUN_CHANCE := 0.2
const STUN_DURATION := 1.0

var owner_player: Node
var hit_data: Dictionary = {}
var _strikes: Array[Node2D] = []
static var _lightning_frames: SpriteFrames
static var _hit_frames: SpriteFrames
static var _additive_material: CanvasItemMaterial


static func prewarm_frames() -> void:
	_get_lightning_frames()
	_get_hit_frames()
	_get_additive_material()


static func clear_cached_frames() -> void:
	_lightning_frames = null
	_hit_frames = null


static func _get_lightning_frames() -> SpriteFrames:
	if _lightning_frames != null:
		return _lightning_frames
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", 60.0)
	frames.set_animation_loop("default", false)
	for index in range(9):
		var path := "res://Art/hero_picture/smsr_shenqi_lightning/lightning/d_%05d.png" % index
		var texture := load(path) as Texture2D
		if texture != null:
			frames.add_frame("default", texture)
	_lightning_frames = frames
	return _lightning_frames


static func _get_hit_frames() -> SpriteFrames:
	if _hit_frames != null:
		return _hit_frames
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", 30.0)
	frames.set_animation_loop("default", false)
	for index in range(0, 20, 2):
		var path := "res://Art/hero_picture/smsr_shenqi_lightning/hit_mesh/hit_%05d.png" % index
		var texture := load(path) as Texture2D
		if texture != null:
			frames.add_frame("default", texture, 2.0 if index >= 16 else 1.0)
	_hit_frames = frames
	return _hit_frames


static func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material


func setup(player: Node, data: Dictionary) -> void:
	owner_player = player
	hit_data = data.duplicate(true)


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	call_deferred("_run_round")


func _exit_tree() -> void:
	_cleanup_strikes()


func _run_round() -> void:
	var target_ids := _collect_nearby_target_ids()
	for strike_index in range(STRIKES_PER_ROUND):
		if owner_player == null or not is_instance_valid(owner_player) or not role_props.is_ws_state:
			_cleanup_strikes()
			queue_free()
			return
		_remove_invalid_target_ids(target_ids)
		if target_ids.is_empty():
			break
		var target := instance_from_id(target_ids[randi_range(0, target_ids.size() - 1)])
		if _is_valid_target(target):
			_spawn_strike(target, target_ids)
		if strike_index < STRIKES_PER_ROUND - 1:
			await get_tree().create_timer(STRIKE_INTERVAL, false).timeout
	await get_tree().create_timer(0.9, false).timeout
	_cleanup_strikes()
	queue_free()


func _remove_invalid_target_ids(target_ids: Array[int]) -> void:
	for index in range(target_ids.size() - 1, -1, -1):
		if not _is_valid_target(instance_from_id(target_ids[index])):
			target_ids.remove_at(index)


func _collect_nearby_target_ids() -> Array[int]:
	var target_ids: Array[int] = []
	for target in _collect_nearby_targets():
		target_ids.append(target.get_instance_id())
	return target_ids


func _collect_nearby_targets() -> Array[BaseMonster]:
	var targets: Array[BaseMonster] = []
	var seen: Dictionary = {}
	var tree := get_tree()
	if tree == null:
		return targets
	var level := _find_level_node()
	var used_level_index := false
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		used_level_index = true
		for node in level.get_active_monsters():
			_try_add_target(node, targets, seen)
	else:
		for node in tree.get_nodes_in_group("monsters"):
			_try_add_target(node, targets, seen)
	if not used_level_index and level != null and "monster" in level and level.monster != null:
		_collect_targets_recursive(level.monster, targets, seen)
	return targets


func _collect_targets_recursive(node: Node, targets: Array[BaseMonster], seen: Dictionary) -> void:
	if node == null:
		return
	_try_add_target(node, targets, seen)
	for child in node.get_children():
		_collect_targets_recursive(child, targets, seen)


func _try_add_target(node: Node, targets: Array[BaseMonster], seen: Dictionary) -> void:
	if not _is_valid_target(node):
		return
	var id := node.get_instance_id()
	if seen.has(id):
		return
	var offset: Vector2 = node.global_position - owner_player.global_position
	if absf(offset.x) > TARGET_HALF_WIDTH or absf(offset.y) > TARGET_HALF_HEIGHT:
		return
	seen[id] = true
	targets.append(node as BaseMonster)


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


func _find_level_node() -> Node:
	var node := owner_player.get_parent()
	while node != null:
		if "monster" in node:
			return node
		node = node.get_parent()
	return null


func _spawn_strike(target: BaseMonster, nearby_target_ids: Array[int]) -> void:
	if not _is_valid_target(target):
		return
	var strike := Node2D.new()
	strike.scale = EFFECT_SCALE
	strike.z_index = 30
	var parent_node := target.get_parent()
	if parent_node == null:
		parent_node = get_tree().current_scene
	if parent_node == null:
		return
	parent_node.add_child(strike)
	_strikes.append(strike)
	strike.global_position = target.global_position + EFFECT_OFFSET

	var lightning := _create_lightning_sprite()
	lightning.position = LIGHTNING_POSITION
	strike.add_child(lightning)

	var hit := _create_hit_sprite()
	hit.position = HIT_POSITION
	strike.add_child(hit)

	lightning.play("default")
	hit.play("default")
	_damage_area(target.global_position, nearby_target_ids)
	_remove_strike_after(strike, 0.43)


func _remove_strike_after(strike: Node, delay: float) -> void:
	await get_tree().create_timer(delay, false).timeout
	if strike != null and is_instance_valid(strike):
		strike.queue_free()
	if strike is Node2D:
		_strikes.erase(strike)


func _cleanup_strikes() -> void:
	for strike in _strikes:
		if strike != null and is_instance_valid(strike):
			strike.queue_free()
	_strikes.clear()


func _create_lightning_sprite() -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = _get_lightning_frames()
	return sprite


func _create_hit_sprite() -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = _get_hit_frames()
	sprite.material = _get_additive_material()
	return sprite


func _damage_area(center: Vector2, target_ids: Array[int]) -> void:
	for target_id in target_ids:
		var target := instance_from_id(target_id)
		if not _is_valid_target(target):
			continue
		var offset: Vector2 = target.global_position - center
		if absf(offset.x) > DAMAGE_RADIUS_X or absf(offset.y) > DAMAGE_RADIUS_Y:
			continue
		_apply_hit(target)
		if randf() < STUN_CHANCE:
			_apply_stun(target)


func _apply_stun(target: BaseMonster) -> void:
	if not _is_valid_target(target) or target.buff == null:
		return
	Global.add_buff(
		target.buff,
		{
			"Name": "stun",
			"AddTime": STUN_DURATION,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanRemove": true,
			"CanAdd": false,
			"DeBuff": true
		}
	)


func _apply_hit(target: BaseMonster) -> void:
	if not _is_valid_target(target) or owner_player == null or not is_instance_valid(owner_player):
		return
	var old_hit_data: Dictionary = owner_player.hit_dic
	owner_player.hit_dic = hit_data
	var damage := int(target.get_role_last_hurt(owner_player))
	if damage > 0:
		if role_props.source_player.istsz:
			var tsz_level := int(player_data.player_data["腾蛇阵"]["Level"])
			role_props.source_player.tszzs = tsz_level * 0.015
		else:
			role_props.source_player.tszzs = 0.0
		damage = int(
			(
				damage
				* role_props.ws_up_power
				* target.jgz_bl
				* target.zznh_bl
				* target.hurt_bl
				* (1.0 + target.lpzzs)
				* (1.0 + owner_player.tszzs)
				* target.llrdzs
			)
		)
		target.hurt_received = damage
		target.hurt_reduce_hp(damage, owner_player)
		target.add_lj(damage)
		Global.total_role_hit += damage
		Global.total_mag_hit += damage
		Global.add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
	owner_player.hit_dic = old_hit_data

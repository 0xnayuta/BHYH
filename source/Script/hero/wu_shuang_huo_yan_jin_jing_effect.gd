extends Node2D
class_name WuShuangHuoYanJinJingEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const FRAME_COUNT := 53
const EFFECT_FPS := 30.0
const BEAM_FRONT_LENGTH := 1450.0
const BEAM_BACK_LENGTH := 350.0
const BEAM_VERTICAL_CENTER := -87.0
const BEAM_HALF_HEIGHT := 420.0
const EFFECT_SCALE := Vector2(1, 1)
const EFFECT_Y_OFFSET := 60
const HIT_EVERY_FRAMES := 3
const FRAME_PATH_FORMAT := "res://Art/hero_picture/role_1/wu_shuang_huo_yan_jin_jing_cropped/hyjj_ws_%03d.png"
const FRAME_OFFSETS := [
	Vector2(-36.0, -104.0),
	Vector2(0.0, 45.5),
	Vector2(-8.0, 27.5),
	Vector2(-17.0, 10.5),
	Vector2(-24.5, -35.5),
	Vector2(-23.0, -25.0),
	Vector2(-25.0, -38.0),
	Vector2(-28.5, -57.0),
	Vector2(-31.5, -73.0),
	Vector2(-38.0, -85.0),
	Vector2(-38.5, -91.5),
	Vector2(-37.5, -96.0),
	Vector2(-36.0, -102.0),
	Vector2(-36.0, -104.0),
	Vector2(-34.5, -108.0),
	Vector2(-33.5, -112.5),
	Vector2(-33.0, -115.0),
	Vector2(-32.0, -120.0),
	Vector2(-38.0, -86.0),
	Vector2(-35.0, -31.0),
	Vector2(7.0, -9.5),
	Vector2(6.0, -16.0),
	Vector2(-478.0, 0.0),
	Vector2(-226.5, 0.0),
	Vector2(-123.0, -0.5),
	Vector2(-49.5, -1.0),
	Vector2(-43.5, -1.0),
	Vector2(-21.0, -1.0),
	Vector2(-1.5, -0.5),
	Vector2(11.0, -0.5),
	Vector2(14.0, 0.0),
	Vector2(15.5, 0.0),
	Vector2(19.5, 0.5),
	Vector2(-128.0, -8.0),
	Vector2(-113.5, -8.0),
	Vector2(-98.5, -8.0),
	Vector2(-92.0, -7.0),
	Vector2(-96.0, -7.0),
	Vector2(-96.5, -7.0),
	Vector2(-97.5, -6.0),
	Vector2(-99.0, -6.0),
	Vector2(-89.5, -6.0),
	Vector2(-94.0, -0.5),
	Vector2(-138.5, 38.5),
	Vector2(-118.5, 37.5),
	Vector2(-143.5, 36.0),
	Vector2(-160.5, 31.0),
	Vector2(-149.5, 31.0),
	Vector2(-150.0, 40.5),
	Vector2(-305.0, 21.0),
	Vector2(-452.5, -16.5),
	Vector2(-452.5, -16.5),
	Vector2(-452.5, -16.5),
]
static var _frame_cache: Array[Texture2D] = []
static var _warming := false
static var _cache_generation := 0

var owner_player: Node
var direction_right := true
var hit_data: Dictionary = {}
var _beam: Sprite2D
var _current_frame := 0
var _last_damage_frame := -HIT_EVERY_FRAMES
var _cached_target_ids: Array[int] = []
var _base_beam_position := Vector2.ZERO
var _target_snapshot_version := -1


func setup(player: Node, face_right: bool, data: Dictionary) -> void:
	owner_player = player
	direction_right = face_right
	hit_data = data.duplicate(true)


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	_cache_targets()
	_beam = Sprite2D.new()
	_beam.scale = EFFECT_SCALE
	_beam.flip_h = not direction_right

	_base_beam_position = Vector2(
		(1100.0 - 554.0) * (1.0 if direction_right else -1.0), 600.0 - 687.0 + EFFECT_Y_OFFSET
	)
	_beam.position = _base_beam_position
	_beam.z_index = 24
	add_child(_beam)
	_run_sequence()


func _process(_delta: float) -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	if _beam == null or not is_instance_valid(_beam):
		return
	if _current_frame - _last_damage_frame >= HIT_EVERY_FRAMES:
		_last_damage_frame = _current_frame
		_damage_targets_in_beam()


func _run_sequence() -> void:
	var frame_time := 1.0 / EFFECT_FPS
	for index in range(FRAME_COUNT):
		if _beam == null or not is_instance_valid(_beam):
			break
		_current_frame = index
		_beam.texture = null
		_beam.texture = _load_frame_texture(index)
		_beam.position = _frame_position(index)

		var tree := get_tree()
		if tree == null:
			break
		await tree.create_timer(frame_time, false).timeout
	if _beam != null and is_instance_valid(_beam):
		_beam.texture = null
	queue_free()


static func prewarm_frames() -> void:
	if _warming or _frame_cache.size() == FRAME_COUNT:
		return
	_warming = true
	var generation := _cache_generation
	var tree := Engine.get_main_loop() as SceneTree
	_frame_cache.resize(FRAME_COUNT)
	var batch_size := 2 if OS.has_feature("mobile") else 4
	for batch_start in range(0, FRAME_COUNT, batch_size):
		var batch_end := mini(batch_start + batch_size, FRAME_COUNT)
		for index in range(batch_start, batch_end):
			ResourceLoader.load_threaded_request(
				FRAME_PATH_FORMAT % index, "Texture2D", false, ResourceLoader.CACHE_MODE_REUSE
			)
		for index in range(batch_start, batch_end):
			var path := FRAME_PATH_FORMAT % index
			while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if tree == null:
					break
				await tree.process_frame
				if generation != _cache_generation:
					_warming = false
					return
			if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
				_frame_cache[index] = ResourceLoader.load_threaded_get(path) as Texture2D
	_warming = false


static func clear_cached_frames() -> void:
	_cache_generation += 1
	_warming = false
	_frame_cache.clear()


static func _load_frame_texture(index: int) -> Texture2D:
	if index < _frame_cache.size() and _frame_cache[index] != null:
		return _frame_cache[index]
	var path := FRAME_PATH_FORMAT % index
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path) as Texture2D
	return ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D


func _frame_position(index: int) -> Vector2:
	var frame_offset := Vector2.ZERO
	if index >= 0 and index < FRAME_OFFSETS.size():
		frame_offset = FRAME_OFFSETS[index]
	frame_offset.x *= 1.0 if direction_right else -1.0
	return _base_beam_position + frame_offset


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
	_cached_target_ids.clear()
	if level == null or not ("monster" in level) or level.monster == null:
		return
	if level.has_method("has_active_monster_index") and level.has_active_monster_index():
		for target in level.get_active_monsters():
			if _is_valid_target(target):
				_cached_target_ids.append(target.get_instance_id())
		return
	var seen: Dictionary = {}
	_collect_target_ids_recursive(level.monster, seen)


func _collect_target_ids_recursive(node: Node, seen: Dictionary) -> void:
	if node == null:
		return
	if _is_valid_target(node):
		var target_id := node.get_instance_id()
		if not seen.has(target_id):
			seen[target_id] = true
			_cached_target_ids.append(target_id)
	for child in node.get_children():
		_collect_target_ids_recursive(child, seen)


func _find_level_node() -> Node:
	var node := owner_player.get_parent()
	while node != null:
		if node is BaseLevel:
			return node
		node = node.get_parent()
	return get_tree().current_scene


func _damage_targets_in_beam() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		return
	var direction := 1.0 if direction_right else -1.0
	var level := _find_level_node()
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		for target in level.get_active_monsters():
			_damage_target_if_in_beam(target, direction)
		return
	for target_id in _cached_target_ids:
		var target := instance_from_id(target_id)
		_damage_target_if_in_beam(target, direction)


func _damage_target_if_in_beam(target: Variant, direction: float) -> void:
	if not _is_valid_target(target):
		return
	var offset: Vector2 = target.global_position - owner_player.global_position
	var forward_distance := offset.x * direction
	if forward_distance < -BEAM_BACK_LENGTH or forward_distance > BEAM_FRONT_LENGTH:
		return
	if absf(offset.y - BEAM_VERTICAL_CENTER) > BEAM_HALF_HEIGHT:
		return
	_apply_hit(target)


func _is_valid_target(target: Variant) -> bool:
	if target == null or not is_instance_valid(target) or not (target is BaseMonster):
		return false
	if target.hp <= 0 or target.no_target:
		return false
	if target.is_boss_protecting():
		return false
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return false
	if target.has_method("get") and target.get("is_summon") == true:
		return false
	return true


func _apply_hit(target: BaseMonster) -> void:
	var damage_source_state := target.bind_role_damage_source(owner_player as BaseHero)
	var old_hit_data: Dictionary = owner_player.hit_dic
	owner_player.hit_dic = hit_data
	var base_damage := float(target.get_role_last_hurt(owner_player))
	var late_frame_multiplier := 2.0 if _beam != null and _current_frame > 25 else 1.0
	var damage := int(
		(
			base_damage
			* late_frame_multiplier
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
		Global.get_audio_runtime().add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not target.is_miss and not target.is_boss_protecting():
			target.hurt_special_effect = Global.add_mr_hurt(target.pz, Vector2(0, 0))

		target.role5_bullet(damage, owner_player)
		if not role_props.is_ws_state:
			role_props.ws_value += int(hit_data.get("WSValue", 4))
	owner_player.hit_dic = old_hit_data
	target.unbind_role_damage_source(damage_source_state)

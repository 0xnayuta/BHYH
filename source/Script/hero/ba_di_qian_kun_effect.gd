extends Node2D
class_name BaDiQianKunEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const FRAME_COUNT := 30
const EFFECT_FPS := 30.0
const EFFECT_POSITION := Vector2(50, -135.0)
const EFFECT_SCALE := Vector2(0.7, 0.7)
const HIT_INTERVAL_FRAMES := 4
const FRONT_HIT_INTERVAL_FRAMES := 2
const FRONT_DAMAGE_MULTIPLIER := 2.0
const FRONT_WIDTH_RATIO := 0.35
const FRAME_BOUNDS := [
	Rect2(167, 292, 317, 202),
	Rect2(141, 270, 337, 262),
	Rect2(120, 247, 351, 320),
	Rect2(113, 230, 350, 365),
	Rect2(116, 217, 337, 406),
	Rect2(123, 211, 321, 441),
	Rect2(137, 210, 294, 458),
	Rect2(135, 198, 309, 495),
	Rect2(149, 209, 273, 473),
	Rect2(20, 191, 479, 467),
	Rect2(80, 0, 515, 498),
	Rect2(217, 307, 729, 426),
	Rect2(221, 306, 730, 433),
	Rect2(226, 300, 732, 438),
	Rect2(230, 289, 726, 449),
	Rect2(232, 283, 723, 454),
	Rect2(231, 284, 723, 454),
	Rect2(232, 287, 726, 450),
	Rect2(229, 291, 727, 447),
	Rect2(227, 294, 729, 443),
	Rect2(224, 298, 731, 440),
	Rect2(223, 302, 732, 436),
	Rect2(220, 305, 734, 433),
	Rect2(218, 309, 736, 430),
	Rect2(151, 382, 325, 291),
	Rect2(102, 354, 377, 176),
	Rect2(280, 250, 156, 335),
	Rect2(310, 427, 228, 193),
	Rect2(309, 465, 209, 147),
	Rect2(309, 465, 209, 147)
]
const TEXTURE_SIZE := Vector2(978.0, 759.0)
const HIT_PADDING := Vector2(28.0, 35.0)
const FRAME_PATH_FORMAT := "res://Art/hero_picture/role_3/ba_di_qian_kun_smooth/bdqk_%03d.png"
const FRAME_OFFSETS := [
	Vector2(-163.5, 13.5),
	Vector2(-179.5, 21.5),
	Vector2(-193.5, 27.5),
	Vector2(-201.0, 33.0),
	Vector2(-204.5, 40.5),
	Vector2(-205.5, 52.0),
	Vector2(-205.0, 59.5),
	Vector2(-199.5, 66.0),
	Vector2(-203.5, 66.0),
	Vector2(-229.5, 45.0),
	Vector2(-151.5, -130.5),
	Vector2(92.5, 140.5),
	Vector2(97.0, 143.0),
	Vector2(103.0, 139.5),
	Vector2(104.0, 134.0),
	Vector2(104.5, 130.5),
	Vector2(103.5, 131.5),
	Vector2(106.0, 132.5),
	Vector2(103.5, 135.0),
	Vector2(102.5, 136.0),
	Vector2(100.5, 138.5),
	Vector2(100.0, 140.5),
	Vector2(98.0, 142.0),
	Vector2(97.0, 144.5),
	Vector2(-175.5, 148.0),
	Vector2(-198.5, 62.5),
	Vector2(-131.0, 38.0),
	Vector2(-65.0, 144.0),
	Vector2(-75.5, 159.0),
	Vector2(-75.5, 159.0)
]
static var _frame_cache: Array[Texture2D] = []
static var _warming := false
static var _cache_generation := 0

var owner_player: Node
var direction_right := true
var hit_data: Dictionary = {}
var _effect: Sprite2D
var _frame_index := 0
var _frame_elapsed := 0.0
var _finished := false
var _last_checked_frame := -1
var _target_last_hit_frame: Dictionary = {}
var _target_last_front_hit_frame: Dictionary = {}
var _cached_target_ids: Array[int] = []


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
	var direction := 1.0 if direction_right else -1.0
	_effect = _create_effect()
	_effect.position = Vector2(EFFECT_POSITION.x * direction, EFFECT_POSITION.y)
	_effect.scale = EFFECT_SCALE
	_effect.flip_h = not direction_right
	_effect.z_index = 12
	add_child(_effect)
	_show_frame(0)


func _process(delta: float) -> void:
	if owner_player != null and is_instance_valid(owner_player):
		global_position = owner_player.global_position
	if _effect == null or not is_instance_valid(_effect):
		return
	if _frame_index != _last_checked_frame:
		_last_checked_frame = _frame_index
		_damage_targets_in_front()
	if _finished:
		return
	_frame_elapsed += delta
	var frame_time := 1.0 / EFFECT_FPS
	while _frame_elapsed >= frame_time and not _finished:
		_frame_elapsed -= frame_time
		_show_frame(_frame_index + 1)


func _create_effect() -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.centered = true
	return sprite


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


func _show_frame(index: int) -> void:
	if index >= FRAME_COUNT:
		_finished = true
		if _effect != null and is_instance_valid(_effect):
			_effect.texture = null
		queue_free()
		return
	_frame_index = index
	var path := FRAME_PATH_FORMAT % index
	var texture: Texture2D = _frame_cache[index] if index < _frame_cache.size() else null
	if texture == null and ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		texture = ResourceLoader.load_threaded_get(path) as Texture2D
	if texture == null:
		texture = ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	_effect.texture = texture
	var frame_offset: Vector2 = FRAME_OFFSETS[index]
	var direction := 1.0 if direction_right else -1.0
	_effect.position = (
		Vector2(EFFECT_POSITION.x * direction, EFFECT_POSITION.y)
		+ Vector2(frame_offset.x * direction, frame_offset.y) * EFFECT_SCALE
	)


func _cache_targets() -> void:
	_cached_target_ids.clear()
	if owner_player == null or owner_player.get_parent() == null:
		return
	var level := owner_player.get_parent().get_parent()
	if level != null and "monster" in level and level.monster != null:
		for target in level.monster.get_children():
			if target is BaseMonster:
				_cached_target_ids.append(target.get_instance_id())


func _damage_targets_in_front() -> void:
	if owner_player == null or not is_instance_valid(owner_player) or _effect == null:
		return
	var level := owner_player.get_parent().get_parent()
	if level == null or not ("monster" in level) or level.monster == null:
		return
	var frame_index := clampi(_frame_index, 0, FRAME_BOUNDS.size() - 1)
	var bounds: Rect2 = FRAME_BOUNDS[frame_index]
	var local_center := bounds.position + bounds.size * 0.5 - TEXTURE_SIZE * 0.5
	local_center *= _effect.scale
	if _effect.flip_h:
		local_center.x = -local_center.x
	var visual_offset: Vector2 = (
		Vector2(FRAME_OFFSETS[frame_index].x * (1.0 if direction_right else -1.0), FRAME_OFFSETS[frame_index].y)
		* EFFECT_SCALE
	)
	var center: Vector2 = _effect.global_position - visual_offset + local_center
	var half_size: Vector2 = bounds.size * _effect.scale * 0.5 + HIT_PADDING
	var direction := 1.0 if direction_right else -1.0
	var front_half_width := maxf(25.0, half_size.x * FRONT_WIDTH_RATIO)
	var front_half_size := Vector2(front_half_width, half_size.y)
	var front_center := center + Vector2((half_size.x - front_half_width) * direction, 0.0)
	for target_id in _cached_target_ids:
		var target := instance_from_id(target_id)
		if not _is_valid_target(target):
			continue
		var origin: Vector2 = target.global_position
		var body: Vector2 = target.global_position + Vector2(0, -70)
		var front_hit := (
			_point_inside(origin, front_center, front_half_size) or _point_inside(body, front_center, front_half_size)
		)
		if front_hit:
			var last_front_frame := int(_target_last_front_hit_frame.get(target_id, -FRONT_HIT_INTERVAL_FRAMES))
			if frame_index - last_front_frame >= FRONT_HIT_INTERVAL_FRAMES:
				_target_last_front_hit_frame[target_id] = frame_index
				_apply_hit(target, FRONT_DAMAGE_MULTIPLIER)
			continue
		var body_hit := _point_inside(origin, center, half_size) or _point_inside(body, center, half_size)
		if body_hit:
			var last_frame := int(_target_last_hit_frame.get(target_id, -HIT_INTERVAL_FRAMES))
			if frame_index - last_frame >= HIT_INTERVAL_FRAMES:
				_target_last_hit_frame[target_id] = frame_index
				_apply_hit(target, 1.0)


func _point_inside(point: Vector2, center: Vector2, half_size: Vector2) -> bool:
	var offset := point - center
	return absf(offset.x) <= half_size.x and absf(offset.y) <= half_size.y


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


func _apply_hit(target: BaseMonster, damage_multiplier: float = 1.0) -> void:
	var damage_source_state := target.bind_role_damage_source(owner_player as BaseHero)
	var old_hit_data: Dictionary = owner_player.hit_dic
	owner_player.hit_dic = hit_data
	var base_damage := float(target.get_role_last_hurt(owner_player))
	var damage := int(
		(
			base_damage
			* damage_multiplier
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
		if not target.is_control_immune():
			_apply_hit_stun(target)
		Global.total_role_hit += damage
		Global.total_phy_hit += damage
		Global.get_audio_runtime().add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not target.is_miss and not target.is_boss_protecting():
			target.hurt_special_effect = Global.add_mr_hurt(target.pz, Vector2(0, 0))
		if not role_props.is_ws_state:
			role_props.ws_value += int(hit_data.get("WSValue", 8))
	owner_player.hit_dic = old_hit_data
	target.unbind_role_damage_source(damage_source_state)


func _apply_hit_stun(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.is_control_immune():
		return
	target.set_meta("bdqk_hit_stun_token", Time.get_ticks_msec())
	target.is_be_attacking = true
	target.interrupt_movement_for_control()
	if target.mr_player != null and target.mr_player.has_animation("hurt"):
		target.mr_player.play("hurt")
	call_deferred("_release_hit_stun", target, int(target.get_meta("bdqk_hit_stun_token")))


func _release_hit_stun(target: BaseMonster, token: int) -> void:
	await get_tree().create_timer(0.2, false).timeout
	if target == null or not is_instance_valid(target):
		return
	if int(target.get_meta("bdqk_hit_stun_token", 0)) != token:
		return
	target.is_be_attacking = false

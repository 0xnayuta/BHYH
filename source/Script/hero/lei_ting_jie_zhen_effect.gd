extends Node2D
class_name LeiTingJieZhenEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const FORMATION_FRAMES_PATH := "res://Art/hero_picture/role_5/lei_ting_jie_zhen/formation_spine/formation_frames.tres"
const LIGHTNING_FRAMES_PATH := "res://Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_frames.tres"
const EFFECT_DISTANCE := 170.0
const LIGHTNING_OFFSETS := [-70.0, 0.0, 70.0]
const DAMAGE_HIT_FRAMES := [10, 14, 18, 22, 26, 30, 34]
const DAMAGE_HALF_WIDTH := 250.0
const DAMAGE_HALF_HEIGHT := 230.0

static var _formation_frames: SpriteFrames
static var _lightning_frames: SpriteFrames

var owner_player: Node
var direction_right := true
var hit_data: Dictionary = {}
var _target_centered := false
var _target_center := Vector2.ZERO
var _formation: AnimatedSprite2D
var _lightnings: Array[AnimatedSprite2D] = []
var _next_damage_indices := [0, 0, 0]


static func prewarm_frames() -> void:
	_get_formation_frames()
	_get_lightning_frames()


static func clear_cached_frames() -> void:
	_formation_frames = null
	_lightning_frames = null


static func _get_formation_frames() -> SpriteFrames:
	if _formation_frames == null:
		_formation_frames = _load_frames(FORMATION_FRAMES_PATH)
	return _formation_frames


static func _get_lightning_frames() -> SpriteFrames:
	if _lightning_frames == null:
		_lightning_frames = _load_frames(LIGHTNING_FRAMES_PATH)
	return _lightning_frames


static func _load_frames(path: String) -> SpriteFrames:
	var frames := ResourceLoader.load(path, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE) as SpriteFrames
	assert(frames != null, "缺少构建期帧资源: " + path)
	return frames


func setup(player: Node, face_right: bool, data: Dictionary) -> void:
	owner_player = player
	direction_right = face_right
	hit_data = data.duplicate(true)


func setup_at_target(player: Node, face_right: bool, data: Dictionary, target_position: Vector2) -> void:
	setup(player, face_right, data)
	_target_centered = true
	_target_center = target_position


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = _target_center if _target_centered else owner_player.global_position
	var direction := 1.0 if direction_right else -1.0

	_formation = _create_animated_sprite(_get_formation_frames())
	_formation.position = Vector2(0.0, -85.0) if _target_centered else Vector2(160.0 * direction, -155.0)
	_formation.scale = Vector2(4.2, 4.2)
	_formation.flip_h = not direction_right
	_formation.z_index = 11
	add_child(_formation)

	for lightning_index in range(LIGHTNING_OFFSETS.size()):
		var lightning := _create_animated_sprite(_get_lightning_frames())
		var offset_x: float = LIGHTNING_OFFSETS[lightning_index]
		lightning.position = (
			Vector2(offset_x * direction, -5.0)
			if _target_centered
			else Vector2((EFFECT_DISTANCE + offset_x) * direction, -75.0)
		)
		lightning.scale = Vector2(2.6, 2.6)
		lightning.flip_h = direction_right if lightning_index == 2 else not direction_right
		lightning.z_index = 12 + lightning_index
		add_child(lightning)
		_lightnings.append(lightning)

	_formation.play("default")
	for lightning in _lightnings:
		lightning.play("default")
	_run_sequence()


func _process(_delta: float) -> void:
	if not _target_centered and owner_player != null and is_instance_valid(owner_player):
		global_position = owner_player.global_position
	for lightning_index in range(_lightnings.size()):
		var lightning := _lightnings[lightning_index]
		if lightning == null or not is_instance_valid(lightning):
			continue
		while (
			_next_damage_indices[lightning_index] < DAMAGE_HIT_FRAMES.size()
			and lightning.frame >= DAMAGE_HIT_FRAMES[_next_damage_indices[lightning_index]]
		):
			_damage_targets(LIGHTNING_OFFSETS[lightning_index])
			_next_damage_indices[lightning_index] += 1


func _create_animated_sprite(frames: SpriteFrames) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	return sprite


func _run_sequence() -> void:
	await _formation.animation_finished
	for lightning in _lightnings:
		if lightning != null and is_instance_valid(lightning) and lightning.is_playing():
			await lightning.animation_finished
	if _formation != null and is_instance_valid(_formation):
		_formation.sprite_frames = null
	for lightning in _lightnings:
		if lightning != null and is_instance_valid(lightning):
			lightning.sprite_frames = null
	queue_free()


func _damage_targets(lightning_offset: float) -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		return
	var level := owner_player.get_parent().get_parent()
	if level == null or not ("monster" in level) or level.monster == null:
		return
	var direction := 1.0 if direction_right else -1.0
	var center: Vector2
	if _target_centered:
		center = global_position + Vector2(lightning_offset * direction, 0.0)
	else:
		center = owner_player.global_position + Vector2((EFFECT_DISTANCE + lightning_offset) * direction, -70.0)
	for target in level.monster.get_children():
		if not _is_valid_target(target):
			continue
		var offset: Vector2 = target.global_position - center
		if absf(offset.x) <= DAMAGE_HALF_WIDTH and absf(offset.y) <= DAMAGE_HALF_HEIGHT:
			_apply_hit(target)


func _is_valid_target(target: Node) -> bool:
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
	var damage := int(target.get_role_last_hurt(owner_player))
	if damage > 0:
		target.hurt_reduce_hp(damage, owner_player)
		if MainSet.set_data["MonsterLittleBlood"]:
			if target.monster_blood_bar == null:
				target.monster_blood_bar = Global.add_monster_blood(
					target, Vector2(-30, -90), target.hp / float(target.max_hp), target.hp
				)
		target.role5_bullet(damage, owner_player)
		Global.total_role_hit += damage
		Global.total_mag_hit += damage
		Global.add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not target.is_miss and not target.is_boss_protecting():
			target.hurt_special_effect = Global.add_mr_hurt(target.pz, Vector2(0, 0))
		if not target.is_control_immune():
			_apply_hit_stun(target)
		if not role_props.is_ws_state:
			role_props.ws_value += int(hit_data.get("WSValue", 6))
	owner_player.hit_dic = old_hit_data
	target.unbind_role_damage_source(damage_source_state)


func _apply_hit_stun(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.is_control_immune():
		return
	target.set_meta("ltjz_hit_stun_token", Time.get_ticks_msec())
	target.is_be_attacking = true
	target.interrupt_movement_for_control()
	if target.mr_player != null and target.mr_player.has_animation("hurt"):
		target.mr_player.play("hurt")
	call_deferred("_release_hit_stun", target, int(target.get_meta("ltjz_hit_stun_token")))


func _release_hit_stun(target: BaseMonster, token: int) -> void:
	await get_tree().create_timer(0.2, false).timeout
	if target == null or not is_instance_valid(target):
		return
	if int(target.get_meta("ltjz_hit_stun_token", 0)) != token:
		return
	target.is_be_attacking = false

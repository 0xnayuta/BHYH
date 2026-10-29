extends Node2D
class_name BiLuoTianEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const CAST_FRAMES_PATH := "res://Art/hero_picture/role_4/bi_luo_tian/cast/cast_frames.tres"
const HIT_FRAMES_PATH := "res://Art/hero_picture/role_4/bi_luo_tian/hit/hit_frames.tres"
const HIT_COUNT := 6
const HIT_INTERVAL := 0.06
const FRONT_DISTANCE := 270.0
const HIT_EFFECT_SCALE := Vector2(3.0, 3.0)
const HIT_EFFECT_OFFSETS := [-90.0, 0.0, 90.0]
const HIT_EFFECT_Y := -200
const HIT_ZONE_HALF_WIDTH := 150.0
const HIT_ZONE_HALF_HEIGHT := 240.0

static var _cast_frames: SpriteFrames
static var _hit_frames: SpriteFrames

var owner_player: Node
var direction_right := true
var hit_data: Dictionary = {}
var _cast_sprite: AnimatedSprite2D
var _hit_sprite: AnimatedSprite2D
var _hit_sprites: Array[AnimatedSprite2D] = []


static func prewarm_frames() -> void:
	_get_cast_frames()
	_get_hit_frames()


static func clear_cached_frames() -> void:
	_cast_frames = null
	_hit_frames = null


static func _get_cast_frames() -> SpriteFrames:
	if _cast_frames == null:
		_cast_frames = _load_frames(CAST_FRAMES_PATH)
	return _cast_frames


static func _get_hit_frames() -> SpriteFrames:
	if _hit_frames == null:
		_hit_frames = _load_frames(HIT_FRAMES_PATH)
	return _hit_frames


static func _load_frames(path: String) -> SpriteFrames:
	var frames := ResourceLoader.load(path, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE) as SpriteFrames
	assert(frames != null, "缺少构建期帧资源: " + path)
	return frames


func setup(player: Node, face_right: bool, data: Dictionary) -> void:
	owner_player = player
	direction_right = face_right
	hit_data = data.duplicate(true)


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	_cast_sprite = _create_sprite(_get_cast_frames())
	add_child(_cast_sprite)
	var direction := 1.0 if direction_right else -1.0
	_cast_sprite.position = Vector2(-95.0 * direction, -70.0)
	_cast_sprite.flip_h = not direction_right
	_cast_sprite.z_index = -1
	for offset_x in HIT_EFFECT_OFFSETS:
		var hit_sprite := _create_sprite(_get_hit_frames())
		hit_sprite.position = Vector2((FRONT_DISTANCE + float(offset_x)) * direction, HIT_EFFECT_Y)
		hit_sprite.flip_h = not direction_right
		hit_sprite.scale = HIT_EFFECT_SCALE
		hit_sprite.z_index = 2
		hit_sprite.visible = false
		add_child(hit_sprite)
		_hit_sprites.append(hit_sprite)
	_hit_sprite = _hit_sprites[1]
	_run_sequence()


func _process(_delta: float) -> void:
	if owner_player != null and is_instance_valid(owner_player):
		global_position = owner_player.global_position


func _create_sprite(frames: SpriteFrames) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	return sprite


func _run_sequence() -> void:
	_cast_sprite.play("default")
	await _cast_sprite.animation_finished
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	_cast_sprite.visible = false
	for hit_sprite in _hit_sprites:
		hit_sprite.visible = true
		hit_sprite.play("default")
	_run_multihit_damage()
	await _hit_sprite.animation_finished
	if _cast_sprite != null and is_instance_valid(_cast_sprite):
		_cast_sprite.sprite_frames = null
	for hit_sprite in _hit_sprites:
		if hit_sprite != null and is_instance_valid(hit_sprite):
			hit_sprite.sprite_frames = null
	queue_free()


func _run_multihit_damage() -> void:
	for hit_index in range(HIT_COUNT):
		if owner_player == null or not is_instance_valid(owner_player):
			return
		_damage_targets_in_front()
		if hit_index < HIT_COUNT - 1:
			await get_tree().create_timer(HIT_INTERVAL, false).timeout


func _damage_targets_in_front() -> void:
	var level := owner_player.get_parent().get_parent()
	if level == null or not ("monster" in level) or level.monster == null:
		return
	var direction := 1.0 if direction_right else -1.0
	for offset_x in HIT_EFFECT_OFFSETS:
		var center: Vector2 = (
			owner_player.global_position + Vector2((FRONT_DISTANCE + float(offset_x)) * direction, -125.0)
		)
		for target in level.monster.get_children():
			if not _is_valid_target(target):
				continue
			var offset: Vector2 = target.global_position - center
			if absf(offset.x) > HIT_ZONE_HALF_WIDTH or absf(offset.y) > HIT_ZONE_HALF_HEIGHT:
				continue
			if direction_right and target.global_position.x < owner_player.global_position.x - 20.0:
				continue
			if not direction_right and target.global_position.x > owner_player.global_position.x + 20.0:
				continue
			_apply_hit(target)


func _is_valid_target(target: Node) -> bool:
	if target == null or not is_instance_valid(target) or not (target is BaseMonster):
		return false
	if target.hp <= 0 or target.no_target:
		return false
	if target.is_boss_protecting():
		return false
	if target is Monster138:
		return true
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return false
	if target.has_method("get") and target.get("is_summon") == true:
		return false
	return true


func _apply_hit(target: BaseMonster) -> void:
	var damage_source_state := target.bind_role_damage_source(owner_player as BaseHero)
	var old_hit_data: Dictionary = owner_player.hit_dic
	owner_player.hit_dic = hit_data
	var damage := int(target.get_role_last_hurt(owner_player))
	if damage > 0:
		target.hurt_reduce_hp(damage, owner_player)
		if target is Monster138:
			target.transfer_linked_damage(damage)
		if MainSet.set_data["MonsterLittleBlood"]:
			if target.monster_blood_bar == null:
				target.monster_blood_bar = Global.add_monster_blood(
					target, Vector2(-30, -90), target.hp / float(target.max_hp), target.hp
				)
		Global.total_role_hit += damage
		Global.total_mag_hit += damage
		Global.add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not target.is_miss and not target.is_boss_protecting():
			target.hurt_special_effect = Global.add_mr_hurt(target.pz, Vector2(0, 0))
		if not target.is_control_immune():
			_apply_hit_stun(target)
		if not target.is_boss_protecting():
			_apply_voodoo_if_learned(target)
		if not role_props.is_ws_state:
			role_props.ws_value += int(hit_data.get("WSValue", 4))
	owner_player.hit_dic = old_hit_data
	target.unbind_role_damage_source(damage_source_state)


func _apply_hit_stun(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.is_control_immune():
		return
	target.set_meta("blt_hit_stun_token", Time.get_ticks_msec())
	target.is_be_attacking = true
	target.interrupt_movement_for_control()
	if target.mr_player != null and target.mr_player.has_animation("hurt"):
		target.mr_player.play("hurt")
	call_deferred("_release_hit_stun", target, int(target.get_meta("blt_hit_stun_token")))


func _release_hit_stun(target: BaseMonster, token: int) -> void:
	await get_tree().create_timer(0.2, false).timeout
	if target == null or not is_instance_valid(target):
		return
	if int(target.get_meta("blt_hit_stun_token", 0)) != token:
		return
	target.is_be_attacking = false


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

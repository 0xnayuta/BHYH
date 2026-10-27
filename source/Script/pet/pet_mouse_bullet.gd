extends "res://Script/monster/monster_bullet.gd"
class_name PetMouseBullet

const EFFECT_FPS := 24.0
const BOOMERANG_DAMAGE_INTERVAL := 2.0 / EFFECT_FPS
const EFFECT_ROOT := "res://Art/pet/pet_mouse/effects"
const EFFECT_COUNTS := {
	"pet_mouse_1_bullet_1": 20,
	"pet_mouse_1_bullet_2": 25,
	"pet_mouse_1_bullet_2_layer": 25,
	"pet_mouse_1_bullet_3": 12,
	"aoyi_buff": 14,
}
const EFFECT_REGISTRATION := {
	"pet_mouse_1_bullet_1": Vector2(297.75, 27.5),
	"pet_mouse_1_bullet_2": Vector2(95.65, 76.2),
	"pet_mouse_1_bullet_3": Vector2(32.75, 34.0),
	"aoyi_buff": Vector2(87.0, 94.0),
}
const EFFECT_OFFSETS := {
	"pet_mouse_1_bullet_1": Vector2(-127.75, 0.0),
	"pet_mouse_1_bullet_2": Vector2(-14.15, -3.2),
	"pet_mouse_1_bullet_3": Vector2(5.25, 4.5),
	"aoyi_buff": Vector2(4.0, 0.5),
}
const DASH_LAYER_EFFECT := "pet_mouse_1_bullet_2_layer"
const DASH_LAYER_SPRITE_OFFSET := Vector2(25.5, 47.0)
const DASH_LAYER_TRANSFORMS := [
	Transform2D(Vector2(0.9411316, 0.0), Vector2(0.0, 0.9411316), Vector2(-11.95, -30.2)),
	Transform2D(Vector2(0.36018372, -0.8694763), Vector2(0.8694763, 0.36018372), Vector2(-43.35, -9.0)),
	Transform2D(Vector2(-0.572876, -0.7466583), Vector2(0.7466583, -0.572876), Vector2(-50.6, 48.25)),
]

static var _frames_cache: Dictionary = {}
static var _effect_rect_cache: Dictionary = {}

var _tick_accumulator := 0.0
var _effect_tick := 0
var _outbound_velocity := Vector2.ZERO
var _outbound_acceleration := Vector2.ZERO
var _returning := false
var _return_speed := 0.0
var _next_target_hit_tick: Dictionary = {}


static func clear_cached_frames() -> void:
	_frames_cache.clear()
	_effect_rect_cache.clear()


static func warm_pet_mouse_frames(pet_level: int) -> void:
	for effect_name in ["pet_mouse_1_bullet_1", "pet_mouse_1_bullet_2", DASH_LAYER_EFFECT]:
		_get_frames(effect_name)
	if pet_level >= 30:
		_get_frames("pet_mouse_1_bullet_3")
	if pet_level >= 50:
		_get_frames("aoyi_buff")


static func _get_frames(effect_name: String) -> SpriteFrames:
	if _frames_cache.has(effect_name):
		return _frames_cache[effect_name] as SpriteFrames
	var frames_path := EFFECT_ROOT.path_join(effect_name).path_join(effect_name + "_frames.tres")
	if not ResourceLoader.exists(frames_path):
		push_error("Pet effect frames missing: " + frames_path)
		return null
	var frames := load(frames_path) as SpriteFrames
	_frames_cache[effect_name] = frames
	return frames


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	if skill_name == "pet_mouse_1_bullet_2":
		z_index = 1
	var frames := _get_frames(skill_name)
	if frames.get_frame_count(skill_name) <= 0:
		queue_free()
		return
	bullet_ani.sprite_frames = frames
	bullet_ani.animation = skill_name
	bullet_ani.position = EFFECT_OFFSETS.get(skill_name, Vector2.ZERO)
	bullet_ani.play(skill_name)
	if skill_name == "pet_mouse_1_bullet_2":
		bullet_ani.visible = false
		_create_dash_layers()
	middle.scale.x = 1.0 if dir else -1.0
	if hit_box != null:
		hit_box.monitoring = false
	_outbound_velocity = get_meta("pet_mouse_velocity_tick", Vector2.ZERO) as Vector2
	_outbound_acceleration = get_meta("pet_mouse_acceleration_tick", Vector2.ZERO) as Vector2
	state = do


func _create_dash_layers() -> void:
	var layer_frames := _get_frames(DASH_LAYER_EFFECT)
	if layer_frames.get_frame_count(DASH_LAYER_EFFECT) <= 0:
		bullet_ani.visible = true
		return
	for layer_index in DASH_LAYER_TRANSFORMS.size():
		var holder := Node2D.new()
		holder.name = "DashLayer%d" % (layer_index + 1)
		holder.transform = DASH_LAYER_TRANSFORMS[layer_index]
		var sprite := AnimatedSprite2D.new()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.sprite_frames = layer_frames
		sprite.animation = DASH_LAYER_EFFECT
		sprite.position = DASH_LAYER_SPRITE_OFFSET
		holder.add_child(sprite)
		middle.add_child(holder)
		sprite.play(DASH_LAYER_EFFECT)


func _physics_process(delta: float) -> void:
	if skill_name == "aoyi_buff":
		_follow_summoner()
	_tick_accumulator += delta * EFFECT_FPS
	while _tick_accumulator >= 1.0 and not is_queued_for_deletion():
		_tick_accumulator -= 1.0
		_effect_tick += 1
		_process_effect_tick()


func _process_effect_tick() -> void:
	match skill_name:
		"pet_mouse_1_bullet_1":
			_apply_effect_damage(999)
			if _effect_tick >= 20:
				queue_free()
		"pet_mouse_1_bullet_2":
			_apply_effect_damage(5)
			if _effect_tick >= 24:
				queue_free()
		"pet_mouse_1_bullet_3":
			_move_boomerang()
			if not is_queued_for_deletion():
				_apply_effect_damage(4)
			if _effect_tick >= 240:
				queue_free()
		"aoyi_buff":
			if _effect_tick >= 14:
				queue_free()


func _move_boomerang() -> void:
	var owner := _summoner_2d()
	if owner == null:
		queue_free()
		return
	var return_target := owner.global_position + (get_meta("pet_mouse_return_offset", Vector2.ZERO) as Vector2)
	if not _returning:
		global_position += _outbound_velocity
		_outbound_velocity += _outbound_acceleration
		var moving_left := _outbound_acceleration.x > 0.0
		if moving_left and _outbound_velocity.x >= 0.0 or not moving_left and _outbound_velocity.x <= 0.0:
			_returning = true
			_return_speed = 1.0
	else:
		var distance := global_position.distance_to(return_target)
		if distance <= 30.0:
			queue_free()
			return
		_return_speed += 1.0
		global_position += global_position.direction_to(return_target) * minf(_return_speed, distance)


func _follow_summoner() -> void:
	var owner := _summoner_2d()
	if owner == null:
		queue_free()
		return
	global_position = owner.global_position + (get_meta("pet_mouse_follow_offset", Vector2.ZERO) as Vector2)


func _apply_effect_damage(interval_ticks: int) -> void:
	var local_rect := _current_effect_rect()
	if local_rect.size == Vector2.ZERO:
		return
	for target in _collect_targets(local_rect):
		var target_id := target.get_instance_id()
		if _effect_tick < int(_next_target_hit_tick.get(target_id, 0)):
			continue
		if _damage_target(target):
			_next_target_hit_tick[target_id] = _effect_tick + interval_ticks


func _current_effect_rect() -> Rect2:
	var cache_key := "%s:%d:%d" % [skill_name, bullet_ani.frame, 1 if dir else 0]
	if _effect_rect_cache.has(cache_key):
		return _effect_rect_cache[cache_key] as Rect2
	var texture := bullet_ani.sprite_frames.get_frame_texture(skill_name, bullet_ani.frame)
	if texture == null:
		return Rect2()
	var image := texture.get_image()
	if image == null or image.is_empty():
		return Rect2()
	var used := image.get_used_rect()
	if used.size == Vector2i.ZERO:
		return Rect2()
	var registration: Vector2 = EFFECT_REGISTRATION.get(skill_name, Vector2.ZERO)
	var rect := Rect2(Vector2(used.position) - registration, Vector2(used.size))
	if not dir:
		rect.position.x = -rect.end.x
	_effect_rect_cache[cache_key] = rect
	return rect


func _collect_targets(local_rect: Rect2) -> Array[BaseMonster]:
	var result: Array[BaseMonster] = []
	var world_rect := Rect2(global_position + local_rect.position, local_rect.size)
	var owner := _summoner_node()
	for node in _get_level_active_monster_candidates():
		if not (node is BaseMonster):
			continue
		var target := node as BaseMonster
		if target == owner or target.hp <= 0 or target.is_boss_protecting():
			continue
		if world_rect.intersects(_target_hurt_rect(target), true):
			result.append(target)
	return result


func _target_hurt_rect(target: BaseMonster) -> Rect2:
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape == null or hurt_shape.shape == null:
		return Rect2(target.global_position - Vector2(24, 45), Vector2(48, 90))
	var shape_rect := hurt_shape.shape.get_rect()
	var global_scale := hurt_shape.global_transform.get_scale().abs()
	var size := shape_rect.size * global_scale
	return Rect2(hurt_shape.global_position - size * 0.5, size)


func _damage_target(target: BaseMonster) -> bool:
	if not (att_list is Dictionary):
		return false
	var data: Dictionary = att_list
	var power := int(data.get("power", 0))
	if power <= 0:
		return false
	var attack_kind := str(data.get("attackKind", "physics"))
	var owner := _summoner_node()
	var damage_hit_count := maxi(1, int(data.get("damageHitCount", 1)))
	var hurt_back: Array = data.get("hurtBack", []) if data.get("hurtBack", []) is Array else []
	if skill_name == "pet_mouse_1_bullet_3" and damage_hit_count > 1:
		if target.hp <= 0 or target.is_boss_protecting():
			return false
		var first_actual_damage := 0
		var remaining_hits := 0
		for hit_index in range(damage_hit_count):
			first_actual_damage = _resolve_mouse_damage_hit(target, power, owner, attack_kind)
			if first_actual_damage > 0:
				remaining_hits = damage_hit_count - hit_index - 1
				break
		if first_actual_damage <= 0:
			return false
		_apply_mouse_hit_feedback(target, owner, hurt_back)
		if (
			remaining_hits <= 0
			or target.hp <= 0
			or owner == null
			or not owner.has_method("queue_mouse_boomerang_followup")
		):
			if owner != null and owner.has_method("on_mouse_boomerang_hit"):
				owner.call("on_mouse_boomerang_hit", first_actual_damage)
			return true
		owner.call(
			"queue_mouse_boomerang_followup",
			target,
			power,
			attack_kind,
			first_actual_damage,
			remaining_hits,
			BOOMERANG_DAMAGE_INTERVAL
		)
		return true

	var dealt_damage := false
	var total_actual_damage := 0
	for _hit_index in range(damage_hit_count):
		var actual := _resolve_mouse_damage_hit(target, power, owner, attack_kind)
		if actual > 0:
			dealt_damage = true
			total_actual_damage += actual
	if not dealt_damage:
		return false
	_apply_mouse_hit_feedback(target, owner, hurt_back)
	if skill_name == "pet_mouse_1_bullet_3" and owner != null and owner.has_method("on_mouse_boomerang_hit"):
		owner.call("on_mouse_boomerang_hit", total_actual_damage)
	if skill_name == "pet_mouse_1_bullet_2" and owner != null and owner.has_method("on_mouse_dash_hit"):
		owner.call("on_mouse_dash_hit", power)
	return true


func _resolve_mouse_damage_hit(target: BaseMonster, power: int, owner: Node, attack_kind: String) -> int:
	if not is_instance_valid(target) or target.hp <= 0 or target.is_boss_protecting():
		return 0
	var resolved := _pet_tiger_resolve_damage(target, power, owner, attack_kind)
	if resolved <= 0:
		return 0
	var remaining_hp := maxi(0, target.hp)
	var actual := target.reduce_pet_hp(resolved, attack_kind)
	return mini(actual, remaining_hp) if actual > 0 else 0


func _apply_mouse_hit_feedback(target: BaseMonster, owner: Node, hurt_back: Array) -> void:
	if not is_instance_valid(target):
		return
	_apply_pet_summon_knockback(target, owner, hurt_back)
	if target.has_method("play_hit_effect"):
		target.play_hit_effect(self)


func _summoner_node() -> Node:
	var owner_value = get_meta("summoner", null)
	if typeof(owner_value) == TYPE_OBJECT and is_instance_valid(owner_value):
		return owner_value as Node
	return null


func _summoner_2d() -> Node2D:
	return _summoner_node() as Node2D


func _on_hit_box_area_entered(_area: Area2D) -> void:
	pass

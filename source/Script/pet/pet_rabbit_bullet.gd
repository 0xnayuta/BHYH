extends "res://Script/monster/monster_bullet.gd"
class_name PetRabbitBullet

const EFFECT_FPS := 24.0
const EFFECT_ROOT := "res://Art/pet/pet_rabbit/effects"
const EFFECT_COUNTS := {
	"pet_pet_rabbit_bullet_1": 1,
	"pet_pet_rabbit_jf_buff": 16,
	"pet_pet_rabbit_bullet_4": 40,
	"pet_pet_rabbit_bullet_buff": 16,
	"pet_rabbit_4_aoyi_buff": 7,
	"monster_130_bullet_2": 30,
}
const EFFECT_ORIGIN_OFFSETS := {
	"pet_pet_rabbit_bullet_1": Vector2(6.5, -5.0),
	"pet_pet_rabbit_jf_buff": Vector2(-9.9, -1.5),
	"pet_pet_rabbit_bullet_4": Vector2(-171.45, 96.0),
	"pet_pet_rabbit_bullet_buff": Vector2(22.3, 64.0),
	"pet_rabbit_4_aoyi_buff": Vector2(-2.525, 1.875),
	"monster_130_bullet_2": Vector2(9.0, -20.5),
}
const RABBIT_ICE_REGISTRATION := Vector2(536.95, 2.0)

const MOONLIGHT_HIT_FRAMES := [5, 13, 21]

static var _frames_cache: Dictionary = {}
var _elapsed := 0.0
var _damage_done := false
var _travelled := 0.0
var _damaged_target_ids: Dictionary = {}
var _ice_frame_rect_cache: Dictionary = {}
var _moonlight_hit_index := 0


static func clear_cached_frames() -> void:
	_frames_cache.clear()


static func warm_pet_rabbit_frames(stage: int) -> void:
	var names := ["pet_pet_rabbit_bullet_1", "monster_130_bullet_2"]
	if stage >= 2:
		names.append("pet_pet_rabbit_jf_buff")
	if stage >= 3:
		names.append("pet_pet_rabbit_bullet_4")
		names.append("pet_pet_rabbit_bullet_buff")
	if stage >= 4:
		names.append("pet_rabbit_4_aoyi_buff")
	for effect_name in names:
		_get_frames(effect_name)


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
	var frames := _get_frames(skill_name)
	if frames.get_frame_count(skill_name) <= 0:
		queue_free()
		return
	bullet_ani.sprite_frames = frames
	bullet_ani.animation = skill_name
	bullet_ani.position = EFFECT_ORIGIN_OFFSETS.get(skill_name, Vector2.ZERO)
	bullet_ani.play(skill_name)
	middle.scale.x = 1.0 if dir else -1.0
	if hit_box != null:
		hit_box.monitoring = false
	state = do


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if bool(get_meta("pet_rabbit_follow", false)):
		_follow_summoner()
	if skill_name == "pet_pet_rabbit_bullet_1":
		var movement := 360.0 * delta
		global_position.x += -movement if dir else movement
		_travelled += movement
		if not _damage_done:
			_try_hit_projectile()
		if _travelled >= 600.0:
			queue_free()
			return
	elif _elapsed >= float(get_meta("pet_rabbit_damage_delay", 0.04)):
		if skill_name == "pet_pet_rabbit_bullet_4":
			_apply_area_damage()
		elif skill_name == "monster_130_bullet_2":
			while _moonlight_hit_index < MOONLIGHT_HIT_FRAMES.size():
				var hit_frame := int(MOONLIGHT_HIT_FRAMES[_moonlight_hit_index])
				var hit_time := float(hit_frame - 1) / EFFECT_FPS
				if _elapsed < hit_time:
					break

				_damaged_target_ids.clear()
				_apply_area_damage()
				_moonlight_hit_index += 1
		elif not _damage_done:
			_damage_done = true
			_apply_area_damage()
	var lifetime := float(get_meta("pet_rabbit_lifetime", 0.0))
	if lifetime <= 0.0:
		lifetime = maxf(0.08, float(EFFECT_COUNTS.get(skill_name, 1)) / EFFECT_FPS + 0.03)
	if _elapsed >= lifetime:
		queue_free()


func _follow_summoner() -> void:
	var owner_value = get_meta("summoner", null)
	if typeof(owner_value) != TYPE_OBJECT or not is_instance_valid(owner_value):
		queue_free()
		return
	var owner := owner_value as Node2D
	global_position = owner.global_position + (get_meta("pet_rabbit_follow_offset", Vector2.ZERO) as Vector2)


func _try_hit_projectile() -> void:
	for target in _collect_targets(Vector2(70, 70)):
		_damage_done = true
		_damage_target(target)
		_notify_summoner_hit(global_position)
		queue_free()
		return


func _apply_area_damage() -> void:
	if skill_name in ["pet_pet_rabbit_jf_buff", "pet_pet_rabbit_bullet_buff", "pet_rabbit_4_aoyi_buff"]:
		return
	var targets: Array[BaseMonster]
	if skill_name == "pet_pet_rabbit_bullet_4":
		var visual_rect := _current_ice_visual_rect()
		if visual_rect.size == Vector2.ZERO:
			return
		targets = _collect_targets_in_effect_rect(visual_rect)
	else:
		var hit_size: Vector2 = get_meta("pet_rabbit_hit_size", _default_hit_size())
		targets = _collect_targets(hit_size)
	var hit_any := false
	for target in targets:
		var target_id := target.get_instance_id()
		if _damaged_target_ids.has(target_id):
			continue
		var damaged := _damage_target(target)
		if damaged:
			_damaged_target_ids[target_id] = true
			hit_any = true
			if skill_name == "pet_pet_rabbit_bullet_4" and bool(get_meta("pet_rabbit_freeze", true)):
				_apply_freeze(target)
	if hit_any:
		_notify_summoner_hit(global_position)


func _default_hit_size() -> Vector2:
	match skill_name:
		"pet_pet_rabbit_bullet_4":
			return Vector2(500, 250)
		"monster_130_bullet_2":
			return Vector2(120, 220)
	return Vector2(90, 70)


func _damage_target(target: BaseMonster) -> bool:
	if typeof(att_list) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = att_list
	var damage := int(data.get("power", 0))
	if damage <= 0:
		return false
	var owner_value = get_meta("summoner", null)
	var owner: Node = (
		owner_value as Node if typeof(owner_value) == TYPE_OBJECT and is_instance_valid(owner_value) else null
	)

	var resolved := _pet_tiger_resolve_damage(target, damage, owner, "magic")
	if resolved <= 0:
		return false
	var actual := target.reduce_pet_hp(resolved, "magic")
	if actual <= 0:
		return false
	var hurt_back: Array = data.get("hurtBack", []) if data.get("hurtBack", []) is Array else []
	_apply_pet_summon_knockback(target, owner, hurt_back)
	if target.has_method("play_hit_effect"):
		target.play_hit_effect(self)
	return true


func _apply_freeze(target: BaseMonster) -> void:
	if target.has_method("is_control_immune") and target.call("is_control_immune"):
		return
	if target.buff != null:
		(
			Global
			. add_buff(
				target.buff,
				{
					"Name": "Ice",
					"AddTime": 2.0,
					"reduce_interval": 0,
					"value": 0,
					"LastTime": 2.0,
					"AttackKind": "",
					"DeBuff": true,
				}
			)
		)


func _notify_summoner_hit(hit_position: Vector2) -> void:
	if skill_name == "monster_130_bullet_2":
		return
	var owner_value = get_meta("summoner", null)
	if (
		typeof(owner_value) == TYPE_OBJECT
		and is_instance_valid(owner_value)
		and owner_value.has_method("on_rabbit_attack_hit")
	):
		owner_value.call("on_rabbit_attack_hit", hit_position)


func _collect_targets(hit_size: Vector2) -> Array[BaseMonster]:
	var result: Array[BaseMonster] = []
	var owner_value = get_meta("summoner", null)
	var owner: Node = (
		owner_value as Node if typeof(owner_value) == TYPE_OBJECT and is_instance_valid(owner_value) else null
	)
	for node in _get_level_active_monster_candidates():
		if not (node is BaseMonster):
			continue
		var target := node as BaseMonster
		if target == owner or target.hp <= 0 or target.is_boss_protecting():
			continue
		var point := target.global_position
		var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
		if hurt_shape != null:
			point = hurt_shape.global_position
		var delta := point - global_position
		if absf(delta.x) <= hit_size.x * 0.5 + 24.0 and absf(delta.y) <= hit_size.y * 0.5 + 45.0:
			result.append(target)
	return result


func _collect_targets_in_effect_rect(local_rect: Rect2) -> Array[BaseMonster]:
	var result: Array[BaseMonster] = []
	var world_rect := Rect2(global_position + local_rect.position, local_rect.size)
	var owner_value = get_meta("summoner", null)
	var owner: Node = (
		owner_value as Node if typeof(owner_value) == TYPE_OBJECT and is_instance_valid(owner_value) else null
	)
	for node in _get_level_active_monster_candidates():
		if not (node is BaseMonster):
			continue
		var target := node as BaseMonster
		if target == owner or target.hp <= 0 or target.is_boss_protecting():
			continue
		if world_rect.intersects(_target_hurt_rect(target), true):
			result.append(target)
	return result


func _current_ice_visual_rect() -> Rect2:
	var frame_index := bullet_ani.frame
	if _ice_frame_rect_cache.has(frame_index):
		return _ice_frame_rect_cache[frame_index] as Rect2
	var texture := bullet_ani.sprite_frames.get_frame_texture(skill_name, frame_index)
	if texture == null:
		return Rect2()
	var image := texture.get_image()
	if image == null or image.is_empty():
		return Rect2()
	var pixel_rect := image.get_used_rect()
	if pixel_rect.size == Vector2i.ZERO:
		_ice_frame_rect_cache[frame_index] = Rect2()
		return Rect2()
	var rect := Rect2(Vector2(pixel_rect.position) - RABBIT_ICE_REGISTRATION, Vector2(pixel_rect.size))
	if not dir:
		rect.position.x = -rect.end.x
	_ice_frame_rect_cache[frame_index] = rect
	return rect


func _target_hurt_rect(target: BaseMonster) -> Rect2:
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape == null or hurt_shape.shape == null:
		return Rect2(target.global_position - Vector2(24, 45), Vector2(48, 90))
	var local_rect: Rect2 = hurt_shape.shape.get_rect()
	var global_scale := hurt_shape.global_transform.get_scale().abs()
	var size := local_rect.size * global_scale
	return Rect2(hurt_shape.global_position - size * 0.5, size)


func _on_hit_box_area_entered(_area: Area2D) -> void:
	pass

extends "res://Script/monster/monster_bullet.gd"
class_name PetYinTigerBullet

const FPS := 24.0
const SECOND_HIT_DELAY := 0.12
const ROOT := "res://Art/pet/pet_yin_tiger/effects"
const COUNTS := {"pet_yin_tiger_1_bullet_1": 20, "pet_yin_tiger_1_bullet_2": 30, "pet_yin_tiger_1_bullet_3": 30}

const EFFECT_OFFSETS := {
	"pet_yin_tiger_1_bullet_1": Vector2(6.0, 0.0),
	"pet_yin_tiger_1_bullet_2": Vector2(-94.0, -25.0),
	"pet_yin_tiger_1_bullet_3": Vector2(-79.0, 0.0),
}
static var _frames_cache: Dictionary = {}
static var _rect_cache: Dictionary = {}
var _elapsed := 0.0
var _next_target_hit_tick: Dictionary = {}
var _pending_hits: Array[Dictionary] = []


static func clear_cached_frames() -> void:
	_frames_cache.clear()
	_rect_cache.clear()


static func warm_pet_yin_tiger_frames(stage: int) -> void:
	_get_frames("pet_yin_tiger_1_bullet_1")
	_get_frames("pet_yin_tiger_1_bullet_2")
	if stage >= 4:
		_get_frames("pet_yin_tiger_1_bullet_3")


static func _get_frames(effect_name: String) -> SpriteFrames:
	if _frames_cache.has(effect_name):
		return _frames_cache[effect_name] as SpriteFrames
	var frames_path := ROOT.path_join(effect_name).path_join(effect_name + "_frames.tres")
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
	bullet_ani.centered = true
	bullet_ani.position = EFFECT_OFFSETS.get(skill_name, Vector2.ZERO)
	bullet_ani.play(skill_name)
	middle.scale.x = 1.0 if dir else -1.0
	if hit_box != null:
		hit_box.monitoring = false
	state = do


func _physics_process(delta: float) -> void:
	_elapsed += delta
	_process_pending_hits()
	var tick := int(floor(_elapsed * FPS))

	var hit_tick := 3 if skill_name == "pet_yin_tiger_1_bullet_1" else 10
	var lifetime := float(COUNTS.get(skill_name, 1)) / FPS + 0.04
	if tick >= hit_tick and _elapsed < lifetime:
		_apply_damage()
	if _elapsed >= lifetime and _pending_hits.is_empty():
		queue_free()


func _process_pending_hits() -> void:
	for index in range(_pending_hits.size() - 1, -1, -1):
		var hit := _pending_hits[index]
		if _elapsed < float(hit["time"]):
			continue
		_pending_hits.remove_at(index)
		var target := (hit["target"] as WeakRef).get_ref() as BaseMonster
		var owner := (hit["owner"] as WeakRef).get_ref() as Node if hit["owner"] != null else null
		_deal_hit(target, int(hit["power"]), owner, str(hit["kind"]))


func _deal_hit(target: BaseMonster, power: int, owner: Node, attack_kind: String) -> int:
	if (
		not is_instance_valid(target)
		or target.is_queued_for_deletion()
		or target.hp <= 0
		or target.is_boss_protecting()
	):
		return 0
	var resolved := _pet_tiger_resolve_damage(target, power, owner, attack_kind)
	return target.reduce_pet_hp(resolved, attack_kind) if resolved > 0 else 0


func _apply_damage() -> void:
	if not (att_list is Dictionary):
		return
	var power := int(att_list.get("power", 0))
	if power <= 0:
		return
	var local_rect := _current_effect_rect()
	if local_rect.size == Vector2.ZERO:
		return
	var owner_value = get_meta("summoner", null)
	var owner: Node = (
		owner_value as Node if typeof(owner_value) == TYPE_OBJECT and is_instance_valid(owner_value) else null
	)
	var attack_kind := str(att_list.get("attackKind", "physics"))
	var interval := maxi(1, int(att_list.get("attackInterval", 10)))
	var world_rect := Rect2(global_position + local_rect.position, local_rect.size)
	var locked_target: Variant = get_meta("yin_tiger_locked_target") if has_meta("yin_tiger_locked_target") else null
	if locked_target == null and owner is BaseMonster:
		locked_target = owner.get("current_target")
	var locked_target_in_skill_range: bool = false
	if skill_name == "pet_yin_tiger_1_bullet_3" and owner is Node2D and locked_target is BaseMonster:
		locked_target_in_skill_range = (
			(owner as Node2D).global_position.distance_to((locked_target as BaseMonster).global_position) <= 300.0
		)
	var candidates: Array = _get_level_active_monster_candidates()

	if owner != null:
		if locked_target is BaseMonster and is_instance_valid(locked_target) and not candidates.has(locked_target):
			candidates.append(locked_target)
	for node in candidates:
		if not (node is BaseMonster):
			continue
		var target := node as BaseMonster
		if target == owner or target.hp <= 0 or target.is_boss_protecting():
			continue
		var hits_effect_area := world_rect.intersects(_target_hurt_rect(target), true)
		var hits_locked_skill_target: bool = locked_target_in_skill_range and target == locked_target
		if not hits_effect_area and not hits_locked_skill_target:
			continue
		var target_id := target.get_instance_id()
		if _elapsed * FPS < float(_next_target_hit_tick.get(target_id, -1)):
			continue
		var actual := _deal_hit(target, power, owner, attack_kind)
		if actual > 0:
			_next_target_hit_tick[target_id] = int(floor(_elapsed * FPS)) + interval
			if skill_name in ["pet_yin_tiger_1_bullet_2", "pet_yin_tiger_1_bullet_3"]:
				_pending_hits.append(
					{
						"time": _elapsed + SECOND_HIT_DELAY,
						"target": weakref(target),
						"owner": weakref(owner) if owner != null else null,
						"power": power,
						"kind": attack_kind
					}
				)
			_apply_pet_summon_knockback(target, owner, att_list.get("hurtBack", []))
			if target.has_method("play_hit_effect"):
				target.play_hit_effect(self)
			if skill_name == "pet_yin_tiger_1_bullet_2" and owner != null and owner.has_method("apply_stun_to_target"):
				owner.call("apply_stun_to_target", target, 2.0)


func _current_effect_rect() -> Rect2:
	var key := "%s:%d:%d" % [skill_name, bullet_ani.frame, 1 if dir else 0]
	if _rect_cache.has(key):
		return _rect_cache[key] as Rect2
	var texture := bullet_ani.sprite_frames.get_frame_texture(skill_name, bullet_ani.frame)
	if texture == null:
		return Rect2()
	var image := texture.get_image()
	if image == null or image.is_empty():
		return Rect2()
	var used := image.get_used_rect()
	if used.size == Vector2i.ZERO:
		return Rect2()
	var canvas := Vector2(texture.get_width(), texture.get_height())
	var rect := Rect2(
		EFFECT_OFFSETS.get(skill_name, Vector2.ZERO) + Vector2(used.position) - canvas * 0.5, Vector2(used.size)
	)
	if not dir:
		rect.position.x = -rect.end.x
	_rect_cache[key] = rect
	return rect


func _target_hurt_rect(target: BaseMonster) -> Rect2:
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape == null or hurt_shape.shape == null:
		return Rect2(target.global_position - Vector2(24, 45), Vector2(48, 90))
	var shape_rect := hurt_shape.shape.get_rect()
	var global_scale := hurt_shape.global_transform.get_scale().abs()
	var size := shape_rect.size * global_scale
	return Rect2(hurt_shape.global_position - size * 0.5, size)


func _on_hit_box_area_entered(_area: Area2D) -> void:
	pass

extends "res://Script/monster/monster_bullet.gd"
class_name PetNeatBullet

const FPS := 24.0
const ROOT := "res://Art/pet/pet_neat/effects"
const COUNTS := {"pet_neat_1_bullet_1": 20, "pet_neat_1_bullet_2": 1, "pet_neat_4_bullet_3": 22}
const ACTIVE_FRAME_END := {"pet_neat_1_bullet_1": 14, "pet_neat_1_bullet_2": 0, "pet_neat_4_bullet_3": 14}
const STOMP_DAMAGE_REPEAT_COUNT := 3
const STOMP_REPEAT_INTERVAL_TICKS := 2

const EFFECT_OFFSETS := {
	"pet_neat_1_bullet_1": Vector2(-53.5, 0.0),
	"pet_neat_1_bullet_2": Vector2(-27.5, -7.5),
	"pet_neat_4_bullet_3": Vector2(-1.5, -65.5),
}
static var _cache: Dictionary = {}
static var _effect_rect_cache: Dictionary = {}
static var _effect_union_cache: Dictionary = {}

static var _candidate_cache_frame := -1
static var _candidate_cache_scene_id := 0
static var _candidate_cache: Array = []
static var _target_rect_cache_frame := -1
static var _target_rect_cache: Dictionary = {}
var _elapsed := 0.0
var _damage_start_delay := 0.04
var _next_target_hit_tick: Dictionary = {}
var _pending_stomp_hits: Dictionary = {}


static func _frames_for(effect_name: String) -> SpriteFrames:
	if _cache.has(effect_name):
		return _cache[effect_name] as SpriteFrames
	var result := SpriteFrames.new()
	result.add_animation(effect_name)
	result.set_animation_speed(effect_name, FPS)
	result.set_animation_loop(effect_name, false)
	for index in range(1, int(COUNTS.get(effect_name, 0)) + 1):
		var texture := (
			ResourceLoader.load(
				ROOT.path_join(effect_name).path_join("%d.png" % index), "Texture2D", ResourceLoader.CACHE_MODE_REUSE
			)
			as Texture2D
		)
		if texture != null:
			if effect_name == "pet_neat_4_bullet_3":
				texture = _remove_blue_matte(texture)
			result.add_frame(effect_name, texture)
	if result.get_frame_count(effect_name) > 0:
		_cache[effect_name] = result
	return result


static func _remove_blue_matte(texture: Texture2D) -> Texture2D:
	var image := texture.get_image()
	if image == null or image.is_empty():
		return texture
	var changed := false
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a <= 0.001:
				continue

			if color.b > 0.78 and color.r < 0.16 and color.g < 0.24:
				image.set_pixel(x, y, Color(color.r, color.g, color.b, 0.0))
				changed = true
	return ImageTexture.create_from_image(image) if changed else texture


static func warm_pet_neat_frames(stage: int) -> void:
	_frames_for("pet_neat_1_bullet_1")
	_frames_for("pet_neat_1_bullet_2")
	if stage >= 4:
		_frames_for("pet_neat_4_bullet_3")


static func clear_cached_frames() -> void:
	_cache.clear()
	_effect_rect_cache.clear()
	_effect_union_cache.clear()
	_clear_target_query_caches()


static func _clear_target_query_caches() -> void:
	_candidate_cache_frame = -1
	_candidate_cache_scene_id = 0
	_candidate_cache.clear()
	_target_rect_cache_frame = -1
	_target_rect_cache.clear()


func _cached_neat_candidates() -> Array:
	var tree := get_tree()
	if tree == null:
		return []
	var scene := tree.current_scene
	var scene_id := scene.get_instance_id() if scene != null else 0
	var frame := Engine.get_physics_frames()
	if frame == _candidate_cache_frame and scene_id == _candidate_cache_scene_id:
		return _candidate_cache

	_candidate_cache_frame = frame
	_candidate_cache_scene_id = scene_id
	_candidate_cache.clear()
	var seen: Dictionary = {}
	for candidate in _get_level_active_monster_candidates():
		if candidate is BaseMonster and is_instance_valid(candidate):
			var candidate_id: int = candidate.get_instance_id()
			if not seen.has(candidate_id):
				seen[candidate_id] = true
				_candidate_cache.append(candidate)
	if scene != null and scene.has_node("Monster"):
		for candidate in _collect_neat_candidates(scene.get_node("Monster")):
			if candidate is BaseMonster and is_instance_valid(candidate):
				var candidate_id_2: int = candidate.get_instance_id()
				if not seen.has(candidate_id_2):
					seen[candidate_id_2] = true
					_candidate_cache.append(candidate)
	return _candidate_cache


static func effect_rect_for(effect_name: String, frame_index: int, face_left: bool) -> Rect2:
	var frames := _frames_for(effect_name)
	if not frames.has_animation(effect_name):
		return Rect2()
	var frame_count := frames.get_frame_count(effect_name)
	if frame_count <= 0:
		return Rect2()
	var frame := clampi(frame_index, 0, frame_count - 1)
	var cache_key := "%s:%d:%d" % [effect_name, frame, 1 if face_left else 0]
	if _effect_rect_cache.has(cache_key):
		return _effect_rect_cache[cache_key] as Rect2
	var texture := frames.get_frame_texture(effect_name, frame)
	var rect := _rect_for_texture(effect_name, texture, face_left)
	_effect_rect_cache[cache_key] = rect
	return rect


static func effect_union_rect(effect_name: String, face_left: bool) -> Rect2:
	var cache_key := "%s:%d" % [effect_name, 1 if face_left else 0]
	if _effect_union_cache.has(cache_key):
		return _effect_union_cache[cache_key] as Rect2
	var frames := _frames_for(effect_name)
	var frame_count := frames.get_frame_count(effect_name) if frames.has_animation(effect_name) else 0
	if frame_count <= 0:
		return Rect2()
	var last_frame := clampi(int(ACTIVE_FRAME_END.get(effect_name, frame_count - 1)), 0, frame_count - 1)
	var result := Rect2()
	var has_rect := false
	for frame in range(last_frame + 1):
		var rect := effect_rect_for(effect_name, frame, face_left)
		if rect.size == Vector2.ZERO:
			continue
		result = rect if not has_rect else result.merge(rect)
		has_rect = true
	if not has_rect:
		result = Rect2()
	_effect_union_cache[cache_key] = result
	return result


static func _rect_for_texture(effect_name: String, texture: Texture2D, face_left: bool) -> Rect2:
	if texture == null:
		return Rect2()
	var image := texture.get_image()
	if image == null or image.is_empty():
		return Rect2()
	var used := image.get_used_rect()
	if used.size == Vector2i.ZERO:
		return Rect2()
	var canvas_size := Vector2(texture.get_width(), texture.get_height())
	var rect := Rect2(
		EFFECT_OFFSETS.get(effect_name, Vector2.ZERO) + Vector2(used.position) - canvas_size * 0.5, Vector2(used.size)
	)
	if not face_left:
		rect.position.x = -rect.end.x
	return rect


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	var frames := _frames_for(skill_name)
	if frames.get_frame_count(skill_name) <= 0:
		queue_free()
		return
	bullet_ani.sprite_frames = frames
	bullet_ani.animation = skill_name
	bullet_ani.centered = true

	bullet_ani.position = EFFECT_OFFSETS.get(skill_name, Vector2.ZERO)
	bullet_ani.visible = true
	bullet_ani.z_as_relative = true
	bullet_ani.z_index = 1
	bullet_ani.play(skill_name)
	var effect_scale := maxf(0.01, float(get_meta("pet_neat_effect_scale", 1.0)))
	middle.scale = Vector2(effect_scale if dir else -effect_scale, effect_scale)
	if hit_box != null:
		hit_box.monitoring = false
		var shape := hit_box.get_node_or_null("Hit_Box") as CollisionShape2D
		if shape != null:
			shape.shape = RectangleShape2D.new()
			(shape.shape as RectangleShape2D).size = get_meta("pet_neat_hit_size", Vector2(220, 120))
	state = do


func _physics_process(delta: float) -> void:
	_sync_neat_follow()
	_elapsed += delta
	var normal_spawn_frame := skill_name == "pet_neat_1_bullet_1" and bullet_ani.frame <= 0
	var current_tick := int(floor(_elapsed * FPS))
	var active_end := int(ACTIVE_FRAME_END.get(skill_name, 999999))
	var damage_window_open := skill_name == "pet_neat_1_bullet_2" or current_tick <= active_end
	if _elapsed >= _damage_start_delay and not normal_spawn_frame and damage_window_open:
		_apply_damage()
	var lifetime := float(get_meta("pet_neat_lifetime", 0.0))
	if lifetime <= 0.0:
		lifetime = float(maxi(1, bullet_ani.sprite_frames.get_frame_count(skill_name))) / FPS + 0.04
	if _elapsed >= lifetime:
		queue_free()


func _apply_damage() -> void:
	if not (att_list is Dictionary):
		return
	var power := int(att_list.get("power", 0))
	if power <= 0:
		return
	var owner_value = get_meta("summoner", null)
	var owner: Node = (
		owner_value as Node if typeof(owner_value) == TYPE_OBJECT and is_instance_valid(owner_value) else null
	)
	var attack_kind := str(att_list.get("attackKind", "physics"))
	var current_tick := maxi(0, int(floor(_elapsed * FPS)))
	var attack_interval := maxi(1, int(att_list.get("attackInterval", 999)))
	if skill_name == "pet_neat_4_bullet_3":
		_process_pending_stomp_hits(current_tick, owner, power, attack_kind, attack_interval)
	var effect_rect := _current_effect_rect()
	if effect_rect.size == Vector2.ZERO:
		return
	var world_effect_rect := Rect2(global_position + effect_rect.position, effect_rect.size)
	var candidates: Array = _cached_neat_candidates()
	for node in candidates:
		if not (node is BaseMonster):
			continue
		var target := node as BaseMonster
		if target == owner or target.hp <= 0 or target.is_boss_protecting():
			continue
		if not world_effect_rect.intersects(_cached_target_hurt_rect(target), true):
			continue
		var target_id := target.get_instance_id()
		if skill_name == "pet_neat_4_bullet_3" and _pending_stomp_hits.has(target_id):
			continue
		if current_tick < int(_next_target_hit_tick.get(target_id, -1)):
			continue
		var resolved := _pet_tiger_resolve_damage(target, power, owner, attack_kind)
		if resolved <= 0:
			continue
		var actual := target.reduce_pet_hp(resolved, attack_kind)
		if actual > 0 and owner != null and owner.has_method("on_neat_damage"):
			owner.call("on_neat_damage", actual)
		if actual > 0:
			if skill_name == "pet_neat_4_bullet_3":
				_pending_stomp_hits[target_id] = {
					"target": target,
					"remaining": STOMP_DAMAGE_REPEAT_COUNT - 1,
					"next_tick": current_tick + STOMP_REPEAT_INTERVAL_TICKS
				}
				_next_target_hit_tick[target_id] = current_tick + attack_interval
				if owner != null and owner.has_method("apply_stun_to_target"):
					owner.call("apply_stun_to_target", target, 3.0)
				if owner != null and owner.has_method("apply_defense_reduce_to_target"):
					owner.call("apply_defense_reduce_to_target", target, 5.0, 0.5)
			else:
				_next_target_hit_tick[target_id] = current_tick + attack_interval
			_apply_pet_summon_knockback(target, owner, att_list.get("hurtBack", []))
			if target.has_method("play_hit_effect"):
				target.play_hit_effect(self)


func _process_pending_stomp_hits(
	current_tick: int, owner: Node, power: int, attack_kind: String, attack_interval: int
) -> void:
	for target_id in _pending_stomp_hits.keys().duplicate():
		var state_value: Variant = _pending_stomp_hits.get(target_id, {})
		var state: Dictionary = state_value if state_value is Dictionary else {}
		var target := state.get("target", null) as BaseMonster
		if target == null or not is_instance_valid(target) or target.hp <= 0:
			_pending_stomp_hits.erase(target_id)
			continue
		if current_tick < int(state.get("next_tick", 0)):
			continue
		var resolved := _pet_tiger_resolve_damage(target, power, owner, attack_kind)
		if resolved > 0:
			var actual := target.reduce_pet_hp(resolved, attack_kind)
			if actual > 0 and owner != null and owner.has_method("on_neat_damage"):
				owner.call("on_neat_damage", actual)
			if actual > 0 and target.has_method("play_hit_effect"):
				target.play_hit_effect(self)
		var remaining := int(state.get("remaining", 0)) - 1
		if remaining <= 0:
			_pending_stomp_hits.erase(target_id)
		else:
			state["remaining"] = remaining
			state["next_tick"] = current_tick + STOMP_REPEAT_INTERVAL_TICKS
			_pending_stomp_hits[target_id] = state


func _current_effect_rect() -> Rect2:
	var rect := effect_rect_for(skill_name, bullet_ani.frame, dir)
	var effect_scale := maxf(0.01, float(get_meta("pet_neat_effect_scale", 1.0)))
	return Rect2(rect.position * effect_scale, rect.size * effect_scale)


func _target_hurt_rect(target: BaseMonster) -> Rect2:
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape == null or hurt_shape.shape == null:
		return Rect2(target.global_position - Vector2(24, 45), Vector2(48, 90))
	var shape_rect := hurt_shape.shape.get_rect()
	var global_scale := hurt_shape.global_transform.get_scale().abs()
	var size := shape_rect.size * global_scale
	return Rect2(hurt_shape.global_position - size * 0.5, size)


func _cached_target_hurt_rect(target: BaseMonster) -> Rect2:
	if target == null or not is_instance_valid(target):
		return Rect2()
	var frame := Engine.get_physics_frames()
	if frame != _target_rect_cache_frame:
		_target_rect_cache_frame = frame
		_target_rect_cache.clear()
	var target_id := target.get_instance_id()
	if _target_rect_cache.has(target_id):
		return _target_rect_cache[target_id] as Rect2
	var rect := _target_hurt_rect(target)
	_target_rect_cache[target_id] = rect
	return rect


func _collect_neat_candidates(node: Node) -> Array:
	var result: Array = []
	if node is BaseMonster:
		result.append(node)
	for child in node.get_children():
		result.append_array(_collect_neat_candidates(child))
	return result


func _sync_neat_follow() -> void:
	if skill_name != "pet_neat_1_bullet_2" or not bool(get_meta("pet_neat_follow", false)):
		return
	var owner_value = get_meta("summoner", null)
	if typeof(owner_value) != TYPE_OBJECT or not is_instance_valid(owner_value):
		queue_free()
		return
	var owner := owner_value as Node2D
	if owner == null:
		queue_free()
		return
	global_position = owner.global_position
	if middle != null:
		dir = bool(owner.get("monster_direction"))
		middle.scale.x = 1.0 if dir else -1.0

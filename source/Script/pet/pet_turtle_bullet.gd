extends "res://Script/monster/monster_bullet.gd"
class_name PetTurtleBullet

const TURTLE_EFFECT_FPS := 24.0
const TURTLE_EFFECT_DIR := "res://Art/pet/pet_turtle/effects"
const TURTLE_EFFECT_FRAME_COUNTS := {
	"pet_turtle_1_bullet_1": 15,
	"pet_turtle_1_bullet_2": 30,
	"pet_turtle_2_buff": 1,
	"pet_turtle_2_bullet_1": 12,
	"pet_turtle_3_bullet_3": 18,
}

static var _turtle_frames_cache: Dictionary = {}

var _turtle_elapsed := 0.0
var _turtle_damage_elapsed := 0.0
var _turtle_repeat_elapsed := 0.0
var _turtle_damage_applied := false
var _turtle_repeat_hits_done := 0


static func clear_cached_frames() -> void:
	_turtle_frames_cache.clear()


static func _effect_names(stage: int) -> Array[String]:
	stage = clampi(stage, 1, 4)
	var names: Array[String] = ["pet_turtle_1_bullet_1", "pet_turtle_1_bullet_2"]
	if stage >= 2:
		names.append("pet_turtle_2_bullet_1")
		names.append("pet_turtle_2_buff")
	if stage >= 3:
		names.append("pet_turtle_3_bullet_3")
	return names


static func _frame_paths(effect_name: String) -> Array[String]:
	var result: Array[String] = []
	var directory := TURTLE_EFFECT_DIR.path_join(effect_name)
	var frame_count := int(TURTLE_EFFECT_FRAME_COUNTS.get(effect_name, 0))
	for frame_index in range(1, frame_count + 1):
		result.append(directory.path_join(str(frame_index) + ".png"))
	return result


static func _get_effect_frames(effect_name: String) -> SpriteFrames:
	if _turtle_frames_cache.has(effect_name):
		return _turtle_frames_cache[effect_name] as SpriteFrames
	var frames := SpriteFrames.new()
	frames.add_animation(effect_name)
	frames.set_animation_speed(effect_name, TURTLE_EFFECT_FPS)
	frames.set_animation_loop(effect_name, effect_name == "pet_turtle_3_bullet_3")
	for texture_path in _frame_paths(effect_name):
		var texture := ResourceLoader.load(texture_path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
		if texture != null:
			texture.get_rid()
			frames.add_frame(effect_name, texture)
	if frames.get_frame_count(effect_name) > 0:
		_turtle_frames_cache[effect_name] = frames
	else:
		push_error("Pet turtle effect has no loadable frames: %s" % effect_name)
	return frames


static func warm_pet_turtle_frames(stage: int) -> void:
	for effect_name in _effect_names(stage):
		_get_effect_frames(effect_name)


static func prewarm_pet_turtle_runtime(stage: int, bullet_scene: PackedScene = null) -> void:
	warm_pet_turtle_frames(stage)
	if bullet_scene == null:
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var warm_root := Node2D.new()
	warm_root.name = "PetTurtleBulletPrewarm"
	warm_root.process_mode = Node.PROCESS_MODE_DISABLED
	warm_root.z_index = -4096
	warm_root.modulate = Color(1.0, 1.0, 1.0, 0.001)
	tree.root.add_child(warm_root)
	for effect_name in _effect_names(stage):
		if effect_name == "pet_turtle_2_buff":
			continue
		var instance = bullet_scene.instantiate()
		if instance == null:
			continue
		instance.att_list = {"power": 0, "attackKind": "physics", "hurtBack": [0, 0]}
		instance.hit_name = "__prewarm__"
		instance.skill_name = effect_name
		instance.dir = false
		instance.speed = 1.0
		instance.process_mode = Node.PROCESS_MODE_DISABLED
		instance.set_meta("pet_turtle_disabled", true)
		warm_root.add_child(instance)
	await tree.process_frame
	await tree.process_frame
	if is_instance_valid(warm_root):
		warm_root.free()


func _ready() -> void:
	_ensure_timer_signals()
	set_meta("is_monster_bullet", true)
	get_prop()
	_setup_turtle_direction()
	_setup_turtle_hit_shape()
	var frames := _get_effect_frames(skill_name)
	if frames.get_frame_count(skill_name) <= 0:
		queue_free()
		return
	bullet_ani.sprite_frames = frames
	bullet_ani.animation = skill_name
	bullet_ani.position = Vector2(0, 10) if skill_name == "pet_turtle_1_bullet_1" else Vector2.ZERO
	bullet_ani.scale = Vector2.ONE
	bullet_ani.self_modulate = Color.WHITE
	bullet_ani.visible = true
	bullet_ani.play(skill_name)
	if hit_box != null:
		hit_box.monitoring = false
	state = do


func _physics_process(delta: float) -> void:
	_sync_turtle_follow()
	if is_queued_for_deletion():
		return
	_turtle_elapsed += delta
	_turtle_damage_elapsed += delta
	if not bool(get_meta("pet_turtle_disabled", false)):
		var repeat_duration := maxf(0.0, float(get_meta("pet_turtle_repeat_duration", 0.0)))
		var repeat_count := maxi(0, int(get_meta("pet_turtle_repeat_count", 0)))
		if repeat_duration > 0.0 or repeat_count > 0:
			_process_repeat_damage(delta, repeat_duration, repeat_count)
		elif not _turtle_damage_applied and _turtle_damage_elapsed >= float(get_meta("pet_turtle_damage_delay", 0.04)):
			_turtle_damage_applied = true
			_apply_turtle_damage()
	var lifetime := float(get_meta("pet_turtle_lifetime", 0.0))
	if lifetime <= 0.0:
		lifetime = float(bullet_ani.sprite_frames.get_frame_count(skill_name)) / TURTLE_EFFECT_FPS + 0.02
	if _turtle_elapsed >= lifetime:
		queue_free()


func _process_repeat_damage(delta: float, repeat_duration: float, repeat_count: int) -> void:
	if repeat_count > 0 and _turtle_repeat_hits_done >= repeat_count:
		return
	if repeat_duration > 0.0 and _turtle_elapsed > repeat_duration:
		return
	_turtle_repeat_elapsed += delta
	var interval := maxf(0.05, float(get_meta("pet_turtle_repeat_interval", 1.0)))
	if not _turtle_damage_applied:
		if _turtle_damage_elapsed < float(get_meta("pet_turtle_damage_delay", 0.04)):
			return
		_turtle_damage_applied = true
		_turtle_repeat_elapsed = 0.0
		_turtle_repeat_hits_done += 1
		_apply_turtle_damage()
		return
	while _turtle_repeat_elapsed >= interval and (repeat_count <= 0 or _turtle_repeat_hits_done < repeat_count):
		_turtle_repeat_elapsed -= interval
		_turtle_repeat_hits_done += 1
		_apply_turtle_damage()


func _setup_turtle_direction() -> void:
	if middle != null:
		middle.scale.x = 1.0 if dir else -1.0


func _sync_turtle_follow() -> void:
	if not bool(get_meta("pet_turtle_follow_self", false)):
		return
	var source_value = get_meta("summoner", null)
	if typeof(source_value) != TYPE_OBJECT or not is_instance_valid(source_value):
		queue_free()
		return
	var source := source_value as Node2D
	if source == null:
		queue_free()
		return
	var follow_offset: Vector2 = get_meta("pet_turtle_follow_offset", Vector2.ZERO)
	global_position = source.global_position + follow_offset
	var source_faces_left := bool(source.get("monster_direction"))
	if source_faces_left != dir:
		dir = source_faces_left
		_setup_turtle_direction()


func _setup_turtle_hit_shape() -> void:
	var collision := hit_box.get_node_or_null("Hit_Box") as CollisionShape2D if hit_box != null else null
	if collision == null:
		return
	var shape := RectangleShape2D.new()
	shape.size = get_meta("pet_turtle_hit_size", _default_turtle_hit_size()) as Vector2
	collision.shape = shape
	collision.position = Vector2.ZERO


func _default_turtle_hit_size() -> Vector2:
	match skill_name:
		"pet_turtle_1_bullet_1":
			return Vector2(190, 82)
		"pet_turtle_2_bullet_1":
			return Vector2(108, 128)
		"pet_turtle_1_bullet_2":
			return Vector2(500, 340)
		"pet_turtle_3_bullet_3":
			return Vector2(560, 170)
	return Vector2(160, 100)


func _apply_turtle_damage() -> void:
	if typeof(att_list) != TYPE_DICTIONARY:
		return
	var hit_data: Dictionary = att_list
	var damage := int(hit_data.get("power", 0))
	if damage <= 0:
		return
	var attack_kind := str(hit_data.get("attackKind", "physics"))
	var summon_owner_value = get_meta("summoner", null)
	var summon_owner: Node = (
		summon_owner_value as Node
		if typeof(summon_owner_value) == TYPE_OBJECT and is_instance_valid(summon_owner_value)
		else null
	)
	var hurt_back: Array = hit_data.get("hurtBack", []) if hit_data.get("hurtBack", []) is Array else []
	if hit_name != "hit1":
		hurt_back = []
	for target in _collect_turtle_targets(summon_owner):
		var resolved_damage := _pet_tiger_resolve_damage(target, damage, summon_owner, attack_kind)
		if resolved_damage <= 0:
			continue
		var actual_damage := target.reduce_pet_hp(resolved_damage, attack_kind)
		if actual_damage > 0:
			if hit_name == "hit2" and summon_owner != null and summon_owner.has_method("heal_from_water_shield_damage"):
				summon_owner.call("heal_from_water_shield_damage", actual_damage)
			_apply_pet_summon_knockback(target, summon_owner, hurt_back)
			if target.has_method("play_hit_effect"):
				target.play_hit_effect(self)


func _collect_turtle_targets(summon_owner: Node) -> Array[BaseMonster]:
	var targets: Array[BaseMonster] = []
	var seen: Dictionary = {}
	var hit_size: Vector2 = get_meta("pet_turtle_hit_size", _default_turtle_hit_size())
	for node in _get_level_active_monster_candidates():
		_try_add_turtle_target(node, summon_owner, hit_size, targets, seen)
	var tree := get_tree()
	var scene := tree.current_scene if tree != null else null
	if targets.is_empty() and scene != null and scene.has_node("Monster"):
		_collect_turtle_targets_recursive(scene.get_node("Monster"), summon_owner, hit_size, targets, seen)
	return targets


func _collect_turtle_targets_recursive(
	node: Node, summon_owner: Node, hit_size: Vector2, targets: Array[BaseMonster], seen: Dictionary
) -> void:
	if node == null:
		return
	_try_add_turtle_target(node, summon_owner, hit_size, targets, seen)
	for child in node.get_children():
		_collect_turtle_targets_recursive(child, summon_owner, hit_size, targets, seen)


func _try_add_turtle_target(
	node: Node, summon_owner: Node, hit_size: Vector2, targets: Array[BaseMonster], seen: Dictionary
) -> void:
	if not (node is BaseMonster):
		return
	var target := node as BaseMonster
	if target == summon_owner or target.hp <= 0 or target.is_boss_protecting():
		return
	var instance_id := target.get_instance_id()
	if seen.has(instance_id):
		return
	var target_position := target.global_position
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape != null:
		target_position = hurt_shape.global_position
	var local_delta := target_position - global_position
	if absf(local_delta.x) > hit_size.x * 0.5 + 28.0 or absf(local_delta.y) > hit_size.y * 0.5 + 48.0:
		return
	targets.append(target)
	seen[instance_id] = true


func _on_hit_box_area_entered(_area: Area2D) -> void:
	pass

extends "res://Script/pet/pet_nian_effect.gd"

const FLIGHT_SECONDS := 1.8
const FIELD_SECONDS := 2.0
var stage := 4
var field_active := false
var _flight_age := 0.0
var _field_age := 0.0
var _pull_shape := CircleShape2D.new()


func _ready() -> void:
	hit_interval = 0.3
	super._ready()
	duration = FLIGHT_SECONDS + FIELD_SECONDS if stage == 4 else FLIGHT_SECONDS
	_pull_shape.radius = 90.0 if stage == 3 else 115.0


func _physics_process(delta: float) -> void:
	if not is_instance_valid(summoner) or summoner.hp <= 0:
		queue_free()
		return
	if not field_active:
		var flight_delta := minf(delta, maxf(0.0, FLIGHT_SECONDS - _flight_age))
		_flight_age += flight_delta
		super._physics_process(flight_delta)
		if stage >= 3:
			_pull_targets()
		if stage == 4 and _flight_age >= FLIGHT_SECONDS:
			_begin_gravity_field()
	else:
		_field_age += delta
		elapsed += delta
		visual.set_time("attack", fmod(_field_age, float(visual.get_frame_count("attack")) / 30.0))
		_pull_targets()
		if _field_age >= FIELD_SECONDS:
			queue_free()


func _begin_gravity_field() -> void:
	field_active = true
	speed = 0.0
	flight_velocity = Vector2.ZERO
	hurt_back.clear()
	if is_instance_valid(_screen_overlay):
		_screen_overlay.get_parent().remove_child(_screen_overlay)
		_screen_overlay.queue_free()
	for child in visual.get_children():
		if child is BackBufferCopy:
			child.queue_free()
	visual.part_index = -1
	visual.load_set("nianshou4_effect1_2")
	visual.rotation = 0.0
	visual.scale = Vector2.ONE
	visual.set_pose("attack", 0)


func _pull_targets() -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _pull_shape
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = 3088
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var seen: Dictionary = {}
	for contact: Dictionary in get_world_2d().direct_space_state.intersect_shape(query, 256):
		var target: Node = contact.collider
		while target != null and not target is BaseMonster:
			target = target.get_parent()
		if (
			not target is BaseMonster
			or target == summoner
			or target is SummonBaseMonster
			or target.hp <= 0
			or seen.has(target.get_instance_id())
		):
			continue
		seen[target.get_instance_id()] = true
		if field_active:
			_try_damage_target(target)
		if target.hp <= 0 or target.is_control_immune():
			continue
		var hurt: Node2D = target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox")
		var center: Vector2 = hurt.global_position if hurt != null else target.global_position
		target.begin_friendly_knockback_lock(0.16)
		target.velocity.x = clampf((global_position.x - center.x) * 8.0, -180.0, 180.0)

extends Node2D

var summoner: SummonBaseMonster
var bank := ""
var power := 1
var speed := 0.0
var hit_size := Vector2(180, 120)
var elapsed := 0.0
var duration := 0.8
var direction := 1.0
var targets: Dictionary = {}
var visual: Node2D
var action := "attack"
var embedded_beam := false
var extra_banks: Array = []
var extra_visuals: Array[Node2D] = []
var hits_per_target := 1
var hurt_back: Array = []
var hit_interval := 0.0
var _last_hit_times: Dictionary = {}
var flight_velocity := Vector2.ZERO
var hit_offset := Vector2.ZERO
var _screen_overlay: Node2D
var initial_stun_duration := 0.0
var initial_stun_window := 0.2


func _ready() -> void:
	visual = Node2D.new()
	visual.set_script(preload("res://Script/pet/pet_nian_parts.gd"))
	add_child(visual)
	if bank.ends_with("_effect1"):
		var screen_material := ShaderMaterial.new()
		screen_material.shader = preload("res://Shader/pet_nian_screen_blend.gdshader")
		visual.material = screen_material
	visual.scale = Vector2(direction, 1.0)
	if visual.load_set(bank):
		if bank.ends_with("_effect1") and visual.max_parts > 1:
			visual.part_index = 0
			var copy := BackBufferCopy.new()
			copy.copy_mode = BackBufferCopy.COPY_MODE_RECT
			var copy_bounds := Rect2()
			for index in range(0, visual._poses.size(), 9):
				var region: Rect2 = visual._regions[int(visual._poses[index])]
				var pose := Transform2D(
					Vector2(visual._poses[index + 1], visual._poses[index + 2]),
					Vector2(visual._poses[index + 3], visual._poses[index + 4]),
					Vector2(visual._poses[index + 5], visual._poses[index + 6])
				)
				var bounds: Rect2 = pose * Rect2(Vector2.ZERO, region.size)
				copy_bounds = bounds if not copy_bounds.has_area() else copy_bounds.merge(bounds)
			copy.rect = copy_bounds.grow(2)
			visual.add_child(copy)
			_screen_overlay = preload("res://Script/pet/pet_nian_parts.gd").new()
			_screen_overlay.material = visual.material
			_screen_overlay.part_index = 1
			visual.add_child(_screen_overlay)
			_screen_overlay.load_set(bank)
			_screen_overlay.set_pose(action, 0)
		duration = maxf(0.1, float(visual.get_frame_count(action)) / 30.0)
		visual.set_pose(action, 0)
		visual.visible = not embedded_beam
		if speed > 0.0:
			duration = 1.8
	for extra_bank: String in extra_banks:
		var extra := preload("res://Script/pet/pet_nian_parts.gd").new()
		add_child(extra)
		extra.scale = Vector2(direction, 1)
		if extra.load_set(extra_bank):
			extra.set_pose("attack", 0)
			extra_visuals.append(extra)
			duration = maxf(duration, float(extra.get_frame_count("attack")) / 30.0)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(summoner) or summoner.hp <= 0:
		queue_free()
		return
	elapsed += delta
	var previous := global_position
	if speed > 0.0 and flight_velocity == Vector2.ZERO and elapsed <= delta:
		previous.x = summoner.global_position.x
	if flight_velocity != Vector2.ZERO:
		global_position += flight_velocity * delta
	else:
		global_position.x += speed * direction * delta
	var visual_time := fmod(elapsed, float(visual.get_frame_count(action)) / 30.0) if speed > 0.0 else elapsed
	visual.set_time(action, visual_time)
	if is_instance_valid(_screen_overlay):
		_screen_overlay.set_time(action, visual_time)
	for extra in extra_visuals:
		extra.set_time("attack", elapsed)
		extra.visible = elapsed < float(extra.get_frame_count("attack")) / 30.0
	var hit_center := (global_position + previous) * 0.5 + hit_offset
	var query_size := hit_size + (global_position - previous).abs()
	var query_angle := 0.0
	if embedded_beam:
		var sample: Dictionary = visual.beam_sample()
		if sample.is_empty():
			if elapsed >= duration:
				queue_free()
			return
		var pose: Transform2D = visual.global_transform * sample.transform
		var region: Rect2 = sample.region
		hit_center = pose * (region.size * 0.5)
		query_size = Vector2(pose.x.length() * region.size.x, pose.y.length() * region.size.y)
		query_angle = pose.x.angle()
	var shape := RectangleShape2D.new()
	shape.size = query_size
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(query_angle, hit_center)
	query.collision_mask = 3088
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for contact: Dictionary in get_world_2d().direct_space_state.intersect_shape(query, 256):
		var target: Node = contact.collider
		while target != null and not target is BaseMonster:
			target = target.get_parent()
		if not target is BaseMonster or target == summoner or target is SummonBaseMonster or target.hp <= 0:
			continue
		_try_damage_target(target)
	if elapsed >= duration:
		queue_free()


func _try_damage_target(target: BaseMonster, segment_index: int = 0) -> void:
	var target_id := target.get_instance_id()
	var key := target_id * 4 + segment_index
	if hit_interval <= 0.0:
		if targets.has(target_id):
			return
	elif elapsed - float(_last_hit_times.get(key, -INF)) < hit_interval - 1e-06:
		return
	var previous_hits := int(targets.get(target_id, 0))
	_damage_target(target)
	if int(targets.get(target_id, 0)) > previous_hits:
		_last_hit_times[key] = elapsed
		if (
			previous_hits == 0
			and initial_stun_duration > 0.0
			and elapsed <= initial_stun_window
			and target.hp > 0
			and not target.is_control_immune()
		):
			summoner.apply_stun_to_target(target, initial_stun_duration)


func _damage_target(target: BaseMonster) -> void:
	var hits := 0
	for hit_index in range(hits_per_target):
		if target.hp <= 0:
			break
		var damage: int = target.resolve_friendly_damage(power, "magic", summoner)
		if damage > 0 and target.reduce_pet_hp(damage, "magic") > 0:
			hits += 1
			target.play_hit_effect(self)
	if hits > 0:
		targets[target.get_instance_id()] = int(targets.get(target.get_instance_id(), 0)) + hits
		if hurt_back.size() >= 2 and target.hp > 0 and not target.is_control_immune():
			target.begin_friendly_knockback_lock(0.16)
			if direction < 0.0:
				target.attack_to_right(hurt_back)
			else:
				target.attack_to_left(hurt_back)

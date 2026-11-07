extends "res://Script/pet/pet_nian_effect.gd"

var segments: Array[PackedVector2Array] = []
var screen_bounds := Rect2()
var _beam_texture: Texture2D
var _beam_region := Rect2()
var _beam_width := 48.0


func _ready() -> void:
	duration = 62.0 / 30.0
	hit_interval = 0.25


func build_segments(bounds: Rect2, origin: Vector2, ray: Vector2) -> void:
	segments.clear()
	screen_bounds = bounds
	var point := origin.clamp(bounds.position + Vector2.ONE, bounds.end - Vector2.ONE)
	ray = ray.normalized()
	for segment_index in range(4):
		var tx := INF
		var ty := INF
		if absf(ray.x) > 0.0001:
			tx = ((bounds.end.x if ray.x > 0 else bounds.position.x) - point.x) / ray.x
		if absf(ray.y) > 0.0001:
			ty = ((bounds.end.y if ray.y > 0 else bounds.position.y) - point.y) / ray.y
		var distance := minf(tx, ty)
		var end := point + ray * distance
		segments.append(PackedVector2Array([point, end]))
		if absf(tx - ty) < 0.001:
			ray = -ray
		elif tx < ty:
			ray.x = -ray.x
		else:
			ray.y = -ray.y
		point = end
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(summoner) or summoner.hp <= 0:
		queue_free()
		return
	elapsed += delta
	var source: Node2D = summoner.get("_nian_action_visual")
	var sample: Dictionary = source.beam_sample()
	if not sample.is_empty() and bool(summoner.get("_nian_ultimate_cast")):
		_beam_texture = sample.texture
		_beam_region = sample.region
		var pose: Transform2D = source.global_transform * sample.transform
		var start: Vector2 = pose * Vector2(0, _beam_region.size.y * 0.5)
		var ray: Vector2 = pose.x.normalized()
		_beam_width = maxf(1.0, pose.y.length() * _beam_region.size.y)
		var canvas_inverse := get_viewport().get_canvas_transform().affine_inverse()
		var bounds: Rect2 = canvas_inverse * get_viewport_rect()
		build_segments(bounds.grow(-4), start, ray)
	else:
		segments.clear()
		queue_redraw()
	if not segments.is_empty():
		for segment_index in range(segments.size()):
			var segment := segments[segment_index]
			var shape := RectangleShape2D.new()
			shape.size = Vector2(segment[0].distance_to(segment[1]), _beam_width)
			var query := PhysicsShapeQueryParameters2D.new()
			query.shape = shape
			query.transform = Transform2D((segment[1] - segment[0]).angle(), (segment[0] + segment[1]) * 0.5)
			query.collision_mask = 3088
			query.collide_with_areas = true
			query.collide_with_bodies = false
			for contact: Dictionary in get_world_2d().direct_space_state.intersect_shape(query, 256):
				var target: Node = contact.collider
				while target != null and not target is BaseMonster:
					target = target.get_parent()
				if target is BaseMonster and not target is SummonBaseMonster and target != summoner and target.hp > 0:
					_try_damage_target(target, segment_index)
	if elapsed >= duration:
		queue_free()


func _draw() -> void:
	if _beam_texture == null or not _beam_region.has_area():
		return
	for segment in segments:
		var start := to_local(segment[0])
		var end := to_local(segment[1])
		draw_set_transform(start, (end - start).angle())
		draw_texture_rect_region(
			_beam_texture, Rect2(0, -_beam_width * 0.5, start.distance_to(end), _beam_width), _beam_region
		)
	draw_set_transform_matrix(Transform2D.IDENTITY)

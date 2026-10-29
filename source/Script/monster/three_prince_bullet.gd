extends MonsterBullet
class_name ThreePrinceBullet

var frame_root: String = ""
var frames_resource_path: String = ""
var frames_animation: StringName = &""
var frame_path_format: String = ""
var frame_start_index: int = 1
var frame_count: int = 1
var frame_fps: float = 24.0
var life_time: float = 1.0
var hit_delay: float = 0.0
var hit_duration: float = 0.35
var hit_radius: float = 60.0
var visual_scale: Vector2 = Vector2.ONE
var visual_offset: Vector2 = Vector2.ZERO
var move_velocity: Vector2 = Vector2.ZERO
var move_acceleration: Vector2 = Vector2.ZERO
var max_distance: float = 0.0
var track_target: bool = false
var track_speed: float = 300.0
var damage_enabled: bool = true
var follow_owner: bool = false
var follow_owner_offset: Vector2 = Vector2.ZERO
var loop_visual: bool = false
var attack_interval_frames: int = 0
var additive_blend: bool = false

static var _texture_geometry_cache: Dictionary = {}
static var _additive_material: CanvasItemMaterial = null

var _elapsed: float = 0.0
var _frame_geometry: Array[Dictionary] = []
var _last_collision_frame: int = -1
var _last_collision_flip: bool = false
var _frame_has_visual: bool = false
var _frame_playback_name: StringName = &"play"
var _travelled_distance: float = 0.0
var _last_attack_cycle: int = -1
var _monitor_reenable_at: float = -1.0


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	my_father = _find_owner_boss()
	get_prop()
	_build_effect_frames()
	if additive_blend:
		bullet_ani.material = _get_additive_material()
	bullet_ani.scale = visual_scale
	_apply_visual_transform()
	bullet_ani.play(_frame_playback_name)
	bullet_ani.frame_changed.connect(_on_visual_frame_changed)
	var shape := CircleShape2D.new()
	shape.radius = maxf(hit_radius, 1.0)
	var hit_shape := get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if hit_shape != null:
		hit_shape.shape = shape
		hit_shape.disabled = not damage_enabled
	_sync_hit_shape_to_frame(true)
	if hit_box != null:
		hit_box.set_deferred("monitoring", false)


static func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material


func _process(delta: float) -> void:
	_elapsed += delta
	if follow_owner and my_father != null and is_instance_valid(my_father):
		global_position = my_father.global_position + follow_owner_offset

		var owner_dir := my_father.get_node_or_null("MonsterDir") as Node2D
		dir = owner_dir != null and owner_dir.scale.x < 0.0
		_apply_visual_transform()
	elif track_target and RoleProp.source_player != null and is_instance_valid(RoleProp.source_player):
		global_position = global_position.move_toward(
			RoleProp.source_player.global_position + Vector2(0.0, -55.0), track_speed * delta
		)
	else:
		var previous_position := global_position
		move_velocity += move_acceleration * delta
		global_position += move_velocity * delta
		_travelled_distance += previous_position.distance_to(global_position)
		if max_distance > 0.0 and _travelled_distance >= max_distance:
			queue_free()
			return
	_sync_hit_shape_to_frame()
	if hit_box != null and damage_enabled:
		var should_monitor: bool = _frame_has_visual and _elapsed >= hit_delay and _elapsed <= hit_delay + hit_duration
		_update_attack_interval(should_monitor)
		var forced_off: bool = _monitor_reenable_at >= 0.0 and _elapsed < _monitor_reenable_at
		if _monitor_reenable_at >= 0.0 and _elapsed >= _monitor_reenable_at:
			hit_box.set_deferred("monitoring", should_monitor)
			_monitor_reenable_at = -1.0
		elif not forced_off and hit_box.monitoring != should_monitor:
			hit_box.set_deferred("monitoring", should_monitor)
	if _elapsed >= life_time:
		queue_free()


func _update_attack_interval(should_monitor: bool) -> void:
	if not should_monitor or attack_interval_frames <= 0 or hit_box == null:
		return
	var attack_elapsed: float = maxf(_elapsed - hit_delay, 0.0)
	var cycle: int = int(floor(attack_elapsed * frame_fps / float(attack_interval_frames)))
	if cycle == _last_attack_cycle:
		return
	_last_attack_cycle = cycle
	if cycle <= 0:
		return

	hit_box.set_deferred("monitoring", false)
	_monitor_reenable_at = _elapsed + 1.0 / maxf(frame_fps, 1.0)


func _build_effect_frames() -> void:
	if not frames_resource_path.is_empty() and not frames_animation.is_empty():
		if _build_resource_frames():
			return
	_frame_playback_name = &"play"
	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	frames.add_animation(&"play")
	frames.set_animation_loop(&"play", loop_visual or frame_count <= 1)
	frames.set_animation_speed(&"play", frame_fps)
	_frame_geometry.clear()
	for frame_index in range(1, frame_count + 1):
		var source_index := frame_start_index + frame_index - 1
		var path := (
			frame_path_format % source_index
			if not frame_path_format.is_empty()
			else frame_root.path_join(str(source_index) + ".png")
		)
		var texture := Global.get_cached_texture(path)
		if texture != null:
			frames.add_frame(&"play", texture)
			_frame_geometry.append(_get_texture_geometry(path, texture))
	if frames.get_frame_count(&"play") == 0:
		frames.add_frame(&"play", null)
		_frame_geometry.append({"used_rect": Rect2(), "texture_size": Vector2.ZERO})
	bullet_ani.sprite_frames = frames


func _build_resource_frames() -> bool:
	var source := load(frames_resource_path) as SpriteFrames
	if source == null or not source.has_animation(frames_animation):
		return false
	var desired_loop := loop_visual or frame_count <= 1
	var frames := source
	if (
		source.get_animation_loop(frames_animation) != desired_loop
		or not is_equal_approx(source.get_animation_speed(frames_animation), frame_fps)
	):
		frames = source.duplicate(true) as SpriteFrames
		frames.set_animation_loop(frames_animation, desired_loop)
		frames.set_animation_speed(frames_animation, frame_fps)
	bullet_ani.sprite_frames = frames
	_frame_geometry.clear()
	for frame_index in range(frames.get_frame_count(frames_animation)):
		var texture := frames.get_frame_texture(frames_animation, frame_index)
		if texture is AtlasTexture:
			var atlas := texture as AtlasTexture
			# AtlasTexture 的 region 是有效像素，margin 是透明画布边距。
			(
				_frame_geometry
				. append(
					{
						"used_rect": Rect2(atlas.margin.position, atlas.region.size),
						"texture_size": atlas.region.size + atlas.margin.size,
					}
				)
			)
		elif texture != null:
			_frame_geometry.append(
				{"used_rect": Rect2(Vector2.ZERO, texture.get_size()), "texture_size": texture.get_size()}
			)
		else:
			_frame_geometry.append({"used_rect": Rect2(), "texture_size": Vector2.ZERO})
	_frame_playback_name = frames_animation
	return true


func _get_texture_geometry(path: String, texture: Texture2D) -> Dictionary:
	if _texture_geometry_cache.has(path):
		return _texture_geometry_cache[path]
	var used_rect := Rect2()
	var image := texture.get_image()
	if image != null:
		var image_rect := image.get_used_rect()
		used_rect = Rect2(Vector2(image_rect.position), Vector2(image_rect.size))
	var geometry := {
		"used_rect": used_rect,
		"texture_size": texture.get_size(),
	}
	_texture_geometry_cache[path] = geometry
	return geometry


func _on_visual_frame_changed() -> void:
	_sync_hit_shape_to_frame(true)


func _effective_visual_offset() -> Vector2:
	return Vector2(-visual_offset.x if dir else visual_offset.x, visual_offset.y)


func _apply_visual_transform() -> void:
	if bullet_ani == null:
		return
	bullet_ani.position = _effective_visual_offset()
	bullet_ani.flip_h = dir


func _sync_hit_shape_to_frame(force: bool = false) -> void:
	if bullet_ani == null:
		return
	var frame_index := bullet_ani.frame
	var flipped := bullet_ani.flip_h
	if not force and frame_index == _last_collision_frame and flipped == _last_collision_flip:
		return
	_last_collision_frame = frame_index
	_last_collision_flip = flipped
	_frame_has_visual = false
	if frame_index < 0 or frame_index >= _frame_geometry.size():
		return
	var geometry: Dictionary = _frame_geometry[frame_index]
	var used_rect: Rect2 = geometry.get("used_rect", Rect2())
	var texture_size: Vector2 = geometry.get("texture_size", Vector2.ZERO)
	if used_rect.size.x <= 0.0 or used_rect.size.y <= 0.0 or texture_size == Vector2.ZERO:
		return
	_frame_has_visual = true
	var visual_center := used_rect.position + used_rect.size * 0.5 - texture_size * 0.5
	visual_center *= visual_scale
	if flipped:
		visual_center.x = -visual_center.x
	var hit_shape := get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if hit_shape != null:
		hit_shape.position = _effective_visual_offset() + visual_center


func _find_owner_boss() -> BaseMonster:
	var node: Node = get_parent()
	while node != null:
		if node is BaseMonster:
			return node as BaseMonster
		node = node.get_parent()
	return null


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_texture_geometry_cache.clear()
	_additive_material = null

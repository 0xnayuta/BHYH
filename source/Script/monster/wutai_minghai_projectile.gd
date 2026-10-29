extends MonsterBullet
class_name WutaiMinghaiProjectile

const SOURCE_FPS := 30.0

enum VisualBackend { NONE, SPRITE_FRAMES, FRAME_SEQUENCE }
const VISUAL_BACKEND_UNDECLARED := -1
const VISUAL_BACKEND_UNKNOWN := -2

static var _frame_geometry_cache: Dictionary = {}

var owner_monster: BaseMonster
var spawn_global_position := Vector2.ZERO
var frame_asset_id := ""
var frame_count := 0
var visual_backend := VisualBackend.NONE
var impact_visual_backend := VisualBackend.NONE
var visual_scale := Vector2.ONE
var frame_fps := SOURCE_FPS
var loop_visual := true
var hold_last_frame := false
var visual_offset := Vector2.ZERO
var visual_registration := Vector2.ZERO
var visual_faces_right := true
var remove_black_background := false
var black_background_threshold := 0.045
var black_background_feather := 0.02
var remove_blue_background := false
var blue_background_threshold := 0.8
var blue_background_feather := 0.08
var impact_frame_asset_id := ""
var impact_frame_count := 0
var impact_visual_offset := Vector2.ZERO
var impact_duration := 0.0
var impact_orient_to_motion := false
var motion_velocity := Vector2.ZERO
var motion_acceleration := Vector2.ZERO
var orient_to_motion := false
var motion_rotation_offset := 0.0
var follow_owner := false
var follow_owner_offset := Vector2.ZERO
var follow_target := false
var collision_size := Vector2.ZERO
var collision_offset := Vector2.ZERO
var _collision_tracks_visual := true
var hit_delay := 0.0
var damage_enable_delay := 0.0
var damage_duration := 0.1
var hit_interval := 0.0
var damage_pulse_interval := 0.0
var poll_overlaps_on_damage_pulse := false
var max_hits := 1
var lifetime := 1.0
var max_distance := 0.0
var expire_on_hit := true
var damage_enabled := true
var track_target := false
var target_node: Node2D
var target_offset := Vector2.ZERO
var finished_callback := Callable()
var hit_callback := Callable()

var frames_resource_path := ""
var frames_animation := ""
var impact_frames_resource_path := ""
var impact_frames_animation := ""
var _visual_stream: StreamedPngEffect
var _visual_sequence: FrameSequence
var _standard_visual: AnimatedSprite2D
var _standard_frames: SpriteFrames
var _standard_animation: StringName = &""
static var _standard_loop_cache: Dictionary = {}
var _elapsed := 0.0
var _impact_elapsed := 0.0
var _hit_count := 0
var _pulse_index := -1
var _reenable_next_frame := false
var _hit_targets_in_pulse: Dictionary = {}
var _last_collision_frame := -1
var _current_frame_has_visual := true
var _finished := false
var _impacting := false
var _configuration_valid: bool = false
var _travelled_distance := 0.0
var target_move_interval := 0.0
var _target_move_elapsed := 0.0
var _target_node: Node2D
var _target_tween: Tween


func _init() -> void:
	var middle_node := Node2D.new()
	middle_node.name = "middle"
	add_child(middle_node)

	var attack_area := Area2D.new()
	attack_area.name = "HitBox"
	attack_area.collision_layer = 4
	attack_area.collision_mask = 8321
	attack_area.monitoring = false
	attack_area.monitorable = false
	middle_node.add_child(attack_area)

	var attack_shape := CollisionShape2D.new()
	attack_shape.name = "Hit_Box"
	attack_area.add_child(attack_shape)

	var visual := AnimatedSprite2D.new()
	visual.name = "BulletANI"
	visual.visible = false
	middle_node.add_child(visual)

	var animation_player := AnimationPlayer.new()
	animation_player.name = "BulletPlayer"
	add_child(animation_player)

	var lifetime_timer := Timer.new()
	lifetime_timer.name = "queue_timer"
	lifetime_timer.one_shot = true
	add_child(lifetime_timer)

	var throw_timer := Timer.new()
	throw_timer.name = "IsThrowClose"
	throw_timer.one_shot = true
	add_child(throw_timer)


func configure(config: Dictionary) -> bool:
	var main_backend := _backend_from_config(config, "visual_backend")
	var impact_backend := _backend_from_config(config, "impact_visual_backend")
	owner_monster = config.get("owner") as BaseMonster
	my_father = owner_monster
	spawn_global_position = config.get("position", Vector2.ZERO)
	hit_name = str(config.get("hit_name", "hit1"))
	att_list = (config.get("attack_data", {}) as Dictionary).duplicate(true)
	obj_attack_dict = {hit_name: att_list}
	skill_name = str(config.get("skill_name", "WutaiMinghaiProjectile"))
	dir = bool(config.get("right", true))
	frame_asset_id = str(config.get("frame_asset_id", ""))
	frame_count = int(config.get("frame_count", 0))
	frames_resource_path = str(config.get("frames_resource", ""))
	frames_animation = str(config.get("frames_animation", ""))
	impact_frame_asset_id = str(config.get("impact_frame_asset_id", ""))
	impact_frame_count = int(config.get("impact_frame_count", 0))
	impact_frames_resource_path = str(config.get("impact_frames_resource", ""))
	impact_frames_animation = str(config.get("impact_frames_animation", ""))

	visual_scale = config.get("visual_scale", Vector2.ONE)
	frame_fps = float(config.get("frame_fps", SOURCE_FPS))
	loop_visual = bool(config.get("loop_visual", true))
	hold_last_frame = bool(config.get("hold_last_frame", false))
	visual_offset = config.get("visual_offset", Vector2.ZERO)
	visual_registration = config.get("visual_registration", Vector2.ZERO)
	visual_faces_right = bool(config.get("visual_faces_right", true))
	remove_black_background = bool(config.get("remove_black_background", false))
	black_background_threshold = float(config.get("black_background_threshold", 0.045))
	black_background_feather = float(config.get("black_background_feather", 0.02))
	remove_blue_background = bool(config.get("remove_blue_background", false))
	blue_background_threshold = float(config.get("blue_background_threshold", 0.8))
	blue_background_feather = float(config.get("blue_background_feather", 0.08))
	impact_visual_offset = config.get("impact_visual_offset", Vector2.ZERO)
	impact_duration = maxf(float(config.get("impact_duration", 0.0)), 0.0)
	impact_orient_to_motion = bool(config.get("impact_orient_to_motion", false))
	motion_velocity = config.get("velocity", Vector2.ZERO)
	motion_acceleration = config.get("acceleration", Vector2.ZERO)
	orient_to_motion = bool(config.get("orient_to_motion", false))
	motion_rotation_offset = float(config.get("motion_rotation_offset", 0.0))
	follow_owner = bool(config.get("follow_owner", false))
	follow_owner_offset = config.get("follow_owner_offset", Vector2.ZERO)
	follow_target = bool(config.get("follow_target", false))
	collision_size = config.get("collision_size", Vector2.ZERO)
	collision_offset = config.get("collision_offset", Vector2.ZERO)
	_collision_tracks_visual = collision_size.x <= 0.0 or collision_size.y <= 0.0
	hit_delay = maxf(float(config.get("hit_delay", 0.0)), 0.0)
	damage_enable_delay = maxf(float(config.get("damage_enable_delay", 0.0)), 0.0)
	damage_duration = maxf(float(config.get("damage_duration", 0.1)), 0.0)
	hit_interval = maxf(float(config.get("hit_interval", 0.0)), 0.0)
	damage_pulse_interval = maxf(float(config.get("damage_pulse_interval", 0.0)), 0.0)
	poll_overlaps_on_damage_pulse = bool(config.get("poll_overlaps_on_damage_pulse", false))
	max_hits = maxi(int(config.get("max_hits", 1)), 1)
	lifetime = maxf(float(config.get("lifetime", 1.0)), 0.05)
	max_distance = maxf(float(config.get("max_distance", 0.0)), 0.0)
	expire_on_hit = bool(config.get("expire_on_hit", true))
	damage_enabled = bool(config.get("damage_enabled", true))
	track_target = bool(config.get("track_target", false))
	var target_value: Variant = config.get("target_node", null)
	target_node = target_value as Node2D if target_value is Node2D and is_instance_valid(target_value) else null
	target_offset = config.get("target_offset", Vector2.ZERO)
	target_move_interval = maxf(float(config.get("target_move_interval", 0.0)), 0.0)
	_target_move_elapsed = 0.0
	_target_node = null
	_target_tween = null
	var callback_value: Variant = config.get("finished_callback", Callable())
	if callback_value is Callable:
		finished_callback = callback_value
	var hit_callback_value: Variant = config.get("hit_callback", Callable())
	if hit_callback_value is Callable:
		hit_callback = hit_callback_value
	_configuration_valid = _validate_visual_config(main_backend, impact_backend)
	return _configuration_valid


func _backend_from_config(config: Dictionary, key: String) -> int:
	if not config.has(key):
		return VISUAL_BACKEND_UNDECLARED
	var value: Variant = config[key]
	if value is int and int(value) >= VisualBackend.NONE and int(value) <= VisualBackend.FRAME_SEQUENCE:
		return int(value)
	return VISUAL_BACKEND_UNKNOWN


func _validate_visual_config(main_backend: int, impact_backend: int) -> bool:
	var main_valid := _validate_backend(main_backend, false)
	var impact_valid := _validate_backend(impact_backend, true)
	return main_valid and impact_valid


func _validate_backend(backend: int, is_impact: bool) -> bool:
	var label := "impact_visual_backend" if is_impact else "visual_backend"
	var declared := _declares_visual(is_impact)
	if backend == VISUAL_BACKEND_UNDECLARED:
		_set_visual_backend(is_impact, VisualBackend.NONE)
		if declared:
			push_error("WutaiMinghaiProjectile: %s 声明了视觉资源但缺少 %s" % [skill_name, label])
			return false
		return true
	if backend == VISUAL_BACKEND_UNKNOWN:
		_set_visual_backend(is_impact, VisualBackend.NONE)
		push_error("WutaiMinghaiProjectile: %s 的 %s 不是有效枚举值" % [skill_name, label])
		return false
	if backend == VisualBackend.NONE:
		_set_visual_backend(is_impact, VisualBackend.NONE)
		if declared:
			push_error("WutaiMinghaiProjectile: %s 声明了视觉资源但 %s=NONE" % [skill_name, label])
			return false
		return true
	if backend == VisualBackend.SPRITE_FRAMES:
		if not _validate_sprite_frames(is_impact, label):
			_set_visual_backend(is_impact, VisualBackend.NONE)
			return false
		_set_visual_backend(is_impact, backend)
		return true
	if backend == VisualBackend.FRAME_SEQUENCE:
		if not _validate_frame_sequence(is_impact, label):
			_set_visual_backend(is_impact, VisualBackend.NONE)
			return false
		_set_visual_backend(is_impact, backend)
		return true
	push_error("WutaiMinghaiProjectile: %s 的 %s 枚举值越界" % [skill_name, label])
	_set_visual_backend(is_impact, VisualBackend.NONE)
	return false


func _set_visual_backend(is_impact: bool, backend: int) -> void:
	if is_impact:
		impact_visual_backend = backend as VisualBackend
	else:
		visual_backend = backend as VisualBackend


func _declares_visual(is_impact: bool) -> bool:
	if is_impact:
		return (
			impact_frame_count > 0
			or not impact_frame_asset_id.is_empty()
			or not impact_frames_resource_path.is_empty()
			or not impact_frames_animation.is_empty()
		)
	return (
		frame_count > 0
		or not frame_asset_id.is_empty()
		or not frames_resource_path.is_empty()
		or not frames_animation.is_empty()
	)


func _validate_sprite_frames(is_impact: bool, label: String) -> bool:
	var asset_id := impact_frame_asset_id if is_impact else frame_asset_id
	var resource_path := impact_frames_resource_path if is_impact else frames_resource_path
	var animation_name := impact_frames_animation if is_impact else frames_animation
	if not asset_id.is_empty():
		push_error("WutaiMinghaiProjectile: %s 的 %s=SPRITE_FRAMES 不得同时声明 frame_asset_id" % [skill_name, label])
		return false
	if resource_path.is_empty() or animation_name.is_empty():
		push_error(
			"WutaiMinghaiProjectile: %s 的 %s=SPRITE_FRAMES 缺少 frames_resource 或 frames_animation" % [skill_name, label]
		)
		return false
	var looped := false if is_impact else loop_visual
	var frames := _load_standard_frames(resource_path, StringName(animation_name), looped)
	if frames == null:
		push_error(
			(
				"WutaiMinghaiProjectile: %s 的 %s 指定 SpriteFrames 缺少动画 %s: %s"
				% [skill_name, label, animation_name, resource_path]
			)
		)
		return false
	if is_impact and impact_frame_count <= 0:
		impact_frame_count = frames.get_frame_count(StringName(animation_name))
	return true


func _validate_frame_sequence(is_impact: bool, label: String) -> bool:
	var asset_id := impact_frame_asset_id if is_impact else frame_asset_id
	var count := impact_frame_count if is_impact else frame_count
	var resource_path := impact_frames_resource_path if is_impact else frames_resource_path
	var animation_name := impact_frames_animation if is_impact else frames_animation
	if not resource_path.is_empty() or not animation_name.is_empty():
		push_error("WutaiMinghaiProjectile: %s 的 %s=FRAME_SEQUENCE 不得同时声明 SpriteFrames 字段" % [skill_name, label])
		return false
	if asset_id.is_empty() or count <= 0:
		push_error(
			"WutaiMinghaiProjectile: %s 的 %s=FRAME_SEQUENCE 缺少 frame_asset_id 或 frame_count" % [skill_name, label]
		)
		return false
	if not FrameSequenceStore.has_sequence(StringName(asset_id)):
		push_error("WutaiMinghaiProjectile: %s 的 %s 缺少构建期帧序列 %s" % [skill_name, label, asset_id])
		return false
	return true


static func _load_standard_frames(resource_path: String, animation: StringName, looped: bool) -> SpriteFrames:
	if resource_path.is_empty() or animation == &"":
		return null
	var cache_key := "%s|%s|%s" % [resource_path, animation, str(looped)]
	var cached := _standard_loop_cache.get(cache_key) as SpriteFrames
	if cached != null:
		return cached
	var source := load(resource_path) as SpriteFrames
	if source == null or not source.has_animation(animation):
		return null
	var frames: SpriteFrames
	if source.get_animation_loop(animation) != looped:
		frames = source.duplicate(true) as SpriteFrames
		frames.set_animation_loop(animation, looped)
	else:
		frames = source
	_standard_loop_cache[cache_key] = frames
	return frames


func _ready() -> void:
	if not _configuration_valid:
		_finished = true
		set_physics_process(false)
		queue_free()
		return
	super._ready()
	set_as_top_level(true)
	global_position = spawn_global_position
	get_prop()
	if visual_backend != VisualBackend.NONE:
		if not _configure_visual(
			visual_backend,
			frame_asset_id,
			frame_count,
			visual_offset,
			loop_visual,
			frames_resource_path,
			frames_animation,
			false
		):
			push_error("WutaiMinghaiProjectile: %s 视觉初始化失败" % skill_name)
			_finished = true
			set_physics_process(false)
			queue_free()
			return
	_configure_collision()
	if damage_enabled and not hit_box.area_entered.is_connected(_on_streamed_hit_box_area_entered):
		hit_box.area_entered.connect(_on_streamed_hit_box_area_entered)


func _configure_visual(
	backend: int,
	asset_id: String,
	count: int,
	offset: Vector2,
	looped: bool,
	resource_path: String,
	animation_name: String,
	is_impact: bool
) -> bool:
	if backend == VisualBackend.NONE:
		return true
	if backend == VisualBackend.SPRITE_FRAMES:
		_release_visual_stream()
		var animation := StringName(animation_name)
		return _configure_standard_visual(
			resource_path, animation, _standard_visual_offset(animation, offset + visual_registration), looped
		)
	if backend == VisualBackend.FRAME_SEQUENCE:
		_release_standard_visual()
		return _configure_stream_visual(asset_id, count, offset, looped, is_impact)
	push_error("WutaiMinghaiProjectile: %s 视觉后端无效" % skill_name)
	return false


func _standard_visual_offset(_animation: StringName, offset: Vector2) -> Vector2:
	return offset


func _configure_stream_visual(asset_id: String, count: int, offset: Vector2, looped: bool, is_impact: bool) -> bool:
	_visual_sequence = null
	if asset_id.is_empty() or count <= 0:
		return false
	if not FrameSequenceStore.has_sequence(StringName(asset_id)):
		push_error("缺少构建期弹道帧序列: " + asset_id)
		return false

	var stream := StreamedPngEffect.new()
	stream.name = "VisualStream"
	stream.sequence = FrameSequenceStore.get_sequence(StringName(asset_id))
	if stream.sequence == null:
		push_error("WutaiMinghaiProjectile: %s 的帧序列加载失败: %s" % [skill_name, asset_id])
		stream.free()
		return false
	var effective_loop := false if is_impact else looped
	stream.configure_playback(frame_fps, effective_loop, hold_last_frame, 2)
	# 九头虫吸收特效的黑底抠除是资产特性，按构建期 asset_id 判定而不是目录字符串。
	if asset_id.ends_with("monster_169/hit2"):
		remove_black_background = true
		black_background_threshold = 0.14
		black_background_feather = 0.05
	_visual_sequence = stream.sequence
	stream.auto_free = false
	stream.remove_black_background = remove_black_background
	stream.black_background_threshold = black_background_threshold
	stream.black_background_feather = black_background_feather
	stream.remove_blue_background = remove_blue_background
	stream.blue_background_threshold = blue_background_threshold
	stream.blue_background_feather = blue_background_feather
	stream.flip_h = visual_faces_right != dir
	var mirrored_offset := offset + visual_registration
	if stream.flip_h:
		mirrored_offset.x = -mirrored_offset.x
	stream.position = mirrored_offset
	_install_visual_stream(stream)
	_update_motion_rotation()
	return true


func _configure_standard_visual(
	resource_path: String, animation: StringName, source_offset: Vector2, looped: bool
) -> bool:
	var frames := _load_standard_frames(resource_path, animation, looped)
	if frames == null:
		push_error("WutaiMinghaiProjectile: %s 指定 SpriteFrames 缺少动画 %s: %s" % [skill_name, animation, resource_path])
		return false
	_release_standard_visual()
	var overlay := AnimatedSprite2D.new()
	overlay.name = "VisualFrames"
	overlay.sprite_frames = frames
	overlay.animation = animation
	overlay.centered = true
	overlay.flip_h = visual_faces_right != dir
	var mirrored_offset := source_offset
	if overlay.flip_h:
		mirrored_offset.x = -mirrored_offset.x
	overlay.position = mirrored_offset
	var base_speed := frames.get_animation_speed(animation)
	if base_speed > 0.0:
		overlay.speed_scale = frame_fps / base_speed
	overlay.play(animation)
	middle.add_child(overlay)
	_standard_visual = overlay
	_standard_frames = frames
	_standard_animation = animation
	_update_motion_rotation()
	return true


func _configure_collision() -> void:
	var shape_node := get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if shape_node == null:
		return
	var shape := RectangleShape2D.new()
	shape.size = Vector2(maxf(collision_size.x, 1.0), maxf(collision_size.y, 1.0))
	shape_node.shape = shape
	if _collision_tracks_visual:
		_sync_collision_to_visual_frame(true)
	else:
		_apply_collision_geometry(collision_size, Vector2.ZERO)
	shape_node.disabled = not damage_enabled
	var starts_active := _damage_window_is_active()
	hit_box.monitoring = starts_active
	_pulse_index = 0 if starts_active else -1


func _displayed_visual_frame() -> int:
	if (
		_standard_frames != null
		and _standard_animation != &""
		and _standard_visual != null
		and is_instance_valid(_standard_visual)
	):
		var standard_count := _standard_frames.get_frame_count(_standard_animation)
		if standard_count > 0:
			return clampi(_standard_visual.frame, 0, standard_count - 1)
	if _visual_stream != null and is_instance_valid(_visual_stream):
		return _visual_stream.displayed_frame()
	return -1


func _sync_collision_to_visual_frame(force: bool = false) -> void:
	if not _collision_tracks_visual:
		return
	if (
		_standard_frames != null
		and _standard_animation != &""
		and _standard_visual != null
		and is_instance_valid(_standard_visual)
	):
		var standard_count := _standard_frames.get_frame_count(_standard_animation)
		if standard_count > 0:
			var standard_frame_index := clampi(_standard_visual.frame, 0, standard_count - 1)
			if not force and standard_frame_index == _last_collision_frame:
				return
			_last_collision_frame = standard_frame_index
			_current_frame_has_visual = false
			var texture := _standard_frames.get_frame_texture(_standard_animation, standard_frame_index)
			if texture is AtlasTexture:
				var atlas := texture as AtlasTexture
				var used_size := atlas.region.size
				var margin := atlas.margin
				var canvas_size := used_size + margin.size
				var frame_center := margin.position + used_size * 0.5 - canvas_size * 0.5
				_current_frame_has_visual = used_size.x > 0.0 and used_size.y > 0.0
				_apply_collision_geometry(used_size, frame_center)
			elif texture is Texture2D:
				var image := texture.get_image()
				if image != null:
					var used_rect := image.get_used_rect()
					if used_rect.size != Vector2i.ZERO:
						var used_size := Vector2(used_rect.size)
						var frame_center := Vector2(used_rect.position) + used_size * 0.5 - texture.get_size() * 0.5
						_current_frame_has_visual = true
						_apply_collision_geometry(used_size, frame_center)
			return
	if _visual_sequence == null:
		_current_frame_has_visual = false
		_apply_collision_geometry(collision_size, Vector2.ZERO)
		return
	var displayed_frame := _displayed_visual_frame()
	if displayed_frame < 0:
		_last_collision_frame = -1
		_current_frame_has_visual = false
		_apply_collision_geometry(collision_size, Vector2.ZERO)
		return
	var paths := _visual_sequence.frame_paths
	var frame_index := clampi(displayed_frame, 0, paths.size() - 1)
	if not force and frame_index == _last_collision_frame:
		return
	_last_collision_frame = frame_index
	_current_frame_has_visual = false
	var geometry: Dictionary = _frame_geometry(paths[frame_index])
	var size_value: Variant = geometry.get("size", Vector2.ONE)
	var center_value: Variant = geometry.get("center", Vector2.ZERO)
	_current_frame_has_visual = bool(geometry.get("has_visual", false))
	var resolved_size := size_value as Vector2 if size_value is Vector2 else Vector2.ONE
	var resolved_center := center_value as Vector2 if center_value is Vector2 else Vector2.ZERO
	_apply_collision_geometry(resolved_size, resolved_center)


func _apply_collision_geometry(size: Vector2, frame_center: Vector2) -> void:
	var shape_node := get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if shape_node == null or not (shape_node.shape is RectangleShape2D):
		return
	(shape_node.shape as RectangleShape2D).size = Vector2(maxf(size.x, 1.0), maxf(size.y, 1.0))
	var resolved_offset := collision_offset + frame_center
	if visual_faces_right != dir:
		resolved_offset.x = -resolved_offset.x
	shape_node.position = resolved_offset


func _frame_geometry(path: String) -> Dictionary:
	if _frame_geometry_cache.has(path):
		return _frame_geometry_cache[path]
	var geometry := {
		"size": Vector2.ONE,
		"center": Vector2.ZERO,
		"has_visual": false,
	}
	var texture := ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	if texture != null:
		var texture_size := texture.get_size()
		var image := texture.get_image()
		if image != null:
			var used_rect := image.get_used_rect()
			if used_rect.size != Vector2i.ZERO:
				var used_size := Vector2(used_rect.size)
				geometry["size"] = used_size
				geometry["center"] = Vector2(used_rect.position) + used_size * 0.5 - texture_size * 0.5
				geometry["has_visual"] = true
	_frame_geometry_cache[path] = geometry
	return geometry


func _physics_process(delta: float) -> void:
	if _finished:
		return
	if _impacting:
		_impact_elapsed += delta
		if _impact_elapsed >= impact_duration:
			_finish()
		return
	_elapsed += delta
	_sync_collision_to_visual_frame()
	_update_target_motion(delta)
	var previous_position := global_position
	if follow_target and target_node != null and is_instance_valid(target_node):
		global_position = target_node.to_global(target_offset)
	elif follow_owner and owner_monster != null and is_instance_valid(owner_monster):
		global_position = owner_monster.to_global(follow_owner_offset)
	elif track_target and target_node != null and is_instance_valid(target_node):
		var target_position := target_node.global_position + target_offset
		var speed_length := motion_velocity.length()
		if speed_length > 0.0:
			motion_velocity = global_position.direction_to(target_position) * speed_length
		motion_velocity += motion_acceleration * delta
		global_position += motion_velocity * delta
	else:
		motion_velocity += motion_acceleration * delta
		global_position += motion_velocity * delta
	_travelled_distance += previous_position.distance_to(global_position)
	if max_distance > 0.0 and _travelled_distance >= max_distance:
		_finish()
		return
	_update_motion_rotation()
	_update_damage_window()
	if poll_overlaps_on_damage_pulse:
		_process_overlapping_hit_areas()
		_process_overlapping_player_bodies()
	if _elapsed >= lifetime:
		_finish()


func _update_motion_rotation() -> void:
	if not orient_to_motion or motion_velocity.is_zero_approx() or middle == null:
		return
	middle.rotation = motion_velocity.angle() + motion_rotation_offset


func launch_linear(new_velocity: Vector2, duration: float) -> void:
	if _finished:
		return
	follow_owner = false
	follow_target = false
	track_target = false
	target_node = null
	motion_velocity = new_velocity
	motion_acceleration = Vector2.ZERO
	lifetime = _elapsed + maxf(duration, 0.05)


func _update_damage_window() -> void:
	if not _damage_window_is_active():
		_reenable_next_frame = false
		_set_monitoring(false)
		return
	var active_elapsed := _elapsed - hit_delay
	var pulse_interval := damage_pulse_interval if damage_pulse_interval > 0.0 else hit_interval
	if pulse_interval <= 0.0:
		if _pulse_index < 0:
			_pulse_index = 0
			_hit_targets_in_pulse.clear()
		_set_monitoring(true)
		return
	var next_index := int(floor(active_elapsed / pulse_interval))
	if next_index != _pulse_index:
		var first_pulse := _pulse_index < 0
		_pulse_index = next_index
		_hit_targets_in_pulse.clear()
		if poll_overlaps_on_damage_pulse:
			_set_monitoring(true)
		elif first_pulse:
			_set_monitoring(true)
		else:
			_set_monitoring(false)
			_reenable_next_frame = true
		return
	if _reenable_next_frame:
		_reenable_next_frame = false
		_set_monitoring(true)
	elif hit_box != null and not hit_box.monitoring:
		_set_monitoring(true)


func _damage_window_is_active() -> bool:
	if not damage_enabled or _hit_count >= max_hits or damage_duration <= 0.0:
		return false
	if _collision_tracks_visual and frame_count > 0 and not _current_frame_has_visual:
		return false
	if _elapsed < damage_enable_delay:
		return false
	var active_elapsed := _elapsed - hit_delay
	return active_elapsed >= 0.0 and active_elapsed <= damage_duration


func _set_monitoring(enabled: bool) -> void:
	if hit_box != null and hit_box.monitoring != enabled:
		hit_box.set_deferred("monitoring", enabled)


func _process_overlapping_hit_areas() -> void:
	if not _damage_window_is_active() or hit_box == null or not hit_box.monitoring:
		return
	for area: Area2D in hit_box.get_overlapping_areas():
		if _finished:
			return
		_on_streamed_hit_box_area_entered(area)


func _process_overlapping_player_bodies() -> void:
	if not _damage_window_is_active() or _finished:
		return
	var players: Array = []
	if owner_monster != null and is_instance_valid(owner_monster) and owner_monster.has_method("_active_players"):
		players = owner_monster.call("_active_players")
	for player: BaseHero in LocalCoop.living_players():
		if not players.has(player):
			players.append(player)
	if players.is_empty():
		var source_player := RoleProp.source_player as BaseHero
		if source_player != null:
			players.append(source_player)
	var shape_node := get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	var rectangle := shape_node.shape as RectangleShape2D if shape_node != null else null
	var half_size := rectangle.size * 0.5 if rectangle != null else Vector2(24.0, 24.0)
	var hit_center := shape_node.global_position if shape_node != null else global_position
	for player_value in players:
		var player := player_value as BaseHero
		if player == null or not is_instance_valid(player) or player.is_death or player.need_protect:
			continue
		var target_id := player.get_instance_id()
		if _hit_targets_in_pulse.has(target_id):
			continue
		var player_shape := player.get_node_or_null("pz") as CollisionShape2D
		var player_half := Vector2(24.0, 48.0)
		if player_shape != null and player_shape.shape is RectangleShape2D:
			player_half = (player_shape.shape as RectangleShape2D).size * 0.5
		var distance := (hit_center - player.global_position).abs()
		if distance.x > half_size.x + player_half.x or distance.y > half_size.y + player_half.y:
			continue
		_apply_hit_to_player(player)


func _apply_hit_to_player(player: BaseHero) -> void:
	if not _damage_window_is_active() or player == null or not is_instance_valid(player):
		return
	var target_id := player.get_instance_id()
	if _hit_targets_in_pulse.has(target_id):
		return
	player.call("_on_hurt_box_area_entered", hit_box)
	_hit_targets_in_pulse[target_id] = true
	_hit_count += 1
	if hit_callback.is_valid():
		hit_callback.call(self, player)
	if expire_on_hit or _hit_count >= max_hits:
		_set_monitoring(false)
		if expire_on_hit:
			if _has_impact_visual():
				_begin_impact()
			else:
				_finish()


func _on_streamed_hit_box_area_entered(area: Area2D) -> void:
	if not _damage_window_is_active():
		return
	var hit_role := _find_role_owner(area)
	if hit_role == null:
		return
	var target_id := hit_role.get_instance_id()
	if _hit_targets_in_pulse.has(target_id):
		return
	if hit_role.is_death or hit_role.need_protect:
		_set_monitoring(false)
		_reenable_next_frame = true
		return
	super._on_hit_box_area_entered(area)
	hit_role.call("_on_hurt_box_area_entered", hit_box)
	_hit_targets_in_pulse[target_id] = true
	_hit_count += 1
	if hit_callback.is_valid():
		hit_callback.call(self, hit_role)
	if expire_on_hit or _hit_count >= max_hits:
		_set_monitoring(false)
		if expire_on_hit:
			if _has_impact_visual():
				_begin_impact()
			else:
				_finish()


func _find_role_owner(area: Area2D) -> BaseHero:
	var node: Node = area
	while node != null:
		if node is BaseHero:
			return node as BaseHero
		node = node.get_parent()
	return null


func _has_impact_visual() -> bool:
	return impact_visual_backend != VisualBackend.NONE


func _begin_impact() -> void:
	if _impacting or _finished:
		return
	if not _has_impact_visual():
		_finish()
		return
	_impact_elapsed = 0.0
	motion_velocity = Vector2.ZERO
	motion_acceleration = Vector2.ZERO
	follow_owner = false
	_set_monitoring(false)
	if not impact_orient_to_motion and middle != null:
		middle.rotation = 0.0
	var impact_configured := _configure_visual(
		impact_visual_backend,
		impact_frame_asset_id,
		impact_frame_count,
		impact_visual_offset,
		false,
		impact_frames_resource_path,
		impact_frames_animation,
		true
	)
	if not impact_configured:
		push_error("WutaiMinghaiProjectile: %s impact 视觉初始化失败" % skill_name)
		_finish()
		return
	_impacting = true
	if impact_duration <= 0.0:
		impact_duration = maxf(float(impact_frame_count) / frame_fps, 0.05)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	if _target_tween != null and _target_tween.is_valid():
		_target_tween.kill()
	_target_tween = null
	_set_monitoring(false)
	_clear_visual_stream()
	if finished_callback.is_valid():
		finished_callback.call(global_position)
	queue_free()


func _clear_visual_stream() -> void:
	_release_visual_stream()
	_release_standard_visual()


func _release_visual_stream() -> void:
	_visual_sequence = null
	if _visual_stream != null and is_instance_valid(_visual_stream):
		_visual_stream.clear_texture()
		_visual_stream.queue_free()
	_visual_stream = null


func _release_standard_visual() -> void:
	if _standard_visual != null and is_instance_valid(_standard_visual):
		_standard_visual.stop()
		_standard_visual.sprite_frames = null
		_standard_visual.queue_free()
	_standard_visual = null
	_standard_frames = null
	_standard_animation = &""


func _install_visual_stream(stream: StreamedPngEffect) -> void:
	var previous_stream := _visual_stream
	_visual_stream = stream
	stream.frame_ready.connect(_on_visual_stream_frame_ready.bind(stream, previous_stream), CONNECT_ONE_SHOT)
	stream.failed.connect(_on_visual_stream_failed.bind(stream), CONNECT_ONE_SHOT)
	middle.add_child(stream)
	if stream.has_displayed_frame():
		_commit_visual_stream(stream, previous_stream)


func _on_visual_stream_failed(message: String, stream: StreamedPngEffect) -> void:
	if _finished or _visual_stream != stream:
		return
	push_error("WutaiMinghaiProjectile: %s 视觉流加载失败: %s" % [skill_name, message])
	_finish()


func _on_visual_stream_frame_ready(stream: StreamedPngEffect, previous_stream: StreamedPngEffect) -> void:
	_commit_visual_stream(stream, previous_stream)


func _commit_visual_stream(stream: StreamedPngEffect, previous_stream: StreamedPngEffect) -> void:
	if _visual_stream != stream or not is_instance_valid(stream):
		return
	if previous_stream != null and previous_stream != stream and is_instance_valid(previous_stream):
		previous_stream.clear_texture()
		previous_stream.queue_free()


func _exit_tree() -> void:
	_clear_visual_stream()


func _update_target_motion(delta: float) -> void:
	if target_move_interval <= 0.0:
		return
	if _target_node == null or not is_instance_valid(_target_node):
		_target_node = _resolve_random_target()

		_target_move_elapsed = target_move_interval if _target_node != null else 0.0
		return
	_target_move_elapsed += delta
	if _target_move_elapsed < target_move_interval:
		return
	_target_move_elapsed = 0.0
	var distance := absf(global_position.x - _target_node.global_position.x)
	var duration := 2.1 * (distance / 1000.0)
	if _target_tween != null and _target_tween.is_valid():
		_target_tween.kill()
	_target_tween = create_tween()
	_target_tween.tween_property(
		self, "global_position", Vector2(_target_node.global_position.x, global_position.y), duration
	)
	_target_node = _resolve_random_target()


func _resolve_random_target() -> Node2D:
	if owner_monster != null and is_instance_valid(owner_monster):
		var owner_target: Variant = owner_monster.get("get_player")
		if owner_target is Node2D and is_instance_valid(owner_target):
			return owner_target as Node2D
	var players: Array[BaseHero] = LocalCoop.living_players()
	if players.is_empty():
		return null
	return players[randi() % players.size()]


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_frame_geometry_cache.clear()
	_standard_loop_cache.clear()

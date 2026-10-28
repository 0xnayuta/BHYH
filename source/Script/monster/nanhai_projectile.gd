extends MonsterBullet
class_name NanhaiProjectile

const SOURCE_FPS := 30.0
static var _frames_cache: Dictionary = {}

var owner_monster: BaseMonster
var spawn_global_position := Vector2.ZERO
var frame_root := ""
var frame_count := 0
var visual_scale := Vector2.ONE
var frame_fps := SOURCE_FPS
var loop_visual := true
var visual_offset := Vector2.ZERO
var visual_faces_right := true
var impact_frame_root := ""
var impact_frame_count := 0
var impact_visual_faces_right := true
var impact_visual_offset := Vector2.ZERO
var impact_duration := 0.0
var motion_velocity := Vector2.ZERO
var motion_acceleration := Vector2.ZERO
var orient_to_motion := false
var follow_owner := false
var follow_owner_offset := Vector2.ZERO
var collision_size := Vector2(48.0, 32.0)
var collision_offset := Vector2.ZERO
var hit_delay := 0.0
var damage_duration := 0.1
var hit_interval := 0.0
var max_hits := 1
var lifetime := 1.0
var expire_on_hit := true
var damage_enabled := true
var finished_callback := Callable()

var _elapsed := 0.0
var _impact_elapsed := 0.0
var _hit_count := 0
var _pulse_index := -1
var _reenable_next_frame := false
var _finished := false
var _impacting := false
var _visual_stream: StreamedPngEffect


func _init() -> void:
	var middle_node := Node2D.new()
	middle_node.name = "middle"
	add_child(middle_node)

	var attack_area := Area2D.new()
	attack_area.name = "HitBox"
	attack_area.collision_layer = 4
	attack_area.collision_mask = 8321
	attack_area.monitoring = false
	attack_area.monitorable = true
	middle_node.add_child(attack_area)

	var attack_shape := CollisionShape2D.new()
	attack_shape.name = "Hit_Box"
	attack_area.add_child(attack_shape)

	var visual := AnimatedSprite2D.new()
	visual.name = "BulletANI"
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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


func configure(config: Dictionary) -> void:
	owner_monster = config.get("owner") as BaseMonster
	my_father = owner_monster
	spawn_global_position = config.get("position", Vector2.ZERO)
	hit_name = str(config.get("hit_name", "hit1"))
	att_list = (config.get("attack_data", {}) as Dictionary).duplicate(true)
	obj_attack_dict = {hit_name: att_list}
	skill_name = str(config.get("skill_name", "NanhaiProjectile"))
	dir = bool(config.get("right", true))
	frame_root = str(config.get("frame_root", ""))
	frame_count = int(config.get("frame_count", 0))
	visual_scale = config.get("visual_scale", Vector2.ONE)
	frame_fps = float(config.get("frame_fps", SOURCE_FPS))
	loop_visual = bool(config.get("loop_visual", true))
	visual_offset = config.get("visual_offset", Vector2.ZERO)
	visual_faces_right = bool(config.get("visual_faces_right", true))
	impact_frame_root = str(config.get("impact_frame_root", ""))
	impact_frame_count = int(config.get("impact_frame_count", 0))

	impact_visual_faces_right = bool(config.get("impact_visual_faces_right", visual_faces_right))
	impact_visual_offset = config.get("impact_visual_offset", Vector2.ZERO)
	impact_duration = maxf(float(config.get("impact_duration", 0.0)), 0.0)
	motion_velocity = config.get("velocity", Vector2.ZERO)
	motion_acceleration = config.get("acceleration", Vector2.ZERO)
	orient_to_motion = bool(config.get("orient_to_motion", false))
	follow_owner = bool(config.get("follow_owner", false))
	follow_owner_offset = config.get("follow_owner_offset", Vector2.ZERO)
	collision_size = config.get("collision_size", Vector2(48.0, 32.0))
	collision_offset = config.get("collision_offset", Vector2.ZERO)
	hit_delay = maxf(float(config.get("hit_delay", 0.0)), 0.0)
	damage_duration = maxf(float(config.get("damage_duration", 0.1)), 0.0)
	hit_interval = maxf(float(config.get("hit_interval", 0.0)), 0.0)
	max_hits = maxi(int(config.get("max_hits", 1)), 1)
	lifetime = maxf(float(config.get("lifetime", 1.0)), 0.05)
	expire_on_hit = bool(config.get("expire_on_hit", true))
	damage_enabled = bool(config.get("damage_enabled", true))
	var callback_value: Variant = config.get("finished_callback", Callable())
	if callback_value is Callable:
		finished_callback = callback_value


func _ready() -> void:
	super._ready()
	set_as_top_level(true)
	global_position = spawn_global_position
	get_prop()
	_configure_visual()
	_configure_collision()
	if damage_enabled and not hit_box.area_entered.is_connected(_on_nanhai_hit_box_area_entered):
		hit_box.area_entered.connect(_on_nanhai_hit_box_area_entered)


func _configure_visual() -> void:
	var next_frames := get_frame_set(frame_root, frame_count, frame_fps, loop_visual)
	if (
		next_frames == null
		or not next_frames.has_animation(&"play")
		or next_frames.get_frame_count(&"play") == 0
		or next_frames.get_frame_texture(&"play", 0) == null
	):
		return
	bullet_ani.visible = true
	bullet_ani.sprite_frames = next_frames
	bullet_ani.animation = &"play"
	bullet_ani.centered = true
	bullet_ani.flip_h = visual_faces_right != dir
	_apply_visual_offset(visual_offset)
	bullet_ani.play(&"play")
	_replace_visual_stream(null)
	_update_motion_rotation()


func _configure_atlas_visual(
	_sequence_name: String,
	_source_offset: Vector2,
	_looped: bool,
	_faces_right: bool = visual_faces_right,
	_metadata_path: String = ""
) -> bool:
	return false


func _apply_visual_offset(source_offset: Vector2) -> void:
	var mirrored_offset := source_offset
	if bullet_ani.flip_h:
		mirrored_offset.x = -mirrored_offset.x
	bullet_ani.position = mirrored_offset


func _configure_collision() -> void:
	var shape_node := get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if shape_node == null:
		return
	var shape := RectangleShape2D.new()
	shape.size = Vector2(maxf(collision_size.x, 1.0), maxf(collision_size.y, 1.0))
	shape_node.shape = shape
	var mirrored_collision_offset := collision_offset
	if bullet_ani.flip_h:
		mirrored_collision_offset.x = -mirrored_collision_offset.x
	shape_node.position = mirrored_collision_offset
	shape_node.disabled = not damage_enabled
	hit_box.monitoring = false


func _physics_process(delta: float) -> void:
	if _finished:
		return
	if _impacting:
		_impact_elapsed += delta
		if _impact_elapsed >= impact_duration:
			_finish()
		return
	_elapsed += delta
	if follow_owner and owner_monster != null and is_instance_valid(owner_monster):
		global_position = owner_monster.to_global(follow_owner_offset)
	else:
		motion_velocity += motion_acceleration * delta
		global_position += motion_velocity * delta
	_update_motion_rotation()
	_update_damage_window()
	if _elapsed >= lifetime:
		_finish()


func _update_motion_rotation() -> void:
	if not orient_to_motion or motion_velocity.is_zero_approx() or middle == null:
		return
	middle.rotation = motion_velocity.angle()


func _update_damage_window() -> void:
	if not damage_enabled:
		_set_monitoring(false)
		return
	if _hit_count >= max_hits:
		_set_monitoring(false)
		return
	var active_elapsed := _elapsed - hit_delay
	var in_window := active_elapsed >= 0.0 and active_elapsed <= damage_duration
	if not in_window:
		_set_monitoring(false)
		return
	if hit_interval <= 0.0:
		_set_monitoring(true)
		return
	var next_index := int(floor(active_elapsed / hit_interval))
	if next_index != _pulse_index:
		_pulse_index = next_index
		_set_monitoring(false)
		_reenable_next_frame = true
		return
	if _reenable_next_frame:
		_reenable_next_frame = false
		_set_monitoring(true)


func _set_monitoring(enabled: bool) -> void:
	if hit_box != null and hit_box.monitoring != enabled:
		hit_box.set_deferred("monitoring", enabled)


func _on_nanhai_hit_box_area_entered(area: Area2D) -> void:
	var role := _find_role_owner(area)
	if role == null:
		return
	_hit_count += 1
	super._on_hit_box_area_entered(area)
	if expire_on_hit or _hit_count >= max_hits:
		_set_monitoring(false)
		if expire_on_hit:
			if not impact_frame_root.is_empty() and impact_frame_count > 0:
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


func _finish() -> void:
	if _finished:
		return
	_finished = true
	_set_monitoring(false)
	if finished_callback.is_valid():
		finished_callback.call(global_position)
	queue_free()


func _begin_impact() -> void:
	if _impacting or _finished:
		return
	_impacting = true
	_impact_elapsed = 0.0
	motion_velocity = Vector2.ZERO
	motion_acceleration = Vector2.ZERO
	follow_owner = false
	_set_monitoring(false)
	var configured := false
	if not configured:
		var impact_frames := get_frame_set(impact_frame_root, impact_frame_count, frame_fps, false)
		if (
			impact_frames == null
			or not impact_frames.has_animation(&"play")
			or impact_frames.get_frame_count(&"play") == 0
			or impact_frames.get_frame_texture(&"play", 0) == null
		):
			_impacting = false
			_finish()
			return
		bullet_ani.visible = true
		bullet_ani.sprite_frames = impact_frames
		bullet_ani.animation = &"play"
		_apply_visual_offset(impact_visual_offset)
		bullet_ani.play(&"play")
		_replace_visual_stream(null)
		configured = true
	if not configured:
		_impacting = false
		_finish()
		return
	if impact_duration <= 0.0:
		var visual_frame_count := impact_frame_count
		impact_duration = maxf(float(visual_frame_count) / frame_fps, 0.05)


static func prewarm_frame_set(root: String, count: int, fps: float = SOURCE_FPS, looped: bool = true) -> void:
	get_frame_set(root, count, fps, looped)
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		await tree.process_frame


static func _standard_frames_for(root: String, fps: float, looped: bool) -> SpriteFrames:
	# swf_png/<model>/<action> 直接复用预生成的标准帧，避免退回逐帧 PNG 加载。
	var marker := "/swf_png/"
	var marker_index := root.find(marker)
	if marker_index < 0:
		return null
	var relative := root.substr(marker_index + marker.length())
	var model := relative.get_slice("/", 0)
	var action := StringName(root.get_file())
	if model.is_empty() or action.is_empty():
		return null
	var frames_path := root.substr(0, marker_index + marker.length()).path_join(model)
	frames_path = frames_path.path_join("atlas").path_join("swf_png_%s_frames.tres" % model)
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null or not source.has_animation(action):
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"play")
	frames.set_animation_loop(&"play", looped)
	frames.set_animation_speed(&"play", fps)
	for frame_index in range(source.get_frame_count(action)):
		frames.add_frame(
			&"play", source.get_frame_texture(action, frame_index), source.get_frame_duration(action, frame_index)
		)
	return frames


static func get_frame_set(root: String, count: int, fps: float = SOURCE_FPS, looped: bool = true) -> SpriteFrames:
	var cache_key := "%s|%d|%.3f|%s" % [root, count, fps, str(looped)]
	if _frames_cache.has(cache_key):
		return _frames_cache[cache_key] as SpriteFrames
	var standard := _standard_frames_for(root, fps, looped)
	if standard != null:
		_frames_cache[cache_key] = standard
		return standard
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"play")
	frames.set_animation_loop(&"play", looped)
	frames.set_animation_speed(&"play", fps)
	if not root.is_empty():
		for frame_index in range(1, count + 1):
			var texture := Global.get_cached_texture(root.path_join(str(frame_index) + ".png"))
			if texture != null:
				frames.add_frame(&"play", texture)
	if frames.get_frame_count(&"play") == 0:
		frames.add_frame(&"play", null)
	_frames_cache[cache_key] = frames
	return frames


func _clear_visual_stream() -> void:
	_replace_visual_stream(null)


func _install_visual_stream(stream: StreamedPngEffect) -> void:
	var previous_stream := _visual_stream
	_visual_stream = stream
	stream.frame_ready.connect(_on_visual_stream_frame_ready.bind(stream, previous_stream), CONNECT_ONE_SHOT)
	middle.add_child(stream)
	if stream.has_displayed_frame():
		_commit_visual_stream(stream, previous_stream)


func _on_visual_stream_frame_ready(stream: StreamedPngEffect, previous_stream: StreamedPngEffect) -> void:
	_commit_visual_stream(stream, previous_stream)


func _commit_visual_stream(stream: StreamedPngEffect, previous_stream: StreamedPngEffect) -> void:
	if _visual_stream != stream or not is_instance_valid(stream):
		return
	bullet_ani.visible = false
	if previous_stream != null and previous_stream != stream and is_instance_valid(previous_stream):
		previous_stream.clear_texture()
		previous_stream.queue_free()


func _replace_visual_stream(next_stream: StreamedPngEffect) -> void:
	var previous_stream := _visual_stream
	if next_stream == null or previous_stream != next_stream:
		_visual_stream = next_stream
	if previous_stream != null and previous_stream != next_stream and is_instance_valid(previous_stream):
		previous_stream.clear_texture()
		previous_stream.queue_free()


func _is_swf_png_root(root: String) -> bool:
	return root.replace("\\", "/").begins_with("res://Art/monster/swf_png/")


func _exit_tree() -> void:
	_clear_visual_stream()

extends RoleBullet
class_name NeZhaSkillEffect

var effect_animation: StringName = &"effect1_2"
var life_seconds: float = 0.5
var hit_interval: float = 0.2
var max_hit_pulses: int = 1
var collision_size: Vector2 = Vector2(180, 100)
var move_velocity: Vector2 = Vector2.ZERO
var follow_target: Node2D
var follow_offset: Vector2 = Vector2.ZERO
var follow_target_facing: bool = false
var mirror_like_player: bool = false
var use_visual_collision: bool = false
var orbit_target: Node2D
var orbit_radii: Vector2 = Vector2(250, 25)
var orbit_offset: Vector2 = Vector2(0, -50)
var orbit_angle: float = 1.5 * PI
var orbit_speed: float = TAU

var _elapsed: float = 0.0
var _pulse_elapsed: float = 0.0
var _pulse_count: int = 1
var _rearming: bool = false
var _damage_exhausted: bool = false
var _visual_collision_visible: bool = true
var _followup_animation: StringName = &""


func configure(
	source: BaseHero,
	animation_name: StringName,
	hit_data: Dictionary,
	facing_right: bool,
	duration: float,
	interval: float,
	hit_pulses: int,
	shape_size: Vector2
) -> void:
	player = source
	effect_animation = animation_name
	hit_dic = hit_data.duplicate(true)
	direction = facing_right
	life_seconds = duration
	hit_interval = interval
	max_hit_pulses = maxi(1, hit_pulses)
	collision_size = shape_size


func _ready() -> void:
	var rectangle := collion.shape as RectangleShape2D
	if rectangle != null:
		rectangle = rectangle.duplicate() as RectangleShape2D
		rectangle.size = collision_size
		collion.shape = rectangle
	collion.disabled = hit_dic.is_empty() or float(hit_dic.get("power", 0.0)) <= 0.0
	bullet_player.frame_changed.connect(_update_visual_collision)
	bullet_player.animation_finished.connect(_on_effect_animation_finished)
	bullet_player.play(effect_animation)
	middle.scale = Vector2(_facing_scale(), 1.0)
	_update_visual_collision()
	if life_seconds > 0.0 and not bullet_player.sprite_frames.get_animation_loop(effect_animation):
		var animation_seconds := 0.0
		var animation_speed := bullet_player.sprite_frames.get_animation_speed(effect_animation)
		if animation_speed > 0.0:
			for frame_index in range(bullet_player.sprite_frames.get_frame_count(effect_animation)):
				animation_seconds += (
					bullet_player.sprite_frames.get_frame_duration(effect_animation, frame_index) / animation_speed
				)
			life_seconds = maxf(life_seconds, animation_seconds)


func _on_hit_box_area_entered(area: Area2D) -> void:
	super._on_hit_box_area_entered(area)
	if effect_animation != &"effect5_8" or not hit_dic.has("addeffect"):
		return
	var target := _get_monster_from_hit_area(area)
	if target == null or _is_summon_or_pet_target(target) or target.buff == null:
		return
	Global.add_buff(target.buff, hit_dic["addeffect"])


func _physics_process(delta: float) -> void:
	_elapsed += delta
	_pulse_elapsed += delta

	if is_instance_valid(orbit_target):
		global_position = (
			orbit_target.global_position
			+ orbit_offset
			+ Vector2(orbit_radii.x * cos(orbit_angle), orbit_radii.y * sin(orbit_angle))
		)
		_update_orbit_layer(orbit_angle)
		orbit_angle += orbit_speed * delta * (1.0 if direction else -1.0)
		if direction and orbit_angle >= TAU:
			orbit_angle -= TAU
		elif not direction and orbit_angle <= -TAU:
			orbit_angle += TAU
	elif is_instance_valid(follow_target):
		if follow_target_facing and follow_target is BaseHero:
			direction = follow_target.player_dir
			middle.scale.x = _facing_scale()
		global_position = (
			follow_target.global_position + Vector2(follow_offset.x if direction else -follow_offset.x, follow_offset.y)
		)
	elif follow_target != null:
		follow_target = null
	else:
		global_position += move_velocity * delta

	if not collion.disabled and hit_interval > 0.0 and _pulse_elapsed >= hit_interval:
		_pulse_elapsed -= hit_interval
		if _pulse_count >= max_hit_pulses:
			_damage_exhausted = true
			_refresh_collision_state()
		else:
			_pulse_count += 1
			_rearm_collision()

	if life_seconds > 0.0 and _elapsed >= life_seconds:
		queue_free()


func _rearm_collision() -> void:
	if _rearming or collion.disabled:
		return
	_rearming = true
	collion.set_deferred("disabled", true)
	await get_tree().physics_frame
	if is_inside_tree() and not is_queued_for_deletion():
		_rearming = false
		_refresh_collision_state()
		return
	_rearming = false


func play_with_followup(animation_name: StringName, followup_animation: StringName) -> void:
	_followup_animation = followup_animation
	bullet_player.play(animation_name)


func _on_effect_animation_finished() -> void:
	if _followup_animation == &"":
		return
	var next_animation := _followup_animation
	_followup_animation = &""
	bullet_player.play(next_animation)


func _facing_scale() -> float:
	if mirror_like_player:
		return -1.0 if direction else 1.0
	return 1.0 if direction else -1.0


func _update_orbit_layer(angle: float) -> void:
	if not is_instance_valid(orbit_target):
		return
	var behind_target := false
	if direction:
		behind_target = angle > PI and angle < TAU
	else:
		behind_target = angle < 0.0 and angle >= -PI
	z_index = orbit_target.z_index - 1 if behind_target else orbit_target.z_index + 1


func _update_visual_collision() -> void:
	if not use_visual_collision:
		return
	var texture := bullet_player.sprite_frames.get_frame_texture(bullet_player.animation, bullet_player.frame)
	var visible_size := Vector2.ZERO
	var visible_center := Vector2.ZERO
	if texture is AtlasTexture:
		var atlas := texture as AtlasTexture
		visible_size = atlas.region.size
		var full_size := atlas.region.size + atlas.margin.size
		visible_center = atlas.margin.position + visible_size * 0.5 - full_size * 0.5
	elif texture != null:
		visible_size = texture.get_size()
	_visual_collision_visible = visible_size.x > 1.0 and visible_size.y > 1.0
	if _visual_collision_visible:
		var rectangle := collion.shape as RectangleShape2D
		if rectangle != null:
			rectangle.size = visible_size
		collion.position = visible_center
	_refresh_collision_state()


func _refresh_collision_state() -> void:
	var has_damage := not hit_dic.is_empty() and float(hit_dic.get("power", 0.0)) > 0.0
	collion.set_deferred("disabled", not has_damage or _damage_exhausted or _rearming or not _visual_collision_visible)

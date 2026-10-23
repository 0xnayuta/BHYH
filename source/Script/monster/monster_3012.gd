extends BaseMonster
class_name WeiyangFlyingAxe

const ROOT := "res://Art/monster/swf_png/3012"
const SOURCE_FPS := 30.0
const FLY_SPEED := 50.0
const SCREEN_MARGIN := 100.0
const ATTACK_INTERVAL := 0.334
const FLIGHT_VISUAL_OFFSET := Vector2(3.05, 3.5)
const ATTACK_BODY_SIZE := Vector2(120.0, 60.0)

static var _frames_cache: SpriteFrames

var removed := false
var source_boss: Node
var _fly_direction := 1.0
var _flight_y := 0.0
var _spawn_position_captured := false
var _attack_timer: Timer


func _ready() -> void:
	_configure_axe()
	_build_frames()
	super._ready()
	monster_dir.visible = true
	mr_ani.visible = true
	mr_ani.play(&"attack")
	_configure_flying_collision()
	_start_attack_timer()


func try_play_default_animation() -> void:
	if mr_ani != null and mr_ani.sprite_frames != null and mr_ani.sprite_frames.has_animation(&"attack"):
		mr_ani.play(&"attack")


func _configure_axe() -> void:
	my_mr_name = "旋转斧头"
	level = 90
	attack_in = 18000
	max_hp = 1200000
	hp = max_hp
	def = 1200
	mdef = 1200
	crit = 0
	miss = 0
	lucky = 0
	htarget = 0
	toughness = 0.0
	crit_reduce = 0
	ar = 0
	sp = 0
	speed = FLY_SPEED
	mysee = 2000
	attack_range = 120
	attack_desire = 100
	behit_calmtime = 0.0
	self_rhp = 0
	add_exp = 0
	fall_coin = 0
	fall_pro = 0.0
	fall_stone_pro = 0.0
	fall_list = []
	fall_stone = []
	no_grav = true
	is_fly = true
	has_target = true
	cannot_attract = true
	no_target = false
	hit_name = "hit1"
	obj_attack_dict = {
		"hit1":
		{
			"power": int(attack_in * 0.5),
			"hurtBack": [0, 0],
			"sourceTargetMove": Vector2(120.0, 60.0),
			"attackKind": "physics",
			"HitProtect": 0,
		},
	}


func _build_frames() -> void:
	mr_ani.sprite_frames = _get_frames()
	mr_ani.centered = true
	mr_ani.flip_h = false
	mr_ani.position = FLIGHT_VISUAL_OFFSET


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3012_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null or not source.has_animation(&"attack1"):
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"attack")
	frames.set_animation_speed(&"attack", source.get_animation_speed(&"attack1"))
	frames.set_animation_loop(&"attack", true)
	for frame_index in range(source.get_frame_count(&"attack1")):
		frames.add_frame(&"attack", source.get_frame_texture(&"attack1", frame_index))
	return frames


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var standard := _load_standard_frames()
	if standard == null:
		push_error("WeiyangFlyingAxe standard frames missing: " + ROOT)
		standard = SpriteFrames.new()
	_frames_cache = standard
	return standard


func _physics_process(delta: float) -> void:
	if not removed:
		_capture_spawn_position()
		_update_flight_direction()
		_apply_flight_facing()
		velocity = Vector2(FLY_SPEED * _fly_direction, 0.0)
		is_attacking = true
	super._physics_process(delta)
	if not removed:
		position.y = _flight_y
		_apply_flight_facing()
		velocity = Vector2(FLY_SPEED * _fly_direction, 0.0)


func ai_think() -> void:
	if removed or death():
		return
	_update_flight_direction()
	_apply_flight_facing()
	velocity = Vector2(FLY_SPEED * _fly_direction, 0.0)


func _capture_spawn_position() -> void:
	if _spawn_position_captured:
		return
	_spawn_position_captured = true
	_flight_y = position.y


func _update_flight_direction() -> void:
	var bounds := _active_screen_bounds()
	if position.x <= bounds.x + SCREEN_MARGIN:
		_fly_direction = 1.0
	elif position.x >= bounds.y - SCREEN_MARGIN:
		_fly_direction = -1.0


func _apply_flight_facing() -> void:
	monster_direction = _fly_direction > 0.0
	mr_ani.flip_h = _fly_direction < 0.0


func _active_screen_bounds() -> Vector2:
	var level_node := get_level_node()
	if level_node != null and "my_camera" in level_node:
		var camera = level_node.get("my_camera")
		if camera != null and is_instance_valid(camera):
			var left_value = camera.get("max_left")
			var right_value = camera.get("max_right")
			if left_value != null and right_value != null:
				var left := float(left_value)
				var right := float(right_value)
				if right - left > SCREEN_MARGIN * 2.0:
					return Vector2(left, right)
	return Vector2(position.x - 600.0, position.x + 600.0)


func _configure_flying_collision() -> void:
	collision_layer = 0
	collision_mask = 0
	if pz != null:
		pz.set_deferred("disabled", true)
	var attack_shape := RectangleShape2D.new()
	attack_shape.size = ATTACK_BODY_SIZE
	hit_box.shape = attack_shape
	hit_box.position = Vector2.ZERO
	hit_box.set_deferred("disabled", false)
	var receive_shape := RectangleShape2D.new()
	receive_shape.size = ATTACK_BODY_SIZE
	hurt_box.shape = receive_shape
	hurt_box.position = Vector2.ZERO
	hurt_box.set_deferred("disabled", false)


func _start_attack_timer() -> void:
	_attack_timer = Timer.new()
	_attack_timer.name = "OriginalAttackInterval"
	_attack_timer.wait_time = ATTACK_INTERVAL
	_attack_timer.one_shot = false
	_attack_timer.timeout.connect(_restart_attack_overlap)
	add_child(_attack_timer)
	_attack_timer.start()


func _restart_attack_overlap() -> void:
	if removed or hit_box == null:
		return
	hit_box.set_deferred("disabled", true)
	_reenable_attack_box_after_physics_frame()


func _reenable_attack_box_after_physics_frame() -> void:
	await get_tree().physics_frame
	if is_instance_valid(self) and not removed and hit_box != null:
		hit_box.set_deferred("disabled", false)


func is_control_immune() -> bool:
	return super.is_control_immune()


func state_death() -> void:
	remove_from_battle()


func remove_from_battle() -> void:
	if removed or is_queued_for_deletion():
		return
	removed = true
	is_death = true
	is_attacking = false
	is_be_attacking = false
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	if _attack_timer != null:
		_attack_timer.stop()
	if hit_box != null:
		hit_box.set_deferred("disabled", true)
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	queue_free()


func monster_info_base_attack() -> int:
	return attack_in


func monster_info_attack_values_include_difficulty() -> bool:
	return false

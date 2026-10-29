extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/nanhai_projectile.gd")
const SOURCE_FPS := 30.0
const AI_DELAY_MSEC := 1000
const SKILL1_DASH_FRAME := 25
const SKILL1_DASH_DURATION := 0.4
const SKILL1_DASH_SPEED := 300.0

const ACTIONS := {
	&"wait": {"sequence": "wait", "frames": 26, "loop": true},
	&"walk": {"sequence": "walk", "frames": 24, "loop": true},
	&"hurt": {"sequence": "hurt", "frames": 35, "loop": false},
	&"skill1": {"sequence": "skill1", "frames": 90, "loop": false},
	&"skill2": {"sequence": "skill2", "frames": 44, "loop": false},
	&"skill3": {"sequence": "skill3", "frames": 35, "loop": false},
	&"death": {"sequence": "death", "frames": 35, "loop": false},
}

var _body_sprite: AnimatedSprite2D
static var _frames_cache: SpriteFrames
var _busy := false
var _death_started := false
var _skill_cycle := 0
var _attack_serial := 0
var _next_attack_msec := 0
var _skill_direction := 1.0
var _skill1_dash_active := false
var _skill1_dash_time_left := 0.0


func _ready() -> void:
	_bind_base_nodes()
	_configure_test_boss()
	_build_animations()
	_setup_body_sprite()
	mr_ani.visible = false
	super._ready()


func _bind_base_nodes() -> void:
	mr_player = get_node("mr_player") as AnimationPlayer
	mr_ani = get_node("MonsterDir/mr_ani") as AnimatedSprite2D
	monster_dir = get_node("MonsterDir") as Node2D
	base_damage_box = get_node("BaseDamageBox") as Node2D
	hit_box = get_node("BaseDamageBox/HitBox/HitBox") as CollisionShape2D
	hurt_box = get_node("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	pz = get_node("pz") as CollisionShape2D


func _configure_test_boss() -> void:
	is_boss = true
	my_mr_name = "3370 Boss测试"
	level = 1
	attack_in = 1800
	max_hp = 500000
	hp = max_hp
	def = 300
	mdef = 300
	crit = 100
	miss = 0
	lucky = 0
	htarget = 100
	toughness = 0.0
	crit_reduce = 0
	ar = 0
	sp = 0
	speed = 6.0
	mysee = 650
	attack_range = 560
	attack_desire = 100
	behit_calmtime = 0.0
	self_rhp = 0
	add_exp = 0
	fall_coin = 0
	fall_pro = 0.0
	fall_stone_pro = 0.0
	obj_attack_dict.clear()
	obj_attack_dict["hit1"] = _attack_data(1.0, [-3, -4], "physics")
	obj_attack_dict["hit2"] = _attack_data(1.0, [-4, -3], "physics")
	obj_attack_dict["hit3"] = _attack_data(1.0, [-2, -2], "magic")


func _attack_data(multiplier: float, hurt_back: Array, attack_kind: String) -> Dictionary:
	return {
		"power": roundi(float(attack_in) * multiplier),
		"hurtBack": hurt_back.duplicate(),
		"attackKind": attack_kind,
		"HitProtect": 10,
	}


func _build_animations() -> void:
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name: StringName in ACTIONS:
		var info: Dictionary = ACTIONS[action_name]
		var animation := _make_animation(action_name, int(info["frames"]), bool(info["loop"]))
		match action_name:
			&"skill1":
				_add_method_key(animation, _frame_time(SKILL1_DASH_FRAME), &"_start_skill1_dash")
				_add_method_key(animation, _frame_time(90), &"_disable_attack_box")
			&"skill2":
				_add_method_key(animation, _frame_time(22), &"_set_skill2_hit_box", [1])
				_add_method_key(animation, _frame_time(27), &"_set_skill2_hit_box", [2])
				_add_method_key(animation, _frame_time(29), &"_set_skill2_hit_box", [3])
				_add_method_key(animation, _frame_time(32), &"_disable_attack_box")
			&"skill3":
				_add_method_key(animation, _frame_time(12), &"_spawn_skill3_field")
			&"death":
				_add_method_key(animation, animation.length - 0.01, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = float(frame_count) / SOURCE_FPS
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_body_action", [action_name])
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


func _play_body_action(action_name: StringName) -> void:
	if _body_sprite == null or not is_instance_valid(_body_sprite):
		return
	var info: Dictionary = ACTIONS.get(action_name, ACTIONS[&"wait"])
	if _body_sprite.sprite_frames == null:
		_body_sprite.sprite_frames = _get_sprite_frames()
	if not _body_sprite.sprite_frames.has_animation(action_name):
		return
	_body_sprite.animation = action_name
	_body_sprite.frame = 0
	_body_sprite.play(action_name)


func _setup_body_sprite() -> void:
	_body_sprite = get_node_or_null("MonsterDir/SpriteBody") as AnimatedSprite2D
	if _body_sprite == null:
		_body_sprite = AnimatedSprite2D.new()
		_body_sprite.name = "SpriteBody"
		monster_dir.add_child(_body_sprite)
	_body_sprite.position = Vector2.ZERO
	_body_sprite.z_index = -47
	_body_sprite.centered = true
	_body_sprite.sprite_frames = _get_sprite_frames()


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := "res://Art/monster/swf_png/3370/atlas/swf_png_3370_frames.tres"
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames


func _get_sprite_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var standard := _load_standard_frames()
	if standard != null:
		_frames_cache = standard
		return standard
	return null


func ai_think() -> void:
	if _busy or death() or RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	var distance := absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - global_position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	_face_role()
	if Time.get_ticks_msec() < _next_attack_msec:
		if distance > 220.0:
			_move_toward_role()
		else:
			stop_move()
		return
	var skill_index := _next_skill(distance)
	if skill_index == 0:
		_move_toward_role()
		return
	_start_skill(skill_index)


func _next_skill(distance: float) -> int:
	var candidate := (_skill_cycle % 3) + 1
	if candidate == 1 and distance <= 220.0:
		return candidate
	if candidate == 2 and distance <= 560.0:
		return candidate
	if candidate == 3 and distance <= float(attack_range):
		return candidate
	return 0


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_skill_cycle = skill_index % 3
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	_face_role()
	hit_name = "hit%d" % skill_index
	_disable_attack_box()
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_finish_skill1_dash()
	_disable_attack_box()
	_busy = false
	is_attacking = false
	_next_attack_msec = Time.get_ticks_msec() + AI_DELAY_MSEC
	mr_player.play(&"wait")


func _set_skill1_hit(enabled: bool) -> void:
	hit_name = "hit1"
	_set_attack_box(Vector2(359.0, 191.0), Vector2(-25.0, -62.0))
	if enabled:
		_enable_attack_box()
	else:
		_disable_attack_box()


func _start_skill1_dash() -> void:
	if death() or not _busy:
		return
	_set_skill1_hit(true)
	_skill1_dash_active = true
	_skill1_dash_time_left = SKILL1_DASH_DURATION
	velocity.x = SKILL1_DASH_SPEED * _skill_direction


func _finish_skill1_dash() -> void:
	_skill1_dash_active = false
	_skill1_dash_time_left = 0.0
	velocity.x = 0.0


func _set_skill2_hit_box(stage: int) -> void:
	hit_name = "hit2"
	match stage:
		1:
			_set_attack_box(Vector2(436.0, 106.0), Vector2(-280.5, -52.5))
		2:
			_set_attack_box(Vector2(498.0, 106.0), Vector2(-311.5, -52.5))
		3:
			_set_attack_box(Vector2(363.0, 106.0), Vector2(-244.0, -52.5))
	_enable_attack_box()


func _spawn_skill3_field() -> void:
	if death() or not _busy:
		return
	var projectile := PROJECTILE_SCRIPT.new() as NanhaiProjectile
	var spawn_position := _official_skill3_position()
	(
		projectile
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": true,
				"hit_name": "hit3",
				"attack_data": (obj_attack_dict["hit3"] as Dictionary).duplicate(true),
				"skill_name": "Monster3370Effect3Field",
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"visual_offset": Vector2(0.0, -58.0),
				"collision_size": Vector2(342.25, 189.2),
				"collision_offset": Vector2(8.425, -72.0),
				"lifetime": 25.0 / SOURCE_FPS,
				"damage_duration": 25.0 / SOURCE_FPS,
				"hit_interval": 0.0,
				"max_hits": 1,
				"expire_on_hit": false,
				"damage_enabled": true,
			}
		)
	)
	bullet.add_child(projectile)


func _official_skill3_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var camera := get_viewport().get_camera_2d()
	if camera == null or viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return global_position + Vector2(randf_range(-245.0, 245.0), 0.0)
	var zoom_value := camera.zoom
	var world_size := Vector2(
		viewport_size.x / maxf(absf(zoom_value.x), 0.001), viewport_size.y / maxf(absf(zoom_value.y), 0.001)
	)
	var screen_center := camera.get_screen_center_position()
	var screen_top_left := screen_center - world_size * 0.5
	return Vector2(
		screen_top_left.x + world_size.x * randf_range(362.0 / 940.0, 852.0 / 940.0),
		screen_top_left.y + world_size.y * randf_range(300.0 / 590.0, 500.0 / 590.0)
	)


func _set_attack_box(box_size: Vector2, box_position: Vector2) -> void:
	if hit_box == null:
		return
	var rectangle := hit_box.shape as RectangleShape2D
	if rectangle == null:
		rectangle = RectangleShape2D.new()
		hit_box.shape = rectangle
	rectangle.size = box_size
	hit_box.position = box_position


func _enable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _face_role() -> void:
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	if float(RoleProp.get_nearest_monster_target_position(global_position).x) >= global_position.x:
		_skill_direction = 1.0
		monster_dir.scale.x = 1.0
		base_damage_box.scale.x = -1.0
	else:
		_skill_direction = -1.0
		monster_dir.scale.x = -1.0
		base_damage_box.scale.x = 1.0


func _move_toward_role() -> void:
	_face_role()
	velocity.x = speed * 10.0 * _skill_direction
	mr_player.play(&"walk")


func _physics_process(delta: float) -> void:
	if _skill1_dash_active and not death():
		velocity.x = SKILL1_DASH_SPEED * _skill_direction
	super._physics_process(delta)
	if _skill1_dash_active:
		_skill1_dash_time_left -= delta
		if death() or _skill1_dash_time_left <= 0.0:
			_finish_skill1_dash()


func state_hurt() -> void:
	if death() or _busy:
		return
	super.state_hurt()


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_attack_serial += 1
	_busy = true
	_finish_skill1_dash()
	_disable_attack_box()
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_frames_cache = null

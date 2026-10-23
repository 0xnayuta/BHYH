extends BaseMonster

const BODY_FRAMES_PATH := "res://Art/monster/hun_dun/hun_dun_frames.tres"
const BODY_FRAME_COLUMNS := 6
const SOURCE_FPS := 24.0
const BODY_SPRITE_POSITION := Vector2(-16, -78)
const EFFECT_ROOT := "res://Art/monster/hun_dun/effects"
const EFFECT_NAMES := ["monster_60_bullet_1", "monster_60_bullet_2", "monster_60_bullet_3"]
static var _effect_frames_cache: Dictionary = {}
static var _effect_prewarm_started := false

var bullet1_height := -90.0
var bullet2_height := -100.0
var bullet3_height := -70.0

const BULLET_DISTANCE := 160.0
const CHARGE_SPEED := 15.0 * SOURCE_FPS
const CHARGE_DURATION := 2.0

var _skill_busy := false
var _charging := false
var _charge_direction := 1.0
var _charge_time_left := 0.0
var _charge_heal_tokens: Dictionary = {}


func _ready() -> void:
	_configure_hundun()
	_build_original_animations()
	super._ready()
	skill_1_cd = randi_range(5, 10)
	skill_2_cd = randi_range(6, 12)


func _configure_hundun() -> void:
	is_boss = true
	cannot_attract = true
	set_meta("allow_role_special_control", true)
	my_mr_name = "混沌"
	attack_in = 250
	level = max(40, RoleProp.baseroleprop.Level + 3)
	max_hp = 2500000
	hp = max_hp
	def = 233
	mdef = 233
	crit = 55
	miss = 15
	lucky = 10
	htarget = 100
	toughness = 20
	speed = 15
	mysee = 1000
	attack_range = 250
	attack_desire = 95
	behit_calmtime = 0.15
	self_rhp = 0
	add_exp = 500
	fall_coin = 2000
	fall_pro = 0.5
	fall_list = [{"name": "xssp", "value": 1}]
	self.independent_fall_list = [{"name": "lingliguo", "value": 1, "chance": 0.1}]
	fall_stone_pro = 0.0
	fall_stone = []
	obj_attack_dict["hit1"] = {"power": 1500, "hurtBack": [6, -5], "attackKind": "physics", "HitProtect": 8}
	obj_attack_dict["hit2"] = {"power": 800, "hurtBack": [6, -5], "attackKind": "physics", "HitProtect": 8}
	obj_attack_dict["hit3"] = {"power": 800, "hurtBack": [6, -5], "attackKind": "magic", "HitProtect": 8}


func _build_original_animations() -> void:
	var frames := load(BODY_FRAMES_PATH) as SpriteFrames
	if frames == null or not frames.has_animation(&"atlas"):
		push_error("SSSL boss standard frames failed to load: " + BODY_FRAMES_PATH)
		return
	mr_ani.sprite_frames = frames
	mr_ani.animation = &"atlas"
	mr_ani.centered = true
	mr_ani.position = BODY_SPRITE_POSITION

	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_action(0, [2, 2, 2, 3, 2, 4], true))
	library.add_animation(&"walk", _make_action(1, [4, 4, 4, 4], true))
	library.add_animation(&"hurt", _make_action(2, [8], false))

	var death_animation := _make_action(3, [2, 2, 2, 9], false)
	_add_standard_death_methods(death_animation)
	library.add_animation(&"death", death_animation)

	var hit1_animation := _make_action(4, [2, 2, 2, 10], false)
	_add_method_key(hit1_animation, 15.0 / SOURCE_FPS, &"_spawn_hit1")
	library.add_animation(&"hit1", hit1_animation)

	var hit2_animation := _make_action(5, [24, 24], false)
	_add_method_key(hit2_animation, 0.01, &"_begin_hit2_charge")
	library.add_animation(&"hit2", hit2_animation)

	var hit3_animation := _make_action(6, [2, 2, 10], false)
	_add_method_key(hit3_animation, 13.0 / SOURCE_FPS, &"_spawn_hit3")
	library.add_animation(&"hit3", hit3_animation)
	mr_player.add_animation_library(&"", library)


func _make_action(row: int, holds: Array, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, NodePath("MonsterDir/mr_ani:frame"))
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	var time := 0.0
	for column in range(holds.size()):
		animation.track_insert_key(frame_track, time, row * BODY_FRAME_COLUMNS + column)
		time += float(holds[column]) / SOURCE_FPS
	animation.length = maxf(time, 0.05)
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(method_track, minf(time, animation.length - 0.001), {"method": method_name, "args": []})


func _add_standard_death_methods(animation: Animation) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	var finish_time := animation.length - 0.001
	animation.track_insert_key(method_track, finish_time, {"method": &"settle_death_drops_and_free", "args": []})


func _physics_process(delta: float) -> void:
	if _charging and not death():
		_charge_time_left -= delta
		velocity.x = _charge_direction * CHARGE_SPEED
		if _charge_time_left <= 0.0:
			_charging = false
			velocity.x = 0.0
	super._physics_process(delta)


func ai_think() -> void:
	if absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if is_limit_buff() or cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	if not has_target:
		normal_state()
		return
	var distance := absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	if skill_2_cd <= 0 and distance <= 700.0:
		_use_skill(&"hit3", randi_range(6, 12))
	elif skill_1_cd <= 0 and distance <= 520.0:
		_use_skill(&"hit2", randi_range(5, 10))
	elif distance <= attack_range:
		stop_move()
		if count % 45 == 0 and randi_range(0, 100) <= attack_desire:
			attack_target()
	else:
		have_target()


func _use_skill(animation_name: StringName, cooldown: int) -> void:
	if _skill_busy or is_attacking:
		return
	_skill_busy = true
	super.to_hero()
	if animation_name == &"hit2":
		skill_1_cd = cooldown
	elif animation_name == &"hit3":
		skill_2_cd = cooldown
	hit_name = String(animation_name)
	velocity.x = 0.0
	is_attacking = true
	mr_player.play(animation_name)
	await mr_player.animation_finished
	_charging = false
	if death():
		return
	velocity.x = 0.0
	is_attacking = false
	_skill_busy = false
	stop_move()


func _spawn_hit1() -> void:
	hit_name = "hit1"
	_spawn_attack_effect(
		"monster_60_bullet_1", Vector2(_front_x(BULLET_DISTANCE), bullet1_height), Vector2(210, 100), 0.8, false
	)


func _begin_hit2_charge() -> void:
	hit_name = "hit2"
	var lost_hp_power := maxi(500, int((max_hp - hp) / 60.0))
	obj_attack_dict["hit2"]["power"] = lost_hp_power
	_charge_direction = 1.0 if _faces_right() else -1.0
	_charge_time_left = CHARGE_DURATION
	_charging = true
	_charge_heal_tokens.clear()
	_spawn_attack_effect(
		"monster_60_bullet_2",
		Vector2(_front_x(BULLET_DISTANCE), bullet2_height),
		Vector2(330, 190),
		CHARGE_DURATION,
		true
	)


func _spawn_hit3() -> void:
	hit_name = "hit3"
	_spawn_attack_effect(
		"monster_60_bullet_3", Vector2(_front_x(BULLET_DISTANCE), bullet3_height), Vector2(610, 150), 1.65, false
	)


func _faces_right() -> bool:
	return monster_dir.scale.x < 0.0


func _front_x(distance: float) -> float:
	return distance if _faces_right() else -distance


func _spawn_attack_effect(
	effect_name: String, local_position: Vector2, hit_size: Vector2, lifetime: float, heal_on_hit: bool
) -> void:
	var holder := Node2D.new()
	holder.name = effect_name
	holder.position = local_position
	add_child(holder)

	var sprite := StreamedPngEffect.new()
	sprite.frame_paths = _effect_frame_paths(effect_name)
	sprite.fps = SOURCE_FPS
	sprite.loop_animation = effect_name == "monster_60_bullet_2"
	sprite.flip_h = _faces_right()
	sprite.z_index = 5
	holder.add_child(sprite)

	var area := Area2D.new()
	area.name = "HitBox"
	area.collision_layer = 4
	area.collision_mask = 896
	area.monitoring = true
	area.monitorable = false
	holder.add_child(area)
	area.area_entered.connect(_on_effect_hurt_box_entered.bind(area, heal_on_hit))

	var shape_node := CollisionShape2D.new()
	shape_node.name = "HitBox"
	var shape := RectangleShape2D.new()
	shape.size = hit_size
	shape_node.shape = shape
	area.add_child(shape_node)

	get_tree().create_timer(lifetime, false).timeout.connect(_free_effect_holder.bind(holder, sprite))


func _free_effect_holder(holder: Node2D, sprite: Node) -> void:
	if sprite != null and is_instance_valid(sprite):
		if sprite.has_method("clear_texture"):
			sprite.call("clear_texture")
		elif sprite is AnimatedSprite2D:
			(sprite as AnimatedSprite2D).sprite_frames = null
	if holder != null and is_instance_valid(holder):
		holder.queue_free()


func _on_effect_hurt_box_entered(hurt_area: Area2D, attack_area: Area2D, heal_on_hit: bool) -> void:
	if not is_instance_valid(hurt_area) or not is_instance_valid(attack_area):
		return
	var damage_target := hurt_area.get_parent().get_parent()
	if damage_target == null or not damage_target.has_method("_on_hurt_box_area_entered"):
		return
	damage_target.call("_on_hurt_box_area_entered", attack_area)
	if heal_on_hit:
		var token := damage_target.get_instance_id()
		if not _charge_heal_tokens.has(token):
			_charge_heal_tokens[token] = true
			cure_hp(int((max_hp - hp) / 60.0))


func _new_effect_frames(effect_name: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"play")
	frames.set_animation_loop(&"play", effect_name == "monster_60_bullet_2")
	frames.set_animation_speed(&"play", SOURCE_FPS)
	return frames


func _effect_file_names(effect_name: String) -> Array[String]:
	var names: Array[String] = []
	var directory_path := EFFECT_ROOT + "/" + effect_name
	var directory := DirAccess.open(directory_path)
	if directory != null:
		for file_name in directory.get_files():
			if file_name.ends_with(".png"):
				names.append(file_name)
	if names.is_empty():
		_append_numbered_effect_file_names(names, directory_path)
	names.sort_custom(func(a: String, b: String): return a.naturalnocasecmp_to(b) < 0)
	return names


func _effect_frame_paths(effect_name: String) -> Array[String]:
	var result: Array[String] = []
	var directory_path := EFFECT_ROOT + "/" + effect_name
	for file_name in _effect_file_names(effect_name):
		result.append(directory_path + "/" + file_name)
	return result


func _append_numbered_effect_file_names(names: Array[String], directory_path: String) -> void:
	var missing_streak := 0
	for index in range(601):
		var file_name := str(index) + ".png"
		if ResourceLoader.exists(directory_path + "/" + file_name):
			names.append(file_name)
			missing_streak = 0
		elif not names.is_empty():
			missing_streak += 1
			if missing_streak >= 30:
				break


func _load_effect_frames(effect_name: String) -> SpriteFrames:
	var frames := _new_effect_frames(effect_name)
	var directory_path: String = EFFECT_ROOT + "/" + effect_name
	for file_name in _effect_file_names(effect_name):
		var texture := Global.get_cached_texture(directory_path + "/" + file_name)
		frames.add_frame(&"play", texture)
	return frames


func _prewarm_effect_frames() -> void:
	pass

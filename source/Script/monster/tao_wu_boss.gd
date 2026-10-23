extends BaseMonster

const BODY_FRAMES_PATH := "res://Art/monster/tao_wu/tao_wu_frames.tres"
const BODY_ANIMATION := &"Monster47FramesCenteredCropped"
const BODY_FRAME_COLUMNS := 6
const FALLBACK_BODY_TEXTURE := "res://Art/monster/tao_wu/monster47.png"
const SOURCE_FPS := 24.0

const BODY_SPRITE_POSITION := Vector2(2, -104)
const EFFECT_NAMES := [
	"Monster47Bullet1",
	"Monster47Bullet2_1",
	"Monster47Bullet2_2",
	"Monster47Bullet2_3",
	"Monster47Bullet3",
	"Monster47Bullet4"
]

var bullet1_height := -104.0
var bullet2_1_height := -34.0
var bullet2_2_height := -99.0
var bullet2_3_height := -144.0
var bullet3_height := -30.0
var bullet4_height := -149.0

const BULLET1_DISTANCE := 300.0
const BULLET2_1_DISTANCE := 300.0
const BULLET2_2_DISTANCE := 300.0
const BULLET2_3_DISTANCE := 300.0
const BULLET3_DISTANCE := 180.0
const BULLET4_DISTANCE := 100.0

var _skill_busy := false


func _ready() -> void:
	_configure_taowu()
	_build_original_animations()
	super._ready()
	skill_1_cd = 8
	skill_2_cd = 9
	skill_3_cd = randi_range(10, 20)


func _configure_taowu() -> void:
	is_boss = true
	cannot_attract = true
	set_meta("allow_role_special_control", true)
	my_mr_name = "梼杌"
	attack_in = 250
	level = max(40, RoleProp.baseroleprop.Level + 3)
	max_hp = 2500000
	hp = max_hp
	def = 200
	mdef = 200
	crit = 55
	miss = 15
	lucky = 10
	htarget = 100
	toughness = 20
	ar = 0
	sp = 0
	crit_reduce = 0
	speed = 15
	mysee = 1000
	attack_range = 250
	attack_desire = 95
	behit_calmtime = 0.15
	self_rhp = 0
	add_exp = 500
	fall_coin = 2000
	fall_pro = 0.5
	fall_list = [{"name": "wpzz", "value": 1}]
	self.independent_fall_list = [{"name": "genguguo", "value": 1, "chance": 0.1}]
	fall_stone_pro = 0.0
	fall_stone = []
	obj_attack_dict["hit1"] = {"power": 800, "hurtBack": [0, -5], "attackKind": "magic", "HitProtect": 8}
	obj_attack_dict["hit2"] = {
		"power": 800,
		"hurtBack": [-5, 0],
		"attackKind": "physics",
		"HitProtect": 6,
		"addeffect":
		{
			"Name": "speed_down",
			"DeBuff": true,
			"CanAdd": true,
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 45,
			"AttackKind": ""
		}
	}
	obj_attack_dict["hit3"] = {
		"power": 800,
		"hurtBack": [-4, 0],
		"attackKind": "magic",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "poision",
			"DeBuff": true,
			"CanAdd": true,
			"AddTime": 5,
			"reduce_interval": 1,
			"value": 90,
			"AttackKind": "real"
		}
	}
	obj_attack_dict["hit4"] = {"power": 800, "hurtBack": [-4, 0], "attackKind": "magic", "HitProtect": 8}


func _build_original_animations() -> void:
	var frames := load(BODY_FRAMES_PATH) as SpriteFrames
	if frames == null or not frames.has_animation(BODY_ANIMATION):
		# 标准资源异常时仅保留单图兜底；正常路径始终使用预生成 SpriteFrames。
		frames = SpriteFrames.new()
		frames.remove_animation(&"default")
		frames.add_animation(&"atlas")
		frames.set_animation_loop(&"atlas", false)
		var sheet := load(FALLBACK_BODY_TEXTURE) as Texture2D
		if sheet != null:
			frames.add_frame(&"atlas", sheet)
		if frames.get_frame_count(&"atlas") == 0:
			push_warning("SSSL boss body frames failed to load: " + BODY_FRAMES_PATH)
	mr_ani.sprite_frames = frames
	mr_ani.animation = BODY_ANIMATION if frames.has_animation(BODY_ANIMATION) else &"atlas"
	mr_ani.frame = 0
	mr_ani.centered = true
	mr_ani.position = BODY_SPRITE_POSITION

	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_action(0, [2, 2, 2, 3, 2, 4], true))
	library.add_animation(&"walk", _make_action(1, [4, 4, 4, 4], true))
	library.add_animation(&"hurt", _make_action(2, [8], false))

	var death_animation := _make_action(3, [2, 2, 2, 2, 10], false)
	_add_standard_death_methods(death_animation)
	library.add_animation(&"death", death_animation)

	var hit1_animation := _make_action(4, [2, 2, 2, 10], false)
	_add_method_key(hit1_animation, 15.0 / SOURCE_FPS, &"_spawn_hit1")
	library.add_animation(&"hit1", hit1_animation)

	var hit2_animation := _make_action(5, [2, 2, 10], false)
	_add_method_key(hit2_animation, 13.0 / SOURCE_FPS, &"_spawn_hit2")
	library.add_animation(&"hit2", hit2_animation)

	var hit3_animation := _make_action(6, [2, 2, 10], false)
	_add_method_key(hit3_animation, 13.0 / SOURCE_FPS, &"_spawn_hit3")
	library.add_animation(&"hit3", hit3_animation)

	var hit4_animation := _make_action(7, [2, 2, 10], false)
	_add_method_key(hit4_animation, 13.0 / SOURCE_FPS, &"_spawn_hit4")
	library.add_animation(&"hit4", hit4_animation)
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


func play_hit_effect(attacker = null) -> void:
	_interrupt_attack_state_on_hit()
	Global.add_special_effect(self, Vector2(0, -92), "RoleBeHit", Vector2(1, 1), false, 1)
	if PlayerData.player_data["Myself"] != 2:
		Global.add_sound(self, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
	else:
		Global.add_sound(self, "res://Music/hero/9_beattack_by_role2.mp3")
	if not death() and mr_player.has_animation("hurt"):
		call_deferred("_deferred_play_hurt_animation")


func _interrupt_attack_state_on_hit() -> void:
	_skill_busy = false
	super._interrupt_attack_state_on_hit()


func ai_think() -> void:
	if absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if is_limit_buff() or cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	if not has_target:
		normal_state()
		return
	var distance := absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	if skill_3_cd <= 0:
		_use_skill(&"hit4", randi_range(10, 20))
	elif skill_2_cd <= 0 and distance <= 650.0:
		_use_skill(&"hit3", 9)
	elif skill_1_cd <= 0 and distance <= 360.0:
		_use_skill(&"hit2", 8)
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
	match animation_name:
		&"hit2":
			skill_1_cd = cooldown
		&"hit3":
			skill_2_cd = cooldown
		&"hit4":
			skill_3_cd = cooldown
	hit_name = String(animation_name)
	velocity.x = 0
	is_attacking = true
	mr_player.play(animation_name)
	await mr_player.animation_finished
	if death():
		return
	is_attacking = false
	_skill_busy = false
	stop_move()


func _spawn_hit1() -> void:
	hit_name = "hit1"
	_spawn_attack_effect(
		"Monster47Bullet1", Vector2(_front_x(BULLET1_DISTANCE), bullet1_height), Vector2(190, 90), 0.75
	)


func _spawn_hit2() -> void:
	hit_name = "hit2"
	_spawn_visual_effect("Monster47Bullet2_1", Vector2(_front_x(BULLET2_1_DISTANCE), bullet2_1_height))
	_spawn_visual_effect("Monster47Bullet2_2", Vector2(_front_x(BULLET2_2_DISTANCE), bullet2_2_height))
	_spawn_attack_effect(
		"Monster47Bullet2_3", Vector2(_front_x(BULLET2_3_DISTANCE), bullet2_3_height), Vector2(280, 230), 0.7
	)


func _spawn_hit3() -> void:
	hit_name = "hit3"
	_spawn_attack_effect(
		"Monster47Bullet3", Vector2(_front_x(BULLET3_DISTANCE), bullet3_height), Vector2(520, 250), 1.25
	)


func _spawn_hit4() -> void:
	hit_name = "hit4"
	_spawn_attack_effect(
		"Monster47Bullet4", Vector2(_front_x(BULLET4_DISTANCE), bullet4_height), Vector2(720, 440), 10.0, false, false
	)


func _faces_right() -> bool:
	return monster_dir.scale.x < 0.0


func _front_x(distance: float) -> float:
	return distance if _faces_right() else -distance


func _spawn_visual_effect(effect_name: String, local_position: Vector2) -> void:
	_spawn_attack_effect(effect_name, local_position, Vector2.ZERO, 0.8)


func _spawn_attack_effect(
	effect_name: String,
	effect_position: Vector2,
	hit_size: Vector2,
	lifetime: float,
	use_global_position := false,
	follow_player := false
) -> void:
	var holder := Node2D.new()
	holder.name = effect_name
	add_child(holder)
	if use_global_position:
		holder.global_position = effect_position
	else:
		holder.position = effect_position

	var standard_frames := load(BODY_FRAMES_PATH) as SpriteFrames
	var effect_animation := StringName("Effects/" + effect_name)
	var sprite: Node2D
	if standard_frames != null and standard_frames.has_animation(effect_animation):
		var animated := AnimatedSprite2D.new()
		animated.sprite_frames = standard_frames
		animated.animation = effect_animation
		animated.flip_h = _faces_right()
		animated.z_index = 5
		animated.play()
		sprite = animated
	else:
		push_error("tao_wu standard effect frames missing: " + effect_name)
		return
	holder.add_child(sprite)

	if hit_size != Vector2.ZERO:
		var area := Area2D.new()
		area.name = "HitBox"

		area.collision_layer = 4
		area.collision_mask = 896
		area.monitoring = true
		area.monitorable = false
		holder.add_child(area)
		area.area_entered.connect(_on_effect_hurt_box_entered.bind(area))
		var shape_node := CollisionShape2D.new()
		shape_node.name = "HitBox"
		var shape := RectangleShape2D.new()
		shape.size = hit_size
		shape_node.shape = shape
		area.add_child(shape_node)
		if lifetime > 1.5:
			_pulse_effect_hitbox(shape_node, holder, lifetime, follow_player)
		elif follow_player:
			_follow_effect_target(holder, lifetime)

	get_tree().create_timer(lifetime, false).timeout.connect(_free_effect_holder.bind(holder, sprite))


func _free_effect_holder(holder: Node2D, sprite: Node) -> void:
	if sprite != null and is_instance_valid(sprite):
		if sprite.has_method("clear_texture"):
			sprite.call("clear_texture")
		elif sprite is AnimatedSprite2D:
			(sprite as AnimatedSprite2D).sprite_frames = null
	if holder != null and is_instance_valid(holder):
		holder.queue_free()


func _on_effect_hurt_box_entered(hurt_area: Area2D, attack_area: Area2D) -> void:
	if not is_instance_valid(hurt_area) or not is_instance_valid(attack_area):
		return
	var damage_target := hurt_area.get_parent().get_parent()
	if damage_target == null or not damage_target.has_method("_on_hurt_box_area_entered"):
		return

	super._on_hit_box_area_entered(hurt_area)
	damage_target.call("_on_hurt_box_area_entered", attack_area)


func _pulse_effect_hitbox(shape_node: CollisionShape2D, holder: Node2D, lifetime: float, follow_player: bool) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var elapsed := 0.0
	while elapsed < lifetime and is_instance_valid(holder):
		if not is_inside_tree() or is_queued_for_deletion() or not is_instance_valid(shape_node):
			return
		if follow_player and get_player != null and is_instance_valid(get_player):
			holder.global_position = (
				RoleProp.get_nearest_monster_target_position(global_position) + Vector2(0, bullet4_height)
			)
		shape_node.set_deferred("disabled", false)
		await tree.physics_frame
		if not is_instance_valid(holder) or not is_instance_valid(shape_node):
			return
		shape_node.set_deferred("disabled", true)
		await tree.create_timer(0.7, false).timeout
		elapsed += 0.7


func _follow_effect_target(holder: Node2D, lifetime: float) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var elapsed := 0.0
	while elapsed < lifetime and is_instance_valid(holder):
		if not is_inside_tree() or is_queued_for_deletion():
			return
		if get_player != null and is_instance_valid(get_player):
			holder.global_position = (
				RoleProp.get_nearest_monster_target_position(global_position) + Vector2(0, bullet4_height)
			)
		await tree.physics_frame
		elapsed += get_physics_process_delta_time()

extends BaseMonster

const SOURCE_FPS := 12.0
const LITTLE_BLOOD_OFFSET := Vector2(-30, -205)

var _skill_busy := false


func _ready() -> void:
	_configure_qingyang()
	_build_body_animations()
	super._ready()
	skill_1_cd = 0.7
	skill_2_cd = randi_range(3, 7)
	skill_3_cd = randi_range(3, 7)
	skill_4_cd = randi_range(3, 7)


func _configure_qingyang() -> void:
	rush_speed = 420
	is_boss = true
	boss_max_protect = 260
	my_mr_name = "青阳神君"
	attack_in = 78
	level = 90
	max_hp = 10640000
	hp = max_hp
	self.def = 2790
	mdef = 2790
	crit = 138
	miss = 100
	lucky = 85
	htarget = 99999
	toughness = 30
	ar = 285
	sp = 278
	crit_reduce = 25
	speed = 25
	mysee = 99999
	attack_range = 650
	attack_desire = 188
	behit_calmtime = 0
	self_rhp = max_hp * 0.00015
	add_exp = 0
	fall_coin = 800
	ebol = 0
	fall_pro = 0.0
	fall_list = []
	self.independent_fall_list = [
		{"name": "xyfjwkzzs", "value": 1, "chance": 0.1},
		{"name": "xyfjbjzzs", "value": 1, "chance": 0.1},
		{"name": "xyfjtszzs", "value": 1, "chance": 0.1},
		{"name": "xyfjsszzs", "value": 1, "chance": 0.1},
		{"name": "xyfjblzzs", "value": 1, "chance": 0.1},
		{"name": "341071301zzs", "value": 1, "chance": 0.1},
	]
	obj_attack_dict["hit1"] = {
		"power": 5200,
		"hurtBack": [-8, -10],
		"attackKind": "magic",
		"HitProtect": 8,
	}
	obj_attack_dict["hit2"] = {
		"power": 5200,
		"hurtBack": [-5, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	obj_attack_dict["hit3"] = {
		"power": 7800,
		"hurtBack": [18, -10],
		"attackKind": "magic",
		"HitProtect": 12,
	}
	obj_attack_dict["hit4"] = {
		"power": 7200,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 12,
	}


func _build_body_animations() -> void:
	var frames_path := "res://Art/monster/game_3_monster/monster_212/monster_212_action_frames.tres"
	var frames := load(frames_path) as SpriteFrames
	if frames == null:
		push_error("Monster212 action frames missing: " + frames_path)
		return

	mr_ani.sprite_frames = frames
	mr_ani.animation = &"wait"
	mr_ani.frame = 0
	mr_ani.centered = true
	mr_ani.position = Vector2(0, -95)
	mr_ani.scale = Vector2.ONE

	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_action(&"wait", true, 0.4))
	library.add_animation(&"walk", _make_action(&"walk", true, 0.4))
	library.add_animation(&"hurt", _make_action(&"hurt", false, 0.2))
	var death_animation := _make_action(&"death", false, 0.25)
	_add_death_method(death_animation)
	library.add_animation(&"death", death_animation)
	var hit_animation := _make_action(&"hit1", false, 0.45)
	_add_method_key(hit_animation, 0.16, &"call_bullet_1")
	library.add_animation(&"hit1", hit_animation)
	var hit2_animation := _make_action(&"hit2", false, 0.45)
	_add_method_key(hit2_animation, 0.16, &"call_bullet_2")
	library.add_animation(&"hit2", hit2_animation)
	var hit3_animation := _make_action(&"hit3", false, 0.45)
	_add_method_key(hit3_animation, 0.16, &"call_bullet_3")
	library.add_animation(&"hit3", hit3_animation)
	var hit4_animation := _make_action(&"hit4", false, 0.45)
	_add_method_key(hit4_animation, 0.16, &"call_bullet_4")
	library.add_animation(&"hit4", hit4_animation)
	mr_player.add_animation_library(&"", library)


func _add_sprite_animation(
	frames: SpriteFrames, anim_name: StringName, textures: Array[Texture2D], looped: bool, start: int, count: int
) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, looped)
	frames.set_animation_speed(anim_name, SOURCE_FPS)
	if textures.is_empty():
		return
	var end_index: int = mini(start + count, textures.size())
	for index in range(start, end_index):
		frames.add_frame(anim_name, textures[index])
	if frames.get_frame_count(anim_name) == 0:
		frames.add_frame(anim_name, textures[0])


func _make_action(sprite_anim: StringName, looped: bool, min_length := 0.05) -> Animation:
	var animation := Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var anim_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(anim_track, NodePath("MonsterDir/mr_ani:animation"))
	animation.value_track_set_update_mode(anim_track, Animation.UPDATE_DISCRETE)
	animation.track_insert_key(anim_track, 0.0, sprite_anim)

	var frame_count: int = maxi(1, mr_ani.sprite_frames.get_frame_count(sprite_anim))
	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, NodePath("MonsterDir/mr_ani:frame"))
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	for frame_index in range(frame_count):
		animation.track_insert_key(frame_track, float(frame_index) / SOURCE_FPS, frame_index)
	animation.length = maxf(float(frame_count) / SOURCE_FPS, min_length)
	return animation


func _add_hitbox_window(animation: Animation, start_time: float, end_time: float) -> void:
	var hitbox_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(hitbox_track, NodePath("BaseDamageBox/HitBox/HitBox:disabled"))
	animation.value_track_set_update_mode(hitbox_track, Animation.UPDATE_DISCRETE)
	animation.track_insert_key(hitbox_track, 0.0, true)
	animation.track_insert_key(hitbox_track, minf(start_time, animation.length - 0.001), false)
	animation.track_insert_key(hitbox_track, minf(end_time, animation.length - 0.001), true)


func _add_death_method(animation: Animation) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(
		method_track, maxf(animation.length - 0.001, 0.0), {"method": &"settle_death_drops_and_free", "args": []}
	)


func _add_method_key(animation: Animation, time: float, method_name: StringName) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(method_track, minf(time, animation.length - 0.001), {"method": method_name, "args": []})


func ai_think() -> void:
	if is_limit_buff():
		_skill_busy = false
		velocity.x = 0
		stop_move()
		return
	if cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	has_target = abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee
	if not has_target:
		to_hero()
		stop_move()
		return
	var distance := absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	if distance > attack_range:
		have_target()
	elif skill_4_cd <= 0:
		_use_hit_4()
	elif skill_3_cd <= 0:
		_use_hit_3()
	elif skill_2_cd <= 0:
		_use_hit_2()
	elif skill_1_cd <= 0:
		_use_hit_1()
	else:
		stop_move()


func _use_hit_1() -> void:
	if skill_1_cd > 0 or is_attacking:
		return
	to_hero()
	skill_1_cd = 1
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	_skill_busy = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	_skill_busy = false
	stop_move()


func _use_hit_2() -> void:
	if skill_2_cd > 0 or is_attacking:
		return
	to_hero()
	skill_2_cd = 7
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	_skill_busy = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	_skill_busy = false
	stop_move()


func _use_hit_3() -> void:
	if skill_3_cd > 0 or is_attacking:
		return
	to_hero()
	skill_3_cd = randi_range(5, 8)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	_skill_busy = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	_skill_busy = false
	stop_move()


func _use_hit_4() -> void:
	if skill_4_cd > 0 or is_attacking:
		return
	to_hero()
	skill_4_cd = randi_range(5, 8)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	_skill_busy = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	_skill_busy = false
	stop_move()


func call_bullet_1() -> void:
	var offset := Vector2(58, -72) if monster_direction else Vector2(-58, -72)
	Global.add_bullet(
		"Monster212Bullet1", bullet, monster_direction, 1.0, position + offset, "hit1", obj_attack_dict["hit1"]
	)


func call_bullet_2() -> void:
	_spawn_bullet2_at_role()
	await get_tree().create_timer(0.32).timeout
	if not is_instance_valid(self) or death():
		return
	_spawn_bullet2_at_role()


func _spawn_bullet2_at_role() -> void:
	var target_pos := Vector2(
		RoleProp.get_nearest_monster_target_position(global_position).x,
		RoleProp.get_nearest_monster_target_position(global_position).y
	)
	Global.add_bullet("Monster212Bullet2", bullet, monster_direction, 1.0, target_pos, "hit2", obj_attack_dict["hit2"])


func call_bullet_3() -> void:
	var offset := Vector2(650, -136) if monster_direction else Vector2(-650, -136)
	Global.add_bullet(
		"Monster212Bullet3", bullet, monster_direction, 1.0, position + offset, "hit3", obj_attack_dict["hit3"]
	)


func call_bullet_4() -> void:
	for index in range(3):
		if index > 0:
			await get_tree().create_timer(0.55, false).timeout
		if not is_instance_valid(self) or death():
			return
		var target_pos := Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x,
			RoleProp.get_nearest_monster_target_position(global_position).y
		)
		Global.add_bullet(
			"Monster212Bullet4", bullet, monster_direction, 1.0, target_pos, "hit4", obj_attack_dict["hit4"]
		)


func little_blood_bar_control():
	super.little_blood_bar_control()
	_move_little_blood_bar_to_head()


func _show_pet_hit_blood_bar() -> void:
	super._show_pet_hit_blood_bar()
	_move_little_blood_bar_to_head()


func _move_little_blood_bar_to_head() -> void:
	if monster_blood_bar != null:
		monster_blood_bar.position = LITTLE_BLOOD_OFFSET

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

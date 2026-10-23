extends BaseMonster

const BODY_FRAME_COLUMNS := 6
const SOURCE_FPS := 24.0
const BODY_SPRITE_POSITION := Vector2(-15, -81)
const BUFF_GREEN_TEXTURE := "res://Art/monster/qiong_qi/effects/buff_green.png"
const BUFF_BLUE_TEXTURE := "res://Art/monster/qiong_qi/effects/buff_blue.png"
const QIONG_QI_FRAMES := preload("res://Art/monster/qiong_qi/qiong_qi_frames.tres")

@export_category("Skill Position Tuning")
@export var bullet1_height := -102.0
@export var bullet2_height := -257.0
@export var bullet3_height := -37.0

var _near_buff_cooldown := 20
var _skill_busy := false
var _aura_token := 0
var _aura_active := false
var _aura_visual: Sprite2D


func _ready() -> void:
	_configure_qiongqi()
	_build_original_animations()
	super._ready()
	skill_1_cd = randi_range(10, 12)
	skill_2_cd = randi_range(5, 8)


func _configure_qiongqi() -> void:
	is_boss = true
	cannot_attract = true
	set_meta("allow_role_special_control", true)
	my_mr_name = "穷奇"
	attack_in = 200
	level = max(40, RoleProp.baseroleprop.Level + 3)
	max_hp = 2000000
	hp = max_hp
	def = 177
	mdef = 177
	crit = 70
	miss = 20
	lucky = 10
	htarget = 100
	toughness = 20
	ar = 0
	sp = 0
	crit_reduce = 0
	speed = 15
	mysee = 1000
	attack_range = 200
	attack_desire = 95
	behit_calmtime = 0.15
	self_rhp = 0
	add_exp = 3500
	fall_coin = 2000
	fall_pro = 0.0
	fall_list = []
	self.independent_fall_list = [{"name": "wuxingguo", "value": 1, "chance": 0.1}]
	fall_stone_pro = 0.0
	fall_stone = []
	obj_attack_dict["hit1"] = {"power": 800, "hurtBack": [-6, -5], "attackKind": "physics", "HitProtect": 14}
	obj_attack_dict["hit2"] = {"power": 600, "hurtBack": [-5, 0], "attackKind": "magic", "HitProtect": 8}
	obj_attack_dict["hit3"] = {"power": 600, "hurtBack": [-15, 0], "attackKind": "magic", "HitProtect": 4}


func _build_original_animations() -> void:
	mr_ani.sprite_frames = QIONG_QI_FRAMES
	mr_ani.animation = &"Monster42FramesCenteredCropped"
	mr_ani.centered = true
	mr_ani.position = BODY_SPRITE_POSITION

	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_action(0, [2, 2, 2, 3, 2, 4], true))
	library.add_animation(&"walk", _make_action(1, [4, 4, 4, 4], true))
	library.add_animation(&"hurt", _make_action(2, [8], false))

	var death_animation := _make_action(3, [2, 2, 2, 2, 10], false)
	_add_standard_death_methods(death_animation)
	library.add_animation(&"death", death_animation)

	var hit2_animation := _make_action(4, [2, 2, 11, 2, 24], false, 0, &"_spawn_charge_effect")
	_add_method_key(hit2_animation, 17.0 / SOURCE_FPS, &"_begin_charge_dash")
	_add_hitbox_window(hit2_animation, 4.0 / SOURCE_FPS, 34.0 / SOURCE_FPS)
	library.add_animation(&"hit2", hit2_animation)

	var hit3_animation := _make_action(5, [2, 2, 10], false, 2, &"_on_ground_spell")
	_add_hitbox_window(hit3_animation, 4.0 / SOURCE_FPS, 11.0 / SOURCE_FPS)
	library.add_animation(&"hit3", hit3_animation)

	var hit1_animation := _make_action(6, [2, 2, 2, 10], false, 3, &"_on_normal_strike")
	_add_hitbox_window(hit1_animation, 5.0 / SOURCE_FPS, 12.0 / SOURCE_FPS)
	library.add_animation(&"hit1", hit1_animation)

	mr_player.add_animation_library(&"", library)


func _make_action(row: int, holds: Array, looped: bool, method_frame := -1, method_name := &"") -> Animation:
	var animation := Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, NodePath("MonsterDir/mr_ani:frame"))
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	var time := 0.0
	for column in range(holds.size()):
		animation.track_insert_key(frame_track, time, row * BODY_FRAME_COLUMNS + column)
		time += float(holds[column]) / SOURCE_FPS
	animation.length = max(time, 0.05)
	if method_frame >= 0:
		var method_track := animation.add_track(Animation.TYPE_METHOD)
		animation.track_set_path(method_track, NodePath("."))
		var method_time := 0.0
		for index in range(method_frame):
			method_time += float(holds[index]) / SOURCE_FPS
		animation.track_insert_key(method_track, method_time, {"method": method_name, "args": []})
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(method_track, minf(time, animation.length - 0.001), {"method": method_name, "args": []})


func _add_hitbox_window(animation: Animation, start_time: float, end_time: float) -> void:
	var hitbox_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(hitbox_track, NodePath("BaseDamageBox/HitBox/HitBox:disabled"))
	animation.value_track_set_update_mode(hitbox_track, Animation.UPDATE_DISCRETE)
	animation.track_insert_key(hitbox_track, 0.0, true)
	animation.track_insert_key(hitbox_track, start_time, false)
	animation.track_insert_key(hitbox_track, minf(end_time, animation.length - 0.001), true)


func _add_standard_death_methods(animation: Animation) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	var finish_time := animation.length - 0.001
	animation.track_insert_key(method_track, finish_time, {"method": &"settle_death_drops_and_free", "args": []})


func ai_think() -> void:
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if is_limit_buff() or cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	if not has_target:
		normal_state()
		return
	_apply_nearby_aura()
	var distance := absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	if skill_1_cd <= 0:
		_use_charge_skill()
	elif distance < 400.0 and skill_2_cd <= 0:
		_use_ground_spell()
	elif distance <= attack_range:
		if count % 45 == 0:
			attack_target()
	else:
		have_target()


func _use_charge_skill() -> void:
	_skill_busy = true
	super.to_hero()
	skill_1_cd = randi_range(10, 12)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play(&"hit2")
	await mr_player.animation_finished
	if death():
		return
	velocity.x = 0
	is_attacking = false
	_skill_busy = false
	stop_move()


func _use_ground_spell() -> void:
	_skill_busy = true
	super.to_hero()
	skill_2_cd = randi_range(5, 8)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play(&"hit3")
	await mr_player.animation_finished
	if death():
		return
	is_attacking = false
	_skill_busy = false
	stop_move()


func _on_normal_strike() -> void:
	var direction := 1.0 if monster_direction else -1.0
	_spawn_effect("Bullet1", Vector2(direction * 190.0, bullet1_height))


func _spawn_charge_effect() -> void:
	var direction := 1.0 if monster_direction else -1.0
	_spawn_effect("Bullet2", Vector2(direction * 150.0, bullet2_height), true)


func _begin_charge_dash() -> void:
	var direction := 1.0 if monster_direction else -1.0
	velocity.x = direction * 30.0 * SOURCE_FPS


func _on_ground_spell() -> void:
	var direction := 1.0 if monster_direction else -1.0
	_spawn_effect("Bullet3", Vector2(direction * 150.0, bullet3_height))


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	var target := super._on_hit_box_area_entered(area)
	if hit_name == "hit2" and target is BaseHero:
		target.effect_reducehp(maxi(1, int(RoleProp.roleprop.Hp / 6.0)), "real")
	return target


func _apply_nearby_aura() -> void:
	if _near_buff_cooldown > 0:
		_near_buff_cooldown -= 1
		return
	_near_buff_cooldown = 20
	if get_player == null or not is_instance_valid(get_player):
		return
	if global_position.distance_to(RoleProp.get_nearest_monster_target_position(global_position)) > 200.0:
		return
	_apply_original_aura(randf() <= 0.5)


func _apply_original_aura(is_green: bool) -> void:
	if _aura_active:
		return
	_aura_active = true
	_aura_token += 1
	var token := _aura_token
	_show_aura_visual(BUFF_GREEN_TEXTURE if is_green else BUFF_BLUE_TEXTURE)
	if is_green:
		get_player.effect_reducehp(maxi(1, int(RoleProp.roleprop.SHp * 0.01)), "real")
	await get_tree().create_timer(1.0, false).timeout
	if token == _aura_token:
		_aura_active = false
		_clear_aura_visual()


func _show_aura_visual(texture_path: String) -> void:
	_clear_aura_visual()
	if get_player == null or not is_instance_valid(get_player):
		return
	_aura_visual = Sprite2D.new()
	_aura_visual.name = "QiongQiAura"
	_aura_visual.texture = Global.get_cached_texture(texture_path)
	_aura_visual.position = Vector2(0, -62)
	_aura_visual.z_index = 6
	get_player.add_child(_aura_visual)


func _clear_aura_visual() -> void:
	if _aura_visual != null and is_instance_valid(_aura_visual):
		_aura_visual.queue_free()
	_aura_visual = null


func _spawn_effect(folder: String, local_offset: Vector2, follow_boss := false) -> void:
	var effect := AnimatedSprite2D.new()
	effect.sprite_frames = QIONG_QI_FRAMES
	effect.animation = StringName("Effects/" + folder)
	effect.centered = true
	effect.flip_h = monster_direction
	effect.z_index = 5
	if follow_boss:
		add_child(effect)
		effect.position = local_offset
	else:
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position + local_offset
	effect.animation_finished.connect(_free_effect_sprite.bind(effect), CONNECT_ONE_SHOT)
	effect.play()


func _free_effect_sprite(effect: Node) -> void:
	if effect == null or not is_instance_valid(effect):
		return
	effect.queue_free()

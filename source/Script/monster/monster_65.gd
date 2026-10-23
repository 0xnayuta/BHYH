extends BaseMonster
class_name Monster65
const BODY_FRAMES_RES := "res://Art/monster/monster_65/atlas/monster_65_frames.tres"
static var _body_frames_resource: SpriteFrames = null

var is_top = false
var is_drop = false
var zz_list: Array[BaseMonster] = []
var _body_frames_sprite: Sprite2D
var _body_frames: SpriteFrames
var _body_frames_animation: StringName = &""
var _body_action: StringName = &""


func monster_65():
	self.rush_speed = 600
	self.is_boss = true
	self.my_mr_name = "五毒·都市王"
	self.attack_in = 15
	self.level = RoleProp.baseroleprop.Level + 1
	self.max_hp = 220000 + int(RoleProp.baseroleprop.Level * 16000)
	self.hp = self.max_hp
	self.def = 180 + int(RoleProp.baseroleprop.Level * 4.0)
	self.mdef = 180 + int(RoleProp.baseroleprop.Level * 4.0)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 1.2)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.6)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 1.8)
	self.htarget = 0
	self.toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 1.0)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 1.0)
	self.crit_reduce = 0
	self.speed = 13
	self.mysee = 500
	self.attack_range = 250
	self.attack_desire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.6),
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 10
	}
	self.obj_attack_dict["zhzz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "physics", "HitProtect": 10}
	self.obj_attack_dict["hit2_1"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "Boundground",
			"AddTime": 4,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.obj_attack_dict["hit2_2"] = {
		"power": 600 + int(RoleProp.baseroleprop.Level * 8.7),
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 25,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.15
	self.fall_list = [
		{"name": "zzyj", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_65()
	skill_1_cd = 20
	skill_2_cd = 10
	skill_3_cd = 15
	_sync_body_visual()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_sync_body_visual()


func _sync_body_visual() -> void:
	var action := mr_ani.animation
	if action != _body_action:
		_replace_body_stream(action)
	if _body_frames_sprite != null and is_instance_valid(_body_frames_sprite):
		if _body_frames == null:
			return
		var frame_count := _body_frames.get_frame_count(_body_frames_animation)
		if frame_count <= 0:
			return
		var frame := clampi(mr_ani.frame, 0, frame_count - 1)
		_body_frames_sprite.position = mr_ani.offset
		_body_frames_sprite.modulate = mr_ani.self_modulate
		_body_frames_sprite.flip_h = mr_ani.flip_h
		_body_frames_sprite.texture = _body_frames.get_frame_texture(_body_frames_animation, frame)
		return


static func _get_body_frames_resource() -> SpriteFrames:
	if _body_frames_resource == null:
		_body_frames_resource = load(BODY_FRAMES_RES) as SpriteFrames
	return _body_frames_resource


func _setup_body_frames(action: StringName) -> bool:
	var frames := _get_body_frames_resource()
	if frames == null or not frames.has_animation(action):
		return false
	var sprite := Sprite2D.new()
	sprite.name = "BodyFrames"
	sprite.centered = true
	sprite.texture_filter = mr_ani.texture_filter
	sprite.modulate = mr_ani.self_modulate
	sprite.flip_h = mr_ani.flip_h
	sprite.position = mr_ani.offset
	sprite.texture = frames.get_frame_texture(action, 0)
	mr_ani.add_child(sprite)
	_body_frames_sprite = sprite
	_body_frames = frames
	_body_frames_animation = action
	_sync_body_visual()
	return true


func _replace_body_stream(action: StringName) -> void:
	if _body_frames_sprite != null and is_instance_valid(_body_frames_sprite):
		_body_frames_sprite.texture = null
		_body_frames_sprite.queue_free()
	_body_frames_sprite = null
	_body_frames = null
	_body_frames_animation = &""
	_body_action = action
	_setup_body_frames(action)


func ai_think():
	if is_top:
		if not is_drop:
			velocity.y = -5
		return
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_skill_2_1()
				if (
					count % 60 == 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 250
				):
					attack_target()
				if skill_3_cd <= 0:
					do_hit_3()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_skill_2_1()
				if (
					count % 60 == 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 250
				):
					attack_target()
				if skill_3_cd <= 0:
					do_hit_3()


func return_body():
	mr_ani.position = Vector2(0, 0)


func await_t_otop():
	is_top = true
	is_drop = false
	self.position = Vector2(self.position.x, 0)
	return_body()


func fall():
	velocity.y += 800
	is_top = true
	is_drop = true
	self.position = Vector2(self.position.x, self.position.y)


func return_normal():
	return_body()
	is_top = false
	is_drop = false


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(30, 35)
	hit_name = "zhzz"
	velocity.x = 0
	is_attacking = true
	mr_player.play("zhzz")
	await mr_player.animation_finished
	is_attacking = false


func do_skill_2_1():
	super.to_hero()
	skill_2_cd = randi_range(15, 20)
	hit_name = "zhzz"
	velocity.x = 0
	is_attacking = true
	mr_player.play("totop")
	await mr_player.animation_finished
	is_attacking = false
	await get_tree().create_timer(randi_range(0.5, 2), false).timeout
	do_skill_2_2()


func do_skill_2_2():
	super.to_hero()
	velocity.x = 0
	is_attacking = true
	self.position = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 300)
	if randi_range(0, 100) <= 50:
		hit_name = "hit2_1"
		mr_player.play("fall2")
	else:
		hit_name = "hit2_2"
		mr_player.play("fall")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(20, 30)
	hit_name = "zhzz"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false


func move_to_player_local():
	self.position = RoleProp.get_nearest_monster_target_position(global_position)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	super._on_hurt_box_area_entered(area)
	if randi_range(0, 100) < 5:
		(
			Global
			. add_buff(
				get_player.buff,
				{
					"Name": "poision",
					"AddTime": 5,
					"reduce_interval": 1,
					"value": 100,
					"AttackKind": "real",
					"DeBuff": true,
					"CanAdd": true,
				}
			)
		)


func call_wang():
	if monster_direction:
		Global.add_monster65_bullet(self.bullet, position + Vector2(240, -55))
	else:
		Global.add_monster65_bullet(self.bullet, position + Vector2(-240, -55))


func call_zz():
	for i in range(randi_range(2, 4)):
		Global.create_monster(66, get_parent(), position + Vector2(randi_range(-200, 200), 0))

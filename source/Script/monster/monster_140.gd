extends BaseMonster
var should_fly: bool
var sword: Monster117
var fire_round: Monster116
var is_call: bool
var onset_eatblood: bool
var remove_blood: bool


func monster_140():
	self.rush_speed = 400

	self.is_boss = true
	self.my_mr_name = "焰中仙"
	self.attack_in = 90
	self.level = 55
	self.max_hp = 500000
	self.hp = self.max_hp
	self.def = 400
	self.mdef = 400
	self.crit = 20
	self.miss = 40
	self.lucky = 50
	self.htarget = 15
	self.toughness = 0
	self.ar = 50
	self.sp = 50
	self.crit_reduce = 0
	self.speed = 14
	self.mysee = 500
	self.attack_range = 325
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 500
	self.ebol = 0
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 450,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.5,
			"CanAdd": false,
			"DeBuff": true,
			"CanRemove": false,
			"AttackKind": "",
		},
	}
	self.obj_attack_dict["hit3"] = {
		"power": 550,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 9,
	}
	self.obj_attack_dict["hit4"] = {
		"power": 800,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 3,
			"reduce_interval": 1,
			"value": int(RoleProp.roleprop.SHp * 0.02),
			"CanAdd": false,
			"DeBuff": true,
			"CanRemove": false,
			"AttackKind": "magic",
		},
	}
	self.obj_attack_dict["hit5"] = {
		"power": 800,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 10,
			"reduce_interval": 0,
			"value": 0.3,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
			"CanAdd": false,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "qszzs", "value": 1},
		{"name": "ytzzs", "value": 1},
		{"name": "llzzs", "value": 1},
		{"name": "rczzs", "value": 1},
		{"name": "ldzzs", "value": 1},
		{"name": "240007001zzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_140()
	skill_1_cd = randi_range(3, 4)
	skill_2_cd = 10
	skill_3_cd = 5
	skill_4_cd = 12
	skill_5_cd = 15


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not is_call:
		if sword == null:
			sword = Global.create_monster(117, get_parent(), self.position)
		if fire_round == null:
			fire_round = Global.create_monster(116, get_parent(), self.position)
		is_call = true
	if sword != null or fire_round != null:
		ebol = 10
	else:
		ebol = 1


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if skill_5_cd <= 0:
					do_hit_5()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 450:
					if skill_4_cd <= 0:
						do_hit_4()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 500:
					if skill_3_cd <= 0:
						do_hit_3()
				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()
				if skill_5_cd <= 0:
					do_hit_5()
				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = 10
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = 24
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = 20
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	super.to_hero()
	skill_4_cd = 15
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit5")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_5():
	super.to_hero()
	skill_5_cd = 14
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit6")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func move_to_top_and_face_player():
	if _movement_command_is_blocked() or get_player == null:
		return
	velocity.y = 0
	var tween = create_control_movement_tween().set_parallel(true)
	var po = Vector2(position.x, position.y - 350)
	if position.y - 350 <= -100:
		po = Vector2(position.x, -100)
	tween.tween_property(self, "position", po, 0.2)
	var target_degrees = -position.angle_to(RoleProp.get_nearest_monster_target_position(global_position))
	tween.tween_property(self, "rotation", target_degrees, 0.2)
	should_in_sky = true


func tweentotop():
	if _movement_command_is_blocked():
		return
	velocity.y = 0
	var tween = create_control_movement_tween().set_parallel(true)
	tween.tween_property(self, "position", Vector2(position.x, -100), 0.2)
	velocity.y = 0
	should_in_sky = true


func not_move_player():
	if _movement_command_is_blocked() or get_player == null:
		velocity.x = 0
		return
	if position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
		velocity.x = 2500
	else:
		velocity.x = -2500


func remove_speedx():
	velocity.x = 0


func drop():
	should_in_sky = false


func call_bullet_1():
	var bb
	if self.monster_direction:
		bb = Global.add_bullet(
			"Monster140Bullet1", self.bullet, true, 2.5, Vector2(20, 0) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	else:
		bb = Global.add_bullet(
			"Monster140Bullet1",
			self.bullet,
			true,
			2.5,
			Vector2(-20, 0) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	bb.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_alt2():
	var _bullet
	var dir = self.monster_direction
	if dir:
		_bullet = Global.add_bullet(
			"Monster140Bullet2",
			self.bullet,
			false,
			0.3,
			Vector2(80, 0) + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)
	else:
		_bullet = Global.add_bullet(
			"Monster140Bullet2",
			self.bullet,
			false,
			0.3,
			Vector2(-80, 0) + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)

	if _bullet:
		var sprite = _bullet.bullet_ani
		if sprite:
			sprite.flip_v = dir
	_bullet.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_3():
	for i in range(12):
		var _bullet
		var bullet_pos = Vector2(position.x + randi_range(-450, 500), -300)
		_bullet = Global.add_bullet(
			"Monster140Bullet3", self.bullet, false, 0.58, bullet_pos, "hit4", self.obj_attack_dict["hit4"]
		)
		_bullet.look_at(RoleProp.get_nearest_monster_target_position(global_position))
		await get_tree().create_timer(0.3, false).timeout


func call_bullet_4():
	var bullet_spawn_positions = [
		Vector2(-500 + position.x, 500),
		Vector2(-400 + position.x, 500),
		Vector2(-300 + position.x, 500),
		Vector2(-200 + position.x, 500),
		Vector2(-100 + position.x, 500),
		Vector2(100 + position.x, 500),
		Vector2(200 + position.x, 500),
		Vector2(300 + position.x, 500),
		Vector2(400 + position.x, 500),
		Vector2(500 + position.x, 500)
	]
	for i in bullet_spawn_positions:
		Global.add_bullet("Monster140Bullet4", self.bullet, false, 1, i, "hit5", self.obj_attack_dict["hit5"])


func to_sky():
	velocity.y = 0
	should_in_sky = true
	velocity.y = 0


func check_player():
	if self.position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
		if Global.get_player.player_dir:
			if not monster_direction:
				move_player_to_boss(0.5)
				(
					Global
					. add_buff(
						get_player.buff,
						{
							"Name": "stun",
							"AddTime": 4,
							"reduce_interval": 0,
							"value": 0,
							"AttackKind": "",
							"CanAdd": false,
							"CanRemove": false,
							"DeBuff": true,
						}
					)
				)
	else:
		if not Global.get_player.player_dir:
			if monster_direction:
				move_player_to_boss(0.5)
				(
					Global
					. add_buff(
						get_player.buff,
						{
							"Name": "stun",
							"AddTime": 4,
							"reduce_interval": 0,
							"value": 0,
							"AttackKind": "",
							"CanAdd": false,
							"CanRemove": false,
							"DeBuff": true,
						}
					)
				)


func reduce_hp(value: int):
	if sword != null or fire_round != null:
		if value > 0:
			value *= 0.5
	super.reduce_hp(value)


func hurt_reduce_hp(value, target):
	if sword != null or fire_round != null:
		if value > 0:
			value *= 0.5
	return super.hurt_reduce_hp(value, target)


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func call_bullet_2():
	return call_bullet_alt2()

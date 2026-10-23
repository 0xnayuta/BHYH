extends BaseMonster
var is_sky = false
var round_list = []
var rolelevel = RoleProp.baseroleprop.Level


func monster_142():
	self.rush_speed = 400
	self.is_boss = true
	self.my_mr_name = "后羿"
	self.attack_in = 90
	self.level = RoleProp.baseroleprop.Level
	self.max_hp = 100000 + int(RoleProp.baseroleprop.Level * 6000)
	self.hp = self.max_hp
	self.def = 120 + int(RoleProp.baseroleprop.Level * 2)
	self.mdef = 120 + int(RoleProp.baseroleprop.Level * 2)
	self.crit = 15 + int(RoleProp.baseroleprop.Level * 0.6)
	self.miss = 15 + int(RoleProp.baseroleprop.Level * 0.3)
	self.lucky = 45 + int(RoleProp.baseroleprop.Level * 1)
	self.htarget = 9999
	self.toughness = 0
	self.ar = 30 + int(RoleProp.baseroleprop.Level * 0.5)
	self.sp = 30 + int(RoleProp.baseroleprop.Level * 0.5)
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 500
	self.attack_range = 355
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = max_hp * 0.02
	self.add_exp = 1
	self.fall_coin = 1
	self.ebol = 0
	self.obj_attack_dict["hit1"] = {
		"power": 100 + int(RoleProp.baseroleprop.Level * 8),
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 12),
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": 0.4,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 500 + int(RoleProp.baseroleprop.Level * 15),
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 6,
			"reduce_interval": 0,
			"value": 1,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}

	self.fall_pro = 1
	self.fall_list = [{"name": "ptsryx", "value": 0}]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_142()
	skill_1_cd = 2
	skill_2_cd = 5
	skill_3_cd = 7


func ai_think():
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
					do_hit_2()
				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = 15
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = 20
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_1():
	var bb
	var sp = 1 + rolelevel * 0.015
	if self.monster_direction:
		bb = Global.add_bullet(
			"Monster145Bullet1", self.bullet, false, sp, Vector2(20, 0) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	else:
		bb = Global.add_bullet(
			"Monster145Bullet1",
			self.bullet,
			false,
			sp,
			Vector2(-20, 0) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	bb.scale = Vector2(2, 2)
	bb.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_2():
	await get_tree().create_timer(2, false).timeout
	var sp = 0.5 + rolelevel * 0.01
	for i in range(5):
		var _bullet
		var bullet_pos = Vector2(position.x + randi_range(-450, 500), -800)
		_bullet = Global.add_bullet(
			"Monster145Bullet2", self.bullet, false, sp, bullet_pos, "hit2", self.obj_attack_dict["hit2"]
		)
		_bullet.look_at(RoleProp.get_nearest_monster_target_position(global_position))
		await get_tree().create_timer(0.5, false).timeout


func call_bullet_3():
	var sp = 1 + rolelevel * 0.02
	var bb
	if self.monster_direction:
		bb = Global.add_bullet(
			"Monster145Bullet2",
			self.bullet,
			!self.monster_direction,
			sp,
			Vector2(20, 0) + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)
		bb.rotation_degrees = -45
	else:
		bb = Global.add_bullet(
			"Monster145Bullet2",
			self.bullet,
			!self.monster_direction,
			sp,
			Vector2(-20, 0) + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)
		bb.rotation_degrees = 45


func call_bullet_4():
	var sp = 0.5 + rolelevel * 0.01
	var bb
	if self.monster_direction:
		bb = Global.add_bullet(
			"Monster145Bullet3",
			self.bullet,
			!self.monster_direction,
			sp,
			Vector2(20, 0) + position,
			"hit3",
			self.obj_attack_dict["hit3"]
		)
	else:
		bb = Global.add_bullet(
			"Monster145Bullet3",
			self.bullet,
			!self.monster_direction,
			sp,
			Vector2(-20, 0) + position,
			"hit3",
			self.obj_attack_dict["hit3"]
		)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

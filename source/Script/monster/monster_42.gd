extends BaseMonster


func monster_42():
	self.rush_speed = 900
	self.is_boss = true
	self.my_mr_name = "战神刑天"
	self.attack_in = 0
	self.level = RoleProp.baseroleprop.Level + 4
	self.max_hp = 500000 + RoleProp.roleprop.SHp * 75
	self.hp = self.max_hp
	self.def = RoleProp.roleprop.Def
	self.mdef = RoleProp.roleprop.Mdef
	self.crit = RoleProp.roleprop.Crit
	self.miss = RoleProp.roleprop.Miss
	self.lucky = RoleProp.roleprop.Lucky
	self.htarget = RoleProp.roleprop.htarget * 2
	self.toughness = 0
	self.ar = RoleProp.roleprop.ar
	self.sp = RoleProp.roleprop.sp
	self.crit_reduce = 0
	self.speed = 13
	self.mysee = 550
	self.attack_range = 225
	self.attack_desire = 90
	self.behit_calmtime = 0.2
	self.self_rhp = self.max_hp * 0.002
	self.add_exp = 5000
	self.fall_coin = 5000
	self.obj_attack_dict["hit1"] = {
		"power": int(800 + RoleProp.roleprop.power),
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 20,
	}
	self.obj_attack_dict["mykl"] = {
		"power": int(350 + RoleProp.roleprop.power * 0.35),
		"hurtBack": [-4, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["xmhd"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "magic",
	}
	self.obj_attack_dict["sfjm"] = {
		"power": int(800 + RoleProp.roleprop.power * 0.3),
		"hurtBack": [-4, -5],
		"attackKind": "magic",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "stun",
			"DeBuff": true,
			"CanAdd": false,
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "xtzy", "value": 0},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0
	monster_42()


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 295:
				if skill_3_cd <= 0:
					if randf_range(0, 1) < 0.8:
						do_hit_3()
					else:
						attack_target()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif count % 30 == 0:
					if randf_range(0, 1) < 0.7:
						attack_target()
					else:
						have_target()
				else:
					have_target()
			elif abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 500:
				if skill_3_cd <= 0:
					if randf_range(0, 1) < 0.8:
						do_hit_3()
					else:
						attack_target()
				elif count % 30 == 0:
					if randf_range(0, 1) < 0.7:
						attack_target()
					else:
						have_target()
				else:
					have_target()
			elif abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 800:
				if skill_1_cd <= 0:
					do_hit_1()
				else:
					have_target()
			else:
				have_target()


func stop_move():
	velocity.x = 0
	mr_player.play("wait")


func do_hit_1():
	super.to_hero()
	skill_1_cd = 6 + randi_range(0, 4)
	hit_name = "xmhd"
	velocity.x = 0
	is_attacking = true
	mr_player.play("xmhd")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_2():
	super.to_hero()
	skill_2_cd = 15
	velocity.x = 0
	hit_name = "mykl"
	is_attacking = true
	mr_player.play("mykl")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	super.to_hero()
	skill_3_cd = 20
	velocity.x = 0
	hit_name = "sfjm"
	is_attacking = true
	mr_player.play("sfjm")
	await mr_player.animation_finished
	is_attacking = false


func normal_state():
	if is_be_attacking:
		return
	if ran_num < 30:
		stop_move()
	elif ran_num >= 30 and ran_num <= 65:
		move_left()
	else:
		move_right()


func call_sfjm_fire():
	var fire_position = [
		Vector2(self.position.x - 180, self.position.y - 20),
		Vector2(self.position.x - 360, self.position.y - 20),
		Vector2(self.position.x, self.position.y - 20),
		Vector2(self.position.x + 180, self.position.y - 20),
		Vector2(self.position.x + 360, self.position.y - 20)
	]
	for i in range(5):
		Global.add_bullet(
			"Monster42Bullet", self.bullet, false, 2, fire_position[i], "sfjm", self.obj_attack_dict["sfjm"]
		)


func call_xmhd():
	var rot := -20.0 if not self.monster_direction else 20.0
	var offset_x := -50.0 if not self.monster_direction else 50.0
	var hd = Global.add_special_effect(
		self, Vector2(offset_x, -5.0), "monster42_bullet_1", Vector2(0.5, 0.9), false, 0.9
	)
	var xw = Global.add_special_effect(
		self, Vector2(offset_x, -5.0), "monster42_bullet_2", Vector2(0.5, 0.9), false, 0.9
	)
	if hd != null:
		hd.set_rotation_degrees(rot)
	if xw != null:
		xw.set_rotation_degrees(rot)
	(
		Global
		. add_buff(
			get_player.buff,
			{
				"Name": "speed_down",
				"AddTime": 2,
				"reduce_interval": 0,
				"value": 0.5,
				"AttackKind": "magic",
				"CanAdd": false,
			}
		)
	)


func no_rush():
	velocity.x = 0

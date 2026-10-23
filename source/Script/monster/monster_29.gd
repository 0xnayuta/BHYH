extends BaseMonster


func monster_29():
	self.is_boss = true
	self.my_mr_name = "魔·红孩儿"
	self.attack_in = 10
	self.level = RoleProp.baseroleprop.Level + 2
	self.max_hp = 5000 + RoleProp.roleprop.SHp * 10
	self.hp = self.max_hp
	self.def = 165
	self.mdef = 165
	self.crit = 10
	self.miss = 5
	self.lucky = 15
	self.htarget = 15
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 13
	self.mysee = 300
	self.attack_range = 165
	self.attack_desire = 90
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 100
	self.fall_coin = 100
	self.obj_attack_dict["hit1"] = {
		"power": int(40 + RoleProp.roleprop.power * 0.2), "hurtBack": [-3, -5], "attackKind": "physics"
	}
	self.obj_attack_dict["lxhjq"] = {
		"power": int(50 + RoleProp.roleprop.power * 0.6), "hurtBack": [-3, -5], "attackKind": "magic"
	}
	self.obj_attack_dict["tghs"] = {
		"power": int(60 + RoleProp.roleprop.power * 0.4),
		"hurtBack": [-3, -5],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"reduce_interval": 0,
			"CanAdd": false,
			"DeBuff": true,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["smzh"] = {
		"power": int(20 + RoleProp.roleprop.power * 0.12),
		"hurtBack": [-3, -5],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 5,
			"CanAdd": true,
			"reduce_interval": 0.5,
			"DeBuff": true,
			"value": int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "real",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "jgj", "value": 0},
		{"name": "ssj", "value": 0},
		{"name": "gjjs_1", "value": 0},
		{"name": "smjs_1", "value": 0},
		{"name": "mfjs_1", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "hhebx"

	update_fall_mode()
	self.fall_stone_pro = 0.9
	self.fall_stone = [
		{"name": "mjlp", "value": 0},
	]


func _ready() -> void:
	super._ready()
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0
	monster_29()


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 1600:
					if skill_3_cd <= 0:
						do_hit_3()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
					if skill_1_cd <= 0:
						do_hit_1()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 200:
					if skill_2_cd <= 0:
						do_hit_2()
			else:
				if skill_3_cd <= 0:
					do_hit_3()
				elif skill_1_cd <= 0:
					do_hit_1()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif count % 60 == 0:
					var rad = randi_range(0, 100)
					if rad <= attack_desire:
						attack_target()
				else:
					stop_move()


func do_hit_1():
	super.to_hero()
	skill_1_cd = 16
	hit_name = "smzh"
	velocity.x = 0
	is_attacking = true
	mr_player.play("smzh")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = 18
	velocity.x = 0
	hit_name = "tghs"
	is_attacking = true
	mr_player.play("tghs")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = 12
	velocity.x = 0
	hit_name = "lxhjq"
	is_attacking = true
	mr_player.play("lxhjq")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func normal_state():
	if is_be_attacking:
		return
	if ran_num < 30:
		stop_move()
	elif ran_num >= 30 and ran_num <= 65:
		move_left()
	else:
		move_right()


func call_lxhjq():
	var po: Vector2
	if monster_direction:
		po = Vector2(90, -15) + position
	else:
		po = Vector2(-90, -15) + position
	Global.add_bullet(
		"Monster29Bullet", self.bullet, self.monster_direction, 1, po, "lxhjq", self.obj_attack_dict["lxhjq"]
	)

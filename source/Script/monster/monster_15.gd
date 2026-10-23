extends BaseMonster


func monster_15():
	self.is_boss = false
	self.my_mr_name = "蟹将"
	self.attack_in = 15
	self.level = 20
	self.max_hp = 600
	self.hp = self.max_hp
	self.def = 80
	self.mdef = 120
	self.crit = 5
	self.miss = 5
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 6
	self.mysee = 400
	self.attack_range = 80
	self.attack_desire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 35
	self.fall_coin = 10
	self.obj_attack_dict["hit1"] = {
		"power": 30,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
	}
	self.obj_attack_dict["qlzg"] = {
		"power": 40,
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 0.5,
			"CanAdd": false,
			"DeBuff": true,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_15()
	skill_1_cd = 0


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_1_cd <= 0:
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 120:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if skill_1_cd <= 0:
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 120:
						do_hit_2()
					else:
						have_target()
				else:
					if count % 90 == 0:
						attack_target()
					else:
						stop_move()


func do_hit_2():
	skill_1_cd = 9
	hit_name = "qlzg"
	velocity.x = 0
	is_attacking = true
	mr_player.play("qlzg")
	await mr_player.animation_finished
	is_attacking = false


func call_boom():
	var po = self.position
	Global.add_bullet(
		"Monster15Bullet", self.bullet, self.monster_direction, 0.7, po, "qlzg", self.obj_attack_dict["qlzg"]
	)

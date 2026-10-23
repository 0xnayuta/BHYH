extends BaseMonster


func monster_96():
	self.is_boss = true
	self.rush_speed = 900
	self.my_mr_name = "猕猴王·通风"
	self.attack_in = 120
	self.level = 35
	self.max_hp = 60000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 10
	self.miss = 18
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 30
	self.sp = 30
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 500
	self.attack_range = 145
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {"power": 505, "hurtBack": [-4, -9], "attackKind": "physics", "HitProtect": 8}
	self.obj_attack_dict["tfhx"] = {
		"power": 90,
		"hurtBack": [-35, -2],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.8,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["jfkx"] = {
		"power": 450,
		"hurtBack": [-15, -24],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.8,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "tfljzzs", "value": 1},
	]
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_96()
	skill_1_cd = 7
	skill_2_cd = 0


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()

				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 550:
					if skill_2_cd <= 0:
						do_hit_3()
			else:
				if skill_2_cd <= 0:
					do_hit_3()
				else:
					if count % 60 == 0:
						if ran_num <= attack_desire:
							attack_target()
						else:
							stop_move()
					else:
						stop_move()


func do_hit_3():
	skill_2_cd = 9
	velocity.x = 0
	hit_name = "jfkx"
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false

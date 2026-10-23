extends BaseMonster


func monster_115():
	self.is_boss = false
	self.my_mr_name = "火龙护卫"
	self.attack_in = 20
	self.level = 55
	self.max_hp = 45000
	self.hp = self.max_hp
	self.def = 300
	self.mdef = 300
	self.crit = 25
	self.miss = 25
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 60
	self.sp = 60
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 600
	self.attack_range = 225
	self.attack_desire = 80
	self.behit_calmtime = 0.1
	self.self_rhp = 0
	self.add_exp = 240
	self.fall_coin = 240
	self.obj_attack_dict["hit1"] = {"power": 500, "hurtBack": [-6, -5], "attackKind": "physics"}
	self.obj_attack_dict["hit2"] = {
		"power": 800,
		"hurtBack": [-6, -5],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 5,
			"CanAdd": true,
			"DeBuff": true,
			"CanRemove": false,
			"reduce_interval": 0,
			"value": 100,
			"AttackKind": "real",
		}
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_115()
	skill_1_cd = 5


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
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				else:
					if count % 90 == 0:
						attack_target()
					else:
						stop_move()


func do_hit_2():
	skill_1_cd = 5
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false

extends BaseMonster


func monster_74():
	self.rush_speed = 500
	self.is_boss = false
	self.my_mr_name = "黑龟"
	self.attack_in = 15
	self.level = 35
	self.max_hp = 4000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 10
	self.miss = 8
	self.lucky = 0
	self.htarget = 0
	self.toughness = 20
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 9
	self.mysee = 400
	self.attack_range = 200
	self.attack_desire = 90
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 110
	self.fall_coin = 70
	self.obj_attack_dict["hit1"] = {
		"power": 200,
		"hurtBack": [-7, -9],
		"attackKind": "physics",
	}
	self.obj_attack_dict["hit2"] = {
		"power": 150,
		"hurtBack": [-7, -15],
		"attackKind": "magic",
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.1
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_74()
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
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if skill_1_cd <= 0:
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
						do_hit_2()
					else:
						have_target()
				else:
					if count % 90 == 0:
						attack_target()
					else:
						stop_move()


func do_hit_2():
	skill_1_cd = 8
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false

extends BaseMonster


func monster_100():
	self.rush_speed = 600
	self.is_boss = true
	self.my_mr_name = "土行孙"
	self.attack_in = 60
	self.level = 40
	self.max_hp = 120000
	self.hp = self.max_hp
	self.def = 165
	self.mdef = 165
	self.crit = 35
	self.miss = 25
	self.lucky = 15
	self.htarget = 0
	self.toughness = 0
	self.ar = 30
	self.sp = 30
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 500
	self.attack_range = 145
	self.attack_desire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 120
	self.fall_coin = 155
	self.obj_attack_dict["hit1"] = {
		"power": 350,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 350,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit3"] = {
		"power": 400,
		"hurtBack": [-6, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "eyzzs", "value": 1},
		{"name": "tzzzs", "value": 1},
		{"name": "yjzzs", "value": 1},
		{"name": "zezzs", "value": 1},
	]

	enable_treasure_box = true
	treasure_box_item = "txsbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_100()
	skill_1_cd = 0


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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 560:
					if skill_2_cd <= 0:
						do_hit_2()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				elif skill_2_cd <= 0:
					do_hit_2()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(8, 10)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(11, 13)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func move_player():
	self.position = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 410)
	self.position.x = RoleProp.get_nearest_monster_target_position(global_position).x


func rush():
	if self.monster_direction:
		velocity.x = rush_speed
	else:
		velocity.x = -rush_speed

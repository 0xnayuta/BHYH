extends BaseMonster
class_name Monster17


func monster_17(is_boss):
	self.rush_speed = 500
	skill_1_cd = 0
	self.my_mr_name = "龟丞相"
	if is_boss:
		self.attack_in = 30
		self.level = 20
		self.max_hp = 5000
		self.hp = self.max_hp
		self.def = 90
		self.mdef = 120
		self.crit = 10
		self.miss = 5
		self.lucky = 0
		self.htarget = 0
		self.toughness = 0
		self.ar = 0
		self.sp = 0
		self.crit_reduce = 0
		self.speed = 9
		self.mysee = 400
		self.attack_range = 400
		self.attack_desire = 75
		self.behit_calmtime = 0.1
		self.self_rhp = 0
		self.add_exp = 350
		self.fall_coin = 200
		self.obj_attack_dict["hit1"] = {
			"power": 155,
			"hurtBack": [-4, -9],
			"attackKind": "real",
			"addeffect":
			{
				"Name": "Ice",
				"AddTime": 1.56,
				"DeBuff": true,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
			}
		}
		self.obj_attack_dict["xfj"] = {
			"power": 185,
			"hurtBack": [-17, -15],
			"attackKind": "magic",
			"HitProtect": 8,
		}
		self.fall_pro = 0.5
		self.fall_list = [
			{"name": "xqzy", "value": 0},
		]
		self.fall_stone_pro = 0
		self.fall_stone = []
	else:
		self.attack_in = 10
		self.level = 23
		self.max_hp = 800
		self.hp = self.max_hp
		self.def = 80
		self.mdef = 120
		self.crit = 5
		self.miss = 5
		self.lucky = 0
		self.htarget = 1
		self.toughness = 0
		self.ar = 0
		self.sp = 0
		self.crit_reduce = 0
		self.speed = 9
		self.mysee = 300
		self.attack_range = 95
		self.attack_desire = 80
		self.behit_calmtime = 0.2
		self.self_rhp = 0
		self.add_exp = 50
		self.fall_coin = 15
		self.obj_attack_dict["hit1"] = {"power": 100, "hurtBack": [-4, -9], "attackKind": "real"}
		self.obj_attack_dict["xfj"] = {"power": 35, "hurtBack": [-3, -15], "attackKind": "magic"}
		self.fall_pro = 0.0
		self.fall_list = []
		self.fall_stone_pro = 0
		self.fall_stone = []


func _ready() -> void:
	super._ready()
	if get_parent().get_parent() is Level1 or get_parent().get_parent() is Level7:
		is_boss = true
	else:
		is_boss = false
	monster_17(is_boss)


func do_hit_2():
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
		move_right()
	else:
		move_left()
	skill_1_cd = 14
	velocity.x = 0
	hit_name = "xfj"
	is_attacking = true
	mr_player.play("xfj")
	await mr_player.animation_finished
	is_attacking = false
	(
		Global
		. add_buff(
			buff,
			{
				"Name": "stun",
				"AddTime": randi_range(3, 5),
				"reduce_interval": 0.0,
				"value": 0,
				"AttackKind": "",
			}
		)
	)


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if is_boss:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
					have_target()
					if skill_1_cd <= 0:
						do_hit_2()
				else:
					if skill_1_cd <= 0:
						do_hit_2()
					elif count % attack_in == 0:
						if ran_num <= attack_desire:
							attack_target()
						else:
							stop_move()
					else:
						have_target()
			elif not is_boss:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= attack_range:
					if count % 60 == 0:
						if ran_num <= attack_desire:
							attack_target()
					else:
						stop_move()
				else:
					have_target()

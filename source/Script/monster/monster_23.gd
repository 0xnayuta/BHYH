extends BaseMonster
class_name Monster23
var boss_3
var up_power = 1


func monster_23():
	if get_parent().get_parent() is LevelNMGHDGQ:
		self.is_boss = true
		self.my_mr_name = "牛魔王·人"
		self.attack_in = 15
		self.level = 50
		self.max_hp = 350000
		self.hp = self.max_hp
		self.def = 335
		self.mdef = 350
		self.crit = 30
		self.miss = 25
		self.lucky = 60
		self.htarget = 20
		self.toughness = 10
		self.ar = 40
		self.sp = 40
		self.crit_reduce = 0
		self.speed = 10
		self.mysee = 400
		self.attack_range = 170
		self.attack_desire = 90
		self.behit_calmtime = 0.3
		self.self_rhp = 0
		self.add_exp = 0
		self.fall_coin = 200
		self.obj_attack_dict["hit1"] = {
			"power": int(250 * up_power),
			"hurtBack": [-4, -9],
			"attackKind": "physics",
		}
		self.obj_attack_dict["whs"] = {"power": int(500 * up_power), "hurtBack": [-4, -15], "attackKind": "magic"}
		self.obj_attack_dict["ryzj"] = {"power": int(500 * up_power), "hurtBack": [-6, 0], "attackKind": "magic"}
		self.obj_attack_dict["mncz"] = {
			"power": int(1500 * up_power),
			"hurtBack": [-15, 0],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "stun",
				"AddTime": 10,
				"CanAdd": true,
				"DeBuff": true,
				"DeRemove": false,
				"reduce_interval": 0.5,
				"value": 0,
				"AttackKind": "",
			}
		}
		self.fall_pro = 0.5
		self.fall_list = [
			{"name": "nmwdnhsp", "value": 3},
		]
		self.fall_stone_pro = 0
		self.fall_stone = []
		return
	self.is_boss = true
	self.my_mr_name = "牛魔王·人"
	self.attack_in = 15
	self.level = 25
	self.max_hp = 12000
	self.hp = self.max_hp
	self.def = 100
	self.mdef = 150
	self.crit = 20
	self.miss = 8
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 400
	self.attack_range = 170
	self.attack_desire = 90
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": int(150 * up_power),
		"hurtBack": [-4, -9],
		"attackKind": "physics",
	}
	self.obj_attack_dict["whs"] = {"power": int(200 * up_power), "hurtBack": [-4, -15], "attackKind": "magic"}
	self.obj_attack_dict["ryzj"] = {"power": int(100 * up_power), "hurtBack": [-6, 0], "attackKind": "magic"}
	self.obj_attack_dict["mncz"] = {
		"power": int(300 * up_power),
		"hurtBack": [-15, 0],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 5,
			"CanAdd": true,
			"DeBuff": true,
			"reduce_interval": 0.5,
			"value": 20,
			"AttackKind": "magic",
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "nmwdnhsp", "value": 3},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	monster_23()
	super._ready()
	start_spawn_damage_protection()
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if self.hp <= 0:
		var par = get_parent().get_parent()
		if par is Level10 or par is LevelNMGHDGQ:
			if boss_3 == null:
				var po: Vector2
				if par is Level10:
					po = Vector2(1425, 330)
				elif par is LevelNMGHDGQ:
					po = Vector2(435, 330)
				boss_3 = Global.create_monster(24, get_parent(), po) as Monster24
				var base_level = get_parent().get_parent() as BaseLevel
				base_level.monster_array.push_back(boss_3)


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if skill_1_cd > 0 and skill_2_cd > 0 and skill_3_cd > 0:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
					have_target()
				else:
					if count % 120 == 0:
						if ran_num <= attack_desire:
							attack_target()
					else:
						stop_move()
			else:
				if (
					skill_1_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 180
				):
					do_hit_2()
				elif (
					skill_2_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300
				):
					do_hit_3()
				elif (
					skill_3_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 280
				):
					do_hit_4()
				else:
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
						have_target()
					else:
						if count % 120 == 0:
							if ran_num <= attack_desire:
								attack_target()
						else:
							stop_move()


func do_hit_2():
	skill_1_cd = 12
	hit_name = "whs"
	velocity.x = 0
	is_attacking = true
	mr_player.play("whs")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 20
	hit_name = "mncz"
	velocity.x = 0
	is_attacking = true
	mr_player.play("mncz")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_4():
	skill_3_cd = 18
	hit_name = "ryzj"
	velocity.x = 0
	is_attacking = true
	mr_player.play("ryzj")
	await mr_player.animation_finished
	is_attacking = false


func speed_up():
	velocity.x = 0
	if self.monster_direction:
		velocity.x = 1000
	else:
		velocity.x = -1000


func self_cure():
	cure_hp((self.max_hp - hp) * 0.02)
	if up_power < 10:
		up_power += 0.03
	else:
		up_power = 10
	if get_parent().get_parent() is LevelNMGHDGQ:
		self.obj_attack_dict["hit1"] = {
			"power": int(250 * up_power),
			"hurtBack": [-4, -9],
			"attackKind": "physics",
		}
		self.obj_attack_dict["whs"] = {"power": int(500 * up_power), "hurtBack": [-4, -15], "attackKind": "magic"}
		self.obj_attack_dict["ryzj"] = {"power": int(500 * up_power), "hurtBack": [-6, 0], "attackKind": "magic"}
		self.obj_attack_dict["mncz"] = {
			"power": int(1500 * up_power),
			"hurtBack": [-15, 0],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "stun",
				"AddTime": 10,
				"CanAdd": true,
				"DeBuff": true,
				"DeRemove": false,
				"reduce_interval": 0.5,
				"value": 0,
				"AttackKind": "",
			}
		}
		return
	self.obj_attack_dict["hit1"] = {
		"power": int(150 * up_power),
		"hurtBack": [-4, -9],
		"attackKind": "physics",
	}
	self.obj_attack_dict["whs"] = {"power": int(200 * up_power), "hurtBack": [-4, -15], "attackKind": "magic"}
	self.obj_attack_dict["ryzj"] = {"power": int(100 * up_power), "hurtBack": [-6, 0], "attackKind": "magic"}
	self.obj_attack_dict["mncz"] = {
		"power": int(300 * up_power),
		"hurtBack": [-15, 0],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 5,
			"CanAdd": true,
			"DeBuff": true,
			"reduce_interval": 0.5,
			"value": 20,
			"AttackKind": "magic",
		}
	}

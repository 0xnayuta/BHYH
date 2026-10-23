extends BaseMonster


func monster_4():
	self.is_boss = true
	self.my_mr_name = "猕猴王"
	self.attack_in = 120
	self.level = 10
	self.max_hp = 600
	self.hp = self.max_hp
	self.def = 50
	self.mdef = 80
	self.crit = 5
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 9
	self.mysee = 500
	self.attack_range = 115
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 50
	self.fall_coin = 20
	self.obj_attack_dict["hit1"] = {"power": 55, "hurtBack": [-4, -9], "attackKind": "physics", "HitProtect": 8}
	self.obj_attack_dict["tfhx"] = {
		"power": 90,
		"hurtBack": [-20, -8],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0.6,
			"CanAdd": false,
			"DeBuff": true,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["jfkx"] = {
		"power": 80,
		"hurtBack": [3, -18],
		"attackKind": "magic",
		"HitProtect": 18,
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "dszy", "value": 0},
		{"name": "dslq", "value": 0},
		{"name": "dshp", "value": 0},
		{"name": "dslj", "value": 0}
	]
	self.independent_fall_list = [
		{"name": "210007001", "value": 0, "chance": 0.25},
	]

	enable_treasure_box = true
	treasure_box_item = "mhwbx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_4()
	skill_1_cd = 0
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
			if skill_1_cd > 0 and skill_2_cd > 0:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
					have_target()
				else:
					if count % attack_in == 0:
						if ran_num <= attack_desire:
							attack_target()
					else:
						stop_move()
			else:
				if (
					skill_1_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 350
				):
					do_hit_2()
				elif (
					skill_2_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 180
				):
					do_hit_3()
				else:
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
						have_target()
					else:
						if count % 60 == 0:
							if ran_num <= attack_desire:
								attack_target()
						else:
							stop_move()


func do_hit_2():
	skill_1_cd = 8
	hit_name = "tfhx"
	velocity.x = 0
	is_attacking = true
	mr_player.play("tfhx")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 11
	velocity.x = 0
	hit_name = "jfkx"
	is_attacking = true
	mr_player.play("jfkx")
	var baselevel = get_parent().get_parent() as BaseLevel
	baselevel._shake_screen(25, 6, 0.02)
	await mr_player.animation_finished
	is_attacking = false


func call_tfhx():
	var tf
	var dir = -1
	var speed = 1000
	var distance = 900
	var skill_name = "Monster4Bullet"
	var _name = "tfhx"
	var hit_dic = self.obj_attack_dict["tfhx"]
	var _position: Vector2
	_position = Vector2(self.position.x, self.position.y)
	if self.monster_direction:
		Global.call_fly_bullet(self.bullet, skill_name, dir, _position, distance, speed, _name, hit_dic)
	else:
		Global.call_fly_bullet(self.bullet, skill_name, dir, _position, distance, -speed, _name, hit_dic)

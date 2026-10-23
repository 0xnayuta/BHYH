extends BaseMonster
var htl


func monster_6():
	self.is_boss = true
	self.my_mr_name = "龙王"
	self.attack_in = 15
	self.level = 27
	self.max_hp = 15000
	self.hp = self.max_hp
	self.def = 110
	self.mdef = 160
	self.crit = 5
	self.miss = 0
	self.lucky = 15
	self.htarget = 10
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 600
	self.attack_range = 160
	self.attack_desire = 100
	self.behit_calmtime = 0.4
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 180,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 8,
	}
	self.obj_attack_dict["qnbx"] = {
		"power": 150,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 8,
		"addeffect":
		{
			"Name": "Ice",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"CanAdd": false,
			"DeBuff": true,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["qnhb"] = {
		"power": 120,
		"hurtBack": [-8, -25],
		"attackKind": "real",
		"HitProtect": 8,
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 5,
			"reduce_interval": 0.5,
			"CanAdd": true,
			"value": 20,
			"AttackKind": "real",
		}
	}
	self.obj_attack_dict["htsl"] = {
		"power": 100,
		"hurtBack": [-2, -25],
		"attackKind": "real",
		"HitProtect": 8,
	}
	self.fall_pro = 0.4
	self.fall_list = [
		{"name": "qld", "value": 0},
		{"name": "hdc", "value": 0},
		{"name": "bhz", "value": 0},
		{"name": "zhp", "value": 0},
		{"name": "twq", "value": 0},
		{"name": "ryjgb", "value": 0},
		{"name": "jcdp", "value": 0},
		{"name": "jhcz", "value": 0},
		{"name": "qxsh", "value": 0},
		{"name": "jlxmc", "value": 0},
		{"name": "qthbq", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "zxbx_2"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_6()
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_3_cd <= 0:
					do_hit_4()
				if skill_1_cd <= 0:
					do_hit_2()
				if skill_2_cd <= 0:
					do_hit_3()
				if count % 90 == 0:
					do_hit_1()
			else:
				if skill_3_cd <= 0:
					do_hit_4()
				elif skill_1_cd <= 0:
					do_hit_2()
				elif skill_2_cd <= 0:
					do_hit_3()
				elif count % 90 == 0:
					var rad = randi_range(0, 100)
					if rad <= attack_desire:
						do_hit_1()
				else:
					stop_move()


func do_hit_1():
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
		move_right()
	else:
		move_left()
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	return


func do_hit_2():
	hit_name = "qnbx"
	velocity.x = 0
	is_attacking = true
	mr_player.play("qnbx")
	await mr_player.animation_finished
	skill_1_cd = 19
	is_attacking = false
	return


func do_hit_3():
	hit_name = "qnhb"
	velocity.x = 0
	velocity.y = -5
	is_attacking = true
	mr_player.play("qnhb")
	await mr_player.animation_finished
	skill_2_cd = 16
	is_attacking = false
	return


func do_hit_4():
	hit_name = "htsl"
	velocity.x = 0
	is_attacking = true
	mr_player.play("htsl")
	await mr_player.animation_finished
	skill_3_cd = 12
	is_attacking = false
	return


func call_m6_bullet():
	var fz
	var dir = self.monster_direction
	if dir:
		fz = Global.call_fly_bullet(
			self.bullet,
			"Monster6Bullet",
			1,
			Vector2(position.x + 100, position.y),
			1000,
			-3400,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		fz = Global.call_fly_bullet(
			self.bullet,
			"Monster6Bullet",
			1,
			Vector2(position.x - 100, position.y),
			1000,
			3400,
			"hit1",
			self.obj_attack_dict["hit1"]
		)

	if fz:
		var sprite = fz.get_node("AnimatedSprite2D")
		if sprite:
			sprite.flip_v = dir


func call_bfx():
	var bullet_spawn_positions = [
		Vector2(-182, 65), Vector2(-91, 65), Vector2(0, 65), Vector2(91, 65), Vector2(182, 65)
	]
	var get_po = []
	for i in bullet_spawn_positions:
		get_po.push_back(i + RoleProp.get_nearest_monster_target_position(global_position))
	await get_tree().create_timer(1.6, false).timeout
	for i in get_po:
		Global.add_bullet("Monster6Bullet3", self.bullet, false, 1, i, "qnbx", self.obj_attack_dict["qnbx"])


func m6_hb_effect_2():
	var dir = self.monster_direction
	var position_x = [
		self.position.x,
		self.position.x - 110,
		self.position.x + 110,
		self.position.x - 290,
		self.position.x + 290,
		self.position.x - 400,
		self.position.x + 400,
		self.position.x - 510,
		self.position.x + 510
	]
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[0], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)
	await get_tree().create_timer(0.2).timeout
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[1], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[2], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)
	await get_tree().create_timer(0.2).timeout
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[3], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[4], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)
	await get_tree().create_timer(0.2).timeout
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[5], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[6], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)
	await get_tree().create_timer(0.2).timeout
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[7], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)
	Global.add_bullet(
		"qnhb_2", self.bullet, dir, 1.2, Vector2(position_x[8], self.position.y), "qnhb", self.obj_attack_dict["qnhb"]
	)


func m6_hb_effect_3():
	var dir = self.monster_direction
	if dir:
		Global.add_bullet(
			"htsl",
			self.bullet,
			dir,
			2,
			Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, self.position.y),
			"htsl",
			self.obj_attack_dict["htsl"]
		)
	else:
		Global.add_bullet(
			"htsl",
			self.bullet,
			dir,
			1,
			Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, self.position.y),
			"htsl",
			self.obj_attack_dict["htsl"]
		)

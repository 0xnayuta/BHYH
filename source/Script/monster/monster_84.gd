extends BaseMonster


func monster_84():
	self.is_boss = true
	self.my_mr_name = "广目天王"
	self.attack_in = 10
	self.level = 35
	self.max_hp = 90000
	self.hp = self.max_hp
	self.def = 170
	self.mdef = 170
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 18
	self.toughness = 0
	self.ar = 10
	self.sp = 10
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 300
	self.attack_range = 165
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 225,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"HitProtect": 6,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 1,
			"reduce_interval": 0.5,
			"value": 20,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit2"] = {
		"power": 300,
		"hurtBack": [-10, -55],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 2,
			"reduce_interval": 0.5,
			"value": 50,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit3"] = {
		"power": 350,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"HitProtect": 12,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 2,
			"reduce_interval": 0.5,
			"value": 20,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit4"] = {
		"power": 225,
		"hurtBack": [-4, -9],
		"attackKind": "real",
		"HitProtect": 15,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit5"] = {
		"power": 325,
		"hurtBack": [-4, -9],
		"attackKind": "real",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit6"] = {
		"power": 325,
		"hurtBack": [-4, -9],
		"attackKind": "real",
		"HitProtect": 1,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 2,
			"reduce_interval": 0.5,
			"value": 20,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		},
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "hylk", "value": 0},
		{"name": "qysz", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "gmtwbx"

	update_fall_mode()
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	skill_1_cd = 5
	skill_2_cd = 6
	skill_3_cd = 7
	super._ready()
	monster_84()


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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300:
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
					if skill_3_cd <= 0:
						do_hit_3()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(8, 9)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(15, 17)
	velocity.x = 0
	hit_name = "hit3"
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(12, 14)
	velocity.x = 0
	hit_name = "hit5"
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func tween_to_top():
	if _movement_command_is_blocked():
		return
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Vector2(0, -250) + position, 1.8)

	pass


func add_fire():
	Global.add_bullet("Monster84Bullet3", self, false, 1, Vector2(0, 0), "hit6", self.obj_attack_dict["hit6"])


func call_sfjm_fire():
	var fire_position1 = [Vector2(self.position.x - 80, 440), Vector2(self.position.x + 80, 440)]
	var fire_position2 = [Vector2(self.position.x - 200, 440), Vector2(self.position.x + 200, 440)]
	var fire_position3 = [Vector2(self.position.x - 320, 440), Vector2(self.position.x + 320, 440)]
	for i in range(2):
		Global.add_bullet(
			"Monster42Bullet", self.bullet, false, 1.3, fire_position1[i], "hit3", self.obj_attack_dict["hit3"]
		)
	await get_tree().create_timer(0.2, false).timeout
	for i in range(2):
		Global.add_bullet(
			"Monster42Bullet", self.bullet, false, 1.3, fire_position2[i], "hit3", self.obj_attack_dict["hit3"]
		)
	await get_tree().create_timer(0.2, false).timeout
	for i in range(2):
		Global.add_bullet(
			"Monster42Bullet", self.bullet, false, 1.3, fire_position3[i], "hit3", self.obj_attack_dict["hit3"]
		)


func call_hl():
	var bullet_pos: Vector2
	if monster_direction:
		bullet_pos = Vector2(250, -35)
	else:
		bullet_pos = Vector2(-250, -35)
	var hl = Global.add_bullet(
		"Monster84Bullet2",
		self.bullet,
		monster_direction,
		1,
		bullet_pos + position,
		"hit4",
		self.obj_attack_dict["hit4"]
	)
	hl.scale = Vector2(0.88, 0.88)


func call_fl():
	var bullet_pos: Vector2
	if monster_direction:
		bullet_pos = Vector2(40, -30)
	else:
		bullet_pos = Vector2(-40, -30)
	var fl = Global.add_bullet(
		"Monster84Bullet1",
		self.bullet,
		monster_direction,
		1,
		bullet_pos + position,
		"hit5",
		self.obj_attack_dict["hit5"]
	)
	fl.scale = Vector2(0.7, 0.7)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

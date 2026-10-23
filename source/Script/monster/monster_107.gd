extends BaseMonster


func monster_107():
	self.is_boss = true
	self.my_mr_name = "银角大王"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 200000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 35
	self.sp = 35
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 500
	self.attack_range = 335
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 300
	self.fall_coin = 335
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-5, -9],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 350,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Immobilize",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 800,
		"hurtBack": [-6, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "Boundground",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0,
			"DeBuff": true,
			"AttackKind": "",
			"CanAdd": false,
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 350,
		"hurtBack": [-2, -9],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Scary",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "dudan", "value": 10},
	]
	self.fall_stone_pro = 0.3
	self.fall_stone = [
		{"name": "yjpysp", "value": 1},
	]


func _ready() -> void:
	super._ready()
	monster_107()
	skill_1_cd = randi_range(4, 7)
	skill_2_cd = randi_range(6, 8)
	skill_3_cd = randi_range(10, 15)


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if skill_3_cd <= 0:
					do_hit_3()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 560:
					if skill_2_cd <= 0:
						do_hit_2()
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


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(11, 13)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func add_line():
	if randi_range(0, 100) < 50:
		Global.add_line(self, self, "Red")
	else:
		Global.add_line(self, self, "Blue")


func call_bullet_1():
	var bullet_spawn_positions = []
	if self.monster_direction:
		bullet_spawn_positions = [Vector2(55, 0), Vector2(25, -45), Vector2(25, 45)]
	else:
		bullet_spawn_positions = [Vector2(-55, 0), Vector2(-25, -45), Vector2(-25, 45)]
	for i in bullet_spawn_positions:
		Global.add_bullet(
			"Monster107Bullet1", self.bullet, monster_direction, 1.5, i + position, "hit1", self.obj_attack_dict["hit1"]
		)


func call_bullet_2():
	var bullet_spawn_positions = []
	if self.monster_direction:
		bullet_spawn_positions = [Vector2(0, 0), Vector2(-75, 45), Vector2(50, 45), Vector2(-75, -105), Vector2(75, 25)]
	else:
		bullet_spawn_positions = [Vector2(0, 0), Vector2(75, 45), Vector2(-50, 45), Vector2(75, -105), Vector2(-75, 25)]
	for i in bullet_spawn_positions:
		Global.add_bullet(
			"Monster107Bullet2", self.bullet, monster_direction, 1, i + position, "hit3", self.obj_attack_dict["hit3"]
		)
		await get_tree().create_timer(0.1, false).timeout


func repeat_cure_hp():
	for i in range(5, 8):
		cure_hp(int(max_hp * randf_range(0.02, 0.03)))
		await get_tree().create_timer(0.1, false).timeout

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

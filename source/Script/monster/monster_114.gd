extends BaseMonster
class_name Monster114
var is_combo: bool


func monster_114():
	self.is_boss = true
	self.my_mr_name = "太上老君"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 400000
	self.hp = self.max_hp
	self.def = 200
	self.mdef = 200
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
	self.attack_range = 235
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
		"power": 700,
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
		"power": 600,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 0.3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 800,
		"hurtBack": [-2, -9],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": 80,
			"AttackKind": "magic",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "doushuaiziyanzzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_114()
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
				if skill_1_cd <= 0:
					do_hit_1()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 560:
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
					if skill_3_cd <= 0:
						do_hit_3()
			else:
				stop_move()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_1_cd <= 0:
					do_hit_1()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(15, 18)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(10, 12)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(15, 17)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet():
	if self.monster_direction:
		Global.add_bullet(
			"Monster114Bullet1", self.bullet, false, 1, Vector2(65, 50) + position, "hit3", self.obj_attack_dict["hit3"]
		)
	else:
		Global.add_bullet(
			"Monster114Bullet1",
			self.bullet,
			false,
			1,
			Vector2(-65, 50) + position,
			"hit3",
			self.obj_attack_dict["hit3"]
		)


func call_bullet_2():
	var position_list1 = [Vector2(position.x + 150, 500), Vector2(position.x + 0, 500), Vector2(position.x - 150, 500)]
	var position_list2 = [Vector2(position.x + 300, 500), Vector2(position.x - 300, 500)]
	var position_list3 = [Vector2(position.x + 450, 500), Vector2(position.x - 450, 500)]
	var position_list4 = [Vector2(position.x + 600, 500), Vector2(position.x - 600, 500)]
	var position_list5 = [Vector2(position.x + 750, 500), Vector2(position.x - 750, 500)]
	for i in position_list1:
		Global.add_bullet("Monster114Bullet3", self.bullet, false, 1, i, "hit4", self.obj_attack_dict["hit4"])
	await get_tree().create_timer(0.2, false).timeout
	for i in position_list2:
		Global.add_bullet("Monster114Bullet3", self.bullet, false, 1, i, "hit4", self.obj_attack_dict["hit4"])
	await get_tree().create_timer(0.2, false).timeout
	for i in position_list3:
		Global.add_bullet("Monster114Bullet3", self.bullet, false, 1, i, "hit4", self.obj_attack_dict["hit4"])
	await get_tree().create_timer(0.2, false).timeout
	for i in position_list4:
		Global.add_bullet("Monster114Bullet3", self.bullet, false, 1, i, "hit4", self.obj_attack_dict["hit4"])
	await get_tree().create_timer(0.2, false).timeout
	for i in position_list5:
		Global.add_bullet("Monster114Bullet3", self.bullet, false, 1, i, "hit4", self.obj_attack_dict["hit4"])

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

extends BaseMonster
class_name Monster59
var role_be_hit_count = Global.player_be_hit_count


func monster_59(BeHitCount):
	self.is_boss = true
	self.my_mr_name = "宋帝王"
	self.attack_in = 10
	self.level = 30
	self.max_hp = 19000 + BeHitCount * 8000
	self.hp = self.max_hp
	self.def = 125 + BeHitCount * 15
	self.mdef = 95 + BeHitCount * 15
	self.crit = 5 + BeHitCount * 0.2
	self.miss = 5 + BeHitCount * 0.8
	self.lucky = 5 + BeHitCount * 0.5
	self.htarget = 5 + BeHitCount * 0.5
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 400
	self.attack_range = 185
	self.attack_desire = 50 + BeHitCount * 1.5
	self.behit_calmtime = 0.2
	self.self_rhp = BeHitCount * 70
	self.add_exp = 100
	self.fall_coin = 100
	self.obj_attack_dict["hit1"] = {
		"power": 128 + BeHitCount * 25,
		"hurtBack": [-6, -1],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 2 + BeHitCount * 0.5,
			"reduce_interval": 0.5,
			"value": 15 + BeHitCount * 5,
			"AttackKind": "real",
			"DeBuff": true,
			"CanAdd": true,
		}
	}
	self.obj_attack_dict["zmhy"] = {
		"power": 128 + BeHitCount * 25,
		"hurtBack": [0, -18],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "silent",
			"AddTime": 4 + BeHitCount * 0.3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.obj_attack_dict["zzzy"] = {
		"power": 333 + BeHitCount * 20,
		"hurtBack": [-12, -1],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Boundground",
			"AddTime": 3 + BeHitCount * 0.5,
			"reduce_interval": 0,
			"value": 0,
			"DeBuff": true,
			"AttackKind": "",
			"CanAdd": false,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "wyzy", "value": 0},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0
	role_be_hit_count = Global.player_be_hit_count
	monster_59(role_be_hit_count)


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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 900:
					if skill_2_cd <= 0:
						do_hit_2()
			else:
				if skill_1_cd <= 0:
					do_hit_1()
				elif skill_2_cd <= 0:
					do_hit_2()
				else:
					if count % 40 == 0:
						if randi_range(0, 100) < attack_desire:
							attack_target()
						else:
							normal_state()
					else:
						stop_move()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(14, 17)
	hit_name = "zmhy"
	velocity.x = 0
	is_attacking = true
	mr_player.play("zmhy")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(10, 14)
	velocity.x = 0
	hit_name = "zzzy"
	is_attacking = true
	mr_player.play("zzzy")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_zzzy():
	var bullet_name = "Monster59Bullet_1"
	var bullet_pos
	if monster_direction:
		bullet_pos = Vector2(420, randi_range(-130, 130)) + self.position
		Global.add_bullet(bullet_name, self.bullet, true, 1, bullet_pos, "zzzy", self.obj_attack_dict["zzzy"])
	else:
		bullet_pos = Vector2(-420, randi_range(-130, 130)) + self.position
		Global.add_bullet(bullet_name, self.bullet, false, 1, bullet_pos, "zzzy", self.obj_attack_dict["zzzy"])


func call_zzhy():
	var target_count = 3 + int(role_be_hit_count / 3)
	for i in range(target_count):
		var bullet_pos = Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x + randi_range(-140, 140), 500
		)
		Global.add_bullet("Monster59Bullet_2", self.bullet, false, 1, bullet_pos, "zmhy", self.obj_attack_dict["zmhy"])


func state_hurt():
	is_jgz = false
	if role_be_hit_count >= 13:
		is_be_attacking = false
		return
	super.state_hurt()

extends BaseMonster
class_name Monster141
var whs_count: int = 0


func monster_141():
	self.rush_speed = 400
	self.is_boss = true
	self.my_mr_name = "牛魔王·魂"
	self.attack_in = 90
	self.level = 55
	self.max_hp = 500000
	self.hp = self.max_hp
	self.def = 300
	self.mdef = 300
	self.crit = 30
	self.miss = 20
	self.lucky = 20
	self.htarget = 25
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 500
	self.attack_range = 130
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 500
	self.ebol = 0
	self.obj_attack_dict["hit1"] = {
		"power": 300,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 1500,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "real",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 400,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 20,
			"reduce_interval": 0,
			"value": 0.5,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 1000,
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.obj_attack_dict["hit5"] = {
		"power": 300,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 0,
	}
	self.obj_attack_dict["hit6"] = {
		"power": 300,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 0,
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "nmwdnhzzs", "value": 1},
	]
	self.fall_stone_pro = 0.1
	self.fall_stone = [
		{"name": "nmwjh", "value": 1},
	]


func _ready() -> void:
	super._ready()
	monster_141()
	skill_1_cd = randi_range(3, 4)
	skill_2_cd = 10
	skill_3_cd = 5
	skill_4_cd = 12
	skill_5_cd = 15


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	whs_count += 1
	if whs_count % 600 == 0:
		var bullet = Global.add_bullet(
			"Monster141Bullet4", self, true, 1, Vector2(0, -30), "hit6", self.obj_attack_dict["hit6"]
		)
		bullet.scale = Vector2(2, 2)


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if skill_2_cd <= 0:
					do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300:
					if skill_1_cd <= 0:
						do_hit_1()
				if skill_3_cd <= 0:
					do_hit_3()
				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = 15
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = 20
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = 15
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func state_hurt():
	is_jgz = false
	if hd > 0:
		is_be_attacking = false
		return
	if randi_range(0, 100) <= 10:
		is_be_attacking = true
		hit_name = "hit5"
		mr_player.play("hit5")
		await mr_player.animation_finished
		is_be_attacking = false
		return
	if get_target.hit_dic["hurtBack"][0] != 0 or get_target.hit_dic["hurtBack"][1] != 0:
		is_be_attacking = true
		velocity.x = 0
		if is_quiescent or is_bt:
			pass
		else:
			be_hit_back(get_target)
		if get_target.hit_dic["hurtBack"][0] != 0 or get_target.hit_dic["hurtBack"][1] != 0:
			mr_player.play("hurt")
			await mr_player.animation_finished
		is_be_attacking = false


func call_bullet_1():
	for i in range(8):
		var _bullet
		var bullet_pos = Vector2(position.x + randi_range(-450, 500), -300)
		_bullet = Global.add_bullet(
			"Monster141Bullet3", self.bullet, false, 0.15, bullet_pos, "hit3", self.obj_attack_dict["hit3"]
		)
		var lasthp = (float(max_hp) - float(hp)) / float(max_hp)
		var scalevalue = float(1 + lasthp)

		_bullet.scale = Vector2(scalevalue, scalevalue)
		_bullet.look_at(RoleProp.get_nearest_monster_target_position(global_position))
		await get_tree().create_timer(0.5, false).timeout


func call_bullet_alt2():
	var dis = int(Global.get_dis_betweem(self, RoleProp.source_player))
	if dis < attack_range:
		return
	var bb
	if self.monster_direction:
		bb = Global.add_bullet(
			"Monster141Bullet2", self.bullet, false, 2, Vector2(20, 0) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	else:
		bb = Global.add_bullet(
			"Monster141Bullet2", self.bullet, false, 2, Vector2(-20, 0) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	bb.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_3():
	var bullet_spawn_positions = [
		Vector2(-300 + position.x, 370),
		Vector2(-200 + position.x, 370),
		Vector2(-100 + position.x, 370),
		Vector2(0 + position.x, 370),
		Vector2(100 + position.x, 370),
		Vector2(200 + position.x, 370),
		Vector2(300 + position.x, 370),
	]
	for i in bullet_spawn_positions:
		Global.add_bullet("Monster22Fire", self.bullet, false, 1, i, "hit2", self.obj_attack_dict["hit2"])


func call_bullet_4():
	Global.add_bullet(
		"Monster141Bullet1",
		self.bullet,
		false,
		1,
		Vector2(position.x - 1000, 450),
		"hit4",
		self.obj_attack_dict["hit4"]
	)
	Global.add_bullet(
		"Monster141Bullet1", self.bullet, true, 1, Vector2(position.x + 1000, 450), "hit4", self.obj_attack_dict["hit4"]
	)


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func call_bullet_2():
	return call_bullet_alt2()

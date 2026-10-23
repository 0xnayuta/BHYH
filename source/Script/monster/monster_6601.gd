extends BaseMonster
@onready var special_effect: AnimatedSprite2D = $MonsterDir/SpecialEffect
var _num: int = 0
var m_ubei: BaseMonster


func monster_6601():
	self.is_boss = true
	self.my_mr_name = "五毒·平等王"
	self.attack_in = 15
	self.level = RoleProp.baseroleprop.Level + 1
	self.max_hp = 240000 + int(RoleProp.baseroleprop.Level * 16000)
	self.hp = self.max_hp
	self.def = 180 + int(RoleProp.baseroleprop.Level * 4.3)
	self.mdef = 180 + int(RoleProp.baseroleprop.Level * 4.3)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 1.4)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.7)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 2.0)
	self.htarget = 0
	self.toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 1.3)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 1.3)
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 500
	self.attack_range = 125
	self.attack_desire = 150
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 500 + int(RoleProp.baseroleprop.Level * 8.8),
		"hurtBack": [-7, -9],
		"attackKind": "magic",
	}
	self.obj_attack_dict["skill_1_1"] = {
		"power": 2000 + int(RoleProp.baseroleprop.Level * 8.8),
		"hurtBack": [-8, 0],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Boundground",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["skill_1_2"] = {
		"power": 600 + int(RoleProp.baseroleprop.Level * 8.8),
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0.2,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["skill_1_3"] = {
		"power": 500 + int(RoleProp.baseroleprop.Level * 8.8),
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "silent",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["skill_1_4"] = {
		"power": 500 + int(RoleProp.baseroleprop.Level * 8.8),
		"hurtBack": [-5, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": 60,
			"AttackKind": "magic",
		}
	}
	self.obj_attack_dict["skill_2"] = {
		"power": 1000 + int(RoleProp.baseroleprop.Level * 8.8),
		"hurtBack": [0, 0],
		"attackKind": "real",
	}
	self.obj_attack_dict["skill_3"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.8),
		"hurtBack": [-6, -9],
		"attackKind": "real",
	}
	self.obj_attack_dict["skill_4"] = {
		"power": 1000 + int(RoleProp.baseroleprop.Level * 8.8),
		"hurtBack": [-6, -9],
		"attackKind": "real",
	}
	self.fall_pro = 0.15
	self.fall_list = [
		{"name": "gzyj", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_6601()
	skill_1_cd = 2
	skill_2_cd = 4
	skill_3_cd = 4
	skill_4_cd = 0


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 800:
					if skill_1_cd <= 0:
						use_skill_1()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 600:
					if m_ubei == null:
						if skill_2_cd <= 0:
							use_skill_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
					if skill_3_cd <= 0:
						use_skill_3()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
					if skill_4_cd <= 0:
						if max_hp * 0.5 >= hp:
							use_skill_4()
			else:
				if skill_3_cd <= 0:
					use_skill_3()
				elif skill_1_cd <= 0:
					use_skill_1()
				elif skill_2_cd <= 0:
					if m_ubei == null:
						if skill_2_cd <= 0:
							use_skill_2()
				elif skill_4_cd <= 0:
					if max_hp * 0.5 >= hp:
						use_skill_4()
					elif count % 60 == 0:
						attack_target()
					else:
						stop_move()
				elif count % 180 == 0:
					attack_target()
				else:
					stop_move()


func use_skill_1():
	super.to_hero()
	hit_name = "skill_1_1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("skill_1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func use_skill_2():
	skill_2_cd = randi_range(35, 45)
	super.to_hero()
	hit_name = "skill_1_1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("skill_2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func use_skill_3():
	skill_3_cd = randi_range(16, 20)
	super.to_hero()
	hit_name = "skill_3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("skill_3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func use_skill_4():
	skill_4_cd = randi_range(10, 15)
	super.to_hero()
	hit_name = "skill_4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("Skill_4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_1():
	super.to_hero()
	hit_name = "skill_1_1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("skill_1_1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	hit_name = "skill_1_2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("skill_1_2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	hit_name = "skill_1_3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("skill_1_3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	super.to_hero()
	hit_name = "skill_1_4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("skill_1_4")
	await mr_player.animation_finished
	is_attacking = false


func rnd_skill():
	_num = randi_range(0, 3)
	special_effect.frame = _num


func change_skill():
	skill_1_cd = randi_range(12, 14)
	match _num:
		0:
			do_hit_1()
		1:
			do_hit_2()
		2:
			do_hit_3()
		3:
			do_hit_4()


func call_m_ubei():
	if m_ubei == null:
		m_ubei = Global.create_monster(6602, get_parent(), Vector2(490, 260))


func call_wg_wb_ullet():
	for i in range(randi_range(4, 6)):
		var bullet_pos = Vector2(self.position.x, self.position.y) + Vector2(0, randi_range(-180, 80))
		var _bullet = Global.add_bullet(
			"Monster61WGW",
			self.bullet,
			monster_direction,
			1,
			bullet_pos,
			"skill_1_4",
			self.obj_attack_dict["skill_1_4"]
		)
		await get_tree().create_timer(0.1, false).timeout


func call_tsw_bullet():
	var pp = self.position
	var bullet_spawn_positions = [
		Vector2(-180, 0) + pp, Vector2(0, 0) + pp, Vector2(180, 0) + pp, Vector2(-360, 0) + pp, Vector2(360, 0) + pp
	]
	for i in range(5):
		var bullet_pos = bullet_spawn_positions[i]
		var _bullet = Global.add_bullet(
			"Monster61TSw",
			self.bullet,
			monster_direction,
			1.7,
			bullet_pos,
			"skill_1_3",
			self.obj_attack_dict["skill_1_3"]
		)
		if _bullet:
			_bullet.scale = Vector2(1.5, 1.5)


func call_bcw_bullet():
	var po_sition
	if monster_direction:
		po_sition = self.position + Vector2(200, -30)
	else:
		po_sition = self.position + Vector2(-200, -30)
	var bullet_instance = Global.add_bullet(
		"Monster61BCW", self.bullet, monster_direction, 1, po_sition, "skill_1_1", self.obj_attack_dict["skill_1_1"]
	)
	if bullet_instance:
		bullet_instance.scale = Vector2(1.5, 1.5)


func call_dsw_bullet():
	var po_sition
	if monster_direction:
		po_sition = self.position + Vector2(300, -50)
	else:
		po_sition = self.position + Vector2(-300, -50)
	var bullet_instance = Global.add_bullet(
		"Monster61DSW", self.bullet, monster_direction, 1, po_sition, "skill_1_2", self.obj_attack_dict["skill_1_2"]
	)
	if bullet_instance:
		bullet_instance.scale = Vector2(1.5, 1.5)


func call_bullet_4():
	var po_sition
	if monster_direction:
		po_sition = self.position + Vector2(300, 0)
	else:
		po_sition = self.position + Vector2(-300, 0)
	var bullet_instance = Global.add_bullet(
		"Monster66bull4", self.bullet, monster_direction, 1, po_sition, "skill_4", self.obj_attack_dict["skill_4"]
	)


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	if hit_name == "skill_4":
		if RoleProp.roleprop.Hp <= RoleProp.roleprop.Hp * 0.2:
			hp = max_hp * 0.2
		else:
			var bl = float(hp) / float(max_hp)
			if bl >= 0.9:
				bl = 0.9
			hp = float(RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp) * max_hp
			RoleProp.roleprop.Hp = RoleProp.roleprop.SHp * bl

	return super._on_hit_box_area_entered(area)


func call_bj():
	var _p = self.position
	var base_offsets = [
		Vector2(-70, 50),
		Vector2(-95, 50),
		Vector2(-120, 50),
		Vector2(-145, 50),
		Vector2(-170, 50),
		Vector2(-195, 50),
		Vector2(-220, 50),
		Vector2(-245, 50),
		Vector2(-270, 50),
		Vector2(-295, 50),
		Vector2(-320, 50),
		Vector2(-345, 50),
		Vector2(-370, 50),
		Vector2(-395, 50),
		Vector2(70, 50),
		Vector2(95, 50),
		Vector2(120, 50),
		Vector2(145, 50),
		Vector2(170, 50),
		Vector2(195, 50),
		Vector2(220, 50),
		Vector2(245, 50),
		Vector2(270, 50),
		Vector2(295, 50),
		Vector2(320, 50),
		Vector2(345, 50),
		Vector2(370, 50),
		Vector2(395, 50)
	]
	for offset in base_offsets:
		var final_pos = _p + offset + Vector2(0, 40)
		Global.add_bullet(
			"Monster_61Bullet", self.bullet, monster_direction, 1, final_pos, "skill_3", self.obj_attack_dict["skill_3"]
		)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

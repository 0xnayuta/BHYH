extends BaseMonster
var is_drop = false
var first: bool = true
var fs: bool = false
@onready var change_timer: Timer = $ChangeTimer
@onready var special_effect: AnimatedSprite2D = $MonsterDir/SpecialEffect


func monster_64():
	self.rush_speed = 600
	self.is_boss = true
	self.my_mr_name = "五毒·泰山王"
	self.attack_in = 15
	self.level = RoleProp.baseroleprop.Level + 1
	self.max_hp = 200000 + int(RoleProp.baseroleprop.Level * 14000)
	self.hp = self.max_hp
	self.def = 180 + int(RoleProp.baseroleprop.Level * 3.5)
	self.mdef = 180 + int(RoleProp.baseroleprop.Level * 3.5)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 1)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.5)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 1.6)
	self.htarget = 0
	self.toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 0.8)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 0.8)
	self.crit_reduce = 0
	self.speed = 9
	self.mysee = 500
	self.attack_range = 335
	self.attack_desire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [-7, -9],
		"attackKind": "physics",
		"HitProtect": 4
	}
	self.obj_attack_dict["hit1_1"] = {
		"power": 200 + int(RoleProp.baseroleprop.Level * 8),
		"hurtBack": [-15, -20],
		"attackKind": "magic",
		"HitProtect": 4
	}
	self.obj_attack_dict["hit1_2"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [50, -20],
		"attackKind": "magic",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0.2,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["xlyj"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [-8, 0],
		"attackKind": "physics",
		"HitProtect": 25,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": randi_range(1, 5),
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.obj_attack_dict["yscs"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "HitProtect": 4}
	self.obj_attack_dict["tsyd"] = {
		"power": 500 + int(RoleProp.baseroleprop.Level * 9),
		"hurtBack": [-3, 0],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 3,
			"reduce_interval": 0.5,
			"value": 300 + int(RoleProp.baseroleprop.Level * 3),
			"AttackKind": "magic",
			"CanAdd": true,
			"DeBuff": true,
		}
	}

	self.obj_attack_dict["zhq_3"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [-50, -40],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["sgq"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8.5),
		"hurtBack": [-4, -40],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}

	self.fall_pro = 0.15
	self.fall_list = [
		{"name": "czyj", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	change_timer.start(randi_range(14, 16))
	super._ready()
	monster_64()
	skill_1_cd = 2
	skill_2_cd = 6
	skill_3_cd = 4
	skill_4_cd = 8
	skill_5_cd = 15
	skill_6_cd = 20
	skill_7_cd = 13


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
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()
				if (
					skill_5_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 100
				):
					do_hit_5()
				if skill_6_cd <= 0:
					do_hit_6()
				if (
					skill_7_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400
				):
					do_hit_7()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()
				if (
					skill_5_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 100
				):
					do_hit_5()
				if skill_6_cd <= 0:
					do_hit_6()
				if (
					skill_7_cd <= 0
					and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400
				):
					do_hit_7()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(2, 5)
	hit_name = "hit1_1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(24, 34)
	hit_name = "xlyj"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(15, 20)
	hit_name = "yscs"
	velocity.x = 0
	is_attacking = true
	mr_player.play("yscs")
	await mr_player.animation_finished
	is_attacking = false
	do_hit_1()


func do_hit_4():
	super.to_hero()
	skill_4_cd = randi_range(28, 38)
	hit_name = "xlyj"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_5():
	super.to_hero()
	skill_5_cd = randi_range(10, 15)
	hit_name = "sgq"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_6():
	super.to_hero()
	skill_6_cd = randi_range(30, 40)
	hit_name = "tsyd"
	velocity.x = 0
	is_attacking = true
	mr_player.play("tsyd")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_7():
	super.to_hero()
	skill_7_cd = randi_range(10, 15)
	hit_name = "hit1_2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit5")
	await mr_player.animation_finished
	is_attacking = false
	if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 100:
		do_hit_5()
	else:
		stop_move()


func move_self_to_player():
	self.position = RoleProp.get_nearest_monster_target_position(global_position)


func call_fly_bullet():
	var fz
	if self.monster_direction:
		fz = Global.call_fly_bullet(
			self.bullet,
			"Monster_63Bullet",
			1,
			Vector2(position.x + 100, position.y + 40),
			1000,
			-900,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		fz = Global.call_fly_bullet(
			self.bullet,
			"Monster_63Bullet",
			1,
			Vector2(position.x - 100, position.y + 40),
			1000,
			900,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
		fz.get_node("AnimatedSprite2D").flip_h = true
	if first:
		fz.scale = Vector2(1, 1)
	else:
		fz.scale = Vector2(1.5, 1.5)


func call_fly_bullet2():
	var fz
	if self.monster_direction:
		fz = Global.call_fly_bullet(
			self.bullet,
			"Monster63Bullet",
			1,
			Vector2(position.x + 100, position.y),
			300,
			-1500,
			"zhq_3",
			self.obj_attack_dict["zhq_3"]
		)
	else:
		fz = Global.call_fly_bullet(
			self.bullet,
			"Monster63Bullet",
			1,
			Vector2(position.x - 100, position.y),
			300,
			1500,
			"zhq_3",
			self.obj_attack_dict["zhq_3"]
		)
		fz.get_node("AnimatedSprite2D").flip_h = true
	if first:
		fz.scale = Vector2(1, 1)
	else:
		fz.scale = Vector2(2, 2)


func _on_timer_timeout() -> void:
	if not fs:
		fs = true
		change_timer.start(randi_range(9, 11))
	else:
		fs = false
		change_timer.start(randi_range(22, 25))
	change_self_color()


func change_self_color():
	var tween = get_tree().create_tween()

	if fs:
		tween.tween_property(self, "modulate", Color("00ffff"), 1)
	else:
		tween.tween_property(self, "modulate", Color("ffffff"), 1)
	pass


func _on_hurt_box_area_entered(area: Area2D) -> void:
	super._on_hurt_box_area_entered(area)
	if fs:
		if get_player != null:
			get_player.effect_reducehp(self.hurt_received, "real")
		self.hurt_received = 0


func to_top():
	if _movement_command_is_blocked():
		return
	var po = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, -30)
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", po, 0.4)


func to_drop():
	if _movement_command_is_blocked():
		velocity.y = 0
		is_drop = false
		return
	velocity.y += 800

	await mr_player.animation_finished
	is_attacking = false
	is_drop = false


func call_bullet():
	var bullet_spawn_positions
	if first:
		bullet_spawn_positions = [
			Vector2(-158, 105), Vector2(158, 105), Vector2(0, 105), Vector2(-315, 105), Vector2(315, 105)
		]
	else:
		bullet_spawn_positions = [
			Vector2(-280, 240), Vector2(280, 240), Vector2(0, 240), Vector2(620, 240), Vector2(-620, 240)
		]
	for i in bullet_spawn_positions:
		var bb = Global.add_bullet(
			"Monster63Bullet", self.bullet, false, 1, i + self.position, "tsyd", self.obj_attack_dict["tsyd"]
		)
		if first:
			bb.scale = Vector2(1.5, 1.5)
		else:
			bb.scale = Vector2(2.0, 2.0)


func _on_change_timer_timeout() -> void:
	pass

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

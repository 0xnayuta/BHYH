extends BaseMonster
var my_child: MonsterBullet


func monster_103():
	self.is_boss = true
	self.my_mr_name = "托塔天王"
	self.attack_in = 60
	self.level = 40
	self.max_hp = 180000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 50
	self.miss = 25
	self.lucky = 115
	self.htarget = 35
	self.toughness = 0
	self.ar = 30
	self.sp = 30
	self.crit_reduce = 0
	self.speed = 16
	self.mysee = 500
	self.attack_range = 245
	self.attack_desire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 120
	self.fall_coin = 155
	self.obj_attack_dict["hit1"] = {
		"power": 300,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 355,
		"hurtBack": [-20, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.4,
			"AttackKind": "",
			"CanRemove": false,
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit3"] = {
		"power": int(200 + RoleProp.roleprop.SHp * 0.3),
		"hurtBack": [-18, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 10,
			"reduce_interval": 0,
			"value": 400,
			"AttackKind": "real",
			"CanRemove": false,
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 200,
		"hurtBack": [-6, -8],
		"attackKind": "real",
		"HitProtect": 10,
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "llyzzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_103()
	skill_1_cd = randi_range(3, 5)
	skill_2_cd = randi_range(5, 8)
	skill_3_cd = randi_range(0, 6)


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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
					if skill_3_cd <= 0:
						do_hit_3()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 360:
					if skill_2_cd <= 0:
						do_hit_2()
			else:
				stop_move()
				if skill_3_cd <= 0:
					do_hit_3()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif skill_1_cd <= 0:
					do_hit_1()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


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
	skill_3_cd = randi_range(10, 12)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_1():
	if self.monster_direction:
		Global.call_fly_bullet(
			self.bullet,
			"Monster103Bullet",
			1,
			Vector2(position.x + 50, position.y + 30),
			600,
			-700,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		var fz = Global.call_fly_bullet(
			self.bullet,
			"Monster103Bullet",
			1,
			Vector2(position.x - 50, position.y + 30),
			600,
			700,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
		fz.get_node("AnimatedSprite2D").flip_h = true


func call_bullet_2():
	var bool_list = [true, false]
	for i in bool_list:
		Global.add_bullet(
			"Monster103Bullet3", self.bullet, i, 2, Vector2(0, -50) + position, "hit2", self.obj_attack_dict["hit2"]
		)
	await get_tree().create_timer(0.4, false).timeout
	for i in bool_list:
		Global.add_bullet(
			"Monster103Bullet3", self.bullet, i, 2, Vector2(0, -50) + position, "hit2", self.obj_attack_dict["hit2"]
		)
	await get_tree().create_timer(0.4, false).timeout
	for i in bool_list:
		Global.add_bullet(
			"Monster103Bullet3", self.bullet, i, 2, Vector2(0, -50) + position, "hit2", self.obj_attack_dict["hit2"]
		)
	await get_tree().create_timer(0.4, false).timeout


func call_bullet_3():
	await get_tree().create_timer(4, false).timeout
	var po = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 70)
	await get_tree().create_timer(0.2, false).timeout
	Global.add_bullet("Monster103Bullet1", self.bullet, false, 1, po, "hit3", self.obj_attack_dict["hit3"])


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	if hit_name == "hit4":
		if is_instance_valid(get_player) and obj_attack_dict != null and obj_attack_dict.has("hit4"):
			Global.add_bullet(
				"Monster103Bullet2",
				self.bullet,
				false,
				1,
				RoleProp.get_nearest_monster_target_position(global_position),
				"hit4",
				self.obj_attack_dict["hit4"]
			)

	var buff_target = super._on_hit_box_area_entered(area)

	return buff_target

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

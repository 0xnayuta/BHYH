extends BaseMonster
var my_child: MonsterBullet
var tick_count: int = 0


func monster_101():
	self.is_fly = true
	self.is_boss = true
	self.my_mr_name = "雷震子"
	self.attack_in = 60
	self.level = 40
	self.max_hp = 140000
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
		"power": 350,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 250,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 4,
			"reduce_interval": 0,
			"value": 0.3,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit3"] = {
		"power": 500,
		"hurtBack": [-6, -1],
		"attackKind": "magic",
		"HitProtect": 5,
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
	self.obj_attack_dict["hit4"] = {
		"power": 350,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 15,
			"reduce_interval": 0,
			"value": 0.5,
			"AttackKind": "",
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.4
	self.fall_list = [
		{"name": "tczzs", "value": 1},
		{"name": "czzzs", "value": 1},
		{"name": "thzzs", "value": 1},
		{"name": "tqzzs", "value": 1},
	]

	enable_treasure_box = true
	treasure_box_item = "lzzbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_101()
	skill_1_cd = randi_range(8, 13)
	skill_2_cd = randi_range(5, 8)
	skill_3_cd = randi_range(0, 6)


func ai_think():
	if my_child != null:
		tick_count += 1
		if tick_count >= 900:
			my_child.queue_free()
	else:
		tick_count = 0
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if my_child == null and skill_1_cd <= 0:
					do_hit_1()
				if skill_3_cd <= 0:
					do_hit_3()
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 560:
					if skill_2_cd <= 0:
						do_hit_2()
			else:
				stop_move()
				if skill_3_cd <= 0:
					do_hit_3()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif my_child == null and skill_1_cd <= 0:
					do_hit_1()
				if tick_count % 60 == 0:
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


func call_bullet_1():
	var position_list = [
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x - 420, 500),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x - 280, 500),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x - 140, 500),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 500),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x + 140, 500),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x + 280, 500),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x + 420, 500)
	]
	for i in position_list:
		Global.add_bullet("Monster101Bullet", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"])


func call_bullet_2():
	var bullet_node
	if self.monster_direction:
		bullet_node = Global.add_bullet(
			"Monster101Bullet1", self.bullet, false, 1, Vector2(35, 25) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	else:
		bullet_node = Global.add_bullet(
			"Monster101Bullet1",
			self.bullet,
			false,
			1,
			Vector2(-35, 25) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_3():
	if my_child == null:
		my_child = Global.add_bullet(
			"Monster101Bullet2", self.bullet, false, 1, position, "hit2", self.obj_attack_dict["hit2"]
		)


func move_player():
	self.position = Vector2(
		RoleProp.get_nearest_monster_target_position(global_position).x,
		RoleProp.get_nearest_monster_target_position(global_position).y
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

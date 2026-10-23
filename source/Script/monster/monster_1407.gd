extends BaseMonster

var alternate_side: bool = false

var my_child: MonsterBullet
var tick_count: int = 0
var is_checking_silent: bool = false
var silent_check_timer: Timer
var has_summoned_1404: bool = false
var has_applied_shield: bool = false
var shield_value: int = 0

var is_special_combo: bool = false


func monster_1407():
	self.is_fly = true
	self.is_boss = true
	self.my_mr_name = "琼霄娘娘"
	self.rush_speed = 600
	self.attack_in = 130
	self.level = 58
	self.max_hp = 1800000
	self.hp = self.max_hp
	self.def = 630
	self.mdef = 630
	self.crit = 35
	self.miss = 55
	self.lucky = 80
	self.htarget = 95
	self.toughness = 40
	self.ar = 120
	self.sp = 120
	self.crit_reduce = 20
	self.speed = 20
	self.mysee = 600
	self.attack_range = 550
	self.attack_desire = 100
	self.behit_calmtime = 0.05
	self.self_rhp = 0
	self.add_exp = 6000
	self.fall_coin = 2500
	self.ebol = 0

	self.has_summoned_1404 = false

	self.obj_attack_dict["hit1"] = {
		"power": 850,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}

	self.obj_attack_dict["hit2"] = {
		"power": 900,
		"hurtBack": [0, -100],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2_1"] = {
		"power": 860,
		"hurtBack": [-30, 0],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "lpzbuff",
			"AddTime": 10,
			"reduce_interval": 0,
			"value": 0.2,
			"CanAdd": true,
			"CanRemove": false,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 950,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0.61,
			"value": 0.3,
			"AttackKind": "magic",
			"CanAdd": true,
			"DeBuff": true,
		}
	}

	self.obj_attack_dict["hit4"] = {
		"power": 950,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0.2,
			"AttackKind": "",
			"CanAdd": true,
			"DeBuff": true,
		},
	}

	self.obj_attack_dict["hit5"] = {
		"power": 250,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
	}

	self.fall_pro = 0.4
	self.fall_list = [
		{"name": "bxhyzzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]

	if Global.current_level == "仙树岛":
		independent_fall_list = YutuEquipmentData.stage_book_drops("仙树岛")


func _ready() -> void:
	super._ready()
	monster_1407()

	skill_1_cd = 3
	skill_2_cd = 10
	skill_3_cd = 7
	skill_4_cd = 12
	skill_5_cd = 25


func ai_think():
	if my_child != null:
		tick_count += 1
		if tick_count >= 900:
			my_child.queue_free()
			my_child = null
			tick_count = 0

	if is_attacking or is_special_combo:
		return

	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if not has_target:
			normal_state()
			return

		var distance_to_player = abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x)

		if distance_to_player < attack_range:
			if skill_2_cd <= 0:
				do_hit_2_1()
			elif skill_1_cd <= 0:
				do_hit_1()
			elif skill_3_cd <= 0:
				do_hit_3()
			elif skill_4_cd <= 0:
				do_hit_4()
			elif skill_5_cd <= 0:
				do_hit_5()
			else:
				normal_state()
		else:
			have_target()
			if skill_3_cd <= 0:
				do_hit_3()
			elif skill_1_cd <= 0:
				do_hit_1()
			elif skill_2_cd <= 0:
				do_hit_2_1()
			elif skill_4_cd <= 0:
				do_hit_4()
			elif skill_5_cd <= 0:
				do_hit_5()
			else:
				have_target()


func do_hit_1():
	if is_attacking or is_special_combo:
		return

	super.to_hero()
	skill_1_cd = 3
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2_1():
	if is_attacking or is_special_combo:
		return

	super.to_hero()
	skill_2_cd = randi_range(20, 25)
	hit_name = "hit2_1"
	velocity.x = 0
	velocity.y = 0

	is_attacking = true
	is_special_combo = true

	var attack_times = randi_range(2, 5)

	for i in range(attack_times):
		if is_ice or is_sleep or is_stun:
			break

		mr_player.play("hit2_1")
		await mr_player.animation_finished

	if not (is_ice or is_sleep or is_stun):
		do_hit_2()

	is_special_combo = false


func do_hit_2():
	super.to_hero()
	hit_name = "hit2"
	velocity.x = 0
	velocity.y = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	if is_attacking or is_special_combo:
		return

	super.to_hero()
	skill_3_cd = randi_range(25, 30)
	hit_name = "hit3"
	velocity.x = 0
	velocity.y = 0

	is_attacking = true
	is_special_combo = true

	mr_player.play("hit3")
	await mr_player.animation_finished

	is_attacking = false
	is_special_combo = false
	stop_move()


func do_hit_4():
	if is_attacking or is_special_combo:
		return
	super.to_hero()
	skill_4_cd = randi_range(25, 30)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_5():
	if is_attacking or is_special_combo:
		return
	super.to_hero()
	skill_5_cd = randi_range(40, 45)
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit5")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_1():
	for i in range(3):
		if i > 0:
			await get_tree().create_timer(0.3).timeout
		var bullet_node = Global.add_bullet(
			"Monster1407Bullet1", self.bullet, false, 1.5, position, "hit1", self.obj_attack_dict["hit1"]
		)
		bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_3():
	for i in range(1):
		var bullet_node = Global.add_bullet(
			"Monster1407Bullet3", self.bullet, false, 1.5, position, "hit3", self.obj_attack_dict["hit3"]
		)
		bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_4():
	for i in range(5):
		var is_left = i % 2 == 0
		var x_offset = randi_range(0, 200)
		var spawn_position = Vector2(
			(
				RoleProp.get_nearest_monster_target_position(global_position).x - x_offset
				if is_left
				else position.x + x_offset
			),
			RoleProp.get_nearest_monster_target_position(global_position).y - 100
		)

		var bullet = Global.add_bullet(
			"Monster1407Bullet4", self.bullet, false, 1, spawn_position, "hit4", self.obj_attack_dict["hit4"]
		)
		if i < 9:
			await get_tree().create_timer(0.5, false).timeout


func call_bullet_5():
	if my_child == null:
		my_child = Global.add_bullet(
			"Monster1407Bullet5", self.bullet, false, 1, Vector2(500, -270), "hit5", self.obj_attack_dict["hit5"]
		)
		tick_count = 0


func move_player_2():
	if not get_player:
		return

	var offset = 100

	if alternate_side:
		self.position = Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x + offset,
			RoleProp.get_nearest_monster_target_position(global_position).y
		)
	else:
		self.position = Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x - offset,
			RoleProp.get_nearest_monster_target_position(global_position).y
		)

	alternate_side = not alternate_side

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

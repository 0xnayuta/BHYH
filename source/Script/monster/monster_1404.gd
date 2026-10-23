extends BaseMonster
var my_child: MonsterBullet
var tick_count: int = 0


func monster_1404():
	self.is_fly = true
	self.is_boss = true
	self.my_mr_name = "碧霄"
	self.rush_speed = 500
	self.attack_in = 110
	self.level = 57
	self.max_hp = 1100000
	self.hp = self.max_hp
	self.def = 500
	self.mdef = 500
	self.crit = 25
	self.miss = 45
	self.lucky = 60
	self.htarget = 90
	self.toughness = 20
	self.ar = 90
	self.sp = 90
	self.crit_reduce = 12
	self.speed = 16
	self.mysee = 1000
	self.attack_range = 600
	self.attack_desire = 90
	self.behit_calmtime = 0.12
	self.self_rhp = 0
	self.add_exp = 4000
	self.fall_coin = 1600
	self.ebol = 0

	self.obj_attack_dict["hit1"] = {
		"power": 700,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 700,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "silent",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0.3,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit3"] = {
		"power": 800,
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
	self.fall_pro = 0.4
	self.fall_list = [
		{"name": "zhhzzzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]

	if Global.current_level == "仙音岛":
		independent_fall_list = YutuEquipmentData.stage_book_drops("仙音岛")


func _ready() -> void:
	super._ready()
	monster_1404()

	skill_1_cd = randi_range(2, 4)
	skill_2_cd = randi_range(4, 8)
	skill_3_cd = randi_range(8, 16)


func ai_think():
	if my_child != null:
		tick_count += 1
		if tick_count >= 900:
			my_child.queue_free()
	else:
		tick_count = 0

	var distance_x = abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	var distance_y = abs(RoleProp.get_nearest_monster_target_position(global_position).y - position.y)

	if distance_x < mysee and distance_y < 100:
		has_target = true
	else:
		has_target = false

	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			var distance_to_player = abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x)
			var is_in_attack_range = distance_to_player <= attack_range

			var can_use_hit3 = skill_3_cd <= 0
			var can_use_hit1 = skill_1_cd <= 0
			var can_use_hit2 = skill_2_cd <= 0

			var can_attack = true
			if is_attacking:
				can_attack = false

			if can_attack:
				if is_in_attack_range:
					stop_move()

					if can_use_hit3 and distance_to_player <= 100:
						do_hit_3()
					elif can_use_hit2:
						do_hit_2()
					elif can_use_hit1:
						do_hit_1()
				else:
					have_target()

					if can_use_hit1 and distance_to_player > 300:
						do_hit_1()
					elif can_use_hit2 and distance_to_player > 400:
						do_hit_2()

					elif can_use_hit3 and distance_to_player <= 500 and distance_to_player > 100:
						do_hit_3()

			if is_in_attack_range and can_attack:
				if tick_count % 60 == 0 and randi_range(0, 100) < attack_desire:
					attack_target()
			elif can_attack:
				if tick_count % 90 == 0 and randi_range(0, 100) < attack_desire * 0.5:
					attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(1, 3)
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(15, 20)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(20, 25)
	hit_name = "hit3"
	velocity.x = 0
	velocity.y = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_1():
	var bullet_count = 3
	var spread_angle = 30

	var direction_multiplier = -1 if self.monster_direction else 1

	for i in range(bullet_count):
		if i > 0:
			await get_tree().create_timer(0.2).timeout

		var angle_offset = (i - 1) * (spread_angle / 2.0)

		var final_rotation = deg_to_rad(angle_offset)

		var bullet_node = Global.add_bullet(
			"Monster1404Bullet1",
			self.bullet,
			false,
			1.5,
			position + Vector2(35 * direction_multiplier, 25),
			"hit1",
			self.obj_attack_dict["hit1"]
		)

		bullet_node.skill_name = "Monster1404Bullet1"

		if direction_multiplier > 0:
			bullet_node.dir = true
			bullet_node.rotation = final_rotation
		else:
			bullet_node.dir = false
			bullet_node.rotation = final_rotation

		bullet_node.set_meta("is_fan_bullet", true)
		bullet_node.set_meta("fan_direction", direction_multiplier)
		bullet_node.set_meta("fan_angle", angle_offset)
		bullet_node.set_meta("move_speed", 200.0)


func call_bullet_2():
	var position_list1 = [Vector2(position.x + 150, 0), Vector2(position.x + 0, 100), Vector2(position.x - 150, 0)]
	var position_list2 = [Vector2(position.x + 300, 100), Vector2(position.x - 300, 100)]
	var position_list3 = [Vector2(position.x + 450, 200), Vector2(position.x - 450, 200)]
	var position_list4 = [Vector2(position.x + 600, 0), Vector2(position.x - 600, 0)]

	for i in position_list1:
		Global.call_chase_bullet(
			self.bullet, "Monster1404Bullet2_1", 250, 6, false, i, "hit2", self.obj_attack_dict["hit2"]
		)
	await get_tree().create_timer(0.2, false).timeout

	for i in position_list2:
		Global.call_chase_bullet(
			self.bullet, "Monster1404Bullet2", 250, 6, false, i, "hit2", self.obj_attack_dict["hit2"]
		)
	await get_tree().create_timer(0.2, false).timeout


func move_player():
	self.position = Vector2(
		RoleProp.get_nearest_monster_target_position(global_position).x,
		RoleProp.get_nearest_monster_target_position(global_position).y
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

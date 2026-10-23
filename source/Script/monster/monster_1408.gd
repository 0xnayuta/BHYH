extends BaseMonster

var alternate_side: bool = false
var is_reviving: bool = false


func monster_1408():
	self.rush_speed = 900
	self.is_boss = true
	self.my_mr_name = "千年妖蚊"
	self.attack_in = 130
	self.level = 59
	self.max_hp = 1950000
	self.hp = self.max_hp
	self.def = 680
	self.mdef = 680
	self.crit = 38
	self.miss = 58
	self.lucky = 83
	self.htarget = 98
	self.toughness = 43
	self.ar = 120
	self.sp = 120
	self.crit_reduce = 20
	self.speed = 18
	self.mysee = 550
	self.attack_range = 280
	self.attack_desire = 100
	self.behit_calmtime = 0.05
	self.self_rhp = 0
	self.add_exp = 6000
	self.fall_coin = 2500
	self.ebol = 1.0

	self.obj_attack_dict["hit1"] = {
		"power": 1000,
		"hurtBack": [-5, -12],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 900,
		"hurtBack": [10, -10],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0.61,
			"value": 0.5,
			"AttackKind": "magic",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 1500,
		"hurtBack": [-30, -12],
		"attackKind": "physics",
		"HitProtect": 10,
	}

	self.obj_attack_dict["hit5"] = {
		"power": 1800,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Immobilize",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 1,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "ttsl1", "value": 1},
		{"name": "shenhuo_1", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_1408()
	skill_1_cd = 2
	skill_2_cd = 15
	skill_3_cd = 10
	skill_4_cd = 20
	skill_5_cd = 30


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
				if skill_5_cd <= 0:
					do_hit_5()
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
				if skill_5_cd <= 0:
					do_hit_5()


func do_hit_1():
	if skill_1_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_1_cd = 2
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	if skill_2_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_2_cd = randi_range(20, 30)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	if skill_3_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_3_cd = randi_range(15, 20)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	if skill_4_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_4_cd = randi_range(35, 40)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	call_parasitic_larva()
	stop_move()


func do_hit_5():
	if skill_5_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_5_cd = randi_range(25, 30)
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	self.ebol = 50.0
	mr_player.play("hit5")
	await mr_player.animation_finished
	self.ebol = 1.0
	is_attacking = false
	stop_move()


func call_parasitic_larva():
	var target = get_player

	var player_max_hp = 0
	if RoleProp and RoleProp.roleprop:
		player_max_hp = RoleProp.roleprop.SHp
	var hp_value = max(1, int(player_max_hp * 0.7))

	var monster_container = get_parent().get_parent().monster
	for child in monster_container.get_children():
		if child is Monster140801:
			child.queue_free()
			await get_tree().process_frame
			break

	var larva = Global.create_monster(140801, monster_container, position + Vector2(0, -50)) as Monster140801

	if larva:
		larva.name = "ParasiticLarva"
		larva.max_hp = hp_value
		larva.hp = larva.max_hp
		larva.my_target = target

		var life_timer = Timer.new()
		life_timer.wait_time = 30.0
		life_timer.one_shot = true

		larva.add_child(life_timer)

		life_timer.start()

		life_timer.timeout.connect(
			func():
				if is_instance_valid(larva):
					larva.queue_free()
		)


func call_bullet_2():
	var po = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 380)
	await get_tree().create_timer(0.3, false).timeout
	var ly = Global.call_chase_bullet(
		self.bullet, "Monster1408Bullet2", 150, 5.0, false, po, "hit2", self.obj_attack_dict["hit2"]
	)
	ly.scale = Vector2(1.5, 1.5)


func move_player_2():
	if not get_player:
		return

	var offset = 150

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


func has_parasitic_larva() -> bool:
	var monster_container = get_parent().get_parent().monster
	for child in monster_container.get_children():
		if child is Monster140801 and is_instance_valid(child):
			return true
	return false


func state_death():
	if is_reviving:
		return

	if has_parasitic_larva():
		is_reviving = true

		if has_node("death_count"):
			$death_count.stop()

		is_attacking = false
		is_be_attacking = false
		velocity.x = 0

		if mr_player.has_animation("death"):
			mr_player.play("death")

		await get_tree().create_timer(3.0).timeout
		Global.add_special_effect(get_parent(), global_position, "relife", Vector2(2, 2), false, 1)

		self.hp = self.max_hp
		self.is_death = false
		is_reviving = false

		if mr_player.has_animation("wait"):
			mr_player.play("wait")

		if has_node("death_count"):
			$death_count.start()
	else:
		super.state_death()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

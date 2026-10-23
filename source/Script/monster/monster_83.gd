extends BaseMonster


func monster_83():
	self.is_boss = true
	self.my_mr_name = "增长天王"
	self.attack_in = 10
	self.level = 35
	self.max_hp = 85000
	self.hp = self.max_hp
	self.def = 170
	self.mdef = 170
	self.crit = 20
	self.miss = 22
	self.lucky = 0
	self.htarget = 18
	self.toughness = 0
	self.ar = 10
	self.sp = 10
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 600
	self.attack_range = 175
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 225,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Ice",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
			"probability": 0.7
		},
	}
	self.obj_attack_dict["hit2"] = {
		"power": 150,
		"hurtBack": [-4, -9],
		"attackKind": "real",
		"HitProtect": 12,
	}
	self.obj_attack_dict["hit3"] = {
		"power": 325,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Ice",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
			"probability": 0.7
		},
	}
	self.obj_attack_dict["hit4"] = {
		"power": 325,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"HitProtect": 9,
		"addeffect":
		{
			"Name": "Ice",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
			"probability": 0.7
		},
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "qyfp", "value": 0},
		{"name": "qybd", "value": 0},
		{"name": "qysq", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "zztwbx"

	update_fall_mode()
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	skill_1_cd = 5
	skill_2_cd = 0
	skill_3_cd = 0
	super._ready()
	monster_83()


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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300:
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 550:
					if skill_3_cd <= 0:
						do_hit_3()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(12, 14)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(16, 18)
	velocity.x = 0
	hit_name = "hit4"
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(14, 16)
	velocity.x = 0
	hit_name = "hit4"
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func tween_to_top():
	if _movement_command_is_blocked():
		return
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Vector2(0, -150) + position, 1.5)
	pass


func call_arrow_1():
	if get_player == null:
		return
	var bullet_spawn_positions = [
		Vector2(0, -150),
		Vector2(-70, -150),
		Vector2(70, -150),
		Vector2(140, -150),
		Vector2(-140, -150),
		Vector2(210, -150),
		Vector2(-210, -150)
	]
	randomize()
	bullet_spawn_positions.shuffle()
	for i in bullet_spawn_positions:
		var desired_angle
		var arrow = Global.add_bullet(
			"Monster83Bullet", self.bullet, false, 2, i + position, "hit4", self.obj_attack_dict["hit4"]
		)
		arrow.scale = Vector2(0.7, 0.7)
		arrow.modulate = Color(1, 1, 1, 0)
		arrow.look_at(RoleProp.get_nearest_monster_target_position(global_position))
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(arrow, "modulate", Color(1, 1, 1, 1), 1)
		await get_tree().create_timer(0.3, false).timeout


func call_arrow_2():
	if get_player == null:
		return
	var desired_angle = 90
	var bullet_spawn_positions = []
	if monster_direction:
		bullet_spawn_positions = [
			Vector2(0, -100), Vector2(-100, -50), Vector2(100, 0), Vector2(200, 50), Vector2(-200, 100)
		]
	else:
		bullet_spawn_positions = [
			Vector2(0, -100), Vector2(-100, -50), Vector2(100, 0), Vector2(200, 50), Vector2(-200, 100)
		]
	randomize()
	bullet_spawn_positions.shuffle()
	for i in bullet_spawn_positions:
		var arrow = Global.add_bullet(
			"Monster83Bullet", self.bullet, monster_direction, 1, i + position, "hit2", self.obj_attack_dict["hit2"]
		)
		arrow.scale = Vector2(0.9, 0.9)
		arrow.modulate = Color(1, 1, 1, 0)
		var po = arrow.position - position
		var tween = get_tree().create_tween().set_parallel(true)
		if monster_direction:
			desired_angle = -desired_angle
		tween.tween_property(arrow, "rotation", desired_angle, 1)
		tween.tween_property(arrow, "modulate", Color(1, 1, 1, 1), 1)
		await get_tree().create_timer(randf_range(0.2, 0.4), false).timeout


func call_arrow_3():
	if get_player == null:
		return
	var bullet_spawn_positions = [
		Vector2(0, -700),
		Vector2(-30, -800),
		Vector2(30, -900),
		Vector2(60, -700),
		Vector2(-60, -700),
		Vector2(90, -900),
		Vector2(-90, -800),
		Vector2(-120, -800),
		Vector2(120, -700),
		Vector2(150, -800),
		Vector2(-150, -800),
		Vector2(0, -700),
		Vector2(-180, -800),
		Vector2(180, -900),
		Vector2(210, -700),
		Vector2(-210, -700),
		Vector2(240, -900),
		Vector2(-240, -800),
		Vector2(-270, -800),
		Vector2(270, -700),
		Vector2(300, -800),
		Vector2(-300, -800)
	]
	randomize()
	bullet_spawn_positions.shuffle()
	for i in bullet_spawn_positions:
		var arrow = Global.add_bullet(
			"Monster83Bullet", self.bullet, false, 3.5, i + position, "hit3", self.obj_attack_dict["hit3"]
		)
		arrow.scale = Vector2(1, 1)
		arrow.rotation_degrees = 90
		await get_tree().create_timer(0.1, false).timeout

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

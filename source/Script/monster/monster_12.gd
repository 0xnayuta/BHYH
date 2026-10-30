extends BaseMonster
var is_eggs = false
var is_play = false
var relive_effect
var is_set = false
var is_rush = false
var po: Vector2
var cure_count: int = 0
var _skill_4_generation: int = 0
var _velocity: Vector2:
	set(val):
		_velocity = val
		rotation = _velocity.angle()


func monster_12():
	self.is_fly = false
	self.is_boss = true
	self.my_mr_name = "鹏魔王"
	self.attack_in = 120
	self.level = 20
	self.max_hp = 4500
	self.hp = self.max_hp
	self.def = 80
	self.mdef = 80
	self.crit = 10
	self.miss = 5
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 300
	self.attack_range = 85
	self.attack_desire = 60
	self.behit_calmtime = 0.4
	self.self_rhp = 0
	self.add_exp = 100
	self.fall_coin = 30
	self.obj_attack_dict["hit1"] = {"power": 70, "hurtBack": [-4, -9], "attackKind": "real"}
	self.obj_attack_dict["bshn"] = {
		"power": 110,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 4,
			"reduce_interval": 1,
			"CanAdd": true,
			"DeBuff": true,
			"value": int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "magic",
		}
	}
	self.obj_attack_dict["hydd"] = {
		"power": 35,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 4,
			"CanAdd": true,
			"DeBuff": true,
			"reduce_interval": 1,
			"value": int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "magic",
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "jcjs", "value": 0},
		{"name": "jcsz", "value": 0},
		{"name": "jclj", "value": 0},
	]
	self.independent_fall_list = [
		{"name": "210007002", "value": 0, "chance": 0.25},
	]

	enable_treasure_box = true
	treasure_box_item = "pmwbx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_12()
	skill_1_cd = 0
	skill_2_cd = 0


func interrupt_movement_for_control() -> void:
	super.interrupt_movement_for_control()
	_skill_4_generation += 1
	is_rush = false
	_velocity = Vector2.ZERO


func ai_think():
	if is_fly:
		self.attack_range = 300
	else:
		self.attack_range = 85

	if is_on_floor():
		mr_ani.rotation = 0
	if is_eggs:
		return
	# 历史全局 is_fire 标志从未被置真，self_rhp 恒为 0；标志已随运行状态收敛删除。
	self.self_rhp = 0
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				match is_fly:
					true:
						if skill_2_cd <= 0:
							use_skill_4()
							is_rush = true
						elif count % 60 == 0:
							do_hit_3()
						else:
							have_target()
					false:
						if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 800:
							if skill_1_cd <= 0:
								do_hit_2()
			else:
				match is_fly:
					true:
						if skill_2_cd <= 0:
							use_skill_4()
							is_rush = true
						elif count % 60 == 0:
							do_hit_3()
						else:
							have_target()
					false:
						if skill_1_cd <= 0:
							do_hit_2()
						elif count % 60 == 0:
							attack_target()
						else:
							stop_move()


func do_hit_2():
	skill_1_cd = 2
	hit_name = "hydd"
	velocity.x = 0
	is_attacking = true
	mr_player.play("FloorSkill")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	velocity.x = 0
	hit_name = "hydd"
	is_attacking = true
	mr_player.play("FlySkill")
	await mr_player.animation_finished
	is_attacking = false


func use_skill_4():
	skill_2_cd = 15
	_skill_4_generation += 1
	var skill_generation := _skill_4_generation
	var sspo = [
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x + 100, -200),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x - 100, -200),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x + 100, -200),
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x - 100, -200)
	]
	for i in range(4):
		if skill_generation != _skill_4_generation or _movement_command_is_blocked():
			is_rush = false
			return
		po = Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x,
			RoleProp.get_nearest_monster_target_position(global_position).y
		)
		var ppx = sspo[i].x
		var ppy = sspo[i].y
		if ppx <= 0:
			ppx = 10
		if ppx >= 4500:
			ppx = 4400
		self.position = Vector2(ppx, ppy)
		await get_tree().create_timer(1).timeout
		if skill_generation != _skill_4_generation or _movement_command_is_blocked():
			is_rush = false
			return
	is_rush = false


func do_hit_4():
	skill_2_cd = 18
	hit_name = "bshn"
	is_attacking = true
	mr_player.play("FlyBirds")
	await mr_player.animation_finished
	velocity.y = 0
	is_attacking = false


func call_fire():
	if self.monster_direction == false:
		var posi = Vector2(self.position.x - 180, self.position.y)
		var aa = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		var bb = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		var cc = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		aa.set_rotation_degrees(-30)
		bb.set_rotation_degrees(0)
		cc.set_rotation_degrees(30)
	else:
		var posi = Vector2(self.position.x + 180, self.position.y)
		var aa = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		var bb = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		var cc = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		aa.set_rotation_degrees(30)
		bb.set_rotation_degrees(0)
		cc.set_rotation_degrees(-30)


func call_fire_fly():
	if self.monster_direction == false:
		var posi = Vector2(self.position.x - 210, self.position.y + 150)
		var aa = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		var bb = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		var cc = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		aa.set_rotation_degrees(-30)
		bb.set_rotation_degrees(0)
		cc.set_rotation_degrees(30)
	else:
		var posi = Vector2(self.position.x + 210, self.position.y + 150)
		var aa = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		var bb = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		var cc = Global.add_bullet(
			"Monster12Bullet", self.bullet, self.monster_direction, 1, posi, "hydd", self.obj_attack_dict["hydd"]
		)
		aa.set_rotation_degrees(30)
		bb.set_rotation_degrees(0)
		cc.set_rotation_degrees(-30)


func protect_fire():
	var po = Vector2(
		RoleProp.get_nearest_monster_target_position(global_position).x + 90,
		RoleProp.get_nearest_monster_target_position(global_position).y + 120
	)
	var aa = Global.add_bullet(
		"Monster12Bullet", self.bullet, self.monster_direction, 1, po, "hydd", self.obj_attack_dict["hydd"]
	)
	var bb = Global.add_bullet(
		"Monster12Bullet", self.bullet, self.monster_direction, 1, po, "hydd", self.obj_attack_dict["hydd"]
	)
	var cc = Global.add_bullet(
		"Monster12Bullet", self.bullet, self.monster_direction, 1, po, "hydd", self.obj_attack_dict["hydd"]
	)
	aa.set_rotation_degrees(30)
	bb.set_rotation_degrees(0)
	cc.set_rotation_degrees(-30)


func state_hurt():
	if not is_eggs:
		super.state_hurt()


func _physics_process(delta: float) -> void:
	if super.check_player_have_debuff("Fire"):
		if cure_count % 60 == 0:
			cure_hp(150)
		cure_count += 1
	if not is_set:
		if not is_fly:
			$Change_zt.wait_time = randi_range(8, 10)
			$Change_zt.start()
		else:
			$Change_zt.wait_time = randi_range(15, 17)
			$Change_zt.start()
		is_set = true
	super._physics_process(delta)
	if hp <= max_hp * 0.2:
		is_eggs = true
	check_eggs()
	if is_movement_locked_by_control():
		is_rush = false
		_velocity = Vector2.ZERO
	elif is_rush:
		bshn(po, delta)


func bshn(pp: Vector2, delta):
	if _movement_command_is_blocked():
		is_rush = false
		_velocity = Vector2.ZERO
		return
	var desired_angle = position.direction_to(pp).angle()
	var cur_angle = lerp_angle(rotation, desired_angle, 0.02)
	_velocity = Vector2.RIGHT.rotated(cur_angle) * 1200
	position += _velocity * delta
	do_hit_4()


func check_eggs():
	if not is_eggs:
		self.def = 80
		self.mdef = 80
		ai_think()
	else:
		is_fly = false
		velocity.x = 0
		self.def = 200
		self.mdef = 200
		if is_play == false:
			mr_player.play("Eggs")
			is_play = true
			await mr_player.animation_finished
			$Relive.wait_time = 7
			$Relive.start()


func play_relive_effect():
	if mr_ani.flip_h == false:
		relive_effect = Global.add_special_effect(self, Vector2(20, 0), "relife", Vector2(1, 1), false, 1)
	else:
		relive_effect = Global.add_special_effect(self, Vector2(-20, 0), "relife", Vector2(1, 1), false, 1)


func _on_relive_timeout() -> void:
	if hp <= 0:
		return
	self.max_hp = self.max_hp * 1.5
	self.hp = self.max_hp
	def += 10
	mdef += 10
	$Relive.stop()
	play_relive_effect()
	if relive_effect != null and is_instance_valid(relive_effect) and relive_effect.has_signal("tree_exited"):
		await relive_effect.tree_exited
	is_eggs = false
	is_play = false


func _on_create_timeout() -> void:
	if is_eggs:
		protect_fire()


func _on_change_zt_timeout() -> void:
	if is_fly:
		is_fly = false
	else:
		is_fly = true
	is_set = false


func _on_hn_timeout() -> void:
	pass


func have_target():
	if is_quiescent:
		return
	if is_fly:
		if RoleProp.get_nearest_monster_target_position(global_position).y > position.y + 500:
			move_down()
		elif RoleProp.get_nearest_monster_target_position(global_position).y < position.y + 240:
			move_up()
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x + randi_range(25, 85):
		move_right()
	elif RoleProp.get_nearest_monster_target_position(global_position).x < position.x - randi_range(25, 85):
		move_left()

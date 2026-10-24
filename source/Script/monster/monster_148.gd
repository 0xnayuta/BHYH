extends BaseMonster

var bullet1_portals: Array = []
var bullet2_active: bool = false
var bullet2_spawn_positions: Array = []
var bullet2_timer: Timer = null
var bullet2_wave_count: int = 0

var bullet3_portals: Array = []


func monster_101():
	self.is_boss = true
	self.my_mr_name = "白水神君"
	self.attack_in = 113
	self.level = 72
	self.max_hp = 7200000
	self.hp = self.max_hp
	self.def = 1858
	self.mdef = 1800
	self.crit = 55
	self.miss = 60
	self.lucky = 122
	self.htarget = 120000
	self.toughness = 43
	self.ar = 410
	self.sp = 401
	self.crit_reduce = 36
	self.speed = 28
	self.mysee = 900
	self.attack_range = 318
	self.attack_desire = 271
	self.behit_calmtime = 0
	self.self_rhp = self.max_hp * 0.00018
	self.add_exp = 0
	self.fall_coin = 0
	self.ebol = 0

	self.obj_attack_dict["hit1"] = {
		"power": 3888,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 3888,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 10,
			"reduce_interval": 0,
			"value": 0.3,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
			"CanAdd": false,
		}
	}

	self.obj_attack_dict["hit3"] = {
		"power": 7200,
		"hurtBack": [-50, 0],
		"attackKind": "magic",
		"HitProtect": 12,
	}

	self.fall_pro = 0.1
	self.fall_list = [
		{"name": "cjshenjzzs", "value": 1},
		{"name": "cdshenjzzs", "value": 1},
		{"name": "zhshenjzzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_101()

	skill_2_cd = randi_range(5, 10)
	skill_3_cd = randi_range(15, 20)


func ai_think():
	if is_attacking or is_using_skills or is_be_attacking:
		return

	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true

	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_2_cd <= 0:
					do_hit_2()
				elif skill_3_cd <= 0:
					do_hit_3()

				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
						_create_bullet1_portal()
			else:
				if skill_2_cd <= 0:
					do_hit_2()
				elif skill_3_cd <= 0:
					do_hit_3()
				elif count % 60 == 0:
					if randi_range(0, 100) <= attack_desire:
						attack_target()
						_create_bullet1_portal()
				else:
					stop_move()


func _create_bullet1_portal():
	var portal = {"position": position, "direction": -1 if self.monster_direction else 1, "count": 0, "timer": null}

	portal.timer = Timer.new()
	add_child(portal.timer)
	portal.timer.one_shot = false
	portal.timer.timeout.connect(_on_portal1_timeout.bind(portal))
	portal.timer.start(0.5)

	bullet1_portals.append(portal)


func _on_portal1_timeout(portal):
	if portal.count >= 3:
		_remove_portal1(portal)
		return

	var bullet_node = Global.add_bullet(
		"monster_148_bullet_1",
		self.bullet,
		false,
		1,
		portal.position + Vector2(35 * portal.direction, 25),
		"hit1",
		self.obj_attack_dict["hit1"]
	)
	bullet_node.rotation = 0.0 if portal.direction < 0 else PI
	portal.count += 1


func _remove_portal1(portal):
	if portal.timer:
		portal.timer.stop()
		portal.timer.queue_free()
	bullet1_portals.erase(portal)


func do_hit_2():
	if is_attacking:
		return

	skill_2_cd = 15
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	is_using_skills = true

	mr_player.stop()
	mr_player.play("hit2")

	await mr_player.animation_finished

	_activate_bullet2()

	is_attacking = false
	is_using_skills = false


func _activate_bullet2():
	if bullet2_active:
		_stop_bullet2()

	bullet2_active = true
	bullet2_wave_count = 0

	bullet2_spawn_positions = [
		Vector2(-500 + position.x, 500),
		Vector2(-400 + position.x, 500),
		Vector2(-300 + position.x, 500),
		Vector2(-200 + position.x, 500),
		Vector2(-100 + position.x, 500),
		Vector2(100 + position.x, 500),
		Vector2(200 + position.x, 500),
		Vector2(300 + position.x, 500),
		Vector2(400 + position.x, 500),
		Vector2(500 + position.x, 500)
	]

	_spawn_bullet2_wave()

	bullet2_timer = Timer.new()
	add_child(bullet2_timer)
	bullet2_timer.one_shot = false
	bullet2_timer.timeout.connect(_on_bullet2_timer_timeout)
	bullet2_timer.start(1.5)


func _spawn_bullet2_wave():
	if not bullet2_active:
		return

	bullet2_wave_count += 1

	if bullet2_wave_count > 3:
		_stop_bullet2()
		return

	for pos in bullet2_spawn_positions:
		var bullet = Global.add_bullet(
			"monster_148_bullet_2", self.bullet, false, 1, pos, "hit2", self.obj_attack_dict["hit2"]
		)


func _on_bullet2_timer_timeout():
	_spawn_bullet2_wave()


func _stop_bullet2():
	if not bullet2_active:
		return

	bullet2_active = false
	bullet2_spawn_positions.clear()
	bullet2_wave_count = 0

	if bullet2_timer:
		if bullet2_timer.is_inside_tree():
			bullet2_timer.stop()
			bullet2_timer.queue_free()
		bullet2_timer = null


func do_hit_3():
	if is_attacking:
		return

	skill_3_cd = 20
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	is_using_skills = true

	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1

	mr_player.stop()
	mr_player.play("hit3")

	await mr_player.animation_finished

	var player_direction = -1 if RoleProp.get_nearest_monster_target_position(global_position).x > position.x else 1
	_create_bullet3_portal(player_direction)

	is_attacking = false
	is_using_skills = false


func _create_bullet3_portal(direction: int = 0):
	var portal_direction = direction if direction != 0 else (-1 if self.monster_direction else 1)

	var portal = {"position": position, "direction": portal_direction, "count": 0, "timer": null}

	portal.timer = Timer.new()
	add_child(portal.timer)
	portal.timer.one_shot = false
	portal.timer.timeout.connect(_on_portal3_timeout.bind(portal))
	portal.timer.start(1)

	bullet3_portals.append(portal)


func _on_portal3_timeout(portal):
	if portal.count >= 5:
		_remove_portal3(portal)
		return

	var spawn_pos = Vector2(portal.position.x + 35 * portal.direction, portal.position.y + 25)

	var bullet_node = Global.add_bullet(
		"monster_148_bullet_3", self.bullet, false, 1, spawn_pos, "hit3", self.obj_attack_dict["hit3"]
	)

	if bullet_node.has_method("set_scale"):
		if portal.direction < 0:
			bullet_node.scale.x = 1
			bullet_node.rotation = 0
		else:
			bullet_node.scale.x = -1
			bullet_node.rotation = 0

	portal.count += 1


func _remove_portal3(portal):
	if portal.timer:
		portal.timer.stop()
		portal.timer.queue_free()
	bullet3_portals.erase(portal)


func state_death():
	for portal in bullet1_portals:
		if portal.timer:
			portal.timer.stop()
			portal.timer.queue_free()
	bullet1_portals.clear()

	for portal in bullet3_portals:
		if portal.timer:
			portal.timer.stop()
			portal.timer.queue_free()
	bullet3_portals.clear()

	_stop_bullet2()

	super.state_death()

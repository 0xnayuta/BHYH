extends BaseMonster

var my_child: MonsterBullet
var tick_count: int = 0
var is_checking_silent: bool = false
var silent_check_timer: Timer
var has_summoned_1404: bool = false
var has_applied_shield: bool = false
var shield_value: int = 0


func monster_1406():
	self.is_fly = true
	self.is_boss = true
	self.my_mr_name = "琼霄"
	self.rush_speed = 550
	self.attack_in = 120
	self.level = 58
	self.max_hp = 1500000
	self.hp = self.max_hp
	self.def = 580
	self.mdef = 580
	self.crit = 30
	self.miss = 50
	self.lucky = 70
	self.htarget = 95
	self.toughness = 30
	self.ar = 110
	self.sp = 110
	self.crit_reduce = 18
	self.speed = 18
	self.mysee = 600
	self.attack_range = 500
	self.attack_desire = 95
	self.behit_calmtime = 0.08
	self.self_rhp = 0
	self.add_exp = 5000
	self.fall_coin = 2000
	self.ebol = 0

	self.has_summoned_1404 = false

	self.obj_attack_dict["hit1"] = {
		"power": 800,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 800,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 5,
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
	self.obj_attack_dict["hit3"] = {
		"power": 1200,
		"hurtBack": [-6, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "silent",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.3,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}

	self.obj_attack_dict["hit4"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 10,
	}

	self.fall_pro = 0.4
	self.fall_list = [
		{"name": "phhlzzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]

	if Global.current_level == "仙幻岛":
		independent_fall_list = YutuEquipmentData.stage_book_drops("仙幻岛")


func _ready() -> void:
	super._ready()
	monster_1406()

	skill_1_cd = 2
	skill_2_cd = 5
	skill_3_cd = 4

	silent_check_timer = Timer.new()
	silent_check_timer.one_shot = true
	silent_check_timer.timeout.connect(_on_silent_check_timeout)
	add_child(silent_check_timer)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if hp <= max_hp * 0.5 and not has_summoned_1404:
		add_help()


func ai_think():
	if my_child != null:
		tick_count += 1
		if tick_count >= 900:
			my_child.queue_free()
	else:
		tick_count = 0

	var distance_x = abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	var distance_y = abs(RoleProp.get_nearest_monster_target_position(global_position).y - position.y)

	has_target = distance_x < mysee and distance_y < 100

	if is_ice or is_sleep or is_stun or cannotchangestatewhenattorbeatt():
		return

	if not has_target:
		normal_state()
		return

	var distance_to_player = abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x)
	var is_in_attack_range = distance_to_player <= attack_range

	var can_use_hit3 = skill_3_cd <= 0
	var can_use_hit2 = skill_2_cd <= 0
	var can_use_hit1 = skill_1_cd <= 0

	if is_attacking:
		return

	if is_in_attack_range:
		stop_move()

		if distance_to_player <= 100:
			if can_use_hit2:
				do_hit_2()
			elif can_use_hit3:
				do_hit_3()
			elif can_use_hit1:
				do_hit_1()
		elif distance_to_player <= 400:
			if can_use_hit2:
				do_hit_2()
			elif can_use_hit1:
				do_hit_1()
			elif can_use_hit3 and distance_to_player <= 150:
				do_hit_3()
		else:
			if can_use_hit1:
				do_hit_1()
	else:
		have_target()

		if can_use_hit1 and distance_to_player > 300:
			do_hit_1()
		elif can_use_hit3 and distance_to_player <= 400:
			do_hit_3()
		elif can_use_hit2 and distance_to_player <= 1500:
			do_hit_2()


func do_hit_1():
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
	skill_3_cd = randi_range(25, 30)
	hit_name = "hit3"
	velocity.x = 0
	velocity.y = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished

	is_attacking = false
	stop_move()

	is_checking_silent = true
	_start_silent_check_coroutine()


func do_hit_4():
	super.to_hero()
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func _start_silent_check_coroutine():
	var check_count = 0
	var max_checks = 12

	while check_count < max_checks and is_checking_silent:
		await get_tree().create_timer(0.5).timeout

		if not is_checking_silent:
			break

		if check_player_has_silent():
			apply_control_reverse(3)
			is_checking_silent = false
			return

		check_count += 1

	is_checking_silent = false


func call_bullet_1():
	for i in range(3):
		if i > 0:
			await get_tree().create_timer(0.3).timeout

		var bullet_node = Global.add_bullet(
			"Monster1406Bullet1", self.bullet, false, 1.5, position, "hit1", self.obj_attack_dict["hit1"]
		)

		bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_2():
	for i in range(10):
		var is_left = i % 2 == 0
		var x_offset = randi_range(50, 400)
		var spawn_position = Vector2(position.x - x_offset if is_left else position.x + x_offset, position.y)

		var bullet = Global.add_bullet(
			"Monster1406Bullet2", self.bullet, false, 1, spawn_position, "hit2", self.obj_attack_dict["hit2"]
		)
		if i < 9:
			await get_tree().create_timer(0.2, false).timeout


func call_bullet_3():
	var position_list1 = [Vector2(position.x, position.y)]

	for i in position_list1:
		Global.call_chase_bullet(
			self.bullet, "Monster1406Bullet3", 300, 5, false, i, "hit3", self.obj_attack_dict["hit3"]
		)
	await get_tree().create_timer(0.2, false).timeout


func check_player_has_silent() -> bool:
	var player = RoleProp.source_player
	if player == null or player.buff == null:
		return false

	for buff in player.buff.get_children():
		if buff != null and buff is BaseBuff and buff.buff_info["Name"] == "silent":
			return true

	return false


func apply_control_reverse(reverse_time: float):
	var player = RoleProp.source_player
	if player == null or player.buff == null:
		return

	var reverse_effect = {
		"Name": "ReverseMove",
		"AddTime": reverse_time,
		"reduce_interval": 0.5,
		"value": 0,
		"AttackKind": "",
		"CanRemove": true,
		"DeBuff": true,
		"CanAdd": false
	}

	Global.add_buff(player.buff, reverse_effect)


func add_help():
	Global.add_bullet("Monster1406Bullet4", self, false, 1, Vector2(15, -30), "hit4", self.obj_attack_dict["hit4"])

	if hp <= max_hp * 0.5 and not has_summoned_1404:
		_summon_monster_1404()

	if hp <= max_hp * 0.5 and not has_applied_shield:
		_apply_shield(max_hp * 0.5)


func _apply_shield(value: int):
	if not has_applied_shield:
		shield_value = int(value)
		get_hd(shield_value, 0, 0)
		has_applied_shield = true


func _summon_monster_1404():
	if not has_summoned_1404:
		var summoned_monster = Global.create_monster(1404, get_parent(), position)
		if summoned_monster != null:
			summoned_monster.direction = self.direction
		has_summoned_1404 = true


func _on_silent_check_timeout():
	is_checking_silent = false


func _exit_tree() -> void:
	super._exit_tree()
	is_checking_silent = false
	if silent_check_timer != null and is_instance_valid(silent_check_timer):
		silent_check_timer.stop()


func move_player():
	self.position = Vector2(
		RoleProp.get_nearest_monster_target_position(global_position).x,
		RoleProp.get_nearest_monster_target_position(global_position).y
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

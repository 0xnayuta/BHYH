extends BaseMonster

var should_fly: bool
var is_call: bool
var onset_eatblood: bool
var remove_blood: bool

var alternate_side: bool = false
var hit3_stage: int = 0


func monster_1403():
	self.rush_speed = 480
	self.is_boss = true
	self.my_mr_name = "狴犴圣者·王魔"
	self.attack_in = 105
	self.level = 56
	self.max_hp = 900000
	self.hp = self.max_hp
	self.def = 470
	self.mdef = 470
	self.crit = 22
	self.miss = 42
	self.lucky = 55
	self.htarget = 85
	self.toughness = 15
	self.ar = 80
	self.sp = 80
	self.crit_reduce = 10
	self.speed = 15
	self.mysee = 550
	self.attack_range = 400
	self.attack_desire = 85
	self.behit_calmtime = 0.14
	self.self_rhp = 0
	self.add_exp = 3500
	self.fall_coin = 1400
	self.ebol = 0

	self.obj_attack_dict["hit1"] = {
		"power": 650,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 9999999,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 15,
	}

	self.obj_attack_dict["hit3"] = {
		"power": 600,
		"hurtBack": [-6, -10],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "silent",
			"AddTime": 3,
			"reduce_interval": 0.99,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}

	self.obj_attack_dict["hit3_2"] = {
		"power": 650,
		"hurtBack": [-7, -11],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 5,
			"reduce_interval": 0.36,
			"value": 50,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		}
	}

	self.obj_attack_dict["hit3_1"] = {
		"power": 600,
		"hurtBack": [-70, -12],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 2,
			"reduce_interval": 0.61,
			"value": 0.99,
			"AttackKind": "magic",
			"CanAdd": true,
			"DeBuff": true,
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "slshjzzs", "value": 1},
		{"name": "sljszzs", "value": 1},
		{"name": "slcpzzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_1403()

	skill_1_cd = 0
	skill_2_cd = 10
	skill_3_cd = 5
	hit3_stage = 0


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
				if skill_3_cd <= 0:
					do_hit_3()

			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_3_cd <= 0:
					do_hit_3()


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
	is_attacking = false

	if skill_2_cd > 0:
		return

	super.to_hero()
	skill_2_cd = randi_range(20, 25)
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
	skill_3_cd = randi_range(15, 25)
	velocity.x = 0
	is_attacking = true

	hit3_stage = 1
	hit_name = "hit3"
	mr_player.play("hit3")
	await mr_player.animation_finished

	await get_tree().create_timer(0.2).timeout

	hit3_stage = 2
	hit_name = "hit3_2"
	mr_player.play("hit3_2")
	await mr_player.animation_finished

	await get_tree().create_timer(0.2).timeout

	hit3_stage = 3
	hit_name = "hit3_1"
	mr_player.play("hit3_1")
	await mr_player.animation_finished

	await get_tree().process_frame

	var has_speed_down = check_player_has_speed_down()

	if has_speed_down:
		var stun_time = randi_range(1, 5)

		apply_real_stun(stun_time)

		if stun_time >= 4 and skill_2_cd <= 0:
			await get_tree().create_timer(0.3).timeout

			is_attacking = false
			hit3_stage = 0

			await do_hit_2()
		else:
			is_attacking = false
			hit3_stage = 0
			stop_move()
	else:
		is_attacking = false
		hit3_stage = 0
		stop_move()


func check_player_has_speed_down() -> bool:
	var player = RoleProp.source_player
	if player == null:
		return false

	if player.buff == null:
		return false

	for buff in player.buff.get_children():
		if buff != null and buff is BaseBuff:
			if buff.buff_info["Name"] == "speed_down":
				return true

	return false


func apply_real_stun(stun_time: float):
	var player = RoleProp.source_player
	if player == null:
		return
	if player.buff == null:
		return

	var stun_effect = {
		"Name": "stun",
		"AddTime": stun_time,
		"reduce_interval": 0,
		"value": 0,
		"AttackKind": "",
		"CanAdd": false,
		"DeBuff": true,
		"CanRemove": false,
	}

	Global.add_buff(player.buff, stun_effect)


func move_player_1():
	if not get_player:
		return
	var offset = 330
	if get_player.player_dir:
		self.position = Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x + offset,
			RoleProp.get_nearest_monster_target_position(global_position).y
		)
	else:
		self.position = Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x - offset,
			RoleProp.get_nearest_monster_target_position(global_position).y
		)


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

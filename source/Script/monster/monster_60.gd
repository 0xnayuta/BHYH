extends BaseMonster
var is_top: bool = false
var is_drop: bool = false
var has_summoned_war_god_xingtian: bool = false
var death_sequence_started: bool = false
const DEATH_SEQUENCE_FALLBACK_SECONDS := 1.5


func monster_60():
	get_parent().get_parent().create_control.stop()

	self.is_boss = true
	self.my_mr_name = "刑天"
	self.attack_in = 15
	self.level = 30
	self.max_hp = 33000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 120
	self.crit = 22
	self.miss = 15
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 500
	self.attack_range = 245
	self.attack_desire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 338,
		"hurtBack": [-7, -9],
		"attackKind": "magic",
	}
	self.obj_attack_dict["mykl"] = {
		"power": 338,
		"hurtBack": [-8, 0],
		"attackKind": "magic",
	}
	self.obj_attack_dict["xmhd"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "",
	}
	self.obj_attack_dict["sfjm"] = {
		"power": 688,
		"hurtBack": [-5, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 4,
			"CanAdd": false,
			"DeBuff": true,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "qtz", "value": 0},
		{"name": "dszk", "value": 0},
		{"name": "jljs", "value": 0},
		{"name": "lhz", "value": 0},
		{"name": "tpzy", "value": 0},
		{"name": "tpltp", "value": 0},
		{"name": "jlfyc", "value": 0},
		{"name": "jlfyj", "value": 0},
		{"name": "ylhq", "value": 0},
		{"name": "yljj", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "xtbx"

	update_fall_mode()
	self.fall_stone_pro = 0.15
	self.fall_stone = [{"name": "qhs_1", "value": randi_range(2, 4)}]


func _ready() -> void:
	monster_60()
	super._ready()
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_top:
		self.cannot_attract = true
	else:
		self.cannot_attract = false


func ai_think():
	if is_top:
		if not is_drop:
			velocity.y = -10
			if RoleProp.get_nearest_monster_target_position(global_position).x - position.x > 0:
				velocity.x = 200
			else:
				velocity.x -= 200
		return
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= 335:
				if skill_2_cd <= 0:
					do_hit_2()
				elif skill_3_cd <= 0:
					do_hit_3()
				else:
					have_target()
			else:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
					if skill_2_cd <= 0:
						if randi_range(0, 100) < 60:
							do_hit_2()
						else:
							if count % 60 == 0:
								attack_target()
							else:
								have_target()
					else:
						if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 260:
							if skill_1_cd <= 0:
								do_hit_1()
						elif skill_3_cd <= 0:
							do_hit_3()
						else:
							have_target()
				else:
					if skill_3_cd <= 0:
						do_hit_3()
					elif skill_1_cd <= 0:
						do_hit_1()
					elif skill_2_cd <= 0:
						if randi_range(0, 100) < 60:
							do_hit_2()
						else:
							if count % 60 == 0:
								attack_target()
							else:
								stop_move()
					else:
						if count % 60 == 0:
							attack_target()
						else:
							stop_move()


func do_hit_1():
	skill_1_cd = 12
	hit_name = "mykl"
	velocity.x = 0
	is_attacking = true
	mr_player.play("mykl")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(14, 18)
	hit_name = "sfjm"
	velocity.x = 0
	is_attacking = true
	mr_player.play("sfjm_1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(6, 10)
	hit_name = "xmhd"
	velocity.x = 0
	is_attacking = true
	mr_player.play("xmhd")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func go_top():
	if _movement_command_is_blocked():
		return
	is_drop = false
	is_top = true
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Vector2(self.position.x, -800), 1)


func drop():
	is_drop = true
	if _movement_command_is_blocked():
		is_drop = false
		is_top = false
		velocity = Vector2.ZERO
		return
	var shallow = Global.add_special_effect(
		self.bullet, Vector2(self.position.x, 500), "shallow", Vector2(1, 1), false, 1
	)
	if shallow != null:
		shallow.scale = Vector2(0.4, 0.4)
		var tween = get_tree().create_tween()
		if tween != null:
			tween.tween_property(shallow, "scale", Vector2(2, 2), 0.6)
		await get_tree().create_timer(0.6, false).timeout
		if is_instance_valid(shallow):
			shallow.queue_free()
	velocity.y += 2000
	velocity.x = 0
	mr_player.play("sfjm_2")
	await mr_player.animation_finished
	is_top = false


func call_sfjm_fire():
	var fire_position1 = [
		Vector2(self.position.x - 80, self.position.y + 30), Vector2(self.position.x + 80, self.position.y + 30)
	]
	var fire_position2 = [
		Vector2(self.position.x - 160, self.position.y + 30), Vector2(self.position.x + 160, self.position.y + 30)
	]
	var fire_position3 = [
		Vector2(self.position.x - 240, self.position.y + 30), Vector2(self.position.x + 240, self.position.y + 30)
	]
	for i in range(2):
		Global.add_bullet(
			"Monster42Bullet", self.bullet, false, 1.3, fire_position1[i], "sfjm", self.obj_attack_dict["sfjm"]
		)
	await get_tree().create_timer(0.2, false).timeout
	for i in range(2):
		Global.add_bullet(
			"Monster42Bullet", self.bullet, false, 1.3, fire_position2[i], "sfjm", self.obj_attack_dict["sfjm"]
		)
	await get_tree().create_timer(0.2, false).timeout
	for i in range(2):
		Global.add_bullet(
			"Monster42Bullet", self.bullet, false, 1.3, fire_position3[i], "sfjm", self.obj_attack_dict["sfjm"]
		)


func delay_call():
	if has_summoned_war_god_xingtian:
		return
	has_summoned_war_god_xingtian = true
	var level_node = get_level_node()
	if not level_node is BaseLevel:
		set_meta("counts_as_alive_for_stage_clear", false)
		return
	level_node.create_control.stop()
	level_node.monster_group["stage_1"].push_back(42)
	level_node.monster_position_x["stage_1"].push_back(position.x)
	level_node.monster_position_y["stage_1"].push_back(position.y)
	set_meta("counts_as_alive_for_stage_clear", false)
	level_node.create_control.start(5)


func state_death():
	if death_sequence_started:
		return
	death_sequence_started = true
	set_meta("counts_as_alive_for_stage_clear", true)
	settle_death_drops()
	super.state_death()
	_finish_death_sequence_after_timeout()


func _finish_death_sequence_after_timeout() -> void:
	await get_tree().create_timer(DEATH_SEQUENCE_FALLBACK_SECONDS, false).timeout
	if not is_instance_valid(self) or is_queued_for_deletion():
		return
	delay_call()
	set_meta("counts_as_alive_for_stage_clear", false)
	queue_free()


func is_alive_for_stage_clear() -> bool:
	return hp <= 0 and not has_summoned_war_god_xingtian


func call_hands():
	var bullet_spawn_positions = []
	var other_po = []
	if monster_direction:
		other_po = [Vector2(37, 55), Vector2(67, 45), Vector2(27, 25)]
		bullet_spawn_positions = [Vector2(37, -35), Vector2(67, -65), Vector2(27, -5)]
	else:
		other_po = [Vector2(-37, 55), Vector2(-67, 45), Vector2(-27, 25)]
		bullet_spawn_positions = [Vector2(-37, -35), Vector2(-67, -65), Vector2(-27, -5)]
	for i in bullet_spawn_positions:
		Global.add_bullet(
			"Monster60Bullet", self, monster_direction, randf_range(1.1, 1.3), i, "mykl", self.obj_attack_dict["mykl"]
		)
		await get_tree().create_timer(0.06, false).timeout
	await get_tree().create_timer(0.06, false).timeout
	for i in other_po:
		Global.add_bullet("Monster60Bullet", self, monster_direction, 1.35, i, "mykl", self.obj_attack_dict["mykl"])

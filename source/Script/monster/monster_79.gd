extends BaseMonster
var current_stage: int = 0
var is_relif: bool


func monster_79():
	self.rush_speed = 600
	self.is_boss = true
	self.my_mr_name = "巨灵神"
	self.attack_in = 15
	self.level = 35
	self.max_hp = 50000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 20
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 15
	self.mysee = 400
	self.attack_range = 200
	self.attack_desire = 90
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 100
	self.obj_attack_dict["hit1"] = {"power": 200, "hurtBack": [-7, -9], "attackKind": "physics", "HitProtect": 10}
	self.obj_attack_dict["hit2"] = {
		"power": 300,
		"hurtBack": [-7, -15],
		"attackKind": "magic",
		"HitProtect": 25,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 1.5,
			"CanAdd": false,
			"DeBuff": true,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 180,
		"hurtBack": [-16, -9],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 1,
			"reduce_interval": 0,
			"value": 0.2,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "xhc", "value": 0},
		{"name": "xhp", "value": 0},
		{"name": "xhj", "value": 0},
	]
	self.independent_fall_list = [
		{"name": "230007001", "value": 0, "chance": 0.333},
	]

	enable_treasure_box = true
	treasure_box_item = "jlsbx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_79()
	skill_1_cd = 0
	skill_2_cd = 0


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
					if skill_1_cd <= 0:
						do_hit_2()
				if skill_2_cd <= 0:
					do_hit_3()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_2()
				if skill_2_cd <= 0:
					do_hit_3()
				if count % 60 == 0:
					if randi_range(0, 100) <= attack_desire:
						attack_target()


func do_hit_2():
	to_hero()
	skill_1_cd = 15
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	to_hero()
	skill_2_cd = 18
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false


func destroy():
	current_stage += 1
	if current_stage >= 3:
		set_meta("counts_as_alive_for_stage_clear", false)
		settle_death_drops()
		await mr_player.animation_finished
		self.queue_free()
		return
	var tween = create_tween()
	match current_stage:
		1:
			tween.tween_property(self, "scale", Vector2(1.5, 1.5), 1)
			await get_tree().create_timer(0.8, false).timeout
			self.def = 180
			self.mdef = 180
			self.max_hp = 60000
			self.speed = 12
			self.obj_attack_dict["hit1"] = {
				"power": 300, "hurtBack": [-7, -9], "attackKind": "physics", "HitProtect": 10
			}
			self.obj_attack_dict["hit2"] = {
				"power": 400,
				"hurtBack": [-7, -15],
				"attackKind": "magic",
				"HitProtect": 25,
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
			self.obj_attack_dict["hit3"] = {
				"power": 270,
				"hurtBack": [-16, -9],
				"attackKind": "magic",
				"HitProtect": 5,
				"addeffect":
				{
					"Name": "speed_down",
					"AddTime": 1,
					"reduce_interval": 0,
					"value": 0.2,
					"AttackKind": "",
					"CanAdd": false,
					"DeBuff": true,
				}
			}
			set_full_hp()
			is_death = false
			hurt_box.set_deferred("disabled", false)
			set_meta("counts_as_alive_for_stage_clear", false)
		2:
			tween.tween_property(self, "scale", Vector2(2.2, 2.2), 1)
			await get_tree().create_timer(0.8, false).timeout
			self.def = 200
			self.mdef = 200
			self.max_hp = 70000
			self.speed = 8
			self.obj_attack_dict["hit1"] = {
				"power": 380, "hurtBack": [-7, -9], "attackKind": "physics", "HitProtect": 10
			}
			self.obj_attack_dict["hit2"] = {
				"power": 500,
				"hurtBack": [-7, -15],
				"attackKind": "magic",
				"HitProtect": 25,
				"addeffect":
				{
					"Name": "stun",
					"AddTime": 3,
					"reduce_interval": 0,
					"value": 0,
					"AttackKind": "",
					"CanAdd": false,
					"DeBuff": true,
				}
			}
			self.obj_attack_dict["hit3"] = {
				"power": 330,
				"hurtBack": [-16, -9],
				"attackKind": "magic",
				"HitProtect": 5,
				"addeffect":
				{
					"Name": "speed_down",
					"AddTime": 2,
					"reduce_interval": 0,
					"value": 0.5,
					"AttackKind": "",
					"CanAdd": false,
					"DeBuff": true,
				}
			}
			set_full_hp()
			is_death = false
			hurt_box.set_deferred("disabled", false)
			set_meta("counts_as_alive_for_stage_clear", false)


func state_death():
	if current_stage < 2:
		set_meta("counts_as_alive_for_stage_clear", true)
	super.state_death()


func is_alive_for_stage_clear() -> bool:
	return current_stage < 2 or bool(get_meta("counts_as_alive_for_stage_clear", false))


func state_hurt():
	is_jgz = false
	if current_stage >= 2:
		is_be_attacking = false
		return
	super.state_hurt()

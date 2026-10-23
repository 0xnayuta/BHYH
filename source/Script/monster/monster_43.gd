extends BaseMonster
class_name Monster43
var firstdoor = false
var seconddoor = false
var thirddoor = false


func monster_43():
	self.is_boss = true
	self.my_mr_name = "阎罗王"
	self.attack_in = 20
	self.level = 27
	self.max_hp = 28000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 15
	self.miss = 10
	self.lucky = 40
	self.htarget = 6
	self.toughness = 8
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 5
	self.speed = 8
	self.mysee = 400
	self.attack_range = 105
	self.attack_desire = 80
	self.behit_calmtime = 0.1
	self.self_rhp = 0
	self.add_exp = 50
	self.fall_coin = 13
	self.obj_attack_dict["hit1"] = {"power": 220, "hurtBack": [-6, -5], "attackKind": "physics"}
	self.obj_attack_dict["gwjq"] = {"power": 170, "hurtBack": [-6, -5], "attackKind": "magic"}
	self.obj_attack_dict["csjq"] = {
		"power": int(RoleProp.roleprop.SHp * 0.3),
		"hurtBack": [-6, -5],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "stun",
			"DeBuff": true,
			"AddTime": 3,
			"reduce_interval": 0,
			"CanAdd": false,
			"value": 0,
			"AttackKind": "",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "fygwj", "value": 1},
		{"name": "lchp", "value": 0},
	]
	self.independent_fall_list = [
		{"name": "221007002", "value": 0, "chance": 0.333},
	]

	enable_treasure_box = true
	treasure_box_item = "ylwbx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_43()
	skill_1_cd = 0
	skill_3_cd = 0


func do_hit_2():
	skill_1_cd = 20
	hit_name = "csjq"
	velocity.x = 0
	is_attacking = true
	mr_player.play("csjq")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	velocity.x = 0
	is_attacking = true
	mr_player.play("sdgm")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_4():
	skill_3_cd = 15
	hit_name = "gwjq"
	velocity.x = 0
	is_attacking = true
	mr_player.play("gwjq")
	await mr_player.animation_finished
	is_attacking = false


func ai_think():
	if hp < max_hp * 0.8:
		if not firstdoor:
			do_hit_3()
			Global.create_monster(
				44,
				get_parent(),
				Vector2(
					RoleProp.get_nearest_monster_target_position(global_position).x,
					RoleProp.get_nearest_monster_target_position(global_position).y - 100
				)
			)
			firstdoor = true
	if hp < max_hp * 0.6:
		if not seconddoor:
			do_hit_3()
			Global.create_monster(
				45,
				get_parent(),
				Vector2(
					RoleProp.get_nearest_monster_target_position(global_position).x,
					RoleProp.get_nearest_monster_target_position(global_position).y - 100
				)
			)
			seconddoor = true
	if hp < max_hp * 0.4:
		if not thirddoor:
			do_hit_3()
			Global.create_monster(
				46,
				get_parent(),
				Vector2(
					RoleProp.get_nearest_monster_target_position(global_position).x,
					RoleProp.get_nearest_monster_target_position(global_position).y - 100
				)
			)
			thirddoor = true
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_1_cd <= 0:
					do_hit_2()
				elif abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 125:
					if skill_3_cd <= 0:
						do_hit_4()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				elif skill_3_cd <= 0:
					do_hit_4()
				elif count % 120 == 0:
					if ran_num <= attack_desire:
						attack_target()
				else:
					stop_move()


func movetorolebehind():
	if RoleProp.directon:
		self.position.x = RoleProp.get_nearest_monster_target_position(global_position).x
	else:
		self.position.x = RoleProp.get_nearest_monster_target_position(global_position).x
	self.position.y = RoleProp.get_nearest_monster_target_position(global_position).y
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
		monster_dir.scale.x = -1
		base_damage_box.scale.x = -1
	else:
		monster_dir.scale.x = 1
		base_damage_box.scale.x = 1

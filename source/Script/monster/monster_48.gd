extends BaseMonster
class_name Monster48
var change_body_flag: bool = false
var change_dir_count: int = 60


func monster_48():
	self.is_boss = true
	self.my_mr_name = "夜叉"
	self.attack_in = 0
	self.level = 30
	self.max_hp = 35000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 25
	self.miss = 10
	self.lucky = 0
	self.htarget = 0
	self.toughness = -10
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 8
	self.mysee = 400
	self.attack_range = 158
	self.attack_desire = 85
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": int(100 + RoleProp.roleprop.SHp * 0.02), "hurtBack": [0, -3], "attackKind": "real"
	}
	self.obj_attack_dict["fszy"] = {
		"power": int(300 + RoleProp.roleprop.SHp * 0.02),
		"hurtBack": [0, -3],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 2,
			"reduce_interval": 0.5,
			"CanAdd": true,
			"DeBuff": true,
			"value": int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "real",
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "xhmj", "value": 0},
		{"name": "xhxc", "value": 0},
		{"name": "lczh", "value": 0},
	]
	self.independent_fall_list = [
		{"name": "220007002", "value": 0, "chance": 0.333},
	]

	enable_treasure_box = true
	treasure_box_item = "ycbx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_48()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if change_body_flag:
		self.cannot_attract = true


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if not change_body_flag:
				$BaseDamageBox/HurtBox.set_collision_mask_value(12, true)
				$BaseDamageBox/HurtBox.set_collision_mask_value(7, true)
				self.def = 150
				self.mdef = 150
				self.speed = 8
				if float(hp) / float(max_hp) <= 0.7:
					change_body()
				elif not is_be_attacking:
					super.ai_think()
			else:
				$BaseDamageBox/HurtBox.set_collision_mask_value(12, false)
				$BaseDamageBox/HurtBox.set_collision_mask_value(7, false)
				self.def = 180
				self.mdef = 180
				self.speed = 30
				if skill_1_cd > 0:
					if self.position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
						move_right()
					else:
						move_left()
					if count % 30 == 0:
						if (
							abs(self.position.x - RoleProp.get_nearest_monster_target_position(global_position).x)
							<= attack_range
						):
							attack_target()
				else:
					if self.position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
						move_left()
					else:
						move_right()
					if skill_1_cd <= 0:
						if (
							(
								abs(self.position.x - RoleProp.get_nearest_monster_target_position(global_position).x)
								<= 245
							)
							and (
								abs(self.position.y - RoleProp.get_nearest_monster_target_position(global_position).y)
								<= 255
							)
						):
							do_hit_2()
					elif count % 30 == 0:
						if (
							abs(self.position.x - RoleProp.get_nearest_monster_target_position(global_position).x)
							<= attack_range
						):
							attack_target()


func attack_target():
	skill_2_cd = randi_range(7, 10)
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
		move_right()
	else:
		move_left()
	hit_name = "hit1"
	if not change_body_flag:
		velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false


func change_body():
	velocity.x = 0
	mr_player.play("changeBody")
	await mr_player.animation_finished
	change_body_flag = true


func do_hit_2():
	skill_1_cd = randi_range(7, 10)
	hit_name = "fszy"
	is_attacking = true
	mr_player.play("fszy")
	await mr_player.animation_finished
	is_attacking = false


func move_left():
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1
	velocity.x = -speed * 10
	if not change_body_flag:
		mr_player.play("walk_1")
	else:
		mr_player.play("walk_2")


func move_right():
	base_damage_box.scale.x = -1
	monster_dir.scale.x = -1
	velocity.x = speed * 10
	if not change_body_flag:
		mr_player.play("walk_1")
	else:
		mr_player.play("walk_2")


func _on_hit_box_area_entered(_area: Area2D) -> Node2D:
	var buff_target = super._on_hit_box_area_entered(_area)

	if hit_name == "fszy" or hit_name == "hit1":
		if change_body_flag:
			if hit_name == "fszy":
				cure_hp(obj_attack_dict[hit_name]["power"] * randi_range(1, 2) + int((max_hp - hp) * 0.02))
			else:
				cure_hp(obj_attack_dict[hit_name]["power"] * randi_range(1, 2) + int((max_hp - hp) * 0.01))
		else:
			cure_hp(obj_attack_dict[hit_name]["power"] * randi_range(18, 22))

	return buff_target

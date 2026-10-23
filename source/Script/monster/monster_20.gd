extends BaseMonster
class_name Monster20

var is_first_low_hp = false
var my_shark


func monster_20():
	self.is_boss = true
	self.my_mr_name = "鲨魔王"
	self.attack_in = 60
	self.level = 25
	self.max_hp = 10000
	self.hp = self.max_hp
	self.def = 100
	self.mdef = 150
	self.crit = 15
	self.miss = 5
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 8
	self.mysee = 450
	self.attack_range = 145
	self.attack_desire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {"power": 225, "hurtBack": [-5, -9], "attackKind": "physics"}
	self.obj_attack_dict["sxks"] = {
		"power": 245,
		"hurtBack": [-5, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 5,
			"CanAdd": true,
			"DeBuff": true,
			"reduce_interval": 0.5,
			"value": 20,
			"AttackKind": "real",
		}
	}
	self.obj_attack_dict["sxks_2"] = {
		"power": 155,
		"hurtBack": [-7, -15],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 5,
			"DeBuff": true,
			"CanAdd": true,
			"reduce_interval": 0.5,
			"value": 20,
			"AttackKind": "real",
		}
	}
	self.obj_attack_dict["spzd"] = {
		"power": 400,
		"hurtBack": [-15, -15],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"CanAdd": false,
			"DeBuff": true,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [{"name": "qlp", "value": 0}, {"name": "zqj", "value": 0}, {"name": "ttj", "value": 0}]

	enable_treasure_box = true
	treasure_box_item = "smwbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_20()
	skill_1_cd = 0
	skill_2_cd = 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if self.hp <= 0:
		if my_shark != null:
			my_shark.hp = -100
			my_shark.state = my_shark.State.DEATH


func ai_think():
	if self.hp <= 0:
		if my_shark != null:
			my_shark.hp = -100
			my_shark.state = my_shark.State.DEATH
	if not is_first_low_hp:
		if low_hp():
			if self.monster_direction:
				my_shark = Global.create_monster(19, get_parent(), Vector2(self.position.x, self.position.y - 30))
			else:
				my_shark = Global.create_monster(19, get_parent(), Vector2(self.position.x, self.position.y - 30))
			is_first_low_hp = true

	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_2_cd <= 0:
					do_hit_3()
				elif abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 550:
					if skill_1_cd <= 0:
						do_hit_2()
			else:
				if skill_2_cd <= 0:
					do_hit_3()
				elif skill_1_cd <= 0:
					do_hit_2()
				else:
					if count % 90 == 0:
						if ran_num <= attack_desire:
							attack_target()
					else:
						stop_move()


func attack_target():
	have_target()
	hit_name = "hit1"
	if not is_fly:
		velocity.x = 0
	is_attacking = true
	if not low_hp():
		mr_player.play("hit1_1")
	else:
		mr_player.play("hit1_2")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_2():
	skill_1_cd = 20
	hit_name = "sxks"
	velocity.x = 0
	is_attacking = true
	if not low_hp():
		mr_player.play("sxks_1")
	else:
		mr_player.play("sxks_2")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 15
	velocity.x = 0
	hit_name = "spzd"
	is_attacking = true
	if not low_hp():
		mr_player.play("spzd_1")
	else:
		mr_player.play("spzd_2")
	await mr_player.animation_finished
	is_attacking = false


func call_pp():
	var nearest_pos := RoleProp.get_nearest_monster_target_position(global_position)
	if nearest_pos.x == null or nearest_pos.y == null:
		return
	var first_position := Vector2(float(nearest_pos.x), float(nearest_pos.y) - 110.0)
	var parent_node: Node = get_parent().get_parent() if get_parent() != null else null
	if parent_node != null:
		Global.add_special_effect(parent_node, first_position, "monster20_bullet_1", Vector2(1, 1), false, 1)
	var second_position := first_position + Vector2(0.0, 70.0)
	await get_tree().create_timer(0.8, false).timeout
	Global.add_bullet(
		"monster20_bullet_1",
		self.bullet,
		self.monster_direction,
		1,
		second_position,
		"spzd",
		self.obj_attack_dict["spzd"]
	)


func call_shark():
	var bullet_name = "Monster_20Bullet"
	var speed_val = 700
	var position_vec = Vector2(position.x, position.y - 20)
	var hit_name = "sxks_2"
	var attack_dic = obj_attack_dict["sxks_2"]

	if monster_direction:
		var shark = Global.call_fly_bullet(bullet, bullet_name, 1, position_vec, 4000, speed_val, hit_name, attack_dic)
		var shark_1 = Global.call_fly_bullet(
			bullet, bullet_name, 1, position_vec, 4000, -speed_val, hit_name, attack_dic
		)

		if shark:
			var sprite = shark.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = false
		if shark_1:
			var sprite = shark_1.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = true
	else:
		var shark = Global.call_fly_bullet(bullet, bullet_name, 1, position_vec, 4000, -speed_val, hit_name, attack_dic)
		var shark_1 = Global.call_fly_bullet(
			bullet, bullet_name, 1, position_vec, 4000, speed_val, hit_name, attack_dic
		)

		if shark:
			var sprite = shark.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = true
		if shark_1:
			var sprite = shark_1.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = false


func low_hp():
	return self.hp <= self.max_hp * 0.7


func move_left():
	monster_dir.scale.x = 1
	base_damage_box.scale.x = 1
	velocity.x = -speed * 10
	if not low_hp():
		mr_player.play("walk_1")
	else:
		mr_player.play("walk_2")


func move_right():
	monster_dir.scale.x = -1
	base_damage_box.scale.x = -1
	velocity.x = speed * 10
	if not low_hp():
		mr_player.play("walk_1")
	else:
		mr_player.play("walk_2")


func stop_move():
	velocity.x = 0
	if not low_hp():
		mr_player.play("wait_1")
	else:
		mr_player.play("wait_2")
	await mr_player.animation_finished


func state_hurt():
	if get_target.hit_dic["hurtBack"][0] != 0 or get_target.hit_dic["hurtBack"][1] != 0:
		is_be_attacking = true
		velocity.x = 0
		if not is_quiescent:
			super.be_hit_back(self.get_target)
			if not low_hp():
				mr_player.play("hurt_1")
			else:
				mr_player.play("hurt_2")
			await mr_player.animation_finished
			is_be_attacking = false


func change_hit():
	if not low_hp():
		self.obj_attack_dict["hit1"] = {"power": 245, "hurtBack": [-5, -9], "attackKind": "real"}
		self.obj_attack_dict["sxks"] = {
			"power": 50,
			"hurtBack": [-5, -15],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 4,
				"reduce_interval": 0.5,
				"value": 15,
				"AttackKind": "real",
			}
		}
		self.obj_attack_dict["sxks_2"] = {
			"power": 70,
			"hurtBack": [-7, -15],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 4,
				"reduce_interval": 0.5,
				"value": 15,
				"AttackKind": "real",
			}
		}
		self.obj_attack_dict["spzd"] = {
			"power": 500,
			"hurtBack": [-15, -15],
			"attackKind": "real",
			"addeffect":
			{
				"Name": "stun",
				"AddTime": 3,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
			}
		}
	else:
		self.obj_attack_dict["hit1"] = {"power": 105, "hurtBack": [-5, -9], "attackKind": "physics"}
		self.obj_attack_dict["sxks"] = {
			"power": 300,
			"hurtBack": [-5, -15],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 4,
				"reduce_interval": 0.5,
				"value": 10,
				"AttackKind": "real",
			}
		}
		self.obj_attack_dict["sxks_2"] = {
			"power": 300,
			"hurtBack": [-7, -15],
			"attackKind": "real",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 4,
				"reduce_interval": 0.5,
				"value": 10,
				"AttackKind": "real",
			}
		}
		self.obj_attack_dict["spzd"] = {
			"power": 210,
			"hurtBack": [-15, -15],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "stun",
				"AddTime": 3,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
			}
		}

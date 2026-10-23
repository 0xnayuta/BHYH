extends BaseMonster
var cure_count: int = 0


func monster_11():
	self.is_boss = true
	self.my_mr_name = "狮驼王"
	self.attack_in = 30
	self.level = 18
	self.max_hp = 3500
	self.hp = self.max_hp
	self.def = 60
	self.mdef = 70
	self.crit = 10
	self.miss = 6
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 300
	self.attack_range = 85
	self.attack_desire = 85
	self.behit_calmtime = 0.4
	self.self_rhp = 0
	self.add_exp = 100
	self.fall_coin = 30
	self.obj_attack_dict["hit1"] = {
		"power": 135,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 15,
	}
	self.obj_attack_dict["kldw"] = {
		"power": 5,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 1,
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 18,
			"reduce_interval": 1,
			"value": 15,
			"CanAdd": true,
			"AttackKind": "real",
		}
	}
	self.obj_attack_dict["ysyb"] = {
		"power": 330,
		"hurtBack": [-7, -25],
		"attackKind": "magic",
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
	self.fall_list = [
		{"name": "jcbj", "value": 0},
		{"name": "jcjp", "value": 0},
		{"name": "jcmc", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "stwbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_11()
	skill_1_cd = 0
	skill_2_cd = 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if super.check_player_have_debuff("poision"):
		if cure_count % 60 == 0:
			cure_hp(200)
		cure_count += 1


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
					if skill_1_cd <= 0:
						if not is_on_floor():
							have_target()
						else:
							do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
					if skill_2_cd <= 0:
						do_hit_3()
			else:
				if skill_1_cd <= 0:
					if not is_on_floor():
						have_target()
					else:
						do_hit_2()
				elif skill_2_cd <= 0:
					do_hit_3()
				elif count % 60 == 0:
					var rad = randi_range(0, 100)
					if rad <= attack_desire:
						attack_target()
				else:
					stop_move()


func do_hit_2():
	skill_1_cd = 20
	hit_name = "kldw"
	velocity.x = 0
	is_attacking = true
	mr_player.play("kldw")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 15
	velocity.x = 0
	hit_name = "ysyb"
	is_attacking = true
	mr_player.play("ysyb")
	await mr_player.animation_finished
	is_attacking = false


func skill_shake():
	get_parent().get_parent().shake(0, 10, 1, 40, 10, 0.01)


func call_poision():
	var position_x_list = []
	var position_y = self.position.y - 10
	if self.monster_direction:
		position_x_list = [
			self.position.x + 20,
			self.position.x + 100,
			self.position.x + 180,
			self.position.x + 260,
			self.position.x + 340,
			self.position.x + 420
		]
		for i in range(5):
			var po = Vector2(position_x_list[i], position_y)
			var poision = Global.add_bullet(
				"PoisionBullet", self.bullet, self.monster_direction, 0.7, po, "kldw", self.obj_attack_dict["kldw"]
			)
			poision.scale = Vector2(1.2, 1.2)
			randomize()
			await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
	else:
		position_x_list = [
			self.position.x - 20,
			self.position.x - 100,
			self.position.x - 180,
			self.position.x - 260,
			self.position.x - 340,
			self.position.x - 420
		]
		for i in range(5):
			var po = Vector2(position_x_list[i], position_y)
			var poision = Global.add_bullet(
				"PoisionBullet", self.bullet, self.monster_direction, 0.7, po, "kldw", self.obj_attack_dict["kldw"]
			)
			poision.scale = Vector2(1.2, 1.2)
			randomize()
			await get_tree().create_timer(randf_range(0.1, 0.5)).timeout


func call_pp():
	if self.monster_direction:
		Global.add_special_effect(self, Vector2(150, 30), "poisionpp", Vector2(2, 2), false, 1)
	else:
		Global.add_special_effect(self, Vector2(-150, 30), "poisionpp", Vector2(2, 2), false, 1)


func call_ysyb():
	var bullet_spawn_positions = [Vector2(0, 90), Vector2(-120, -20), Vector2(120, -20)]
	for i in bullet_spawn_positions:
		Global.add_bullet(
			"Monster11Bullet",
			self.bullet,
			self.monster_direction,
			1,
			i + position,
			"ysyb",
			self.obj_attack_dict["ysyb"]
		)
		await get_tree().create_timer(0.6, false).timeout
	pass

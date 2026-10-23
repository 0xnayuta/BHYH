extends BaseMonster
class_name Monster28


func monster_28(is_boss_):
	self.my_mr_name = "守夜人"
	if is_boss_:
		self.attack_in = 30
		self.level = 25
		self.max_hp = 15000
		self.hp = self.max_hp
		self.def = 120
		self.mdef = 150
		self.crit = 35
		self.miss = 18
		self.lucky = 0
		self.htarget = 10
		self.toughness = 10
		self.ar = 20
		self.sp = 20
		self.crit_reduce = 0
		self.speed = 6
		self.mysee = 400
		self.attack_range = 135
		self.attack_desire = 100
		self.behit_calmtime = 0.1
		self.self_rhp = 0
		self.add_exp = 200
		self.fall_coin = 200
		self.obj_attack_dict["hit1"] = {
			"power": 180,
			"hurtBack": [-6, -9],
			"attackKind": "physics",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 2,
				"reduce_interval": 0.5,
				"CanAdd": true,
				"DeBuff": true,
				"value": int(RoleProp.roleprop.SHp * 0.02),
				"AttackKind": "magic",
			}
		}
		self.obj_attack_dict["hsg"] = {
			"power": 90 + RoleProp.roleprop.SHp * 0.08,
			"hurtBack": [-4, -9],
			"attackKind": "physics",
			"addeffect":
			{
				"Name": "Fire",
				"AddTime": 4,
				"reduce_interval": 0.5,
				"CanAdd": true,
				"DeBuff": true,
				"value": int(RoleProp.roleprop.SHp * 0.02),
				"AttackKind": "magic",
			}
		}

		self.fall_pro = 0.5
		self.fall_list = [{"name": "lzp", "value": 0}, {"name": "jmy", "value": 0}]
		self.independent_fall_list = [
			{"name": "221007001", "value": 0, "chance": 0.333},
		]

		enable_treasure_box = true
		treasure_box_item = "syrbx"

		update_fall_mode()
		if current_fall_mode == FallMode.TREASURE_BOX:
			self.independent_fall_list.clear()
		self.fall_stone_pro = 0
		self.fall_stone = []
	else:
		self.attack_in = 10
		self.level = 27
		self.max_hp = 2000
		self.hp = self.max_hp
		self.def = 150
		self.mdef = 150
		self.crit = 10
		self.miss = 10
		self.lucky = 0
		self.htarget = 8
		self.toughness = 0
		self.ar = 0
		self.sp = 0
		self.crit_reduce = 0
		self.speed = 7
		self.mysee = 300
		self.attack_range = 135
		self.attack_desire = 100
		self.behit_calmtime = 0.2
		self.self_rhp = 0
		self.add_exp = 60
		self.fall_coin = 25
		self.obj_attack_dict["hit1"] = {
			"power": 90,
			"hurtBack": [-6, -9],
			"attackKind": "physics",
			"addeffect":
			{
				"Name": "Bleed",
				"AddTime": 1,
				"reduce_interval": 0.5,
				"CanAdd": true,
				"DeBuff": true,
				"value": int(RoleProp.roleprop.SHp * 0.02),
				"AttackKind": "magic",
			}
		}
		self.obj_attack_dict["hsg"] = {
			"power": 40 + RoleProp.roleprop.SHp * 0.04,
			"hurtBack": [-4, -9],
			"attackKind": "physics",
			"addeffect":
			{
				"Name": "Fire",
				"AddTime": 1,
				"reduce_interval": 0.5,
				"CanAdd": true,
				"DeBuff": true,
				"value": int(RoleProp.roleprop.SHp * 0.02),
				"AttackKind": "magic",
			}
		}
		self.fall_pro = 0
		self.fall_list = []
		self.fall_stone_pro = 0
		self.fall_stone = []


func _ready() -> void:
	super._ready()
	if get_parent().get_parent().name == "Level_11":
		is_boss = true
	else:
		is_boss = false
	monster_28(is_boss)


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_1_cd <= 0:
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 330:
						do_hit_2()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				elif count % 90 == 0:
					if ran_num <= attack_desire:
						attack_target()
				else:
					stop_move()


func do_hit_2():
	skill_1_cd = 8
	hit_name = "hsg"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hsg")
	await mr_player.animation_finished
	is_attacking = false


func call_bullet_1():
	if self.monster_direction:
		var po = Vector2(self.position.x + 40, self.position.y + 20)
		Global.add_bullet(
			"Monster28Bullet_2", self.bullet, self.monster_direction, 1, po, "hit1", self.obj_attack_dict["hit1"]
		)
		await get_tree().create_timer(0.3, false).timeout
		Global.add_bullet(
			"Monster28Bullet_2",
			self.bullet,
			self.monster_direction,
			1,
			po + Vector2(randi_range(40, 50), 0),
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		var po = Vector2(self.position.x - 40, self.position.y + 20)
		Global.add_bullet(
			"Monster28Bullet_2", self.bullet, self.monster_direction, 1, po, "hit1", self.obj_attack_dict["hit1"]
		)
		Global.add_bullet(
			"Monster28Bullet_2",
			self.bullet,
			self.monster_direction,
			1,
			po + Vector2(randi_range(-40, -50), 0),
			"hit1",
			self.obj_attack_dict["hit1"]
		)


func call_bullet_2():
	if self.monster_direction:
		Global.call_fly_bullet(
			self.bullet,
			"Monster28Bullet_1",
			1,
			Vector2(position.x, position.y),
			900,
			-200,
			"hsg",
			self.obj_attack_dict["hsg"]
		)
	else:
		Global.call_fly_bullet(
			self.bullet,
			"Monster28Bullet_1",
			1,
			Vector2(position.x, position.y),
			900,
			200,
			"hsg",
			self.obj_attack_dict["hsg"]
		)

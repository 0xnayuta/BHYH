extends BaseMonster
class_name Monster77
var round_num


func monster_77():
	self.is_boss = true
	self.my_mr_name = "千里眼"
	self.attack_in = 15
	self.level = 35
	self.max_hp = 40000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 20
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 14
	self.mysee = 400
	self.attack_range = 350
	self.attack_desire = 75
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 100
	self.obj_attack_dict["hit1"] = {
		"power": 330,
		"hurtBack": [-7, -9],
		"attackKind": "physics",
	}
	self.obj_attack_dict["hit2"] = {
		"power": 600,
		"hurtBack": [-7, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 6,
			"reduce_interval": 0,
			"value": 0.5,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 700,
		"hurtBack": [25, -25],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "kyz", "value": 0},
		{"name": "kyc", "value": 0},
	]
	self.independent_fall_list = [
		{"name": "231007001", "value": 0, "chance": 0.333},
	]

	enable_treasure_box = true
	treasure_box_item = "qlysfebx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_77()
	skill_1_cd = 0


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
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 600:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				else:
					if count % 60 == 0:
						if randi_range(0, 100) < attack_desire:
							attack_target()
						else:
							stop_move()
					else:
						stop_move()


func do_hit_2():
	to_hero()
	skill_1_cd = 10
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false


func add_child_1():
	var rotation_value
	var rotation2
	var po: Vector2
	var bullet_spawn_positions = []
	if monster_direction:
		po = Vector2(70, -20)
		rotation_value = -11
		rotation2 = 40
		bullet_spawn_positions = [
			Vector2(1400, -1000), Vector2(1200, -1000), Vector2(1000, -1000), Vector2(800, -1000), Vector2(600, -1000)
		]
	else:
		po = Vector2(-70, -20)
		bullet_spawn_positions = [
			Vector2(-1400, -1000),
			Vector2(-1200, -1000),
			Vector2(-1000, -1000),
			Vector2(-800, -1000),
			Vector2(-600, -1000)
		]
		rotation_value = 11
		rotation2 = -40
	var child = Global.add_bullet(
		"Monster77Bullet2", bullet, monster_direction, 2, position + po, "hit2", self.obj_attack_dict["hit2"]
	)
	child.rotation_degrees = rotation_value
	var dir = monster_direction
	await get_tree().create_timer(1, false).timeout
	for i in bullet_spawn_positions:
		child = Global.add_bullet(
			"Monster77Bullet3", bullet, dir, 2, position + i, "hit3", self.obj_attack_dict["hit3"]
		)
		child.rotation_degrees = rotation2
		await get_tree().create_timer(0.5, false).timeout


func add_child_2():
	var po: Vector2
	if monster_direction:
		po = Vector2(50, 0)
	else:
		po = Vector2(-50, 0)
	var child = Global.add_bullet(
		"Monster77Bullet1", bullet, monster_direction, 2, position + po, "hit1", self.obj_attack_dict["hit1"]
	)

extends BaseMonster
var dog: Monster72
var call_dog: bool


func monster_93():
	self.rush_speed = 400
	self.is_boss = true
	self.my_mr_name = "二郎神"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 140000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 500
	self.attack_range = 165
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 500
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-8, -12],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": int(RoleProp.roleprop.SHp * 0.3 + 1000),
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 20,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 400,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 5,
	}
	self.obj_attack_dict["hit4"] = {
		"power": 300,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "blood_fix",
			"AddTime": 20,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit5"] = {
		"power": 300,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 8,
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "shsjt", "value": 0},
	]
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_93()
	skill_1_cd = randi_range(3, 4)
	skill_2_cd = 10
	skill_3_cd = 5
	skill_4_cd = 0


func ai_think():
	if dog == null and not call_dog:
		dog = Global.create_monster(72, get_parent(), position)
		dog.max_hp = 70000
		dog.hp = dog.max_hp
		dog.is_call = true
		dog.my_father = self
		call_dog = true
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

				if skill_4_cd <= 0:
					do_hit_4()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300:
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 800:
					if skill_3_cd <= 0:
						do_hit_3()
			else:
				if skill_1_cd <= 0:
					do_hit_1()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif skill_3_cd <= 0:
					do_hit_3()
				elif skill_4_cd <= 0:
					do_hit_4()
				elif count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
					else:
						stop_move()
				else:
					stop_move()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(10, 12)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	do_hit_2()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(8, 12)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(15, 18)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	super.to_hero()
	skill_4_cd = randi_range(10, 14)
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit5")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func add_bullet():
	var bullet_spawn_positions = [Vector2()]
	var position2: Vector2
	var tween = create_tween().set_parallel(true)
	if monster_direction:
		bullet_spawn_positions = [Vector2(-10, -315), Vector2(70, -70), Vector2(-65, -70)]
		position2 = Vector2(-10, -160)
	else:
		bullet_spawn_positions = [Vector2(10, -315), Vector2(-70, -70), Vector2(65, -70)]
		position2 = Vector2(10, -160)
	for i in bullet_spawn_positions:
		var line = Global.add_bullet(
			"Monster93Bullet", self.bullet, monster_direction, 1.6, i + position, "hit5", self.obj_attack_dict["hit5"]
		)
		if monster_direction:
			tween.tween_property(line, "rotation_degrees", 45, 2)
		else:
			tween.tween_property(line, "rotation_degrees", -45, 2)
	var line2 = Global.add_bullet(
		"Monster93Bullet",
		self.bullet,
		monster_direction,
		1.6,
		position2 + position,
		"hit5",
		self.obj_attack_dict["hit5"]
	)
	line2.scale.y = 2.2


func blood_fix():
	if self.position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
		if Global.get_player.player_dir:
			if not monster_direction:
				add_blood_fix()
	else:
		if not Global.get_player.player_dir:
			if monster_direction:
				add_blood_fix()


func add_blood_fix():
	(
		Global
		. add_buff(
			get_player.buff,
			{
				"Name": "blood_fix",
				"AddTime": 20,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"CanAdd": false,
				"DeBuff": true,
			}
		)
	)

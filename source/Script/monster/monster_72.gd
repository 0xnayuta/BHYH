extends BaseMonster
class_name Monster72
var my_father: BaseMonster
var is_call: bool


func monster_72():
	self.is_boss = true
	self.my_mr_name = "哮天犬"
	self.attack_in = 0
	self.level = 35
	self.max_hp = 40000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 20
	self.miss = 18
	self.lucky = 18
	self.htarget = 10
	self.toughness = 10
	self.ar = 20
	self.sp = 20
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 400
	self.attack_range = 175
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": 288,
		"hurtBack": [-7, -9],
		"attackKind": "magic",
	}
	self.obj_attack_dict["hit2"] = {
		"power": 300,
		"hurtBack": [-7, -9],
		"attackKind": "magic",
	}
	self.obj_attack_dict["hit3"] = {
		"power": 300,
		"hurtBack": [-7, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 5,
			"CanAdd": true,
			"DeBuff": true,
			"reduce_interval": 0.5,
			"value": 35,
			"AttackKind": "real",
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "sichou", "value": randi_range(3, 5)},
		{"name": "xuantie", "value": randi_range(3, 5)},
		{"name": "tanmu", "value": randi_range(3, 5)},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	skill_1_cd = 0
	skill_2_cd = 0
	monster_72()


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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
					if skill_2_cd <= 0:
						do_hit_2()
				if count % 120 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
			else:
				if skill_1_cd <= 0:
					do_hit_1()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
					else:
						stop_move()
				else:
					stop_move()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(15, 18)
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("Skill")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(10, 12)
	velocity.x = 0
	hit_name = "hit2"
	is_attacking = true
	mr_player.play("Skill2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_monster_bullet():
	var bullet_name = "Monster72Bullet"
	var bullet_pos
	var bullet_spawn_positions = [Vector2(0, 0), Vector2(0, -75), Vector2(0, 75)]
	for i in bullet_spawn_positions:
		Global.add_bullet(
			bullet_name, self.bullet, monster_direction, 1, i + position, "hit2", self.obj_attack_dict["hit2"]
		)
		await get_tree().create_timer(0.3, false).timeout


func strength_obj():
	self.cure_hp(max_hp * 0.15)
	for i in self.obj_attack_dict:
		if self.obj_attack_dict[i].has("power"):
			self.obj_attack_dict[i]["power"] *= 1.05
	self.crit += 10
	sp += 10
	ar += 10
	if my_father != null:
		my_father.cure_hp(max_hp * 0.15)
		for i in my_father.obj_attack_dict:
			if my_father.obj_attack_dict[i].has("power"):
				my_father.obj_attack_dict[i]["power"] *= 1.05
		my_father.crit += 5
		my_father.sp += 5
		my_father.ar += 5


func call_monster():
	if not is_call:
		var self_ref = Global.create_monster(72, get_parent(), position)
		self_ref.max_hp = max_hp * 1.5
		self_ref.hp = self_ref.max_hp
		self_ref.def = def * 1.2
		self_ref.mdef = mdef * 1.2
		self_ref.modulate = Color("00ffff")
		self_ref.my_mr_name = "邪·哮天犬"
		self_ref.is_call = true
		for i in self_ref.obj_attack_dict:
			if self_ref.obj_attack_dict[i].has("power"):
				self_ref.obj_attack_dict[i]["power"] = self.obj_attack_dict[i]["power"] * 1.5
		is_call = true

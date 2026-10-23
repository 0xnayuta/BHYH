extends BaseMonster
class_name Monster57
var round_speed: int = 230
var round_chase_time: float = 2.3
var round_throw_count: int = 2
var round_list = []
var boss_2: Monster55


func monster_57():
	if get_parent().get_parent() is LevelZLDHDGQ:
		self.is_fly = true
		self.is_boss = true
		self.my_mr_name = "转轮·圣王"
		self.attack_in = 120
		self.level = 50
		self.max_hp = 250000
		self.hp = self.max_hp
		self.def = 350
		self.mdef = 380
		self.crit = 25
		self.miss = 8
		self.lucky = 15
		self.htarget = 15
		self.toughness = 0
		self.ar = 30
		self.sp = 70
		self.crit_reduce = 0
		self.speed = 10
		self.mysee = 300
		self.attack_range = 600
		self.attack_desire = 90
		self.behit_calmtime = 0.2
		self.self_rhp = 0
		self.add_exp = 1000
		self.fall_coin = 1000
		self.obj_attack_dict["hit1"] = {
			"power": 600,
			"hurtBack": [-4, -9],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "stun",
				"AddTime": randi_range(2, 3),
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"CanAdd": false,
				"DeBuff": true,
			}
		}
		self.obj_attack_dict["hit1_1"] = {
			"power": 660,
			"hurtBack": [-4, -9],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "Ice",
				"AddTime": randi_range(2, 3),
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"CanAdd": false,
				"DeBuff": true,
			}
		}
		self.obj_attack_dict["hit1_2"] = {
			"power": 680,
			"hurtBack": [-4, -9],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "poision",
				"AddTime": randi_range(2, 3),
				"reduce_interval": randf_range(0.6, 1),
				"value": randi_range(40, 60),
				"AttackKind": "magic",
				"CanAdd": true,
				"DeBuff": true,
			}
		}
		self.obj_attack_dict["hit1_3"] = {
			"power": 520,
			"hurtBack": [-4, -9],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "Fire",
				"AddTime": randi_range(2, 3),
				"reduce_interval": randf_range(0.6, 1),
				"value": randi_range(40, 60),
				"AttackKind": "magic",
				"CanAdd": true,
				"DeBuff": true,
			}
		}
		self.obj_attack_dict["dmzhl"] = {"power": 600, "hurtBack": [-8, 0], "attackKind": "magic"}
		self.obj_attack_dict["dmgz"] = {"power": 800, "hurtBack": [0, -7], "attackKind": "magic"}
		self.fall_pro = 0.5
		self.fall_list = [
			{"name": "zlwdahsp1", "value": 1},
			{"name": "zlwdahsp2", "value": 1},
		]
		return
	self.is_fly = true
	self.is_boss = true
	self.my_mr_name = "转轮·圣王"
	self.attack_in = 120
	self.level = 30
	self.max_hp = 30000
	self.hp = self.max_hp
	self.def = 200
	self.mdef = 100
	self.crit = 25
	self.miss = 8
	self.lucky = 15
	self.htarget = 15
	self.toughness = 0
	self.ar = 30
	self.sp = 30
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 300
	self.attack_range = 600
	self.attack_desire = 90
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 1000
	self.fall_coin = 1000
	self.obj_attack_dict["hit1"] = {
		"power": 200,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": randi_range(2, 3),
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit1_1"] = {
		"power": 220,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Ice",
			"AddTime": randi_range(2, 3),
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit1_2"] = {
		"power": 240,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "poision",
			"AddTime": randi_range(2, 3),
			"reduce_interval": randf_range(0.6, 1),
			"value": randi_range(40, 60),
			"AttackKind": "magic",
			"CanAdd": true,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit1_3"] = {
		"power": 260,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": randi_range(2, 3),
			"reduce_interval": randf_range(0.6, 1),
			"value": randi_range(40, 60),
			"AttackKind": "magic",
			"CanAdd": true,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["dmzhl"] = {"power": 300, "hurtBack": [-8, 0], "attackKind": "magic"}
	self.obj_attack_dict["dmgz"] = {"power": 400, "hurtBack": [0, -7], "attackKind": "magic"}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	skill_1_cd = 0
	monster_57()


func ai_think():
	change_properies()
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if skill_1_cd <= 0:
				use_skill()
			elif follow_hero():
				have_target()
			elif count % attack_in == 0:
				attack_target()
			else:
				normal_state()


func normal_hit():
	super.to_hero()
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func use_skill():
	super.to_hero()
	skill_1_cd = randi_range(10, 14)
	hit_name = "dmzhl"
	velocity.x = 0
	is_attacking = true
	mr_player.play("dmzhl")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func change_properies():
	if hp >= max_hp * 0.8 and hp <= max_hp:
		attack_in = 180
		round_speed = 230
		round_chase_time = 2.3
		round_throw_count = 2
	elif hp >= max_hp * 0.6 and hp <= max_hp * 0.8:
		attack_in = 150
		round_speed = 260
		round_chase_time = 2.6
		round_throw_count = 3
	elif hp >= max_hp * 0.4 and hp <= max_hp * 0.6:
		attack_in = 120
		round_speed = 300
		round_chase_time = 3
		round_throw_count = 3
	elif hp >= max_hp * 0.2 and hp <= max_hp * 0.4:
		attack_in = 100
		round_speed = 300
		round_chase_time = 4
		round_throw_count = 4
	elif hp >= 0 and hp <= max_hp * 0.2:
		attack_in = 100
		round_speed = 300
		round_chase_time = 5
		round_throw_count = 5


func call_round():
	var round_position_list = []
	var tween = get_tree().create_tween().set_parallel(true)
	for i in range(round_throw_count):
		var round = Global.add_bullet(
			"Monster57Bullet", bullet, false, 1, position, "dmzhl", self.obj_attack_dict["dmzhl"]
		)
		round_list.push_back(round)
	for i in round_list:
		if i != null:
			var pp = Vector2(
				RoleProp.get_nearest_monster_target_position(global_position).x + randi_range(-220, 220), 500
			)
			tween.tween_property(i, "position", pp, 0.35)
	round_list.clear()


func normal_bullet():
	var _bullet
	var bullet_name: String
	var hit_name: String
	var bullet_pos = Vector2(self.position.x, self.position.y + 15)
	var rnd_num = randi_range(0, 100)
	if rnd_num <= 100 and rnd_num >= 75:
		bullet_name = "Monster57Bullet"
		hit_name = "hit1"
	elif rnd_num < 75 and rnd_num >= 50:
		bullet_name = "Monster57Bullet2"
		hit_name = "hit1_1"
	elif rnd_num < 50 and rnd_num >= 25:
		bullet_name = "Monster57Bullet3"
		hit_name = "hit1_2"
	else:
		bullet_name = "Monster57Bullet4"
		hit_name = "hit1_3"
	if monster_direction:
		_bullet = Global.call_chase_bullet(
			self.bullet,
			bullet_name,
			round_speed,
			round_chase_time,
			false,
			bullet_pos,
			hit_name,
			self.obj_attack_dict[hit_name]
		)
	else:
		_bullet = Global.call_chase_bullet(
			self.bullet,
			bullet_name,
			round_speed,
			round_chase_time,
			false,
			bullet_pos,
			hit_name,
			self.obj_attack_dict[hit_name]
		)
	_bullet.scale = Vector2(0.5, 0.5)


func call_monster():
	if get_parent().get_parent() is Level21:
		if boss_2 == null:
			boss_2 = Global.create_monster(55, get_parent(), Vector2(1450, 320)) as Monster55
			var base_level = get_parent().get_parent() as BaseLevel
	elif get_parent().get_parent() is LevelZLDHDGQ:
		if boss_2 == null:
			boss_2 = Global.create_monster(55, get_parent(), Vector2(750, 320)) as Monster55
			var base_level = get_parent().get_parent() as BaseLevel

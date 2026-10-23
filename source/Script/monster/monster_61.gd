extends BaseMonster

var should_fly: bool
var is_call: bool
var onset_eatblood: bool
var remove_blood: bool

var max_summon_count: int = 5
var current_summon_count: int = 0


func monster_61():
	self.rush_speed = 400
	self.is_boss = true
	self.my_mr_name = "五毒·五官王"
	self.attack_in = 90
	self.level = RoleProp.baseroleprop.Level
	self.max_hp = 160000 + int(RoleProp.baseroleprop.Level * 10000)
	self.hp = self.max_hp
	self.def = 130 + int(RoleProp.baseroleprop.Level * 3)
	self.mdef = 130 + int(RoleProp.baseroleprop.Level * 3)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 0.7)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.3)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 1.5)
	self.htarget = 0
	self.toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 0.6)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 0.6)
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 500
	self.attack_range = 300
	self.attack_desire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.ebol = 0

	self.obj_attack_dict["hit1"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 9),
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 500 + int(RoleProp.baseroleprop.Level * 13),
		"hurtBack": [-6, -10],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "MagicDrain",
			"AddTime": 3.0,
			"reduce_interval": 1.0,
			"value": 0,
			"CanAdd": false,
			"AttackKind": "control"
		}
	}

	self.obj_attack_dict["hit3"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
	}

	self.obj_attack_dict["hit4"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 11),
		"hurtBack": [30, -10],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 3,
			"reduce_interval": 1,
			"value": 400,
			"CanAdd": true,
			"AttackKind": "real",
		}
	}

	self.fall_pro = 0.15
	self.fall_list = [
		{"name": "szyj", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_61()
	skill_1_cd = 2
	skill_2_cd = 5
	skill_3_cd = 8
	skill_4_cd = 10


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
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()

			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()


func do_hit_1():
	if skill_1_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_1_cd = 2
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(15, 20)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	if skill_3_cd > 0 or is_attacking:
		return
	if get_current_summon_count() >= max_summon_count:
		return
	super.to_hero()
	skill_3_cd = randi_range(25, 30)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished

	var count_to_summon = randi_range(1, 3)
	for i in range(count_to_summon):
		if get_current_summon_count() >= max_summon_count:
			break
		_summon_monster_62()

	is_attacking = false
	stop_move()


func do_hit_4():
	super.to_hero()
	skill_4_cd = 20
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func get_current_summon_count() -> int:
	var count = 0
	var parent = get_parent()
	if parent == null:
		return 0
	for child in parent.get_children():
		if child is Monster62:
			count += 1
	return count


func _summon_monster_62():
	var offset_x = randf_range(-200.0, 500.0)
	var summon_pos = Vector2(position.x + offset_x, position.y)
	var summoned = Global.create_monster(62, get_parent(), summon_pos)
	if summoned != null:
		summoned.direction = self.direction


func call_bullet_1():
	var po: Vector2
	if monster_direction:
		po = Vector2(50, 50)
	else:
		po = Vector2(-50, 50)
	var child = Global.add_bullet(
		"Monster61WGW", bullet, monster_direction, 1, position + po, "hit1", self.obj_attack_dict["hit1"]
	)


func call_bullet_2():
	var base_dir = monster_direction
	var forward_dist = 200
	var base_offset = Vector2(forward_dist, 0) if base_dir else Vector2(-forward_dist, 0)

	var positions = [Vector2(-60, 20), Vector2(0, 0), Vector2(50, -30)]

	var base_angles = [15, 0, -15]

	for i in range(3):
		var pos_offset = positions[i]

		if not base_dir:
			pos_offset.x = -pos_offset.x
		var spawn_pos = position + base_offset + pos_offset

		var angle = base_angles[i]
		if not base_dir:
			angle = -angle
		var rad = deg_to_rad(angle)

		var bullet = Global.add_bullet(
			"Monster61Bullet2", get_parent(), base_dir, 1.3, spawn_pos, "hit2", obj_attack_dict["hit2"]
		)
		if bullet:
			bullet.rotation = rad


func call_bullet_3():
	var po: Vector2
	if monster_direction:
		po = Vector2(300, 0)
	else:
		po = Vector2(-300, 0)
	var child = Global.add_bullet(
		"Monster61Bullet3", bullet, monster_direction, 1, position + po, "hit4", self.obj_attack_dict["hit4"]
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

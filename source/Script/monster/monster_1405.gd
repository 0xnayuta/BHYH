extends BaseMonster

var should_fly: bool
var is_call: bool
var onset_eatblood: bool
var remove_blood: bool


func monster_1405():
	self.rush_speed = 520
	self.is_boss = true
	self.my_mr_name = "魔王吕岳"
	self.attack_in = 115
	self.level = 57
	self.max_hp = 1300000
	self.hp = self.max_hp
	self.def = 540
	self.mdef = 540
	self.crit = 28
	self.miss = 40
	self.lucky = 65
	self.htarget = 90
	self.toughness = 25
	self.ar = 100
	self.sp = 100
	self.crit_reduce = 15
	self.speed = 16
	self.mysee = 500
	self.attack_range = 350
	self.attack_desire = 95
	self.behit_calmtime = 0.1
	self.self_rhp = 3000
	self.add_exp = 4500
	self.fall_coin = 1800
	self.ebol = 0

	self.obj_attack_dict["hit1"] = {
		"power": 750,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 700,
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
		"power": 400,
		"hurtBack": [-6, -10],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 3,
			"reduce_interval": 1,
			"value": 300,
			"CanAdd": true,
			"AttackKind": "real",
		}
	}

	self.obj_attack_dict["hit4"] = {
		"power": 400,
		"hurtBack": [-6, -10],
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

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "slshgzzs", "value": 1},
		{"name": "slfmzzzs", "value": 1},
		{"name": "slhlqzzs", "value": 1},
		{"name": "slxjczzs", "value": 1},
		{"name": "sllypzzs", "value": 1},
		{"name": "240007005zzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_1405()

	skill_1_cd = 2
	skill_2_cd = 8
	skill_3_cd = 6
	skill_4_cd = 15


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
	skill_2_cd = randi_range(20, 25)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(15, 20)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	super.to_hero()
	skill_4_cd = randi_range(25, 30)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_2():
	var position_list1 = [Vector2(position.x, position.y - 200)]
	var position_list2 = [Vector2(position.x - 200, position.y - 200), Vector2(position.x + 200, position.y - 200)]

	var player = get_player if get_player else null

	for i in position_list1:
		var bullet = Global.add_bullet(
			"Monster1405Bullet2", self.bullet, false, 1, i, "hit2", self.obj_attack_dict["hit2"]
		)
		if bullet and player:
			await get_tree().create_timer(0.6, false).timeout
			bullet.look_at(player.position)

	for i in position_list2:
		var bullet = Global.add_bullet(
			"Monster1405Bullet2", self.bullet, false, 1, i, "hit2", self.obj_attack_dict["hit2"]
		)
		if bullet and player:
			await get_tree().create_timer(0.6, false).timeout
			bullet.look_at(player.position)


func call_bullet_3():
	var position_list1 = [Vector2(position.x, position.y - 20), Vector2(position.x, position.y + 20)]
	var position_list2 = [Vector2(position.x, position.y - 40), Vector2(position.x, position.y + 40)]
	var position_list3 = [Vector2(position.x, position.y - 60), Vector2(position.x, position.y + 60)]
	var position_list4 = [Vector2(position.x, position.y - 80), Vector2(position.x, position.y + 80)]

	var player = get_player if get_player else null

	for i in position_list1:
		var bullet = Global.add_bullet(
			"Monster1405Bullet3", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"]
		)
		if bullet and player:
			bullet.look_at(player.position)
	await get_tree().create_timer(0.2, false).timeout

	for i in position_list2:
		var bullet = Global.add_bullet(
			"Monster1405Bullet3", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"]
		)
		if bullet and player:
			bullet.look_at(player.position)
	await get_tree().create_timer(0.2, false).timeout

	for i in position_list3:
		var bullet = Global.add_bullet(
			"Monster1405Bullet3", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"]
		)
		if bullet and player:
			bullet.look_at(player.position)
	await get_tree().create_timer(0.2, false).timeout

	for i in position_list4:
		var bullet = Global.add_bullet(
			"Monster1405Bullet3", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"]
		)
		if bullet and player:
			bullet.look_at(player.position)
	await get_tree().create_timer(0.2, false).timeout


func add_fire():
	Global.add_bullet("Monster1405Bullet4", self, false, 1, Vector2(-20, -50), "hit4", self.obj_attack_dict["hit4"])

	var player = RoleProp.source_player
	var stun_effect = {
		"Name": "DeadLink",
		"AddTime": 7,
		"reduce_interval": 0,
		"value": 0,
		"DeBuff": true,
		"AttackKind": "",
	}

	Global.add_buff(player.buff, stun_effect)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

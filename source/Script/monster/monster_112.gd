extends BaseMonster
var blink_count: int = randi_range(80, 120)


func monster_112():
	self.is_boss = true
	self.my_mr_name = "太白金星"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 300000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 35
	self.sp = 35
	self.crit_reduce = 0
	self.speed = 14
	self.mysee = 500
	self.attack_range = 235
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 300
	self.fall_coin = 335
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-5, -9],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 1500,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Immobilize",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 1500,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "qlgzzs", "value": 1},
		{"name": "plzzzs", "value": 1},
		{"name": "ylfzzs", "value": 1},
		{"name": "jlczzs", "value": 1},
		{"name": "tlqzzs", "value": 1},
		{"name": "230007004zzs", "value": 1},
	]

	enable_treasure_box = true
	treasure_box_item = "tbjxbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_112()
	skill_1_cd = randi_range(4, 7)
	skill_2_cd = randi_range(6, 8)
	skill_3_cd = randi_range(10, 15)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	blink_count -= 1
	if blink_count <= 0:
		movetoplayer()
		blink_count = randi_range(80, 120)


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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 560:
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
					if skill_3_cd <= 0:
						do_hit_3()
			else:
				stop_move()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_1_cd <= 0:
					do_hit_1()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(7, 10)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(6, 8)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_1():
	if self.monster_direction:
		Global.add_bullet(
			"Monster112Bullet1",
			self.bullet,
			monster_direction,
			1,
			Vector2(25, 0) + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)
	else:
		Global.add_bullet(
			"Monster112Bullet1",
			self.bullet,
			monster_direction,
			1,
			Vector2(-25, 0) + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)


func call_bullet_2():
	if self.monster_direction:
		Global.add_bullet(
			"Monster112Bullet2",
			self.bullet,
			monster_direction,
			1,
			Vector2(70, 0) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		Global.add_bullet(
			"Monster112Bullet2",
			self.bullet,
			monster_direction,
			1,
			Vector2(-70, 0) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)


func call_bullet_3():
	var position_list1 = [Vector2(position.x + 150, 0), Vector2(position.x + 0, 100), Vector2(position.x - 150, 0)]
	var position_list2 = [Vector2(position.x + 300, 100), Vector2(position.x - 300, 100)]
	var position_list3 = [Vector2(position.x + 450, 200), Vector2(position.x - 450, 200)]
	var position_list4 = [Vector2(position.x + 600, 0), Vector2(position.x - 600, 0)]
	for i in position_list1:
		Global.add_bullet("Monster112Bullet3", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"])
	await get_tree().create_timer(0.2, false).timeout
	for i in position_list2:
		Global.add_bullet("Monster112Bullet3", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"])
	await get_tree().create_timer(0.2, false).timeout
	for i in position_list3:
		Global.add_bullet("Monster112Bullet3", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"])
	await get_tree().create_timer(0.2, false).timeout
	for i in position_list4:
		Global.add_bullet("Monster112Bullet3", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"])
	await get_tree().create_timer(0.2, false).timeout

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

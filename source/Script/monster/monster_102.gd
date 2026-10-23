extends BaseMonster
class_name Monster102
var my_child: MonsterBullet


func monster_101():
	self.is_boss = true
	self.my_mr_name = "哪吒"
	self.attack_in = 60
	self.level = 40
	self.max_hp = 150000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 50
	self.miss = 25
	self.lucky = 115
	self.htarget = 35
	self.toughness = 0
	self.ar = 30
	self.sp = 30
	self.crit_reduce = 0
	self.speed = 16
	self.mysee = 500
	self.attack_range = 245
	self.attack_desire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 120
	self.fall_coin = 155
	self.obj_attack_dict["hit1"] = {
		"power": 350,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 405,
		"hurtBack": [-20, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.4,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit3"] = {
		"power": 650,
		"hurtBack": [-18, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 400,
			"AttackKind": "real",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "",
		"HitProtect": 0,
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "rls", "value": 1},
		{"name": "ryzzs", "value": 1},
		{"name": "tszzs", "value": 1},
		{"name": "230007003zzs", "value": 1},
		{"name": "231007003zzs", "value": 1},
	]

	enable_treasure_box = true
	treasure_box_item = "nzbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_101()
	skill_1_cd = randi_range(3, 5)
	skill_2_cd = randi_range(5, 8)
	skill_3_cd = randi_range(0, 6)


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
				if skill_3_cd <= 0:
					do_hit_3()
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 560:
					if skill_2_cd <= 0:
						do_hit_2()
			else:
				stop_move()
				if skill_3_cd <= 0:
					do_hit_3()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif skill_1_cd <= 0:
					do_hit_1()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(6, 7)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(11, 13)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(20, 25)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_1():
	var bullet_node
	if self.monster_direction:
		bullet_node = Global.add_bullet(
			"Monster102Bullet", self.bullet, false, 0.6, Vector2(50, 0) + position, "hit2", self.obj_attack_dict["hit2"]
		)
	else:
		bullet_node = Global.add_bullet(
			"Monster102Bullet",
			self.bullet,
			false,
			0.6,
			Vector2(-50, 0) + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)
	bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func call_bullet_2():
	var bullet_node
	var bullet_list = []
	if self.monster_direction:
		bullet_list = [Vector2(0, 0), Vector2(50, 0)]
	else:
		bullet_list = [Vector2(0, 0), Vector2(-50, 0)]
	for i in bullet_list:
		bullet_node = Global.add_bullet(
			"Monster102Bullet1", self.bullet, false, 1, i + position, "hit3", self.obj_attack_dict["hit3"]
		)
		bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))
		await get_tree().create_timer(0.2, false).timeout


func call_bullet_3():
	my_child = Global.add_bullet(
		"Monster102Bullet2", self, false, 1, Vector2(0, 0), "hit3", self.obj_attack_dict["hit3"]
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

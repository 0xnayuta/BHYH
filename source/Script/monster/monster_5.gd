extends BaseMonster
class_name Monster5


func monster_5():
	self.is_boss = true
	self.my_mr_name = "禺狨王"
	self.attack_in = 120
	self.level = 13
	self.max_hp = 1200
	self.hp = self.max_hp
	self.def = 50
	self.mdef = 80
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 400
	self.attack_range = 180
	self.attack_desire = 80
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 80
	self.fall_coin = 30
	self.obj_attack_dict["hit1"] = {
		"power": 55,
		"hurtBack": [-8, -15],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.35,
			"CanAdd": false,
			"DeBuff": true,
			"AttackKind": "",
		},
		"HitProtect": 8,
	}
	self.obj_attack_dict["yyzl"] = {
		"power": 75,
		"hurtBack": [5, -15],
		"attackKind": "magic",
		"HitProtect": 18,
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "dsqz", "value": 0},
		{"name": "dsyj", "value": 0},
		{"name": "jmc", "value": 0},
		{"name": "zhj", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "yrwbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_5()
	skill_1_cd = 0
	MonsterBullet.warm_monster5_stream_images()


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
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 900:
						do_hit_2()
					else:
						have_target()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				elif count % 60 == 0:
					attack_target()
				else:
					stop_move()


func do_hit_2():
	skill_1_cd = 15
	hit_name = "yyzl"
	velocity.x = 0
	is_attacking = true
	mr_player.play("yyzl")
	await mr_player.animation_finished
	is_attacking = false


func call_yyzl():
	var po = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 500)
	await get_tree().create_timer(1, false).timeout
	MonsterBullet.wait_for_monster5_stream_images()
	if not is_inside_tree() or is_queued_for_deletion():
		return
	var ly = Global.add_bullet("Monster5Bullet", self.bullet, false, 1, po, "yyzl", self.obj_attack_dict["yyzl"])
	ly.scale = Vector2(0.57, 0.7)

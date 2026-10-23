extends BaseMonster


func monster_137():
	self.is_fly = true
	self.is_boss = true
	self.my_mr_name = "持国天王"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 110000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 25
	self.sp = 25
	self.crit_reduce = 0
	self.speed = 13
	self.mysee = 500
	self.attack_range = 145
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 135
	self.obj_attack_dict["hit1"] = {
		"power": 300,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "silent",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.obj_attack_dict["hit2"] = {
		"power": 350,
		"hurtBack": [-2, -4],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 4,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanAdd": false,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "tdlzjzzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_137()


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
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(10, 12)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_summon():
	Global.create_monster(136, get_parent(), RoleProp.get_nearest_monster_target_position(global_position))
	var bullet_spawn_positions = [
		RoleProp.get_nearest_monster_target_position(global_position) + Vector2(-100, -100),
		RoleProp.get_nearest_monster_target_position(global_position) + Vector2(0, -100),
		RoleProp.get_nearest_monster_target_position(global_position) + Vector2(100, -100)
	]
	for i in bullet_spawn_positions:
		Global.add_bullet("Monster137Bullet1", self.bullet, false, 1, i, "hit2", self.obj_attack_dict["hit2"])

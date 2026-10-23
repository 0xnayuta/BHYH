extends BaseMonster

var cure_bl: float = 1


func monster_119():
	self.is_fly = false
	self.is_boss = false
	self.my_mr_name = "噩梦炼气师"
	self.attack_in = 30
	self.level = 55
	self.max_hp = 45000
	self.hp = self.max_hp
	self.def = 355
	self.mdef = 365
	self.crit = 28
	self.miss = 28
	self.lucky = 40
	self.htarget = 0
	self.toughness = 35
	self.ar = 65
	self.sp = 65
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 600
	self.attack_range = 135
	self.attack_desire = 85
	self.behit_calmtime = 0.4
	self.self_rhp = 0
	self.add_exp = 100
	self.fall_coin = 30
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 15,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 800,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0,
			"CanAdd": false,
			"CanRemove": false,
			"AttackKind": "",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_119()
	skill_1_cd = 6
	skill_2_cd = 8


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


func ai_think():
	if is_death:
		return

	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_1_cd <= 0:
					do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
					if skill_2_cd <= 0:
						do_hit_3()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				elif skill_2_cd <= 0:
					do_hit_3()
				elif count % 60 == 0:
					var rad = randi_range(0, 100)
					if rad <= attack_desire:
						attack_target()
				else:
					stop_move()


func do_hit_2():
	skill_1_cd = 6
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 8
	velocity.x = 0
	hit_name = "hit1"
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false


func strength_self():
	for i in obj_attack_dict:
		if obj_attack_dict[i].has("power"):
			obj_attack_dict[i].power *= 1.2
	cure_bl += 0.5
	def += 10
	mdef += 10


func _on_hit_box_area_exited(_area: Area2D) -> void:
	super._on_hit_box_area_entered(_area)
	if hit_name == "hit2":
		cure_hp(max_hp * 0.1 * cure_bl)

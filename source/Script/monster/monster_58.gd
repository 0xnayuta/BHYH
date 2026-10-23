extends BaseMonster
var round_num


func monster_58():
	self.is_boss = false
	self.my_mr_name = "勾魂使者"
	self.attack_in = 0
	self.level = 30
	self.max_hp = 5000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 100
	self.crit = 10
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 8
	self.mysee = 500
	self.attack_range = 80
	self.attack_desire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 90
	self.fall_coin = 50
	self.obj_attack_dict["hit1"] = {
		"power": 180,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
	}
	self.obj_attack_dict["dmghr"] = {
		"power": 60,
		"hurtBack": [-1, 0],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 3,
			"reduce_interval": 0.5,
			"value": 10,
			"CanAdd": true,
			"DeBuff": true,
			"AttackKind": "real",
		}
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_58()
	skill_1_cd = 0


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
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 320:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				else:
					if count % 90 == 0:
						attack_target()
					else:
						stop_move()


func do_hit_2():
	skill_1_cd = 4
	hit_name = "dmghr"
	velocity.x = 0
	is_attacking = true
	mr_player.play("dmghr")
	await mr_player.animation_finished
	is_attacking = false


func call_round():
	var pp = Vector2(self.position.x, self.position.y)
	var tween = get_tree().create_tween()
	round_num = Global.add_bullet("Monster58Bullet", bullet, false, 1, pp, "dmghr", self.obj_attack_dict["dmghr"])
	tween.tween_property(round_num, "position", setposition(), 0.5)
	await get_tree().create_timer(2.5, false).timeout
	_return_to_spawn()


func _return_to_spawn():
	if round_num != null:
		var tween = get_tree().create_tween()
		var pp = Vector2(self.position.x, self.position.y)
		tween.tween_property(round_num, "position", pp, 0.3)
		await get_tree().create_timer(0.28, false).timeout
		round_num.queue_free()


func setposition():
	return Vector2(
		RoleProp.get_nearest_monster_target_position(global_position).x,
		RoleProp.get_nearest_monster_target_position(global_position).y
	)

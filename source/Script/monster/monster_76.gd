extends BaseMonster
var round_num


func monster_76():
	self.is_boss = false
	self.my_mr_name = "巫鹰"
	self.attack_in = 15
	self.level = 35
	self.max_hp = 5000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 18
	self.miss = 8
	self.lucky = 0
	self.htarget = 0
	self.toughness = 20
	self.ar = 25
	self.sp = 25
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 400
	self.attack_range = 350
	self.attack_desire = 90
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 110
	self.fall_coin = 70
	self.obj_attack_dict["hit1"] = {
		"power": 200,
		"hurtBack": [-7, -9],
		"attackKind": "physics",
	}
	self.obj_attack_dict["hit2"] = {
		"power": 180,
		"hurtBack": [-7, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 2,
			"reduce_interval": 0,
			"CanAdd": false,
			"DeBuff": true,
			"value": 0.3,
			"AttackKind": "",
		}
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.1
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_76()
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
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if skill_1_cd <= 0:
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
						do_hit_2()
					else:
						have_target()
				else:
					if count % 60 == 0:
						attack_target()
					else:
						stop_move()


func do_hit_2():
	to_hero()
	skill_1_cd = 8
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false


func call_round():
	var pp = Vector2(self.position.x, self.position.y)
	var tween = get_tree().create_tween()
	round_num = Global.add_bullet("Monster76Bullet2", bullet, false, 1, pp, "hit2", self.obj_attack_dict["hit2"])
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


func call_knife():
	var po: Vector2
	if monster_direction:
		po = Vector2(70, -20)
	else:
		po = Vector2(-70, -20)
	Global.add_bullet(
		"Monster76Bullet1", bullet, monster_direction, 1, position + po, "hit1", self.obj_attack_dict["hit1"]
	)

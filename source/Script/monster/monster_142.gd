extends BaseMonster
class_name Monster142
var is_sky = false
var round_list = []


func monster_142():
	self.rush_speed = 400
	self.is_boss = true
	self.my_mr_name = "遮迦越罗"
	self.attack_in = 90
	self.level = 55
	self.max_hp = 500000
	self.hp = self.max_hp
	self.def = 400
	self.mdef = 400
	self.crit = 30
	self.miss = 20
	self.lucky = 20
	self.htarget = 25
	self.toughness = 0
	self.ar = 60
	self.sp = 60
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 500
	self.attack_range = 160
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 500
	self.ebol = 0
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 1500,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	self.obj_attack_dict["hit3"] = {
		"power": 650,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 20,
			"reduce_interval": 0,
			"value": 1,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 600,
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.obj_attack_dict["hit5"] = {
		"power": 1500,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	self.obj_attack_dict["hit6"] = {
		"power": 600,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 0,
	}
	self.fall_pro = 0.5
	self.fall_list = [{"name": "zlwdahsp3", "value": 1}]
	self.fall_stone_pro = 0.2
	self.fall_stone = [{"name": "zlwdahzzs", "value": 1}]


func _ready() -> void:
	super._ready()
	monster_142()
	skill_1_cd = 2
	skill_2_cd = 5
	skill_3_cd = 7
	skill_4_cd = 9
	skill_5_cd = 11


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_sky == true:
		gravity = 0
		velocity.y = 0
	else:
		gravity = -980.0


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if skill_4_cd <= 0:
					do_hit_4()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_5_cd <= 0:
					do_hit_5()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()
				if skill_5_cd <= 0:
					do_hit_5()


func do_hit_1():
	super.to_hero()
	skill_1_cd = 2
	velocity.x = 0
	hit_name = "hit1"
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = 15
	velocity.x = 0
	hit_name = "hit2"
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = 17
	velocity.x = 0
	hit_name = "hit3"
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	super.to_hero()
	skill_4_cd = 13
	velocity.x = 0
	hit_name = "hit6"
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_5():
	super.to_hero()
	skill_5_cd = 20
	velocity.x = 0
	hit_name = "hit5"
	is_attacking = true
	mr_player.play("hit5")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func tween_to_top():
	if _movement_command_is_blocked():
		return
	should_in_sky = true
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Vector2(0, -250) + position, 0.2)


func tween_to_top_2():
	if _movement_command_is_blocked():
		return
	should_in_sky = true
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Vector2(position.x, 100), 1)


func drop():
	should_in_sky = false


func call_bullet_1():
	var round_num = Global.add_bullet(
		"Monster142Bullet1", self.bullet, false, 1, position, "hit1", self.obj_attack_dict["hit1"]
	)
	var tween = create_tween()
	tween.tween_property(round_num, "position", RoleProp.source_player.position, 0.5)


func call_bullet_3():
	var bullet_spawn_positions = [
		Vector2(-400 + position.x, 470),
		Vector2(-300 + position.x, 470),
		Vector2(-200 + position.x, 470),
		Vector2(-100 + position.x, 470),
		Vector2(position.x, 470),
		Vector2(100 + position.x, 470),
		Vector2(200 + position.x, 470),
		Vector2(300 + position.x, 470),
		Vector2(400 + position.x, 470)
	]
	for i in bullet_spawn_positions:
		Global.add_bullet("Monster56Bullet", self.bullet, false, 1, i, "hit3", self.obj_attack_dict["hit3"])


func call_bullet_4():
	var max_count: int = 10
	var target_count: int = 0
	var tween = create_tween().set_parallel(true)
	var bullet_spawn_positions = []
	while target_count < max_count:
		var new_rotation = 360 / max_count
		new_rotation = new_rotation * target_count
		var stab_position = Vector2(
			self.position.x + sin(float(new_rotation) * PI / 180) * 150,
			self.position.y - 15 - cos(float(new_rotation) * PI / 180) * 150
		)
		bullet_spawn_positions.push_back(stab_position)
		target_count += 1
	if not monster_direction:
		bullet_spawn_positions.reverse()
	for i in bullet_spawn_positions:
		var stab = Global.add_bullet(
			"Monster142Bullet2", self.bullet, false, 1, i, "hit4", self.obj_attack_dict["hit4"]
		)
		await get_tree().create_timer(0.2, false).timeout


func call_bullet_5():
	var bullet_spawn_positions = [
		Vector2(-400 + position.x, 450),
		Vector2(-300 + position.x, 450),
		Vector2(-200 + position.x, 450),
		Vector2(-100 + position.x, 450),
		Vector2(position.x, 450),
		Vector2(100 + position.x, 450),
		Vector2(200 + position.x, 450),
		Vector2(300 + position.x, 450),
		Vector2(400 + position.x, 450),
		Vector2(500 + position.x, 450)
	]
	randomize()
	var count_time = bullet_spawn_positions.size() * 0.1
	bullet_spawn_positions.shuffle()
	for i in bullet_spawn_positions:
		var round_num = Global.add_bullet(
			"Monster55Bullet", self.bullet, false, 1, position, "hit5", self.obj_attack_dict["hit5"]
		)
		round_list.push_back(round_num)
		var tween = create_tween()
		tween.tween_property(round_num, "position", i, 1)
		await get_tree().create_timer(0.1, false).timeout
	await get_tree().create_timer(2, false).timeout
	for i in round_list:
		if i != null:
			var tween = create_tween()
			tween.tween_property(i, "position", self.position, 1)
	await get_tree().create_timer(count_time, false).timeout
	for i in round_list:
		i.queue_free()
	round_list.clear()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

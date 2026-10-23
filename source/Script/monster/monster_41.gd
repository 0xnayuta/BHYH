extends BaseMonster
const Level15 := preload("res://Script/level/level_15.gd")
var already_use_mrsp = false
var is_speed_up = false
var _count: int = 0
var is_need_run = false
var need_left = false
var need_right = false
var _get_parent


func monster_41():
	self.is_boss = true
	self.my_mr_name = "判官"
	self.attack_in = 15
	self.level = 27
	self.max_hp = 20000
	self.hp = self.max_hp
	self.def = 120
	self.mdef = 120
	self.crit = 0
	self.miss = 25
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 8
	self.mysee = 600
	self.attack_range = 800
	self.attack_desire = 60
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 270,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Fire",
			"CanAdd": true,
			"AddTime": 2,
			"DeBuff": true,
			"reduce_interval": 1,
			"value": int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "real",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "lcld", "value": 0},
		{"name": "tsyp", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "pgbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	_get_parent = get_parent().get_parent()
	monster_41()
	skill_1_cd = 0
	skill_2_cd = 0


func ai_think():
	_count += 1
	if is_speed_up:
		self.speed = 100
		if _count % 30 == 0:
			add_speed_up_specialbullet()
	else:
		self.speed = init_speed
	if not already_use_mrsp:
		do_hit_2()
	else:
		if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
			has_target = true
		if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
			if has_target == false:
				normal_state()
			else:
				if not is_need_run:
					if skill_1_cd <= 0:
						do_hit_3()
					elif (
						abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) < 300
						and not is_need_run
					):
						if (
							position.x > RoleProp.get_nearest_monster_target_position(global_position).x
							or self.position.x <= 3430
						):
							need_right = true
						elif (
							position.x <= RoleProp.get_nearest_monster_target_position(global_position).x
							or self.position.x >= 4500
						):
							need_left = true
						is_need_run = true
						$Run.wait_time = 2
						$Run.start()
					elif (
						abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range
					):
						have_target()
					else:
						if skill_2_cd <= 0 and skill_1_cd > 0:
							do_hit_4()
						else:
							stop_move()
				else:
					if skill_1_cd <= 0:
						do_hit_3()
					elif skill_2_cd <= 0 and skill_1_cd > 0:
						do_hit_4()
					else:
						if need_left:
							move_left()
						elif need_right:
							move_right()


func do_hit_2():
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("mrsp")
	await mr_player.animation_finished
	already_use_mrsp = true
	if _get_parent is Level15:
		_get_parent.add_ini()
	is_attacking = false


func do_hit_3():
	skill_1_cd = 22
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("jx")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_4():
	super.to_hero()
	skill_2_cd = 5
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false


func call_speed_up():
	is_speed_up = true
	self.miss = 35
	$SpeedUp.wait_time = randi_range(12, 16)
	$SpeedUp.start()


func _on_speed_up_timeout() -> void:
	self.miss = 25
	is_speed_up = false
	$SpeedUp.stop()


func add_speed_up_specialbullet():
	if self.monster_direction:
		Global.add_special_effect(self, Vector2(0, 55), "speed_up", Vector2(1, 1), true, 1)
	else:
		Global.add_special_effect(self, Vector2(0, 55), "speed_up", Vector2(1, 1), true, 1)


func call_fly_bullet():
	if monster_direction:
		Global.call_fly_bullet(
			bullet,
			"Monster41Bullet",
			1,
			Vector2(position.x + 100, position.y),
			800,
			-300,
			"hit1",
			obj_attack_dict["hit1"]
		)
	else:
		var fz = Global.call_fly_bullet(
			bullet,
			"Monster41Bullet",
			1,
			Vector2(position.x - 100, position.y),
			800,
			300,
			"hit1",
			obj_attack_dict["hit1"]
		)
		if fz:
			var sprite = fz.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = true


func _on_run_timeout() -> void:
	is_need_run = false
	need_right = false
	need_left = false

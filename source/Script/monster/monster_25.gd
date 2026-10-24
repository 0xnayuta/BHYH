extends BaseMonster
var is_can_attack
var dir = 1
var is_can_move
enum { move, hit, return_, stop_, _death }
var is_set
var rr_an = randi_range(0, 100)


func monster_25():
	self.cannot_attract = true
	self.is_fly = true
	self.is_boss = false
	self.my_mr_name = "鬼手"
	self.attack_in = 10
	self.level = 25
	self.max_hp = 100
	self.hp = 100
	self.def = 20
	self.mdef = 20
	self.crit = 8
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 7
	self.mysee = 405
	self.attack_range = 175
	self.attack_desire = 75
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 20
	self.fall_coin = 4
	if get_parent().get_parent() is LevelNMGHDGQ:
		self.obj_attack_dict["hit1"] = {"power": 800, "hurtBack": [-4, -9], "attackKind": "physics"}
		self.fall_pro = 0.0
		self.fall_list = []
		self.fall_stone_pro = 0.0
		self.fall_stone = []
		return
	self.obj_attack_dict["hit1"] = {"power": 300, "hurtBack": [-4, -9], "attackKind": "physics"}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0.0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_25()
	hit_name = "hit1"


func ai_think():
	if not is_set:
		monster_25()
		is_set = true
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
			if count % randi_range(90, 120) == 0:
				move_down()
		else:
			if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) > mysee:
				has_target = false
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if count % randi_range(90, 120) == 0:
					move_down()
			else:
				if count % 120 == 0:
					if ran_num <= attack_desire:
						move_down()
				else:
					if ran_num < 30:
						stop_move()
					else:
						if ran_num > 65:
							move_left()
						else:
							move_right()


func normal_state():
	if is_quiescent:
		return
	if is_be_attacking:
		return
	var dir_num: int
	if ran_num <= 50:
		if ran_num < 2:
			stop_move()
		else:
			move_left()
	else:
		if ran_num < 77:
			stop_move()
		else:
			move_right()


func have_target():
	if is_quiescent:
		return
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x + randi_range(25, 85):
		move_right()
	elif RoleProp.get_nearest_monster_target_position(global_position).x < position.x - randi_range(25, 85):
		move_left()


func move_left():
	base_damage_box.scale.x = 1
	velocity.x = -speed * 10
	mr_player.play("Hands")


func move_right():
	base_damage_box.scale.x = -1
	velocity.x = speed * 10
	mr_player.play("Hands")


func move_up():
	is_attacking = true
	mr_player.play("fanhui")
	await mr_player.animation_finished
	is_attacking = false


func move_down():
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	move_up()


func stop_move():
	velocity.x = 0
	mr_player.play("Hands")


func _on_change_dir_timeout() -> void:
	rr_an = randi_range(0, 100)


func reduce_hp(value: int):
	return

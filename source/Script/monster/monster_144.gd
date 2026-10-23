extends BaseMonster
class_name Monster144
var should_chase: bool = false
@onready var normal_walk_timer: Timer = $NormalWalkTimer
@onready var jcqb: RayCast2D = $jcqb
@onready var jumpcd: Timer = $Jumpcd
@onready var qbtimer: Timer = $qbtimer
@onready var can_jumpqb: RayCast2D = $CanJumpqb

enum WangWang { MoveLeft, MoveRight, QBMoveLeft, QBMoveRight, Jump, Smile, Dance, Cry, Wait, NormalWalk, Chase }
var wang_state = WangWang.NormalWalk
var is_jump: bool


func monster_144():
	self.cannot_attract = true
	self.is_boss = false
	self.my_mr_name = "汪汪"
	self.attack_in = 10
	self.level = 1000
	self.max_hp = 1000
	self.hp = self.max_hp
	self.def = 0
	self.mdef = 0
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 13
	self.mysee = 400
	self.attack_range = 200
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 225,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_144()


func ai_think():
	if qb():
		if qbtimer.is_stopped():
			qbtimer.start(3)
		if monster_dir.scale.x == 1:
			wang_state = WangWang.QBMoveRight
		else:
			wang_state = WangWang.QBMoveLeft

	match wang_state:
		WangWang.Wait:
			stop_move()
		WangWang.Dance:
			do_hit_2()
		WangWang.MoveLeft:
			move_left()
		WangWang.MoveRight:
			move_right()
		WangWang.QBMoveLeft:
			move_left()
		WangWang.QBMoveRight:
			move_right()
		WangWang.Jump:
			jump()
		WangWang.Smile:
			attack_target()
		WangWang.Cry:
			do_hit_3()
		WangWang.NormalWalk:
			normal_state()
		WangWang.Chase:
			have_target()


func move_left():
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1
	velocity.x = -speed * 10
	if not is_jump:
		mr_player.play("walk")


func move_right():
	base_damage_box.scale.x = -1
	monster_dir.scale.x = -1
	velocity.x = speed * 10
	if not is_jump:
		mr_player.play("walk")


func have_target():
	if not $RayCast2D.get_collider():
		jump()
	if can_jumpqb.get_collider():
		jump()
	if randi_range(0, 100) < 25 and jumpcd.time_left <= 0:
		jump()
	else:
		if RoleProp.get_nearest_monster_target_position(global_position).x > position.x + randi_range(65, 85):
			move_right()
		elif RoleProp.get_nearest_monster_target_position(global_position).x < position.x - randi_range(65, 85):
			move_left()
		else:
			stop_move()


func jump():
	if jumpcd.time_left <= 0:
		randomize()
		jumpcd.start(randi_range(1, 4))
		is_jump = true
		if monster_dir.scale.x == 1:
			velocity.x = -speed * 18
		else:
			velocity.x = speed * 18
		velocity.y = -randi_range(400, 900)
		mr_player.play("jump")
		await mr_player.animation_finished
	is_jump = false
	wang_state = WangWang.NormalWalk


func normal_state():
	if not $RayCast2D.get_collider():
		jump()
	if can_jumpqb.get_collider():
		jump()
	if randi_range(0, 100) < 25 and jumpcd.time_left <= 0:
		jump()
	else:
		if ran_num < 10:
			stop_move()
		elif ran_num >= 10 and ran_num <= 55:
			move_left()
		else:
			move_right()


func qb():
	return jcqb.get_collider()


func check_hp_ratio(i: float):
	return hp >= max_hp * i


func attack_target():
	super.to_hero()
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("smile")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(12, 14)
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("scary")
	await mr_player.animation_finished
	is_attacking = false
	wang_state = WangWang.NormalWalk


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(16, 18)
	velocity.x = 0
	hit_name = "hit1"
	is_attacking = true
	mr_player.play("dance")
	await mr_player.animation_finished
	is_attacking = false
	wang_state = WangWang.NormalWalk


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(14, 16)
	velocity.x = 0
	hit_name = "hit1"
	is_attacking = true
	mr_player.play("cry")
	await mr_player.animation_finished
	is_attacking = false
	wang_state = WangWang.NormalWalk


func _on_normal_walk_timer_timeout() -> void:
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) > 600:
		if randi_range(0, 100) < 30:
			wang_state = WangWang.Cry
		else:
			wang_state = WangWang.Chase
	else:
		randomize()
		var aa = randi_range(0, 100)
		if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) > 500:
			if aa < 70:
				wang_state = WangWang.NormalWalk
			else:
				wang_state = WangWang.Chase
		else:
			if aa < 70:
				wang_state = WangWang.NormalWalk
			else:
				if aa > 75:
					wang_state = WangWang.Smile
				else:
					wang_state = WangWang.Dance


func _on_qbtimer_timeout() -> void:
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) > 500:
		wang_state = WangWang.Cry
	else:
		randomize()
		var aa = randi_range(0, 100)
		if aa > 30:
			if aa < 50:
				wang_state = WangWang.NormalWalk
			else:
				wang_state = WangWang.Chase
		else:
			if aa < 5:
				wang_state = WangWang.Dance
			else:
				wang_state = WangWang.Smile


func reduce_hp(value: int):
	return


func hurt_reduce_hp(value, target):
	return 0

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

extends BaseMonster
var use_skill_2


func monster_19():
	self.is_fly = true
	self.is_boss = false
	self.my_mr_name = "鲨鱼"
	self.attack_in = 10
	self.level = 100
	self.max_hp = 1000000
	self.hp = self.max_hp
	self.def = 100
	self.mdef = 150
	self.crit = 15
	self.miss = 5
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 300
	self.attack_range = 75
	self.attack_desire = 40
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 500
	self.fall_coin = 200
	self.obj_attack_dict["slj"] = {"power": 260, "hurtBack": [-4, -20], "attackKind": "real"}
	self.obj_attack_dict["sytx"] = {"power": 115, "hurtBack": [-4, -9], "attackKind": "physics"}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "qhs_1", "value": 0},
		{"name": "qhs_2", "value": 0},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	skill_1_cd = 0
	skill_2_cd = 0
	monster_19()


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if (
				skill_1_cd <= 0
				and abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 350
			):
				do_hit_1()
			elif skill_2_cd <= 0:
				do_hit_2()
			else:
				have_target()


func do_hit_1():
	skill_1_cd = randi_range(7, 12)
	hit_name = "slj"
	is_attacking = true
	mr_player.play("slj")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_2():
	use_skill_2 = true
	if self.monster_direction:
		velocity.x += 700
	else:
		velocity.x += -700
	velocity.y = 0
	skill_2_cd = randi_range(6, 15)
	hit_name = "sytx"
	is_attacking = true
	mr_player.play("sytx")
	await mr_player.animation_finished
	is_attacking = false
	use_skill_2 = false


func call_ljf():
	var nearest_pos := RoleProp.get_nearest_monster_target_position(global_position)
	if nearest_pos.x == null or nearest_pos.y == null:
		return
	var first_position := Vector2(float(nearest_pos.x), float(nearest_pos.y) - 50.0)
	var parent_node: Node = get_parent().get_parent() if get_parent() != null else null
	if parent_node != null:
		Global.add_special_effect(parent_node, first_position, "monster19_bullet", Vector2(1, 1), false, 1)
	var xx := first_position + Vector2(0.0, 150.0)
	await get_tree().create_timer(1.7, false).timeout
	Global.add_bullet(
		"monster19_bullet",
		self.bullet,
		self.monster_direction,
		1,
		xx - Vector2(0.0, 125.0),
		"slj",
		self.obj_attack_dict["slj"]
	)


func call_sylj():
	var pp = self.position - Vector2(0, 20)
	Global.add_bullet(
		"Monster19Bullet_1", self.bullet, self.monster_direction, 1, pp, "sytx", self.obj_attack_dict["sytx"]
	)


func have_target():
	if is_quiescent:
		return
	if is_fly:
		mr_player.play("Fly")
		if RoleProp.get_nearest_monster_target_position(global_position).y > position.y + randi_range(125, 245):
			velocity.y = speed * 8
		elif RoleProp.get_nearest_monster_target_position(global_position).y < position.y + randi_range(35, 55):
			velocity.y = -speed * 8
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x + randi_range(65, 85):
		move_right()
	elif RoleProp.get_nearest_monster_target_position(global_position).x < position.x - randi_range(65, 85):
		move_left()


func call_boom():
	var pp = self.position - Vector2(0, 0)
	Global.add_bullet(
		"Monster19Bullet_2", self.bullet, self.monster_direction, 1, pp, "slj", self.obj_attack_dict["slj"]
	)

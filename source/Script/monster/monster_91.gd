extends BaseMonster
var is_fs: bool
var fs: BaseMonster = null
var call_count: int = 0
var bl: float = 1


func monster_91():
	self.rush_speed = 400
	self.is_boss = true
	self.my_mr_name = "袁洪"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 130000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 10
	self.miss = 0
	self.lucky = 0
	self.htarget = 20
	self.toughness = 0
	self.ar = 20
	self.sp = 20
	self.crit_reduce = 0
	self.speed = 9
	self.mysee = 500
	self.attack_range = 165
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 400
	self.obj_attack_dict["hit1"] = {
		"power": 330,
		"hurtBack": [-8, -12],
		"attackKind": "physics",
		"HitProtect": 30,
	}
	self.obj_attack_dict["hit2"] = {
		"power": int(350 * bl),
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.4,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit3"] = {
		"power": 350,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 3,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 0,
		"hurtBack": [-30, -50],
		"attackKind": "real",
		"HitProtect": 50,
	}
	self.obj_attack_dict["hit5"] = {
		"power": int(RoleProp.roleprop.SHp * 10),
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 30,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "zjbtgzzs", "value": 1},
		{"name": "smz", "value": 0},
		{"name": "jllm", "value": 0},
		{"name": "wsjgzzs", "value": 1},
		{"name": "blmqzzs", "value": 1},
	]

	enable_treasure_box = true
	treasure_box_item = "yhbx"

	update_fall_mode()
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_91()
	skill_1_cd = randi_range(3, 4)
	skill_3_cd = 18


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(8, 12)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(8, 12)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(8, 12)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	bl = 1 + float(RoleProp.roleprop.SHp - RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp)
	match self.base_level.current_stage:
		1:
			if position.x <= 0:
				position.x = 50
			if position.x > 1100:
				position.x = 900
		2:
			if position.x <= 0:
				position.x = 50
			if position.x > 2250:
				position.x = 2100
		3:
			if position.x <= 0:
				position.x = 50
			if position.x > 3500:
				position.x = 3400
		4:
			if position.x <= 3500:
				position.x = 3600
			if position.x > 4600:
				position.x = 4500


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if hp <= max_hp * 0.65:
				if not is_fs:
					if fs == null:
						do_hit_3()
						return
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if skill_1_cd <= 0:
					do_hit_1()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 500:
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300:
					if count % 90 == 0:
						if randi_range(0, 100) < attack_desire:
							attack_target()
			else:
				if skill_1_cd <= 0:
					do_hit_1()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
					else:
						stop_move()
				else:
					stop_move()


func to_top():
	if _movement_command_is_blocked():
		return
	var po = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 100)
	if monster_direction:
		po = Vector2(position.x, 100)
	else:
		po = Vector2(position.x, 100)
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", po, 0.5)


func to_drop():
	if _movement_command_is_blocked():
		velocity = Vector2.ZERO
		return
	if monster_direction:
		velocity.x += 1200
	else:
		velocity.x += -1200
	velocity.y += 800


func removeve():
	velocity.x = 0


func add_bullet_2():
	var bullet_spawn_positions
	if monster_direction:
		bullet_spawn_positions = Vector2(25, -30)
	else:
		bullet_spawn_positions = Vector2(-25, -30)
	for i in range(randi_range(3, 5)):
		Global.add_bullet(
			"Monster91Bullet2",
			self.bullet,
			monster_direction,
			1,
			bullet_spawn_positions + position,
			"hit3",
			self.obj_attack_dict["hit3"]
		)
		await get_tree().create_timer(0.1, false).timeout


func add_bullet():
	var bullet_spawn_positions = []
	if monster_direction:
		bullet_spawn_positions = [Vector2(100, 75), Vector2(180, 75), Vector2(260, 75), Vector2(340, 75)]
	else:
		bullet_spawn_positions = [Vector2(-100, 75), Vector2(-180, 75), Vector2(-260, 75), Vector2(-340, 75)]
	for i in bullet_spawn_positions:
		var lt = Global.add_bullet(
			"Monster91Bullet1", self.bullet, monster_direction, 2, i + position, "hit2", self.obj_attack_dict["hit2"]
		)
		lt.scale.y = 1.5
		await get_tree().create_timer(0.1, false).timeout
	pass


func call_self():
	if fs == null:
		fs = Global.create_monster(91, get_parent(), position)
		fs.is_fs = true
		fs.my_mr_name = "袁洪·分身"
		fs.max_hp = int(self.max_hp * 0.5)
		fs.hp = fs.max_hp
		fs.fall_list = []
		fs.fall_pro = 0


func state_death():
	if not is_fs:
		if fs != null:
			fs.hp = -100
	hit_name = "hit5"
	if add_exp > 0 and RoleProp.baseroleprop.Level < 90:
		if PlayerData.player_data["西天王殿"]:
			if RoleProp.baseroleprop.Level < 90:
				RoleProp.baseroleprop.exp += add_exp
				PlayerData.player_data.玩家当前经验 = RoleProp.baseroleprop.exp
		else:
			if RoleProp.baseroleprop.Level < 40:
				RoleProp.baseroleprop.exp += add_exp
				PlayerData.player_data.玩家当前经验 = RoleProp.baseroleprop.exp
		add_exp = 0
	if not _is_tower_drop_context() and fall_coin > 0:
		for i in range(1, 4):
			var pp = position + Vector2(randi_range(-15, 15), randi_range(-15, 15))
			Global.add_aura(get_parent().get_parent().fall_it, pp, fall_coin)
		fall_coin = 0
	velocity.x = 0
	if is_fs:
		mr_player.play("death2")
	else:
		mr_player.play("death")
	if not is_death:
		if PlayerData.player_data.has(my_mr_name):
			var current = PlayerData.player_data[my_mr_name]
			PlayerData.player_data[my_mr_name] += 1
		is_death = true
		await mr_player.animation_finished

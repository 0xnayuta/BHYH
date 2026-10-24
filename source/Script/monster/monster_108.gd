extends BaseMonster
var is_combo: bool


func monster_108():
	self.is_boss = true
	self.my_mr_name = "金角大王"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 300000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 35
	self.sp = 35
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 500
	self.attack_range = 235
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 300
	self.fall_coin = 335
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-5, -9],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 520,
		"hurtBack": [-2, -1],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit3"] = {
		"power": int(1000 + RoleProp.roleprop.SHp * 0.35),
		"hurtBack": [-6, -1],
		"attackKind": "real",
		"HitProtect": 5,
	}
	self.obj_attack_dict["hit4"] = {
		"power": 450,
		"hurtBack": [-2, -9],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 5,
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
		{"name": "yjpyasp", "value": 1},
	]
	self.fall_stone_pro = 0.0
	self.fall_stone = [
		{"name": "ziyanyujin", "value": randi_range(1, 5)},
		{"name": "xianzhilu", "value": 1},
	]


func _ready() -> void:
	super._ready()
	monster_108()
	skill_1_cd = randi_range(4, 7)
	skill_2_cd = randi_range(6, 8)
	skill_3_cd = randi_range(10, 15)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


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
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	is_combo = true
	super.to_hero()
	skill_1_cd = 7
	hit_name = "hit2"
	velocity.x = 0
	velocity.y = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = 15
	hit_name = "hit3"
	velocity.x = 0
	velocity.y = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = 10
	hit_name = "hit4"
	velocity.x = 0
	velocity.y = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func tween_to_player():
	if _movement_command_is_blocked() or get_player == null:
		return
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", RoleProp.get_nearest_monster_target_position(global_position), 0.2)


func tween_to_top():
	if _movement_command_is_blocked():
		return
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Vector2(position.x, -100), 0.4)


func to_drop():
	if _movement_command_is_blocked():
		velocity.y = 0
		return
	velocity.y = 0

	velocity.y = 1600
	pass


func no_combo():
	should_in_sky = false


func _on_hurt_box_area_entered(area: Area2D) -> void:
	should_in_sky = false
	super._on_hurt_box_area_entered(area)


func movetoplayer():
	if _movement_command_is_blocked() or get_player == null:
		return
	self.position.x = RoleProp.get_nearest_monster_target_position(global_position).x


func call_bullet_1():
	var bullet_spawn_positions = [{}]
	if self.monster_direction:
		bullet_spawn_positions = [
			{"position": Vector2(50, 0), "Scale": Vector2(0.5, 0.5)},
			{"position": Vector2(90, 0), "Scale": Vector2(0.7, 0.7)},
			{"position": Vector2(130, 0), "Scale": Vector2(1, 1)}
		]
	else:
		bullet_spawn_positions = [
			{"position": Vector2(-50, 0), "Scale": Vector2(0.5, 0.5)},
			{"position": Vector2(-90, 0), "Scale": Vector2(0.7, 0.7)},
			{"position": Vector2(-130, 0), "Scale": Vector2(1, 1)}
		]
	for i in bullet_spawn_positions:
		var _bullet = Global.add_bullet(
			"Monster108Bullet2", self, monster_direction, 1, i["position"], "hit4", self.obj_attack_dict["hit4"]
		)
		_bullet.scale = i["Scale"]
		await get_tree().create_timer(0.1, false).timeout


func call_bullet_2():
	var _bullet
	if self.monster_direction:
		_bullet = Global.add_bullet(
			"Monster108Bullet1",
			self.bullet,
			false,
			1,
			Vector2(100, 25) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		_bullet = Global.add_bullet(
			"Monster108Bullet1",
			self.bullet,
			false,
			1,
			Vector2(-100, 25) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	_bullet.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func check_player():
	if not is_instance_valid(get_player) or RoleProp == null or not has_method("move_playerto_boss"):
		print("CheckPlayer：依赖节点无效/无位移方法，跳过")
		return

	var buff_target: Node2D = null

	if is_instance_valid(get_player) and get_player is Node2D:
		buff_target = get_player

	if self.position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
		if get_player.player_dir:
			if not monster_direction:
				move_playerto_boss(buff_target, 0.5)
	else:
		if not get_player.player_dir:
			if monster_direction:
				move_playerto_boss(buff_target, 0.5)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

extends BaseMonster
class_name Monster67


func monster_67():
	self.is_boss = true
	self.my_mr_name = "楚江王"
	self.attack_in = 0
	self.level = 35
	self.max_hp = 35000
	self.hp = self.max_hp
	self.def = 130
	self.mdef = 120
	self.crit = 5
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 500
	self.attack_range = 175
	self.attack_desire = 0
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {"power": 150, "hurtBack": [-4, -9], "attackKind": "physics", "HitProtect": 15}
	self.obj_attack_dict["hit2"] = {
		"power": 150,
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 3,
			"reduce_interval": 1,
			"value": 20,
			"DeBuff": true,
			"AttackKind": "real",
			"CanAdd": true,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 160,
		"hurtBack": [-10, -22],
		"attackKind": "magic",
		"HitProtect": 8,
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "dzj", "value": 0},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_67()
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0


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
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if count % 120 == 0:
					attack_target()
			else:
				if skill_2_cd <= 0:
					do_hit_2()
				elif skill_1_cd <= 0:
					do_hit_1()
				elif skill_3_cd <= 0:
					do_hit_3()
				elif count % 60 == 0:
					attack_target()
				else:
					stop_move()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(8, 10)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("cjwlj")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(5, 7)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("szzh")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(12, 16)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("wjl")
	await mr_player.animation_finished
	is_attacking = false


func _on_hit_box_area_exited(_area: Area2D) -> void:
	var xx = 5 * (1 - float(hp) / float(max_hp)) + randi_range(0, 1)
	self.cure_hp(xx * obj_attack_dict[hit_name]["power"])
	super._on_hit_box_area_entered(_area)


func call_bullet():
	var bullet_spawn_positions = []
	if randi_range(0, 100) < 30:
		if not monster_direction:
			bullet_spawn_positions = [
				Vector2(-80, 70),
				Vector2(-180, 70),
				Vector2(-280, 70),
				Vector2(-380, 70),
				Vector2(-480, 70),
				Vector2(-580, 70)
			]
		else:
			bullet_spawn_positions = [
				Vector2(80, 70),
				Vector2(180, 70),
				Vector2(280, 70),
				Vector2(380, 70),
				Vector2(480, 70),
				Vector2(580, 70)
			]
		for i in bullet_spawn_positions:
			Global.add_bullet(
				"Monster67Bullet", self.bullet, monster_direction, 1, i + position, "hit3", self.obj_attack_dict["hit3"]
			)
			await get_tree().create_timer(0.2, false).timeout
	else:
		await get_tree().create_timer(2, false).timeout
		bullet_spawn_positions = [
			Vector2(1050, 510),
			Vector2(1210, 510),
			Vector2(1370, 510),
			Vector2(1530, 510),
			Vector2(1690, 510),
			Vector2(1850, 510)
		]
		for i in bullet_spawn_positions:
			Global.add_bullet(
				"Monster67Bullet", self.bullet, monster_direction, 1, i, "hit3", self.obj_attack_dict["hit3"]
			)
		await get_tree().create_timer(2, false).timeout
		bullet_spawn_positions = [
			Vector2(1110, 510),
			Vector2(1240, 510),
			Vector2(1370, 510),
			Vector2(1500, 510),
			Vector2(1630, 510),
			Vector2(1760, 510),
			Vector2(1890, 510),
			Vector2(2020, 510)
		]
		for i in bullet_spawn_positions:
			Global.add_bullet(
				"Monster67Bullet", self.bullet, monster_direction, 1, i, "hit3", self.obj_attack_dict["hit3"]
			)


func call_sz():
	var sz = Global.create_monster(68, get_parent(), position) as Monster68
	sz.myfather = self

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

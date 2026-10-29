extends SummonBaseMonster

var weapon_level: int = 1
var attribute_scale: float = 0.1

var player_power: int = 0
var damage_ratio: float = 0.3
var damage_scale: float = 1.0

var whs_count: int = 0


func set_weapon_level(level: int, scale: float, damage_scale_: float = 1.0) -> void:
	weapon_level = level
	attribute_scale = scale
	damage_scale = damage_scale_
	damage_ratio = (0.3 + (float(weapon_level) / 10.0) * 0.5) * damage_scale
	initialize_monster_properties()
	setup_skills()
	print(
		(
			"召唤物接收法宝等级: %d, 属性系数: %.1f%%, 伤害倍率: %.1f, 伤害比例: %.1f%%"
			% [weapon_level, attribute_scale * 100, damage_scale, damage_ratio * 100]
		)
	)


func fetch_player_power() -> void:
	if RoleProp and RoleProp.roleprop:
		player_power = RoleProp.roleprop.power
	else:
		var hero: BaseHero = player_reference
		if not is_instance_valid(hero):
			hero = LocalCoop.nearest_player(self.global_position)
		if hero and hero.has_method("get_power"):
			player_power = hero.get_power()
		else:
			player_power = 100
	print("获取到玩家攻击力: %d" % player_power)


func initialize_monster_properties() -> void:
	fetch_player_power()

	var base_hp = 500000
	var base_def = 300
	var base_mdef = 300
	var base_crit = 30
	var base_miss = 20
	var base_lucky = 20

	var scaled_hp = int(base_hp * attribute_scale)
	var scaled_def = int(base_def * attribute_scale)
	var scaled_mdef = int(base_mdef * attribute_scale)
	var scaled_crit = int(base_crit * attribute_scale)
	var scaled_miss = int(base_miss * attribute_scale)
	var scaled_lucky = int(base_lucky * attribute_scale)

	max_hp = scaled_hp
	hp = max_hp

	self.set("rush_speed", 400)
	self.set("is_boss", true)
	self.set("my_mr_name", "牛魔王·魂 (Lv.%d)" % weapon_level)
	self.set("attack_in", 90)
	self.set("level", 55)
	self.set("def", scaled_def)
	self.set("mdef", scaled_mdef)
	self.set("crit", scaled_crit)
	self.set("miss", scaled_miss)
	self.set("lucky", scaled_lucky)
	self.set("htarget", 25)
	self.set("toughness", 0)
	self.set("ar", 0)
	self.set("sp", 0)
	self.set("crit_reduce", 0)
	self.set("speed", 12)
	self.set("behit_calmtime", 0)
	self.set("self_rhp", 0)
	self.set("add_exp", 0)
	self.set("fall_coin", 500)
	self.set("ebol", 0)

	attack_range = 130
	mysee = 99999
	speed = 12
	attack_desire = 80

	var base_damage_hit1 = 300
	var base_damage_hit2 = 1500
	var base_damage_hit3 = 400
	var base_damage_hit4 = 1000
	var base_damage_hit5 = 300
	var base_damage_hit6 = 300

	var actual_damage_hit1 = int(player_power * damage_ratio * (base_damage_hit1 / 300.0))
	var actual_damage_hit2 = int(player_power * damage_ratio * (base_damage_hit2 / 300.0))
	var actual_damage_hit3 = int(player_power * damage_ratio * (base_damage_hit3 / 300.0))
	var actual_damage_hit4 = int(player_power * damage_ratio * (base_damage_hit4 / 300.0))
	var actual_damage_hit5 = int(player_power * damage_ratio * (base_damage_hit5 / 300.0))
	var actual_damage_hit6 = int(player_power * damage_ratio * (base_damage_hit6 / 300.0))

	obj_attack_dict["hit1"] = {
		"power": actual_damage_hit1,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	obj_attack_dict["hit2"] = {
		"power": actual_damage_hit2,
		"hurtBack": [-1, -1],
		"attackKind": "magic",
		"HitProtect": 5,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": int(max_hp * 0.01),
			"AttackKind": "magic",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	obj_attack_dict["hit3"] = {
		"power": actual_damage_hit3,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 20,
			"reduce_interval": 0,
			"value": 0.5,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}
	obj_attack_dict["hit4"] = {
		"power": actual_damage_hit4,
		"hurtBack": [0, 0],
		"attackKind": "magic",
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
	obj_attack_dict["hit5"] = {
		"power": actual_damage_hit5,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	obj_attack_dict["hit6"] = {
		"power": actual_damage_hit6,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
	}

	print(
		(
			"牛魔王·魂召唤物属性初始化完成 - HP: %d, 防御: %d/%d, 伤害比例: %.1f%%, 实际攻击力(示例): hit1=%d"
			% [scaled_hp, scaled_def, scaled_mdef, damage_ratio * 100, actual_damage_hit1]
		)
	)


func _ready() -> void:
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	whs_count += 1
	if whs_count % 600 == 0:
		var bullet = Global.add_bullet(
			"Monster141Bullet4", self, true, 1, Vector2(0, -30), "hit6", obj_attack_dict["hit6"]
		)
		if bullet:
			bullet.scale = Vector2(2, 2)
			setup_bullet_collision(bullet)


func setup_skills() -> void:
	var cd_multiplier = max(0.5, 1.0 - (weapon_level - 1) * 0.05)
	skill_1_cd = 15 * cd_multiplier
	skill_2_cd = 20 * cd_multiplier
	skill_3_cd = 15 * cd_multiplier
	skill_4_cd = 12 * cd_multiplier
	skill_5_cd = 15 * cd_multiplier


func try_use_skills() -> void:
	if should_in_sky:
		return
	if randi_range(0, 100) >= attack_desire:
		return
	if not is_instance_valid(current_target):
		return

	var distance_to_target = abs(position.x - current_target.position.x)

	if skill_2_cd <= 0:
		do_hit_2()
	elif distance_to_target <= 300 and skill_1_cd <= 0:
		do_hit_1()
	elif skill_3_cd <= 0:
		do_hit_3()
	elif count % 90 == 0 and randi_range(0, 100) < attack_desire:
		attack_target()


func attack_target() -> void:
	if not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
		monster_direction = false
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
		monster_direction = true

	hit_name = "hit1"
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	reset_attack_state()


func do_hit_1() -> void:
	if not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
		monster_direction = false
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
		monster_direction = true

	skill_1_cd = 15
	velocity.x = 0
	hit_name = "hit2"
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	reset_attack_state()
	stop_move()


func do_hit_2() -> void:
	if not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
		monster_direction = false
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
		monster_direction = true

	skill_2_cd = 20
	velocity.x = 0
	hit_name = "hit3"
	is_attacking = true
	mr_player.play("hit3")
	attract_monsters(0.8)
	await mr_player.animation_finished
	is_attacking = false
	reset_attack_state()
	stop_move()


func do_hit_3() -> void:
	if not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
		monster_direction = false
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
		monster_direction = true

	skill_3_cd = 15
	velocity.x = 0
	hit_name = "hit4"
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	reset_attack_state()
	stop_move()


func state_hurt(attacker: Node) -> void:
	if hd > 0:
		is_be_attacking = false
		return

	if randi_range(0, 100) <= 10:
		is_be_attacking = true
		hit_name = "hit5"
		mr_player.play("hit5")
		await mr_player.animation_finished
		is_be_attacking = false
		reset_attack_state()
		return

	super.state_hurt(attacker)


func call_bullet_1() -> void:
	for i in range(8):
		var pos = Vector2(position.x + randi_range(-450, 500), -300)
		var bullet_instance = Global.add_bullet(
			"Monster141Bullet3", bullet, false, 0.15, pos, "hit3", obj_attack_dict["hit3"]
		)
		if bullet_instance:
			var lasthp = (float(max_hp) - float(hp)) / float(max_hp)
			var scalevalue = 1.0 + lasthp
			bullet_instance.scale = Vector2(scalevalue, scalevalue)
			if is_instance_valid(current_target):
				bullet_instance.look_at(current_target.position)
			setup_bullet_collision(bullet_instance)
			if not is_inside_tree():
				return
			var tree := get_tree()
			if tree == null:
				return
			await tree.create_timer(0.5, false).timeout


func call_bullet_alt2() -> void:
	if not is_instance_valid(current_target):
		return
	if position.distance_to(current_target.position) < attack_range:
		return
	var bullet_instance
	if monster_direction:
		bullet_instance = Global.add_bullet(
			"Monster141Bullet2", bullet, false, 2, Vector2(20, 0) + position, "hit1", obj_attack_dict["hit1"]
		)
	else:
		bullet_instance = Global.add_bullet(
			"Monster141Bullet2", bullet, false, 2, Vector2(-20, 0) + position, "hit1", obj_attack_dict["hit1"]
		)
	if bullet_instance:
		bullet_instance.look_at(current_target.position)
		setup_bullet_collision(bullet_instance)


func call_bullet_3() -> void:
	var x_offsets = [-300, -200, -100, 0, 100, 200, 300]
	for offset_x in x_offsets:
		var pos = Vector2(position.x + offset_x, 370)
		var bullet_instance = Global.add_bullet("Monster22Fire", bullet, false, 1, pos, "hit2", obj_attack_dict["hit2"])
		if bullet_instance:
			setup_bullet_collision(bullet_instance)


func call_bullet_4() -> void:
	var bullet1 = Global.add_bullet(
		"Monster141Bullet1", bullet, false, 1, Vector2(position.x - 1000, 450), "hit4", obj_attack_dict["hit4"]
	)
	var bullet2 = Global.add_bullet(
		"Monster141Bullet1", bullet, true, 1, Vector2(position.x + 1000, 450), "hit4", obj_attack_dict["hit4"]
	)
	if bullet1:
		setup_bullet_collision(bullet1)
	if bullet2:
		setup_bullet_collision(bullet2)


# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
## [Phase 7-1 兼容代理] 确保动画轨道与反射调用正常
func call_bullet_2() -> void:
	call_bullet_alt2()

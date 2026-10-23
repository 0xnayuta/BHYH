extends BaseMonster
@onready var gethd: Timer = $GetHd
@onready var remove_hd_and_cure: Timer = $RemoveHdAndCure
@onready var special_effect_1: AnimatedSprite2D = $MonsterDir/SpecialEffect1


func monster_89():
	self.is_boss = true
	self.my_mr_name = "朱子真"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 120000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 70
	self.toughness = 20
	self.ar = 35
	self.sp = 35
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 500
	self.attack_range = 185
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 300
	self.obj_attack_dict["hit1"] = {
		"power": 400,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 500,
		"hurtBack": [-1, -1],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit3"] = {
		"power": 900,
		"hurtBack": [-1, -1],
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
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": hd,
		"hurtBack": [-30, -50],
		"attackKind": "real",
		"HitProtect": 50,
	}

	self.obj_attack_dict["hit5"] = {
		"power": 400,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "zjksf", "value": 0},
		{"name": "zjxmczzs", "value": 1},
		{"name": "zjqj", "value": 0},
		{"name": "hljhzzs", "value": 1},
		{"name": "zjgp", "value": 0},
	]
	self.independent_fall_list = [
		{"name": "230007002", "value": 0, "chance": 0.333},
	]

	enable_treasure_box = true
	treasure_box_item = "zzzbx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_89()
	skill_1_cd = randi_range(5, 8)


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
	skill_3_cd = randi_range(10, 15)
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit5")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if hd > 0:
		special_effect_1.visible = true
	else:
		special_effect_1.visible = false


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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 500:
					if skill_2_cd <= 0:
						do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= 500:
					if skill_3_cd <= 0:
						do_hit_3()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300:
					if count % 90 == 0:
						if randi_range(0, 100) < attack_desire:
							attack_target()
			else:
				if skill_1_cd <= 0:
					do_hit_1()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif skill_3_cd <= 0:
					do_hit_3()
				elif count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
					else:
						stop_move()
				else:
					stop_move()


func add_bullet():
	Global.add_bullet(
		"Monster88Bullet2",
		self.bullet,
		monster_direction,
		1,
		Vector2(position.x, 470),
		"hit3",
		self.obj_attack_dict["hit3"]
	)
	await get_tree().create_timer(0.7, false).timeout
	var bullet_spawn_positions = [[-180, 180], [-360, 360], [-540, 540]]
	for i in bullet_spawn_positions:
		for u in i:
			Global.add_bullet(
				"Monster88Bullet2",
				self.bullet,
				monster_direction,
				2,
				Vector2(u + position.x, 470),
				"hit3",
				self.obj_attack_dict["hit3"]
			)
		await get_tree().create_timer(0.2, false).timeout


func call_bullet_3():
	for i in range(1):
		var bullet_node = Global.add_bullet(
			"Monster89Bullet3", self.bullet, false, 1.5, position, "hit3", self.obj_attack_dict["hit3"]
		)
		bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func _on_get_hd_timeout() -> void:
	var tween = create_tween()
	special_effect_1.modulate = Color("ffff00")
	tween.tween_property(special_effect_1, "modulate", Color("ff0000"), 8)
	get_hd(max_hp * 0.05, 0, 0.3)
	remove_hd_and_cure.start(8)


func _on_remove_hd_and_cure_timeout() -> void:
	if hd > 0:
		self.obj_attack_dict["hit4"]["power"] = int(hd)
		Global.add_bullet(
			"Monster88Bullet3", self.bullet, monster_direction, 1, position, "hit4", self.obj_attack_dict["hit4"]
		)
		change_hd_cure_hp(1)
	gethd.start(8)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

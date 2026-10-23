extends BaseMonster
class_name Monster50
var is_stop: bool = false
var call_monster_list: Dictionary = {"List_0": [18, 20, 23], "List_1": [37, 43, 41]}
var call_monster_id: int = 0
var call_monster: BaseMonster
var is_be_call = false


func monster_50():
	self.is_boss = true
	self.my_mr_name = "孟婆"
	self.attack_in = 20
	self.level = 30
	self.max_hp = 35000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 120
	self.crit = 18
	self.miss = 16
	self.lucky = 0
	self.htarget = 0
	self.toughness = 5
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 400
	self.attack_range = 255
	self.attack_desire = 80
	self.behit_calmtime = 0.1
	self.self_rhp = 0
	self.add_exp = 500
	self.fall_coin = 130
	self.obj_attack_dict["hit1"] = {"power": 260, "hurtBack": [-8, -7], "attackKind": "magic"}
	self.obj_attack_dict["mffd_1"] = {
		"power": int(RoleProp.roleprop.SHp * 0.05 + 100),
		"hurtBack": [-8, -5],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Ice",
			"AddTime": 4,
			"reduce_interval": 0,
			"CanAdd": false,
			"DeBuff": true,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["mffd_2"] = {
		"power": int(RoleProp.roleprop.SHp * 0.05 + 100),
		"hurtBack": [-8, -5],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 2,
			"reduce_interval": 0.5,
			"CanAdd": true,
			"DeBuff": true,
			"value": int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "real",
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "xhgp", "value": 0},
		{"name": "xhxh", "value": 0},
		{"name": "xhymk", "value": 0},
		{"name": "xhyk", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "mpbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_50()
	skill_1_cd = 0
	skill_2_cd = 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not is_stop:
		create_monster()
		move()
		self.self_rhp = 0
	else:
		self.self_rhp = randi_range(150, 250)
		check_call_monster_death()
		stop()


func ai_think():
	if is_be_call:
		velocity.x = 0
		self.modulate = Color(1, 1, 1, 0.0)
		$BaseDamageBox/HurtBox/HurtBox.disabled = true
		return
	else:
		if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
			has_target = true
		if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
			if has_target == false:
				normal_state()
			else:
				if not is_stop:
					if (
						abs(self.position.x - RoleProp.get_nearest_monster_target_position(global_position).x)
						> attack_range
					):
						have_target()
						if skill_1_cd <= 0:
							do_hit_2()
						elif skill_2_cd <= 0:
							do_hit_3()
					else:
						if skill_1_cd <= 0:
							do_hit_2()
						elif skill_2_cd <= 0:
							do_hit_3()
						else:
							if count % 60 == 0:
								attack_target()
							else:
								stop_move()


func do_hit_2():
	skill_1_cd = 12
	hit_name = "nlls"
	velocity.x = 0
	is_attacking = true
	mr_player.play("nlls")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 10
	velocity.x = 0
	is_attacking = true
	mr_player.play("mffd")
	await mr_player.animation_finished
	is_attacking = false


func stop():
	mr_player.play("wait")
	$BaseDamageBox/HurtBox/HurtBox.disabled = true
	self.modulate = Color(1, 1, 1, 0.5)


func move():
	self.modulate = Color(1, 1, 1, 1)


func create_monster():
	if call_monster_id == 0:
		if hp < max_hp * 0.5:
			self.modulate = Color(1, 1, 1, 0.5)
			$BaseDamageBox/HurtBox/HurtBox.disabled = true
			var get_list = call_monster_list["List_" + str(call_monster_id)]
			var monster_id: int = get_list[randi_range(0, get_list.size() - 1)]
			if call_monster == null:
				call_monster = Global.create_monster(20, get_parent(), self.position)
			strength_boss()
			is_stop = true
			mr_player.play("wait")
			call_monster_id = 1
	elif call_monster_id == 1:
		if hp < max_hp * 0.25:
			is_stop = true
			mr_player.play("wait")
			self.modulate = Color(1, 1, 1, 0.5)
			$BaseDamageBox/HurtBox/HurtBox.disabled = true
			var get_list = call_monster_list["List_" + str(call_monster_id)]
			var monster_id: int = get_list[randi_range(0, get_list.size() - 1)]
			if call_monster == null:
				call_monster = Global.create_monster(43, get_parent(), self.position)
			strength_boss()
			call_monster_id = 2


func check_call_monster_death():
	if call_monster != null:
		if call_monster.is_death:
			is_stop = false
			self.modulate = Color(1, 1, 1, 1)
			$BaseDamageBox/HurtBox/HurtBox.disabled = false
			call_monster = null


func add_nlls():
	(
		Global
		. add_buff(
			get_player.buff,
			{
				"Name": "nlls",
				"AddTime": 6,
				"reduce_interval": 0.01,
				"value": 1.2,
				"AttackKind": "magic",
				"CanAdd": true,
				"DeBuff": true,
			}
		)
	)


func call_bullet():
	var bullet
	var bullet_name: String
	var hit_name: String
	if randi_range(0, 100) < 50:
		bullet_name = "Monster49Bullet_1"
		hit_name = "mffd_1"
	else:
		bullet_name = "Monster49Bullet_2"
		hit_name = "mffd_2"
	if monster_direction:
		bullet = Global.call_chase_bullet(
			self.bullet,
			bullet_name,
			330,
			4,
			false,
			Vector2(self.position.x + 220, self.position.y - 180),
			hit_name,
			self.obj_attack_dict[hit_name]
		)
	else:
		bullet = Global.call_chase_bullet(
			self.bullet,
			bullet_name,
			330,
			4,
			false,
			Vector2(self.position.x - 220, self.position.y - 180),
			hit_name,
			self.obj_attack_dict[hit_name]
		)
	bullet.scale = Vector2(2, 2)


func strength_boss():
	if call_monster != null:
		if call_monster is Monster43:
			call_monster.max_hp = max_hp
			call_monster.my_mr_name = "邪·阎罗王"
		elif call_monster is Monster20:
			call_monster.my_mr_name = "邪·鲨魔王"
			call_monster.max_hp = max_hp * 0.75
		call_monster.hp = call_monster.max_hp
		call_monster.level = level
		call_monster.def = def * 1.1
		call_monster.mdef = mdef * 1.1
		call_monster.fall_pro = 0
		call_monster.hp = call_monster.max_hp
		call_monster.speed = speed
		call_monster.modulate = Color("00ffff")
		call_monster.fall_list = []
		if call_monster is Monster20:
			for i in call_monster.obj_attack_dict:
				if call_monster.obj_attack_dict[i].has("power"):
					call_monster.obj_attack_dict[i]["power"] = randi_range(265, 330)


func call_fly_bullet():
	if monster_direction:
		var pp = Global.call_fly_bullet(
			bullet,
			"Monster49Bulet",
			1,
			Vector2(position.x, position.y + 30),
			2500,
			-900,
			"hit1",
			obj_attack_dict["hit1"]
		)
		if pp:
			var sprite = pp.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = true
	else:
		Global.call_fly_bullet(
			bullet,
			"Monster49Bulet",
			1,
			Vector2(position.x, position.y + 30),
			2500,
			900,
			"hit1",
			obj_attack_dict["hit1"]
		)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

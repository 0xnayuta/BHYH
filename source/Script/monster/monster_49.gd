extends BaseMonster
class_name Monster49
var is_stop: bool = false
var call_monster_list: Dictionary = {"List_0": [4, 5, 11], "List_1": [28, 30, 31]}
var call_monster_id: int = 0
var call_monster: BaseMonster
var is_cr: bool = false


func monster_49():
	self.is_boss = true
	self.my_mr_name = "孟婆"
	self.attack_in = 20
	self.level = 30
	self.max_hp = 30000
	self.hp = self.max_hp
	self.def = 125
	self.mdef = 125
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 5
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 7
	self.mysee = 400
	self.attack_range = 225
	self.attack_desire = 80
	self.behit_calmtime = 0.1
	self.self_rhp = 0
	self.add_exp = 50
	self.fall_coin = 13
	self.obj_attack_dict["hit1"] = {"power": 240, "hurtBack": [-8, -7], "attackKind": "magic"}
	self.obj_attack_dict["mffd_1"] = {
		"power": int(RoleProp.roleprop.SHp * 0.03 + 200),
		"hurtBack": [-8, -5],
		"attackKind": "magic",
	}
	self.obj_attack_dict["mffd_2"] = {
		"power": int(RoleProp.roleprop.SHp * 0.03 + 200),
		"hurtBack": [-8, -5],
		"attackKind": "magic",
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_49()
	skill_1_cd = 0
	skill_2_cd = 0


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if is_stop:
				check_call_monster_death()
				stop()
			else:
				create_monster()
				move()
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
						if count % 120 == 0:
							attack_target()
						else:
							stop_move()


func do_hit_2():
	skill_1_cd = 15
	velocity.x = 0
	is_attacking = true
	mr_player.play("nlls")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 18
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
			call_monster = Global.create_monster(18, get_parent(), self.position)
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
			call_monster = Global.create_monster(37, get_parent(), self.position)
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
				"AddTime": 4,
				"reduce_interval": 0.01,
				"value": 1,
				"DeBuff": true,
				"AttackKind": "magic",
				"CanAdd": true,
			}
		)
	)


func call_bullet():
	var bullet
	if monster_direction:
		bullet = Global.call_chase_bullet(
			self.bullet,
			"Monster49Bullet_1",
			280,
			3,
			false,
			Vector2(self.position.x + 220, self.position.y - 180),
			"mffd_1",
			self.obj_attack_dict["mffd_1"]
		)
	else:
		bullet = Global.call_chase_bullet(
			self.bullet,
			"Monster49Bullet_1",
			280,
			3,
			false,
			Vector2(self.position.x - 220, self.position.y - 180),
			"mffd_1",
			self.obj_attack_dict["mffd_1"]
		)
	bullet.scale = Vector2(2, 2)


func strength_boss():
	if call_monster != null:
		call_monster.max_hp = 20000
		call_monster.hp = call_monster.max_hp
		call_monster.level = RoleProp.baseroleprop.Level - 2
		call_monster.def = 100
		call_monster.mdef = 100
		call_monster.hp = call_monster.max_hp
		call_monster.fall_pro = 0
		call_monster.use_parent_material = true

		if call_monster is Monster18:
			call_monster.my_mr_name = "邪·蛟魔王"
		elif call_monster is Monster37:
			call_monster.my_mr_name = "邪·秦广王"
		call_monster.modulate = Color("00ffff")
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


func local_level():
	var pp = get_parent().get_parent() as BaseLevel
	if pp is Level19:
		if pp.mm == null:
			pp.can_notpass = true
			pp.ck_hero.disabled = true

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

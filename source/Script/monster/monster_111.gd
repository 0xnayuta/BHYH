extends BaseMonster


func monster_109():
	self.is_boss = false
	self.my_mr_name = "人参童子"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 16000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 25
	self.sp = 25
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 500
	self.attack_range = 165
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 220
	self.fall_coin = 220
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "renshen", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.28
	self.fall_stone = [
		{"name": "ziyanyujin", "value": randi_range(1, 5)},
	]


func _ready() -> void:
	super._ready()
	skill_1_cd = 0
	monster_109()


func call_bullet_1():
	var bullet_node
	if self.monster_direction:
		bullet_node = Global.add_bullet(
			"Monster111Bullet",
			self.bullet,
			monster_direction,
			1,
			Vector2(40, 0) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		bullet_node = Global.add_bullet(
			"Monster111Bullet",
			self.bullet,
			monster_direction,
			1,
			Vector2(40, 0) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(15, 18)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt() and not is_immobilize:
		if has_target == false:
			normal_state()
		else:
			if follow_hero():
				have_target()
				if skill_1_cd <= 0:
					do_hit_1()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func monster_cure_hp():
	var base_level = get_parent().get_parent() as BaseLevel
	for i in base_level.monster.get_children():
		if i != null:
			if i is BaseMonster:
				Global.add_special_effect(i, Vector2(0, -45), "monster111_bullet", Vector2(1, 1), false, 1)
				i.cure_hp(i.max_hp * 0.35)
				if i.hp >= i.max_hp:
					i.hd += i.max_hp * 0.35
					i.max_hd = i.hd

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

extends BaseMonster
class_name Monster117


func monster_117():
	self.rush_speed = 800
	self.is_fly = true
	self.is_boss = true
	self.my_mr_name = "飞烟剑"
	self.attack_in = 60
	self.level = 55
	self.max_hp = 300000
	self.hp = self.max_hp
	self.def = 350
	self.mdef = 400
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 20
	self.sp = 20
	self.crit_reduce = 0
	self.speed = 14
	self.mysee = 500
	self.attack_range = 325
	self.attack_desire = 90
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 15
	self.fall_coin = 4
	self.obj_attack_dict["hit1"] = {"power": 600, "hurtBack": [-4, -9], "attackKind": "real"}
	self.obj_attack_dict["hit2"] = {"power": 500, "hurtBack": [-4, -9], "attackKind": "real"}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_117()
	skill_1_cd = 10


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 250:
					if skill_1_cd <= 0:
						do_hit_1()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = 10
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()

extends BaseMonster
var cure_bl: float = 1


func monster_120():
	self.is_boss = false
	self.my_mr_name = "妖风炼气师"
	self.attack_in = 30
	self.level = 55
	self.max_hp = 45000
	self.hp = self.max_hp
	self.def = 355
	self.mdef = 365
	self.crit = 28
	self.miss = 28
	self.lucky = 40
	self.htarget = 0
	self.toughness = 35
	self.ar = 65
	self.sp = 65
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 600
	self.attack_range = 135
	self.attack_desire = 85
	self.behit_calmtime = 0.4
	self.self_rhp = 0
	self.add_exp = 100
	self.fall_coin = 30
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 15,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 800,
		"hurtBack": [0, -50],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0.4,
			"CanAdd": false,
			"CanRemove": false,
			"AttackKind": "",
		}
	}
	self.fall_pro = 0.5
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_120()
	skill_1_cd = 6


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


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
					do_hit_2()
				if count % 90 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				elif count % 60 == 0:
					var rad = randi_range(0, 100)
					if rad <= attack_desire:
						attack_target()
				else:
					stop_move()


func do_hit_2():
	skill_1_cd = 3
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	call_bullet_2()
	await mr_player.animation_finished
	is_attacking = false


func call_bullet_2():
	Global.add_bullet(
		"Monster122Bullet2",
		self.bullet,
		false,
		1.5,
		Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 500),
		"hit2",
		self.obj_attack_dict["hit2"]
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

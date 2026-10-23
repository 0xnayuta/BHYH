extends BaseMonster


func monster_104():
	self.is_boss = false
	self.my_mr_name = "硫磺童子"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 15000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
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
	self.attack_range = 365
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 220
	self.fall_coin = 220
	self.obj_attack_dict["hit1"] = {
		"power": 300,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": 100,
			"AttackKind": "magic",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit2"] = {
		"power": 600,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Fire",
			"AddTime": 8,
			"reduce_interval": 1,
			"value": 150,
			"AttackKind": "magic",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "liuhuang", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.28
	self.fall_stone = [
		{"name": "ziyanyujin", "value": randi_range(1, 5)},
	]


func _ready() -> void:
	super._ready()
	monster_104()


func call_bullet_1():
	var bullet_node
	if self.monster_direction:
		bullet_node = Global.add_bullet(
			"Monster104Bullet",
			self.bullet,
			monster_direction,
			1,
			Vector2(30, 25) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		bullet_node = Global.add_bullet(
			"Monster104Bullet",
			self.bullet,
			monster_direction,
			1,
			Vector2(-30, 25) + position,
			"hit1",
			self.obj_attack_dict["hit1"]
		)


func state_death():
	hit_name = "hit2"
	super.state_death()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

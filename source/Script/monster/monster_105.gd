extends BaseMonster


func monster_105():
	self.is_boss = false
	self.my_mr_name = "巫毒童子"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 13000
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
	self.attack_range = 365
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 220
	self.fall_coin = 220
	self.obj_attack_dict["hit1"] = {
		"power": 120,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": 30,
			"AttackKind": "magic",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "xianmao", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.28
	self.fall_stone = [
		{"name": "ziyanyujin", "value": randi_range(1, 5)},
	]


func _ready() -> void:
	super._ready()
	monster_105()


func call_dd():
	if self.monster_direction:
		Global.call_chase_bullet(
			self.bullet,
			"Monster37Bullet",
			220,
			3,
			true,
			Vector2(self.position.x + 70, self.position.y),
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		Global.call_chase_bullet(
			self.bullet,
			"Monster37Bullet",
			220,
			3,
			true,
			Vector2(self.position.x - 70, self.position.y),
			"hit1",
			self.obj_attack_dict["hit1"]
		)

extends BaseMonster


func monster_26():
	self.rush_speed = 150
	self.is_boss = false
	self.my_mr_name = "鬼灯"
	self.attack_in = 10
	self.level = 25
	self.max_hp = 1300
	self.hp = self.max_hp
	self.def = 120
	self.mdef = 120
	self.crit = 20
	self.miss = 15
	self.lucky = 0
	self.htarget = 10
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 13
	self.mysee = 300
	self.attack_range = 45
	self.attack_desire = 80
	self.behit_calmtime = 0.1
	self.self_rhp = 0
	self.add_exp = 60
	self.fall_coin = 22
	self.obj_attack_dict["hit1"] = {
		"power": 175,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 3,
			"reduce_interval": 0.5,
			"CanAdd": true,
			"DeBuff": true,
			"value": 50,
			"AttackKind": "magic",
		}
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_26()

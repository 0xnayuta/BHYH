extends BaseMonster


func monster_27():
	self.rush_speed = 0
	self.is_boss = false
	self.my_mr_name = "僵尸"
	self.attack_in = 10
	self.level = 25
	self.max_hp = 1600
	self.hp = self.max_hp
	self.def = 120
	self.mdef = 120
	self.crit = 20
	self.miss = 10
	self.lucky = 0
	self.htarget = 10
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 300
	self.attack_range = 45
	self.attack_desire = 80
	self.behit_calmtime = 0.1
	self.self_rhp = 0
	self.add_exp = 60
	self.fall_coin = 22
	self.obj_attack_dict["hit1"] = {
		"power": 255,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 4,
			"CanAdd": true,
			"DeBuff": true,
			"reduce_interval": 1,
			"value": 80,
			"AttackKind": "magic",
		}
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_27()

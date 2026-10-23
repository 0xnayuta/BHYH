extends BaseMonster


func monster_39():
	self.is_boss = false
	self.my_mr_name = "马面"
	self.attack_in = 10
	self.level = 27
	self.max_hp = 2000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 8
	self.miss = 6
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 8
	self.mysee = 300
	self.attack_range = 145
	self.attack_desire = 70
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 60
	self.fall_coin = 25
	self.obj_attack_dict["hit1"] = {
		"power": 98,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 3,
			"CanAdd": true,
			"DeBuff": true,
			"reduce_interval": 1,
			"value": 30,
			"AttackKind": "physics",
		}
	}

	self.fall_pro = 0.03
	self.fall_list = [
		{"name": "gtq", "value": 0},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_39()

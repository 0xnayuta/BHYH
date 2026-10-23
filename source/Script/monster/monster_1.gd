extends BaseMonster


func monster_1():
	self.is_boss = false
	self.my_mr_name = "小猴子"
	self.attack_in = 90
	self.level = 5
	self.max_hp = 60
	self.hp = self.max_hp
	self.def = 50
	self.mdef = 80
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 8
	self.mysee = 300
	self.attack_range = 45
	self.attack_desire = 70
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 1
	self.fall_coin = 1
	self.obj_attack_dict["hit1"] = {
		"power": 10,
		"hurtBack": [-3, -6],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.fall_pro = 1.0
	self.fall_list = [
		{"name": "ptjs", "value": 0},
		{"name": "ptdp", "value": 0},
		{"name": "ptcs", "value": 0},
		{"name": "ptyyc", "value": 0},
		{"name": "ptcp", "value": 0},
		{"name": "pttq", "value": 0},
		{"name": "ptcf", "value": 0},
		{"name": "nzhjq", "value": 0},
		{"name": "nzly", "value": 0},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_1()

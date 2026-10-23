extends BaseMonster


func monster_135():
	self.is_boss = false
	self.my_mr_name = "天王使者"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 15000
	self.hp = self.max_hp
	self.def = 175
	self.mdef = 170
	self.crit = 20
	self.miss = 0
	self.lucky = 0
	self.htarget = 20
	self.toughness = 0
	self.ar = 20
	self.sp = 20
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 600
	self.attack_range = 135
	self.attack_desire = 70
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 150
	self.obj_attack_dict["hit1"] = {
		"power": 400,
		"hurtBack": [-3, -6],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_135()

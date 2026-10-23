extends BaseMonster


func monster_21():
	self.is_boss = false
	self.my_mr_name = "牛魔斗士"
	self.attack_in = 30
	self.level = 25
	self.max_hp = 1200
	self.hp = self.max_hp
	self.def = 100
	self.mdef = 160
	self.crit = 50
	self.miss = 5
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 500
	self.attack_range = 100
	self.attack_desire = 70
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 50
	self.fall_coin = 20
	self.obj_attack_dict["hit1"] = {"power": 150, "hurtBack": [-4, -9], "attackKind": "physics"}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_21()

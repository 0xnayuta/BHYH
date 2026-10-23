extends BaseMonster


func monster_2():
	self.is_boss = false
	self.my_mr_name = "妖猴"
	self.attack_in = 60
	self.run_hit_active = true
	self.run_hit_count = 90
	self.level = 5
	self.max_hp = 90
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
	self.speed = 11
	self.mysee = 300
	self.attack_range = 85
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 5
	self.fall_coin = 2
	self.obj_attack_dict["hit1"] = {"power": 20, "hurtBack": [-4, -9], "attackKind": "physics", "HitProtect": 15}
	self.fall_pro = 0.18
	self.fall_list = [
		{"name": "ptxzg", "value": 0},
		{"name": "ptxzf", "value": 0},
		{"name": "ptsmz", "value": 0},
		{"name": "ptjs", "value": 0},
		{"name": "ptdp", "value": 0},
		{"name": "ptcs", "value": 0},
		{"name": "ptyyc", "value": 0},
		{"name": "ptcp", "value": 0},
		{"name": "nzhjq", "value": 0},
		{"name": "nzly", "value": 0},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_2()

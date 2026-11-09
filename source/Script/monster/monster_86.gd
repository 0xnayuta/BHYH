extends BaseMonster


func monster_86():
	self.is_boss = false
	self.my_mr_name = "狗妖"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 10000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 35
	self.sp = 35
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 500
	self.attack_range = 155
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 150
	self.fall_coin = 110
	self.obj_attack_dict["hit1"] = {
		"power": 250,
		"hurtBack": [-8, -12],
		"attackKind": "real",
		"HitProtect": 10,
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.1
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_86()

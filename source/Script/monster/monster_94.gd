extends BaseMonster
var level_base
var stage = 1


func monster_94():
	self.is_boss = false
	self.my_mr_name = "天兵·斧"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 6000 + stage * 3000
	self.hp = self.max_hp
	self.def = 100 + stage * 25
	self.mdef = 100 + stage * 25
	self.crit = 0 + stage * 15
	self.miss = 0 + stage * 5
	self.lucky = 0 + stage * 15
	self.htarget = 0
	self.toughness = 0
	self.ar = 15 + stage * 10
	self.sp = 15 + stage * 10
	self.crit_reduce = 0
	self.speed = 8 + stage * 2
	self.mysee = 500
	self.attack_range = 165
	self.attack_desire = 75 + stage * 10
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 160
	self.fall_coin = 110
	self.obj_attack_dict["hit1"] = {
		"power": 150 + stage * 45,
		"hurtBack": [-8, -12],
		"attackKind": "physics",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 3,
			"reduce_interval": 0.5,
			"value": 30,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	level_base = get_parent().get_parent()
	if level_base is Levelpty:
		stage = 0
	super._ready()
	monster_94()

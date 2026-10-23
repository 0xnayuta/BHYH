extends BaseMonster


func monster_75():
	self.is_boss = false
	self.my_mr_name = "黑虎"
	self.attack_in = 15
	self.level = 35
	self.max_hp = 4000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 10
	self.miss = 8
	self.lucky = 0
	self.htarget = 0
	self.toughness = 20
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 14
	self.mysee = 400
	self.attack_range = 150
	self.attack_desire = 80
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 110
	self.fall_coin = 70
	self.obj_attack_dict["hit1"] = {
		"power": 200,
		"hurtBack": [-7, -9],
		"attackKind": "physics",
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
	monster_75()

extends BaseMonster


func monster_97():
	self.is_boss = false
	self.my_mr_name = "巨盾护卫"
	self.attack_in = 60
	self.level = 40
	self.max_hp = 9000 + Global.get_tower_floor() * 500
	self.hp = self.max_hp
	self.def = 140 + Global.get_tower_floor() * 2
	self.mdef = 140 + Global.get_tower_floor() * 2
	self.crit = 0 + Global.get_tower_floor() * 1.5
	self.miss = 0 + Global.get_tower_floor() * 1
	self.lucky = 0 + Global.get_tower_floor() * 3
	self.htarget = 0 + Global.get_tower_floor() * 1.5
	self.toughness = 0
	self.ar = 6 + Global.get_tower_floor() * 1
	self.sp = 6 + Global.get_tower_floor() * 1
	self.crit_reduce = 0
	self.speed = 8
	self.mysee = 500
	self.attack_range = 125
	self.attack_desire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 60 + Global.get_tower_floor() * 5
	self.fall_coin = 70 + Global.get_tower_floor() * 6
	self.obj_attack_dict["hit1"] = {
		"power": 330 + Global.get_tower_floor() * 6,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.07
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_97()

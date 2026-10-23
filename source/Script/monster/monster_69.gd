extends BaseMonster


func monster_69():
	self.is_boss = false
	self.my_mr_name = "鱼鬼妖"
	self.attack_in = 10
	self.level = 45
	self.max_hp = 3000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 120
	self.crit = 18
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 20
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 13
	self.mysee = 300
	self.attack_range = 115
	self.attack_desire = 80
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {"power": 268, "hurtBack": [-4, -9], "attackKind": "physics", "HitProtect": 18}
	self.fall_pro = 0.1
	self.fall_list = [
		{"name": "t", "value": 1},
		{"name": "c", "value": 1},
		{"name": "ch", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_69()


func _on_hit_box_area_exited(_area: Area2D) -> void:
	var xx = 5 * (1 - float(hp) / float(max_hp)) + randi_range(0, 1)
	self.cure_hp(xx * obj_attack_dict["hit1"]["power"])
	super._on_hit_box_area_entered(_area)

extends BaseMonster


func monster_7():
	self.is_fly = true
	self.is_boss = false
	self.my_mr_name = "蝙蝠"
	self.attack_in = 60
	self.level = 17
	self.max_hp = 370
	self.hp = self.max_hp
	self.def = 60
	self.mdef = 70
	self.crit = 8
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 8
	self.mysee = 300
	self.attack_range = 75
	self.attack_desire = 80
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 15
	self.fall_coin = 4
	self.obj_attack_dict["hit1"] = {"power": 25, "hurtBack": [-4, -9], "attackKind": "physics"}

	self.fall_pro = 0.2
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
	monster_7()


func attack_target():
	velocity.y = 100
	super.attack_target()


func self_reco():
	super.cure_hp((self.max_hp - self.hp) * 0.1)


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	var buff_target = super._on_hit_box_area_entered(area)

	self_reco()

	return buff_target

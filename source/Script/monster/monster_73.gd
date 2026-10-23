extends BaseMonster


func monster_73():
	self.is_fly = true
	self.is_boss = false
	self.my_mr_name = "恶鹰"
	self.attack_in = 10
	self.level = 90
	self.max_hp = 1
	self.hp = self.max_hp
	self.def = 1
	self.mdef = 1
	self.crit = 0
	self.miss = 1
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 15
	self.mysee = 600
	self.attack_range = 95
	self.attack_desire = 100
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": 1 + RoleProp.roleprop.SHp * 0.04, "hurtBack": [-4, -9], "attackKind": "real"
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0.0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_73()


func attack_target():
	velocity.x = 0
	velocity.y = 40
	super.attack_target()

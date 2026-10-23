extends BaseMonster
class_name Monster51
var check_count: int = 0


func monster_51():
	self.is_boss = false
	self.my_mr_name = "沙华"
	self.attack_in = 0
	self.level = 30
	self.max_hp = 3000
	self.hp = self.max_hp
	self.def = 170
	self.mdef = 130
	self.crit = 22
	self.miss = 10
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 20
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 7
	self.mysee = 400
	self.attack_range = 90
	self.attack_desire = 75
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 75
	self.fall_coin = 40
	self.obj_attack_dict["hit1"] = {
		"power": 150,
		"hurtBack": [-8, 0],
		"attackKind": "physics",
	}

	self.fall_pro = 0.05
	self.fall_list = [
		{"name": "lssp", "value": 1},
		{"name": "zshb", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_51()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if check_count % 60 == 0:
		if check_have_mz() and hp > 0:
			cure_hp(int(self.max_hp * 0.03))
	check_count += 1


func check_have_mz():
	var pp = get_parent().get_parent() as BaseLevel
	for i in pp.monster.get_children():
		if i is Monster53:
			return true
	return false

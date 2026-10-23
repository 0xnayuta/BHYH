extends BaseMonster
var curecount: int = 0


func monster_45():
	self.is_bt = true
	self.is_boss = true
	self.cannot_attract = true
	self.my_mr_name = "鬼门·贪婪"
	self.attack_in = 0
	self.level = 90
	self.max_hp = 12000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 25
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 25
	self.speed = 0
	self.mysee = 0
	self.attack_range = 0
	self.attack_desire = 0
	self.behit_calmtime = 0.0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "yll", "value": randi_range(1, 10)},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_45()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	velocity.x = 0
	if is_on_floor():
		velocity.y = 0


func ai_think():
	velocity.x = 0
	if is_on_floor():
		velocity.y = 0
	if curecount % 120 == 0:
		monster_cure_hp()
	curecount += 1


func monster_cure_hp():
	var base_level = get_parent().get_parent() as BaseLevel
	for i in base_level.monster.get_children():
		if i != null:
			if i is BaseMonster and not i is Monster138:
				i.cure_hp(i.max_hp * 0.02)
				if i.hp >= i.max_hp:
					i.hd += i.max_hp * 0.02
					i.max_hd = i.hd

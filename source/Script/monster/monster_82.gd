extends BaseMonster


func monster_82():
	self.c_hange_clam_count = 3
	self.is_smart_monster = true
	self.smart_wait_count = 60
	self.smart_hit_count = 40
	self.is_boss = false
	self.my_mr_name = "天兵·弓"
	self.attack_in = 10
	self.level = 35
	self.max_hp = 6000
	self.hp = self.max_hp
	self.def = 130
	self.mdef = 130
	self.crit = 25
	self.miss = 0
	self.lucky = 0
	self.htarget = 58
	self.toughness = 0
	self.ar = 20
	self.sp = 20
	self.crit_reduce = 0
	self.speed = 14
	self.mysee = 800
	self.attack_range = 355
	self.attack_desire = 85
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 110
	self.fall_coin = 90
	self.obj_attack_dict["hit1"] = {
		"power": 325,
		"hurtBack": [-15, -12],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 1,
			"reduce_interval": 0,
			"value": 0.7,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
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
	monster_82()


func add_bullet():
	var target_position: Vector2
	if monster_direction:
		target_position = Vector2(30, 5)
	else:
		target_position = Vector2(-30, 5)
	var arrow = Global.add_bullet(
		"Monster82Bullet",
		self.bullet,
		monster_direction,
		1,
		target_position + position,
		"hit1",
		self.obj_attack_dict["hit1"]
	)
	arrow.scale = Vector2(0.7, 0.7)

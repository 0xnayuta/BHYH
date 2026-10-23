extends BaseMonster


func monster_90():
	self.is_fly = true
	self.is_boss = false
	self.my_mr_name = "蛇妖"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 15000
	self.hp = self.max_hp
	self.def = 120
	self.mdef = 150
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 25
	self.sp = 25
	self.crit_reduce = 0
	self.speed = 13
	self.mysee = 500
	self.attack_range = 365
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 150
	self.fall_coin = 110
	self.obj_attack_dict["hit1"] = {
		"power": 300,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "sichou", "value": randi_range(1, 3)},
		{"name": "xuantie", "value": randi_range(1, 3)},
		{"name": "tanmu", "value": randi_range(1, 3)},
	]
	self.fall_stone_pro = 0.1
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_90()


func add_bullet():
	var bullet_pos: Vector2
	if monster_direction:
		bullet_pos = Vector2(50, 5)
	else:
		bullet_pos = Vector2(-50, 5)
	Global.add_bullet(
		"Monster90Bullet",
		self.bullet,
		monster_direction,
		1,
		bullet_pos + position,
		"hit1",
		self.obj_attack_dict["hit1"]
	)

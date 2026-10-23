extends BaseMonster


func monster_87():
	self.is_boss = false
	self.my_mr_name = "羊妖"
	self.attack_in = 90
	self.level = 35
	self.max_hp = 13000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 35
	self.sp = 35
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 500
	self.attack_range = 265
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 150
	self.fall_coin = 110
	self.obj_attack_dict["hit1"] = {
		"power": 130,
		"hurtBack": [-8, -12],
		"attackKind": "physics",
		"HitProtect": 10,
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
	monster_87()


func add_bullet():
	var bullet_spawn_positions = []
	if monster_direction:
		bullet_spawn_positions = [
			Vector2(-15, -35),
			Vector2(-10, -55),
			Vector2(-5, -10),
			Vector2(5, -45),
		]
	else:
		bullet_spawn_positions = [
			Vector2(15, -35),
			Vector2(10, -55),
			Vector2(5, -10),
			Vector2(-5, -45),
		]
	for i in bullet_spawn_positions:
		Global.add_bullet(
			"Monster87Bullet", self.bullet, monster_direction, 1, i + position, "hit1", self.obj_attack_dict["hit1"]
		)
		await get_tree().create_timer(0.2, false).timeout

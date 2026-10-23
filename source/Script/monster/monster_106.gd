extends BaseMonster


func monster_106():
	self.is_boss = false
	self.my_mr_name = "勾魂童子"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 17000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 25
	self.sp = 25
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 500
	self.attack_range = 335
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 220
	self.fall_coin = 220
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [1, -2],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 1,
			"reduce_interval": 1,
			"value": 0,
			"AttackKind": "magic",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "lingli", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.28
	self.fall_stone = [
		{"name": "ziyanyujin", "value": randi_range(1, 5)},
	]


func _ready() -> void:
	super._ready()
	monster_106()


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	var buff_target = super._on_hit_box_area_entered(area)

	var original_y = self.position.y
	self.position.y = buff_target.position.y

	move_playerto_boss(buff_target, 0.85)

	self.position.y = original_y

	return buff_target

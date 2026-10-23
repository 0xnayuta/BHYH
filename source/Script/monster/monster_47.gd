extends BaseMonster
class_name Monster47
var fish_count: int = 0
var pp: Vector2
var can_hit = false


func monster_47():
	self.is_boss = false
	self.cannot_attract = true
	self.my_mr_name = "鱼"
	self.attack_in = 0
	self.level = RoleProp.baseroleprop.Level
	self.max_hp = 1
	self.hp = self.max_hp
	self.def = 0
	self.mdef = 0
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 0
	self.mysee = 0
	self.attack_range = 0
	self.attack_desire = 0
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": int(RoleProp.roleprop.SHp * 0.02) + 1, "hurtBack": [-15, -3], "attackKind": "real"
	}
	self.obj_attack_dict["hit2"] = {
		"power": int(RoleProp.roleprop.SHp * 0.02) + 1,
		"hurtBack": [-15, -3],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "Bleed",
			"AddTime": 2,
			"reduce_interval": 0.5,
			"CanAdd": true,
			"DeBuff": true,
			"value": int(RoleProp.roleprop.SHp * 0.005) + 1,
			"AttackKind": "real",
		}
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_47()
	await get_tree().create_timer(4, false).timeout
	can_hit = true


func ai_think():
	if can_hit:
		if fish_count > 0:
			fish_count -= 1
		if fish_count <= 0:
			call_fish()


func call_fish():
	var _hit_name: String
	if randi_range(0, 100) < 30:
		_hit_name = "hit2"
	else:
		_hit_name = "hit1"
	for i in range(2):
		var bullet_pos = Vector2(randi_range(-90, 90), randi_range(140, 200)) + self.position
		if randi_range(0, 100) < 50:
			Global.add_bullet("fish_1", bullet, false, 1, bullet_pos, _hit_name, self.obj_attack_dict[_hit_name])
		else:
			Global.add_bullet("fish_2", bullet, false, 1, bullet_pos, _hit_name, self.obj_attack_dict[_hit_name])
	fish_count = randi_range(80, 160)

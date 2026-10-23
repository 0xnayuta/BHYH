extends BaseMonster


func monster_1301():
	self.is_fly = true
	self.is_boss = false
	self.my_mr_name = "凤翎"
	self.attack_in = 30
	self.level = 55
	self.max_hp = 55000
	self.hp = self.max_hp
	self.def = 355
	self.mdef = 365
	self.crit = 28
	self.miss = 28
	self.lucky = 40
	self.htarget = 0
	self.toughness = 35
	self.ar = 65
	self.sp = 65
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 600
	self.attack_range = 135
	self.attack_desire = 85
	self.behit_calmtime = 0.4
	self.self_rhp = 0
	self.add_exp = 100
	self.fall_coin = 30
	self.obj_attack_dict["hit1"] = {"power": 1000, "hurtBack": [-4, -9], "attackKind": "physics"}

	self.fall_pro = 0.28
	self.fall_list = [
		{"name": "ygs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_1301()


func call_bullet_1():
	var bullet_node
	if self.monster_direction:
		bullet_node = Global.add_bullet(
			"Monster123Bullet1", self.bullet, false, 1.5, Vector2(0, 0) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	else:
		bullet_node = Global.add_bullet(
			"Monster123Bullet1", self.bullet, false, 1.5, Vector2(0, 0) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

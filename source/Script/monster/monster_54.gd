extends BaseMonster

var check_count: int = 0


func monster_54():
	self.is_boss = false
	self.my_mr_name = "青蛇"
	self.attack_in = 0
	self.level = 30
	self.max_hp = 3000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 130
	self.crit = 5
	self.miss = 19
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 20
	self.crit_reduce = 0
	self.speed = 7
	self.mysee = 400
	self.attack_range = 260
	self.attack_desire = 75
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 75
	self.fall_coin = 40
	self.obj_attack_dict["hit1"] = {
		"power": 150,
		"hurtBack": [-8, 0],
		"attackKind": "magic",
	}
	self.fall_pro = 0.05
	self.fall_list = [
		{"name": "jssp", "value": 1},
		{"name": "lshb", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_54()


func call_bullet():
	if self.monster_direction:
		Global.add_bullet(
			"Monster54Bullet",
			self.bullet,
			self.monster_direction,
			1,
			Vector2(self.position.x + 220, self.position.y),
			"hit1",
			self.obj_attack_dict["hit1"]
		)
	else:
		Global.add_bullet(
			"Monster54Bullet",
			self.bullet,
			self.monster_direction,
			1,
			Vector2(self.position.x - 220, self.position.y),
			"hit1",
			self.obj_attack_dict["hit1"]
		)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

extends BaseMonster


func monster_99():
	self.is_boss = false
	self.is_fly = true
	self.my_mr_name = "黑雕护卫"
	self.attack_in = 60
	self.level = 40
	self.max_hp = 8000 + Global.llbt_level * 350
	self.hp = self.max_hp
	self.def = 90 + Global.llbt_level * 2
	self.mdef = 90 + Global.llbt_level * 2
	self.crit = 0 + Global.llbt_level * 1.5
	self.miss = 0 + Global.llbt_level * 1
	self.lucky = 0 + Global.llbt_level * 10
	self.htarget = 0 + Global.llbt_level * 1
	self.toughness = 0
	self.ar = 7 + Global.llbt_level * 1
	self.sp = 7 + Global.llbt_level * 1
	self.crit_reduce = 0
	self.speed = 15
	self.mysee = 500
	self.attack_range = 255
	self.attack_desire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 60 + Global.llbt_level * 5
	self.fall_coin = 70 + Global.llbt_level * 6
	self.obj_attack_dict["hit1"] = {
		"power": 270 + Global.llbt_level * 10,
		"hurtBack": [-8, -12],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "sichou", "value": randi_range(1, 2)},
		{"name": "xuantie", "value": randi_range(1, 2)},
		{"name": "tanmu", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.07
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_99()


func call_bullet():
	var bullet_node

	if self.monster_direction:
		bullet_node = Global.add_bullet(
			"Monster99Bullet", self.bullet, false, 1, Vector2(40, 20) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	else:
		bullet_node = Global.add_bullet(
			"Monster99Bullet", self.bullet, false, 1, Vector2(-40, 20) + position, "hit1", self.obj_attack_dict["hit1"]
		)
	bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

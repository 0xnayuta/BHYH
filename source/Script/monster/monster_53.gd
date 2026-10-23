extends BaseMonster
class_name Monster53
var check_count: int = 0


func monster_53():
	self.is_fly = true
	self.is_boss = false
	self.my_mr_name = "曼珠"
	self.attack_in = 0
	self.level = 30
	self.max_hp = 2500
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 130
	self.crit = 8
	self.miss = 8
	self.lucky = 0
	self.htarget = 0
	self.toughness = -20
	self.ar = 0
	self.sp = 20
	self.crit_reduce = 10
	self.speed = 7
	self.mysee = 400
	self.attack_range = 160
	self.attack_desire = 50
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 75
	self.fall_coin = 40
	self.obj_attack_dict["hit1"] = {
		"power": 90,
		"hurtBack": [-8, 0],
		"attackKind": "magic",
	}

	self.fall_pro = 0.05
	self.fall_list = [
		{"name": "yizfw", "value": 1},
		{"name": "hshb", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_53()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if check_count % 60 == 0:
		if check_have_sh() and hp > 0:
			cure_hp(int(self.max_hp * 0.03))
	check_count += 1


func check_have_sh():
	var pp = get_parent().get_parent() as BaseLevel
	for i in pp.monster.get_children():
		if i is Monster51:
			return true
	return false


func call_bullet():
	for i in range(randi_range(3, 5)):
		bullet = Global.call_chase_bullet(
			self.bullet,
			"Monster53Bullet",
			250,
			4,
			false,
			Vector2(self.position.x, self.position.y),
			"hit1",
			self.obj_attack_dict["hit1"]
		)
		await get_tree().create_timer(0.3).timeout

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

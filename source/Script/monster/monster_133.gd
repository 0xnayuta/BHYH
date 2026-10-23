extends BaseMonster
class_name Monster133
var my_parent: Monster132
var death_count: int = 900


func monster_133():
	self.cannot_attract = true
	self.is_boss = false
	self.no_target = true
	self.my_mr_name = "天庭战神幻影"
	self.attack_in = 0
	self.level = 1500
	self.max_hp = 9999999999
	self.hp = self.max_hp
	self.def = 9999999
	self.mdef = 9999999
	self.crit = 50
	self.miss = 25
	self.lucky = 115
	self.htarget = 35
	self.toughness = 0
	self.ar = 40
	self.sp = 40
	self.crit_reduce = 0
	self.speed = 0
	self.mysee = 600
	self.attack_range = 245
	self.attack_desire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": 150,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_133()


func _physics_process(delta: float) -> void:
	if my_parent != null:
		self.obj_attack_dict["hit1"] = my_parent.obj_attack_dict["hit1"]
	else:
		hp = -10
	super._physics_process(delta)
	velocity = Vector2(0, 0)
	should_in_sky = true
	death_count -= 1
	if death_count <= 0:
		hp = -10


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not cannotchangestatewhenattorbeatt():
		stop_move()
		if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= attack_range:
			if count % 60 == 0:
				if randi_range(0, 100) < attack_desire:
					attack_target()

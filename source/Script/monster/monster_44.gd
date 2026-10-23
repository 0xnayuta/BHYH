extends BaseMonster
var monster_list = [39, 40, 30, 31]
var curecount: int = 0


func monster_44():
	self.is_bt = true
	self.cannot_attract = true
	preload("res://Scene/monster/monster_39.tscn")
	preload("res://Scene/monster/monster_40.tscn")
	preload("res://Scene/monster/monster_28.tscn")
	preload("res://Scene/monster/monster_27.tscn")
	preload("res://Scene/monster/monster_26.tscn")
	preload("res://Scene/monster/monster_30.tscn")
	preload("res://Scene/monster/monster_31.tscn")
	preload("res://Scene/monster/monster_23.tscn")
	preload("res://Scene/monster/monster_29.tscn")
	self.is_boss = true
	self.my_mr_name = "鬼门·生灵"
	self.attack_in = 0
	self.level = 90
	self.max_hp = 12000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
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
	self.behit_calmtime = 0.0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
	self.fall_pro = 1
	self.fall_list = [
		{"name": "yll", "value": randi_range(1, 10)},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_44()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	velocity.x = 0
	if is_on_floor():
		velocity.y = 0


func ai_think():
	if curecount % 60 == 0:
		monster_call()
	curecount += 1


func monster_call():
	var base_level = get_parent().get_parent() as BaseLevel
	if base_level.monster.get_children().size() < 6:
		var chlid_monster = monster_list[randi_range(0, monster_list.size() - 1)]
		var mm = Global.create_monster(chlid_monster, get_parent(), Vector2(self.position.x, self.position.y - 30))
		if mm is BaseMonster:
			if mm.is_boss:
				mm.is_boss = false
			if mm.max_hp > 10000:
				mm.max_hp = mm.max_hp * randf_range(1.2, 1.8)
				mm.hp = mm.max_hp
			else:
				mm.max_hp = 5000
				mm.hp = mm.max_hp
			mm.def = 150
			mm.mdef = 150
			for u in mm.obj_attack_dict:
				if mm.obj_attack_dict[u].has("power"):
					if mm.obj_attack_dict[u]["power"] <= 150:
						mm.obj_attack_dict[u]["power"] = 150
						mm.obj_attack_dict[u]["power"] = mm.obj_attack_dict[u]["power"] * 1.5
					else:
						mm.obj_attack_dict[u]["power"] = mm.obj_attack_dict[u]["power"] * 1.5

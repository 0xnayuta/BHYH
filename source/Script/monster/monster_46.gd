extends BaseMonster
var curecount: int = 0
var de_buff_list = [
	{
		"Name": "stun",
		"AddTime": 2,
		"reduce_interval": 0,
		"value": 0,
		"AttackKind": "",
		"CanAdd": false,
		"DeBuff": true,
	},
	{
		"Name": "Ice",
		"AddTime": 2,
		"reduce_interval": 0,
		"value": 0,
		"AttackKind": "",
		"CanAdd": false,
		"DeBuff": true,
	},
	{
		"Name": "Fire",
		"AddTime": 5,
		"reduce_interval": 1,
		"value": int(RoleProp.roleprop.SHp * 0.01),
		"AttackKind": "real",
		"CanAdd": true,
		"DeBuff": true,
	},
	{
		"Name": "poision",
		"AddTime": 5,
		"reduce_interval": 1,
		"value": int(RoleProp.roleprop.SHp * 0.02),
		"AttackKind": "magic",
		"CanAdd": true,
		"DeBuff": true,
	}
]


func monster_46():
	self.is_bt = true
	self.is_boss = true
	self.cannot_attract = true
	self.my_mr_name = "鬼门·地狱"
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
	self.toughness = 25
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 25
	self.speed = 0
	self.mysee = 0
	self.attack_range = 0
	self.attack_desire = 0
	self.behit_calmtime = 0.0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "yll", "value": randi_range(1, 10)},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_46()
	curecount = 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	velocity.x = 0
	if is_on_floor():
		velocity.y = 0


func ai_think():
	velocity.x = 0
	if is_on_floor():
		velocity.y = 0
	if curecount % 60 == 0:
		role_reduce_hp()
	if curecount % 600 == 0:
		role_add_de_buff()
	curecount += 1


func role_reduce_hp():
	if not PlayerData.check_eq_zb("头衔", "sxyr"):
		get_player.effect_reducehp(int(RoleProp.roleprop.SHp * 0.01), "real")


func role_add_de_buff():
	Global.add_buff(get_player.buff, de_buff_list[randi_range(0, 3)])

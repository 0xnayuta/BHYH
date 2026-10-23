extends BaseMonster
var death_count: int = 0
var x_ycount: int = 0


func monster_6602():
	self.is_boss = false
	self.my_mr_name = "死亡墓碑"
	self.attack_in = 0
	self.level = RoleProp.baseroleprop.Level - 2
	self.max_hp = 250000
	self.hp = self.max_hp
	self.def = 300
	self.mdef = 300
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 60
	self.sp = 60
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
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "",
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_6602()
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0
	skill_4_cd = 0


func _physics_process(delta: float) -> void:
	velocity.x = 0
	if not is_on_floor():
		mr_player.play("begin")
	else:
		velocity.y = 0
		if hp > 0:
			mr_player.play("wait")
			death_count += 1
			x_ycount += 1
			if death_count % 60 == 0:
				role_reduce_prop()
			if x_ycount % 180 == 0:
				move_playerto_boss(null, 0.3)
				(
					Global
					. add_buff(
						get_player.buff,
						{
							"Name": "speed_down",
							"AddTime": 1,
							"reduce_interval": 0,
							"value": 0.6,
							"AttackKind": "",
						}
					)
				)
	super._physics_process(delta)


func ai_think():
	velocity.x = 0
	if not is_on_floor():
		mr_player.play("begin")
	else:
		velocity.y = 0
		if hp > 0:
			mr_player.play("wait")
			death_count += 1
			x_ycount += 1
			if death_count % 60 == 0:
				role_reduce_prop()
			if x_ycount % 180 == 0:
				move_playerto_boss(null, 0.3)
				(
					Global
					. add_buff(
						get_player.buff,
						{
							"Name": "speed_down",
							"AddTime": 1,
							"reduce_interval": 0,
							"value": 0.6,
							"AttackKind": "",
						}
					)
				)


func role_reduce_prop():
	if get_player != null:
		if get_player is BaseHero:
			get_player.effect_reducehp(randi_range(100, 200), "real")
			RoleProp.roleprop.Mp -= 20

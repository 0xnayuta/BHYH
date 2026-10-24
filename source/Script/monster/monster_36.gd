extends BaseMonster
var should_death = false
var wait_time = [120, 90, 180, 60]
var get_w_wait_time: int


func monster_36():
	self.is_fly = true
	self.cannot_attract = true
	self.is_boss = false
	self.my_mr_name = "傀儡王右手"
	self.attack_in = 10
	self.level = 90
	self.max_hp = 10000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 8
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 7
	self.mysee = 225
	self.attack_range = 305
	self.attack_desire = 80
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": 400,
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "Bleed",
			"DeBuff": true,
			"AddTime": 3,
			"reduce_interval": 0.5,
			"value": 35,
			"AttackKind": "physics",
		}
	}
	self.obj_attack_dict["xfj"] = {
		"power": 500,
		"hurtBack": [-3, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "silent",
			"DeBuff": true,
			"AddTime": 5,
			"CanAdd": false,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["wl"] = {"power": 400, "hurtBack": [-3, -15], "attackKind": "magic"}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	$ChangePL.start(randi_range(4, 6))
	get_w_wait_time = wait_time[randi_range(0, 3)]
	super._ready()
	monster_36()
	hit_name = "hit1"
	skill_1_cd = 0
	skill_2_cd = 0


func _physics_process(delta: float) -> void:
	velocity.x = 0
	velocity.y = 0
	super._physics_process(delta)


func ai_think():
	velocity.x = 0
	velocity.y = 0
	if hp > 0:
		if skill_1_cd > 0 and skill_2_cd > 0:
			if count % 240 == 0:
				if randi_range(0, 100) <= attack_desire:
					do_hit_1()
				else:
					if not is_attacking:
						mr_player.play("wait")
			else:
				if not is_attacking:
					mr_player.play("wait")
		else:
			if skill_1_cd <= 0:
				do_hit_2()
			else:
				if not is_attacking:
					mr_player.play("wait")


func do_hit_1():
	hit_name = "hit1"
	is_attacking = true
	mr_player.play("hit")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_2():
	skill_1_cd = 12
	hit_name = "xfj"
	is_attacking = true
	mr_player.play("jf")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 20
	hit_name = "wl"
	is_attacking = true
	mr_player.play("wl")
	await mr_player.animation_finished
	is_attacking = false


func call_ljf():
	var ljf = Global.call_fly_bullet(
		self.bullet,
		"Monster17Bullet",
		1,
		Vector2(self.position.x + 130, self.position.y + 120),
		900,
		400,
		"xfj",
		self.obj_attack_dict["xfj"]
	)
	ljf.set_modulate(Color(2, 0, 2, 1))


func call_wling():
	randomize()
	for i in range(randi_range(1, 2)):
		var list = [26, 27, 28, 30, 31]
		Global.create_monster(list[randi_range(0, 4)], get_parent(), Vector2(self.position.x, self.position.y + 100))


func call_fl():
	return


func _on_change_pl_timeout() -> void:
	get_w_wait_time = wait_time[randi_range(0, 3)]
	$ChangePL.start(randi_range(4, 6))

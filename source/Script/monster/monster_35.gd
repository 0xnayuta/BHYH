extends BaseMonster
var should_death = false
var wait_time = [30, 80, 90, 120]
var get_w_wait_time: int


func monster_35():
	self.cannot_attract = true
	self.is_fly = true
	self.is_boss = false
	self.my_mr_name = "傀儡王左手"
	self.attack_in = 10
	self.level = 90
	self.max_hp = 10000
	self.hp = self.max_hp
	self.def = 70
	self.mdef = 150
	self.crit = 8
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 0
	self.mysee = 225
	self.attack_range = 305
	self.attack_desire = 70
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
			"AddTime": 3,
			"DeBuff": true,
			"reduce_interval": 0.5,
			"value": 30,
			"AttackKind": "physics",
		}
	}
	self.obj_attack_dict["xfj"] = {
		"power": 400,
		"hurtBack": [-3, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"DeBuff": true,
			"reduce_interval": 0,
			"value": 0.2,
			"AttackKind": "",
		},
	}
	self.obj_attack_dict["wl"] = {
		"power": 500,
		"hurtBack": [-3, -15],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Boundground",
			"AddTime": 5,
			"CanAdd": false,
			"DeBuff": true,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0.0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	$ChangeWaitTime.start(randi_range(9, 12))
	monster_35()
	hit_name = "hit1"
	skill_1_cd = 0


func _physics_process(delta: float) -> void:
	velocity.x = 0
	velocity.y = 0
	super._physics_process(delta)


func ai_think():
	velocity.x = 0
	velocity.y = 0
	if hp > 0:
		if skill_1_cd > 0 and skill_2_cd > 0:
			if count % 180 == 0:
				if randi_range(0, 100) < attack_desire:
					do_hit_1()
				else:
					if not is_attacking:
						mr_player.play("wait")
			else:
				if not is_attacking:
					mr_player.play("wait")
		else:
			if skill_2_cd <= 0:
				do_hit_3()
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
	skill_1_cd = 22
	hit_name = "xfj"
	is_attacking = true
	mr_player.play("jf")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 16
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
		Vector2(self.position.x, self.position.y + 100),
		700,
		-400,
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
	var new_list = [
		{"Ratation": 30, "Position": Vector2(-1200, -400)},
		{"Ratation": 60, "Position": Vector2(-320, -900)},
		{"Ratation": -20, "Position": Vector2(-1100, 900)},
		{"Ratation": -60, "Position": Vector2(200, 900)},
		{"Ratation": 70, "Position": Vector2(-180, -900)},
		{"Ratation": 20, "Position": Vector2(-900, -400)}
	]
	new_list.reverse()
	for i in new_list:
		var fl = Global.add_bullet(
			"Monster33Bullet2", self.bullet, false, 1, i["Position"] + position, "wl", self.obj_attack_dict["wl"]
		)
		fl.rotation_degrees = i["Ratation"]
		await get_tree().create_timer(0.7, false).timeout


func _on_change_wait_time_timeout() -> void:
	$ChangeWaitTime.start(randi_range(9, 12))
	get_w_wait_time = wait_time[randi_range(0, 3)]

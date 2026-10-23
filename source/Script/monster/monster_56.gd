extends BaseMonster
class_name Monster56
@onready var zlw_special_effect_2: Node2D = $MonsterDir/zlwSpecialEffect_2
var boss_4
var round_list = []
var round_position = [
	Vector2(-390, 305),
	Vector2(-280, 305),
	Vector2(-170, 305),
	Vector2(-60, 305),
	Vector2(50, 305),
	Vector2(160, 305),
	Vector2(270, 305),
	Vector2(380, 305)
]
var round_position_2 = [
	Vector2(-390, 305),
	Vector2(-280, 305),
	Vector2(-170, 305),
	Vector2(-60, 305),
	Vector2(50, 305),
	Vector2(160, 305),
	Vector2(270, 305),
	Vector2(380, 305)
]
var jgpp = [
	Vector2(-370, 325),
	Vector2(-255, 325),
	Vector2(-140, 325),
	Vector2(-25, 325),
	Vector2(90, 325),
	Vector2(200, 325),
	Vector2(310, 325),
	Vector2(425, 325)
]
var idx_list = [0, 1, 2, 3, 4, 5, 6, 7]
var current_round: int = 8
var throw = true
var is_call = false
var throw_cout: int = 3
var call_stage = false
var add_shallow = false
var addcount: int = 0
var poweradd: float = 1


func monster_56():
	if get_parent().get_parent() is LevelZLDHDGQ:
		poweradd = 2
		self.is_boss = true
		self.cannot_attract = true
		self.my_mr_name = "转轮·真法"
		self.attack_in = 0
		self.level = 50
		self.max_hp = 350000
		self.hp = self.max_hp
		self.def = 400
		self.mdef = 400
		self.crit = 25
		self.miss = 35
		self.lucky = 0
		self.htarget = 0
		self.toughness = 6
		self.ar = 0
		self.sp = 0
		self.crit_reduce = 12
		self.speed = 0
		self.mysee = 0
		self.attack_range = 0
		self.attack_desire = 0
		self.behit_calmtime = 0
		self.self_rhp = 1000
		self.add_exp = 0
		self.fall_coin = 0
		self.obj_attack_dict["hit1"] = {"power": 200 * poweradd, "hurtBack": [-1, 0], "attackKind": "magic"}
		self.obj_attack_dict["hit2"] = {"power": 200 * poweradd, "hurtBack": [-1, -25], "attackKind": "magic"}
		self.fall_pro = 0.5
		self.fall_list = [
			{"name": "zlwdahsp1", "value": 3},
			{"name": "zlwdahsp2", "value": 3},
		]
		self.fall_stone_pro = 0.5
		self.fall_stone = [
			{"name": "putongzlwsz", "value": 0},
		]
		return
	self.is_boss = true
	self.cannot_attract = true
	self.my_mr_name = "转轮·真法"
	self.attack_in = 0
	self.level = 30
	self.max_hp = 100000
	self.hp = self.max_hp
	self.def = 200
	self.mdef = 200
	self.crit = 18
	self.miss = 15
	self.lucky = 0
	self.htarget = 0
	self.toughness = 10
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 12
	self.speed = 0
	self.mysee = 0
	self.attack_range = 0
	self.attack_desire = 0
	self.behit_calmtime = 0
	self.self_rhp = 1000
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {"power": 200 * poweradd, "hurtBack": [-1, 0], "attackKind": "magic"}
	self.obj_attack_dict["hit2"] = {"power": 200 * poweradd, "hurtBack": [-1, -25], "attackKind": "magic"}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "xyq", "value": 0},
		{"name": "syc", "value": 0},
		{"name": "nyd", "value": 0},
		{"name": "myz", "value": 0},
		{"name": "shyc", "value": 0}
	]

	enable_treasure_box = true
	treasure_box_item = "zlwbx"

	update_fall_mode()
	self.fall_stone_pro = 0.6
	self.fall_stone = [
		{"name": "ttlp2", "value": 1},
	]


func _ready() -> void:
	skill_1_cd = 4
	super._ready()
	monster_56()


func _physics_process(delta: float) -> void:
	if get_parent().get_parent() is LevelZLDHDGQ:
		if hp <= 0:
			if boss_4 == null:
				boss_4 = Global.create_monster(142, get_parent(), Vector2(750, 320)) as Monster142
	if is_on_floor():
		velocity.y = 0
	velocity.x = 0
	super._physics_process(delta)


func ai_think():
	if not call_stage:
		var pp = get_parent().get_parent()
		if not pp is Lhhj and not pp is LevelZLDHDGQ:
			Global.add_z_lw_stage(pp, Vector2(815, 210), 1, 1, 2060, true)
			Global.add_z_lw_stage(pp, Vector2(2100, 55), 1, -1, 860, false)
		call_stage = true
	if hp <= max_hp and hp > max_hp * 0.8:
		throw_cout = 1
		self.obj_attack_dict["hit1"] = {"power": 200 * poweradd, "hurtBack": [-1, 0], "attackKind": "magic"}
		self.obj_attack_dict["hit2"] = {"power": 90 * poweradd, "hurtBack": [-1, -5], "attackKind": "magic"}
	if hp <= max_hp * 0.8 and hp > max_hp * 0.6:
		throw_cout = 2
		self.obj_attack_dict["hit1"] = {"power": 500 * poweradd, "hurtBack": [-1, 0], "attackKind": "magic"}
		self.obj_attack_dict["hit2"] = {"power": 300 * poweradd, "hurtBack": [-1, -10], "attackKind": "magic"}
	if hp <= max_hp * 0.6 and hp > max_hp * 0.4:
		throw_cout = 3
		self.obj_attack_dict["hit1"] = {"power": 900 * poweradd, "hurtBack": [-1, 0], "attackKind": "magic"}
		self.obj_attack_dict["hit2"] = {"power": 500 * poweradd, "hurtBack": [-1, -15], "attackKind": "magic"}
	if hp <= max_hp * 0.4:
		throw_cout = 4
		self.obj_attack_dict["hit1"] = {"power": 1500 * poweradd, "hurtBack": [-1, 0], "attackKind": "magic"}
		self.obj_attack_dict["hit2"] = {
			"power": 700 * poweradd,
			"hurtBack": [-1, -25],
			"attackKind": "magic",
			"addeffect":
			{
				"Name": "speed_down",
				"AddTime": 3,
				"reduce_interval": 0,
				"value": 0.45,
				"DeBuff": true,
				"AttackKind": "",
				"CanAdd": false,
			}
		}
	if current_round <= 0:
		throw = false
	mr_player.play("wait")
	if is_on_floor():
		velocity.y = 0
	velocity.x = 0
	if throw:
		if skill_1_cd <= 0:
			throw_round(throw_cout)
	else:
		if skill_1_cd <= 0:
			return_all_round()


func throw_round(value):
	is_call = false
	skill_1_cd = randi_range(3, 5)
	var i = 0
	var i_dx_list = [0, 1, 2, 3, 4, 5, 6, 7]
	var tween = get_tree().create_tween().set_parallel(true)

	for u in range(value):
		if current_round > 0:
			var round_num = Global.add_bullet(
				"Monster55Bullet", bullet, false, 1, position, "hit1", self.obj_attack_dict["hit1"]
			)
			round_list.push_back(round_num)
			current_round -= 1

	for idx in range(round_list.size() - 1, -1, -1):
		if not is_instance_valid(round_list[idx]):
			round_list.remove_at(idx)

	for u in round_list:
		if i_dx_list.size() > 0:
			var get_num = i_dx_list.pick_random()
			var pp = round_position[get_num] + position
			u.is_throw = true
			tween.tween_property(u, "position", pp, 2)

			if u.is_throw_close:
				u.is_throw_close.start(2)
			i_dx_list.erase(get_num)

	zlw_special_effect_2.current_count -= value
	if zlw_special_effect_2.current_count <= 0:
		zlw_special_effect_2.current_count = 0

	if current_round <= 0:
		current_round = 0


func return_all_round():
	skill_1_cd = randi_range(3, 5)
	idx_list = [0, 1, 2, 3, 4, 5, 6, 7]
	var tween = get_tree().create_tween().set_parallel(true)
	if round_list.size() > 0:
		for i in round_list:
			if i != null:
				i.is_throw = true
				tween.tween_property(i, "position", position, 1)

	await get_tree().create_timer(1.2, false).timeout
	for i in round_list:
		if i != null:
			i.queue_free()
	round_list.clear()
	if not is_call:
		is_call = true
		call_jg(throw_cout)
	current_round = 8
	zlw_special_effect_2.current_count = 8


func call_jg(lx):
	jgpp = [
		Vector2(-370, 325),
		Vector2(-255, 325),
		Vector2(-140, 325),
		Vector2(-25, 325),
		Vector2(90, 325),
		Vector2(200, 325),
		Vector2(310, 325),
		Vector2(425, 325)
	]
	var list = []
	var jg: float
	match lx:
		1:
			list = [Vector2(-370, 325), Vector2(425, 325)]
			jg = 0.01
		2:
			list = [Vector2(-370, 325), Vector2(-25, 325), Vector2(90, 325), Vector2(425, 325)]
			jg = 0.02
		3:
			list = [
				Vector2(-370, 325),
				Vector2(-255, 325),
				Vector2(-25, 325),
				Vector2(90, 325),
				Vector2(310, 325),
				Vector2(425, 325)
			]
			jg = 0.02
		4:
			list = [
				Vector2(-255, 325),
				Vector2(-140, 325),
				Vector2(-25, 325),
				Vector2(90, 325),
				Vector2(200, 325),
				Vector2(310, 325),
				Vector2(425, 325)
			]
			jg = 0.4
			list.reverse()
			for i in list:
				Global.add_bullet(
					"Monster56Bullet", bullet, false, 1, i + position, "hit2", self.obj_attack_dict["hit2"]
				)
				await get_tree().create_timer(jg, false).timeout
			await get_tree().create_timer(1.8, false).timeout
			list = [
				Vector2(-370, 325),
				Vector2(-255, 325),
				Vector2(-140, 325),
				Vector2(-25, 325),
				Vector2(90, 325),
				Vector2(200, 325),
				Vector2(310, 325)
			]
			for i in list:
				Global.add_bullet(
					"Monster56Bullet", bullet, false, 1, i + position, "hit2", self.obj_attack_dict["hit2"]
				)
				await get_tree().create_timer(jg, false).timeout
			await get_tree().create_timer(1.8, false).timeout
			list = [
				Vector2(-370, 325),
				Vector2(-255, 325),
				Vector2(-140, 325),
				Vector2(200, 325),
				Vector2(310, 325),
				Vector2(425, 325)
			]
			for i in list:
				Global.add_bullet(
					"Monster56Bullet", bullet, false, 1, i + position, "hit2", self.obj_attack_dict["hit2"]
				)
				await get_tree().create_timer(0, false).timeout
			await get_tree().create_timer(1.8, false).timeout
			list = [
				Vector2(-255, 325),
				Vector2(-140, 325),
				Vector2(-25, 325),
				Vector2(90, 325),
				Vector2(200, 325),
				Vector2(310, 325)
			]
			for i in list:
				Global.add_bullet(
					"Monster56Bullet", bullet, false, 1, i + position, "hit2", self.obj_attack_dict["hit2"]
				)
				await get_tree().create_timer(0, false).timeout
			await get_tree().create_timer(2, false).timeout
			throw = true
			return
	for i in list:
		Global.add_bullet("Monster56Bullet", bullet, false, 1, i + position, "hit2", self.obj_attack_dict["hit2"])
		await get_tree().create_timer(jg, false).timeout
	throw = true
	pass


func otherjg():
	for i in range(randi_range(3, throw_cout * 2)):
		Global.add_bullet(
			"Monster56Bullet",
			bullet,
			false,
			1,
			Vector2(randi_range(-370, 425), 325) + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)

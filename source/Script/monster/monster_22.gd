extends BaseMonster
class_name Monster22
var moving_right = true
var moving_left = false
var boss_2: Monster23


func monster_22():
	if get_parent().get_parent() is LevelNMGHDGQ:
		self.cannot_attract = true
		self.is_bt = true
		self.is_boss = true
		self.my_mr_name = "牛魔王·兽"
		self.attack_in = 0
		self.level = 50
		self.max_hp = 250000
		self.hp = self.max_hp
		self.def = 300
		self.mdef = 350
		self.crit = 105
		self.miss = 40
		self.lucky = 100
		self.htarget = 200
		self.toughness = 0
		self.ar = 100
		self.sp = 100
		self.crit_reduce = 0
		self.speed = 40
		self.mysee = 300
		self.attack_range = 85
		self.attack_desire = 70
		self.behit_calmtime = 0
		self.self_rhp = 0
		self.add_exp = 0
		self.fall_coin = 1
		self.obj_attack_dict["hit1"] = {
			"power": 1000,
			"hurtBack": [-8, -9],
			"attackKind": "physics",
			"addeffect":
			{
				"Name": "stun",
				"AddTime": 5,
				"CanAdd": true,
				"DeBuff": true,
				"DeRemove": false,
				"reduce_interval": 0.5,
				"value": 0,
				"AttackKind": "",
			}
		}
		self.obj_attack_dict["Fire"] = {"power": 1000, "hurtBack": [-4, -9], "attackKind": "magic"}
		self.fall_pro = 0.5
		self.fall_list = [
			{"name": "nmwdnhsp", "value": 1},
		]
		self.fall_stone_pro = 0
		self.fall_stone = []
		return
	self.cannot_attract = true
	self.is_bt = true
	self.is_boss = true
	self.my_mr_name = "牛魔王·兽"
	self.attack_in = 0
	self.level = 25
	self.max_hp = 5000
	self.hp = self.max_hp
	self.def = 100
	self.mdef = 150
	self.crit = 5
	self.miss = 8
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 40
	self.mysee = 300
	self.attack_range = 85
	self.attack_desire = 70
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 200

	self.obj_attack_dict["hit1"] = {"power": 300, "hurtBack": [-8, -9], "attackKind": "physics"}
	self.obj_attack_dict["Fire"] = {"power": 300, "hurtBack": [-4, -9], "attackKind": "magic"}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "nmwdnhsp", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	monster_22()
	super._ready()
	start_spawn_damage_protection()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if self.hp <= 0:
		var par = get_parent().get_parent()
		if par is Level10 or par is LevelNMGHDGQ:
			if boss_2 == null:
				boss_2 = Global.create_monster(23, get_parent(), Vector2(self.position.x, 330))


func ai_think():
	hit_name = "hit1"
	if hp > 0:
		if moving_left:
			move_left()
		else:
			move_right()


func move_left():
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1
	velocity.x = -speed * 10
	if int($change_dir.time_left) < 7:
		mr_player.play("walk")
	else:
		mr_player.play("hit1")


func move_right():
	base_damage_box.scale.x = -1
	monster_dir.scale.x = -1
	velocity.x = speed * 10
	if int($change_dir.time_left) < 7:
		mr_player.play("walk")
	else:
		mr_player.play("hit1")


func _on_change_dir_timeout() -> void:
	if moving_left:
		moving_right = true
		moving_left = false
	else:
		moving_right = false
		moving_left = true


func call_fire():
	var po = Vector2(self.position.x, self.position.y - 100)
	Global.add_bullet("Monster22Fire", self.bullet, false, 1, po, "Fire", self.obj_attack_dict["Fire"])
	pass

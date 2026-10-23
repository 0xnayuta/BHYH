extends BaseMonster
var hand_1
var hand_2
var is_set
var kl
@onready var change_loc: Timer = $change_loc
@onready var qgw: Sprite2D = $qgw

var should_empty = false


func monster_33():
	self.is_bt = true
	self.cannot_attract = true
	self.is_boss = true
	self.my_mr_name = "傀儡王"
	self.attack_in = 0
	self.level = 27
	self.max_hp = 25000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 0
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
	self.fall_coin = 500
	self.obj_attack_dict["hit1"] = {"power": 0, "hurtBack": [-4, -9], "attackKind": "physics"}
	self.obj_attack_dict["KLZD"] = {
		"power": 400,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 4,
			"DeBuff": true,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "lcgy", "value": 0},
		{"name": "tsgp", "value": 0},
	]

	enable_treasure_box = true
	treasure_box_item = "klwbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	Global.add_special_effect(mr_ani, Vector2(0, 0), "mw", Vector2(2.4, 2.4), false, 0.8)

	skill_1_cd = 10
	monster_33()
	if mr_player.has_animation("empty"):
		mr_player.play("empty")
	qgw_local(randi_range(0, 4))
	$Hide.visible = true

	add_eyes()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if self.hp <= 0:
		if hand_1 != null:
			hand_1.queue_free()
		if hand_2 != null:
			hand_2.queue_free()
		if kl != null:
			kl.hp = -100
	if hand_1 != null:
		if hand_1.death():
			$left.wait_time = 12
			$left.start()
	if hand_2 != null:
		if hand_2.death():
			$right.wait_time = 12
			$right.start()


func ai_think():
	if not is_set:
		if hand_1 == null:
			var position_left = Vector2(self.position.x - 115, self.position.y - 45)
			hand_1 = Global.create_monster(35, get_parent(), position_left)
		if hand_2 == null:
			var position_right = Vector2(self.position.x + 195, self.position.y - 70)
			hand_2 = Global.create_monster(36, get_parent(), position_right)

		is_set = true
	if self.hp <= 0:
		qgw.visible = false
		if hand_1 != null:
			hand_1.queue_free()
		if hand_2 != null:
			hand_2.queue_free()
		if kl != null:
			kl.hp = -100
	if hand_1 != null:
		if hand_1.death():
			$left.wait_time = randi_range(6, 8)
			$left.start()
	if hand_2 != null:
		if hand_2.death():
			$right.wait_time = randi_range(6, 8)
			$right.start()


func qgw_local(need_loc):
	should_empty = true
	change_loc.wait_time = 5
	change_loc.start()
	$BaseDamageBox/HurtBox/HurtBox.disabled = false
	qgw.visible = true
	var loc_x = [-5, 335, 100, -70, -235]
	var loc_y = [-40, 145, 95, 120, 80]
	qgw.position = Vector2(loc_x[need_loc], loc_y[need_loc])
	$BaseDamageBox/HurtBox/HurtBox.position = qgw.position


func add_eyes():
	var eye_1 = Global.add_special_effect(self, Vector2(15, -75), "green_eyes", Vector2(1, 1), true, 0.8)
	var eye_2 = Global.add_special_effect(self, Vector2(-50, -75), "green_eyes", Vector2(1, 1), false, 0.8)


func _on_add_eyes_timeout() -> void:
	add_eyes()


func _on_change_loc_timeout() -> void:
	if should_empty:
		hide_qgw()
	else:
		randomize()
		var loc = randi_range(0, 4)
		qgw_local(loc)


func hide_qgw():
	should_empty = false
	change_loc.wait_time = 3
	change_loc.start()
	$BaseDamageBox/HurtBox/HurtBox.disabled = true
	qgw.visible = false


func add_zd():
	var _zd = Global.call_chase_bullet(
		self.bullet,
		"Monster33Bullet",
		300,
		2.5,
		false,
		Vector2(self.position.x, self.position.y),
		"KLZD",
		self.obj_attack_dict["KLZD"]
	)


func _on_call_zd_timeout() -> void:
	return
	call_wling()


func call_wling():
	randomize()
	for i in range(randi_range(2, 4)):
		var list = [26, 27, 28, 30, 31]
		Global.create_monster(list[randi_range(0, 4)], get_parent(), Vector2(self.position.x, self.position.y + 100))


func call_left():
	if hand_1 == null:
		var position_left = Vector2(self.position.x - 115, self.position.y - 15)
		hand_1 = Global.create_monster(35, get_parent(), position_left)


func call_right():
	if hand_2 == null:
		var position_right = Vector2(self.position.x + 195, self.position.y - 40)
		hand_2 = Global.create_monster(36, get_parent(), position_right)


func _on_left_timeout() -> void:
	call_left()
	$left.stop()


func _on_right_timeout() -> void:
	call_right()
	$right.stop()

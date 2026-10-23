extends BaseMonster
class_name Monster85
@onready var special_effect_1: AnimatedSprite2D = $MonsterDir/SpecialEffect1
var is_hd: bool
var combo_count: int = 0


func monster_85():
	self.is_boss = true
	self.my_mr_name = "多闻天王"
	self.attack_in = 10
	self.level = 35
	self.max_hp = 100000
	self.hp = self.max_hp
	self.def = 170
	self.mdef = 170
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 18
	self.toughness = 0
	self.ar = 10
	self.sp = 10
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 300
	self.attack_range = 165
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {
		"power": 225,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"HitProtect": 6,
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 1,
			"reduce_interval": 0.5,
			"value": 20,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit2"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "MagicDrain",
			"AddTime": 3.0,
			"reduce_interval": 1.0,
			"value": 0,
			"CanAdd": false,
			"AttackKind": "control"
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 300,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"HitProtect": 8,
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 2,
			"reduce_interval": 0.5,
			"value": 50,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit4"] = {
		"power": 325,
		"hurtBack": [-4, -9],
		"attackKind": "real",
		"HitProtect": 15,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit5"] = {
		"power": 225,
		"hurtBack": [-4, -9],
		"attackKind": "real",
		"HitProtect": 18,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 0.55,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}
	self.obj_attack_dict["hit6"] = {
		"power": 225,
		"hurtBack": [-4, -9],
		"attackKind": "real",
		"HitProtect": 1,
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 2,
			"reduce_interval": 0.5,
			"value": 80,
			"AttackKind": "real",
			"CanAdd": true,
			"DeBuff": true,
		},
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "hylc", "value": 0},
		{"name": "hylz", "value": 0},
	]
	self.independent_fall_list = [
		{"name": "231007002", "value": 0, "chance": 0.333},
	]

	enable_treasure_box = true
	treasure_box_item = "dwtwbx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0
	super._ready()
	monster_85()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if hd > 0:
		special_effect_1.visible = true
	else:
		special_effect_1.visible = false
	if combo_count >= 6:
		is_hd = true
		special_effect_1.visible = true
		combo_count = 0
	if is_hd:
		get_hd(max_hp * 0.05, 0, 0.3)
		$ChangeHDtoSELF.start(8)
		is_hd = false


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 600:
					if skill_3_cd <= 0:
						do_hit_3()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
					if skill_2_cd <= 0:
						do_hit_2()
				if skill_1_cd <= 0:
					do_hit_1()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(12, 15)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(8, 10)
	velocity.x = 0
	hit_name = "hit3"
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(14, 16)
	velocity.x = 0
	hit_name = "hit5"
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func tween_to_top():
	if _movement_command_is_blocked():
		return
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Vector2(0, -250) + position, 1.8)

	pass


func call_ltwj():
	var fire_position1 = [Vector2(self.position.x - 80, 240), Vector2(self.position.x + 80, 240)]
	var fire_position2 = [Vector2(self.position.x - 200, 240), Vector2(self.position.x + 200, 240)]
	var fire_position3 = [Vector2(self.position.x - 320, 240), Vector2(self.position.x + 320, 240)]
	for i in range(2):
		Global.add_bullet(
			"Monster85Bullet1", self.bullet, false, 1.3, fire_position1[i], "hit3", self.obj_attack_dict["hit3"]
		)
	await get_tree().create_timer(0.2, false).timeout
	for i in range(2):
		Global.add_bullet(
			"Monster85Bullet1", self.bullet, false, 1.3, fire_position2[i], "hit3", self.obj_attack_dict["hit3"]
		)
	await get_tree().create_timer(0.2, false).timeout
	for i in range(2):
		Global.add_bullet(
			"Monster85Bullet1", self.bullet, false, 1.3, fire_position3[i], "hit3", self.obj_attack_dict["hit3"]
		)


func add_bullet():
	var target_position: Vector2
	if monster_direction:
		target_position = Vector2(55, 5)
	else:
		target_position = Vector2(-55, 5)
	var arrow = Global.add_bullet(
		"Monster85Bullet3",
		self.bullet,
		monster_direction,
		1,
		target_position + position,
		"hit1",
		self.obj_attack_dict["hit1"]
	)


func add_sd():
	var bullet_spawn_positions = [
		Vector2(-380, -45), Vector2(-190, -45), Vector2(0, -45), Vector2(190, -45), Vector2(380, -45)
	]
	for i in bullet_spawn_positions:
		Global.add_bullet(
			"Monster85Bullet2", self.bullet, monster_direction, 1, i + position, "hit5", self.obj_attack_dict["hit5"]
		)


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	var buff_target = super._on_hit_box_area_entered(area)

	combo_count += 1

	return buff_target


func _on_change_h_dto_self_timeout() -> void:
	if hd > 0:
		change_hd_cure_hp(1.2)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

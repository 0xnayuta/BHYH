extends BaseMonster
const BossXieShaSengWdww := preload("res://Script/monster/monster_14501_wdww.gd")

var is_sky = false
var round_list = []
var rolelevel = RoleProp.baseroleprop.Level
var current_stage: int = 1
var max_stage: int = 5
var has_summoned_next = false

var is_relif: bool
var is_have_wdww: bool = false
var wdww: BossXieShaSengWdww


func monster_14501():
	var stage_multiplier = 1.0 + (current_stage - 1) * 0.2
	var stage_name = ""

	match current_stage:
		1:
			stage_name = "初阶-邪·沙僧"
		2:
			stage_name = "二阶-邪·沙僧"
		3:
			stage_name = "三阶-邪·沙僧"
		4:
			stage_name = "四阶-邪·沙僧"
		5:
			stage_name = "五阶-邪·沙僧"
		_:
			stage_name = "邪·沙僧"

	self.rush_speed = 400 * stage_multiplier
	self.is_boss = true
	self.my_mr_name = stage_name
	self.attack_in = 90
	self.level = RoleProp.baseroleprop.Level + (current_stage - 1) * 5
	self.max_hp = int((100000 + int(RoleProp.baseroleprop.Level * 6000)) * stage_multiplier)
	self.hp = self.max_hp
	self.def = int((120 + int(RoleProp.baseroleprop.Level * 2)) * stage_multiplier)
	self.mdef = int((120 + int(RoleProp.baseroleprop.Level * 2)) * stage_multiplier)
	self.crit = int((15 + int(RoleProp.baseroleprop.Level * 0.6)) * stage_multiplier)
	self.miss = int((3 + int(RoleProp.baseroleprop.Level * 0.1)) * stage_multiplier)
	self.lucky = int((45 + int(RoleProp.baseroleprop.Level * 1)) * stage_multiplier)
	self.htarget = 9999
	self.toughness = (current_stage - 1) * 10
	self.ar = int((30 + int(RoleProp.baseroleprop.Level * 0.5)) * stage_multiplier)
	self.sp = int((30 + int(RoleProp.baseroleprop.Level * 0.5)) * stage_multiplier)
	self.crit_reduce = (current_stage - 1) * 5
	self.speed = 12 * stage_multiplier
	self.mysee = 500
	self.attack_range = 355
	self.attack_desire = 355
	self.behit_calmtime = 0
	self.self_rhp = max_hp * 0.0002
	self.add_exp = 1 * current_stage
	self.fall_coin = 1 * current_stage
	self.ebol = 0

	var base_power_multiplier = 1.0 + (current_stage - 1) * 0.3

	self.obj_attack_dict["hit1"] = {
		"power": int((400 + int(RoleProp.baseroleprop.Level * 8)) * base_power_multiplier),
		"hurtBack": [-7, -9],
		"attackKind": "physics",
		"HitProtect": 10
	}
	self.obj_attack_dict["hit2"] = {
		"power": int((600 + int(RoleProp.baseroleprop.Level * 12)) * base_power_multiplier),
		"hurtBack": [-7, -15],
		"attackKind": "magic",
		"HitProtect": 25,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 1.5,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": int((500 + int(RoleProp.baseroleprop.Level * 15)) * base_power_multiplier),
		"hurtBack": [-16, -9],
		"attackKind": "magic",
		"HitProtect": 8,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 1,
			"reduce_interval": 0,
			"value": 0.2,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 8,
	}

	self.fall_pro = 0.5

	match current_stage:
		1:
			self.fall_list = [{"name": "yxsp_1", "value": 1}, {"name": "bsd_1", "value": 1}]
		2:
			self.fall_list = [{"name": "yxsp_2", "value": 1}, {"name": "bsd_2", "value": 1}]
		3:
			self.fall_list = [{"name": "yxsp_3", "value": 1}, {"name": "bsd_3", "value": 1}]
		4:
			self.fall_list = [{"name": "bsd_4", "value": 1}]
		5:
			self.fall_list = [{"name": "bsd_5", "value": 1}]
		_:
			self.fall_list = [{"name": "bsd_1", "value": 1}]

	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_14501()
	skill_1_cd = 2
	skill_2_cd = 5
	skill_3_cd = 7
	skill_4_cd = 10
	has_summoned_next = false


func ai_think():
	var wdww_call_chance: float = 0.3
	var wdww_cooldown: float = 8.0
	var wdww_timer: float = 0.0

	if wdww_timer > 0:
		wdww_timer -= get_process_delta_time()

	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true

	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()

		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270:
					if skill_2_cd <= 0:
						do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_wdww()
				if count % 180 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()
			else:
				stop_move()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_wdww()
				if count % 180 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_2():
	to_hero()
	skill_2_cd = 5
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	to_hero()
	skill_3_cd = 8
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_wdww():
	to_hero()
	skill_4_cd = 20
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false


func call_attack1_bullet():
	velocity.x = 0
	var dir = monster_direction
	var fz
	if dir:
		fz = Global.call_fly_bullet(
			bullet,
			"Monster_xss_Bulet2",
			1,
			Vector2(position.x + 50, position.y - 20),
			500,
			-4000,
			"hit1",
			obj_attack_dict["hit1"]
		)
	else:
		fz = Global.call_fly_bullet(
			bullet,
			"Monster_xss_Bulet2",
			1,
			Vector2(position.x - 50, position.y - 20),
			500,
			4000,
			"hit1",
			obj_attack_dict["hit1"]
		)
	if fz:
		var sprite = fz.get_node("AnimatedSprite2D")
		if sprite:
			sprite.flip_h = dir


func call_attack1_3bullet():
	velocity.x = 0
	var dir = monster_direction
	var y_offsets = [-30, 0, 30]
	for offset in y_offsets:
		var fz
		if dir:
			fz = Global.call_fly_bullet(
				bullet,
				"Monster_xss_Bulet2",
				1,
				Vector2(position.x + 50, position.y - 20 + offset),
				500,
				-4000,
				"hit1",
				obj_attack_dict["hit1"]
			)
		else:
			fz = Global.call_fly_bullet(
				bullet,
				"Monster_xss_Bulet2",
				1,
				Vector2(position.x - 50, position.y - 20 + offset),
				500,
				4000,
				"hit1",
				obj_attack_dict["hit1"]
			)
		if fz:
			var sprite = fz.get_node("AnimatedSprite2D")
			if sprite:
				sprite.flip_h = dir


func call_attack2_bullet():
	velocity.x = 0
	var dir = monster_direction
	var fz
	if dir:
		fz = Global.call_fly_bullet(
			bullet, "Monster_xss_Bulet1", 1, Vector2(position.x + 150, 500), 10, 10, "hit2", obj_attack_dict["hit2"]
		)
	else:
		fz = Global.call_fly_bullet(
			bullet, "Monster_xss_Bulet1", 1, Vector2(position.x - 150, 500), 10, -10, "hit2", obj_attack_dict["hit2"]
		)
	if fz:
		var sprite = fz.get_node("AnimatedSprite2D")
		if sprite:
			sprite.flip_h = dir


func call_attack3_bullet():
	velocity.x = 0
	var dir = monster_direction
	var fz
	if dir:
		fz = Global.call_fly_bullet(
			bullet, "Monster63Bullet", 1, Vector2(position.x + 100, 450), 1000, -3400, "hit3", obj_attack_dict["hit3"]
		)
	else:
		fz = Global.call_fly_bullet(
			bullet, "Monster63Bullet", 1, Vector2(position.x - 100, 450), 1000, 3400, "hit3", obj_attack_dict["hit3"]
		)
	if fz:
		var sprite = fz.get_node("AnimatedSprite2D")
		if sprite:
			sprite.flip_h = not dir


func call_wdww():
	var bullet_pos: Vector2
	if direction >= 0:
		bullet_pos = Vector2(30, -30)
	else:
		bullet_pos = Vector2(-30, -30)
	var scene = preload("res://Scene/monster/monster_14501_wdww.tscn")

	if not ResourceLoader.exists("res://Scene/monster/monster_14501_wdww.tscn"):
		print("错误：文件不存在")
		return
	wdww = Global.instance_scene(scene, get_parent())
	wdww.entity = self
	wdww.position = bullet_pos

	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(wdww) and wdww != null:
		wdww.queue_free()

		is_have_wdww = false
		wdww = null


func state_death():
	super.state_death()

	await get_tree().create_timer(0.5).timeout

	if current_stage < max_stage and not has_summoned_next:
		_summon_next_stage()


func _summon_next_stage():
	has_summoned_next = true

	var next_boss_scene := Global.load_scene_uncached("res://Scene/monster/monster_14501.tscn")
	if next_boss_scene == null:
		return
	var next_boss = next_boss_scene.instantiate() as BaseMonster

	next_boss.current_stage = current_stage + 1
	next_boss.position = position + Vector2(randi_range(-50, 50), 0)

	get_parent().add_child(next_boss)

	Global.add_message_show(
		get_parent(),
		"召唤了%s！" % ["初阶-邪·沙僧", "二阶-邪·沙僧", "三阶-邪·沙僧", "四阶-邪·沙僧", "五阶-邪·沙僧"][next_boss.current_stage - 1],
		2.0,
		Vector2(470, 200)
	)

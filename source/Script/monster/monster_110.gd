extends BaseMonster
class_name Monster110
var aex
var is_rush: bool


func monster_110():
	self.rush_speed = 500
	self.is_boss = true
	self.my_mr_name = "青牛精"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 300000
	self.hp = self.max_hp
	self.def = 180
	self.mdef = 180
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 35
	self.sp = 35
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 500
	self.attack_range = 235
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 300
	self.fall_coin = 335
	self.obj_attack_dict["hit1"] = {
		"power": 300,
		"hurtBack": [-5, -9],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 400,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0,
			"value": 0.4,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 800,
		"hurtBack": [-2, -1],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 1,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "qljzzs", "value": 1},
		{"name": "plpzzs", "value": 1},
		{"name": "ylkzzs", "value": 1},
		{"name": "jljzzs", "value": 1},
		{"name": "tljzzs", "value": 1},
		{"name": "231007004zzs", "value": 1},
	]

	enable_treasure_box = true
	treasure_box_item = "qnjbx"

	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_110()
	skill_1_cd = randi_range(2, 5)
	skill_2_cd = randi_range(4, 6)


func ai_think():
	if is_rush:
		if monster_direction:
			velocity.x = 600
		else:
			velocity.x = -600
		return
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if skill_2_cd <= 0:
					do_hit_2()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 360:
					if skill_1_cd <= 0:
						do_hit_1()
			else:
				stop_move()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_1_cd <= 0:
					do_hit_1()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func do_hit_1():
	super.to_hero()
	skill_1_cd = randi_range(8, 10)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	super.to_hero()
	skill_2_cd = randi_range(15, 17)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_aex():
	var pp = Vector2(self.position.x, self.position.y)
	var tween = get_tree().create_tween()
	aex = Global.add_bullet("Monster110Bullet", bullet, false, 1, pp, "hit2", self.obj_attack_dict["hit2"])
	tween.tween_property(aex, "position", RoleProp.get_nearest_monster_target_position(global_position), 0.5)
	await get_tree().create_timer(2.5, false).timeout


func _return_to_spawn():
	if aex != null:
		var tween = get_tree().create_tween()
		var pp = Vector2(self.position.x, self.position.y)
		tween.tween_property(aex, "position", pp, 0.3)
		await get_tree().create_timer(0.28, false).timeout
		aex.queue_free()


func call_gc():
	var gc: MonsterBullet
	var bullet_spawn_positions: Array[Vector2] = []
	if monster_direction:
		bullet_spawn_positions = [
			Vector2(40, 55), Vector2(140, 55), Vector2(240, 55), Vector2(340, 55), Vector2(440, 55)
		]
	else:
		bullet_spawn_positions = [
			Vector2(-40, 55), Vector2(-140, 55), Vector2(-240, 55), Vector2(-340, 55), Vector2(-440, 55)
		]
	for i in bullet_spawn_positions:
		gc = Global.add_bullet(
			"Monster32Bullet", self.bullet, monster_direction, 1, i + position, "hit1", self.obj_attack_dict["hit1"]
		)
		gc.scale = Vector2(1.2, 1)
		await get_tree().create_timer(0.2, false).timeout


func begin():
	is_rush = true


func end():
	is_rush = false

extends BaseMonster
class_name Monster18
var is_need_change = true
var move_le = false
var move_ri = false


func monster_18():
	self.is_boss = true
	self.my_mr_name = "蛟魔王"
	self.attack_in = 30
	self.level = 23
	self.max_hp = 7000
	self.hp = self.max_hp
	self.def = 100
	self.mdef = 150
	self.crit = 15
	self.miss = 5
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 300
	self.attack_range = 95
	self.attack_desire = 90
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 200
	self.fall_coin = 200
	self.obj_attack_dict["hit1"] = {"power": 165, "hurtBack": [-4, -9], "attackKind": "physics"}
	self.obj_attack_dict["fhjl"] = {
		"power": 228,
		"hurtBack": [-10, -5],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3,
			"reduce_interval": 0,
			"DeBuff": true,
			"CanAdd": false,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["dtsz"] = {
		"power": 200,
		"hurtBack": [-22, -15],
		"attackKind": "real",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0,
			"CanAdd": false,
			"DeBuff": true,
			"value": 0.4,
			"AttackKind": "",
		}
	}

	self.fall_pro = 0.5
	self.fall_list = [{"name": "xwj", "value": 0}, {"name": "bxp", "value": 0}, {"name": "pxk", "value": 0}]
	self.independent_fall_list = [
		{"name": "211007002", "value": 0, "chance": 0.25},
	]

	enable_treasure_box = true
	treasure_box_item = "jmwbx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_18()
	skill_1_cd = 0
	skill_2_cd = 0


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if skill_2_cd <= 0:
				whencando_hit3()
				return
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 300:
					if skill_1_cd <= 0:
						do_hit_2()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				elif count % 90 == 0:
					var rad = randi_range(0, 100)
					if rad <= attack_desire:
						attack_target()
				else:
					stop_move()


func do_hit_2():
	skill_1_cd = 7
	hit_name = "fhjl"
	velocity.x = 0
	is_attacking = true
	mr_player.play("fhjl")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	skill_2_cd = 15
	velocity.x = 0
	hit_name = "dtsz"
	is_attacking = true
	mr_player.play("dtsz")
	await mr_player.animation_finished
	is_attacking = false


func call_fhjl():
	if self.monster_direction:
		Global.add_bullet(
			"Monster18Bullet_1",
			self.bullet,
			self.monster_direction,
			1,
			Vector2(self.position.x + 80, self.position.y - 10),
			"fhjl",
			self.obj_attack_dict["fhjl"]
		)
	else:
		Global.add_bullet(
			"Monster18Bullet_1",
			self.bullet,
			self.monster_direction,
			1,
			Vector2(self.position.x - 80, self.position.y - 10),
			"fhjl",
			self.obj_attack_dict["fhjl"]
		)


func call_dtsz():
	var bullet_spawn_positions = []
	if self.monster_direction == false:
		bullet_spawn_positions = [
			Vector2(self.position.x - 120, self.position.y - 250),
			Vector2(self.position.x - 270, self.position.y - 250),
			Vector2(self.position.x - 420, self.position.y - 250),
			Vector2(self.position.x - 570, self.position.y - 250),
			Vector2(self.position.x - 720, self.position.y - 250)
		]
	else:
		bullet_spawn_positions = [
			Vector2(self.position.x + 120, self.position.y - 250),
			Vector2(self.position.x + 270, self.position.y - 250),
			Vector2(self.position.x + 420, self.position.y - 250),
			Vector2(self.position.x + 570, self.position.y - 250),
			Vector2(self.position.x + 720, self.position.y - 250)
		]
	for i in range(5):
		Global.add_bullet(
			"Monster18Bullet_2",
			self.bullet,
			self.monster_direction,
			1,
			bullet_spawn_positions[i],
			"dtsz",
			self.obj_attack_dict["dtsz"]
		)
		await get_tree().create_timer(0.32, false).timeout


func whencando_hit3():
	var pp = get_parent().get_parent()
	if skill_1_cd <= 0:
		do_hit_2()
	elif count % 90 == 0:
		var rad = randi_range(0, 100)
		if rad <= attack_desire:
			attack_target()
	elif abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) < 170:
		if is_need_change:
			match int(pp.current_stage):
				1:
					if position.x > 750:
						move_le = true
						move_ri = false
						move_left()
					elif position.x <= 200:
						move_ri = true
						move_le = false
						move_right()
					else:
						move_le = true
						move_ri = false
						move_left()
				2:
					if position.x > 200:
						move_le = true
						move_ri = false
						move_left()
					else:
						move_ri = true
						move_le = false
						move_right()
				3:
					if position.x > 330:
						move_le = true
						move_ri = false
						move_left()
					else:
						move_ri = true
						move_le = false
						move_right()
				4:
					if position.x > 4330:
						move_le = true
						move_ri = false
						move_left()
					elif position.x <= 3670:
						move_ri = true
						move_le = false
						move_right()
					else:
						move_le = true
						move_ri = false
						move_left()
			is_need_change = false
		else:
			if move_le:
				move_left()
			elif move_ri:
				move_right()
	else:
		if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= 170:
			if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
				move_right()
			else:
				move_left()
			do_hit_3()


func _on_change_dir_timeout(_extra = null):
	is_need_change = true

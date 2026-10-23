extends BaseMonster
var my_brother


func monster_78():
	self.is_boss = true
	self.my_mr_name = "顺风耳"
	self.attack_in = 15
	self.level = 35
	self.max_hp = 40000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 20
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 400
	self.attack_range = 350
	self.attack_desire = 75
	self.behit_calmtime = 0.3
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 100
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-7, -9],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 0.5,
			"DeBuff": true,
			"AttackKind": "",
			"CanAdd": false,
		}
	}
	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "xhz", "value": 0},
		{"name": "kys", "value": 0},
	]
	self.independent_fall_list = [
		{"name": "231007001", "value": 0, "chance": 0.333},
	]

	enable_treasure_box = true
	treasure_box_item = "qlysfebx"

	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0.2
	self.fall_stone = [
		{"name": "smlp", "value": randi_range(1, 2)},
	]


func _ready() -> void:
	super._ready()
	monster_78()
	skill_1_cd = 0


func ai_think():
	get_monster_76()
	if my_brother != null:
		self.def = 600
		self.mdef = 600
	else:
		self.def = 150
		self.mdef = 150
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_1_cd <= 0:
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 1200:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				else:
					if count % 60 == 0:
						if randi_range(0, 100) < attack_desire:
							attack_target()
						else:
							stop_move()
					else:
						stop_move()


func do_hit_2():
	to_hero()
	skill_1_cd = 5
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false


func get_monster_76():
	if self.is_boss:
		var tta = get_parent().get_children()
		for i in tta:
			if i is Monster77:
				my_brother = i


func strength():
	if my_brother != null:
		my_brother.cure_hp(max_hp * 0.4)
		for i in my_brother.obj_attack_dict:
			if my_brother.obj_attack_dict[i].has("power"):
				my_brother.obj_attack_dict[i]["power"] *= 1.05


func add_child_2():
	var po: Vector2
	if monster_direction:
		po = Vector2(60, 5)
	else:
		po = Vector2(-60, 5)
	var child = Global.add_bullet(
		"Monster78Bullet", bullet, monster_direction, 2, position + po, "hit1", self.obj_attack_dict["hit1"]
	)

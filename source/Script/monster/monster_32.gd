extends BaseMonster
class_name Monster32
var get_hero: BaseHero
@onready var wing: AnimatedSprite2D = $MonsterDir/Wing

@onready var mr_player_1: AnimationPlayer = $mr_player


func monster_32():
	_current = 0
	self.is_boss = true
	self.my_mr_name = "白骨精·精"
	self.attack_in = 120
	self.level = 30
	self.max_hp = 20000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 30
	self.sp = 30
	self.crit_reduce = 0
	self.speed = 9
	self.mysee = 300
	self.attack_range = 85
	self.attack_desire = 50
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {"power": 350, "hurtBack": [-6, -9], "attackKind": "physics"}
	self.obj_attack_dict["dmzw"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "EyeFix",
			"AddTime": 5,
			"CanAdd": false,
			"DeBuff": true,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
		}
	}
	self.obj_attack_dict["dmlhc"] = {
		"power": 280,
		"hurtBack": [-6, -8],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "Bleed",
			"CanAdd": true,
			"AddTime": 2,
			"reduce_interval": 0.5,
			"value": 5 + int(RoleProp.roleprop.SHp * 0.01),
			"AttackKind": "physics",
		}
	}
	self.fall_pro = 0.3
	self.fall_list = [
		{"name": "bsxj", "value": 0},
		{"name": "bszj", "value": 0},
		{"name": "bsyz", "value": 0},
		{"name": "bsbc", "value": 0},
		{"name": "bshq", "value": 0},
	]

	enable_treasure_box = true
	self.treasure_box_item = "bgjbx1"
	update_fall_mode()
	self.fall_stone_pro = 0
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_32()
	is_bounds = false
	skill_1_cd = 0
	skill_2_cd = 0
	wing.set_frame_and_progress(0, true)


func ai_think():
	if self._current < 3:
		wing.set_frame_and_progress(self._current, true)
	if not self.is_bounds:
		if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
			has_target = true
		if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
			if has_target == false:
				normal_state()
			else:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
					have_target()
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 1200:
						if skill_1_cd <= 0:
							do_hit_2()
					if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 400:
						if skill_2_cd <= 0:
							do_hit_3()
				else:
					if skill_1_cd <= 0:
						do_hit_2()
					elif skill_2_cd <= 0:
						do_hit_3()
					elif count % 60 == 0:
						attack_target()
					else:
						stop_move()


func attack_target():
	super.attack_target()


func do_hit_2():
	if self._current == 0:
		skill_1_cd = 16
	elif self._current == 1:
		to_hero()
		skill_1_cd = 10
	elif self._current == 2:
		to_hero()
		skill_1_cd = 8
	hit_name = "dmzw"
	velocity.x = 0
	is_attacking = true
	mr_player.play("dmzw")
	await mr_player.animation_finished
	is_attacking = false


func do_hit_3():
	if self._current == 0:
		skill_2_cd = 15
	elif self._current == 1:
		skill_2_cd = 12
	elif self._current == 2:
		skill_2_cd = 9
	velocity.x = 0
	hit_name = "dmlhc"
	is_attacking = true
	mr_player.play("dmlhc")
	await mr_player.animation_finished
	is_attacking = false


func turn_bounds():
	await get_tree().create_timer(6.0).timeout
	turn_relive()


func turn_relive():
	mr_player.play("relife")


func _on_relive_timeout() -> void:
	turn_relive()
	is_fall = false
	$Relive.stop()


func relive():
	self._current += 1
	match self._current:
		1:
			skill_1_cd = 0
			skill_2_cd = 0
			self.my_mr_name = "白骨精·妖"
			self.max_hp = 30000
			self.hp = self.max_hp
			self.def = 150
			self.mdef = 150
			self.crit = 10
			self.attack_desire = 70
			self.obj_attack_dict["dmlhc"] = {
				"power": 400,
				"hurtBack": [-12, -15],
				"attackKind": "magic",
				"addeffect":
				{
					"Name": "Bleed",
					"AddTime": 2,
					"CanAdd": true,
					"DeBuff": true,
					"reduce_interval": 1,
					"value": 5 + int(RoleProp.roleprop.SHp * 0.01),
					"AttackKind": "physics",
				}
			}
			self.fall_pro = 0.5
			self.fall_list = [
				{"name": "bsxj", "value": 0},
				{"name": "bszj", "value": 0},
				{"name": "bsyz", "value": 0},
				{"name": "bsbc", "value": 0},
				{"name": "bshq", "value": 0},
			]

			treasure_box_item = "bgjbx1"
			update_fall_mode()
		2:
			skill_1_cd = 0
			skill_2_cd = 0
			self.my_mr_name = "白骨精·魔"
			self.max_hp = 50000
			self.hp = self.max_hp
			self.def = 200
			self.mdef = 200
			self.crit = 10
			self.attack_desire = 100
			self.obj_attack_dict["dmlhc"] = {
				"power": 400,
				"hurtBack": [-12, -19],
				"attackKind": "magic",
				"addeffect":
				{
					"Name": "Bleed",
					"AddTime": 2,
					"CanAdd": true,
					"DeBuff": true,
					"reduce_interval": 0.5,
					"value": 5 + int(RoleProp.roleprop.SHp * 0.01),
					"AttackKind": "physics",
				}
			}
			self.fall_pro = 0.5
			self.fall_list = [
				{"name": "csgs", "value": 0},
			]
			self.fall_stone_pro = 0.3
			self.fall_stone = [
				{"name": "bszy", "value": 0},
			]

			treasure_box_item = "bgjbx2"
			update_fall_mode()
	self.is_bounds = false

	_is_set = false


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
			"Monster32Bullet", self.bullet, monster_direction, 0.8, i + position, "dmlhc", self.obj_attack_dict["dmlhc"]
		)
		match self._current:
			0:
				gc.scale.x = 1
				gc.scale.y = 0.7
			1:
				gc.scale.x = 1.2
				gc.scale.y = 1
			2:
				gc.scale.x = 1.5
				gc.scale.y = 1.5
		await get_tree().create_timer(0.2, false).timeout


func eye_fix():
	if not is_instance_valid(get_player):
		return
	if self.position.x > RoleProp.get_nearest_monster_target_position(global_position).x:
		if get_player.player_dir:
			if not monster_direction:
				add_eye_fix()
	else:
		if not get_player.player_dir:
			if monster_direction:
				add_eye_fix()


func add_eye_fix():
	(
		Global
		. add_buff(
			get_player.buff,
			{
				"Name": "EyeFix",
				"AddTime": 5,
				"reduce_interval": 0.0,
				"value": 0,
				"AttackKind": "",
				"DeBuff": true,
				"CanAdd": false,
			}
		)
	)


func mark_bounds():
	is_bounds = true


func state_death():
	set_exp()
	set_gxp()
	velocity.x = 0

	if _current < _max:
		if is_bounds:
			return
		mr_player_1.play("bounds")
		if PlayerData.player_data.has(my_mr_name):
			var current = PlayerData.player_data[my_mr_name]
			if not base_level is Lhhj:
				PlayerData.player_data[my_mr_name] += 1

				return
		else:
			pass
	else:
		settle_death_drops()
		mr_player.play("death")
		if not is_death:
			if PlayerData.player_data.has(my_mr_name):
				var current = PlayerData.player_data[my_mr_name]
				if not base_level is Lhhj:
					PlayerData.player_data[my_mr_name] += 1
		is_death = true
		await mr_player.animation_finished

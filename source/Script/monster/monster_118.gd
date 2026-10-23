extends BaseMonster


func monster_118():
	self.is_boss = false
	self.my_mr_name = "地狱练气师"
	self.attack_in = 20
	self.level = 55
	self.max_hp = 45000
	self.hp = self.max_hp
	self.def = 300
	self.mdef = 300
	self.crit = 25
	self.miss = 25
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 60
	self.sp = 60
	self.crit_reduce = 0
	self.speed = 12
	self.mysee = 600
	self.attack_range = 225
	self.attack_desire = 80
	self.behit_calmtime = 0.1
	self.self_rhp = 0
	self.add_exp = 240
	self.fall_coin = 240
	self.obj_attack_dict["hit1"] = {"power": 500, "hurtBack": [-6, -5], "attackKind": "magic"}
	self.obj_attack_dict["hit2"] = {
		"power": 800,
		"hurtBack": [-6, -5],
		"attackKind": "magic",
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 5,
			"CanAdd": true,
			"DeBuff": true,
			"CanRemove": false,
			"reduce_interval": 1,
			"value": 900,
			"AttackKind": "magic",
		}
	}
	self.fall_pro = 0.0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_118()
	skill_1_cd = 5


func ai_think():
	var role_position_x = RoleProp.get_nearest_monster_target_position(global_position).x
	if role_position_x == null:
		has_target = false
		stop_move()
		return
	var distance := absf(float(role_position_x) - position.x)
	has_target = distance < mysee
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if distance > attack_range:
				have_target()
				if skill_1_cd <= 0:
					if distance <= 300:
						do_hit_2()
					else:
						have_target()
				else:
					have_target()
			else:
				if skill_1_cd <= 0:
					do_hit_2()
				else:
					if count % 90 == 0:
						attack_target()
					else:
						stop_move()


func do_hit_2():
	skill_1_cd = 5
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false


func call_bullet_1():
	var bullet_node
	var bullet_parent: Node = self.bullet
	var level_node := get_level_node()
	if level_node != null:
		var level_bullet := level_node.get_node_or_null("Bullet")
		if level_bullet != null:
			bullet_parent = level_bullet
	elif get_tree() != null and get_tree().current_scene != null:
		bullet_parent = get_tree().current_scene
	var hit_data: Dictionary = self.obj_attack_dict["hit2"].duplicate(true)
	if self.monster_direction:
		bullet_node = Global.add_bullet(
			"Monster118Bullet2", bullet_parent, false, 1, Vector2(35, 25) + global_position, "hit2", hit_data
		)
	else:
		bullet_node = Global.add_bullet(
			"Monster118Bullet2", bullet_parent, false, 1, Vector2(-35, 25) + global_position, "hit2", hit_data
		)
	if bullet_node != null and get_player != null:
		bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))


func state_death():
	mr_player.play("death")

	await mr_player.animation_finished

	call_bullet_1()
	settle_death_drops_and_free()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

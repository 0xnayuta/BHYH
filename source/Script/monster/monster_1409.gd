extends BaseMonster

static var instance_count: int = 0

var alternate_side: bool = false
var is_reviving: bool = false
var has_been_controlled: bool = false


func init_monster(is_boss_flag: bool):
	self.rush_speed = 700
	self.is_boss = is_boss_flag
	self.my_mr_name = "千年蜈蚣"
	self.attack_in = 130
	self.level = 59

	var hp_multiplier = 1.0 if is_boss_flag else 0.5
	self.max_hp = int(1950000 * hp_multiplier)
	self.hp = self.max_hp

	self.def = 680
	self.mdef = 680
	self.crit = 38
	self.miss = 58
	self.lucky = 83
	self.htarget = 98
	self.toughness = 43
	self.ar = 120
	self.sp = 120
	self.crit_reduce = 20
	self.speed = 15
	self.mysee = 550
	self.attack_range = 280
	self.attack_desire = 100
	self.behit_calmtime = 0.05
	self.self_rhp = 0

	self.add_exp = 6000 if is_boss_flag else 3000
	self.fall_coin = 2500 if is_boss_flag else 1250
	self.ebol = 0

	self.obj_attack_dict["hit1"] = {
		"power": 1200,
		"hurtBack": [-10, -12],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 1000,
		"hurtBack": [-20, -10],
		"attackKind": "magic",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0.61,
			"value": 0.5,
			"AttackKind": "magic",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit3"] = {
		"power": 1500,
		"hurtBack": [-8, -12],
		"attackKind": "physics",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Immobilize",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 1,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}

	self.obj_attack_dict["hit5"] = {
		"power": 1800,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
		"addeffect":
		{
			"Name": "Immobilize",
			"AddTime": 2,
			"reduce_interval": 0,
			"value": 1,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}

	if is_boss_flag:
		self.fall_pro = 0.5
		self.fall_list = [
			{"name": "ttsl2", "value": 1},
			{"name": "shenhuo_2", "value": 1},
		]
		self.fall_stone_pro = 0
		self.fall_stone = [
			{"name": "sichou", "value": randi_range(1, 2)},
			{"name": "xuantie", "value": randi_range(1, 2)},
			{"name": "tanmu", "value": randi_range(1, 2)},
		]
	else:
		self.fall_pro = 0.0
		self.fall_list.clear()
		self.fall_stone_pro = 0
		self.fall_stone.clear()


func _ready() -> void:
	var is_clone = has_meta("is_clone") and get_meta("is_clone")
	init_monster(not is_clone)

	super._ready()

	skill_1_cd = 2
	skill_2_cd = 8
	skill_3_cd = 15
	skill_4_cd = 20
	skill_5_cd = 30

	instance_count += 1

	if buff:
		buff.connect("child_entered_tree", Callable(self, "_on_buff_child_entered"))


func _exit_tree() -> void:
	super._exit_tree()

	instance_count -= 1


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
				have_target()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()
				if skill_5_cd <= 0:
					do_hit_5()
			else:
				stop_move()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_2_cd <= 0:
					do_hit_2()
				if skill_3_cd <= 0:
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()
				if skill_5_cd <= 0:
					do_hit_5()


func do_hit_1():
	if skill_1_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_1_cd = 2
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	if skill_2_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_2_cd = randi_range(20, 30)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	if skill_3_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_3_cd = randi_range(25, 30)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_2():
	var wave_offsets = [
		[Vector2(0, -20), Vector2(0, 20)],
		[Vector2(0, -40), Vector2(0, 40)],
		[Vector2(0, -60), Vector2(0, 60)],
	]

	var player = get_player if get_player else null
	var base_attack = self.obj_attack_dict["hit2"]
	var multiplier = 1.0

	for wave_idx in range(wave_offsets.size()):
		var attack_data = base_attack.duplicate(true)
		attack_data["power"] = base_attack["power"] * multiplier

		for offset in wave_offsets[wave_idx]:
			var bullet_pos = position + offset
			var bullet_instance = Global.add_bullet(
				"Monster1409Bullet2", self.bullet, false, 1, bullet_pos, "hit2", attack_data
			)
			if bullet_instance and player:
				var horizontal_target = Vector2(player.position.x, bullet_instance.position.y)
				bullet_instance.look_at(horizontal_target)

		await get_tree().create_timer(0.3, false).timeout
		multiplier *= 1.3


func move_player_2():
	if not get_player:
		return

	var offset = 150
	if alternate_side:
		self.position = Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x + offset,
			RoleProp.get_nearest_monster_target_position(global_position).y
		)
	else:
		self.position = Vector2(
			RoleProp.get_nearest_monster_target_position(global_position).x - offset,
			RoleProp.get_nearest_monster_target_position(global_position).y
		)

	alternate_side = not alternate_side


func _on_buff_child_entered(child: Node):
	if child is BaseBuff:
		var buff_name = child.buff_info.get("Name", "")
		if buff_name in ["stun", "Ice", "Immobilize"]:
			has_been_controlled = true


func revive_and_summon():
	is_reviving = true

	await get_tree().create_timer(0.5, false).timeout

	var has_control_now = false
	if buff:
		for b in buff.get_children():
			if b is BaseBuff and b.buff_info.get("Name", "") in ["stun", "Ice", "Immobilize"]:
				has_control_now = true
				break

	if has_been_controlled or has_control_now or instance_count >= 4:
		is_reviving = false
		state_death()
		return

	self.hp = self.max_hp
	self.is_death = false
	has_been_controlled = false

	if buff:
		for b in buff.get_children():
			if b is BaseBuff and b.buff_info.get("Name", "") in ["stun", "Ice", "Immobilize"]:
				b.queue_free()

	velocity = Vector2.ZERO
	if mr_player and mr_player.has_animation("idle"):
		mr_player.play("idle")
	elif mr_player and mr_player.has_animation("wait"):
		mr_player.play("wait")

	if instance_count < 4:
		var scene_path = scene_file_path
		if scene_path:
			var new_monster = Global.preload_scene_path(scene_path).instantiate()

			new_monster.set_meta("is_clone", true)
			new_monster.position = position + Vector2(randi_range(-100, 100), randi_range(-30, 30))
			get_parent().add_child(new_monster)

	is_reviving = false


func state_death():
	if is_reviving:
		return

	var has_control_now = false
	if buff:
		for b in buff.get_children():
			if b is BaseBuff and b.buff_info.get("Name", "") in ["stun", "Ice", "Immobilize"]:
				has_control_now = true
				break

	if not has_been_controlled and not has_control_now and instance_count < 4 and not is_reviving:
		revive_and_summon()
		return

	super.state_death()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

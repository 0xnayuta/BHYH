extends BaseMonster

static var instance_count: int = 0
const LIGHT_ORB_LIFE_SECONDS := 10
const LIGHT_ORB_COOLDOWN_AFTER_END_SECONDS := 55

var alternate_side: bool = false
var is_reviving: bool = false
var has_been_controlled: bool = false
var next_light_orb_cast_msec: int = 0

var is_invincible: bool = false
var clone_count: int = 0
var is_weakened_clone: bool = false


func set_invincible(enabled: bool):
	is_invincible = enabled
	print("Monster1410: 无敌状态 = ", enabled)


func on_clone_spawned():
	clone_count += 1
	print("分身生成，当前分身数量 = ", clone_count)
	if clone_count == 1:
		set_invincible(true)


func on_clone_died():
	if clone_count <= 0:
		print("警告：分身死亡时 clone_count 已经 <= 0，跳过递减")
		return
	clone_count -= 1
	print("分身死亡，当前分身数量 = ", clone_count)
	if clone_count == 0:
		set_invincible(false)


func spawn_clone():
	var scene_path = scene_file_path
	if scene_path.is_empty():
		return
	var clone = Global.preload_scene_path(scene_path).instantiate()
	clone.set_meta("is_clone", true)
	clone.set_meta("owner_monster", self)

	if clone.has_meta("_death_reported"):
		clone.remove_meta("_death_reported")
	clone.is_boss = false
	clone.init_monster(false)
	clone.position = position + Vector2(randi_range(-80, 80), randi_range(-50, 50))
	get_parent().add_child(clone)
	on_clone_spawned()


func init_monster(is_boss_flag: bool):
	self.rush_speed = 700
	self.is_boss = is_boss_flag
	self.my_mr_name = "千年妖蝉"
	self.attack_in = 130
	self.level = 59

	var hp_multiplier = 1.0 if is_boss_flag else 0.5
	self.max_hp = int(2100000 * hp_multiplier)
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
	self.attack_range = 160
	self.attack_desire = 100
	self.behit_calmtime = 0.05
	self.self_rhp = 0

	self.add_exp = 6000 if is_boss_flag else 3000
	self.fall_coin = 2500 if is_boss_flag else 1250
	self.ebol = 0

	self.obj_attack_dict["hit1"] = {
		"power": 1500,
		"hurtBack": [-5, -12],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit2"] = {
		"power": 1700,
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
		"power": 1800,
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
	self.obj_attack_dict["hit4"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit5"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
	}
	self.obj_attack_dict["hit6"] = {
		"power": 10,
		"hurtBack": [0, 0],
		"attackKind": "real",
		"HitProtect": 10,
	}

	if is_boss_flag:
		self.fall_pro = 0.5
		self.fall_list = [
			{"name": "ttsl3", "value": 1},
			{"name": "shenhuo_3", "value": 1},
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

	if has_meta("is_clone") and get_meta("is_clone"):
		is_weakened_clone = true
		var weaken = 0.3
		self.max_hp = int(self.max_hp * 0.6)
		self.hp = self.max_hp
		self.def = int(self.def * weaken)
		self.mdef = int(self.mdef * weaken)
		self.crit = int(self.crit * weaken)
		self.miss = int(self.miss * weaken)
		self.lucky = int(self.lucky * weaken)
		self.htarget = int(self.htarget * weaken)
		self.toughness = int(self.toughness * weaken)
		self.ar = int(self.ar * weaken)
		self.sp = int(self.sp * weaken)
		self.crit_reduce = int(self.crit_reduce * weaken)

		self.add_exp = int(self.add_exp * weaken)
		self.fall_coin = int(self.fall_coin * weaken)

		for key in self.obj_attack_dict.keys():
			if self.obj_attack_dict[key].has("power"):
				self.obj_attack_dict[key]["power"] = int(self.obj_attack_dict[key]["power"] * weaken)


func _ready() -> void:
	var is_clone = has_meta("is_clone") and get_meta("is_clone")
	init_monster(not is_clone)

	super._ready()

	skill_1_cd = 2
	skill_2_cd = 10
	skill_3_cd = 22
	skill_4_cd = 20
	skill_5_cd = 50

	instance_count += 1

	if buff:
		buff.connect("child_entered_tree", Callable(self, "_on_buff_child_entered"))


func _exit_tree() -> void:
	super._exit_tree()
	instance_count -= 1


func _on_buff_child_entered(child: Node):
	if child is BaseBuff:
		var buff_name = child.buff_info.get("Name", "")
		if buff_name in ["stun", "Ice", "Immobilize"]:
			has_been_controlled = true


func ai_think():
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if (
					abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 160
					and skill_1_cd <= 0
				):
					do_hit_1()
				if (
					abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 290
					and skill_2_cd <= 0
				):
					do_hit_2()
				if (
					abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 270
					and skill_3_cd <= 0
				):
					do_hit_3()
				if skill_4_cd <= 0:
					do_hit_4()
				if _can_cast_light_orb():
					do_hit_5()
			else:
				if skill_1_cd <= 0:
					do_hit_1()
				elif skill_2_cd <= 0:
					do_hit_2()
				elif skill_3_cd <= 0:
					do_hit_3()
				elif skill_4_cd <= 0:
					do_hit_4()
				elif _can_cast_light_orb():
					do_hit_5()
				else:
					stop_move()


func do_hit_1():
	if skill_1_cd > 0 or is_attacking:
		return
	super.to_hero()
	var cd_base = randi_range(1, 3)
	skill_1_cd = int(cd_base * (1.3 if is_weakened_clone else 1.0))
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	if is_weakened_clone:
		return
	if skill_2_cd > 0 or is_attacking:
		return
	super.to_hero()
	var cd_base = randi_range(10, 20)
	skill_2_cd = int(cd_base * (1.3 if is_weakened_clone else 1.0))
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3(ignore_cd := false):
	if is_attacking:
		return
	if not ignore_cd and skill_3_cd > 0:
		return
	super.to_hero()
	if not ignore_cd:
		var cd_base = randi_range(25, 30)
		skill_3_cd = int(cd_base * (1.3 if is_weakened_clone else 1.0))
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	if skill_4_cd > 0 or is_attacking:
		return
	super.to_hero()
	var cd_base = randi_range(20, 25)
	skill_4_cd = int(cd_base * (1.3 if is_weakened_clone else 1.0))
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	do_hit_3(true)


func do_hit_5():
	if is_weakened_clone:
		return
	if not _can_cast_light_orb() or is_attacking:
		return
	super.to_hero()
	var cd_base = LIGHT_ORB_LIFE_SECONDS + LIGHT_ORB_COOLDOWN_AFTER_END_SECONDS
	skill_5_cd = int(cd_base * (1.3 if is_weakened_clone else 1.0))
	next_light_orb_cast_msec = Time.get_ticks_msec() + cd_base * 1000
	hit_name = "hit5"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2_1")
	MonsterBullet.explode_all_1410()
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func _can_cast_light_orb() -> bool:
	return skill_5_cd <= 0 and Time.get_ticks_msec() >= next_light_orb_cast_msec


func call_bullet_1():
	var bullet_count = randi_range(1, 3)
	for i in range(bullet_count):
		var bullet_node
		if self.monster_direction:
			bullet_node = Global.add_bullet(
				"Monster1410Bullet1",
				self.bullet,
				false,
				1,
				Vector2(35, 25) + position,
				"hit1",
				self.obj_attack_dict["hit1"]
			)
		else:
			bullet_node = Global.add_bullet(
				"Monster1410Bullet1",
				self.bullet,
				false,
				1,
				Vector2(-35, 25) + position,
				"hit1",
				self.obj_attack_dict["hit1"]
			)
		bullet_node.look_at(RoleProp.get_nearest_monster_target_position(global_position))
		bullet_node.my_father = self
		if i < bullet_count - 1:
			await get_tree().create_timer(0.2).timeout


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


func revive():
	if is_reviving:
		return
	is_reviving = true
	set_meta("counts_as_alive_for_stage_clear", true)
	MonsterBullet.clear_all_1410_bullets()
	await get_tree().create_timer(2.0, false).timeout
	Global.add_special_effect(get_parent(), global_position, "relife", Vector2(2, 2), false, 1)
	await get_tree().create_timer(0.3, false).timeout
	self.hp = self.max_hp
	self.is_death = false
	if buff:
		for b in buff.get_children():
			if b is BaseBuff:
				var buff_name = b.buff_info.get("Name", "")
				if buff_name in ["stun", "Ice", "Immobilize"]:
					b.queue_free()
	velocity = Vector2.ZERO
	if mr_player and mr_player.has_animation("idle"):
		mr_player.play("idle")
	elif mr_player and mr_player.has_animation("wait"):
		mr_player.play("wait")
	is_reviving = false
	set_meta("counts_as_alive_for_stage_clear", false)


func state_death():
	if is_reviving:
		set_meta("counts_as_alive_for_stage_clear", true)
		return

	if has_meta("is_clone") and get_meta("is_clone"):
		if not has_meta("_death_reported"):
			set_meta("_death_reported", true)
			var owner = get_meta("owner_monster") if has_meta("owner_monster") else null
			if owner and is_instance_valid(owner):
				owner.on_clone_died()
		super.state_death()
		return

	if MonsterBullet.get_active_1410_bullet_count() > 0:
		set_meta("counts_as_alive_for_stage_clear", true)
		revive()
		return

	set_meta("counts_as_alive_for_stage_clear", false)
	super.state_death()


func is_alive_for_stage_clear() -> bool:
	if has_meta("is_clone") and get_meta("is_clone"):
		return not death()
	return is_reviving or MonsterBullet.get_active_1410_bullet_count() > 0 or not death()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if is_invincible:
		print("本体无敌，免疫伤害")
		return
	super._on_hurt_box_area_entered(area)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

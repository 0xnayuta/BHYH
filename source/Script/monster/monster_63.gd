extends BaseMonster
var death_count: int = 0
var hurtcount: int = 0
var should_fs: bool = false
var _fs_queued: bool = false
var is_fs = false
var fs_list = []
var reduce_count: int = 0
var accumulated_hit: int = 0


func monster_63():
	self.is_boss = true
	self.my_mr_name = "五毒·卞城王"
	self.attack_in = 0
	self.level = RoleProp.baseroleprop.Level
	self.max_hp = 180000 + int(RoleProp.baseroleprop.Level * 12000)
	self.hp = self.max_hp
	self.def = 150 + int(RoleProp.baseroleprop.Level * 3)
	self.mdef = 150 + int(RoleProp.baseroleprop.Level * 3)
	self.crit = 5 + int(RoleProp.baseroleprop.Level * 0.8)
	self.miss = 5 + int(RoleProp.baseroleprop.Level * 0.4)
	self.lucky = 0 + int(RoleProp.baseroleprop.Level * 1.5)
	self.htarget = 0
	self.toughness = 0
	self.ar = 20 + int(RoleProp.baseroleprop.Level * 0.6)
	self.sp = 20 + int(RoleProp.baseroleprop.Level * 0.6)
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 0
	self.attack_range = 280
	self.attack_desire = 0
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0

	self.obj_attack_dict["hit1"] = {
		"power": 300 + int(RoleProp.baseroleprop.Level * 8),
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 6
	}

	self.obj_attack_dict["hit2"] = {
		"power": 100 + int(RoleProp.baseroleprop.Level * 12),
		"hurtBack": [-10, 0],
		"attackKind": "magic",
		"HitProtect": 4,
		"addeffect":
		{
			"Name": "Boundground",
			"AddTime": 4,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["hit4"] = {
		"power": 100 + int(RoleProp.baseroleprop.Level * 10),
		"hurtBack": [20, -10],
		"attackKind": "magic",
	}
	self.fall_pro = 0.15
	self.fall_list = [{"name": "xzyj", "value": 1}]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_63()
	skill_1_cd = 10
	skill_2_cd = 0
	skill_3_cd = 0
	skill_4_cd = 15
	should_fs = false


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	reduce_count += 1

	if reduce_count % 120 == 0:
		if hurtcount > 0:
			hurtcount -= 1
		if accumulated_hit > 0:
			accumulated_hit -= 1

	if not is_fs and accumulated_hit >= randi_range(4, 8):
		if get_player != null:
			get_player.effect_reducehp(int(accumulated_hit * randi_range(10, 15)), "real")
			cure_hp((max_hp - hp) * accumulated_hit * 0.001)
			accumulated_hit = 0

	if should_fs:
		mr_player.play("hit3")
		await mr_player.animation_finished
		should_fs = false
		stop_move()
		return

	if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_4_cd <= 0:
					do_hit_4()
			else:
				if skill_1_cd <= 0:
					do_hit_1()
				if skill_4_cd <= 0:
					do_hit_4()
				elif count % 120 == 0:
					attack_target()
				else:
					stop_move()


func do_hit_1():
	skill_1_cd = randi_range(20, 30)
	super.to_hero()
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_4():
	if skill_4_cd > 0 or is_attacking:
		return
	super.to_hero()
	skill_4_cd = randi_range(25, 30)
	hit_name = "hit4"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit4")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func move_player_to_boss(movetime: float = 0.0):
	var player = get_player
	if not player or not is_instance_valid(player):
		return

	var elapsed_time = 0.0
	var max_radius = 2000
	var min_radius = 5
	var base_pull = 8

	while true:
		if not is_instance_valid(self) or not is_inside_tree() or not is_instance_valid(player):
			return

		if movetime > 0:
			elapsed_time += get_process_delta_time()
			if elapsed_time >= movetime:
				break

		var distance = position.distance_to(player.position)

		if distance > min_radius and distance < max_radius:
			var pull_strength = (max_radius - distance) / max_radius
			pull_strength = clamp(pull_strength * base_pull, 0.5, base_pull * 1.5)
			var direction = (position - player.position).normalized()
			player.position += direction * pull_strength

		await get_tree().process_frame


func _on_hurt_box_area_entered(area: Area2D) -> void:
	super._on_hurt_box_area_entered(area)
	hurtcount += 1

	if not is_fs:
		accumulated_hit += 1

	if not is_fs and get_parent().get_children().size() < 5:
		if hurtcount >= 40:
			if randi_range(0, 100) <= 15:
				hurtcount = 0
				should_fs = true


func call_fs():
	if _fs_queued:
		return
	_fs_queued = true
	call_deferred("_call_fs_deferred")


func _call_fs_deferred() -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	_fs_queued = false
	if get_parent().get_children().size() >= 6:
		should_fs = false
		return
	var fs = Global.create_monster(63, get_parent(), position)
	if fs == null:
		should_fs = false
		return

	await fs.ready

	fs.should_fs = false
	fs.is_fs = true
	fs.is_boss = false
	fs.fall_list.clear()
	fs.fall_stone.clear()

	if fs.mr_player:
		fs.mr_player.stop()

	fs.stop_move()
	fs.modulate = Color(0.5, 0.5, 0.5)

	fs.max_hp = int(self.max_hp * 0.5)
	fs.hp = fs.max_hp
	fs.def = int(self.def * 0.5)
	fs.mdef = int(self.mdef * 0.5)
	fs.crit = int(self.crit * 0.5)
	fs.miss = int(self.miss * 0.5)
	fs.lucky = int(self.lucky * 0.5)
	fs.ar = int(self.ar * 0.5)
	fs.sp = int(self.sp * 0.5)
	fs.speed = int(self.speed * 0.5)

	for attack_key in self.obj_attack_dict:
		if attack_key in fs.obj_attack_dict:
			var original_power = self.obj_attack_dict[attack_key]["power"]
			fs.obj_attack_dict[attack_key]["power"] = int(original_power * 0.5)

	should_fs = false


func call_bullet_2():
	var bullet_pos
	for i in range(randi_range(6, 10)):
		if monster_direction:
			bullet_pos = Vector2(-100, randi_range(-65, 35))
		else:
			bullet_pos = Vector2(100, randi_range(-65, 35))
		Global.add_bullet(
			"Monster63Bullet1",
			self.bullet,
			!monster_direction,
			1,
			bullet_pos + position,
			"hit2",
			self.obj_attack_dict["hit2"]
		)
		await get_tree().create_timer(0.1, false).timeout


func _on_death_timeout() -> void:
	if is_fs:
		self.hp = -990


func _on_hit_box_area_exited(_area: Area2D) -> void:
	if not is_fs:
		accumulated_hit += 1

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

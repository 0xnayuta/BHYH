extends BaseMonster
class_name Monster132

var is_strength: bool
var relif_times: int = 0
var should_relive: bool = false
var create_count: int = randi_range(600, 720)
var is_resurrecting: bool = false
var resurrection_completed: bool = false
var custom_death_handled: bool = false
var death_timer: Timer


func monster_132():
	self.is_boss = true
	self.my_mr_name = "天庭战神"
	self.attack_in = 60
	self.level = RoleProp.baseroleprop.Level + 5
	self.max_hp = 300000
	self.hp = self.max_hp
	self.def = 200
	self.mdef = 200
	self.crit = 50
	self.miss = 25
	self.lucky = 115
	self.htarget = 35
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 14
	self.mysee = 500
	self.attack_range = 245
	self.attack_desire = 100
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 120
	self.fall_coin = 155

	self.obj_attack_dict["hit1"] = {
		"power": 200,
		"hurtBack": [-4, -7],
		"attackKind": "magic",
		"HitProtect": 10,
	}

	self.obj_attack_dict["hit2"] = {
		"power": 200,
		"hurtBack": [-5, -1],
		"attackKind": "magic",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 5,
			"reduce_interval": 0,
			"value": 1,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
			"CanAdd": false,
		}
	}

	self.fall_pro = 0.05
	self.fall_list = [{"name": "canglongjiezzs", "value": 1}]

	self.fall_stone_pro = 0.05
	self.fall_stone = [{"name": "canglonglingpo", "value": randi_range(1, 2)}]


func _ready() -> void:
	super._ready()
	monster_132()
	skill_1_cd = randi_range(3, 5)
	skill_2_cd = randi_range(5, 8)

	death_timer = Timer.new()
	death_timer.name = "death_timer"
	death_timer.one_shot = true
	add_child(death_timer)


func _physics_process(delta: float) -> void:
	if is_resurrecting or resurrection_completed:
		if can_set_gra():
			gravity = -980
		else:
			gravity = 0

		if not is_on_floor() and not is_fly:
			velocity.y -= gravity * delta
		move_and_slide()
		return

	super._physics_process(delta)

	if hp > 0 and not is_resurrecting and not resurrection_completed:
		create_count -= 1
		if create_count <= 0:
			var shallow = Global.create_monster(133, get_parent(), position) as Monster133
			if shallow:
				shallow.my_parent = self
				create_count = randi_range(600, 720)


func _process(delta: float) -> void:
	if hp <= 0 and not custom_death_handled and not is_resurrecting and not resurrection_completed:
		custom_death_handled = true
		handle_custom_death()


func death() -> bool:
	if is_resurrecting or resurrection_completed or should_relive:
		return false

	if relif_times < 9 and hp <= 0:
		return true

	if hp <= 0:
		return true

	return false


func handle_custom_death():
	velocity = Vector2.ZERO
	is_attacking = false

	if relif_times < 9:
		start_resurrection()
	else:
		final_death()


func start_resurrection():
	is_resurrecting = true
	should_relive = true
	set_meta("counts_as_alive_for_stage_clear", true)

	if hit_box:
		hit_box.disabled = true
	if hurt_box:
		hurt_box.disabled = true

	if mr_player.is_playing():
		mr_player.stop()

	relif_times += 1

	if has_node("MonsterDir/mr_ani"):
		var mr_ani = $MonsterDir/mr_ani
		if mr_ani.sprite_frames and mr_ani.sprite_frames.has_animation("death1"):
			mr_ani.animation = "death1"
			mr_ani.frame = 0
			mr_ani.play()

			var frame_count = mr_ani.sprite_frames.get_frame_count("death1")
			var speed_val = mr_ani.sprite_frames.get_animation_speed("death1")
			var anim_duration = frame_count / speed_val if speed_val > 0 else 6.0

			death_timer.wait_time = anim_duration
			if death_timer.timeout.is_connected(_on_resurrection_animation_complete):
				death_timer.timeout.disconnect(_on_resurrection_animation_complete)
			death_timer.timeout.connect(_on_resurrection_animation_complete, CONNECT_ONE_SHOT)
			death_timer.start()
			return

	if mr_player and mr_player.has_animation("death1"):
		mr_player.play("death1")
		death_timer.wait_time = 6.0
		if death_timer.timeout.is_connected(_on_resurrection_animation_complete):
			death_timer.timeout.disconnect(_on_resurrection_animation_complete)
		death_timer.timeout.connect(_on_resurrection_animation_complete, CONNECT_ONE_SHOT)
		death_timer.start()
		return

	await get_tree().create_timer(0.5).timeout
	perform_resurrection()


func _on_resurrection_animation_complete():
	perform_resurrection()


func perform_resurrection():
	max_hp = int(max_hp * 1.2)
	hp = max_hp
	def += 20
	mdef += 20
	ar += 10
	sp += 10
	speed += 1
	ebol += 0.25

	if obj_attack_dict.size() != 0:
		for attack_name in obj_attack_dict:
			if obj_attack_dict[attack_name].has("power"):
				obj_attack_dict[attack_name].power = int(obj_attack_dict[attack_name].power * 1.2)

	fall_pro += 0.08
	fall_stone_pro += 0.08

	should_relive = false
	is_resurrecting = false
	resurrection_completed = true
	is_death = false
	is_fall = false
	custom_death_handled = false
	set_meta("counts_as_alive_for_stage_clear", false)

	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0

	if hit_box:
		hit_box.disabled = false
	if hurt_box:
		hurt_box.disabled = false

	if has_node("MonsterDir/SpecialEffect"):
		var special_effect = $MonsterDir/SpecialEffect

		special_effect.position = Vector2.ZERO

		special_effect.scale.x = 1

		if special_effect is AnimatedSprite2D and special_effect.sprite_frames:
			if special_effect.sprite_frames.has_animation("relive"):
				special_effect.play("relive")
			elif special_effect.sprite_frames.has_animation("relive"):
				special_effect.play("relive")

	resume_idle_animation()

	await get_tree().create_timer(1.0).timeout
	resurrection_completed = false


func resume_idle_animation():
	if mr_player.is_playing():
		mr_player.stop()

	if has_node("MonsterDir/mr_ani"):
		var mr_ani = $MonsterDir/mr_ani
		if mr_ani.is_playing():
			mr_ani.stop()

	if mr_player.has_animation("wait"):
		mr_player.play("wait")
	elif mr_player.has_animation("idle"):
		mr_player.play("idle")
	elif has_node("MonsterDir/mr_ani"):
		var mr_ani = $MonsterDir/mr_ani
		if mr_ani.sprite_frames:
			if mr_ani.sprite_frames.has_animation("wait"):
				mr_ani.animation = "wait"
				mr_ani.play()
			elif mr_ani.sprite_frames.has_animation("idle"):
				mr_ani.animation = "idle"
				mr_ani.play()


func final_death():
	is_death = true
	set_meta("counts_as_alive_for_stage_clear", false)

	if mr_player.has_animation("death"):
		mr_player.play("death")
	elif has_node("MonsterDir/mr_ani"):
		var mr_ani = $MonsterDir/mr_ani
		if mr_ani.sprite_frames and mr_ani.sprite_frames.has_animation("death"):
			mr_ani.animation = "death"
			mr_ani.play()

	super.set_exp()
	super.set_gxp()

	if PlayerData.player_data.has(my_mr_name):
		PlayerData.player_data[my_mr_name] += 1

	settle_death_drops()

	await get_tree().create_timer(2.0).timeout

	if is_instance_valid(self):
		queue_free()


func state_death():
	if relif_times < 9:
		set_meta("counts_as_alive_for_stage_clear", true)
		if not custom_death_handled and not is_resurrecting and not resurrection_completed:
			custom_death_handled = true
			handle_custom_death()
		return
	if not custom_death_handled:
		custom_death_handled = true
		final_death()


func is_alive_for_stage_clear() -> bool:
	return (
		relif_times < 9
		or is_resurrecting
		or resurrection_completed
		or should_relive
		or bool(get_meta("counts_as_alive_for_stage_clear", false))
	)


func ai_think():
	if is_resurrecting or resurrection_completed or should_relive:
		return

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
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) <= 560:
					if skill_2_cd <= 0:
						do_hit_2()
			else:
				stop_move()
				if skill_2_cd <= 0:
					do_hit_2()
				elif skill_1_cd <= 0:
					do_hit_1()
				if count % 60 == 0:
					if randi_range(0, 100) < attack_desire:
						attack_target()


func check_hp():
	if is_resurrecting or resurrection_completed:
		return

	if hp >= max_hp:
		hp = max_hp
	if hp <= 0 and not custom_death_handled:
		hp = 0


func do_hit_1():
	if is_resurrecting or resurrection_completed:
		return

	super.to_hero()
	skill_1_cd = randi_range(15, 18)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	if is_resurrecting or resurrection_completed:
		return

	super.to_hero()
	skill_2_cd = randi_range(11, 13)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func tween_to_top():
	if is_resurrecting or resurrection_completed or _movement_command_is_blocked():
		return

	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", Vector2(0, -250) + position, 2)
	velocity = Vector2(0, 0)


func call_bullet():
	if is_resurrecting or resurrection_completed:
		return

	var max_count: int = 15
	var target_count: int = 0

	while target_count < max_count:
		var new_rotation = 360.0 / max_count * target_count
		var rad = deg_to_rad(new_rotation)
		var stab_position = Vector2(self.position.x + sin(rad) * 300, self.position.y - 15 - cos(rad) * 300)
		var arrow = Global.add_bullet(
			"Monster132Bullet", self.bullet, false, 1, stab_position, "hit2", self.obj_attack_dict["hit2"]
		)
		if arrow:
			arrow.rotation_degrees = new_rotation - 90

		await get_tree().create_timer(0.05, false).timeout
		target_count += 1


func _on_hurt_box_area_entered(area: Area2D):
	if is_resurrecting or resurrection_completed:
		return

	super._on_hurt_box_area_entered(area)

	var bl: float = 0.02 + relif_times * 0.01
	if is_strength:
		Global.add_buff(
			RoleProp.source_player.buff,
			{
				"Name": "Fire",
				"AddTime": 5,
				"reduce_interval": 1,
				"value": int(RoleProp.roleprop.SHp * bl),
				"AttackKind": "real",
				"CanAdd": true,
				"CanRemove": false
			}
		)
		is_strength = false


func strength_self():
	if is_resurrecting or resurrection_completed:
		return

	is_strength = false
	if obj_attack_dict.size() != 0:
		for i in obj_attack_dict:
			if obj_attack_dict[i].has("power"):
				obj_attack_dict[i].power *= 1.2

	for i in range(randi_range(3, 6)):
		cure_hp(int(max_hp * randf_range(0.01, 0.02)))
		await get_tree().create_timer(0.2, false).timeout


func on_strength():
	if is_resurrecting or resurrection_completed:
		return

	is_strength = true


func _exit_tree():
	super._exit_tree()
	if death_timer and death_timer.timeout.is_connected(_on_resurrection_animation_complete):
		death_timer.timeout.disconnect(_on_resurrection_animation_complete)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================

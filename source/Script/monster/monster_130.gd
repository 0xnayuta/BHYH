extends BaseMonster

const MODEL_ROOT := "res://Art/monster/game_3_monster/monster_130"
var _skill_busy := false
var _barrage_generation := 0


func _ready() -> void:
	_configure_visuals()
	_configure_animation_player()
	super._ready()
	_configure_stats()

	skill_1_cd = 3
	skill_2_cd = 3
	skill_3_cd = 10


func _configure_stats() -> void:
	var average_level := clampi(int(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, 1)), 1, 80)
	var level_step := ceili(float(average_level) / 10.0)
	var attack_power := 3000

	is_boss = true
	my_mr_name = "嫦娥"
	level = average_level
	max_hp = 4500000
	hp = 4500000
	def = 700
	mdef = 700
	crit = 0
	miss = 100
	lucky = 0
	htarget = 9999
	toughness = 20
	ar = 450
	sp = 450
	crit_reduce = 0
	speed = 9
	mysee = 1000
	attack_range = 200
	attack_desire = 60
	behit_calmtime = 0.25
	self_rhp = 0
	add_exp = 500
	fall_coin = 0
	fall_pro = 0.1
	fall_list = []
	fall_stone_pro = 0.0
	fall_stone = []

	obj_attack_dict["hit1"] = {
		"power": attack_power,
		"hurtBack": [-6, -5],
		"attackKind": "physics",
		"HitProtect": 0,
	}
	obj_attack_dict["hit2"] = {
		"power": attack_power,
		"hurtBack": [0, 0],
		"attackKind": "physics",
		"HitProtect": 0,
	}
	obj_attack_dict["hit3"] = {
		"power": 900,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	obj_attack_dict["hit4"] = {
		"power": 2000,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 0,
	}


func _configure_visuals() -> void:
	var frames_path := MODEL_ROOT.path_join("monster_130_action_frames.tres")
	var frames := load(frames_path) as SpriteFrames
	if frames == null:
		push_error("Monster130 action frames missing: " + frames_path)
		return

	mr_ani.sprite_frames = frames
	mr_ani.offset = Vector2(5, -56)
	mr_ani.play(&"wait")


func _configure_animation_player() -> void:
	for library_name in mr_player.get_animation_library_list():
		mr_player.remove_animation_library(library_name)
	var library := AnimationLibrary.new()
	library.add_animation(&"RESET", _make_state_animation(&"wait", 0.05, false))
	library.add_animation(&"wait", _make_state_animation(&"wait", 15.0 / 24.0, true))
	library.add_animation(&"walk", _make_state_animation(&"walk", 15.0 / 24.0, true))
	library.add_animation(&"hurt", _make_state_animation(&"hurt", 8.0 / 24.0, false))
	library.add_animation(&"death", _make_state_animation(&"death", 18.0 / 24.0, false))
	library.add_animation(&"hit1", _make_state_animation(&"hit1", 14.0 / 24.0, false))
	library.add_animation(&"hit2", _make_state_animation(&"hit2", 0.5, false))
	library.add_animation(&"hit3", _make_state_animation(&"hit3", 10.0 / 24.0, false))
	library.add_animation(&"hit4", _make_state_animation(&"hit4", 10.0 / 24.0, false))
	mr_player.add_animation_library(&"", library)


func _make_state_animation(state_name: StringName, duration: float, loops: bool) -> Animation:
	var animation := Animation.new()
	animation.length = duration
	animation.loop_mode = Animation.LOOP_LINEAR if loops else Animation.LOOP_NONE
	var animation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(animation_track, NodePath("MonsterDir/mr_ani:animation"))
	animation.track_insert_key(animation_track, 0.0, state_name)
	animation.value_track_set_update_mode(animation_track, Animation.UPDATE_DISCRETE)
	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, NodePath("MonsterDir/mr_ani:frame"))
	animation.track_insert_key(frame_track, 0.0, 0)
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	if state_name == &"death":
		var finish_track := animation.add_track(Animation.TYPE_METHOD)
		animation.track_set_path(finish_track, NodePath("."))
		(
			animation
			. track_insert_key(
				finish_track,
				maxf(0.01, duration - 0.01),
				{
					"method": &"settle_death_drops_and_free",
					"args": [],
				}
			)
		)
	return animation


func ai_think() -> void:
	if (
		_skill_busy
		or hp <= 0
		or RoleProp.source_player == null
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
	):
		return
	var distance := global_position.distance_to(RoleProp.source_player.global_position)
	if distance < mysee:
		has_target = true
	if not has_target:
		normal_state()
		return
	if is_ice or is_sleep or is_stun or is_immobilize or islljy or cannotchangestatewhenattorbeatt():
		return

	if skill_1_cd <= 0 and distance < 1000.0:
		_cast_moonlight()
	elif skill_2_cd <= 0 and distance < 400.0:
		_cast_gaze()
	elif skill_3_cd <= 0 and distance < 600.0:
		_cast_repeated_moonlight()
	elif distance > attack_range:
		have_target()
	else:
		stop_move()
		if count % 60 == 0 and randf() < 0.6:
			attack_target()


func attack_target() -> void:
	if _skill_busy or hp <= 0:
		return
	_skill_busy = true
	to_hero()
	velocity.x = 0
	hit_name = "hit1"
	is_attacking = true
	mr_player.play(&"hit1")
	await get_tree().create_timer(4.0 / 24.0, false).timeout
	if hp > 0:
		var offset_x := 50.0 if monster_direction else -50.0
		_spawn_effect("monster_130_bullet_1", global_position + Vector2(offset_x, 0), "hit1", obj_attack_dict["hit1"])
	await get_tree().create_timer(10.0 / 24.0, false).timeout
	is_attacking = false
	_skill_busy = false
	if hp > 0:
		stop_move()


func _cast_moonlight() -> void:
	if _skill_busy:
		return
	_skill_busy = true
	skill_1_cd = 8
	to_hero()
	velocity.x = 0
	hit_name = "hit2"
	is_attacking = true
	mr_player.play(&"hit2")
	await get_tree().create_timer(2.0 / 24.0, false).timeout
	if hp > 0:
		_spawn_moonlight_on_random_target()
	await get_tree().create_timer(10.0 / 24.0, false).timeout
	is_attacking = false
	_skill_busy = false
	if hp > 0:
		stop_move()


func _cast_gaze() -> void:
	if _skill_busy:
		return
	_skill_busy = true
	skill_2_cd = 10
	to_hero()
	velocity.x = 0
	hit_name = "hit3"
	is_attacking = true
	mr_player.play(&"hit3")
	await get_tree().process_frame
	if hp > 0:
		var effect = _spawn_effect("monster_130_bullet_3", global_position, "hit3", obj_attack_dict["hit3"])
		if effect != null:
			effect.my_father = self
			effect.set_meta("monster130_gaze_lifetime", randf_range(1.0, 3.0))
	await get_tree().create_timer(10.0 / 24.0, false).timeout
	is_attacking = false
	_skill_busy = false
	if hp > 0:
		stop_move()


func _cast_repeated_moonlight() -> void:
	if _skill_busy:
		return
	_skill_busy = true
	skill_3_cd = 30
	_barrage_generation += 1
	var generation := _barrage_generation
	to_hero()
	velocity.x = 0
	hit_name = "hit4"
	is_attacking = true
	mr_player.play(&"hit4")
	await get_tree().process_frame

	_spawn_moonlight_on_random_target()
	call_deferred("_run_moonlight_barrage", generation)
	await get_tree().create_timer(10.0 / 24.0, false).timeout
	is_attacking = false
	_skill_busy = false
	if hp > 0:
		stop_move()


func _run_moonlight_barrage(generation: int) -> void:
	for _index in range(5):
		await get_tree().create_timer(2.0, false).timeout
		if generation != _barrage_generation or hp <= 0 or not is_inside_tree():
			return
		_spawn_moonlight_on_random_target()


func _spawn_moonlight_on_random_target() -> void:
	var targets := _get_player_and_pet_targets()
	if targets.is_empty():
		return
	var target := targets[randi_range(0, targets.size() - 1)] as Node2D
	_spawn_effect("monster_130_bullet_2", target.global_position + Vector2(0, -30), "hit2", obj_attack_dict["hit2"])


func _spawn_effect(effect_name: String, spawn_position: Vector2, attack_name: String, attack_data: Dictionary):
	var effect = Global.add_bullet(
		effect_name, bullet, monster_direction, 1.0, spawn_position, attack_name, attack_data
	)
	if effect != null:
		if effect is Node2D:
			effect.set_as_top_level(true)
			effect.global_position = spawn_position
		effect.my_father = self
	return effect


func _apply_gaze_control() -> void:
	if hp <= 0:
		return
	for target_value in _get_player_and_pet_targets():
		var target := target_value as Node2D
		if target == null or not is_instance_valid(target):
			continue
		var facing_right := false
		if target is BaseHero:
			facing_right = bool(target.get("player_dir"))
		elif target is BaseMonster:
			facing_right = bool(target.get("monster_direction"))
		var looking_at_change := (
			(target.global_position.x < global_position.x and facing_right)
			or (target.global_position.x > global_position.x and not facing_right)
		)
		if not looking_at_change:
			continue
		var buff_node = target.get("buff")
		if buff_node == null:
			buff_node = target.get_node_or_null("Buff")
		if buff_node != null:
			(
				Global
				. add_buff(
					buff_node,
					{
						"Name": "EyeFix",
						"AddTime": 3.0,
						"reduce_interval": 0,
						"value": 0,
						"AttackKind": "",
						"DeBuff": true,
						"CanRemove": false,
					}
				)
			)


func _get_player_and_pet_targets() -> Array[Node2D]:
	var result: Array[Node2D] = []
	if (
		RoleProp.source_player != null
		and is_instance_valid(RoleProp.source_player)
		and RoleProp.source_player is Node2D
	):
		result.append(RoleProp.source_player as Node2D)
	var scene_root := get_tree().current_scene
	if scene_root != null:
		_collect_pet_targets(scene_root, result)
	return result


func _collect_pet_targets(node: Node, result: Array[Node2D]) -> void:
	if node != self and node is Node2D and bool(node.get_meta("is_summon", false)):
		var candidate := node as Node2D
		if candidate not in result:
			result.append(candidate)
	for child in node.get_children():
		_collect_pet_targets(child, result)


func state_death() -> void:
	_barrage_generation += 1
	_skill_busy = true
	super.state_death()
	if not get_meta("monster130_death_cleanup_started", false):
		set_meta("monster130_death_cleanup_started", true)
		call_deferred("_finish_monster130_death")


func _finish_monster130_death() -> void:
	var death_length := 0.9
	if mr_player != null and is_instance_valid(mr_player):
		var death_animation := mr_player.get_animation(&"death")
		if death_animation != null:
			death_length = maxf(float(death_animation.length) + 0.08, 0.25)
	await get_tree().create_timer(death_length, false).timeout
	if is_instance_valid(self) and not is_queued_for_deletion():
		_try_unlock_pet_rabbit()
		settle_death_drops()
		queue_free()


func settle_death_drops_and_free() -> void:
	if is_queued_for_deletion() or get_meta("death_drops_settled", false):
		return
	_try_unlock_pet_rabbit()
	super.settle_death_drops_and_free()


func _try_unlock_pet_rabbit() -> void:
	var unlocked := false
	var coop := get_node_or_null("/root/LocalCoop")
	if coop != null and coop.is_enabled():
		var profiles: Array[Node] = [
			coop.canonical_profile_for_slot(1),
			coop.canonical_profile_for_slot(2),
		]
		for profile in profiles:
			if is_instance_valid(profile) and profile.has_method("unlock_pet_rabbit"):
				unlocked = profile.unlock_pet_rabbit() or unlocked
	elif PlayerData.has_method("unlock_pet_rabbit"):
		unlocked = PlayerData.unlock_pet_rabbit()
	if not unlocked:
		return
	Global.add_message_show(Global.windows, "击败嫦娥，成功解锁宠物月兔！", 2.0, Vector2(500, 305))
	MemoryClass.request_save("monster_unlock_pet_rabbit")

extends BaseMonster

const BODY_FRAMES_PATH := "res://Art/monster/tao_tie/tao_tie_frames.tres"
const BODY_FRAME_COLUMNS := 6
const SOURCE_FPS := 24.0
const BODY_SPRITE_POSITION := Vector2(-9, -103)
const EFFECT_ROOT := "res://Art/monster/tao_tie/effects"
const EFFECT_NAMES := ["monster_115_bullet_1", "monster_115_bullet_2", "monster_115_bullet_3"]

var bullet1_height := -70.0
var bullet2_height := -50.0
var bullet3_height := -30.0

var _skill_busy := false
var _effect_hit_tokens: Dictionary = {}


func _ready() -> void:
	_configure_taotie()
	_build_original_animations()
	super._ready()
	skill_1_cd = randi_range(5, 13)
	skill_2_cd = randi_range(6, 12)


func _configure_taotie() -> void:
	is_boss = true
	cannot_attract = true
	set_meta("allow_role_special_control", true)
	my_mr_name = "饕餮"
	attack_in = 250
	level = max(40, RoleProp.baseroleprop.Level + 3)
	max_hp = 3000000
	hp = max_hp
	def = 250
	mdef = 250
	crit = 55
	miss = 15
	lucky = 10
	htarget = 100
	toughness = 20
	speed = 15
	mysee = 1000
	attack_range = 250
	attack_desire = 95
	behit_calmtime = 0.15
	self_rhp = 0
	add_exp = 500
	fall_coin = 2000
	fall_pro = 0.0
	fall_list = []
	self.independent_fall_list = [{"name": "zizhiguo", "value": 3, "chance": 0.25}]
	fall_stone_pro = 0.0
	fall_stone = []
	obj_attack_dict["hit1"] = {"power": 1400, "hurtBack": [6, -5], "attackKind": "magic", "HitProtect": 8}
	obj_attack_dict["hit2"] = {"power": 1200, "hurtBack": [0, 0], "attackKind": "physics", "HitProtect": 0}
	obj_attack_dict["hit3"] = {
		"power": 1500,
		"hurtBack": [6, -5],
		"attackKind": "magic",
		"HitProtect": 8,
		"addeffect":
		{
			"Name": "speed_down",
			"DeBuff": true,
			"CanAdd": true,
			"AddTime": 8,
			"reduce_interval": 0,
			"value": 0.5,
			"AttackKind": ""
		}
	}


func _build_original_animations() -> void:
	var frames := load(BODY_FRAMES_PATH) as SpriteFrames
	if frames == null or not frames.has_animation(&"atlas"):
		push_error("SSSL boss standard frames failed to load: " + BODY_FRAMES_PATH)
		return
	mr_ani.sprite_frames = frames
	mr_ani.animation = &"atlas"
	mr_ani.centered = true
	mr_ani.position = BODY_SPRITE_POSITION

	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_action(0, [2, 2, 2, 3, 2, 4], true))
	library.add_animation(&"walk", _make_action(1, [4, 4, 4, 4], true))
	library.add_animation(&"hurt", _make_action(2, [8], false))

	var death_animation := _make_action(3, [2, 2, 2, 2, 9], false)
	_add_standard_death_methods(death_animation)
	library.add_animation(&"death", death_animation)

	var hit1_animation := _make_action(4, [2, 2, 2, 10], false)
	_add_method_key(hit1_animation, 15.0 / SOURCE_FPS, &"_spawn_hit1")
	library.add_animation(&"hit1", hit1_animation)

	var hit2_animation := _make_action(5, [2, 27], false)
	_add_method_key(hit2_animation, 28.0 / SOURCE_FPS, &"_spawn_hit2")
	library.add_animation(&"hit2", hit2_animation)

	var hit3_animation := _make_action(6, [2, 2, 20], false)
	_add_method_key(hit3_animation, 23.0 / SOURCE_FPS, &"_spawn_hit3")
	library.add_animation(&"hit3", hit3_animation)
	mr_player.add_animation_library(&"", library)


func _make_action(row: int, holds: Array, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, NodePath("MonsterDir/mr_ani:frame"))
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	var time := 0.0
	for column in range(holds.size()):
		animation.track_insert_key(frame_track, time, row * BODY_FRAME_COLUMNS + column)
		time += float(holds[column]) / SOURCE_FPS
	animation.length = maxf(time, 0.05)
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(method_track, minf(time, animation.length - 0.001), {"method": method_name, "args": []})


func _add_standard_death_methods(animation: Animation) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	var finish_time := animation.length - 0.001
	animation.track_insert_key(method_track, finish_time, {"method": &"settle_death_drops_and_free", "args": []})


func ai_think() -> void:
	if absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if is_limit_buff() or cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	if not has_target:
		normal_state()
		return
	var distance := absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	if skill_2_cd <= 0 and distance <= 300.0:
		_use_skill(&"hit3", randi_range(6, 12))
	elif skill_1_cd <= 0:
		_use_skill(&"hit2", randi_range(5, 13))
	elif distance <= attack_range:
		stop_move()
		if count % 45 == 0 and randi_range(0, 100) <= attack_desire:
			attack_target()
	else:
		have_target()


func _use_skill(animation_name: StringName, cooldown: int) -> void:
	if _skill_busy or is_attacking:
		return
	_skill_busy = true
	super.to_hero()
	if animation_name == &"hit2":
		skill_1_cd = cooldown
	else:
		skill_2_cd = cooldown
	hit_name = String(animation_name)
	velocity.x = 0.0
	is_attacking = true
	mr_player.play(animation_name)
	await mr_player.animation_finished
	if death():
		return
	is_attacking = false
	_skill_busy = false
	stop_move()


func _spawn_hit1() -> void:
	hit_name = "hit1"
	_spawn_effect(
		"monster_115_bullet_1", Vector2(_front_x(150.0), bullet1_height), Vector2(360, 95), 0.7, "hit1", false
	)


func _spawn_hit2() -> void:
	hit_name = "hit2"
	_effect_hit_tokens.clear()
	_spawn_effect("monster_115_bullet_2", Vector2(_front_x(40.0), bullet2_height), Vector2(270, 250), 1.0, "hit2", true)
	_pull_player_and_pets()


func _spawn_hit3() -> void:
	hit_name = "hit3"
	obj_attack_dict["hit3"]["power"] = randi_range(500, 900)
	_effect_hit_tokens.clear()
	for offset_x in [95.0, -95.0, 240.0, -240.0]:
		_spawn_effect("monster_115_bullet_3", Vector2(offset_x, bullet3_height), Vector2(260, 170), 1.65, "hit3", false)


func _faces_right() -> bool:
	return monster_dir.scale.x < 0.0


func _front_x(distance: float) -> float:
	return distance if _faces_right() else -distance


func _spawn_effect(
	effect_name: String,
	local_position: Vector2,
	hit_size: Vector2,
	lifetime: float,
	attack_name: String,
	reduce_hp_effect: bool
) -> void:
	var holder := Node2D.new()
	holder.name = effect_name
	holder.position = local_position
	add_child(holder)

	var sprite := StreamedPngEffect.new()
	sprite.frame_paths = _effect_frame_paths(effect_name)
	sprite.fps = SOURCE_FPS
	sprite.flip_h = _faces_right()
	sprite.z_index = 5
	holder.add_child(sprite)

	var area := Area2D.new()
	area.name = "HitBox"
	area.collision_layer = 4
	area.collision_mask = 896
	area.monitoring = true
	area.monitorable = false
	holder.add_child(area)
	area.set_meta("attack_name", attack_name)
	area.set_meta("reduce_hp_effect", reduce_hp_effect)
	area.area_entered.connect(_on_effect_hurt_box_entered.bind(area))

	var shape_node := CollisionShape2D.new()
	shape_node.name = "HitBox"
	var shape := RectangleShape2D.new()
	shape.size = hit_size
	shape_node.shape = shape
	area.add_child(shape_node)
	get_tree().create_timer(lifetime, false).timeout.connect(_free_effect_holder.bind(holder, sprite))


func _free_effect_holder(holder: Node2D, sprite: Node) -> void:
	if sprite != null and is_instance_valid(sprite):
		if sprite.has_method("clear_texture"):
			sprite.call("clear_texture")
		elif sprite is AnimatedSprite2D:
			(sprite as AnimatedSprite2D).sprite_frames = null
	if holder != null and is_instance_valid(holder):
		holder.queue_free()


func _on_effect_hurt_box_entered(hurt_area: Area2D, attack_area: Area2D) -> void:
	if not is_instance_valid(hurt_area) or not is_instance_valid(attack_area):
		return
	var damage_target := hurt_area.get_parent().get_parent()
	if damage_target == null or not damage_target.has_method("_on_hurt_box_area_entered"):
		return
	var attack_name := String(attack_area.get_meta("attack_name", "hit1"))
	var token := str(attack_area.get_instance_id()) + ":" + str(damage_target.get_instance_id())
	if _effect_hit_tokens.has(token):
		return
	_effect_hit_tokens[token] = true
	hit_name = attack_name
	super._on_hit_box_area_entered(hurt_area)
	damage_target.call("_on_hurt_box_area_entered", attack_area)
	if bool(attack_area.get_meta("reduce_hp_effect", false)):
		_apply_reduce_hp_effect(damage_target)


func _apply_reduce_hp_effect(target: Node) -> void:
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("effect_reducehp") or target.has_method("reduce_hp"):
		_run_reduce_hp_over_time(target)


func _run_reduce_hp_over_time(target: Node) -> void:
	for tick in range(9):
		await get_tree().create_timer(1.0, false).timeout
		if not is_instance_valid(target):
			return
		if target.has_method("effect_reducehp"):
			target.call("effect_reducehp", 12, "real")
		elif target.has_method("reduce_hp"):
			target.call("reduce_hp", 12, self)


func _pull_player_and_pets() -> void:
	var target_point := global_position + Vector2(_front_x(30.0), -40.0)
	var candidates: Array[Node] = []
	if get_player != null and is_instance_valid(get_player):
		candidates.append(get_player)
	var scene_root := get_tree().current_scene
	if scene_root != null:
		_collect_active_pets(scene_root, candidates)
	for target in candidates:
		if target is Node2D:
			var tween := create_tween()
			tween.tween_property(target, "global_position", target_point, 1.0)


func _collect_active_pets(node: Node, result: Array[Node]) -> void:
	if node != null and is_instance_valid(node):
		var is_pet := bool(node.get_meta("pet_tiger_unit", false)) or bool(node.get_meta("is_summon", false))
		if not is_pet and node.has_method("get"):
			is_pet = node.get("is_summon") == true
		if is_pet and node is Node2D and not result.has(node):
			result.append(node)
			return
		for child in node.get_children():
			_collect_active_pets(child, result)


func _new_effect_frames(effect_name: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"play")
	frames.set_animation_loop(&"play", false)
	frames.set_animation_speed(&"play", SOURCE_FPS)
	return frames


func _effect_file_names(effect_name: String) -> Array[String]:
	var names: Array[String] = []
	var directory_path := EFFECT_ROOT + "/" + effect_name
	var directory := DirAccess.open(directory_path)
	if directory != null:
		for file_name in directory.get_files():
			if file_name.ends_with(".png"):
				names.append(file_name)
	if names.is_empty():
		_append_numbered_effect_file_names(names, directory_path)
	names.sort_custom(func(a: String, b: String): return a.naturalnocasecmp_to(b) < 0)
	return names


func _effect_frame_paths(effect_name: String) -> Array[String]:
	var result: Array[String] = []
	var directory_path := EFFECT_ROOT + "/" + effect_name
	for file_name in _effect_file_names(effect_name):
		result.append(directory_path + "/" + file_name)
	return result


func _append_numbered_effect_file_names(names: Array[String], directory_path: String) -> void:
	var missing_streak := 0
	for index in range(601):
		var file_name := str(index) + ".png"
		if ResourceLoader.exists(directory_path + "/" + file_name):
			names.append(file_name)
			missing_streak = 0
		elif not names.is_empty():
			missing_streak += 1
			if missing_streak >= 30:
				break


func _load_effect_frames(effect_name: String) -> SpriteFrames:
	var frames := _new_effect_frames(effect_name)
	var directory_path: String = EFFECT_ROOT + "/" + effect_name
	for file_name in _effect_file_names(effect_name):
		var texture := Global.get_cached_texture(directory_path + "/" + file_name)
		frames.add_frame(&"play", texture)
	return frames


func _prewarm_effect_frames() -> void:
	pass

extends "res://Script/pet/pet_turtle_summon_base.gd"

const SKILL_MNCZ := "mncz"
const SKILL_MLJT := "mljt"
const SKILL_CNAOYI := "cnaoyi"
const NEAT_SKILL_NAMES := {SKILL_MNCZ: "蛮牛冲撞", SKILL_MLJT: "蛮力践踏", SKILL_CNAOYI: "丑牛奥义"}
const SKILL_COSTS := {SKILL_MNCZ: 50, SKILL_MLJT: 75, SKILL_CNAOYI: 100}
const SKILL_INITIAL_CDS := {SKILL_MNCZ: 4.0, SKILL_MLJT: 7.0, SKILL_CNAOYI: 25.0}
const SKILL_CDS := {SKILL_MNCZ: 10.0, SKILL_MLJT: 12.0, SKILL_CNAOYI: 25.0}
const STAGE_NAMES := {1: "丑牛元帅", 2: "丑牛元帅", 3: "丑牛元帅", 4: "丑牛大元帅"}
const STAGE_SKILLS := {1: ["蛮牛冲撞"], 2: ["蛮牛冲撞"], 3: ["蛮牛冲撞"], 4: ["蛮牛冲撞", "蛮力践踏", "丑牛奥义"]}
const MODEL_FRAMES_RES := "res://Art/pet/pet_neat/model/pet_neat_stage%d_frames.tres"
const SCENE_RES := "res://Scene/pet/pet_neat_summon_%d.tscn"
const BULLET_SCENE := preload("res://Scene/pet/pet_neat_bullet.tscn")
const ACTIONS := {
	1:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 10],
		"hit2": [30]
	},
	2:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 10],
		"hit2": [30]
	},
	3:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 10],
		"hit2": [30]
	},
	4:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 10],
		"hit1": [2, 2, 10],
		"hit2": [30],
		"hit3": [2, 2, 10]
	},
}
const STAGE_OFFSETS := {1: Vector2(10, -25), 2: Vector2(10, -25), 3: Vector2(10, -25), 4: Vector2(10, -20)}
const NORMAL_HIT_SIZE := Vector2(360, 120)
const RUSH_HIT_SIZE := Vector2(420, 180)
const STOMP_HIT_SIZE := Vector2(620, 190)

const HIT1_EFFECT_TICK := 14
const HIT2_EFFECT_TICK := 30
const HIT3_EFFECT_TICK := 14
static var _scene_cache: Dictionary = {}
var _aoyi_step := 0
var _neat_aoyi_stomp := false


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_neat_unit", true)
	set_meta("is_summon", true)
	if is_in_group("monsters"):
		remove_from_group("monsters")
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	setup_skills()
	_setup_turtle_model_frames()
	PetNeatBullet.warm_pet_neat_frames(turtle_stage)
	if hurt_box != null:
		hurt_box.disabled = false
	if hit_box != null:
		hit_box.disabled = true


func _pet_stage_from_data(data: Dictionary, fallback: int) -> int:
	var level_stage := (
		4
		if int(data.get(DataKeys.LEVEL, 1)) >= 50
		else 3 if int(data.get(DataKeys.LEVEL, 1)) >= 30 else 2 if int(data.get(DataKeys.LEVEL, 1)) >= 15 else 1
	)
	return maxi(level_stage, clampi(int(data.get("阶段", fallback)), 1, 4))


func setup_pet_turtle(stage: int) -> void:
	super.setup_pet_turtle(clampi(stage, 1, 4))
	turtle_stage = clampi(stage, 1, 4)
	pet_data["阶段"] = turtle_stage
	pet_data[DataKeys.TYPE] = "PetNeat"
	pet_data[DataKeys.ALT_NAME] = STAGE_NAMES[turtle_stage]
	pet_data[DataKeys.NAME] = STAGE_NAMES[turtle_stage]
	pet_data["技能"] = (STAGE_SKILLS[turtle_stage] as Array).duplicate(true)
	my_mr_name = str(STAGE_NAMES[turtle_stage])
	speed = 14
	init_speed = speed
	attack_range = 200
	attack_desire = 70
	_rebuild_pet_turtle_attack_data()


func _rebuild_pet_turtle_attack_data() -> void:
	var root_rate := 1.0 + float(clampi(int(pet_data.get("根骨", 0)), 0, 25)) * 0.02
	var magic_add := int(pet_data.get("法术能量", pet_data.get("魔法加成", 0)))
	var normal_power := maxi(1, int(float(attack_in + magic_add) * root_rate))
	var rush_power := maxi(1, int(float(attack_in * 2.0 + magic_add) * root_rate))
	var stomp_power := maxi(1, int(float(attack_in * 4.0 + magic_add) * root_rate))
	obj_attack_dict["hit1"] = _attack_dic(normal_power, [6, -5], "physics", 999)
	obj_attack_dict["hit2"] = _attack_dic(rush_power, [-10, 0], "physics", 5)
	obj_attack_dict["hit3"] = _attack_dic(stomp_power, [0, 0], "magic", 5)


func setup_skills() -> void:
	skill_1_cd = SKILL_INITIAL_CDS[SKILL_MNCZ] * pet_skill_cooldown_multiplier
	skill_2_cd = SKILL_INITIAL_CDS[SKILL_MLJT] * pet_skill_cooldown_multiplier
	skill_3_cd = SKILL_INITIAL_CDS[SKILL_CNAOYI] * pet_skill_cooldown_multiplier
	skill_4_cd = 0.0


func _has_neat_skill(skill_id: String) -> bool:
	var skills = pet_data.get("技能", [])
	return skills is Array and (skills.has(skill_id) or skills.has(NEAT_SKILL_NAMES[skill_id]))


func _skill_cost_neat(skill_id: String) -> int:
	return PET_SKILL_PROGRESSION.mana_cost(
		SKILL_COSTS[skill_id], PET_SKILL_PROGRESSION.get_level(pet_data, NEAT_SKILL_NAMES[skill_id])
	)


func _can_use_neat_skill(skill_id: String) -> bool:
	return _has_neat_skill(skill_id) and mp >= _skill_cost_neat(skill_id)


func ai_think() -> void:
	if is_attacking or is_be_attacking:
		return
	if not is_instance_valid(current_target) or current_target.hp <= 0:
		current_target = null
		has_target = false
		follow_player_when_idle()
		return
	var distance := global_position.distance_to(current_target.global_position)
	if distance >= mysee:
		current_target = null
		has_target = false
		follow_player_when_idle()
		return
	has_target = true
	try_use_skills()
	if is_attacking:
		return
	var center_distance := absf(current_target.global_position.x - global_position.x)
	var normal_origin := _neat_normal_attack_origin()
	var can_hit := (
		center_distance <= float(attack_range) and _target_in_neat_effect_range("pet_neat_1_bullet_1", normal_origin)
	)
	if not can_hit:
		if current_target.global_position.x > global_position.x:
			move_right()
		else:
			move_left()
	else:
		stop_move()
		to_monster()
		if count % 48 == 0 and randi_range(0, 100) < attack_desire:
			do_hit_1()


func _neat_normal_attack_origin() -> Vector2:
	var x_offset := 60.0 if turtle_stage >= 4 else 0.0
	return Vector2(-x_offset if _neat_face_left_for_target() else x_offset, -30.0)


func try_use_skills() -> void:
	if is_attacking or is_be_attacking or not is_instance_valid(current_target):
		return
	if (
		turtle_stage >= 4
		and skill_3_cd <= 0.0
		and _can_use_neat_skill(SKILL_CNAOYI)
		and _target_in_neat_skill_range(520.0)
	):
		do_neat_aoyi()
	elif turtle_stage >= 4 and skill_2_cd <= 0.0 and _can_use_neat_skill(SKILL_MLJT) and _target_in_neat_stomp_range():
		do_neat_stomp()
	elif skill_1_cd <= 0.0 and _can_use_neat_skill(SKILL_MNCZ) and _target_in_neat_skill_range(520.0):
		do_neat_rush()


func _target_in_neat_skill_range(_max_distance: float) -> bool:
	return is_instance_valid(current_target) and current_target.hp > 0


func _neat_effect_offset(effect_name: String) -> Vector2:
	var offset: Vector2 = PetNeatBullet.EFFECT_OFFSETS.get(effect_name, Vector2.ZERO)
	var facing_left := monster_direction
	if is_instance_valid(current_target) and current_target.global_position.x != global_position.x:
		facing_left = current_target.global_position.x < global_position.x
	offset.x = offset.x if facing_left else -offset.x
	return offset


func _target_in_neat_damage_range(size: Vector2, origin: Vector2) -> bool:
	if not is_instance_valid(current_target):
		return false
	var target_pos := current_target.global_position
	var hurt := current_target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt != null:
		target_pos = hurt.global_position
	var delta_pos := target_pos - (global_position + origin)
	return absf(delta_pos.x) <= size.x * 0.5 and absf(delta_pos.y) <= size.y * 0.5


func _target_in_neat_effect_range(effect_name: String, origin: Vector2) -> bool:
	if not is_instance_valid(current_target):
		return false
	var local_rect := PetNeatBullet.effect_union_rect(effect_name, _neat_face_left_for_target())
	if local_rect.size == Vector2.ZERO:
		return false
	var world_rect := Rect2(global_position + origin + local_rect.position, local_rect.size)
	return world_rect.intersects(_neat_target_hurt_rect(current_target), true)


func _neat_target_hurt_rect(target: BaseMonster) -> Rect2:
	var hurt_shape := target.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape == null or hurt_shape.shape == null:
		return Rect2(target.global_position - Vector2(24, 45), Vector2(48, 90))
	var local_rect: Rect2 = hurt_shape.shape.get_rect()
	var global_scale := hurt_shape.global_transform.get_scale().abs()
	var size := local_rect.size * global_scale
	return Rect2(hurt_shape.global_position - size * 0.5, size)


func _target_in_neat_stomp_range() -> bool:
	var stomp_rect := PetNeatBullet.effect_union_rect("pet_neat_4_bullet_3", _neat_face_left_for_target())
	if stomp_rect.size == Vector2.ZERO or not is_instance_valid(current_target):
		return false
	for origin in [
		Vector2(-100, 50),
		Vector2(-220, 50),
		Vector2(-340, 50),
		Vector2(-460, 50),
		Vector2(-580, 50),
		Vector2(100, 50),
		Vector2(220, 50),
		Vector2(340, 50),
		Vector2(460, 50),
		Vector2(580, 50),
	]:
		var world_rect := Rect2(global_position + origin + stomp_rect.position, stomp_rect.size)
		if world_rect.intersects(_neat_target_hurt_rect(current_target), true):
			return true
	return false


func _neat_face_left_for_target() -> bool:
	if is_instance_valid(current_target) and current_target.global_position.x != global_position.x:
		return current_target.global_position.x < global_position.x
	return monster_direction


func do_hit_1() -> void:
	_face_current_target()
	hit_name = "hit1"
	_start_turtle_action("hit1")


func do_neat_rush(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana:
		var cost := _skill_cost_neat(SKILL_MNCZ)
		if mp < cost:
			return
		mp -= cost
		pet_data[DataKeys.MP] = mp
	_face_current_target()
	if set_cooldown:
		skill_1_cd = SKILL_CDS[SKILL_MNCZ] * pet_skill_cooldown_multiplier
	hit_name = "hit2"
	_start_turtle_action("hit2")


func do_neat_stomp(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana:
		var cost := _skill_cost_neat(SKILL_MLJT)
		if mp < cost:
			return
		mp -= cost
		pet_data[DataKeys.MP] = mp
	_face_current_target()
	if set_cooldown:
		skill_2_cd = SKILL_CDS[SKILL_MLJT] * pet_skill_cooldown_multiplier
	hit_name = "hit3"
	_start_turtle_action("hit3")


func do_neat_aoyi() -> void:
	var cost := _skill_cost_neat(SKILL_CNAOYI)
	if mp < cost:
		return
	mp -= cost
	pet_data[DataKeys.MP] = mp
	skill_3_cd = SKILL_CDS[SKILL_CNAOYI] * pet_skill_cooldown_multiplier
	_aoyi_step = 0
	_neat_aoyi_stomp = true
	_face_current_target()
	hit_name = "hit3"
	_start_turtle_action("hit3")


func _start_turtle_action(action_name: String) -> void:
	if not (ACTIONS[turtle_stage] as Dictionary).has(action_name):
		return
	if action_name != "hurt":
		is_attacking = true
	velocity.x = 0.0
	_turtle_action = action_name
	_turtle_action_tick = 0
	_turtle_action_accumulator = 0.0
	_turtle_action_triggered.clear()
	_set_turtle_action_visual(action_name, 0)


func _turtle_action_total_ticks(action_name: String) -> int:
	var total := 0
	for value in (ACTIONS[turtle_stage] as Dictionary).get(action_name, []):
		total += int(value)
	return total


func _set_turtle_action_visual(action_name: String, action_tick: int) -> void:
	if (
		turtle_sprite == null
		or turtle_sprite.sprite_frames == null
		or not turtle_sprite.sprite_frames.has_animation(action_name)
	):
		return
	turtle_sprite.animation = action_name
	turtle_sprite.pause()
	var running := 0
	var frame_index := 0
	for value in (ACTIONS[turtle_stage] as Dictionary).get(action_name, []):
		running += int(value)
		if action_tick <= running:
			break
		frame_index += 1
	turtle_sprite.frame = clampi(frame_index, 0, turtle_sprite.sprite_frames.get_frame_count(action_name) - 1)


func _process_turtle_action_triggers() -> void:
	if _turtle_action == "hit1" and _trigger_once("neat_hit1", HIT1_EFFECT_TICK):
		_spawn_neat_effect("pet_neat_1_bullet_1", "hit1", obj_attack_dict["hit1"], NORMAL_HIT_SIZE)
	elif _turtle_action == "hit2":
		if _trigger_once("neat_hit2", HIT2_EFFECT_TICK):
			_spawn_neat_effect("pet_neat_1_bullet_2", "hit2", obj_attack_dict["hit2"], RUSH_HIT_SIZE, true)
		var rush_speed := 360.0 if _aoyi_step > 0 else 240.0
		velocity.x = -rush_speed if monster_direction else rush_speed
	elif _turtle_action == "hit3" and _trigger_once("neat_hit3", HIT3_EFFECT_TICK):
		if _neat_aoyi_stomp:
			_spawn_aoyi_stomp_sequence()
		else:
			_spawn_neat_effect("pet_neat_4_bullet_3", "hit3", obj_attack_dict["hit3"], STOMP_HIT_SIZE)


func _finish_turtle_action() -> void:
	var finished := _turtle_action
	super._finish_turtle_action()
	if finished == "hit3" and _neat_aoyi_stomp:
		_neat_aoyi_stomp = false
		_aoyi_step = 0


func _spawn_aoyi_stomp_sequence() -> void:
	for _index in range(3):
		if not is_inside_tree() or hp <= 0 or is_queued_for_deletion():
			return
		_spawn_neat_effect("pet_neat_4_bullet_3", "hit3", obj_attack_dict["hit3"], STOMP_HIT_SIZE * 2.0, false, 2.0)
		if _index < 2:
			await get_tree().create_timer(1.0, false).timeout


func _spawn_neat_effect(
	effect_name: String,
	attack_name: String,
	attack_data: Dictionary,
	hit_size: Vector2,
	follow: bool = false,
	effect_scale: float = 1.0
) -> Node:
	if bullet == null:
		return null
	var normal_x_offset := 60.0 if turtle_stage >= 4 else 0.0
	var offsets: Array[Vector2] = [
		_front_offset(
			normal_x_offset if effect_name == "pet_neat_1_bullet_1" else 0.0,
			-30.0 if effect_name == "pet_neat_1_bullet_1" else 0.0
		)
	]
	if effect_name == "pet_neat_4_bullet_3":
		offsets = [
			Vector2(-100, 50),
			Vector2(-220, 50),
			Vector2(-340, 50),
			Vector2(-460, 50),
			Vector2(-580, 50),
			Vector2(100, 50),
			Vector2(220, 50),
			Vector2(340, 50),
			Vector2(460, 50),
			Vector2(580, 50),
		]
	var first_instance: Node = null
	for offset in offsets:
		var instance = BULLET_SCENE.instantiate()
		instance.att_list = attack_data
		instance.hit_name = attack_name
		instance.dir = monster_direction
		instance.skill_name = effect_name
		instance.speed = 1.0
		instance.set_meta("summoner", self)
		instance.set_meta("pet_neat_hit_size", hit_size)
		instance.set_meta("pet_neat_effect_scale", effect_scale)
		var effect_frames := int(PetNeatBullet.COUNTS.get(effect_name, 0))
		instance.set_meta(
			"pet_neat_lifetime",
			(
				30.0 / PetNeatBullet.FPS
				if effect_name == "pet_neat_1_bullet_2"
				else float(effect_frames) / PetNeatBullet.FPS
			)
		)
		instance.set_meta("pet_neat_follow", follow)

		instance.z_as_relative = true
		instance.z_index = 1
		bullet.add_child(instance)
		instance.global_position = global_position + offset
		setup_bullet_collision(instance)
		if first_instance == null:
			first_instance = instance
	return first_instance


func on_neat_damage(_value: int) -> void:
	pass


func _setup_turtle_model_frames() -> void:
	var frames := (
		ResourceLoader.load(MODEL_FRAMES_RES % turtle_stage, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE)
		as SpriteFrames
	)
	if frames == null:
		push_error("PetNeat SpriteFrames missing for stage %d" % turtle_stage)
		return
	turtle_sprite.sprite_frames = frames
	turtle_sprite.offset = STAGE_OFFSETS[turtle_stage]
	_align_neat_model_to_ground()
	_play_turtle_model_animation("wait")


func _align_neat_model_to_ground() -> void:
	if (
		turtle_sprite == null
		or turtle_sprite.sprite_frames == null
		or not turtle_sprite.sprite_frames.has_animation("wait")
	):
		return
	var texture := turtle_sprite.sprite_frames.get_frame_texture("wait", 0)
	if texture == null:
		return
	var image := texture.get_image()
	if image == null or image.is_empty():
		return
	var used := image.get_used_rect()
	if used.size == Vector2i.ZERO:
		return
	var pz := get_node_or_null("pz") as CollisionShape2D
	if pz == null or pz.shape == null:
		return
	var pz_bottom := _collision_shape_bottom(pz)
	var visual_bottom := (
		turtle_sprite.position.y
		+ turtle_sprite.offset.y
		+ float(used.position.y + used.size.y)
		- float(texture.get_height()) * 0.5
	)
	turtle_sprite.offset.y += pz_bottom - visual_bottom


func _apply_turtle_stage_scene_layout() -> void:
	var packed := _get_neat_stage_scene(turtle_stage)
	if packed == null:
		return
	var template := packed.instantiate()
	var ground_shape := get_node_or_null("pz") as CollisionShape2D
	var old_ground_bottom := _collision_shape_bottom(ground_shape)
	var template_sprite := template.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if template_sprite != null:
		turtle_sprite.position = template_sprite.position
		turtle_sprite.rotation = template_sprite.rotation
		turtle_sprite.offset = template_sprite.offset
		turtle_sprite.scale = template_sprite.scale
		turtle_sprite.centered = template_sprite.centered
	for path in ["BaseDamageBox/HitBox/HitBox", "BaseDamageBox/HurtBox/HurtBox", "pz"]:
		_copy_turtle_collision_layout(template, NodePath(path))
	var new_ground_bottom := _collision_shape_bottom(ground_shape)
	global_position.y += old_ground_bottom - new_ground_bottom
	velocity.y = 0.0
	template.free()


static func _get_neat_stage_scene(stage: int) -> PackedScene:
	var safe_stage := clampi(stage, 1, 4)
	if _scene_cache.has(safe_stage):
		return _scene_cache[safe_stage] as PackedScene
	var scene := (
		ResourceLoader.load(SCENE_RES % safe_stage, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	)
	if scene != null:
		_scene_cache[safe_stage] = scene
	return scene


func apply_pet_data(data: Dictionary) -> void:
	var previous_stage := turtle_stage
	var previous_skills: Array = pet_data.get("技能", []).duplicate(true) if pet_data.get("技能", []) is Array else []
	pet_data = data.duplicate(true)
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	if is_node_ready() and turtle_sprite != null:
		if previous_stage != turtle_stage:
			_apply_turtle_stage_scene_layout()
		_setup_turtle_model_frames()
		if not previous_skills.has("蛮牛冲撞") and _has_neat_skill(SKILL_MNCZ):
			skill_1_cd = 0.0
		if not previous_skills.has("蛮力践踏") and _has_neat_skill(SKILL_MLJT):
			skill_2_cd = 0.0
		if not previous_skills.has("丑牛奥义") and _has_neat_skill(SKILL_CNAOYI):
			skill_3_cd = 0.0

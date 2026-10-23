extends "res://Script/pet/pet_turtle_summon_base.gd"

const SKILL_HX := "hx"
const SKILL_MHXS := "mhxs"
const SKILL_YHAOYI := "yhaoyi"
const YIN_SKILL_NAMES := {SKILL_HX: "虎啸", SKILL_MHXS: "猛虎下山", SKILL_YHAOYI: "寅虎奥义"}
const SKILL_COSTS := {SKILL_HX: 50, SKILL_MHXS: 70, SKILL_YHAOYI: 100}
const STAGE_NAMES := {1: "寅虎元帅", 2: "寅虎元帅", 3: "寅虎元帅", 4: "寅虎大元帅"}
const STAGE_SKILLS := {
	1: ["虎啸"],
	2: ["虎啸"],
	3: ["虎啸"],
	4: ["虎啸", "猛虎下山", "寅虎奥义"],
}
const ACTIONS := {
	1:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 2, 10],
		"hit1": [3, 3, 3, 3, 10],
		"hit2": [3, 3, 10]
	},
	4:
	{
		"wait": [2, 2, 2, 3, 2, 4],
		"walk": [4, 4, 4, 4],
		"hurt": [8],
		"death": [2, 2, 2, 2, 2, 10],
		"hit1": [3, 3, 3, 3, 10],
		"hit2": [3, 3, 10],
		"hit3": [3, 3, 3, 20]
	},
}
const MODEL_ROOT := "res://Art/pet/pet_yin_tiger/model/actions"
const MODEL_MAP := {
	1: {"wait": "wait", "walk": "walk", "hurt": "hurt", "death": "death", "hit1": "hit1", "hit2": "hit2"},
	4:
	{"wait": "wait", "walk": "walk", "hurt": "hurt", "death": "death", "hit1": "hit1", "hit2": "hit2", "hit3": "hit3"},
}
const MODEL_SOURCE_STAGE := {1: 1, 2: 1, 3: 1, 4: 2}
const MODEL_FRAME_COUNTS := {"wait": 6, "walk": 4, "hurt": 1, "death": 6, "hit1": 5, "hit2": 3, "hit3": 4}
const MODEL_STOP_COUNTS := {
	"wait": [2, 2, 2, 3, 2, 4],
	"walk": [4, 4, 4, 4],
	"hurt": [8],
	"death": [2, 2, 2, 2, 2, 10],
	"hit1": [3, 3, 3, 3, 10],
	"hit2": [3, 3, 10],
	"hit3": [3, 3, 3, 20]
}
const BULLET_SCENE := preload("res://Scene/pet/pet_yin_tiger_bullet.tscn")

const HIT1_TICK := 7
const HIT2_TICK := 7
const HIT3_TICK := 10
const HIT3_RUSH_SPEED := 240.0
const NORMAL_ATTACK_RANGES := {1: 90, 4: 100}

var _aoyi_step := 0
var _aoyi_running := false


func _ready() -> void:
	_initialize_summon_base()
	set_meta("pet_yin_tiger_unit", true)
	set_meta("is_summon", true)
	if is_in_group("monsters"):
		remove_from_group("monsters")
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	setup_skills()
	_setup_turtle_model_frames()
	PetYinTigerBullet.warm_pet_yin_tiger_frames(turtle_stage)
	if hurt_box != null:
		hurt_box.disabled = false
	if hit_box != null:
		hit_box.disabled = true


func _pet_stage_from_data(data: Dictionary, _fallback: int) -> int:
	return (
		4
		if int(data.get(DataKeys.LEVEL, 1)) >= 50
		else 3 if int(data.get(DataKeys.LEVEL, 1)) >= 30 else 2 if int(data.get(DataKeys.LEVEL, 1)) >= 15 else 1
	)


func setup_pet_turtle(stage: int) -> void:
	super.setup_pet_turtle(clampi(stage, 1, 4))
	turtle_stage = clampi(stage, 1, 4)
	pet_data["阶段"] = turtle_stage
	pet_data[DataKeys.TYPE] = "PetYinTiger"
	pet_data[DataKeys.ALT_NAME] = STAGE_NAMES[turtle_stage]
	pet_data[DataKeys.NAME] = STAGE_NAMES[turtle_stage]
	pet_data["技能"] = (STAGE_SKILLS[turtle_stage] as Array).duplicate(true)
	my_mr_name = str(STAGE_NAMES[turtle_stage])
	speed = 14
	init_speed = speed
	attack_range = int(NORMAL_ATTACK_RANGES.get(4 if turtle_stage >= 4 else 1, 90))
	attack_desire = 100
	_rebuild_pet_tiger_attack_data()


func _rebuild_pet_tiger_attack_data() -> void:
	var root_rate := 1.0 + float(clampi(int(pet_data.get("根骨", 0)), 0, 25)) * 0.02
	var magic_add := int(pet_data.get("法术能量", pet_data.get("魔法加成", 0)))
	var normal_power := maxi(1, int(float(attack_in + magic_add) * root_rate))
	var skill_power := maxi(1, int(float(attack_in * 5.0 + magic_add) * root_rate))
	var strong_power := maxi(1, int(float(attack_in * 8.0 + magic_add) * root_rate))
	obj_attack_dict["hit1"] = _attack_dic(normal_power, [6, -5], "physics", 5)
	obj_attack_dict["hit2"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(skill_power, pet_data, YIN_SKILL_NAMES[SKILL_HX]), [6, -5], "physics", 15
	)
	obj_attack_dict["hit3"] = _attack_dic(
		PET_SKILL_PROGRESSION.scaled_power(strong_power, pet_data, YIN_SKILL_NAMES[SKILL_MHXS]), [6, -5], "physics", 10
	)


func _attack_dic(power: int, hurt_back: Array, kind: String, interval: int) -> Dictionary:
	return {"power": power, "hurtBack": hurt_back, "attackKind": kind, "attackInterval": interval, "HitProtect": 0}


func setup_skills() -> void:
	skill_1_cd = 6.0 * pet_skill_cooldown_multiplier
	skill_2_cd = 8.0 * pet_skill_cooldown_multiplier
	skill_3_cd = 30.0 * pet_skill_cooldown_multiplier
	skill_4_cd = 0.0


func _has_yin_skill(skill_id: String) -> bool:
	var skills = pet_data.get("技能", [])
	return skills is Array and (skills.has(skill_id) or skills.has(YIN_SKILL_NAMES[skill_id]))


func _yin_skill_cost(skill_id: String) -> int:
	return PET_SKILL_PROGRESSION.mana_cost(
		SKILL_COSTS[skill_id], PET_SKILL_PROGRESSION.get_level(pet_data, YIN_SKILL_NAMES[skill_id])
	)


func try_use_skills() -> void:
	if is_attacking or is_be_attacking or _aoyi_running or not is_instance_valid(current_target):
		return
	var distance := global_position.distance_to(current_target.global_position)
	if (
		turtle_stage >= 4
		and skill_3_cd <= 0.0
		and _has_yin_skill(SKILL_YHAOYI)
		and mp >= _yin_skill_cost(SKILL_YHAOYI)
		and distance <= 300.0
	):
		do_yin_aoyi()
	elif (
		turtle_stage >= 4
		and skill_2_cd <= 0.0
		and _has_yin_skill(SKILL_MHXS)
		and mp >= _yin_skill_cost(SKILL_MHXS)
		and distance <= 300.0
	):
		do_mhxs()
	elif skill_1_cd <= 0.0 and _has_yin_skill(SKILL_HX) and mp >= _yin_skill_cost(SKILL_HX) and distance <= 200.0:
		do_hx()


func do_hit_1() -> void:
	_face_current_target()
	hit_name = "hit1"
	_start_yin_action("hit1")


func do_hx(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana:
		var cost := _yin_skill_cost(SKILL_HX)
		if mp < cost:
			return
		mp -= cost
		pet_data[DataKeys.MP] = mp
	_face_current_target()
	if set_cooldown:
		skill_1_cd = 8.0 * pet_skill_cooldown_multiplier
	hit_name = "hit2"
	_start_yin_action("hit2")


func do_mhxs(without_mana: bool = false, set_cooldown: bool = true) -> void:
	if not without_mana:
		var cost := _yin_skill_cost(SKILL_MHXS)
		if mp < cost:
			return
		mp -= cost
		pet_data[DataKeys.MP] = mp
	_face_current_target()
	if set_cooldown:
		skill_2_cd = 10.0 * pet_skill_cooldown_multiplier
	hit_name = "hit3"
	_start_yin_action("hit3")


func do_yin_aoyi() -> void:
	var cost := _yin_skill_cost(SKILL_YHAOYI)
	if mp < cost:
		return
	mp -= cost
	pet_data[DataKeys.MP] = mp
	skill_3_cd = 30.0 * pet_skill_cooldown_multiplier
	_aoyi_running = true
	_aoyi_step = 1
	do_hx(true, false)


func _start_yin_action(action_name: String) -> void:
	var action_stage := 4 if turtle_stage >= 4 else 1
	if not (ACTIONS[action_stage] as Dictionary).has(action_name):
		return
	is_attacking = true
	velocity.x = 0.0
	_turtle_action = action_name
	_turtle_action_tick = 0
	_turtle_action_accumulator = 0.0
	_turtle_action_triggered.clear()
	_set_yin_action_visual(action_name, 0)


func _turtle_action_total_ticks(action_name: String) -> int:
	var action_stage := 4 if turtle_stage >= 4 else 1
	var total := 0
	for value in (ACTIONS[action_stage] as Dictionary).get(action_name, []):
		total += int(value)
	return total


func _set_turtle_action_visual(action_name: String, action_tick: int) -> void:
	_set_yin_action_visual(action_name, action_tick)


func _set_yin_action_visual(action_name: String, action_tick: int) -> void:
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
	for value in MODEL_STOP_COUNTS.get(action_name, [1]):
		running += int(value)
		if action_tick <= running:
			break
		frame_index += 1
	turtle_sprite.frame = clampi(frame_index, 0, turtle_sprite.sprite_frames.get_frame_count(action_name) - 1)
	_sync_turtle_model_facing()


func _process_turtle_action_triggers() -> void:
	match _turtle_action:
		"hit1":
			if _trigger_once("yin_hit1", HIT1_TICK):
				_spawn_yin_effect(
					"pet_yin_tiger_1_bullet_1",
					"hit1",
					obj_attack_dict["hit1"],
					_front_offset(90.0 if turtle_stage >= 4 else 80.0, -50.0)
				)
		"hit2":
			if _trigger_once("yin_hit2", HIT2_TICK):
				_spawn_yin_effect(
					"pet_yin_tiger_1_bullet_2",
					"hit2",
					obj_attack_dict["hit2"],
					_front_offset(60.0 if turtle_stage >= 4 else 50.0, -25.0)
				)
		"hit3":
			if _trigger_once("yin_hit3", HIT3_TICK):
				velocity.x = -HIT3_RUSH_SPEED if monster_direction else HIT3_RUSH_SPEED
				_spawn_yin_effect(
					"pet_yin_tiger_1_bullet_3", "hit3", obj_attack_dict["hit3"], _front_offset(400.0, -100.0)
				)
			elif _turtle_action_tick >= HIT3_TICK + 19:
				velocity.x = 0.0


func _finish_turtle_action() -> void:
	var finished := _turtle_action
	super._finish_turtle_action()
	if not _aoyi_running or hp <= 0:
		return
	if finished == "hit2" and _aoyi_step == 1:
		_aoyi_step = 2
		do_mhxs(true, false)
	elif finished == "hit3" and _aoyi_step == 2:
		_aoyi_step = 3
		do_hx(true, false)
	elif finished == "hit2" and _aoyi_step == 3:
		_aoyi_step = 4
		do_mhxs(true, false)
	elif finished == "hit3" and _aoyi_step == 4:
		_aoyi_step = 0
		_aoyi_running = false


func _spawn_yin_effect(
	effect_name: String, attack_name: String, attack_data: Dictionary, effect_position: Vector2
) -> Node:
	if bullet == null:
		return null
	var instance = BULLET_SCENE.instantiate()
	instance.att_list = attack_data
	instance.hit_name = attack_name
	instance.dir = monster_direction
	instance.skill_name = effect_name
	instance.speed = 1.0
	instance.set_meta("summoner", self)
	if effect_name == "pet_yin_tiger_1_bullet_3" and is_instance_valid(current_target):
		instance.set_meta("yin_tiger_locked_target", current_target)
	bullet.add_child(instance)
	instance.global_position = global_position + effect_position
	setup_bullet_collision(instance)
	return instance


func _target_effect_offset(y_offset: float) -> Vector2:
	if is_instance_valid(current_target):
		return current_target.global_position - global_position + Vector2(0.0, y_offset)
	return _front_offset(400.0, y_offset)


func _setup_turtle_model_frames() -> void:
	if turtle_sprite == null:
		return
	var preserved_action := _turtle_action
	var preserved_tick := _turtle_action_tick
	var source_stage := int(MODEL_SOURCE_STAGE.get(turtle_stage, 1))
	var source_map: Dictionary = MODEL_MAP[4] if source_stage == 2 else MODEL_MAP[1]
	var frames := SpriteFrames.new()
	for action_name in source_map.keys():
		frames.add_animation(action_name)
		frames.set_animation_speed(action_name, 24.0)
		frames.set_animation_loop(action_name, action_name == "wait" or action_name == "walk")
		var folder := MODEL_ROOT.path_join("stage%d" % source_stage).path_join(str(source_map[action_name]))
		var count := int(MODEL_FRAME_COUNTS.get(action_name, 0))
		for frame_index in range(count):
			var path := folder.path_join("%d.png" % (frame_index + 1))
			var texture := ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
			if texture != null:
				var stop_counts: Array = MODEL_STOP_COUNTS.get(action_name, [1])
				var duration := float(stop_counts[frame_index]) if frame_index < stop_counts.size() else 1.0
				frames.add_frame(action_name, texture, duration)
	turtle_sprite.sprite_frames = frames
	turtle_sprite.offset = Vector2(1, -23)
	if not preserved_action.is_empty() and frames.has_animation(preserved_action):
		if preserved_action == "wait" or preserved_action == "walk":
			_play_turtle_model_animation(preserved_action)
		else:
			_set_yin_action_visual(preserved_action, preserved_tick)
	else:
		_play_turtle_model_animation("wait")


func apply_pet_data(data: Dictionary) -> void:
	var previous_stage := turtle_stage
	pet_data = data.duplicate(true)
	setup_pet_turtle(_pet_stage_from_data(pet_data, turtle_stage))
	if is_node_ready() and (previous_stage != turtle_stage or turtle_sprite.sprite_frames == null):
		if previous_stage != turtle_stage:
			_apply_turtle_stage_scene_layout()
		_setup_turtle_model_frames()


func _apply_turtle_stage_scene_layout() -> void:
	var scene_path := "res://Scene/pet/pet_yin_tiger_summon_%d.tscn" % clampi(turtle_stage, 1, 4)
	var packed_scene := ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	if packed_scene == null:
		return
	var template := packed_scene.instantiate()
	if template == null:
		return
	var ground_shape := get_node_or_null("pz") as CollisionShape2D
	var old_ground_bottom := _collision_shape_bottom(ground_shape)
	var template_sprite := template.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if template_sprite != null and turtle_sprite != null:
		turtle_sprite.position = template_sprite.position
		turtle_sprite.rotation = template_sprite.rotation
		turtle_sprite.scale = template_sprite.scale
		turtle_sprite.offset = template_sprite.offset
		turtle_sprite.centered = template_sprite.centered
	for path in ["BaseDamageBox/HitBox/HitBox", "BaseDamageBox/HurtBox/HurtBox", "pz"]:
		_copy_turtle_collision_layout(template, NodePath(path))
	var new_ground_bottom := _collision_shape_bottom(ground_shape)
	global_position.y += old_ground_bottom - new_ground_bottom
	template.free()


func state_hurt(attacker: Node) -> void:
	_aoyi_running = false
	_aoyi_step = 0
	super.state_hurt(attacker)

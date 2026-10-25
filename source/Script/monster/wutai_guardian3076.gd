extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3076"
const FRAMES := ROOT + "/atlas/swf_png_3076_frames.tres"
const SOURCE_FPS := 30.0
const AI_DELAY_MSEC := 2000
const SKILL3_DURATION := 0.667
const SKILL3_HIT_BOX_SIZE := Vector2(312.0, 306.0)
const SKILL3_HIT_BOX_POSITION := Vector2(-133.0, -127.0)
const SKILL1_HIT_START_FRAME := 21
const SKILL1_HIT_END_FRAME := 33
const SKILL2_HIT_START_FRAME := 11
const SKILL2_HIT_END_FRAME := 21
const SKILL3_HIT_START_FRAME := 22
const SKILL3_HIT_END_FRAME := 32

const ACTIONS := {
	&"wait": {"folder": "wait", "frames": 30, "offset": Vector2(0.6, -101.4), "loop": true},
	&"walk": {"folder": "walk", "frames": 24, "offset": Vector2(14.1, -102.45), "loop": true},
	&"death": {"folder": "death", "frames": 50, "offset": Vector2(-78.15, -101.15), "loop": false},
	&"skill1": {"folder": "effect1", "frames": 35, "offset": Vector2(-5.0, -148.95), "loop": false},
	&"skill2": {"folder": "effect2", "frames": 102, "offset": Vector2(52.0, -98.65), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 35, "offset": Vector2(103.5, -128.1), "loop": false},
}

@export var monster_kind := 3076

static var _frames_cache: SpriteFrames

var _runtime_config: Dictionary = {}
var _busy := false
var _death_started := false
var _attack_serial := 0
var _skill_order := [1, 3, 2]
var _skill_step := 0
var _skill_cycle_initialized := false
var _next_attack_msec := 0
var _skill_direction := 1.0
var _skill3_travel: WutaiMinghaiProjectile
var _attack_hit_consumed := false


func _ready() -> void:
	super_armor_active = true
	var attack_area := hit_box.get_parent() as Area2D if hit_box != null else null
	if attack_area != null:
		attack_area.monitorable = false
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_guardian(_runtime_config)
	_build_animations()
	super._ready()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WutaiGuardian3076 requires level monster config for 3076")
	return {}


func _configure_guardian(config: Dictionary) -> void:
	my_mr_name = str(config.get("name", "五台守卫%d" % monster_kind))
	level = int(config["level"])
	attack_in = int(config["attack"])
	max_hp = int(config["hp"])
	hp = max_hp
	def = int(config["def"])
	mdef = int(config["mdef"])
	crit = int(config["crit"])
	miss = int(config["miss"])
	htarget = int(config["hit"])
	toughness = float(config["toughness"])
	crit_reduce = int(config["crit_reduce"])
	ar = int(config["armor_break"])
	sp = int(config["magic_break"])
	speed = float(config["speed"])
	mysee = int(config["sight"])
	attack_range = int(config["range"])
	attack_desire = int(config["attack_desire"])
	add_exp = int(config["exp"])
	fall_coin = int(config["coin"])
	fall_pro = float(config["drop_rate"])
	fall_list = Array(config["drop_list"]).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	obj_attack_dict.clear()
	var attacks: Dictionary = config["attacks"]
	for attack_name: String in attacks:
		obj_attack_dict[attack_name] = _attack_data(attacks[attack_name])


func _attack_data(attack: Dictionary) -> Dictionary:
	var data := {
		"power": roundi(float(attack_in) * float(attack["multiplier"])),
		"hurtBack": Array(attack["hurt_back"]).duplicate(),
		"attackKind": str(attack["kind"]),
		"HitProtect": int(attack["protect"]),
	}
	var effect: Variant = attack.get("effect", {})
	if effect is Dictionary and not effect.is_empty():
		data["addeffect"] = (effect as Dictionary).duplicate(true)
	return data


func _configure_monster(config: Dictionary = {}) -> void:
	if config.is_empty():
		config = _runtime_config
	if not config.is_empty():
		_configure_guardian(config)


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


static func prewarm_frames() -> void:
	_get_sprite_frames()


static func prewarm_effects() -> void:
	pass


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3076_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action_name: StringName in ACTIONS:
		var info: Dictionary = ACTIONS[action_name]
		var sequence_name := StringName(str(info["folder"]))
		if not source.has_animation(sequence_name):
			return null
		frames.add_animation(action_name)
		frames.set_animation_speed(action_name, source.get_animation_speed(sequence_name))
		frames.set_animation_loop(action_name, bool(info["loop"]))
		for frame_index in range(source.get_frame_count(sequence_name)):
			frames.add_frame(action_name, source.get_frame_texture(sequence_name, frame_index))
	return frames


static func _get_sprite_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var standard := _load_standard_frames()
	if standard != null:
		_frames_cache = standard
		return standard
	return null


func _build_animations() -> void:
	var frames := _get_sprite_frames()
	if frames != null:
		mr_ani.sprite_frames = frames
		mr_ani.centered = true
		mr_ani.visible = true
	else:
		mr_ani.visible = false
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name: StringName in ACTIONS:
		var info: Dictionary = ACTIONS[action_name]
		var animation := _make_animation(action_name, int(info["frames"]), bool(info["loop"]))
		match action_name:
			&"skill1":
				_add_method_key(animation, _source_frame_time(SKILL1_HIT_START_FRAME), &"_enable_attack_box")
				_add_method_key(animation, _source_frame_time(SKILL1_HIT_END_FRAME), &"_disable_attack_box")
			&"skill2":
				_add_method_key(animation, _source_frame_time(SKILL2_HIT_START_FRAME), &"_enable_attack_box")
				_add_method_key(animation, _source_frame_time(SKILL2_HIT_END_FRAME), &"_disable_attack_box")
			&"skill3":
				_add_method_key(animation, 0.0, &"_start_skill3_travel")
				_add_method_key(animation, _source_frame_time(SKILL3_HIT_START_FRAME), &"_enable_attack_box")
				_add_method_key(animation, _source_frame_time(SKILL3_HIT_END_FRAME), &"_disable_attack_box")
			&"death":
				_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _source_frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_body_action", [action_name])
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _play_body_action(action_name: StringName) -> void:
	var info: Dictionary = ACTIONS.get(action_name, ACTIONS[&"wait"])
	if mr_ani.sprite_frames != null:
		mr_ani.visible = true
		mr_ani.position = info["offset"]
		mr_ani.play(action_name)


func ai_think() -> void:
	if (
		_busy
		or death()
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
		or _runtime_config.is_empty()
	):
		return
	var distance := absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	_face_role()
	if Time.get_ticks_msec() < _next_attack_msec:
		stop_move()
		return
	var skill_index := _current_cycle_skill()
	if not _skill_in_range(skill_index, distance):
		_move_into_skill_range(skill_index, distance)
		return
	_start_skill(skill_index)


func _current_cycle_skill() -> int:
	if not _skill_cycle_initialized:
		_skill_order = [1, 3, 2] if randi() % 2 == 0 else [2, 3, 1]
		_skill_step = 0
		_skill_cycle_initialized = true
	return int(_skill_order[_skill_step])


func _skill_in_range(skill_index: int, distance: float) -> bool:
	match skill_index:
		1:
			return distance <= 210.0
		2:
			return distance <= 195.0
		3:
			return distance >= 100.0 and distance <= 600.0
	return false


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	_face_role()
	hit_name = "hit%d" % skill_index
	_attack_hit_consumed = false
	_configure_attack_box(skill_index)
	_disable_attack_box()
	_skill_step += 1
	if _skill_step >= _skill_order.size():
		_skill_cycle_initialized = false
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_disable_attack_box()
	_busy = false
	is_attacking = false
	velocity.x = 0.0
	_next_attack_msec = Time.get_ticks_msec() + randi_range(AI_DELAY_MSEC, 4000)
	mr_player.play(&"wait")


func _configure_attack_box(skill_index: int) -> void:
	if hit_box == null:
		return
	var rectangle := hit_box.shape as RectangleShape2D
	if rectangle == null:
		rectangle = RectangleShape2D.new()
		hit_box.shape = rectangle
	if skill_index == 1:
		rectangle.size = Vector2(210.0, 155.0)
		hit_box.position = Vector2(-105.0, -77.5)
	elif skill_index == 3:
		rectangle.size = SKILL3_HIT_BOX_SIZE
		hit_box.position = SKILL3_HIT_BOX_POSITION
	else:
		rectangle.size = Vector2(195.0, 190.0)
		hit_box.position = Vector2(-97.5, -95.0)


func _start_skill3_travel() -> void:
	if death() or not _busy:
		return
	if _skill3_travel != null and is_instance_valid(_skill3_travel):
		_skill3_travel.queue_free()
	var target_x := global_position.x + 100.0 * _skill_direction
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
		target_x += -100.0 if target_x > global_position.x else 100.0
	_skill3_travel = _spawn_projectile(
		{
			"position": global_position,
			"right": _skill_direction > 0.0,
			"hit_name": "hit3",
			"attack_data": _attack_entry(&"hit3"),
			"skill_name": "WutaiGuardianLeap",
			"frame_root": ROOT.path_join("effect3_1"),
			"frame_count": 21,
			"loop_visual": false,
			"visual_offset": Vector2(-55.0, -111.8),
			"velocity": Vector2((target_x - global_position.x) / SKILL3_DURATION, -180.0),
			"acceleration": Vector2(0.0, 540.0),
			"collision_size": Vector2(2.0, 2.0),
			"collision_offset": Vector2.ZERO,
			"lifetime": SKILL3_DURATION,
			"damage_enabled": false,
			"finished_callback": Callable(self, "_finish_skill3_travel"),
		}
	)


func _finish_skill3_travel(end_position: Vector2) -> void:
	_skill3_travel = null
	if death():
		return
	global_position.x = end_position.x


func _spawn_projectile(config: Dictionary) -> WutaiMinghaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var sequence := str(config.get("frame_root", "")).get_file()
	config["owner"] = self
	if sequence.is_empty():
		config["visual_backend"] = WutaiMinghaiProjectile.VisualBackend.NONE
	else:
		config["visual_backend"] = WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES
		config["frames_resource"] = FRAMES
		config["frames_animation"] = sequence
		config["frame_root"] = ""
	config["damage_enabled"] = bool(config.get("damage_enabled", not (config["attack_data"] as Dictionary).is_empty()))
	if not projectile.configure(config):
		projectile.free()
		return null
	bullet.add_child(projectile)
	return projectile


func _attack_entry(attack_name: StringName) -> Dictionary:
	var key := str(attack_name)
	if obj_attack_dict.has(key):
		return (obj_attack_dict[key] as Dictionary).duplicate(true)
	push_error("WutaiGuardian3076 level config is missing attack %s" % attack_name)
	return {}


func _enable_attack_box() -> void:
	if hit_box != null and not _attack_hit_consumed:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _face_role() -> void:
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	_skill_direction = (
		1.0 if float(RoleProp.get_nearest_monster_target_position(global_position).x) >= global_position.x else -1.0
	)
	monster_dir.scale.x = _skill_direction
	base_damage_box.scale.x = -_skill_direction


func _move_toward_role() -> void:
	_face_role()
	velocity.x = speed * 10.0 * _skill_direction
	mr_player.play(&"walk")


func _move_into_skill_range(skill_index: int, distance: float) -> void:
	_face_role()
	var move_direction := _skill_direction
	if skill_index == 3 and distance < 100.0:
		move_direction = -move_direction
	velocity.x = speed * 10.0 * move_direction
	mr_player.play(&"walk")


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	if _attack_hit_consumed:
		return null
	var hit_target := super._on_hit_box_area_entered(area)
	if hit_target is BaseHero:
		var attack_area := hit_box.get_parent() as Area2D if hit_box != null else null
		if attack_area != null:
			hit_target.call("_on_hurt_box_area_entered", attack_area)
		_attack_hit_consumed = true
		_disable_attack_box()
	return hit_target


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _skill3_travel != null and is_instance_valid(_skill3_travel) and not death():
		global_position.x = _skill3_travel.global_position.x


func _finish_hurt_reaction(hurt_generation: int) -> void:
	super._finish_hurt_reaction(hurt_generation)
	velocity.x = 0.0


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_attack_serial += 1
	_busy = true
	if _skill3_travel != null and is_instance_valid(_skill3_travel):
		_skill3_travel.queue_free()
	_skill3_travel = null
	_disable_attack_box()
	no_grav = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()
